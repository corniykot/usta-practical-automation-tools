#target photoshop
app.bringToFront();

(function () {
    var oldUnits = app.preferences.rulerUnits;
    var oldDialogs = app.displayDialogs;

    app.preferences.rulerUnits = Units.PIXELS;
    app.displayDialogs = DialogModes.NO;

    var folder = null;
    var logFile = null;
    var processedCount = 0;
    var skippedCount = 0;

    try {
        if (app.documents.length === 0) {
            alert("Open an A4 portrait document first.");
            return;
        }

        var doc = app.activeDocument;
        var resolution = doc.resolution;

        var docWidthMM = (doc.width.as("px") / resolution) * 25.4;
        var docHeightMM = (doc.height.as("px") / resolution) * 25.4;

        if (
            Math.abs(docWidthMM - 210) > 1 ||
            Math.abs(docHeightMM - 297) > 1
        ) {
            alert(
                "The active document is not A4 portrait.\n" +
                "Expected: 210 x 297 mm.\n" +
                "Current: " +
                docWidthMM.toFixed(1) + " x " +
                docHeightMM.toFixed(1) + " mm."
            );
            return;
        }

        folder = Folder.selectDialog("Select a folder with images");
        if (!folder) return;

        var files = folder.getFiles(function (f) {
            return (f instanceof File) &&
                /\.(jpg|jpeg|png|tif|tiff|psd|bmp)$/i.test(f.name);
        });

        if (files.length === 0) {
            alert("No supported image files were found in the selected folder.");
            return;
        }

        files.sort(function (a, b) {
            var aa = a.name.toLowerCase();
            var bb = b.name.toLowerCase();
            if (aa < bb) return -1;
            if (aa > bb) return 1;
            return 0;
        });

        logFile = createLogFile("Place_Layout_72x102");
        logLine("Files found: " + files.length);
        logLine("");

        var imageWmm = 72;
        var imageHmm = 102;

        var positions = [
            {x: 2,   y: 3},
            {x: 106, y: 3},
            {x: 2,   y: 76},
            {x: 106, y: 76},
            {x: 2,   y: 149},
            {x: 106, y: 149},
            {x: 2,   y: 222},
            {x: 106, y: 222}
        ];

        var sheetNumber = 1;
        var currentGroup = null;
        var itemsInGroup = 0;

        for (var i = 0; i < files.length; i++) {
            var layer = null;

            try {
                if (currentGroup === null) {
                    currentGroup = doc.layerSets.add();
                    currentGroup.name = "Sheet_" + padNumber(sheetNumber, 2);
                    itemsInGroup = 0;
                }

                placeFile(files[i]);

                layer = doc.activeLayer;
                layer.name = decodeURI(files[i].name).replace(/\.[^\.]+$/, "");

                ensurePortraitOrientation(layer);
                resizeLayerMM(layer, imageWmm, imageHmm);

                layer.rotate(
                    90,
                    AnchorPosition.MIDDLECENTER
                );

                moveLayerToMM(
                    layer,
                    positions[itemsInGroup].x,
                    positions[itemsInGroup].y
                );

                layer.move(
                    currentGroup,
                    ElementPlacement.INSIDE
                );

                itemsInGroup++;
                processedCount++;

                if (itemsInGroup === 8) {
                    var mergedLayer = currentGroup.merge();
                    mergedLayer.name =
                        "Sheet_" +
                        padNumber(sheetNumber, 2) +
                        "_8pcs";

                    sheetNumber++;
                    itemsInGroup = 0;
                    currentGroup = null;
                }

            } catch (fileError) {
                skippedCount++;
                safeRemoveLayer(layer);

                logLine(
                    "SKIPPED: " +
                    files[i].fsName +
                    " | " +
                    errorText(fileError)
                );

                if (currentGroup !== null && itemsInGroup === 0) {
                    try { currentGroup.remove(); } catch (ignoreEmptyGroup) {}
                    currentGroup = null;
                }
            }
        }

        if (currentGroup !== null && itemsInGroup > 0) {
            var finalCount = itemsInGroup;
            var finalLayer = currentGroup.merge();

            finalLayer.name =
                "Sheet_" +
                padNumber(sheetNumber, 2) +
                "_" +
                finalCount +
                "pcs";
        }

        finishLog();

        alert(
            "Done.\n" +
            "Processed: " + processedCount + "\n" +
            "Skipped: " + skippedCount +
            (logFile ? "\n\nLog:\n" + logFile.fsName : "")
        );

        function placeFile(file) {
            var d = new ActionDescriptor();

            d.putPath(charIDToTypeID("null"), file);
            d.putEnumerated(
                charIDToTypeID("FTcs"),
                charIDToTypeID("QCSt"),
                charIDToTypeID("Qcsa")
            );

            var offset = new ActionDescriptor();
            offset.putUnitDouble(charIDToTypeID("Hrzn"), charIDToTypeID("#Pxl"), 0);
            offset.putUnitDouble(charIDToTypeID("Vrtc"), charIDToTypeID("#Pxl"), 0);

            d.putObject(charIDToTypeID("Ofst"), charIDToTypeID("Ofst"), offset);
            executeAction(charIDToTypeID("Plc "), d, DialogModes.NO);
        }

        function ensurePortraitOrientation(layer) {
            var b = layer.bounds;
            var currentW = b[2].as("px") - b[0].as("px");
            var currentH = b[3].as("px") - b[1].as("px");

            if (currentW > currentH) {
                layer.rotate(-90, AnchorPosition.MIDDLECENTER);
            }
        }

        function resizeLayerMM(layer, widthMM, heightMM) {
            var widthPX = (widthMM / 25.4) * resolution;
            var heightPX = (heightMM / 25.4) * resolution;

            var b = layer.bounds;
            var currentW = b[2].as("px") - b[0].as("px");
            var currentH = b[3].as("px") - b[1].as("px");

            var scaleX = (widthPX / currentW) * 100;
            var scaleY = (heightPX / currentH) * 100;

            layer.resize(scaleX, scaleY, AnchorPosition.MIDDLECENTER);
        }

        function moveLayerToMM(layer, xMM, yMM) {
            var xPX = (xMM / 25.4) * resolution;
            var yPX = (yMM / 25.4) * resolution;

            var b = layer.bounds;
            var currentX = b[0].as("px");
            var currentY = b[1].as("px");

            layer.translate(xPX - currentX, yPX - currentY);
        }

        function padNumber(number, digits) {
            var s = number.toString();
            while (s.length < digits) s = "0" + s;
            return s;
        }

        function pad2(n) {
            return n < 10 ? "0" + n : "" + n;
        }

        function timestamp() {
            var d = new Date();
            return d.getFullYear() + "-" +
                pad2(d.getMonth() + 1) + "-" +
                pad2(d.getDate()) + "_" +
                pad2(d.getHours()) + "-" +
                pad2(d.getMinutes()) + "-" +
                pad2(d.getSeconds());
        }

        function createLogFile(prefix) {
            var fileName = prefix + "_log_" + timestamp() + ".txt";
            var locations = [];

            try {
                if ($.fileName) locations.push(File($.fileName).parent);
            } catch (ignoreScriptPath) {}

            locations.push(folder);

            for (var j = 0; j < locations.length; j++) {
                try {
                    var f = new File(locations[j].fsName + "/" + fileName);
                    f.encoding = "UTF8";

                    if (f.open("w")) {
                        f.writeln("Photoshop Place Layout 72x102");
                        f.writeln("Started: " + new Date().toString());
                        f.writeln("Source folder: " + folder.fsName);
                        f.writeln("");
                        f.close();
                        return f;
                    }
                } catch (ignoreCreate) {}
            }

            return null;
        }

        function logLine(text) {
            if (!logFile) return;

            try {
                logFile.encoding = "UTF8";
                if (logFile.open("a")) {
                    logFile.writeln(text);
                    logFile.close();
                }
            } catch (ignoreLog) {}
        }

        function finishLog() {
            logLine("");
            logLine("Finished: " + new Date().toString());
            logLine("Processed: " + processedCount);
            logLine("Skipped: " + skippedCount);
        }

        function safeRemoveLayer(layer) {
            if (!layer) return;
            try { layer.remove(); } catch (ignoreRemove) {}
        }

        function errorText(e) {
            var s = (e && e.message) ? e.message : String(e);
            if (e && e.line) s += " | line " + e.line;
            return s;
        }

    } catch (e) {
        alert("Fatal error: " + ((e && e.message) ? e.message : e));
    } finally {
        app.preferences.rulerUnits = oldUnits;
        app.displayDialogs = oldDialogs;
    }
})();
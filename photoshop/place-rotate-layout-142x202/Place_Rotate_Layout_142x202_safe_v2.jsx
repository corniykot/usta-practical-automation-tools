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

        logFile = createLogFile("Place_Rotate_Layout_142x202");
        logLine("Files found: " + files.length);
        logLine("");

        var imageWmm = 142;
        var imageHmm = 202;

        var positions = [
            {x: 4, y: 4},
            {x: 4, y: 148}
        ];

        var successIndex = 0;

        for (var i = 0; i < files.length; i++) {
            var layer = null;

            try {
                placeFile(files[i]);

                layer = doc.activeLayer;
                layer.name = decodeURI(files[i].name).replace(/\.[^\.]+$/, "");

                ensurePortraitOrientation(layer);
                resizeLayerMM(layer, imageWmm, imageHmm);

                layer.rotate(
                    90,
                    AnchorPosition.MIDDLECENTER
                );

                var posIndex = successIndex % 2;
                moveLayerToMM(
                    layer,
                    positions[posIndex].x,
                    positions[posIndex].y
                );

                successIndex++;
                processedCount++;

            } catch (fileError) {
                skippedCount++;
                safeRemoveLayer(layer);

                logLine(
                    "SKIPPED: " +
                    files[i].fsName +
                    " | " +
                    errorText(fileError)
                );
            }
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
                layer.rotate(90, AnchorPosition.MIDDLECENTER);
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
                        f.writeln("Photoshop Place Rotate Layout 142x202");
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
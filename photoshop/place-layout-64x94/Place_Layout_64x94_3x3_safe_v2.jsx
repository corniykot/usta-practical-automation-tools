#target photoshop
app.bringToFront();

(function () {
    var oldRulerUnits = app.preferences.rulerUnits;
    var oldDialogs = app.displayDialogs;

    app.preferences.rulerUnits = Units.PIXELS;
    app.displayDialogs = DialogModes.NO;

    var folder = null;
    var logFile = null;
    var processedCount = 0;
    var skippedCount = 0;

    try {
        if (app.documents.length === 0) {
            alert("Open an A4 portrait document first (210 x 297 mm).");
            return;
        }

        var doc = app.activeDocument;
        var RES = doc.resolution;

        function mmToPx(mm) {
            return mm * RES / 25.4;
        }

        function approx(a, b, tolerance) {
            return Math.abs(a - b) <= tolerance;
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

        function errorText(e) {
            var s = (e && e.message) ? e.message : String(e);
            if (e && e.line) s += " | line " + e.line;
            return s;
        }

        function tryCreateLogFile() {
            var fileName = "Place_Layout_64x94_3x3_log_" + timestamp() + ".txt";
            var locations = [];

            // Prefer the folder where the script itself lives.
            try {
                if ($.fileName) locations.push(File($.fileName).parent);
            } catch (ignoreScriptPath) {}

            // Fallback: selected source-images folder.
            if (folder) locations.push(folder);

            for (var i = 0; i < locations.length; i++) {
                try {
                    var f = new File(locations[i].fsName + "/" + fileName);
                    f.encoding = "UTF8";
                    if (f.open("w")) {
                        f.writeln("Photoshop Place Layout 64x94 (3x3)");
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

        function safeRemoveLayer(layer) {
            if (!layer) return;
            try { layer.remove(); } catch (ignoreRemove) {}
        }

        // Check active document: A4 portrait 210 x 297 mm.
        var docWmm = doc.width.as("mm");
        var docHmm = doc.height.as("mm");
        if (!approx(docWmm, 210, 0.7) || !approx(docHmm, 297, 0.7)) {
            var proceed = confirm(
                "Active document is " + docWmm.toFixed(1) + " x " + docHmm.toFixed(1) + " mm, not A4 portrait 210 x 297 mm.\n\nContinue anyway?"
            );
            if (!proceed) return;
        }

        folder = Folder.selectDialog("Choose folder with images for 64 x 94 mm layout");
        if (!folder) return;

        var files = folder.getFiles(function (f) {
            return (f instanceof File) && /\.(jpg|jpeg|png|tif|tiff|psd|bmp)$/i.test(f.name);
        });

        if (files.length === 0) {
            alert("No supported image files found in the selected folder.");
            return;
        }

        files.sort(function (a, b) {
            var aa = a.name.toLowerCase();
            var bb = b.name.toLowerCase();
            return aa < bb ? -1 : (aa > bb ? 1 : 0);
        });

        logFile = tryCreateLogFile();
        if (logFile) {
            logLine("Files found: " + files.length);
            logLine("");
        }

        // Layout geometry, millimeters.
        // A4 portrait: 210 x 297 mm
        // Image: 64 x 94 mm, portrait
        // Grid: 3 x 3
        // Gaps: 2 mm horizontal and vertical
        // Margins: 7 mm left/right, 5.5 mm top/bottom
        var TARGET_W_MM = 64;
        var TARGET_H_MM = 94;

        var X_MM = [7, 73, 139];
        var Y_MM = [5.5, 101.5, 197.5];

        var TARGET_W = mmToPx(TARGET_W_MM);
        var TARGET_H = mmToPx(TARGET_H_MM);

        function placeFile(file) {
            var desc = new ActionDescriptor();
            desc.putPath(charIDToTypeID("null"), file);
            desc.putEnumerated(
                charIDToTypeID("FTcs"),
                charIDToTypeID("QCSt"),
                charIDToTypeID("Qcsa")
            );
            executeAction(charIDToTypeID("Plc "), desc, DialogModes.NO);
            return doc.activeLayer;
        }

        function getBoundsPx(layer) {
            var b = layer.bounds;
            var left = b[0].as("px");
            var top = b[1].as("px");
            var right = b[2].as("px");
            var bottom = b[3].as("px");
            return {
                left: left,
                top: top,
                right: right,
                bottom: bottom,
                width: right - left,
                height: bottom - top
            };
        }

        function prepareLayer(layer) {
            var b = getBoundsPx(layer);
            if (b.width > b.height) {
                layer.rotate(90, AnchorPosition.MIDDLECENTER);
                b = getBoundsPx(layer);
            }
            var sx = (TARGET_W / b.width) * 100;
            var sy = (TARGET_H / b.height) * 100;
            layer.resize(sx, sy, AnchorPosition.MIDDLECENTER);
        }

        function moveLayerTo(layer, xMm, yMm) {
            var b = getBoundsPx(layer);
            var targetLeft = mmToPx(xMm);
            var targetTop = mmToPx(yMm);
            layer.translate(targetLeft - b.left, targetTop - b.top);
        }

        var sheetIndex = 0;
        var itemInSheet = 0;
        var group = null;

        function startSheet() {
            sheetIndex++;
            itemInSheet = 0;
            group = doc.layerSets.add();
            group.name = "Sheet_" + (sheetIndex < 10 ? "0" : "") + sheetIndex;
        }

        function finishSheet(count) {
            if (!group) return;
            doc.activeLayer = group;
            var merged = group.merge();
            merged.name = "Sheet_" + (sheetIndex < 10 ? "0" : "") + sheetIndex + "_" + count + "pcs";
            group = null;
        }

        for (var i = 0; i < files.length; i++) {
            var layer = null;

            try {
                // Broken files do not consume a slot. The next valid file uses the same position.
                if (group === null) startSheet();

                var pos = itemInSheet;
                var col = pos % 3;
                var row = Math.floor(pos / 3);

                layer = placeFile(files[i]);
                layer.name = files[i].name;

                prepareLayer(layer);
                moveLayerTo(layer, X_MM[col], Y_MM[row]);
                layer.move(group, ElementPlacement.INSIDE);

                itemInSheet++;
                processedCount++;

                if (itemInSheet === 9) finishSheet(9);

            } catch (fileError) {
                skippedCount++;
                safeRemoveLayer(layer);

                logLine(
                    "SKIPPED: " + files[i].fsName +
                    " | " + errorText(fileError)
                );

                // Remove a group created for a file that failed before anything was placed.
                if (group !== null && itemInSheet === 0) {
                    try { group.remove(); } catch (ignoreEmptyGroup) {}
                    group = null;
                    sheetIndex--;
                }
                // No rethrow: continue with the next file.
            }
        }

        if (group && itemInSheet > 0) finishSheet(itemInSheet);

        logLine("");
        logLine("Finished: " + new Date().toString());
        logLine("Processed: " + processedCount);
        logLine("Skipped: " + skippedCount);

        var summary =
            "Done.\n" +
            "Processed: " + processedCount + "\n" +
            "Skipped: " + skippedCount + "\n" +
            "Sheet layers: " + sheetIndex;

        if (logFile) {
            summary += "\n\nLog:\n" + logFile.fsName;
        } else if (skippedCount > 0) {
            summary += "\n\nWARNING: Could not create the text log file.";
        }

        alert(summary);

    } catch (e) {
        logLine("");
        logLine("FATAL ERROR: " + errorText(e));
        alert(
            "Fatal error: " + errorText(e) +
            (logFile ? "\n\nLog:\n" + logFile.fsName : "")
        );
    } finally {
        app.preferences.rulerUnits = oldRulerUnits;
        app.displayDialogs = oldDialogs;
    }
})();
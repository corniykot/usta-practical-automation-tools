#target photoshop
app.bringToFront();

(function () {
    var oldRulerUnits = app.preferences.rulerUnits;
    var oldDialogs = app.displayDialogs;

    app.preferences.rulerUnits = Units.PIXELS;
    app.displayDialogs = DialogModes.NO;

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

        // Check active document: A4 portrait 210 x 297 mm.
        var docWmm = doc.width.as("mm");
        var docHmm = doc.height.as("mm");
        if (!approx(docWmm, 210, 0.7) || !approx(docHmm, 297, 0.7)) {
            var proceed = confirm(
                "Active document is " + docWmm.toFixed(1) + " x " + docHmm.toFixed(1) + " mm, not A4 portrait 210 x 297 mm.\n\nContinue anyway?"
            );
            if (!proceed) return;
        }

        var folder = Folder.selectDialog("Choose folder with images for 64 x 94 mm layout");
        if (!folder) return;

        var files = folder.getFiles(function (f) {
            return (f instanceof File) && /\.(jpg|jpeg|png|tif|tiff|psd|bmp)$/i.test(f.name);
        });

        if (files.length === 0) {
            alert("No supported image files found in the selected folder.");
            return;
        }

        // Natural-ish filename sort.
        files.sort(function (a, b) {
            var aa = a.name.toLowerCase();
            var bb = b.name.toLowerCase();
            return aa < bb ? -1 : (aa > bb ? 1 : 0);
        });

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

            // Orientation check: landscape sources are rotated into portrait orientation.
            if (b.width > b.height) {
                layer.rotate(90, AnchorPosition.MIDDLECENTER);
                b = getBoundsPx(layer);
            }

            // Resize non-proportionally to exact physical size 64 x 94 mm,
            // matching the workflow used in the previous layout script.
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

        startSheet();

        for (var i = 0; i < files.length; i++) {
            var pos = itemInSheet; // 0..8
            var col = pos % 3;
            var row = Math.floor(pos / 3);

            var layer = placeFile(files[i]);
            layer.name = files[i].name;

            prepareLayer(layer);
            moveLayerTo(layer, X_MM[col], Y_MM[row]);

            // Keep each 9-piece sheet together, then merge it to one layer.
            layer.move(group, ElementPlacement.INSIDE);

            itemInSheet++;

            if (itemInSheet === 9) {
                finishSheet(9);
                if (i < files.length - 1) startSheet();
            }
        }

        // Merge an incomplete final sheet too.
        if (group && itemInSheet > 0) {
            finishSheet(itemInSheet);
        }

        alert(
            "Done.\n" +
            files.length + " image(s) placed.\n" +
            sheetIndex + " sheet layer(s) created.\n\n" +
            "Layout: 3 x 3, 64 x 94 mm\n" +
            "Gaps: 2 mm\n" +
            "Margins: 7 mm left/right, 5.5 mm top/bottom"
        );

    } catch (e) {
        alert("Error: " + e.message + (e.line ? "\nLine: " + e.line : ""));
    } finally {
        app.preferences.rulerUnits = oldRulerUnits;
        app.displayDialogs = oldDialogs;
    }
})();
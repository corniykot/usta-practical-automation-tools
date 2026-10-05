#target photoshop
app.bringToFront();

(function () {

    if (app.documents.length === 0) {
        alert("Open the 72 x 102 mm A4 layout first.");
        return;
    }

    var doc = app.activeDocument;

    var oldUnits = app.preferences.rulerUnits;
    var oldDialogs = app.displayDialogs;

    app.preferences.rulerUnits = Units.PIXELS;
    app.displayDialogs = DialogModes.NO;

    try {

        var RES = doc.resolution;

        function mmToPx(mm) {
            return mm * RES / 25.4;
        }

        function approx(a, b, tolerance) {
            return Math.abs(a - b) <= tolerance;
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

        function placeFile(file) {
            var desc = new ActionDescriptor();

            desc.putPath(
                charIDToTypeID("null"),
                file
            );

            desc.putEnumerated(
                charIDToTypeID("FTcs"),
                charIDToTypeID("QCSt"),
                charIDToTypeID("Qcsa")
            );

            executeAction(
                charIDToTypeID("Plc "),
                desc,
                DialogModes.NO
            );

            return doc.activeLayer;
        }

        function resizeToWidthMM(layer, widthMM) {

            var targetWidth = mmToPx(widthMM);
            var b = getBoundsPx(layer);

            var scale = (
                targetWidth /
                b.width
            ) * 100;

            layer.resize(
                scale,
                scale,
                AnchorPosition.MIDDLECENTER
            );
        }

        function moveRotatedSignature(layer, imageXmm, imageYmm) {

            // The source artwork is 72 x 102 mm portrait.
            // In the layout it is rotated 90 degrees and occupies 102 x 72 mm.
            //
            // The signature is intended to be 25 mm wide and located
            // 3 mm from the RIGHT and BOTTOM edges BEFORE rotation.
            //
            // After the same 90-degree rotation this becomes:
            // 3 mm from the LEFT edge and 3 mm from the BOTTOM edge
            // of the 102 x 72 mm placed image.

            var PLACED_H_MM = 72;
            var MARGIN_MM = 3;

            var b = getBoundsPx(layer);

            var targetLeft = mmToPx(
                imageXmm + MARGIN_MM
            );

            var targetBottom = mmToPx(
                imageYmm +
                PLACED_H_MM -
                MARGIN_MM
            );

            var targetTop =
                targetBottom -
                b.height;

            layer.translate(
                targetLeft - b.left,
                targetTop - b.top
            );
        }

        // Check active document: A4 portrait.
        var docWmm = doc.width.as("mm");
        var docHmm = doc.height.as("mm");

        if (
            !approx(docWmm, 210, 0.7) ||
            !approx(docHmm, 297, 0.7)
        ) {
            var proceed = confirm(
                "Active document is " +
                docWmm.toFixed(1) +
                " x " +
                docHmm.toFixed(1) +
                " mm, not A4 portrait 210 x 297 mm.\n\nContinue anyway?"
            );

            if (!proceed) {
                return;
            }
        }

        // Same geometry as Place Layout 72x102.
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

        // User chooses the signature/logo once.
        var signatureFile = File.openDialog(
            "Choose signature / logo file"
        );

        if (!signatureFile) {
            return;
        }

        // All 8 signatures remain separate, independently editable Smart Objects.
        var group = doc.layerSets.add();
        group.name = "Signatures_72x102_2x4";

        for (var i = 0; i < positions.length; i++) {

            // Place the source file independently each time.
            var layer = placeFile(signatureFile);

            layer.name =
                "Signature_" +
                ((i + 1) < 10 ? "0" : "") +
                (i + 1);

            // Size in the original, pre-layout orientation:
            // 25 mm wide, height proportional.
            resizeToWidthMM(
                layer,
                25
            );

            // Rotate exactly as the 72x102 artwork is rotated in the layout script.
            layer.rotate(
                90,
                AnchorPosition.MIDDLECENTER
            );

            moveRotatedSignature(
                layer,
                positions[i].x,
                positions[i].y
            );

            layer.move(
                group,
                ElementPlacement.INSIDE
            );
        }

        alert(
            "Done.\n" +
            "8 independent signatures placed.\n" +
            "Original signature width: 25 mm\n" +
            "Original right/bottom margin: 3 mm\n" +
            "Each Smart Object can be edited separately."
        );

    } catch (e) {

        alert(
            "Error: " +
            e.message +
            (e.line ? "\nLine: " + e.line : "")
        );

    } finally {

        app.preferences.rulerUnits = oldUnits;
        app.displayDialogs = oldDialogs;
    }

})();

#target photoshop
app.bringToFront();

(function () {

    if (app.documents.length === 0) {
        alert("Open the 64 x 94 mm A4 layout first.");
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

        function moveSignature(layer, imageXmm, imageYmm) {

            var IMAGE_W_MM = 64;
            var IMAGE_H_MM = 94;

            var SIGNATURE_W_MM = 25;
            var MARGIN_MM = 3;

            var b = getBoundsPx(layer);

            var signatureHeightMM =
                b.height / RES * 25.4;

            var targetXmm =
                imageXmm +
                IMAGE_W_MM -
                MARGIN_MM -
                SIGNATURE_W_MM;

            var targetYmm =
                imageYmm +
                IMAGE_H_MM -
                MARGIN_MM -
                signatureHeightMM;

            var targetX = mmToPx(targetXmm);
            var targetY = mmToPx(targetYmm);

            layer.translate(
                targetX - b.left,
                targetY - b.top
            );
        }

        // Same geometry as Place Layout 64x94 3x3.
        var X_MM = [
            7,
            73,
            139
        ];

        var Y_MM = [
            5.5,
            101.5,
            197.5
        ];

        // User chooses the signature/logo once.
        var signatureFile = File.openDialog(
            "Choose signature / logo file"
        );

        if (!signatureFile) {
            return;
        }

        // All 9 signatures stay as separate editable Smart Objects.
        var group = doc.layerSets.add();
        group.name = "Signatures_64x94_3x3";

        var index = 1;

        for (var row = 0; row < 3; row++) {

            for (var col = 0; col < 3; col++) {

                // Place the source file again each time.
                // Do not duplicate an existing Smart Object:
                // every signature must remain independently editable.
                var layer = placeFile(signatureFile);

                layer.name =
                    "Signature_" +
                    (index < 10 ? "0" : "") +
                    index;

                resizeToWidthMM(
                    layer,
                    25
                );

                moveSignature(
                    layer,
                    X_MM[col],
                    Y_MM[row]
                );

                layer.move(
                    group,
                    ElementPlacement.INSIDE
                );

                index++;
            }
        }

        alert(
            "Done.\n" +
            "9 independent signatures placed.\n" +
            "Width: 25 mm\n" +
            "Right/bottom margin: 3 mm\n" +
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

#target photoshop
app.bringToFront();

(function () {

    if (app.documents.length === 0) {
        alert("Önce 64 x 94 mm A4 yerleşimini açın.");
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

        var signatureFile = File.openDialog(
            "İmza / logo dosyasını seçin"
        );

        if (!signatureFile) {
            return;
        }

        var group = doc.layerSets.add();
        group.name = "Signatures_64x94_3x3";

        var index = 1;

        for (var row = 0; row < 3; row++) {

            for (var col = 0; col < 3; col++) {

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
            "Tamamlandı.\n" +
            "9 bağımsız imza yerleştirildi.\n" +
            "Genişlik: 25 mm\n" +
            "Sağ/alt kenar payı: 3 mm\n" +
            "Her Akıllı Nesne ayrı ayrı düzenlenebilir."
        );

    } catch (e) {

        alert(
            "Hata: " +
            e.message +
            (e.line ? "\nSatır: " + e.line : "")
        );

    } finally {

        app.preferences.rulerUnits = oldUnits;
        app.displayDialogs = oldDialogs;
    }

})();

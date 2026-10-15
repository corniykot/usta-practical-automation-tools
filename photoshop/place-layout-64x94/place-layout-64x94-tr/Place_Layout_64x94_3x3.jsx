#target photoshop
app.bringToFront();

(function () {
    var oldRulerUnits = app.preferences.rulerUnits;
    var oldDialogs = app.displayDialogs;

    app.preferences.rulerUnits = Units.PIXELS;
    app.displayDialogs = DialogModes.NO;

    try {
        if (app.documents.length === 0) {
            alert("Önce A4 dikey bir belge açın (210 x 297 mm).");
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

        var docWmm = doc.width.as("mm");
        var docHmm = doc.height.as("mm");
        if (!approx(docWmm, 210, 0.7) || !approx(docHmm, 297, 0.7)) {
            var proceed = confirm(
                "Etkin belge " + docWmm.toFixed(1) + " x " + docHmm.toFixed(1) + " mm. A4 dikey 210 x 297 mm değil.\n\nYine de devam edilsin mi?"
            );
            if (!proceed) return;
        }

        var folder = Folder.selectDialog("64 x 94 mm yerleşim için görsellerin bulunduğu klasörü seçin");
        if (!folder) return;

        var files = folder.getFiles(function (f) {
            return (f instanceof File) && /\.(jpg|jpeg|png|tif|tiff|psd|bmp)$/i.test(f.name);
        });

        if (files.length === 0) {
            alert("Seçilen klasörde desteklenen görsel dosyası bulunamadı.");
            return;
        }

        files.sort(function (a, b) {
            var aa = a.name.toLowerCase();
            var bb = b.name.toLowerCase();
            return aa < bb ? -1 : (aa > bb ? 1 : 0);
        });

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

        startSheet();

        for (var i = 0; i < files.length; i++) {
            var pos = itemInSheet;
            var col = pos % 3;
            var row = Math.floor(pos / 3);

            var layer = placeFile(files[i]);
            layer.name = files[i].name;

            prepareLayer(layer);
            moveLayerTo(layer, X_MM[col], Y_MM[row]);
            layer.move(group, ElementPlacement.INSIDE);

            itemInSheet++;

            if (itemInSheet === 9) {
                finishSheet(9);
                if (i < files.length - 1) startSheet();
            }
        }

        if (group && itemInSheet > 0) {
            finishSheet(itemInSheet);
        }

        alert(
            "Tamamlandı.\n" +
            files.length + " görsel yerleştirildi.\n" +
            sheetIndex + " sayfa katmanı oluşturuldu.\n\n" +
            "Yerleşim: 3 x 3, 64 x 94 mm\n" +
            "Boşluklar: 2 mm\n" +
            "Kenar payları: sağ/sol 7 mm, üst/alt 5,5 mm"
        );

    } catch (e) {
        alert("Hata: " + e.message + (e.line ? "\nSatır: " + e.line : ""));
    } finally {
        app.preferences.rulerUnits = oldRulerUnits;
        app.displayDialogs = oldDialogs;
    }
})();

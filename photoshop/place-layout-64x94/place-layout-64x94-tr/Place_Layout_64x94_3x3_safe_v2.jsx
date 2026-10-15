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
            if (e && e.line) s += " | satır " + e.line;
            return s;
        }

        function tryCreateLogFile() {
            var fileName = "Place_Layout_64x94_3x3_log_" + timestamp() + ".txt";
            var locations = [];

            try {
                if ($.fileName) locations.push(File($.fileName).parent);
            } catch (ignoreScriptPath) {}

            if (folder) locations.push(folder);

            for (var i = 0; i < locations.length; i++) {
                try {
                    var f = new File(locations[i].fsName + "/" + fileName);
                    f.encoding = "UTF8";
                    if (f.open("w")) {
                        f.writeln("Photoshop 64x94 Yerleşim (3x3)");
                        f.writeln("Başlangıç: " + new Date().toString());
                        f.writeln("Kaynak klasör: " + folder.fsName);
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

        var docWmm = doc.width.as("mm");
        var docHmm = doc.height.as("mm");
        if (!approx(docWmm, 210, 0.7) || !approx(docHmm, 297, 0.7)) {
            var proceed = confirm(
                "Etkin belge " + docWmm.toFixed(1) + " x " + docHmm.toFixed(1) + " mm. A4 dikey 210 x 297 mm değil.\n\nYine de devam edilsin mi?"
            );
            if (!proceed) return;
        }

        folder = Folder.selectDialog("64 x 94 mm yerleşim için görsellerin bulunduğu klasörü seçin");
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

        logFile = tryCreateLogFile();
        if (logFile) {
            logLine("Bulunan dosya: " + files.length);
            logLine("");
        }

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
                    "ATLANDI: " + files[i].fsName +
                    " | " + errorText(fileError)
                );

                if (group !== null && itemInSheet === 0) {
                    try { group.remove(); } catch (ignoreEmptyGroup) {}
                    group = null;
                    sheetIndex--;
                }
            }
        }

        if (group && itemInSheet > 0) finishSheet(itemInSheet);

        logLine("");
        logLine("Bitiş: " + new Date().toString());
        logLine("İşlenen: " + processedCount);
        logLine("Atlanan: " + skippedCount);

        var summary =
            "Tamamlandı.\n" +
            "İşlenen: " + processedCount + "\n" +
            "Atlanan: " + skippedCount + "\n" +
            "Sayfa katmanları: " + sheetIndex;

        if (logFile) {
            summary += "\n\nKayıt dosyası:\n" + logFile.fsName;
        } else if (skippedCount > 0) {
            summary += "\n\nUYARI: TXT kayıt dosyası oluşturulamadı.";
        }

        alert(summary);

    } catch (e) {
        logLine("");
        logLine("KRİTİK HATA: " + errorText(e));
        alert(
            "Kritik hata: " + errorText(e) +
            (logFile ? "\n\nKayıt dosyası:\n" + logFile.fsName : "")
        );
    } finally {
        app.preferences.rulerUnits = oldRulerUnits;
        app.displayDialogs = oldDialogs;
    }
})();

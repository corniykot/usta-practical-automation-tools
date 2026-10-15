#target photoshop

app.displayDialogs = DialogModes.NO;

var doc = app.activeDocument;
var printLayers = [];

for (var i = 0; i < doc.layers.length; i++) {
    var layer = doc.layers[i];

    if (layer.typename == "ArtLayer") {
        try {
            if (!layer.isBackgroundLayer) {
                printLayers.push(layer);
            }
        } catch (e) {
            printLayers.push(layer);
        }
    }
}

if (printLayers.length === 0) {
    alert("Yazdırılabilir üst düzey katman bulunamadı.");
    throw new Error("Yazdırılabilir katman yok");
}

var originalVisibility = [];
for (var j = 0; j < printLayers.length; j++) {
    originalVisibility[j] = printLayers[j].visible;
}

for (var k = 0; k < printLayers.length; k++) {
    printLayers[k].visible = false;
}

for (var n = 0; n < printLayers.length; n++) {
    printLayers[n].visible = true;

    try {
        doc.printOneCopy();
    } catch (e) {
        alert(
            "Katman yazdırılırken hata oluştu:\n" +
            printLayers[n].name +
            "\n\n" +
            e.message
        );
        throw e;
    }

    $.sleep(300);
    printLayers[n].visible = false;
}

for (var m = 0; m < printLayers.length; m++) {
    printLayers[m].visible = originalVisibility[m];
}

alert("Tamamlandı. Yazdırılan katman sayısı: " + printLayers.length);

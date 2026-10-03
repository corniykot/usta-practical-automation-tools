#target photoshop

app.displayDialogs = DialogModes.NO;

if (app.documents.length === 0) {
    alert("Open a document first.");
    throw new Error("No active document");
}

var doc = app.activeDocument;
var folder = Folder.selectDialog("Select a folder with images");

if (!folder) {
    throw new Error("Cancelled");
}

var files = folder.getFiles(function (f) {
    return (f instanceof File) &&
        /\.(jpg|jpeg|png|tif|tiff|psd|bmp)$/i.test(f.name);
});

if (files.length === 0) {
    alert("No supported image files were found in the selected folder.");
    throw new Error("No images");
}

files.sort(function (a, b) {
    var aa = a.name.toLowerCase();
    var bb = b.name.toLowerCase();

    if (aa < bb) return -1;
    if (aa > bb) return 1;
    return 0;
});

var oldUnits = app.preferences.rulerUnits;
app.preferences.rulerUnits = Units.PIXELS;

var resolution = doc.resolution;

// Final physical size before layout rotation
var imageWmm = 142;
var imageHmm = 202;

// After the final 90° rotation each image occupies 202 × 142 mm on A4.
var positions = [
    {x: 4, y: 4},
    {x: 4, y: 148}
];

try {
    for (var i = 0; i < files.length; i++) {
        placeFile(files[i]);

        var layer = doc.activeLayer;
        layer.name = decodeURI(files[i].name).replace(/\.[^\.]+$/, "");

        // Normalize sideways source files before applying the exact print size.
        ensurePortraitOrientation(layer);

        resizeLayerMM(layer, imageWmm, imageHmm);

        // Rotate the correctly oriented portrait artwork for the A4 top/bottom layout.
        layer.rotate(
            90,
            AnchorPosition.MIDDLECENTER
        );

        var posIndex = i % 2;

        moveLayerToMM(
            layer,
            positions[posIndex].x,
            positions[posIndex].y
        );
    }
}
finally {
    app.preferences.rulerUnits = oldUnits;
}

alert(
    "Done.\n" +
    "Placed images: " + files.length +
    "\nImage size: 142 x 202 mm\n" +
    "Layout rotation: 90 degrees\n" +
    "Layout: top / bottom\n" +
    "Landscape source files were normalized automatically."
);


// -------------------------
// PLACE
// -------------------------

function placeFile(file) {

    var d = new ActionDescriptor();

    d.putPath(
        charIDToTypeID("null"),
        file
    );

    d.putEnumerated(
        charIDToTypeID("FTcs"),
        charIDToTypeID("QCSt"),
        charIDToTypeID("Qcsa")
    );

    var offset = new ActionDescriptor();

    offset.putUnitDouble(
        charIDToTypeID("Hrzn"),
        charIDToTypeID("#Pxl"),
        0
    );

    offset.putUnitDouble(
        charIDToTypeID("Vrtc"),
        charIDToTypeID("#Pxl"),
        0
    );

    d.putObject(
        charIDToTypeID("Ofst"),
        charIDToTypeID("Ofst"),
        offset
    );

    executeAction(
        charIDToTypeID("Plc "),
        d,
        DialogModes.NO
    );
}


// -------------------------
// ORIENTATION
// -------------------------

function ensurePortraitOrientation(layer) {

    var b = layer.bounds;

    var currentW = b[2].as("px") - b[0].as("px");
    var currentH = b[3].as("px") - b[1].as("px");

    if (currentW > currentH) {
        layer.rotate(
            90,
            AnchorPosition.MIDDLECENTER
        );
    }
}


// -------------------------
// RESIZE
// -------------------------

function resizeLayerMM(layer, widthMM, heightMM) {

    var widthPX  = (widthMM  / 25.4) * resolution;
    var heightPX = (heightMM / 25.4) * resolution;

    var b = layer.bounds;

    var currentW = b[2].as("px") - b[0].as("px");
    var currentH = b[3].as("px") - b[1].as("px");

    var scaleX = (widthPX  / currentW) * 100;
    var scaleY = (heightPX / currentH) * 100;

    layer.resize(
        scaleX,
        scaleY,
        AnchorPosition.MIDDLECENTER
    );
}


// -------------------------
// MOVE
// -------------------------

function moveLayerToMM(layer, xMM, yMM) {

    var xPX = (xMM / 25.4) * resolution;
    var yPX = (yMM / 25.4) * resolution;

    var b = layer.bounds;

    var currentX = b[0].as("px");
    var currentY = b[1].as("px");

    layer.translate(
        xPX - currentX,
        yPX - currentY
    );
}

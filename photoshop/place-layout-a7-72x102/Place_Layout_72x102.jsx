#target photoshop

var oldDialogs = app.displayDialogs;
var oldUnits = app.preferences.rulerUnits;

app.displayDialogs = DialogModes.NO;

if (app.documents.length === 0) {
    alert("Open an A4 portrait document first.");
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

app.preferences.rulerUnits = Units.PIXELS;

var resolution = doc.resolution;

// Validate the active document.
// A4 portrait should be approximately 210 x 297 mm.
var docWidthMM = (doc.width.as("px") / resolution) * 25.4;
var docHeightMM = (doc.height.as("px") / resolution) * 25.4;

if (
    Math.abs(docWidthMM - 210) > 1 ||
    Math.abs(docHeightMM - 297) > 1
) {
    app.preferences.rulerUnits = oldUnits;
    app.displayDialogs = oldDialogs;

    alert(
        "The active document is not A4 portrait.\n" +
        "Expected: 210 x 297 mm.\n" +
        "Current: " +
        docWidthMM.toFixed(1) + " x " +
        docHeightMM.toFixed(1) + " mm."
    );

    throw new Error("Wrong document size");
}


// --------------------------------------------------
// PRINT SIZE
// --------------------------------------------------

// Each source image is normalized to portrait orientation,
// then resized to exactly 72 x 102 mm.
// It is rotated 90 degrees for the A4 layout,
// so its occupied size on the sheet is 102 x 72 mm.

var imageWmm = 72;
var imageHmm = 102;


// --------------------------------------------------
// A4 LAYOUT: 8 IMAGES
// --------------------------------------------------
//
// Horizontal:
// 2 + 102 + 2 + 102 + 2 = 210 mm
//
// Vertical:
// 3 + 72 + 1 + 72 + 1 + 72 + 1 + 72 + 3 = 297 mm
//
// Side margins:       2 mm
// Column gap:         2 mm
// Top/bottom margins: 3 mm
// Row gaps:           1 mm
//

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


// --------------------------------------------------
// PROCESS
// --------------------------------------------------

var sheetNumber = 1;
var currentGroup = null;
var itemsInGroup = 0;

try {

    for (var i = 0; i < files.length; i++) {

        // Start a new printable sheet every 8 images.
        if (itemsInGroup === 0) {
            currentGroup = doc.layerSets.add();
            currentGroup.name = "Sheet_" + padNumber(sheetNumber, 2);
        }

        placeFile(files[i]);

        var layer = doc.activeLayer;

        layer.name = decodeURI(files[i].name).replace(/\.[^\.]+$/, "");

        // If a source is sideways, rotate it before applying the exact size.
        ensurePortraitOrientation(layer);

        // Force exact print dimensions.
        resizeLayerMM(layer, imageWmm, imageHmm);

        // Rotate for the 2 x 4 A4 layout.
        layer.rotate(
            90,
            AnchorPosition.MIDDLECENTER
        );

        // Position the current image.
        moveLayerToMM(
            layer,
            positions[itemsInGroup].x,
            positions[itemsInGroup].y
        );

        // Keep the current sheet isolated from other sheets.
        layer.move(
            currentGroup,
            ElementPlacement.INSIDE
        );

        itemsInGroup++;

        // Merge each complete set of 8 into one layer.
        if (itemsInGroup === 8) {

            var mergedLayer = currentGroup.merge();

            mergedLayer.name =
                "Sheet_" +
                padNumber(sheetNumber, 2) +
                "_8pcs";

            sheetNumber++;
            itemsInGroup = 0;
            currentGroup = null;
        }
    }

    // Merge the final incomplete sheet as one layer too.
    if (currentGroup !== null) {

        var finalCount = itemsInGroup;
        var finalLayer = currentGroup.merge();

        finalLayer.name =
            "Sheet_" +
            padNumber(sheetNumber, 2) +
            "_" +
            finalCount +
            "pcs";
    }

}
finally {

    app.preferences.rulerUnits = oldUnits;
    app.displayDialogs = oldDialogs;
}

alert(
    "Done.\n" +
    "Images processed: " + files.length + "\n" +
    "Print size: 72 x 102 mm\n" +
    "Layout: 2 x 4 on A4\n" +
    "Side margins: 2 mm\n" +
    "Column gap: 2 mm\n" +
    "Top/bottom margins: 3 mm\n" +
    "Row gaps: 1 mm\n" +
    "Each set of up to 8 images was merged into one layer."
);


// --------------------------------------------------
// PLACE FILE
// --------------------------------------------------

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


// --------------------------------------------------
// ORIENTATION
// --------------------------------------------------

function ensurePortraitOrientation(layer) {

    var b = layer.bounds;

    var currentW =
        b[2].as("px") -
        b[0].as("px");

    var currentH =
        b[3].as("px") -
        b[1].as("px");

    if (currentW > currentH) {

        layer.rotate(
            90,
            AnchorPosition.MIDDLECENTER
        );
    }
}


// --------------------------------------------------
// RESIZE TO EXACT MILLIMETRES
// --------------------------------------------------

function resizeLayerMM(layer, widthMM, heightMM) {

    var widthPX =
        (widthMM / 25.4) *
        resolution;

    var heightPX =
        (heightMM / 25.4) *
        resolution;

    var b = layer.bounds;

    var currentW =
        b[2].as("px") -
        b[0].as("px");

    var currentH =
        b[3].as("px") -
        b[1].as("px");

    var scaleX =
        (widthPX / currentW) *
        100;

    var scaleY =
        (heightPX / currentH) *
        100;

    layer.resize(
        scaleX,
        scaleY,
        AnchorPosition.MIDDLECENTER
    );
}


// --------------------------------------------------
// MOVE TO EXACT MILLIMETRE POSITION
// --------------------------------------------------

function moveLayerToMM(layer, xMM, yMM) {

    var xPX =
        (xMM / 25.4) *
        resolution;

    var yPX =
        (yMM / 25.4) *
        resolution;

    var b = layer.bounds;

    var currentX =
        b[0].as("px");

    var currentY =
        b[1].as("px");

    layer.translate(
        xPX - currentX,
        yPX - currentY
    );
}


// --------------------------------------------------
// NUMBER FORMAT
// --------------------------------------------------

function padNumber(number, digits) {

    var s = number.toString();

    while (s.length < digits) {
        s = "0" + s;
    }

    return s;
}

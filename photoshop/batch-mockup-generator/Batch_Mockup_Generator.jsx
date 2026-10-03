#target photoshop

(function () {
    if (!app.documents.length) {
        alert("Open a mockup PSD first.");
        return;
    }

    var mockup = app.activeDocument;
    var startState = mockup.activeHistoryState;
    var smartObjects = [];

    function collectSmartObjects(container, prefix) {
        for (var i = 0; i < container.layers.length; i++) {
            var layer = container.layers[i];
            var label = prefix ? prefix + " / " + layer.name : layer.name;

            if (layer.typename == "ArtLayer" && layer.kind == LayerKind.SMARTOBJECT) {
                smartObjects.push({ layer: layer, label: label });
            } else if (layer.typename == "LayerSet") {
                collectSmartObjects(layer, label);
            }
        }
    }

    collectSmartObjects(mockup, "");

    if (!smartObjects.length) {
        alert("No Smart Object layers found in the active document.");
        return;
    }

    var w = new Window("dialog", "Batch Mockup Generator");
    w.orientation = "column";
    w.alignChildren = "fill";

    var targetPanel = w.add("panel", undefined, "Mockup");
    targetPanel.orientation = "column";
    targetPanel.alignChildren = "fill";
    var names = [];
    for (var n = 0; n < smartObjects.length; n++) names.push(smartObjects[n].label);
    var target = targetPanel.add("dropdownlist", undefined, names);
    target.selection = 0;

    var inputPanel = w.add("panel", undefined, "Designs");
    inputPanel.orientation = "row";
    var inputText = inputPanel.add("edittext", undefined, "");
    inputText.characters = 42;
    var inputBrowse = inputPanel.add("button", undefined, "Browse");

    var fitPanel = w.add("panel", undefined, "Placement");
    fitPanel.orientation = "row";
    var fit = fitPanel.add("radiobutton", undefined, "Fit");
    var fill = fitPanel.add("radiobutton", undefined, "Fill");
    fit.value = true;

    var outputPanel = w.add("panel", undefined, "Output");
    outputPanel.orientation = "row";
    var outputText = outputPanel.add("edittext", undefined, "");
    outputText.characters = 42;
    var outputBrowse = outputPanel.add("button", undefined, "Browse");

    var formatPanel = w.add("panel", undefined, "Format");
    formatPanel.orientation = "row";
    var format = formatPanel.add("dropdownlist", undefined, ["JPEG", "PNG"]);
    format.selection = 0;
    formatPanel.add("statictext", undefined, "JPEG quality:");
    var quality = formatPanel.add("edittext", undefined, "10");
    quality.characters = 3;

    inputBrowse.onClick = function () {
        var f = Folder.selectDialog("Choose the folder containing design files");
        if (f) inputText.text = f.fsName;
    };

    outputBrowse.onClick = function () {
        var f = Folder.selectDialog("Choose the output folder");
        if (f) outputText.text = f.fsName;
    };

    var buttons = w.add("group");
    buttons.alignment = "right";
    buttons.add("button", undefined, "Cancel", {name:"cancel"});
    buttons.add("button", undefined, "Generate", {name:"ok"});

    if (w.show() != 1) return;

    var inputFolder = new Folder(inputText.text);
    var outputFolder = new Folder(outputText.text);

    if (!inputFolder.exists) {
        alert("Choose a valid designs folder.");
        return;
    }
    if (!outputFolder.exists) {
        alert("Choose a valid output folder.");
        return;
    }

    var q = parseInt(quality.text, 10);
    if (isNaN(q) || q < 0 || q > 12) {
        alert("JPEG quality must be from 0 to 12.");
        return;
    }

    var files = inputFolder.getFiles(function (f) {
        return f instanceof File && /\.(png|jpe?g|tif|tiff|psd)$/i.test(f.name);
    });

    if (!files.length) {
        alert("No PNG, JPEG, TIFF or PSD design files found.");
        return;
    }

    function baseName(file) {
        return decodeURI(file.name).replace(/\.[^.]+$/, "");
    }

    function selectLayer(layer) {
        mockup.activeLayer = layer;
    }

    function editSmartObject() {
        executeAction(stringIDToTypeID("placedLayerEditContents"), undefined, DialogModes.NO);
    }

    function placeFile(file) {
        var d = new ActionDescriptor();
        d.putPath(charIDToTypeID("null"), file);
        executeAction(charIDToTypeID("Plc "), d, DialogModes.NO);
    }

    function fitPlacedLayer(mode) {
        var doc = app.activeDocument;
        var layer = doc.activeLayer;
        var b = layer.bounds;
        var lw = b[2].as("px") - b[0].as("px");
        var lh = b[3].as("px") - b[1].as("px");
        var dw = doc.width.as("px");
        var dh = doc.height.as("px");

        if (lw <= 0 || lh <= 0) throw new Error("Placed design has invalid bounds.");

        var sx = dw / lw * 100;
        var sy = dh / lh * 100;
        var scale = mode == "fill" ? Math.max(sx, sy) : Math.min(sx, sy);
        layer.resize(scale, scale, AnchorPosition.MIDDLECENTER);

        b = layer.bounds;
        var cx = (b[0].as("px") + b[2].as("px")) / 2;
        var cy = (b[1].as("px") + b[3].as("px")) / 2;
        layer.translate(dw / 2 - cx, dh / 2 - cy);
    }

    function replaceSmartObjectContents(targetLayer, file, mode) {
        selectLayer(targetLayer);
        editSmartObject();

        var soDoc = app.activeDocument;
        var oldUnits = app.preferences.rulerUnits;
        app.preferences.rulerUnits = Units.PIXELS;

        try {
            for (var i = 0; i < soDoc.layers.length; i++) soDoc.layers[i].visible = false;
            placeFile(file);
            fitPlacedLayer(mode);
            soDoc.activeLayer.visible = true;
            soDoc.save();
            soDoc.close(SaveOptions.SAVECHANGES);
        } catch (e) {
            try { soDoc.close(SaveOptions.DONOTSAVECHANGES); } catch (_) {}
            throw e;
        } finally {
            app.preferences.rulerUnits = oldUnits;
        }
    }

    function saveOutput(file, type, jpegQuality) {
        var name = baseName(file);
        if (type == "JPEG") {
            var out = new File(outputFolder.fsName + "/" + name + ".jpg");
            var opts = new JPEGSaveOptions();
            opts.quality = jpegQuality;
            opts.embedColorProfile = true;
            opts.formatOptions = FormatOptions.STANDARDBASELINE;
            mockup.saveAs(out, opts, true, Extension.LOWERCASE);
        } else {
            var outPng = new File(outputFolder.fsName + "/" + name + ".png");
            var png = new PNGSaveOptions();
            mockup.saveAs(outPng, png, true, Extension.LOWERCASE);
        }
    }

    var chosen = smartObjects[target.selection.index].layer;
    var mode = fill.value ? "fill" : "fit";
    var type = format.selection.text;
    var done = 0;

    try {
        for (var f = 0; f < files.length; f++) {
            mockup.activeHistoryState = startState;
            replaceSmartObjectContents(chosen, files[f], mode);
            app.activeDocument = mockup;
            saveOutput(files[f], type, q);
            done++;
        }
    } catch (e) {
        try { app.activeDocument = mockup; mockup.activeHistoryState = startState; } catch (_) {}
        alert("Batch Mockup Generator stopped after " + done + " file(s).\n\n" + e.message);
        return;
    }

    try { app.activeDocument = mockup; mockup.activeHistoryState = startState; } catch (_) {}
    alert("Done. Generated " + done + " mockup(s).");
})();
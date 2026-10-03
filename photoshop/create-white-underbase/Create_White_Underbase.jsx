#target photoshop

(function () {
    if (!app.documents.length) {
        alert("Open a document first.");
        return;
    }

    var doc = app.activeDocument;
    var originalLayer = doc.activeLayer;
    var originalDialogs = app.displayDialogs;
    app.displayDialogs = DialogModes.NO;

    function buildDialog() {
        var w = new Window("dialog", "Create White Underbase");
        w.orientation = "column";
        w.alignChildren = "fill";

        var src = w.add("panel", undefined, "Source");
        src.orientation = "column";
        src.alignChildren = "left";
        var activeRB = src.add("radiobutton", undefined, "Active layer transparency");
        var whiteRB = src.add("radiobutton", undefined, "Everything except white");
        activeRB.value = true;

        var opts = w.add("group");
        opts.orientation = "column";
        opts.alignChildren = "left";

        var chokeG = opts.add("group");
        chokeG.add("statictext", undefined, "Choke:");
        var choke = chokeG.add("edittext", undefined, "1");
        choke.characters = 5;
        chokeG.add("statictext", undefined, "px");

        var tolG = opts.add("group");
        tolG.add("statictext", undefined, "White tolerance:");
        var tolerance = tolG.add("edittext", undefined, "5");
        tolerance.characters = 5;
        tolerance.enabled = false;

        activeRB.onClick = function () { tolerance.enabled = false; };
        whiteRB.onClick = function () { tolerance.enabled = true; };

        var buttons = w.add("group");
        buttons.alignment = "right";
        buttons.add("button", undefined, "Cancel", {name:"cancel"});
        buttons.add("button", undefined, "Create White", {name:"ok"});

        if (w.show() != 1) return null;

        var c = Number(choke.text);
        var t = Number(tolerance.text);
        if (isNaN(c) || c < 0 || Math.floor(c) != c) {
            alert("Choke must be a whole number of pixels, 0 or greater.");
            return false;
        }
        if (isNaN(t) || t < 0 || t > 255 || Math.floor(t) != t) {
            alert("White tolerance must be a whole number from 0 to 255.");
            return false;
        }
        return { mode: activeRB.value ? "layer" : "white", choke: c, tolerance: t };
    }

    function selectionExists(d) {
        try {
            var b = d.selection.bounds;
            return true;
        } catch (e) {
            return false;
        }
    }

    function loadActiveLayerTransparency() {
        if (doc.activeLayer.typename != "ArtLayer") {
            throw new Error("Select a normal artwork layer first.");
        }
        var d = new ActionDescriptor();
        var r = new ActionReference();
        r.putProperty(charIDToTypeID("Chnl"), charIDToTypeID("fsel"));
        d.putReference(charIDToTypeID("null"), r);
        var r2 = new ActionReference();
        r2.putEnumerated(charIDToTypeID("Chnl"), charIDToTypeID("Chnl"), charIDToTypeID("Trsp"));
        d.putReference(charIDToTypeID("T   "), r2);
        executeAction(charIDToTypeID("setd"), d, DialogModes.NO);
    }

    function selectEverythingExceptWhite(tol) {
        // Color Range: sample pure white and select its inverse.
        var d = new ActionDescriptor();
        d.putInteger(charIDToTypeID("Fzns"), tol);
        var mn = new ActionDescriptor();
        mn.putDouble(charIDToTypeID("Rd  "), 255);
        mn.putDouble(charIDToTypeID("Grn "), 255);
        mn.putDouble(charIDToTypeID("Bl  "), 255);
        d.putObject(charIDToTypeID("Mnm "), charIDToTypeID("RGBC"), mn);
        var mx = new ActionDescriptor();
        mx.putDouble(charIDToTypeID("Rd  "), 255);
        mx.putDouble(charIDToTypeID("Grn "), 255);
        mx.putDouble(charIDToTypeID("Bl  "), 255);
        d.putObject(charIDToTypeID("Mxm "), charIDToTypeID("RGBC"), mx);
        d.putBoolean(charIDToTypeID("Invr"), true);
        executeAction(charIDToTypeID("ClrR"), d, DialogModes.NO);
    }

    function existingWhiteChannel() {
        for (var i = 0; i < doc.channels.length; i++) {
            if (doc.channels[i].name.toLowerCase() == "white") return doc.channels[i];
        }
        return null;
    }

    function makeWhiteSpot() {
        var ch = doc.channels.add();
        ch.name = "White";
        ch.kind = ChannelType.SPOTCOLOR;
        var spot = new SolidColor();
        spot.rgb.red = 255;
        spot.rgb.green = 255;
        spot.rgb.blue = 255;
        ch.color = spot;
        ch.opacity = 100;
        return ch;
    }

    try {
        var settings = buildDialog();
        if (!settings) return;

        var oldWhite = existingWhiteChannel();
        if (oldWhite) {
            if (!confirm("A White channel already exists.\n\nReplace it?")) return;
        }

        if (settings.mode == "layer") loadActiveLayerTransparency();
        else selectEverythingExceptWhite(settings.tolerance);

        if (!selectionExists(doc)) {
            alert("No printable artwork was found.");
            return;
        }

        if (settings.choke > 0) {
            try {
                doc.selection.contract(settings.choke);
            } catch (e) {
                alert("The selection is too small for a " + settings.choke + " px choke.");
                return;
            }
            if (!selectionExists(doc)) {
                alert("The selection disappeared after applying the choke.");
                return;
            }
        }

        if (oldWhite) oldWhite.remove();

        var white = makeWhiteSpot();
        doc.activeChannels = [white];

        var ink = new SolidColor();
        ink.gray.gray = 0;
        doc.selection.fill(ink, ColorBlendMode.NORMAL, 100, false);
        doc.selection.deselect();

        // Keep the spot channel visible together with the composite for inspection.
        var visible = [];
        for (var i = 0; i < doc.channels.length; i++) {
            if (doc.channels[i].kind == ChannelType.COMPONENT || doc.channels[i] == white) visible.push(doc.channels[i]);
        }
        try { doc.activeChannels = visible; } catch (e) { doc.activeChannels = [white]; }

        doc.activeLayer = originalLayer;
        alert("White underbase created.");
    } catch (e) {
        try { doc.selection.deselect(); } catch (_) {}
        try { doc.activeLayer = originalLayer; } catch (_) {}
        alert("White Underbase error:\n" + e.message);
    } finally {
        app.displayDialogs = originalDialogs;
    }
})();
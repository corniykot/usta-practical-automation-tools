#target photoshop

(function () {
    if (!app.documents.length) {
        alert("Open a document first.");
        return;
    }

    var doc = app.activeDocument;
    var originalChannels;
    try { originalChannels = doc.activeChannels; } catch (e) { originalChannels = null; }

    function kindName(ch) {
        try {
            if (ch.kind == ChannelType.SPOTCOLOR) return "SPOT";
            if (ch.kind == ChannelType.MASKEDAREA || ch.kind == ChannelType.SELECTEDAREA) return "ALPHA";
            if (ch.kind == ChannelType.COMPONENT) return "COMPONENT";
        } catch (e) {}
        return "OTHER";
    }

    function isEmpty(ch) {
        var temp = null;
        try {
            temp = doc.selection;
            doc.selection.load(ch, SelectionType.REPLACE);
            var b = doc.selection.bounds;
            doc.selection.deselect();
            return false;
        } catch (e) {
            try { doc.selection.deselect(); } catch (_) {}
            return true;
        }
    }

    function modeName() {
        try {
            switch (doc.mode) {
                case DocumentMode.CMYK: return "CMYK";
                case DocumentMode.RGB: return "RGB";
                case DocumentMode.GRAYSCALE: return "Grayscale";
                case DocumentMode.LAB: return "Lab";
                case DocumentMode.BITMAP: return "Bitmap";
                case DocumentMode.MULTICHANNEL: return "Multichannel";
                case DocumentMode.DUOTONE: return "Duotone";
                case DocumentMode.INDEXEDCOLOR: return "Indexed Color";
            }
        } catch (e) {}
        return "Unknown";
    }

    var spots = [];
    var alphas = [];
    var empty = [];
    var other = [];

    for (var i = 0; i < doc.channels.length; i++) {
        var ch = doc.channels[i];
        var k = kindName(ch);

        if (k == "COMPONENT") continue;

        var blank = isEmpty(ch);
        var item = { name: ch.name, empty: blank };

        if (k == "SPOT") spots.push(item);
        else if (k == "ALPHA") alphas.push(item);
        else other.push(item);

        if (blank) empty.push(ch.name);
    }

    try {
        if (originalChannels) doc.activeChannels = originalChannels;
    } catch (e) {}

    var lines = [];
    lines.push("SPOT CHANNEL CHECK");
    lines.push("");
    lines.push("Document mode: " + modeName());
    lines.push("");

    lines.push("Spot channels:");
    if (!spots.length) {
        lines.push("None");
    } else {
        for (var s = 0; s < spots.length; s++) {
            lines.push(spots[s].name + (spots[s].empty ? " — EMPTY" : " — OK"));
        }
    }

    lines.push("");
    lines.push("Alpha channels:");
    if (!alphas.length) {
        lines.push("None");
    } else {
        for (var a = 0; a < alphas.length; a++) {
            lines.push(alphas[a].name + (alphas[a].empty ? " — EMPTY" : " — CHECK"));
        }
    }

    if (other.length) {
        lines.push("");
        lines.push("Other channels:");
        for (var o = 0; o < other.length; o++) {
            lines.push(other[o].name + (other[o].empty ? " — EMPTY" : " — CHECK"));
        }
    }

    lines.push("");
    lines.push("Empty channels:");
    if (!empty.length) lines.push("None");
    else for (var e = 0; e < empty.length; e++) lines.push(empty[e]);

    lines.push("");
    lines.push(spots.length + " spot channel" + (spots.length == 1 ? "" : "s") + " found.");

    var w = new Window("dialog", "Spot Channel Check");
    w.orientation = "column";
    w.alignChildren = "fill";
    var box = w.add("edittext", undefined, lines.join("\r"), {multiline:true, scrolling:true});
    box.preferredSize = [430, 330];
    box.readonly = true;

    var buttons = w.add("group");
    buttons.alignment = "right";
    var copy = buttons.add("button", undefined, "Copy");
    buttons.add("button", undefined, "Close", {name:"ok"});

    copy.onClick = function () {
        try {
            box.active = true;
            box.selection = [0, box.text.length];
            app.system('cmd /c echo ' + '"' + box.text.replace(/"/g, '""').replace(/\r/g, ' & echo ') + '" | clip');
        } catch (e) {
            alert("Could not copy automatically. Select the report text and copy it manually.");
        }
    };

    w.show();
})();
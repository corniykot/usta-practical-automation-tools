#target photoshop

(function () {
    if (!app.documents.length) {
        alert("Open a document first.");
        return;
    }

    var doc = app.activeDocument;
    var originalActiveChannels = doc.activeChannels;
    var items = [];

    function typeOf(ch) {
        if (ch.kind == ChannelType.SPOTCOLOR) return "SPOT";
        if (ch.kind == ChannelType.MASKEDAREA || ch.kind == ChannelType.SELECTEDAREA) return "ALPHA";
        return "OTHER";
    }

    function isEmpty(ch) {
        var old = doc.activeChannels;
        try {
            doc.selection.deselect();
            doc.activeChannels = [ch];
            doc.selection.load(ch, SelectionType.REPLACE);
            try {
                var b = doc.selection.bounds;
                doc.selection.deselect();
                doc.activeChannels = old;
                return false;
            } catch (_) {
                doc.selection.deselect();
                doc.activeChannels = old;
                return true;
            }
        } catch (e) {
            try { doc.selection.deselect(); } catch (_) {}
            try { doc.activeChannels = old; } catch (_) {}
            return null;
        }
    }

    for (var i = 0; i < doc.channels.length; i++) {
        var ch = doc.channels[i];
        if (ch.kind == ChannelType.COMPONENT) continue;
        items.push({
            channel: ch,
            originalName: ch.name,
            type: typeOf(ch),
            empty: isEmpty(ch)
        });
    }

    try { doc.activeChannels = originalActiveChannels; } catch (_) {}

    if (!items.length) {
        alert("Spot Channel Manager\n\nDocument mode: " + doc.mode + "\nNo spot or alpha channels found.");
        return;
    }

    var w = new Window("dialog", "Spot Channel Manager");
    w.orientation = "column";
    w.alignChildren = "fill";

    var info = w.add("statictext", undefined, "Document mode: " + doc.mode);
    info.alignment = "left";

    var head = w.add("group");
    var h1 = head.add("statictext", undefined, "Type"); h1.preferredSize.width = 55;
    var h2 = head.add("statictext", undefined, "Status"); h2.preferredSize.width = 55;
    var h3 = head.add("statictext", undefined, "Current name"); h3.preferredSize.width = 145;
    var h4 = head.add("statictext", undefined, "New name"); h4.preferredSize.width = 180;
    head.add("statictext", undefined, "Alpha → Spot");

    var rows = [];
    for (var j = 0; j < items.length; j++) {
        var row = w.add("group");
        var t = row.add("statictext", undefined, items[j].type); t.preferredSize.width = 55;
        var status = items[j].empty === true ? "EMPTY" : (items[j].empty === false ? "OK" : "CHECK");
        var s = row.add("statictext", undefined, status); s.preferredSize.width = 55;
        var old = row.add("statictext", undefined, items[j].originalName); old.preferredSize.width = 145;
        var edit = row.add("edittext", undefined, items[j].originalName); edit.preferredSize.width = 180;
        var convert = row.add("checkbox", undefined, "");
        convert.enabled = (items[j].type == "ALPHA");
        rows.push({nameEdit: edit, convert: convert});
    }

    var note = w.add("statictext", undefined,
        "Inspection is automatic. Nothing changes until Apply.",
        {multiline:true});
    note.preferredSize.width = 540;

    var buttons = w.add("group");
    buttons.alignment = "right";
    buttons.add("button", undefined, "Close", {name:"cancel"});
    buttons.add("button", undefined, "Apply", {name:"ok"});

    if (w.show() != 1) return;

    var wanted = [];
    for (var k = 0; k < items.length; k++) {
        var n = rows[k].nameEdit.text.replace(/^\s+|\s+$/g, "");
        if (!n.length) {
            alert("Channel names cannot be empty.");
            return;
        }
        wanted.push(n);
    }

    for (var a = 0; a < wanted.length; a++) {
        for (var b = a + 1; b < wanted.length; b++) {
            if (wanted[a].toLowerCase() == wanted[b].toLowerCase()) {
                alert("Duplicate channel name: " + wanted[a]);
                return;
            }
        }
    }

    var stamp = (new Date()).getTime();
    try {
        for (var r = 0; r < items.length; r++) {
            if (items[r].channel.name != wanted[r])
                items[r].channel.name = "__USTA_TMP_" + stamp + "_" + r + "__";
        }
        for (var r2 = 0; r2 < items.length; r2++) {
            if (items[r2].channel.name != wanted[r2])
                items[r2].channel.name = wanted[r2];
        }

        var renamed = 0, converted = 0;
        for (var m = 0; m < items.length; m++) {
            if (items[m].originalName != wanted[m]) renamed++;
            if (items[m].type == "ALPHA" && rows[m].convert.value) {
                items[m].channel.kind = ChannelType.SPOTCOLOR;
                var spot = new SolidColor();
                spot.rgb.red = 255; spot.rgb.green = 0; spot.rgb.blue = 255;
                try { items[m].channel.color = spot; } catch (_) {}
                try { items[m].channel.opacity = 100; } catch (_) {}
                converted++;
            }
        }

        alert("Spot Channel Manager\n\nRenamed: " + renamed +
              "\nConverted Alpha → Spot: " + converted);
    } catch (e) {
        for (var x = 0; x < items.length; x++) {
            try { items[x].channel.name = items[x].originalName; } catch (_) {}
        }
        alert("Spot Channel Manager error:\n" + e.message);
    } finally {
        try { doc.activeChannels = originalActiveChannels; } catch (_) {}
    }
})();
#target photoshop

(function () {
    if (!app.documents.length) {
        alert("Open a document first.");
        return;
    }

    var doc = app.activeDocument;
    var items = [];

    function channelType(ch) {
        if (ch.kind == ChannelType.SPOTCOLOR) return "SPOT";
        if (ch.kind == ChannelType.MASKEDAREA || ch.kind == ChannelType.SELECTEDAREA) return "ALPHA";
        return "OTHER";
    }

    for (var i = 0; i < doc.channels.length; i++) {
        var ch = doc.channels[i];
        if (ch.kind == ChannelType.COMPONENT) continue;
        items.push({
            channel: ch,
            originalName: ch.name,
            type: channelType(ch)
        });
    }

    if (!items.length) {
        alert("No spot or alpha channels found.");
        return;
    }

    var w = new Window("dialog", "Spot Channel Manager");
    w.orientation = "column";
    w.alignChildren = "fill";

    var head = w.add("group");
    var h1 = head.add("statictext", undefined, "Type"); h1.preferredSize.width = 55;
    var h2 = head.add("statictext", undefined, "Current name"); h2.preferredSize.width = 145;
    var h3 = head.add("statictext", undefined, "New name"); h3.preferredSize.width = 180;
    head.add("statictext", undefined, "Alpha → Spot");

    var rows = [];
    for (var j = 0; j < items.length; j++) {
        var row = w.add("group");
        var t = row.add("statictext", undefined, items[j].type); t.preferredSize.width = 55;
        var old = row.add("statictext", undefined, items[j].originalName); old.preferredSize.width = 145;
        var edit = row.add("edittext", undefined, items[j].originalName); edit.preferredSize.width = 180;
        var convert = row.add("checkbox", undefined, "");
        convert.enabled = (items[j].type == "ALPHA");
        rows.push({nameEdit: edit, convert: convert});
    }

    var note = w.add("statictext", undefined,
        "Nothing changes until Apply. Alpha → Spot is always a deliberate choice.",
        {multiline:true});
    note.preferredSize.width = 510;

    var buttons = w.add("group");
    buttons.alignment = "right";
    buttons.add("button", undefined, "Cancel", {name:"cancel"});
    buttons.add("button", undefined, "Apply", {name:"ok"});

    if (w.show() != 1) return;

    // Validate all requested names before modifying anything.
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

    // Rename in two passes through temporary unique names so swaps such as
    // "White" <-> "Spot 1" do not collide halfway through.
    var stamp = (new Date()).getTime();
    try {
        for (var r = 0; r < items.length; r++) {
            if (items[r].channel.name != wanted[r]) {
                items[r].channel.name = "__USTA_TMP_" + stamp + "_" + r + "__";
            }
        }

        for (var r2 = 0; r2 < items.length; r2++) {
            if (items[r2].channel.name != wanted[r2]) {
                items[r2].channel.name = wanted[r2];
            }
        }

        var converted = 0;
        var renamed = 0;

        for (var m = 0; m < items.length; m++) {
            if (items[m].originalName != wanted[m]) renamed++;

            if (items[m].type == "ALPHA" && rows[m].convert.value) {
                items[m].channel.kind = ChannelType.SPOTCOLOR;

                // Neutral preview color only. The actual production ink identity
                // is determined by the channel name / downstream workflow.
                var spot = new SolidColor();
                spot.rgb.red = 255;
                spot.rgb.green = 0;
                spot.rgb.blue = 255;
                try { items[m].channel.color = spot; } catch (e) {}
                try { items[m].channel.opacity = 100; } catch (e) {}
                converted++;
            }
        }

        alert(
            "Spot Channel Manager\n\n" +
            "Renamed: " + renamed + "\n" +
            "Converted Alpha → Spot: " + converted
        );
    } catch (e) {
        // Best-effort restoration of original names if anything fails.
        for (var x = 0; x < items.length; x++) {
            try { items[x].channel.name = items[x].originalName; } catch (_) {}
        }
        alert("Spot Channel Manager error:\n" + e.message);
    }
})();
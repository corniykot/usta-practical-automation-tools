# USTA Smart Node Cleaner — CorelDRAW Node Reduction & Bézier Curve Cleanup

**Reduce unnecessary nodes in CorelDRAW without blindly smoothing away the details you need.**

Imported SVG, PDF and other vector artwork, bitmap traces, and text converted to curves can leave you with hundreds of extra Bézier nodes. The result is familiar: curves become tedious to edit, and files take more work to prepare for laser cutting, plotting, engraving, or print production.

CorelDRAW already includes **Reduce Nodes** and curve-smoothing tools. The difficult part is choosing how much simplification is acceptable: removing more nodes can also reshape a contour. **USTA Smart Node Cleaner** takes a different, tolerance-based approach. It tests candidate node deletions against the **unchanged original curve** and keeps only changes that stay within the specified **sampled deviation**.

A practical CorelDRAW 2018 VBA macro for designers and production workshops who want **fewer nodes, with measurable control over shape changes** — not a promise of mathematically identical geometry.

## When to use it

- **Traced logos and bitmap-to-vector artwork** with excessive control points.
- **Imported vector paths** that are difficult to edit or clean up.
- **Lettering converted to curves** before production.
- **Laser, CNC and plotter preparation** where manageable contours matter.

It works on one selected CorelDRAW Curve object at a time. It does not join disconnected paths, repair open contours, or automatically optimize cutting order.

## Versions and status

- **v0.73 — current tested build:** CorelDRAW 2018 VBA UserForm, two-sided sampled tolerance comparison, repeated passes over closed curves, support links and adjustable attempt limit. The project file is available as [UstaSmartNodeCleaner.gms](UstaSmartNodeCleaner.gms).
- **v0.7 — previous version:** kept as historical engine and UI source.
- **v0.6 — stable fallback:** text-prompt version retained for rollback.

## How it differs from CorelDRAW's Reduce Nodes

The built-in command is useful for quick cleanup. USTA is for cases where you want to **set a deviation tolerance** and compare each proposed deletion to the original geometry instead of applying an unspecified amount of smoothing. The trade-off is speed: repeated candidate testing can be slow on complex curves.

## What it does

1. Accepts **one selected Curve object**.
2. Duplicates it internally and attempts node removal, working backward through subpaths.
3. Samples the original and candidate subpath (16 samples per segment).
4. Compares sampled polylines in **both directions** and accepts a removal only when the measured deviation is within the tolerance.
5. Replaces the selected object with the result. **Ctrl+Z** can undo the command group.

The original geometry stays the fixed comparison reference throughout processing. The tolerance is a **sampled approximation**, not a mathematical guarantee of maximum Bézier deviation.

## Settings

| Setting | Default | Range / meaning |
|---|---:|---|
| Maximum curve deviation | 0.05 mm | Greater than 0, up to 2 mm |
| Quick | 512 attempts | Preset |
| Medium | 1024 attempts | Preset |
| Serious | 2048 attempts | Preset; warning |
| Extreme | 4096 attempts | Preset; warning |
| Manual attempt limit | 512 | 128–4096 |

**For best results, clean complex artwork one object at a time.** This keeps each cleanup focused and avoids unnecessary processing.

**4096 attempts is a per-run safety limit, not a total cleanup limit.** If the attempt limit is reached and the curve still has redundant nodes, simply run Smart Node Cleaner again on the resulting curve. Repeat as needed.

Higher attempt limits can take longer, especially on complex geometry. The limit exists to keep processing manageable, not to restrict how far a curve can be simplified.

## Install v0.73 (CorelDRAW 2018)

**Direct installation:** Download [UstaSmartNodeCleaner.gms](UstaSmartNodeCleaner.gms), close CorelDRAW, and copy it to the applicable CorelDRAW VBA macro/GMS folder for your installation. Start CorelDRAW and run the USTA Smart Node Cleaner macro. If the available entry point or displayed version differs, verify the macro project's embedded VBA code: the GMS binary was uploaded separately from the current source files.

**Install from published source:**

- [USTA_Node_Cleaner_v0_73_Engine.bas](USTA_Node_Cleaner_v0_73_Engine.bas) — current VBA engine, entry point `UstaSmartNodeCleanerV073`.
- [frmUSTANodeCleaner_v0_73_CODE.txt](frmUSTANodeCleaner_v0_73_CODE.txt) — matching UserForm code (controls created at runtime).

1. Open CorelDRAW 2018, then the VBA editor (**Alt+F11**).
2. In a VBA project, import the engine with **File → Import File**.
3. Create a blank UserForm, set its **(Name)** to `frmUSTANodeCleaner`, and paste the form code into the form's code window (**F7**).
4. Compile with **Debug → Compile VBAProject**.
5. Select one curve and run `UstaSmartNodeCleanerV073`.

Do not paste the engine source into the form code window. The blank design-time form is expected because controls are created during `UserForm_Initialize`.

## Download and code signing

The committed GMS file is the current project artifact, **not a signed Windows installer**. We are preparing a separate installer for a future release. No signing or SignPath Foundation endorsement is currently claimed.

See [Code signing policy](../../CODE_SIGNING.md) for intended release provenance and verification. Automated, reproducible installer builds and a downloadable Windows release still need to be implemented before a signing request.

## Production Notes

USTA Smart Node Cleaner is designed for practical vector cleanup in CorelDRAW, with controlled node reduction and predictable workflow behaviour.

- **Work with individual curves.** Process one selected Curve object at a time for better control over the result. Convert other object types to curves before cleaning.
- **You control the precision.** Set the maximum sampled deviation to suit your artwork. The tool evaluates proposed node removals against the original geometry rather than relying on unrestricted smoothing.
- **Preserve important geometry.** Open-path endpoints are retained; closed paths are checked cyclically.
- **Allow time for complex artwork.** Each candidate is evaluated geometrically, so processing time depends on curve complexity and the selected attempt limit. For large projects, work through objects individually.
- **Keep your workflow reversible.** The cleaned curve replaces the selected object, and Ctrl+Z restores the previous state.

**Compatibility:** Tested by the developer in CorelDRAW 2018 with VBA. Installation uses CorelDRAW's built-in VBA editor; compatibility with other CorelDRAW versions has not been verified.

## Further reading

- [CorelDRAW Help: adding, removing and joining nodes](https://help.coreldraw.com/CorelDRAW/540111192/Documentation-Windows/CorelDRAW-en/CorelDRAW-Add-remove-join-nodes.html) — built-in node reduction and its effect on curves.
- [CorelDRAW Community: Reduce Nodes in VBA](https://community.coreldraw.com/sdk/f/code-snippets-feedback/61711/how-apply-reduce-nodes-in-vba) — practical discussion of automation, varying artwork scale and unwanted changes to appearance.

## Feedback and contact

This tool exists for actual production files, not benchmark-perfect demo curves that have never experienced a deadline. If it saves you time, I'd love to know what kind of artwork you used it on. If it behaves badly, even better — do send the CorelDRAW version, node counts before and after, tolerance, attempt limit, and a minimal reproducible curve if you can share one. Misbehaving Bézier curves deserve a fair trial, after all.

Bug reports, improvement ideas, and proposals for other practical production automations are welcome at **[usta.scripts@gmail.com](mailto:usta.scripts@gmail.com)**.

*Fewer nodes. Same curve. Less time negotiating with Bézier.*

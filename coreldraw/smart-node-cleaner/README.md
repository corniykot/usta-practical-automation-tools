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

- **v0.7 — current UI build:** graphite-and-amber UserForm, four workload presets, manual attempt limit, tolerance setting, and an in-place result. Fully tested in CorelDRAW 2018.
- **v0.6 — stable fallback:** tested macro with text prompts. Kept unchanged as a rollback option.

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

## Install v0.7 (CorelDRAW 2018)

Files in this folder:

- [`USTA_Node_Cleaner_v0_7_Engine.bas`](USTA_Node_Cleaner_v0_7_Engine.bas) — VBA engine and macro entry point.
- [`frmUSTANodeCleaner_CODE.txt`](frmUSTANodeCleaner_CODE.txt) — code for the UserForm; controls are generated at runtime.

1. Save your work and **back up your existing CorelDRAW VBA/GMS project**.
2. In CorelDRAW, open the VBA editor with **Alt+F11**.
3. Import `USTA_Node_Cleaner_v0_7_Engine.bas` using **File → Import File**.
4. In the same VBA project, choose **Insert → UserForm**.
5. In the Properties window (F4), set the form's **(Name)** to `frmUSTANodeCleaner`.
6. Open the form's code window (F7) and paste the **entire** contents of `frmUSTANodeCleaner_CODE.txt`.
7. Run **Debug → Compile VBAProject**.
8. Select one curve in CorelDRAW and run `UstaSmartNodeCleanerV07` from the Macros dialog.

**Important:** the form is intentionally blank in the VBA designer; it creates its controls when opened. Do not import the TXT as a `.frm` file. If an older copy of the engine or form exists, replace it rather than creating duplicate macro names. The custom toolbar icon is **not included**; it can be assigned separately in CorelDRAW's command customization.

## Limitations

- One Curve object at a time; other object types need conversion to curves first.
- No preview or side-by-side result.
- Sampling does not establish a continuous Hausdorff bound.
- Some endpoints/seam nodes are deliberately skipped.
- Processing and Undo can be slow because temporary candidate shapes are created inside a command group.
- Tested with CorelDRAW 2018; other versions are not verified.
- This is a **manual VBA installation**, not a one-click installer.

For a simpler fallback, use [v0.6](Usta_Smart_Node_Cleaner_v0_6.bas).

## Further reading

- [CorelDRAW Help: adding, removing and joining nodes](https://help.coreldraw.com/CorelDRAW/540111192/Documentation-Windows/CorelDRAW-en/CorelDRAW-Add-remove-join-nodes.html) — built-in node reduction and its effect on curves.
- [CorelDRAW Community: Reduce Nodes in VBA](https://community.coreldraw.com/sdk/f/code-snippets-feedback/61711/how-apply-reduce-nodes-in-vba) — practical discussion of automation, varying artwork scale and unwanted changes to appearance.

## Feedback and contact

This tool exists for actual production files, not benchmark-perfect demo curves that have never experienced a deadline. If it saves you time, I'd love to know what kind of artwork you used it on. If it behaves badly, even better — do send the CorelDRAW version, node counts before and after, tolerance, attempt limit, and a minimal reproducible curve if you can share one. Misbehaving Bézier curves deserve a fair trial, after all.

Bug reports, improvement ideas, and proposals for other practical production automations are welcome at **[usta.scripts@gmail.com](mailto:usta.scripts@gmail.com)**.

*Fewer nodes. Same curve. Less time negotiating with Bézier.*

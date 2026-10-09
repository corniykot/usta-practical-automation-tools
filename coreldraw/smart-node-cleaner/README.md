# USTA Smart Node Cleaner

A CorelDRAW 2018 VBA tool for removing redundant nodes from curves while checking each proposed change against the **original, untouched geometry**. Made for imported vectors, traced artwork, and converted lettering that arrive with more nodes than anyone ordered.

## Versions and status

- **v0.7 — current UI build:** graphite-and-amber UserForm, four workload presets, manual attempt limit, tolerance setting, and an in-place result. The form has been used in CorelDRAW 2018; the latest wording and report text need a final in-app check.
- **v0.6 — stable fallback:** tested macro with text prompts. Kept unchanged as a rollback option.

The v0.7 engine uses the same node-removal and sampled-distance routines as v0.6, with a UserForm entry point. Identical output between the two versions has **not** yet been independently regression-tested on the same saved geometry.

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

The attempt limit is a cap, not a promise to perform that many trials. Higher limits may take considerably longer, particularly with complicated geometry.

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

## Feedback and contact

This tool exists for actual production files, not benchmark-perfect demo curves. If it saves you time, I'd like to know what kind of artwork you used it on. If it behaves badly, even better: send the CorelDRAW version, node counts before and after, tolerance, attempt limit, and a minimal reproducible curve if you can share one.

Bug reports, improvement ideas, and proposals for other practical production automations are welcome at **[usta.scripts@gmail.com](mailto:usta.scripts@gmail.com)**.

*Fewer nodes. Same curve. Less time negotiating with Bézier.*

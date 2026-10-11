# USTA Smart Node Cleaner v0.73 — CorelDRAW Curve Simplification & Node Reduction

**Too many nodes after tracing? Reduce unnecessary Bézier nodes without blindly smoothing away your artwork.**

USTA Smart Node Cleaner is a **CorelDRAW 2018 (Windows 64-bit) VBA macro** for vector path cleanup, node reduction, and tolerance-controlled Bézier curve simplification. It is designed for traced logos, bitmap-to-vector artwork, imported SVG/PDF paths, lettering converted to curves, and vector preparation for laser cutting, engraving, vinyl cutting, CNC, and plotters.

Unlike a generic smoothing command, USTA tests each proposed node removal against the **unchanged original curve**, using a two-way sampled deviation check. You choose the allowed deviation in millimeters, so node reduction is guided by a measurable tolerance rather than just a visual smoothness setting.

## How it differs from CorelDRAW's Reduce Nodes

The built-in command is useful for quick cleanup. USTA is for cases where you want to **set a deviation tolerance** and compare each proposed deletion to the original geometry instead of applying an unspecified amount of smoothing. The trade-off is speed: repeated candidate testing can be slow on complex curves.


## Problems it solves

- **Too many nodes after bitmap tracing or PowerTRACE?** Clean up dense curves that are difficult to select, edit, or reshape manually.
- **Does Reduce Nodes round off corners or distort a logo?** Set a maximum *sampled* curve deviation instead of relying only on a smoothness slider.
- **Imported SVG or PDF has messy vector paths?** Simplify the nodes of an individual selected Curve object before further editing or production.
- **Preparing artwork for laser cutting, engraving, vinyl cutting, or plotting?** Reduce unnecessary path complexity while keeping control of contour changes. This tool does **not** repair open paths, merge disconnected objects, or optimize cutting order.
- **Cleaning converted text or detailed outlines?** Work one curve at a time, inspect the result, and undo if necessary.

## Quick answers

**What is USTA Smart Node Cleaner?** A CorelDRAW 2018 VBA macro that removes candidate Bézier nodes when the sampled curve deviation remains within your chosen tolerance.

**How is it different from CorelDRAW Reduce Nodes?** CorelDRAW provides built-in node reduction and a curve smoothness control; USTA explicitly evaluates proposed removals against the unchanged original curve with a tolerance expressed in millimeters.

**Will it preserve the exact original shape?** It limits the deviation measured by its sampling method; it does not mathematically prove zero deviation or guarantee unchanged geometry everywhere.

**Does it work on all objects or CorelDRAW versions?** It processes one selected Curve object at a time and has been tested in CorelDRAW 2018 (64-bit). Other versions have not been verified.

## Get started

### Option A — Windows installer (recommended)

**[Download USTA Smart Node Cleaner v0.73 — CorelDRAW 2018 / Windows 64-bit](USTA-Smart-Node-Cleaner-v0.73-Setup.zip)**

Download the ZIP from this folder, extract it, **close CorelDRAW**, and run the setup EXE.

The installer copies the macro and its icon into the current user's
CorelDRAW folder and integrates a button **at the end of the Standard
toolbar**. The button launches the existing macro. The integration preserves
a workspace backup. Start CorelDRAW after installation.

The setup EXE is **not digitally signed**.

### Option B — inspect or install manually

Prefer to review the source or avoid an EXE? Everything needed for the
macro itself is available:

- [VBA project (GMS)](UstaSmartNodeCleaner.gms)
- [VBA engine v0.73](USTA_Node_Cleaner_v0_73_Engine.bas)
- [VBA form code v0.73](frmUSTANodeCleaner_v0_73_CODE.txt)
- [Original icon](Usta_Smart_Node_Cleaner.ico)

To install the existing GMS manually, close CorelDRAW and copy it to
`%APPDATA%\Corel\CorelDRAW Graphics Suite 2018\Draw\GMS\`.
Restart CorelDRAW and launch the
`UstaSmartNodeCleaner.Module1.UstaSmartNodeCleanerV073` macro through the
macro manager.

Alternatively, create your own VBA project: import the `.bas` engine,
create a UserForm named `frmUSTANodeCleaner`, paste the matching form
code and compile the VBA project. The form builds its controls at runtime.

The custom toolbar icon is installed automatically by the Windows installer.
Manual GMS installation does not automatically add that toolbar button.

## How it works

1. Select **one Curve object** in CorelDRAW.
2. Run USTA from the toolbar (or macro manager).
3. Set a tolerance in millimeters (default **0.05 mm**, maximum **2 mm**).
4. Choose a workload: **Quick 512**, **Medium 1024**,
   **Serious 2048**, or **Extreme 4096** candidate attempts.
5. Inspect the before/after node counts. **Ctrl+Z** restores the original.

The tool keeps open-path endpoints and compares candidate subpaths with the
unchanged original. More attempts can require substantially more time.
It does not repair open contours, join paths, or optimize cutting order.

## Compatibility and limitations

Tested locally in CorelDRAW 2018 (64-bit). Other CorelDRAW versions have
not been verified. The installer targets the default 2018 workspace.
The button and icon have been verified locally across restarts;
installation on a second clean machine and uninstall behavior have not
been fully validated.

The downloadable setup EXE is not digitally signed.

## Earlier milestones

The historical [v0.1](Usta_Smart_Node_Cleaner_v0_1.bas) and
[v0.3](Usta_Smart_Node_Cleaner_v0_3_FAST.bas) are retained, along with a
[v0.3 result image](smart-node-cleaner-v0.3-result.png).

## Contact

If this tool saves you time, I'd love to hear what kind of artwork you threw at it. If it misbehaves, send the CorelDRAW version, node counts, tolerance, attempt limit, and—if possible—a sample curve. Misbehaving Bézier curves deserve a fair trial, after all.

Bug reports, better ideas, or another production task that has been wasting your afternoons: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)

*Less time negotiating with Bézier.*

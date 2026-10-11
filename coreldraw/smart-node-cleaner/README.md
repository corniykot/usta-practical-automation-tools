# USTA Smart Node Cleaner v0.73

**Fewer Bézier nodes. More control over the shape.**

A practical curve-cleanup tool for **CorelDRAW 2018 (64-bit)**, designed for
traced logos, imported vector art, lettering converted to curves, and
laser/CNC/plotter preparation.

USTA tests proposed node removals against the original curve using a
two-way sampled deviation check. It removes nodes only when the sampled
deviation is within the tolerance you choose. This is **not** an exact
geometric Hausdorff guarantee.

## Get started

### Option A — Windows installer (recommended)

**[Download USTA Smart Node Cleaner v0.73 — CorelDRAW 2018 / Windows 64-bit](USTA-Smart-Node-Cleaner-v0.73-Setup.zip)**

Download the ZIP from this folder, extract it, **close CorelDRAW**, and run the setup EXE.

The installer copies the macro and its icon into the current user's
CorelDRAW folder and integrates a button **at the end of the Standard
toolbar**. The button launches the existing macro. The integration preserves
a workspace backup. Start CorelDRAW after installation.

The setup is **not digitally signed**. GitHub Actions builds the installer;
building on GitHub is not a substitute for code signing.

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
For auditability, the [installer source](installer/) includes the icon
integration script and build instructions.

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

The current public installer is an unsigned GitHub Actions artifact, not a
digitally signed release.

## Earlier milestones

The historical [v0.1](Usta_Smart_Node_Cleaner_v0_1.bas) and
[v0.3](Usta_Smart_Node_Cleaner_v0_3_FAST.bas) are retained, along with a
[v0.3 result image](smart-node-cleaner-v0.3-result.png).
Intermediate experiments are kept in the development archive, not
recommended for current use.

## License and contact

MIT License — see the [repository license](../../LICENSE).

Problems or ideas? [Open an issue](https://github.com/corniykot/usta-practical-automation-tools/issues)
or email **usta.scripts@gmail.com**.

*Less time negotiating with Bézier.*

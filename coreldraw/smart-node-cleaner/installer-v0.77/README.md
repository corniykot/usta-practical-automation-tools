# USTA Smart Node Cleaner v0.77 — test installer

Based on the existing v0.75 installer. Includes the tolerance decimal-separator
patch and the toolbar placement/deduplication patch. UI design and cleaning
algorithm are retained; the GMS and setup display v0.77.

Download the setup artifact from the Build USTA Smart Node Cleaner v0.77 GitHub
Actions workflow. This is an unsigned test build, not a GitHub Release.

Close every CorelDRAW process before setup. If v0.73/v0.75/v0.9 is installed,
uninstall it using its own Windows uninstall entry first. The guarded installer
preserves differing existing GMS/customization rather than overwriting it.
Run setup, choose the detected initialized CorelDRAW x64 target, then start Corel.
Uninstall through Windows Installed Apps with CorelDRAW closed.

Discovery targets internal majors 17–24 (X7 through 2022). Discovery and fixture
checks are not proof of macro compatibility with every version. VBA must exist.
The installer copies a ready GMS; it does not import VBA or change macro security.
Installation diagnostics are under the per-user application Logs/State folders.

Toolbar integration edits the existing saved Standard definition at its dynamic
tail, retaining user command order, frame layout and lock settings. References
with the integration's own GUID on other bars are removed; no bar is created,
reset or deleted. Independently assigned GUIDs are preserved. Narrow-window
clipping and an existing empty user toolbar are not forcibly rearranged.

**Known limits:** the owner's reported locked/personalized toolbar failures occur
on another computer with CorelDRAW 2019. They have not been reproduced or verified
fixed on that target. Its personalized .cdws and a real installation test remain
required. Native restart preservation of toolbar lock was inconclusive locally;
archive-level preservation is covered. Do not label these items verified.

See TEST-REPORT.md and evidence/. No older version sources are changed.

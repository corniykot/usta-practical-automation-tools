# v0.77 preflight error presentation regression

Observed 2026-10-21 on Windows with CorelDRAW 2018 selected. The real setup and
PowerShell logs agree: preflight exited with `Already installed. Uninstall this
version first.` The check completed; it was not still processing the workspace.
No subsequent integration step was reached in that attempt.

Root cause: PrepareToInstall rendered the error immediately, then Inno's later
CurPageChanged(wpPreparing) rendered the checking/progress screen over it. That
screen hid the presentation buttons and the native inline error was covered.

Fix: retain the failure reason across the event boundary and render the final
preparing page as an error with Back/Cancel and no progress or unusable Retry.
Manage-Usta can optionally write its actual exception message to a temporary INI;
the existing refusal to overwrite an owned installation remains unchanged.
Native navigation visibility is left to Inno behind the presentation panel:
hiding its Next button also broke silent navigation, found by the new real EXE
test and corrected without changing integration decisions.

Executed locally:
- 123 file/workspace and 10 installation-orchestration fixture assertions: PASS.
- Real repeated-install check on a synthetic profile reports the exact exception
  through ResultIni and leaves the workspace hash unchanged: PASS.
- Compiled UI_PREFLIGHT_TEST EXE, actual Inno silent event lifecycle: PASS.
  Log contains the exact error, asserts progress/Next hidden and Back/Cancel
  visible, then exits with the expected preflight-failure code 7.

The UI_PREFLIGHT_TEST compile configuration contains no copyable product files,
creates no app directory or uninstall entry, does no Corel discovery, and always
fails preflight. It cannot install the macro. It is separate from production.
The Actions workflow repeats this native event regression and script checks.

The installed product and user workspaces were not changed for diagnosis.
Successful installation/uninstallation of the final production EXE is a separate
check and is not claimed by the preflight regression test.

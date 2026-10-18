# Local verification — 0.75 integration prototype

Date: 2026-10-17. Windows x64; Windows PowerShell 5.1 and PowerShell 7.
Initial local testing was performed without an EXE. GitHub source commit is authorized; no setup EXE or GitHub Release is produced.

| Check | Result | Evidence |
|---|---|---|
| Engine and ICO preserved | PASS | Before the label update, installed GMS matched after real use and restart; current payload SHA256 is in README |
| Version/path discovery | PASS | Actual initialized major 20 (2018) and 22 (2020) profiles detected via registry + archive metadata |
| Versions 17–24 file operations | PASS | 123 assertions in PowerShell 7 and 123 in Windows PowerShell 5.1; synthetic archives, not eight application installations |
| Copies of actual 2018/2020 workspaces | PASS | Install/remove on five 2018 and six 2020 full workspace descriptions; live inputs unchanged |
| Real local install with CorelDRAW closed | PASS | Windows PowerShell 5.1 `Manage-Usta.ps1 -Mode Install -Major 20`; GMS copied, five workspaces integrated; no COM/VBA build |
| Toolbar position/icon and launch | PASS | Original icon at end of Standard; click opened original form before label update |
| Real macro behavior | PASS | One disposable straight open curve: 11 → 3 nodes, removed 8, tolerance 0.05 mm; actual CLEAN NODES handler |
| Persistence | PASS | CorelDRAW closed normally and relaunched; button remained and launched original form |
| Real local removal | PASS | GMS, button and unused embedded icon removed; five original Standard command sequences retained exactly by GUID |
| CorelDRAW 2020 VBA function | BLOCKED | Existing expired trial; no licensing/security changes attempted |
| Other target-version application tests, complex contours, 32-bit | UNTESTED | Not installed/operational locally or outside current test scope |
| Windows Installed Apps registration/uninstall | UNTESTED | Inno Setup now implements registration and guarded removal; the EXE UI is not exercised by file tests |

Local machine evidence in the task workspace:

- `outputs/USTA-v075-local-20261017-191722/results.json`: PowerShell 7 synthetic tests.
- `outputs/USTA-v075-ps51-20261017-191857/results.json`: successful Windows PowerShell 5.1 synthetic tests before real install.
- Later `outputs/USTA-v075-ps51-*` includes the repeated passing 5.1 run after the interrupted turn.
- `outputs/USTA-v075-real-copies-20261017-191752/results.json`: real-profile copies.
- `outputs/USTA-v075-live-state/`: actual install/remove transcripts, preserved ownership record, screenshots `form.png`, `cleanup.png`, `toolbar-after-restart.png`, `form-after-restart.png`, and `uninstall-verification.json`.

The first Windows PowerShell 5.1 run found that loading Compression.FileSystem
alone did not expose ZipArchiveMode. Fixed by explicitly loading both Compression
assemblies, then reran all 123 assertions successfully. The production scripts
are not dependent on modules installed during development.

The previous GMS had been deleted at the owner's request before this test. The local test
installed the verified original, then removed it again. No previous GMS was backed
up or restored. Workspace snapshots and diagnostic evidence remain outside Corel
under the task outputs. Existing v0.9 uninstall state is outside this prototype's
scope and is not claimed cleaned by these tests.

Known prototype limits: a pre-existing button with the same GUID or an existing
ownership record causes a safe refusal rather than automatic migration. A future
EXE must wire these tested operations into Inno Setup and clean its support/state
files only after successful integration removal. Runtime compatibility of each
CorelDRAW version requires an application test; registry detection is not proof.

## Version-label update

The saved GMS now displays 0.75 in its caption and subtitle, without a fixed CorelDRAW year. Its public entry point and the integration binding use V075. Extracted VBA was compared against the previously tested engine: differences are version labels, the matching entry-point name and native VB_Base class metadata only. Algorithm, layout and handlers are unchanged. The saved form was launched in CorelDRAW 2018 and displayed 0.75. See form-version-075.png and version-label-verification.json in the existing local evidence directory. File/workspace regression tests are rerun against this new payload before committing. No renewed multi-version application compatibility claim is made.

Final version-label verification and Windows PowerShell 5.1 regression: 2026-10-18. All 123 assertions passed with the GMS 0.75 payload. Evidence included under evidence/: file-tests.json, vba-source-verification.json and form-0.75.png. No setup EXE or Release created.

## Installer wrapper regression, 2026-10-18

Windows PowerShell 5.1: 123 existing assertions plus 10 setup integration assertions passed. Additional checks prove preflight does not install GMS or change workspaces, edited GMS blocks UninstallAll before another target is removed, and successful UninstallAll removes two tracked target integrations without registry discovery. Inno uninstall uses Abort at usUninstall to preserve support/state if integration cleanup fails, as documented by Inno Setup. EXE compilation is performed by GitHub Actions. End-to-end EXE installation, Windows Apps listing and Inno uninstallation are UNTESTED until actually executed.

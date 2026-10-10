# USTA Smart Node Cleaner v0.73 — Windows installer

This installer packages the already existing `UstaSmartNodeCleaner.gms` and icon.
It integrates a toolbar button using the tested workspace patcher `Add-UstaToolbarButton.ps1`.
The VBA engine and UserForm sources are not modified by this project.

CorelDRAW 2018 (64-bit) must have been launched at least once to create its default
workspace. **Close CorelDRAW before installation.** The integration script refuses to
change the workspace while CorelDRAW is running.

On installation, Inno Setup copies the GMS, ICO, and PowerShell helper to the current
user's CorelDRAW 2018 Draw/GMS directory. It invokes the helper using the **installed**
ICO path, not the developer's Downloads folder. The helper operates on the target
user's default workspace and puts one USTA icon at the end of the Standard toolbar.
It creates a uniquely named workspace backup beside the .cdws file.

The installer invokes `Invoke-UstaToolbarIntegration.ps1` in fresh 64-bit Windows
PowerShell 5.1. This adapter explicitly loads both `System.IO.Compression` and
`System.IO.Compression.FileSystem`, then calls the original integration script
without modifying it. This fixes the reproduced `Unable to find type
[IO.Compression.ZipArchiveMode]` / exit-code-1 failure. Independently running the
helper in an already initialized PowerShell session can hide that missing assembly.

Before copying files, setup validates the workspace and rejects a running CorelDRAW
process. The helper checks again immediately before patching. An existing GMS is
preserved rather than overwritten, and uninstall never removes the GMS. The three
original payload files remain unchanged in source. Setup does not reset workspaces
or change macro security settings.

Diagnostics are stored under `%LOCALAPPDATA%\USTA\Smart Node Cleaner\Logs\<run>\`:
`preflight.log` and `integration.log` include PowerShell version/bitness, resolved
paths, the result and full exception details. Inno Setup also enables its own log;
use `/LOG="C:\path\setup.log"` to choose a location. The failure message identifies
the integration log path. Install as the Windows user who runs CorelDRAW.

To target a different saved workspace, run:

```text
USTA-Smart-Node-Cleaner-v0.73-Setup.exe /WORKSPACE="C:\path\custom-workspace.cdws"
```

The default paths use the target user's AppData directories. No developer profile
path is compiled into the installer. The selected workspace must already exist.
The Actions build runs `Test-InstallerIntegration.ps1`, which reproduces the old
fresh-process failure and checks the adapter, logs, order, icon and repeat behavior.
These archive tests do not substitute for testing the EXE with CorelDRAW installed.

Build with GitHub Actions `.github/workflows/build-usta-installer.yml` and download
the resulting workflow artifact. **Unsigned:** a GitHub-hosted build is not a digital
signature and does not guarantee that Microsoft SmartScreen will trust the EXE.
No code-signing credentials or service are configured.

**Limitations before public release:** Test on a second clean CorelDRAW 2018
installation, including an existing GMS, customized workspace, repeat install,
restart and uninstall. The current integration targets the default workspace only.
Removing the program files does not reverse the toolbar customization; reverting
the workspace requires restoring a backup, which also reverts any subsequent
workspace changes. Never distribute another user's workspace backup.

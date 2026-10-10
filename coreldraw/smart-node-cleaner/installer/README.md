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

# USTA Smart Node Cleaner v0.9 — native-source installer

This folder is the local successor to the working 2018 installer. Build
`USTA-Smart-Node-Cleaner.iss` (which includes the v0.9 script) with Inno Setup 6.3+.
No precompiled GMS is included in the v0.9 EXE.

## Installation

Use the Windows account that runs CorelDRAW. Start the licensed CorelDRAW once to
initialize its profile and VBA, then close every CorelDRAW window. Run
`USTA-Smart-Node-Cleaner-v0.9-Setup.exe` and select the detected version. No manual
source import or interface customization is required by the installation code.
For unattended setup with several versions installed, specify
`/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /TARGETMAJOR=20` (replace 20 with the
detected **internal major version**, not a marketing year).

The installer detects registered 64-bit CorelDRAW executables and matches their
file version against saved workspace metadata. It opens its own version-specific
COM host, creates a native project, adds Module1 from the BAS and a native blank
UserForm with the supplied form code, checks references, compiles, saves and reloads.
This specific UserForm creates all controls and layout at runtime; code-only text
is not treated as a general replacement for a designer `.frm/.frx` export.

The native `UstaSmartNodeCleanerV09.gms` is installed in the GMS folder confirmed by
the selected host. The original v0.73 GMS and other macros are not overwritten.
The same USTA button identity is appended to the end of compatible saved Standard
toolbars, with a separator and the original embedded ICO. Existing commands retain
their order; toolbar visibility is not forced. Incomplete workspace deltas are
left unchanged rather than reconstructed or reset. Each replaced workspace has a
unique `.usta-v09-*.bak` backup.

The engine is the existing v0.73 algorithm. Only the form title/subtitle identify
v0.9 and remove the fixed 2018 label; control positions, colors, handlers and
algorithm behavior are preserved.

## Requirements and limits

- Windows x64, initialized CorelDRAW x64, installed VBA/MSForms and permission to
  access the VBA project model. Restricted/expired editions may not provide this.
- The installer never changes macro trust, Windows security or licensing settings.
  It retains the previous installer's process-only PowerShell execution-policy
  argument; no persistent execution policy is written. Mandatory system policy wins.
- Native compilation/save uses the VBE host commands. Missing commands, broken
  references or blocked automation stop installation with diagnostics.
- CorelDRAW 2018 source-to-native-GMS GUI build/reload and simple-curve function
  were tested. CorelDRAW 2020 here shows Trial Expired with Script Editor/Run Script
  disabled; native build/function there remain BLOCKED, not verified compatible.
- The attempted v0.9 EXE test was blocked by Windows Application Control before
  setup started. The final rebuilt EXE has **not** completed an end-to-end install.
  Do not describe it as production-verified or universally compatible.
- No security bypass, new runtime installation, commits or publication were done.

Diagnostics: `%LOCALAPPDATA%\Usta.Scripts\SmartNodeCleaner\Logs\<run>\`.
Native build result includes host major, resolved GMS path, source/artifact hashes,
reference paths and compile/reload checks. Setup accepts `/LOG="C:\path\setup.log"`.

As in the previous installer, uninstall removes installer support files, while
the installed macro and embedded toolbar button remain usable. For rollback use
the per-file backups; restoring a whole workspace also restores its earlier user
customization, so do not restore over later changes blindly.

Only the native v0.9 scripts, sources, ICO and build instructions belong in the
transfer/source archive. Legacy 2018 helper/test files retained in this working
folder are reference material and are not shipped or invoked by the v0.9 EXE.

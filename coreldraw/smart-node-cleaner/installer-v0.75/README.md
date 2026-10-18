# USTA Smart Node Cleaner 0.75 — installer and local integration

Smart Node Cleaner 0.75 uses the verified engine with version labels updated to
0.75 and the original ICO. The form identifies itself as 0.75 / CorelDRAW without
a fixed year. The VBA entry point and toolbar binding use V075. No algorithm,
layout or event-handler behavior was changed. No VBA import, compilation, COM
activation or CorelDRAW launch occurs during installation or removal.

## Scope

Windows PowerShell 5.1, CorelDRAW x64, internal versions 17–24:
X7, X8, 2017, 2018, 2019, 2020, 2021 and 2022.
Detection reads registered version-specific COM server paths without activating
COM, verifies executable version and x64 PE machine, then matches initialized
user profiles using metadata inside saved `.cdws` archives. No year-to-path table
or fixed drive/user name is used. Only compatible complete Standard toolbar
descriptions are edited; incomplete workspace deltas remain unchanged.

Versions 17–24 are a detection target range, not a claim that the macro works in
every version. Local application testing covers 2018. Real 2020 profile copies
are used for archive tests; its expired trial prevents a VBA functional test.
32-bit installations and profiles without compatible `.cdws` metadata are not
currently supported. Initialize the licensed application once before installation.

## Local commands

Run from this directory in Windows PowerShell, using the Windows account that
runs CorelDRAW. Close CorelDRAW before Install or Uninstall. No policies should
be changed to run this prototype; mandatory system policy takes precedence.

```powershell
.\Manage-Usta.ps1 -Mode Detect
.\Manage-Usta.ps1 -Mode Install -Major 20
.\Manage-Usta.ps1 -Mode Uninstall -Major 20
```

Replace `20` with the desired **internal major**. If more than one profile matches,
also specify `-ProfilePath` using an exact detected profile. `-StateRoot` can move
logs and ownership records to a chosen location; pass the same value to uninstall.
Default state directory: `%LOCALAPPDATA%\Usta.Scripts\SmartNodeCleaner\v0.75`.

A different existing GMS is preserved by default. Explicit `-ReplaceExistingGms`
backs it up and restores it on uninstall. A pre-existing USTA button with the same
identity is preserved and reported as a conflict rather than silently overwritten.
Reinstallation while an ownership record exists is refused: uninstall first.
An edited installed GMS is also preserved and reported during uninstall.

The original ICO is embedded in each compatible saved workspace. USTA is appended
after all existing Standard commands, with a separator as needed. Uninstall
removes only this button and its unused embedded icon, retaining later unrelated
customizations. It removes the added separator where ownership was recorded.
Staged archives and backup copies permit rollback; whole workspaces are never
restored during normal uninstall. The Inno Setup uninstaller first removes all tracked integrations. It then
removes its support/state files and Windows Installed Apps entry. A failed
cleanup aborts removal before support files and ownership records are deleted.

## Tests

```powershell
.\Test-Local.ps1 -TestRoot C:\path\to\NEW-empty-test-directory
```

123 assertions cover synthetic version 17–24 archives, dynamic command order,
original icon bytes, GMS copy/removal, retention of later customizations and
restoration of an explicitly replaced pre-existing GMS. These are file-level tests,
not application compatibility tests. See local `outputs/USTA-v075-*` evidence for
actual machine results. The GitHub workflow builds an unsigned setup EXE artifact; it does not create a GitHub Release.

GMS 0.75 SHA256:
`510E4A7ED648745BA9F5301E9DA647223A82BB26491F0AB42C8BDD9EDC6786FC`

Original ICO SHA256:
`57DE42FEFA72FCB9F6B9A89E6EDEF7B522320D860504AF9BFBEF3DB743CF4284`

## Setup EXE

Build USTA-Smart-Node-Cleaner.iss with Inno Setup 6. The workflow .github/workflows/build-usta-v075.yml runs file-level regression tests and uploads USTA-Smart-Node-Cleaner-v0.75-Setup.exe with SHA256 and build metadata. Run setup under the CorelDRAW user's account with CorelDRAW closed, select the detected version and install. Silent setup with several installed versions requires /TARGETMAJOR=<17..24>. No VBA rebuild occurs. Remove it through Windows Installed Apps while CorelDRAW is closed. Setup and uninstall do not terminate CorelDRAW automatically. Uninstall cannot remove an edited GMS silently: it aborts and preserves diagnostics and support files.

Installer logs: setup /LOG and the per-target logs in %LOCALAPPDATA%\Usta.Scripts\SmartNodeCleaner\v0.75\State. Full EXE install/uninstall UI verification is separate from the passing PowerShell and archive tests.

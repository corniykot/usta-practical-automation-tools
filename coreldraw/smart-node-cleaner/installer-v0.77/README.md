# USTA Smart Node Cleaner v0.77

Source code and resources for the Windows installer. It installs the included
GMS and adds the USTA button to the existing CorelDRAW Standard toolbar.

| Files | Purpose |
|---|---|
| `USTA-Smart-Node-Cleaner.iss`, `Usta.UI.iss` | Inno Setup installation and English interface |
| `Get-CorelTargets.ps1`, `Get-RunningCorel.ps1` | Version discovery and running-process diagnostics |
| `Manage-Usta.ps1`, `Usta.Files.ps1`, `Add-UstaToolbarButton.ps1` | Installation, removal and workspace integration |
| `vba/` | Readable VBA extracted from the included v0.77 GMS |
| `UstaSmartNodeCleaner.gms` | Ready-to-install VBA project |
| `Usta_Smart_Node_Cleaner.ico`, `ui/` | Toolbar icon, setup icon and required artwork |

The form's `.code.vba` file contains its VBA code, not a complete `.frm/.frx`
designer export. Controls are created at runtime. The installer uses the ready
GMS; the readable files are provided for code inspection, not automatic import.
The GMS is unchanged: SHA-256
`A98A01F9C6AF70032B13B5F621CD905819111EE50339A410A2966AE3756D6C99`.

## Build and use

Build with **Inno Setup 6.7.3**:

```text
ISCC.exe USTA-Smart-Node-Cleaner.iss
```

The [GitHub Actions workflow](../../../.github/workflows/build-usta-v077.yml)
builds the EXE and runs the [separate test suite](../../../tests/coreldraw/smart-node-cleaner/v0.77).
Build output is in `output/`; test downloads are Actions artifacts.

Close CorelDRAW before installation or removal. Select a detected, initialized
x64 profile; VBA must be available. An existing owned v0.77 installation must
first be removed through Windows Installed Apps. Installation does not change
macro security settings or reset the workspace.

Discovery covers internal versions 17–24 (X7–2022). This is not verification of
every version's macro or personalized-workspace compatibility. In particular,
the reported CorelDRAW 2019 personalized-toolbar case remains unverified.

Original artwork was supplied by the owner. The single-line header's left text
band was edited; its right-hand artwork was preserved. See the repository
[license](../../../LICENSE).

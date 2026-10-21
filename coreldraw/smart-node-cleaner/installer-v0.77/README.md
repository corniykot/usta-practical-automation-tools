# USTA Smart Node Cleaner v0.77 — Installer & VBA Source

**[Download the Windows installer](https://github.com/corniykot/usta-practical-automation-tools/releases/tag/smart-node-cleaner-v0.77)** · [Product overview and screenshots](../README.md)

USTA Smart Node Cleaner is a free CorelDRAW Bézier node reduction macro with millimeter-based tolerance control. This folder contains the **Inno Setup project**, installation scripts, ready-to-install CorelDRAW VBA project and readable source.

## v0.77 screenshots

![USTA Smart Node Cleaner v0.77 screenshot](Screenshot%202026-10-21%20231707.png)

![USTA Smart Node Cleaner v0.77 screenshot](Screenshot%202026-10-21%20231856.png)

![USTA Smart Node Cleaner v0.77 screenshot](Screenshot%202026-10-22%20010534.png)

## What's included?

| File | Purpose |
|---|---|
| `USTA-Smart-Node-Cleaner.iss`, `Usta.UI.iss` | Inno Setup installer and UI |
| `Get-CorelTargets.ps1`, `Get-RunningCorel.ps1` | CorelDRAW discovery and process checks |
| `Manage-Usta.ps1`, `Usta.Files.ps1`, `Add-UstaToolbarButton.ps1` | Installation, removal and Standard toolbar integration |
| `UstaSmartNodeCleaner.gms` | Ready-to-install CorelDRAW VBA macro |
| [`vba/`](vba/) | Readable VBA extracted from the included GMS |
| [`ui/`](ui/) | Installer artwork and icons |

The GMS is included as a prebuilt VBA project. Its readable source is published for inspection, **not** rebuilt from source by CI. GMS SHA-256: `A98A01F9C6AF70032B13B5F621CD905819111EE50339A410A2966AE3756D6C99`.

## Build and compatibility

The installer is built using **Inno Setup 6.7.3** (`ISCC.exe USTA-Smart-Node-Cleaner.iss`). [GitHub Actions](../../../.github/workflows/build-usta-v077.yml) builds and checks the EXE, with a [separate regression test suite](../../../tests/coreldraw/smart-node-cleaner/v0.77/). The product has also been tested in real CorelDRAW installations.

Close CorelDRAW before installing or uninstalling. The installer detects initialized 64-bit CorelDRAW X7–2022 profiles with VBA support. Personalized toolbar compatibility can vary.

**Code signing:** the publicly available v0.77 EXE is currently unsigned. The project is preparing for SignPath Foundation review; see the [code signing policy](../README.md#open-source-testing--signing). Source and installer files are licensed under [MIT](../../../LICENSE).

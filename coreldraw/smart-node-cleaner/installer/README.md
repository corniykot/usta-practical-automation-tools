# USTA Smart Node Cleaner v0.73 — Windows installer

This directory contains the Inno Setup project that packages the existing
`UstaSmartNodeCleaner.gms` VBA project for CorelDRAW 2018.

## Installation destination

The installer copies the GMS project to:

`%AppData%\Corel\CorelDRAW Graphics Suite 2018\Draw\GMS\UstaSmartNodeCleaner.gms`

It installs for the current Windows user and does not request administrator
permissions. Close CorelDRAW before installing and start it again afterward.

## Build

On Windows, install Inno Setup and compile
`USTA-Smart-Node-Cleaner.iss` using ISCC.exe.

GitHub Actions workflow:
[`build-usta-installer.yml`](../../../.github/workflows/build-usta-installer.yml).

The workflow compiles an **unsigned** setup EXE from the GMS checked into the
repository and uploads the EXE as a GitHub Actions artifact. The workflow does
not build the GMS from VBA source. This limitation must be resolved or
documented and accepted by SignPath Foundation before code signing.

## Signing status

Not signed. We plan to request open-source signing from SignPath Foundation.
No valid signed installer or published GitHub Release is claimed at this time.
See [Code signing policy](../../../CODE_SIGNING.md).

## Testing checklist

- Compile without errors in GitHub Actions.
- Install with CorelDRAW closed.
- Confirm USTA appears in CorelDRAW 2018's macro manager.
- Run a geometry-preserving node-cleanup test.
- Check the PayPal and GitHub buttons.
- Uninstall and verify that unrelated GMS files are unaffected.

**Important:** The bundled GMS is a binary VBA project uploaded by its author.
Its embedded version and current source should be verified independently.

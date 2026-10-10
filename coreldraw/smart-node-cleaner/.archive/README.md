# USTA Smart Node Cleaner — historical development material

This directory retains obsolete prototypes and intermediate source files for
project provenance. It is **not part of the current installer**. Do not use these
files to install the current version.

## Development notes (reconstructed from committed files and Git history)

- Early v0.1 and v0.3 source versions remain publicly visible in the product
  directory as historical milestones.
- Intermediate v0.2, v0.6, and v0.7 VBA engines have been retained here,
  together with the earlier form source.
- The retired XML/XSLT add-on experiment is preserved under
  `development/addon-experimental/`. It is not used by the current release.
- The first installer workflow, built on GitHub Actions and Inno Setup, was
  introduced on 2026-10-10 and later withdrawn during experimentation.
- A later PowerShell workspace integration was tested in CorelDRAW 2018 and
  used for the current build. Installer troubleshooting identified that
  Windows PowerShell 5.1 needs explicit loading of the compression assemblies.
- The release build uses the existing GMS and original ICO and includes the
  toolbar integration code. The macro algorithm is not generated or modified
  during installer compilation.

## Historical references

- [Early installer build configuration](https://github.com/corniykot/usta-practical-automation-tools/commit/4e95da41818089c577f6112ce5c6dfb61a5ec780)
- [Removal of abandoned installer experiments](https://github.com/corniykot/usta-practical-automation-tools/commit/974cbdce8397498e5fe6b3ff03d77ac331b65515)
- [Reintroduction of portable icon integration](https://github.com/corniykot/usta-practical-automation-tools/commit/d6397c3657fa3838507e29f62a7073464556b0b2)
- [Installer tests fix](https://github.com/corniykot/usta-practical-automation-tools/commit/ac23a51c00dddc7846f44935a8e149925a8745b0)

This is a summary of documented milestones, **not** a verbatim chat or
terminal transcript. Detailed CI logs remain accessible through GitHub Actions
subject to GitHub retention rules. Moving files here does not conceal them
from anyone who can browse this public repository or its Git history.

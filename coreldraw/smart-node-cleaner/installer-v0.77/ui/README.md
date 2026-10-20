# v0.77 setup artwork

Owner-supplied graphics and U icon, approved in the project conversation on
2026-10-20/21. English-only text and one 720 x 620 logical-pixel client size.
Welcome/finish use the vertical artwork; other pages use the horizontal banner.
The native Windows title bar is retained, with dark appearance requested where
Windows supports it. No custom window-management DLL is shipped.

`prepare-assets.py` converts the source PNGs to Inno resources, preserving aspect
ratios. Pillow is a developer tool only. `setup.ico` is the setup executable icon;
the original macro/toolbar ICO remains unchanged.

Build with Inno Setup 6.7.3. `UI_PREVIEW` produces a separate visual-only EXE:
its NextButtonClick always refuses native installation. Use `/PREVIEW=welcome`,
`target`, `running`, `ready`, `progress`, or `finished`. Preview labels/processes
are fixtures and do not prove installation. This define is absent from setup.

Progress shows real file-copy progress followed by an indeterminate combined
GMS/workspace/button operation. Integration success is shown only after its
process returns success. The existing integration remains a single transaction.
Running-Corel diagnostics are read-only; icons are extracted from the installed
EXE, not downloaded or bundled from a third party. CorelDRAW is never terminated.

Validation scope: unchanged GMS SHA-256
`A98A01F9C6AF70032B13B5F621CD905819111EE50339A410A2966AE3756D6C99`.
Actual setup/preview compilation is distinct from native visual and installation
testing. Application Control blocked the locally built preview during development;
no security policy was changed. See the Actions artifact for the runner build.

Central standards reviewed: Operating `2df9344ebf5227b185bf6446e99791b9a8294fe4`,
Voice `8c3832131830f95257b4eb5fa53399ba2aec5aab`, Workflow
`5af96d8255c11e5d1d212de18601bb026e3d5cf4`.

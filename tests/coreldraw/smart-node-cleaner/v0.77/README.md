# USTA v0.77 regression tests

Tests are separate from the public installer source directory. The
[Actions workflow](../../../../.github/workflows/build-usta-v077.yml) stages a
temporary copy of the installer sources and these PowerShell tests together,
because the tests resolve runtime scripts relative to their own location.

- `Test-Local.ps1`: synthetic file/workspace cases.
- `Test-SetupIntegration.ps1`: install/remove orchestration on those fixtures.
- `Test-ToolbarPlacement.ps1`: preserved order, lock state and owned-button placement.
- `Test-OleDecimalLocales.ps1`: explicit-locale numeric conversion.
- `Test-PreflightError.ps1`: exact repeated-install error reporting and unchanged workspace.
- `fixtures/toolbar-baseline.cdws`: synthetic toolbar fixture.

The workflow also compiles the install-disabled `UI_PREFLIGHT_TEST` configuration
from the actual installer source and exercises Inno's native failure event
sequence. No CorelDRAW is installed on the runner. These checks do not claim
complete native CorelDRAW compatibility or a full end-user installation test.

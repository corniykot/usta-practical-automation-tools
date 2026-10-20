# v0.77 verification — 2026-10-20

| Check | Result | Scope |
|---|---|---|
| Saved GMS source comparison | PASS | Only 0.75→0.77 labels and V075→V077 entry rename differ from the tested decimal-fixed GMS; native VB_Base metadata excluded |
| Native CorelDRAW 2018 v0.77 entry/form launch | PASS | evidence/form-v077.png; design retained |
| File/workspace operations | PASS locally | 123 assertions, synthetic majors 17–24; not eight Corel installations |
| Install/uninstall orchestration | PASS locally | 10 assertions; not EXE UI installation |
| Toolbar regression | PASS locally | 8 cases, two runs each; lock 0/1, missing/first/other/both USTA locations; user commands, states and archive entries preserved |
| Decimal conversion | PASS locally | 56 Windows OLE tests, LCID 1033 and 1049, valid/invalid/range input |
| Setup runner checks | See Actions artifact | Workflow repeats tests on Windows PowerShell 5.1, compiles Inno Setup and checks real EXE startup/no-target handling |
| Complete v0.77 EXE installation on this PC | UNTESTED | This task builds the artifact; no local setup was run |
| CorelDRAW 2019 reported toolbar failures | UNTESTED | External computer and problem workspace unavailable; root causes unconfirmed |
| Lock preservation across native restart | PARTIAL in prior toolbar test | Archive preservation passed; GUI/external settings disagreement and two process observations remain unresolved |

Prior same-code v0.75 decimal patch was tested through the actual CorelDRAW 2018
form with both 0.05 and 0,05: each cleaned a disposable curve from 11 to 3 nodes
and reported 0.05 mm. Malformed 0.0,5 retained the original error. The v0.77 source
comparison preserves that handler exactly. Full node-cleaning was not rerun in
v0.77, and neither locale test nor runner compilation claims it was.

Original ICO is unchanged. Macro algorithm and older release folders are unchanged.
The CI workspace fixture is synthetic and contains no personal workspace settings.

# USTA Practical Automation Tools

Small, practical automation tools built for real production work.

The goal of this repository is simple: if a repetitive task can be reduced to a reliable script, macro, workflow, or small utility, keep the finished solution here instead of solving the same problem again later.

## Tools

### Photoshop

| Tool | What it does | Status |
|---|---|---|
| [Print Folder](photoshop/print-folder/) | Places every image from a folder into the current Photoshop document and prints it using the current print settings. | Tested on Photoshop CS6 |
| [Print All Layers](photoshop/print-all-layers/) | Prints top-level layers from the current Photoshop document one by one. | Tested on Photoshop CS6 |
| [Place Layout 102×142](photoshop/place-layout-4up-102x142/) | Exact-size 102 × 142 mm A4 batch layout with orientation checking. Safe version available with skip-on-error logging. | Original tested on Photoshop CS6; safe version pending test |
| [A5 Place Rotate Layout 142×202](photoshop/place-layout-a5-142x202/) | A5-style exact-size 142 × 202 mm layout with automatic orientation normalization and 90° print rotation. Safe version available with skip-on-error logging. | Original tested on Photoshop CS6; safe version pending test |
| [Place Layout A4 Portrait](photoshop/place-layout-a4-portrait/) | Batch-places images as full A4 portrait layers with orientation checking. Safe version available with skip-on-error logging. | Original tested on Photoshop CS6; safe version pending test |

### Photoshop layout workflow assumptions

The current print-layout scripts are designed around a simple production workflow:

- Create or open an **A4 document (210 × 297 mm)** in Photoshop for a standard desktop printer before running the script.
- Prepare source artwork in the intended print proportions before placement. Typical source proportions are **2:3** or standard **ISO A-series** proportions such as A3, A4, A5, A6, and related sizes.
- The scripts place source files into the active A4 document as Smart Objects and then apply the fixed physical dimensions required by that particular layout.
- The current layout scripts check source orientation before resizing. A source that is wider than it is tall is treated as a sideways portrait image and rotated 90° before the target physical size is applied.
- These tools are layout automations, not automatic cropping or composition tools. A source image with an unsuitable aspect ratio may still be stretched because the target width and height are enforced exactly.

More categories will be added as useful tools are built: Blender, Windows, image processing, production utilities, and other small automations.

## Language policy

English is the default language for all public tools in this repository.

- Source code, comments, filenames, user-facing messages, and primary documentation are written in English by default.
- Localizations are added separately only when useful.
- Localized documentation should use explicit language suffixes such as `README.ru.md`.
- Localized strings or resources should live in a separate `locales/` directory when a tool grows enough to need them.
- Primary source files should not mix multiple languages unless there is a technical reason to do so.

## Philosophy

- Solve a real repetitive task.
- Keep the tool small and understandable.
- Prefer deterministic automation over unnecessary AI when a script is enough.
- Document the exact workflow and limitations.
- Keep the public source English-first; localize separately when needed.
- Mark tools as tested only after real use.

## License

MIT License. See [LICENSE](LICENSE).

## Contact

Questions, feedback, or custom workflow requests: **usta.scripts@gmail.com**

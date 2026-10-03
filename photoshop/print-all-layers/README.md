# Photoshop Print Automation — Print All Layers Separately

A small Photoshop script for a very repetitive job: **print every top-level layer separately without clicking Print over and over again**.

Set up the document, make one test print, confirm the printer settings, and run the script. It goes through the printable layers one by one, sends each layer to the printer using Photoshop's current print settings, then restores the document's original visibility state.

No exporting. No temporary files. No babysitting every print.

## Useful for

- **batch printing in Photoshop** — print a stack of prepared layers automatically
- **photo and art print production** — one finished image per layer, one print per image
- **small print shops and studio workflows** — reduce repetitive operator work on recurring jobs
- **sublimation, transfers, stickers, magnets, and craft production** — run prepared designs through the same print setup
- **production and prepress automation** — turn a manually repeated Photoshop step into a one-command workflow

If your document is already prepared as **one job per layer**, this script handles the boring part.

## How it works

1. Prepare the Photoshop document with one printable job on each top-level layer.
2. Make **one manual test print** and confirm the printer, paper, scale, orientation, color, and other print settings.
3. Run `Print_All_Layers.jsx`.
4. The script hides the printable layers and prints them individually, one at a time.
5. When the batch is finished, the original layer visibility is restored.

The script uses Photoshop's existing print setup. It does not change printer settings for you.

## Why this instead of Photoshop Actions?

For a simple production document, the job is not really “run an action on every file.” The jobs are already sitting inside one Photoshop document as layers.

**Print All Layers** works directly with that structure: layer → print → next layer → print.

That makes it useful as the final step after automated layout scripts or any workflow that builds multiple print-ready jobs as separate layers.

## Requirements

- Adobe Photoshop with ExtendScript / JSX support
- a document containing printable top-level layers
- printer settings confirmed with a manual test print

Tested in **Adobe Photoshop CS6 on Windows**.

## Install

Copy `Print_All_Layers.jsx` to Photoshop's Scripts folder. On Windows, the Photoshop Scripts folder is typically:

`C:\Program Files (x86)\Adobe\Adobe Photoshop CS6\Presets\Scripts\`

Restart Photoshop. The script will appear under:

**File → Scripts → Print_All_Layers**

For an even faster production workflow, assign it a keyboard shortcut:

**Edit → Keyboard Shortcuts → Application Menus → File → Scripts**

## Notes

- No layer naming convention is required.
- The Background layer is ignored.
- Only top-level `ArtLayer` layers are processed; layers inside groups are not.
- Layers are printed in Photoshop's top-level layer order.
- The script uses `printOneCopy()`.
- Original layer visibility is restored after a successful batch.
- Always make one manual test print before running a production batch.

## Status

**Field-tested on a real multi-image print batch.**

## Contact

If your workflow involves “and then I do this 80 more times,” we should probably talk: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)

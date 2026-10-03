# Photoshop Batch Print Layout — 4 Images on A4, 102×142 mm

A free **Photoshop JSX / ExtendScript** for turning a folder of images into a repeatable **4-up A4 print layout**.

The script batch-places different images into Photoshop, corrects sideways orientation, resizes every image to exactly **102 × 142 mm**, and arranges them in a fixed **2 × 2 print sheet**.

It is designed for practical production work where many finished images need to be prepared quickly at a consistent physical size.

## Where this workflow is useful

This kind of exact-size batch layout can be useful for:

- **photo printing and photo labs** — preparing multiple photographs on one A4 sheet
- **portrait, school, and event photography** — building repeatable print sheets from folders of finished images
- **small production and prepress workflows** — placing different artworks at a fixed physical size without rebuilding the layout manually
- **sticker, transfer, sublimation, and craft production** — when artwork needs to be arranged consistently before printing
- **general batch printing** — any workflow that repeatedly needs four different images on one A4 page at 102 × 142 mm

The script does not generate or edit the artwork itself. It automates the repetitive Photoshop layout step between finished source files and printing.

## What the script does

Choose a folder containing your source images and the script:

- imports supported files as **Smart Objects**
- processes different images in filename order
- detects landscape/sideways source files and rotates them automatically
- resizes every valid image to exactly **102 × 142 mm**
- places images into four fixed positions on an **A4 sheet**
- repeats the same positions for additional files, creating stacked print sets

Supported formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## Print layout

Four images are placed on each A4 sheet at exactly **102 × 142 mm**. Additional images continue in the same 2 × 2 pattern as new layers.

## Why use a Photoshop script for this?

A manual **photo print layout** usually means placing each image, checking its orientation, entering the required dimensions, and moving it into position.

For a folder containing many different images, those small steps become repetitive very quickly.

This script turns that process into a **batch print layout**: select the folder once and Photoshop handles the placement, orientation, exact-size resizing, and positioning automatically.

It is intentionally a small production utility rather than a general collage or contact-sheet tool.

## Versions

- `Place_Layout_102x142.jsx` — original tested version
- `Place_Layout_102x142_safe_v2.jsx` — fault-tolerant batch version

The safe version skips an image if Photoshop cannot import or process it, writes the error to a TXT log, and continues with the next valid file instead of stopping the entire batch.

A failed file does not consume one of the four layout positions.

## How to run the Photoshop script

1. Open an **A4 document (210 × 297 mm)** in Photoshop.
2. Choose **File → Scripts → Browse…**
3. Select `Place_Layout_102x142.jsx` or `Place_Layout_102x142_safe_v2.jsx`.
4. Select the folder containing your source images.
5. Photoshop builds the print layout automatically.

Optional: copy the JSX file into Photoshop's `Presets/Scripts` folder and restart Photoshop. The script will then appear directly under **File → Scripts**.

## Requirements

- Adobe Photoshop with ExtendScript / JSX support
- Active A4 document, **210 × 297 mm**
- Tested environment: **Photoshop CS6**

## Notes

- Images are placed as Smart Objects.
- Width and height are enforced independently to exactly 102 × 142 mm.
- The script does not crop or intelligently recompose images.
- Source artwork should already have a suitable aspect ratio.
- This is an exact-size production layout, not an ID/passport photo generator.

## Status

**Original version tested on Photoshop CS6. Safe version added for fault-tolerant batch processing; production testing still required.**

## Contact

Questions, feedback, or a workflow that has been testing your patience since 2007: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)

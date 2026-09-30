# Photoshop — Place Layout 72×102

Automatically builds exact-size A4 print sheets from a folder of images. Each source is normalized to portrait orientation, resized to **72 × 102 mm**, rotated for the sheet layout, and arranged **8 per A4 page layer (2 × 4)**.

Each completed set is merged into one Photoshop layer, ready to use with the repository's **Print All Layers** tool.

## Versions

- `Place_Layout_72x102.jsx` — original tested version.
- `Place_Layout_72x102_safe_v2.jsx` — safe batch version. Failed images are skipped, the batch continues, and errors are written to a TXT log beside the script or in the source-image folder.

## A4 layout

Designed for **70 × 100 mm blanks** with **1 mm bleed**.

- Print size: **72 × 102 mm**
- Layout: **8 per A4 sheet (2 × 4)**
- Side margins: **2 mm**
- Column gap: **2 mm**
- Top/bottom margins: **3 mm**
- Row gaps: **1 mm**

## How to run

1. Open an **A4 portrait document, 210 × 297 mm**, in Photoshop.
2. Choose **File → Scripts → Browse…**
3. Select `Place_Layout_72x102.jsx` or `Place_Layout_72x102_safe_v2.jsx`.
4. Select the folder containing the source images.
5. The script sorts the files, checks orientation, resizes and places them, then merges every 8 images into one sheet layer.

Optional: copy the JSX file into Photoshop's `Presets/Scripts` folder and restart Photoshop. It will then appear directly under **File → Scripts**.

Supported formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## Tested result

The original script has been **tested successfully in Photoshop CS6**.

![Tested Photoshop CS6 result — 72×102 mm layout](tested-layout-72x102.png)

## Notes

- Images are initially placed as Smart Objects.
- The script enforces the exact target dimensions and does not perform intelligent cropping.
- Safe version: failed files do not consume a print position; the next valid file fills that slot.

## Status

**Original version tested successfully in Photoshop CS6. Safe version added; production testing still required.**

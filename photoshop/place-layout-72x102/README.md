# Photoshop — Place Layout 72×102

Places all supported images from a selected folder into an active A4 portrait document, normalizes sideways source orientation, resizes every image to exactly **72 × 102 mm**, rotates it for the print layout, and arranges up to **8 images per A4 sheet layer**.

Every complete set of 8 images is merged into one Photoshop layer. A final incomplete set is also merged into one layer, so the result can be printed with the repository's **Print All Layers** tool.

## A4 layout

Designed for printing on **70 × 100 mm blanks** with a **1 mm bleed on every side**.

- Print size: **72 × 102 mm**
- Layout: **8 per A4 sheet (2 × 4)**
- Side margins: **2 mm**
- Column gap: **2 mm**
- Top/bottom margins: **3 mm**
- Row gaps: **1 mm**

## Workflow

1. Create or open an **A4 portrait document, 210 × 297 mm**, in Photoshop.
2. Run `Place_Layout_72x102.jsx`.
3. Select the folder containing the source images.
4. The script sorts the files alphabetically.
5. Landscape source files are rotated to portrait orientation before sizing.
6. Every image is forced to exactly **72 × 102 mm**.
7. Each image is rotated 90° for the A4 layout and placed at its exact position.
8. Every 8 images are merged into one layer named like `Sheet_01_8pcs`.
9. If the last sheet contains fewer than 8 images, it is merged into one layer such as `Sheet_03_5pcs`.

Supported source formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## Tested result

The script has been **tested successfully in Photoshop CS6** on an A4 portrait document.

The screenshot below shows the generated **2 × 4 layout with 8 images on one A4 sheet**, after placement and sizing by the script.

![Tested Photoshop CS6 result — 72×102 mm layout](tested-layout-72x102.png)

## Notes

- The script checks that the active document is approximately A4 portrait before processing.
- Images are initially placed as Smart Objects.
- Merging each sheet produces one final layer for that sheet.
- Source artwork should already have a suitable aspect ratio. The script enforces the exact target width and height and does not perform intelligent cropping.
- The generated sheet layers are intended to work directly with `photoshop/print-all-layers/`.

## Status

**Tested successfully in Photoshop CS6.**

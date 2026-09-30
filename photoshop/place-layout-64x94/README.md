# Photoshop — Place Layout 64×94 (3×3)

Places images from a selected folder onto an active **A4 portrait** document, checks orientation, resizes each image to exactly **64 × 94 mm**, and arranges them **9 per sheet (3 × 3)**.

Each set of 9 images is merged into one Photoshop layer. A final incomplete set is merged as well.

## Layout

- A4: **210 × 297 mm**
- Image: **64 × 94 mm**
- Grid: **3 × 3**
- Gaps: **2 mm**
- Margins: **7 mm left/right**, **5.5 mm top/bottom**

## Versions

- `Place_Layout_64x94_3x3.jsx` — original layout script.
- `Place_Layout_64x94_3x3_safe_v2.jsx` — safe version: skips files that fail to import, continues processing, and writes skipped-file errors to a TXT log.

## Workflow

1. Open an A4 portrait document.
2. Run the script.
3. Select the source folder.
4. Landscape images are rotated automatically.
5. Images are placed 3 × 3 and merged every 9 into one layer.

Supported formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## Tested safe-run result

The safe version was tested with a batch containing import failures:

- **143 processed**
- **4 skipped**
- **16 sheet layers**
- TXT error log created successfully

![Safe layout test report](tested-safe-layout-report-64x94.png)

## Status

**Safe version tested successfully in Photoshop CS6.**

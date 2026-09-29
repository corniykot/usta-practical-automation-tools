# Photoshop — Place Layout 64×94 (3×3)

Places all supported images from a selected folder into an active A4 portrait document, checks source orientation, resizes every image to exactly **64 × 94 mm**, and arranges up to **9 images per A4 sheet layer** in a **3 × 3** grid.

Every complete set of 9 images is merged into one Photoshop layer. A final incomplete set is also merged into one layer, so the result can be printed with the repository's **Print All Layers** tool.

## A4 layout

Designed for a portrait **A4 sheet, 210 × 297 mm**.

- Print size: **64 × 94 mm**
- Layout: **9 per A4 sheet (3 × 3)**
- Left/right margins: **7 mm**
- Top/bottom margins: **5.5 mm**
- Horizontal gaps: **2 mm**
- Vertical gaps: **2 mm**

### Horizontal

```text
7 mm | 64 | 2 | 64 | 2 | 64 | 7 mm
= 210 mm
```

### Vertical

```text
5.5 mm
94
2
94
2
94
5.5 mm
= 297 mm
```

## Workflow

1. Create or open an **A4 portrait document, 210 × 297 mm**, in Photoshop.
2. Run `Place_Layout_64x94_3x3.jsx`.
3. Select the folder containing the source images.
4. The script sorts the files alphabetically.
5. Landscape source files are automatically rotated 90° into portrait orientation.
6. Every image is forced to exactly **64 × 94 mm**.
7. Images are placed in a **3 × 3** grid using the exact margins and gaps above.
8. Every 9 images are merged into one layer named like `Sheet_01_9pcs`.
9. If the last sheet contains fewer than 9 images, it is merged into one layer such as `Sheet_03_4pcs`.

Supported source formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## Notes

- The script checks that the active document is approximately A4 portrait before processing.
- Images are initially placed as Smart Objects.
- Merging each sheet produces one final layer for that sheet.
- Source artwork should already have a suitable aspect ratio. The script enforces the exact target width and height and does not perform intelligent cropping.
- The generated sheet layers are intended to work directly with `photoshop/print-all-layers/`.

## Status

**Ready for production test in Photoshop CS6.**

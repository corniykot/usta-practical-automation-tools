# Photoshop A7 Batch Print Layout — 8 Images on A4, 72×102 mm

A free **Photoshop JSX / ExtendScript** for automatically preparing small-format images for print.

Select a folder and the script places different images at exactly **72 × 102 mm**, arranges **8 images on each A4 sheet**, and merges every completed sheet into a single Photoshop layer ready for printing.

The 72 × 102 mm print area is designed for **70 × 100 mm finished pieces with 1 mm bleed**.

## Where this workflow is useful

- **mini photo prints and photo labs** — batch-preparing small prints from many different files
- **portrait, school, and event photography** — creating repeatable multi-photo print sheets
- **small art prints and mini portfolios** — fitting multiple finished artworks onto A4 efficiently
- **stickers, sublimation, transfers, magnets, and craft production** — preparing small-format artwork with bleed for trimming or transfer
- **prepress and small-batch production** — automating repetitive exact-size placement in Photoshop

This is a production layout tool: it does not create a collage or edit the artwork. It automates the repetitive step between a folder of finished images and a print-ready A4 sheet.

## What the script does

- batch-imports supported images from a folder
- sorts files by filename
- corrects sideways orientation automatically
- places every image at exactly **72 × 102 mm**
- fits **8 different images per A4 sheet**
- merges each set of 8 into one sheet layer
- continues automatically with additional files

Supported formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## Versions

- `Place_Layout_72x102.jsx` — original tested version
- `Place_Layout_72x102_safe_v2.jsx` — fault-tolerant batch version

The safe version skips unreadable or failed files, logs the error, and continues without wasting a print position.

## How to run

1. Open an **A4 portrait document (210 × 297 mm)** in Photoshop.
2. Choose **File → Scripts → Browse…**
3. Select `Place_Layout_72x102.jsx` or `Place_Layout_72x102_safe_v2.jsx`.
4. Select the folder containing your source images.
5. Photoshop builds the print sheets automatically.

Optional: copy the JSX file into Photoshop's `Presets/Scripts` folder and restart Photoshop. It will then appear directly under **File → Scripts**.

## Tested result

The original script has been **tested successfully in Photoshop CS6**.

![Tested Photoshop CS6 result — 72×102 mm A7 print layout](tested-layout-72x102.png)

## Notes

- Images are initially placed as Smart Objects.
- Exact target dimensions are enforced; the script does not intelligently crop or recompose artwork.
- Standard ISO A7 is 74 × 105 mm. This production layout uses **72 × 102 mm** to provide a 1 mm bleed around a **70 × 100 mm finished piece**.
- Each completed sheet works directly with the repository's **Print All Layers** workflow.

## Status

**Original version tested successfully in Photoshop CS6. Safe version added; production testing still required.**

## Contact

Have a Photoshop routine that feels suspiciously like unpaid data entry? [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)

# Place Layout 102×142

Automatically places images from a folder into an A4 Photoshop document, corrects sideways orientation, resizes each image to exactly **102 × 142 mm**, and cycles through a **2 × 2 print layout**.

## Versions

- `Place_Layout_102x142.jsx` — original tested version.
- `Place_Layout_102x142_safe_v2.jsx` — safe batch version. Failed imports are skipped, processing continues, and errors are written to a TXT log beside the script or, if needed, in the source-image folder.

## Layout

Each image is exactly **102 × 142 mm**.

1. Top-left — X 2.5 mm, Y 4 mm
2. Top-right — X 105.5 mm, Y 4 mm
3. Bottom-left — X 2.5 mm, Y 148 mm
4. Bottom-right — X 105.5 mm, Y 148 mm

The positions repeat for additional files, creating stacked print sets.

## Requirements

- Adobe Photoshop with ExtendScript / JSX support
- Tested environment: Photoshop CS6
- Active A4 document, 210 × 297 mm

## How to run

1. Open the A4 target document in Photoshop.
2. Choose **File → Scripts → Browse…**
3. Select `Place_Layout_102x142.jsx` or `Place_Layout_102x142_safe_v2.jsx`.
4. Select the folder containing the source images.
5. The script checks orientation, resizes, names, and places the images automatically.

Optional: copy the JSX file into Photoshop's `Presets/Scripts` folder and restart Photoshop. It will then appear directly under **File → Scripts**.

Supported formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## Notes

- Images are placed as Smart Objects.
- Exact width and height are enforced independently.
- Safe version: a broken or unreadable image is logged and skipped without stopping the batch; the next valid image uses the same free layout position.

## Status

**Original version tested on Photoshop CS6. Safe version added for fault-tolerant batch processing; production testing still required.**

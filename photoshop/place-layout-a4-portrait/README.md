# Place Layout A4 Portrait

Automatically places every supported image from a folder into an active Photoshop document as a Smart Object, corrects sideways source orientation, resizes each image to exactly **210 × 297 mm**, and aligns it to the A4 canvas.

## Versions

- `Place_Layout_A4_Portrait.jsx` — original tested version.
- `Place_Layout_A4_Portrait_safe_v2.jsx` — safe batch version. Failed imports are skipped, the batch continues, and errors are written to a TXT log beside the script or in the source-image folder.

## Layout

Each image is resized to exactly **210 × 297 mm** and positioned at X 0 mm / Y 0 mm. Multiple files become stacked layers in the active document.

## Requirements

- Adobe Photoshop with ExtendScript / JSX support
- Tested environment: Photoshop CS6
- Active A4 portrait document, 210 × 297 mm

## How to run

1. Open the A4 portrait target document in Photoshop.
2. Choose **File → Scripts → Browse…**
3. Select `Place_Layout_A4_Portrait.jsx` or `Place_Layout_A4_Portrait_safe_v2.jsx`.
4. Select the folder containing the source images.
5. The script checks orientation, resizes, names, and aligns every valid image automatically.

Optional: copy the JSX file into Photoshop's `Presets/Scripts` folder and restart Photoshop. It will then appear directly under **File → Scripts**.

Supported formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## Notes

- Images are placed as Smart Objects.
- Width and height are forced independently to exactly 210 × 297 mm.
- Safe version: broken or unreadable images are skipped and logged instead of stopping the batch.

## Status

**Original version tested on Photoshop CS6. Safe version added for fault-tolerant batch processing; production testing still required.**

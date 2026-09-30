# Place Rotate Layout 142×202

Places every supported image from a selected folder into the active Photoshop document, normalizes sideways source orientation, resizes each image to exactly **142 × 202 mm**, rotates it **90°** for the A4 layout, and alternates between two fixed positions.

## Versions

- `Place_Rotate_Layout_142x202.jsx` — original tested version.
- `Place_Rotate_Layout_142x202_safe_v2.jsx` — safe batch version. If one image fails to import or process, it is skipped, the batch continues, and the error is written to a TXT log. The log is saved beside the script when possible, otherwise in the source-image folder.

## Layout

After the final layout rotation, each image occupies **202 × 142 mm** on A4.

1. Top — X 4 mm, Y 4 mm
2. Bottom — X 4 mm, Y 148 mm

The positions repeat for additional files, creating stacked print sets.

## Requirements

- Adobe Photoshop with ExtendScript / JSX support
- Tested environment: Photoshop CS6
- Active A4 document, 210 × 297 mm

## How to run

1. Open the A4 target document in Photoshop.
2. In Photoshop choose **File → Scripts → Browse…**
3. Select `Place_Rotate_Layout_142x202.jsx` or the safe version `Place_Rotate_Layout_142x202_safe_v2.jsx`.
4. Select the folder containing the source images.
5. The script handles orientation, exact sizing, rotation, naming, and placement automatically.

Optional: copy the JSX file into Photoshop's `Presets/Scripts` folder and restart Photoshop. The script will then appear directly under **File → Scripts**.

Supported formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## Notes

- Images are placed as Smart Objects.
- Width and height are forced independently to exactly 142 × 202 mm.
- Source orientation correction and the final 90° layout rotation are separate steps.
- Safe version: failed files do not consume a layout position; the next valid image uses that slot.

## Status

**Original version tested on Photoshop CS6. Safe version added for fault-tolerant batch processing; production testing still required.**

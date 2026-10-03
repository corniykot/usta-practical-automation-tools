# Photoshop A5 Print Layout Script — 142×202 mm on A4

A free **Photoshop JSX / ExtendScript** for automatically building an exact-size A5-style print layout from a folder of images.

The script batch-places images into Photoshop, checks their orientation, resizes every image to exactly **142 × 202 mm**, rotates it for printing, and positions **two images on an A4 sheet**.

Useful if you need to:

- print multiple images on one A4 sheet in Photoshop
- batch place and resize images automatically
- print images at an exact size in millimetres
- automate a repetitive Photoshop print layout
- prepare repeatable prepress or production sheets
- avoid opening, resizing, rotating, and positioning every image by hand

## What the script does

Choose a folder of images and the script handles the repetitive work:

- imports supported images as Smart Objects
- detects sideways source images and corrects their orientation
- resizes every valid image to exactly **142 × 202 mm**
- applies the required 90° print-layout rotation
- places images into fixed top and bottom positions on A4
- repeats the positions for additional files, creating stacked print sets

Supported formats: JPG, JPEG, PNG, TIFF, PSD, BMP.

## A5-style size

Standard A5 is **148 × 210 mm**. This production layout uses **142 × 202 mm**, so it is close to A5 but intentionally not standard A5.

The exact 142 × 202 mm size is preserved by the script.

## Versions

- `Place_Rotate_Layout_142x202.jsx` — original tested version.
- `Place_Rotate_Layout_142x202_safe_v2.jsx` — fault-tolerant batch version.

The safe version skips an image if Photoshop cannot import or process it, records the error in a TXT log, and continues with the next valid file instead of stopping the whole batch.

Failed files do not consume a layout position.

## A4 print layout

After the final 90° rotation, each image occupies **202 × 142 mm** on the sheet.

1. Top — X 4 mm, Y 4 mm
2. Bottom — X 4 mm, Y 148 mm

The vertical gap between the two positions is 2 mm.

Additional files repeat these positions as stacked layers.

## How to run the Photoshop script

1. Open an **A4 document (210 × 297 mm)** in Photoshop.
2. Choose **File → Scripts → Browse…**
3. Select `Place_Rotate_Layout_142x202.jsx` or `Place_Rotate_Layout_142x202_safe_v2.jsx`.
4. Select the folder containing your source images.
5. Photoshop processes the batch automatically.

Optional: copy the JSX file into Photoshop's `Presets/Scripts` folder and restart Photoshop. The script will then appear directly under **File → Scripts**.

## Why use a script instead of placing images manually?

A manual Photoshop print workflow usually means opening or placing each image, checking its orientation, resizing it, rotating it, and moving it into position.

This script turns those repeated steps into one folder-based batch operation.

It is useful as a lightweight Photoshop automation for exact-size printing when a fixed production layout matters more than a general-purpose contact sheet or collage.

## Requirements

- Adobe Photoshop with ExtendScript / JSX support
- Tested environment: Photoshop CS6
- Active A4 document, 210 × 297 mm

## Notes

- Images are placed as Smart Objects.
- Width and height are forced independently to exactly 142 × 202 mm.
- Source orientation correction and the final 90° layout rotation are separate steps.
- The script does not crop or intelligently recompose images.
- Source artwork should already have a suitable aspect ratio.

## Status

**Original version tested on Photoshop CS6. Safe version added for fault-tolerant batch processing; production testing still required.**

## Contact

Questions, feedback, or custom workflow requests: **usta.scripts@gmail.com**

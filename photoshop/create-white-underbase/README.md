# Photoshop White Underbase

Creates a **White spot channel** for print-production artwork without flattening or modifying the original layers.

Two source modes:

- **Active layer transparency** — builds the underbase from the selected artwork layer.
- **Everything except white** — builds it from the visible composite while excluding white / near-white background pixels.

Includes adjustable **choke** and **white tolerance**.

## Use

1. Open the artwork in Photoshop.
2. Run `Create_White_Underbase.jsx`.
3. Choose the source mode.
4. Set choke and, when needed, white tolerance.
5. Click **Create White**.
6. Inspect the resulting `White` spot channel before production.

The script does not save, print, flatten, resize, or overwrite the artwork.

Always inspect the generated separation and confirm spot-channel naming and underbase requirements with the target RIP / print workflow before production.

## Status

First production prototype — test on duplicate files before using it in a live print workflow.

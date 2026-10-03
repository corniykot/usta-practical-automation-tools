# Photoshop White Underbase — Spot White Channel with Choke

Create a **white ink underbase in Photoshop** without rebuilding the separation by hand.

This free JSX script turns artwork into a real **White spot channel**, applies an optional **choke**, and leaves the original artwork untouched. It is made for raster prepress jobs where white ink needs to sit under color on dark, transparent, metallic, or otherwise non-white media.

## What it automates

The usual manual workflow is simple but repetitive:

**select artwork → remove the background → contract the selection → create a spot channel → fill it → name it White → inspect it**

**Create White Underbase** does that in one pass.

Choose the source:

- **Active layer transparency** — useful for PSD artwork, logos, decals, transfers, DTF/DTG graphics, and other files that already have clean transparency.
- **Everything except white** — useful for flattened JPG/TIFF artwork supplied on a white background. Adjustable **White tolerance** ignores pure white and near-white pixels.

Then set the **Choke** in pixels. The script pulls the white separation slightly inside the color edge to help prevent a visible white halo caused by registration error or ink spread. The correct choke depends on the print process, resolution, media, and production setup.

## Result

The script creates a real Photoshop **Spot Color channel** named:

`White`

It does **not** create a fake white layer.

It does not flatten, merge, resize, print, save, or overwrite the artwork. After processing, the White channel remains visible so the separation can be inspected before the file goes to the RIP or production workflow.

If a `White` channel already exists, the script asks before replacing it.

## Useful for

- white ink printing
- white underbase preparation
- spot white separations
- DTF and DTG artwork preparation
- UV and flatbed printing
- printing on transparent, dark, colored, or metallic media
- print-shop and prepress workflows using Photoshop spot channels

## Why the spot channel matters

White ink is production data, not simply the color white in the artwork. Many print workflows expect white to be supplied as a separate spot separation, and the required channel name can depend on the RIP or printer setup.

This script uses `White` as its channel name. **Confirm the required spot name with your RIP or print provider before production.**

## Install

Place `Create_White_Underbase.jsx` in Photoshop's Scripts folder and restart Photoshop. Then run it from:

`File → Scripts → Create_White_Underbase`

It can also be launched directly through `File → Scripts → Browse...`.

## Production note

Always inspect the generated White separation before printing. Soft shadows, gradients, semi-transparent edges, fine detail, and intentionally unprinted areas may need manual prepress judgment; a one-click underbase should not replace that check.

## Status

**First public prototype.**

Built to remove a repetitive Photoshop prepress step while keeping the operator in control.

## Contact

Questions, feedback, or custom workflow requests: **usta.scripts@gmail.com**

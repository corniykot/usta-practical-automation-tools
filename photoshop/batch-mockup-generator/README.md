# Photoshop Batch Mockup Generator — Smart Object Replacement & Bulk Export

Generate multiple Photoshop mockups from a folder of designs without replacing the Smart Object by hand every single time.

**Batch Mockup Generator** takes an open PSD mockup, finds its Smart Object layers, lets you choose the design target, and processes a folder of PNG, JPEG, TIFF or PSD artwork automatically.

Choose **Fit** or **Fill**, select an output folder, and export the finished mockups as JPEG or PNG.

Built for the very common workflow:

```text
PSD mockup
    +
folder of designs
    ↓
replace Smart Object
fit / fill artwork
export mockup
repeat
    ↓
folder of finished mockups
```

In other words: the part where Photoshop is perfectly capable of doing the job, but would otherwise like you to do it 200 times.

## What it does

`Batch_Mockup_Generator.jsx` works with the currently open Photoshop mockup.

It can:

- detect Smart Object layers in the active PSD
- find Smart Objects inside layer groups
- let you choose which Smart Object receives the artwork
- batch process a folder of designs
- place PNG, JPEG, TIFF and PSD files
- scale each design using **Fit** or **Fill**
- center the placed artwork automatically
- export each finished mockup as **JPEG or PNG**
- use the source design filename for the exported mockup
- restore the original mockup state between designs
- leave the source PSD unchanged after the batch finishes

## Fit vs Fill

**Fit** scales the entire design to fit inside the Smart Object canvas while preserving its proportions. Empty space may remain when the aspect ratios differ.

**Fill** covers the entire Smart Object canvas while preserving proportions. Parts of the design may extend beyond the canvas when the aspect ratios differ.

No stretching.

## Typical uses

Useful for repetitive Photoshop mockup production such as:

- **batch mockup generation**
- **bulk Smart Object replacement**
- product mockups
- T-shirt and apparel mockups
- poster and art print mockups
- frame and wall-art mockups
- packaging mockups
- merchandise previews
- Etsy and marketplace product images
- print-on-demand artwork previews
- social and portfolio presentation images
- generating many mockups from one PSD template

If your workflow is basically **replace Smart Object → save image → replace Smart Object → save image → repeat**, this script is aimed directly at it.

## How to use

1. Open the Photoshop PSD mockup.
2. Run `Batch_Mockup_Generator.jsx`.
3. Select the Smart Object that should receive the designs.
4. Choose the folder containing your artwork.
5. Select **Fit** or **Fill**.
6. Choose an output folder.
7. Select **JPEG** or **PNG**.
8. Click **Generate**.

The script processes the files one by one and restores the mockup before inserting the next design.

## Supported input

Current prototype accepts:

- PNG
- JPG / JPEG
- TIFF
- PSD

## Output

Choose:

- **JPEG** with quality control
- **PNG**

Output files inherit the base filename of each source design.

Example:

```text
design-red.png   → design-red.jpg
design-blue.png  → design-blue.jpg
design-gold.psd  → design-gold.jpg
```

## Scope

This first version intentionally handles the simple, high-volume case:

**one PSD mockup + one selected Smart Object + one folder of designs.**

It is not trying to become a complete mockup production system.

Complex templates with multiple coordinated Smart Objects, linked artwork sets, nested replacement logic, CSV-driven jobs or multiple PSD templates may need a different workflow.

## Safety

The script returns the open mockup to its original Photoshop history state between designs and again when processing finishes.

It does not intentionally overwrite the source PSD.

As with any batch Photoshop automation, test it on copies before using it in a production workflow.

## Status

**First public prototype — testing in progress.**

The core workflow is implemented, but compatibility with different Photoshop versions and unusual Smart Object structures still needs broader testing.

## Search terms / problem this solves

Photoshop batch mockup generator, Photoshop mockup automation, batch replace Smart Objects, bulk Smart Object replacement, automate Photoshop mockups, generate mockups from folder, Photoshop product mockup script, batch product images, Photoshop JSX mockup automation.

## Contact

If Photoshop makes you do the same thing 200 times, tell us about it: [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com)

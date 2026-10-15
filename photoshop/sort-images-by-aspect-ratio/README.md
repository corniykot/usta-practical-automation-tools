# PNG Aspect Ratio Sorter — A4, Square, Other

A small **PowerShell image sorting utility** for production folders.

It scans PNG files, reads their pixel dimensions, calculates the aspect ratio, and copies each image into one of three automatically created folders:

- `A4` — A4 or A4-like proportions
- `Square` — square or effectively square images
- `Other` — everything that does not match the first two groups

The original files are **never moved, renamed, modified, or deleted**.

## Why this exists

Large artwork folders often contain a mix of portrait images, squares, 2:3 files, 3:4 files, panoramas, and other proportions.

For print preparation, it is useful to separate the obvious groups first and inspect the remaining formats as a second step.

This script performs that first-pass sorting automatically.

## Classification rules

The script always compares the **short side to the long side**, so portrait and landscape orientation are treated identically.

### Square

An image is classified as square when:

```text
short side / long side >= 0.99
```

Examples:

- 1000 × 1000 → Square
- 1000 × 995 → Square

### A4-like

True A4 has the ratio:

```text
210 / 297 = 0.7071
```

The sorter uses a deliberately broad **±10% tolerance**:

```text
approximately 0.6364 – 0.7778
```

This is intended for production triage rather than strict ISO paper validation.

### Other

Anything that is neither square nor inside the A4-like range goes into `Other`.

The `Other` folder can then be reviewed separately and split into additional format groups if needed.

## Safety

The script is non-destructive:

- source PNG files remain untouched
- files are copied, not moved
- output folders are created automatically
- existing copies are not overwritten
- rerunning the script is safe
- only PNG files directly inside the source folder are scanned

## Default folder

By default the script uses an English-named source folder:

```text
Desktop\Artwork
```

and creates:

```text
Desktop\Artwork\A4
Desktop\Artwork\Square
Desktop\Artwork\Other
```

You can also run it against another folder:

```powershell
.\Sort_PNG_By_Aspect_Ratio.ps1 -Source "D:\Artwork\Incoming"
```

## How to run

1. Open PowerShell.
2. Run the script, or right-click it and choose **Run with PowerShell**.
3. Wait for the classification report.
4. Review the three generated folders.

If PowerShell blocks local scripts, you can run it for the current session with an appropriate execution-policy setting used in your environment.

## Output

For every image, the console shows:

- filename
- pixel dimensions
- calculated aspect ratio
- assigned category

At the end it reports totals for:

- A4-like images
- square images
- other images
- newly copied files
- files that already existed
- read errors

## Requirements

- Windows PowerShell or PowerShell on Windows
- `System.Drawing`
- PNG source images

## File

`Sort_PNG_By_Aspect_Ratio.ps1`

## Search terms

PowerShell image sorter, sort images by aspect ratio, sort PNG by dimensions, A4 image sorter, square image sorter, batch image organization, image aspect ratio script, prepress image sorting, Photoshop production workflow.

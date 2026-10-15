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

## Part of the print-layout workflow

This sorter is intended as a **preparation step before the Photoshop placement scripts** in this repository.

First, use it to separate portrait/A4-like artwork from square and unusual proportions. Then send the prepared images into the appropriate production layout:

- [A4 portrait — 210 × 297 mm](../place-layout-a4-portrait/)
- [A5-style — 142 × 202 mm](../place-layout-a5-142x202/)
- [A6-style — 102 × 142 mm](../place-layout-a6-102x142/)
- [A7-style — 72 × 102 mm](../place-layout-a7-72x102/)
- [64 × 94 mm — 3 × 3 on A4](../place-layout-64x94/)

The sorter does **not** decide which final print size you need. It only performs the first proportion check so obviously incompatible source files can be separated before batch layout.

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

## Working folder

By default, the script processes the **current folder** — the folder where PowerShell was opened.

It creates three subfolders there:

```text
.\A4
.\Square
.\Other
```

No absolute path is hard-coded.

You can still point the script to another folder explicitly:

```powershell
.\Sort_PNG_By_Aspect_Ratio.ps1 -Source ".\Incoming"
```

## How to run

1. Put `Sort_PNG_By_Aspect_Ratio.ps1` in the folder containing the PNG files you want to sort.
2. Open that folder in **File Explorer**.
3. Click the address bar, type:

```text
powershell
```

4. Press **Enter**. PowerShell opens directly in that folder.
5. Run the script with the relative path:

```powershell
.\Sort_PNG_By_Aspect_Ratio.ps1
```

6. Wait for the classification report, then review the new `A4`, `Square`, and `Other` subfolders.

If PowerShell blocks local scripts, allow them for the current session only:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

Then run `.\Sort_PNG_By_Aspect_Ratio.ps1` again.

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

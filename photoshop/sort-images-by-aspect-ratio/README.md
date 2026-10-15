# Lightweight Image Aspect Ratio Sorter — A4, Square, Other

A small **no-install PowerShell image sorter** for quickly organizing large production folders by aspect ratio.

Drop one `.ps1` file into the folder, run it once, and get three automatically created groups:

- `A4` — A4 or A4-like proportions
- `Square` — square or effectively square images
- `Other` — everything that does not match the first two groups

Supported formats: **JPG, JPEG, PNG, BMP, GIF, TIF, TIFF**.

The original files are **never moved, renamed, modified, or deleted**.

## Why this exists

Large artwork folders can contain hundreds of mixed images: portraits, squares, 2:3 files, 3:4 files, panoramas, and other proportions.

Before print layout, it is faster to separate the obvious groups automatically than inspect every file by hand.

This script performs that first-pass sorting in one run.

## No installation required

This is a lightweight **single-file PowerShell utility**.

- no Photoshop required for the sorting step
- no third-party image organizer required
- no installer
- no permanent setup
- run it directly in the working folder and remove the script afterward if you no longer need it

It uses Windows PowerShell and `System.Drawing` to read image dimensions.

## Part of the print-layout workflow

This sorter is intended as a **preparation step before the Photoshop placement scripts** in this repository.

First, use it to separate portrait/A4-like artwork from square and unusual proportions. Then send the prepared images into the appropriate production layout:

- [A4 portrait — 210 × 297 mm](../place-layout-a4-portrait/)
- [A5-style — 142 × 202 mm](../place-layout-a5-142x202/)
- [A6-style — 102 × 142 mm](../place-layout-a6-102x142/)
- [A7-style — 72 × 102 mm](../place-layout-a7-72x102/)
- [64 × 94 mm — 3 × 3 on A4](../place-layout-64x94/)

The sorter does **not** decide which final print size you need. It only separates obviously different proportions before batch layout.

## Classification rules

The script compares the **short side to the long side**, so portrait and landscape orientation are treated identically.

### Square

An image is classified as square when:

```text
short side / long side >= 0.99
```

### A4-like

A4 proportion with **±10% tolerance**.

### Other

Anything that is neither square nor A4-like goes into `Other`.

## Safety

The script is non-destructive:

- source images remain untouched
- files are copied, not moved
- output folders are created automatically
- existing copies are not overwritten
- rerunning the script is safe
- only supported image files directly inside the source folder are scanned

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
.\Sort_Images_By_Aspect_Ratio.ps1 -Source ".\Incoming"
```

## How to run

1. Put `Sort_Images_By_Aspect_Ratio.ps1` in the folder containing the images you want to sort.
2. Open that folder in **File Explorer**.
3. Click the address bar, type:

```text
powershell
```

4. Press **Enter**.
5. Run:

```powershell
.\Sort_Images_By_Aspect_Ratio.ps1
```

6. Review the new `A4`, `Square`, and `Other` folders.

If PowerShell blocks local scripts, allow them for the current session only:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
```

Then run the script again.

## Output

For every image, the console shows:

- filename
- pixel dimensions
- calculated aspect ratio
- assigned category

At the end it reports totals for each category, copied files, existing files, and read errors.

## Requirements

- Windows PowerShell or PowerShell on Windows
- `System.Drawing`

## Contact

If “I’ll sort these by eye” means opening a folder with **400 images** and slowly reconsidering your life choices, write to us before image 237. Send the next repetitive production step to [**usta.scripts@gmail.com**](mailto:usta.scripts@gmail.com) — it may deserve a script too.

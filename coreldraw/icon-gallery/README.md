# CorelDRAW icon gallery (local resource extractor)

Generate an easy-to-browse, searchable HTML gallery of icon resources from your **own installed** CorelDRAW application. Every thumbnail is labeled with its zero-based DLL resource index.

No external utilities, downloads or Python dependencies are needed: Windows PowerShell + built-in Windows libraries only.

## CorelDRAW 2018

Run in PowerShell:

```powershell
irm https://raw.githubusercontent.com/corniykot/usta-practical-automation-tools/main/coreldraw/icon-gallery/Export-CorelIcons.ps1 | iex 
```

Or download the script first and run it locally:

```powershell
powershell.exe -ExecutionPolicy Bypass -File ".\Export-CorelIcons.ps1"
```

By default, it reads:

```text
C:\Program Files\Corel\CorelDRAW Graphics Suite 2018\Programs64\CrlIcons.dll
```

and opens the resulting `USTA-Corel-Icon-Gallery/index.html` on your Desktop. You can also supply `-DllPath` and `-OutputDirectory` explicitly.

## Notes

- This uses Windows `ExtractIconEx` to extract **standard Windows icon resources**. CorelDRAW may also use proprietary resources that the Windows API cannot extract. A DLL's file size does not imply all images are standard icons.
- It does not modify CorelDRAW, the DLL, or user workspaces.
- Icon images are **Corel's third-party assets**. The generated PNGs are for inspecting your local installed copy; do not commit or redistribute the full library without permission. This repository publishes only the extractor and gallery generator.
- DLL icon indices are not guaranteed to remain stable between CorelDRAW versions. A visual selection does not automatically register an image in a CorelDRAW add-on.

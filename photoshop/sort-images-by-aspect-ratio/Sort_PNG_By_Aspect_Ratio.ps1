param(
    [string]$Source
)

Add-Type -AssemblyName System.Drawing

# Default source folder: Desktop\Artwork
if ([string]::IsNullOrWhiteSpace($Source)) {
    $desktop = [Environment]::GetFolderPath("Desktop")
    $Source = Join-Path $desktop "Artwork"
}

if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
    Write-Error "Source folder not found: $Source"
    exit 1
}

$a4Folder     = Join-Path $Source "A4"
$squareFolder = Join-Path $Source "Square"
$otherFolder  = Join-Path $Source "Other"

# Create output folders automatically.
New-Item -ItemType Directory -Force -Path $a4Folder     | Out-Null
New-Item -ItemType Directory -Force -Path $squareFolder | Out-Null
New-Item -ItemType Directory -Force -Path $otherFolder  | Out-Null

# A4 aspect ratio using short side / long side.
# A4 = 210 / 297 = approximately 0.7071.
# This workflow intentionally accepts +/-10% around the A4 ratio.
$a4Ratio = 210 / 297
$a4Min   = $a4Ratio * 0.90
$a4Max   = $a4Ratio * 1.10

$a4Count = 0
$squareCount = 0
$otherCount = 0
$errorCount = 0
$copiedCount = 0
$existingCount = 0

# Process only PNG files directly inside the source folder.
# Output subfolders are not scanned.
$files = Get-ChildItem -LiteralPath $Source -File -Filter *.png

foreach ($file in $files) {
    $img = $null

    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)

        $width  = $img.Width
        $height = $img.Height

        $shortSide = [Math]::Min($width, $height)
        $longSide  = [Math]::Max($width, $height)
        $ratio = $shortSide / $longSide

        # Check squares first so they can never be classified as A4-like.
        if ($ratio -ge 0.99) {
            $destination = $squareFolder
            $category = "Square"
            $squareCount++
        }
        elseif ($ratio -ge $a4Min -and $ratio -le $a4Max) {
            $destination = $a4Folder
            $category = "A4"
            $a4Count++
        }
        else {
            $destination = $otherFolder
            $category = "Other"
            $otherCount++
        }

        $target = Join-Path $destination $file.Name

        # Originals are never moved, renamed, modified, or deleted.
        # Existing copies are skipped so rerunning the script is safe.
        if (-not (Test-Path -LiteralPath $target)) {
            Copy-Item -LiteralPath $file.FullName -Destination $target
            $copiedCount++
        }
        else {
            $existingCount++
        }

        Write-Host (
            "{0} | {1}x{2} | ratio={3} | {4}" -f
            $file.Name,
            $width,
            $height,
            ([Math]::Round($ratio, 4)),
            $category
        )
    }
    catch {
        Write-Warning "Could not read: $($file.Name) | $($_.Exception.Message)"
        $errorCount++
    }
    finally {
        if ($img -ne $null) {
            $img.Dispose()
        }
    }
}

Write-Host ""
Write-Host "Done."
Write-Host "A4-like (+/-10%): $a4Count"
Write-Host "Square:           $squareCount"
Write-Host "Other:            $otherCount"
Write-Host "Copied:           $copiedCount"
Write-Host "Already existed:  $existingCount"
Write-Host "Errors:           $errorCount"
Write-Host ""
Write-Host (
    "A4 ratio range: {0} - {1}" -f
    ([Math]::Round($a4Min, 4)),
    ([Math]::Round($a4Max, 4))
)
Write-Host "Original PNG files were not modified."

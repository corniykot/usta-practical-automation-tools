param(
    [string]$Source
)

Add-Type -AssemblyName System.Drawing

# Varsayılan olarak PowerShell'in açıldığı klasörü işler.
if ([string]::IsNullOrWhiteSpace($Source)) {
    $Source = (Get-Location).Path
}

if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
    Write-Error "Kaynak klasör bulunamadı: $Source"
    exit 1
}

$a4Folder     = Join-Path $Source "A4"
$squareFolder = Join-Path $Source "Square"
$otherFolder  = Join-Path $Source "Other"

# Çıktı klasörlerini otomatik oluştur.
New-Item -ItemType Directory -Force -Path $a4Folder     | Out-Null
New-Item -ItemType Directory -Force -Path $squareFolder | Out-Null
New-Item -ItemType Directory -Force -Path $otherFolder  | Out-Null

# System.Drawing tarafından desteklenen formatlar.
$supportedExtensions = @(
    ".jpg",
    ".jpeg",
    ".png",
    ".bmp",
    ".gif",
    ".tif",
    ".tiff"
)

# A4 oranı: kısa kenar / uzun kenar, +/-10% tolerans.
$a4Ratio = 210 / 297
$a4Min   = $a4Ratio * 0.90
$a4Max   = $a4Ratio * 1.10

$a4Count = 0
$squareCount = 0
$otherCount = 0
$errorCount = 0
$copiedCount = 0
$existingCount = 0

# Yalnızca kaynak klasörün içindeki desteklenen görselleri işle.
# Oluşturulan alt klasörler taranmaz.
$files = Get-ChildItem -LiteralPath $Source -File | Where-Object {
    $supportedExtensions -contains $_.Extension.ToLowerInvariant()
}

foreach ($file in $files) {
    $img = $null

    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)

        $width  = $img.Width
        $height = $img.Height

        $shortSide = [Math]::Min($width, $height)
        $longSide  = [Math]::Max($width, $height)
        $ratio = $shortSide / $longSide

        # Kareleri önce kontrol et; A4-benzeri olarak sınıflandırılmasınlar.
        if ($ratio -ge 0.99) {
            $destination = $squareFolder
            $category = "Kare"
            $squareCount++
        }
        elseif ($ratio -ge $a4Min -and $ratio -le $a4Max) {
            $destination = $a4Folder
            $category = "A4"
            $a4Count++
        }
        else {
            $destination = $otherFolder
            $category = "Diğer"
            $otherCount++
        }

        $target = Join-Path $destination $file.Name

        # Orijinaller taşınmaz, yeniden adlandırılmaz, değiştirilmez veya silinmez.
        # Mevcut kopyalar atlanır; script tekrar güvenle çalıştırılabilir.
        if (-not (Test-Path -LiteralPath $target)) {
            Copy-Item -LiteralPath $file.FullName -Destination $target
            $copiedCount++
        }
        else {
            $existingCount++
        }

        Write-Host (
            "{0} | {1}x{2} | oran={3} | {4}" -f
            $file.Name,
            $width,
            $height,
            ([Math]::Round($ratio, 4)),
            $category
        )
    }
    catch {
        Write-Warning "Okunamadı: $($file.Name) | $($_.Exception.Message)"
        $errorCount++
    }
    finally {
        if ($img -ne $null) {
            $img.Dispose()
        }
    }
}

Write-Host ""
Write-Host "Tamamlandı."
Write-Host "A4-benzeri (+/-10%): $a4Count"
Write-Host "Kare:                $squareCount"
Write-Host "Diğer:                $otherCount"
Write-Host "Kopyalandı:           $copiedCount"
Write-Host "Zaten vardı:          $existingCount"
Write-Host "Hata:                 $errorCount"
Write-Host ""
Write-Host "Orijinal görsel dosyaları değiştirilmedi."

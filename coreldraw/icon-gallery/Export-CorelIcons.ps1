# CorelDRAW resource icon gallery — local extractor for Windows PowerShell 5.1+
# Reads your legally installed CorelDRAW library; does not modify it.
param(
    [string]$DllPath = 'C:\Program Files\Corel\CorelDRAW Graphics Suite 2018\Programs64\CrlIcons.dll',
    [string]$OutputDirectory = (Join-Path ([Environment]::GetFolderPath('Desktop')) 'USTA-Corel-Icon-Gallery')
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $DllPath -PathType Leaf)) {
    throw "Icon library not found: $DllPath"
}

Add-Type -ReferencedAssemblies @('System.Drawing') -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class CorelIconNative {
    [DllImport("shell32.dll", CharSet=CharSet.Unicode, EntryPoint="ExtractIconExW")]
    public static extern uint ExtractIconEx(string file, int index,
        [Out] IntPtr[] large, [Out] IntPtr[] small, uint count);

    [DllImport("user32.dll", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool DestroyIcon(IntPtr hIcon);
}
'@

Add-Type -AssemblyName System.Drawing
$iconsDir = Join-Path $OutputDirectory 'icons'
New-Item -ItemType Directory -Path $iconsDir -Force | Out-Null
$count = [int][CorelIconNative]::ExtractIconEx($DllPath, -1, $null, $null, 0)
if ($count -lt 1) {
    throw "No standard Windows icon resources found. Corel may store the images in a different resource format."
}
Write-Host "Icon count reported by Windows: $count"

# ExtractIconEx uses zero-based indices, which the resulting gallery preserves.
$indices = [System.Collections.Generic.List[int]]::new()
$blockSize = 64
for ($start = 0; $start -lt $count; $start += $blockSize) {
    $n = [Math]::Min($blockSize, $count - $start)
    $large = New-Object 'System.IntPtr[]' $n
    $small = New-Object 'System.IntPtr[]' $n
    $obtained = [int][CorelIconNative]::ExtractIconEx($DllPath, $start, $large, $small, [uint32]$n)
    for ($i = 0; $i -lt $n; $i++) {
        $idx = $start + $i
        $h = if ($large[$i] -ne [IntPtr]::Zero) { $large[$i] } else { $small[$i] }
        try {
            if ($h -ne [IntPtr]::Zero) {
                $icon = [System.Drawing.Icon]::FromHandle($h)
                $bitmap = $icon.ToBitmap()
                try {
                    $png = Join-Path $iconsDir ('{0:D5}.png' -f $idx)
                    $bitmap.Save($png, [System.Drawing.Imaging.ImageFormat]::Png)
                    $indices.Add($idx)
                } finally {
                    $bitmap.Dispose()
                }
            }
        } finally {
            if ($large[$i] -ne [IntPtr]::Zero) {
                [void][CorelIconNative]::DestroyIcon($large[$i])
            }
            if ($small[$i] -ne [IntPtr]::Zero) {
                [void][CorelIconNative]::DestroyIcon($small[$i])
            }
        }
    }
    Write-Progress -Activity "Exporting CorelDRAW icons" -Status "$([Math]::Min($start+$n,$count)) / $count" -PercentComplete ([int](100 * [Math]::Min($start+$n,$count) / $count))
}
Write-Progress -Activity "Exporting CorelDRAW icons" -Completed

$json = ConvertTo-Json -InputObject @($indices.ToArray()) -Compress
$template = @'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>CorelDRAW Icon Gallery — Local</title>
<style>
:root{color-scheme:dark;font-family:Segoe UI,Arial,sans-serif}
body{background:#1f242c;color:#e7ebef;margin:0;padding:24px}
h1{margin:0 0 8px;font-size:24px}
p{color:#a9b3c2}
.bar{display:flex;gap:12px;align-items:center;flex-wrap:wrap;position:sticky;top:0;background:#1f242c;padding:14px 0;z-index:2}
input{background:#343c49;border:1px solid #667080;border-radius:6px;color:white;padding:9px;font-size:15px;width:200px}
button{background:#414b59;border:0;border-radius:6px;color:white;padding:9px 12px;cursor:pointer}
button:disabled{opacity:.4}
#grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(98px,1fr));gap:10px}
.cell{background:#303744;border:1px solid #495364;border-radius:8px;display:flex;align-items:center;justify-content:center;flex-direction:column;height:88px;gap:8px}
.cell img{width:40px;height:40px;object-fit:contain;image-rendering:auto}
.cell span{font-size:12px;color:#bac2ce;font-variant-numeric:tabular-nums}
</style>
</head>
<body>
<h1>CorelDRAW icon gallery</h1>
<p>Icons exported from your local installation. The number under each icon is its zero-based resource index.</p>
<div class="bar">
<label>Index <input id="filter" placeholder="e.g. 123" inputmode="numeric"></label>
<button id="prev">← Previous</button><span id="status"></span><button id="next">Next →</button>
</div>
<div id="grid"></div>
<script>
const icons=__ICON_INDEX_JSON__;
const perPage=120;
let page=0;
const grid=document.getElementById('grid'),filter=document.getElementById('filter');
const prev=document.getElementById('prev'),next=document.getElementById('next'),status=document.getElementById('status');
function render(){
 const needle=filter.value.trim();
 const matching=icons.filter(n=>!needle || String(n).includes(needle));
 const pages=Math.max(1,Math.ceil(matching.length/perPage));page=Math.min(page,pages-1);
 grid.replaceChildren();
 for(const n of matching.slice(page*perPage,(page+1)*perPage)){
  const el=document.createElement('div');el.className='cell';
  const im=document.createElement('img');im.src='icons/'+String(n).padStart(5,'0')+'.png';im.loading='lazy';im.alt='Icon '+n;
  const label=document.createElement('span');label.textContent='#'+n;
  el.append(im,label);grid.append(el);
 }
 status.textContent='Page '+(page+1)+'/'+pages+' · '+matching.length+' icons';
 prev.disabled=page===0;next.disabled=page===pages-1;
}
filter.addEventListener('input',()=>{page=0;render()});
prev.addEventListener('click',()=>{page--;render()});
next.addEventListener('click',()=>{page++;render()});
render();
</script>
</body>
</html>
'@
$html = $template.Replace('__ICON_INDEX_JSON__', $json)
$indexPath = Join-Path $OutputDirectory 'index.html'
[System.IO.File]::WriteAllText($indexPath, $html, [System.Text.UTF8Encoding]::new($false))
Write-Host "Exported $($indices.Count) icons to: $iconsDir"
Write-Host "Gallery: $indexPath"
Start-Process $indexPath

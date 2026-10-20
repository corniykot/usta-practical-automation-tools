# Read-only UI diagnostics. Never starts or terminates CorelDRAW.
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$OutputIni)
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$lines=[Collections.Generic.List[string]]::new()
$processes=@(Get-Process -Name CorelDRW -ErrorAction SilentlyContinue)
$lines.Add('[Running]'); $lines.Add('Count='+$processes.Count)
$index=0
foreach($process in $processes){
    $exe=$null; $major=0; $label='CorelDRAW (version unavailable)'; $icon=''
    try {$exe=$process.Path} catch {}
    if($exe){
        $v=[Diagnostics.FileVersionInfo]::GetVersionInfo($exe); $major=$v.FileMajorPart
        $edition=if($major -eq 17){'X7'}elseif($major -eq 18){'X8'}elseif($major -ge 19 -and $major -le 24){[string]($major+1998)}else{$v.ProductVersion}
        $stream=[IO.File]::OpenRead($exe); $reader=[IO.BinaryReader]::new($stream)
        try {$stream.Position=60;$pe=$reader.ReadInt32();$stream.Position=$pe+4;$bits=if($reader.ReadUInt16() -eq 0x8664){64}else{32}}finally{$reader.Dispose()}
        $label='CorelDRAW Graphics Suite '+$edition+' ('+$bits+'-bit)'
        try {
            $icon=Join-Path ([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($OutputIni))) ('corel-'+$process.Id+'.bmp')
            $ico=[Drawing.Icon]::ExtractAssociatedIcon($exe)
            try {$bmp=$ico.ToBitmap();try{$bmp.Save($icon,[Drawing.Imaging.ImageFormat]::Bmp)}finally{$bmp.Dispose()}}finally{$ico.Dispose()}
        } catch {$icon=''}
    }
    $lines.Add('[Process'+$index+']')
    $lines.Add('Label='+$label);$lines.Add('PID='+$process.Id);$lines.Add('Exe='+$exe);$lines.Add('Icon='+$icon)
    $lines.Add('Responding='+$process.Responding);$index++
}
[IO.File]::WriteAllLines([IO.Path]::GetFullPath($OutputIni),$lines,[Text.Encoding]::Unicode)

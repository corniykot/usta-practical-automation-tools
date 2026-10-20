# USTA Smart Node Cleaner v0.77
[CmdletBinding()]
param([string]$OutputJson,[string]$OutputIni)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Read-WorkspaceInfo([string]$Path) {
    $zip=[IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $entry=$zip.GetEntry('content/workspace.xml')
        if (!$entry) { return }
        $reader=[IO.StreamReader]::new($entry.Open())
        try { $doc=[xml]$reader.ReadToEnd() } finally { $reader.Dispose() }
        $info=$doc.SelectSingleNode('/uiConfig/applicationInfo')
        if ($info -and $info.GetAttribute('name') -eq 'CorelDRAW') {
            [pscustomobject]@{Major=[int]($info.GetAttribute('version').Split('.')[0]);Path=$Path}
        }
    } finally { $zip.Dispose() }
}
$programs=@{}
foreach($view in @([Microsoft.Win32.RegistryView]::Registry64,[Microsoft.Win32.RegistryView]::Registry32)) {
    $classes=[Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::ClassesRoot,$view)
    try {
        foreach($name in $classes.GetSubKeyNames() | Where-Object {$_ -match '^CorelDRAW\.Application\.\d+$'}) {
            $key=$classes.OpenSubKey($name+'\CLSID'); if(!$key){continue}
            try {$clsid=$key.GetValue('')} finally {$key.Dispose()}
            $server=$classes.OpenSubKey('CLSID\'+$clsid+'\LocalServer32'); if(!$server){continue}
            try {$command=[string]$server.GetValue('')} finally {$server.Dispose()}
            $match=[regex]::Match($command,'^\s*(?:"([^"]+\.exe)"|(.+?\.exe))(?:\s|$)', 'IgnoreCase')
            if(!$match.Success){continue}
            $exe=$match.Groups[1].Value; if(!$exe){$exe=$match.Groups[2].Value}
            $exe=[Environment]::ExpandEnvironmentVariables($exe)
            if(!(Test-Path -LiteralPath $exe -PathType Leaf)){continue}
            $major=[Diagnostics.FileVersionInfo]::GetVersionInfo($exe).FileMajorPart
            if($major -lt 17 -or $major -gt 24 -or [int]($name.Split('.')[-1]) -ne $major){continue}
            # Verify the executable's PE machine; never infer bitness from a folder name.
            $stream=[IO.File]::OpenRead($exe); $reader=[IO.BinaryReader]::new($stream)
            try {$stream.Position=60; $pe=$reader.ReadInt32(); $stream.Position=$pe+4; $x64=$reader.ReadUInt16() -eq 0x8664} finally {$reader.Dispose()}
            if(!$x64){continue}
            $programs[$major]=[pscustomobject]@{Major=$major;Exe=$exe;ProgId=$name}
        }
    } finally {$classes.Dispose()}
}
$profiles=@{}
$corelRoot=Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Corel'
if(Test-Path -LiteralPath $corelRoot) {
    foreach($profile in Get-ChildItem -LiteralPath $corelRoot -Directory) {
        $folder=Join-Path $profile.FullName 'Draw\Workspace'
        if(!(Test-Path -LiteralPath $folder)){continue}
        foreach($file in Get-ChildItem -LiteralPath $folder -Filter '*.cdws' -File) {
            try {
                $info=Read-WorkspaceInfo $file.FullName
                if($info) {
                    $id=[string]$info.Major+'|'+$profile.FullName
                    $profiles[$id]=[pscustomobject]@{Major=$info.Major;Profile=$profile.FullName;Label=$profile.Name;GmsPath=(Join-Path $profile.FullName 'Draw\GMS');WorkspaceFolder=$folder}
                }
            } catch {Write-Warning ('Skipped unreadable workspace: '+$file.FullName+'; '+$_.Exception.Message)}
        }
    }
}
$targets=@()
foreach($p in $profiles.Values | Sort-Object Major -Descending) {
    if($programs.ContainsKey([int]$p.Major)) {
        $program=$programs[[int]$p.Major]
        $targets += [pscustomobject]@{Label=($p.Label+' (64-bit)');Major=$p.Major;Exe=$program.Exe;ProgId=$program.ProgId;Profile=$p.Profile;GmsPath=$p.GmsPath;WorkspaceFolder=$p.WorkspaceFolder}
    }
}
$result=ConvertTo-Json -InputObject @($targets) -Depth 5
if($OutputIni){
    $lines=[Collections.Generic.List[string]]::new();$lines.Add('[Targets]');$lines.Add('Count='+$targets.Count);$index=0
    foreach($target in $targets){$lines.Add('[Target'+$index+']');foreach($property in $target.PSObject.Properties){$lines.Add($property.Name+'='+$property.Value)};$index++}
    [IO.File]::WriteAllLines([IO.Path]::GetFullPath($OutputIni),$lines,[Text.Encoding]::Unicode)
}
if($OutputJson){[IO.File]::WriteAllText([IO.Path]::GetFullPath($OutputJson),[string]$result,[Text.UTF8Encoding]::new($false))}
$result

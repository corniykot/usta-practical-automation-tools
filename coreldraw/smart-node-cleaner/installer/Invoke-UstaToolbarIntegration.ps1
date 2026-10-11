# Installer adapter for the unchanged Add-UstaToolbarButton.ps1.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$WorkspacePath,
    [Parameter(Mandatory=$true)][string]$LogPath,
    [string]$ScriptPath,
    [string]$IconPath,
    [string]$OutputPath,
    [switch]$CheckOnly
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$exitCode = 0
$transcribing = $false
try {
    $logDirectory = Split-Path -Parent $LogPath
    [void][IO.Directory]::CreateDirectory($logDirectory)
    Start-Transcript -LiteralPath $LogPath -Force | Out-Null
    $transcribing = $true
    Write-Output ('UTC: ' + [DateTime]::UtcNow.ToString('o'))
    Write-Output ('PowerShell: ' + $PSVersionTable.PSVersion + '; 64-bit: ' + [Environment]::Is64BitProcess)
    Write-Output ('Workspace: ' + $WorkspacePath)
    Write-Output ('Script: ' + $ScriptPath + '; Icon: ' + $IconPath)
    Write-Output ('CheckOnly: ' + $CheckOnly + '; OutputPath: ' + $OutputPath)
    # Fresh Windows PowerShell does not resolve ZipArchiveMode merely by loading
    # FileSystem. Load BOTH assemblies before invoking the protected helper.
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (Get-Process -Name CorelDRW -ErrorAction SilentlyContinue) {
        throw 'Close CorelDRAW before installation; no workspace change is safe while it is running.'
    }
    $WorkspacePath = (Resolve-Path -LiteralPath $WorkspacePath).Path
    $zip = [IO.Compression.ZipFile]::OpenRead($WorkspacePath)
    try {
        $entry = $zip.GetEntry('content/workspace.xml')
        if (!$entry) { throw 'The target is not a CorelDRAW workspace archive.' }
        $reader = [IO.StreamReader]::new($entry.Open())
        try { $xml = [xml]$reader.ReadToEnd() } finally { $reader.Dispose() }
        $info = $xml.SelectSingleNode('/uiConfig/applicationInfo')
        if (!$info -or $info.GetAttribute('name') -ne 'CorelDRAW' -or $info.GetAttribute('version') -ne '20') {
            throw 'Expected a CorelDRAW 2018 (version 20) workspace.'
        }
        if ($xml.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='c2b44f69-6dec-444e-a37e-5dbf7ff43dae']/toolbar").Count -ne 1) {
            throw 'Expected exactly one Standard toolbar in the target workspace.'
        }
    } finally { $zip.Dispose() }
    if ($CheckOnly) {
        Write-Output 'PASS: pre-install workspace and process checks.'
    } else {
        if (!$ScriptPath -or !$IconPath) { throw 'ScriptPath and IconPath are required for integration.' }
        $arguments = @{ WorkspacePath=$WorkspacePath; IconPath=$IconPath }
        if ($OutputPath) { $arguments.OutputPath=$OutputPath }
        $result = & $ScriptPath @arguments
        Write-Output ($result | Format-List | Out-String)
        Write-Output 'PASS: toolbar integration completed.'
    }
} catch {
    $exitCode = 1
    Write-Output 'FAIL: toolbar integration or pre-install check.'
    Write-Output ($_ | Format-List * -Force | Out-String)
    Write-Output ($_.Exception.ToString())
    Write-Output $_.ScriptStackTrace
} finally {
    if ($transcribing) { Stop-Transcript | Out-Null }
}
exit $exitCode

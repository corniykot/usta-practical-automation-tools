# USTA Smart Node Cleaner v0.77
[CmdletBinding()]
param([ValidateSet('Detect','Check','Install','Uninstall','UninstallAll')][string]$Mode='Detect',[ValidateScript({$_ -eq 0 -or ($_ -ge 17 -and $_ -le 24)})][int]$Major=0,[string]$ProfilePath,[string]$StateRoot=(Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Usta.Scripts\SmartNodeCleaner\v0.77'),[switch]$ReplaceExistingGms,[string]$ResultIni)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Usta.Files.ps1')
if($Mode -eq 'Detect'){& (Join-Path $PSScriptRoot 'Get-CorelTargets.ps1');return}
if($Mode -eq 'UninstallAll'){
    if(Get-Process CorelDRW -ErrorAction SilentlyContinue){throw 'Close CorelDRAW before uninstalling; no process will be terminated.'}
    if(!(Test-Path -LiteralPath $StateRoot)){return}
    $records=@(Get-ChildItem -LiteralPath $StateRoot -Filter installation.json -File -Recurse)
    foreach($file in $records){$record=Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json;Invoke-UstaFiles -Mode Uninstall -Profile $record.Profile -Major $record.Major -Source $PSScriptRoot -State $file.DirectoryName -CheckOnly | Out-Null}
    foreach($file in $records){$record=Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json;Invoke-UstaFiles -Mode Uninstall -Profile $record.Profile -Major $record.Major -Source $PSScriptRoot -State $file.DirectoryName | ConvertTo-Json -Depth 6}
    return
}
$targets=@((& (Join-Path $PSScriptRoot 'Get-CorelTargets.ps1') | Out-String | ConvertFrom-Json) | Where-Object {$Major -eq 0 -or $_.Major -eq $Major})
if($ProfilePath){$targets=@($targets | Where-Object {$_.Profile -ieq [IO.Path]::GetFullPath($ProfilePath)})}
if($targets.Count -ne 1){throw 'Select exactly one detected target with -Major and, if needed, -ProfilePath. Run -Mode Detect first.'}
$target=$targets[0]
$Major=[int]$target.Major
$sha=[Security.Cryptography.SHA256]::Create();try{$id=[BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($target.Profile.ToLowerInvariant()))).Replace('-','').Substring(0,16)}finally{$sha.Dispose()}
$state=Join-Path $StateRoot ($Major.ToString()+'-'+$id)
[void][IO.Directory]::CreateDirectory($state)
$log=Join-Path $state ((Get-Date -Format yyyyMMdd-HHmmss)+'-'+$Mode+'.log')
Start-Transcript -LiteralPath $log | Out-Null
try{$operation=$Mode;if($Mode -eq 'Check'){$operation='Install'};Invoke-UstaFiles -Mode $operation -Profile $target.Profile -Major $Major -Source $PSScriptRoot -State $state -ReplaceExistingGms:$ReplaceExistingGms -CheckOnly:($Mode -eq 'Check') | ConvertTo-Json -Depth 6}
catch {
    if($ResultIni){
        $message=$_.Exception.Message -replace '[\r\n]+',' '
        [IO.File]::WriteAllLines([IO.Path]::GetFullPath($ResultIni),@('[Result]',('Message='+$message)),[Text.Encoding]::Unicode)
    }
    throw
}finally{Stop-Transcript | Out-Null}

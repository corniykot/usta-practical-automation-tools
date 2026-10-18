# USTA Smart Node Cleaner v0.75
[CmdletBinding()]
param([ValidateSet('Detect','Install','Uninstall')][string]$Mode='Detect',[ValidateScript({$_ -eq 0 -or ($_ -ge 17 -and $_ -le 24)})][int]$Major=0,[string]$ProfilePath,[string]$StateRoot=(Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'Usta.Scripts\SmartNodeCleaner\v0.75'),[switch]$ReplaceExistingGms)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Usta.Files.ps1')
if($Mode -eq 'Detect'){& (Join-Path $PSScriptRoot 'Get-CorelTargets.ps1');return}
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
try{Invoke-UstaFiles -Mode $Mode -Profile $target.Profile -Major $Major -Source $PSScriptRoot -State $state -ReplaceExistingGms:$ReplaceExistingGms | ConvertTo-Json -Depth 6}finally{Stop-Transcript | Out-Null}

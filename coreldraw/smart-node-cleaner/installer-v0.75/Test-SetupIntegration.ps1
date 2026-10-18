# USTA Smart Node Cleaner v0.75
param([Parameter(Mandatory=$true)][string]$TestRoot)
$ErrorActionPreference='Stop'
& (Join-Path $PSScriptRoot 'Test-Local.ps1') -TestRoot $TestRoot
. (Join-Path $PSScriptRoot 'Usta.Files.ps1')
$results=[Collections.Generic.List[object]]::new()
function Check($value,$name){if(!$value){throw $name};$results.Add([pscustomobject]@{Test=$name;Status='PASS'})}
$root=Join-Path $TestRoot 'setup-state'
$profile=Join-Path $TestRoot '23-1\Profile';$state=Join-Path $root '23'
$workspace=Join-Path $profile 'Draw\Workspace\_default.cdws';$hash=(Get-FileHash $workspace).Hash
$null=Invoke-UstaFiles Install $profile 23 $PSScriptRoot $state -CheckOnly
Check ((Get-FileHash $workspace).Hash -eq $hash) 'Setup preflight leaves workspace unchanged'
Check (!(Test-Path (Join-Path $profile 'Draw\GMS\UstaSmartNodeCleaner.gms'))) 'Setup preflight does not install GMS'
Check (!(Test-Path (Join-Path $state 'installation.json'))) 'Setup preflight does not claim installed state'
$profiles=@();$hashes=@()
foreach($major in @(17,24)){
    $p=Join-Path $TestRoot ($major.ToString()+'-1\Profile');$profiles+=$p
    $hashes+=(Get-FileHash (Join-Path $p 'Draw\Workspace\_default.cdws')).Hash
    $null=Invoke-UstaFiles Install $p $major $PSScriptRoot (Join-Path $root $major)
}
$changed=Join-Path $profiles[1] 'Draw\GMS\UstaSmartNodeCleaner.gms'
[IO.File]::AppendAllText($changed,'user edit')
$blocked=$false
try{& (Join-Path $PSScriptRoot 'Manage-Usta.ps1') -Mode UninstallAll -StateRoot $root | Out-Null}catch{$blocked=$_.Exception.Message -like 'GMS modified*'}
Check $blocked 'Uninstall blocks on edited GMS'
Check (Test-Path (Join-Path $root '17\installation.json')) 'Failed precheck preserves other target ownership'
Check (Test-Path (Join-Path $profiles[0] 'Draw\GMS\UstaSmartNodeCleaner.gms')) 'Failed precheck preserves other target GMS'
[IO.File]::Copy((Join-Path $PSScriptRoot 'UstaSmartNodeCleaner.gms'),$changed,$true)
& (Join-Path $PSScriptRoot 'Manage-Usta.ps1') -Mode UninstallAll -StateRoot $root | Out-Null
for($i=0;$i -lt 2;$i++){
    Check (!(Test-Path (Join-Path $profiles[$i] 'Draw\GMS\UstaSmartNodeCleaner.gms'))) ('UninstallAll removes owned GMS '+$i)
    $x=Read-UstaXml (Join-Path $profiles[$i] 'Draw\Workspace\_default.cdws')
    Check (!$x.SelectSingleNode("//*[@guid='$script:Button' or @guidRef='$script:Button']")) ('UninstallAll removes owned button '+$i)
}
$results | ConvertTo-Json -Depth 4 | Set-Content (Join-Path $TestRoot 'setup-results.json') -Encoding UTF8
'PASS: '+$results.Count+' installer integration assertions; EXE UI is not tested by this script.'

# Run after Test-SetupIntegration. Uses only its synthetic profile and copied sources.
param([Parameter(Mandatory=$true)][string]$TestRoot)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Usta.Files.ps1')
$profile=Join-Path ([IO.Path]::GetFullPath($TestRoot)) '17-1\Profile'
$fixture=Join-Path ([IO.Path]::GetFullPath($TestRoot)) 'error-report-fixture'
[void][IO.Directory]::CreateDirectory($fixture)
foreach($name in @('Manage-Usta.ps1','Usta.Files.ps1','Add-UstaToolbarButton.ps1','UstaSmartNodeCleaner.gms','Usta_Smart_Node_Cleaner.ico')){
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination (Join-Path $fixture $name)
}
$state=Join-Path $fixture 'state'
$sha=[Security.Cryptography.SHA256]::Create()
try{$id=[BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($profile.ToLowerInvariant()))).Replace('-','').Substring(0,16)}finally{$sha.Dispose()}
$owned=Join-Path $state ('17-'+$id)
$null=Invoke-UstaFiles Install $profile 17 $PSScriptRoot $owned
$workspace=Join-Path $profile 'Draw\Workspace\_default.cdws'
$before=(Get-FileHash $workspace).Hash
$json=ConvertTo-Json -InputObject @([pscustomobject]@{Major=17;Profile=$profile}) -Compress
$literal=$json.Replace("'","''")
[IO.File]::WriteAllText((Join-Path $fixture 'Get-CorelTargets.ps1'),("'"+$literal+"'"))
$report=Join-Path $fixture 'preflight.ini'
$caught=$false
try{& (Join-Path $fixture 'Manage-Usta.ps1') -Mode Check -Major 17 -StateRoot $state -ResultIni $report | Out-Null}catch{$caught=$true}
if(!$caught){throw 'Repeated installation did not fail'}
$text=Get-Content -LiteralPath $report -Raw
if($text -notmatch 'Message=Already installed\. Uninstall this version first\.'){throw 'Actual preflight error was not reported'}
if((Get-FileHash $workspace).Hash -ne $before){throw 'Failed check changed workspace'}
'PASS: repeated-install preflight writes its exact reason and preserves workspace.'

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][ValidateSet('Check','Install')][string]$Mode,
    [Parameter(Mandatory=$true)][string]$WorkspaceFolder,
    [Parameter(Mandatory=$true)][string]$GmsPath,
    [Parameter(Mandatory=$true)][int]$ExpectedMajor,
    [Parameter(Mandatory=$true)][string]$ExePath,
    [Parameter(Mandatory=$true)][string]$ProgId,
    [Parameter(Mandatory=$true)][string]$SourceDir,
    [Parameter(Mandatory=$true)][string]$LogPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSHOME 'Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShell.Utility.psd1') -ErrorAction Stop
$recording=$false
$exitCode=0
$staged=@();$changed=@();$created=@();$rollbackFiles=@()
try {
    [void][IO.Directory]::CreateDirectory((Split-Path -Parent $LogPath))
    Start-Transcript -LiteralPath $LogPath -Force | Out-Null;$recording=$true
    Write-Output ('UTC: '+[DateTime]::UtcNow.ToString('o'))
    Write-Output ('Mode='+$Mode+'; PowerShell='+$PSVersionTable.PSVersion+'; 64-bit='+[Environment]::Is64BitProcess)
    Write-Output ('Executable='+$ExePath+'; Major='+$ExpectedMajor+'; GMS='+$GmsPath+'; Workspaces='+$WorkspaceFolder)
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if(Get-Process -Name CorelDRW -ErrorAction SilentlyContinue){throw 'Close CorelDRAW before installation. No process will be terminated automatically.'}
    if(!(Test-Path -LiteralPath $ExePath -PathType Leaf) -or [Diagnostics.FileVersionInfo]::GetVersionInfo($ExePath).FileMajorPart -ne $ExpectedMajor){throw 'Detected CorelDRAW executable/version no longer matches.'}
    $WorkspaceFolder=(Resolve-Path -LiteralPath $WorkspaceFolder).Path
    $draw=[IO.Path]::GetDirectoryName($WorkspaceFolder)
    if([IO.Path]::GetFileName($WorkspaceFolder) -ine 'Workspace' -or [IO.Path]::GetFullPath($GmsPath).TrimEnd('\') -ine (Join-Path $draw 'GMS')){throw 'GMS and workspace paths do not belong to the same detected Draw profile.'}
    if($ProgId -ne ('CorelDRAW.Application.'+$ExpectedMajor)){throw 'Version-specific ProgID required.'}
    $sourceGms=$null
    $sourceIcon=Join-Path $SourceDir 'Usta_Smart_Node_Cleaner.ico'
    $helper=Join-Path $SourceDir 'Add-UstaToolbarButton.MultiVersion.ps1'
    foreach($name in @('USTA_Node_Cleaner_v0_73_Engine.bas','frmUSTANodeCleaner_v0_73_CODE.txt','Build-NativeGms.ps1','Usta_Smart_Node_Cleaner.ico','Add-UstaToolbarButton.MultiVersion.ps1')){if(!(Test-Path -LiteralPath (Join-Path $SourceDir $name) -PathType Leaf)){throw ('Missing native source payload: '+$name)}}
    if((Get-FileHash -LiteralPath $sourceIcon).Hash -ne '57DE42FEFA72FCB9F6B9A89E6EDEF7B522320D860504AF9BFBEF3DB743CF4284'){throw 'ICO payload checksum mismatch.'}
    $nativeDestination=Join-Path $GmsPath 'UstaSmartNodeCleanerV09.gms'
    $oldNativeHash=''
    if(Test-Path -LiteralPath $nativeDestination){
        $oldNativeHash=(Get-FileHash -LiteralPath $nativeDestination).Hash
        $oldManifest=Get-Content -LiteralPath ($nativeDestination+'.install.json') -Raw | ConvertFrom-Json
        if($oldManifest.GmsSHA256 -ne $oldNativeHash -or [int]$oldManifest.HostMajor -ne $ExpectedMajor){throw 'Existing v0.9 GMS was edited or built for another host; preserve it.'}
    }
    $iconDestination=Join-Path $GmsPath 'Usta_Smart_Node_Cleaner.ico'
    if((Test-Path -LiteralPath $iconDestination) -and (Get-FileHash -LiteralPath $iconDestination).Hash -ne (Get-FileHash -LiteralPath $sourceIcon).Hash){throw 'Different existing ICO preserved.'}
    $workspaces=@()
    foreach($file in Get-ChildItem -LiteralPath $WorkspaceFolder -Filter '*.cdws' -File) {
        $zip=[IO.Compression.ZipFile]::OpenRead($file.FullName)
        try {
            $entry=$zip.GetEntry('content/workspace.xml');if(!$entry){throw ('Invalid workspace: '+$file.FullName)}
            $reader=[IO.StreamReader]::new($entry.Open());try {$doc=[xml]$reader.ReadToEnd()} finally {$reader.Dispose()}
            $info=$doc.SelectSingleNode('/uiConfig/applicationInfo')
            if(!$info -or $info.GetAttribute('name') -ne 'CorelDRAW' -or [int]($info.GetAttribute('version').Split('.')[0]) -ne $ExpectedMajor){throw ('Workspace/executable version mismatch: '+$file.FullName)}
            $bars=$doc.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='c2b44f69-6dec-444e-a37e-5dbf7ff43dae']/toolbar")
            if($bars.Count -eq 1 -and $doc.SelectSingleNode('/uiConfig/items')) {$workspaces += $file.FullName}
            else {Write-Output ('No compatible Standard toolbar; leave unchanged: '+$file.FullName)}
        } finally {$zip.Dispose()}
    }
    if(!$workspaces.Count){throw 'No compatible saved Standard toolbar found. Start the selected CorelDRAW once, close it, then retry.'}
    Write-Output ('Validated compatible workspaces: '+$workspaces.Count)
    if($Mode -eq 'Install') {
        $buildDir=Join-Path (Split-Path -Parent $LogPath) ('native-'+[guid]::NewGuid().ToString('N'))
        [void][IO.Directory]::CreateDirectory($buildDir)
        $sourceGms=Join-Path $buildDir 'UstaSmartNodeCleanerV09.gms'
        $resultFile=Join-Path $buildDir 'build.json'
        function Q([string]$Value){return '"'+$Value+'"'}
        $arguments='-NoProfile -NonInteractive -STA -ExecutionPolicy Bypass -File '+(Q (Join-Path $SourceDir 'Build-NativeGms.ps1'))+' -ProgId '+$ProgId+' -ExpectedMajor '+$ExpectedMajor+' -SourceDir '+(Q $SourceDir)+' -OutputGms '+(Q $sourceGms)+' -ResultPath '+(Q $resultFile)
        if($oldNativeHash){$arguments += ' -ExistingOwnedGms '+(Q $nativeDestination)}
        $psi=[Diagnostics.ProcessStartInfo]::new((Join-Path $PSHOME 'powershell.exe'),$arguments)
        $psi.UseShellExecute=$false;$psi.CreateNoWindow=$true
        $child=[Diagnostics.Process]::Start($psi)
        if(!$child.WaitForExit(180000)){$child.Kill();throw ('Native build timed out. No workspace changed. Inspect: '+$resultFile+'.log')}
        if($child.ExitCode -ne 0){throw ('Native build failed. No workspace changed. Inspect: '+$resultFile+'.log')}
        $native=Get-Content -LiteralPath $resultFile -Raw | ConvertFrom-Json
        if($native.Status -ne 'PASS' -or !$native.Compiled -or !$native.Reloaded -or !$native.SourceVerified){throw 'Incomplete native build verification.'}
        if((Get-FileHash -LiteralPath $sourceGms).Hash -ne $native.GmsSHA256){throw 'Native artifact changed after verification.'}
        if([IO.Path]::GetFullPath($native.UserGMSPath).TrimEnd('\') -ine [IO.Path]::GetFullPath($GmsPath).TrimEnd('\')){throw 'Native host reports another GMS folder; nothing installed.'}
        $deadline=[DateTime]::UtcNow.AddSeconds(15)
        while((Get-Process -Name CorelDRW -ErrorAction SilentlyContinue) -and [DateTime]::UtcNow -lt $deadline){Start-Sleep -Milliseconds 200}
        if(Get-Process -Name CorelDRW -ErrorAction SilentlyContinue){throw 'Owned build host is still running; no workspace change is safe.'}
        # Build and validate every changed archive before touching any user file.
        foreach($workspace in $workspaces) {
            $candidate=Join-Path ([IO.Path]::GetTempPath()) ('usta-stage-'+[guid]::NewGuid().ToString('N')+'.cdws')
            $item=[pscustomobject]@{Original=$workspace;Candidate=$candidate;Hash=(Get-FileHash -LiteralPath $workspace).Hash;Backup=($workspace+'.usta-v09-'+[guid]::NewGuid().ToString('N')+'.bak')}
            $staged += $item
            & $helper -WorkspacePath $workspace -IconPath $sourceIcon -ExpectedMajor $ExpectedMajor -OutputPath $candidate | Format-List | Out-String | Write-Output
        }
        if(Get-Process -Name CorelDRW -ErrorAction SilentlyContinue){throw 'CorelDRAW started during preparation; installation cancelled before changing user files.'}
        foreach($item in $staged){if((Get-FileHash -LiteralPath $item.Original).Hash -ne $item.Hash){throw ('Workspace changed during preparation: '+$item.Original)}}
        [void][IO.Directory]::CreateDirectory($GmsPath)
        if((Test-Path -LiteralPath $nativeDestination) -and (Get-FileHash -LiteralPath $nativeDestination).Hash -ne $oldNativeHash){throw 'Existing native GMS changed during preparation.'}
        if(!(Test-Path -LiteralPath $nativeDestination) -and $oldNativeHash){throw 'Existing native GMS disappeared during preparation.'}
        $payloads=@([pscustomobject]@{Source=$sourceGms;Target=$nativeDestination},[pscustomobject]@{Source=$resultFile;Target=($nativeDestination+'.install.json')})
        if(!(Test-Path -LiteralPath $iconDestination)){$payloads += [pscustomobject]@{Source=$sourceIcon;Target=$iconDestination}}
        foreach($payload in $payloads){
            if(Get-Process -Name CorelDRW -ErrorAction SilentlyContinue){throw 'CorelDRAW started during installation; stopping and rolling back.'}
            if(Test-Path -LiteralPath $payload.Target){
                $backup=$payload.Target+'.usta-v09-'+[guid]::NewGuid().ToString('N')+'.bak'
                [IO.File]::Copy($payload.Target,$backup,$false)
                $rollbackFiles += [pscustomobject]@{Original=$payload.Target;Backup=$backup}
            } else {$created += $payload.Target}
            [IO.File]::Copy($payload.Source,$payload.Target,$true)
        }
        foreach($item in $staged) {
            if(Get-Process -Name CorelDRW -ErrorAction SilentlyContinue){throw 'CorelDRAW started during installation; stopping and rolling back.'}
            [IO.File]::Copy($item.Original,$item.Backup,$false)
            $changed += $item
            [IO.File]::Copy($item.Candidate,$item.Original,$true)
        }
        [pscustomobject]@{Version=$ExpectedMajor;NativeBuild=$native;GmsPath=$nativeDestination;Workspaces=@($changed | Select-Object Original,Backup);CreatedFiles=$created;GmsSHA256=(Get-FileHash -LiteralPath $nativeDestination).Hash} | ConvertTo-Json -Depth 7 | Set-Content -LiteralPath (Join-Path (Split-Path -Parent $LogPath) 'installation.json') -Encoding UTF8
        Write-Output 'PASS: target-native GMS installed; original icon embedded; USTA appended to Standard toolbars.'
    } else {Write-Output 'PASS: read-only installation preflight.'}
} catch {
    $exitCode=1
    Write-Output ('FAIL: '+$_.Exception.ToString());Write-Output $_.ScriptStackTrace
    foreach($item in @($changed)+@($rollbackFiles)) {
        try {[IO.File]::Copy($item.Backup,$item.Original,$true);Write-Output ('Rolled back: '+$item.Original)} catch {Write-Output ('ROLLBACK FAILED: '+$_.Exception.Message)}
    }
    foreach($file in $created) {try {[IO.File]::Delete($file)} catch {Write-Output ('Could not remove newly created payload: '+$file)}}
} finally {
    foreach($item in $staged){if(Test-Path -LiteralPath $item.Candidate){[IO.File]::Delete($item.Candidate)}}
    if($recording){Stop-Transcript | Out-Null}
}
exit $exitCode

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$ProgId,
    [Parameter(Mandatory=$true)][int]$ExpectedMajor,
    [Parameter(Mandatory=$true)][string]$SourceDir,
    [Parameter(Mandatory=$true)][string]$OutputGms,
    [Parameter(Mandatory=$true)][string]$ResultPath,
    [string]$ProjectName='UstaSmartNodeCleanerV09',
    [string]$ExistingOwnedGms,
    [switch]$AttachForTest
)
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
Import-Module (Join-Path $PSHOME 'Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShell.Utility.psd1') -ErrorAction Stop
$app=$null;$project=$null;$ownsHost=$false;$loaded=$false
$transcript=$false
function Normalize-Code([string]$Code) {
    $lines=@($Code -split '\r?\n' | Where-Object {$_.Trim() -and $_ -notmatch '^\s*Attribute\s'} | ForEach-Object {
        # VBE changes identifier case. Preserve string literals exactly.
        [regex]::Replace($_.Trim(),'"(?:[^"]|"")*"|[^"]+', [Text.RegularExpressions.MatchEvaluator]{param($m) if($m.Value.StartsWith('"')){$m.Value}else{$m.Value.ToLowerInvariant()}})
    })
    return $lines -join "`n"
}
function Host-Command([int]$Id) {
    $control=$app.VBE.CommandBars.FindControl(1,$Id)
    if(!$control){throw ('Required VBE host command unavailable: '+$Id)}
    return $control
}
function Save-NativeProject {
    $app.VBE.ActiveVBProject=$app.VBE.VBProjects.Item($ProjectName)
    (Host-Command 3).Execute()
    $deadline=[DateTime]::UtcNow.AddSeconds(15)
    while($app.GMSManager.Projects.Item($ProjectName).Dirty -and [DateTime]::UtcNow -lt $deadline){Start-Sleep -Milliseconds 100}
    if($app.GMSManager.Projects.Item($ProjectName).Dirty -or !(Test-Path -LiteralPath $OutputGms)){throw 'Native host did not save the GMS.'}
}
try {
    [void][IO.Directory]::CreateDirectory((Split-Path -Parent $ResultPath))
    Start-Transcript -LiteralPath ($ResultPath+'.log') -Force | Out-Null;$transcript=$true
    if($ProgId -notmatch '^CorelDRAW\.Application\.\d+$' -or [int]($ProgId.Split('.')[-1]) -ne $ExpectedMajor){throw 'Version-specific CorelDRAW ProgID required.'}
    if($ProjectName -notmatch '^[A-Za-z_]\w*$'){throw 'Invalid VBA project name.'}
    $OutputGms=[IO.Path]::GetFullPath($OutputGms)
    if(Test-Path -LiteralPath $OutputGms){throw 'Disposable output GMS already exists; never overwrite.'}
    $enginePath=Join-Path $SourceDir 'USTA_Node_Cleaner_v0_73_Engine.bas'
    $formPath=Join-Path $SourceDir 'frmUSTANodeCleaner_v0_73_CODE.txt'
    $engine=[IO.File]::ReadAllText($enginePath,[Text.Encoding]::UTF8)
    $form=[IO.File]::ReadAllText($formPath,[Text.Encoding]::UTF8)
    if($engine -notmatch 'Public Sub UstaSmartNodeCleanerV073\(' -or $form -notmatch 'Private Sub UserForm_Initialize\(' -or $form -notmatch 'https://www.paypal.com/ncp/payment/PUPB8U5QQFLYU'){throw 'Unexpected or incomplete VBA source bundle.'}
    if($AttachForTest) {
        # Explicit test mode: no workspace changes, no host shutdown and unique project only.
        if($ProjectName -eq 'UstaSmartNodeCleaner'){throw 'AttachForTest requires a disposable project name.'}
        $app=[Runtime.InteropServices.Marshal]::GetActiveObject($ProgId)
    } else {
        if(Get-Process -Name CorelDRW -ErrorAction SilentlyContinue){throw 'Close CorelDRAW first. The builder will create and close its own host instance.'}
        $beforeIds=@(Get-Process -Name CorelDRW -ErrorAction SilentlyContinue | ForEach-Object Id)
        $app=New-Object -ComObject $ProgId
        $newProcesses=@(Get-Process -Name CorelDRW -ErrorAction SilentlyContinue | Where-Object {$beforeIds -notcontains $_.Id})
        if(!$newProcesses.Count){throw 'Cannot establish ownership of the activated host process; it will not be closed.'}
        foreach($process in $newProcesses){if($process.MainWindowTitle -match 'Trial Expired|Evaluation Expired'){throw 'Selected CorelDRAW is in an expired trial mode. Native VBA build is unavailable; no license setting will be changed.'}}
        if($app.Documents.Count -ne 0){throw 'Activated host already has documents; preserving the existing session.'}
        $ownsHost=$true
    }
    if([int]$app.VersionMajor -ne $ExpectedMajor){throw 'COM activation returned the wrong CorelDRAW version.'}
    $actualGmsPath=[string]$app.GMSManager.UserGMSPath
    Write-Output ('Native host version: '+$app.VersionMajor+'; UserGMSPath: '+$actualGmsPath)
    foreach($existing in $app.GMSManager.Projects){
        if($existing.Name -eq $ProjectName){
            # Only a previous v0.9 installation with its own matching hash may be unloaded.
            # The original v0.73 macro/project has a different identity and is never touched.
            if(!$AttachForTest -and $ExistingOwnedGms -and $ProjectName -eq 'UstaSmartNodeCleanerV09' -and
               [IO.Path]::GetFullPath($existing.FullFileName) -ieq [IO.Path]::GetFullPath($ExistingOwnedGms)){
                $manifest=Get-Content -LiteralPath ($ExistingOwnedGms+'.install.json') -Raw | ConvertFrom-Json
                if($manifest.GmsSHA256 -ne (Get-FileHash -LiteralPath $ExistingOwnedGms).Hash){throw 'Previous native GMS was edited; preserve it.'}
                $existing.Unload()
            } else {throw ('Project already loaded; preserved: '+$ProjectName)}
        }
    }
    [void][IO.Directory]::CreateDirectory((Split-Path -Parent $OutputGms))
    $project=$app.GMSManager.Projects.Create($ProjectName,$false,$OutputGms);$loaded=$true
    $vb=$app.VBE.VBProjects.Item($ProjectName)
    $module=$vb.VBComponents.Add(1)
    $module.Name='Module1'
    # "Require Variable Declaration" may insert Option Explicit on another PC.
    # Replace only the brand-new component's generated code, not any user module.
    if($module.CodeModule.CountOfLines -gt 0){$module.CodeModule.DeleteLines(1,$module.CodeModule.CountOfLines)}
    $module.CodeModule.AddFromString(($engine -replace '\r?\n',"`r`n"))
    $vb=$app.VBE.VBProjects.Item($ProjectName)
    # This specific form constructs ALL controls and layout in UserForm_Initialize.
    # Create the form in the target VBA host; do not pretend code-only text is a general FRM export.
    $formComponent=$vb.VBComponents.Add(3)
    $formComponent.Name='frmUSTANodeCleaner'
    $formComponent.Properties.Item('BorderStyle').Value=0
    $formComponent.Properties.Item('StartUpPosition').Value=1
    if($formComponent.CodeModule.CountOfLines -gt 0){$formComponent.CodeModule.DeleteLines(1,$formComponent.CodeModule.CountOfLines)}
    $formComponent.CodeModule.AddFromString(($form -replace '\r?\n',"`r`n"))
    $vb=$app.VBE.VBProjects.Item($ProjectName)
    $references=@()
    foreach($reference in $vb.References){
        $references += [pscustomobject]@{Name=$reference.Name;IsBroken=[bool]$reference.IsBroken;Path=$reference.FullPath}
        if($reference.IsBroken){throw ('Broken native reference: '+$reference.Name)}
    }
    if(!@($references | Where-Object Name -eq 'MSForms').Count){throw 'Native Microsoft Forms reference missing.'}
    $app.VBE.ActiveVBProject=$vb
    $compile=Host-Command 578
    if($compile.Enabled){$compile.Execute()}
    $deadline=[DateTime]::UtcNow.AddSeconds(30)
    while((Host-Command 578).Enabled -and [DateTime]::UtcNow -lt $deadline){Start-Sleep -Milliseconds 150}
    if((Host-Command 578).Enabled){throw 'Compilation did not complete. Inspect the native VBE compiler message; security will not be changed.'}
    Save-NativeProject
    $app.GMSManager.Projects.Item($ProjectName).Unload();$loaded=$false
    $project=$app.GMSManager.Projects.Load($OutputGms,$false,$false);$loaded=$true
    $vb=$app.VBE.VBProjects.Item($ProjectName)
    $module=$vb.VBComponents.Item('Module1');$formComponent=$vb.VBComponents.Item('frmUSTANodeCleaner')
    if($module.Type -ne 1 -or $formComponent.Type -ne 3){throw 'Reloaded module/form type mismatch.'}
    $engineActual=$module.CodeModule.Lines(1,$module.CodeModule.CountOfLines)
    $formActual=$formComponent.CodeModule.Lines(1,$formComponent.CodeModule.CountOfLines)
    if((Normalize-Code $engineActual) -cne (Normalize-Code $engine) -or (Normalize-Code $formActual) -cne (Normalize-Code $form)){throw 'Reloaded VBA source does not match the supplied sources.'}
    if($formComponent.Properties.Item('BorderStyle').Value -ne 0){throw 'Reloaded form design property mismatch.'}
    foreach($reference in $vb.References){if($reference.IsBroken){throw ('Broken reference after reload: '+$reference.Name)}}
    # Capture the final on-disk hash only after the host has released the project.
    Save-NativeProject
    $app.GMSManager.Projects.Item($ProjectName).Unload();$loaded=$false
    $result=[ordered]@{Status='PASS';HostMajor=[int]$app.VersionMajor;ProgId=$ProgId;ProjectName=$ProjectName;UserGMSPath=$actualGmsPath;GmsPath=$OutputGms;GmsSHA256=(Get-FileHash -LiteralPath $OutputGms).Hash;EngineSHA256=(Get-FileHash -LiteralPath $enginePath).Hash;FormSHA256=(Get-FileHash -LiteralPath $formPath).Hash;References=$references;Compiled=$true;Reloaded=$true;SourceVerified=$true;FormBorderStyle=0;FunctionalTest='NOT_RUN_BY_INSTALLER'}
    $result | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
    Write-Output 'PASS: target-native GMS compiled, saved, reloaded and source-verified.'
} catch {
    [pscustomobject]@{Status='BLOCKED';Message=$_.Exception.ToString();Stack=$_.ScriptStackTrace;ProgId=$ProgId;HostMajor=$ExpectedMajor} | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $ResultPath -Encoding UTF8
    Write-Output $_.Exception.ToString()
    exit 1
} finally {
    if($loaded -and $app){try {$app.GMSManager.Projects.Item($ProjectName).Unload()} catch {Write-Output ('Disposable project unload failed: '+$_.Exception.Message)}}
    if($ownsHost -and $app){try {$app.Quit()} catch {Write-Output ('Owned host could not close: '+$_.Exception.Message)}}
    if($app){try {[void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($app)} catch {}}
    if($transcript){Stop-Transcript | Out-Null}
}

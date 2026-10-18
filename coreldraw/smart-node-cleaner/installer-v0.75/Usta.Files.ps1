# USTA Smart Node Cleaner v0.75
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$script:Button='9ec68916-62d5-4a5c-9558-cb60977da5e3'
$script:Icon='d49df810-0118-48b7-a0a4-9bd3e721c913'
$script:Standard='c2b44f69-6dec-444e-a37e-5dbf7ff43dae'
function Read-UstaXml([string]$Path){
    $z=[IO.Compression.ZipFile]::OpenRead($Path)
    try{$e=$z.GetEntry('content/workspace.xml');if(!$e){throw 'Missing workspace.xml'};$r=[IO.StreamReader]::new($e.Open());try{$x=[xml]::new();$x.PreserveWhitespace=$true;$x.LoadXml($r.ReadToEnd());return $x}finally{$r.Dispose()}}finally{$z.Dispose()}
}
function Remove-UstaButton([string]$InputPath,[string]$OutputPath,[bool]$RemoveSeparator){
    [IO.File]::Copy($InputPath,$OutputPath,$false)
    $x=Read-UstaXml $InputPath
    foreach($n in @($x.SelectNodes("//*[@guidRef='$script:Button']"))){
        $previous=$n.PreviousSibling
        if($RemoveSeparator -and $previous -and $previous.LocalName -eq 'item' -and $previous.GetAttribute('guidRef') -eq '266435b4-6e53-460f-9fa7-f45be187d400'){[void]$previous.ParentNode.RemoveChild($previous)}
        [void]$n.ParentNode.RemoveChild($n)
    }
    foreach($n in @($x.SelectNodes("/uiConfig/items/itemData[@guid='$script:Button']"))){[void]$n.ParentNode.RemoveChild($n)}
    $z=[IO.Compression.ZipFile]::Open($OutputPath,[IO.Compression.ZipArchiveMode]::Update)
    try{$z.GetEntry('content/workspace.xml').Delete();$w=[IO.StreamWriter]::new($z.CreateEntry('content/workspace.xml').Open(),[Text.UTF8Encoding]::new($false));try{$w.Write($x.OuterXml)}finally{$w.Dispose()}
        if(!$x.SelectSingleNode("//*[@icon='guid://$script:Icon']")){$e=$z.GetEntry("content/icons/$script:Icon.ico");if($e){$e.Delete()}}
    }finally{$z.Dispose()}
    $check=Read-UstaXml $OutputPath
    if($check.SelectSingleNode("//*[@guidRef='$script:Button' or @guid='$script:Button']")){throw 'Button removal verification failed'}
}
function Invoke-UstaFiles {
    param([ValidateSet('Install','Uninstall')][string]$Mode,[string]$Profile,[int]$Major,[string]$Source,[string]$State,[switch]$ReplaceExistingGms,[switch]$CheckOnly)
    if($Major -lt 17 -or $Major -gt 24){throw 'Supported internal versions: 17 through 24'}
    if(Get-Process CorelDRW -ErrorAction SilentlyContinue){throw 'Close CorelDRAW first; no process will be terminated.'}
    $Profile=[IO.Path]::GetFullPath($Profile);$State=[IO.Path]::GetFullPath($State)
    $gms=Join-Path $Profile 'Draw\GMS\UstaSmartNodeCleaner.gms'
    $folder=Join-Path $Profile 'Draw\Workspace'
    $manifest=Join-Path $State 'installation.json'
    [void][IO.Directory]::CreateDirectory($State)
    $run=Join-Path $State ([guid]::NewGuid().ToString('N'));[void][IO.Directory]::CreateDirectory($run)
    $changes=@();$applied=@();$gmsChanged=$false;$hadGms=Test-Path -LiteralPath $gms
    $oldGms=$null;$createdDirectory=$false
    try{
        if($Mode -eq 'Install'){
            if(Test-Path -LiteralPath $manifest){throw 'Already installed. Uninstall this version first.'}
            $payload=Join-Path $Source 'UstaSmartNodeCleaner.gms';$ico=Join-Path $Source 'Usta_Smart_Node_Cleaner.ico'
            $payloadHash=(Get-FileHash -LiteralPath $payload).Hash
            if($payloadHash -ne '510E4A7ED648745BA9F5301E9DA647223A82BB26491F0AB42C8BDD9EDC6786FC' -or (Get-FileHash -LiteralPath $ico).Hash -ne '57DE42FEFA72FCB9F6B9A89E6EDEF7B522320D860504AF9BFBEF3DB743CF4284'){throw 'GMS 0.75 / original ICO payload checksum mismatch'}
            if($hadGms){$oldGms=Join-Path $run 'previous.gms';[IO.File]::Copy($gms,$oldGms,$false);if((Get-FileHash -LiteralPath $gms).Hash -ne $payloadHash -and !$ReplaceExistingGms){throw 'Different existing GMS preserved. Explicit -ReplaceExistingGms required; it will be backed up.'}}
            foreach($file in Get-ChildItem -LiteralPath $folder -Filter *.cdws -File){
                $x=Read-UstaXml $file.FullName;$info=$x.SelectSingleNode('/uiConfig/applicationInfo')
                if(!$info -or $info.GetAttribute('name') -ne 'CorelDRAW' -or [int]($info.GetAttribute('version').Split('.')[0]) -ne $Major){throw ('Workspace version mismatch: '+$file.Name)}
                $bar=$x.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$script:Standard']/toolbar")
                if($bar.Count -ne 1 -or !$x.SelectSingleNode('/uiConfig/items')){continue}
                if($x.SelectSingleNode("//*[@guid='$script:Button' or @guidRef='$script:Button']")){throw ('Existing USTA toolbar customization preserved: '+$file.Name)}
                $before=Join-Path $run ('before-'+$file.Name);$stage=Join-Path $run ('install-'+$file.Name)
                [IO.File]::Copy($file.FullName,$before,$false)
                $last=$bar[0].SelectSingleNode('item[last()]');$addedSeparator=[bool]($last -and $last.GetAttribute('guidRef') -ne '266435b4-6e53-460f-9fa7-f45be187d400')
                $null=& (Join-Path $Source 'Add-UstaToolbarButton.ps1') -WorkspacePath $file.FullName -ExpectedMajor $Major -IconPath $ico -OutputPath $stage
                $changes+= [pscustomobject]@{Path=$file.FullName;Backup=$before;Stage=$stage;BeforeHash=(Get-FileHash -LiteralPath $before).Hash;AddedSeparator=$addedSeparator}
            }
            if(!$changes.Count){throw 'No compatible saved Standard toolbar. Start selected CorelDRAW once, close it, retry.'}
            $record=[pscustomobject]@{Version='0.75';Major=$Major;Profile=$Profile;GmsPath=$gms;GmsHash=$payloadHash;HadGms=$hadGms;OldGms=$oldGms;Workspaces=$changes}
        }else{
            if(!(Test-Path -LiteralPath $manifest)){throw 'No installation record; refusing untracked cleanup'}
            $record=Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
            if($record.Profile -ine $Profile -or $record.Major -ne $Major){throw 'Installation record belongs to another target'}
            if($hadGms -and (Get-FileHash -LiteralPath $gms).Hash -ne $record.GmsHash){throw 'GMS modified since installation; preserved. Resolve before uninstall.'}
            if($record.HadGms -and !(Test-Path -LiteralPath $record.OldGms)){throw 'Missing previous GMS backup; preserving installation'}
            if($hadGms){$oldGms=Join-Path $run 'rollback.gms';[IO.File]::Copy($gms,$oldGms,$false)}
            foreach($file in Get-ChildItem -LiteralPath $folder -Filter *.cdws -File){
                $x=Read-UstaXml $file.FullName
                if(!$x.SelectSingleNode("//*[@guid='$script:Button' or @guidRef='$script:Button']")){continue}
                $definition=$x.SelectSingleNode("/uiConfig/items/itemData[@guid='$script:Button']")
                if(!$definition -or $definition.GetAttribute('dynamicCommand') -ne 'UstaSmartNodeCleaner.Module1.UstaSmartNodeCleanerV075'){throw 'Button reassigned by user; preserved'}
                $tracked=@($record.Workspaces | Where-Object {$_.Path -ieq $file.FullName})
                $removeSeparator=($tracked.Count -eq 1 -and [bool]$tracked[0].AddedSeparator)
                $before=Join-Path $run ('before-'+$file.Name);$stage=Join-Path $run ('remove-'+$file.Name)
                [IO.File]::Copy($file.FullName,$before,$false);Remove-UstaButton $file.FullName $stage $removeSeparator
                $changes+=[pscustomobject]@{Path=$file.FullName;Backup=$before;Stage=$stage;BeforeHash=(Get-FileHash -LiteralPath $before).Hash}
            }
        }
        if($CheckOnly){return [pscustomobject]@{Status='PASS';Mode='Check';Major=$Major;Profile=$Profile;ChangedWorkspaces=0;PreparedWorkspaces=$changes.Count;Evidence=$run}}
        if(Get-Process CorelDRW -ErrorAction SilentlyContinue){throw 'CorelDRAW started; no changes committed'}
        foreach($c in $changes){if((Get-FileHash -LiteralPath $c.Path).Hash -ne $c.BeforeHash){throw 'Workspace changed during preparation'}}
        if($hadGms -and (Get-FileHash -LiteralPath $gms).Hash -ne (Get-FileHash -LiteralPath $oldGms).Hash){throw 'GMS changed during preparation'}
        if(!$hadGms -and (Test-Path -LiteralPath $gms)){throw 'GMS appeared during preparation'}
        foreach($c in $changes){if(Get-Process CorelDRW -ErrorAction SilentlyContinue){throw 'CorelDRAW started; rolling back'};$applied+=$c;[IO.File]::Copy($c.Stage,$c.Path,$true)}
        if(Get-Process CorelDRW -ErrorAction SilentlyContinue){throw 'CorelDRAW started; rolling back'}
        $gmsChanged=$true
        if($Mode -eq 'Install'){
            $createdDirectory=!(Test-Path -LiteralPath (Split-Path -Parent $gms));[void][IO.Directory]::CreateDirectory((Split-Path -Parent $gms))
            [IO.File]::Copy($payload,$gms,$true)
            $record | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifest -Encoding UTF8
        }else{
            if($record.HadGms){[IO.File]::Copy($record.OldGms,$gms,$true)}elseif(Test-Path -LiteralPath $gms){[IO.File]::Delete($gms)}
            Move-Item -LiteralPath $manifest -Destination (Join-Path $run 'uninstalled.json')
        }
        [pscustomobject]@{Status='PASS';Mode=$Mode;Major=$Major;Profile=$Profile;ChangedWorkspaces=$changes.Count;GmsPath=$gms;Evidence=$run}
    }catch{
        foreach($c in $applied){[IO.File]::Copy($c.Backup,$c.Path,$true)}
        if($gmsChanged){if($hadGms){[IO.File]::Copy($oldGms,$gms,$true)}elseif(Test-Path -LiteralPath $gms){[IO.File]::Delete($gms)}}
        throw
    }
}

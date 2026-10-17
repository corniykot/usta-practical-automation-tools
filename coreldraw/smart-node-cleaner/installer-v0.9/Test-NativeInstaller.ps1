param([string]$TestRoot=(Join-Path $PSScriptRoot '..\evidence\archive-tests'))
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
[void][IO.Directory]::CreateDirectory($TestRoot)
$helper=Join-Path $PSScriptRoot 'Add-UstaToolbarButton.MultiVersion.ps1'
$icon=Join-Path $PSScriptRoot 'Usta_Smart_Node_Cleaner.ico'
$standard='c2b44f69-6dec-444e-a37e-5dbf7ff43dae'
$button='9ec68916-62d5-4a5c-9558-cb60977da5e3'
$separator='266435b4-6e53-460f-9fa7-f45be187d400'
$results=[Collections.Generic.List[object]]::new()
function Assert($Condition,[string]$Name){if(!$Condition){throw $Name};$results.Add([pscustomobject]@{Test=$Name;Result='PASS'})}
function Read-Xml([string]$Path){$z=[IO.Compression.ZipFile]::OpenRead($Path);try{$r=[IO.StreamReader]::new($z.GetEntry('content/workspace.xml').Open());try{return [xml]$r.ReadToEnd()}finally{$r.Dispose()}}finally{$z.Dispose()}}
foreach($major in @(20,22,99)){
    foreach($count in @(0,1,9,47)){
        $source=Join-Path $TestRoot ('fixture-'+$major+'-'+$count+'.cdws')
        $destination=Join-Path $TestRoot ('result-'+$major+'-'+$count+'.cdws')
        $commands=@(1..([Math]::Max(1,$count)) | ForEach-Object {[guid]::NewGuid().ToString()})
        if(!$count){$commands=@()}
        $text='<uiConfig><applicationInfo name="CorelDRAW" version="'+$major+'"/><items/><commandBars><commandBarData guid="'+$standard+'"><toolbar><item guidRef="'+$button+'"/>'
        foreach($command in $commands){$text+='<item guidRef="'+$command+'" custom="preserve-me"/>'}
        $text+='</toolbar></commandBarData></commandBars><states><toolbar guidRef="'+$standard+'" userVisibility="false"/></states></uiConfig>'
        if(Test-Path -LiteralPath $source){[IO.File]::Delete($source)}
        if(Test-Path -LiteralPath $destination){[IO.File]::Delete($destination)}
        $z=[IO.Compression.ZipFile]::Open($source,[IO.Compression.ZipArchiveMode]::Create)
        try{$w=[IO.StreamWriter]::new($z.CreateEntry('content/workspace.xml').Open());try{$w.Write($text)}finally{$w.Dispose()}}finally{$z.Dispose()}
        $hash=(Get-FileHash -LiteralPath $source).Hash
        $null=& $helper -WorkspacePath $source -IconPath $icon -ExpectedMajor $major -OutputPath $destination
        $doc=Read-Xml $destination
        $items=@($doc.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$standard']/toolbar/item"))
        $expected=@($commands);if($count){$expected+= $separator};$expected+=$button
        Assert ((@($items | ForEach-Object {$_.GetAttribute('guidRef')}) -join ',') -ceq ($expected -join ',')) ('Dynamic tail/order: major '+$major+', native commands '+$count)
        Assert ($doc.SelectSingleNode('/uiConfig/states/toolbar').GetAttribute('userVisibility') -eq 'false') ('Visibility retained: '+$major+'/'+$count)
        $sequence=$doc.SelectSingleNode('/uiConfig/commandBars/commandBarData/toolbar').OuterXml
        $null=& $helper -WorkspacePath $destination -IconPath $icon -ExpectedMajor $major
        $repeat=Read-Xml $destination
        Assert ($repeat.SelectSingleNode('/uiConfig/commandBars/commandBarData/toolbar').OuterXml -ceq $sequence) ('No duplicates on repeat: '+$major+'/'+$count)
        Assert ((Get-FileHash -LiteralPath $source).Hash -eq $hash) ('Input untouched: '+$major+'/'+$count)
    }
}
$realRoot=Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Corel'
if(Test-Path -LiteralPath $realRoot){
foreach($profile in Get-ChildItem -LiteralPath $realRoot -Directory){
    $folder=Join-Path $profile.FullName 'Draw\Workspace'
    if(!(Test-Path -LiteralPath $folder)){continue}
    foreach($file in Get-ChildItem -LiteralPath $folder -Filter *.cdws){
        $before=(Get-FileHash -LiteralPath $file.FullName).Hash
        $doc=Read-Xml $file.FullName
        $major=[int]$doc.uiConfig.applicationInfo.version
        $bars=$doc.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$standard']/toolbar")
        if($bars.Count -ne 1 -or $doc.SelectNodes('/uiConfig/items').Count -ne 1){
            Assert ((Get-FileHash -LiteralPath $file.FullName).Hash -eq $before) ('Unsupported/ambiguous layout left untouched: '+$major+'/'+$file.Name)
            continue
        }
        $bar=$bars[0]
        $original=@($bar.SelectNodes("item[not(@guidRef='$button')]") | ForEach-Object OuterXml)
        $output=Join-Path $TestRoot ('real-'+$profile.Name+'-'+$file.Name)
        $null=& $helper -WorkspacePath $file.FullName -IconPath $icon -ExpectedMajor $major -OutputPath $output
        $verified=Read-Xml $output
        $native=@($verified.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$standard']/toolbar/item[not(@guidRef='$button')]"))
        for($i=0;$i -lt $original.Count;$i++){Assert ($native[$i].OuterXml -ceq $original[$i]) ('Real command retained '+$major+'/'+$file.Name+'/'+$i)}
        $z=[IO.Compression.ZipFile]::OpenRead($output)
        try{
            $stream=$z.GetEntry('content/icons/d49df810-0118-48b7-a0a4-9bd3e721c913.ico').Open();$memory=[IO.MemoryStream]::new()
            try{$stream.CopyTo($memory);Assert ([Convert]::ToBase64String($memory.ToArray()) -ceq [Convert]::ToBase64String([IO.File]::ReadAllBytes($icon))) ('Real icon exact bytes: '+$major+'/'+$file.Name)}finally{$stream.Dispose();$memory.Dispose()}
        }finally{$z.Dispose()}
        Assert ((Get-FileHash -LiteralPath $file.FullName).Hash -eq $before) ('Real workspace untouched: '+$major+'/'+$file.Name)
    }
}
}
$results | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $TestRoot 'results.json') -Encoding UTF8
Write-Output ('PASS: '+$results.Count+' archive assertions. These do not prove application behavior on untested versions.')

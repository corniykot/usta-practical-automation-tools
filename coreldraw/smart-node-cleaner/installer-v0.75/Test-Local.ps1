# USTA Smart Node Cleaner v0.75
param([Parameter(Mandatory=$true)][string]$TestRoot)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Usta.Files.ps1')
[void][IO.Directory]::CreateDirectory($TestRoot)
$results=[Collections.Generic.List[object]]::new()
function Assert($condition,$name){if(!$condition){throw $name};$results.Add([pscustomobject]@{Test=$name;Status='PASS'})}
foreach($major in 17..24){foreach($count in @(0,1,47)){
    $root=Join-Path $TestRoot ($major.ToString()+'-'+$count);$profile=Join-Path $root 'Profile';$folder=Join-Path $profile 'Draw\Workspace';[void][IO.Directory]::CreateDirectory($folder)
    $file=Join-Path $folder '_default.cdws';$native=@();for($i=0;$i -lt $count;$i++){$native+=[guid]::NewGuid().ToString()}
    $text='<uiConfig><applicationInfo name="CorelDRAW" version="'+$major+'"/><items/><commandBars><commandBarData guid="'+$script:Standard+'"><toolbar>'
    foreach($id in $native){$text+='<item guidRef="'+$id+'" custom="retain"/>'};$text+='</toolbar></commandBarData></commandBars></uiConfig>'
    $z=[IO.Compression.ZipFile]::Open($file,[IO.Compression.ZipArchiveMode]::Create);try{$w=[IO.StreamWriter]::new($z.CreateEntry('content/workspace.xml').Open());try{$w.Write($text)}finally{$w.Dispose()};$w=[IO.StreamWriter]::new($z.CreateEntry('untouched.txt').Open());try{$w.Write('keep exact')}finally{$w.Dispose()}}finally{$z.Dispose()}
    $state=Join-Path $root 'State'
    $null=Invoke-UstaFiles Install $profile $major $PSScriptRoot $state
    $x=Read-UstaXml $file;$bar=$x.SelectSingleNode("/uiConfig/commandBars/commandBarData[@guid='$script:Standard']/toolbar")
    Assert ($bar.LastChild.GetAttribute('guidRef') -eq $script:Button) ('Last button '+$major+'/'+$count)
    Assert ((@($bar.SelectNodes("item[not(@guidRef='$script:Button') and not(@guidRef='266435b4-6e53-460f-9fa7-f45be187d400')]") | ForEach-Object {$_.GetAttribute('guidRef')}) -join ',') -ceq ($native -join ',')) ('Native order '+$major+'/'+$count)
    $z=[IO.Compression.ZipFile]::OpenRead($file);try{$s=$z.GetEntry("content/icons/$script:Icon.ico").Open();$sha=[Security.Cryptography.SHA256]::Create();try{$hash=[BitConverter]::ToString($sha.ComputeHash($s)).Replace('-','')}finally{$s.Dispose();$sha.Dispose()}}finally{$z.Dispose()}
    Assert ($hash -eq '57DE42FEFA72FCB9F6B9A89E6EDEF7B522320D860504AF9BFBEF3DB743CF4284') ('Original icon '+$major+'/'+$count)
    # Simulate a later unrelated customization. Uninstall must retain it.
    $custom=[guid]::NewGuid().ToString();$n=$x.CreateElement('item');$n.SetAttribute('guidRef',$custom);[void]$bar.AppendChild($n)
    $z=[IO.Compression.ZipFile]::Open($file,[IO.Compression.ZipArchiveMode]::Update);try{$z.GetEntry('content/workspace.xml').Delete();$w=[IO.StreamWriter]::new($z.CreateEntry('content/workspace.xml').Open());try{$w.Write($x.OuterXml)}finally{$w.Dispose()}}finally{$z.Dispose()}
    $null=Invoke-UstaFiles Uninstall $profile $major $PSScriptRoot $state
    $x=Read-UstaXml $file;$actual=@($x.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$script:Standard']/toolbar/item") | ForEach-Object {$_.GetAttribute('guidRef')})
    Assert (($actual -join ',') -ceq (@($native)+@($custom) -join ',')) ('Uninstall retains later customization '+$major+'/'+$count)
    Assert (!(Test-Path -LiteralPath (Join-Path $profile 'Draw\GMS\UstaSmartNodeCleaner.gms'))) ('Uninstall removes own GMS '+$major+'/'+$count)
}}
# Existing GMS: never replace implicitly; explicit replacement restores on uninstall.
$profile=Join-Path $TestRoot '20-1\Profile';$state=Join-Path $TestRoot '20-1\State';$g=Join-Path $profile 'Draw\GMS\UstaSmartNodeCleaner.gms';[IO.File]::WriteAllText($g,'existing user file');$before=(Get-FileHash $g).Hash
$blocked=$false;try{$null=Invoke-UstaFiles Install $profile 20 $PSScriptRoot $state}catch{$blocked=$_.Exception.Message -like 'Different existing GMS*'}
Assert $blocked 'Different GMS blocked';Assert ((Get-FileHash $g).Hash -eq $before) 'Different GMS untouched'
$null=Invoke-UstaFiles Install $profile 20 $PSScriptRoot $state -ReplaceExistingGms
$null=Invoke-UstaFiles Uninstall $profile 20 $PSScriptRoot $state
Assert ((Get-FileHash $g).Hash -eq $before) 'Explicit replacement restored previous GMS'
$results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $TestRoot 'results.json') -Encoding UTF8
'PASS: '+$results.Count+' file/workspace assertions. Application compatibility is not proved by fixtures.'

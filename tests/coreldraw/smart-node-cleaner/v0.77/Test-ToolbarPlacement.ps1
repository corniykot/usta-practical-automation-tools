# USTA v0.77: saved-workspace regression tests, not an installer/application test.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$BaselineWorkspace,
    [Parameter(Mandatory=$true)][string]$TestRoot
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$button='9ec68916-62d5-4a5c-9558-cb60977da5e3'
$standard='c2b44f69-6dec-444e-a37e-5dbf7ff43dae'
$custom='58e189e7-64d4-4840-bb76-d256657f8fe8'
$other='8c1241eb-61f5-4098-8b3e-1eeed51a3018'
$results=[Collections.Generic.List[object]]::new()
[void][IO.Directory]::CreateDirectory([IO.Path]::GetFullPath($TestRoot))
function Read-Entries([string]$Path) {
    $z=[IO.Compression.ZipFile]::OpenRead($Path);$entries=@{}
    try { foreach($e in $z.Entries) {
        $s=$e.Open();$m=[IO.MemoryStream]::new()
        try {$s.CopyTo($m);$entries[$e.FullName]=$m.ToArray()} finally {$s.Dispose();$m.Dispose()}
    }} finally {$z.Dispose()}
    return $entries
}
function Read-Xml($Entries) {
    $r=[IO.StreamReader]::new([IO.MemoryStream]::new([byte[]]$Entries['content/workspace.xml']))
    try {$x=[xml]::new();$x.PreserveWhitespace=$true;$x.LoadXml($r.ReadToEnd());return $x} finally {$r.Dispose()}
}
function Assert($Condition,[string]$Message) { if(!$Condition){throw $Message} }
foreach($locked in @('0','1')) { foreach($placement in @('absent','first','other','both')) {
    $id=$locked+'-'+$placement
    $input=Join-Path $TestRoot ($id+'-input.cdws')
    $output=Join-Path $TestRoot ($id+'-output.cdws')
    $again=Join-Path $TestRoot ($id+'-again.cdws')
    [IO.File]::Copy((Resolve-Path -LiteralPath $BaselineWorkspace).Path,[IO.Path]::GetFullPath($input),$true)
    $x=Read-Xml (Read-Entries $input)
    $bar=$x.SelectSingleNode("/uiConfig/commandBars/commandBarData[@guid='$standard']/toolbar")
    # A personalized command at the tail must stay ahead of USTA, with its attributes.
    $n=$x.CreateElement('item');$n.SetAttribute('guidRef',$custom);$n.SetAttribute('userWidth','91');[void]$bar.AppendChild($n)
    $d=$x.CreateElement('itemData');$d.SetAttribute('guid',$custom);$d.SetAttribute('userCaption','User command');[void]$x.uiConfig.items.AppendChild($d)
    $d=$x.CreateElement('commandBarData');$d.SetAttribute('guid',$other)
    $t=$x.CreateElement('toolbar');$t.SetAttribute('dock','floating');[void]$d.AppendChild($t);[void]$x.uiConfig.commandBars.AppendChild($d)
    $n=$x.CreateElement('item');$n.SetAttribute('guidRef',$custom);[void]$t.AppendChild($n)
    if($placement -in @('first','both')) {
        $n=$x.CreateElement('item');$n.SetAttribute('guidRef',$button);[void]$bar.PrependChild($n)
    }
    if($placement -in @('other','both')) {
        $n=$x.CreateElement('item');$n.SetAttribute('guidRef',$button);[void]$t.AppendChild($n)
    }
    if($placement -ne 'absent') {
        $d=$x.CreateElement('itemData');$d.SetAttribute('guid',$button);[void]$x.uiConfig.items.AppendChild($d)
    }
    $z=[IO.Compression.ZipFile]::Open($input,[IO.Compression.ZipArchiveMode]::Update)
    try {
        $z.GetEntry('content/workspace.xml').Delete()
        $w=[IO.StreamWriter]::new($z.CreateEntry('content/workspace.xml').Open(),[Text.UTF8Encoding]::new($false))
        try {$w.Write($x.OuterXml)} finally {$w.Dispose()}
        $e=$z.GetEntry('content/settings.ini');if($e){$e.Delete()}
        $w=[IO.StreamWriter]::new($z.CreateEntry('content/settings.ini').Open(),[Text.Encoding]::Unicode)
        try {$w.Write("[Framework]`r`nLockToolbars=$locked`r`nUnrelatedPreference=keep`r`n")} finally {$w.Dispose()}
    } finally {$z.Dispose()}
    $before=Read-Entries $input
    $original=Read-Xml $before
    $null=& (Join-Path $PSScriptRoot 'Add-UstaToolbarButton.ps1') -WorkspacePath $input -ExpectedMajor 20 -IconPath (Join-Path $PSScriptRoot 'Usta_Smart_Node_Cleaner.ico') -OutputPath $output
    $after=Read-Entries $output;$v=Read-Xml $after
    $tail=$v.SelectSingleNode("/uiConfig/commandBars/commandBarData[@guid='$standard']/toolbar/item[last()]")
    Assert ($tail.GetAttribute('guidRef') -eq $button) "$id final position"
    Assert ($v.SelectNodes("/uiConfig/commandBars/commandBarData//item[@guidRef='$button']").Count -eq 1) "$id duplicate"
    Assert ($v.uiConfig.states.OuterXml -ceq $original.uiConfig.states.OuterXml) "$id layout/state"
    foreach($name in $before.Keys) {
        if($name -eq 'content/workspace.xml'){continue}
        Assert ([Convert]::ToBase64String($before[$name]) -ceq [Convert]::ToBase64String($after[$name])) "$id archive entry changed: $name"
    }
    Assert ($v.uiConfig.commandBars.ChildNodes.Count -eq $original.uiConfig.commandBars.ChildNodes.Count) "$id bar count"
    $old=@($original.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$standard']/toolbar/item[not(@guidRef='$button')]") | ForEach-Object OuterXml)
    $new=@($v.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$standard']/toolbar/item"))
    for($i=0;$i -lt $old.Count;$i++){Assert ($old[$i] -ceq $new[$i].OuterXml) "$id original item $i"}
    $null=& (Join-Path $PSScriptRoot 'Add-UstaToolbarButton.ps1') -WorkspacePath $output -ExpectedMajor 20 -IconPath (Join-Path $PSScriptRoot 'Usta_Smart_Node_Cleaner.ico') -OutputPath $again
    $repeat=Read-Entries $again
    Assert ((Read-Xml $repeat).OuterXml -ceq $v.OuterXml) "$id repeat XML changed"
    $results.Add([pscustomobject]@{Case=$id;Status='PASS';LockToolbars=$locked;OriginalUstaPlacement=$placement;PreservedStandardItems=$old.Count;Runs=2;Scope='saved-workspace regression'})
}}
$results | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $TestRoot 'results.json') -Encoding UTF8
$results

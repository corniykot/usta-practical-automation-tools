# CorelDRAW 2018 x64: add an existing VBA macro button to a saved workspace.
# Run with CorelDRAW CLOSED. This is integration code, not an installer.
[CmdletBinding()]
param(
    [string]$WorkspacePath = (Join-Path $env:APPDATA 'Corel\CorelDRAW Graphics Suite 2018\Draw\Workspace\_default.cdws'),
    [string]$IconPath = (Join-Path $env:USERPROFILE 'Downloads\Usta_Smart_Node_Cleaner.ico'),
    [string]$MacroCommand = 'UstaSmartNodeCleaner.Module1.UstaSmartNodeCleanerV073',
    [string]$OutputPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (Get-Process -Name CorelDRW -ErrorAction SilentlyContinue) {
    throw 'Close CorelDRAW before running this script; it saves the workspace on exit.'
}
if ($MacroCommand -notmatch '^UstaSmartNodeCleaner\.[A-Za-z_]\w*\.[A-Za-z_]\w*$') {
    throw 'MacroCommand must be the existing project.module.procedure name.'
}
$WorkspacePath = (Resolve-Path -LiteralPath $WorkspacePath).Path
$IconPath = (Resolve-Path -LiteralPath $IconPath).Path
$iconBytes = [IO.File]::ReadAllBytes($IconPath)
if ($iconBytes.Length -lt 22 -or $iconBytes[0] -ne 0 -or $iconBytes[1] -ne 0 -or
    $iconBytes[2] -ne 1 -or $iconBytes[3] -ne 0) { throw 'IconPath is not a Windows ICO file.' }
$frameCount = [BitConverter]::ToUInt16($iconBytes, 4)
if ($frameCount -eq 0 -or $iconBytes.Length -lt (6 + 16 * $frameCount)) { throw 'Invalid ICO directory.' }
for ($i = 0; $i -lt $frameCount; $i++) {
    $length = [BitConverter]::ToUInt32($iconBytes, 6 + 16 * $i + 8)
    $offset = [BitConverter]::ToUInt32($iconBytes, 6 + 16 * $i + 12)
    if ([long]$offset + [long]$length -gt $iconBytes.Length) { throw 'Truncated ICO image.' }
}
if ($OutputPath) { $destination = [IO.Path]::GetFullPath($OutputPath) }
else { $destination = $WorkspacePath }
if (!(Test-Path -LiteralPath ([IO.Path]::GetDirectoryName($destination)) -PathType Container)) {
    throw 'The output directory must already exist.'
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$buttonGuid = '9ec68916-62d5-4a5c-9558-cb60977da5e3'
$iconGuid = 'd49df810-0118-48b7-a0a4-9bd3e721c913'
# CorelDRAW's built-in toolbar identity, NOT a machine-specific button position.
$standardGuid = 'c2b44f69-6dec-444e-a37e-5dbf7ff43dae'
$separatorGuid = '266435b4-6e53-460f-9fa7-f45be187d400'
$iconEntryName = "content/icons/$iconGuid.ico"
$temporary = Join-Path ([IO.Path]::GetDirectoryName($destination)) ('.usta-' + [guid]::NewGuid().ToString('N') + '.cdws')
$zip = $null
try {
    [IO.File]::Copy($WorkspacePath, $temporary, $false)
    $zip = [IO.Compression.ZipFile]::Open($temporary, [IO.Compression.ZipArchiveMode]::Update)
    $entry = $zip.GetEntry('content/workspace.xml')
    if (!$entry) { throw 'This is not a CorelDRAW workspace archive.' }
    $reader = [IO.StreamReader]::new($entry.Open())
    try { $xmlText = $reader.ReadToEnd() } finally { $reader.Dispose() }
    $xml = [xml]::new()
    $xml.PreserveWhitespace = $true
    $xml.XmlResolver = $null
    $xml.LoadXml($xmlText)
    $info = $xml.SelectSingleNode('/uiConfig/applicationInfo')
    if (!$info -or $info.GetAttribute('name') -ne 'CorelDRAW' -or $info.GetAttribute('version') -ne '20') {
        throw 'Expected a CorelDRAW 2018 (version 20) workspace.'
    }
    $items = $xml.SelectSingleNode('/uiConfig/items')
    $standardToolbars = $xml.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$standardGuid']/toolbar")
    if (!$items -or $standardToolbars.Count -ne 1) {
        throw 'Expected exactly one Standard toolbar in the target workspace; nothing has been changed.'
    }
    $toolbar = $standardToolbars[0]
    $existingToolbarItems = @($toolbar.SelectNodes("item[not(@guidRef='$buttonGuid')]") | ForEach-Object OuterXml)
    # Only our own fixed GUID is replaced. Other commands/customizations remain.
    foreach ($node in @($xml.SelectNodes("/uiConfig/items/itemData[@guid='$buttonGuid']"))) {
        [void]$node.ParentNode.RemoveChild($node)
    }
    # Move only this integration's button on the target Standard toolbar.
    # References on other toolbars are preserved.
    foreach ($node in @($toolbar.SelectNodes("item[@guidRef='$buttonGuid']"))) {
        [void]$node.ParentNode.RemoveChild($node)
    }
    $definition = $xml.CreateElement('itemData')
    $attributes = @{
        guid = $buttonGuid
        dynamicCommand = $MacroCommand
        dynamicCategory = '2cc24a3e-fe24-4708-9a74-9c75406eebcd'
        icon = "guid://$iconGuid"
        userCaption = 'USTA Smart Node Cleaner'
        userToolTip = 'USTA Smart Node Cleaner'
    }
    foreach ($key in $attributes.Keys) { $definition.SetAttribute($key, $attributes[$key]) }
    [void]$items.AppendChild($definition)
    $button = $xml.CreateElement('item')
    $button.SetAttribute('guidRef', $buttonGuid)
    $button.SetAttribute('itemFace', 'imageOnly')
    # Determine the tail from THIS target workspace after removing old copies
    # of our button. No local button count, Launch/New/Open anchor, or numerical
    # insertion position is used. AppendChild places USTA after every item,
    # including any custom commands added on another computer.
    # Reuse a trailing native separator on reruns.
    $lastItem = $toolbar.SelectSingleNode('item[last()]')
    if ($lastItem -and $lastItem.GetAttribute('guidRef') -ne $separatorGuid) {
        $separator = $xml.CreateElement('item')
        $separator.SetAttribute('guidRef', $separatorGuid)
        [void]$toolbar.AppendChild($separator)
    }
    $insertionPosition = $toolbar.SelectNodes('item').Count + 1
    [void]$toolbar.AppendChild($button)
    foreach ($state in @($xml.SelectNodes("/uiConfig/states//toolbar[@guidRef='$standardGuid']"))) {
        $state.SetAttribute('userVisibility', 'true')
    }
    $entry.Delete()
    $entry = $zip.CreateEntry('content/workspace.xml')
    $stream = $entry.Open()
    $settings = [Xml.XmlWriterSettings]::new()
    $settings.Encoding = [Text.UTF8Encoding]::new($false)
    $settings.Indent = $false
    $writer = [Xml.XmlWriter]::Create($stream, $settings)
    try { $xml.Save($writer) } finally { $writer.Dispose(); $stream.Dispose() }
    $oldIcon = $zip.GetEntry($iconEntryName)
    if ($oldIcon) { $oldIcon.Delete() }
    $iconEntry = $zip.CreateEntry($iconEntryName)
    $stream = $iconEntry.Open()
    try { $stream.Write($iconBytes, 0, $iconBytes.Length) } finally { $stream.Dispose() }
    $zip.Dispose(); $zip = $null
    # Validate the completed archive before replacing any workspace.
    $check = [IO.Compression.ZipFile]::OpenRead($temporary)
    try {
        $reader = [IO.StreamReader]::new($check.GetEntry('content/workspace.xml').Open())
        try { $verified = [xml]$reader.ReadToEnd() } finally { $reader.Dispose() }
        if ($verified.SelectNodes("/uiConfig/items/itemData[@guid='$buttonGuid']").Count -ne 1 -or
            $verified.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$standardGuid']/toolbar/item[@guidRef='$buttonGuid']").Count -ne 1 -or
            $check.GetEntry($iconEntryName).Length -ne $iconBytes.Length) {
            throw 'Workspace validation failed.'
        }
        $verifiedToolbar = $verified.SelectSingleNode("/uiConfig/commandBars/commandBarData[@guid='$standardGuid']/toolbar")
        $verifiedItems = @($verifiedToolbar.SelectNodes('item'))
        if ($verifiedItems[-1].GetAttribute('guidRef') -ne $buttonGuid) {
            throw 'USTA button must be the final Standard-toolbar item.'
        }
        if ($verifiedItems.Count -ne $insertionPosition) {
            throw 'Target toolbar item count does not match the dynamically computed insertion position.'
        }
        for ($i = 0; $i -lt $existingToolbarItems.Count; $i++) {
            if ($verifiedItems[$i].OuterXml -cne $existingToolbarItems[$i]) {
                throw 'An existing Standard-toolbar item or its order changed.'
            }
        }
    } finally { $check.Dispose() }
    $backup = $null
    if (Test-Path -LiteralPath $destination) {
        $backup = $destination + '.usta-backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N') + '.bak'
        # A normal backup/copy also works where Windows blocks ReplaceFile.
        [IO.File]::Copy($destination, $backup, $false)
        try { [IO.File]::Copy($temporary, $destination, $true) }
        catch {
            [IO.File]::Copy($backup, $destination, $true)
            throw
        }
    } else { [IO.File]::Move($temporary, $destination) }
    [pscustomobject]@{ Workspace = $destination; Backup = $backup; Macro = $MacroCommand; Icon = $IconPath; ButtonGuid = $buttonGuid; Position = 'End of Standard toolbar'; ItemIndex = $insertionPosition; PreservedItemCount = $existingToolbarItems.Count }
} finally {
    if ($zip) { $zip.Dispose() }
    if (Test-Path -LiteralPath $temporary) { [IO.File]::Delete($temporary) }
}
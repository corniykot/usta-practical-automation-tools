# Runs without CorelDRAW. Actual application testing is separately required.
param([string]$TestRoot = $env:TEMP)
$ErrorActionPreference = 'Stop'
$helper = Join-Path $PSScriptRoot 'Add-UstaToolbarButton.ps1'
$adapter = Join-Path $PSScriptRoot 'Invoke-UstaToolbarIntegration.ps1'
$icon = Join-Path $PSScriptRoot '..\Usta_Smart_Node_Cleaner.ico'
$protected = @($helper, $icon, (Join-Path $PSScriptRoot '..\UstaSmartNodeCleaner.gms'))
$before = @($protected | ForEach-Object { (Get-FileHash -LiteralPath $_).Hash })
$testDir = Join-Path $TestRoot ('USTA test ' + [char]0x416 + ' ' + [guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($testDir)
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$source = Join-Path $testDir 'custom workspace.cdws'
$destination = Join-Path $testDir 'result.cdws'
$button = '9ec68916-62d5-4a5c-9558-cb60977da5e3'
$standard = 'c2b44f69-6dec-444e-a37e-5dbf7ff43dae'
$separator = '266435b4-6e53-460f-9fa7-f45be187d400'
$commands = @([guid]::NewGuid().ToString(), [guid]::NewGuid().ToString(), [guid]::NewGuid().ToString())
$xml = '<uiConfig><applicationInfo name="CorelDRAW" version="20"/><items/><commandBars><commandBarData guid="' + $standard + '"><toolbar>'
$xml += '<item guidRef="' + $button + '"/>'
foreach ($command in $commands) { $xml += '<item guidRef="' + $command + '" itemFace="imageOnly"/>' }
$xml += '</toolbar></commandBarData></commandBars><states/></uiConfig>'
$zip = [IO.Compression.ZipFile]::Open($source, [IO.Compression.ZipArchiveMode]::Create)
try {
    $writer = [IO.StreamWriter]::new($zip.CreateEntry('content/workspace.xml').Open())
    try { $writer.Write($xml) } finally { $writer.Dispose() }
} finally { $zip.Dispose() }
function Assert($condition, $message) { if (!$condition) { throw $message }; Write-Output ('PASS: ' + $message) }
function ReadWorkspace($path) {
    $zip = [IO.Compression.ZipFile]::OpenRead($path)
    try {
        $reader = [IO.StreamReader]::new($zip.GetEntry('content/workspace.xml').Open())
        try { return [xml]$reader.ReadToEnd() } finally { $reader.Dispose() }
    } finally { $zip.Dispose() }
}
$ps = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
# Each invocation is a fresh 5.1 process, not the assembly-warmed test host.
$baseline = & $ps -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $helper -WorkspacePath $source -IconPath $icon -OutputPath $destination 2>&1 | Out-String
Assert ($LASTEXITCODE -eq 1 -and $baseline -match 'ZipArchiveMode') 'Original fresh-process exit 1 reproduced (ZipArchiveMode)'
Assert (!(Test-Path -LiteralPath $destination)) 'Failed original invocation did not create output'
$sourceHash = (Get-FileHash $source).Hash
& $ps -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $adapter -CheckOnly -WorkspacePath $source -LogPath (Join-Path $testDir 'preflight.log')
Assert ($LASTEXITCODE -eq 0) 'Read-only preflight succeeds'
& $ps -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $adapter -ScriptPath $helper -IconPath $icon -WorkspacePath $source -OutputPath $destination -LogPath (Join-Path $testDir 'success.log')
Assert ($LASTEXITCODE -eq 0) 'Adapter succeeds in fresh Windows PowerShell 5.1'
$v = ReadWorkspace $destination
$items = @($v.SelectNodes("/uiConfig/commandBars/commandBarData[@guid='$standard']/toolbar/item"))
Assert ((($items | ForEach-Object { $_.GetAttribute('guidRef') }) -join ',') -ceq (($commands + $separator + $button) -join ',')) 'Original commands retained in order, separator and USTA last'
Assert ($v.SelectSingleNode("/uiConfig/items/itemData[@guid='$button']").GetAttribute('dynamicCommand') -ceq 'UstaSmartNodeCleaner.Module1.UstaSmartNodeCleanerV073') 'Macro binding unchanged'
$zip = [IO.Compression.ZipFile]::OpenRead($destination)
try {
    $stream = $zip.GetEntry('content/icons/d49df810-0118-48b7-a0a4-9bd3e721c913.ico').Open()
    $memory = [IO.MemoryStream]::new()
    try { $stream.CopyTo($memory); Assert ([Convert]::ToBase64String($memory.ToArray()) -ceq [Convert]::ToBase64String([IO.File]::ReadAllBytes($icon))) 'Embedded icon bytes unchanged' } finally { $stream.Dispose(); $memory.Dispose() }
} finally { $zip.Dispose() }
$sequence = $v.SelectSingleNode('/uiConfig/commandBars/commandBarData/toolbar').OuterXml
& $ps -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $adapter -ScriptPath $helper -IconPath $icon -WorkspacePath $destination -LogPath (Join-Path $testDir 'repeat.log')
Assert ($LASTEXITCODE -eq 0) 'Repeat integration succeeds'
$v = ReadWorkspace $destination
Assert ($v.SelectSingleNode('/uiConfig/commandBars/commandBarData/toolbar').OuterXml -ceq $sequence) 'Repeat integration adds no duplicate separator/button'
Assert ((Get-FileHash $source).Hash -ceq $sourceHash) 'Source workspace unchanged during copy tests'
& $ps -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $adapter -CheckOnly -WorkspacePath (Join-Path $testDir 'missing.cdws') -LogPath (Join-Path $testDir 'failure.log')
Assert ($LASTEXITCODE -eq 1) 'Missing workspace returns failure'
Assert ((Get-Content (Join-Path $testDir 'failure.log') -Raw) -match 'Cannot find path|PathNotFound') 'Failure log includes actual exception'
Assert ((Get-Content (Join-Path $testDir 'success.log') -Raw) -match 'PASS: toolbar integration completed') 'Success log retained'
$after = @($protected | ForEach-Object { (Get-FileHash -LiteralPath $_).Hash })
Assert (($before -join ',') -ceq ($after -join ',')) 'All three protected payloads byte-identical'
Write-Output ('Diagnostic fixtures/logs: ' + $testDir)

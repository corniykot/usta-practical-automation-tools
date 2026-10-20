param([Parameter(Mandatory=$true)][string]$OutputPath)
# Test Windows OLE Automation formatting/conversion with explicit LCIDs.
# No Windows/user regional settings are changed. This is not a CorelDRAW test.
$ErrorActionPreference='Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class UstaOleDecimal077 {
 [DllImport("oleaut32.dll", CharSet=CharSet.Unicode, PreserveSig=true)]
 public static extern int VarR8FromStr(string text, uint lcid, uint flags, out double value);
 [DllImport("oleaut32.dll", PreserveSig=true)]
 public static extern int VarBstrFromR8(double value, uint lcid, uint flags, [MarshalAs(UnmanagedType.BStr)] out string text);
}
'@
$cases=@(
 @('0.05','OK',0.05),@('0,05','OK',0.05),@(' 0.05 ','OK',0.05),@(' 0,05 ','OK',0.05),
 @('.05','OK',0.05),@(',05','OK',0.05),@('+0.05','OK',0.05),@('0,050','OK',0.05),
 @('5e-2','OK',0.05),@('1.25','OK',1.25),@('1,25','OK',1.25),@('2','OK',2.0),@('2,0','OK',2.0),
 @('0','RANGE',0.0),@('-0,05','RANGE',0.0),@('2.0001','RANGE',0.0),
 @('','INVALID',0.0),@('   ','INVALID',0.0),@('abc','INVALID',0.0),@('0.05mm','INVALID',0.0),
 @('0.0.5','INVALID',0.0),@('0,0,5','INVALID',0.0),@('0.0,5','INVALID',0.0),@('0,0.5','INVALID',0.0),
 @('.','INVALID',0.0),@(',','INVALID',0.0),@('NaN','INVALID',0.0),@('1e999','INVALID',0.0)
)
$results=@()
foreach($locale in @(@('en-US',1033,'.'),@('ru-RU',1049,','))){
    $formatted='';$hr=[UstaOleDecimal077]::VarBstrFromR8(1.5,$locale[1],0,[ref]$formatted)
    if($hr -ne 0 -or $formatted.Substring(1,1) -cne $locale[2]){throw 'Requested locale formatting did not take effect'}
    foreach($case in $cases){
        $t=$case[0].Trim().Replace(',','.').Replace('.',$locale[2])
        $value=0.0;$hr=[UstaOleDecimal077]::VarR8FromStr($t,$locale[1],0,[ref]$value)
        if(!$t -or $hr -ne 0){$status='INVALID'}elseif($value -le 0 -or $value -gt 2){$status='RANGE'}else{$status='OK'}
        $pass=$status -ceq $case[1]
        if($status -eq 'OK'){$pass=$pass -and [Math]::Abs($value-$case[2]) -lt 1e-12}
        $results+=[pscustomobject]@{Locale=$locale[0];DecimalSeparator=$locale[2];Input=$case[0];Normalized=$t;Expected=$case[1];Actual=$status;Value=$value;Passed=$pass;HRESULT=$hr}
    }
}
$results | ConvertTo-Json -Depth 5 | Set-Content  $OutputPath -Encoding UTF8
$failed=@($results | Where-Object {!$_.Passed})
if($failed.Count){$failed | ConvertTo-Json;throw ('Failed tests: '+$failed.Count)}
'PASS: '+$results.Count+' explicit-locale Windows OLE Automation tests. CorelDRAW/VBA host behavior is a separate test.'

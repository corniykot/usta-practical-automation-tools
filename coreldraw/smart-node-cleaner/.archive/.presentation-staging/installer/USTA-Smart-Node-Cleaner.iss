; USTA Smart Node Cleaner v0.73 — CorelDRAW 2018 x64
; Installs the existing GMS and patches the user's saved Standard toolbar.
#define AppName "USTA Smart Node Cleaner"
#define AppVersion "0.73"

[Setup]
AppId={{93A5344A-826C-4973-9E85-8D9E47B079F5}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=USTA Practical Automation Tools
AppPublisherURL=https://github.com/corniykot/usta-practical-automation-tools
DefaultDirName={userappdata}\Corel\CorelDRAW Graphics Suite 2018\Draw\GMS
UsePreviousAppDir=no
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
SetupLogging=yes
OutputDir=output
OutputBaseFilename=USTA-Smart-Node-Cleaner-v0.73-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=no
RestartApplications=no
UninstallDisplayName={#AppName} v{#AppVersion}

[Files]
; Preserve an already installed macro byte-for-byte, including on repeat setup.
Source: "..\UstaSmartNodeCleaner.gms"; DestDir: "{app}"; Flags: onlyifdoesntexist uninsneveruninstall
Source: "..\Usta_Smart_Node_Cleaner.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "Add-UstaToolbarButton.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Invoke-UstaToolbarIntegration.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Code]
var
  DiagnosticDir: String;

function TargetWorkspace(): String;
begin
  Result := ExpandConstant('{param:WORKSPACE|{userappdata}\Corel\CorelDRAW Graphics Suite 2018\Draw\Workspace\_default.cdws}');
end;

function PowerShellPath(): String;
begin
  // Setup is 32-bit; sysnative explicitly starts 64-bit Windows PowerShell.
  Result := ExpandConstant('{sysnative}\WindowsPowerShell\v1.0\powershell.exe');
end;

function InitializeSetup(): Boolean;
var
  Workspace: String;
begin
  Result := True;
  Workspace := TargetWorkspace();
  if not FileExists(Workspace) then
  begin
    MsgBox('CorelDRAW 2018 default workspace was not found.' + #13#10 +
      'Start CorelDRAW once, close it, and then run this installer.', mbError, MB_OK);
    Result := False;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  Code: Integer;
  Params: String;
begin
  Result := '';
  DiagnosticDir := ExpandConstant('{localappdata}\USTA\Smart Node Cleaner\Logs\') +
    GetDateTimeString('yyyymmdd-hhnnss', '-', ':') + '-' + ExtractFileName(ExpandConstant('{tmp}'));
  if not ForceDirectories(DiagnosticDir) then
  begin
    Result := 'Could not create installer diagnostic directory: ' + DiagnosticDir;
    Exit;
  end;
  ExtractTemporaryFile('Invoke-UstaToolbarIntegration.ps1');
  Params := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    ExpandConstant('{tmp}\Invoke-UstaToolbarIntegration.ps1') + '" -CheckOnly -WorkspacePath "' +
    TargetWorkspace() + '" -LogPath "' + DiagnosticDir + '\preflight.log"';
  Log('Pre-install check: ' + PowerShellPath() + ' ' + Params);
  if not Exec(PowerShellPath(), Params, '', SW_HIDE, ewWaitUntilTerminated, Code) then
    Result := 'Could not start Windows PowerShell: ' + SysErrorMessage(Code)
  else if Code <> 0 then
    Result := 'Pre-install check failed. Close CorelDRAW and inspect: ' + DiagnosticDir + '\preflight.log';
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  Code: Integer;
  Params, ScriptPath, IconPath: String;
begin
  if CurStep <> ssPostInstall then Exit;
  ScriptPath := ExpandConstant('{app}\Add-UstaToolbarButton.ps1');
  IconPath := ExpandConstant('{app}\Usta_Smart_Node_Cleaner.ico');
  Params := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    ExpandConstant('{app}\Invoke-UstaToolbarIntegration.ps1') + '" -ScriptPath "' + ScriptPath +
    '" -IconPath "' + IconPath + '" -WorkspacePath "' + TargetWorkspace() +
    '" -LogPath "' + DiagnosticDir + '\integration.log"';
  Log('Toolbar invocation: ' + PowerShellPath() + ' ' + Params);
  if not Exec(PowerShellPath(),
    Params, '', SW_HIDE, ewWaitUntilTerminated, Code) then
    RaiseException('Could not start PowerShell toolbar integration: ' + SysErrorMessage(Code));
  if Code <> 0 then
    RaiseException('Toolbar integration failed (exit code ' + IntToStr(Code) +
      '). Diagnostic log: ' + DiagnosticDir + '\integration.log');
  Log('Toolbar integration completed. Diagnostics: ' + DiagnosticDir);
end;

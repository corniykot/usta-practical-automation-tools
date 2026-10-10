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
OutputDir=output
OutputBaseFilename=USTA-Smart-Node-Cleaner-v0.73-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=no
RestartApplications=no
UninstallDisplayName={#AppName} v{#AppVersion}

[Files]
Source: "..\UstaSmartNodeCleaner.gms"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Usta_Smart_Node_Cleaner.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "Add-UstaToolbarButton.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Code]
function InitializeSetup(): Boolean;
var
  Workspace: String;
begin
  Result := True;
  Workspace := ExpandConstant('{userappdata}\Corel\CorelDRAW Graphics Suite 2018\Draw\Workspace\_default.cdws');
  if not FileExists(Workspace) then
  begin
    MsgBox('CorelDRAW 2018 default workspace was not found.' + #13#10 +
      'Start CorelDRAW once, close it, and then run this installer.', mbError, MB_OK);
    Result := False;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  Code: Integer;
  Params, ScriptPath, IconPath: String;
begin
  if CurStep <> ssPostInstall then Exit;
  ScriptPath := ExpandConstant('{app}\Add-UstaToolbarButton.ps1');
  IconPath := ExpandConstant('{app}\Usta_Smart_Node_Cleaner.ico');
  Params := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' + ScriptPath +
    '" -IconPath "' + IconPath + '"';
  if not Exec(ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'),
    Params, '', SW_HIDE, ewWaitUntilTerminated, Code) then
    RaiseException('Could not start PowerShell toolbar integration.');
  if Code <> 0 then
    RaiseException('Toolbar integration failed (exit code ' + IntToStr(Code) +
      '). Close CorelDRAW, review the workspace backup, and rerun setup.');
end;

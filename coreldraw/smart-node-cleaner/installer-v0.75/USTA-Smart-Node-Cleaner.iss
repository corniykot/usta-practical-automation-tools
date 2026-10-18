; USTA Smart Node Cleaner v0.75. Uses the verified file integration, no VBA build.
#define AppName "USTA Smart Node Cleaner"
#define AppVersion "0.75"
[Setup]
AppId={{F893B682-45A2-4D44-AE3B-7F0512B07575}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=Corniy Kot / Usta.Scripts
AppPublisherURL=https://github.com/corniykot/usta-practical-automation-tools
DefaultDirName={localappdata}\Usta.Scripts\SmartNodeCleaner\v0.75
UsePreviousAppDir=no
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
SetupLogging=yes
UninstallLogging=yes
OutputDir=output
OutputBaseFilename=USTA-Smart-Node-Cleaner-v0.75-Setup
SetupIconFile=Usta_Smart_Node_Cleaner.ico
UninstallDisplayIcon={app}\Usta_Smart_Node_Cleaner.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=no
RestartApplications=no
UninstallDisplayName={#AppName} v{#AppVersion}

[Files]
Source: "UstaSmartNodeCleaner.gms"; DestDir: "{app}"; Flags: ignoreversion
Source: "Usta_Smart_Node_Cleaner.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "Get-CorelTargets.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Manage-Usta.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Usta.Files.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Add-UstaToolbarButton.ps1"; DestDir: "{app}"; Flags: ignoreversion

[UninstallDelete]
; These directories belong exclusively to this application. Integration cleanup
; must succeed before Inno is allowed to remove them or the uninstall entry.
Type: filesandordirs; Name: "{app}\State"
Type: filesandordirs; Name: "{app}\Logs"

[Code]
var
  TargetPage: TInputOptionWizardPage;
  TargetIni, LogDirectory: String;
  IntegrationFailed: Boolean;

function PowerShellPath(): String;
begin
  Result := ExpandConstant('{sysnative}\WindowsPowerShell\v1.0\powershell.exe');
end;

function SelectedIndex(): Integer;
var I: Integer;
begin
  Result := -1;
  for I := 0 to TargetPage.CheckListBox.Items.Count - 1 do
    if TargetPage.Values[I] then Result := I;
end;

function TargetValue(Name: String): String;
begin
  Result := GetIniString('Target' + IntToStr(SelectedIndex()), Name, '', TargetIni);
end;

function IntegrationParameters(Mode, SourcePath: String): String;
begin
  Result := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    SourcePath + '\Manage-Usta.ps1" -Mode ' + Mode +
    ' -Major ' + TargetValue('Major') + ' -ProfilePath "' + TargetValue('Profile') +
    '" -StateRoot "' + ExpandConstant('{app}\State') + '"';
end;

procedure InitializeWizard();
var Params, Requested: String;
    Count, I, Code, Preferred: Integer;
begin
  // The app constant is not initialized here. Use the current default directory.
  LogDirectory := AddBackslash(WizardDirValue) + 'Logs';
  if not ForceDirectories(LogDirectory) then RaiseException('Cannot create diagnostics: ' + LogDirectory);
  TargetIni := LogDirectory + '\targets.ini';
  ExtractTemporaryFile('Get-CorelTargets.ps1');
  Params := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    ExpandConstant('{tmp}\Get-CorelTargets.ps1') + '" -OutputIni "' + TargetIni + '"';
  if not Exec(PowerShellPath(), Params, ExpandConstant('{tmp}'), SW_HIDE, ewWaitUntilTerminated, Code) then
    RaiseException('Cannot start CorelDRAW discovery: ' + SysErrorMessage(Code));
  if Code <> 0 then RaiseException('CorelDRAW discovery failed. See the setup log.');
  Count := StrToIntDef(GetIniString('Targets', 'Count', '0', TargetIni), 0);
  if Count = 0 then begin
    Log('No initialized CorelDRAW X7-2022 x64 profile found.');
    SuppressibleMsgBox('No initialized CorelDRAW X7-2022 x64 profile found. Start your CorelDRAW once, close it, and retry.', mbError, MB_OK, IDOK);
    Abort;
  end;
  TargetPage := CreateInputOptionPage(wpWelcome, 'Select CorelDRAW',
    'Install Smart Node Cleaner v0.75 for this version',
    'Close all CorelDRAW windows before continuing. VBA must be available in the selected version.', True, False);
  Requested := ExpandConstant('{param:TARGETMAJOR|}');
  Preferred := -1;
  for I := 0 to Count - 1 do begin
    TargetPage.Add(GetIniString('Target' + IntToStr(I), 'Label', '', TargetIni));
    if (Requested <> '') and (GetIniString('Target' + IntToStr(I), 'Major', '', TargetIni) = Requested) then Preferred := I;
  end;
  if (Requested <> '') and (Preferred < 0) then RaiseException('Requested CorelDRAW version was not found.');
  if (Count > 1) and WizardSilent() and (Requested = '') then RaiseException('Several versions detected. Silent setup requires /TARGETMAJOR=<17..24>.');
  if Preferred < 0 then Preferred := 0;
  TargetPage.Values[Preferred] := True;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var Code: Integer;
begin
  Result := '';
  if SelectedIndex() < 0 then begin Result := 'Select a CorelDRAW version.'; Exit; end;
  ExtractTemporaryFile('Manage-Usta.ps1');
  ExtractTemporaryFile('Usta.Files.ps1');
  ExtractTemporaryFile('Add-UstaToolbarButton.ps1');
  ExtractTemporaryFile('UstaSmartNodeCleaner.gms');
  ExtractTemporaryFile('Usta_Smart_Node_Cleaner.ico');
  if not Exec(PowerShellPath(), IntegrationParameters('Check', ExpandConstant('{tmp}')),
    ExpandConstant('{tmp}'), SW_HIDE, ewWaitUntilTerminated, Code) then
    Result := 'Could not start preflight: ' + SysErrorMessage(Code)
  else if Code <> 0 then Result := 'Preflight failed. Close CorelDRAW and inspect: ' + ExpandConstant('{app}\State');
end;

procedure CurStepChanged(CurStep: TSetupStep);
var Code: Integer;
begin
  if CurStep <> ssPostInstall then Exit;
  IntegrationFailed := True;
  WizardForm.StatusLabel.Caption := 'Installing the macro and toolbar button...';
  if not Exec(PowerShellPath(), IntegrationParameters('Install', ExpandConstant('{app}')),
    ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, Code) then
    RaiseException('Could not start integration: ' + SysErrorMessage(Code));
  if Code <> 0 then RaiseException('Macro integration failed. Inspect: ' + ExpandConstant('{app}\State'));
  IntegrationFailed := False;
end;

function GetCustomSetupExitCode(): Integer;
begin
  if IntegrationFailed then Result := 1 else Result := 0;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if (CurPageID = wpFinished) and IntegrationFailed then begin
    WizardForm.FinishedHeadingLabel.Caption := 'Smart Node Cleaner installation failed';
    WizardForm.FinishedLabel.Caption := 'Macro and toolbar integration did not complete. Diagnostics: ' + ExpandConstant('{app}\State');
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var Params: String;
    Code: Integer;
begin
  if CurUninstallStep <> usUninstall then Exit;
  Params := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    ExpandConstant('{app}\Manage-Usta.ps1') + '" -Mode UninstallAll -StateRoot "' + ExpandConstant('{app}\State') + '"';
  if not Exec(PowerShellPath(), Params, ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, Code) then begin
    SuppressibleMsgBox('Cannot start integration cleanup. Support files and the uninstall entry are preserved.', mbError, MB_OK, IDOK);
    Abort;
  end;
  if Code <> 0 then begin
    SuppressibleMsgBox('Cleanup could not complete. Close CorelDRAW or inspect edited files. Support files and the uninstall entry are preserved. Diagnostics: ' + ExpandConstant('{app}\State'), mbError, MB_OK, IDOK);
    Abort;
  end;
end;

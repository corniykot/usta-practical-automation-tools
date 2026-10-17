; Native-source successor to the existing USTA Inno Setup installer.
#define AppName "USTA Smart Node Cleaner"
#define AppVersion "0.9"
[Setup]
AppId={{CA207DF9-51B3-4695-A0EF-01CF33CBEA09}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=Corniy Kot / Usta.Scripts
AppPublisherURL=https://github.com/corniykot/usta-practical-automation-tools
DefaultDirName={localappdata}\Usta.Scripts\SmartNodeCleaner\v0.9
UsePreviousAppDir=no
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
SetupLogging=yes
OutputDir=output
OutputBaseFilename=USTA-Smart-Node-Cleaner-v0.9-Setup
SetupIconFile=Usta_Smart_Node_Cleaner.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=no
RestartApplications=no
UninstallDisplayName={#AppName} v{#AppVersion}

[Files]
; Source only: no precompiled GMS is shipped or copied to the target host.
Source: "USTA_Node_Cleaner_v0_73_Engine.bas"; DestDir: "{app}"; Flags: ignoreversion
Source: "frmUSTANodeCleaner_v0_73_CODE.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "Usta_Smart_Node_Cleaner.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "Get-CorelTargets.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Build-NativeGms.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Manage-UstaInstallation.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "Add-UstaToolbarButton.MultiVersion.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Code]
var
  TargetPage: TInputOptionWizardPage;
  TargetIni, DiagnosticDir: String;
  TargetCount: Integer;
  NativeFailed: Boolean;

function PowerShellPath(): String;
begin
  Result := ExpandConstant('{sysnative}\WindowsPowerShell\v1.0\powershell.exe');
end;

function SelectedIndex(): Integer;
var I: Integer;
begin
  Result := -1;
  for I := 0 to TargetCount - 1 do
    if TargetPage.Values[I] then Result := I;
end;

function TargetValue(Key: String): String;
begin
  Result := GetIniString('Target' + IntToStr(SelectedIndex()), Key, '', TargetIni);
end;

procedure InitializeWizard();
var I, Code, Preferred: Integer;
    Requested, LabelText, Params: String;
begin
  DiagnosticDir := ExpandConstant('{localappdata}\Usta.Scripts\SmartNodeCleaner\Logs\') +
    GetDateTimeString('yyyymmdd-hhnnss', '-', ':') + '-' + ExtractFileName(ExpandConstant('{tmp}'));
  Requested := ExpandConstant('{param:DIAGNOSTICDIR|}');
  if Requested <> '' then DiagnosticDir := Requested;
  if not ForceDirectories(DiagnosticDir) then RaiseException('Cannot create diagnostics: ' + DiagnosticDir);
  TargetIni := DiagnosticDir + '\targets.ini';
  ExtractTemporaryFile('Get-CorelTargets.ps1');
  Params := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    ExpandConstant('{tmp}\Get-CorelTargets.ps1') + '" -OutputIni "' + TargetIni + '"';
  if not Exec(PowerShellPath(), Params, '', SW_HIDE, ewWaitUntilTerminated, Code) then
    RaiseException('Cannot start version discovery: ' + SysErrorMessage(Code));
  if Code <> 0 then RaiseException('CorelDRAW discovery failed. Log: ' + TargetIni + '.log');
  TargetCount := StrToIntDef(GetIniString('Targets', 'Count', '0', TargetIni), 0);
  if TargetCount = 0 then RaiseException('No initialized CorelDRAW 64-bit profile found. Start your licensed CorelDRAW once, close it, and retry. Log: ' + TargetIni);
  TargetPage := CreateInputOptionPage(wpWelcome, 'Select CorelDRAW',
    'Install for the selected CorelDRAW version',
    'A licensed CorelDRAW installation with VBA is required. Close all CorelDRAW windows before clicking Install. Your existing v0.73 macro and other commands will be preserved.', True, False);
  Requested := ExpandConstant('{param:TARGETMAJOR|}');
  Preferred := -1;
  for I := 0 to TargetCount - 1 do begin
    LabelText := GetIniString('Target' + IntToStr(I), 'Label', '', TargetIni);
    TargetPage.Add(LabelText);
    if Requested <> '' then begin
      if GetIniString('Target' + IntToStr(I), 'Major', '', TargetIni) = Requested then Preferred := I;
    end else if FileExists(GetIniString('Target' + IntToStr(I), 'GmsPath', '', TargetIni) + '\UstaSmartNodeCleaner.gms') then
      Preferred := I;
  end;
  if (Requested <> '') and (Preferred < 0) then RaiseException('Requested CorelDRAW version/profile was not found.');
  if (TargetCount > 1) and WizardSilent() and (Requested = '') then
    RaiseException('Several CorelDRAW versions found. Silent setup requires /TARGETMAJOR=<major>.');
  if Preferred < 0 then Preferred := 0;
  TargetPage.Values[Preferred] := True;
end;

function ParametersFor(Mode, SourcePath, LogName: String): String;
begin
  Result := '-NoProfile -NonInteractive -STA -ExecutionPolicy Bypass -File "' +
    SourcePath + '\Manage-UstaInstallation.ps1" -Mode ' + Mode +
    ' -WorkspaceFolder "' + TargetValue('WorkspaceFolder') +
    '" -GmsPath "' + TargetValue('GmsPath') +
    '" -ExpectedMajor ' + TargetValue('Major') +
    ' -ExePath "' + TargetValue('Exe') +
    '" -ProgId "' + TargetValue('ProgId') +
    '" -SourceDir "' + SourcePath +
    '" -LogPath "' + DiagnosticDir + '\' + LogName + '"';
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var Code: Integer;
    Params: String;
begin
  Result := '';
  if SelectedIndex() < 0 then begin Result := 'Select a CorelDRAW version.'; Exit; end;
  ExtractTemporaryFile('Manage-UstaInstallation.ps1');
  ExtractTemporaryFile('Build-NativeGms.ps1');
  ExtractTemporaryFile('Add-UstaToolbarButton.MultiVersion.ps1');
  ExtractTemporaryFile('USTA_Node_Cleaner_v0_73_Engine.bas');
  ExtractTemporaryFile('frmUSTANodeCleaner_v0_73_CODE.txt');
  ExtractTemporaryFile('Usta_Smart_Node_Cleaner.ico');
  Params := ParametersFor('Check', ExpandConstant('{tmp}'), 'preflight.log');
  Log('Native installation preflight: ' + Params);
  if not Exec(PowerShellPath(), Params, '', SW_HIDE, ewWaitUntilTerminated, Code) then
    Result := 'Could not start installation preflight: ' + SysErrorMessage(Code)
  else if Code <> 0 then begin
    Log('Preflight PowerShell exit code: ' + IntToStr(Code));
    Result := 'Preflight failed (exit ' + IntToStr(Code) + '). Inspect: ' + DiagnosticDir + '\preflight.log';
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var Code: Integer;
    Params: String;
begin
  if CurStep <> ssPostInstall then Exit;
  NativeFailed := True;
  WizardForm.StatusLabel.Caption := 'Building the macro in your CorelDRAW VBA environment...';
  Params := ParametersFor('Install', ExpandConstant('{app}'), 'native-install.log');
  Log('Native GMS build and integration: ' + Params);
  if not Exec(PowerShellPath(), Params, '', SW_HIDE, ewWaitUntilTerminated, Code) then
    RaiseException('Could not start native installation: ' + SysErrorMessage(Code));
  if Code <> 0 then RaiseException('Native GMS installation failed. Existing macro/workspaces preserved or rolled back. Diagnostics: ' + DiagnosticDir);
  NativeFailed := False;
  Log('Native installation completed: ' + DiagnosticDir);
end;

function GetCustomSetupExitCode(): Integer;
begin
  if NativeFailed then Result := 1 else Result := 0;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if (CurPageID = wpFinished) and NativeFailed then begin
    WizardForm.FinishedHeadingLabel.Caption := 'Native macro installation failed';
    WizardForm.FinishedLabel.Caption := 'The macro and toolbar installation did not complete. Existing macro/workspaces were preserved or rolled back. Diagnostics: ' + DiagnosticDir;
  end;
end;
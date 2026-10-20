; USTA Smart Node Cleaner v0.77. Uses the verified file integration, no VBA build.
#define AppName "USTA Smart Node Cleaner"
#define AppVersion "0.77"
[Setup]
AppId={{F893B682-45A2-4D44-AE3B-7F0512B07777}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=Corniy Kot / Usta.Scripts
AppPublisherURL=https://github.com/corniykot/usta-practical-automation-tools
DefaultDirName={localappdata}\Usta.Scripts\SmartNodeCleaner\v0.77
UsePreviousAppDir=no
DisableDirPage=yes
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
SetupLogging=yes
UninstallLogging=yes
OutputDir=output
#ifndef UI_PREVIEW
OutputBaseFilename=USTA-Smart-Node-Cleaner-v0.77-Setup
#endif
SetupIconFile=ui\setup.ico
UninstallDisplayIcon={app}\Usta_Smart_Node_Cleaner.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
DisableWelcomePage=no
DisableReadyPage=no
#ifdef UI_PREVIEW
OutputBaseFilename=USTA-v077-UI-Preview
Uninstallable=no
CreateAppDir=no
#endif
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

Source: "Get-RunningCorel.ps1"; Flags: dontcopy
Source: "ui\welcome.png"; Flags: dontcopy
Source: "ui\header.png"; Flags: dontcopy

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

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

#include "Usta.UI.iss"

procedure InitializeWizard();
var Params, Requested: String;
    Count, I, Code, Preferred: Integer;
begin
#ifdef UI_PREVIEW
  // Dedicated visual test executable: no discovery, integration or installed files.
  TargetPage := CreateInputOptionPage(wpWelcome,'Preview','','',True,False);
  TargetPage.Add('CorelDRAW Graphics Suite 2018 (64-bit)');
  TargetPage.Add('CorelDRAW Graphics Suite 2020 (64-bit)');
  TargetPage.Add('CorelDRAW Graphics Suite 2022 (64-bit)');
  TargetPage.Values[0] := True;
  UstaInitializeUI();
#else
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
    'Install Smart Node Cleaner v0.77 for this version',
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
  UstaInitializeUI();
#endif
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var Code: Integer;
begin
  Result := '';
  if SelectedIndex() < 0 then begin Result := 'Select a CorelDRAW version.'; Exit; end;
  if UstaCheckRunning() > 0 then begin Result := 'Save your documents and close CorelDRAW, then retry.'; Exit; end;
  ExtractTemporaryFile('Manage-Usta.ps1');
  ExtractTemporaryFile('Usta.Files.ps1');
  ExtractTemporaryFile('Add-UstaToolbarButton.ps1');
  ExtractTemporaryFile('UstaSmartNodeCleaner.gms');
  ExtractTemporaryFile('Usta_Smart_Node_Cleaner.ico');
  if not Exec(PowerShellPath(), IntegrationParameters('Check', ExpandConstant('{tmp}')),
    ExpandConstant('{tmp}'), SW_HIDE, ewWaitUntilTerminated, Code) then
    Result := 'Could not start preflight: ' + SysErrorMessage(Code)
  else if Code <> 0 then Result := 'Preflight failed. Close CorelDRAW and inspect: ' + ExpandConstant('{app}\State');
  if Result<>'' then begin UstaRender(6); UstaBody.Caption := Result; end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var Code: Integer;
begin
  if CurStep <> ssPostInstall then Exit;
  IntegrationFailed := True;
  UstaBody.Caption := 'Installing the GMS macro and configuring the USTA toolbar button...';
  UstaProgress.Style := npbstMarquee;
  UstaPanel.Repaint;
  WizardForm.StatusLabel.Caption := UstaBody.Caption;
  if not Exec(PowerShellPath(), IntegrationParameters('Install', ExpandConstant('{app}')),
    ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, Code) then
    RaiseException('Could not start integration: ' + SysErrorMessage(Code));
  if Code <> 0 then RaiseException('Macro integration failed. Inspect: ' + ExpandConstant('{app}\State'));
  IntegrationFailed := False;
  UstaProgress.Style := npbstNormal; UstaProgress.Position := 100;
  UstaBody.Caption := 'Macro and toolbar integration completed.';
end;

function GetCustomSetupExitCode(): Integer;
begin
  if IntegrationFailed then Result := 1 else Result := 0;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
#ifdef UI_PREVIEW
  Result := False;
#else
  Result := True;
  if (CurPageID=TargetPage.ID) and (UstaCheckRunning()>0) then begin
    UstaRender(2); Result := False;
  end;
#endif
end;

procedure CurInstallProgressChanged(CurProgress,MaxProgress: Integer);
begin
  if MaxProgress>0 then UstaProgress.Position := (CurProgress*100) div MaxProgress;
end;

procedure CurPageChanged(CurPageID: Integer);
var Preview: String;
begin
  if UstaPanel=nil then Exit;
  UstaPageID := CurPageID;
  WizardForm.BackButton.Visible := False; WizardForm.NextButton.Visible := False; WizardForm.CancelButton.Visible := False;
  WizardForm.Bevel.Visible := False;
#ifdef UI_PREVIEW
  Preview := ExpandConstant('{param:PREVIEW|welcome}');
  if Preview='target' then UstaRender(1)
  else if Preview='running' then UstaRender(2)
  else if Preview='ready' then UstaRender(3)
  else if Preview='progress' then begin UstaRender(4); UstaProgress.Position := 65; end
  else if Preview='finished' then UstaRender(5)
  else UstaRender(0);
#else
  if CurPageID=wpWelcome then UstaRender(0)
  else if CurPageID=TargetPage.ID then UstaRender(1)
  else if CurPageID=wpReady then UstaRender(3)
  else if CurPageID=wpInstalling then UstaRender(4)
  else if CurPageID=wpFinished then UstaRender(5)
  else if CurPageID=wpPreparing then begin
    UstaRender(4); UstaHeading.Caption := 'Checking Installation';
    UstaBody.Caption := 'Checking the selected CorelDRAW workspace...';
  end;
#endif
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

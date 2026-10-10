; USTA Smart Node Cleaner v0.73 - CorelDRAW 2018
; Per-user installer. No admin rights required.
#define MyAppName "USTA Smart Node Cleaner"
#define MyAppVersion "0.73"
#define MyFileName "UstaSmartNodeCleaner.gms"

[Setup]
AppId={{93A5344A-826C-4973-9E85-8D9E47B079F5}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher=USTA Practical Automation Tools
AppPublisherURL=https://github.com/corniykot/usta-practical-automation-tools
AppSupportURL=https://github.com/corniykot/usta-practical-automation-tools/issues
AppUpdatesURL=https://github.com/corniykot/usta-practical-automation-tools/releases
DefaultDirName={userappdata}\Corel\CorelDRAW Graphics Suite 2018\Draw\GMS
UsePreviousAppDir=no
DisableDirPage=yes
DisableProgramGroupPage=yes
UninstallDisplayName={#MyAppName} v{#MyAppVersion}
PrivilegesRequired=lowest
OutputDir=output
OutputBaseFilename=USTA-Smart-Node-Cleaner-v0.73-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=no
RestartApplications=no
DisableWelcomePage=no
; We intentionally do not sign the EXE locally. Signed releases require
; a SignPath Foundation verified GitHub Actions build and approval.

[Files]
Source: "..\UstaSmartNodeCleaner.gms"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Usta_Smart_Node_Cleaner.ico"; DestDir: "{app}"; Flags: ignoreversion

[Run]
; CorelDRAW must be restarted after installation to load new GMS macros.

[UninstallDelete]
; Inno Setup removes only files it installed; user projects are untouched.

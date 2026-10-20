// Native Inno controls only. Preview is a separate, compile-time, non-installing build.
const
  UstaBackground = $120C06;
  UstaMuted = $D4C8BC;
  UstaOrange = $009DFF;
var
  UstaPanel: TPanel;
  UstaArt, UstaBanner: TBitmapImage;
  UstaBrand, UstaProduct, UstaHeading, UstaDescription, UstaBody, UstaDetail: TLabel;
  UstaWarning: TLabel;
  UstaNext, UstaBack, UstaCancel: TBitmapButton;
  UstaRows: array of TBitmapButton;
  UstaIcons: array of TBitmapImage;
  UstaProgress: TBitmapImage;
  UstaMode, UstaPageID: Integer;
  UstaRunningIni: String;
  UstaBusy: Boolean;

function DwmSetWindowAttribute(Wnd: HWND; Attribute: Integer; var Value: Integer; Size: Integer): Integer;
  external 'DwmSetWindowAttribute@dwmapi.dll stdcall delayload';
function UstaSendMessage(Wnd: HWND; Msg, WParam, LParam: Longint): Longint;
  external 'SendMessageW@user32.dll stdcall';
function UstaSetWindowTheme(Wnd: HWND; AppName, PartList: String): Integer;
  external 'SetWindowTheme@uxtheme.dll stdcall';

procedure UstaBounds(Control: TControl; X,Y,W,H: Integer);
begin
  Control.SetBounds(ScaleX(X), ScaleY(Y), ScaleX(W), ScaleY(H));
end;

function UstaLabel(X,Y,W,H,Size: Integer; Bold: Boolean): TLabel;
begin
  Result := TLabel.Create(WizardForm); Result.Parent := UstaPanel;
  Result.AutoSize := False; Result.WordWrap := True; Result.Transparent := True;
  Result.Font.Name := 'Segoe UI'; Result.Font.Size := Size; Result.Font.Color := clWhite;
  if Bold then Result.Font.Style := [fsBold];
  UstaBounds(Result,X,Y,W,H);
end;

procedure UstaPaintButton(B: TBitmapButton; Text: String; Primary: Boolean);
var C: TCanvas; TW,TH: Integer;
begin
  B.Caption := Text; B.Bitmap.Width := B.Width; B.Bitmap.Height := B.Height;
  C := B.Bitmap.Canvas; C.Brush.Color := UstaBackground; C.Pen.Color := UstaBackground; C.Rectangle(0,0,B.Width,B.Height);
  if Primary then begin C.Brush.Color := UstaOrange; C.Pen.Color := UstaOrange; end
  else begin C.Brush.Color := UstaBackground; C.Pen.Color := $665543; end;
  C.RoundRect(1,1,B.Width-1,B.Height-1,ScaleX(9),ScaleY(9));
  C.Font.Name := 'Segoe UI'; C.Font.Size := 12;
  if Primary then C.Font.Color := UstaBackground else C.Font.Color := clWhite;
  TW := C.TextWidth(Text); TH := C.TextHeight(Text);
  C.TextOut((B.Width-TW) div 2,(B.Height-TH) div 2,Text);
  B.Invalidate;
end;

procedure UstaRender(Mode: Integer); forward;

procedure UstaSetProgress(Value: Integer);
var C: TCanvas; W,H,L,R: Integer;
begin
  W := UstaProgress.Width; H := UstaProgress.Height;
  UstaProgress.Bitmap.Width := W; UstaProgress.Bitmap.Height := H;
  C := UstaProgress.Bitmap.Canvas; C.Brush.Color := UstaBackground;
  C.Pen.Color := $665543; C.RoundRect(0,0,W,H,H,H);
  C.Brush.Color := UstaOrange; C.Pen.Color := UstaOrange;
  if Value<0 then begin L := W div 3; R := (W*2) div 3; end
  else begin L := 1; R := ((W-2)*Value) div 100; end;
  if R>L then C.RoundRect(L,1,R,H-1,H-2,H-2);
  UstaProgress.Invalidate;
end;

procedure UstaRowClick(Sender: TObject);
var I, Selected: Integer;
begin
  if UstaMode <> 1 then Exit;
  Selected := TBitmapButton(Sender).Tag;
  for I := 0 to TargetPage.CheckListBox.Items.Count-1 do TargetPage.Values[I] := I=Selected;
  UstaRender(1);
end;

procedure UstaRowsClear();
var I: Integer;
begin
  for I := 0 to GetArrayLength(UstaRows)-1 do UstaRows[I].Free;
  for I := 0 to GetArrayLength(UstaIcons)-1 do UstaIcons[I].Free;
  SetArrayLength(UstaRows,0); SetArrayLength(UstaIcons,0);
end;

procedure UstaDrawRow(Index,Y: Integer; Text,IconPath: String; Selected,Radio: Boolean);
var B: TBitmapButton; C: TCanvas; N, CY: Integer;
    Image: TBitmapImage;
begin
  B := TBitmapButton.Create(WizardForm); B.Parent := UstaPanel; B.Tag := Index;
  UstaBounds(B,40,Y,640,40); B.Caption := Text; B.TabStop := Radio;
  B.Bitmap.Width := B.Width; B.Bitmap.Height := B.Height; C := B.Bitmap.Canvas;
  C.Brush.Color := UstaBackground; C.Pen.Color := UstaBackground; C.Rectangle(0,0,B.Width,B.Height);
  if Radio then begin
    if Selected then C.Pen.Color := UstaOrange else C.Pen.Color := $786654;
    C.Pen.Width := ScaleX(2); C.Ellipse(ScaleX(4),ScaleY(8),ScaleX(28),ScaleY(32));
    if Selected then begin C.Brush.Color := UstaOrange; C.Ellipse(ScaleX(10),ScaleY(14),ScaleX(22),ScaleY(26)); end;
    B.OnClick := @UstaRowClick;
  end;
  C.Font.Name := 'Segoe UI'; C.Font.Size := 14; C.Font.Color := clWhite;
  C.Brush.Color := UstaBackground;
  CY := (B.Height-C.TextHeight(Text)) div 2; C.TextOut(ScaleX(48),CY,Text);
  N := GetArrayLength(UstaRows); SetArrayLength(UstaRows,N+1); UstaRows[N] := B;
  if (IconPath <> '') and FileExists(IconPath) then begin
    Image := TBitmapImage.Create(WizardForm); Image.Parent := UstaPanel;
    UstaBounds(Image,43,Y+6,28,28); Image.Stretch := True;
    try Image.Bitmap.LoadFromFile(IconPath); except Log('Could not display CorelDRAW icon.'); end;
    N := GetArrayLength(UstaIcons); SetArrayLength(UstaIcons,N+1); UstaIcons[N] := Image;
  end;
end;

function UstaCheckRunning(): Integer;
var Code: Integer; Params: String;
begin
#ifdef UI_PREVIEW
  Result := 1;
#else
  UstaRunningIni := ExpandConstant('{tmp}\usta-running.ini');
  ExtractTemporaryFile('Get-RunningCorel.ps1');
  Params := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "'+
    ExpandConstant('{tmp}\Get-RunningCorel.ps1')+'" -OutputIni "'+UstaRunningIni+'"';
  if not Exec(PowerShellPath(),Params,ExpandConstant('{tmp}'),SW_HIDE,ewWaitUntilTerminated,Code) then
    RaiseException('Cannot check running CorelDRAW processes: '+SysErrorMessage(Code));
  if Code <> 0 then RaiseException('Cannot check running CorelDRAW. See the setup log.');
  Result := StrToIntDef(GetIniString('Running','Count','-1',UstaRunningIni),-1);
  if Result < 0 then RaiseException('Invalid CorelDRAW process-check result.');
#endif
end;

procedure UstaRender(Mode: Integer);
var I, Count: Integer; Text, IconPath: String;
begin
  UstaMode := Mode; UstaRowsClear();
  UstaArt.Visible := (Mode=0) or (Mode=5);
  UstaBrand.Visible := UstaArt.Visible; UstaProduct.Visible := UstaArt.Visible;
  UstaBanner.Visible := not UstaArt.Visible;
  UstaBody.Caption := ''; UstaDetail.Caption := ''; UstaDescription.Caption := '';
  UstaProgress.Visible := Mode=4;
  UstaWarning.Visible := Mode=2;
  UstaBack.Visible := Mode=1; UstaCancel.Visible := (Mode<>4) and (Mode<>5);
  UstaNext.Visible := Mode<>4; UstaNext.Enabled := True;
#ifdef UI_PREVIEW
  UstaNext.Visible := True;
#endif
  UstaBounds(UstaHeading,40,30,640,58); UstaBounds(UstaDescription,40,90,620,70);
  UstaBounds(UstaBody,40,200,640,220); UstaBounds(UstaDetail,40,438,640,72);
  UstaPaintButton(UstaBack,'< Back',False); UstaPaintButton(UstaCancel,'Cancel',False);
  UstaPaintButton(UstaNext,'Next >',True);
  UstaBounds(UstaNext,366,548,150,46); UstaBounds(UstaCancel,530,548,150,46);
  if (Mode=0) or (Mode=5) then begin
    UstaBounds(UstaNext,530,548,150,46); UstaBounds(UstaCancel,366,548,150,46);
    UstaBounds(UstaHeading,300,65,382,120); UstaBounds(UstaBody,300,208,376,210);
    UstaBounds(UstaDetail,300,430,376,72);
  end;
  case Mode of
    0: begin
      UstaHeading.Caption := 'Welcome to USTA Practical Automation Tools!';
      UstaBody.Caption := 'This setup will install USTA Smart Node Cleaner on your computer.'+#13#10+#13#10+
        'Please close CorelDRAW before continuing.';
    end;
    1: begin
      UstaHeading.Caption := 'Select CorelDRAW Version';
      UstaDescription.Caption := 'Select the version of CorelDRAW to install USTA Smart Node Cleaner for.';
      Count := TargetPage.CheckListBox.Items.Count;
      for I := 0 to Count-1 do UstaDrawRow(I,194+I*38,TargetPage.CheckListBox.Items[I],'',TargetPage.Values[I],True);
    end;
    2: begin
      UstaBounds(UstaHeading,100,30,580,58);
      UstaHeading.Caption := 'CorelDRAW is running'; UstaHeading.Font.Color := UstaOrange;
      UstaDescription.Caption := 'Please close the following versions of CorelDRAW to continue installation:';
#ifdef UI_PREVIEW
      UstaDrawRow(0,210,'CorelDRAW Graphics Suite 2020 (64-bit)','',False,False);
#else
      Count := StrToIntDef(GetIniString('Running','Count','0',UstaRunningIni),0);
      for I := 0 to Count-1 do begin
        Text := GetIniString('Process'+IntToStr(I),'Label','CorelDRAW',UstaRunningIni);
        IconPath := GetIniString('Process'+IntToStr(I),'Icon','',UstaRunningIni);
        UstaDrawRow(I,200+I*42,Text,IconPath,False,False);
      end;
#endif
      UstaDetail.Caption := 'Save your open documents and close CorelDRAW, then click Check Again.';
      UstaPaintButton(UstaNext,'Check Again',True);
    end;
    3: begin
      UstaHeading.Caption := 'Ready to Install';
      UstaDescription.Caption := 'Setup is ready to install USTA Smart Node Cleaner v0.77.';
      UstaBody.Caption := 'Selected version:'+#13#10+TargetPage.CheckListBox.Items[SelectedIndex()]+#13#10+#13#10+
        'The macro and USTA button will be installed for your Windows account.';
      UstaBack.Visible := True; UstaPaintButton(UstaNext,'Install',True);
    end;
    4: begin
      UstaHeading.Caption := 'Installing';
      UstaDescription.Caption := 'Please wait while USTA Smart Node Cleaner is installed on your computer.';
      UstaBody.Caption := 'Copying files...';
      UstaSetProgress(0);
#ifdef UI_PREVIEW
      UstaSetProgress(65);
#endif
    end;
    5: begin
      if IntegrationFailed then begin
        UstaHeading.Caption := 'Installation Incomplete';
        UstaBody.Caption := 'Macro and toolbar integration did not complete.'+#13#10+#13#10+'Diagnostics: '+ExpandConstant('{app}\State');
      end else begin
        UstaHeading.Caption := 'Installation Complete!';
        UstaBody.Caption := 'USTA Smart Node Cleaner has been successfully installed.'+#13#10+#13#10+
          'Removing unnecessary nodes in CorelDRAW is now easier.'+#13#10+#13#10+'Enjoy using USTA Smart Node Cleaner!';
      end;
      UstaPaintButton(UstaNext,'Finish',True);
    end;
    6: begin
      UstaHeading.Caption := 'Installation Cannot Continue';
      UstaDescription.Caption := 'No successful installation has been reported. Please resolve the issue below.';
      UstaBack.Visible := True; UstaPaintButton(UstaNext,'Retry',True);
    end;
  end;
  if Mode<>2 then UstaHeading.Font.Color := clWhite;
  UstaPanel.Repaint;
end;

procedure UstaNextClick(Sender: TObject);
begin
  if UstaBusy then Exit;
  UstaBusy := True;
  try
#ifdef UI_PREVIEW
    case UstaMode of
      0: UstaRender(1);
      1: UstaRender(2);
      2: UstaRender(3);
      3: UstaRender(4);
      4: UstaRender(5);
      5: WizardForm.Close;
    end;
#else
    if UstaMode=2 then begin
      if UstaCheckRunning()=0 then UstaSendMessage(WizardForm.NextButton.Handle,$00F5,0,0) else UstaRender(2);
    end else UstaSendMessage(WizardForm.NextButton.Handle,$00F5,0,0);
#endif
  finally UstaBusy := False; end;
end;

procedure UstaBackClick(Sender: TObject);
begin
#ifdef UI_PREVIEW
  UstaRender(1);
#else
  UstaSendMessage(WizardForm.BackButton.Handle,$00F5,0,0);
#endif
end;

procedure UstaCancelClick(Sender: TObject);
begin
#ifdef UI_PREVIEW
  WizardForm.Close;
#else
  UstaSendMessage(WizardForm.CancelButton.Handle,$00F5,0,0);
#endif
end;

function UstaButton(X: Integer; Handler: TNotifyEvent): TBitmapButton;
begin
  Result := TBitmapButton.Create(WizardForm); Result.Parent := UstaPanel;
  UstaBounds(Result,X,548,150,46); Result.TabStop := True; Result.OnClick := Handler;
end;

procedure UstaInitializeUI();
var Dark: Integer;
begin
  WizardForm.ClientWidth := ScaleX(720); WizardForm.ClientHeight := ScaleY(620);
  WizardForm.Caption := 'Setup - USTA Smart Node Cleaner v0.77';
  WizardForm.Color := UstaBackground;
  Dark := 1;
  try DwmSetWindowAttribute(WizardForm.Handle,20,Dark,4); except Log('Native title bar dark mode is unavailable.'); end;
  UstaPanel := TPanel.Create(WizardForm); UstaPanel.Parent := WizardForm;
  UstaPanel.SetBounds(0,0,WizardForm.ClientWidth,WizardForm.ClientHeight);
  UstaPanel.BevelOuter := bvNone; UstaPanel.Color := UstaBackground;
  ExtractTemporaryFile('welcome.png'); ExtractTemporaryFile('header.png');
  UstaArt := TBitmapImage.Create(WizardForm); UstaArt.Parent := UstaPanel;
  UstaBounds(UstaArt,0,0,264,620); UstaArt.Stretch := True;
  UstaArt.PngImage.LoadFromFile(ExpandConstant('{tmp}\welcome.png'));
  UstaBanner := TBitmapImage.Create(WizardForm); UstaBanner.Parent := UstaPanel;
  UstaBounds(UstaBanner,0,0,720,180); UstaBanner.Stretch := True;
  UstaBanner.PngImage.LoadFromFile(ExpandConstant('{tmp}\header.png'));
  UstaBrand := UstaLabel(28,35,224,82,48,True); UstaBrand.Caption := 'USTA'; UstaBrand.Font.Color := UstaOrange;
  UstaProduct := UstaLabel(28,123,224,44,14,False); UstaProduct.Caption := 'SMART NODE CLEANER';
  UstaHeading := UstaLabel(40,30,640,58,23,True);
  UstaWarning := UstaLabel(40,19,58,64,36,True);
  UstaWarning.Caption := #$26A0; UstaWarning.Font.Name := 'Segoe UI Symbol'; UstaWarning.Font.Color := UstaOrange;
  UstaDescription := UstaLabel(40,90,620,70,13,False); UstaDescription.Font.Color := UstaMuted;
  UstaBody := UstaLabel(40,200,640,220,14,False);
  UstaDetail := UstaLabel(40,438,640,72,12,False); UstaDetail.Font.Color := UstaMuted;
  UstaProgress := TBitmapImage.Create(WizardForm); UstaProgress.Parent := UstaPanel;
  UstaBounds(UstaProgress,40,450,640,16);
  UstaBack := UstaButton(202,@UstaBackClick); UstaNext := UstaButton(366,@UstaNextClick);
  UstaCancel := UstaButton(530,@UstaCancelClick);
  WizardForm.OuterNotebook.Visible := False;
  WizardForm.Bevel.Visible := False;
  WizardForm.NextButton.Default := False; WizardForm.CancelButton.Cancel := False;
  // Inno's close guard requires a focusable native Cancel button. Keep it alive
  // behind our panel; hiding it would disable both Cancel and the title-bar X.
  WizardForm.BackButton.Visible := False; WizardForm.NextButton.Visible := False;
  WizardForm.CancelButton.Visible := True; WizardForm.CancelButton.TabStop := False;
  UstaPanel.BringToFront;
end;

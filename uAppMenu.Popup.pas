unit uAppMenu.Popup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Menus, Clipbrd, uMain,

  uExplorer, uMenu.Popup, uMessageBox;

procedure AppMenu_Popup_Init(F: TfrmMain);
procedure AppMenu_Popup_Copy(F: TfrmMain; Sender: TObject);
procedure AppMenu_Popup_OpenFileLocation(F: TfrmMain);
procedure AppMenu_Popup_ByteEncoding(F: TfrmMain; Sender: TObject);
procedure AppMenu_Popup_Update(F: TfrmMain; Sender: TObject; const Items: TPopupItems);

implementation

uses
  uAppController, uAppStatusBar, uAppStrings, uTextByteCount;

procedure AppMenu_Popup_Init(F: TfrmMain);
begin
  if (F = nil) or (F.sSkinManager = nil) then Exit;

  F.sSkinManager.SkinnedPopups := True;

  if F.pmCopy <> nil then
    F.sSkinManager.SkinableMenus.HookPopupMenu(F.pmCopy, True);
end;

procedure AppMenu_Popup_Copy(F: TfrmMain; Sender: TObject);
var
  Stats: string;
  StartPos: Integer;
  EndPos: Integer;
begin
  if F = nil then Exit;

  if (F.pmCopy <> nil) and (F.pmCopy.PopupComponent = F.stsbr) then
  begin
    AppStatusBar_Copy(F);
    Exit;
  end;

  if (F.pmCopy <> nil) and
     ((F.pmCopy.PopupComponent = F.scrStats) or (F.pmCopy.PopupComponent = F.lblStats)) then
  begin
    Stats := F.lblStats.Caption;
    Stats := Stats.Replace('<br><br>', sLineBreak + sLineBreak, [rfReplaceAll, rfIgnoreCase]);
    Stats := Stats.Replace('<br>', sLineBreak, [rfReplaceAll, rfIgnoreCase]);

    StartPos := Pos('<', Stats);
    while StartPos > 0 do
    begin
      EndPos := Pos('>', Stats, StartPos);
      if EndPos = 0 then
        Break;
      Delete(Stats, StartPos, EndPos - StartPos + 1);
      StartPos := Pos('<', Stats);
    end;

    Stats := Trim(Stats);
    if Stats = '' then
      Exit;

    try
      Clipboard.AsText := Stats;
    except
      on E: Exception do
        UI_MessageBox(F, Format(SClipboardCopyErrMsg, [E.Message]), MB_ICONWARNING or MB_OK);
    end;
    Exit;
  end;

  UI_Menu_Popup_Copy(Sender);
end;

procedure AppMenu_Popup_OpenFileLocation(F: TfrmMain);
begin
  if F = nil then Exit;
  if Trim(F.FCurrentFileName) = '' then Exit;

  UI_Explorer_SelectFile(F.FCurrentFileName);
end;

procedure AppMenu_Popup_ByteEncoding(F: TfrmMain; Sender: TObject);
begin
  if (F = nil) or not (Sender is TMenuItem) then
    Exit;

  if Sender = F.pmiEncodingCP949 then
    F.FByteEncoding := emCP949
  else if Sender = F.pmiEncodingUTF8 then
    F.FByteEncoding := emUTF8
  else
    Exit;

  AppController_UpdateStats(F);
end;

procedure AppMenu_Popup_Update(F: TfrmMain; Sender: TObject; const Items: TPopupItems);
var
  PopupComponent: TComponent;
  IsStatsPopup: Boolean;
  IsStatusBarPopup: Boolean;
  HasCurrentFile: Boolean;
begin
  UI_Menu_Popup_Update(Sender, Items);

  if F = nil then
    Exit;

  PopupComponent := nil;
  if Sender is TPopupMenu then
    PopupComponent := TPopupMenu(Sender).PopupComponent;

  IsStatsPopup := (PopupComponent = F.scrStats) or (PopupComponent = F.lblStats);
  IsStatusBarPopup := PopupComponent = F.stsbr;
  HasCurrentFile := Trim(F.FCurrentFileName) <> '';

  if Assigned(F.pmiCopySep) then
    F.pmiCopySep.Visible := IsStatsPopup or (IsStatusBarPopup and HasCurrentFile);
  if Assigned(F.pmiOpenFileLocation) then
    F.pmiOpenFileLocation.Visible := IsStatusBarPopup and HasCurrentFile;
  if Assigned(F.pmiByteEncoding) then
    F.pmiByteEncoding.Visible := IsStatsPopup;

  if IsStatsPopup then
  begin
    if Assigned(F.pmiEncodingCP949) then
      F.pmiEncodingCP949.Checked := F.FByteEncoding = emCP949;
    if Assigned(F.pmiEncodingUTF8) then
      F.pmiEncodingUTF8.Checked := F.FByteEncoding = emUTF8;
  end;

  if not Assigned(Items.Copy) then
    Exit;

  if PopupComponent = F.stsbr then
  begin
    Items.Copy.Enabled := Assigned(F.stsbr) and (F.stsbr.Panels.Count > 0) and
                          (Trim(F.stsbr.Panels[0].Text) <> '');
    if Assigned(F.pmiOpenFileLocation) then
      F.pmiOpenFileLocation.Enabled := HasCurrentFile;
  end;

  if IsStatsPopup then
    Items.Copy.Enabled := Assigned(F.lblStats) and
                          (Trim(F.lblStats.PlainCaption) <> '');
end;

end.

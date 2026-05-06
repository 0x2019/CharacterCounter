unit uAppMenu.Popup;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Menus, Clipbrd, uMain,

  uMenu.Popup;

procedure AppMenu_Popup_Init(F: TfrmMain);
procedure AppMenu_Popup_Copy(F: TfrmMain; Sender: TObject);
procedure AppMenu_Popup_Update(F: TfrmMain; Sender: TObject; const Items: TPopupItems);

implementation

uses
  uAppStatusBar, uAppStrings, uMessageBox;

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

procedure AppMenu_Popup_Update(F: TfrmMain; Sender: TObject; const Items: TPopupItems);
var
  PopupComponent: TComponent;
begin
  UI_Menu_Popup_Update(Sender, Items);

  if (F = nil) or not Assigned(Items.Copy) then
    Exit;

  PopupComponent := nil;
  if Sender is TPopupMenu then
    PopupComponent := TPopupMenu(Sender).PopupComponent;

  if PopupComponent = F.stsbr then
    Items.Copy.Enabled := Assigned(F.stsbr) and (F.stsbr.Panels.Count > 0) and
                          (Trim(F.stsbr.Panels[0].Text) <> '');

  if (PopupComponent = F.scrStats) or (PopupComponent = F.lblStats) then
    Items.Copy.Enabled := Assigned(F.lblStats) and
                          (Trim(F.lblStats.PlainCaption) <> '');
end;

end.

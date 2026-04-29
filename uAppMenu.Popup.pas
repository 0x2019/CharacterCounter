unit uAppMenu.Popup;

interface

uses
  System.SysUtils, System.Classes, Vcl.Menus, uMain,

  uMenu.Popup;

procedure AppMenu_Popup_Init(F: TfrmMain);
procedure AppMenu_Popup_Copy(F: TfrmMain; Sender: TObject);
procedure AppMenu_Popup_Update(F: TfrmMain; Sender: TObject; const Items: TPopupItems);

implementation

uses
  uAppStatusBar;

procedure AppMenu_Popup_Init(F: TfrmMain);
begin
  if (F = nil) or (F.sSkinManager = nil) then Exit;

  F.sSkinManager.SkinnedPopups := True;

  if F.pmCopy <> nil then
    F.sSkinManager.SkinableMenus.HookPopupMenu(F.pmCopy, True);
end;

procedure AppMenu_Popup_Copy(F: TfrmMain; Sender: TObject);
begin
  if F = nil then Exit;

  if (F.pmCopy <> nil) and (F.pmCopy.PopupComponent = F.stsbr) then
  begin
    AppStatusBar_Copy(F);
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
end;

end.

unit uAppController;

interface

uses
  Winapi.Windows, System.Math, System.SysUtils, Vcl.Forms, uMain,

  uForms, uMenu, uStatusBar;

procedure AppController_UpdateStats(F: TfrmMain);

procedure AppController_Init(F: TfrmMain);
procedure AppController_Load(F: TfrmMain);

procedure AppController_CP949Encoding(F: TfrmMain);

implementation

uses
  uAppMenu, uAppSettings, uAppStatusBar, uAppStats, uTextEncoding, uTextStats;

procedure AppController_UpdateStats(F: TfrmMain);
var
  Stats: TTextStats;
  InputText: string;
begin
  if F = nil then Exit;

  InputText := F.mmoText.Text;
  if InputText <> '' then
    if F.FLoadedFromFile and (not F.mmoText.Modified) and (not F.FHasTrailingNewLine) then
    begin
      if InputText.EndsWith(#13#10) then
        Delete(InputText, Length(InputText) - 1, 2)
      else if CharInSet(InputText[Length(InputText)], [#10, #13]) then
        Delete(InputText, Length(InputText), 1);
    end;

  Stats := GetTextStats(InputText);
  F.lblStats.Caption := ShowTextStats(Stats);
  if Assigned(F.miClearAll) then
    F.miClearAll.Enabled := Trim(InputText) <> '';
  if Assigned(F.miCopy) then
    F.miCopy.Enabled := Trim(InputText) <> '';
end;

procedure AppController_Init(F: TfrmMain);
begin
  if F = nil then Exit;
  if Assigned(F.miRecentSep) then F.miRecentSep.Tag := UI_RECENT_MENU_SEP_TAG;
  if Assigned(F.miClearHistory) then F.miClearHistory.Tag := UI_RECENT_MENU_CLEAR_TAG;
end;

procedure AppController_Load(F: TfrmMain);
begin
  if F = nil then Exit;

  AppSettings_Load(F);
  UI_SetAlwaysOnTop(F, F.miAlwaysOnTop.Checked);
  AppMenu_WordWrap(F);
  AppStatusBar_Init(F);
  if Assigned(F.stsbr) then
    UI_StatusBar_SetVisible(F, F.stsbr, F.miShowStatusBar.Checked, False);

  AppController_CP949Encoding(F);
end;

procedure AppController_CP949Encoding(F: TfrmMain);
begin
  if F = nil then Exit;
  SetEncoding(TEncodingMode(IfThen(F.FUseCP949, Ord(emCP949), Ord(emUTF8))));

  F.mmoTextChange(nil);
end;

end.

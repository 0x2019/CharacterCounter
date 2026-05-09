unit uAppController;

interface

uses
  System.SysUtils, Vcl.Forms, uMain,

  uForms, uMessageBox, uStatusBar;

procedure AppController_Init(F: TfrmMain);
function AppController_Exit(F: TfrmMain; const ConfirmExit: Boolean = False): Boolean;

procedure AppController_ByteEncoding(F: TfrmMain);
procedure AppController_UpdateStats(F: TfrmMain);

implementation

uses
  uAppMenu, uAppSettings, uAppStatusBar, uAppStats, uAppStrings, uAppTaskbar,
  uTextByteCount, uTextStats;

procedure AppController_Init(F: TfrmMain);
begin
  if F = nil then Exit;

  AppSettings_Load(F);
  AppTaskbar_Init(F);
  UI_SetAlwaysOnTop(F, F.miAlwaysOnTop.Checked);
  AppMenu_WordWrap(F);
  AppMenu_ShowMagnifier(F);
  AppStatusBar_Init(F);
  if Assigned(F.stsbr) then
    UI_StatusBar_SetVisible(F, F.stsbr, F.miShowStatusBar.Checked, False);
  AppTaskbar_Sync(F);

  AppController_ByteEncoding(F);
end;

function AppController_Exit(F: TfrmMain; const ConfirmExit: Boolean): Boolean;
begin
  Result := False;
  if F = nil then Exit;

  if ConfirmExit and F.FConfirmOnExit and not UI_ConfirmYesNo(F, SConfirmOnExitMsg) then
    Exit;

  Result := True;
end;

procedure AppController_ByteEncoding(F: TfrmMain);
begin
  if F = nil then Exit;
  SetEncoding(F.FByteEncoding);

  F.mmoTextChange(nil);
end;

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
  F.lblStats.Caption := ShowTextStats(Stats, F.FByteEncoding = emCP949);
  if Assigned(F.miClearAll) then
    F.miClearAll.Enabled := InputText <> '';
  if Assigned(F.miCopy) then
    F.miCopy.Enabled := F.mmoText.SelLength > 0;
end;

end.

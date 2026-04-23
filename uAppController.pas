unit uAppController;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Forms, Clipbrd, uMain;

procedure AppController_UpdateStats(F: TfrmMain);

procedure AppController_Clear(F: TfrmMain);
procedure AppController_Copy(F: TfrmMain);

procedure AppController_About(F: TfrmMain);
procedure AppController_Exit(F: TfrmMain);
procedure AppController_ToggleCP949Encoding(F: TfrmMain);

implementation

uses
  uForms, uMessageBox,
  uAppStats, uAppStrings, uEncoding, uTextStats;

procedure AppController_UpdateStats(F: TfrmMain);
var
  Stats: TTextStats;
begin
  if F = nil then Exit;

  Stats := GetTextStats(F.mmoText.Text);
  F.lblStats.Caption := ShowTextStats(Stats);
  F.btnClear.Enabled := Trim(F.mmoText.Text) <> '';
  F.btnCopy.Enabled  := Trim(F.mmoText.Text) <> '';
end;

procedure AppController_Clear(F: TfrmMain);
begin
  if F = nil then Exit;
  if F.mmoText.Text = '' then Exit;

  if UI_ConfirmYesNo(F, SClearConfirmMsg) then
  begin
    F.mmoText.Clear;
    F.mmoTextChange(nil);
  end;
end;

procedure AppController_Copy(F: TfrmMain);
begin
  if F = nil then Exit;
  if F.mmoText.Text = '' then Exit;
  Clipboard.AsText := F.mmoText.Text;
end;

procedure AppController_About(F: TfrmMain);
begin
  if F = nil then Exit;
  UI_MessageBox(F, Format(SAboutMsg, [APP_NAME, APP_VERSION, APP_RELEASE, APP_URL]), MB_ICONQUESTION or MB_OK);
end;

procedure AppController_Exit(F: TfrmMain);
begin
  if F = nil then Exit;
  F.Close;
end;

procedure AppController_ToggleCP949Encoding(F: TfrmMain);
begin
  if F = nil then Exit;
  if F.chkUseCP949.Checked then
    SetEncoding(emCP949)
  else
    SetEncoding(emUTF8);

  F.mmoTextChange(nil);
end;

end.

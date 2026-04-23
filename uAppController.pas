unit uAppController;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Forms, Clipbrd, uMain,

  uForms, uMessageBox;

procedure AppController_UpdateStats(F: TfrmMain);

procedure AppController_Clear(F: TfrmMain);
procedure AppController_Copy(F: TfrmMain);

procedure AppController_About(F: TfrmMain);
procedure AppController_Exit(F: TfrmMain);
procedure AppController_ToggleCP949Encoding(F: TfrmMain);

implementation

uses
  uAppStats, uAppStrings, uTextEncoding, uTextStats;

procedure AppController_UpdateStats(F: TfrmMain);
var
  Stats: TTextStats;
  InputText: string;
begin
  if F = nil then Exit;

  InputText := string.Join(sLineBreak, F.mmoText.Lines.ToStringArray);
  Stats := GetTextStats(InputText);
  F.lblStats.Caption := ShowTextStats(Stats);
  F.btnClear.Enabled := Trim(InputText) <> '';
  F.btnCopy.Enabled  := Trim(InputText) <> '';
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

unit uAppController;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Forms, Clipbrd, uMain;

procedure AppController_UpdateStats(AForm: TfrmMain);

procedure AppController_Clear(AForm: TfrmMain);
procedure AppController_Copy(AForm: TfrmMain);

procedure AppController_About(AForm: TfrmMain);
procedure AppController_Exit(AForm: TfrmMain);
procedure AppController_ToggleAlwaysOnTop(AForm: TfrmMain);
procedure AppController_ToggleCP949Encoding(AForm: TfrmMain);

implementation

uses
  uForms, uMessageBox,
  uAppStats, uAppStrings, uEncoding, uTextStats;

procedure AppController_UpdateStats(AForm: TfrmMain);
var
  Stats: TTextStats;
begin
  if AForm = nil then Exit;

  Stats := GetTextStats(AForm.mmoText.Text);
  AForm.lblStats.Caption := ShowTextStats(Stats);
  AForm.btnClear.Enabled := Trim(AForm.mmoText.Text) <> '';
  AForm.btnCopy.Enabled  := Trim(AForm.mmoText.Text) <> '';
end;

procedure AppController_Clear(AForm: TfrmMain);
begin
  if AForm = nil then Exit;
  if AForm.mmoText.Text = '' then Exit;

  if UI_ConfirmYesNo(AForm, SClearConfirmMsg) then
  begin
    AForm.mmoText.Clear;
    AForm.mmoTextChange(nil);
  end;
end;

procedure AppController_Copy(AForm: TfrmMain);
begin
  if AForm = nil then Exit;
  if AForm.mmoText.Text = '' then Exit;
  Clipboard.AsText := AForm.mmoText.Text;
end;

procedure AppController_About(AForm: TfrmMain);
begin
  if AForm = nil then Exit;
  UI_MessageBox(AForm, Format(SAboutMsg, [APP_NAME, APP_VERSION, APP_RELEASE, APP_URL]), MB_ICONQUESTION or MB_OK);
end;

procedure AppController_Exit(AForm: TfrmMain);
begin
  if AForm = nil then Exit;
  AForm.Close;
end;

procedure AppController_ToggleAlwaysOnTop(AForm: TfrmMain);
begin
  if AForm = nil then Exit;
  UI_SetAlwaysOnTop(AForm, AForm.chkAlwaysOnTop.Checked);
end;

procedure AppController_ToggleCP949Encoding(AForm: TfrmMain);
begin
  if AForm = nil then Exit;
  if AForm.chkUseCP949.Checked then
    SetEncoding(emCP949)
  else
    SetEncoding(emUTF8);

  AForm.mmoTextChange(nil);
end;

end.

unit uMain.UI;

interface

uses
  Winapi.Windows, System.SysUtils, Vcl.Forms, Clipbrd;

procedure UI_ClearConfirm(AForm: TObject);
procedure UI_CopyText(AForm: TObject);

procedure UI_UpdateStats(AForm: TObject);

implementation

uses
  uExt,
  uMain, uMain.UI.Stats;

procedure UI_ClearConfirm(AForm: TObject);
var
  F: TfrmMain;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  if F.mmoText.Text = '' then Exit;

  PostMessage(F.Handle, mbMessage, 100, 0);
  xMsgCaption := '';

  if Application.MessageBox('모든 입력 내용을 지우시겠습니까?',
                 xMsgCaption,
                 MB_ICONQUESTION or MB_YESNO or MB_DEFBUTTON2) <> IDYES then Exit;

  F.mmoText.Clear;
  F.mmoTextChange(nil);
end;

procedure UI_CopyText(AForm: TObject);
var
  F: TfrmMain;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  if F.mmoText.Text = '' then Exit;
  Clipboard.AsText := F.mmoText.Text;
end;

procedure UI_UpdateStats(AForm: TObject);
var
  F: TfrmMain;
  Stats: TTextStats;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  Stats := GetTextStats(F.mmoText.Text);
  F.lblStats.Caption := ShowTextStats(Stats);
  F.btnClear.Enabled := Trim(F.mmoText.Text) <> '';
  F.btnCopy.Enabled  := Trim(F.mmoText.Text) <> '';
end;

end.

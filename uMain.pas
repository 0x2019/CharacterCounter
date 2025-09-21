unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Character, sSkinProvider, sSkinManager,
  Vcl.StdCtrls, Vcl.Buttons, sBitBtn, System.ImageList, Vcl.ImgList,
  acAlphaImageList, sMemo, acAlphaHints, sCheckBox, sLabel, Vcl.ExtCtrls,
  sScrollBox;

const
  mbMessage = WM_USER + 1024;
  APP_NAME    = 'Character Counter';
  APP_VERSION = 'v1.0.0.0';
  APP_RELEASE = 'September 21, 2025';
  APP_URL     = 'https://github.com/0x2019/CharacterCounter';

type
  TfrmMain = class(TForm)
    sSkinManager: TsSkinManager;
    sSkinProvider: TsSkinProvider;
    mmoText: TsMemo;
    sCharImageList: TsCharImageList;
    btnExit: TsBitBtn;
    btnAbout: TsBitBtn;
    sAlphaHints: TsAlphaHints;
    chkAlwaysOnTop: TsCheckBox;
    btnClear: TsBitBtn;
    scrStats: TsScrollBox;
    lblStats: TsHTMLLabel;
    chkUseCP949: TsCheckBox;
    btnCopy: TsBitBtn;
    procedure btnAboutClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure chkAlwaysOnTopClick(Sender: TObject);
    procedure mmoTextChange(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure chkUseCP949Click(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
  private
    procedure ChangeMessageBoxPosition(var Msg: TMessage); message mbMessage;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  xMsgCaption: PWideChar;

implementation

{$R *.dfm}

uses
  uExt, uExt.Encoding,
  uMain.UI, uMain.UI.Settings, uMain.UI.Stats;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  PostMessage(Handle, mbMessage, 0, 0);
  xMsgCaption := '';

  Application.MessageBox(
  APP_NAME + ' ' + APP_VERSION + sLineBreak +
  'c0ded by 龍, written in Delphi.' + sLineBreak + sLineBreak +
  'Release Date: ' + APP_RELEASE + sLineBreak +
  'URL: ' + APP_URL, xMsgCaption, MB_ICONQUESTION);
end;

procedure TfrmMain.btnClearClick(Sender: TObject);
begin
  UI_ClearConfirm(Self);
end;

procedure TfrmMain.btnCopyClick(Sender: TObject);
begin
  UI_CopyText(Self);
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.ChangeMessageBoxPosition(var Msg: TMessage);
var
  mbHWND: LongWord;
  mbRect: TRect;
  x, y, w, h: Integer;
begin
  mbHWND := FindWindow(MAKEINTRESOURCE(WC_DIALOG), xMsgCaption);
  if (mbHWND <> 0) then begin
    GetWindowRect(mbHWND, mbRect);
  with mbRect do begin
    w := Right - Left;
    h := Bottom - Top;
  end;
  x := frmMain.Left + ((frmMain.Width - w) div 2);
  if x < 0 then
    x := 0
    else if x + w > Screen.Width then x := Screen.Width - w;
      y := frmMain.Top + ((frmMain.Height - h) div 2);
  if y < 0 then y := 0
    else if y + h > Screen.Height then y := Screen.Height - h;
    SetWindowPos(mbHWND, 0, x, y, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
  end;
end;

procedure TfrmMain.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  if Msg.Result = htClient then Msg.Result := htCaption;
end;

procedure TfrmMain.chkAlwaysOnTopClick(Sender: TObject);
begin
  if chkAlwaysOnTop.Checked then begin
    SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
  end else begin
    SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
  end;
end;

procedure TfrmMain.chkUseCP949Click(Sender: TObject);
begin
  if chkUseCP949.Checked then
    SetEncoding(emCP949)
  else
    SetEncoding(emUTF8);

  mmoTextChange(nil);
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettings(Self);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  LoadSettings(Self);

  mmoTextChange(nil);
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmMain.mmoTextChange(Sender: TObject);
begin
  UI_UpdateStats(Self);
end;

end.

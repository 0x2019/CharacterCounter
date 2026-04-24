unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Character, sSkinProvider, sSkinManager,
  Vcl.StdCtrls, Vcl.Buttons, sBitBtn, System.ImageList, Vcl.ImgList,
  acAlphaImageList, sMemo, acAlphaHints, sCheckBox, sLabel, Vcl.ExtCtrls,
  sScrollBox, Vcl.Menus, sDialogs,

  uForms, uMessageBox, uSettings;

type
  TfrmMain = class(TForm)
    sSkinManager: TsSkinManager;
    sSkinProvider: TsSkinProvider;
    mmoText: TsMemo;
    sCharImageList: TsCharImageList;
    btnExit: TsBitBtn;
    btnAbout: TsBitBtn;
    sAlphaHints: TsAlphaHints;
    OpenFileDlg: TsOpenDialog;
    MainMenu: TMainMenu;
    mnuFile: TMenuItem;
    miOpenFile: TMenuItem;
    mnuView: TMenuItem;
    miAlwaysOnTop: TMenuItem;
    miWordWrap: TMenuItem;
    btnClear: TsBitBtn;
    scrStats: TsScrollBox;
    lblStats: TsHTMLLabel;
    chkUseCP949: TsCheckBox;
    btnCopy: TsBitBtn;
    sMenuImageList: TsCharImageList;
    procedure btnAboutClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miAlwaysOnTopClick(Sender: TObject);
    procedure miWordWrapClick(Sender: TObject);
    procedure miOpenFileClick(Sender: TObject);
    procedure mmoTextChange(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure chkUseCP949Click(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
  private
    { Private declarations }
  public
    FLoadedFromFile: Boolean;
    FHasTrailingNewLine: Boolean;

    procedure ChangeMessageBoxPosition(var Msg: TMessage); message mbMessage;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  uAppController, uAppMenu, uAppSettings, uAppStats, uTextEncoding, uTextStats;

procedure TfrmMain.ChangeMessageBoxPosition(var Msg: TMessage);
begin
  UI_ChangeMessageBoxPosition(Self);
end;

procedure TfrmMain.btnAboutClick(Sender: TObject);
begin
  AppController_About(Self);
end;

procedure TfrmMain.btnClearClick(Sender: TObject);
begin
  AppController_Clear(Self);
end;

procedure TfrmMain.btnCopyClick(Sender: TObject);
begin
  AppController_Copy(Self);
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  AppController_Exit(Self);
end;

procedure TfrmMain.miAlwaysOnTopClick(Sender: TObject);
begin
  AppMenu_AlwaysOnTop(Self);
end;

procedure TfrmMain.miWordWrapClick(Sender: TObject);
begin
  AppMenu_WordWrap(Self);
end;

procedure TfrmMain.miOpenFileClick(Sender: TObject);
begin
  AppMenu_OpenFile(Self);
end;

procedure TfrmMain.chkUseCP949Click(Sender: TObject);
begin
  AppController_ToggleCP949Encoding(Self);
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  UI_SaveFormSettings(Self);
  AppSettings_Save(Self);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FLoadedFromFile := False;
  FHasTrailingNewLine := False;

  UI_SetMinConstraints(Self);
  UI_LoadFormSettings(Self);
  UI_EnableDragForm(Self);

  AppSettings_Load(Self);
  UI_SetAlwaysOnTop(Self, miAlwaysOnTop.Checked);
  AppMenu_WordWrap(Self);

  mmoTextChange(nil);
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    AppController_Exit(Self);
end;

procedure TfrmMain.mmoTextChange(Sender: TObject);
begin
  AppController_UpdateStats(Self);
end;

end.

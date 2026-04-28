unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, System.Character, sSkinProvider, sSkinManager,
  Vcl.StdCtrls, System.ImageList, Vcl.ImgList, acAlphaImageList, sMemo, acAlphaHints,
  sLabel, Vcl.ExtCtrls, sScrollBox, Vcl.Menus, sDialogs, ShellAPI,

  uFileUtils, uForms, uMenu, uMessageBox, uSettings;

type
  TfrmMain = class(TForm)
    sSkinManager: TsSkinManager;
    sSkinProvider: TsSkinProvider;
    mmoText: TsMemo;
    sAlphaHints: TsAlphaHints;
    OpenFileDlg: TsOpenDialog;
    MainMenu: TMainMenu;
    mnuFile: TMenuItem;
    miOpenFile: TMenuItem;
    miRecent: TMenuItem;
    miRecentSep: TMenuItem;
    miClearHistory: TMenuItem;
    miOptions: TMenuItem;
    mnuView: TMenuItem;
    miAlwaysOnTop: TMenuItem;
    miWordWrap: TMenuItem;
    scrStats: TsScrollBox;
    lblStats: TsHTMLLabel;
    sMenuImageList: TsCharImageList;
    mnuTool: TMenuItem;
    mnuEdit: TMenuItem;
    mnuHelp: TMenuItem;
    miAbout: TMenuItem;
    miCopy: TMenuItem;
    miClearClipboard: TMenuItem;
    miClearAll: TMenuItem;
    miExit: TMenuItem;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miAlwaysOnTopClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure miWordWrapClick(Sender: TObject);
    procedure miOpenFileClick(Sender: TObject);
    procedure miRecentItems(Sender: TObject);
    procedure miClearHistoryClick(Sender: TObject);
    procedure mmoTextChange(Sender: TObject);
    procedure miCopyClick(Sender: TObject);
    procedure miClearClipboardClick(Sender: TObject);
    procedure miClearAllClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
  private
    { Private declarations }
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure WMClipboardUpdate(var Msg: TMessage); message WM_CLIPBOARDUPDATE;
  public
    FLoadedFromFile: Boolean;
    FHasTrailingNewLine: Boolean;

// uOptions - Global
    FOptionsSection: Integer;

// uOptions - General
    FUseCP949: Boolean;
    FCloseOnEsc: Boolean;

    procedure ChangeMessageBoxPosition(var Msg: TMessage); message mbMessage;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  uAppController, uAppMenu, uAppSettings, uAppStats, uTextStats;

procedure TfrmMain.ChangeMessageBoxPosition(var Msg: TMessage);
begin
  UI_ChangeMessageBoxPosition(Self);
end;

procedure TfrmMain.WMDropFiles(var Msg: TWMDropFiles);
var
  Files: TStringList;
begin
  Files := TStringList.Create;
  try
    UI_GetDroppedFiles(Msg.Drop, Files);
    if (Files.Count > 0) and FileExists(Files[0]) then
      AppMenu_OpenFile(Self, ExpandFileName(Files[0]));
  finally
    Files.Free;
  end;
end;

procedure TfrmMain.WMClipboardUpdate(var Msg: TMessage);
begin
  AppMenu_Update(Self);
end;

procedure TfrmMain.miAboutClick(Sender: TObject);
begin
  AppMenu_About(Self);
end;

procedure TfrmMain.miCopyClick(Sender: TObject);
begin
  AppMenu_Copy(Self);
end;

procedure TfrmMain.miClearClipboardClick(Sender: TObject);
begin
  AppMenu_ClearClipboard(Self);
end;

procedure TfrmMain.miClearAllClick(Sender: TObject);
begin
  AppMenu_ClearAll(Self);
end;

procedure TfrmMain.miAlwaysOnTopClick(Sender: TObject);
begin
  AppMenu_AlwaysOnTop(Self);
end;

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  AppMenu_Exit(Self);
end;

procedure TfrmMain.miOptionsClick(Sender: TObject);
begin
  AppMenu_ShowOptions(Self);
end;

procedure TfrmMain.miWordWrapClick(Sender: TObject);
begin
  AppMenu_WordWrap(Self);
end;

procedure TfrmMain.miOpenFileClick(Sender: TObject);
begin
  AppMenu_OpenFile(Self);
end;

procedure TfrmMain.miRecentItems(Sender: TObject);
begin
  AppMenu_RecentItems(Self, Sender);
end;

procedure TfrmMain.miClearHistoryClick(Sender: TObject);
begin
  AppMenu_Recent_Clear(Self);
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RemoveClipboardFormatListener(Handle);
  DragAcceptFiles(Handle, False);
  UI_SaveFormSettings(Self);
  AppSettings_Save(Self);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FLoadedFromFile := False;
  FHasTrailingNewLine := False;
  FUseCP949 := False;
  FCloseOnEsc := False;
  FOptionsSection := 0;

  UI_SetMinConstraints(Self);
  UI_LoadFormSettings(Self);
  UI_EnableDragForm(Self);

  AppController_Init(Self);
  AppController_Load(Self);
  AppMenu_Update(Self);

  AddClipboardFormatListener(Handle);
  DragAcceptFiles(Handle, True);
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and FCloseOnEsc then
    AppMenu_Exit(Self);
end;

procedure TfrmMain.mmoTextChange(Sender: TObject);
begin
  AppController_UpdateStats(Self);
end;

end.

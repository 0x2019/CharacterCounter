unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.ComCtrls,
  Vcl.Controls, Vcl.Dialogs, Vcl.Forms, sSkinProvider, sSkinManager, Vcl.StdCtrls,
  System.ImageList, Vcl.ImgList, acAlphaImageList, sMemo, acAlphaHints, sLabel,
  Vcl.ExtCtrls, sScrollBox, Vcl.Menus, sDialogs, ShellAPI, sStatusBar, acMagn,
  uTextByteCount,

  uFileUtils, uForms, uMenu, uMenu.Popup, uMessageBox, uSettings;

type
  TfrmMain = class(TForm)
    sSkinManager: TsSkinManager;
    sSkinProvider: TsSkinProvider;
    mmoText: TsMemo;
    sAlphaHints: TsAlphaHints;
    sMagnifier: TsMagnifier;
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
    miShowStatusBar: TMenuItem;
    miShowMagnifier: TMenuItem;
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
    mnuFormat: TMenuItem;
    miFont: TMenuItem;
    FontDlg: TFontDialog;
    stsbr: TsStatusBar;
    pmCopy: TPopupMenu;
    pmiCopyOnSelect: TMenuItem;
    N1: TMenuItem;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miAlwaysOnTopClick(Sender: TObject);
    procedure miShowStatusBarClick(Sender: TObject);
    procedure miShowMagnifierClick(Sender: TObject);
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
    procedure miFontClick(Sender: TObject);
    procedure FontDlgShow(Sender: TObject);
    procedure mmoTextClick(Sender: TObject);
    procedure mmoTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mmoTextMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure mmoTextMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pmiCopyOnSelectClick(Sender: TObject);
    procedure pmCopyPopup(Sender: TObject);
  private
    procedure WMActivateApp(var Msg: TWMActivateApp); message WM_ACTIVATEAPP;
    procedure WMClipboardUpdate(var Msg: TMessage); message WM_CLIPBOARDUPDATE;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  public
    FLoadedFromFile: Boolean;
    FHasTrailingNewLine: Boolean;
    FMagnifierLeft: Integer;
    FMagnifierTop: Integer;

// uOptions - Global
    FOptionsSection: Integer;

// uOptions - General
    FByteEncoding: TEncodingMode;
    FCloseOnEsc: Boolean;

    procedure ChangeMessageBoxPosition(var Msg: TMessage); message mbMessage;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  uAppController, uAppMenu, uAppMenu.Popup, uAppSettings, uAppStatusBar,
  uAppStats, uAppTaskbar, uTextStats;

procedure TfrmMain.ChangeMessageBoxPosition(var Msg: TMessage);
begin
  UI_ChangeMessageBoxPosition(Self);
end;

procedure TfrmMain.WMActivateApp(var Msg: TWMActivateApp);
begin
  inherited;

  if Msg.Active then
    AppTaskbar_Sync(Self);
end;

procedure TfrmMain.WMClipboardUpdate(var Msg: TMessage);
begin
  AppMenu_UpdateClipboard(Self);
end;

procedure TfrmMain.WMCopyData(var Msg: TWMCopyData);
var
  FilePath: string;
begin
  Msg.Result := 0;

  if (Msg.CopyDataStruct = nil) or (Msg.CopyDataStruct.cbData = 0) then
    Exit;

  FilePath := PChar(Msg.CopyDataStruct.lpData);
  if not FileExists(FilePath) then
    Exit;

  AppMenu_OpenFile(Self, FilePath);
  Msg.Result := 1;
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

procedure TfrmMain.miShowStatusBarClick(Sender: TObject);
begin
  AppMenu_ShowStatusBar(Self);
end;

procedure TfrmMain.miShowMagnifierClick(Sender: TObject);
begin
  AppMenu_ShowMagnifier(Self);
end;

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  AppMenu_Exit(Self);
end;

procedure TfrmMain.miFontClick(Sender: TObject);
begin
  AppMenu_SetFont(Self);
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
  FMagnifierLeft := -1;
  FMagnifierTop := -1;
  FByteEncoding := emUTF8;
  FCloseOnEsc := False;
  FOptionsSection := 0;

  UI_SetMinConstraints(Self);
  UI_LoadFormSettings(Self);
  UI_EnableDragForm(Self);

  AppMenu_Init(Self);
  AppMenu_UpdateClipboard(Self);
  AppController_Init(Self);
  AppStatusBar_UpdateCaret(Self);

  AddClipboardFormatListener(Handle);
  DragAcceptFiles(Handle, True);
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) and FCloseOnEsc then
    AppMenu_Exit(Self);
end;

procedure TfrmMain.FontDlgShow(Sender: TObject);
begin
  UI_CenterDialog(Self, FontDlg.Handle);
end;

procedure TfrmMain.mmoTextChange(Sender: TObject);
begin
  AppController_UpdateStats(Self);
  AppStatusBar_UpdateCaret(Self);
end;

procedure TfrmMain.mmoTextClick(Sender: TObject);
begin
  if Assigned(miCopy) then
    miCopy.Enabled := mmoText.SelLength > 0;
  AppStatusBar_UpdateCaret(Self);
end;

procedure TfrmMain.mmoTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(miCopy) then
    miCopy.Enabled := mmoText.SelLength > 0;
  AppStatusBar_UpdateCaret(Self);
end;

procedure TfrmMain.mmoTextMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    if Assigned(miCopy) then
      miCopy.Enabled := mmoText.SelLength > 0;
    AppStatusBar_UpdateCaret(Self);
  end;
end;

procedure TfrmMain.mmoTextMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(miCopy) then
    miCopy.Enabled := mmoText.SelLength > 0;
  AppStatusBar_UpdateCaret(Self);
end;

procedure TfrmMain.pmiCopyOnSelectClick(Sender: TObject);
begin
  AppMenu_Popup_Copy(Self, Sender);
end;

procedure TfrmMain.pmCopyPopup(Sender: TObject);
var
  PopupItems: TPopupItems;
begin
  PopupItems := Default(TPopupItems);
  PopupItems.Copy := pmiCopyOnSelect;
  AppMenu_Popup_Update(Self, Sender, PopupItems);
end;

end.

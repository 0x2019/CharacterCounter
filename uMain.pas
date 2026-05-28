unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.ComCtrls,
  Vcl.Controls, Vcl.Dialogs, Vcl.Forms, Vcl.AppEvnts, sSkinProvider, sSkinManager,
  Vcl.StdCtrls, System.ImageList, Vcl.ImgList, acAlphaImageList, sMemo, acAlphaHints,
  sLabel, Vcl.ExtCtrls, sScrollBox, Vcl.Menus, ShellAPI, sStatusBar, acMagn,
  uTextByteCount,

  uFileDialog, uFileUtils, uForms, uMenu, uMenu.Popup, uMessageBox, uMutex, uOSUtils,
  uSettings, uTextEncoding;

type
  TfrmMain = class(TForm)
    sSkinManager: TsSkinManager;
    sSkinProvider: TsSkinProvider;
    mmoText: TsMemo;
    sAlphaHints: TsAlphaHints;
    sMagnifier: TsMagnifier;
    OpenFileDlg: TFileOpenDialog;
    SaveFileDlg: TFileSaveDialog;
    MainMenu: TMainMenu;
    mnuFile: TMenuItem;
    miOpenFile: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
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
    miFind: TMenuItem;
    miFindNext: TMenuItem;
    miFindPrev: TMenuItem;
    miCopy: TMenuItem;
    miClearClipboard: TMenuItem;
    miClearAll: TMenuItem;
    miExit: TMenuItem;
    mnuFormat: TMenuItem;
    miFont: TMenuItem;
    FontDlg: TFontDialog;
    FindDlg: TFindDialog;
    stsbr: TsStatusBar;
    pmCopy: TPopupMenu;
    pmiCopyOnSelect: TMenuItem;
    pmiCopySep: TMenuItem;
    pmiByteEncoding: TMenuItem;
    pmiEncodingCP949: TMenuItem;
    pmiEncodingUTF8: TMenuItem;
    ApplicationEvents: TApplicationEvents;
    N3: TMenuItem;
    N1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    miCloseFile: TMenuItem;
    N6: TMenuItem;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miAlwaysOnTopClick(Sender: TObject);
    procedure miShowStatusBarClick(Sender: TObject);
    procedure miShowMagnifierClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure miWordWrapClick(Sender: TObject);
    procedure miOpenFileClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure miSaveAsClick(Sender: TObject);
    procedure miCloseFileClick(Sender: TObject);
    procedure miRecentItems(Sender: TObject);
    procedure miClearHistoryClick(Sender: TObject);
    procedure mmoTextChange(Sender: TObject);
    procedure miCopyClick(Sender: TObject);
    procedure miClearClipboardClick(Sender: TObject);
    procedure miClearAllClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miFindClick(Sender: TObject);
    procedure miFindNextClick(Sender: TObject);
    procedure miFindPrevClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miFontClick(Sender: TObject);
    procedure FontDlgShow(Sender: TObject);
    procedure FindDlgShow(Sender: TObject);
    procedure mmoTextClick(Sender: TObject);
    procedure mmoTextKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mmoTextMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure mmoTextMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pmiCopyOnSelectClick(Sender: TObject);
    procedure pmiByteEncodingClick(Sender: TObject);
    procedure pmCopyPopup(Sender: TObject);
    procedure FindDlgFind(Sender: TObject);
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure SaveFileDlgExecute(Sender: TObject);
    procedure SaveFileDlgFileOkClick(Sender: TObject; var CanClose: Boolean);
    procedure OpenFileDlgExecute(Sender: TObject);
    procedure OpenFileDlgFileOkClick(Sender: TObject; var CanClose: Boolean);
  private
    procedure WMActivateApp(var Msg: TWMActivateApp); message WM_ACTIVATEAPP;
    procedure WMShowMe(var Message: TMessage); message WM_SHOWME;
    procedure WMClipboardUpdate(var Msg: TMessage); message WM_CLIPBOARDUPDATE;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
  public

// File
    FExit: Boolean;
    FLoadedFromFile: Boolean;
    FHasTrailingNewLine: Boolean;
    FCurrentFileName: string;
    FOpenEncoding: TOpenEncoding;
    FSaveEncoding: TSaveEncoding;

// Edit
    FFindText: string;
    FFindOptions: TFindOptions;

// View
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

procedure TfrmMain.AppMessage(var Msg: TMsg; var Handled: Boolean);
begin
  if not Assigned(FindDlg) then Exit;
  if FindDlg.Handle = 0 then Exit;
  if not IsWindowVisible(FindDlg.Handle) then Exit;
  if Msg.message <> WM_KEYDOWN then Exit;
  if (Msg.hwnd <> FindDlg.Handle) and (not IsChild(FindDlg.Handle, Msg.hwnd)) then Exit;

  if Msg.wParam = VK_RETURN then
  begin
    PostMessage(FindDlg.Handle, WM_COMMAND, IDOK, 0);
    Handled := True;
  end
  else if Msg.wParam = VK_ESCAPE then
  begin
    PostMessage(FindDlg.Handle, WM_COMMAND, IDCANCEL, 0);
    Handled := True;
  end;
end;

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

procedure TfrmMain.WMShowMe(var Message: TMessage);
var
  ForegroundWnd: HWND;
  ForegroundThreadID: Cardinal;
  CurrentThreadID: Cardinal;
  Attached: Boolean;
begin
  if IsIconic(Handle) then
    SendMessage(Handle, WM_SYSCOMMAND, SC_RESTORE, 0)
  else
    ShowWindow(Handle, SW_SHOW);

  ForegroundWnd := GetForegroundWindow;
  ForegroundThreadID := 0;
  if ForegroundWnd <> 0 then
    ForegroundThreadID := GetWindowThreadProcessId(ForegroundWnd, nil);

  CurrentThreadID := GetWindowThreadProcessId(Handle, nil);
  Attached := (ForegroundThreadID <> 0) and (ForegroundThreadID <> CurrentThreadID);
  if Attached then
    AttachThreadInput(ForegroundThreadID, CurrentThreadID, True);
  try
    BringWindowToTop(Handle);
    SetForegroundWindow(Handle);
    SetActiveWindow(Handle);
  finally
    if Attached then
      AttachThreadInput(ForegroundThreadID, CurrentThreadID, False);
  end;
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

  if mmoText.CanFocus then
    mmoText.SetFocus;

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
    begin
      AppMenu_OpenFile(Self, ExpandFileName(Files[0]));

      SetForegroundWindow(Handle);

      if mmoText.CanFocus then
        mmoText.SetFocus;
    end;
  finally
    Files.Free;
  end;
end;

procedure TfrmMain.miAboutClick(Sender: TObject);
begin
  AppMenu_About(Self);
end;

procedure TfrmMain.miFindClick(Sender: TObject);
begin
  AppMenu_Find(Self);
end;

procedure TfrmMain.miFindNextClick(Sender: TObject);
begin
  AppMenu_FindNext(Self, not (frDown in FFindOptions), True);
end;

procedure TfrmMain.miFindPrevClick(Sender: TObject);
begin
  AppMenu_FindNext(Self, True, True);
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

procedure TfrmMain.miSaveClick(Sender: TObject);
begin
  AppMenu_Save(Self);
end;

procedure TfrmMain.miSaveAsClick(Sender: TObject);
begin
  AppMenu_SaveAs(Self);
end;

procedure TfrmMain.miCloseFileClick(Sender: TObject);
begin
  AppMenu_CloseFile(Self);
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
  if not FExit then
    if not AppController_Exit(Self) then
    begin
      Action := caNone;
      Exit;
    end
    else
      FExit := True;

  RemoveClipboardFormatListener(Handle);
  DragAcceptFiles(Handle, False);
  UI_SaveFormSettings(Self);
  AppSettings_Save(Self);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FExit := False;
  FLoadedFromFile := False;
  FHasTrailingNewLine := False;
  FCurrentFileName := '';
  FOpenEncoding := oeAutoDetect;
  FSaveEncoding := seUTF8;

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
  if Assigned(ApplicationEvents) then
    ApplicationEvents.OnMessage := AppMessage;

  AllowUIPIMessages(Handle, WM_SHOWME);
  AddClipboardFormatListener(Handle);
  DragAcceptFiles(Handle, True);
end;

procedure TfrmMain.SaveFileDlgExecute(Sender: TObject);
begin
  if Sender is TFileSaveDialog then
    UI_Save_SetEncoding(TFileSaveDialog(Sender), FSaveEncoding);
end;

procedure TfrmMain.OpenFileDlgExecute(Sender: TObject);
begin
  if Sender is TFileOpenDialog then
    UI_Open_SetEncoding(TFileOpenDialog(Sender), FOpenEncoding);
end;

procedure TfrmMain.OpenFileDlgFileOkClick(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  if Sender is TFileOpenDialog then
    UI_Open_GetEncoding(TFileOpenDialog(Sender), FOpenEncoding);
end;

procedure TfrmMain.SaveFileDlgFileOkClick(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := True;
  if Sender is TFileSaveDialog then
    UI_Save_GetEncoding(TFileSaveDialog(Sender), FSaveEncoding);
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F3 then
  begin
    AppMenu_FindNext(Self, ssShift in Shift);
    Key := 0;
    Exit;
  end;

  if (Key = VK_ESCAPE) and FCloseOnEsc then
    AppMenu_Exit(Self);
end;

procedure TfrmMain.FontDlgShow(Sender: TObject);
begin
  UI_CenterDialog(Self, FontDlg.Handle);
end;

procedure TfrmMain.FindDlgShow(Sender: TObject);
begin
  UI_CenterDialog(Self, FindDlg.Handle);
  SendMessage(FindDlg.Handle, DM_SETDEFID, IDOK, 0);
end;

procedure TfrmMain.mmoTextChange(Sender: TObject);
begin
  if (FCurrentFileName = '') and (mmoText.Text = '') then
    mmoText.Modified := False;

  if Assigned(miFind) then
    miFind.Enabled := mmoText.Text <> '';
  if Assigned(miFindNext) and (mmoText.Text = '') then
    miFindNext.Enabled := False;
  if Assigned(miFindPrev) and (mmoText.Text = '') then
    miFindPrev.Enabled := False;
  AppMenu_UpdateCaption(Self);
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

procedure TfrmMain.pmiByteEncodingClick(Sender: TObject);
begin
  AppMenu_Popup_ByteEncoding(Self, Sender);
end;

procedure TfrmMain.pmCopyPopup(Sender: TObject);
var
  PopupItems: TPopupItems;
begin
  PopupItems := Default(TPopupItems);
  PopupItems.Copy := pmiCopyOnSelect;
  AppMenu_Popup_Update(Self, Sender, PopupItems);
end;

procedure TfrmMain.FindDlgFind(Sender: TObject);
begin
  if not Assigned(FindDlg) then
    Exit;

  FFindText := FindDlg.FindText;
  FFindOptions := FindDlg.Options;
  if Assigned(miFindNext) then
    miFindNext.Enabled := Trim(FFindText) <> '';
  if Assigned(miFindPrev) then
    miFindPrev.Enabled := Trim(FFindText) <> '';

  AppMenu_FindNext(Self, not (frDown in FFindOptions));
end;

end.

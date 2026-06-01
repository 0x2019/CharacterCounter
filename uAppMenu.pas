unit uAppMenu;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.IOUtils,
  Vcl.Forms, Vcl.StdCtrls, Vcl.Menus, Vcl.Dialogs, Clipbrd, uMain,

  uFileDialog, uFileUtils, uForms, uMenu, uMessageBox, uStatusBar, uTextDecoding, uTextEncoding;

// Global
procedure AppMenu_Init(F: TfrmMain);
procedure AppMenu_UpdateCaption(F: TfrmMain);
procedure AppMenu_UpdateClipboard(F: TfrmMain);
procedure AppMenu_UpdateFile(F: TfrmMain; const FileName: string);

// File
procedure AppMenu_OpenFile(F: TfrmMain; FileName: string = '');
function AppMenu_Save(F: TfrmMain): Boolean;
function AppMenu_SaveAs(F: TfrmMain): Boolean;

procedure AppMenu_RecentItems(F: TfrmMain; Sender: TObject);
procedure AppMenu_Recent_Add(F: TfrmMain; const FilePath: string);
procedure AppMenu_Recent_Clear(F: TfrmMain);

procedure AppMenu_CloseFile(F: TfrmMain);
procedure AppMenu_Exit(F: TfrmMain);

// Edit
procedure AppMenu_Find(F: TfrmMain);
procedure AppMenu_FindNext(F: TfrmMain; SearchBackward: Boolean = False; Focus: Boolean = False);
procedure AppMenu_Copy(F: TfrmMain);
procedure AppMenu_ClearAll(F: TfrmMain);

// View
procedure AppMenu_AlwaysOnTop(F: TfrmMain);
procedure AppMenu_ShowMagnifier(F: TfrmMain);
procedure AppMenu_ShowStatusBar(F: TfrmMain);

// Format
procedure AppMenu_WordWrap(F: TfrmMain);
procedure AppMenu_SetFont(F: TfrmMain);

// Tool
procedure AppMenu_ClearClipboard(F: TfrmMain);
procedure AppMenu_ShowOptions(F: TfrmMain);

// Help
procedure AppMenu_About(F: TfrmMain);

implementation

uses
  uAbout,
  uAppController, uAppMenu.Popup, uAppStatusBar, uAppStrings, uAppTaskbar, uOptions,
  uTextByteCount, uTextSearch;

procedure AppMenu_Init(F: TfrmMain);
begin
  if F = nil then Exit;

  F.FFindText := '';
  F.FFindOptions := [frDown];
  if Assigned(F.mmoText) then F.mmoText.HideSelection := False;
  if Assigned(F.miFind) and Assigned(F.mmoText) then
    F.miFind.Enabled := F.mmoText.Text <> '';
  if Assigned(F.miFindNext) then F.miFindNext.Enabled := False;
  if Assigned(F.miFindPrev) then F.miFindPrev.Enabled := False;

  if Assigned(F.miRecentSep) then F.miRecentSep.Tag := UI_RECENT_MENU_SEP_TAG;
  if Assigned(F.miClearHistory) then F.miClearHistory.Tag := UI_RECENT_MENU_CLEAR_TAG;

  if Assigned(F.miCloseFile) then F.miCloseFile.Enabled := F.FCurrentFileName <> '';

  AppMenu_UpdateCaption(F);
  AppMenu_Popup_Init(F);
end;

procedure AppMenu_UpdateCaption(F: TfrmMain);
var
  Title: string;
begin
  if F = nil then Exit;
  if F.FCurrentFileName <> '' then
    Title := ExtractFileName(F.FCurrentFileName)
  else
    Title := SUntitled;

  if Assigned(F.mmoText) and F.mmoText.Modified then
    Title := '*' + Title;

  Title := Title + ' - ' + APP_NAME;

  try
    F.Caption := Title;
  except
    F.Caption := APP_NAME;
  end;

  if Assigned(F.sSkinProvider) then
  begin
    try
      F.sSkinProvider.AddedTitle.Text := Title;
    except
      try F.sSkinProvider.AddedTitle.Text := APP_NAME; except end;
    end;
  end;
end;

procedure AppMenu_UpdateClipboard(F: TfrmMain);
begin
  if F = nil then Exit;
  UI_Menu_UpdateClipboard(F.miClearClipboard);
end;

procedure AppMenu_UpdateFile(F: TfrmMain; const FileName: string);
var
  SourceText: string;
begin
  if F = nil then Exit;
  if FileName = '' then Exit;
  if not Assigned(F.mmoText) then Exit;

  F.FCurrentFileName := FileName;
  F.FLoadedFromFile := True;
  F.FHasTrailingNewLine := (F.mmoText.Text <> '') and
    CharInSet(F.mmoText.Text[Length(F.mmoText.Text)], [#10, #13]);

  if Assigned(F.miCloseFile) then F.miCloseFile.Enabled := True;

  AppMenu_UpdateCaption(F);
  AppMenu_Recent_Add(F, FileName);

  SourceText := F.mmoText.Text;
  AppStatusBar_Update(F, FileName, SourceText);
end;

procedure AppMenu_OpenFile(F: TfrmMain; FileName: string);
var
  InputText: string;
  Encoding: TOpenEncoding;
begin
  if F = nil then Exit;
  Encoding := oeAutoDetect;

  if FileName = '' then
  begin
    if not Assigned(F.OpenFileDlg) then Exit;
    if not UI_OpenFileDialog(F.OpenFileDlg, F.Handle, FileName) then Exit;
    Encoding := F.FOpenEncoding;
  end;

  FileName := UI_ResolveFileShortcut(FileName);
  if FileName = '' then Exit;

  if not AppController_Exit(F) then
    Exit;

  if Assigned(F.FindDlg) and (F.FindDlg.Handle <> 0) and IsWindowVisible(F.FindDlg.Handle) then
    PostMessage(F.FindDlg.Handle, WM_CLOSE, 0, 0);

  try
    if not DecodeFile(FileName, Encoding, InputText) then
    begin
      UI_MessageBox(F, SUnsupportedFileMsg, MB_ICONERROR or MB_OK);
      Exit;
    end;

    F.FSaveLineBreak := GetSaveLineBreak(InputText);
    InputText := ConvertToCRLF(InputText);

    F.mmoText.Text := InputText;
    F.mmoText.Modified := False;
    F.mmoText.SelStart := 0;
    F.mmoText.SelLength := 0;

    try
      F.mmoTextChange(nil);
    except

    end;

    if Encoding = oeAutoDetect then
      UI_DetectEncoding(FileName, F.FSaveEncoding)
    else
      F.FSaveEncoding := TSaveEncoding(Pred(Ord(Encoding)));
    AppMenu_UpdateFile(F, FileName);
  except
    on E: Exception do
      UI_MessageBox(F, Format(SOpenFileErrorMsg, [E.Message]), MB_ICONERROR or MB_OK);
  end;
end;

function AppMenu_SaveAs(F: TfrmMain): Boolean;
var
  FileName: string;
begin
  Result := False;
  if F = nil then Exit;
  if not Assigned(F.SaveFileDlg) then Exit;
  if not Assigned(F.mmoText) then Exit;
  if not UI_SaveFileDialog(F.SaveFileDlg, F.Handle, F.FCurrentFileName, FileName) then Exit;
  if FileName = '' then Exit;

  try
    TFile.WriteAllBytes(FileName, GetEncodedBytes(ConvertLineBreak(F.mmoText.Text, F.FSaveLineBreak), F.FSaveEncoding));
    F.mmoText.Modified := False;
    AppMenu_UpdateFile(F, FileName);
    Result := True;
  except
    on E: Exception do
      UI_MessageBox(F, Format(SSaveFileErrorMsg, [E.Message]), MB_ICONERROR or MB_OK);
  end;
end;

function AppMenu_Save(F: TfrmMain): Boolean;
begin
  Result := False;
  if F = nil then Exit;
  if not Assigned(F.mmoText) then Exit;

  if F.FCurrentFileName = '' then
  begin
    Result := AppMenu_SaveAs(F);
    Exit;
  end;

  try
    TFile.WriteAllBytes(F.FCurrentFileName, GetEncodedBytes(ConvertLineBreak(F.mmoText.Text, F.FSaveLineBreak), F.FSaveEncoding));
    F.mmoText.Modified := False;
    AppMenu_UpdateFile(F, F.FCurrentFileName);
    Result := True;
  except
    on E: Exception do
      UI_MessageBox(F, Format(SSaveFileErrorMsg, [E.Message]), MB_ICONERROR or MB_OK);
  end;
end;

procedure AppMenu_RecentItems(F: TfrmMain; Sender: TObject);
var
  MI: TMenuItem;
begin
  if F = nil then Exit;
  if not (Sender is TMenuItem) then Exit;

  MI := TMenuItem(Sender);
  if Assigned(F.miClearHistory) and (MI = F.miClearHistory) then
  begin
    AppMenu_Recent_Clear(F);
    Exit;
  end;

  AppMenu_OpenFile(F, MI.Hint);
end;

procedure AppMenu_Recent_Add(F: TfrmMain; const FilePath: string);
begin
  if F = nil then Exit;
  if not Assigned(F.miRecent) then Exit;
  if Trim(FilePath) = '' then Exit;

  UI_Menu_Recent_Add(F.miRecent, FilePath, ExtractFileName(FilePath), F.miRecentItems);
  AppTaskbar_Sync(F);
end;

procedure AppMenu_Recent_Clear(F: TfrmMain);
begin
  if F = nil then Exit;
  if not Assigned(F.miRecent) then Exit;
  UI_Menu_Recent_Clear(F.miRecent);
  AppTaskbar_Sync(F);
end;

procedure AppMenu_CloseFile(F: TfrmMain);
begin
  if F = nil then Exit;
  if not Assigned(F.mmoText) then Exit;

  if not AppController_Exit(F) then
    Exit;

  F.FLoadedFromFile := False;
  F.FHasTrailingNewLine := False;
  F.FCurrentFileName := '';
  F.FOpenEncoding := oeAutoDetect;
  F.FSaveEncoding := seUTF8;
  F.FSaveLineBreak := slbCRLF;
  F.FFindText := '';
  F.FFindOptions := [frDown];

  if Assigned(F.FindDlg) and (F.FindDlg.Handle <> 0) and IsWindowVisible(F.FindDlg.Handle) then
    PostMessage(F.FindDlg.Handle, WM_CLOSE, 0, 0);

  if Assigned(F.miCloseFile) then F.miCloseFile.Enabled := False;

  F.mmoText.Clear;
  F.mmoText.Modified := False;
  F.mmoText.SelStart := 0;
  F.mmoText.SelLength := 0;
  if Assigned(F.miFind) then F.miFind.Enabled := False;
  if Assigned(F.miFindNext) then F.miFindNext.Enabled := False;
  if Assigned(F.miFindPrev) then F.miFindPrev.Enabled := False;

  AppMenu_UpdateCaption(F);
  AppController_UpdateStats(F);
  AppStatusBar_Init(F);
  AppStatusBar_UpdateCaret(F);
end;

procedure AppMenu_Exit(F: TfrmMain);
begin
  if F = nil then Exit;
  F.Close;
end;

procedure AppMenu_Find(F: TfrmMain);
begin
  if F = nil then Exit;
  if not Assigned(F.FindDlg) then Exit;
  if not Assigned(F.mmoText) then Exit;

  if F.mmoText.SelLength > 0 then
    F.FindDlg.FindText := F.mmoText.SelText
  else
    F.FindDlg.FindText := F.FFindText;

  F.FindDlg.Options := F.FFindOptions;

  SendMessage(F.mmoText.Handle, WM_SETREDRAW, 0, 0);
  try
    F.FindDlg.Execute;
  finally
    SendMessage(F.mmoText.Handle, WM_SETREDRAW, 1, 0);
    F.mmoText.Invalidate;
  end;
end;

procedure AppMenu_FindNext(F: TfrmMain; SearchBackward: Boolean; Focus: Boolean);
var
  SourceText: string;
  SearchText: string;
  MatchCase: Boolean;
  WholeWord: Boolean;
  StartIndex: Integer;
  FoundIndex: Integer;
begin
  if F = nil then Exit;
  if not Assigned(F.mmoText) then Exit;

  SearchText := Trim(F.FFindText);
  if SearchText = '' then
  begin
    AppMenu_Find(F);
    Exit;
  end;

  if Assigned(F.miFindNext) then
    F.miFindNext.Enabled := True;
  if Assigned(F.miFindPrev) then
    F.miFindPrev.Enabled := True;

  SourceText := F.mmoText.Text;
  MatchCase := frMatchCase in F.FFindOptions;
  WholeWord := frWholeWord in F.FFindOptions;

  if SearchBackward then
  begin
    StartIndex := F.mmoText.SelStart;
    FoundIndex := FindBackward(SourceText, SearchText, StartIndex, MatchCase, WholeWord);
  end
  else
  begin
    StartIndex := F.mmoText.SelStart + F.mmoText.SelLength + 1;
    FoundIndex := FindForward(SourceText, SearchText, StartIndex, MatchCase, WholeWord);
  end;

  if FoundIndex > 0 then
  begin
    if Focus and Assigned(F.mmoText) and not F.mmoText.Focused then
      F.mmoText.SetFocus;
    F.mmoText.SelStart := FoundIndex - 1;
    F.mmoText.SelLength := Length(SearchText);
    SendMessage(F.mmoText.Handle, EM_SCROLLCARET, 0, 0);
    Exit;
  end;

  if Assigned(F.FindDlg) and (F.FindDlg.Handle <> 0) and IsWindowVisible(F.FindDlg.Handle) then
    UI_MessageBox(F.FindDlg.Handle, Format(STextNotFoundMsg, [SearchText]), MB_ICONINFORMATION or MB_OK, '', WRAP_MAX_CHARS)
  else
    UI_MessageBox(F, Format(STextNotFoundMsg, [SearchText]), MB_ICONINFORMATION or MB_OK, '', WRAP_MAX_CHARS);
end;

procedure AppMenu_Copy(F: TfrmMain);
begin
  if F = nil then Exit;
  if F.mmoText.SelLength <= 0 then Exit;

  try
    Clipboard.AsText := F.mmoText.SelText;
  except
    on E: Exception do
      UI_MessageBox(F, Format(SClipboardCopyErrMsg, [E.Message]), MB_ICONWARNING or MB_OK);
  end;
end;

procedure AppMenu_ClearAll(F: TfrmMain);
begin
  if F = nil then Exit;
  if F.mmoText.Text = '' then Exit;

  if UI_ConfirmYesNo(F, SClearConfirmMsg) then
  begin
    F.FLoadedFromFile := False;
    F.FHasTrailingNewLine := False;
    F.mmoText.Clear;
    F.mmoTextChange(nil);
  end;
end;

procedure AppMenu_AlwaysOnTop(F: TfrmMain);
begin
  if F = nil then Exit;
  F.miAlwaysOnTop.Checked := not F.miAlwaysOnTop.Checked;
  UI_SetAlwaysOnTop(F, F.miAlwaysOnTop.Checked);
end;

procedure AppMenu_ShowMagnifier(F: TfrmMain);
var
  MagnifierPos: TPoint;
begin
  if F = nil then Exit;
  if not Assigned(F.sMagnifier) then Exit;
  if not Assigned(F.miShowMagnifier) then Exit;

  if F.miShowMagnifier.Checked then
    F.sMagnifier.Execute(F.FMagnifierLeft, F.FMagnifierTop)
  else
  begin
    if F.sMagnifier.IsVisible then
    begin
      MagnifierPos := F.sMagnifier.GetPosition;
      F.FMagnifierLeft := MagnifierPos.X;
      F.FMagnifierTop := MagnifierPos.Y;
    end;

    F.sMagnifier.Hide;
  end;
end;

procedure AppMenu_ShowStatusBar(F: TfrmMain);
begin
  if F = nil then Exit;
  if not Assigned(F.stsbr) then Exit;

  F.miShowStatusBar.Checked := not F.miShowStatusBar.Checked;
  UI_StatusBar_SetVisible(F, F.stsbr, F.miShowStatusBar.Checked, False);
end;

procedure AppMenu_WordWrap(F: TfrmMain);
begin
  if F = nil then Exit;
  if not Assigned(F.miWordWrap) then Exit;
  if not Assigned(F.mmoText) then Exit;
  F.mmoText.WordWrap := F.miWordWrap.Checked;

  if F.miWordWrap.Checked then
    F.mmoText.ScrollBars := ssVertical
  else
    F.mmoText.ScrollBars := ssBoth;
end;

procedure AppMenu_SetFont(F: TfrmMain);
begin
  if F = nil then Exit;
  if not Assigned(F.mmoText) then Exit;

  F.FontDlg.Font.Assign(F.mmoText.Font);

  if F.FontDlg.Execute(F.Handle) then
    F.mmoText.Font.Assign(F.FontDlg.Font);
end;

procedure AppMenu_ClearClipboard(F: TfrmMain);
begin
  if F = nil then Exit;

  try
    Clipboard.Clear;
  except
    on E: Exception do
      UI_MessageBox(F, Format(SClipboardClearErrMsg, [E.Message]), MB_ICONWARNING or MB_OK);
  end;

  AppMenu_UpdateClipboard(F);
end;

procedure AppMenu_ShowOptions(F: TfrmMain);
begin
  if F = nil then Exit;
  UI_ShowModalForm(TfrmOptions.Create(F));
end;

procedure AppMenu_About(F: TfrmMain);
begin
  if F = nil then Exit;
  UI_ShowModalForm(TfrmAbout.Create(F));
end;

end.

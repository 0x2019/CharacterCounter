unit uAppMenu;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, Vcl.Forms, Vcl.StdCtrls, Vcl.Menus,
  Clipbrd, uMain,

  uEncoding, uFileUtils, uForms, uMenu, uMessageBox;

// Global
procedure AppMenu_UpdateCaption(F: TfrmMain; const ACaption: string);
procedure AppMenu_UpdateClipboard(F: TfrmMain);

// File
procedure AppMenu_OpenFile(F: TfrmMain); overload;
procedure AppMenu_OpenFile(F: TfrmMain; FileName: string); overload;

procedure AppMenu_RecentItems(F: TfrmMain; Sender: TObject);
procedure AppMenu_Recent_Add(F: TfrmMain; const FilePath: string);
procedure AppMenu_Recent_Clear(F: TfrmMain);

procedure AppMenu_Exit(F: TfrmMain);

// Edit
procedure AppMenu_Copy(F: TfrmMain);
procedure AppMenu_ClearAll(F: TfrmMain);

// View
procedure AppMenu_AlwaysOnTop(F: TfrmMain);
procedure AppMenu_WordWrap(F: TfrmMain);

// Tool
procedure AppMenu_ClearClipboard(F: TfrmMain);
procedure AppMenu_ShowOptions(F: TfrmMain);

// Help
procedure AppMenu_About(F: TfrmMain);

implementation

uses
  uAppStrings, uOptions, uTextEncoding;

procedure AppMenu_UpdateCaption(F: TfrmMain; const ACaption: string);
begin
  if F = nil then Exit;

  try
    F.Caption := ACaption;
  except
    F.Caption := APP_NAME;
  end;

  if Assigned(F.sSkinProvider) then
  begin
    try
      F.sSkinProvider.AddedTitle.Text := ACaption;
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

procedure AppMenu_OpenFile(F: TfrmMain);
var
  FileName: string;
begin
  if F = nil then Exit;
  if not Assigned(F.OpenFileDlg) then Exit;

  F.OpenFileDlg.FileName := '';
  if not F.OpenFileDlg.Execute then Exit;

  FileName := F.OpenFileDlg.FileName;
  AppMenu_OpenFile(F, FileName);
end;

procedure AppMenu_OpenFile(F: TfrmMain; FileName: string);
var
  InputText: string;
  WindowTitle: string;
begin
  if F = nil then Exit;
  if FileName = '' then Exit;

  FileName := UI_ResolveFileShortcut(FileName);
  if FileName = '' then Exit;

  try
    if not TryReadAllText(FileName, InputText) then
    begin
      UI_MessageBox(F, SUnsupportedFileMsg, MB_ICONERROR or MB_OK);
      Exit;
    end;

    InputText := ConvertToCRLF(InputText);

    F.FLoadedFromFile := True;
    F.FHasTrailingNewLine := (InputText <> '') and
      CharInSet(InputText[Length(InputText)], [#10, #13]);

    F.mmoText.Text := InputText;
    F.mmoText.Modified := False;
    F.mmoText.SelStart := 0;
    F.mmoText.SelLength := 0;

    try
      F.mmoTextChange(nil);
    except

    end;

    WindowTitle := ExtractFileName(FileName) + ' - ' + APP_NAME;
    AppMenu_UpdateCaption(F, WindowTitle);

    AppMenu_Recent_Add(F, FileName);
  except
    on E: Exception do
      UI_MessageBox(F, Format(SOpenFileErrorMsg, [E.Message]), MB_ICONERROR or MB_OK);
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
end;

procedure AppMenu_Recent_Clear(F: TfrmMain);
begin
  if F = nil then Exit;
  if not Assigned(F.miRecent) then Exit;
  UI_Menu_Recent_Clear(F.miRecent);
end;

procedure AppMenu_Exit(F: TfrmMain);
begin
  if F = nil then Exit;
  F.Close;
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
  UI_MessageBox(F, Format(SAboutMsg, [APP_NAME, APP_VERSION, APP_RELEASE, APP_URL]), MB_ICONQUESTION or MB_OK);
end;

end.

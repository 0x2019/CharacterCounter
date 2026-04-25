unit uAppMenu;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, Vcl.Forms,
  Vcl.StdCtrls, Clipbrd, uMain,

  uEncoding, uForms, uMessageBox;

// File
procedure AppMenu_OpenFile(F: TfrmMain);
procedure AppMenu_Exit(F: TfrmMain);

// Edit
procedure AppMenu_Copy(F: TfrmMain);
procedure AppMenu_ClearAll(F: TfrmMain);

// View
procedure AppMenu_AlwaysOnTop(F: TfrmMain);
procedure AppMenu_WordWrap(F: TfrmMain);

// Tool
procedure AppMenu_ShowOptions(F: TfrmMain);

// Help
procedure AppMenu_About(F: TfrmMain);

implementation

uses
  uAppStrings, uOptions;

procedure AppMenu_OpenFile(F: TfrmMain);
var
  FileName: string;
  InputText: string;
  WindowTitle: string;
begin
  if F = nil then Exit;
  if not Assigned(F.OpenFileDlg) then Exit;

  F.OpenFileDlg.FileName := '';
  if not F.OpenFileDlg.Execute then Exit;

  FileName := F.OpenFileDlg.FileName;
  if FileName = '' then Exit;

  try
    if not TryReadAllText(FileName, InputText) then
    begin
      UI_MessageBox(F, SUnsupportedFileMsg, MB_ICONERROR or MB_OK);
      Exit;
    end;

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
    try
      F.Caption := WindowTitle;
    except
      F.Caption := APP_NAME;
    end;

    if Assigned(F.sSkinProvider) then
    begin
      try
        F.sSkinProvider.AddedTitle.Text := WindowTitle;
      except
        try
          F.sSkinProvider.AddedTitle.Text := APP_NAME;
        except
        end;
      end;
    end;
  except
    on E: Exception do
      UI_MessageBox(F, Format(SOpenFileErrorMsg, [E.Message]), MB_ICONERROR or MB_OK);
  end;
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
  Clipboard.AsText := F.mmoText.SelText;
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

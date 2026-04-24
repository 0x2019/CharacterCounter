unit uAppMenu;

interface

uses
  Winapi.Windows, System.Classes, System.IOUtils, System.SysUtils, Vcl.Forms,
  uMain,

  uEncoding, uForms, uMessageBox;

// File
procedure AppMenu_OpenFile(F: TfrmMain);

// View
procedure AppMenu_AlwaysOnTop(F: TfrmMain);

implementation

uses
  uAppStrings;

procedure AppMenu_OpenFile(F: TfrmMain);
var
  FileName: string;
  FileBytes: TBytes;
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
    FileBytes := TFile.ReadAllBytes(FileName);
    if not TryDecode(FileBytes, InputText) then
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

procedure AppMenu_AlwaysOnTop(F: TfrmMain);
begin
  if F = nil then Exit;
  F.miAlwaysOnTop.Checked := not F.miAlwaysOnTop.Checked;
  UI_SetAlwaysOnTop(F, F.miAlwaysOnTop.Checked);
end;

end.

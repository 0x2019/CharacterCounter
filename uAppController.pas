unit uAppController;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, Vcl.Forms, uMain,

  uForms, uMessageBox, uStatusBar;

procedure AppController_Init(F: TfrmMain);
function AppController_Exit(F: TfrmMain): Boolean;

procedure AppController_UpdateStats(F: TfrmMain);

implementation

uses
  uAppMenu, uAppSettings, uAppStatusBar, uAppStats, uAppStrings, uAppTaskbar,
  uTextByteCount, uTextStats;

procedure AppController_Init(F: TfrmMain);
begin
  if F = nil then Exit;

  AppSettings_Load(F);
  AppTaskbar_Init(F);
  UI_SetAlwaysOnTop(F, F.miAlwaysOnTop.Checked);
  AppMenu_WordWrap(F);

  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(100);
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(F) and
             (not Application.Terminated) and
             (not (csDestroying in F.ComponentState)) and
             Assigned(F.miShowMagnifier) and
             F.miShowMagnifier.Checked then
          begin
            AppMenu_ShowMagnifier(F);
          end;
        end);
    end).Start;

  AppStatusBar_Init(F);
  if Assigned(F.stsbr) then
    UI_StatusBar_SetVisible(F, F.stsbr, F.miShowStatusBar.Checked, False);
  AppTaskbar_Sync(F);

  AppController_UpdateStats(F);
end;

function AppController_Exit(F: TfrmMain): Boolean;
var
  ConfirmResult: Integer;
  FileName: string;
begin
  Result := False;
  if F = nil then Exit;

  if Assigned(F.mmoText) and F.mmoText.Modified then
  begin
    if F.FCurrentFileName <> '' then
      FileName := ExtractFileName(F.FCurrentFileName)
    else
      FileName := SUntitled;

    ConfirmResult := UI_ConfirmYesNoCancel(F, Format(SSaveFileConfirmMsg, [FileName]));
    case ConfirmResult of
      IDYES:
        if not AppMenu_Save(F) then
          Exit;
      IDCANCEL:
        Exit;
    end;
  end;

  Result := True;
end;

procedure AppController_UpdateStats(F: TfrmMain);
var
  Stats: TTextStats;
  InputText: string;
begin
  if F = nil then Exit;

  InputText := F.mmoText.Text;
  if InputText <> '' then
    if F.FLoadedFromFile and (not F.mmoText.Modified) and (not F.FHasTrailingNewLine) then
    begin
      if InputText.EndsWith(#13#10) then
        Delete(InputText, Length(InputText) - 1, 2)
      else if CharInSet(InputText[Length(InputText)], [#10, #13]) then
        Delete(InputText, Length(InputText), 1);
    end;

  Stats := GetTextStats(InputText, F.FByteEncoding);
  F.lblStats.Caption := ShowTextStats(Stats, F.FByteEncoding = emCP949);
  if Assigned(F.miClearAll) then
    F.miClearAll.Enabled := InputText <> '';
  if Assigned(F.miCopy) then
    F.miCopy.Enabled := F.mmoText.SelLength > 0;
end;

end.

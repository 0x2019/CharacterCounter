program CharacterCounter;

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uAbout in 'uAbout.pas' {frmAbout},
  uOptions in 'uOptions.pas' {frmOptions},
  uAppController in 'uAppController.pas',
  uAppMenu in 'uAppMenu.pas',
  uAppMenu.Popup in 'uAppMenu.Popup.pas',
  uAppSettings in 'uAppSettings.pas',
  uAppStats in 'uAppStats.pas',
  uAppStatusBar in 'uAppStatusBar.pas',
  uAppStrings in 'uAppStrings.pas',
  uAppTaskbar in 'uAppTaskbar.pas',
  uChars in 'uChars.pas',
  uTextByteCount in 'uTextByteCount.pas',
  uTextStats in 'uTextStats.pas',
  uFileDialog in '..\Common\uFileDialog.pas',
  uFileUtils in '..\Common\uFileUtils.pas',
  uForms in '..\Common\uForms.pas',
  uMenu in '..\Common\uMenu.pas',
  uMessageBox in '..\Common\uMessageBox.pas',
  uMutex in '..\Common\uMutex.pas',
  uProcessUtils in '..\Common\uProcessUtils.pas',
  uSettings.Menu in '..\Common\uSettings.Menu.pas',
  uSettings in '..\Common\uSettings.pas',
  uStatusBar in '..\Common\uStatusBar.pas',
  uTaskbar in '..\Common\uTaskbar.pas',
  uTextEncoding in '..\Common\uTextEncoding.pas',
  uTextDecoding in '..\Common\uTextDecoding.pas',
  uTextSearch in '..\Common\uTextSearch.pas',
  uMetaballs in '..\Common\About\uMetaballs.pas';

var
  uMutex: THandle;
  OpenFilePath: string;

{$R *.res}

begin
  if not UI_CreateMutex('CC!', uMutex) then
  begin
    UI_ActivateInstance(TfrmMain.ClassName, '', WM_SHOWME);

    if (ParamCount >= 1) and FileExists(ParamStr(1)) then
      AppTaskbar_OpenFile(ParamStr(1));

    UI_CloseMutex(uMutex);
    Exit;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  if ParamCount >= 1 then
  begin
    OpenFilePath := ParamStr(1);
    if FileExists(OpenFilePath) then
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(frmMain) and FileExists(OpenFilePath) then
            AppMenu_OpenFile(frmMain, OpenFilePath);
        end);
  end;

  Application.Run;

  UI_CloseMutex(uMutex);
end.


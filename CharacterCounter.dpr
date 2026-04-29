program CharacterCounter;

uses
  Winapi.Windows,
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uOptions in 'uOptions.pas' {frmOptions},
  uAppController in 'uAppController.pas',
  uAppMenu in 'uAppMenu.pas',
  uAppMenu.Popup in 'uAppMenu.Popup.pas',
  uAppSettings in 'uAppSettings.pas',
  uAppStats in 'uAppStats.pas',
  uAppStatusBar in 'uAppStatusBar.pas',
  uAppStrings in 'uAppStrings.pas',
  uChars in 'uChars.pas',
  uTextEncoding in 'uTextEncoding.pas',
  uTextStats in 'uTextStats.pas',
  uEncoding in '..\Common\uEncoding.pas',
  uFileUtils in '..\Common\uFileUtils.pas',
  uForms in '..\Common\uForms.pas',
  uMenu in '..\Common\uMenu.pas',
  uMessageBox in '..\Common\uMessageBox.pas',
  uSettings.Menu in '..\Common\uSettings.Menu.pas',
  uSettings in '..\Common\uSettings.pas',
  uStatusBar in '..\Common\uStatusBar.pas';

var
  uMutex: THandle;

{$R *.res}

begin
  uMutex := CreateMutex(nil, True, 'CC!');
  if (uMutex <> 0) and (GetLastError = 0) then
  begin
    Application.Initialize;
    Application.MainFormOnTaskbar := True;
    Application.CreateForm(TfrmMain, frmMain);
    Application.Run;

    if uMutex <> 0 then
      CloseHandle(uMutex);
  end;
end.

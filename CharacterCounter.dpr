program CharacterCounter;

uses
  Winapi.Windows,
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uOptions in 'uOptions.pas' {frmOptions},
  uAppController in 'uAppController.pas',
  uAppMenu in 'uAppMenu.pas',
  uAppSettings in 'uAppSettings.pas',
  uAppStats in 'uAppStats.pas',
  uAppStrings in 'uAppStrings.pas',
  uChars in 'uChars.pas',
  uTextEncoding in 'uTextEncoding.pas',
  uTextStats in 'uTextStats.pas',
  uEncoding in '..\Common\uEncoding.pas',
  uForms in '..\Common\uForms.pas',
  uMessageBox in '..\Common\uMessageBox.pas',
  uSettings in '..\Common\uSettings.pas';

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

program CharacterCounter;

uses
  Vcl.Forms,
  Winapi.Windows,
  uMain in 'uMain.pas' {frmMain},
  uMain.UI.Settings in 'uMain.UI.Settings.pas',
  uExt in 'uExt.pas',
  uMain.UI in 'uMain.UI.pas',
  uExt.Chars in 'uExt.Chars.pas',
  uExt.Encoding in 'uExt.Encoding.pas',
  uMain.UI.Stats in 'uMain.UI.Stats.pas';

var
  uMutex: THandle;

{$O+} {$SetPEFlags IMAGE_FILE_RELOCS_STRIPPED}
{$R *.res}

begin
  uMutex := CreateMutex(nil, True, 'CC!');
  if (uMutex <> 0 ) and (GetLastError = 0) then begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
  if uMutex <> 0 then
    CloseHandle(uMutex);
  end;
end.

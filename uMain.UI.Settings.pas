unit uMain.UI.Settings;

interface

uses
  System.SysUtils, Vcl.Forms, IniFiles;

procedure LoadSettings(AForm: TObject);
procedure SaveSettings(AForm: TObject);

implementation

uses
  uMain;

procedure LoadSettings(AForm: TObject);
var
  F: TfrmMain;
  xIni: TMemIniFile;
  xIniFileName: string;
  FirstRun: Boolean;
  FormLeft, FormTop: Integer;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  xIniFileName := ChangeFileExt(Application.ExeName, '.ini');
  xIni := TMemIniFile.Create(xIniFileName);
  FirstRun := not FileExists(xIniFileName);
  try
    if FirstRun then
      F.Position := poDesktopCenter
    else
    begin
      FormLeft    := xIni.ReadInteger('Form', 'Left', F.Left);
      FormTop     := xIni.ReadInteger('Form', 'Top', F.Top);
      F.Position  := poDesigned;
      F.SetBounds(FormLeft, FormTop, F.Width, F.Height);
    end;
    F.chkAlwaysOnTop.Checked := xIni.ReadBool('Main', 'AlwaysOnTop', False);
    F.chkUseCP949.Checked := xIni.ReadBool('Main', 'UseCP949', False);

  finally
    xIni.Free;
  end;
end;

procedure SaveSettings(AForm: TObject);
var
  F: TfrmMain;
  xIni: TMemIniFile;
begin
  if not (AForm is TfrmMain) then Exit;
  F := TfrmMain(AForm);

  xIni := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  try
    xIni.WriteInteger('Form', 'Left', F.Left);
    xIni.WriteInteger('Form', 'Top', F.Top);
    xIni.WriteBool('Main', 'AlwaysOnTop', F.chkAlwaysOnTop.Checked);
    xIni.WriteBool('Main', 'UseCP949', F.chkUseCP949.Checked);
    xIni.UpdateFile;
  finally
    xIni.Free;
  end;
end;

end.

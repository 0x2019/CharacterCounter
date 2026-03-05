unit uAppSettings;

interface

uses
  System.SysUtils, Vcl.Forms, IniFiles, uMain;

procedure AppSettings_Load(AForm: TfrmMain);
procedure AppSettings_Save(AForm: TfrmMain);

implementation

procedure AppSettings_Load(AForm: TfrmMain);
var
  Ini: TMemIniFile;
begin
  if AForm = nil then Exit;

  Ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'), TEncoding.UTF8);
  try
    AForm.chkAlwaysOnTop.Checked := Ini.ReadBool('Main', 'AlwaysOnTop', False);
    AForm.chkUseCP949.Checked := Ini.ReadBool('Main', 'UseCP949', False);
  finally
    Ini.Free;
  end;
end;

procedure AppSettings_Save(AForm: TfrmMain);
var
  Ini: TMemIniFile;
begin
  if AForm = nil then Exit;

  Ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'), TEncoding.UTF8);
  try
    Ini.WriteBool('Main', 'AlwaysOnTop', AForm.chkAlwaysOnTop.Checked);
    Ini.WriteBool('Main', 'UseCP949', AForm.chkUseCP949.Checked);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

end.

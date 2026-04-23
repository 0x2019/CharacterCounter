unit uAppSettings;

interface

uses
  System.SysUtils, Vcl.Forms, IniFiles, uMain;

procedure AppSettings_Load(F: TfrmMain);
procedure AppSettings_Save(F: TfrmMain);

implementation

procedure AppSettings_Load(F: TfrmMain);
var
  Ini: TMemIniFile;
begin
  if F = nil then Exit;

  Ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'), TEncoding.UTF8);
  try
    F.miAlwaysOnTop.Checked := Ini.ReadBool('Main', 'AlwaysOnTop', False);
    F.chkUseCP949.Checked := Ini.ReadBool('Main', 'UseCP949', False);
  finally
    Ini.Free;
  end;
end;

procedure AppSettings_Save(F: TfrmMain);
var
  Ini: TMemIniFile;
begin
  if F = nil then Exit;

  Ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'), TEncoding.UTF8);
  try
    Ini.WriteBool('Main', 'AlwaysOnTop', F.miAlwaysOnTop.Checked);
    Ini.WriteBool('Main', 'UseCP949', F.chkUseCP949.Checked);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

end.

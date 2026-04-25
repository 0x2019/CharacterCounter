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
    F.miAlwaysOnTop.Checked := Ini.ReadBool('View', 'AlwaysOnTop', False);
    F.miWordWrap.Checked := Ini.ReadBool('View', 'WordWrap', False);

    F.FUseCP949 := Ini.ReadBool('General', 'UseCP949', False);
    F.FOptionsSection := Ini.ReadInteger('Options', 'TreeIndex', 0);
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
    Ini.WriteBool('View', 'AlwaysOnTop', F.miAlwaysOnTop.Checked);
    Ini.WriteBool('View', 'WordWrap', F.miWordWrap.Checked);

    Ini.WriteBool('General', 'UseCP949', F.FUseCP949);
    Ini.WriteInteger('Options', 'TreeIndex', F.FOptionsSection);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

end.

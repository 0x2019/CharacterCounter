unit uAppSettings;

interface

uses
  Winapi.Windows, System.SysUtils, System.UITypes, Vcl.Forms, Vcl.Graphics, IniFiles,
  uMain,

  uSettings.Menu;

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
    F.miShowStatusBar.Checked := Ini.ReadBool('View', 'ShowStatusBar', True);
    F.miWordWrap.Checked := Ini.ReadBool('View', 'WordWrap', False);

    F.FUseCP949 := Ini.ReadBool('General', 'UseCP949', False);
    F.FCloseOnEsc := Ini.ReadBool('General', 'CloseOnEsc', False);
    F.FOptionsSection := Ini.ReadInteger('Options', 'TreeIndex', 0);

    F.mmoText.Font.Name := Ini.ReadString('Font', 'Name', 'Tahoma');
    F.mmoText.Font.Size := Ini.ReadInteger('Font', 'Size', 8);
    F.mmoText.Font.Style := TFontStyles(Byte(Ini.ReadInteger('Font', 'Style', 0)));
    F.mmoText.Font.Charset := Ini.ReadInteger('Font', 'Charset', DEFAULT_CHARSET);
  finally
    Ini.Free;
  end;

  UI_LoadMenuSettings(F.miRecent, F.miRecentItems);
end;

procedure AppSettings_Save(F: TfrmMain);
var
  Ini: TMemIniFile;
begin
  if F = nil then Exit;

  Ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'), TEncoding.UTF8);
  try
    Ini.WriteBool('View', 'AlwaysOnTop', F.miAlwaysOnTop.Checked);
    Ini.WriteBool('View', 'ShowStatusBar', F.miShowStatusBar.Checked);
    Ini.WriteBool('View', 'WordWrap', F.miWordWrap.Checked);

    Ini.WriteBool('General', 'UseCP949', F.FUseCP949);
    Ini.WriteBool('General', 'CloseOnEsc', F.FCloseOnEsc);
    Ini.WriteInteger('Options', 'TreeIndex', F.FOptionsSection);

    Ini.WriteString('Font', 'Name', F.mmoText.Font.Name);
    Ini.WriteInteger('Font', 'Size', F.mmoText.Font.Size);
    Ini.WriteInteger('Font', 'Style', Integer(Byte(F.mmoText.Font.Style)));
    Ini.WriteInteger('Font', 'Charset', F.mmoText.Font.Charset);

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;

  UI_SaveMenuSettings(F.miRecent);
end;

end.

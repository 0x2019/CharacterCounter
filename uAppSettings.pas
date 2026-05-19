unit uAppSettings;

interface

uses
  Winapi.Windows, System.SysUtils, System.UITypes, Vcl.Forms, Vcl.Graphics, IniFiles,
  uMain, uTextByteCount,

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
    F.miShowMagnifier.Checked := Ini.ReadBool('View', 'ShowMagnifier', False);
    F.miShowStatusBar.Checked := Ini.ReadBool('View', 'ShowStatusBar', True);

    F.miWordWrap.Checked := Ini.ReadBool('Format', 'WordWrap', False);

    F.FByteEncoding := TEncodingMode(Ini.ReadInteger('General', 'ByteEncoding', Ord(emUTF8)));
    F.FCloseOnEsc := Ini.ReadBool('General', 'CloseOnEsc', False);
    F.FOptionsSection := Ini.ReadInteger('Options', 'TreeIndex', 0);

    F.mmoText.Font.Name := Ini.ReadString('Font', 'Name', 'Tahoma');
    F.mmoText.Font.Size := Ini.ReadInteger('Font', 'Size', 8);
    F.mmoText.Font.Style := TFontStyles(Byte(Ini.ReadInteger('Font', 'Style', 0)));
    F.mmoText.Font.Charset := Ini.ReadInteger('Font', 'Charset', DEFAULT_CHARSET);

    // 돋보기
    if Assigned(F.sMagnifier) then
    begin
      F.sMagnifier.Width := Ini.ReadInteger('Magnifier', 'Width', F.sMagnifier.Width);
      F.sMagnifier.Height := Ini.ReadInteger('Magnifier', 'Height', F.sMagnifier.Height);
    end;

    F.FMagnifierLeft := Ini.ReadInteger('Magnifier', 'Left', F.FMagnifierLeft);
    F.FMagnifierTop := Ini.ReadInteger('Magnifier', 'Top', F.FMagnifierTop);
  finally
    Ini.Free;
  end;

  UI_LoadMenuSettings(F.miRecent, F.miRecentItems);
end;

procedure AppSettings_Save(F: TfrmMain);
var
  Ini: TMemIniFile;
  MagnifierPos: TPoint;
begin
  if F = nil then Exit;

  Ini := TMemIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'), TEncoding.UTF8);
  try
    Ini.WriteBool('View', 'AlwaysOnTop', F.miAlwaysOnTop.Checked);
    Ini.WriteBool('View', 'ShowMagnifier', F.miShowMagnifier.Checked);
    Ini.WriteBool('View', 'ShowStatusBar', F.miShowStatusBar.Checked);

    Ini.WriteBool('Format', 'WordWrap', F.miWordWrap.Checked);

    Ini.WriteInteger('General', 'ByteEncoding', Ord(F.FByteEncoding));
    Ini.WriteBool('General', 'CloseOnEsc', F.FCloseOnEsc);
    Ini.WriteInteger('Options', 'TreeIndex', F.FOptionsSection);

    Ini.WriteString('Font', 'Name', F.mmoText.Font.Name);
    Ini.WriteInteger('Font', 'Size', F.mmoText.Font.Size);
    Ini.WriteInteger('Font', 'Style', Integer(Byte(F.mmoText.Font.Style)));
    Ini.WriteInteger('Font', 'Charset', F.mmoText.Font.Charset);


    // 돋보기
    if Assigned(F.sMagnifier) then
    begin
      if F.sMagnifier.IsVisible then
      begin
        MagnifierPos := F.sMagnifier.GetPosition;
        F.FMagnifierLeft := MagnifierPos.X;
        F.FMagnifierTop := MagnifierPos.Y;
      end;

      Ini.WriteInteger('Magnifier', 'Width', F.sMagnifier.Width);
      Ini.WriteInteger('Magnifier', 'Height', F.sMagnifier.Height);
    end;

    Ini.WriteInteger('Magnifier', 'Left', F.FMagnifierLeft);
    Ini.WriteInteger('Magnifier', 'Top', F.FMagnifierTop);

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;

  UI_SaveMenuSettings(F.miRecent);
end;

end.


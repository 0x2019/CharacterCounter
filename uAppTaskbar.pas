unit uAppTaskbar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, Vcl.Menus,
  uMain,

  uMenu, uTaskbar;

procedure AppTaskbar_Init(F: TfrmMain);
procedure AppTaskbar_OpenFile(const FilePath: string; MainWnd: HWND = 0);
procedure AppTaskbar_Sync(F: TfrmMain);

implementation

uses
  uAppSettings, uAppStrings;

type
  TAppCopyDataStruct = packed record
    dwData: NativeUInt;
    cbData: Cardinal;
    lpData: Pointer;
  end;

procedure AppTaskbar_Init(F: TfrmMain);
begin
  if F = nil then Exit;

  TBP_SetAppUserModelID(APP_NAME);
  TBP_Reset;
end;

procedure AppTaskbar_OpenFile(const FilePath: string; MainWnd: HWND);
var
  CopyDataStruct: TAppCopyDataStruct;
begin
  if Trim(FilePath) = '' then
    Exit;

  if MainWnd = 0 then
  begin
    MainWnd := FindWindow(PChar(APP_NAME), nil);
    if MainWnd = 0 then
      MainWnd := FindWindow('TfrmMain', nil);
  end;
  if MainWnd = 0 then
    Exit;

  if IsIconic(MainWnd) then
    ShowWindow(MainWnd, SW_RESTORE)
  else
    ShowWindow(MainWnd, SW_SHOW);
  SetForegroundWindow(MainWnd);

  CopyDataStruct.dwData := 1;
  CopyDataStruct.cbData := (Length(FilePath) + 1) * SizeOf(Char);
  CopyDataStruct.lpData := PChar(FilePath);
  SendMessage(MainWnd, WM_COPYDATA, 0, LPARAM(@CopyDataStruct));
end;

procedure AppTaskbar_Sync(F: TfrmMain);
var
  RecentFiles: TStringList;
  Index: Integer;
  PrevCount: Integer;
  FilePath: string;
  MI: TMenuItem;
begin
  if F = nil then Exit;
  if not Assigned(F.miRecent) then Exit;

  RecentFiles := TStringList.Create;
  try
    for Index := 0 to F.miRecent.Count - 1 do
    begin
      FilePath := Trim(F.miRecent.Items[Index].Hint);
      if FilePath <> '' then
        RecentFiles.Add(FilePath);
    end;

    PrevCount := RecentFiles.Count;

    TBP_SetAppUserModelID(APP_NAME);
    TBP_Recent_Sync(RecentFiles);

    if RecentFiles.Count < PrevCount then
    begin
      for Index := F.miRecent.Count - 1 downto 0 do
      begin
        MI := F.miRecent.Items[Index];
        FilePath := Trim(MI.Hint);

        if (FilePath <> '') and (RecentFiles.IndexOf(FilePath) = -1) then
        begin
          UI_Menu_Recent_Remove(F.miRecent, FilePath);
        end;
      end;

      AppSettings_Save(F);
    end;
  finally
    RecentFiles.Free;
  end;
end;

end.

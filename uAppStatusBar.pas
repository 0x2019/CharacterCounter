unit uAppStatusBar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, System.IOUtils,
  System.Types, Vcl.Clipbrd, uMain,

  uFileUtils, uTextEncoding;

const
  STATUS_PANEL_MAIN = 0;

// Global
procedure AppStatusBar_Init(F: TfrmMain);
procedure AppStatusBar_Copy(F: TfrmMain);
procedure AppStatusBar_Update(F: TfrmMain; const FilePath, SourceText: string);

// Caret
function AppStatusBar_GetCaret(F: TfrmMain): string;
procedure AppStatusBar_UpdateCaret(F: TfrmMain);

implementation

uses
  uAppStrings;

function GetFileExt(const FilePath: string): string;
begin
  Result := UpperCase(Copy(ExtractFileExt(FilePath), 2, MaxInt));
  if Result = '' then
    Result := SNotAvailable;
end;

function AppStatusBar_GetStatusText(F: TfrmMain): string;
begin
  Result := '';
  if (F = nil) or not Assigned(F.stsbr) then Exit;
  if F.stsbr.Panels.Count = 0 then Exit;
  Result := F.stsbr.Panels[STATUS_PANEL_MAIN].Text;
end;

procedure AppStatusBar_SetStatusText(F: TfrmMain; const Text: string);
begin
  if (F = nil) or not Assigned(F.stsbr) then Exit;
  if F.stsbr.Panels.Count = 0 then
    F.stsbr.Panels.Add;
  F.stsbr.Panels[STATUS_PANEL_MAIN].Text := Text;
end;

procedure AppStatusBar_Init(F: TfrmMain);
begin
  AppStatusBar_SetStatusText(F, '');
end;

procedure AppStatusBar_Copy(F: TfrmMain);
var
  StatusText: string;
begin
  StatusText := Trim(AppStatusBar_GetStatusText(F));
  if StatusText = '' then
    Exit;

  Clipboard.AsText := StatusText;
end;

procedure AppStatusBar_Update(F: TfrmMain; const FilePath, SourceText: string);
var
  Bytes: TBytes;
  Size: string;
  Encoding: string;
  SplitPos: Integer;
  StatusText: string;
begin
  if (F = nil) or (FilePath = '') then Exit;
  if not Assigned(F.stsbr) then Exit;
  if not TFile.Exists(FilePath) then Exit;

  Bytes := TFile.ReadAllBytes(FilePath);

  Size := GetFileSize(FilePath, suAuto);
  SplitPos := Pos(' (', Size);
  if SplitPos > 0 then
    Size := Copy(Size, 1, SplitPos - 1);
  if Size = '' then
    Size := SNotAvailable;

  Encoding := GetEncodingName(F.FSaveEncoding);
  if not SameText(FilePath, F.FCurrentFileName) then
    Encoding := GetEncodingName(Bytes);

  StatusText := GetFileExt(FilePath) + SSeparator +
                Encoding + SSeparator +
                GetLineBreak(SourceText) + SSeparator +
                Size;
  AppStatusBar_SetStatusText(F, StatusText);
  AppStatusBar_UpdateCaret(F);
end;

function AppStatusBar_GetCaret(F: TfrmMain): string;
var
  CaretPoint: TPoint;
  CaretIndex: Integer;
  LineIndex: Integer;
  LineStart: Integer;
  ColumnIndex: Integer;
begin
  Result := Format(SCaret, [1, 1]);
  if (F = nil) or not Assigned(F.mmoText) then Exit;

  CaretIndex := F.mmoText.SelStart;
  if F.mmoText.Focused and GetCaretPos(CaretPoint) then
    CaretIndex := F.mmoText.Perform(
      EM_CHARFROMPOS,
      0,
      LPARAM((CaretPoint.Y shl 16) or (CaretPoint.X and $FFFF))
    ) and $FFFF;

  if CaretIndex < 0 then
    CaretIndex := 0;

  LineIndex := F.mmoText.Perform(EM_LINEFROMCHAR, CaretIndex, 0);
  if LineIndex < 0 then
    LineIndex := 0;

  LineStart := F.mmoText.Perform(EM_LINEINDEX, LineIndex, 0);
  if LineStart < 0 then
    LineStart := 0;

  ColumnIndex := (CaretIndex - LineStart) + 1;
  if ColumnIndex < 1 then
    ColumnIndex := 1;

  Result := Format(SCaret, [LineIndex + 1, ColumnIndex]);
end;

procedure AppStatusBar_UpdateCaret(F: TfrmMain);
var
  SepChar: Char;
  I: Integer;
  SepCount: Integer;
  PrevSepPos: Integer;
  SplitPos: Integer;
  BaseText: string;
  CaretText: string;
  LeftText: string;
  RightText: string;
begin
  if F = nil then Exit;
  if not Assigned(F.stsbr) then Exit;
  CaretText := AppStatusBar_GetCaret(F);

  SepChar := '|';
  if Length(SSeparator) >= 2 then
    SepChar := SSeparator[2];

  BaseText := AppStatusBar_GetStatusText(F);
  if Pos(SSeparator, BaseText) = 0 then
    BaseText := ''
  else
  begin
    SepCount := 0;
    for I := 1 to Length(BaseText) do
      if BaseText[I] = SepChar then
        Inc(SepCount);

    if SepCount >= 4 then
    begin
      SplitPos := LastDelimiter(SepChar, BaseText);
      PrevSepPos := LastDelimiter(SepChar, Copy(BaseText, 1, SplitPos - 1));
      if (SplitPos > 0) and (PrevSepPos > 0) then
        Delete(BaseText, PrevSepPos, SplitPos - PrevSepPos);
    end;
  end;

  if BaseText = '' then
    AppStatusBar_SetStatusText(F, CaretText)
  else
  begin
    SplitPos := LastDelimiter(SepChar, BaseText);
    if SplitPos > 0 then
    begin
      LeftText := Trim(Copy(BaseText, 1, SplitPos - 1));
      RightText := Trim(Copy(BaseText, SplitPos + 1, MaxInt));
      if RightText = '' then
        AppStatusBar_SetStatusText(F, LeftText + SSeparator + CaretText)
      else
        AppStatusBar_SetStatusText(F, LeftText + SSeparator + CaretText + SSeparator + RightText);
    end
    else
      AppStatusBar_SetStatusText(F, BaseText + SSeparator + CaretText);
  end;
end;

end.


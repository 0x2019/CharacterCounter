unit uAppStats;

interface

uses
  System.SysUtils, uTextStats, uAppStrings;

const
  COLOR_RED           = '#FF0000';
  COLOR_GREEN         = '#008000';
  COLOR_BLUE          = '#0000FF';
  COLOR_PURP          = '#800080';
  COLOR_NAVY          = '#000080';
  COLOR_TEAL          = '#008080';

// 줄바꿈 / 굵은 글씨 태그
  HTML_BR             = '<br>';
  HTML_BR2            = '<br><br>';
  HTML_BOLD_ON        = '<b>';
  HTML_BOLD_OFF       = '</b>';

  FMT_MAIN_BYTE       = '%s: ' + HTML_BR + '%s / %s %s' + HTML_BR2;
  FMT_MAIN_LINE       = '%s: %s %s' + HTML_BR;
  FMT_MAIN_WORD       = '%s: %s %s' + HTML_BR;

  FMT_VAL             = HTML_BOLD_ON + '%s %s' + HTML_BOLD_OFF;
  FMT_STAT_ITEM       = '%s: ' + FMT_VAL + '%s';

  FMT_SUB_DUAL        = '(%s: ' + FMT_VAL + ' / %s: ' + FMT_VAL + ')';
  FMT_SUB_SINGLE      = '(%s: ' + FMT_VAL + ')';

function ShowTextStats(const TextInfo: TTextStats): string;

implementation

function AddColor(const Color, Text: string): string;
begin
  Result := Format('<font color="%s"><b>%s</b></font>', [Color, Text]);
end;

function AddComma(const N: Int64): string;
begin
  Result := FormatFloat('#,##0', N);
end;

function Bold(const S: string): string; inline;
begin
  Result := HTML_BOLD_ON + S + HTML_BOLD_OFF;
end;

function FormatSubStats(const Label1: string; Val1: Integer; const Label2: string; Val2: Integer; IsLast: Boolean = False): string;
begin
  if (Val1 > 0) and (Val2 > 0) then
    Result := Format(FMT_SUB_DUAL, [Label1, AddComma(Val1), SUnitChar, Label2, AddComma(Val2), SUnitChar])
  else if Val1 > 0 then
    Result := Format(FMT_SUB_SINGLE, [Label1, AddComma(Val1), SUnitChar])
  else if Val2 > 0 then
    Result := Format(FMT_SUB_SINGLE, [Label2, AddComma(Val2), SUnitChar])
  else
    Result := '';

  if not IsLast then
  begin
    if Result <> '' then
      Result := Result + HTML_BR2
    else
      Result := HTML_BR;
  end;
end;

function ShowTextStats(const TextInfo: TTextStats): string;
var
  SB: TStringBuilder;
  CharTypes: Boolean;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendFormat(FMT_MAIN_BYTE, [
      Bold(SCharCountWithSpaces),
      AddColor(COLOR_GREEN, AddComma(TextInfo.CharCountWithSpaces)),
      AddColor(COLOR_GREEN, AddComma(TextInfo.ByteCountWithSpaces)),
      SUnitByte
    ]);

    SB.AppendFormat(FMT_MAIN_BYTE, [
      Bold(SCharCountNoSpaces),
      AddColor(COLOR_GREEN, AddComma(TextInfo.CharCountNoSpaces)),
      AddColor(COLOR_GREEN, AddComma(TextInfo.ByteCountNoSpaces)),
      SUnitByte
    ]);

    SB.AppendFormat(FMT_MAIN_LINE, [
      Bold(SLineCount),
      AddColor(COLOR_PURP, AddComma(TextInfo.LineCount)),
      SUnitLine
    ]);

    SB.AppendFormat(FMT_MAIN_WORD, [
      Bold(SWordCount),
      AddColor(COLOR_NAVY, AddComma(TextInfo.WordCount)),
      SUnitWord
    ]);

    CharTypes := (TextInfo.HangulCount > 0) or (TextInfo.HanjaCharCount > 0) or
                 (TextInfo.AsciiLetterCount > 0) or (TextInfo.AsciiDigitCount > 0) or
                 (TextInfo.SpecialCharCount > 0) or ((TextInfo.SpaceCount + TextInfo.OtherSpaceCount) > 0);

    if CharTypes then
    begin
      SB.Append(HTML_BR).Append(Bold(SCharTypes)).Append(HTML_BR);

      if TextInfo.HangulCount > 0 then
      begin
        SB.AppendFormat(FMT_STAT_ITEM, [SHangul, AddComma(TextInfo.HangulCount), SUnitChar, HTML_BR]);
        SB.Append(FormatSubStats(SHangulConsonant, TextInfo.HangulConsonantCount, SHangulVowel, TextInfo.HangulVowelCount));
      end;

      if TextInfo.HanjaCharCount > 0 then
        SB.AppendFormat(FMT_STAT_ITEM, [SHanja, AddComma(TextInfo.HanjaCharCount), SUnitChar, HTML_BR2]);

      if TextInfo.AsciiLetterCount > 0 then
      begin
        SB.AppendFormat(FMT_STAT_ITEM, [SEnglish, AddComma(TextInfo.AsciiLetterCount), SUnitChar, HTML_BR]);
        SB.Append(FormatSubStats(SEnglishLowercase, TextInfo.AsciiLowerCount, SEnglishUppercase, TextInfo.AsciiUpperCount));
      end;

      if TextInfo.AsciiDigitCount > 0 then
        SB.AppendFormat(FMT_STAT_ITEM, [SDigit, AddComma(TextInfo.AsciiDigitCount), SUnitChar, HTML_BR2]);

      if TextInfo.SpecialCharCount > 0 then
        SB.AppendFormat(FMT_STAT_ITEM, [SSpecialChar, AddComma(TextInfo.SpecialCharCount), SUnitChar, HTML_BR2]);

      if (TextInfo.SpaceCount + TextInfo.OtherSpaceCount) > 0 then
      begin
        SB.AppendFormat(FMT_STAT_ITEM, [SSpace, AddComma(TextInfo.SpaceCount + TextInfo.OtherSpaceCount), SUnitChar, HTML_BR]);
        SB.Append(FormatSubStats(SSpaceStandard, TextInfo.SpaceCount, SSpaceOther, TextInfo.OtherSpaceCount, True));
      end;
    end;

    Result := SB.ToString;

    while Result.EndsWith(HTML_BR) do
      Result := Copy(Result, 1, Length(Result) - Length(HTML_BR));

  finally
    SB.Free;
  end;
end;

end.

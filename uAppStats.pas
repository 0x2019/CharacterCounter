unit uAppStats;

interface

uses
  System.SysUtils, uTextStats;

const
  COLOR_RED   = '#FF0000';
  COLOR_GREEN = '#008000';
  COLOR_BLUE  = '#0000FF';
  COLOR_PURP  = '#800080';
  COLOR_NAVY  = '#000080';
  COLOR_TEAL  = '#008080';

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
  Result := '<b>' + S + '</b>';
end;

function ShowTextStats(const TextInfo: TTextStats): string;
var
  SB: TStringBuilder;
begin
  SB := TStringBuilder.Create;
  try
    SB.AppendFormat('%s <br>%s / %s 바이트<br>', [
      Bold('문자 (공백 포함):'),
      AddColor(COLOR_GREEN, AddComma(TextInfo.CharCountWithSpaces)),
      AddColor(COLOR_GREEN, AddComma(TextInfo.ByteCountWithSpaces))
    ]);

    SB.AppendFormat('<br>%s <br>%s / %s 바이트<br>', [
      Bold('문자 (공백 제외):'),
      AddColor(COLOR_GREEN, AddComma(TextInfo.CharCountNoSpaces)),
      AddColor(COLOR_GREEN, AddComma(TextInfo.ByteCountNoSpaces))
    ]);

    SB.AppendFormat('<br>%s %s 줄<br>', [
      Bold('줄 수:'),
      AddColor(COLOR_PURP, AddComma(TextInfo.LineCount))
    ]);

    SB.AppendFormat('%s %s 개<br>', [
      Bold('단어 수:'),
      AddColor(COLOR_NAVY, AddComma(TextInfo.WordCount))
    ]);

    SB.Append('<br>').Append(Bold('문자 종류:')).Append('<br>');

    SB.AppendFormat('한글: <b>%s 자</b><br>', [AddComma(TextInfo.HangulCount)]);
    SB.AppendFormat('(자음: <b>%s 자</b> / 모음: <b>%s 자</b>)<br><br>', [
      AddComma(TextInfo.HangulConsonantCount),
      AddComma(TextInfo.HangulVowelCount)
    ]);

    SB.AppendFormat('한자: <b>%s 자</b><br><br>', [AddComma(TextInfo.HanjaCharCount)]);

    SB.AppendFormat('영문: <b>%s 자</b><br>', [AddComma(TextInfo.AsciiLetterCount)]);
    SB.AppendFormat('(소문자: <b>%s 자</b> / 대문자: <b>%s 자</b>)<br><br>', [
      AddComma(TextInfo.AsciiLowerCount),
      AddComma(TextInfo.AsciiUpperCount)
    ]);

    SB.AppendFormat('숫자: <b>%s 자 </b><br>', [AddComma(TextInfo.AsciiDigitCount)]);
    SB.AppendFormat('특수 문자: <b>%s 자 </b><br><br>', [AddComma(TextInfo.SpecialCharCount)]);

    SB.AppendFormat('공백: <b>%s 자 </b><br>', [AddComma(TextInfo.SpaceCount + TextInfo.OtherSpaceCount)]);
    SB.AppendFormat('(스페이스: <b>%s 자</b> / 기타: <b>%s 자</b>)', [
      AddComma(TextInfo.SpaceCount),
      AddComma(TextInfo.OtherSpaceCount)
    ]);

    Result := SB.ToString;
  finally
    SB.Free;
  end;
end;

end.

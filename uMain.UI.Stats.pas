unit uMain.UI.Stats;

interface

uses
  System.SysUtils, uExt;

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
begin
  Result :=
    Format('%s <br>%s / %s 바이트<br>',
      [Bold('문자 (공백 포함):'),
       AddColor(COLOR_GREEN, AddComma(TextInfo.CharCountWithSpaces)),
       AddColor(COLOR_GREEN, AddComma(TextInfo.ByteCountWithSpaces))]) +

    Format('<br>%s <br>%s / %s 바이트<br>',
      [Bold('문자 (공백 제외):'),
       AddColor(COLOR_GREEN, AddComma(TextInfo.CharCountNoSpaces)),
       AddColor(COLOR_GREEN, AddComma(TextInfo.ByteCountNoSpaces))]) +

    Format('<br>%s %s 줄<br>',
      [Bold('줄 수:'),
       AddColor(COLOR_PURP, AddComma(TextInfo.LineCount))]) +

    Format('%s %s 개<br>',
      [Bold('단어 수:'),
       AddColor(COLOR_NAVY, AddComma(TextInfo.WordCount))]) +

    Format('<br>%s' +
           '<br>한글: <b>%s 개</b>' +
           '<br>(자음: <b>%s 개</b> / 모음: <b>%s 개</b>)' +
           '<br><br>한자: <b>%s 개</b>' +
           '<br>영문: <b>%s 개</b>' +
           '<br>(소문자: <b>%s 개</b> / 대문자: <b>%s 개</b>)' +
           '<br><br>숫자: <b>%s 개 </b>' +
           '<br>특수 문자: <b>%s 개 </b>' +
           '<br><br>공백: <b>%s 개 </b>' +
           '<br>(스페이스: <b>%s 개</b> / 기타: <b>%s 개</b>)',
      [Bold('문자 종류:'),
       AddComma(TextInfo.HangulCount),
       AddComma(TextInfo.HangulConsonantCount), AddComma(TextInfo.HangulVowelCount),
       AddComma(TextInfo.HanjaCharCount),
       AddComma(TextInfo.AsciiLetterCount),
       AddComma(TextInfo.AsciiLowerCount), AddComma(TextInfo.AsciiUpperCount),
       AddComma(TextInfo.AsciiDigitCount),
       AddComma(TextInfo.SpecialCharCount),
       AddComma(TextInfo.SpaceCount + TextInfo.OtherSpaceCount),
       AddComma(TextInfo.SpaceCount),
       AddComma(TextInfo.OtherSpaceCount)]);
end;

end.

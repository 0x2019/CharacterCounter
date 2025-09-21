unit uExt;

interface

uses
  System.Character, System.SysUtils;

type
  TTextStats = record
    CharCountWithSpaces: Integer;     // 공백 포함 전체 문자 수 (UTF-16)
    CharCountNoSpaces: Integer;       // 공백 제외 문자 수
    ByteCountWithSpaces: Integer;     // 공백 포함 전체 바이트 수
    ByteCountNoSpaces: Integer;       // 공백 제외 바이트 수

    WordCount: Integer;               // 단어 수 (공백 기준)
    LineCount: Integer;               // 줄 수 (CR/LF 정규화 후 계산)

    HangulCount: Integer;             // 한글 전체 개수
    HangulConsonantCount: Integer;    // 한글 자모 중 자음 개수
    HangulVowelCount: Integer;        // 한글 자모 중 모음 개수

    HanjaCharCount: Integer;          // 한자 개수

    AsciiLetterCount: Integer;        // ASCII 영문자 전체 개수
    AsciiUpperCount: Integer;         // ASCII 대문자 개수 (A-Z)
    AsciiLowerCount: Integer;         // ASCII 소문자 개수 (a-z)
    AsciiDigitCount: Integer;         // ASCII 숫자 개수 (0-9)

    SpecialCharCount: Integer;        // 특수 문자 개수
    SpaceCount: Integer;              // 스페이스 개수
    OtherSpaceCount: Integer;         // 다른 공백 문자 개수 (탭, 줄바꿈, 전각 공백 등)
  end;

// 종합 통계 (문자/바이트/단어/줄 등)
function GetTextStats(const Text: string): TTextStats;

// 단어 수 계산
function GetWordCount(const Text: string): Integer;

// 한글 자모 여부에 따라 자음/모음 수를 갱신
procedure UpdateHangulCounts(const ch: Char; var ConsonantCount, VowelCount: Integer);

implementation

uses
  uExt.Chars, uExt.Encoding;

function GetTextStats(const Text: string): TTextStats;
var
  i, TextLen, LineFeedCount: Integer;
  ch: Char;
  actualCharCode: Cardinal;
  NoSpaceBuilder: TStringBuilder;
  HasNonNewline: Boolean;
begin
  Result := Default(TTextStats);
  Result.CharCountWithSpaces := Length(ConvertCRLFtoLF(Text));

  TextLen := Length(Text);
  NoSpaceBuilder := TStringBuilder.Create(TextLen);
  try
    i := 1;
    while i <= TextLen do
    begin
      ch := Text[i];
      if ch.IsWhiteSpace then
      begin
        if ch = ' ' then Inc(Result.SpaceCount) else Inc(Result.OtherSpaceCount);
        Inc(i);
        Continue;
      end;

      if ch.IsHighSurrogate and (i < TextLen) and Text[i+1].IsLowSurrogate then
      begin
        NoSpaceBuilder.Append(ch);
        NoSpaceBuilder.Append(Text[i+1]);
        actualCharCode := Cardinal(((Ord(ch) - $D800) shl 10) + (Ord(Text[i+1]) - $DC00) + $10000);
        if IsHanjaChar(actualCharCode) then Inc(Result.HanjaCharCount) else Inc(Result.SpecialCharCount);
        Inc(i, 2);
        Continue;
      end;

      NoSpaceBuilder.Append(ch);
      if IsHangulChar(ch) then
      begin
        Inc(Result.HangulCount);
        UpdateHangulCounts(ch, Result.HangulConsonantCount, Result.HangulVowelCount);
      end
      else if IsAsciiLetter(ch) then
      begin
        Inc(Result.AsciiLetterCount);
      if IsAsciiUpper(ch) then
        Inc(Result.AsciiUpperCount)
      else
        Inc(Result.AsciiLowerCount);
      end
      else if IsAsciiDigit(ch) then Inc(Result.AsciiDigitCount)
      else if IsHanjaChar(Ord(ch)) then Inc(Result.HanjaCharCount)
      else Inc(Result.SpecialCharCount);

      Inc(i);
    end;

    Result.CharCountNoSpaces := NoSpaceBuilder.Length;
    Result.ByteCountNoSpaces := GetByteCount(NoSpaceBuilder.ToString);
  finally
    NoSpaceBuilder.Free;
  end;

  Result.WordCount := GetWordCount(Text);

  if Text = '' then
    Result.LineCount := 0
  else
  begin
    LineFeedCount := 0;
    HasNonNewline := False;
    i := 1;
    while i <= TextLen do
    begin
      if Text[i] = #13 then
      begin
        Inc(LineFeedCount);
        if (i < TextLen) and (Text[i+1] = #10) then
          Inc(i);
      end
      else if Text[i] = #10 then
        Inc(LineFeedCount)
      else
        HasNonNewline := True;
      Inc(i);
    end;

    if (TextLen > 0) and not CharInSet(Text[TextLen], [#10, #13]) then
      Inc(LineFeedCount);

    Result.LineCount := LineFeedCount;

    // 마지막이 개행으로 끝난 경우 빈 줄도 1줄로 포함
    if (TextLen > 0) and CharInSet(Text[TextLen], [#10, #13]) and HasNonNewline then
      Inc(Result.LineCount);

    end;
  Result.ByteCountWithSpaces := GetByteCount(Text);
end;

function GetWordCount(const Text: string): Integer;
var
  i: Integer;
  InWord: Boolean;
  ch: Char;
begin
  Result := 0;
  InWord := False;
  for i := 1 to Length(Text) do
  begin
    ch := Text[i];
    if ch.IsWhiteSpace then
      InWord := False
    else if not InWord then
    begin
      InWord := True;
      Inc(Result);
    end;
  end;
end;

procedure UpdateHangulCounts(const ch: Char; var ConsonantCount, VowelCount: Integer);
var
  Code: Integer;
begin
  Code := Ord(ch);

  if IsHangulSyllable(Code) then
  begin
{
  // 완성형 음절(가~힣)은 자음/모음 카운트에 포함하지 않음
    SyllableIndex := Code - $AC00;
    FinalIndex := SyllableIndex mod 28;

    Inc(ConsonantCount);
    Inc(VowelCount);
    if FinalIndex > 0 then
      Inc(ConsonantCount);
}
    Exit;
  end;

  if ((Code >= $1100) and (Code <= $115F)) or
     ((Code >= $A960) and (Code <= $A97F)) then
  begin
    Inc(ConsonantCount);
    Exit;
  end;

  if ((Code >= $1160) and (Code <= $11A7)) or
     ((Code >= $D7B0) and (Code <= $D7C6)) then
  begin
    Inc(VowelCount);
    Exit;
  end;

  if ((Code >= $11A8) and (Code <= $11FF)) or
     ((Code >= $D7CB) and (Code <= $D7FB)) then
  begin
    Inc(ConsonantCount);
    Exit;
  end;

  if (Code >= $3131) and (Code <= $314E) then
  begin
    Inc(ConsonantCount);
    Exit;
  end;

  if (Code >= $314F) and (Code <= $3163) then
  begin
    Inc(VowelCount);
    Exit;
  end;
end;

end.

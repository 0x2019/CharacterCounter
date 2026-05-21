unit uChars;

interface

uses
  System.Character, System.SysUtils;

// ASCII 영문자 여부 (A–Z, a–z)
function IsAsciiLetter(const ch: Char): Boolean; inline;

// ASCII 대문자 여부 (A–Z)
function IsAsciiUpper(const ch: Char): Boolean; inline;

// ASCII 소문자 여부 (a–z)
function IsAsciiLower(const ch: Char): Boolean; inline;

// ASCII 숫자 여부 (0–9)
function IsAsciiDigit(const ch: Char): Boolean; inline;

// 한글 여부
function IsHangulChar(const ch: Char): Boolean; inline;

// 완성형 한글 음절 여부
function IsHangulSyllable(Code: Integer): Boolean; inline;

// 한자 여부
function IsHanjaChar(Code: Cardinal): Boolean; inline;

// 히라가나 여부
function IsHiraganaChar(Code: Cardinal): Boolean; inline;

// 가타카나 여부 (반각 포함 옵션)
function IsKatakanaChar(Code: Cardinal; HalfWidth: Boolean = True): Boolean; inline;

implementation

{$INLINE AUTO}

function IsAsciiLetter(const ch: Char): Boolean; inline;
begin
  Result := CharInSet(ch, ['A'..'Z', 'a'..'z']);
end;

function IsAsciiLower(const ch: Char): Boolean; inline;
begin
  Result := CharInSet(ch, ['a'..'z']);
end;

function IsAsciiUpper(const ch: Char): Boolean; inline;
begin
  Result := CharInSet(ch, ['A'..'Z']);
end;

function IsAsciiDigit(const ch: Char): Boolean; inline;
begin
  Result := CharInSet(ch, ['0'..'9']);
end;

function IsHanjaChar(Code: Cardinal): Boolean; inline;
begin
  Result :=
    ((Code >= $3400)  and (Code <= $4DBF))  or  // 한중일 통합 한자 확장 A
    ((Code >= $4E00)  and (Code <= $9FFF))  or  // 한중일 통합 한자 (기본)
    ((Code >= $F900)  and (Code <= $FAFF))  or  // 한중일 호환 한자
    ((Code >= $20000) and (Code <= $2A6DF)) or  // 한중일 통합 한자 확장 B
    ((Code >= $2A700) and (Code <= $2B73F)) or  // 한중일 통합 한자 확장 C
    ((Code >= $2B740) and (Code <= $2B81F)) or  // 한중일 통합 한자 확장 D
    ((Code >= $2B820) and (Code <= $2CEAF)) or  // 한중일 통합 한자 확장 E
    ((Code >= $2CEB0) and (Code <= $2EBEF)) or  // 한중일 통합 한자 확장 F
    ((Code >= $30000) and (Code <= $3134F)) or  // 한중일 통합 한자 확장 G
    ((Code >= $31350) and (Code <= $323AF));    // 한중일 통합 한자 확장 H
end;

function IsHiraganaChar(Code: Cardinal): Boolean; inline;
begin
  Result := (Code >= $3040) and (Code <= $309F);
end;

function IsKatakanaChar(Code: Cardinal; HalfWidth: Boolean): Boolean; inline;
begin
  Result := (Code >= $30A0) and (Code <= $30FF);
  if (not Result) and HalfWidth then
    Result := (Code >= $FF66) and (Code <= $FF9F);
end;

function IsHangulChar(const ch: Char): Boolean;
var
  Code: Integer;
begin
  Code := Ord(ch);
  Result :=
    IsHangulSyllable(Code) or
    ((Code >= $1100) and (Code <= $11FF)) or  // 한글 자모 (초성, 중성, 종성 개별)
    ((Code >= $3130) and (Code <= $318F)) or  // 한글 호환 자모 (옛 자모, 반각 자모 등)
    ((Code >= $A960) and (Code <= $A97F)) or  // 한글 자모 확장 A
    ((Code >= $D7B0) and (Code <= $D7FF));    // 한글 자모 확장 B
end;

function IsHangulSyllable(Code: Integer): Boolean; inline;
begin
  Result := (Code >= $AC00) and (Code <= $D7A3); // 완성형 한글 음절 인지 판별
end;

end.

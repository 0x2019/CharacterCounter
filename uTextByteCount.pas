unit uTextByteCount;

interface

uses
  System.Character, System.SysUtils;

type
  TEncodingMode = (emUTF8, emCP949);

// 개행 문자 정규화 (CRLF → LF, CR → LF)
function ConvertCRLFtoLF(const S: string): string; inline;
function ConvertToCRLF(const S: string): string; inline;

// TEncodingMode에 따라 UTF-8 또는 CP949 바이트 수를 반환
function GetByteCount(const Text: string; Mode: TEncodingMode): Integer;

// CP949 인코딩으로 문자열 전체의 바이트 수를 계산
function GetCP949ByteCount(const Text: string): Integer;

// UTF-8 인코딩으로 문자열 전체의 바이트 수를 계산
function GetUTF8ByteCount(const Text: string): Integer;

implementation

var
  EncCP949: TEncoding = nil;

function ConvertCRLFtoLF(const S: string): string; inline;
begin
  Result := S.Replace(#13#10, #10, [rfReplaceAll]).Replace(#13, #10, [rfReplaceAll]);
end;

function ConvertToCRLF(const S: string): string; inline;
begin
  Result := ConvertCRLFtoLF(S).Replace(#10, sLineBreak, [rfReplaceAll]);
end;

function GetByteCount(const Text: string; Mode: TEncodingMode): Integer;
var
  S: string;
begin
  S := ConvertCRLFtoLF(Text);

  if Mode = emCP949 then
    Result := GetCP949ByteCount(S)
  else
    Result := GetUTF8ByteCount(S);
end;

function GetCP949ByteCount(const Text: string): Integer;
begin
  if EncCP949 = nil then
    EncCP949 := TEncoding.GetEncoding(949);
  Result := EncCP949.GetByteCount(Text);
end;

function GetUTF8ByteCount(const Text: string): Integer;
begin
  Result := TEncoding.UTF8.GetByteCount(Text);
end;

initialization

finalization
  FreeAndNil(EncCP949);

end.


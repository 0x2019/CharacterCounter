unit uAppStrings;

interface

resourcestring
  APP_NAME                            = 'Character Counter';
  APP_VERSION                         = 'v1.0.0.0';
  APP_RELEASE                         = 'September 21, 2025';
  APP_URL                             = 'https://github.com/0x2019/CharacterCounter';

  SOpenFileErrorMsg                   = '파일을 열 수 없습니다.' + sLineBreak + '%s';
  SUnsupportedFileMsg                 = '지원하지 않는 파일 형식입니다.';

  SClearConfirmMsg                    = '모든 입력 내용을 지우시겠습니까?';
  SConfirmOnExitMsg                   = '프로그램을 종료하시겠습니까?';

  SClipboardClearErrMsg               = '클립보드를 초기화할 수 없습니다.' + sLineBreak + '%s';
  SClipboardCopyErrMsg                = '클립보드에 복사할 수 없습니다.' + sLineBreak + '%s';

  SOptionsNodeGeneral                 = '일반';

// uAppStats
// 인코딩
  SEncodingCP949                      = 'CP949';
  SEncodingUTF8                       = 'UTF-8';

// 통계
  SCharCountWithSpaces                = '문자 (%s | 공백 포함)';
  SCharCountNoSpaces                  = '문자 (%s | 공백 제외)';
  SLineCount                          = '줄 수';
  SWordCount                          = '단어 수';
  SCharTypes                          = '문자 종류:';

// 한글
  SHangul                             = '한글';
  SHangulConsonant                    = '자음';
  SHangulVowel                        = '모음';

// 한자
  SHanja                              = '한자';

// 영문
  SEnglish                            = '영문';
  SEnglishLowercase                   = '소문자';
  SEnglishUppercase                   = '대문자';

// 숫자
  SDigit                              = '숫자';

// 특수 문자
  SSpecialChar                        = '특수 문자';

// 공백
  SSpace                              = '공백';
  SSpaceStandard                      = '스페이스';
  SSpaceOther                         = '기타';

// 단위
  SUnitChar                           = '자';
  SUnitByte                           = '바이트';
  SUnitLine                           = '줄';
  SUnitWord                           = '개';

// uAppStatusBar
  SCaret                              = '줄 %d, 열 %d';
  SNotAvailable                       = 'N/A';
  SSeparator                          = ' | ';

implementation

end.

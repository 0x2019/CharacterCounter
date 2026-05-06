unit uAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.MMSystem, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,

  uMetaballs;

const
  FORM_WIDTH = 314;
  FORM_HEIGHT = 124;
  TEXT_LEFT = 0;

type
  TfrmAbout = class(TForm)
  private
    FMetaballs: TMetaballs;
    FLock: TRTLCriticalSection;
    FThread: TThread;
    FScrollDirection: Integer;
    FScrollPos: Integer;
    FTextHeight: Integer;
    FAboutText: string;

    procedure DrawText;
    procedure Init;
    procedure Free;
    procedure Loop;

    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMRButtonDown(var Msg: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMKeyDown(var Msg: TWMKeyDown); message WM_KEYDOWN;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoCreate; override;
    procedure DoShow; override;
    procedure DoClose(var Action: TCloseAction); override;
    procedure DoDestroy; override;
  end;

var
  frmAbout: TfrmAbout;

implementation

{$R *.dfm}

uses
  uAppStrings;

procedure TfrmAbout.DoCreate;
begin
  inherited;
  BorderStyle := bsNone;
  Position := poMainFormCenter;
  ClientWidth := FORM_WIDTH;
  ClientHeight := FORM_HEIGHT;
  ControlStyle := ControlStyle + [csClickEvents, csCaptureMouse, csDoubleClicks, csOpaque];

  AlphaBlend := True;
  AlphaBlendValue := 0;

  InitializeCriticalSection(FLock);
  FillChar(FMetaballs, SizeOf(FMetaballs), 0);

  Init;
end;

procedure TfrmAbout.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := WS_POPUP or WS_BORDER;
  Params.WindowClass.Style := Params.WindowClass.Style or CS_HREDRAW or CS_VREDRAW;
end;

procedure TfrmAbout.DoShow;
begin
  inherited;
  Cursor := crArrow;
  timeBeginPeriod(1);

  FThread := TThread.CreateAnonymousThread(Loop);
  FThread.FreeOnTerminate := False;
  FThread.Start;
  SetThreadPriority(FThread.Handle, THREAD_PRIORITY_NORMAL);
end;

procedure TfrmAbout.DoClose(var Action: TCloseAction);
begin
  Free;
  timeEndPeriod(1);
  inherited;
end;

procedure TfrmAbout.DoDestroy;
begin
  DeleteCriticalSection(FLock);
  inherited;
end;

procedure TfrmAbout.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TfrmAbout.WMLButtonDown(var Msg: TWMLButtonDown);
begin
  Close;
end;

procedure TfrmAbout.WMRButtonDown(var Msg: TWMRButtonDown);
begin
  Close;
end;

procedure TfrmAbout.WMKeyDown(var Msg: TWMKeyDown);
begin
  if Msg.CharCode = VK_ESCAPE then
    Close;
end;

procedure TfrmAbout.WMPaint(var Msg: TWMPaint);
var
  PaintStruct: TPaintStruct;
  WindowDC: HDC;
begin
  WindowDC := BeginPaint(Handle, PaintStruct);
  try
    if Metaballs_HasBuffer(FMetaballs) then
    begin
      EnterCriticalSection(FLock);
      try
        Metaballs_DrawBuffer(FMetaballs, WindowDC);
      finally
        LeaveCriticalSection(FLock);
      end;

      if AlphaBlendValue = 0 then
        AlphaBlendValue := 255;
    end
    else
    begin
      FillRect(WindowDC, ClientRect, GetStockObject(BLACK_BRUSH));
    end;
  finally
    EndPaint(Handle, PaintStruct);
  end;
end;

procedure TfrmAbout.DrawText;
const
  NL = sLineBreak;
  N2 = NL + NL;
  N3 = NL + NL + NL;
  N10 = N3 + N3 + N3 + NL;
begin
  FAboutText := Concat(
    NL,
    APP_NAME, NL,
    APP_VERSION, NL,
    N10,
    'c0ded by:', NL,
    '?', N10,
    'Release Date:', NL,
    APP_RELEASE, N10,
    'Music:', NL,
    'Tiger M. Hi-score', N10,
    '-= [Greetz fly out to] =-', N10,
    'A***', NL,
    'M****', NL,
    'O*******', NL,
    'P****', NL,
    'S*****', NL,
    'T**', NL,
    'X*****', NL,
    'Z*****', NL,
    'and you.', N10,
    'Have fun with this', NL,
    'and', NL,
    'have a nice day.', N10,
    APP_URL, N3
  );
end;

procedure TfrmAbout.Init;
begin
  DrawText;
  Metaballs_Init(FMetaballs, FORM_WIDTH, FORM_HEIGHT, METABALLS_INITIAL_SEED);

  FScrollPos := FORM_HEIGHT;
  FScrollDirection := -1;
  FTextHeight := Metaballs_GetTextHeight(FMetaballs, FAboutText);

  if FTextHeight <= 0 then
    FTextHeight := FORM_HEIGHT;

  EnterCriticalSection(FLock);
  try
    Metaballs_Draw(FMetaballs, FAboutText, FScrollPos, TEXT_LEFT);
  finally
    LeaveCriticalSection(FLock);
  end;
end;

procedure TfrmAbout.Free;
begin
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
  Metaballs_Free(FMetaballs);
end;

procedure TfrmAbout.Loop;
begin
  Metaballs_Loop(FMetaballs, FThread, Handle, @FLock, FAboutText,
    FScrollPos, FScrollDirection, FTextHeight, TEXT_LEFT, FORM_HEIGHT);
end;

end.

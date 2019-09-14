program mgtest;

{$ifdef FPC}{$mode tp}{$endif}
{$ifdef VER70}{$X+}{$F+}{$endif}

uses
  UG_FONTS,
  UG,
  UG_TYPES,
  GRAPH,
  CRT;

var
  gui: UG_GUI;
  grmode, grdriver: integer;
  x, y: integer;

  ugWnd: UG_WINDOW;
  ugObj: array[0..19] of UG_OBJECT;

  procedure WndCallBack(msg: PUG_MESSAGE);
  begin
  end;

  procedure pset(x: UG_S16; y: UG_S16; c: UG_COLOR);
  begin
    PutPixel(x, y, Word(c));
  end;

  function DrawLine(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR): UG_RESULT;
  var
    clr: Word;
  begin
    clr := GetColor;
    SetColor(Word(c));
    Line(x1, y1, x2, y2);
    SetColor(clr);
    DrawLine := 1;
  end;

  function FillFrame(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR): UG_RESULT;
  var
    clr: Word;
  begin
    clr := GetColor;
    setfillstyle(12, Word(c));
    SetColor(Word(c));
    Bar(x1, y1, x2, y2);
    SetColor(clr);
    FillFrame := 1;
  end;

begin
  grdriver := DETECT;
{$ifdef FPC}
  initgraph(grdriver, grmode, ' ');
{$endif}
{$ifdef VER70}
  initgraph(grdriver, grmode, 'C:\TP7\BGI');
{$endif}
  UG_Init(gui, pset, getmaxx + 1, getmaxy + 1);
  UG_DriverRegister(0, @DrawLine);
  (* UG_DriverRegister(1, @FillFrame); *)
  UG_SetBackcolor(black);
  UG_SetForecolor(blue);
  UG_FontSelect(@FONT_8X14);
  UG_PutString(100, 100, 'Hello, Pascal!');
  UG_FontSelect(@FONT_16X26);
  UG_PutString(140, 140, 'Hello, Pascal!');
(*
  UG_DrawLine(4, 10, 400, 10, white);
  UG_FillFrame(4, 200, 400, 300, blue);
  UG_DrawCircle(250, 400, 100, white);
  UG_FillCircle(250, 400, 80, white);
*)
  UG_ConsoleSetArea(getmaxx div 2, getmaxy div 2, getmaxx - 2, getmaxy - 2);
  UG_ConsoleSetForecolor(blue);
  UG_ConsoleSetBackcolor(white);
  UG_ConsolePutString('High Voltage' + #10);
  UG_ConsolePutString('Rebooting...' + #10);
  UG_ConsolePutString('Please, wait...');
  ReadLn;

  UG_WindowCreate(ugWnd, @ugObj[0], 20, WndCallBack);
  UG_WindowSetTitleText(ugWnd, 'uGUI Demo Window');
  UG_WindowSetTitleTextFont(ugWnd, @FONT_8X14);
  UG_WindowSetForeColor(ugWnd, black);
  UG_WindowSetBackColor(ugWnd, green);
  UG_WindowSetTitleTextColor(ugWnd, blue);
  UG_WindowSetTitleColor(ugWnd, white);
  UG_WindowResize(ugWnd, 40, 40, getmaxx - 40, getmaxy - 40);
  UG_WindowShow(ugWnd);
  UG_Update;
  ReadLn;

  UG_WindowAlert(ugWnd);
  UG_Update;
  ReadLn;
  CloseGraph;
end.

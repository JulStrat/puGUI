program mgtest;

{$ifdef FPC}{$mode tp}{$endif}
{$ifdef VER70}{$X+}{$F+}{$endif}
{$I UG_CFG.inc}

uses
  UG_TYPES, UG_FONTS, UG,
{$ifdef FPC}
  PTCGRAPH, PTCCRT, PTCMOUSE;
{$endif}
{$ifdef VER70}
  GRAPH, CRT;
{$endif}

{$I logo.inc}

{$I Tuffy_20X32.inc}
{$I Tuffy_43X68.inc}

var
  gui: UG_GUI;
  grmode, grdriver: integer;
  mx, my, mbtn: LongInt;
  palSize: integer;
  ch: Char;

  ugWnd: UG_WINDOW;
  {$ifdef UG_USE_BTN}
  ugBtn: UG_BUTTON;
  ugBtn2: UG_BUTTON;
  {$endif}
  {$ifdef UG_USE_TXB}
  ugTbox: UG_TEXTBOX;
  ugTbox1: UG_TEXTBOX;
  {$endif}
  ugObj: array[0..19] of UG_OBJECT;

  ugWndReg: UG_WINDOW;
  ugObjReg: array[0..19] of UG_OBJECT;
  ugImg: UG_IMAGE;

  procedure WndCallBack(msg: PUG_MESSAGE);
  begin
    if msg^.mtype = MSG_TYPE_OBJECT then
      if msg^.id = Ord(OBJ_TYPE_BUTTON) then
        if msg^.sub_id = Ord(BTN_ID_0) then
          UG.UG_ConsolePutString('BTN_ID_0' + #10)
        else
          if msg^.sub_id = Ord(BTN_ID_1) then
            UG.UG_ConsolePutString('BTN_ID_1' + #10);
  end;

  procedure pset(x: UG_S16; y: UG_S16; c: UG_COLOR);
  begin
    PutPixel(x, y, c);
  end;

  function DrawLine(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR): UG_RESULT;
  var
    clr: byte;
  begin
    (* clr := GetColor; *)
    SetColor(c);
    Line(x1, y1, x2, y2);
    (* SetColor(clr); *)
    DrawLine := RESULT_OK;
  end;

  function FillFrame(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR): UG_RESULT;
  var
    clr: byte;
  begin
    (* clr := GetColor; *)
    Setfillstyle(SolidFill, c);
    (* SetColor(c); *)
    Bar(x1, y1, x2, y2);
    (* SetColor(clr); *)
    FillFrame := RESULT_OK;
  end;

begin
  (* WriteLn('SizeOf(Integer) - ', SizeOf(Integer)); *)
  (* WriteLn('SizeOf(ShortInt) - ', SizeOf(ShortInt)); *)
  grdriver := DETECT;
  { DetectGraph(grdriver, grdriver); }
{$ifdef FPC}
  grdriver := D16bit;
  grmode := m800x600;
//  grmode := m1024x768;
  initgraph(grdriver, grmode, '.');
{$endif}
{$ifdef VER70}
  initgraph(grdriver, grmode, 'C:\TP7\BGI');
{$endif}
//  SetWriteMode(CopyPut);
  palSize := GetPaletteSize;
  (* WriteLn('Palette size - ', palSize); *)

  UG_Init(gui, pset, getmaxx + 1, getmaxy + 1);
//  UG_DriverRegister(0, @DrawLine);
//  UG_DriverRegister(1, @FillFrame);
  UG_SetForecolor(white);
  UG_SetForecolor(C_WHITE);
  UG_SetBackcolor(black);

  UG_FontSelect(@FONT_8X14);
  UG_PutString(10, 100, 'Powered by Free Pascal. Font - FONT_8X14.');
  UG_FontSelect(@FONT_16X26);
  UG_PutString(10, 140, 'Powered by Free Pascal. Font - FONT_16X26.');

(*
  UG_DrawLine(0, 0, getmaxx, getmaxy, $F79E);
  UG_FillFrame(4, 200, 400, 300, blue);
  UG_DrawCircle(250, 400, 100, white);
  UG_FillCircle(250, 400, 80, white);
*)
  UG_ConsoleSetArea(0, 3 * (getmaxy div 4), getmaxx - 2, getmaxy - 2);
  UG_ConsoleSetForecolor(C_BLUE);
  UG_ConsoleSetBackcolor(C_WHITE);
  UG_FontSelect(@FONT_Tuffy_20X32);
  UG_ConsolePutString('Tuffy_20X32 font. ');
  UG_ConsoleSetForecolor(C_RED);
  UG_ConsolePutString('High Voltage' + #10);
  UG_ConsolePutString('Rebooting...' + #10);
  UG_ConsoleSetForecolor(C_DARK_GREEN);
  UG_ConsolePutString('Please, wait...');

  {$ifdef FPC}
  ch := ReadKey();
  {$endif}
  {$ifdef VER70}
  ReadLn;
  {$endif}

  UG_WindowCreate(ugWnd, @ugObj[0], 20, WndCallBack);
  UG_WindowSetTitleText(ugWnd, 'uGUI Demo Window');
  UG_WindowSetTitleTextFont(ugWnd, @FONT_8X14);

  UG_WindowSetForeColor(ugWnd, black);
  UG_WindowSetBackColor(ugWnd, C_LIGHT_GRAY);
  UG_WindowSetTitleTextColor(ugWnd, C_BLACK);
  UG_WindowSetTitleColor(ugWnd, C_MOCCASIN);

  UG_WindowSetTitleTextHSpace(ugWnd, 10);
  UG_WindowResize(ugWnd, 40, 40, getmaxx - 40, getmaxy - 40);
  UG_WindowShow(ugWnd);

{$ifdef UG_USE_BTN}
  UG_ButtonCreate(ugWnd, ugBtn, BTN_ID_0, 10, 10, 210, 50);
  UG_ButtonSetText(ugWnd, BTN_ID_0, 'Open door');
  UG_ButtonSetForeColor(ugWnd, BTN_ID_0, C_BLACK);
  UG_ButtonSetBackColor(ugWnd, BTN_ID_0, C_GRAY);
  (* UG_ButtonShow(ugWnd, BTN_ID_0); *)

  UG_ButtonCreate(ugWnd, ugBtn2, BTN_ID_1, 310, 10, 510, 50);
  UG_ButtonSetText(ugWnd, BTN_ID_1, 'Close window');
  UG_ButtonSetForeColor(ugWnd, BTN_ID_1, C_BLACK);
  UG_ButtonSetBackColor(ugWnd, BTN_ID_1, C_GRAY);
  (* UG_ButtonShow(ugWnd, BTN_ID_1); *)

{$endif}

{$ifdef UG_USE_TXB}
  UG_TextboxCreate(ugWnd, ugTbox, TXB_ID_0, 10, 60, 210, 100);
  UG_TextboxSetForeColor(ugWnd, TXB_ID_0, C_BLUE);
  UG_TextboxSetBackColor(ugWnd, TXB_ID_0, C_GHOST_WHITE);
  UG_TextboxSetText(ugWnd, TXB_ID_0, 'Closed');

  UG_TextboxCreate(ugWnd, ugTbox1, TXB_ID_1, 310, 60, 510, 100);
  UG_TextboxSetForeColor(ugWnd, TXB_ID_1, C_BLUE);
  UG_TextboxSetBackColor(ugWnd, TXB_ID_1, C_GHOST_WHITE);
  UG_TextboxSetText(ugWnd, TXB_ID_1, 'Opened');

{$endif}
  UG_WindowShow(ugWnd);
  UG_Update;

  {$ifdef FPC}
    while not PTCCrt.KeyPressed do
    begin
      if PTCMouse.LPressed then
      begin
        PTCMouse.GetMouseState(mx, my, mbtn);
        UG_TouchUpdate(mx, my, TOUCH_STATE_PRESSED);
      end
      else
        UG_TouchUpdate(-1 , -1, TOUCH_STATE_RELEASED );
      UG_Update;
    end;
    ch := PTCCrt.ReadKey;
  {$endif}
  {$ifdef VER70}
    ReadLn;
  {$endif}

  UG_WindowCreate(ugWndReg, @ugObjReg[0], 20, WndCallBack);
  UG_WindowSetTitleText(ugWndReg, 'Registers Window');
  UG_WindowSetTitleTextFont(ugWndReg, @FONT_8X14);
  UG_WindowSetForeColor(ugWndReg, black);
  UG_WindowSetBackColor(ugWndReg, C_LIGHT_GRAY);
  UG_WindowSetTitleTextColor(ugWndReg, C_BLACK);
  UG_WindowSetTitleColor(ugWndReg, C_MOCCASIN);
  UG_WindowResize(ugWndReg, 140, 140, getmaxx - 140, getmaxy - 140);

  UG_ImageCreate(ugWndReg, ugImg, IMG_ID_0, 10, 10, 0, 0);
  UG_ImageSetBMP(ugWndReg, IMG_ID_0, @logo);
  UG_WindowShow(ugWndReg);
  UG_Update;

  (*
  WriteLn(UG_WindowGetXStart(ugWnd), ',', UG_WindowGetYStart(ugWnd), ',',
    UG_WindowGetXEnd(ugWnd), ',', UG_WindowGetYEnd(ugWnd));
  *)
  {$ifdef FPC}
    while not PTCCrt.KeyPressed do
    begin
      if PTCMouse.LPressed then
      begin
        PTCMouse.GetMouseState(mx, my, mbtn);
        UG_TouchUpdate(mx, my, TOUCH_STATE_PRESSED);
      end
      else
        UG_TouchUpdate(-1 , -1, TOUCH_STATE_RELEASED );
      UG_Update;
    end;
    ch := PTCCrt.ReadKey;
  {$endif}
  {$ifdef VER70}
    ReadLn;
  {$endif}

(*
  UG_WindowShow(ugWnd);
  UG_WindowAlert(ugWnd);
  UG_Update;

{$ifdef FPC}
  ch := ReadKey();
{$endif}
{$ifdef VER70}
  ReadLn;
{$endif}

  UG_WindowShow(ugWndReg);
  UG_WindowAlert(ugWndReg);
  UG_Update;

{$ifdef FPC}
  while not PTCCrt.KeyPressed do
  begin
    if PTCMouse.LPressed then
    begin
      PTCMouse.GetMouseState(mx, my, mbtn);
      UG_TouchUpdate(mx, my, TOUCH_STATE_PRESSED ) ;
    end
    else
      UG_TouchUpdate(-1 , -1, TOUCH_STATE_RELEASED );

    UG_Update;
  end;
{$endif}
{$ifdef VER70}
  ReadLn;
{$endif}

*)
  CloseGraph;
end.

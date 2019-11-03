program mgtest;

{$ifdef FPC}{$mode tp}{$endif}
{$ifdef VER70}{$X+}{$F+}{$endif}
{$I UG_CFG.inc}

uses
  UG_TYPES, UG_FONTS, UG, baseunix;

{$I logo.inc}
{$I Tuffy_20X32.inc}
{$I Tuffy_43X68.inc}

const 
  fbdev = '/dev/fb0';
  SCR_WIDTH = 1824;
  SCR_HEIGHT = 984;

var
  gui: UG_GUI;

(* fb *)
  fd: cint;
  scr: PUG_COLOR;

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
  {$endif}
  ugObj: array[0..19] of UG_OBJECT;

  ugWndReg: UG_WINDOW;
  ugObjReg: array[0..19] of UG_OBJECT;
  ugImg: UG_IMAGE;

  procedure WndCallBack(msg: PUG_MESSAGE);
  begin
  end;

  procedure pset(x: UG_S16; y: UG_S16; c: UG_COLOR);
  var
    t: PUG_COLOR;
  begin
    t := scr;
    Inc(t, SCR_WIDTH*y + x);
    t^ := c;
  end;

{
  function DrawLine(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR): UG_RESULT;
  var
    clr: byte;
  begin
    (* clr := GetColor; *)
    SetColor(c);
    Line(x1, y1, x2, y2);
    (* SetColor(clr); *)
    DrawLine := UG_RESULT_OK;
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
    FillFrame := UG_RESULT_OK;
  end;
}

begin
  fd := fpOpen(fbdev, O_RDWR);
  scr := PUG_COLOR(fpmmap(nil, SCR_WIDTH*SCR_HEIGHT*SizeOf(UG_COLOR), PROT_READ or PROT_WRITE, MAP_SHARED, fd, 0));
(*
  WriteLn('SizeOf(Integer) - ', SizeOf(Integer));
  WriteLn('SizeOf(ShortInt) - ', SizeOf(ShortInt));
*)
  UG_Init(gui, pset, SCR_WIDTH, SCR_HEIGHT);
(*  
  UG_DriverRegister(0, @DrawLine);
  UG_DriverRegister(1, @FillFrame);
*)
  UG_FillScreen(C_BLACK);
  UG_SetForecolor(C_WHITE);
  UG_SetBackcolor(C_BLACK);

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
  UG_ConsoleSetArea(0, 3 * (SCR_HEIGHT div 4), SCR_WIDTH - 1, SCR_HEIGHT - 1);
  UG_ConsoleSetForecolor(C_BLUE);
  UG_ConsoleSetBackcolor(C_WHITE);
  UG_FontSelect(@FONT_Tuffy_20X32);
  UG_ConsolePutString('Tuffy_20X32 font. ');
  UG_ConsoleSetForecolor(C_RED);
  UG_ConsolePutString('High Voltage' + #10);
  UG_ConsolePutString('Rebooting...' + #10);
  UG_ConsoleSetForecolor(C_DARK_GREEN);
  UG_ConsolePutString('Please, wait...');
  
  {$ifdef WINDOWS}
  ch := ReadKey();
  {$endif}
  {$ifdef FPC}
  ReadLn;
  {$endif}

  UG_WindowCreate(ugWnd, @ugObj[0], 20, WndCallBack);
  UG_WindowSetTitleText(ugWnd, 'uGUI Demo Window');
  UG_WindowSetTitleTextFont(ugWnd, @FONT_8X14);

  UG_WindowSetForeColor(ugWnd, C_BLACK);
  UG_WindowSetBackColor(ugWnd, C_LIGHT_GRAY);
  UG_WindowSetTitleTextColor(ugWnd, C_BLACK);
  UG_WindowSetTitleColor(ugWnd, C_MOCCASIN);

  UG_WindowSetTitleTextHSpace(ugWnd, 10);
  UG_WindowResize(ugWnd, 40, 40, SCR_WIDTH - 40, SCR_HEIGHT - 140);
  UG_WindowShow(ugWnd);

{$ifdef UG_USE_BTN}
  UG_ButtonCreate(ugWnd, ugBtn, BTN_ID_0, 10, 10, 210, 50);
  UG_ButtonSetText(ugWnd, BTN_ID_0, 'Open door');
  UG_ButtonSetForeColor(ugWnd, BTN_ID_0, C_BLACK);
  UG_ButtonSetBackColor(ugWnd, BTN_ID_0, C_GRAY);
  (* UG_ButtonShow(ugWnd, BTN_ID_0); *)

  UG_ButtonCreate(ugWnd, ugBtn2, BTN_ID_1, 210, 10, 410, 50);
  UG_ButtonSetText(ugWnd, BTN_ID_1, 'Close window');
  UG_ButtonSetForeColor(ugWnd, BTN_ID_1, C_BLACK);
  UG_ButtonSetBackColor(ugWnd, BTN_ID_1, C_GRAY);
  (* UG_ButtonShow(ugWnd, BTN_ID_1); *)
{$endif}

{$ifdef UG_USE_TXB}
  UG_TextboxCreate(ugWnd, ugTbox, TXB_ID_0, 10, 60, 210, 100);
  UG_TextboxSetForeColor(ugWnd, TXB_ID_0, C_BLUE);
  UG_TextboxSetBackColor(ugWnd, TXB_ID_0, C_GHOST_WHITE);
  UG_TextboxSetText(ugWnd, TXB_ID_0, 'UG Text Box');
{$endif}
  UG_WindowShow(ugWnd);
  UG_Update;

  {$ifdef WINDOWS}
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
  {$ifdef FPC}
    ReadLn;
  {$endif}

  UG_WindowCreate(ugWndReg, @ugObjReg[0], 20, WndCallBack);
  UG_WindowSetTitleText(ugWndReg, 'Registers Window');
  UG_WindowSetTitleTextFont(ugWndReg, @FONT_8X14);
  UG_WindowSetForeColor(ugWndReg, C_BLACK);
  UG_WindowSetBackColor(ugWndReg, C_LIGHT_GRAY);
  UG_WindowSetTitleTextColor(ugWndReg, C_BLACK);
  UG_WindowSetTitleColor(ugWndReg, C_MOCCASIN);
  UG_WindowResize(ugWndReg, 140, 140, SCR_WIDTH - 140, SCR_HEIGHT - 240);

  UG_ImageCreate(ugWndReg, ugImg, IMG_ID_0, 10, 10, 0, 0);
  UG_ImageSetBMP(ugWndReg, IMG_ID_0, @logo);
  UG_WindowShow(ugWndReg);
  UG_Update;

  (*
  WriteLn(UG_WindowGetXStart(ugWnd), ',', UG_WindowGetYStart(ugWnd), ',',
    UG_WindowGetXEnd(ugWnd), ',', UG_WindowGetYEnd(ugWnd));
  *)
  {$ifdef WINDOWS}
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
  {$ifdef FPC}
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

  fpmunmap(scr, SCR_WIDTH*SCR_HEIGHT*SizeOf(UG_COLOR));
  fpclose(fd);
end.

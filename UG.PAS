(* Original C code license                                                          *)
(* -------------------------------------------------------------------------------- *)
(* -- µGUI - Generic GUI module (C)Achim Döbler, 2015                            -- *)
(* -------------------------------------------------------------------------------- *)
(* µGUI is a generic GUI module for embedded systems.                               *)
(* This is a free software that is open for education, research and commercial      *)
(* developments under license policy of following terms.                            *)
(**)
(*  Copyright (C) 2015, Achim Döbler, all rights reserved.                          *)
(*  URL: http://www.embeddedlightning.com/                                          *)
(**)
(* * The µGUI module is a free software and there is NO WARRANTY.                   *)
(* * No restriction on use. You can use, modify and redistribute it for             *)
(*   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.         *)
(* * Redistributions of source code must retain the above copyright notice.         *)
(**)
(* -------------------------------------------------------------------------------- *)
(* -- MY SPECIAL THANKS GO TO                                                    -- *)
(* -------------------------------------------------------------------------------- *)
(* Andrey Filimonov (-->https://github.com/Sermus)*)
(* for giving valuable suggestions, reporting bugs and adding several new features. *)
(* Andrey also put a lot of work in the implementaion of anti-aliased font support. *)
(**)
(* Mikhail Podkur (-->https://github.com/MikhailPodkur)                             *)
(* for adding cyrillic 8x12 font, checkbox feature and RGB565 support.              *)
(**)
(* Gustavo Denardin                                                                 *)
(* for giving valuable suggestions regarding real-time os support.                  *)
(**)
(* Samuel Kleiser                                                                   *)
(* for reporting bugs and giving examples how to improve µGUI.                      *)
(* -------------------------------------------------------------------------------- *)
(* -- REVISION HISTORY                                                           -- *)
(* -------------------------------------------------------------------------------- *)
(*  Dec 20, 2015  V0.31 Checkbox component with all funtions added.                 *)
(*                      Cyrillic font 8x12 added.                                   *)
(*                      RGB565 color schema added.                                  *)
(*                      Windows components font could be getted from current GUI
                        by default                                                  *)
(*  Mar 18, 2015  V0.3  Driver support added.                                       *)
(*                      Window and object support added.                            *)
(*                      Touch support added.                                        *)
(*                      Fixed some minor bugs.                                      *)
(**)
(*  Oct 20, 2014  V0.2  Function UG_DrawRoundFrame() added.                         *)
(*                      Function UG_FillRoundFrame() added.                         *)
(*                      Function UG_DrawArc() added.                                *)
(*                      Fixed some minor bugs.                                      *)
(**)
(*  Oct 11, 2014  V0.1  First release.                                              *)
(* -------------------------------------------------------------------------------- *)
(* Pascal Port (C) Ioulianos Kakoulidis                                             *)

unit UG;

{$ifdef FPC}{$mode tp}{$endif}
{$ifdef VER70}{$X+}{$endif}
{$I UG_CFG.inc}

interface

uses UG_FONTS, UG_TYPES
{$ifndef EMBEDDED}
{$ifdef FPC}, SysUtils (* Delay func *){$endif}
{$endif}
;

const
  UG_VERSION = 1;

  {$I UG_CLR.INC}
  (* Alignments *)
  ALIGN_H_LEFT = 1 shl 0;
  ALIGN_H_CENTER = 1 shl 1;
  ALIGN_H_RIGHT = 1 shl 2;
  ALIGN_V_TOP = 1 shl 3;
  ALIGN_V_CENTER = 1 shl 4;
  ALIGN_V_BOTTOM = 1 shl 5;
  ALIGN_BOTTOM_RIGHT = ALIGN_V_BOTTOM or ALIGN_H_RIGHT;
  ALIGN_BOTTOM_CENTER = ALIGN_V_BOTTOM or ALIGN_H_CENTER;
  ALIGN_BOTTOM_LEFT = ALIGN_V_BOTTOM or ALIGN_H_LEFT;
  ALIGN_CENTER_RIGHT = ALIGN_V_CENTER or ALIGN_H_RIGHT;
  ALIGN_CENTER = ALIGN_V_CENTER or ALIGN_H_CENTER;
  ALIGN_CENTER_LEFT = ALIGN_V_CENTER or ALIGN_H_LEFT;
  ALIGN_TOP_RIGHT = ALIGN_V_TOP or ALIGN_H_RIGHT;
  ALIGN_TOP_CENTER = ALIGN_V_TOP or ALIGN_H_CENTER;
  ALIGN_TOP_LEFT = ALIGN_V_TOP or ALIGN_H_LEFT;

  (* Default IDs *)
  OBJ_ID_0 = 0;
  OBJ_ID_1 = 1;
  OBJ_ID_2 = 2;
  OBJ_ID_3 = 3;
  OBJ_ID_4 = 4;
  OBJ_ID_5 = 5;
  OBJ_ID_6 = 6;
  OBJ_ID_7 = 7;
  OBJ_ID_8 = 8;
  OBJ_ID_9 = 9;
  OBJ_ID_10 = 10;
  OBJ_ID_11 = 11;
  OBJ_ID_12 = 12;
  OBJ_ID_13 = 13;
  OBJ_ID_14 = 14;
  OBJ_ID_15 = 15;
  OBJ_ID_16 = 16;
  OBJ_ID_17 = 17;
  OBJ_ID_18 = 18;
  OBJ_ID_19 = 19;

  UG_RESULT_FAIL = -1;
  UG_RESULT_OK = 0;

  MSG_TYPE_NONE = 0;
  MSG_TYPE_WINDOW = 1;
  MSG_TYPE_OBJECT = 2;

  TOUCH_STATE_PRESSED = 1;
  TOUCH_STATE_RELEASED = 0;

  OBJ_TYPE_NONE = 0;
  OBJ_TYPE_BUTTON = 1;
  OBJ_TYPE_TEXTBOX = 2;
  OBJ_TYPE_IMAGE = 3;
  OBJ_TYPE_CHECKBOX = 4;

  (* Standard object events *)
  OBJ_EVENT_NONE = 0;
  OBJ_EVENT_CLICKED = 1;

{$ifdef USE_PRERENDER_EVENT}
  OBJ_EVENT_PRERENDER = 2;
{$endif}
{$ifdef USE_POSTRENDER_EVENT}
  OBJ_EVENT_POSTRENDER = 3;
{$endif}
  OBJ_EVENT_PRESSED = 4;
  OBJ_EVENT_RELEASED = 5;

  (* Object states *)
  OBJ_STATE_FREE = 1 shl 0;
  OBJ_STATE_VALID = 1 shl 1;
  OBJ_STATE_BUSY = 1 shl 2;
  OBJ_STATE_VISIBLE = 1 shl 3;
  OBJ_STATE_ENABLE = 1 shl 4;
  OBJ_STATE_UPDATE = 1 shl 5;
  OBJ_STATE_REDRAW = 1 shl 6;
  OBJ_STATE_TOUCH_ENABLE = 1 shl 7;
  OBJ_STATE_INIT = OBJ_STATE_FREE or OBJ_STATE_VALID;

  (* Object touch states *)
  OBJ_TOUCH_STATE_CHANGED = 1 shl 0;
  OBJ_TOUCH_STATE_PRESSED_ON_OBJECT = 1 shl 1;
  OBJ_TOUCH_STATE_PRESSED_OUTSIDE_OBJECT = 1 shl 2;
  OBJ_TOUCH_STATE_RELEASED_ON_OBJECT = 1 shl 3;
  OBJ_TOUCH_STATE_RELEASED_OUTSIDE_OBJECT = 1 shl 4;
  OBJ_TOUCH_STATE_IS_PRESSED_ON_OBJECT = 1 shl 5;
  OBJ_TOUCH_STATE_IS_PRESSED = 1 shl 6;
  OBJ_TOUCH_STATE_CLICK_ON_OBJECT = 1 shl 7;
  OBJ_TOUCH_STATE_INIT = 0;

  (* Window states *)
  WND_STATE_FREE = 1 shl 0;
  WND_STATE_VALID = 1 shl 1;
  WND_STATE_BUSY = 1 shl 2;
  WND_STATE_VISIBLE = 1 shl 3;
  WND_STATE_ENABLE = 1 shl 4;
  WND_STATE_UPDATE = 1 shl 5;
  WND_STATE_REDRAW_TITLE = 1 shl 6;

  (* Window styles *)
  WND_STYLE_2D = 0 shl 0;
  WND_STYLE_3D = 1 shl 0;
  WND_STYLE_HIDE_TITLE = 0 shl 1;
  WND_STYLE_SHOW_TITLE = 1 shl 1;

  UG_SATUS_WAIT_FOR_UPDATE = 1 shl 0;

  DRIVER_REGISTERED = 1 shl 0;
  DRIVER_ENABLED = 1 shl 1;

  (* Supported drivers *)
  NUMBER_OF_DRIVERS = 3;
  DRIVER_DRAW_LINE = 0;
  DRIVER_FILL_FRAME = 1;
  DRIVER_FILL_AREA = 2;

type

  (* S_OBJECT = record end; *)
  PUG_OBJECT = ^UG_OBJECT;
  PUG_WINDOW = ^UG_WINDOW;

  (* UG_OBJECT = S_OBJECT; *)
  (* S_WINDOW = record end; *)

  (* UG_WINDOW = S_WINDOW; *)
  UG_RESULT = UG_S8;

  PUG_COLOR = ^UG_COLOR;
  {$ifdef USE_COLOR_RGB888}
  UG_COLOR = UG_U32;
  {$endif}
  {$ifdef USE_COLOR_RGB565}
  UG_COLOR = UG_U16;
  {$endif}


  (* -------------------------------------------------------------------------- *)
  (* -- UNIVERSAL STRUCTURES                                                 -- *)
  (* -------------------------------------------------------------------------- *)
  (* Area structure *)

  UG_AREA = record
    xs: UG_S16;
    ys: UG_S16;
    xe: UG_S16;
    ye: UG_S16;
  end;

  (* Text structure *)
  PUG_TEXT = ^UG_TEXT;

  UG_TEXT = record
    str: PChar;
    font: PUG_FONT;
    a: UG_AREA;
    fc: UG_COLOR;
    bc: UG_COLOR;
    align: UG_U8;
    h_space: UG_S16;
    v_space: UG_S16;
  end;

  (* -------------------------------------------------------------------------------- *)
  (* -- MESSAGE                                                                    -- *)
  (* -------------------------------------------------------------------------------- *)
  (* Message structure *)
  PUG_MESSAGE = ^UG_MESSAGE;

  UG_MESSAGE = record
    mtype: UG_U8;
    id: UG_U8;
    sub_id: UG_U8;
    event: UG_U8;
    src: PUG_U8;
  end;

  (* -------------------------------------------------------------------------------- *)
  (* -- TOUCH                                                                      -- *)
  (* -------------------------------------------------------------------------------- *)
  (* Touch structure *)
  UG_TOUCH = record
    state: UG_U8;
    xp: UG_S16;
    yp: UG_S16;
  end;

  (* -------------------------------------------------------------------------------- *)
  (* -- OBJECTS                                                                    -- *)
  (* -------------------------------------------------------------------------------- *)
  (* Object structure *)

  PUG_CALLBACK = ^UG_CALLBACK;
  UG_CALLBACK = procedure(w: PUG_WINDOW; o: PUG_OBJECT);

  S_OBJECT = record
    state: UG_U8;         (* object state                               *)
    touch_state: UG_U8;   (* object touch state                         *)
    update: UG_CALLBACK;  (* pointer to object-specific update function *)
    a_abs: UG_AREA;       (* absolute area of the object                *)
    a_rel: UG_AREA;       (* relative area of the object                *)
    otype: UG_U8;         (* object type                                *)
    id: UG_U8;            (* object ID                                  *)
    event: UG_U8;         (* object-specific events                     *)
    Data: PUG_U8;         (* pointer to object-specific data            *)
  end;
  UG_OBJECT = S_OBJECT;

  (* Currently supported objects *)

  (* ------------------------------------------------------------------------ *)
  (* -- WINDOW                                                             -- *)
  (* ------------------------------------------------------------------------ *)
  (* Title structure *)
  UG_TITLE = record
    str: PChar;
    font: PUG_FONT;
    h_space: UG_S8;
    v_space: UG_S8;
    align: UG_U8;
    fc: UG_COLOR;
    bc: UG_COLOR;
    ifc: UG_COLOR;
    ibc: UG_COLOR;
    Height: UG_U8;
  end;

  (* Window structure *)
  UG_WINDOW_CB = procedure(msg: PUG_MESSAGE);

  S_WINDOW = record
    objcnt: UG_U8;
    objlst: PUG_OBJECT;
    state: UG_U8;
    fc: UG_COLOR;
    bc: UG_COLOR;
    xs: UG_S16;
    ys: UG_S16;
    xe: UG_S16;
    ye: UG_S16;
    style: UG_U8;
    title: UG_TITLE;
    cb: UG_WINDOW_CB;
  end;
  UG_WINDOW = S_WINDOW;

(* -------------------------------------------------------------------------- *)
(* -- µGUI DRIVER                                                          -- *)
(* -------------------------------------------------------------------------- *)
type
  UG_DRIVER = record
    driver: Pointer;
    state: UG_U8;
  end;

  (* ------------------------------------------------------------------------ *)
  (* -- µGUI CORE STRUCTURE                                                -- *)
  (* ------------------------------------------------------------------------ *)

  PUG_PSET = ^UG_PSET;
  UG_PSET = procedure(x, y: UG_S16; c: UG_COLOR);
  _HW_DRAWLINE = function(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR): UG_RESULT;
  _HW_FILLFRAME = function(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR): UG_RESULT;

  UG_CONSOLE = record
    x_pos: UG_S16;
    y_pos: UG_S16;
    x_start: UG_S16;
    y_start: UG_S16;
    x_end: UG_S16;
    y_end: UG_S16;
    fore_color: UG_COLOR;
    back_color: UG_COLOR;
  end;

  PUG_GUI = ^UG_GUI;

  UG_GUI = record
    pset: UG_PSET;
    x_dim: UG_S16;
    y_dim: UG_S16;
    touch: UG_TOUCH;
    next_window: PUG_WINDOW;
    active_window: PUG_WINDOW;
    last_window: PUG_WINDOW;
    console: UG_CONSOLE;
    font: UG_FONT;
    char_h_space: UG_S8;
    char_v_space: UG_S8;
    fore_color: UG_COLOR;
    back_color: UG_COLOR;
    desktop_color: UG_COLOR;
    state: UG_U8;
    driver: array[0..Pred(NUMBER_OF_DRIVERS)] of UG_DRIVER;
  end;

(* -------------------------------------------------------------------------- *)
(* -- PROTOTYPES                                                           -- *)
(* -------------------------------------------------------------------------- *)
(* Classic functions *)
function UG_Init(var g: UG_GUI; p: UG_PSET; x, y: UG_S16): UG_S16;
function UG_SelectGUI(g: PUG_GUI): UG_S16;
procedure UG_FontSelect(font: PUG_FONT);
procedure UG_FillScreen(c: UG_COLOR);
procedure UG_FillFrame(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR);
procedure UG_FillRoundFrame(x1, y1: UG_S16; x2, y2: UG_S16; r: UG_S16; c: UG_COLOR);
procedure UG_DrawMesh(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR);
procedure UG_DrawFrame(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR);
procedure UG_DrawRoundFrame(x1, y1: UG_S16; x2, y2: UG_S16; r: UG_S16; c: UG_COLOR);
procedure UG_DrawPixel(x0, y0: UG_S16; c: UG_COLOR);
procedure UG_DrawCircle(x0, y0: UG_S16; r: UG_S16; c: UG_COLOR);
procedure UG_FillCircle(x0, y0: UG_S16; r: UG_S16; c: UG_COLOR);
procedure UG_DrawArc(x0, y0: UG_S16; r: UG_S16; s: UG_U8; c: UG_COLOR);
procedure UG_DrawHLine(x1, x2, y: UG_S16; c: UG_COLOR);
procedure UG_DrawVLine(y1, y2, x: UG_S16; c: UG_COLOR);
procedure UG_DrawLine(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR);
procedure UG_PutString(x, y: UG_S16; str: PChar);
procedure UG_PutChar(chr: char; x, y: UG_S16; fc: UG_COLOR; bc: UG_COLOR);
procedure UG_SetForecolor(c: UG_COLOR);
procedure UG_SetBackcolor(c: UG_COLOR);
function UG_GetXDim: UG_S16;
function UG_GetYDim: UG_S16;
procedure UG_FontSetHSpace(s: UG_U16);
procedure UG_FontSetVSpace(s: UG_U16);

(* Console *)
procedure UG_ConsolePutString(str: PChar);
procedure UG_ConsoleSetArea(xs, ys: UG_S16; xe, ye: UG_S16);
procedure UG_ConsoleSetForecolor(c: UG_COLOR);
procedure UG_ConsoleSetBackcolor(c: UG_COLOR);

(* Window functions *)
function UG_WindowCreate(var wnd: UG_WINDOW; objlst: PUG_OBJECT;
  objcnt: UG_U8; cb: UG_WINDOW_CB): UG_RESULT;
function UG_WindowDelete(var wnd: UG_WINDOW): UG_RESULT;
function UG_WindowShow(var wnd: UG_WINDOW): UG_RESULT;
function UG_WindowHide(var wnd: UG_WINDOW): UG_RESULT;
function UG_WindowResize(var wnd: UG_WINDOW; xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT;
function UG_WindowAlert(var wnd: UG_WINDOW): UG_RESULT;

(* Window setters *)
function UG_WindowSetForeColor(var wnd: UG_WINDOW; fc: UG_COLOR): UG_RESULT;
function UG_WindowSetBackColor(var wnd: UG_WINDOW; bc: UG_COLOR): UG_RESULT;
function UG_WindowSetTitleTextColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
function UG_WindowSetTitleColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
function UG_WindowSetTitleInactiveTextColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
function UG_WindowSetTitleInactiveColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
function UG_WindowSetTitleText(var wnd: UG_WINDOW; str: PChar): UG_RESULT;
function UG_WindowSetTitleTextFont(var wnd: UG_WINDOW; font: PUG_FONT): UG_RESULT;
function UG_WindowSetTitleTextHSpace(var wnd: UG_WINDOW; hs: UG_S8): UG_RESULT;
function UG_WindowSetTitleTextVSpace(var wnd: UG_WINDOW; vs: UG_S8): UG_RESULT;
function UG_WindowSetTitleTextAlignment(var wnd: UG_WINDOW; align: UG_U8): UG_RESULT;
function UG_WindowSetTitleHeight(var wnd: UG_WINDOW; Height: UG_U8): UG_RESULT;
function UG_WindowSetXStart(var wnd: UG_WINDOW; xs: UG_S16): UG_RESULT;
function UG_WindowSetYStart(var wnd: UG_WINDOW; ys: UG_S16): UG_RESULT;
function UG_WindowSetXEnd(var wnd: UG_WINDOW; xe: UG_S16): UG_RESULT;
function UG_WindowSetYEnd(var wnd: UG_WINDOW; ye: UG_S16): UG_RESULT;
function UG_WindowSetStyle(var wnd: UG_WINDOW; style: UG_U8): UG_RESULT;

(* Window getters *)
function UG_WindowGetForeColor(const wnd: UG_WINDOW): UG_COLOR;
function UG_WindowGetBackColor(const wnd: UG_WINDOW): UG_COLOR;
function UG_WindowGetTitleTextColor(const wnd: UG_WINDOW): UG_COLOR;
function UG_WindowGetTitleColor(const wnd: UG_WINDOW): UG_COLOR;
function UG_WindowGetTitleInactiveTextColor(const wnd: UG_WINDOW): UG_COLOR;
function UG_WindowGetTitleInactiveColor(const wnd: UG_WINDOW): UG_COLOR;
function UG_WindowGetTitleText(const wnd: UG_WINDOW): PChar;
function UG_WindowGetTitleTextFont(const wnd: UG_WINDOW): PUG_FONT;
function UG_WindowGetTitleTextHSpace(const wnd: UG_WINDOW): UG_S8;
function UG_WindowGetTitleTextVSpace(const wnd: UG_WINDOW): UG_S8;
function UG_WindowGetTitleTextAlignment(const wnd: UG_WINDOW): UG_U8;
function UG_WindowGetTitleHeight(const wnd: UG_WINDOW): UG_U8;
function UG_WindowGetXStart(const wnd: UG_WINDOW): UG_S16;
function UG_WindowGetYStart(const wnd: UG_WINDOW): UG_S16;
function UG_WindowGetXEnd(const wnd: UG_WINDOW): UG_S16;
function UG_WindowGetYEnd(const wnd: UG_WINDOW): UG_S16;
function UG_WindowGetStyle(const wnd: UG_WINDOW): UG_U8;
function UG_WindowGetArea(const wnd: UG_WINDOW; var a: UG_AREA): UG_RESULT;
function UG_WindowGetInnerWidth(const wnd: UG_WINDOW): UG_S16;
function UG_WindowGetOuterWidth(const wnd: UG_WINDOW): UG_S16;
function UG_WindowGetInnerHeight(const wnd: UG_WINDOW): UG_S16;
function UG_WindowGetOuterHeight(const wnd: UG_WINDOW): UG_S16;

(* -------------------------------------------------------------------------- *)
(* -- BUTTON OBJECT                                                        -- *)
(* -------------------------------------------------------------------------- *)
(* Button structure *)
type
  PUG_BUTTON = ^UG_BUTTON;

  UG_BUTTON = record
    state: UG_U8;
    style: UG_U8;
    fc: UG_COLOR;
    bc: UG_COLOR;
    afc: UG_COLOR;
    abc: UG_COLOR;
    font: PUG_FONT;
    align: UG_U8;
    h_space: UG_S8;
    v_space: UG_S8;
    str: PChar;
  end;

const
  (* Default button IDs *)
  BTN_ID_0 = OBJ_ID_0;
  BTN_ID_1 = OBJ_ID_1;
  BTN_ID_2 = OBJ_ID_2;
  BTN_ID_3 = OBJ_ID_3;
  BTN_ID_4 = OBJ_ID_4;
  BTN_ID_5 = OBJ_ID_5;
  BTN_ID_6 = OBJ_ID_6;
  BTN_ID_7 = OBJ_ID_7;
  BTN_ID_8 = OBJ_ID_8;
  BTN_ID_9 = OBJ_ID_9;
  BTN_ID_10 = OBJ_ID_10;
  BTN_ID_11 = OBJ_ID_11;
  BTN_ID_12 = OBJ_ID_12;
  BTN_ID_13 = OBJ_ID_13;
  BTN_ID_14 = OBJ_ID_14;
  BTN_ID_15 = OBJ_ID_15;
  BTN_ID_16 = OBJ_ID_16;
  BTN_ID_17 = OBJ_ID_17;
  BTN_ID_18 = OBJ_ID_18;
  BTN_ID_19 = OBJ_ID_19;

  (* Button states *)
  BTN_STATE_RELEASED = 0 shl 0;
  BTN_STATE_PRESSED = 1 shl 0;
  BTN_STATE_ALWAYS_REDRAW = 1 shl 1;

  (* Button style *)
  BTN_STYLE_2D = 0 shl 0;
  BTN_STYLE_3D = 1 shl 0;
  BTN_STYLE_TOGGLE_COLORS = 1 shl 1;
  BTN_STYLE_USE_ALTERNATE_COLORS = 1 shl 2;
  BTN_STYLE_NO_BORDERS = 1 shl 3;
  BTN_STYLE_NO_FILL = 1 shl 4;

  (* Button events *)
  BTN_EVENT_CLICKED = OBJ_EVENT_CLICKED;

(* Button functions *)
function UG_ButtonCreate(const wnd: UG_WINDOW; var btn: UG_BUTTON;
  id: UG_U8; xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT;
function UG_ButtonDelete(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
function UG_ButtonShow(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
function UG_ButtonHide(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;

function UG_ButtonSetForeColor(const wnd: UG_WINDOW; id: UG_U8; fc: UG_COLOR): UG_RESULT;
function UG_ButtonSetBackColor(const wnd: UG_WINDOW; id: UG_U8; bc: UG_COLOR): UG_RESULT;
function UG_ButtonSetAlternateForeColor(const wnd: UG_WINDOW; id: UG_U8;
  afc: UG_COLOR): UG_RESULT;
function UG_ButtonSetAlternateBackColor(const wnd: UG_WINDOW; id: UG_U8;
  abc: UG_COLOR): UG_RESULT;
function UG_ButtonSetText(const wnd: UG_WINDOW; id: UG_U8; str: PChar): UG_RESULT;
function UG_ButtonSetFont(const wnd: UG_WINDOW; id: UG_U8; font: PUG_FONT): UG_RESULT;
function UG_ButtonSetStyle(const wnd: UG_WINDOW; id: UG_U8; style: UG_U8): UG_RESULT;
function UG_ButtonSetHSpace(const wnd: UG_WINDOW; id: UG_U8; hs: UG_S8): UG_RESULT;
function UG_ButtonSetVSpace(const wnd: UG_WINDOW; id: UG_U8; vs: UG_S8): UG_RESULT;
function UG_ButtonSetAlignment(const wnd: UG_WINDOW; id: UG_U8;
  align: UG_U8): UG_RESULT;

function UG_ButtonGetForeColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
function UG_ButtonGetBackColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
function UG_ButtonGetAlternateForeColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
function UG_ButtonGetAlternateBackColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
function UG_ButtonGetText(const wnd: UG_WINDOW; id: UG_U8): PChar;
function UG_ButtonGetFont(const wnd: UG_WINDOW; id: UG_U8): PUG_FONT;
function UG_ButtonGetStyle(const wnd: UG_WINDOW; id: UG_U8): UG_U8;
function UG_ButtonGetHSpace(const wnd: UG_WINDOW; id: UG_U8): UG_S8;
function UG_ButtonGetVSpace(const wnd: UG_WINDOW; id: UG_U8): UG_S8;
function UG_ButtonGetAlignment(const wnd: UG_WINDOW; id: UG_U8): UG_U8;

(* -------------------------------------------------------------------------- *)
(* -- CHECKBOX OBJECT                                                      -- *)
(* -------------------------------------------------------------------------- *)
(* Checkbox structure *)
type
  PUG_CHECKBOX = ^UG_CHECKBOX;

  UG_CHECKBOX = record
    state: UG_U8;
    style: UG_U8;
    fc: UG_COLOR;
    bc: UG_COLOR;
    afc: UG_COLOR;
    abc: UG_COLOR;
    font: PUG_FONT;
    align: UG_U8;
    h_space: UG_S8;
    v_space: UG_S8;
    str: PChar;
    Checked: UG_U8;
  end;

(* Default checkbox IDs *)
const
  CHB_ID_0 = OBJ_ID_0;
  CHB_ID_1 = OBJ_ID_1;
  CHB_ID_2 = OBJ_ID_2;
  CHB_ID_3 = OBJ_ID_3;
  CHB_ID_4 = OBJ_ID_4;
  CHB_ID_5 = OBJ_ID_5;
  CHB_ID_6 = OBJ_ID_6;
  CHB_ID_7 = OBJ_ID_7;
  CHB_ID_8 = OBJ_ID_8;
  CHB_ID_9 = OBJ_ID_9;
  CHB_ID_10 = OBJ_ID_10;
  CHB_ID_11 = OBJ_ID_11;
  CHB_ID_12 = OBJ_ID_12;
  CHB_ID_13 = OBJ_ID_13;
  CHB_ID_14 = OBJ_ID_14;
  CHB_ID_15 = OBJ_ID_15;
  CHB_ID_16 = OBJ_ID_16;
  CHB_ID_17 = OBJ_ID_17;
  CHB_ID_18 = OBJ_ID_18;
  CHB_ID_19 = OBJ_ID_19;

  (* Checkbox states *)
  CHB_STATE_RELEASED = 0 shl 0;
  CHB_STATE_PRESSED = 1 shl 0;
  CHB_STATE_ALWAYS_REDRAW = 1 shl 1;

  (* Checkbox style *)
  CHB_STYLE_2D = 0 shl 0;
  CHB_STYLE_3D = 1 shl 0;
  CHB_STYLE_TOGGLE_COLORS = 1 shl 1;
  CHB_STYLE_USE_ALTERNATE_COLORS = 1 shl 2;
  CHB_STYLE_NO_BORDERS = 1 shl 3;
  CHB_STYLE_NO_FILL = 1 shl 4;

  (* Checkbox events *)
  CHB_EVENT_CLICKED = OBJ_EVENT_CLICKED;

(* Checkbox functions *)
(*
function UG_CheckboxCreate(const wnd: UG_WINDOW; var btn: UG_CHECKBOX; id: UG_U8; xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT;
function UG_CheckboxDelete(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
function UG_CheckboxShow(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
function UG_CheckboxHide(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;

function UG_CheckboxSetCheched(const wnd: UG_WINDOW; id: UG_U8; ch: UG_U8): UG_RESULT;
function UG_CheckboxSetForeColor(const wnd: UG_WINDOW; id: UG_U8; fc: UG_COLOR): UG_RESULT;
function UG_CheckboxSetBackColor(const wnd: UG_WINDOW; id: UG_U8; bc: UG_COLOR): UG_RESULT;
function UG_CheckboxSetAlternateForeColor(const wnd: UG_WINDOW; id: UG_U8; afc: UG_COLOR): UG_RESULT;
function UG_CheckboxSetAlternateBackColor(const wnd: UG_WINDOW; id: UG_U8; abc: UG_COLOR): UG_RESULT;
function UG_CheckboxSetText(const wnd: UG_WINDOW; id: UG_U8; str: pchar): UG_RESULT;

function UG_CheckboxSetFont(const wnd: UG_WINDOW; id: UG_U8; font: PUG_FONT): UG_RESULT;
function UG_CheckboxSetStyle(const wnd: UG_WINDOW; id: UG_U8; style: UG_U8): UG_RESULT;
function UG_CheckboxSetHSpace(const wnd: UG_WINDOW; id: UG_U8; hs: UG_S8): UG_RESULT;
function UG_CheckboxSetVSpace(const wnd: UG_WINDOW; id: UG_U8; vs: UG_S8): UG_RESULT;
function UG_CheckboxSetAlignment(const wnd: UG_WINDOW; id: UG_U8; align: UG_U8): UG_RESULT;

function UG_CheckboxGetChecked(const wnd: UG_WINDOW; id: UG_U8): UG_U8;
function UG_CheckboxGetForeColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
function UG_CheckboxGetBackColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
function UG_CheckboxGetAlternateForeColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
function UG_CheckboxGetAlternateBackColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
function UG_CheckboxGetText(const wnd: UG_WINDOW; id: UG_U8): pchar;
function UG_CheckboxGetFont(const wnd: UG_WINDOW; id: UG_U8): PUG_FONT;
function UG_CheckboxGetStyle(const wnd: UG_WINDOW; id: UG_U8): UG_U8;
function UG_CheckboxGetHSpace(const wnd: UG_WINDOW; id: UG_U8): UG_S8;
function UG_CheckboxGetVSpace(const wnd: UG_WINDOW; id: UG_U8): UG_S8;
function UG_CheckboxGetAlignment(const wnd: UG_WINDOW; id: UG_U8): UG_U8;
*)



(* -------------------------------------------------------------------------- *)
(* -- TEXTBOX OBJECT                                                       -- *)
(* -------------------------------------------------------------------------- *)
(* Textbox structure *)
type
  PUG_TEXTBOX = ^UG_TEXTBOX;
  UG_TEXTBOX = record
    str: PChar;
    font: PUG_FONT;
    style: UG_U8;
    fc: UG_COLOR;
    bc: UG_COLOR;
    align: UG_U8;
    h_space: UG_S8;
    v_space: UG_S8;
  end;

const
  (* Default textbox IDs *)
  TXB_ID_0 = OBJ_ID_0;
  TXB_ID_1 = OBJ_ID_1;
  TXB_ID_2 = OBJ_ID_2;
  TXB_ID_3 = OBJ_ID_3;
  TXB_ID_4 = OBJ_ID_4;
  TXB_ID_5 = OBJ_ID_5;
  TXB_ID_6 = OBJ_ID_6;
  TXB_ID_7 = OBJ_ID_7;
  TXB_ID_8 = OBJ_ID_8;
  TXB_ID_9 = OBJ_ID_9;
  TXB_ID_10 = OBJ_ID_10;
  TXB_ID_11 = OBJ_ID_11;
  TXB_ID_12 = OBJ_ID_12;
  TXB_ID_13 = OBJ_ID_13;
  TXB_ID_14 = OBJ_ID_14;
  TXB_ID_15 = OBJ_ID_15;
  TXB_ID_16 = OBJ_ID_16;
  TXB_ID_17 = OBJ_ID_17;
  TXB_ID_18 = OBJ_ID_18;
  TXB_ID_19 = OBJ_ID_19;

(* Textbox functions *)

function UG_TextboxCreate(const wnd: UG_WINDOW; var txb: UG_TEXTBOX; id: UG_U8; 
  xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT; 
(*
function UG_TextboxDelete(wnd: pUG_WINDOW;  id: UG_U8): UG_RESULT; 
*)
function UG_TextboxShow(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT; 
(*
function UG_TextboxHide(wnd: pUG_WINDOW;  id: UG_U8): UG_RESULT; 
function UG_TextboxSetForeColor(wnd: pUG_WINDOW;  id: UG_U8;  fc: UG_COLOR): UG_RESULT; 
function UG_TextboxSetBackColor(wnd: pUG_WINDOW;  id: UG_U8;  bc: UG_COLOR): UG_RESULT; 
function UG_TextboxSetText(wnd: pUG_WINDOW;  id: UG_U8;  str: pchar): UG_RESULT; 
function UG_TextboxSetFont(wnd: pUG_WINDOW;  id: UG_U8;  font: pUG_FONT): UG_RESULT; 
function UG_TextboxSetHSpace(wnd: pUG_WINDOW;  id: UG_U8;  hs: UG_S8): UG_RESULT; 
function UG_TextboxSetVSpace(wnd: pUG_WINDOW;  id: UG_U8;  vs: UG_S8): UG_RESULT; 
function UG_TextboxSetAlignment(wnd: pUG_WINDOW;  id: UG_U8;  align: UG_U8): UG_RESULT; 

function UG_TextboxGetForeColor(wnd: pUG_WINDOW;  id: UG_U8): UG_COLOR; 
function UG_TextboxGetBackColor(wnd: pUG_WINDOW;  id: UG_U8): UG_COLOR; 
function UG_TextboxGetText(wnd: pUG_WINDOW;  id: UG_U8): pchar; 
function UG_TextboxGetFont(wnd: pUG_WINDOW;  id: UG_U8): pUG_FONT; 
function UG_TextboxGetHSpace(wnd: pUG_WINDOW;  id: UG_U8): UG_S8; 
function UG_TextboxGetVSpace(wnd: pUG_WINDOW;  id: UG_U8): UG_S8; 
function UG_TextboxGetAlignment(wnd: pUG_WINDOW;  id: UG_U8): UG_U8; 
*)




(* -------------------------------------------------------------------------- *)
(* -- IMAGE OBJECT                                                         -- *)
(* -------------------------------------------------------------------------- *)
const
  (* Default image IDs *)
  IMG_ID_0 = OBJ_ID_0;
  IMG_ID_1 = OBJ_ID_1;
  IMG_ID_2 = OBJ_ID_2;
  IMG_ID_3 = OBJ_ID_3;
  IMG_ID_4 = OBJ_ID_4;
  IMG_ID_5 = OBJ_ID_5;
  IMG_ID_6 = OBJ_ID_6;
  IMG_ID_7 = OBJ_ID_7;
  IMG_ID_8 = OBJ_ID_8;
  IMG_ID_9 = OBJ_ID_9;
  IMG_ID_10 = OBJ_ID_10;
  IMG_ID_11 = OBJ_ID_11;
  IMG_ID_12 = OBJ_ID_12;
  IMG_ID_13 = OBJ_ID_13;
  IMG_ID_14 = OBJ_ID_14;
  IMG_ID_15 = OBJ_ID_15;
  IMG_ID_16 = OBJ_ID_16;
  IMG_ID_17 = OBJ_ID_17;
  IMG_ID_18 = OBJ_ID_18;
  IMG_ID_19 = OBJ_ID_19;

  (* Image types *)
  IMG_TYPE_BMP = 1 shl 0;

  (* BMP constants *)
  BMP_BPP_1 = 1 shl 0;
  BMP_BPP_2 = 1 shl 1;
  BMP_BPP_4 = 1 shl 2;
  BMP_BPP_8 = 1 shl 3;
  BMP_BPP_16 = 1 shl 4;
  BMP_BPP_32 = 1 shl 5;
  BMP_RGB888 = 1 shl 0;
  BMP_RGB565 = 1 shl 1;
  BMP_RGB555 = 1 shl 2;

(* Image structure *)
type
  PUG_IMAGE = ^UG_IMAGE;

  UG_IMAGE = record
    img: PUG_U8;
    itype: UG_U8;
  end;

  (* BMP structure *)
  PUG_BMP = ^UG_BMP;

  UG_BMP = record
    p: PUG_U8;
    Width: UG_U16;
    Height: UG_U16;
    bpp: UG_U8;
    colors: UG_U8;
  end;

(* Image functions *)
function UG_ImageCreate(const wnd: UG_WINDOW; var img: UG_IMAGE;
  id: UG_U8; xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT;
function UG_ImageDelete(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
function UG_ImageShow(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
function UG_ImageHide(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
function UG_ImageSetBMP(const wnd: UG_WINDOW; id: UG_U8; bmp: PUG_BMP): UG_RESULT;

(* ------------------------------------------------- *)
(* ------------------------------------------------- *)
(* ------------------------------------------------- *)

(* Miscellaneous functions *)
procedure UG_WaitForUpdate;
procedure UG_Update;
procedure UG_TouchUpdate(xp, yp: UG_S16; state: UG_U8);

(* Driver functions *)
procedure UG_DriverRegister(t: UG_U8; driver: Pointer);
procedure UG_DriverEnable(t: UG_U8);
procedure UG_DriverDisable(t: UG_U8);

implementation

const
{$ifdef USE_COLOR_RGB888}
  pal_window: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464, (* Frame 0 *)
    $FFFFFF, $FFFFFF, $696969, $696969,  (* Frame 1 *)
    $E3E3E3, $E3E3E3, $A0A0A0, $A0A0A0); (* Frame 2 *)
{$endif}
{$ifdef USE_COLOR_RGB565}
  pal_window: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $FFFF, $FFFF, $6B4D, $6B4D, $E71C, $E71C, $9D13, $9D13);
{$endif}

var
  gui: PUG_GUI;
  msg: UG_MESSAGE;

(* -------------------------------------------------------------------------- *)
(* -- INTERNAL FUNCTIONS                                                   -- *)
(* -------------------------------------------------------------------------- *)
procedure _UG_PutChar(chr: char; x, y: UG_S16; fc: UG_COLOR; bc: UG_COLOR;
  const font: UG_FONT);
var
  i, j, k: UG_U16;
  xo, yo: UG_U16;
  c: UG_U16;
  bn: UG_U16;
  actual_char_width: UG_U16;
  b: UG_U8;
  bt: char;
  (* TP7 Compat *)
  index: UG_U16;
  (* index: UG_U32; *)
  color: UG_COLOR;
begin
  bt := chr;
  case Ord(bt) of
    $F6: bt := char($94);
    $D6: bt := char($99);
    $FC: bt := char($81);
    $DC: bt := char($9A);
    $E4: bt := char($84);
    $C4: bt := char($8E);
    $B5: bt := char($E6);
    $B0: bt := char($F8);
  end;

  if (Ord(bt) < font.start_char) or (Ord(bt) > font.end_char) then
    exit;
  yo := y;
  bn := font.char_width;
  if 0 = bn then
    exit;
  bn := bn shr 3;
  if (font.char_width mod 8) <> 0 then
    Inc(bn);
  if font.widths <> nil then
    actual_char_width := IncPtrU8(font.widths, Ord(bt) - font.start_char)^
  else
    actual_char_width := font.char_width;

  (* TO DO *)
  (* Is hardware acceleration available? *)

  (* Not accelerated output *)
  if font.font_type = FONT_TYPE_1BPP then
  begin
    index := (Ord(bt) - font.start_char) * (font.char_height) * bn;
    for j := 0 to Pred(font.char_height) do
    begin
      xo := x;
      c := actual_char_width;
      for i := 0 to Pred(bn) do
      begin
        b := IncPtrU8(font.p, index)^;
        Inc(index);
        k := 0;
        while (k < 8) and (c <> 0) do
        begin
          if (b and $01) <> 0 then
            gui^.pset(xo, yo, fc)
          else
            gui^.pset(xo, yo, bc);
          b := b shr 1;
          Inc(xo);
          Dec(c);
          Inc(k);
        end;
      end;
      Inc(yo);
    end;
  end
  else
  if font.font_type = FONT_TYPE_8BPP then
  begin
    index := (Ord(bt) - font.start_char) * font.char_height * font.char_width;
    for j := 0 to Pred(font.char_height) do
    begin
      xo := x;
      for i := 0 to Pred(actual_char_width) do
      begin
        b := IncPtrU8(font.p, index)^;
        Inc(index);
        color := (((fc and $FF) * b + (bc and $FF) * (256 - b)) shr 8) and
          $FF or (((fc and $FF00) * b + (bc and $FF00) * (256 - b)) shr 8) and
          $FF00 or (((fc and $FF0000) * b + (bc and $FF0000) * (256 - b)) shr 8) and
          $FF0000;
        gui^.pset(xo, yo, color);
        (* Blue component  *)
        (* Green component *)
        (* Red component   *)
        Inc(xo);
      end;
      index := index + font.char_width - actual_char_width;
      Inc(yo);
    end;
  end;

end;

procedure _UG_PutText(var txt: UG_TEXT);
var
  sl: UG_U16;
  rc: UG_U16;
  wl: UG_U16;
  xp, yp: UG_S16;
  xs, ys: UG_S16;
  xe, ye: UG_S16;
  align: UG_U8;
  char_width, char_height: UG_S16;
  char_h_space, char_v_space: UG_S16;
  chr: char;
  str: PChar;
  c: PChar;
begin
  xs := txt.a.xs;
  ys := txt.a.ys;
  xe := txt.a.xe;
  ye := txt.a.ye;
  align := txt.align;
  char_width := txt.font^.char_width;
  char_height := txt.font^.char_height;
  char_h_space := txt.h_space;
  char_v_space := txt.v_space;
  str := txt.str;
  c := str;
  if (txt.font^.p = nil) or (str = nil) or ((ye - ys) < txt.font^.char_height) then
    exit;
  rc := 1;
  c := str;
  while c^ <> char(0) do
  begin
    if c^ = char($0A) then
      Inc(rc);
    Inc(c);
  end;
  yp := 0;
  if (align and (ALIGN_V_CENTER or ALIGN_V_BOTTOM)) <> 0 then
  begin
    yp := ye - ys + 1;
    yp := yp - char_height * rc;
    yp := yp - char_v_space * (rc - 1);
    if yp < 0 then
      exit;
  end;
  if (align and ALIGN_V_CENTER) <> 0 then
    yp := yp shr 1;
  yp := yp + ys;
  while True do
  begin
    sl := 0;
    c := str;
    wl := 0;
    while (c^ <> char(0)) and (c^ <> char($0A)) do
    begin
      if (Ord(c^) < txt.font^.start_char) or (Ord(c^) > txt.font^.end_char) then
      begin
        Inc(c);
        continue;
      end;
      Inc(sl);
      if txt.font^.widths <> nil then
        wl := wl + IncPtrU8(txt.font^.widths, Ord(c^) - txt.font^.start_char)^
      else
        wl := wl + char_width;
      wl := wl + char_h_space;
      Inc(c);
    end;
    wl := wl - char_h_space;
    xp := xe - xs + 1;
    xp := xp - wl;
    if xp < 0 then
      exit;
    if (align and ALIGN_H_LEFT) <> 0 then
      xp := 0
    else if (align and ALIGN_H_CENTER) <> 0 then
      xp := xp shr (1);
    xp := xp + xs;
    while str^ <> char($0A) do
    begin
      chr := str^;
      Inc(str);
      if Ord(chr) = 0 then
        exit;
      _UG_PutChar(chr, xp, yp, txt.fc, txt.bc, txt.font^);
      if txt.font^.widths <> nil then
        xp := xp + IncPtrU8(txt.font^.widths, Ord(chr) - txt.font^.start_char)^
      else
        xp := xp + char_width;
      xp := xp + char_h_space;
    end;
    Inc(str);
    yp := yp + char_height + char_v_space;
  end;
end;

procedure _UG_DrawObjectFrame(xs, ys: UG_S16; xe, ye: UG_S16; p: PUG_COLOR);
begin
  (* Frame 0*)
  UG_DrawHLine(xs, xe - 1, ys, p^);
  Inc(p);
  UG_DrawVLine(ys + 1, ye - 1, xs, p^);
  Inc(p);
  UG_DrawHLine(xs, xe, ye, p^);
  Inc(p);
  UG_DrawVLine(ys, ye - 1, xe, p^);
  Inc(p);

  (* Frame 1*)
  UG_DrawHLine(xs + 1, xe - 2, ys + 1, p^);
  Inc(p);
  UG_DrawVLine(ys + 2, ye - 2, xs + 1, p^);
  Inc(p);
  UG_DrawHLine(xs + 1, xe - 1, ye - 1, p^);
  Inc(p);
  UG_DrawVLine(ys + 1, ye - 2, xe - 1, p^);
  Inc(p);

  (* Frame 2*)
  UG_DrawHLine(xs + 2, xe - 3, ys + 2, p^);
  Inc(p);
  UG_DrawVLine(ys + 3, ye - 3, xs + 2, p^);
  Inc(p);
  UG_DrawHLine(xs + 2, xe - 2, ye - 2, p^);
  Inc(p);
  UG_DrawVLine(ys + 2, ye - 3, xe - 2, p^);
end;

(* Window internal *)
function _UG_WindowDrawTitle(var wnd: UG_WINDOW): UG_RESULT;
var
  txt: UG_TEXT;
  xs, ys: UG_S16;
  xe, ye: UG_S16;

begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    xs := wnd.xs;
    ys := wnd.ys;
    xe := wnd.xe;
    ye := wnd.ye;
    (* 3D style? *)
    if (wnd.style and WND_STYLE_3D) <> 0 then
    begin
      xs := xs + 3;
      ys := ys + 3;
      xe := xe - 3;
      ye := ye - 3;
    end;

    (* Is the window active or inactive? *)
    if @wnd = gui^.active_window then
    begin
      txt.bc := wnd.title.bc;
      txt.fc := wnd.title.fc;
    end
    else
    begin
      txt.bc := wnd.title.ibc;
      txt.fc := wnd.title.ifc;
    end;

    (* Draw title *)
    UG_FillFrame(xs, ys, xe, ys + wnd.title.Height - 1, txt.bc);

    (* Draw title text *)
    txt.str := wnd.title.str;
    txt.font := wnd.title.font;
    txt.a.xs := xs + 3;
    txt.a.ys := ys;
    txt.a.xe := xe;
    txt.a.ye := ys + wnd.title.Height - 1;
    txt.align := wnd.title.align;
    txt.h_space := wnd.title.h_space;
    txt.v_space := wnd.title.v_space;
    _UG_PutText(txt);

    (* Draw line *)
    UG_DrawHLine(xs, xe, ys + wnd.title.Height,
      pal_window[11]);
    _UG_WindowDrawTitle := UG_RESULT_OK;
  end
  else
    _UG_WindowDrawTitle := UG_RESULT_FAIL;
end;

procedure _UG_WindowUpdate(var wnd: UG_WINDOW);
var
  i: UG_U16;
  objcnt: UG_U16;
  obj: PUG_OBJECT;
  xs, ys: UG_S16;
  xe, ye: UG_S16;
begin
  xs := wnd.xs;
  ys := wnd.ys;
  xe := wnd.xe;
  ye := wnd.ye;
  wnd.state := wnd.state and (not WND_STATE_UPDATE);
  (* Is the window visible? *)
  if (wnd.state and WND_STATE_VISIBLE) <> 0 then
  begin
    (* 3D style? *)
    if ((wnd.style and WND_STYLE_3D) <> 0) and
      ((wnd.state and WND_STATE_REDRAW_TITLE) = 0) then
    begin
      _UG_DrawObjectFrame(xs, ys, xe, ye, PUG_COLOR(@pal_window[0]));
      xs := xs + 3;
      ys := ys + 3;
      xe := xe - 3;
      ye := ye - 3;
    end;
    (* Show title bar? *)
    if (wnd.style and WND_STYLE_SHOW_TITLE) <> 0 then
    begin
      _UG_WindowDrawTitle(wnd);
      ys := ys + wnd.title.Height + 1;
      if (wnd.state and WND_STATE_REDRAW_TITLE) <> 0 then
      begin
        wnd.state := wnd.state and (not WND_STATE_REDRAW_TITLE);
        exit;
      end;
    end;
    (* Draw window area? *)
    UG_FillFrame(xs, ys, xe, ye, wnd.bc);
    objcnt := wnd.objcnt;
    (* Force each object to be updated! *)
    obj := wnd.objlst;
    for i := 0 to Pred(objcnt) do
    begin
      if ((obj^.state and OBJ_STATE_FREE) = 0) and
        ((obj^.state and OBJ_STATE_VALID) <> 0) and
        ((obj^.state and OBJ_STATE_VISIBLE) <> 0) then
        obj^.state := obj^.state or OBJ_STATE_UPDATE or OBJ_STATE_REDRAW;
      Inc(obj);
    end;
  end
  else
    UG_FillFrame(wnd.xs, wnd.xs, wnd.xe, wnd.ye, gui^.desktop_color);
end;

function _UG_WindowClear(var wnd: UG_WINDOW): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VISIBLE) <> 0 then
  begin
    wnd.state := wnd.state and (not WND_STATE_VISIBLE);
    UG_FillFrame(wnd.xs, wnd.ys, wnd.xe, wnd.ye, gui^.desktop_color);
    if @wnd <> gui^.active_window then
    begin
      (* If the current window is visible, update it! *)
      if (gui^.active_window^.state and WND_STATE_VISIBLE) <> 0 then
      begin
        gui^.active_window^.state :=
          gui^.active_window^.state and (not WND_STATE_REDRAW_TITLE);
        gui^.active_window^.state := gui^.active_window^.state or WND_STATE_UPDATE;
      end;
    end;
  end;
  _UG_WindowClear := UG_RESULT_OK;
end;

function _UG_GetFreeObject(const wnd: UG_WINDOW): PUG_OBJECT;
var
  i: UG_U8;
  obj: PUG_OBJECT;
begin
  obj := wnd.objlst;
  for i := 0 to Pred(wnd.objcnt) do
  begin
    if ((obj^.state and OBJ_STATE_FREE) <> 0) and
      ((obj^.state and OBJ_STATE_VALID) <> 0) then
    begin
      (* Free object found! *)
      _UG_GetFreeObject := obj;
      exit;
    end;
    Inc(obj);
  end;
  _UG_GetFreeObject := nil;
end;

function _UG_SearchObject(const wnd: UG_WINDOW; otype: UG_U8; id: UG_U8): PUG_OBJECT;
var
  i: UG_U8;
  obj: PUG_OBJECT;

begin
  obj := wnd.objlst;
  for i := 0 to Pred(wnd.objcnt) do
  begin
    if ((obj^.state and OBJ_STATE_FREE) = 0) and
      ((obj^.state and OBJ_STATE_VALID) <> 0) and (obj^.otype = otype) and
      (obj^.id = id) then
    begin
      (* Requested object found! *)
      _UG_SearchObject := obj;
      exit;
    end;
    Inc(obj);
  end;
  _UG_SearchObject := nil;
end;

function _UG_DeleteObject(const wnd: UG_WINDOW; otype: UG_U8; id: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := nil;
  obj := _UG_SearchObject(wnd, otype, id);
  (* Object found? *)
  if obj <> nil then
  begin
    (* We dont't want to delete a visible or busy object! *)
    if ((obj^.state and OBJ_STATE_VISIBLE) <> 0) or
      ((obj^.state and OBJ_STATE_UPDATE) <> 0) then
      _UG_DeleteObject := UG_RESULT_FAIL
    else
    begin
      obj^.state := OBJ_STATE_INIT;
      obj^.Data := nil;
      obj^.event := 0;
      obj^.id := 0;
      obj^.touch_state := 0;
      obj^.otype := 0;
      obj^.update := nil;
      _UG_DeleteObject := UG_RESULT_OK;
    end;
  end
  else
    _UG_DeleteObject := UG_RESULT_FAIL;
end;

procedure _UG_ProcessTouchData(wnd: PUG_WINDOW);
var
  xp, yp: UG_S16;
  i: UG_U16;
  objcnt: UG_U16;
  obj: PUG_OBJECT;
  objstate: UG_U8;
  objtouch: UG_U8;
  tchstate: UG_U8;
begin
  xp := gui^.touch.xp;
  yp := gui^.touch.yp;
  tchstate := gui^.touch.state;
  objcnt := wnd^.objcnt;
  obj := wnd^.objlst;
  for i := 0 to Pred(objcnt) do
  begin
    (* obj := wnd.objlst[i]; *)
    (* post inc *)
    objstate := obj^.state;
    objtouch := obj^.touch_state;
    if ((objstate and OBJ_STATE_FREE) = 0) and
      ((objstate and OBJ_STATE_VALID) <> 0) and
      ((objstate and OBJ_STATE_VISIBLE) <> 0) and
      ((objstate and OBJ_STATE_REDRAW) = 0) then
    begin
      (* Process touch data *)
      if (tchstate <> 0) and (xp <> -1) then
      begin
        if (objtouch and OBJ_TOUCH_STATE_IS_PRESSED) = 0 then
        begin
          objtouch := objtouch or (OBJ_TOUCH_STATE_PRESSED_OUTSIDE_OBJECT or
            OBJ_TOUCH_STATE_CHANGED);
          objtouch := objtouch and
            (not (OBJ_TOUCH_STATE_RELEASED_ON_OBJECT or
            OBJ_TOUCH_STATE_RELEASED_OUTSIDE_OBJECT or OBJ_TOUCH_STATE_CLICK_ON_OBJECT));
        end;
        objtouch := objtouch and (not OBJ_TOUCH_STATE_IS_PRESSED_ON_OBJECT);

        if (xp >= obj^.a_abs.xs) and (xp <= obj^.a_abs.xe) and
          (yp >= obj^.a_abs.ys) and (yp <= obj^.a_abs.ye) then

        begin
          objtouch := objtouch or OBJ_TOUCH_STATE_IS_PRESSED_ON_OBJECT;
          if (objtouch and OBJ_TOUCH_STATE_IS_PRESSED) = 0 then
          begin
            objtouch := objtouch and (not OBJ_TOUCH_STATE_PRESSED_OUTSIDE_OBJECT);
            objtouch := objtouch or OBJ_TOUCH_STATE_PRESSED_ON_OBJECT;
          end;
        end;

        objtouch := objtouch or OBJ_TOUCH_STATE_IS_PRESSED;
      end
      else
      if (objtouch and OBJ_TOUCH_STATE_IS_PRESSED) <> 0 then
      begin
        if (objtouch and OBJ_TOUCH_STATE_IS_PRESSED_ON_OBJECT) <> 0 then
        begin
          if (objtouch and OBJ_TOUCH_STATE_PRESSED_ON_OBJECT) <> 0 then
            objtouch := objtouch or OBJ_TOUCH_STATE_CLICK_ON_OBJECT;
          objtouch := objtouch or OBJ_TOUCH_STATE_RELEASED_ON_OBJECT;
        end
        else
          objtouch := objtouch or OBJ_TOUCH_STATE_RELEASED_OUTSIDE_OBJECT;
        if (objtouch and OBJ_TOUCH_STATE_IS_PRESSED) <> 0 then
          objtouch := objtouch or OBJ_TOUCH_STATE_CHANGED;
        objtouch := objtouch and
          (not (OBJ_TOUCH_STATE_PRESSED_OUTSIDE_OBJECT or
          OBJ_TOUCH_STATE_PRESSED_ON_OBJECT or OBJ_TOUCH_STATE_IS_PRESSED));
      end;
    end;
    obj^.touch_state := objtouch;
    (* post inc *)
    Inc(obj);
  end;
end;

procedure _UG_UpdateObjects(wnd: PUG_WINDOW);
var
  i: UG_U16;
  objcnt: UG_U16;
  obj: PUG_OBJECT;
  objstate: UG_U8;
  objtouch: UG_U8;
begin
  objcnt := wnd^.objcnt;
  obj := wnd^.objlst;
  (* Check each object, if it needs to be updated? *)
  for i := 0 to Pred(objcnt) do
  begin
    objstate := obj^.state;
    objtouch := obj^.touch_state;
    if ((objstate and OBJ_STATE_FREE) = 0) and
      ((objstate and OBJ_STATE_VALID) <> 0) then
    begin
      if (objstate and OBJ_STATE_UPDATE) <> 0 then
        obj^.update(@wnd, obj);
      if ((objstate and OBJ_STATE_VISIBLE) <> 0) and
        ((objstate and OBJ_STATE_TOUCH_ENABLE) <> 0) then
        if (objtouch and (OBJ_TOUCH_STATE_CHANGED or
          OBJ_TOUCH_STATE_IS_PRESSED)) <> 0 then
          obj^.update(wnd, obj);
    end;
    Inc(obj);
  end;
end;

procedure _UG_HandleEvents(wnd: PUG_WINDOW);
var
  i: UG_U16;
  objcnt: UG_U16;
  obj: PUG_OBJECT;
  objstate: UG_U8;
begin
  msg.src := nil;
  msg.mtype := MSG_TYPE_OBJECT;
  objcnt := wnd^.objcnt;
  obj := wnd^.objlst;

  (* Handle window-related events *)
  (*ToDo*)

  (* Handle object-related events *)
  for i := 0 to Pred(objcnt) do
  begin
    (* obj:= (UG_OBJECT* )@wnd.objlst[i]; *)
    objstate := obj^.state;
    if ((objstate and OBJ_STATE_FREE) = 0) and ((objstate and OBJ_STATE_VALID) <> 0) then
    begin
      if obj^.event <> OBJ_EVENT_NONE then
      begin
        msg.src := @obj;
        msg.id := obj^.otype;
        msg.sub_id := obj^.id;
        msg.event := obj^.event;
        wnd^.cb(@msg);
        obj^.event := OBJ_EVENT_NONE;
      end;
    end;
    Inc(obj);
  end;
end;


(*
procedure _UG_TextboxUpdate(wnd: PUG_WINDOW;  obj: PUG_OBJECT);
procedure _UG_ButtonUpdate(wnd: PUG_WINDOW;  obj: PUG_OBJECT);
procedure _UG_CheckboxUpdate(wnd: PUG_WINDOW;  obj: PUG_OBJECT);
procedure _UG_ImageUpdate(wnd: PUG_WINDOW;  obj: PUG_OBJECT);
*)

(* CLASSIC *)

function UG_Init(var g: UG_GUI; p: UG_PSET; x, y: UG_S16): UG_S16;
var
  i: shortint;
begin
  g.pset := p;
  g.x_dim := x;
  g.y_dim := y;
  g.console.x_start := 4;
  g.console.y_start := 4;
  g.console.x_end := g.x_dim - g.console.x_start - 1;
  g.console.y_end := g.y_dim - g.console.x_start - 1;
  g.console.x_pos := g.console.x_end;
  g.console.y_pos := g.console.y_end;
  g.char_h_space := 1;
  g.char_v_space := 1;
  g.font.p := nil;
  g.font.char_height := 0;
  g.font.char_width := 0;
  g.font.start_char := 0;
  g.font.end_char := 0;
  g.font.widths := nil;
  {$ifdef USE_COLOR_RGB888}
  g.desktop_color := $5E8BEf;
  {$endif}
  {$ifdef USE_COLOR_RGB565}
  g.desktop_color := $5C5D;
  {$endif}
  g.fore_color := C_WHITE;
  g.back_color := C_BLACK;
  g.next_window := nil;
  g.active_window := nil;
  g.last_window := nil;
  (* Clear drivers *)
  for i := 0 to Pred(NUMBER_OF_DRIVERS) do
  begin
    g.driver[i].driver := nil;
    g.driver[i].state := UG_U8(0);
  end;
  gui := @g;
  UG_Init := 1;
end;

function UG_SelectGUI(g: PUG_GUI): UG_S16;
begin
  gui := g;
  UG_SelectGUI := 1;
end;

procedure UG_FontSelect(font: PUG_FONT);
begin
  gui^.font := font^;
end;

procedure UG_FillScreen(c: UG_COLOR);
begin
  UG_FillFrame(0, 0, gui^.x_dim - 1, gui^.y_dim - 1, c);
end;

procedure UG_FillFrame(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR);
var
  n, m: UG_S16;
  pset: UG_PSET;
begin
  pset := gui^.pset;

  if x2 < x1 then
  begin
    n := x2;
    x2 := x1;
    x1 := n;
  end;
  if y2 < y1 then
  begin
    n := y2;
    y2 := y1;
    y1 := n;
  end;

  (* Is hardware acceleration available? *)
  if ((gui^.driver[DRIVER_FILL_FRAME].state and DRIVER_ENABLED) <> 0) and
    (_HW_FILLFRAME(gui^.driver[DRIVER_FILL_FRAME].driver)(x1, y1, x2, y2, c) =
    UG_RESULT_OK) then
    exit;

  for m := y1 to y2 do
  begin
    for n := x1 to x2 do
    begin
      (* gui^.pset(n, m, c); *)
      pset(n, m, c);
    end;
  end;
end;

procedure UG_FillRoundFrame(x1, y1: UG_S16; x2, y2: UG_S16; r: UG_S16; c: UG_COLOR);
var
  x, y: UG_S16;
  xd: UG_S16;
begin
  if x2 < x1 then
  begin
    x := x2;
    x2 := x1;
    x1 := x;
  end;
  if y2 < y1 then
  begin
    y := y2;
    y2 := y1;
    y1 := y;
  end;

  if r <= 0 then
    exit;

  xd := 3 - (r shl 1);
  x := 0;
  y := r;
  UG_FillFrame(x1 + r, y1, x2 - r, y2, c);

  while x <= y do
  begin
    if y > 0 then
    begin
      UG_DrawLine(x2 + x - r, y1 - y + r, x2 + x - r, y + y2 - r, c);
      UG_DrawLine(x1 - x + r, y1 - y + r, x1 - x + r, y + y2 - r, c);
    end;
    if x > 0 then
    begin
      UG_DrawLine(x1 - y + r, y1 - x + r, x1 - y + r, x + y2 - r, c);
      UG_DrawLine(x2 + y - r, y1 - x + r, x2 + y - r, x + y2 - r, c);
    end;
    if xd < 0 then
    begin
      xd := xd + (x shl 2) + 6;
    end
    else
    begin
      xd := xd + ((x - y) shl 2) + 10;
      Dec(y);
    end;
    Inc(x);
  end;
end;

procedure UG_DrawMesh(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR);
var
  n, m: UG_S16;
begin
  if x2 < x1 then
  begin
    n := x2;
    x2 := x1;
    x1 := n;
  end;
  if y2 < y1 then
  begin
    n := y2;
    y2 := y1;
    y1 := n;
  end;
  m := y1;
  while m <= y2 do
  begin
    n := x1;
    while n <= x2 do
    begin
      gui^.pset(n, m, c);
      n := n + 2;
    end;
    m := m + 2;
  end;
end;

procedure UG_DrawFrame(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR);
begin
  UG_DrawHLine(x1, x2, y1, c);
  UG_DrawHLine(x1, x2, y2, c);
  UG_DrawVLine(y1, y2, x1, c);
  UG_DrawVLine(y1, y2, x2, c);
end;

procedure UG_DrawRoundFrame(x1, y1: UG_S16; x2, y2: UG_S16; r: UG_S16; c: UG_COLOR);
var
  n: UG_S16;
begin
  if x2 < x1 then
  begin
    n := x2;
    x2 := x1;
    x1 := n;
  end;
  if y2 < y1 then
  begin
    n := y2;
    y2 := y1;
    y1 := n;
  end;
  if (r > x2) or (r > y2) then
    exit;

  UG_DrawLine(x1 + r, y1, x2 - r, y1, c);
  UG_DrawLine(x1 + r, y2, x2 - r, y2, c);
  UG_DrawLine(x1, y1 + r, x1, y2 - r, c);
  UG_DrawLine(x2, y1 + r, x2, y2 - r, c);

  UG_DrawArc(x1 + r, y1 + r, r, $0C, c);
  UG_DrawArc(x2 - r, y1 + r, r, $03, c);
  UG_DrawArc(x1 + r, y2 - r, r, $30, c);
  UG_DrawArc(x2 - r, y2 - r, r, $C0, c);
end;

procedure UG_DrawPixel(x0, y0: UG_S16; c: UG_COLOR);
begin
  gui^.pset(x0, y0, c);
end;

procedure UG_DrawCircle(x0, y0: UG_S16; r: UG_S16; c: UG_COLOR);
var
  x, y: UG_S16;
  xd, yd: UG_S16;
  e: UG_S16;
begin
  if (x0 < 0) or (y0 < 0) or (r <= 0) then
    exit;

  xd := 1 - (r shl 1);
  yd := 0;
  e := 0;
  x := r;
  y := 0;
  while x >= y do
  begin
    gui^.pset(x0 - x, y0 + y, c);
    gui^.pset(x0 - x, y0 - y, c);
    gui^.pset(x0 + x, y0 + y, c);
    gui^.pset(x0 + x, y0 - y, c);
    gui^.pset(x0 - y, y0 + x, c);
    gui^.pset(x0 - y, y0 - x, c);
    gui^.pset(x0 + y, y0 + x, c);
    gui^.pset(x0 + y, y0 - x, c);
    Inc(y);
    e := e + yd;
    yd := yd + 2;
    if (e shl 1) + xd > 0 then
    begin
      Dec(x);
      e := e + xd;
      xd := xd + 2;
    end;
  end;
end;

procedure UG_FillCircle(x0, y0: UG_S16; r: UG_S16; c: UG_COLOR);
var
  x, y: UG_S16;
  xd: UG_S16;
begin
  if (x0 < 0) or (y0 < 0) or (r <= 0) then
    exit;

  xd := 3 - (r shl 1);
  x := 0;
  y := r;
  while x <= y do
  begin
    if y > 0 then
    begin
      UG_DrawLine(x0 - x, y0 - y, x0 - x, y0 + y, c);
      UG_DrawLine(x0 + x, y0 - y, x0 + x, y0 + y, c);
    end;
    if x > 0 then
    begin
      UG_DrawLine(x0 - y, y0 - x, x0 - y, y0 + x, c);
      UG_DrawLine(x0 + y, y0 - x, x0 + y, y0 + x, c);
    end;
    if xd < 0 then
    begin
      xd := xd + (x shl 2) + 6;
    end
    else
    begin
      xd := xd + ((x - y) shl 2) + 10;
      Dec(y);
    end;
    Inc(x);
  end;
  UG_DrawCircle(x0, y0, r, c);
end;

procedure UG_DrawArc(x0, y0: UG_S16; r: UG_S16; s: UG_U8; c: UG_COLOR);
var
  x, y: UG_S16;
  xd, yd: UG_S16;
  e: UG_S16;
begin
  if (x0 < 0) or (y0 < 0) or (r <= 0) then
    exit;

  xd := 1 - (r shl 1);
  yd := 0;
  e := 0;
  x := r;
  y := 0;
  while x >= y do
  begin
    (* Q1 *)
    if (byte(s) and $01) <> 0 then
      gui^.pset(x0 + x, y0 - y, c);
    if (byte(s) and $02) <> 0 then
      gui^.pset(x0 + y, y0 - x, c);

    (* Q2 *)
    if (byte(s) and $04) <> 0 then
      gui^.pset(x0 - y, y0 - x, c);
    if (byte(s) and $08) <> 0 then
      gui^.pset(x0 - x, y0 - y, c);

    (* Q3 *)
    if (byte(s) and $10) <> 0 then
      gui^.pset(x0 - x, y0 + y, c);
    if (byte(s) and $20) <> 0 then
      gui^.pset(x0 - y, y0 + x, c);

    (* Q4 *)
    if (byte(s) and $40) <> 0 then
      gui^.pset(x0 + y, y0 + x, c);
    if (byte(s) and $80) <> 0 then
      gui^.pset(x0 + x, y0 + y, c);
    Inc(y);
    e := e + yd;
    yd := yd + 2;
    if (e shl 1) + xd > 0 then
    begin
      Dec(x);
      e := e + xd;
      xd := xd + 2;
    end;
  end;
end;

procedure UG_DrawHLine(x1, x2, y: UG_S16; c: UG_COLOR);
var
  x: UG_S16;
begin
  if x1 > x2 then
  begin
    x := x2;
    x2 := x1;
    x1 := x;
  end;
  (* Is hardware acceleration available? *)
  if ((gui^.driver[DRIVER_DRAW_LINE].state and DRIVER_ENABLED) <> 0) and
    (_HW_DRAWLINE(gui^.driver[DRIVER_DRAW_LINE].driver)(x1, y, x2, y, c) =
    UG_RESULT_OK) then
    exit;

  for x := x1 to x2 do
  begin
    gui^.pset(x, y, c);
  end;
end;

procedure UG_DrawVLine(y1, y2, x: UG_S16; c: UG_COLOR);
var
  y: UG_S16;
begin
  if y1 > y2 then
  begin
    y := y2;
    y2 := y1;
    y1 := y;
  end;
  (* Is hardware acceleration available? *)
  if ((gui^.driver[DRIVER_DRAW_LINE].state and DRIVER_ENABLED) <> 0) and
    (_HW_DRAWLINE(gui^.driver[DRIVER_DRAW_LINE].driver)(x, y1, x, y2, c) =
    UG_RESULT_OK) then
    exit;

  for y := y1 to y2 do
  begin
    gui^.pset(x, y, c);
  end;
end;

procedure UG_DrawLine(x1, y1: UG_S16; x2, y2: UG_S16; c: UG_COLOR);
var
  n: UG_S16;
  dx, dy: UG_S16;
  sgndx, sgndy: UG_S16;
  dxabs, dyabs: UG_S16;
  x, y: UG_S16;
  drawx, drawy: UG_S16;
begin
  (* Is hardware acceleration available? *)
  if ((gui^.driver[DRIVER_DRAW_LINE].state and DRIVER_ENABLED) <> 0) and
    (_HW_DRAWLINE(gui^.driver[DRIVER_DRAW_LINE].driver)(x1, y1, x2, y2, c) =
    UG_RESULT_OK) then
    exit;

  dx := x2 - x1;
  dy := y2 - y1;
  dxabs := Abs(dx);
  dyabs := Abs(dy);
  if dx >= 0 then
    sgndx := 1
  else
    sgndx := -1;
  if dy >= 0 then
    sgndy := 1
  else
    sgndy := -1;
  x := dyabs shr 1;
  y := dxabs shr 1;
  drawx := x1;
  drawy := y1;
  gui^.pset(drawx, drawy, c);

  if dxabs >= dyabs then
  begin
    for n := 0 to Pred(dxabs) do
    begin
      y := y + dyabs;
      if y >= dxabs then
      begin
        y := y - dxabs;
        drawy := drawy + sgndy;
      end;
      drawx := drawx + sgndx;
      gui^.pset(drawx, drawy, c);
    end;
  end
  else
  begin
    for n := 0 to Pred(dyabs) do
    begin
      x := x + dxabs;
      if x >= dyabs then
      begin
        x := x - dyabs;
        drawx := drawx + sgndx;
      end;
      drawy := drawy + sgndy;
      gui^.pset(drawx, drawy, c);
    end;
  end;
end;

procedure UG_PutString(x, y: UG_S16; str: PChar);
var
  xp, yp: UG_S16;
  cw: UG_U8;
  chr: char;
begin
  xp := x;
  yp := y;
  while str^ <> char(0) do
  begin
    chr := str^;
    Inc(str);
    if (Ord(chr) < gui^.font.start_char) or (Ord(chr) > gui^.font.end_char) then
      Continue;
    if chr = char($0A) then
    begin
      xp := gui^.x_dim;
      Continue;
    end;
    if gui^.font.widths <> nil then
      cw := IncPtrU8(gui^.font.widths, Ord(chr) - gui^.font.start_char)^
    else
      cw := gui^.font.char_width;

    if xp + cw > gui^.x_dim - 1 then
    begin
      xp := x;
      yp := yp + gui^.font.char_height + gui^.char_v_space;
    end;
    UG_PutChar(chr, xp, yp, gui^.fore_color, gui^.back_color);
    xp := xp + cw + gui^.char_h_space;
  end;
end;

procedure UG_PutChar(chr: char; x, y: UG_S16; fc: UG_COLOR; bc: UG_COLOR);
begin
  _UG_PutChar(chr, x, y, fc, bc, gui^.font);
end;

procedure UG_ConsolePutString(str: PChar);
var
  chr: char;
  cw: UG_U8;
begin
  while str^ <> char(0) do
  begin
    chr := str^;
    if chr = char($0A) then
    begin
      gui^.console.x_pos := gui^.x_dim;
      Inc(str);
      continue;
    end;

    if gui^.font.widths <> nil then
      cw := IncPtrU8(gui^.font.widths, Ord(chr) - gui^.font.start_char)^
    else
      cw := gui^.font.char_width;

    gui^.console.x_pos := gui^.console.x_pos + cw + gui^.char_h_space;
    if gui^.console.x_pos + cw > gui^.console.x_end then
    begin
      gui^.console.x_pos := gui^.console.x_start;
      gui^.console.y_pos := gui^.console.y_pos + gui^.font.char_height +
        gui^.char_v_space;
    end;
    if gui^.console.y_pos + gui^.font.char_height > gui^.console.y_end then
    begin
      gui^.console.x_pos := gui^.console.x_start;
      gui^.console.y_pos := gui^.console.y_start;
      UG_FillFrame(gui^.console.x_start, gui^.console.y_start,
        gui^.console.x_end, gui^.console.y_end, gui^.console.back_color);
    end;
    UG_PutChar(chr, gui^.console.x_pos, gui^.console.y_pos,
      gui^.console.fore_color, gui^.console.back_color);
    Inc(str);
  end;
end;

procedure UG_ConsoleSetArea(xs, ys: UG_S16; xe, ye: UG_S16);
begin
  gui^.console.x_start := xs;
  gui^.console.y_start := ys;
  gui^.console.x_end := xe;
  gui^.console.y_end := ye;
end;

procedure UG_ConsoleSetForecolor(c: UG_COLOR);
begin
  gui^.console.fore_color := c;
end;

procedure UG_ConsoleSetBackcolor(c: UG_COLOR);
begin
  gui^.console.back_color := c;
end;

procedure UG_SetForecolor(c: UG_COLOR);
begin
  gui^.fore_color := c;
end;

procedure UG_SetBackcolor(c: UG_COLOR);
begin
  gui^.back_color := c;
end;

function UG_GetXDim: UG_S16;
begin
  UG_GetXDim := gui^.x_dim;
end;

function UG_GetYDim: UG_S16;
begin
  UG_GetYDim := gui^.y_dim;
end;

procedure UG_FontSetHSpace(s: UG_U16);
begin
  gui^.char_h_space := s;
end;

procedure UG_FontSetVSpace(s: UG_U16);
begin
  gui^.char_v_space := s;
end;

(* Window functions *)
function UG_WindowCreate(var wnd: UG_WINDOW; objlst: PUG_OBJECT;
  objcnt: UG_U8; cb: UG_WINDOW_CB): UG_RESULT;
var
  i: UG_U8;
  obj: PUG_OBJECT;
begin
  obj := nil;
  if (objlst = nil) or (objcnt = 0) then
  begin
    UG_WindowCreate := UG_RESULT_FAIL;
    exit;
  end;
  obj := objlst;
  (* Initialize all objects of the window *)
  for i := 0 to Pred(objcnt) do
  begin
    { obj := (UG_OBJECT* )@objlst[i]; }
    Inc(obj, i);
    obj^.state := OBJ_STATE_INIT;
    obj^.Data := nil;
  end;
  wnd.objcnt := objcnt;
  wnd.objlst := objlst;
  wnd.state := WND_STATE_VALID;

  (* Initialize window *)
  {$ifdef USE_COLOR_RGB888}
  wnd.fc := $000000;
  wnd.bc := $F0F0F0;
  {$endif}
  {$ifdef USE_COLOR_RGB565}
  wnd.fc := $0000;
  wnd.bc := $EF7D;
  {$endif}
  wnd.xs := 0;
  wnd.ys := 0;
  wnd.xe := UG_GetXDim - 1;
  wnd.ye := UG_GetYDim - 1;
  wnd.cb := cb;
  wnd.style := WND_STYLE_3D or WND_STYLE_SHOW_TITLE;
  wnd.title.str := nil;

  (* Initialize window title-bar *)
  if gui <> nil then
    wnd.title.font := @gui^.font
  else
    wnd.title.font := nil;

  wnd.title.h_space := 2;
  wnd.title.v_space := 2;
  wnd.title.align := ALIGN_CENTER_LEFT;
  wnd.title.fc := C_WHITE;
  wnd.title.bc := C_BLUE;
  wnd.title.ifc := C_WHITE;
  wnd.title.ibc := C_GRAY;
  wnd.title.Height := 15;
  UG_WindowCreate := UG_RESULT_OK;
end;

function UG_WindowDelete(var wnd: UG_WINDOW): UG_RESULT;
begin
  if @wnd = gui^.active_window then
  begin
    UG_WindowDelete := UG_RESULT_FAIL;
  end
  else
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.state := 0;
    wnd.cb := nil;
    wnd.objcnt := 0;
    wnd.objlst := nil;
    wnd.xs := 0;
    wnd.ys := 0;
    wnd.xe := 0;
    wnd.ye := 0;
    wnd.style := 0;
    UG_WindowDelete := UG_RESULT_OK;
  end
  else
    UG_WindowDelete := UG_RESULT_FAIL;
end;

function UG_WindowShow(var wnd: UG_WINDOW): UG_RESULT;
begin
  (* Force an update, even if this is the active window! *)
  wnd.state := wnd.state or (WND_STATE_VISIBLE or WND_STATE_UPDATE);
  wnd.state := wnd.state and (not WND_STATE_REDRAW_TITLE);
  gui^.next_window := @wnd;
  UG_WindowShow := UG_RESULT_OK;
end;

(* CHECK RETURN VALUE *)
function UG_WindowHide(var wnd: UG_WINDOW): UG_RESULT;
begin
  if @wnd = gui^.active_window then
  begin
    (* Is there an old window which just lost the focus? *)
    if (gui^.last_window <> nil) and
      ((gui^.last_window^.state and WND_STATE_VISIBLE) <> 0) then
    begin
      if (gui^.last_window^.xs > wnd.xs) or (gui^.last_window^.ys > wnd.ys) or
        (gui^.last_window^.xe < wnd.xe) or (gui^.last_window^.ye < wnd.ye) then
      begin
        _UG_WindowClear(wnd);
      end;
      gui^.next_window := gui^.last_window;
    end
    else
    begin
      gui^.active_window^.state :=
        gui^.active_window^.state and (not WND_STATE_VISIBLE);
      gui^.active_window^.state := gui^.active_window^.state or WND_STATE_UPDATE;
    end;
  end
  else
  begin
    (* If the old window is visible, clear it! *)
    _UG_WindowClear(wnd);
    UG_WindowHide := UG_RESULT_OK;
  end;
end;

function UG_WindowResize(var wnd: UG_WINDOW; xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT;
var
  pos: UG_S16;
  xmax, ymax: UG_S16;
begin
  xmax := UG_GetXDim - 1;
  ymax := UG_GetYDim - 1;
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    (* Do some checks... *)
    if (xs < 0) or (ys < 0) or (xe > xmax) or (ye > ymax) then
    begin
      UG_WindowResize := UG_RESULT_FAIL;
      exit;
    end;

    if ((xe - xs) < 10) or ((ye - ys) < 10) then
    begin
      UG_WindowResize := UG_RESULT_FAIL;
      exit;
    end;

    (* ... and if everything is OK move the window! *)
    wnd.xs := xs;
    wnd.ys := ys;
    wnd.xe := xe;
    wnd.ye := ye;
    if ((wnd.state and WND_STATE_VISIBLE) <> 0) and (gui^.active_window = @wnd) then
    begin
      if wnd.ys <> 0 then
        UG_FillFrame(0, 0, xmax, wnd.ys - 1, gui^.desktop_color);
      pos := wnd.ye + 1;
      if pos <= ymax then
        UG_FillFrame(0, pos, xmax, ymax, gui^.desktop_color);
      if wnd.xs <> 0 then
        UG_FillFrame(0, wnd.ys, wnd.xs - 1, wnd.ye, gui^.desktop_color);
      pos := wnd.xe + 1;
      if pos <= xmax then
        UG_FillFrame(pos, wnd.ys, xmax, wnd.ye, gui^.desktop_color);
      wnd.state := wnd.state and (not WND_STATE_REDRAW_TITLE);
      wnd.state := wnd.state or WND_STATE_UPDATE;
    end;
    UG_WindowResize := UG_RESULT_OK;
  end
  else
    UG_WindowResize := UG_RESULT_FAIL;
end;

function UG_WindowAlert(var wnd: UG_WINDOW): UG_RESULT;
var
  c: UG_COLOR;
begin
  c := UG_WindowGetTitleTextColor(wnd);
  if UG_WindowSetTitleTextColor(wnd, UG_WindowGetTitleColor(wnd)) = UG_RESULT_FAIL then
  begin
    UG_WindowAlert := UG_RESULT_FAIL;
    exit;
  end;
  if UG_WindowSetTitleColor(wnd, c) = UG_RESULT_FAIL then
  begin
    UG_WindowAlert := UG_RESULT_FAIL;
    exit;
  end;
  UG_WindowAlert := UG_RESULT_OK;
end;

(* Windows setters *)
(* PACK ! CHECK SetX/Y Logic ! *)
function UG_WindowSetForeColor(var wnd: UG_WINDOW; fc: UG_COLOR): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.fc := fc;
    wnd.state := wnd.state or WND_STATE_UPDATE;
    UG_WindowSetForeColor := UG_RESULT_OK;
  end
  else
    UG_WindowSetForeColor := UG_RESULT_FAIL;
end;

function UG_WindowSetBackColor(var wnd: UG_WINDOW; bc: UG_COLOR): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.bc := bc;
    wnd.state := wnd.state or WND_STATE_UPDATE;
    UG_WindowSetBackColor := UG_RESULT_OK;
  end
  else
    UG_WindowSetBackColor := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleTextColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.fc := c;
    wnd.state := wnd.state or (WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE);
    UG_WindowSetTitleTextColor := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleTextColor := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.bc := c;
    wnd.state := wnd.state or (WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE);
    UG_WindowSetTitleColor := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleColor := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleInactiveTextColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.ifc := c;
    wnd.state := wnd.state or (WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE);
    UG_WindowSetTitleInactiveTextColor := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleInactiveTextColor := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleInactiveColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.ibc := c;
    wnd.state := wnd.state or (WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE);
    UG_WindowSetTitleInactiveColor := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleInactiveColor := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleText(var wnd: UG_WINDOW; str: PChar): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.str := str;
    wnd.state := wnd.state or (WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE);
    UG_WindowSetTitleText := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleText := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleTextFont(var wnd: UG_WINDOW; font: PUG_FONT): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.state := wnd.state or WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE;
    wnd.title.font := font;
    if wnd.title.Height <= font^.char_height + 1 then
    begin
      wnd.title.Height := font^.char_height + 2;
      wnd.state := wnd.state and (not WND_STATE_REDRAW_TITLE);
    end;
    UG_WindowSetTitleTextFont := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleTextFont := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleTextHSpace(var wnd: UG_WINDOW; hs: UG_S8): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.h_space := hs;
    wnd.state := wnd.state or (WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE);
    UG_WindowSetTitleTextHSpace := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleTextHSpace := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleTextVSpace(var wnd: UG_WINDOW; vs: UG_S8): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.v_space := vs;
    wnd.state := wnd.state or (WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE);
    UG_WindowSetTitleTextVSpace := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleTextVSpace := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleTextAlignment(var wnd: UG_WINDOW; align: UG_U8): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.align := align;
    wnd.state := wnd.state or (WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE);
    UG_WindowSetTitleTextAlignment := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleTextAlignment := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleHeight(var wnd: UG_WINDOW; Height: UG_U8): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.Height := Height;
    wnd.state := wnd.state and (not WND_STATE_REDRAW_TITLE);
    wnd.state := wnd.state or WND_STATE_UPDATE;
    UG_WindowSetTitleHeight := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleHeight := UG_RESULT_FAIL;
end;

function UG_WindowSetXStart(var wnd: UG_WINDOW; xs: UG_S16): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.xs := xs;
    UG_WindowSetXStart := UG_WindowResize(wnd, wnd.xs, wnd.ys, wnd.xe, wnd.ye);
  end
  else
    UG_WindowSetXStart := UG_RESULT_FAIL;
end;

function UG_WindowSetYStart(var wnd: UG_WINDOW; ys: UG_S16): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.ys := ys;
    UG_WindowSetYStart := UG_WindowResize(wnd, wnd.xs, wnd.ys, wnd.xe, wnd.ye);
  end
  else
    UG_WindowSetYStart := UG_RESULT_FAIL;
end;

function UG_WindowSetXEnd(var wnd: UG_WINDOW; xe: UG_S16): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.xe := xe;
    UG_WindowSetXEnd := UG_WindowResize(wnd, wnd.xs, wnd.ys, wnd.xe, wnd.ye);
  end
  else
    UG_WindowSetXEnd := UG_RESULT_FAIL;
end;

function UG_WindowSetYEnd(var wnd: UG_WINDOW; ye: UG_S16): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.ye := ye;
    UG_WindowSetYEnd := UG_WindowResize(wnd, wnd.xs, wnd.ys, wnd.xe, wnd.ye);
  end
  else
    UG_WindowSetYEnd := UG_RESULT_FAIL;
end;

function UG_WindowSetStyle(var wnd: UG_WINDOW; style: UG_U8): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    if (style and WND_STYLE_3D) <> 0 then
      wnd.style := wnd.style or WND_STYLE_3D
    else
      wnd.style := wnd.style and (not WND_STYLE_3D);
    (* Show title-bar? *)
    if (style and WND_STYLE_SHOW_TITLE) <> 0 then
      wnd.style := wnd.style or WND_STYLE_SHOW_TITLE
    else
      wnd.style := wnd.style and (not WND_STYLE_SHOW_TITLE);
    wnd.state := wnd.state or WND_STATE_UPDATE;
    UG_WindowSetStyle := UG_RESULT_OK;
  end
  else
    UG_WindowSetStyle := UG_RESULT_FAIL;
end;

(* Window getters *)
(* PACK *)
function UG_WindowGetForeColor(const wnd: UG_WINDOW): UG_COLOR;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetForeColor := wnd.fc
  else
    UG_WindowGetForeColor := C_BLACK;
end;

function UG_WindowGetBackColor(const wnd: UG_WINDOW): UG_COLOR;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetBackColor := wnd.bc
  else
    UG_WindowGetBackColor := C_BLACK;
end;

function UG_WindowGetTitleTextColor(const wnd: UG_WINDOW): UG_COLOR;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleTextColor := wnd.title.fc
  else
    UG_WindowGetTitleTextColor := C_BLACK;
end;

function UG_WindowGetTitleColor(const wnd: UG_WINDOW): UG_COLOR;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleColor := wnd.title.bc
  else
    UG_WindowGetTitleColor := C_BLACK;
end;

function UG_WindowGetTitleInactiveTextColor(const wnd: UG_WINDOW): UG_COLOR;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleInactiveTextColor := wnd.title.ifc
  else
    UG_WindowGetTitleInactiveTextColor := C_BLACK;
end;

function UG_WindowGetTitleInactiveColor(const wnd: UG_WINDOW): UG_COLOR;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleInactiveColor := wnd.title.ibc
  else
    UG_WindowGetTitleInactiveColor := C_BLACK;
end;

function UG_WindowGetTitleText(const wnd: UG_WINDOW): PChar;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleText := wnd.title.str
  else
    UG_WindowGetTitleText := nil;
end;

function UG_WindowGetTitleTextFont(const wnd: UG_WINDOW): PUG_FONT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleTextFont := wnd.title.font
  else
    UG_WindowGetTitleTextFont := nil;
end;

function UG_WindowGetTitleTextHSpace(const wnd: UG_WINDOW): UG_S8;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleTextHSpace := wnd.title.h_space
  else
    UG_WindowGetTitleTextHSpace := 0;
end;

function UG_WindowGetTitleTextVSpace(const wnd: UG_WINDOW): UG_S8;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleTextVSpace := wnd.title.v_space
  else
    UG_WindowGetTitleTextVSpace := 0;
end;

function UG_WindowGetTitleTextAlignment(const wnd: UG_WINDOW): UG_U8;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleTextAlignment := wnd.title.align
  else
    UG_WindowGetTitleTextAlignment := 0;
end;

function UG_WindowGetTitleHeight(const wnd: UG_WINDOW): UG_U8;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetTitleHeight := wnd.title.Height
  else
    UG_WindowGetTitleHeight := 0;
end;

function UG_WindowGetXStart(const wnd: UG_WINDOW): UG_S16;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetXStart := wnd.xs
  else
    UG_WindowGetXStart := -1;
end;

function UG_WindowGetYStart(const wnd: UG_WINDOW): UG_S16;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetYStart := wnd.ys
  else
    UG_WindowGetYStart := -1;
end;

function UG_WindowGetXEnd(const wnd: UG_WINDOW): UG_S16;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetXEnd := wnd.xe
  else
    UG_WindowGetXEnd := -1;
end;

function UG_WindowGetYEnd(const wnd: UG_WINDOW): UG_S16;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetYEnd := wnd.ye
  else
    UG_WindowGetYEnd := -1;
end;

function UG_WindowGetStyle(const wnd: UG_WINDOW): UG_U8;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
    UG_WindowGetStyle := wnd.style
  else
    UG_WindowGetStyle := 0;
end;

function UG_WindowGetArea(const wnd: UG_WINDOW; var a: UG_AREA): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    a.xs := wnd.xs;
    a.ys := wnd.ys;
    a.xe := wnd.xe;
    a.ye := wnd.ye;
    if (wnd.style and WND_STYLE_3D) <> 0 then
    begin
      a.xs := a.xs + 3;
      a.ys := a.ys + 3;
      a.xe := a.xe - 3;
      a.ye := a.ye - 3;
    end;
    if (wnd.style and WND_STYLE_SHOW_TITLE) <> 0 then
      a.ys := a.ys + wnd.title.Height + 1;
    UG_WindowGetArea := UG_RESULT_OK;
  end
  else
    UG_WindowGetArea := UG_RESULT_FAIL;
end;

function UG_WindowGetInnerWidth(const wnd: UG_WINDOW): UG_S16;
var
  w: UG_S16;
begin
  w := 0;
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    w := wnd.xe - wnd.xs;
    (* 3D style? *)
    if (wnd.style and WND_STYLE_3D) <> 0 then
      w := w - 6;
    if w < 0 then
      w := 0;
  end;
  UG_WindowGetInnerWidth := w;
end;

function UG_WindowGetOuterWidth(const wnd: UG_WINDOW): UG_S16;
var
  w: UG_S16;
begin
  w := 0;
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    w := wnd.xe - wnd.xs;
    if w < 0 then
      w := 0;
  end;
  UG_WindowGetOuterWidth := w;
end;

function UG_WindowGetInnerHeight(const wnd: UG_WINDOW): UG_S16;
var
  h: UG_S16;
begin
  h := 0;
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    h := wnd.ye - wnd.ys;
    (* 3D style? *)
    if (wnd.style and WND_STYLE_3D) <> 0 then
      h := h - 6;
    (* Is the title active *)
    if (wnd.style and WND_STYLE_SHOW_TITLE) <> 0 then
      h := h - wnd.title.Height;
    if h < 0 then
      h := 0;
  end;
  UG_WindowGetInnerHeight := h;
end;

function UG_WindowGetOuterHeight(const wnd: UG_WINDOW): UG_S16;
var
  h: UG_S16;
begin
  h := 0;
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    h := wnd.ye - wnd.ys;
    if h < 0 then
      h := 0;
  end;
  UG_WindowGetOuterHeight := h;
end;

{$I UG_BTN.INC}


(* -------------------------------------------------------------------------------- *)
(* -- TEXTBOX FUNCTIONS                                                          -- *)
(* -------------------------------------------------------------------------------- *)

procedure _UG_TextboxUpdate(wnd: pUG_WINDOW; obj: pUG_OBJECT); 
var
txb: pUG_TEXTBOX; 
a: UG_AREA; 
txt: UG_TEXT; 
(* Get object-specific data *)
begin
  txb:= pUG_TEXTBOX(obj^.data); 
  (* -------------------------------------------------- *)
  (* Object touch section                               *)
  (* -------------------------------------------------- *)
  
  (* Textbox doesn't support touch *)
  
  (* -------------------------------------------------- *)
  (* Object update section                              *)
  (* -------------------------------------------------- *)
  if (obj^.state and OBJ_STATE_UPDATE) <> 0 then
  begin 
    if (obj^.state and OBJ_STATE_VISIBLE) <> 0 then
    begin 
      (* Full redraw necessary? *)
      if (obj^.state and OBJ_STATE_REDRAW) <> 0 then
      begin 
        { UG_WindowGetArea(wnd, a); }
        obj^.a_abs.xs:= obj^.a_rel.xs+a.xs; 
        obj^.a_abs.ys:= obj^.a_rel.ys+a.ys; 
        obj^.a_abs.xe:= obj^.a_rel.xe+a.xs; 
        obj^.a_abs.ye:= obj^.a_rel.ye+a.ys; 
        if obj^.a_abs.ye>=wnd^.ye then exit;
        if obj^.a_abs.xe>=wnd^.xe then exit;
        {$ifdef USE_PRERENDER_EVENT}        
        _UG_SendObjectPrerenderEvent(wnd,obj); 
        {$endif}
        txt.bc:= txb^.bc; 
        txt.fc:= txb^.fc; 
        UG_FillFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe, obj^.a_abs.ye, txt.bc); 
        txt.a.xs:= obj^.a_abs.xs; 
        txt.a.ys:= obj^.a_abs.ys; 
        txt.a.xe:= obj^.a_abs.xe; 
        txt.a.ye:= obj^.a_abs.ye; 
        txt.align:= txb^.align; 
        txt.font:= txb^.font; 
        txt.h_space:= txb^.h_space; 
        txt.v_space:= txb^.v_space; 
        txt.str:= txb^.str; 
        _UG_PutText(txt);
        (* Draw Textbox text *)
        obj^.state:= obj^.state and (not OBJ_STATE_REDRAW); 
        {$ifdef USE_POSTRENDER_EVENT}
        _UG_SendObjectPostrenderEvent(wnd,obj); 
        {$endif}
      end;
    end
    else
    begin 
      UG_FillFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe, obj^.a_abs.ye, wnd^.bc); 
    end;
    obj^.state:= obj^.state and (not OBJ_STATE_UPDATE); 
  end;
end;

function UG_TextboxCreate(const wnd: UG_WINDOW; var txb: UG_TEXTBOX; id: UG_U8;
  xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT; 
var
obj: pUG_OBJECT; 
begin
  obj:= _UG_GetFreeObject(wnd); 
  if obj=nil then
  begin
    UG_TextboxCreate:= UG_RESULT_FAIL; 
    exit;
  end;
  (* Initialize object-specific parameters *)  
  txb.str:= nil; 
  if gui<>nil then
    txb.font:= @(gui^.font)
  else
    txb.font:= nil; 
  txb.style:= 0; 
  txb.fc:= wnd.fc; 
  txb.bc:= wnd.bc; 
  txb.align:= ALIGN_CENTER; 
  txb.h_space:= 0; 
  txb.v_space:= 0; 
  (* Initialize standard object parameters *)  
  { obj.update:= _UG_TextboxUpdate; }
  obj^.touch_state:= OBJ_TOUCH_STATE_INIT; 
  obj^.otype:= OBJ_TYPE_TEXTBOX; 
  obj^.event:= OBJ_EVENT_NONE; 
  obj^.a_rel.xs:= xs; 
  obj^.a_rel.ys:= ys; 
  obj^.a_rel.xe:= xe; 
  obj^.a_rel.ye:= ye; 
  obj^.a_abs.xs:= -1; 
  obj^.a_abs.ys:= -1; 
  obj^.a_abs.xe:= -1; 
  obj^.a_abs.ye:= -1; 
  obj^.id:= id; 
  obj^.state:= obj^.state or (OBJ_STATE_VISIBLE or OBJ_STATE_REDRAW or OBJ_STATE_VALID); 
  obj^.data:= @txb; 
  obj^.state:= obj^.state and (not OBJ_STATE_FREE);
  (* Update function: Do your thing! *)
  UG_TextboxCreate:= UG_RESULT_OK; 
end;

function UG_TextboxDelete(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT; 
begin
    UG_TextboxDelete:= _UG_DeleteObject(wnd, OBJ_TYPE_TEXTBOX,id); 
end;

function UG_TextboxShow(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT; 
var
obj: pUG_OBJECT;
begin
  obj:= _UG_SearchObject(wnd,OBJ_TYPE_TEXTBOX,id); 
  if obj <> nil then 
  begin
    obj^.state:= obj^.state or (OBJ_STATE_VISIBLE); 
    obj^.state:= obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW); 
    UG_TextboxShow:= UG_RESULT_OK; 
  end
  else 
    UG_TextboxShow:= UG_RESULT_FAIL;   
end;



(* -------------------------------------------------------------------------- *)
(* -- Checkbox FUNCTIONS ! TO DO !                                         -- *)
(* -------------------------------------------------------------------------- *)
const
{$ifdef USE_COLOR_RGB888}
  pal_checkbox_pressed: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464,  (* Frame 0 *)
    $A0A0A0, $A0A0A0, $A0A0A0, $A0A0A0,   (* Frame 1 *)
    $F0F0F0, $F0F0F0, $F0F0F0, $F0F0F0);  (* Frame 2 *)
  pal_checkbox_released: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464,  (* Frame 0 *)
    $FFFFFF, $FFFFFF, $696969, $696969,   (* Frame 1 *)
    $E3E3E3, $E3E3E3, $A0A0A0, $A0A0A0);  (* Frame 2 *)
{$endif}
{$ifdef USE_COLOR_RGB565}
  pal_checkbox_pressed: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $9D13, $9D13, $9D13, $9D13, $EF7D, $EF7D, $EF7D, $EF7D);
  pal_checkbox_released: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $FFFF, $FFFF, $6B4D, $6B4D, $E71C, $E71C, $9D13, $9D13);

{$endif}

(* -------------------------------------------------------------------------- *)
(* -- Image functions                                                      -- *)
(* -------------------------------------------------------------------------- *)

(* ? Internal ? *)
procedure UG_DrawBMP(xp, yp: UG_S16; bmp: PUG_BMP);
var
  x, y, xs: UG_S16;
  r, g, b: UG_U8;
  p: PUG_U16;
  tmp: UG_U16;
  c: UG_COLOR;
begin
  if bmp^.p = nil then
    exit;

  (* Only support 16 BPP so  *)
  if bmp^.bpp = BMP_BPP_16 then
    p := PUG_U16(bmp^.p)
  else
    exit;

  xs := xp;
  for y := 0 to Pred(bmp^.Height) do
  begin
    xp := xs;
    for x := 0 to Pred(bmp^.Width) do
    begin
      tmp := p^;
      Inc(p);
      (* Convert RGB565 to RGB888 *)
      r := (tmp shr 11) and $1F;
      r := r shl (3);
      g := (tmp shr 5) and $3F;
      g := g shl (2);
      b := (tmp) and $1F;
      b := b shl (3);
      c := UG_COLOR(r shl 16) or UG_COLOR(g shl 8) or UG_COLOR(b);
      UG_DrawPixel(xp, yp, c);
      Inc(xp);
    end;
    Inc(yp);
  end;
end;

procedure _UG_ImageUpdate(wnd: PUG_WINDOW; obj: PUG_OBJECT);
var
  img: PUG_IMAGE;
  a: UG_AREA;
begin
  (* Get object-specific data *)
  img := PUG_IMAGE(obj^.Data);
  (* -------------------------------------------------- *)
  (* Object touch section                               *)
  (* -------------------------------------------------- *)

  (* Image doesn't support touch *)

  (* -------------------------------------------------- *)
  (* Object update section                              *)
  (* -------------------------------------------------- *)
  if (obj^.state and OBJ_STATE_UPDATE) <> 0 then
  begin
    if (obj^.state and OBJ_STATE_VISIBLE) <> 0 then
    begin
      (* Full redraw necessary? *)
      if (obj^.state and OBJ_STATE_REDRAW) <> 0 then
      begin
        UG_WindowGetArea(wnd^, a);
        (* ToDo: more/better image features *)
        obj^.a_abs.xs := obj^.a_rel.xs + a.xs;
        obj^.a_abs.ys := obj^.a_rel.ys + a.ys;
        obj^.a_abs.xe := obj^.a_rel.xs + PUG_BMP(img^.img)^.Width + a.xs;
        obj^.a_abs.ye := obj^.a_rel.ys + PUG_BMP(img^.img)^.Height + a.ys;
        if (obj^.a_abs.ye >= wnd^.ye) or (obj^.a_abs.xe >= wnd^.xe) then
          exit;

        (* Draw Image *)
        if (img^.img <> nil) and ((img^.itype and IMG_TYPE_BMP) <> 0) then
          UG_DrawBMP(obj^.a_abs.xs, obj^.a_abs.ys, PUG_BMP(img^.img));
        obj^.state := obj^.state and (not OBJ_STATE_REDRAW);
      end;
    end
    else
      UG_FillFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe, obj^.a_abs.ye, wnd^.bc);
    obj^.state := obj^.state and (not OBJ_STATE_UPDATE);
  end;
end;

function UG_ImageCreate(const wnd: UG_WINDOW; var img: UG_IMAGE;
  id: UG_U8; xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := _UG_GetFreeObject(wnd);
  if obj = nil then
  begin
    UG_ImageCreate := UG_RESULT_FAIL;
    exit;
  end;
  (* Initialize object-specific parameters *)
  img.img := nil;
  img.itype := IMG_TYPE_BMP;
  (* Initialize standard object parameters *)
  obj^.update := _UG_ImageUpdate;
  obj^.touch_state := OBJ_TOUCH_STATE_INIT;
  obj^.otype := OBJ_TYPE_IMAGE;
  obj^.event := OBJ_EVENT_NONE;
  obj^.a_rel.xs := xs;
  obj^.a_rel.ys := ys;
  obj^.a_rel.xe := xe;
  obj^.a_rel.ye := ye;
  obj^.a_abs.xs := -1;
  obj^.a_abs.ys := -1;
  obj^.a_abs.xe := -1;
  obj^.a_abs.ye := -1;
  obj^.id := id;
  obj^.state := obj^.state or (OBJ_STATE_VISIBLE or OBJ_STATE_REDRAW or OBJ_STATE_VALID);
  obj^.Data := @img;
  (* Update function: Do your thing! *)
  obj^.state := obj^.state and (not OBJ_STATE_FREE);
  UG_ImageCreate := UG_RESULT_OK;
end;

function UG_ImageDelete(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
begin
  UG_ImageDelete := _UG_DeleteObject(wnd, OBJ_TYPE_IMAGE, id);
end;

function UG_ImageShow(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_IMAGE, id);
  if obj = nil then
  begin
    UG_ImageShow := UG_RESULT_FAIL;
    exit;
  end;
  obj^.state := obj^.state or (OBJ_STATE_VISIBLE);
  obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
  UG_ImageShow := UG_RESULT_OK;
end;

function UG_ImageHide(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_IMAGE, id);
  if obj = nil then
  begin
    UG_ImageHide := UG_RESULT_FAIL;
    exit;
  end;
  obj^.state := obj^.state and (not OBJ_STATE_VISIBLE);
  obj^.state := obj^.state or (OBJ_STATE_UPDATE);
  UG_ImageHide := UG_RESULT_OK;
end;

function UG_ImageSetBMP(const wnd: UG_WINDOW; id: UG_U8; bmp: PUG_BMP): UG_RESULT;
var
  obj: PUG_OBJECT;
  img: PUG_IMAGE;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_IMAGE, id);
  if obj = nil then
  begin
    UG_ImageSetBMP := UG_RESULT_FAIL;
    exit;
  end;
  img := PUG_IMAGE(obj^.Data);
  img^.img := PUG_U8(bmp);
  img^.itype := IMG_TYPE_BMP;
  obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
  UG_ImageSetBMP := UG_RESULT_OK;
end;

(* -------------------------------------------------------------------------- *)
(* -- MISCELLANEOUS FUNCTIONS                                              -- *)
(* -------------------------------------------------------------------------- *)
(* PACK *)
procedure UG_Update;
var
  wnd: PUG_WINDOW;
begin
  (* Is somebody waiting for this update? *)
  if (gui^.state and UG_SATUS_WAIT_FOR_UPDATE) <> 0 then
    gui^.state := gui^.state and (not UG_SATUS_WAIT_FOR_UPDATE);
  (* Keep track of the windows *)
  if gui^.next_window <> gui^.active_window then
  begin
    if gui^.next_window <> nil then
    begin
      gui^.last_window := gui^.active_window;
      gui^.active_window := gui^.next_window;
      (* Do we need to draw an inactive title? *)
      if (gui^.last_window <> nil) and
        ((gui^.last_window^.style and WND_STYLE_SHOW_TITLE) <> 0) and
        ((gui^.last_window^.state and WND_STATE_VISIBLE) <> 0) then
      begin
        (* Do both windows differ in size *)
        if ((gui^.last_window^.xs <> gui^.active_window^.xs) or
          (gui^.last_window^.xe <> gui^.active_window^.xe) or
          (gui^.last_window^.ys <> gui^.active_window^.ys) or
          (gui^.last_window^.ye <> gui^.active_window^.ye)) then
        begin
          (* Redraw title of the last window *)
          _UG_WindowDrawTitle(gui^.last_window^);
        end;
      end;
      gui^.active_window^.state :=
        gui^.active_window^.state and (not WND_STATE_REDRAW_TITLE);
      gui^.active_window^.state :=
        gui^.active_window^.state or WND_STATE_UPDATE or WND_STATE_VISIBLE;
    end;
  end;

  (* Is there an active window *)
  if gui^.active_window <> nil then
  begin
    wnd := gui^.active_window;
    (* Does the window need to be updated? *)
    if (wnd^.state and WND_STATE_UPDATE) <> 0 then
      (* Do it! *)
      _UG_WindowUpdate(wnd^);

    (* Is the window visible? *)
    if (wnd^.state and WND_STATE_VISIBLE) <> 0 then
    begin
      _UG_ProcessTouchData(wnd);
      _UG_UpdateObjects(wnd);
      _UG_HandleEvents(wnd);
    end;
  end;
end;

(* ! NOT USED ! *)
procedure UG_WaitForUpdate;
begin
  gui^.state := gui^.state or UG_SATUS_WAIT_FOR_UPDATE;
  (* TO REV *)
  while (gui^.state and UG_SATUS_WAIT_FOR_UPDATE) <> 0 do
  begin
{$ifndef EMBEDDED}  
    {$ifdef FPC}
    Sleep(10);
    {$endif}
{$endif}
    ;
  end;
end;

procedure UG_TouchUpdate(xp, yp: UG_S16; state: UG_U8);
begin
  gui^.touch.xp := xp;
  gui^.touch.yp := yp;
  gui^.touch.state := state;
end;

(* -------------------------------------------------------------------------- *)
(* -- DRIVER FUNCTIONS                                                     -- *)
(* -------------------------------------------------------------------------- *)

procedure UG_DriverRegister(t: UG_U8; driver: Pointer);
begin
  if t < NUMBER_OF_DRIVERS then
  begin
    gui^.driver[t].driver := driver;
    gui^.driver[t].state := DRIVER_REGISTERED or DRIVER_ENABLED;
  end;
end;

procedure UG_DriverEnable(t: UG_U8);
begin
  if (t < NUMBER_OF_DRIVERS) and ((gui^.driver[t].state and DRIVER_REGISTERED) <> 0) then
    gui^.driver[t].state := gui^.driver[t].state or DRIVER_ENABLED;
end;

procedure UG_DriverDisable(t: UG_U8);
begin
  if (t < NUMBER_OF_DRIVERS) and ((gui^.driver[t].state and DRIVER_REGISTERED) <> 0) then
    gui^.driver[t].state := gui^.driver[t].state and (not DRIVER_ENABLED);
end;

end.

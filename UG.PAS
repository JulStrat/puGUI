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
{$define USE_COLOR_RGB888}

interface

uses UG_FONTS, UG_TYPES;

const
  (* Alignments *)
  ALIGN_H_LEFT = (1 shl 0);
  ALIGN_H_CENTER = (1 shl 1);
  ALIGN_H_RIGHT = (1 shl 2);
  ALIGN_V_TOP = (1 shl 3);
  ALIGN_V_CENTER = (1 shl 4);
  ALIGN_V_BOTTOM = (1 shl 5);
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

  BMP_BPP_1 = 1 shl 0;
  BMP_BPP_2 = 1 shl 1;
  BMP_BPP_4 = 1 shl 2;
  BMP_BPP_8 = 1 shl 3;
  BMP_BPP_16 = 1 shl 4;
  BMP_BPP_32 = 1 shl 5;
  BMP_RGB888 = 1 shl 0;
  BMP_RGB565 = 1 shl 1;
  BMP_RGB555 = 1 shl 2;

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
  OBJ_STATE_FREE = (1 shl 0);
  OBJ_STATE_VALID = (1 shl 1);
  OBJ_STATE_BUSY = (1 shl 2);
  OBJ_STATE_VISIBLE = (1 shl 3);
  OBJ_STATE_ENABLE = (1 shl 4);
  OBJ_STATE_UPDATE = (1 shl 5);
  OBJ_STATE_REDRAW = (1 shl 6);
  OBJ_STATE_TOUCH_ENABLE = (1 shl 7);
  OBJ_STATE_INIT = (OBJ_STATE_FREE or OBJ_STATE_VALID);

  (* Object touch states *)
  OBJ_TOUCH_STATE_CHANGED = (1 shl 0);
  OBJ_TOUCH_STATE_PRESSED_ON_OBJECT = (1 shl 1);
  OBJ_TOUCH_STATE_PRESSED_OUTSIDE_OBJECT = (1 shl 2);
  OBJ_TOUCH_STATE_RELEASED_ON_OBJECT = (1 shl 3);
  OBJ_TOUCH_STATE_RELEASED_OUTSIDE_OBJECT = (1 shl 4);
  OBJ_TOUCH_STATE_IS_PRESSED_ON_OBJECT = (1 shl 5);
  OBJ_TOUCH_STATE_IS_PRESSED = (1 shl 6);
  OBJ_TOUCH_STATE_CLICK_ON_OBJECT = (1 shl 7);
  OBJ_TOUCH_STATE_INIT = 0;

  (* Window states *)
  WND_STATE_FREE = (1 shl 0);
  WND_STATE_VALID = (1 shl 1);
  WND_STATE_BUSY = (1 shl 2);
  WND_STATE_VISIBLE = (1 shl 3);
  WND_STATE_ENABLE = (1 shl 4);
  WND_STATE_UPDATE = (1 shl 5);
  WND_STATE_REDRAW_TITLE = (1 shl 6);

  (* Window styles *)
  WND_STYLE_2D = (0 shl 0);
  WND_STYLE_3D = (1 shl 0);
  WND_STYLE_HIDE_TITLE = (0 shl 1);
  WND_STYLE_SHOW_TITLE = (1 shl 1);

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
  IMG_TYPE_BMP = (1 shl 0);

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
  BTN_STATE_RELEASED = (0 shl 0);
  BTN_STATE_PRESSED = (1 shl 0);
  BTN_STATE_ALWAYS_REDRAW = (1 shl 1);

  (* Button style *)
  BTN_STYLE_2D = (0 shl 0);
  BTN_STYLE_3D = (1 shl 0);
  BTN_STYLE_TOGGLE_COLORS = (1 shl 1);
  BTN_STYLE_USE_ALTERNATE_COLORS = (1 shl 2);
  BTN_STYLE_NO_BORDERS = (1 shl 3);
  BTN_STYLE_NO_FILL = (1 shl 4);

  (* Button events *)
  BTN_EVENT_CLICKED = OBJ_EVENT_CLICKED;

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

  UG_SATUS_WAIT_FOR_UPDATE = (1 shl 0);

  (* -------------------------------------------------------------------------------- *)
  (* -- µGUI COLORS                                                                -- *)
  (* -- Source: http://www.rapidtables.com/web/color/RGB_Color.htm                 -- *)
  (* -------------------------------------------------------------------------------- *)
{$ifdef USE_COLOR_RGB565}
  C_MAROON = $8000;
  C_DARK_RED = $8800;
  C_BROWN = $A145;
  C_FIREBRICK = $B104;
  C_CRIMSON = $D8A7;
  C_RED = $F800;
  C_TOMATO = $FB09;
  C_CORAL = $FBEA;
  C_INDIAN_RED = $CAEB;
  C_LIGHT_CORAL = $EC10;
  C_DARK_SALMON = $E4AF;
  C_SALMON = $F40E;
  C_LIGHT_SALMON = $FD0F;
  C_ORANGE_RED = $FA20;
  C_DARK_ORANGE = $FC60;
  C_ORANGE = $FD20;
  C_GOLD = $FEA0;
  C_DARK_GOLDEN_ROD = $B421;
  C_GOLDEN_ROD = $DD24;
  C_PALE_GOLDEN_ROD = $EF35;
  C_DARK_KHAKI = $BDAD;
  C_KHAKI = $EF31;
  C_OLIVE = $8400;
  C_YELLOW = $FFE0;
  C_YELLOW_GREEN = $9E66;
  C_DARK_OLIVE_GREEN = $5346;
  C_OLIVE_DRAB = $6C64;
  C_LAWN_GREEN = $7FC0;
  C_CHART_REUSE = $7FE0;
  C_GREEN_YELLOW = $AFE6;
  C_DARK_GREEN = $0320;
  C_GREEN = $07E0;
  C_FOREST_GREEN = $2444;
  C_LIME = $07E0;
  C_LIME_GREEN = $3666;
  C_LIGHT_GREEN = $9772;
  C_PALE_GREEN = $97D2;
  C_DARK_SEA_GREEN = $8DD1;
  C_MEDIUM_SPRING_GREEN = $07D3;
  C_SPRING_GREEN = $07EF;
  C_SEA_GREEN = $344B;
  C_MEDIUM_AQUA_MARINE = $6675;
  C_MEDIUM_SEA_GREEN = $3D8E;
  C_LIGHT_SEA_GREEN = $2595;
  C_DARK_SLATE_GRAY = $328A;
  C_TEAL = $0410;
  C_DARK_CYAN = $0451;
  C_AQUA = $07FF;
  C_CYAN = $07FF;
  C_LIGHT_CYAN = $DFFF;
  C_DARK_TURQUOISE = $0679;
  C_TURQUOISE = $46F9;
  C_MEDIUM_TURQUOISE = $4E99;
  C_PALE_TURQUOISE = $AF7D;
  C_AQUA_MARINE = $7FFA;
  C_POWDER_BLUE = $AEFC;
  C_CADET_BLUE = $64F3;
  C_STEEL_BLUE = $4C16;
  C_CORN_FLOWER_BLUE = $64BD;
  C_DEEP_SKY_BLUE = $05FF;
  C_DODGER_BLUE = $249F;
  C_LIGHT_BLUE = $AEBC;
  C_SKY_BLUE = $867D;
  C_LIGHT_SKY_BLUE = $867E;
  C_MIDNIGHT_BLUE = $18CE;
  C_NAVY = $0010;
  C_DARK_BLUE = $0011;
  C_MEDIUM_BLUE = $0019;
  C_BLUE = $001F;
  C_ROYAL_BLUE = $435B;
  C_BLUE_VIOLET = $897B;
  C_INDIGO = $4810;
  C_DARK_SLATE_BLUE = $49F1;
  C_SLATE_BLUE = $6AD9;
  C_MEDIUM_SLATE_BLUE = $7B5D;
  C_MEDIUM_PURPLE = $939B;
  C_DARK_MAGENTA = $8811;
  C_DARK_VIOLET = $901A;
  C_DARK_ORCHID = $9999;
  C_MEDIUM_ORCHID = $BABA;
  C_PURPLE = $8010;
  C_THISTLE = $D5FA;
  C_PLUM = $DD1B;
  C_VIOLET = $EC1D;
  C_MAGENTA = $F81F;
  C_ORCHID = $DB9A;
  C_MEDIUM_VIOLET_RED = $C0B0;
  C_PALE_VIOLET_RED = $DB92;
  C_DEEP_PINK = $F8B2;
  C_HOT_PINK = $FB56;
  C_LIGHT_PINK = $FDB7;
  C_PINK = $FDF9;
  C_ANTIQUE_WHITE = $F75A;
  C_BEIGE = $F7BB;
  C_BISQUE = $FF18;
  C_BLANCHED_ALMOND = $FF59;
  C_WHEAT = $F6F6;
  C_CORN_SILK = $FFBB;
  C_LEMON_CHIFFON = $FFD9;
  C_LIGHT_GOLDEN_ROD_YELLOW = $F7DA;
  C_LIGHT_YELLOW = $FFFB;
  C_SADDLE_BROWN = $8A22;
  C_SIENNA = $9A85;
  C_CHOCOLATE = $D344;
  C_PERU = $CC28;
  C_SANDY_BROWN = $F52C;
  C_BURLY_WOOD = $DDB0;
  C_TAN = $D591;
  C_ROSY_BROWN = $BC71;
  C_MOCCASIN = $FF16;
  C_NAVAJO_WHITE = $FEF5;
  C_PEACH_PUFF = $FED6;
  C_MISTY_ROSE = $FF1B;
  C_LAVENDER_BLUSH = $FF7E;
  C_LINEN = $F77C;
  C_OLD_LACE = $FFBC;
  C_PAPAYA_WHIP = $FF7A;
  C_SEA_SHELL = $FFBD;
  C_MINT_CREAM = $F7FE;
  C_SLATE_GRAY = $7412;
  C_LIGHT_SLATE_GRAY = $7453;
  C_LIGHT_STEEL_BLUE = $AE1B;
  C_LAVENDER = $E73E;
  C_FLORAL_WHITE = $FFDD;
  C_ALICE_BLUE = $EFBF;
  C_GHOST_WHITE = $F7BF;
  C_HONEYDEW = $EFFD;
  C_IVORY = $FFFD;
  C_AZURE = $EFFF;
  C_SNOW = $FFDE;
  C_BLACK = $0000;
  C_DIM_GRAY = $6B4D;
  C_GRAY = $8410;
  C_DARK_GRAY = $AD55;
  C_SILVER = $BDF7;
  C_LIGHT_GRAY = $D69A;
  C_GAINSBORO = $DEDB;
  C_WHITE_SMOKE = $F7BE;
  C_WHITE = $FFFF;
{$endif}

{$ifdef USE_COLOR_RGB888}
  C_MAROON = $800000;
  C_DARK_RED = $8B0000;
  C_BROWN = $A52A2A;
  C_FIREBRICK = $B22222;
  C_CRIMSON = $DC143C;
  C_RED = $FF0000;
  C_TOMATO = $FF6347;
  C_CORAL = $FF7F50;
  C_INDIAN_RED = $CD5C5C;
  C_LIGHT_CORAL = $F08080;
  C_DARK_SALMON = $E9967A;
  C_SALMON = $FA8072;
  C_LIGHT_SALMON = $FFA07A;
  C_ORANGE_RED = $FF4500;
  C_DARK_ORANGE = $FF8C00;
  C_ORANGE = $FFA500;
  C_GOLD = $FFD700;
  C_DARK_GOLDEN_ROD = $B8860B;
  C_GOLDEN_ROD = $DAA520;
  C_PALE_GOLDEN_ROD = $EEE8AA;
  C_DARK_KHAKI = $BDB76B;
  C_KHAKI = $F0E68C;
  C_OLIVE = $808000;
  C_YELLOW = $FFFF00;
  C_YELLOW_GREEN = $9ACD32;
  C_DARK_OLIVE_GREEN = $556B2F;
  C_OLIVE_DRAB = $6B8E23;
  C_LAWN_GREEN = $7CFC00;
  C_CHART_REUSE = $7FFF00;
  C_GREEN_YELLOW = $ADFF2F;
  C_DARK_GREEN = $006400;
  C_GREEN = $00FF00;
  C_FOREST_GREEN = $228B22;
  C_LIME = $00FF00;
  C_LIME_GREEN = $32CD32;
  C_LIGHT_GREEN = $90EE90;
  C_PALE_GREEN = $98FB98;
  C_DARK_SEA_GREEN = $8FBC8F;
  C_MEDIUM_SPRING_GREEN = $00FA9A;
  C_SPRING_GREEN = $00FF7F;
  C_SEA_GREEN = $2E8B57;
  C_MEDIUM_AQUA_MARINE = $66CDAA;
  C_MEDIUM_SEA_GREEN = $3CB371;
  C_LIGHT_SEA_GREEN = $20B2AA;
  C_DARK_SLATE_GRAY = $2F4F4F;
  C_TEAL = $008080;
  C_DARK_CYAN = $008B8B;
  C_AQUA = $00FFFF;
  C_CYAN = $00FFFF;
  C_LIGHT_CYAN = $E0FFFF;
  C_DARK_TURQUOISE = $00CED1;
  C_TURQUOISE = $40E0D0;
  C_MEDIUM_TURQUOISE = $48D1CC;
  C_PALE_TURQUOISE = $AFEEEE;
  C_AQUA_MARINE = $7FFFD4;
  C_POWDER_BLUE = $B0E0E6;
  C_CADET_BLUE = $5F9EA0;
  C_STEEL_BLUE = $4682B4;
  C_CORN_FLOWER_BLUE = $6495ED;
  C_DEEP_SKY_BLUE = $00BFFF;
  C_DODGER_BLUE = $1E90FF;
  C_LIGHT_BLUE = $ADD8E6;
  C_SKY_BLUE = $87CEEB;
  C_LIGHT_SKY_BLUE = $87CEFA;
  C_MIDNIGHT_BLUE = $191970;
  C_NAVY = $000080;
  C_DARK_BLUE = $00008B;
  C_MEDIUM_BLUE = $0000CD;
  C_BLUE = $0000FF;
  C_ROYAL_BLUE = $4169E1;
  C_BLUE_VIOLET = $8A2BE2;
  C_INDIGO = $4B0082;
  C_DARK_SLATE_BLUE = $483D8B;
  C_SLATE_BLUE = $6A5ACD;
  C_MEDIUM_SLATE_BLUE = $7B68EE;
  C_MEDIUM_PURPLE = $9370DB;
  C_DARK_MAGENTA = $8B008B;
  C_DARK_VIOLET = $9400D3;
  C_DARK_ORCHID = $9932CC;
  C_MEDIUM_ORCHID = $BA55D3;
  C_PURPLE = $800080;
  C_THISTLE = $D8BFD8;
  C_PLUM = $DDA0DD;
  C_VIOLET = $EE82EE;
  C_MAGENTA = $FF00FF;
  C_ORCHID = $DA70D6;
  C_MEDIUM_VIOLET_RED = $C71585;
  C_PALE_VIOLET_RED = $DB7093;
  C_DEEP_PINK = $FF1493;
  C_HOT_PINK = $FF69B4;
  C_LIGHT_PINK = $FFB6C1;
  C_PINK = $FFC0CB;
  C_ANTIQUE_WHITE = $FAEBD7;
  C_BEIGE = $F5F5DC;
  C_BISQUE = $FFE4C4;
  C_BLANCHED_ALMOND = $FFEBCD;
  C_WHEAT = $F5DEB3;
  C_CORN_SILK = $FFF8DC;
  C_LEMON_CHIFFON = $FFFACD;
  C_LIGHT_GOLDEN_ROD_YELLOW = $FAFAD2;
  C_LIGHT_YELLOW = $FFFFE0;
  C_SADDLE_BROWN = $8B4513;
  C_SIENNA = $A0522D;
  C_CHOCOLATE = $D2691E;
  C_PERU = $CD853F;
  C_SANDY_BROWN = $F4A460;
  C_BURLY_WOOD = $DEB887;
  C_TAN = $D2B48C;
  C_ROSY_BROWN = $BC8F8F;
  C_MOCCASIN = $FFE4B5;
  C_NAVAJO_WHITE = $FFDEAD;
  C_PEACH_PUFF = $FFDAB9;
  C_MISTY_ROSE = $FFE4E1;
  C_LAVENDER_BLUSH = $FFF0F5;
  C_LINEN = $FAF0E6;
  C_OLD_LACE = $FDF5E6;
  C_PAPAYA_WHIP = $FFEFD5;
  C_SEA_SHELL = $FFF5EE;
  C_MINT_CREAM = $F5FFFA;
  C_SLATE_GRAY = $708090;
  C_LIGHT_SLATE_GRAY = $778899;
  C_LIGHT_STEEL_BLUE = $B0C4DE;
  C_LAVENDER = $E6E6FA;
  C_FLORAL_WHITE = $FFFAF0;
  C_ALICE_BLUE = $F0F8FF;
  C_GHOST_WHITE = $F8F8FF;
  C_HONEYDEW = $F0FFF0;
  C_IVORY = $FFFFF0;
  C_AZURE = $F0FFFF;
  C_SNOW = $FFFAFA;
  C_BLACK = $000000;
  C_DIM_GRAY = $696969;
  C_GRAY = $808080;
  C_DARK_GRAY = $A9A9A9;
  C_SILVER = $C0C0C0;
  C_LIGHT_GRAY = $D3D3D3;
  C_GAINSBORO = $DCDCDC;
  C_WHITE_SMOKE = $F5F5F5;
  C_WHITE = $FFFFFF;
{$endif}

  DRIVER_REGISTERED = (1 shl 0);
  DRIVER_ENABLED = (1 shl 1);

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
{$ifdef USE_COLOR_RGB888}
  UG_COLOR = UG_U32;
{$endif}
{$ifdef USE_COLOR_RGB565}
  UG_COLOR = UG_U16;
{$endif}

  (* -------------------------------------------------------------------------------- *)
  (* -- UNIVERSAL STRUCTURES                                                       -- *)
  (* -------------------------------------------------------------------------------- *)
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
  (* -- BITMAP                                                                     -- *)
  (* -------------------------------------------------------------------------------- *)
  UG_BMP = record
    p: PUG_U8;
    Width: UG_U16;
    Height: UG_U16;
    bpp: UG_U8;
    colors: UG_U8;
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
    update: PUG_CALLBACK; (* pointer to object-specific update function *)
    a_abs: UG_AREA;       (* absolute area of the object                *)
    a_rel: UG_AREA;       (* relative area of the object                *)
    otype: UG_U8;         (* object type                                *)
    id: UG_U8;            (* object ID                                  *)
    event: UG_U8;         (* object-specific events                     *)
    Data: PUG_U8;       (* pointer to object-specific data            *)
  end;
  UG_OBJECT = S_OBJECT;

  (* Currently supported objects *)

  (* -------------------------------------------------------------------------------- *)
  (* -- WINDOW                                                                     -- *)
  (* -------------------------------------------------------------------------------- *)
  (* Title structure *)

  UG_TITLE = record
    str: PChar;
    font: pUG_FONT;
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
    objlst: pUG_OBJECT;
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

  (* -------------------------------------------------------------------------------- *)
  (* -- BUTTON OBJECT                                                              -- *)
  (* -------------------------------------------------------------------------------- *)
  (* Button structure *)
  UG_BUTTON = record
    state: UG_U8;
    style: UG_U8;
    fc: UG_COLOR;
    bc: UG_COLOR;
    afc: UG_COLOR;
    abc: UG_COLOR;
    font: pUG_FONT;
    align: UG_U8;
    h_space: UG_S8;
    v_space: UG_S8;
    str: PChar;
  end;

(* -------------------------------------------------------------------------------- *)
(* -- CHECKBOX OBJECT                                                            -- *)
(* -------------------------------------------------------------------------------- *)
(* Checkbox structure *)
type
  UG_CHECKBOX = record
    state: UG_U8;
    style: UG_U8;
    fc: UG_COLOR;
    bc: UG_COLOR;
    afc: UG_COLOR;
    abc: UG_COLOR;
    font: pUG_FONT;
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
  CHB_STATE_RELEASED = (0 shl 0);
  CHB_STATE_PRESSED = (1 shl 0);
  CHB_STATE_ALWAYS_REDRAW = (1 shl 1);

  (* Checkbox style *)
  CHB_STYLE_2D = (0 shl 0);
  CHB_STYLE_3D = (1 shl 0);
  CHB_STYLE_TOGGLE_COLORS = (1 shl 1);
  CHB_STYLE_USE_ALTERNATE_COLORS = (1 shl 2);
  CHB_STYLE_NO_BORDERS = (1 shl 3);
  CHB_STYLE_NO_FILL = (1 shl 4);

  (* Checkbox events *)
  CHB_EVENT_CLICKED = OBJ_EVENT_CLICKED;

(* -------------------------------------------------------------------------------- *)
(* -- TEXTBOX OBJECT                                                             -- *)
(* -------------------------------------------------------------------------------- *)
(* Textbox structure *)
type
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

  (* -------------------------------------------------------------------------------- *)
  (* -- IMAGE OBJECT                                                               -- *)
  (* -------------------------------------------------------------------------------- *)
  (* Image structure *)

  UG_IMAGE = record
    img: PUG_U8;
    itype: UG_U8;
  end;

(* -------------------------------------------------------------------------------- *)
(* -- µGUI DRIVER                                                                -- *)
(* -------------------------------------------------------------------------------- *)
type
  UG_DRIVER = record
    driver: Pointer;
    state: UG_U8;
  end;

  (* -------------------------------------------------------------------------------- *)
  (* -- µGUI CORE STRUCTURE                                                        -- *)
  (* -------------------------------------------------------------------------------- *)

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

(* -------------------------------------------------------------------------------- *)
(* -- PROTOTYPES                                                                 -- *)
(* -------------------------------------------------------------------------------- *)
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
(* Console *)
procedure UG_ConsolePutString(str: PChar);
procedure UG_ConsoleSetArea(xs, ys: UG_S16; xe, ye: UG_S16);
procedure UG_ConsoleSetForecolor(c: UG_COLOR);
procedure UG_ConsoleSetBackcolor(c: UG_COLOR);

procedure UG_SetForecolor(c: UG_COLOR);
procedure UG_SetBackcolor(c: UG_COLOR);
function UG_GetXDim: UG_S16;
function UG_GetYDim: UG_S16;
procedure UG_FontSetHSpace(s: UG_U16);
procedure UG_FontSetVSpace(s: UG_U16);

(* Window functions *)

function UG_WindowCreate(var wnd: UG_WINDOW; objlst: pUG_OBJECT;
  objcnt: UG_U8; cb: UG_WINDOW_CB): UG_RESULT;

(*
function UG_WindowDelete(wnd: pUG_WINDOW): UG_RESULT;
*)
function UG_WindowShow(var wnd: UG_WINDOW): UG_RESULT;
(*
function UG_WindowHide(wnd: pUG_WINDOW): UG_RESULT;
function UG_WindowResize(wnd: pUG_WINDOW;  xs: UG_S16;  ys: UG_S16;  xe: UG_S16;  ye: UG_S16): UG_RESULT;
function UG_WindowAlert(wnd: pUG_WINDOW): UG_RESULT;
*)
function UG_WindowSetForeColor(var wnd: UG_WINDOW; fc: UG_COLOR): UG_RESULT;
function UG_WindowSetBackColor(var wnd: UG_WINDOW; bc: UG_COLOR): UG_RESULT;

function UG_WindowSetTitleTextColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
function UG_WindowSetTitleColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
(*
function UG_WindowSetTitleInactiveTextColor(wnd: pUG_WINDOW;  c: UG_COLOR): UG_RESULT;
function UG_WindowSetTitleInactiveColor(wnd: pUG_WINDOW;  c: UG_COLOR): UG_RESULT;
*)
function UG_WindowSetTitleText(var wnd: UG_WINDOW; str: PChar): UG_RESULT;
function UG_WindowSetTitleTextFont(var wnd: UG_WINDOW; font: pUG_FONT): UG_RESULT;
(*
function UG_WindowSetTitleTextHSpace(wnd: pUG_WINDOW;  hs: UG_S8): UG_RESULT;
function UG_WindowSetTitleTextVSpace(wnd: pUG_WINDOW;  vs: UG_S8): UG_RESULT;
function UG_WindowSetTitleTextAlignment(wnd: pUG_WINDOW;  align: UG_U8): UG_RESULT;
function UG_WindowSetTitleHeight(wnd: pUG_WINDOW;  height: UG_U8): UG_RESULT;
function UG_WindowSetXStart(wnd: pUG_WINDOW;  xs: UG_S16): UG_RESULT;
function UG_WindowSetYStart(wnd: pUG_WINDOW;  ys: UG_S16): UG_RESULT;
function UG_WindowSetXEnd(wnd: pUG_WINDOW;  xe: UG_S16): UG_RESULT;
function UG_WindowSetYEnd(wnd: pUG_WINDOW;  ye: UG_S16): UG_RESULT;
function UG_WindowSetStyle(wnd: pUG_WINDOW;  style: UG_U8): UG_RESULT;
function UG_WindowGetForeColor(wnd: pUG_WINDOW): UG_COLOR;
function UG_WindowGetBackColor(wnd: pUG_WINDOW): UG_COLOR;
function UG_WindowGetTitleTextColor(wnd: pUG_WINDOW): UG_COLOR;
function UG_WindowGetTitleColor(wnd: pUG_WINDOW): UG_COLOR;
function UG_WindowGetTitleInactiveTextColor(wnd: pUG_WINDOW): UG_COLOR;
function UG_WindowGetTitleInactiveColor(wnd: pUG_WINDOW): UG_COLOR;
function UG_WindowGetTitleText(wnd: pUG_WINDOW): pchar;
function UG_WindowGetTitleTextFont(wnd: pUG_WINDOW): pUG_FONT;
function UG_WindowGetTitleTextHSpace(wnd: pUG_WINDOW): UG_S8;
function UG_WindowGetTitleTextVSpace(wnd: pUG_WINDOW): UG_S8;
function UG_WindowGetTitleTextAlignment(wnd: pUG_WINDOW): UG_U8;
function UG_WindowGetTitleHeight(wnd: pUG_WINDOW): UG_U8;
function UG_WindowGetXStart(wnd: pUG_WINDOW): UG_S16;
function UG_WindowGetYStart(wnd: pUG_WINDOW): UG_S16;
function UG_WindowGetXEnd(wnd: pUG_WINDOW): UG_S16;
function UG_WindowGetYEnd(wnd: pUG_WINDOW): UG_S16;
function UG_WindowGetStyle(wnd: pUG_WINDOW): UG_U8;
function UG_WindowGetArea(wnd: pUG_WINDOW;  a: pUG_AREA): UG_RESULT;
function UG_WindowGetInnerWidth(wnd: pUG_WINDOW): UG_S16;
function UG_WindowGetOuterWidth(wnd: pUG_WINDOW): UG_S16;
function UG_WindowGetInnerHeight(wnd: pUG_WINDOW): UG_S16;
function UG_WindowGetOuterHeight(wnd: pUG_WINDOW): UG_S16;
*)

(* Miscellaneous functions *)
procedure UG_WaitForUpdate;
procedure UG_Update;
procedure UG_TouchUpdate(xp, yp: UG_S16; state: UG_U8);

(* Driver functions *)
procedure UG_DriverRegister(t: UG_U8; driver: Pointer);
procedure UG_DriverEnable(t: UG_U8);
procedure UG_DriverDisable(t: UG_U8);

implementation

var
  gui: PUG_GUI;

{$ifdef USE_COLOR_RGB888}
const
  (* Frame 0 *)
  (* Frame 1 *)
  (* Frame 2 *)
  pal_window: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464, $FFFFFF, $FFFFFF, $696969, $696969,
    $E3E3E3, $E3E3E3, $A0A0A0, $A0A0A0);
  (* Frame 0 *)
  (* Frame 1 *)
  (* Frame 2 *)
  pal_button_pressed: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464, $A0A0A0, $A0A0A0, $A0A0A0,
    $A0A0A0, $F0F0F0, $F0F0F0, $F0F0F0, $F0F0F0);
  (* Frame 0 *)
  (* Frame 1 *)
  (* Frame 2 *)
  pal_button_released: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464, $FFFFFF, $FFFFFF, $696969,
    $696969, $E3E3E3, $E3E3E3, $A0A0A0, $A0A0A0);
  (* Frame 0 *)
  (* Frame 1 *)
  (* Frame 2 *)
  pal_checkbox_pressed: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464, $A0A0A0, $A0A0A0, $A0A0A0,
    $A0A0A0, $F0F0F0, $F0F0F0, $F0F0F0, $F0F0F0);
  (* Frame 0 *)
  (* Frame 1 *)
  (* Frame 2 *)
  pal_checkbox_released: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464, $FFFFFF, $FFFFFF, $696969,
    $696969, $E3E3E3, $E3E3E3, $A0A0A0, $A0A0A0);
{$endif}
{$ifdef USE_COLOR_RGB565}
  pal_window: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $FFFF, $FFFF, $6B4D, $6B4D, $E71C, $E71C, $9D13, $9D13);
  pal_button_pressed: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $9D13, $9D13, $9D13, $9D13, $EF7D, $EF7D, $EF7D, $EF7D);
  pal_button_released: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $FFFF, $FFFF, $6B4D, $6B4D, $E71C, $E71C, $9D13, $9D13);
  pal_checkbox_pressed: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $9D13, $9D13, $9D13, $9D13, $EF7D, $EF7D, $EF7D, $EF7D);
  pal_checkbox_released: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $FFFF, $FFFF, $6B4D, $6B4D, $E71C, $E71C, $9D13, $9D13);

{$endif}

(* -------------------------------------------------------------------------------- *)
(* -- INTERNAL FUNCTIONS                                                         -- *)
(* -------------------------------------------------------------------------------- *)
procedure _UG_PutChar(chr: char; x, y: UG_S16; fc: UG_COLOR; bc: UG_COLOR;
  const font: UG_FONT);
var
  i, j, k: UG_U16;
  xo, yo: UG_U16;
  c: UG_U16;
  bn: UG_U16;
  actual_char_width: UG_U16;
  b: UG_U8;
  bt: Char;
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
    actual_char_width := Ord(font.char_width);

  (* Is hardware acceleration available? *)
  if 1 = 0 then
  begin
    (* TO DO *)
    ;
  end
  else
  begin
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
          color := (((fc and $FF) * Ord(b) + (bc and $FF) * (256 - Ord(b))) shr 8) and
            $FF or (((fc and $FF00) * Ord(b) + (bc and $FF00) * (256 - Ord(b))) shr
            8) and $FF00 or (((fc and $FF0000) * Ord(b) + (bc and $FF0000) *
            (256 - Ord(b))) shr 8) and $FF0000;
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
  if (Ord(align) and (ALIGN_V_CENTER or ALIGN_V_BOTTOM)) <> 0 then
  begin
    yp := ye - ys + 1;
    yp := yp - char_height * rc;
    yp := yp - char_v_space * (rc - 1);
    if yp < 0 then
      exit;
  end;
  if (Ord(align) and ALIGN_V_CENTER) <> 0 then
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
    if (Ord(align) and ALIGN_H_LEFT) <> 0 then
      xp := 0
    else if (Ord(align) and ALIGN_H_CENTER) <> 0 then
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

function _UG_WindowDrawTitle(var wnd: UG_WINDOW): UG_RESULT;
var
  txt: UG_TEXT;
  xs, ys: UG_S16;
  xe, ye: UG_S16;

begin
  { if (wnd<>nil) and (Ord(wnd.state) and WND_STATE_VALID) then }
  if (Ord(wnd.state) and WND_STATE_VALID) <> 0 then
  begin
    xs := wnd.xs;
    ys := wnd.ys;
    xe := wnd.xe;
    ye := wnd.ye;
    (* 3D style? *)
    if (Ord(wnd.style) and WND_STYLE_3D) <> 0 then
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

    UG_FillFrame(xs, ys, xe, ys + Ord(wnd.title.Height) - 1, txt.bc);
    (* UG_FillFrame(xs, ys, xe, ys + Ord(wnd.title.Height) - 1, 2); *)

    (* Draw title text *)
    txt.str := wnd.title.str;
    txt.font := wnd.title.font;
    txt.a.xs := xs + 3;
    txt.a.ys := ys;
    txt.a.xe := xe;
    txt.a.ye := ys + Ord(wnd.title.Height) - 1;
    txt.align := wnd.title.align;
    txt.h_space := wnd.title.h_space;
    txt.v_space := wnd.title.v_space;
    _UG_PutText(txt);

    (* Draw line *)
    UG_DrawLine(xs, ys + Ord(wnd.title.Height), xe, ys + Ord(wnd.title.Height),
      pal_window[11]);
    _UG_WindowDrawTitle := UG_RESULT_OK;
    exit;
  end;
  _UG_WindowDrawTitle := UG_RESULT_FAIL;
end;

procedure _UG_WindowUpdate(var wnd: UG_WINDOW);
var
  i: UG_U16;
  objcnt: UG_U16;
  obj: pUG_OBJECT;
  xs: UG_S16;
  ys: UG_S16;
  xe: UG_S16;
  ye: UG_S16;
begin
  xs := wnd.xs;
  ys := wnd.ys;
  xe := wnd.xe;
  ye := wnd.ye;
  wnd.state := Ord(wnd.state) and (not WND_STATE_UPDATE);
  (* Is the window visible? *)
  if (Ord(wnd.state) and WND_STATE_VISIBLE) <> 0 then
  begin
    (* 3D style? *)
    if ((Ord(wnd.style) and WND_STYLE_3D) <> 0) and
      (0 = (Ord(wnd.state) and WND_STATE_REDRAW_TITLE)) then
    begin
      (* _UG_DrawObjectFrame(xs,ys,xe,ye,pUG_COLOR(pal_window)); *)
      xs := xs + 3;
      ys := ys + 3;
      xe := xe - 3;
      ye := ye - 3;
    end;
    (* Show title bar? *)
    if (Ord(wnd.style) and WND_STYLE_SHOW_TITLE) <> 0 then
    begin
      _UG_WindowDrawTitle(wnd);
      ys := ys + Ord(wnd.title.Height) + 1;
      if (Ord(wnd.state) and WND_STATE_REDRAW_TITLE) <> 0 then
      begin
        wnd.state := wnd.state and (not WND_STATE_REDRAW_TITLE);
        exit;
      end;
    end;
    UG_FillFrame(xs, ys, xe, ye, wnd.bc);
    (* Draw window area? *)
    objcnt := Ord(wnd.objcnt);
    (* Force each object to be updated! *)
    for i := 0 to Pred(objcnt) do
    begin
      (*
      obj:= (UG_OBJECT* )@wnd.objlst[i];
      if 0 = (obj.state and OBJ_STATE_FREE))and((obj.state and OBJ_STATE_VALID))and((obj.state and OBJ_STATE_VISIBLE)
      then
      obj.state:= obj.state or ((OBJ_STATE_UPDATE or OBJ_STATE_REDRAW));
      *)
    end;
  end
  else
  begin
    UG_FillFrame(wnd.xs, wnd.xs, wnd.xe, wnd.ye, gui^.desktop_color);
  end;
end;

(*
function _UG_WindowClear(wnd: pUG_WINDOW): UG_RESULT;

procedure _UG_TextboxUpdate(wnd: pUG_WINDOW;  obj: pUG_OBJECT);
procedure _UG_ButtonUpdate(wnd: pUG_WINDOW;  obj: pUG_OBJECT);
procedure _UG_CheckboxUpdate(wnd: pUG_WINDOW;  obj: pUG_OBJECT);
procedure _UG_ImageUpdate(wnd: pUG_WINDOW;  obj: pUG_OBJECT);
procedure _UG_PutChar(chr: char;  x: UG_S16;  y: UG_S16;  fc: UG_COLOR;  bc: UG_COLOR;  font: pUG_FONT);
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
  if (Ord(gui^.driver[DRIVER_FILL_FRAME].state) and DRIVER_ENABLED) <> 0 then
  begin
    _HW_FILLFRAME(gui^.driver[DRIVER_FILL_FRAME].driver)(x1, y1, x2, y2, c);
    exit;
  end;

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
  UG_DrawLine(x1, y1, x2, y1, c);
  UG_DrawLine(x1, y2, x2, y2, c);
  UG_DrawLine(x1, y1, x1, y2, c);
  UG_DrawLine(x2, y1, x2, y2, c);
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
  if (Ord(gui^.driver[DRIVER_DRAW_LINE].state) and DRIVER_ENABLED) <> 0 then
  begin
    _HW_DRAWLINE(gui^.driver[DRIVER_DRAW_LINE].driver)(x1, y, x2, y, c);
    exit;
  end;
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
  if (Ord(gui^.driver[DRIVER_DRAW_LINE].state) and DRIVER_ENABLED) <> 0 then
  begin
    _HW_DRAWLINE(gui^.driver[DRIVER_DRAW_LINE].driver)(x, y1, x, y2, c);
    exit;
  end;
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
  if (Ord(gui^.driver[DRIVER_DRAW_LINE].state) and DRIVER_ENABLED) <> 0 then
  begin
    _HW_DRAWLINE(gui^.driver[DRIVER_DRAW_LINE].driver)(x1, y1, x2, y2, c);
    exit;
  end;

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

    if xp + Ord(cw) > gui^.x_dim - 1 then
    begin
      xp := x;
      yp := yp + gui^.font.char_height + gui^.char_v_space;
    end;
    UG_PutChar(chr, xp, yp, gui^.fore_color, gui^.back_color);
    xp := xp + Ord(cw) + gui^.char_h_space;
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

    gui^.console.x_pos := gui^.console.x_pos + Ord(cw) + gui^.char_h_space;
    if gui^.console.x_pos + Ord(cw) > gui^.console.x_end then
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
function UG_WindowCreate(var wnd: UG_WINDOW; objlst: pUG_OBJECT;
  objcnt: UG_U8; cb: UG_WINDOW_CB): UG_RESULT;
var
  i: UG_U8;
  obj: pUG_OBJECT;
begin
  obj := nil;
  if (objlst = nil) or (objcnt = 0) then
  begin
    UG_WindowCreate := UG_RESULT_FAIL;
    exit;
  end;
  obj := objlst;
  (* Initialize all objects of the window *)
  for i := 0 to Pred(Ord(objcnt)) do
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

function UG_WindowShow(var wnd: UG_WINDOW): UG_RESULT;
begin
  (* Force an update, even if this is the active window! *)
  wnd.state := wnd.state or WND_STATE_VISIBLE or WND_STATE_UPDATE;
  wnd.state := wnd.state and (not WND_STATE_REDRAW_TITLE);
  gui^.next_window := @wnd;
  UG_WindowShow := UG_RESULT_OK;
end;

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

function UG_WindowSetTitleText(var wnd: UG_WINDOW; str: PChar): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.str := str;
    wnd.state := wnd.state or WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE;
    UG_WindowSetTitleText := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleText := UG_RESULT_FAIL;
end;

function UG_WindowSetTitleTextFont(var wnd: UG_WINDOW; font: pUG_FONT): UG_RESULT;
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

function UG_WindowSetTitleTextColor(var wnd: UG_WINDOW; c: UG_COLOR): UG_RESULT;
begin
  if (wnd.state and WND_STATE_VALID) <> 0 then
  begin
    wnd.title.fc := c;
    wnd.state := wnd.state or WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE;
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
    wnd.state := wnd.state or WND_STATE_UPDATE or WND_STATE_REDRAW_TITLE;
    UG_WindowSetTitleColor := UG_RESULT_OK;
  end
  else
    UG_WindowSetTitleColor := UG_RESULT_FAIL;
end;

(* -------------------------------------------------------------------------------- *)
(* -- MISCELLANEOUS FUNCTIONS                                                    -- *)
(* -------------------------------------------------------------------------------- *)

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
        (((Ord(gui^.last_window^.style) and WND_STYLE_SHOW_TITLE) and
        (Ord(gui^.last_window^.state) and WND_STATE_VISIBLE)) <> 0) then
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
    begin
      (* Do it! *)
      _UG_WindowUpdate(wnd^);
    end;

    (* Is the window visible? *)
    if (wnd^.state and WND_STATE_VISIBLE) <> 0 then
    begin
      { _UG_ProcessTouchData(wnd); }
      { _UG_UpdateObjects(wnd);    }
      { _UG_HandleEvents(wnd);     }
      ;
    end;
  end;
end;

procedure UG_WaitForUpdate;
begin
  gui^.state := Ord(gui^.state) or (UG_SATUS_WAIT_FOR_UPDATE);
  {$ifdef USE_MULTITASKING}
  while Ord(gui^.state) and UG_SATUS_WAIT_FOR_UPDATE do
  begin
  end;
  {$endif}
  {$ifndef USE_MULTITASKING}
  while Ord(gui^.state) and UG_SATUS_WAIT_FOR_UPDATE <> 0 do
  begin
    ;
  end;
  {$endif}
end;

procedure UG_TouchUpdate(xp, yp: UG_S16; state: UG_U8);
begin
  gui^.touch.xp := xp;
  gui^.touch.yp := yp;
  gui^.touch.state := state;
end;

(* -------------------------------------------------------------------------------- *)
(* -- DRIVER FUNCTIONS                                                           -- *)
(* -------------------------------------------------------------------------------- *)

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

(* -------------------------------------------------------------------------- *)
(* -- µGUI COLORS                                                          -- *)
(* -- Source: http://www.rapidtables.com/web/color/RGB_Color.htm           -- *)
(* -------------------------------------------------------------------------- *)
(* ? MAKE UNIT ? *)
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


(*
unit UG_BTN;

interface

implementation
*)

const
{$ifdef USE_COLOR_RGB888}
  pal_button_pressed: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464, (* Frame 0 *)
    $A0A0A0, $A0A0A0, $A0A0A0, $A0A0A0,  (* Frame 1 *)
    $F0F0F0, $F0F0F0, $F0F0F0, $F0F0F0); (* Frame 2 *)
  pal_button_released: array [0..11] of UG_COLOR =
    ($646464, $646464, $646464, $646464, (* Frame 0 *)
    $FFFFFF, $FFFFFF, $696969, $696969,  (* Frame 1 *)
    $E3E3E3, $E3E3E3, $A0A0A0, $A0A0A0); (* Frame 2 *)
{$endif}
{$ifdef USE_COLOR_RGB565}
  pal_button_pressed: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $9D13, $9D13, $9D13, $9D13, $EF7D, $EF7D, $EF7D, $EF7D);
  pal_button_released: array [0..11] of UG_COLOR =
    ($632C, $632C, $632C, $632C, $FFFF, $FFFF, $6B4D, $6B4D, $E71C, $E71C, $9D13, $9D13);

{$endif}

procedure _UG_ButtonUpdate(wnd: PUG_WINDOW; obj: PUG_OBJECT);
var
  btn: PUG_BUTTON;
  a: UG_AREA;
  txt: UG_TEXT;
  d: UG_U8;

begin
  (* Get object-specific data *)
  btn := PUG_BUTTON(obj^.Data);
  (* -------------------------------------------------- *)
  (* Object touch section                               *)
  (* -------------------------------------------------- *)
  if (obj^.touch_state and OBJ_TOUCH_STATE_CHANGED) <> 0 then
  begin
    (* Handle 'click' event *)
    if (obj^.touch_state and OBJ_TOUCH_STATE_CLICK_ON_OBJECT) <> 0 then
    begin
      obj^.event := BTN_EVENT_CLICKED;
      obj^.state := obj^.state or OBJ_STATE_UPDATE;
    end;
    (* Is the button pressed down? *)
    if (obj^.touch_state and OBJ_TOUCH_STATE_PRESSED_ON_OBJECT) <> 0 then
    begin
      btn^.state := btn^.state or BTN_STATE_PRESSED;
      obj^.state := obj^.state or OBJ_STATE_UPDATE;
      obj^.event := OBJ_EVENT_PRESSED;
    end
    else
    (* Can we release the button? *)
    if (btn^.state and BTN_STATE_PRESSED) <> 0 then
    begin
      btn^.state := btn^.state and (not BTN_STATE_PRESSED);
      obj^.state := obj^.state or OBJ_STATE_UPDATE;
      obj^.event := OBJ_EVENT_RELEASED;
    end;
    obj^.touch_state := obj^.touch_state and (not OBJ_TOUCH_STATE_CHANGED);
  end;

  (* -------------------------------------------------- *)
  (* Object update section                              *)
  (* -------------------------------------------------- *)
  if (obj^.state and OBJ_STATE_UPDATE) <> 0 then
  begin
    if (obj^.state and OBJ_STATE_VISIBLE) <> 0 then
    begin
      (* Full redraw necessary? *)
      if ((obj^.state and OBJ_STATE_REDRAW) <> 0) or
        ((btn^.state and BTN_STATE_ALWAYS_REDRAW) <> 0) then
      begin
        UG_WindowGetArea(wnd^, a);
        obj^.a_abs.xs := obj^.a_rel.xs + a.xs;
        obj^.a_abs.ys := obj^.a_rel.ys + a.ys;
        obj^.a_abs.xe := obj^.a_rel.xe + a.xs;
        obj^.a_abs.ye := obj^.a_rel.ye + a.ys;
        if (obj^.a_abs.ye > wnd^.ye) or (obj^.a_abs.xe > wnd^.xe) then
          exit;
        {$ifdef USE_PRERENDER_EVENT}
        _UG_SendObjectPrerenderEvent(wnd, obj);
        {$endif}
        (* 3D or 2D style? *)
        if (btn^.style and BTN_STYLE_3D) <> 0 then
          d := 3
        else
          d := 1;
        txt.bc := btn^.bc;
        txt.fc := btn^.fc;

        if (btn^.state and BTN_STATE_PRESSED) <> 0 then
        begin
          (* "toggle" style? *)
          if (btn^.style and BTN_STYLE_TOGGLE_COLORS) <> 0 then
          begin
            (* Swap colors *)
            txt.bc := btn^.fc;
            txt.fc := btn^.bc;
          end
          else
          (* Use alternate colors? *)
          if (btn^.style and BTN_STYLE_USE_ALTERNATE_COLORS) <> 0 then
          begin
            txt.bc := btn^.abc;
            txt.fc := btn^.afc;
          end;
        end;
        if (btn^.style and BTN_STYLE_NO_FILL) = 0 then
          UG_FillFrame(obj^.a_abs.xs + d, obj^.a_abs.ys + d, obj^.a_abs.xe -
            d, obj^.a_abs.ye - d, txt.bc);
        (* Draw button text *)
        txt.a.xs := obj^.a_abs.xs + d;
        txt.a.ys := obj^.a_abs.ys + d;
        txt.a.xe := obj^.a_abs.xe - d;
        txt.a.ye := obj^.a_abs.ye - d;
        txt.align := btn^.align;
        txt.font := btn^.font;
        txt.h_space := 2;
        txt.v_space := 2;
        txt.str := btn^.str;
        _UG_PutText(txt);
        obj^.state := obj^.state and (not OBJ_STATE_REDRAW);
        {$ifdef USE_POSTRENDER_EVENT}
        _UG_SendObjectPostrenderEvent(wnd, obj);
        {$endif}
      end;
      (* Draw button frame *)
      if (btn^.style and BTN_STYLE_NO_BORDERS) = 0 then
        if (btn^.style and BTN_STYLE_3D) <> 0 then
          (* 3D *)
          if (btn^.state and BTN_STATE_PRESSED) <> 0 then
            _UG_DrawObjectFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe,
              obj^.a_abs.ye, @pal_button_pressed)
          else
            _UG_DrawObjectFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe,
              obj^.a_abs.ye, @pal_button_released)
        else
        (* 2D *)
        if (btn^.state and BTN_STATE_PRESSED) <> 0 then
          UG_DrawFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe,
            obj^.a_abs.ye, btn^.abc)
        else
          UG_DrawFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe, obj^.a_abs.ye,
            btn^.afc);

    end
    else
    if (btn^.style and BTN_STYLE_NO_FILL) = 0 then
      UG_FillFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe, obj^.a_abs.ye, wnd^.bc);
    obj^.state := obj^.state and (not OBJ_STATE_UPDATE);
  end;
end;

function UG_ButtonCreate(const wnd: UG_WINDOW; var btn: UG_BUTTON;
  id: UG_U8; xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := _UG_GetFreeObject(wnd);
  if obj = nil then
  begin
    UG_ButtonCreate := RESULT_FAIL;
    exit;
  end;

  (* Initialize object-specific parameters *)
  btn.state := BTN_STATE_RELEASED;
  btn.bc := wnd.bc;
  btn.fc := wnd.fc;
  btn.abc := wnd.bc;
  btn.afc := wnd.fc;
  btn.style := BTN_STYLE_3D;
  btn.align := ALIGN_CENTER;
  if gui <> nil then
    btn.font := @(gui^.font)
  else
    btn.font := nil;
  btn.str := '-';

  (* Initialize standard object parameters *)
  obj^.update := _UG_ButtonUpdate;
  obj^.touch_state := OBJ_TOUCH_STATE_INIT;
  obj^.otype := OBJ_TYPE_BUTTON;
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
  obj^.state := obj^.state or (OBJ_STATE_VISIBLE or OBJ_STATE_REDRAW or
    OBJ_STATE_VALID or OBJ_STATE_TOUCH_ENABLE);
  obj^.Data := @btn;

  (* Update function: Do your thing! *)
  obj^.state := obj^.state and (not OBJ_STATE_FREE);
  UG_ButtonCreate := RESULT_OK;
end;

function UG_ButtonDelete(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
begin
  UG_ButtonDelete := _UG_DeleteObject(wnd, OBJ_TYPE_BUTTON, id);
end;

function UG_ButtonShow(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    obj^.state := obj^.state or (OBJ_STATE_VISIBLE or OBJ_STATE_UPDATE or
      OBJ_STATE_REDRAW);
    UG_ButtonShow := RESULT_OK;
  end
  else
    UG_ButtonShow := RESULT_FAIL;
end;

function UG_ButtonHide(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.state := btn^.state and (not BTN_STATE_PRESSED);
    obj^.touch_state := OBJ_TOUCH_STATE_INIT;
    obj^.event := OBJ_EVENT_NONE;
    obj^.state := obj^.state and (not OBJ_STATE_VISIBLE);
    obj^.state := obj^.state or OBJ_STATE_UPDATE;
    UG_ButtonHide := RESULT_OK;
  end
  else
    UG_ButtonHide := RESULT_FAIL;
end;

(* Button setters *)

function UG_ButtonSetForeColor(const wnd: UG_WINDOW; id: UG_U8;
  fc: UG_COLOR): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.fc := fc;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetForeColor := RESULT_OK;
  end
  else
    UG_ButtonSetForeColor := RESULT_FAIL;
end;

function UG_ButtonSetBackColor(const wnd: UG_WINDOW; id: UG_U8;
  bc: UG_COLOR): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.bc := bc;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetBackColor := RESULT_OK;
  end
  else
    UG_ButtonSetBackColor := RESULT_FAIL;
end;

function UG_ButtonSetAlternateForeColor(const wnd: UG_WINDOW; id: UG_U8;
  afc: UG_COLOR): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.afc := afc;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetAlternateForeColor := RESULT_OK;
  end
  else
    UG_ButtonSetAlternateForeColor := RESULT_FAIL;
end;

function UG_ButtonSetAlternateBackColor(const wnd: UG_WINDOW; id: UG_U8;
  abc: UG_COLOR): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.abc := abc;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetAlternateBackColor := RESULT_OK;
  end
  else
    UG_ButtonSetAlternateBackColor := RESULT_FAIL;
end;

function UG_ButtonSetText(const wnd: UG_WINDOW; id: UG_U8; str: PChar): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.str := str;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetText := RESULT_OK;
  end
  else
    UG_ButtonSetText := RESULT_FAIL;
end;

function UG_ButtonSetFont(const wnd: UG_WINDOW; id: UG_U8; font: PUG_FONT): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.font := font;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetFont := RESULT_OK;
  end
  else
    UG_ButtonSetFont := RESULT_FAIL;
end;

function UG_ButtonSetStyle(const wnd: UG_WINDOW; id: UG_U8; style: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    (* Select color scheme *)
    btn^.style := btn^.style and
      (not (BTN_STYLE_USE_ALTERNATE_COLORS or BTN_STYLE_TOGGLE_COLORS or
      BTN_STYLE_NO_BORDERS or BTN_STYLE_NO_FILL));
    btn^.state := btn^.state or BTN_STATE_ALWAYS_REDRAW;
    if (style and BTN_STYLE_NO_BORDERS) <> 0 then
      btn^.style := btn^.style or BTN_STYLE_NO_BORDERS;
    if (style and BTN_STYLE_NO_FILL) <> 0 then
      btn^.style := btn^.style or BTN_STYLE_NO_FILL;
    (* ! CHECK IF LOGIC ! *)
    if (style and BTN_STYLE_TOGGLE_COLORS) <> 0 then
      btn^.style := btn^.style or BTN_STYLE_TOGGLE_COLORS
    else
    if (style and BTN_STYLE_USE_ALTERNATE_COLORS) <> 0 then
      btn^.style := btn^.style or BTN_STYLE_USE_ALTERNATE_COLORS
    else
      btn^.state := btn^.state and (not BTN_STATE_ALWAYS_REDRAW);

    (* 3D or 2D *)
    if (style and BTN_STYLE_3D) <> 0 then
      btn^.style := btn^.style or BTN_STYLE_3D
    else
      btn^.style := btn^.style and (not BTN_STYLE_3D);
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetStyle := RESULT_OK;
  end
  else
    UG_ButtonSetStyle := RESULT_FAIL;
end;

function UG_ButtonSetHSpace(const wnd: UG_WINDOW; id: UG_U8; hs: UG_S8): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.h_space := hs;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetHSpace := RESULT_OK;
  end
  else
    UG_ButtonSetHSpace := RESULT_FAIL;
end;

function UG_ButtonSetVSpace(const wnd: UG_WINDOW; id: UG_U8; vs: UG_S8): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.v_space := vs;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetVSpace := RESULT_OK;
  end
  else
    UG_ButtonSetVSpace := RESULT_FAIL;
end;

function UG_ButtonSetAlignment(const wnd: UG_WINDOW; id: UG_U8;
  align: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    btn^.align := align;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ButtonSetAlignment := RESULT_OK;
  end
  else
    UG_ButtonSetAlignment := RESULT_FAIL;
end;

(* Button getters *)
(* PACK *)
function UG_ButtonGetForeColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetForeColor := btn^.fc;
  end
  else
    UG_ButtonGetForeColor := C_BLACK;
end;

function UG_ButtonGetBackColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetBackColor := btn^.bc;
  end
  else
    UG_ButtonGetBackColor := C_BLACK;
end;

function UG_ButtonGetAlternateForeColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetAlternateForeColor := btn^.afc;
  end
  else
    UG_ButtonGetAlternateForeColor := C_BLACK;
end;

function UG_ButtonGetAlternateBackColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetAlternateBackColor := btn^.abc;
  end
  else
    UG_ButtonGetAlternateBackColor := C_BLACK;
end;

function UG_ButtonGetText(const wnd: UG_WINDOW; id: UG_U8): PChar;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetText := btn^.str;
  end
  else
    UG_ButtonGetText := nil;
end;

function UG_ButtonGetFont(const wnd: UG_WINDOW; id: UG_U8): PUG_FONT;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetFont := btn^.font;
  end
  else
    UG_ButtonGetFont := nil;
end;

function UG_ButtonGetStyle(const wnd: UG_WINDOW; id: UG_U8): UG_U8;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetStyle := btn^.style;
  end
  else
    UG_ButtonGetStyle := 0;
end;

function UG_ButtonGetHSpace(const wnd: UG_WINDOW; id: UG_U8): UG_S8;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetHSpace := btn^.h_space;
  end
  else
    UG_ButtonGetHSpace := 0;
end;

function UG_ButtonGetVSpace(const wnd: UG_WINDOW; id: UG_U8): UG_S8;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetVSpace := btn^.v_space;
  end
  else
    UG_ButtonGetVSpace := 0;
end;

function UG_ButtonGetAlignment(const wnd: UG_WINDOW; id: UG_U8): UG_U8;
var
  obj: PUG_OBJECT;
  btn: PUG_BUTTON;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_BUTTON, id);
  if obj <> nil then
  begin
    btn := PUG_BUTTON(obj^.Data);
    UG_ButtonGetAlignment := btn^.align;
  end
  else
    UG_ButtonGetAlignment := 0;
end;

(*
end.
*)

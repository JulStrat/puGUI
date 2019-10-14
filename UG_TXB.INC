(*
unit UG_TXB;

interface

implementation
*)

procedure _UG_TextboxUpdate(wnd: PUG_WINDOW; obj: pUG_OBJECT);
{$ifdef VER70}far;{$endif}
var
  txb: PUG_TEXTBOX;
  a: UG_AREA;
  txt: UG_TEXT;
  (* Get object-specific data *)
begin
  txb := PUG_TEXTBOX(obj^.Data);
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
        UG_WindowGetArea(wnd^, a);
        obj^.a_abs.xs := obj^.a_rel.xs + a.xs;
        obj^.a_abs.ys := obj^.a_rel.ys + a.ys;
        obj^.a_abs.xe := obj^.a_rel.xe + a.xs;
        obj^.a_abs.ye := obj^.a_rel.ye + a.ys;
        if (obj^.a_abs.ye >= wnd^.ye) or (obj^.a_abs.xe >= wnd^.xe) then
          exit;
        {$ifdef USE_PRERENDER_EVENT}
        _UG_SendObjectPrerenderEvent(wnd, obj);
        {$endif}
        txt.bc := txb^.bc;
        txt.fc := txb^.fc;
        UG_FillFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe,
          obj^.a_abs.ye, txt.bc);
        txt.a.xs := obj^.a_abs.xs;
        txt.a.ys := obj^.a_abs.ys;
        txt.a.xe := obj^.a_abs.xe;
        txt.a.ye := obj^.a_abs.ye;
        txt.align := txb^.align;
        txt.font := txb^.font;
        txt.h_space := txb^.h_space;
        txt.v_space := txb^.v_space;
        txt.str := txb^.str;
        (* Draw Textbox text *)
        _UG_PutText(txt);
        obj^.state := obj^.state and (not OBJ_STATE_REDRAW);
        {$ifdef USE_POSTRENDER_EVENT}
        _UG_SendObjectPostrenderEvent(wnd, obj);
        {$endif}
      end;
    end
    else
    begin
      UG_FillFrame(obj^.a_abs.xs, obj^.a_abs.ys, obj^.a_abs.xe, obj^.a_abs.ye, wnd^.bc);
    end;
    obj^.state := obj^.state and (not OBJ_STATE_UPDATE);
  end;
end;

function UG_TextboxCreate(const wnd: UG_WINDOW; var txb: UG_TEXTBOX;
  id: UG_U8; xs, ys: UG_S16; xe, ye: UG_S16): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := _UG_GetFreeObject(wnd);
  if obj = nil then
  begin
    UG_TextboxCreate := UG_RESULT_FAIL;
    exit;
  end;
  (* Initialize object-specific parameters *)
  txb.str := nil;
  if gui <> nil then
    txb.font := @(gui^.font)
  else
    txb.font := nil;
  txb.style := 0;
  txb.fc := wnd.fc;
  txb.bc := wnd.bc;
  txb.align := ALIGN_CENTER;
  txb.h_space := 0;
  txb.v_space := 0;
  (* Initialize standard object parameters *)
  obj^.update := _UG_TextboxUpdate;
  obj^.touch_state := OBJ_TOUCH_STATE_INIT;
  obj^.otype := OBJ_TYPE_TEXTBOX;
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
  obj^.Data := @txb;
  obj^.state := obj^.state and (not OBJ_STATE_FREE);
  (* Update function: Do your thing! *)
  UG_TextboxCreate := UG_RESULT_OK;
end;

function UG_TextboxDelete(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
begin
  UG_TextboxDelete := _UG_DeleteObject(wnd, OBJ_TYPE_TEXTBOX, id);
end;

function UG_TextboxShow(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    obj^.state := obj^.state or (OBJ_STATE_VISIBLE);
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_TextboxShow := UG_RESULT_OK;
  end
  else
    UG_TextboxShow := UG_RESULT_FAIL;
end;

function UG_TextboxHide(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    obj^.state := obj^.state and (not OBJ_STATE_VISIBLE);
    obj^.state := obj^.state or OBJ_STATE_UPDATE;
    UG_TextboxHide := UG_RESULT_OK;
  end
  else
    UG_TextboxHide := UG_RESULT_FAIL;
end;

(* Text box setters *)
function UG_TextboxSetForeColor(const wnd: UG_WINDOW; id: UG_U8;
  fc: UG_COLOR): UG_RESULT;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    txb^.fc := fc;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_TextboxSetForeColor := UG_RESULT_OK;
  end
  else
    UG_TextboxSetForeColor := UG_RESULT_FAIL;
end;

function UG_TextboxSetBackColor(const wnd: UG_WINDOW; id: UG_U8;
  bc: UG_COLOR): UG_RESULT;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    txb^.bc := bc;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_TextboxSetBackColor := UG_RESULT_OK;
  end
  else
    UG_TextboxSetBackColor := UG_RESULT_FAIL;
end;

function UG_TextboxSetText(const wnd: UG_WINDOW; id: UG_U8; str: PChar): UG_RESULT;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    txb^.str := str;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_TextboxSetText := UG_RESULT_OK;
  end
  else
    UG_TextboxSetText := UG_RESULT_FAIL;
end;

function UG_TextboxSetFont(const wnd: UG_WINDOW; id: UG_U8; font: PUG_FONT): UG_RESULT;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    txb^.font := font;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_TextboxSetFont := UG_RESULT_OK;
  end
  else
    UG_TextboxSetFont := UG_RESULT_FAIL;
end;

function UG_TextboxSetHSpace(const wnd: UG_WINDOW; id: UG_U8; hs: UG_S8): UG_RESULT;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    txb^.h_space := hs;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_TextboxSetHSpace := UG_RESULT_OK;
  end
  else
    UG_TextboxSetHSpace := UG_RESULT_FAIL;
end;


function UG_TextboxSetVSpace(const wnd: UG_WINDOW; id: UG_U8; vs: UG_S8): UG_RESULT;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    txb^.v_space := vs;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_TextboxSetVSpace := UG_RESULT_OK;
  end
  else
    UG_TextboxSetVSpace := UG_RESULT_FAIL;
end;

function UG_TextboxSetAlignment(const wnd: UG_WINDOW; id: UG_U8;
  align: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    txb^.align := align;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_TextboxSetAlignment := UG_RESULT_OK;
  end
  else
    UG_TextboxSetAlignment := UG_RESULT_FAIL;
end;

(* Text box getters *)
function UG_TextboxGetForeColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    UG_TextboxGetForeColor := txb^.fc;
  end
  else
    UG_TextboxGetForeColor := C_BLACK;
end;

function UG_TextboxGetBackColor(const wnd: UG_WINDOW; id: UG_U8): UG_COLOR;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    UG_TextboxGetBackColor := txb^.bc;
  end
  else
    UG_TextboxGetBackColor := C_BLACK;
end;

function UG_TextboxGetText(const wnd: UG_WINDOW; id: UG_U8): PChar;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    UG_TextboxGetText := txb^.str;
  end
  else
    UG_TextboxGetText := nil;
end;

function UG_TextboxGetFont(const wnd: UG_WINDOW; id: UG_U8): PUG_FONT;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    UG_TextboxGetFont := txb^.font;
  end
  else
    UG_TextboxGetFont := nil;
end;

function UG_TextboxGetHSpace(const wnd: UG_WINDOW; id: UG_U8): UG_S8;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    UG_TextboxGetHSpace := txb^.h_space;
  end
  else
    UG_TextboxGetHSpace := 0;
end;

function UG_TextboxGetVSpace(const wnd: UG_WINDOW; id: UG_U8): UG_S8;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    UG_TextboxGetVSpace := txb^.v_space;
  end
  else
    UG_TextboxGetVSpace := 0;
end;

function UG_TextboxGetAlignment(const wnd: UG_WINDOW; id: UG_U8): UG_U8;
var
  obj: PUG_OBJECT;
  txb: PUG_TEXTBOX;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_TEXTBOX, id);
  if obj <> nil then
  begin
    txb := PUG_TEXTBOX(obj^.Data);
    UG_TextboxGetAlignment := txb^.align;
  end
  else
    UG_TextboxGetAlignment := 0;
end;

(*
end.
*)

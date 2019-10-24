(*
unit UG_IMG;

interface

implementation
*)

(* ? Internal ? *)
(* ! REVIEW ! *)
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
      {
      // RGB565 -> RGB888 using integer approximation
      r8 = ( r5 << 3 ) | (r5 >> 2);
      g8 = ( g6 << 2 ) | (g6 >> 4);
      b8 = ( b5 << 3 ) | (b5 >> 2);      
      
      (* Convert RGB565 to RGB888 *)
      r := (tmp shr 11) and $1F;
      r := r shl 3;
      g := (tmp shr 5) and $3F;
      g := g shl 2;
      b := tmp and $1F;
      b := b shl 3;
      (* c := UG_COLOR(r shl 16) or UG_COLOR(g shl 8) or UG_COLOR(b); *)
      c := (UG_COLOR(r) shl 16) or (UG_COLOR(g) shl 8) or UG_COLOR(b);
      UG_DrawPixel(xp, yp, c);
      }
      UG_DrawPixel(xp, yp, tmp);
      Inc(xp);
    end;
    Inc(yp);
  end;
end;

procedure _UG_ImageUpdate(wnd: PUG_WINDOW; obj: PUG_OBJECT);
{$ifdef VER70} far;{$endif}
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
  if obj <> nil then
  begin
    obj^.state := obj^.state or (OBJ_STATE_VISIBLE or OBJ_STATE_UPDATE or
      OBJ_STATE_REDRAW);
    UG_ImageShow := UG_RESULT_OK;
  end
  else
    UG_ImageShow := UG_RESULT_FAIL;
end;

function UG_ImageHide(const wnd: UG_WINDOW; id: UG_U8): UG_RESULT;
var
  obj: PUG_OBJECT;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_IMAGE, id);
  if obj <> nil then
  begin
    obj^.state := obj^.state and (not OBJ_STATE_VISIBLE);
    obj^.state := obj^.state or OBJ_STATE_UPDATE;
    UG_ImageHide := UG_RESULT_OK;
  end
  else
    UG_ImageHide := UG_RESULT_FAIL;
end;

function UG_ImageSetBMP(const wnd: UG_WINDOW; id: UG_U8; bmp: PUG_BMP): UG_RESULT;
var
  obj: PUG_OBJECT;
  img: PUG_IMAGE;
begin
  obj := _UG_SearchObject(wnd, OBJ_TYPE_IMAGE, id);
  if obj <> nil then
  begin
    img := PUG_IMAGE(obj^.Data);
    img^.img := PUG_U8(bmp);
    img^.itype := IMG_TYPE_BMP;
    obj^.state := obj^.state or (OBJ_STATE_UPDATE or OBJ_STATE_REDRAW);
    UG_ImageSetBMP := UG_RESULT_OK;
  end
  else
    UG_ImageSetBMP := UG_RESULT_FAIL;
end;

(*
end.
*)

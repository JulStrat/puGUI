procedure _UG_CheckboxUpdate(wnd: PUG_WINDOW; obj: PUG_OBJECT); 
var
  chb: pUG_CHECKBOX; 
  a: UG_AREA; 
  txt: UG_TEXT; 
  d: UG_U8; 
  d2: UG_U8; 
begin
{
(* Get object-specific data *)  
  chb:= pUG_CHECKBOX(obj^.data); 
  (* -------------------------------------------------- *)
  (* Object touch section                               *)
  (* -------------------------------------------------- *)
  if (obj^.touch_state and OBJ_TOUCH_STATE_CHANGED) <> 0 then
  begin 
    (* Handle 'click' event *)
    if (obj^.touch_state and OBJ_TOUCH_STATE_CLICK_ON_OBJECT) <> 0 then
    begin 
      obj^.event:= CHB_EVENT_CLICKED; 
      obj^.state:= obj^.state or OBJ_STATE_UPDATE; 
    end;
    (* Is the Checkbox pressed down? *)
    if (obj^.touch_state and OBJ_TOUCH_STATE_PRESSED_ON_OBJECT) <> 0 then
    begin 
      chb^.state:= chb^.state or CHB_STATE_PRESSED; 
      obj^.state:= obj^.state or OBJ_STATE_UPDATE; 
      obj^.event:= OBJ_EVENT_PRESSED; 
    end
    else
    (* Can we release the Checkbox? *)
    if (chb^.state and CHB_STATE_PRESSED) <> 0 then
    begin 
      chb^.state:= chb^.state and (not CHB_STATE_PRESSED); 
      obj^.state:= obj^.state or OBJ_STATE_UPDATE; 
      obj^.event:= OBJ_EVENT_RELEASED; 
      chb^.checked:= 0; 
    end;
    obj^.touch_state:= obj^.touch_state and (not OBJ_TOUCH_STATE_CHANGED); 
  end;
  
  (* -------------------------------------------------- *)
  (* Object update section                              *)
  (* -------------------------------------------------- *)
  if (obj^.state and OBJ_STATE_UPDATE) <> 0 then
  begin 
    UG_WindowGetArea(wnd, a); 
    obj^.a_abs.xs:= obj^.a_rel.xs+a.xs; 
    obj^.a_abs.ys:= obj^.a_rel.ys+a.ys; 
    obj^.a_abs.xe:= obj^.a_rel.xe+a.xs; 
    obj^.a_abs.ye:= obj^.a_rel.ye+a.ys; 
    if obj^.a_abs.ye > wnd.ye then exit;
    if obj^.a_abs.xe > wnd.xe then exit;
    if (obj^.state and OBJ_STATE_VISIBLE) <> 0 then
    begin 
      (* 3D or 2D style? *)
      if (chb^.style and CHB_STYLE_3D) <> 0 then
        d : = 3;
      else
        d := 1;      
      
      if (chb^.font.char_width<chb^.font.char_height) then 
        d2:= chb^.font.char_height
      else
        d2 := chb^.font.char_width; 
        (* Full redraw necessary? *)
      if ((obj.state and OBJ_STATE_REDRAW) <> 0) or ((chb^.state and CHB_STATE_ALWAYS_REDRAW) <> 0) then
            begin 
      {$ifdef USE_PRERENDER_EVENT}

        _UG_SendObjectPrerenderEvent(wnd,obj); 
        {$endif}
        txt.bc:= chb^.bc; 
        txt.fc:= chb^.fc; 
        if (chb^.state and CHB_STATE_PRESSED) <> 0 then
        begin 
          (* "toggle" style? *)
          if (chb^.style and CHB_STYLE_TOGGLE_COLORS) <> 0 then
          begin 
            (* Swap colors *)
            txt.bc:= chb^.fc; 
            txt.fc:= chb^.bc; 
          end
          else
          (* Use alternate colors? *)
          if (chb^.style and CHB_STYLE_USE_ALTERNATE_COLORS) <> 0 then
          begin 
            txt.bc:= chb^.abc; 
            txt.fc:= chb^.afc; 
          end;
        end;
        if (chb^.style and CHB_STYLE_NO_FILL) = 0 then
          UG_FillFrame(obj.a_abs.xs+d,obj.a_abs.ys+d,obj.a_abs.xe-d,obj.a_abs.ye-d,txt.bc); 
        txt.a.xs:= obj.a_abs.xs+d2+3*d; 
        txt.a.ys:= obj.a_abs.ys+d; 
        txt.a.xe:= obj.a_abs.xe; 
        txt.a.ye:= obj.a_abs.ye; 
        txt.align:= chb^.align; 
        txt.font:= chb^.font; 
        txt.h_space:= 2; 
        txt.v_space:= 2; 
        txt.str:= chb^.str; 
        _UG_PutText(@txt); 
        (* Draw Checkbox text *)
        (* txt.a.xs = obj->a_abs.xs+d;*)
        (* txt.a.ys = obj->a_abs.ys+d;*)
        (* txt.a.xe = obj->a_abs.xe-d;*)
        (* txt.a.ye = obj->a_abs.ye-d;*)
        obj.state:= obj.state and (not OBJ_STATE_REDRAW); 
        {$ifdef USE_POSTRENDER_EVENT}
        _UG_SendObjectPostrenderEvent(wnd,obj); 
        {$endif}
      end;
      (* Draw Checkbox X *)
      if chb^.checked <> 0 then
      begin 
        UG_DrawLine(obj.a_abs.xs+d+1, obj.a_abs.ys+d, obj.a_abs.xs+d2+d-1, obj.a_abs.ys+d2+d-2, chb^.fc); 
        UG_DrawLine(obj.a_abs.xs+d, obj.a_abs.ys+d, obj.a_abs.xs+d2+d-1, obj.a_abs.ys+d2+d-1, chb^.fc); 
        UG_DrawLine(obj.a_abs.xs+d, obj.a_abs.ys+d+1, obj.a_abs.xs+d2+d-2, obj.a_abs.ys+d2+d-1, chb^.fc); 
        UG_DrawLine(obj.a_abs.xs+d2+d-1, obj.a_abs.ys+d+1, obj.a_abs.xs+d+1, obj.a_abs.ys+d2+d-1, chb^.fc); 
        UG_DrawLine(obj.a_abs.xs+d2+d-1, obj.a_abs.ys+d, obj.a_abs.xs+d, obj.a_abs.ys+d2+d-1, chb^.fc); 
        UG_DrawLine(obj.a_abs.xs+d2+d-2, obj.a_abs.ys+d, obj.a_abs.xs+d, obj.a_abs.ys+d2+d-2, chb^.fc); 
      end
      else
      begin 
        UG_DrawLine(obj.a_abs.xs+d+1, obj.a_abs.ys+d, obj.a_abs.xs+d2+d-1, obj.a_abs.ys+d2+d-2, chb^.bc); 
        UG_DrawLine(obj.a_abs.xs+d, obj.a_abs.ys+d, obj.a_abs.xs+d2+d-1, obj.a_abs.ys+d2+d-1, chb^.bc); 
        UG_DrawLine(obj.a_abs.xs+d, obj.a_abs.ys+d+1, obj.a_abs.xs+d2+d-2, obj.a_abs.ys+d2+d-1, chb^.bc); 
        UG_DrawLine(obj.a_abs.xs+d2+d-1, obj.a_abs.ys+d+1, obj.a_abs.xs+d+1, obj.a_abs.ys+d2+d-1, chb^.bc); 
        UG_DrawLine(obj.a_abs.xs+d2+d-1, obj.a_abs.ys+d, obj.a_abs.xs+d, obj.a_abs.ys+d2+d-1, chb^.bc); 
        UG_DrawLine(obj.a_abs.xs+d2+d-2, obj.a_abs.ys+d, obj.a_abs.xs+d, obj.a_abs.ys+d2+d-2, chb^.bc); 
      end;
      (* Draw Checkbox frame *)
      if (chb^.style and CHB_STYLE_NO_BORDERS) = 0 then
        if (chb^.style and CHB_STYLE_3D) <> 0 then
          (* 3D *)
          if (chb^.state and CHB_STATE_PRESSED) <> 0 then
            _UG_DrawObjectFrame(obj.a_abs.xs,obj.a_abs.ys,obj.a_abs.xs+d2+2*d-1,obj.a_abs.ys+d2+2*d-1, pal_checkbox_pressed)
          else
            _UG_DrawObjectFrame(obj.a_abs.xs,obj.a_abs.ys,obj.a_abs.xs+d2+2*d-1,obj.a_abs.ys+d2+2*d-1, pal_checkbox_released);
        else
          (* 2D *)
          if (chb^.state and CHB_STATE_PRESSED) <> 0 then          
            UG_DrawFrame(obj.a_abs.xs,obj.a_abs.ys,obj.a_abs.xs+d2+2*d-1,obj.a_abs.ys+d2+2*d-1, chb^.abc)
          else
            UG_DrawFrame(obj.a_abs.xs,obj.a_abs.ys,obj.a_abs.xs+d2+2*d-1,obj.a_abs.ys+d2+2*d-1, chb^.afc); 
    end;
    else
      if (chb^.style and CHB_STYLE_NO_FILL) = 0 then
        UG_FillFrame(obj.a_abs.xs, obj.a_abs.ys, obj.a_abs.xe, obj.a_abs.ye, wnd.bc); 
    obj.state:= obj.state and ( not OBJ_STATE_UPDATE); 
  end;
  }
end;

function UG_CheckboxCreate(const wnd: UG_WINDOW; var chb: UG_CHECKBOX; id: UG_U8;
  xs, ys: UG_S16;  xe, ye: UG_S16): UG_RESULT; 
var
  obj: pUG_OBJECT; 
begin
  obj:= _UG_GetFreeObject(wnd); 
  if obj= nil then
  begin
    UG_CheckboxCreate:= UG_RESULT_FAIL; 
    exit;
  end;
  (* Initialize object-specific parameters *)  
  chb.state:= CHB_STATE_RELEASED; 
  chb.bc:= wnd.bc; 
  chb.fc:= wnd.fc; 
  chb.abc:= wnd.bc; 
  chb.afc:= wnd.fc; 
  chb.style:= CHB_STYLE_3D; 
  chb.align:= ALIGN_TOP_LEFT; 
  if gui <> nil then
    chb.font:= @(gui^.font); 
  else
    chb.font:= nil; 
  chb.str:= '-'; 
  chb.checked:= 0; 
  (* Initialize standard object parameters *)  
  obj^.update:= _UG_CheckboxUpdate; 
  obj^.touch_state:= OBJ_TOUCH_STATE_INIT; 
  obj^.otype:= OBJ_TYPE_CHECKBOX; 
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
  obj^.state:= obj^.state or OBJ_STATE_VISIBLE or OBJ_STATE_REDRAW or OBJ_STATE_VALID or OBJ_STATE_TOUCH_ENABLE; 
  obj^.data:= @chb; 
  obj^.state:= obj^.state and (not OBJ_STATE_FREE); 
  (* Update function: Do your thing! *)
  UG_CheckboxCreate:= UG_RESULT_OK; 
end;

function UG_CheckboxShow(var wnd: UG_WINDOW;  id: UG_U8): UG_RESULT; 
var
  obj: pUG_OBJECT;
begin
  obj:=nil; 
  obj:= _UG_SearchObject(wnd,OBJ_TYPE_CHECKBOX,id); 
  if obj=nil then
  begin
    UG_CheckboxShow:= UG_RESULT_FAIL; 
    exit;
  end;
  obj^.state:= obj^.state or OBJ_STATE_VISIBLE; 
  obj^.state:= obj^.state or OBJ_STATE_UPDATE or OBJ_STATE_REDRAW; 
  UG_CheckboxShow:= UG_RESULT_OK; 
end;

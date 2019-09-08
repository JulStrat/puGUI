unit UG_TYPES;
{$ifdef FPC}{$mode tp}{$endif}
{$ifdef VER70}{$X+}{$endif}

interface

type
  PUG_U8 = ^UG_U8;
  UG_U8 = Byte;

  PUG_S8 = ^UG_S8;  
  UG_S8 = ShortInt; 
  
  PUG_U16 = ^UG_U16;  
  UG_U16 = Word; 
  
  PUG_S16 = ^UG_S16;  
  UG_S16 = Integer; 

  PUG_U32 = ^UG_U32;
{$ifdef VER70}
  UG_U32 = LongInt;
{$else}
  UG_U32 = DWORD;
{$endif}

  PUG_S32 = ^UG_S32;
  UG_S32 = LongInt;

function IncPtrU8(p: PUG_U8; x: LongInt): PUG_U8;

implementation

function IncPtrU8(p: PUG_U8; x: LongInt): PUG_U8;
begin
  Inc(p, x);
  IncPtrU8 := p;
end;

end.

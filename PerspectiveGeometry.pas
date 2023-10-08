[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','STRRTL')]Module PerspectiveGeometry;

(******************************************************************************)

[Global]Function getNearCenter(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getMiddleCenter(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getCenterFar(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getLeftFar(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getRightFar(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getCenterMiddle(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getLeftMiddle(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getRightMiddle(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getCenterNear(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Passage;
      front:= Passage;
      right:= Passage;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getLeftNear(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;

(******************************************************************************)

[Global]Function getRightNear(Direction: Direction_Type): ISpot;

Var
   returnValue: ISpot;

Begin
  returnValue:=Zero;
  with returnValue do
    Begin
      left:= Wall;
      front:= Wall;
      right:= Wall;
      contents:=0;
      kind:=Corridor;
    End;
  return returnValue;
End;
End.

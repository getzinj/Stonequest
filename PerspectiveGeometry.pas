[Inherit ('SYS$LIBRARY:STARLET','Types')]Module PerspectiveGeometry;

Type
  NewISpot = Record
            direction: Direction_Type;
            kind: Area_Type;
            front,left,right: Exit_Type;
            contents: [Byte]0..15; {index of Special_Table }
            rowX,rowY: [Byte]1..20;
          End;


Var
   Maze:                                            [External]Level;
   PosX,PosY,PosZ:                                  [Byte,External]0..20;


(******************************************************************************)

Function getLocation(direction: Direction_Type; posX, posY: Integer): NewISpot;

Var
  room: Room_Record;
  resultSpot: NewISpot; { Temporary record to hold the result }

Begin
  room := Maze.Room[posX][posY];

  resultSpot.direction := direction;
  resultSpot.kind := room.Kind;
  resultSpot.contents := room.Contents;
  resultSpot.rowX := posX;
  resultSpot.rowY := posY;

  Case direction Of
    North:
      Begin
        resultSpot.front := room.North;
        resultSpot.left := room.West;
        resultSpot.right := room.East;
      End;
    South:
      Begin
        resultSpot.front := room.South;
        resultSpot.left := room.East;
        resultSpot.right := room.West;
      End;
    East:
      Begin
        resultSpot.front := room.East;
        resultSpot.left := room.North;
        resultSpot.right := room.South;
      End;
    West:
      Begin
        resultSpot.front := room.West;
        resultSpot.left := room.South;
        resultSpot.right := room.North;
      End;
  End;

  { After setting the properties, return the temporary record }
  getLocation := resultSpot;
End;

Function getPositionToLeft(spot: NewISpot): NewISpot;

Var
  leftX, leftY: Integer;

Begin
  leftX := spot.rowX;
  leftY := spot.rowY;

  if (spot.direction = North) then
  Begin
    if spot.rowX > 1 then
      leftX := spot.rowX - 1
    else
      leftX := 20;
  End
  else if (spot.direction = South) then
  Begin
    if spot.rowX < 20 then
      leftX := spot.rowX + 1
    else
      leftX := 1;
  End
  else if (spot.direction = East) then
  Begin
    if spot.rowY > 1 then
      leftY := spot.rowY - 1
    else
      leftY := 20;
  End
  else if (spot.direction = West) then
  Begin
    if spot.rowY < 20 then
      leftY := spot.rowY + 1
    else
      leftY := 1;
  End;

  return getLocation(spot.direction, leftX, leftY);
End;

Function getPositionToRight(spot: NewISpot): NewISpot;

Var
  rightX, rightY: Integer;

Begin
  rightX := spot.rowX;
  rightY := spot.rowY;

  if (spot.direction = North) then
  Begin
    if spot.rowX < 20 then
      rightX := spot.rowX + 1
    else
      rightX := 1;
  End
  else if (spot.direction = South) then
  Begin
    if spot.rowX > 1 then
      rightX := spot.rowX - 1
    else
      rightX := 20;
  End
  else if (spot.direction = East) then
  Begin
    if spot.rowY < 20 then
      rightY := spot.rowY + 1
    else
      rightY := 1;
  End
  else if (spot.direction = West) then
  Begin
    if spot.rowY > 1 then
      rightY := spot.rowY - 1
    else
      rightY := 20;
  End;

  return getLocation(spot.direction, rightX, rightY);
End;

Function getPositionInFront(spot: NewISpot): NewISpot;

Var
  frontX, frontY: Integer;

Begin
  frontX := spot.rowX;
  frontY := spot.rowY;

  if (spot.direction = North) then
  Begin
    if spot.rowY > 1 then
      frontY := spot.rowY - 1
    else
      frontY := 20;
  End
  else if (spot.direction = South) then
  Begin
    if spot.rowY < 20 then
      frontY := spot.rowY + 1
    else
      frontY := 1;
  End
  else if (spot.direction = East) then
  Begin
    if spot.rowX < 20 then
      frontX := spot.rowX + 1
    else
      frontX := 1;
  End
  else if (spot.direction = West) then
  Begin
    if spot.rowX > 1 then
      frontX := spot.rowX - 1
    else
      frontX := 20;
  End;

  return getLocation(spot.direction, frontX, frontY);
End;

(******************************************************************************)
(************************ NEAR ***********************)
(******************************************************************************)

[Global]Function getCenterNear(Direction: Direction_Type): NewISpot;

Begin
  return getLocation(Direction, posX, posY);
End;


[Global]Function getLeftNear(Direction: Direction_Type): NewISpot;

Begin
  return getPositionToLeft(getCenterNear(Direction));
End;

[Global]Function getRightNear(Direction: Direction_Type): NewISpot;

  Begin
    return getPositionToRight(getLocation(Direction, posX, posY));
  End;

(******************************************************************************)
(******************** MIDDLE ***********************)
(******************************************************************************)

[Global]Function getCenterMiddle(Direction: Direction_Type): NewISpot;

Begin
  return getPositionInFront(getCenterNear(Direction));
End;

(******************************************************************************)

[Global]Function getLeftMiddle(Direction: Direction_Type): NewISpot;

Begin
  return getPositionToLeft(getCenterMiddle(Direction));
End;

(******************************************************************************)

[Global]Function getRightMiddle(Direction: Direction_Type): NewISpot;

Begin
  return getPositionToRight(getCenterMiddle(Direction));
End;

(******************************************************************************)
(************************ Far ***********************)
(******************************************************************************)

[Global]Function getCenterFar(Direction: Direction_Type): NewISpot;

Begin
  return getPositionInFront(getCenterMiddle(Direction));
End;

(******************************************************************************)

[Global]Function getLeftFar(Direction: Direction_Type): NewISpot;

Begin
  return getPositionToLeft(getCenterMiddle(Direction));
End;

(******************************************************************************)

[Global]Function getLeftLeftFar(Direction: Direction_Type): NewISpot;

Begin
  return getPositionToLeft(getLeftFar(Direction));
End;

(******************************************************************************)

[Global]Function getRightFar(Direction: Direction_Type): NewISpot;

Begin
  return getPositionToRight(getCenterMiddle(Direction));
End;

(******************************************************************************)

[Global]Function getRightRightFar(Direction: Direction_Type): NewISpot;

Begin
  return getPositionToRight(getRightFar(Direction));
End;
End.

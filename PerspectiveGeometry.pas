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

Function getXToEast(x: integer): integer;

Begin
  If x < 20 then
     getXToEast := x + 1
  Else
     getXToEast := 1;
End;

(******************************************************************************)

Function GetXToWest(x: integer): integer;

Begin
  If x > 1 then
     GetXToWest := x - 1
  Else
     GetXToWest := 20;
End;

(******************************************************************************)

Function getXToNorth(x: integer): integer;

Begin
  getXToNorth := x;
End;

(******************************************************************************)

Function GetXToSouth(x: integer): integer;

Begin
  GetXToSouth := x;
End;

(******************************************************************************)

Function getYToEast(y: integer): integer;

Begin
  getYToEast := y;
End;

(******************************************************************************)

Function GetYToWest(y: integer): integer;

Begin
  GetYToWest := y;
End;

(******************************************************************************)

Function getYToNorth(y: integer): integer;

Begin
  If y > 1 then
     getYToNorth := y - 1
  Else
     getYToNorth := 20;
End;

(******************************************************************************)

Function GetYToSouth(y: integer): integer;

Begin
  If y < 20 then
     GetYToSouth := y + 1
  Else
     GetYToSouth := 1;
End;

(******************************************************************************)

Function getLocation(direction: Direction_Type; posX, posY: Integer): NewISpot;

Var
  room: Room_Record;
  resultSpot: NewISpot; { Temporary record to hold the result }

Begin
  room := Maze.Room[posX][posY];

  resultSpot:=Zero;

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

(******************************************************************************)

Function getPositionToLeft(spot: NewISpot): NewISpot;

Var
  newX, newY: Integer;

Begin
  newX := spot.rowX;
  newY := spot.rowY;
  if (spot.direction = North) then
      Begin
         newX:=getXToWest(spot.rowX);
         newY:=getYToWest(spot.rowY);
      End
  else if (spot.direction = South) then
      Begin
         newX:=getXToEast(spot.rowX);
         newY:=getYToEast(spot.rowY);
      End
  else if (spot.direction = East) then
      Begin
         newX:=getXToNorth(spot.rowX);
         newY:=getYToNorth(spot.rowY);
      End
  else if (spot.direction = West) then
      Begin
         newX:=getXToSouth(spot.rowX);
         newY:=getYToSouth(spot.rowY);
      End;

  getPositionToLeft := getLocation(spot.direction, newX, newY);
End;

(******************************************************************************)

Function getPositionToRight(spot: NewISpot): NewISpot;

Var
  newX, newY: Integer;

Begin
  newX := spot.rowX;
  newY := spot.rowY;

  if (spot.direction = North) then
      Begin
         newX:=getXToEast(spot.rowX);
         newY:=getYToEast(spot.rowY);
      End
  else if (spot.direction = South) then
      Begin
         newX:=getXToWest(spot.rowX);
         newY:=getYToWest(spot.rowY);
      End
  else if (spot.direction = East) then
      Begin
         newX:=getXToSouth(spot.rowX);
         newY:=getYToSouth(spot.rowY);
      End
  else if (spot.direction = West) then
      Begin
         newX:=getXToNorth(spot.rowX);
         newY:=getYToNorth(spot.rowY);
      End;

  getPositionToRight := getLocation(spot.direction, newX, newY);
End;

(******************************************************************************)

Function getPositionInFront(spot: NewISpot): NewISpot;

Var
  newX, newY: Integer;

Begin
  newX := spot.rowX;
  newY := spot.rowY;

  if (spot.direction = North) then
      Begin
         newX:=getXToNorth(spot.rowX);
         newY:=getYToNorth(spot.rowY);
      End
  else if (spot.direction = South) then
      Begin
         newX:=getXToSouth(spot.rowX);
         newY:=getYToSouth(spot.rowY);
      End
  else if (spot.direction = East) then
      Begin
         newX:=getXToEast(spot.rowX);
         newY:=getYToEast(spot.rowY);
      End
  else if (spot.direction = West) then
      Begin
         newX:=getXToWest(spot.rowX);
         newY:=getYToWest(spot.rowY);
      End;

  getPositionInFront := getLocation(spot.direction, newX, newY);
End;

(******************************************************************************)
(************************ NEAR ***********************)
(******************************************************************************)

[Global]Function getCenterNear(Direction: Direction_Type): NewISpot;

Begin
  getCenterNear := getLocation(Direction, posX, posY);
End;

(******************************************************************************)

[Global]Function getLeftNear(Direction: Direction_Type): NewISpot;

Begin
  getLeftNear:=getPositionToLeft(getCenterNear(Direction));
End;

(******************************************************************************)

[Global]Function getRightNear(Direction: Direction_Type): NewISpot;

Begin
  getRightNear := getPositionToRight(getLocation(Direction, posX, posY));
End;

(******************************************************************************)
(******************** MIDDLE ***********************)
(******************************************************************************)

[Global]Function getCenterMiddle(Direction: Direction_Type): NewISpot;

Begin
  getCenterMiddle := getPositionInFront(getCenterNear(Direction));
End;

(******************************************************************************)

[Global]Function getLeftMiddle(Direction: Direction_Type): NewISpot;

Begin
  getLeftMiddle := getPositionToLeft(getCenterMiddle(Direction));
End;

(******************************************************************************)

[Global]Function getRightMiddle(Direction: Direction_Type): NewISpot;

Begin
  getRightMiddle := getPositionToRight(getCenterMiddle(Direction));
End;

(******************************************************************************)
(************************ Far ***********************)
(******************************************************************************)

[Global]Function getCenterFar(Direction: Direction_Type): NewISpot;

Begin
  getCenterFar := getPositionInFront(getCenterMiddle(Direction));
End;

(******************************************************************************)

[Global]Function getLeftFar(Direction: Direction_Type): NewISpot;

Begin
  getLeftFar := getPositionToLeft(getCenterFar(Direction));
End;

(******************************************************************************)

[Global]Function getLeftLeftFar(Direction: Direction_Type): NewISpot;

Begin
  getLeftLeftFar := getPositionToLeft(getLeftFar(Direction));
End;

(******************************************************************************)

[Global]Function getRightFar(Direction: Direction_Type): NewISpot;

Begin
  getRightFar := getPositionToRight(getCenterFar(Direction));
End;

(******************************************************************************)

[Global]Function getRightRightFar(Direction: Direction_Type): NewISpot;

Begin
  getRightRightFar := getPositionToRight(getRightFar(Direction));
End;
End.

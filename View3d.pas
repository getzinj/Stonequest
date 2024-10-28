(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL')]Module View3d;

Const
  Diamond_Join = 0;

Type
   Vertex = Packed Array [1..4] of Integer;
  NewISpot = Record
            direction: Direction_Type;
            kind: Area_Type;
            front,left,right: Exit_Type;
            contents: [Byte]0..15; {index of Special_Table }
            rowX,rowY: [Byte]1..20;
          End;

Var
  ViewDisplay: [External]Unsigned;

{********************************************************************************************************************}
[External]Function getNearCenter(Direction: Direction_Type): NewISpot;External;
[External]Function getMiddleCenter(Direction: Direction_Type): NewISpot;External;
[External]Function getCenterFar(Direction: Direction_Type): NewISpot;External;
[External]Function getLeftLeftFar(Direction: Direction_Type): NewISpot;External;
[External]Function getLeftFar(Direction: Direction_Type): NewISpot;External;
[External]Function getRightFar(Direction: Direction_Type): NewISpot;External;
[External]Function getRightRightFar(Direction: Direction_Type): NewISpot;External;
[External]Function getCenterMiddle(Direction: Direction_Type): NewISpot;External;
[External]Function getLeftMiddle(Direction: Direction_Type): NewISpot;External;
[External]Function getRightMiddle(Direction: Direction_Type): NewISpot;External;
[External]Function getCenterNear(Direction: Direction_Type): NewISpot;External;
[External]Function getLeftNear(Direction: Direction_Type): NewISpot;External;
[External]Function getRightNear(Direction: Direction_Type): NewISpot;External;
[External]Function Detected_Secret_Door (Member: Party_Type;  Current_Party_Size: Party_Size_Type; Rounds_Left: Spell_Duration_List;
 distance: Integer:=0):[Volatile]Boolean;External;
{********************************************************************************************************************}
{**************************************************** NEAR ROW ******************************************************}
{********************************************************************************************************************}

Function get_rendition_set(isDoor: Boolean): unsigned;

Begin
   If isDoor then
      get_rendition_set := SMG$M_REVERSE
   Else
      get_rendition_set := SMG$M_NORMAL;
End;

{********************************************************************************************************************}

Procedure wallNearFrontCenter(isDoor: Boolean);

var
  col, row: integer;
  renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    For col := 4 to 20 do
      For row := 1 to 6 do
         if (col = 4) or (col = 20) or (row = 6) then
           SMG$Put_Chars (ViewDisplay, ' ', row, col, , renditionSet)
         else
           SMG$Put_Chars (ViewDisplay, ' ', row, col);


    { Vertical line }
    SMG$Draw_Line(ViewDisplay, 1,  3, 7,  3);
    SMG$Draw_Line(ViewDisplay, 1, 21, 7, 21);

    { Horizontal Line }
    SMG$Draw_Line(ViewDisplay, 7, 3, 7, 21);
End;

{********************************************************************************************************************}

Procedure wallNearFrontLeft(isDoor: Boolean);

Var
   row, col: Integer;
   renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    For col := 1 to 2 do
      For row := 1 to 6 do
        if (col = 2) or (row = 6) then
          SMG$Put_Chars(ViewDisplay, ' ', row, col, , renditionSet)
        else
          SMG$Put_Chars(ViewDisplay, ' ', row, col);

    SMG$Draw_Line(ViewDisplay, 1, 3, 7, 3);
    SMG$Draw_Line(ViewDisplay, 7, 1, 7, 3);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 7, 3);
End;

{********************************************************************************************************************}

Procedure wallNearFrontRight(isDoor: Boolean);

Var
   row, col: Integer;
   renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    For col := 22 to 23 do
      For row := 1 to 6 do
        if (col = 22) or (row = 6) then
          SMG$Put_Chars(ViewDisplay, ' ', row, col, , renditionSet)
        else
          SMG$Put_Chars(ViewDisplay, ' ', row, col);

    SMG$Draw_Line(ViewDisplay, 1, 21, 7, 21);
    SMG$Draw_Line(ViewDisplay, 7, 21, 7, 23);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 7, 21);
End;

{********************************************************************************************************************}

Procedure wallNearLeftSide(isDoor: Boolean);

Var
  renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    SMG$Put_Chars (ViewDisplay, ' ', 1, 1, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 2, 1, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 3, 1, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 4, 1, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 5, 1, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 6, 1, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 7, 1, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 8, 1, , renditionSet);

    SMG$Put_Chars (ViewDisplay, ' ', 1, 2, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 2, 2, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 3, 2, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 4, 2, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 5, 2, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 6, 2, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 7, 2, , renditionSet);

    SMG$Put_Chars(ViewDisplay, '/', 8, 2);
    SMG$Put_Chars(ViewDisplay, '/', 9, 1);

    SMG$Draw_Line (ViewDisplay, 1, 3, 6, 3);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 7, 3);
End;

{********************************************************************************************************************}

Procedure wallNearRightSide(isDoor: Boolean);

Var
  renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    SMG$Put_Chars (ViewDisplay, ' ', 1, 22, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 2, 22, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 3, 22, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 4, 22, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 5, 22, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 6, 22, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 7, 22, , renditionSet);

    SMG$Put_Chars (ViewDisplay, ' ', 1, 23, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 2, 23, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 3, 23, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 4, 23, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 5, 23, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 6, 23, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 7, 23, , renditionSet);
    SMG$Put_Chars (ViewDisplay, ' ', 8, 23, , renditionSet);

    SMG$Put_Chars(ViewDisplay, '\', 8, 22);
    SMG$Put_Chars(ViewDisplay, '\', 9, 23);

    SMG$Draw_Line (ViewDisplay, 1, 21, 6, 21);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 7, 21);
End;

{********************************************************************************************************************}
{**************************************************** MIDDLE ROW ****************************************************}
{********************************************************************************************************************}

Procedure wallMiddleFrontCenter(isDoor: Boolean);

Var
   row, col: Integer;
   renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    For col := 7 to 17 do
      For row := 1 to 3 do
        if (col = 7) or (col = 17) or (row = 3) then
           SMG$Put_Chars(ViewDisplay, ' ', row,col, , renditionSet)
        else
           SMG$Put_Chars(ViewDisplay, ' ', row,col);

    SMG$Draw_Line(ViewDisplay, 1,  6, 4,  6);
    SMG$Draw_Line(ViewDisplay, 4,  6, 4, 18);
    SMG$Draw_Line(ViewDisplay, 1, 18, 4, 18);

    SMG$Draw_Char(ViewDisplay, Diamond_Join, 4, 6);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 4, 18);
End;

{********************************************************************************************************************}

Procedure wallMiddleFrontLeft(isDoor: Boolean);

Var
   row, col: Integer;
   renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    For col := 1 to 5 do
      For row := 1 to 3 do
        if (col = 1) or (col = 5) or (row = 3) then
          SMG$Put_Chars(ViewDisplay,' ', row, col, , renditionSet)
        else
          SMG$Put_Chars(ViewDisplay,' ', row, col);

    SMG$Draw_Line(ViewDisplay, 4, 1, 4, 6);
    SMG$Draw_Line(ViewDisplay, 1, 6, 4, 6);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 4, 6);
End;

{********************************************************************************************************************}

Procedure wallMiddleFrontRight(isDoor: Boolean);

Var
   row, col: Integer;
   renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    For col := 19 to 23 do
      For row := 1 to 3 do
        if (col = 19) or (col = 23) or (row = 3) then
           SMG$Put_Chars(ViewDisplay,' ', row, col, , renditionSet)
        Else
           SMG$Put_Chars(ViewDisplay,' ', row, col);

    SMG$Draw_Line(ViewDisplay, 1, 18, 4, 18);
    SMG$Draw_Line(ViewDisplay, 4, 18, 4, 23);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 4, 18);
End;

{********************************************************************************************************************}

Procedure wallMiddleLeftSide(isDoor: Boolean);

Var
  renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 4, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 2, 4, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 3, 4, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 4, 4, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 5, 4, , renditionSet);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 5, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 2, 5, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 3, 5, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 4, 5, , renditionSet);

    SMG$Draw_Line(ViewDisplay, 1, 3, 6, 3);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 7, 3);

    SMG$Put_Chars(ViewDisplay, '/', 6, 4);
    SMG$Put_Chars(ViewDisplay, '/', 5, 5);

    SMG$Draw_Line(ViewDisplay, 1, 6, 3, 6);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 4, 6);
End;

{********************************************************************************************************************}

Procedure wallMiddleRightSide(isDoor: Boolean);

Var
  renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 19, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 2, 19, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 3, 19, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 4, 19, , renditionSet);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 20, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 2, 20, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 3, 20, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 4, 20, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 5, 20, , renditionSet);

    SMG$Draw_Line(ViewDisplay, 1, 18, 3, 18);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 4, 18);

    SMG$Put_Chars(ViewDisplay, '\', 5, 19);
    SMG$Put_Chars(ViewDisplay, '\', 6, 20);

    SMG$Draw_Line(ViewDisplay, 1, 21, 6, 21);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 7, 21);
End;

{********************************************************************************************************************}
{****************************************************** FAR ROW *****************************************************}
{********************************************************************************************************************}

Procedure wallFarFrontLeftLeft(isDoor: Boolean);

Begin
    SMG$Draw_Line(ViewDisplay, 1, 1, 1, 2);
End;

{********************************************************************************************************************}

Procedure wallFarFrontLeft(isDoor: Boolean);

Begin
  SMG$Draw_Line(ViewDisplay, 1, 2, 1, 9);
End;

{********************************************************************************************************************}

Procedure wallFarFrontCenter(isDoor: Boolean);

Begin
    SMG$Draw_Line(ViewDisplay, 1, 9, 1, 15);
End;

{********************************************************************************************************************}

Procedure wallFarFrontRight(isDoor: Boolean);

Begin
    SMG$Draw_Line(ViewDisplay, 1, 15, 1, 22);
End;

{********************************************************************************************************************}

Procedure wallFarFrontRightRight(isDoor: Boolean);

Begin
    SMG$Draw_Line(ViewDisplay, 1, 22, 1, 23);
End;

{********************************************************************************************************************}

Procedure wallFarLeftLeftSide(isDoor: Boolean);

Var
  renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 1, , renditionSet);

    SMG$Draw_Char(ViewDisplay, Diamond_Join, 1, 2);
    SMG$Put_Chars(ViewDisplay, '/', 2, 1);
End;

{********************************************************************************************************************}

Procedure wallFarLeftSide(isDoor: Boolean);

Var
  renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 7, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 2, 7, , renditionSet);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 8, , renditionSet);

    SMG$Put_Chars(ViewDisplay, '/', 2, 8);
    SMG$Put_Chars(ViewDisplay, '/', 3, 7);

    SMG$Draw_Line(ViewDisplay, 1, 6, 3, 6);

    SMG$Draw_Char(ViewDisplay, Diamond_Join, 1, 9);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 4, 6);
End;

{********************************************************************************************************************}

Procedure wallFarRightSide(isDoor: Boolean);

Var
  renditionSet: Unsigned;

Begin
    renditionSet := get_rendition_set(isDoor);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 16, , renditionSet);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 17, , renditionSet);
    SMG$Put_Chars(ViewDisplay, ' ', 2, 17, , renditionSet);

    SMG$Put_Chars(ViewDisplay, '\', 2, 16);
    SMG$Put_Chars(ViewDisplay, '\', 3, 17);
    SMG$Draw_Line(ViewDisplay, 1, 18, 3, 18);

    SMG$Draw_Char(ViewDisplay, Diamond_Join, 1, 15);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 4, 18);
End;

{********************************************************************************************************************}

Procedure wallFarRightRightSide(isDoor: Boolean);


Var
  renditionSet: Unsigned;


Begin
    renditionSet := get_rendition_set(isDoor);
    SMG$Put_Chars(ViewDisplay, ' ', 1, 23, , renditionSet);

    SMG$Put_Chars(ViewDisplay, '\', 2, 23);
    SMG$Draw_Char(ViewDisplay, Diamond_Join, 1, 22);
End;

{********************************************************************************************************************}

Function looksLikeWall(exit: Exit_Type): Boolean;

Begin
  return (exit in [Wall,Door,Walk_Through,Secret]);
End;

{********************************************************************************************************************}

Function looksLikeDoor(distance: Integer; exit: Exit_Type; Member: Party_Type; Current_Party_Size: Party_Size_Type;
                       Rounds_Left: Spell_Duration_List): [Volatile]Boolean;

Begin
  return (exit = Door) or ((exit = Secret) and (Detected_Secret_Door(Member, Current_Party_Size, Rounds_Left, distance)));
End;

{********************************************************************************************************************}

[Global]Procedure far(leftLeftRoom: NewISpot; leftRoom: NewISpot; centerRoom: NewISpot; rightRoom: NewISpot; rightRightRoom: NewISpot;
                      Member: Party_Type; Current_Party_Size: Party_Size_Type; Rounds_Left: Spell_Duration_List);

Begin
   if (looksLikeWall(leftLeftRoom.front)) then
      wallFarFrontLeftLeft(looksLikeDoor(2, leftLeftRoom.front, Member, current_Party_size, Rounds_Left));

    if (looksLikeWall(leftRoom.front)) then
      wallFarFrontLeft(looksLikeDoor(2, leftRoom.front, Member, current_Party_size, Rounds_Left));

    if (looksLikeWall(centerRoom.front)) then
      wallFarFrontCenter(looksLikeDoor(2, centerRoom.front, Member, current_Party_size, Rounds_Left));

    if (looksLikeWall(rightRoom.front)) then
      wallFarFrontRight(looksLikeDoor(2, rightRoom.front, Member, current_Party_size, Rounds_Left));

    if (looksLikeWall(rightRightRoom.front)) then
      wallFarFrontRightRight(looksLikeDoor(2, rightRightRoom.front, Member, current_Party_size, Rounds_Left));

    if (looksLikeWall(leftRoom.left)) then
      wallFarLeftLeftSide(looksLikeDoor(2, leftRoom.left, Member, current_Party_size, Rounds_Left));

    if (looksLikeWall(centerRoom.left)) then
      wallFarLeftSide(looksLikeDoor(2, centerRoom.left, Member, current_Party_size, Rounds_Left));

    if (looksLikeWall(centerRoom.right)) then
      wallFarRightSide(looksLikeDoor(2, centerRoom.right, Member, current_Party_size, Rounds_Left));

    if (looksLikeWall(rightRoom.right)) then
      wallFarRightRightSide(looksLikeDoor(2, rightRoom.right, Member, current_Party_size, Rounds_Left));
End;

{********************************************************************************************************************}

Procedure middle(leftRoom: NewISpot; centerRoom: NewISpot; rightRoom: NewISpot; Member: Party_Type; Current_Party_Size: Party_Size_Type;
                 Rounds_Left: Spell_Duration_List);

Begin
  if (looksLikeWall(leftRoom.front)) then
    Begin
      wallMiddleFrontLeft(looksLikeDoor(1, leftRoom.front, Member, current_Party_size, Rounds_Left));
    End;
  if (looksLikeWall(rightRoom.front)) then
    Begin
      wallMiddleFrontRight(looksLikeDoor(1, rightRoom.front, Member, current_Party_size, Rounds_Left));
    End;
  if (looksLikeWall(centerRoom.front)) then
    Begin
      wallMiddleFrontCenter(looksLikeDoor(1, centerRoom.front, Member, current_Party_size, Rounds_Left));
    End;

  if (looksLikeWall(centerRoom.left)) then
    Begin
      wallMiddleLeftSide(looksLikeDoor(1, centerRoom.left, Member, current_Party_size, Rounds_Left));
    End;

  if (looksLikeWall(centerRoom.right)) then
    Begin
      wallMiddleRightSide(looksLikeDoor(1, centerRoom.right, Member, current_Party_size, Rounds_Left));
    End;
End;

{********************************************************************************************************************}

Procedure near(leftRoom: NewISpot; centerRoom: NewISpot; rightRoom: NewISpot; Member: Party_Type;
               Current_Party_Size: Party_Size_Type; Rounds_Left: Spell_Duration_List);

Begin
  if (looksLikeWall(leftRoom.front)) then
    Begin
      wallNearFrontLeft(looksLikeDoor(0, leftRoom.front, Member, current_Party_size, Rounds_Left));
    End;
  if (looksLikeWall(rightRoom.front)) then
    Begin
      wallNearFrontRight(looksLikeDoor(0, rightRoom.front, Member, current_Party_size, Rounds_Left));
    End;
  if (looksLikeWall(centerRoom.front)) then
    Begin
      wallNearFrontCenter(looksLikeDoor(0, centerRoom.front, Member, current_Party_size, Rounds_Left));
    End;
  if (looksLikeWall(centerRoom.left)) then
    Begin
      wallNearLeftSide(looksLikeDoor(0, centerRoom.left, Member, current_Party_size, Rounds_Left));
    End;
  if (looksLikeWall(centerRoom.right)) then
    Begin
      wallNearRightSide(looksLikeDoor(0, centerRoom.right, Member, current_Party_size, Rounds_Left));
    End;
End;

{********************************************************************************************************************}

[Global]Procedure printView3D (Direction: Direction_Type; Member: Party_Type; Current_Party_Size: Party_Size_Type;
                               Rounds_Left: Spell_Duration_List);

var
  leftNear,centerNear,rightNear: NewISpot;

Begin
  SMG$Begin_Display_Update(ViewDisplay);

  far(
      getLeftLeftFar(Direction),
      getLeftFar(Direction),
      getCenterFar(Direction),
      getRightFar(Direction),
      getRightRightFar(Direction),
      member,
      current_Party_Size,
      Rounds_Left
  );
  middle(
    getLeftMiddle(Direction),
    getCenterMiddle(Direction),
    getRightMiddle(Direction),
    member,
    current_Party_Size,
    Rounds_Left
  );

  leftNear:=getLeftNear(Direction);
  centerNear:=getCenterNear(Direction);
  rightNear:=getRightNear(Direction);

  near(
    leftNear,
    centerNear,
    rightNear,
    member,
    current_Party_Size,
    Rounds_Left
  );

  SMG$End_Display_Update(ViewDisplay);
End;
End.

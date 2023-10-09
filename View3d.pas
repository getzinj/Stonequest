[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL')]Module View3d;

Type
   Vertex = Packed Array [1..4] of Integer;

Var
  ViewDisplay: [External]Unsigned;


{********************************************************************************************************************}
[External]Function getNearCenter(Direction: Direction_Type): ISpot;External;
[External]Function getMiddleCenter(Direction: Direction_Type): ISpot;External;
[External]Function getCenterFar(Direction: Direction_Type): ISpot;External;
[External]Function getLeftLeftFar(Direction: Direction_Type): ISpot;External;
[External]Function getLeftFar(Direction: Direction_Type): ISpot;External;
[External]Function getRightFar(Direction: Direction_Type): ISpot;External;
[External]Function getRightRightFar(Direction: Direction_Type): ISpot;External;
[External]Function getCenterMiddle(Direction: Direction_Type): ISpot;External;
[External]Function getLeftMiddle(Direction: Direction_Type): ISpot;External;
[External]Function getRightMiddle(Direction: Direction_Type): ISpot;External;
[External]Function getCenterNear(Direction: Direction_Type): ISpot;External;
[External]Function getLeftNear(Direction: Direction_Type): ISpot;External;
[External]Function getRightNear(Direction: Direction_Type): ISpot;External;
{********************************************************************************************************************}



Function isPointInsideQuadrilateral(vertx: Vertex; verty: Vertex; testx: Integer; testy: Integer): boolean;

Var
   Result: Boolean;
   i,j: Integer;

Begin
    result:=false;

    i:=1;
    j:=4;
    Repeat
       Begin
          If (
            ((verty[i] > testy) <> (verty[j] > testy)) and
            (testx < (vertx[j] - vertx[i]) * (testy - verty[i]) / (verty[j] - verty[i]) + vertx[i])
          ) then
            result:=not result;

          j:=i;
          i:=i + 1;
       End
    Until (i > 4);

    return result;
End;


Procedure clearQuadrilateral(
  upperLeftY: Integer; upperLeftX: Integer;
  upperRightY: Integer; upperRightX: Integer;
  lowerRightY: Integer; lowerRightX: Integer;
  lowerLeftY: Integer; lowerLeftX: Integer);

  Var
    Row,Col: Integer;
    isInsideQuadrilateral: Boolean;
    vertx: Vertex;
    verty: Vertex;

  Begin
    for row:=min(upperLeftY,upperRightY,lowerLeftY,lowerRightY) to max(upperLeftY,upperRightY,lowerLeftY,lowerRightY) do
      for col:=min(upperLeftX,upperRightX,lowerLeftX,lowerRightX) to max(upperLeftX,upperRightX,lowerLeftX,lowerRightX) do
        begin
            vertx[1]:=upperLeftX;  vertx[2]:=upperRightX; vertx[3]:=lowerRightX;  vertx[4]:=lowerLeftX;
            verty[1]:=upperLeftY;  verty[2]:=upperRightY; verty[3]:=lowerRightY;  verty[4]:=lowerLeftY;

            isInsideQuadrilateral:=isPointInsideQuadrilateral(
              vertx,
              verty,
              col, row
            );

            if (isInsideQuadrilateral) then
              Begin
                 SMG$Erase_Chars(ViewDisplay, 1, row, col);
              End;
        End;
 End;

{********************************************************************************************************************}
{**************************************************** NEAR ROW ******************************************************}
{********************************************************************************************************************}

Procedure wallNearFrontCenter;

Begin
    clearQuadrilateral(1, 3, 1, 21, 7, 21, 7, 7);

    { Vertical line }
    SMG$Draw_Line(ViewDisplay, 1, 3, 7, 3);
    SMG$Draw_Line(ViewDisplay, 1, 21, 7, 21);

    { Horizontal Line }
    SMG$Draw_Line(ViewDisplay, 7, 3, 7, 21);
End;

{********************************************************************************************************************}

Procedure wallNearFrontLeft;

Begin
    clearQuadrilateral(1, 1, 1, 3, 7, 3, 7, 1);

    SMG$Draw_Line(ViewDisplay, 1, 3, 7, 3);
    SMG$Draw_Line(ViewDisplay, 7, 1, 7, 3);
End;

{********************************************************************************************************************}

Procedure wallNearFrontRight;

Begin
    clearQuadrilateral(1, 21, 1, 23, 7, 23, 7, 21);

    SMG$Draw_Line(ViewDisplay, 1, 21, 7, 21);
    SMG$Draw_Line(ViewDisplay, 7, 21, 7, 23)
End;

{********************************************************************************************************************}

Procedure wallNearLeftSide;

Begin
    clearQuadrilateral(1, 1, 1, 3, 7, 3, 9, 1);

    SMG$Draw_Char(ViewDisplay, 0, 7, 3);
    SMG$Put_Chars(ViewDisplay, '/', 8, 2);
    SMG$Put_Chars(ViewDisplay, '/', 9, 1);
End;

{********************************************************************************************************************}

Procedure wallNearRightSide;

Begin
    clearQuadrilateral(1, 21, 1, 23, 9, 23, 7, 21);

    SMG$Draw_Char(ViewDisplay, 0, 7, 21);
    SMG$Put_Chars(ViewDisplay, '\\', 8, 22);
    SMG$Put_Chars(ViewDisplay, '\\', 9, 23);
End;

{********************************************************************************************************************}
{**************************************************** MIDDLE ROW ****************************************************}
{********************************************************************************************************************}

Procedure wallMiddleFrontCenter;

Begin
    clearQuadrilateral(1, 6, 1, 18, 4, 18, 4, 6);
    SMG$Put_Chars(ViewDisplay, '', 1, 9);
    SMG$Put_Chars(ViewDisplay, ' ', 2, 8);
    SMG$Put_Chars(ViewDisplay, ' ', 3, 7);

    SMG$Put_Chars(ViewDisplay, ' ', 1, 6);
    SMG$Put_Chars(ViewDisplay, ' ', 2, 6);
    SMG$Put_Chars(ViewDisplay, ' ', 3, 6);
    SMG$Put_Chars(ViewDisplay, ' ', 4, 6);

    SMG$Draw_Line(ViewDisplay, 1,  6, 4,  6);
    SMG$Draw_Line(ViewDisplay, 1, 18, 4, 18);
    SMG$Draw_Line(ViewDisplay, 4,  6, 4, 18);
End;

{********************************************************************************************************************}

Procedure wallMiddleFrontLeft;

Begin
    clearQuadrilateral(1, 1, 1, 6, 4, 6, 4, 1);

    SMG$Draw_Line(ViewDisplay, 4, 0, 4, 6);

    SMG$Draw_Line(ViewDisplay, 1, 6, 4, 6);
End;

{********************************************************************************************************************}

Procedure wallMiddleFrontRight;

Begin
    clearQuadrilateral(1, 18, 1, 23, 4, 23, 4, 18);

    SMG$Draw_Line(ViewDisplay, 1, 18, 4, 18);
    SMG$Draw_Line(ViewDisplay, 4, 18, 4, 23);
End;

{********************************************************************************************************************}

Procedure wallMiddleLeftSide;

Begin
    clearQuadrilateral(4, 6, 7, 3, 1, 3, 1, 6);

    SMG$Draw_Char(ViewDisplay, 0, 4, 6);
    SMG$Draw_Line(ViewDisplay, 1, 6, 4, 6);
    SMG$Put_Chars(ViewDisplay, '/', 5, 5);
    SMG$Put_Chars(ViewDisplay, '/', 6, 4);
    SMG$Draw_Line(ViewDisplay, 1, 3, 7, 3);
    SMG$Draw_Char(ViewDisplay, 0, 7, 3);
End;

{********************************************************************************************************************}

Procedure wallMiddleRightSide;

Begin
    clearQuadrilateral(1, 18, 1, 21, 7, 21, 4, 18);

    SMG$Draw_Line(ViewDisplay, 1, 18, 4, 18);
    SMG$Draw_Char(ViewDisplay, 0, 4, 18);
    SMG$Put_Chars(ViewDisplay, '\\', 5, 19);
    SMG$Put_Chars(ViewDisplay, '\\', 6, 20);
    SMG$Draw_Line(ViewDisplay, 1, 21, 7, 21);
    SMG$Draw_Char(ViewDisplay, 0, 7, 21);
End;

{********************************************************************************************************************}
{****************************************************** FAR ROW *****************************************************}
{********************************************************************************************************************}

Procedure wallFarFrontLeftLeft;

Begin
    SMG$Draw_Line(ViewDisplay, 1, 1, 1, 2);
End;

{********************************************************************************************************************}


Procedure wallFarFrontLeft;

Begin
  SMG$Draw_Line(ViewDisplay, 1, 2, 1, 9);
End;

{********************************************************************************************************************}

Procedure wallFarFrontCenter;

Begin
    SMG$Draw_Line(ViewDisplay, 1, 9, 1, 15);
End;

{********************************************************************************************************************}

Procedure wallFarFrontRight;

Begin
    SMG$Draw_Line(ViewDisplay, 1, 15, 1, 22);
End;

{********************************************************************************************************************}

Procedure wallFarFrontRightRight;

Begin
    SMG$Draw_Line(ViewDisplay, 1, 22, 1, 23);
End;


{********************************************************************************************************************}

Procedure wallFarLeftLeftSide;

Begin
    SMG$Draw_Char(ViewDisplay, 0, 1, 2);
    SMG$Put_Chars(ViewDisplay, '/', 2, 1);
End;

{********************************************************************************************************************}

Procedure wallFarLeftSide;

Begin
    clearQuadrilateral(1, 9, 4, 6, 1, 6, 1, 9);

    SMG$Draw_Char(ViewDisplay, 0, 1, 9);
    SMG$Put_Chars(ViewDisplay, '/', 2, 8);
    SMG$Put_Chars(ViewDisplay, '/', 3, 7);
    SMG$Draw_Line(ViewDisplay, 1, 6, 4, 6);
    SMG$Draw_Char(ViewDisplay, 0, 4, 6);
End;

{********************************************************************************************************************}

Procedure wallFarRightSide;

Begin
    clearQuadrilateral(1, 15, 4, 18, 1, 18, 1, 15);

    SMG$Draw_Char(ViewDisplay, 0, 1, 15);
    SMG$Put_Chars(ViewDisplay, '\\', 2, 16);
    SMG$Put_Chars(ViewDisplay, '\\', 3, 17);
    SMG$Draw_Line(ViewDisplay, 1, 22, 4, 18);
    SMG$Draw_Char(ViewDisplay, 0, 4, 18);
End;

{********************************************************************************************************************}

Procedure wallFarRightRightSide;

Begin
    SMG$Draw_Char(ViewDisplay, 0, 1, 22);
    SMG$Put_Chars(ViewDisplay, '\\', 2, 23);
End;


{********************************************************************************************************************}

Function looksLikeWall(exit: Exit_Type): Boolean;

Begin
  return (exit in [Wall,Door,Walk_Through,Secret]);
End;

{********************************************************************************************************************}

Procedure far(leftLeftRoom: ISpot; leftRoom: ISpot; centerRoom: ISpot; rightRoom: ISpot; rightRightRoom: ISpot);

Begin
    if (looksLikeWall(leftLeftRoom.front)) then
      wallFarFrontLeftLeft;
    if (looksLikeWall(leftRoom.front)) then
      wallFarFrontLeft;
    if (looksLikeWall(centerRoom.front)) then
      wallFarFrontCenter;
    if (looksLikeWall(rightRoom.front)) then
      wallFarFrontRight;
    if (looksLikeWall(rightRightRoom.front)) then
      wallFarFrontRightRight;


    if (looksLikeWall(leftRoom.left)) then
      wallFarLeftLeftSide;
    if (looksLikeWall(centerRoom.left)) then
      wallFarLeftSide;
    if (looksLikeWall(centerRoom.right)) then
      wallFarRightSide;
    if (looksLikeWall(rightRoom.right)) then
      wallFarRightRightSide;
End;

{********************************************************************************************************************}


Procedure middle(leftRoom: ISpot; centerRoom: ISpot; rightRoom: ISpot);

Begin
  if (looksLikeWall(leftRoom.front)) then
    Begin
      wallMiddleFrontLeft;
    End;
  if (looksLikeWall(rightRoom.front)) then
    Begin
      wallMiddleFrontRight;
    End;
  if (looksLikeWall(centerRoom.front)) then
    Begin
      wallMiddleFrontCenter;
    End;

  if (looksLikeWall(centerRoom.left)) then
    Begin
      wallMiddleLeftSide;
    End;

  if (looksLikeWall(centerRoom.right)) then
    Begin
      wallMiddleRightSide;
    End;
End;

{********************************************************************************************************************}

Procedure near(leftRoom: ISpot; centerRoom: ISpot; rightRoom: ISpot);

Begin
  if (looksLikeWall(leftRoom.front)) then
    Begin
      wallNearFrontLeft;
    End;
  if (looksLikeWall(rightRoom.front)) then
    Begin
      wallNearFrontRight;
    End;
  if (looksLikeWall(centerRoom.front)) then
    Begin
      wallNearFrontCenter;
    End;

  if (looksLikeWall(centerRoom.left)) then
    Begin
      wallNearLeftSide;
    End;
  if (looksLikeWall(centerRoom.right)) then
    Begin
      wallNearRightSide;
    End;
End;

{********************************************************************************************************************}

[Global]Procedure printView3D (Direction: Direction_Type; Member: Party_Type; Current_Party_Size: Party_Size_Type);

Begin
  SMG$Begin_Display_Update(ViewDisplay);
  far(
      getLeftLeftFar(Direction),
      getLeftFar(Direction),
      getCenterFar(Direction),
      getRightFar(Direction),
      getRightRightFar(Direction)
  );
  middle(
    getLeftMiddle(Direction),
    getCenterMiddle(Direction),
    getRightMiddle(Direction)
  );
  near(
    getLeftNear(Direction),
    getCenterNear(Direction),
    getRightNear(Direction)
  );
  SMG$End_Display_Update(ViewDisplay);
End;
End.

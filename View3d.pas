[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL')]Module View3d;

Const
  farWallChar = ' ';
  middleWallChar = ' ';
  closeWallChar = ' ';

  MAX_COLUMN = 27;
  MAX_ROW = 9;

  WALL_UPRIGHT_CHARACTER = '|';
  WALL_HORIZONTAL_CHARACTER = '-';
  JOIN_CHARACTER = '+';
  RIGHT_WALL_DIAGONAL = '\\';
  LEFT_WALL_DIAGONAL = '/';

Var
  ViewDisplay: [External]Unsigned;

{********************************************************************************************************************}
{**************************************************** NEAR ROW ******************************************************}
{********************************************************************************************************************}

Procedure wallNearFrontCenter;

Var
  row,innerCol,col: Integer;

Begin
  for row:=1 to 6 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row, 3);
      for innerCol:=4 to 24 do
        Begin
          SMG$Put_Chars (ViewDisplay,closeWallChar,row,innerCol);
        End;
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row, 25);
    End;

  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 7, 3);
  for col:=4 to 24 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 7, col);
    End;
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 7, 25);
End;

{********************************************************************************************************************}

Procedure wallNearFrontLeft;

Var
   row,innerCol: Integer;

Begin
  for row:=1 to 6 do
    Begin
      for innerCol:=1 to 2 do
        Begin
          SMG$Put_Chars (ViewDisplay,closeWallChar,row,innerCol);
        End;
    End;

  SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 7, 1);
  SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 7, 2);

  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 7, 3);
  for row:=1 to 6 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row, 3);
    End;
End;

{********************************************************************************************************************}

Procedure wallNearFrontRight;

Var
   row,innerCol: Integer;

Begin
  for row:=1 to 6 do
    Begin
      for innerCol:=26 to 27 do
        Begin
          SMG$Put_Chars (ViewDisplay,closeWallChar,row,innerCol);
        End;
    End;

  for row:=1 to 6 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row, 25);
    End;

  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 7, 25);
  SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 7, 26);
  SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 7, 27);
End;

{********************************************************************************************************************}

Procedure wallNearLeftSide;

Var
   row: Integer;

Begin
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER,7, 3);
  SMG$Put_Chars (ViewDisplay,LEFT_WALL_DIAGONAL,8, 2);
  SMG$Put_Chars (ViewDisplay,LEFT_WALL_DIAGONAL,9, 1);

  for row:=1 to 7 do
    Begin
      SMG$Put_Chars (ViewDisplay,closeWallChar,row,1);
      SMG$Put_Chars (ViewDisplay,closeWallChar,row,2);
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row,3);
    End;
  SMG$Put_Chars (ViewDisplay,closeWallChar,8,1);
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 7, 3);
End;

{********************************************************************************************************************}

Procedure wallNearRightSide;

Var
   row: Integer;

Begin
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER,7, 25);
  SMG$Put_Chars (ViewDisplay,RIGHT_WALL_DIAGONAL,8, 26);
  SMG$Put_Chars (ViewDisplay,RIGHT_WALL_DIAGONAL,9, 27);

  for row:=1 to 7 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row,25);
      SMG$Put_Chars (ViewDisplay,closeWallChar,row,26);
      SMG$Put_Chars (ViewDisplay,closeWallChar,row,27);
    End;

  SMG$Put_Chars (ViewDisplay,closeWallChar,8,27);
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 7, 25);
End;

{********************************************************************************************************************}
{**************************************************** MIDDLE ROW ****************************************************}
{********************************************************************************************************************}

Procedure wallMiddleFrontCenter;

Var
   row,col,innerCol: Integer;

Begin
  for row:=1 to 2 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row, 6);
      for innerCol:=7 to 21 do
        Begin
          SMG$Put_Chars (ViewDisplay,middleWallChar,row,innerCol);
        End;
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row, 22);
    End;

  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 3, 6);
  for col:=7 to 20 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 3, col);
    End;
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 3, 21);
End;

{********************************************************************************************************************}

Procedure wallMiddleFrontLeft;

Var
   row,column,innerCol: Integer;


Begin
  for row:=1 to 2 do
    Begin
      for innerCol:=1 to 6 do
        Begin
          SMG$Put_Chars (ViewDisplay,middleWallChar,row,innerCol);
        End;
    End;
  for column:=1 to 6 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 3, column);
    End;

  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 3, 7);
  for row:=1 to 2 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row, 7);
    End;
End;

{********************************************************************************************************************}

Procedure wallMiddleFrontRight;

Var
   row,column,innerCol: Integer;


Begin
  for row:=1 to 2 do
    Begin
      for innerCol:=22 to 27 do
        Begin
          SMG$Put_Chars (ViewDisplay,middleWallChar,row,innerCol);
        End;
    End;
    for column:=22 to 27 do
      Begin
        SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 3, column);
      End;

  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 3, 21);
  for row:=1 to 2 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER,row, 21);
    End;
End;

{********************************************************************************************************************}

Procedure wallMiddleLeftSide;

Var
   row: Integer;


Begin
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER,7, 3);
  SMG$Put_Chars (ViewDisplay,LEFT_WALL_DIAGONAL,6, 4);
  SMG$Put_Chars (ViewDisplay,LEFT_WALL_DIAGONAL,5, 5);
  SMG$Put_Chars (ViewDisplay,LEFT_WALL_DIAGONAL,4, 6);
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER,3, 7);

  for row:=1 to 2 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER, row, 7);
    End;
  SMG$Put_Chars (ViewDisplay,middleWallChar, 1, 6);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 2, 6);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 3, 6);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 1, 5);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 2, 5);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 3, 5);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 4, 5);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 1, 4);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 2, 4);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 3, 4);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 4, 4);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 5, 4);

  for row:=1 to 6 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER, row, 3);
    End;
End;

{********************************************************************************************************************}

Procedure wallMiddleRightSide;

Var
   row: Integer;


Begin
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER,7, 25);
  SMG$Put_Chars (ViewDisplay,RIGHT_WALL_DIAGONAL,6, 24);
  SMG$Put_Chars (ViewDisplay,RIGHT_WALL_DIAGONAL,5, 23);
  SMG$Put_Chars (ViewDisplay,RIGHT_WALL_DIAGONAL,4, 22);
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 3, 21);

  for row:=1 to 2 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER, row, 21);
    End;
  SMG$Put_Chars (ViewDisplay,middleWallChar, 1, 22);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 2, 22);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 3, 22);

  SMG$Put_Chars (ViewDisplay,middleWallChar, 1, 23);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 2, 23);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 3, 23);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 4, 23);

  SMG$Put_Chars (ViewDisplay,middleWallChar, 1, 24);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 2, 24);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 3, 24);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 4, 24);
  SMG$Put_Chars (ViewDisplay,middleWallChar, 5, 24);

  for row:=1 to 6 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER, row, 25);
    End;
End;

{********************************************************************************************************************}
{****************************************************** FAR ROW *****************************************************}
{********************************************************************************************************************}

Procedure wallFarFrontLeft;

Var
   innerCol: Integer;


Begin
  for innerCol:=1 to 8 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 1, innerCol);
    End;
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 1, 9);
End;

{********************************************************************************************************************}

Procedure wallFarFrontCenter;

Var
   innerCol: Integer;


Begin
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 1, 9);
  for innerCol:=10 to 18 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 1, innerCol);
    End;
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 1, 19);
End;

{********************************************************************************************************************}

Procedure wallFarFrontRight;

Var
   innerCol: Integer;

Begin
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 1, 19);
  for innerCol:=20 to 27 do
    Begin
      SMG$Put_Chars (ViewDisplay,WALL_HORIZONTAL_CHARACTER, 1, innerCol);
    End;
End;

{********************************************************************************************************************}

Procedure wallFarLeftSide;

Begin
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 1, 9);
  SMG$Put_Chars (ViewDisplay,LEFT_WALL_DIAGONAL, 2, 8);
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 3, 7);

  SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER, 2, 7);
  SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER, 1, 7);

  SMG$Put_Chars (ViewDisplay,farWallChar, 1, 8);
End;

{********************************************************************************************************************}

Procedure wallFarRightSide;

Begin
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 1, 19);
  SMG$Put_Chars (ViewDisplay,RIGHT_WALL_DIAGONAL, 2, 20);
  SMG$Put_Chars (ViewDisplay,JOIN_CHARACTER, 3, 21);

  SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER, 2, 21);
  SMG$Put_Chars (ViewDisplay,WALL_UPRIGHT_CHARACTER, 1, 21);

  SMG$Put_Chars (ViewDisplay,farWallChar, 1, 20);
End;

{********************************************************************************************************************}

Procedure far;

Begin
  wallFarFrontLeft;
  wallFarFrontCenter;
  wallFarFrontRight;
  wallFarLeftSide;
  wallFarRightSide;
End;

{********************************************************************************************************************}

Procedure middle;

Begin
  wallMiddleFrontLeft;
  wallMiddleFrontCenter;
  wallMiddleFrontRight;
  wallMiddleLeftSide;
  wallMiddleRightSide;
End;

{********************************************************************************************************************}

Procedure near;

Begin
  wallNearFrontLeft;
  wallNearFrontCenter;
  wallNearFrontRight;
  wallNearLeftSide;
  wallNearRightSide;
End;

{********************************************************************************************************************}

Procedure drawView;

Begin
  far;
  middle;
  near;
End;
End.

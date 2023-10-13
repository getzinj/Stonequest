[Inherit ('Types','SMGRTL')]Module Pic_Edit;

Const
   Up_Arrow      = CHR(18);             Down_Arrow     = CHR(19);
   Left_Arrow    = CHR(20);             Right_Arrow    = CHR(21);

Var
   CursorX,CursorY: Integer;  { Where the cursor is during editing.  If the cursor is not being used, the values will be 0, 0 }
   ScreenDisplay: [External]Unsigned;


(******************************************************************************)
[External]Function Get_Key (Time_Out: Integer:=-1; Time_out_Char: Integer:=32): [Volatile]Integer;External;
[External]Function String(Num: Integer; Len: Integer:=0):Line;External;
[External]Procedure Get_Num (Var Number: Integer; Display: Unsigned);External;
(******************************************************************************)

Procedure Display_Image (Image: Image_Type;  Start_Row, Start_Column: Integer:=1);

{ This procedure will display the image at 1,1 }

Var
  X,Y: Integer;
  C: Unsigned;

Begin { Display Image }
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Put_Chars (ScreenDisplay,'+------------------------+',Start_Row,Start_Column);
   For Y:=1 to 9 do
      Begin
         SMG$Put_Chars (ScreenDisplay,'|',Start_Row+Y,Start_Column);
         For X:=1 to 23 do
             Begin
                C:=0;
                If (X=CursorX) and (Y=CursorY) then C:=2;  { If this is the location of the cursor, inverse }
                SMG$Put_Chars (ScreenDisplay,
                   Image[X,Y]
                   +'',
                   Y+Start_Row,
                   X+Start_Column,
                   0,
                   C);
             End;
         SMG$Put_Chars (ScreenDisplay,'|',Start_Row+Y,Start_Column+24);
      End;
   SMG$Put_Chars (ScreenDisplay,'+------------------------+',Start_Row+10,Start_Column);
   SMG$End_Display_Update (ScreenDisplay);
End;  { Display Image }

(******************************************************************************)

Procedure Fix_Image (Var Image: Image_Type);

{ This procedure will initialize an un-initialized image by replacing invalid characters with spaces }

Var
  X,Y: Integer;

Begin { Fix Image }
   For X:=1 to 23 do
      For Y:=1 to 9 do
         If (Image[X,Y] in [CHR(0)..CHR(31),CHR(127),CHR(255)]) then
             Image[X,Y]:=' ';
End;  { Fix Image }

(******************************************************************************)

Procedure Initialize_Eyes (Var Pic: Picture);

{ This procedure will make it so that PIC does not have eyes that bug out }

Begin { Initialize Eyes }
  Pic.Left_Eye.X:=0;
  Pic.Left_Eye.Y:=0;
  Pic.Right_Eye.X:=0;
  Pic.Right_Eye.Y:=0;
End;  { Initialize Eyes }

(******************************************************************************)

Procedure Fix_Eyes (Var Pic: Picture);

{ This procedure will initialize the eyes of a picture if they are n ot in an acceptable format. }

Begin { Fix Eyes }
  If (Pic.Left_Eye.X<0) or (Pic.Left_Eye.X>23) then
     Initialize_Eyes(Pic)
  Else
     If (Pic.Left_Eye.Y<0) or (Pic.Left_Eye.Y>23) then
        Initialize_Eyes(Pic)
     Else
        If (Pic.Right_Eye.X<0) or (Pic.Right_Eye.X>23) then
           Initialize_Eyes(Pic)
        Else
           If (Pic.Right_Eye.Y<0) or (Pic.Right_Eye.Y>23) then
              Initialize_Eyes(Pic);
  If Not (Pic.Eye_Type in [CHR(32)..CHR(126)]) then
      Pic.Eye_Type:=' ';
End;  { Fix Eyes }

(******************************************************************************)

Procedure Fix_Pic (Var Pic: Picture);

{ This procedure initializes am non-initialized pictures }

Begin { Fix Pic }
   Fix_Image (Pic,Image);
   Fix_Eyes (Pic);
End;  { Fix Pic }

(******************************************************************************)

Function Make_Choice (Options: Char_Set): Char;

{ This function is identical to the MAKE_CHOICE in the main module except that here, one can enter lower case letters }

Var
   Temp: Char;
   Keyin: Integer;

Begin { Make Choice }
  Repeat
    Begin
       KeyIn:=Get_Key;
       Temp:=CHR(Keyin)
    End;
  Until (Temp in Options);
  Make_Choice:=Temp;
End;  { Make Choice }

(******************************************************************************)

Procedure Move_Up (Var CursorY: Ordinate);

{ This procedure moves CursorY up one, and wraps if it goes over }

Begin { Move Up }
   CursorY:=CursorY-1;
   If CursorY < 1 then CursorY:=9;
End;  { Move Up }

(******************************************************************************)

Procedure Move_Left (Var CursorX,CursorY: Ordinate);

{ This procedure moves CursorX left, and wraps if it goes over }

Begin { Move Left }
   CursorX:=CursorX-1;
   If CursorX < 1 then
      Begin
         CursorX:=23;
         Move_Up (CursorY);
      End;
End;  { Move Left }

(******************************************************************************)

Procedure Move_Down (Var CursorY: Ordinate);

{ This procedure moves CursorY down one, and wraps if it goes over }

Begin { Move Down }
   CursorY:=CursorY+1;
   If CursorY > 9 then CursorY:=1;
End;  { Move Down }

(******************************************************************************)

Procedure Move_Right (Var CursorX,CursorY: Ordinate);

{ This procedure moves CursorX right, and wraps if it goes over }

Begin { Move Right }
   CursorX:=CursorX+1;
   If CursorX > 23 then
      Begin
         Move_Down (CursorY);
         CursorX:=1;
      End;
End;  { Move Right }

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Pic_Edit (Var Pics: Pic_List);

Begin { Pic Edit }

{ TODO: Enter this code }

End;  { Pic Edit }
End.  { Pic Edit }

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
[External]Function Get_Num (Display: Unsigned): Integer;External;
(******************************************************************************)

Procedure Display_Image (Image: Image_Type;  Start_Row, Start_Column: Integer:=1);

{ This procedure will display the image at 1,1 }

Var
  X,Y: Integer;
  C: Unsigned;

Begin { Display Image }
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Put_Chars (ScreenDisplay,'+-----------------------+',Start_Row,Start_Column);
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
   SMG$Put_Chars (ScreenDisplay,'+-----------------------+',Start_Row+10,Start_Column);
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
   Fix_Image (Pic.Image);
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

Procedure Edit_Image (Var Image: Image_Type);

{ This procedure allows the user to edit the picture, IMAGE }

Var
  Answer: Char;

Begin { Edit Image }

   { Set up }

   CursorX:=1;  CursorY:=1;
   Fix_Image (Image);

   { Show the image and update }

   SMG$Begin_Display_Update (ScreenDisplay);
   Repeat
      Begin
         Display_Image (Image,4,1);
         SMG$Put_Chars (ScreenDisplay,
             '[RETURN] exits',16,1);
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice ([CHR(13),Up_Arrow,Down_Arrow,Left_Arrow,Right_Arrow,CHR(32)..CHR(127)]);
         Case Answer of
            CHR(13):  ;
            Left_Arrow:  Move_Left (CursorX,CursorY);
            Right_Arrow: Move_Right (CursorX,CursorY);
            Up_Arrow: Move_Up (CursorY);
            Down_Arrow: Move_Down (CursorY);

            { Delete or space }

            CHR(127),' ': Begin
                             Image[CursorX,CursorY]:=' ';
                             Move_Right (CursorX,CursorY);
                          End;

            { Otherwise it's a valid character to be entered }

            Otherwise    Begin
                            Image[CursorX,CursorY]:=Answer;
                            Move_Right (CursorX,CursorY);
                         End;
         End;
         If Answer<>CHR(13) then
            SMG$Begin_Display_Update (ScreenDisplay);
      End;
   Until Answer=CHR(13);
   CursorX:=0;   CursorY:=0;
End;  { Edit Image }

(******************************************************************************)

Function Coordinate_Used (Place: Coordinate): Boolean;

{ This function returns TRUE if a coordinate is anything
  better than (0,0) and FALSE otherwise }

Begin { Coordinate Used }
   Coordinate_Used:=(Place.X<>0) and (Place.Y<>0);
End;  { Coordinate Used }

(******************************************************************************)

Procedure Add_Eyes (Pic: Picture; Var Image: Image_Type);

{ This procedure tacks the bug eyes onto the image }

Begin { Add Eyes }
   If Coordinate_Used (Pic.Left_Eye) then Image[Pic.Left_Eye.X,Pic.Left_Eye.Y]:=Pic.Eye_Type;
   If Coordinate_Used (Pic.Right_Eye) then Image[Pic.Right_Eye.X,Pic.Right_Eye.Y]:=Pic.Eye_Type;
End;  { Add Eyes }

(******************************************************************************)

Procedure Display_Image_With_Eyes (Pic: Picture;  Start_Row, Start_Column: Integer:=1);

{ This procedure will display the image with bug-eyes at 1,1 }

Var
  X,Y: Integer;
  C: Unsigned;
  Image: Image_Type;

Begin { Display Image with Eyes }
   Image:=Pic.Image;
   Add_Eyes (Pic,Image);

   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Put_Chars (ScreenDisplay,'+-----------------------+',Start_Row,Start_Column);
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
   SMG$Put_Chars (ScreenDisplay,'+-----------------------+',Start_Row+10,Start_Column);
   SMG$End_Display_Update (ScreenDisplay);
End;  { Display Image with Eyes }

(******************************************************************************)

Procedure Get_Eye_Character (Var Eye_Type: Char);

{ This procedure gets the character to be used when the eyes bug out }

Var
   Answer: Char;

Begin { Get Eye Character }
   SMG$Put_Chars (ScreenDisplay,'Current eye character: '+Eye_Type,22,1);
   SMG$Put_Chars (ScreenDisplay,'Enter new character: ([RETURN] exits)',23,1);
   Answer:=Make_Choice([CHR(13),CHR(32)..CHR(126)]);
   If Answer<>CHR(13) then
      Eye_Type:=Answer;
End;  { Get Eye Character }

(******************************************************************************)

Procedure Get_Eye_Location (Var Spot: Coordinate; Image: Image_Type;  Eye: Char;
                            StartY,StartX: Integer:=-1);

{ This procedure will allow the user to place the bugged-out eye. }

Var
   Answer: Char;
   SpotX,SpotY: Integer;

Begin { Get Eye Location }
   Repeat
      Begin
         CursorX:=Spot.X;
         CursorY:=Spot.Y;
         SMG$Begin_Display_Update (ScreenDisplay);
         Display_Image (Image,4,40);
         If (CursorX>0) and (CursorY>0) then
            SMG$Put_Chars (ScreenDisplay,
                Eye
                +'',CursorY+StartY,CursorX+StartX,0,1);
         SMG$Put_Chars (ScreenDisplay,
             'X: '
             +String(CursorX,3),23,1);
         SMG$Put_Chars (ScreenDisplay,
             'Y: '
             +String(CursorY,3),24,1);
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice ([
             Up_Arrow,
             Down_Arrow,
             Left_Arrow,
             Right_Arrow,
             ' ']);
         SpotX:=Spot.X;  SpotY:=Spot.Y;
         Case Answer of
            Left_Arrow:  Move_Left (SpotX,SpotY);
            Right_Arrow:  Move_Right (SpotX,SpotY);
            Down_Arrow:  Move_Down (SpotY);
            Up_Arrow:  Move_Up (SpotY);
            ' ': ;
         End;
         Spot.X:=SpotX;  Spot.Y:=SpotY;
      End;
   Until Answer=' ';
End;  { Get Eye Location }

(******************************************************************************)

Procedure Eyes (Var Pic: Picture);

{ This procedure will allow the user to edit the bugging-eyes aspect of an image }

Var
   Answer: Char;

Begin { Eyes }
   Fix_Pic (Pic);
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         Display_Image_With_Eyes (Pic,4,40);
         SMG$Put_Chars (ScreenDisplay,
             'Edit which?', 20,1);
         SMG$Put_Chars (ScreenDisplay,
             '1) Bug-eye character',21,1);
         SMG$Put_Chars (ScreenDisplay,
             '2) Left bug-eye character',22,1);
         SMG$Put_Chars (ScreenDisplay,
             '3) Right bug-eye character',23,1);
         SMG$Put_Chars (ScreenDisplay,
             '<SPACE> exit',24,1);
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice (['1'..'3',' ']);
         SMG$Erase_Display (ScreenDisplay);
         Case Answer of
              ' ':  ;
              '1': Get_Eye_Character (Pic.Eye_Type);
              '2': Get_Eye_Location (Pic.Left_Eye,Pic.Image,Pic.Eye_Type,4,40);
              '3': Get_Eye_Location (Pic.Right_Eye,Pic.Image,Pic.Eye_Type,4,40);
         End;
      End;
   Until Answer=' ';
End;  { Eyes }

(******************************************************************************)

Procedure Edit_Picture (Var Pics: Pic_List; Picture_Number: Integer);

{ This procedure allows the user to edit the pictures }

Var
   Answer: Char;

Begin { Edit Picture }
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,
             'Edit picture #'
             +String(Picture_Number,2));
         SMG$Put_Line (ScreenDisplay,
             '------------ ---');
         SMG$Put_Line (ScreenDisplay,
             ' Edit 1=Image   2=Bug-eyes   <SPACE>=exit');
         Display_Image (Pics[Picture_Number].Image,4,1);
         Display_Image_With_Eyes (Pics[Picture_Number],4,40);
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice (['1','2',' ']);
         Case Answer of
             '1': Edit_Image (Pics[Picture_Number].Image);
             '2': Eyes (Pics[Picture_Number]);
             ' ': ;
         End
      End;
   Until Answer=' ';
End;  { Edit Picture }

(******************************************************************************)

[Global]Procedure Pic_Edit (Var Pics: Pic_List);

Var
  Response: Integer;

{ This procedure will edit the pictures used in the encounter and maze modules }

Begin { Pic Edit }
   CursorX:=0;  CursorY:=0;
   Repeat
      Begin
         Repeat
            Begin
               SMG$Begin_Display_Update (ScreenDisplay);
               SMG$Erase_Display (ScreenDisplay);
               SMG$Put_Line (ScreenDisplay,
                   'Monster image editor');
               SMG$Put_Chars (ScreenDisplay,
                  'Edit which image? (0-150, -1 exits) --->');
               SMG$End_Display_Update (ScreenDisplay);
               Response:=Get_Num(ScreenDisplay);
            End;
         Until (Response<=150) and (Response>-2);
         If Response<>-1 then
            Edit_Picture (Pics,Response);
      End;
   Until Response=-1;
End;  { Pic Edit }
End.  { Pic Edit }

[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL')]Module Messages;

{ This module allows the editing of the scenario messages. It is simply a
  full-screen line editor. }

Const
   Up_Arrow          = CHR(18);                Down_Arrow      = CHR(19);
   Tab               = CHR(9);

Var
   Inverse:                    Boolean;  { Should the current line be printed inverse? }
   Top,Bottom,Curs:            Integer;
   Done:                       Boolean;
   Answer:                     Char;
   Options:                    Char_Set;
   ScreenDisplay,Keyboard:     [External]Unsigned;
   Messages:                   Message_Group;


(******************************************************************************)
[External]Function Read_Messages: Message_Group;external;
[External]Procedure Save_Messages (Messages: Message_Group);external;
[External]Function Get_Num (Display: Unsigned): Integer;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): Char;External;
[External]Function String (Num: Integer; Len: Integer:=0): Line;External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
(******************************************************************************)

Function Y_Pos (Top,Curs: Integer): Integer;

{ This function returns the y position on the screen given the cursor location
   in the text and the top line number. }

Begin
   Y_Pos:=(Curs-Top)+3;
End;

(******************************************************************************)

Procedure Print_Out (L: Line);

Var
   Place: Integer;
   Num: Integer;
   T: Line;

Begin
  T:='';
  For Place:=1 to L.Length do
      Begin
         Num:=Ord(L.Body[Place]);
         If Num<32 then
            If Num=9 then
               T:='<=Tab==>'
            Else
               T:=T+'#'
         Else
            T:=T+CHR(Num);
      End;
  If Inverse then
      SMG$Put_Line (ScreenDisplay,Pad(T,' ',80),1,2)
  Else
      SMG$Put_Line (ScreenDisplay,T,1,0);
End;

(******************************************************************************)

Procedure Print_Messages (Top,Bottom,Curs: Integer);

Var
   Position: Integer;

Begin
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Set_Cursor_ABS (ScreenDisplay,3,1);
   For Position:=Top to Bottom do
      Begin
         If Position=Curs then Inverse:=True;
         Print_Out (Messages[Position]);
         If Position=Curs then Inverse:=False;
      End;
   If Bottom=999 then SMG$Erase_Display (ScreenDisplay,Bottom-Top+4);
   SMG$End_Display_Update (ScreenDisplay);
End;

(******************************************************************************)

Procedure Get_Replacement (Var Line_Text: Line; Curs,Top: Integer);

Begin
  SMG$Put_Chars (ScreenDisplay,'R',1,79,0,1);
  SMG$Set_Cursor_ABS (ScreenDisplay,Y_Pos(Top, Curs),1);
  Cursor;
  SMG$Read_String (Keyboard,Line_Text,Display_ID:=ScreenDisplay,prompt_string:=Line_Text,Rendition_Set:=SMG$M_REVERSE);
  No_Cursor;
End;

(******************************************************************************)

Procedure Jump (Var Top,Bottom,Curs: Integer);

Var
  Temp: Integer;

Begin
   Temp:=0;
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Put_Chars (ScreenDisplay,'J',1,79,0,1);
   SMG$Put_Chars (ScreenDisplay,'Jump to what line number? ('+String(Curs,3)+' is default)',22,1,1);
   SMG$End_Display_Update (ScreenDisplay);

   Temp:=Get_Num (ScreenDisplay);

   If (Temp>0) and (Temp<=999) then
      Begin
         Top:=Temp;
         Curs:=Temp;
         Bottom:=Min(Top+18,999); { TODO: Make constant for page size }
      End;

   SMG$Erase_Display (ScreenDisplay,22,1);
End;

(******************************************************************************)

Procedure Move_Down (Var Top,Bottom,Curs: Integer);

Begin
   Curs:=Curs+1;
   If Curs>Bottom then
      Begin
         Top:=Curs-1;
         Bottom:=Min(Top+18,999);
         Print_Messages (Top,Bottom,Curs);
      End;

   SMG$Begin_Display_Update (ScreenDisplay);

   SMG$Set_Cursor_ABS (ScreenDisplay,Y_Pos (Top,Curs-1),1);
   Print_Out (Messages[Curs-1]);

   SMG$Set_Cursor_ABS (ScreenDisplay,Y_Pos (Top,Curs),1);
   Inverse:=True;
   Print_Out (Messages[Curs]);
   Inverse:=False;

   SMG$End_Display_Update (ScreenDisplay);
End;

(******************************************************************************)

Procedure Move_Up (Var Top,Bottom,Curs: Integer);

Begin
   Curs:=Curs-1;
   If Curs>Bottom then
      Begin
         Bottom:=Curs+1;
         Top:=Max(Bottom-18,1);
         Print_Messages (Top,Bottom,Curs);
      End;

   SMG$Begin_Display_Update (ScreenDisplay);

   SMG$Set_Cursor_ABS (ScreenDisplay,Y_Pos (Top,Curs+1),1);
   Print_Out (Messages[Curs+1]);

   SMG$Set_Cursor_ABS (ScreenDisplay,Y_Pos (Top,Curs),1);
   Inverse:=True;
   Print_Out (Messages[Curs]);
   Inverse:=False;

   SMG$End_Display_Update (ScreenDisplay);
End;

(******************************************************************************)

Procedure Handle_Jump (Var Top,Bottom,Curs: Integer);

Begin
   Jump (Top,Bottom,Curs);
   SMG$Begin_Display_Update (ScreenDisplay);
   Print_Messages (Top,Bottom,Curs);
   SMG$End_Display_Update (ScreenDisplay);
End;

(******************************************************************************)

Procedure Replace_Line (Var Message: Line;  Var Top,Curs: Integer);

Begin
   Get_Replacement (Message,Curs,Top);
   SMG$Set_Cursor_ABS (ScreenDisplay,Y_Pos(Top,Curs),1);
   Inverse:=True;
   Print_Out (Message);
   Inverse:=False;
End;

(******************************************************************************)

[Global]Procedure Edit_Messages;

Const
   Page_Heading = '          Up-down arrows, "J" jumps, [RETURN] edits, <SPACE> quits ';

Begin
   Messages:=Read_Messages;
   Inverse:=False;  Curs:=1;  Top:=1;  Bottom:=19;  Done:=False;
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay);
   SMG$Put_Line (ScreenDisplay,Page_Heading,0,1);
   Print_Messages (Top,Bottom,Curs);
   SMG$End_Display_Update (ScreenDisplay);

   Repeat
      Begin
        SMG$Begin_Display_Update (ScreenDisplay);
        SMG$Put_Chars (ScreenDisplay,'M',1,79,0,1);
        SMG$Put_Chars (ScreenDisplay,String(Curs,3),1,1,0,1);
        SMG$Put_Chars (ScreenDisplay,String(Messages[Curs].Length,2),1,5,0,1);
        SMG$End_Display_Update (ScreenDisplay);

        Options:=[Up_Arrow,Down_Arrow,CHR(32),CHR(13),'J'];
        If (Curs=1) then
           Options:=Options-[Up_Arrow]
        Else if (Curs=999) then
           Options:=Options-[Down_Arrow];

        Answer:=Make_Choice (Options);

        Case Answer of
                   'J': Handle_Jump (Top,Bottom,Curs);
               CHR(13): Replace_Line (Messages[Curs],Top,Curs);
               CHR(32): Done:=True;
              Up_Arrow: Move_Up   (Top,Bottom,Curs);
            Down_Arrow: Move_Down (Top,Bottom,Curs);
        End;
      End;
   Until Done;
   Save_Messages (Messages);
End;
End.  { Messages }

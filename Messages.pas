[Inherit ('Types','SMGRTL')]Module Messages;

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

Procedure Print_Message (Top,Bottom,Curs: Integer);

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

{ TODO: Enter this code }

[Global]Procedure Edit_Messages;

Begin

{ TODO: Enter this code }

End;
End.  { Messages }

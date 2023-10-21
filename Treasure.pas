[Inherit ('Types','SMGRTL')]Module Edit_Treasure_Types;

Type
   Traps_Set = Set of Trap_Type;

Var
   ScreenDisplay: [External]Unsigned;
   Item_List: [External]List_of_Items;
   TrapName: [External]Array [Trap_Type] of Varying [20] of Char;
   Cat:      Array [1..5] of Packed Array [1..24] of char;

(******************************************************************************)
[External]Function String(Num: Integer; Len: Integer:=0): Line;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): Char;External;
[External]Function Get_Num (Display: Unsigned):Integer;External;
(******************************************************************************)

Procedure Home_Cursor;

Begin
   SMG$Home_Cursor (ScreenDisplay);
End;

Procedure Home;

Begin
   SMG$Erase_Display (ScreenDisplay);
   Home_Cursor;
End;

(******************************************************************************)

[Global]Procedure Edit_Treasures (Var Treasure: List_of_treasures);

Procedure Change_Treasure_Type (Number: Integer);

Var
        Loop:  Integer;
        Options: Char_Set;
        Answer: Char;
        Number1: Integer;
        T: Line;

(*----------------------------------------------------------------------------*)

Procedure Edit_Traps (Var Traps: Traps_Set);

Var
          Pos: Integer;
          Loop: Trap_Type;
          Temp: Trap_Type;
          TrapNum: Integer;
          Answer: Char;
          T: Line;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         Home;
         SMG$Put_Line (ScreenDisplay, 'The chest can have these traps:');
         Pos:=1;
         T:='';
         For Loop:=PoisonNeedle to Stunner do
                 If Loop in Traps then
                    Begin
                       T:=T+Pad(TrapName[Loop],' ',20);
                       If Pos/3<>Pos div 3 then
                          T:=T+'   '
                       Else
                          Begin
                             SMG$Put_Line (ScreenDisplay, T);
                             T:='';
                          End;
                       Pos:=Pos+1;
                   End;
         SMG$Put_Line (ScreenDisplay,T);

         SMG$Set_Cursor_ABS (ScreenDisplay,15,1);
         SMG$Put_Line (ScreenDisplay,'Change which trap?');
         Pos:=1;
         T:='';
         For Loop:=PoisonNeedle to Stunner do
            Begin
                T:=T+CHR(Ord(Loop)+64)+'  '+Pad(TrapName[Loop],' ',20);
                If Pos/3<>Pos div 3 then
                   T:=T+'   '
                Else
                   Begin
                      SMG$Put_Line (ScreenDisplay, T);
                      T:='';
                   End;
                Pos:=Pos+1;
            End;
         SMG$Put_Line (ScreenDisplay,T,0,0);
         SMG$End_Display_Update (ScreenDisplay);

         Answer:=Make_Choice(['A'..CHR(Ord(Stunner)+64),' ']);
         If Answer<>' ' then
            Begin
               TrapNum:=Ord(Answer)-64;
               Temp:=PoisonNeedle;
               While (Ord(Temp)<>TrapNum) do
                  Temp:=Succ(Temp);
               If Temp in Traps then
                  Traps:=Traps-[Temp]
               Else
                  Traps:=Traps+[Temp];
            End;
      End;
   Until Answer=' ';
End;

{ TODO: Enter this code }

Begin { Change_Treasure_Type }

{ TODO: Enter this code }

End;  { Change_Treasure_Type }

{ TODO: Enter this code }

Begin { Edit Treasures }

{ TODO: Enter this code }

End;  {Edit Treasures }
End.  { Edit Treasure Types }

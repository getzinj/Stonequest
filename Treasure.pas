(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types','SMGRTL')]Module Edit_Treasure_Types;

Type
   Traps_Set = Set of Trap_Type;

Var
   ScreenDisplay: [External]Unsigned;
   Item_List: [External]List_of_Items;
   TrapName: [External]Array [Trap_Type] of Varying [20] of Char;
   Cat:      Array [1..5] of Packed Array [1..24] of char;

Value
   Cat[1]:='Treasure Number';
   Cat[2]:='In a chest?';
   Cat[3]:='Possible Traps';
   Cat[4]:='Max. num of treasures';
   Cat[5]:='Treasures';

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
                       T:=T + Pad(TrapName[Loop],' ',20);
                       If Pos/3<>Pos div 3 then
                          T:=T+'   '
                       Else
                          Begin
                             SMG$Put_Line (ScreenDisplay, T);
                             T:='';
                          End;
                       Pos:=Pos + 1;
                   End;
         SMG$Put_Line (ScreenDisplay,T);

         SMG$Set_Cursor_ABS (ScreenDisplay,15,1);
         SMG$Put_Line (ScreenDisplay,'Change which trap?');
         Pos:=1;
         T:='';
         For Loop:=PoisonNeedle to Stunner do
            Begin
                T:=T + CHR(Ord(Loop)+64)+'  '+Pad(TrapName[Loop],' ',20);
                If Pos/3<>Pos div 3 then
                   T:=T+'   '
                Else
                   Begin
                      SMG$Put_Line (ScreenDisplay, T);
                      T:='';
                   End;
                Pos:=Pos + 1;
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

(*----------------------------------------------------------------------------*)

Procedure Edit_Cash (Var Treasure: Treasure_Record);

Var
   Answer: Char;
   Options: Char_Set;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         Home;
         SMG$Put_Line (ScreenDisplay,'A) Initial base: '+String(Treasure.Initial_Base));
         SMG$Put_Line (ScreenDisplay,'B) Initial random: '+String(Treasure.Initial_Random.X)+'D'+String(Treasure.Initial_Random.Y)+'+'+String(Treasure.Initial_Random.Z));
         SMG$Put_Line (ScreenDisplay,'C) Random multiplier: '+String(Treasure.Multiplier.X)+'D'+String(Treasure.Multiplier.Y)+'+'+String(Treasure.Multiplier.Z), 2);
         SMG$Put_Line (ScreenDisplay,'Which?',0);
         SMG$End_Display_Update (ScreenDisplay);

         Options:=['A','B','C',' '];
         Answer:=Make_Choice (Options);

         Case Answer of
            'A': Begin
                   SMG$Put_Chars (ScreenDisplay,'Enter base:',5,1);
                   Treasure.Initial_Base:=Get_Num (ScreenDisplay);
                 End;
            'B': Begin
                   SMG$Put_Chars (ScreenDisplay,'Enter X: ',5,1);
                   Treasure.Initial_Random.X:=Get_Num (ScreenDisplay);

                   SMG$Put_Chars (ScreenDisplay,'Enter Y: ',6,1);
                   Treasure.Initial_Random.Y:=Get_Num (ScreenDisplay);

                   SMG$Put_Chars (ScreenDisplay,'Enter Z: ',7,1);
                   Treasure.Initial_Random.Z:=Get_Num (ScreenDisplay);
                End;
            'C': Begin
                   SMG$Put_Chars (ScreenDisplay,'Enter X: ',5,1);
                   Treasure.Multiplier.X:=Get_Num (ScreenDisplay);

                   SMG$Put_Chars (ScreenDisplay,'Enter Y: ',6,1);
                   Treasure.Multiplier.Y:=Get_Num (ScreenDisplay);

                   SMG$Put_Chars (ScreenDisplay,'Enter Z: ',7,1);
                   Treasure.Multiplier.Z:=Get_Num (ScreenDisplay);
                End;
         End;
      End;
   Until Answer=' ';
End;

(*----------------------------------------------------------------------------*)

Procedure Edit_Item (Var Treasure: Treasure_Record);

Var
   Answer: Char;
   Options: Char_Set;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         Home;
         SMG$Put_Line (ScreenDisplay,'A) Base item: '+Item_List[Treasure.Item_Number.Z].True_Name);
         SMG$Put_Line (ScreenDisplay,'B) Random addition: '+String(Treasure.Item_Number.X)+'D'+String(Treasure.Item_Number.Y));
         SMG$Put_Line (ScreenDisplay,'C) Appear probability: '+String(Treasure.Appear_Probability)+'%',2);
         SMG$Put_Line (ScreenDisplay,'Which?',0);
         SMG$End_Display_Update (ScreenDisplay);

         Options:=['A','B','C',' '];
         Answer:=Make_Choice (Options);

         Case Answer of
            'A': Begin
                   SMG$Put_Chars (ScreenDisplay,'Enter the item number:',6,1);
                   Treasure.Item_Number.Z:=Get_Num (ScreenDisplay);
                 End;
            'B': Begin
                   SMG$Put_Chars (ScreenDisplay,'Enter X: ',6,1);
                   Treasure.Item_Number.X:=Get_Num (ScreenDisplay);

                   SMG$Put_Chars (ScreenDisplay,'Enter Y: ',7,1);
                   Treasure.Item_Number.Y:=Get_Num (ScreenDisplay);
                End;
            'C': Begin
                   SMG$Put_Chars (ScreenDisplay,'Enter probability: ',6,1);
                   Treasure.Appear_Probability:=Get_Num (ScreenDisplay);
                End;
         End;
      End;
   Until Answer=' ';
End;

(*----------------------------------------------------------------------------*)

Procedure Edit_Treasure (Var Treasure: Treasure_Record);

Var
   Options: Char_Set;
   Answer: Char;
   T: Line;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         Home;

         T:='A)  Kind: ';
         If Treasure.Kind=Cash_Given then
            T:=T+'Cash'
         Else
            T:=T+'Item';
         SMG$Put_Line (ScreenDisplay, T);

         T:='B)  ';
         If Treasure.Kind=Cash_Given then
            T:=T+'Enter Cash editor'
         Else
            T:=T+'Enter item editor';
         SMG$Put_Line (ScreenDisplay, T,2,0);

         SMG$Put_Line (ScreenDisplay,'Which?',0,0);
         SMG$End_Display_Update (ScreenDisplay);

         Options:=['A','B',' '];
         Answer:=Make_Choice (Options);

          Case Answer of
             'A': Begin
                     If Treasure.Kind=Cash_Given then
                        Begin
                           Treasure.Kind:=Item_Given;
                           Treasure.Range:=0;
                           Treasure.Item_Number.X:=0;
                           Treasure.Item_Number.Y:=0;
                           Treasure.Item_Number.Z:=0;
                        End
                     Else
                        Begin
                           Treasure.Kind:=Cash_Given;
                           Treasure.Initial_Random.X:=0;
                           Treasure.Initial_Random.Y:=0;
                           Treasure.Initial_Random.Z:=0;
                           Treasure.Multiplier.X:=0;
                           Treasure.Multiplier.Y:=0;
                           Treasure.Multiplier.Z:=0;
                           Treasure.Initial_Base:=0;
                        End;
                  End;
             'B': Begin
                     If Treasure.Kind=Cash_Given then
                        Edit_Cash (Treasure)
                     Else
                        Edit_Item (Treasure);
                  End;
          End;
      End;
   Until Answer=' ';
End;

(*----------------------------------------------------------------------------*)

Procedure Edit_Treasures (Var Treasure: List_of_TreasureType);

Var
   Number,Loop: Integer;
   T: Line;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         Home;
         SMG$Put_Line (ScreenDisplay,'Edit Treasures');
         SMG$Put_Line (ScreenDisplay,'---- ---------');
         For Loop:=1 to 7 do
            Begin
               T:=String(Loop,1)+') ';
               If Treasure[Loop].Kind=Cash_Given then
                  T:=T+'Gold'
               Else
                  T:=T+'Item';
               SMG$Put_Line (ScreenDisplay,T);
            End;
         SMG$End_Display_Update (ScreenDisplay);

         SMG$Put_Chars (ScreenDisplay,'Change which treasure? (0 exits)->',11,1);
         Number:=Get_Num (ScreenDisplay);

         If (Number<=7) and (Number>=1) then
            Edit_Treasure (Treasure[Number]);
      End;
   Until Number=0;
End;

(*----------------------------------------------------------------------------*)

Begin
   Loop:=0;
   Repeat
     Begin
        SMG$Begin_Display_Update (ScreenDisplay);
        Home;

        SMG$Put_Line (ScreenDisplay,'Treasure #'+String(Number,3));
        SMG$Put_Line (ScreenDisplay,'-------- ----');
        For Loop:=1 to 5 do
           Begin
              T:=CHR(Loop + 64)+'  '+Cat[Loop]+': ';
              Case Loop of
                 1: T:=T + String(Number);
                 2: If Treasure[Number].In_Chest then
                       T:=T+'Yes'
                    Else
                       T:=T+'No';
                 3: If Treasure[Number].Possible_Traps=[] then
                       T:=T+'None'
                    Else
                       T:=T+'Type ''C'' to edit';
                 4: If Treasure[Number].Max_No_Of_Treasures=0 then
                       T:=T+'None'
                    Else
                       T:=T + String(Treasure[Number].Max_No_of_Treasures);
                 5: If Treasure[Number].Max_No_Of_Treasures=0 then
                       T:=T+'None'
                    Else
                       T:=T+'Type ''E'' to edit';
              End;
              SMG$Put_Line (ScreenDisplay, T);
           End;
        SMG$Put_Line (ScreenDisplay,'',2);
        SMG$End_Display_Update (ScreenDisplay);

        Options:=['B','C','D','E',' '];
        Answer:=Make_Choice (Options);

        Case Ord(Answer)-64 of
             2: Treasure[Number].In_Chest:=Not Treasure[Number].In_Chest;
             3: Edit_Traps (Treasure[Number].Possible_Traps);
             4: Begin
                  SMG$Put_Chars (ScreenDisplay,'How many? ->',2,0,1);
                  Treasure[Number].Max_No_of_Treasures:=Get_Num (ScreenDisplay);
                End;
             5: Edit_Treasures (Treasure[Number].Treasure);
        End;
     End;
   Until Answer=' ';
End;

(******************************************************************************)

Procedure Edit_Treasure_Types;

Var
   Number: Integer;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         Home;
         SMG$Put_Line (ScreenDisplay,'        Edit treasure');
         SMG$Put_Line (ScreenDisplay,'150 is the table size. Edit which treasure?');
         SMG$End_Display_Update (ScreenDisplay);
         SMG$Put_Chars (ScreenDisplay,'(1-150, 0 exits) --->',3,1);
         Number:=Get_Num (ScreenDisplay);
         If (Number>0) and (Number<151) then
            Change_Treasure_Type (Number);
      End;
   Until Number=0;
End;

(*-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=*)

Begin
   Edit_Treasure_Types;
End;
End.  { Edit Treasure Types }

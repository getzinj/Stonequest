[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','STRRTL')]Module MazeSpecial;

Type
    Coordinate_Matrix = Array [1..6] of Integer;
    Place_Ptr  = ^Place_Node;
    Place_Node = Record
                    PosX,PosY: Horizontal_Type;
                    PosZ: Vertical_Type;
                    Next,Previous: Place_Ptr;
                 End;
    Place_Stack  = Record
                    Length: Integer;
                    Front,Rear: Place_Ptr;
                 End;

Var
   Game_Saved,Leave_Maze,Auto_Load,Auto_Save:       [External]Boolean;
   Rounds_Left:                                     [External]Array [Spell_Name] of Unsigned;
   Keyboard,CharacterDisplay,MessageDisplay,ViewDisplay,WinDisplay,Pasteboard:           [External]Unsigned;
   Plane_Name:                                      [External]Array [0..9] of Line;
   Item_List:                                       [External]List_of_Items;
   Direction:                                       [External]Direction_Type;
   Maze:                                            [External]Level;
   Messages:                                        [External]Message_Group;
   Minute_Counter:                                  [External]Real;
   PosX,PosY,PosZ:                                  [Byte,External]0..20;
   Places:                                          [External]Place_Stack;

(******************************************************************************)
[External]Function Compute_AC (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function Get_Level (Level_Number: Integer; Maze: Level; PosZ: Vertical_Type:=0): [Volatile]Level;External;
[External]Function Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '):Char;External;
[External]Function Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function Rendition_Set (Var T: Line): Unsigned;External;
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Procedure Change_Status (Var Character: Character_Type; Status: Status_Type; Var Changed: Boolean);External;
[External]Procedure Cursor;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Draw_View (Direction: Direction_Type;  New_Spot: Boolean; Member: Party_Type; Current_Party_Size: Party_Size_Type);External;
[External]Procedure Insert_Place (PosX,PosY: Horizontal_Type; PosZ: Vertical_Type; Var Stack: Place_Stack);External;
[External]Procedure Move_Backward (Direction: Direction_Type;  Var New_Spot: Boolean);External;
[External]Procedure No_Cursor;External;
[External]Procedure Party_Box (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                             Var Leave_Maze: Boolean);External;
[External]Function Pick_Character_Number (Party_Size: Integer; Current_Party_Size: Integer:=0;  Time_Out: Integer:=-1;
                                          Time_Out_Char: Char:='0'):[Volatile]Integer;External;
[External]Procedure Remove_Nodes (Var Stack: Place_Stack);External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Procedure Show_Image (Number: Pic_Type; Var Display: Unsigned);External;
[External]Procedure Spells_Box (Rounds_Left: Spell_Duration_List);External;
[External]Procedure Unpaste_All;External;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Procedure Run_Encounter_Aux (Monster_Number: Integer;  Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                             Party_Size: Integer;  Var Alarm_Off: Boolean; Location: Area_Type:=Corridor;
                                   NoMagic: Boolean:=False; Var Time_Delay: Integer);External;
[External]Function Choose_Monster (Table: Encounter_Table; Area: Area_Type; Var Encountered: Boolean): Integer;External;
[External]Procedure Update_Status (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                               Var Leave_Maze: Boolean; Rounds_Left: Spell_Duration_List);External;
[External]Procedure Fix_Compass (Direction: Direction_Type;  Rounds_Left: Spell_Duration_List);External;
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;
(******************************************************************************)

[Global]Function Show_Special (Member: [Unsafe]Party_Type:=0; Current_Party_Size: Integer:=0): Boolean;

Var
   Person,Psi_Chance: Integer;
   Temp: Boolean;

Begin { Show Special }
   PSI_Chance:=0;
   Temp:=(Rounds_Left[DetS]>0);
   If Current_Party_Size>0 then
      Begin
         For Person:=1 to Current_Party_Size do
            If Member[Person].Psionics then
               Psi_Chance:=Psi_Chance+Member[Person].DetectTrap; { TODO: Should check if character is alive and conscious }
         Temp:=Temp or Made_Roll (PSI_Chance);
      End;
   Show_Special:=Temp;
End;  { Show Special }

(******************************************************************************)

Procedure Print_Message (Start: Integer);

Var
   Lines_Printed: Integer;
   Curr: Integer;
   LineP: Integer;
   R: Unsigned;
   L: Line;

Begin
   Lines_Printed:=0;
   Curr:=Start;  LineP:=1;
   If Start<>-1 then
      Repeat
         Begin
            SMG$Begin_Display_Update (MessageDisplay);
            SMG$Erase_Display (MessageDisplay);
            Repeat
               Begin
                  If (Messages[Curr]<>'~') and (Lines_Printed<200) then
                     Begin
                        L:=Messages[Curr];
                        R:=Rendition_Set (L);
                        SMG$Put_Line (MessageDisplay,Messages[Curr],1,R,Wrap_Flag:=SMG$M_WRAP_WORD);
                        Curr:=Curr+1;   LineP:=LineP+1;  Lines_Printed:=Lines_Printed+1;
                     End;
               End;
            Until (LineP=5) or (Messages[Curr]='~');
            If Messages[Curr]<>'~' then
               Begin
                  LineP:=1;
                  SMG$Label_Border (MessageDisplay,'[More]',SMG$K_BOTTOM);
                  Make_Choice ([CHR(13)]);
               End
         End;
      Until Messages[Curr]='~';

   SMG$Label_Border (MessageDisplay,'');
End;

(******************************************************************************)

Procedure Wait_For_Return;

Begin
  SMG$Label_Border (MessageDisplay,' Press [RETURN] ',SMG$K_BOTTOM);

  Make_Choice ([CHR(13)]);

  SMG$Begin_Display_Update (MessageDisplay);
  SMG$Label_Border (MessageDisplay,'');
  SMG$Erase_Display (MessageDisplay);
  SMG$End_Display_Update (MessageDisplay);
End;

(******************************************************************************)

Procedure Print_Message_With_Return (Message_No: Integer);

Begin
   If Message_No<>-1 then
      Begin
         Print_Message (Message_No);
         Wait_For_Return;
      End;
End;

(******************************************************************************)

Procedure Inflict_Damage (Damage: Die_Type;  Direction: Direction_Type;  Var Member: Party_Type;
                          Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;  New_Spot: Boolean);

Var
   Person: Integer;

Begin
   Draw_View (Direction,New_Spot,Member,Current_Party_Size);

   SMG$Begin_Display_Update (CharacterDisplay);
   For Person:=1 to Current_Party_Size do
      Begin
         Member[Person].Curr_HP:=Member[Person].Curr_HP-Random_Number(Damage);
         If Member[Person].Curr_HP<1 then
            Begin
               Member[Person].Status:=Dead;
               Member[Person].Curr_HP:=0;
            End;
         If Member[Person].Status=Asleep then
            Member[Person].Status:=Healthy;

         Member[Person].Regenerates:=Regenerates (Member[Person],PosZ);
         Member[Person].Armor_Class:=Compute_AC (Member[Person],PosZ);
         Member[Person].Attack.Berserk:=False;
      End;
   Party_Box (Member,Current_Party_Size,Party_Size,Leave_Maze);
   SMG$End_Display_Update (CharacterDisplay);
End;

(******************************************************************************)

Procedure Avernus_Fireball (Direction: Direction_Type; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                            Party_Size: Integer;  New_Spot: Boolean);

Var
   Temp: Die_Type;

Begin
   SMG$Put_Line (MessageDisplay,'There is a huge explosion close to the party!');
   SMG$Ring_Bell (MessageDisplay);

   Temp.X:=Roll_Die(6)+1;   Temp.Y:=6;   Temp.Z:=0;

   Inflict_Damage (Temp,Direction,Member,Current_Party_Size,Party_Size,New_Spot);
   Delay(2);
End;

(******************************************************************************)

Procedure Stygia_Fireball (Direction: Direction_Type; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                            Party_Size: Integer;  New_Spot: Boolean);

Var
   Temp: Die_Type;

Begin
   SMG$Put_Line (MessageDisplay,'There is an explosion of cold fire close to the party!');
   SMG$Ring_Bell (MessageDisplay);

   Temp.X:=2;   Temp.Y:=6;   Temp.Z:=0;

   Inflict_Damage (Temp,Direction,Member,Current_Party_Size,Party_Size,New_Spot);
   Delay(2);
End;

(******************************************************************************)

Procedure Nessus_Effects (Direction: Direction_Type; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                            Party_Size: Integer;  New_Spot: Boolean);

Var
   Temp: Die_Type;

Begin
   Case Roll_Die(3) of
      1: SMG$Put_Line (MessageDisplay,'There is an explosion of cold fire close to the party!');
      2: SMG$Put_Line (MessageDisplay,'There is an explosion of fire close to the party!');
      3: SMG$Put_Line (MessageDisplay,'A wall of flames shoots close to the party!');
   End;
   SMG$Ring_Bell (MessageDisplay);

   Temp.X:=9;   Temp.Y:=8;   Temp.Z:=0;

   Inflict_Damage (Temp,Direction,Member,Current_Party_Size,Party_Size,New_Spot);
   Delay(2);
End;

(******************************************************************************)

Procedure Caina_Cold (Direction: Direction_Type; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                            Party_Size: Integer;  New_Spot: Boolean);

Var
   Temp: Die_Type;

Begin
   Case Roll_Die(10) of
      1: SMG$Put_Line (MessageDisplay,'Brrrrrrr!');
      2: SMG$Put_Line (MessageDisplay,'It''s freezing here!');
      3: SMG$Put_Line (MessageDisplay,'Thine teeth are chattering!');
      4: SMG$Put_Line (MessageDisplay,'It''s very cold!');
      5: SMG$Put_Line (MessageDisplay,'Thou''re losing feeling in thine extremities!');
      6: SMG$Put_Line (MessageDisplay,'Snow drifts across thine face!');
      7: SMG$Put_Line (MessageDisplay,'Thou are starting to feel sleepy!');
      8: SMG$Put_Line (MessageDisplay,'The wind whistles by thine ears!');
      9: SMG$Put_Line (MessageDisplay,'Thy fingers hurt!');
     10: SMG$Put_Line (MessageDisplay,'Thine faces feel raw!');
   End;
   SMG$Ring_Bell (MessageDisplay);

   Temp.X:=Roll_Die(2);   Temp.Y:=3;   Temp.Z:=0;

   Inflict_Damage (Temp,Direction,Member,Current_Party_Size,Party_Size,New_Spot);
   Delay(2);
End;

(******************************************************************************)

Procedure Minauros_Poison (Var Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Var
   Chara: Integer;
   Dummy: Boolean;

[External]Function Made_Save (Character: Character_Type;  Attack: Attack_Type): [Volatile]Boolean;External;

Begin
   Chara:=Roll_Die (Current_Party_Size);
   If Not Made_Save (Member[Chara],Poison) then
      Change_Status (Member[Chara],Poisoned,Dummy);
End;

(******************************************************************************)

Procedure Hell_Effects (Direction: Direction_Type;  Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                        Party_Size: Integer;  New_Spot: Boolean;  Hell_Level: Integer);

Begin
   Case Hell_Level of
        1: If ((Round(Minute_Counter) mod 6)=0) and Made_Roll(15) then
               Avernus_Fireball(Direction,Member,Current_Party_Size,Party_Size,New_Spot);
        2: ;
        3: If ((Round(Minute_Counter) mod 10)=0) then
               Minauros_Poison(Member,Current_Party_Size);
        4: ;
        5: If ((Round(Minute_Counter) mod 6)=0) then
               Stygia_Fireball(Direction,Member,Current_Party_Size,Party_Size,New_Spot);
        6: ;
        7: ;
        8: Caina_Cold (Direction,Member,Current_Party_Size,Party_Size,New_Spot);
        9: If ((Round(Minute_Counter) mod 10)=0) then
               Nessus_Effects(Direction,Member,Current_Party_Size,Party_Size,New_Spot);
   End;
End;

(******************************************************************************)

Procedure A_Pit (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                 Damage: Die_Type; New_Spot: Boolean);

Begin
  Inflict_Damage (Damage,Direction,Member,Current_Party_Size,Party_Size,New_Spot);
  SMG$Put_Line (MessageDisplay,'A pit!');
  Ring_Bell (MessageDisplay);
End;

(******************************************************************************)

Procedure Random_Rotate (Var Maze: Level; PosX,PosY: Horizontal_Type;  Var direction: Direction_Type;  New_Spot: Boolean;
                              Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Var
   D: Integer;

Begin
   D:=Roll_Die (4);
   Case D of
      1: Direction:=North;
      2: Direction:=South;
      3: Direction:=East;
      4: Direction:=West;
   End;
   Draw_View (Direction,New_Spot,Member,Current_Party_Size);
End;

(******************************************************************************)

Function Character_With_Room (Member: Party_Type;  Current_Party_Size: Integer): Integer;

Var
   Person: Integer;

Begin
  Person:=0;
  Repeat
     Person:=Person+1
  Until (Person=Current_Party_Size) or (Member[Person].No_of_Items<8);
  If Member[Person].No_of_Items>7 then Person:=8;
  Character_With_Room:=Person;
End;

(******************************************************************************)

Function CharacterCanUseItem(Character: Character_Type; ItemNumber: Integer): Boolean;

Begin
  return (Character.Class in Item_List[ItemNumber].Usable_By)
     or (Character.PreviousClass in Item_List[ItemNumber].Usable_By)
End;

(******************************************************************************)

Procedure Give_Item_if_Room (Var Character: Character_Type; Item_No: Integer);

{ This procedure is only to be called if character has room }

Var
   Num: Integer;

Begin
   Character.No_of_Items:=-Character.No_of_Items+1;
   Num:=Character.No_of_Items;

   With Character.Item[Num] do
      Begin
         Equipted:=False;
         Ident:=False;
         Cursed:= False;
         Usable:=CharacterCanUseItem(Character, Item_No);
         Item_num:=Item_Num;
      End;
End;

(******************************************************************************)

Procedure Give_Item (Item_No: Integer; Var Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Var
   Person: Integer;

Begin
   Person:=Character_with_Room (Member,Current_Party_Size);

   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);

   If Person<=Current_Party_Size then
      Begin
         Give_Item_if_Room (Member[Person],Item_No);

         SMG$Put_Line (MessageDisplay,Member[Person].Name+' found an item!',0);
      End
   Else
      SMG$Put_Line (MessageDisplay,'An item is found, but it soon vanishes as nobody has room for it!',0,Wrap_Flag:=SMG$M_WRAP_WORD);

   SMG$End_Display_Update (MessageDisplay);

   Delay (2);

   SMG$Erase_Display (MessageDisplay);
End;

(******************************************************************************)

Function Party_has_Item (Member: Party_Type; Party_Size,SearchItem: Integer; Var Person,Slot: Integer): Boolean;

Var
   Found: boolean;

Begin
  Person:=0;  Found:=False;
  Repeat
     Begin
        Person:=Person+1;
        Slot:=0;
        If Member[Person].No_of_Items>0 then
           Repeat
              Begin
                Slot:=Slot+1;
                Found:=(Member[Person].Item[Slot].Item_Num=SearchItem);
              End;
           Until Found or (Slot=Member[Person].No_of_Items);
     End;
  Until Found or (Person=Party_Size);
  Party_Has_Item:=Found;
End;

(******************************************************************************)

Procedure Message_and_Item_Trade (Message: Integer; Traded_With,Traded_For: Integer;  Var Member: Party_Type;
                                   Current_Party_Size: Party_Size_Type);

Var
   Person,Slot: Integer;
   Found: Boolean;

Begin
   Print_Message_with_Return (Message);

   Found:=Party_has_Item (Member,Current_Party_Size,Traded_With,Person,Slot);

   If Found then
      Begin
         With Member[Person].Item[Slot] do
            Begin
               Item_Num:=Traded_For;
               Ident:=False;
               Cursed:=False;
               Equipted:=False;
               Usable:=CharacterCanUseItem(Member[Person], Traded_For);
            End;

         SMG$Begin_Display_Update (MessageDisplay);
         SMG$Erase_Display (MessageDisplay);

         SMG$Put_Line (MessageDisplay,Member[Person].Name+' traded for an item!',0);
         SMG$End_Display_Update (MessageDisplay);
      End;
End;

(******************************************************************************)

Procedure Message_and_Item (Message,Item: Integer;  Var Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Begin
   Print_Message_with_Return (Message);
   Give_Item (Item,Member,Current_Party_Size);
End;

(******************************************************************************)

Function Get_Answer: Line;

Var
   Temp: Line;

Begin
   SMG$Set_Cursor_ABS (MessageDisplay,2,1);
   Cursor;
   SMG$Read_String (Keyboard,Temp,Display_ID:=Messagedisplay,Prompt_String:='Answer?  --->');
   No_Cursor;

   STR$Upcase (Temp,Temp);
   If Temp.Length>2 then
     If SubStr(Temp,1,2)='A ' then
        Temp:=Substr(Temp,3,Temp.Length-2);
   If Temp.Length>3 then
     If SubStr(Temp,1,3)='AN ' then
        TEMP:=Substr(Temp,4,Temp.Length-3);
   If Temp.Length>4 then
     If SubStr(Temp,1,4)='THE ' then
        TEMP:=Substr(Temp,5,Temp.Length-4);
   Get_Answer:=Temp;
End;

(******************************************************************************)

Procedure Ask_Riddle (Question,Answer_line: Integer;  Var New_Spot: Boolean);

Var
   Answer: Line;

Begin
   Print_Message (Question);
   Wait_for_Return;

   Answer:=Get_Answer;

   If STR$Case_Blind_Compare(Answer,Messages[answer_line])=0 then
      Begin
         SMG$Put_Chars (MessageDisplay,'Right!',3,1);
         Delay(1);
         SMG$Erase_Display (MessageDisplay);
      End
   Else
      Begin
         SMG$Put_Chars (MessageDisplay,'Wrong!',3,1);
         Delay(1);
         Move_Backward (Direction,New_Spot);
      End;
End;

(******************************************************************************)

Procedure Pay_Fee (Message,Cost: Integer;  Var New_Spot: Boolean; Var Member: Party_Type;  Party_Size: Integer;
                                Current_Party_Size: Party_Size_Type);

Var
   Number: Integer;

Begin
   Print_Message (Message);
   Wait_For_Return;

   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);

   SMG$Put_Chars (Messagedisplay,'Who will pay?',2,1);
   SMG$End_Display_Update (MessageDisplay);

   Number:=Pick_Character_Number (Party_Size,Current_Party_Size);

   If Number=0 then
      Move_Backward (Direction,New_Spot)
   Else if Member[Number].Gold<Cost then
      Begin
         SMG$Put_Chars (MessageDisplay,'Thou canst not pay!',5,41);

         Move_Backward (Direction,New_Spot);
      End
   Else
      Begin
         SMG$Put_Chars (MessageDisplay,'Thanks!',5,41);

         Member[Number].Gold:=Max(Member[Number].Gold-Cost, 0);

         Delay (1);

         SMG$Erase_Display (MessageDisplay);
      End;
End;

(******************************************************************************)

Procedure Teleported_Into_Rock (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                                   Var Leave_Maze: Boolean);

Var
   Person: Integer;

Begin
  For Person:=1 to Party_Size do
     Member[Person].Status:=Deleted;

  Party_Box (Member,Current_Party_Size,Party_Size,Leave_Maze);

  SMG$Begin_Display_Update (MessageDisplay);
  SMG$Erase_Display (MessageDisplay);

  SMG$Put_Line (MessageDisplay,'Thou teleported into rock!!!',0,1);
  SMG$End_Display_Update (MessageDisplay);

  Delay (3);
End;

(******************************************************************************)

Procedure Need_Item_to_Pass (Item_no,Approved,Denied: Integer;
                             Var New_Spot: Boolean;
                                 Member: Party_Type;
                                 Current_Party_Size,Party_Size: Integer);

Var
   Person,Item: Integer;
   Found: Boolean;

Begin
   Person:=0;  Item:=0;
   Found:=Party_Has_Item (Member,Party_Size,Item_No,Person,Item);
   If (Not Found) then
      Begin
         Print_Message_With_Return (Denied);
         Move_Backward (Direction,New_Spot);
      End
   Else
      Print_Message_With_Return (Approved);
End;

(******************************************************************************)

Procedure Message_and_Teleport_to_Kyrn (message_No: Integer);

Begin
   Print_Message_with_Return (Message_No);
   Leave_Maze:=True;
End;

(******************************************************************************)

Procedure Initiate_Characters (Var Member: Party_Type;  Party_Size: Integer);

Var
   Person: Integer;

Begin
   For Person:=1 to Party_Size do
      Begin
         Member[Person].No_of_Items:=0;
         Member[Person].Item:=Zero;
         Member[Person].Gold:=Round (1/4 * member[Person].Gold);
         Member[Person].Experience:=Member[Person].Experience + 50000;
         Member[Person].Scenarios_Won[0]:=True; { TODO: Make this a set }
         Member[Person].Armor_Class:=Compute_AC (Member[Person],PosZ);
         Member[Person].Regenerates:=Regenerates (Member[Person],PosZ);
      End;
End;

(******************************************************************************)

[Global]Procedure Handle_Completed_Quest (Var Member: Party_Type;  Party_Size: Integer);

Const
   Win_Text = 61;

Var
  T: Line;
  Linenum: Integer;
  R: Unsigned;

Begin
   Linenum:=Win_Text;
   Initiate_Characters (Member,Party_Size);
   SMG$Erase_Display (WinDisplay);

   While Messages[LineNum]<>'~' do
      Begin
         T:=Messages[Linenum];
         R:=Rendition_Set (T);
         SMG$Put_Line (WinDisplay,T,1,R,Wrap_Flag:=SMG$M_WRAP_WORD);
         Linenum:=LineNum+1;
      End;

   SMG$Put_Chars (WinDisplay,'Press any key to continue',21,25,1,1);
   SMG$Paste_Virtual_Display (WinDisplay,Pasteboard,2,2);

   Wait_Key;

   Unpaste_All;

   SMG$Unpaste_Virtual_Display (WinDisplay,Pasteboard);
   SMG$Erase_Display (WinDisplay);
End;

(******************************************************************************)

Procedure Stair_Case (Var Maze: Level; Var PosX,PosY:  Horizontal_Type;  Var PosZ: Vertical_Type;  Special: Special_Type;
                      Var New_Spot: Boolean; Var Previous_Spot: Area_Type;  Member: Party_Type;
                      Current_Party_Size: Party_Size_Type);

Const
  Down_Staircase_Number = 37;
  Up_Staircase_Number = 38;

Var
  E: Varying[4] of Char;
  Answer: Char;

[External]Function Yes_or_No (Time_Out: Integer:=-1; Time_out_Char: Char:=' '): [Volatile]Char;External;

Begin
  If Special.Pointer3>PosZ then
     Begin
        E:='down';
        Show_Image (Down_Staircase_Number,ViewDisplay);
     End
  Else
     Begin
        E:='up';
        Show_Image (Up_Staircase_Number,ViewDisplay);
     End;

  SMG$Begin_Display_Update (MessageDisplay);
  SMG$Erase_Display (MessageDisplay);

  SMG$Put_Line (MessageDisplay,'A staircase going '+E+'. Wilt thou go '+E+' them? (Y/N)',Wrap_Flag:=SMG$M_WRAP_WORD);
  SMG$End_Display_Update (MessageDisplay);

  Answer:=Yes_or_No;

  SMG$Erase_Display (MessageDisplay);

  If Answer='Y' then
     Begin
        Previous_Spot:=Maze.Room[PosX,PosY].Kind;
        PosX:=Special.Pointer1;  PosY:=Special.Pointer2;
        New_Spot:=True;
        Maze:=Get_Level (Special.Pointer3,Maze,PosZ);
        PosZ:=Special.Pointer3;

        Remove_Nodes (Places);
     End;

  If PosZ>0 then
     Draw_View (Direction,New_Spot,Member,Current_Party_Size);
End;

(******************************************************************************)

Procedure Cliff_to_Hell (Var Maze: Level; Var PosX,PosY: Horizontal_Type; Var PosZ: Vertical_Type;  Special: Special_Type;
                         Var New_Spot: Boolean; Var Previous_Spot: Area_Type; Var Member: Party_Type;
                         Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer);

Const
   Cliff_Picture_Number = 67;

Var
   Temp: Die_Type;
   Answer: Char;

[External]Function Yes_or_No (Time_Out: Integer:=-1; Time_out_Char: Char:=' '): [Volatile]Char;External;

Begin
   Show_Image (Cliff_Picture_Number,ViewDisplay);

   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);

   SMG$Put_Line (MessageDisplay,'A 1/2 mile drop to the next plane of Hell.  Wilst thou jump off the cliff?',Wrap_Flag:=SMG$M_WRAP_WORD);
   SMG$End_Display_Update (MessageDisplay);

   Answer:=Yes_or_No;

   SMG$Erase_Display (MessageDisplay);

   If Answer='Y' then
      Begin
         Previous_Spot:=Maze.Room[PosX,PosY].Kind;
         PosX:=Special.Pointer1; PosY:=Special.Pointer2;
         New_Spot:=True;
         PosZ:=Special.Pointer3;

         If Rounds_Left[Levi]<1 then
            Begin
               Temp.X:=20;  Temp.Y:=6;  Temp.Z:=0;

               Inflict_Damage(Temp,Direction,Member,Current_Party_Size,Party_Size,New_Spot);
            End
         Else
            Begin
               SMG$Put_Line (MessageDisplay,'Thou gently drift down to the surface ...',Wrap_Flag:=SMG$M_WRAP_WORD);
               Delay(2);
            End;

         If PosZ>10 then
            SMG$Put_Line (MessageDisplay,'Welcome to '+Plane_Name[PosZ-10]+'!',Wrap_Flag:=SMG$M_WRAP_WORD);

         Remove_Nodes (Places);
      End;

   If PosZ>0 then Draw_View (Direction,New_Spot,Member,Current_Party_Size);
End;

(******************************************************************************)

Procedure An_Elevator (Top,Bottom: Integer; Var Maze: Level;  Var PosX,PosY: Horizontal_Type;
                       Var PosZ: Vertical_Type;  Var New_Spot: Boolean;  Var Previous_Spot: Area_Type;  Member: Party_Type;
                       Current_Party_Size: Party_Size_Type);

Const
   Elevator_Picture_Number = 36;

Var
   Number_of_Buttons,Button: Integer;
   TopC: Char;
   Answer: Char;

Begin
   Show_Image (Elevator_Picture_Number,ViewDisplay);

   Number_of_Buttons:=(Bottom - Top)+1;

   TopC:=CHR(Number_of_Buttons+64);

   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Line (MessageDisplay,'In this room there are buttons labeled "A" to "'+ TopC + '".');
   SMG$Put_Line (MessageDisplay,'Which button wilt thou press?  [Return exits]');

   Answer:=Make_Choice(['A'..TopC,CHR(13)]);

   SMG$Erase_Display (MessageDisplay);

   If Answer<>CHR(13) then
      Begin
         Previous_Spot:=Maze.Room[PosX,PosY].Kind;
         Button:=Ord(Answer)-64;
         Maze:=Get_Level (Top + Button - 1,Maze,PosZ);
         PosZ:=Top + Button - 1;
         New_Spot:=True;
         If PosZ>0 then
            Begin
              SMG$Erase_Display(ViewDisplay);
              Delay(1);
            End;
         Remove_Nodes (Places); { TODO: Should only do this if they choose a DIFFERENT floor from the one they're on! }
      End
   Else
      Draw_View (Direction,New_Spot,Member,Current_Party_Size);
End;

(******************************************************************************)

Procedure Special_Encounter (MonsterNo: Integer; Var New_Spot: Boolean; Var Member: Party_Type;
                             Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;  Var Time_Delay: Integer);

Var
   No_Magic,Dummy,Alarm_Off: Boolean;
   Area: Area_Type;

Begin
   Draw_View (Direction,New_Spot,Member,Current_Party_Size);
   No_Magic:=(Maze.Special_Table[Maze.Room[PosX,PosY].Contents].Special=AntiMagic);
   Area:=Room;

   Repeat
      Begin
         Alarm_Off:=False;
         Run_Encounter_Aux (MonsterNo,Member,Current_Party_Size,Party_Size,Alarm_Off,Area,No_Magic,Time_Delay);
         If Alarm_Off then
            Begin
               MonsterNo:=Choose_Monster (Maze.Monsters,Area,Dummy);
               Area:=Corridor;
            End;
      End;
   Until Not Alarm_Off;

   Maze.Room[PosX,PosY].Contents:=0;

   New_Spot:=True;

   Update_Status (Member,Current_Party_Size,Party_Size,Leave_Maze,Rounds_Left);
   Fix_Compass (Direction,Rounds_Left);
End;

(******************************************************************************)

Procedure Message_And_Encounter (MessageNo,MonsterNo: Integer; Var New_Spot: Boolean; Var Member: Party_Type;
                                         Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;  Var Time_Delay: Integer);

Begin
  Draw_View (Direction,New_Spot,Member,Current_Party_Size);
  If MessageNo>-1 then
     Begin
        Print_Message (MessageNo);
        Wait_for_Return;
     End;
  Special_Encounter (MonsterNo,New_Spot,Member,Current_Party_Size,Party_Size,Time_Delay);
End;

(******************************************************************************)

Procedure Encounter_SQ_Creator (Var Maze: Level; Var PosX,PosY: Horizontal_Type; Var PosZ: Vertical_Type;
                                Var New_Spot: Boolean; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                                Party_Size: Integer; Var Time_Delay: Integer);

Const
   Creator_Picture_Number = 66;
   Creators_Question = 204;
   Encounter_Number = 243;

Var
   Answer: Char;

Begin
   Show_Image (Creator_Picture_Number,ViewDisplay);

   Print_Message (Creators_Question);

   Wait_For_Return;

   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);

   SMG$Put_Line (MessageDisplay,'Answer? (Y/N)');

   Answer:=Make_Choice (['Y','N']);

   If Answer='N' then
      Special_Encounter (Encounter_Number,New_Spot,Member,Current_Party_Size,Party_Size,Time_Delay)
   Else
      Begin
         SMG$Put_Line (MessageDisplay,'Good!');
         Delay (2);
      End;

   SMG$Erase_Display (MessageDisplay);
   Draw_View (Direction,New_Spot,Member,Current_Party_Size);
End;

(******************************************************************************)

Procedure Message_and_Picture (MessageNo,PictureNo: Integer; New_Spot: Boolean; Member: Party_Type;
                               Current_Party_Size: Party_Size_Type);

Begin
   Show_Image (PictureNo,ViewDisplay);
   Print_Message (MessageNo);
   Wait_for_Return;
   Draw_View (Direction,New_Spot,Member,Current_Party_Size);
End;

(******************************************************************************)

Procedure Character_Finds_Item (Var Character: Character_Type; Item_No: Integer);

Var
   Num: Integer;

Begin
   Character.No_of_Items:=Character.No_of_Items+1;
   Num:=Character.No_of_Items;
   With Character.Item[Num] do
      Begin
         Equipted:=False;
         Ident:=False;
         Cursed:=False;
         Usable:=CharacterCanUseItem(Character,Item_No);
         Item_Num:=Item_No;
      End;

   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Line (MessageDisplay,Character.Name+' found an item!',0);
   SMG$End_Display_Update (MessageDisplay);
End;

(******************************************************************************)

{ $$+

Procedure Encounter_UJB (Var Member: Party_Type;  Current_Party_Size: Integer);

Const
  UJB_Image = 74;
  UJB_Message = 259;

Var
   Person: Integer;

Begin
  Show_Image (UJB_Image,ViewDisplay);
  Print_Message (UJB_Message);

  If Current_Party_Size>0 then
     For Person:=1 to Current_Party_Size do
        If Member[Person].Status = Healthy then
           Begin
              Member[Person].Status:=OnProbation;
              Member[Person].Abilities[6]:=Max(Member[Person].Abilities[6]-2,3);
           End;
End;  -$$}

(******************************************************************************)

Procedure Message_and_Hidden_Item (    Message_No,Item_No: Integer;
                                           Var Maze: Level;
                                           Var PosX,PosY: Horizontal_Type;
                                           Var New_Spot: Boolean;
                                           Var Member: Party_Type;
                                           Var Current_Party_Size: Party_Size_Type;
                                               Party_Size: Integer;
                                           Var Time_Delay: Integer);

Var
   Person: Integer;

Begin
   Print_Message (Message_No);

   Wait_For_Return;

   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Chars (MessageDisplay,'Who will search it?',2,1);

   Person:=Pick_Character_Number (Party_Size,Current_Party_Size);

   If Person>0 then
      If Item_No < 0 then
        Special_Encounter (ABS(Item_No),New_Spot,Member,Current_Party_Size,Party_Size,Time_Delay)
      Else If Member[Person].No_of_Items<8 then
         Character_Finds_Item (Member[Person],Item_No)
   Else
      SMG$Erase_Display (MessageDisplay);
End;

(******************************************************************************)

Procedure A_Chute (Special: Special_Type;  Var New_Spot: Boolean; Var Maze: Level;  Var PosX,PosY: Horizontal_Type;
                   Var PosZ: Vertical_Type; Var Previous_Spot: Area_Type;  Member: Party_Type;
                   Current_Party_Size: Integer);

Const
   Chute_Picture_Number = 35;

Var
   Go_Down: Boolean;

[External]Function Yes_or_No (Time_Out: Integer:=-1; Time_out_Char: Char:=' '): [Volatile]Char;External;

Begin
   Go_Down:=True;
   Show_Image (Chute_Picture_Number,ViewDisplay);

   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Line (MessageDisplay,'A chute!');

   If Rounds_Left[Levi]>0 then
      Begin
         SMG$Put_Line (MessageDisplay,'Dost thou wish to go down it? (Y/N)');
         SMG$End_Display_Update (MessageDisplay);

         Go_Down:=(Yes_or_No='Y');
      End
   Else
      SMG$End_Display_Update (MessageDisplay);

   SMG$Erase_Display(MessageDisplay);

   If Go_Down then
      Begin
         Delay(2);

         New_Spot:=True;
         Previous_Spot:=Maze.Room[PosX,PosY].Kind;

         Maze:=Get_Level (Special.Pointer3,Maze,PosZ);

         PosX:=Special.Pointer1;   PosY:=Special.Pointer2;  PosZ:=Special.Pointer3;

         Remove_Nodes (Places);
      End;

   Draw_View (Direction,New_Spot,Member,Current_Party_Size);
End;

(******************************************************************************)

[Global]Function Game_Won (Member: Party_Type; Party_Size: Integer): Boolean;

Const
  Maleficent_Stone_Item_Number = 116;

Var
  Person,Item: Integer;
  Found: Boolean;

Begin
  Found:=Party_Has_Item (Member,Party_Size,Maleficent_Stone_Item_Number,Person,Item);
  Game_Won:=Found and Not (Auto_Save);
End;

(******************************************************************************)
(********************************* Special Areas ******************************)
(******************************************************************************)

Procedure Magic_Darkness (Maze: Level);

Begin
   Rounds_Left[Lght]:=0;
   Rounds_Left[CoLi]:=0;
   Spells_Box (Rounds_Left);
   SMG$Erase_Display (ViewDisplay);
End;

(******************************************************************************)

Procedure Random_Score_Change (Var Score: Ability_Score);

Var
  TempScore: Integer;

Begin
  TempScore:=Score;
  If Made_Roll(49) and (Score>3) then
     TempScore:=Min(TempScore+Roll_Die(4),25)
  Else
     TempScore:=Max(TempScore-Roll_Die(4),3);

  Score:=TempScore;
End;

(******************************************************************************)

Procedure Print_Change (Character: Character_Type; ScoreNum: Integer);

Var
   AbilName: [External]Array [1..7] of Packed Array [1..12] of char;

Begin
  SMG$Put_Chars (MessageDisplay,Character.Name+'''s '+AbilName[ScoreNum]);
  SMG$Put_Line (MessageDisplay,' is now a '+String(Character.Abilities[ScoreNum])+'!');
  Delay(1);
End;

(******************************************************************************)

Procedure Enter_Pool (PoolNum: Integer; Var Character: Character_Type);
{ $4 }
Begin
   Case poolNum of
      1..7: Begin
              Random_Score_Change (Character.Abilities[PoolNum]);
              Print_Change (Character,PoolNum);
            End;
      Otherwise ;
   End;
End;

(******************************************************************************)

Procedure Message_and_Pool (MessageNo,PoolNo: Integer; Var Maze: Level; Var PosX,PosY: Horizontal_Type;
                            Direction: Direction_Type; Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                            Party_Size: Integer; Var New_Spot: Boolean);

Const
   Pool_Image_Number = 30;

Var
   Number: Integer;

Begin
   Print_Message_With_Return (MessageNo);
   SMG$Erase_Display (MessageDisplay);

   Show_Image (Pool_Image_Number,ViewDisplay);
   Repeat
      Begin
         SMG$Erase_Display (MessageDisplay);
         SMG$Put_Chars (MessageDisplay,'A pool!  Who will enter? ([RETURN] exists)',2,1);

         Number:=Pick_Character_Number (Party_Size);

         SMG$Erase_Display (MessageDisplay);

         If Number=0 then
            Move_Backward (Direction,New_Spot)
         Else
            Enter_Pool (PoolNo,Member[Number]);
      End;
   Until (Number=0);

   Draw_View (Direction,New_Spot,Member,Current_Party_Size);
End;

(******************************************************************************)

Procedure Special_Feature (Var Maze: Level; Var PosX,PosY: Horizontal_Type;
                           Var PosZ: Vertical_Type; Var Direction: Direction_Type;
                           Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                               Special: Special_Type;  Var Rounds_Left: Spell_Duration_List;  Var New_Spot: Boolean;
                           Var Time_Delay: Integer);

Var
   P1,P2,P3: Integer;

Begin
   Draw_View (Direction,New_Spot,Member,Current_Party_Size);
   P1:=Special.Pointer1;  P2:=Special.Pointer2;  P3:=Special.Pointer3;

   Case Special.Feature of
       NothingSpecial: ;
                  Msg: Print_Message (P1);
       Msg_Item_Given: Message_and_Item (P1,P2,Member,Current_Party_Size);
             Msg_Pool: Message_and_Pool (P1,P2,Maze,PosX,PosY,Direction,Member,Current_Party_Size,Party_Size,New_Spot);
      Msg_Hidden_Item: Message_and_Hidden_Item (P1,P2,Maze,PosX,PosY,New_Spot,Member,Current_Party_Size,Party_Size,Time_Delay);
        Msg_Need_Item: Need_Item_to_Pass (P1,P2,P3,New_Spot,Member,Current_Party_Size,Party_Size);
         Msg_Lower_AC: Rounds_Left[DiPr]:=MaxInt;
         Msg_Raise_AC: Rounds_Left[DiPr]:=0;
      Msg_Goto_Castle: Message_and_Teleport_to_Kyrn (P1);
        Msg_Encounter: Message_and_Encounter (P1,P2,New_Spot, Member,Current_party_Size,Party_Size,Time_Delay);
               Riddle: Ask_Riddle (P1,P2,New_Spot);
                  Fee: Pay_Fee (P1,P2,New_Spot,Member,Party_Size,Current_Party_Size);
       Msg_Trade_Item: Message_and_Item_Trade (P1,P2,P3,Member,Current_Party_Size);
          Msg_Picture: Message_and_Picture (P1,P2,New_Spot,Member,Current_Party_Size);
              Unknown: Case P1 of
                           1: Encounter_SQ_Creator (Maze,PosX,PosY,PosZ,New_Spot,Member,Current_Party_Size,Party_Size,Time_Delay);
                         { 2: Encounter_UJB (Member,Current_Party_Size); }
                           Otherwise ;
                       End;
   End;
End;

(******************************************************************************)

Procedure Check_Special (Special: Special_Type;  Var New_Spot: Boolean; Var Member: Party_Type;
                         Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                         Var Previous_Spot: Area_Type;  Var Time_Delay: Integer);

Var
   Temp: Die_Type;
   P1,P2,P3: Integer;

Begin
   If PosZ>10 then
      Hell_Effects (Direction,Member,Current_Party_Size,Party_Size,New_Spot,PosZ-10);

   P1:=Special.Pointer1;  P2:=Special.Pointer2;  P3:=Special.Pointer3;

   Case Special.Special of
             Nothing: Draw_View (Direction,New_Spot,Member,Current_Party_Size);
              Stairs: Stair_Case (Maze,PosX,PosY,PosZ,Special,New_Spot,Previous_Spot,Member,Current_Party_Size);
              Cliff:  Cliff_to_Hell (Maze,PosX,PosY,PosZ,Special,New_Spot,Previous_Spot,Member,Current_Party_size,Party_Size);
                Pit:  If Rounds_Left[Levi]<1 then
                         Begin
                            Temp.X:=P1;  Temp.Y:=P2;  Temp.Z:=P3;
                            A_Pit (Member,Current_Party_Size,Party_Size,Temp,New_Spot);
                         End;
               Chute: A_Chute (Special,New_Spot,Maze,PosX,PosY,PosZ,Previous_Spot,Member,Current_Party_Size);
              Rotate: Random_Rotate (Maze,PosX,PosY,Direction,New_Spot,Member,Current_Party_Size);
            Darkness: Magic_Darkness (Maze);
            Teleport: Begin
                         PosX:=P1; PosY:=P2;
                         Draw_View (Direction,New_Spot,Member,Current_Party_Size);
                         New_Spot:=True;
                         Remove_Nodes (Places);
                      End;
              Damage: Begin
                         Temp.X:=P1;  Temp.Y:=P2;  Temp.Z:=P3;
                         Inflict_Damage (Temp,Direction,Member,Current_Party_Size,Party_Size,New_Spot);
                      End;
            Elevator: An_Elevator (P1,P2,Maze,PosX,PosY,PosZ,New_Spot,Previous_Spot,Member,Current_Party_Size);
                Rock: Teleported_into_Rock (Member,Current_Party_Size,Party_Size,Leave_Maze);
           Antimagic: Rounds_Left:=Zero;
           SPFeature: Special_Feature (Maze,PosX,PosY,PosZ,Direction,Member,Current_Party_Size,Party_Size,Special,Rounds_Left,New_Spot,Time_Delay);
        An_Encounter: Special_Encounter (P1,New_Spot,Member,Current_Party_Size,Party_Size,Time_Delay);
   End;
   If Special.Special<>Nothing then
      Remove_Nodes (Places)
   Else
      Insert_Place (PosX,PosY,PosZ,Places);
End;

(******************************************************************************)

[Global]Procedure Handle_Room_Special (Var New_Spot: Boolean; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                                           Party_Size: Integer;  Var Leave_Maze: Boolean;  Var Previous_Spot: Area_Type;
                                       Var Time_Delay: Integer);

Var
   Special: Special_Type;

Begin
   Special:=Maze.Special_Table[Maze.Room[PosX,PosY].Contents];
   While New_Spot and Not(Leave_Maze) do
      Begin
         New_Spot:=False;
         If (PosZ>0) and Not (Leave_Maze) then
            Check_Special (Special,New_Spot,Member,Current_Party_Size,Party_Size,Previous_Spot,Time_Delay);

         If PosZ>0 then
            Special:=Maze.Special_Table[Maze.Room[PosX,PosY].Contents];
      End;
   New_Spot:=False;
End;
End.

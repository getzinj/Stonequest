[Inherit ('Types','LIBRTL','SMGRTL','STRRTL')]Module PrintCharacter;

Const
    Success = '* * * Success! * * *';
    Failure = '* * * Failure * * *';
    Done_It = '* * * Done! * * *'

    Up_Arrow         = CHR(18);            Down_Arrow         = CHR(19);
    Left_Arrow       = CHR(20);            Right_Arrow        = CHR(21);
    ZeroOrd=ORD('0');

    Cler_Spell = 1;                        Wiz_Spell  = 2;

Type
   Spell_List_Type = Set of Spell_Name;
   Spell_List      = Packed Array [1..9] of Spell_List_Type;

   ItemSet         = ^ItemNode;
   ItemNode        = Record
                        Identified: Boolean;  { Is the item identified? }
                        Item_Num: Integer;    { Which item is it? }
                        Position: 1..8;       { Where is it held? }
                        Next_Item: ItemSet;   { The other items... }
                     End;
   Choice_Array    = Array [Item_Type] of ItemSet;

Var
   No_Magic:     Boolean;
   Camp_Spells:  Set of Spell_Name;
   SpellDisplay: Unsigned;
   ScreenDisplay,keyboard,pastebaord,campdisplay,optionsdisplay,characterdisplay: [External]Unsigned;
   CommandsDisplay,spellsdisplay,messagedisplay,monsterdisplay,viewdisplay,GraveDisplay: [External]Unsigned;

   Rounds_Left:                 [External]Array [Spell_Name] of Unsigned;
   Maze:                        [External]Level;
   Direction:                   [External]Direction_Type;
   Location:                    [External]Place_Type;
   Spell:                       [External]Array [Spell_Name] of Varying [4] of Char;
   PosX,PosY,PosZ:              [Byte,External]0..20;
   AbilName:                    [External]Array [1..7] of Packed Array [1..12] of char;
   Item_List:                   [External]List_of_Items;
   WizSpells,ClerSpells:        [External]Spell_List;
   Item_Name:                   [External]Array [Item_Type] of Varying [7] of char;

{ TODO: Enter this code }
(******************************************************************************)

Procedure Print_Experience (Character: Character_Type);

Begin { Print Experience }
   If Character.Age>0 then
      Begin
         SMG$Put_Chars (ScreenDisplay,
             'Experience: ');
         SMG$Put_Chars(ScreenDisplay,
             String(Trunc(Character.Experience),12));
      End;
   SMG$Put_Line (ScreenDisplay,'');
End;  { Print Experience }

(******************************************************************************)

Procedure Print_Level_And_Age (Character: Character_Type);

Begin { Print Level and Age }
  If Character.Age>0 then
     Begin
        SMG$Put_Chars (ScreenDisplay,
            'Level: ');
        SMG$Put_Chars (ScreenDisplay,
            String(Character.Level,3));
        If Character.PreviousClass<>NoClass then
           SMG$Put_Chars (ScreenDisplay,
               '/'
               +'String(Character.Previous_Lvl,3))
        Else
           SMG$Put_Chars (ScreenDisplay,
               '    ');
        SMG$Put_Chars (ScreenDisplay,
            '           Age: ');
        SMG$Put_Chars (ScreenDisplay,
            String(Trunc(Character.Age/365),3));
     End;
  SMG$Put_Line (ScreenDisplay,'');
End;  { Print Level and Age }

(******************************************************************************)

Procedure Print_Hit_Points_and_AC (Character: Character_Type);

Begin { Print Hit Points and Armor Class }
   If Character.Age>0 then
      Begin
         SMG$Put_Chars (ScreenDisplay,
             'Hit Points: ');
         SMG$Put_Chars (ScreenDisplay,
             String(Character.Curr_HP,5)
             +'/'
             +String(Character.Max_HP,5));
         SMG$Put_Chars (ScreenDisplay,
             '  Armor Class: ');
         SMG$Put_Cars (ScreenDisplay,String(10-Character.Armor_Class,3));
      End;
   SMG$Put_Line (ScreenDisplay, '');
End;  { Print Hit Points and Armor Class }

(******************************************************************************)

Procedure Print_Abilities_and_Statistics (Character: Character_Type);

Var: Ability: Integer;

Begin { Print Abilities and Statistics }
  For Ability:=1 to 7 do
      Begin
         SMG$Put_Chars (ScreenDisplay,
             AbilName[Ability]
             +': '
             +String(Character.Abilities[Ability],2));
         SMG$Put_Cars (ScreenDisplay,
             '           ');
         Case Ability of
            1: Print_Gold (Character);
            2: Print_Experience (Character);
            3,6: SMG$Put_Line (ScreenDisplay,'');
            4: Print_Level_and_Age (Character);
            5: Print_Hit_Points_and_AC (Character);
            7: Print_Status (Character);
         End;
      End;
End;  { Print Abilities and Statistics }

(******************************************************************************)

Procedure Print_Top (Character: Character_Type);

Begin { Print Top }
  SMG$Begin_Display_Update (ScreenDisplay);
  SMG$Home_Cursor (ScreenDisplay);
  Print_Top_Line (Character);
  Print_Abilities_and_Statistics (Character);
  SMG$End_Display_Update (ScreenDisplay);
End;  { Print Top }

{ TODO: Enter this code }

(******************************************************************************)

Procedure Character_Fully_Made (Var Character: Character_Type;  Var Leave_Maze: Boolean;  Var Answer: Char;
                                    Direction: Direction_Type;  Automatic: Boolean;  Var Party: Party_Type;
                                Var Party_Size: Integer);

{ This procedure is called at the tail end of PRINT_CHARACTER. It prints the bottom hjalf of the character record, and allows player
  options }

Var
   Choices: Char_Set;

Begin { Character fully made }
   { TODO: Enter this code }
End;  { Character fully made }

(******************************************************************************)

[Global]Procedure Print_Character (Var Party: Party_Type;  Party_Size: Integer;  Var Character: Character_Type;
                                   Var Leave_Maze: Boolean;  Automatic: Boolean:=False);

Var
   Answer: Char;

Begin { Print Character }
  Answer:=' ';
  Initialize;                 { Initialize displays and global variables }
  Repeat
     Begin { Repeat }
        SMG$Erase_Display (ScreenDisplay);
        Print_Top (Character);       { Print the top half of the character's info }
        SMG$Put_Line (ScreenDisplay,'');
        If Not Automatic then Character_Fully_Made (Character,Leave_Maze,Answer,Direction,Automatic,Party,Party_Size)
        Else SMG$End_Pasteboard_Update (Pasteboard);
     End;  { Reoeat }
  Until (Answer='L') or Automatic or Leave_Maze;
End;  { Print Character }
End.  { Print Character }

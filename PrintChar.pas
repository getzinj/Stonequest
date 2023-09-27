[Inherit ('Types','LIBRTL','SMGRTL','STRRTL')]Module PrintCharacter;

Const
    Success = '* * * Success! * * *';
    Failure = '* * * Failure * * *';
    Done_It = '* * * Done! * * *';

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
   ScreenDisplay,keyboard,pasteboard,campdisplay,optionsdisplay,characterdisplay: [External]Unsigned;
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

(******************************************************************************)
{ TODO: Enter this code }
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
{ TODO: Enter this code }
(******************************************************************************)
{ TODO: Enter this code }

Procedure Initialize;

Begin { Initialize }
   Camp_Spells:=[AnDe,Crlt,Lght,CrPs,CrSe,CoLi,CrVs,CrCr,Raze,heal,Ress,WoRe,PaHe,Loct,LtId,BgId,DuBl,Tele,Rein,DiPr,HgSh,Comp,CrPa,
                 UnCu,Levi,ReFe,DetS];
   No_Magic:=False;
   If PosZ > 0 then No_Magic:=(Maze.Special_Table[Maze.Room[PosX,PosY].Contents].Special=AntiMagic);
End;  { Initialize }

{ TODO: Enter this code }
(******************************************************************************)

Function Scenarios_Won (P: Int_Set): Integer;

Var
   Temp,Loop: Integer;

Begin { Scenarios Won }
   Temp:=0;
   For Loop:=0 to 999 do
      If P[Loop] then Temp:=Temp+1;
   Scenarios_Won:=Temp;
End;  { Scenarios Won }

(******************************************************************************)


Function Print_Wins (Character: Character_Type): Line;

{ Indicates how many scenarios this character has beaten }

Var
   Num,Loop: Integer;
   T: Line;

Begin { Print Wins }
   T:='';
   Num:=Scenarios_Won (Character.Scenarios_Won);
   If Num>8 then
      Begin
         T:='';
         For Loop:=1 to Num-8 do
             T:=T+'*';
      End;
   Print_Wins:=T;
End;  { Print Wins }

(******************************************************************************)

Procedure Print_Top_Line (Character: Character_Type);

Var
   ClassName:      [External]Array [Class_Type] of Varying [13] of char;
   AlignName:      [External]Array [Align_Type] of Packed Array [1..7] of char;
   RaceName:       [External]Array [Race_Type] of Packed Array [1..12] of char;
   SexName:        [External]Array [Sex_Type] of Packed Array [1..11] of char;

Begin { Print Top Line }
   SMG$Put_Chars (ScreenDisplay,
       'Name: '
       +Pad(Character.Name,' ',21));
   If Character.Sex=NoSex then
      SMG$Put_Chars (ScreenDisplay,
          ' ')
   Else
      SMG$Put_Chars (ScreenDisplay,
          SexName[Character.Sex][1]
          +'-');
   If Character.Race=NoRace then
      SMG$Put_Chars (ScreenDisplay,
          '  ')
   Else
      SMG$Put_Chars (screenDisplay,
          RaceName[Character.Race]
          +' ');
   If Character.Alignment=NoAlign then
      SMG$Put_Chars (ScreenDisplay,
          '  ')
   Else
      SMG$Put_Chars (ScreenDisplay,
          AlignName[Character.Alignment][1]
          +'-');
   If Character.Class<>NoClass then
      Begin
         SMG$Put_Chars (ScreenDisplay,
             ClassName[Character.Class] );
         If Character.PreviousClass<>Noclass then
            SMG$Put_Chars (ScreenDisplay,
                '/'+
                ClassName[Character.PreviousClass] )
      End;
   If Character.Psionics then
      Begin
         SMG$Put_Chars (ScreenDisplay,
             '  (');
         If Character.DetectTrap<>0 then
            SMG$Put_Chars (ScreenDisplay,
                'T');
         If Character.DetectSecret<>0 then
            SMG$Put_Chars (ScreenDisplay,
                'S');
         If Character.Regenerate<>0 then
            SMG$Put_Chars (ScreenDisplay,
                'R');
         SMG$Put_Chars (ScreenDisplay,
               ')');
         SMG$Put_Line (ScreenDisplay,
             '');
      End;
      SMG$Put_Line (ScreenDisplay,
          '');
      Case Scenarios_Won (Character.Scenarios_Won) of
         0:        SMG$Put_Line (ScreenDisplay,
                       '');
         1:        SMG$Put_Line (ScreenDisplay,
                       'Rank: Private');
         2:        SMG$Put_Line (ScreenDisplay,
                       'Rank: Corporal');
         3:        SMG$Put_Line (ScreenDisplay,
                       'Rank: Sargent');
         4:        SMG$Put_Line (ScreenDisplay,
                       'Rank: Lieutenant');
         5:        SMG$Put_Line (ScreenDisplay,
                       'Rank: Captain');
         6:        SMG$Put_Line (ScreenDisplay,
                       'Rank: Major');
         7:        SMG$Put_Line (ScreenDisplay,
                       'Rank: Lt. Colonel');
         8:        SMG$Put_Line (ScreenDisplay,
                       'Rank: Colonel');
         Otherwise SMG$Put_Line (ScreenDisplay,
                       'Rank: General ('
                       +Print_Wins(Character)
                       +')');
      End;
End;  { Print Top Line }

(******************************************************************************)

Procedure Print_Gold (Character: Character_Type);

Begin { Print Gold }
   If Character.Age>0 then
      Begin
         SMG$Put_Chars (ScreenDisplay,
             'Gold:      ');
         SMG$Put_Chars (ScreenDisplay,
             String(Character.Gold,12));
      End;
   SMG$Put_Line (ScreenDisplay,
       '');
End;  { Print Gold }

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
               +String(Character.Previous_Lvl,3))
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
         SMG$Put_Chars (ScreenDisplay,String(10-Character.Armor_Class,3));
      End;
   SMG$Put_Line (ScreenDisplay, '');
End;  { Print Hit Points and Armor Class }

(******************************************************************************)

Procedure Print_Status (Character: Character_Type);

Var
   StatusName: [External]Array [Status_Type] of Varying [14] of char;

Begin { Print Status }
   If Character.Age>0 then
      SMG$Put_Chars(ScreenDisplay,
          'Status:  '
          +StatusName[Character.Status]);
End;  { Print Status }

(******************************************************************************)

Procedure Print_Abilities_and_Statistics (Character: Character_Type);

Var
   Ability: Integer;

Begin { Print Abilities and Statistics }
  For Ability:=1 to 7 do
      Begin
         SMG$Put_Chars (ScreenDisplay,
             AbilName[Ability]
             +': '
             +String(Character.Abilities[Ability],2));
         SMG$Put_Chars (ScreenDisplay,
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

Procedure Print_The_Rest (Character: Character_Type; Var Choices: Char_Set;  Party: Party_Type;  Party_Size: Integer);

Begin { Print the Rest }
   Print_Spell_Points (Character);                      { Print out the remaining spell points }
   Print_Equipment (Character);                         { Print out the equipment list }
   Show_Options (Character,Choices,Party,Party_Size);   { Show the player's options }
Ehd;  { Print the Rest }

(******************************************************************************)

Procedure Character_Fully_Made (Var Character: Character_Type;  Var Leave_Maze: Boolean;  Var Answer: Char;
                                    Direction: Direction_Type;  Automatic: Boolean;  Var Party: Party_Type;
                                Var Party_Size: Integer);

{ This procedure is called at the tail end of PRINT_CHARACTER. It prints the bottom hjalf of the character record, and allows player
  options }

Var
   Choices: Char_Set;

Begin { Character fully made }
   Print_The_Rest (Character,Choices,Party,Party_Size);
   if Answer=' '' then
      SMG$End_Pasteboard_Update(Pasteboard)              { End updating from main }
   Else
      SMG$End_Display_Update (ScreenDisplay);

          { End updating from this procedure }

   Answer:=Make_Choice (Choices);                           { Get the option }
   Case Answer of
      'I': Identify_Object (Character);                                        { Bards can identify objects }
      'U': Use_Item (Character,Leave_Maze,Direction,Party,Party_Size);         { Cast a spell from an item }
      'T': Trade_Stuff (Character,Party,Party_Size);                           { Trade money and items within the party }
      'E': Equip_Character (Character);                                        { Determine which equip. is used }
      'D': Drop_Item (Character);                                              { Drop an item }
      'R': Print_Books (Character);                                            { Print what spells are known }
      'S': Cast_Camp_Spell (Character,Leave_Maze,Direction,Party,Party_Size);  { Case a spell }
      'L': ;                                                                   { Leave }
   End;

       { Then begin updating for the next pass }

   If Not((Answer='L') or Automatic or Leave_Maze) then SMG$Begin_Display_Update (ScreenDisplay);l
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
     End;  { Repeat }
  Until (Answer='L') or Automatic or Leave_Maze;
End;  { Print Character }
End.  { Print Character }

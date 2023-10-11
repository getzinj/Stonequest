[Inherit ('SYS$LIBRARY:STARLET','Types','LIBRTL','SMGRTL','STRRTL')]Module PrintCharacter;

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
[External]Function Spell_Duration (Spell: Spell_Name; Caster_Level: Integer):Integer;External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Procedure Special_Occurance (Var Character: Character_Type; Number: Integer);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Function Get_Level (Level_Number: Integer; Maze: Level; PosZ: Vertical_Type:=0): [Volatile]Level;External;
[External]Procedure Change_Score (Var Character: Character_Type; Score_Num, Inc: Integer);External;
[External]Procedure No_Cursor;External;
[External]Procedure Cursor;External;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
[External]Function Make_Choice (Choices: Char_Set;  Time_Out:  Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Function Zero_Through_Six (Var Number: Integer; Time_Out: Integer:=-1;
    Time_Out_Char: Char:='0'): Char;External;
[External]Procedure Race_Adjustments (Var Character: Character_Type; Race: Race_Type);External;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Procedure Get_Num (Var Number: Integer; Display: Unsigned);External;
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  Compute_AC (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function  Regenerates (Character: Character_Type, Posz: Integer:=0):Integer;external;
[External]Function Alive (Character: Character_Type): Boolean;External;
[External]Procedure Find_Spell_Group (Spell: Spell_Name;  Character: Character_Type;  Var Class,Level: Integer);External;
[External]Function Caster_Level (Cls: Integer; Character: Character_Type): Integer;External;
[External]Procedure Cast_Camp_Spell (Var Character: Character_Type; Var Leave_Maze: Boolean;  Direction: Direction_Type;
                                     Var Party: Party_Type;  Var Party_Size: Integer);External;
[External]Procedure Handle_Spell (Var Character: Character_Type; Spell: Spell_Name;  Class,Spell_Level: Integer;  Var Leave_Maze: Boolean;
                                  Direction: Direction_Type;  Var Party: Party_Type;  Var Party_Size: Integer;  Item_Spell: Boolean:=False);External;

(******************************************************************************)

Function Can_Use (Character: Character_Type; Stats: Equipment_Type): Boolean;

Var
   Temp: Boolean;
   Item: Item_Record;

Begin { Can Use }
  Item:=Item_List[Stats.Item_Num];
  Temp:=Stats.Equipted or (Item.kind=Scroll);
  Temp:=Temp and ((Item.Spell_Cast<>NoSp) or (Item.Special_Occurance_No>0));
  Temp:=Temp and ((Item.Alignment=NoAlign) or (Item.Alignment=Character.Alignment));
  Temp:=Temp and ((Character.Class in Item.Usable_By) or (Character.PreviousClass in Item.Usable_By));
  Can_Use:=Temp;
End;  { Can Use }

(******************************************************************************)

Function Can_Identify (Character: Character_Type): Boolean;

Begin { Can Identify }
  Can_Identify:=((Character.Class=Bard) or (Character.PreviousClass=Bard)) and (Character.No_of_Items>0);
End;  { Can Identify }

(******************************************************************************)

Function Can_Trade (Character: Character_Type;  Party_Size: Integer): Boolean;

Begin { Can Trade }
  Can_Trade:=(Party_Size > 1) and ((Character.No_Of_Items>0) or (Character.Gold>0));
End;  { Can Trade }

(******************************************************************************)

Procedure Initialize;

Begin { Initialize }
   Camp_Spells:=[AnDe,Crlt,Lght,CrPs,CrSe,CoLi,CrVs,CrCr,Raze,heal,Ress,WoRe,PaHe,Loct,LtId,BgId,DuBl,Tele,Rein,DiPr,HgSh,Comp,CrPa,
                 UnCu,Levi,ReFe,DetS];
   No_Magic:=False;
   If PosZ > 0 then No_Magic:=(Maze.Special_Table[Maze.Room[PosX,PosY].Contents].Special=AntiMagic);
End;  { Initialize }

(******************************************************************************)

Function Center_Text (Txt: Line;  Line_Length: Integer:=80): Integer;

Var Half: Integer;
    Indent: Integer;

Begin { Center Text }
   Indent:=Txt.Length div 2;
   Half:=Line_Length Div 2;
   Center_Text:=Half-Indent;
End;  { Center Text }

(******************************************************************************)

Procedure Select_Camp_Spell (Var SpellChosen: Spell_Name);

Var
  SpellName: Line;
  Location,Loop: Spell_Name;
  Long_Spell: [External]Array [Spell_Name] of Varying[25] of Char;

Begin { Select Camp Spell }
   Location:=NoSp;
   SMG$Set_Cursor_ABS (ScreenDisplay,20,1);
   Cursor;
   SMG$Read_String (Keyboard,SpellName,Display_ID:=ScreenDisplay,
       prompt_string:='--->');
   No_Cursor;
   If SpellName.Length<4 then SpellName:=Pad(SpellName,' ',4);
   For Loop:=CrLt to DetS do
       If (STR$Case_Blind_Compare(Spell[Loop]+'',SpellName)=0) or
          (STR$Case_Blind_Compare(Long_Spell[Loop]+'',SpellName)=0) then
          Location:=Loop;
   SpellChosen:=Location;
   SMG$Erase_Line (ScreenDisplay,20);
End;  { Select Camp Spell }

(******************************************************************************)

Procedure Handle_Party_Spell (Caster_Level: Integer; Spell: Spell_Name; Var Party: Party_Type; Party_Size: Integer);

Var
  Add: Integer;
  Position: Integer;

Begin
   Case Spell of
        DiPr: Add:=2;
        HgSh: Add:=4;
   End;
   Rounds_Left[Spell]:=Rounds_Left[Spell]+Spell_Duration (Spell,Caster_Level);
   For Position:=1 to Party_Size do
      Party[Position].Armor_Class:=Party[Position].Armor_Class-Add;
   SMG$Put_Chars (ScreenDisplay,Done_It,23,32);
End;

(******************************************************************************)

Procedure Print_Item (Character: Character_Type; Position: Integer);

Var
   Item: Item_Record;
   Temp: Equipment_Type;

Begin
  If Position Mod 2=1 then SMG$Erase_Line(ScreenDisplay);
  SMG$Put_Chars (ScreenDisplay,
      String(Position,1)
      +')');
      If Position<=Character.No_of_Items then
         Begin
            Temp:=Character.Item[Position];
            Item:=Item_List[Temp.Item_num];
            If (Temp.Equipted) and (Temp.Cursed) then
               SMG$Put_Chars (ScreenDisplay,
                   '-')
            Else
               If Temp.Equipted then
                  SMG$Put_Chars (ScreenDisplay,
                      '*')
               Else
                  If Not((Character.class in Item.usable_by) or (Character.PreviousClass in Item.Usable_By)) or
                        ((Character.Alignment<>Item.Alignment) and (Item.Alignment<>NoAlign)) then
                     SMG$Put_Chars (ScreenDisplay,
                        '#')
                  Else
                     SMG$Put_Chars (ScreenDisplay,
                         ' ');
           If Temp.Ident then
              SMG$Put_Chars (ScreenDisplay,
                  Pad(Item.True_Name,
                      ' ',20))
           Else
              SMG$Put_Chars (ScreenDisplay,
                  Pad(Item.Name,
                      ' ',20));
         End;
  If (Position Mod 2)=0 then SMG$Put_Line (
     ScreenDisplay, '')
  Else                 SMG$Set_Cursor_ABS (
     ScreenDisplay,,32);
End;

(******************************************************************************)

Procedure Print_Equipment (Character: Character_Type);

Var
  Eq: Integer;

Begin { Print Equipment }
  SMG$Begin_Display_Update (ScreenDisplay);
  SMG$Set_Cursor_ABS (ScreenDisplay,14,5);
  SMG$Put_Line (ScreenDisplay,
      '* = Equipped,  - = Cu'
      +'rsed,  ? = Unknown, '
      +' # = Unusable');
  For Eq:=1 to 8 do Print_Item (Character,Eq);
  SMG$End_Display_Update (ScreenDisplay);
End;  { Print Equipment }

(******************************************************************************)

Function Choose_Item (Character: Character_Type; Action: Line): [Volatile]Integer;

Var
  Choices: Char_Set;
  Answer: Char;

Begin { Choose Item }
   If Character.No_of_items>0 then
     Begin
        SMG$Begin_Display_Update (ScreenDisplay);
        SMG$Erase_Display (ScreenDisplay,19,1);
        Print_Equipment (Character);
        SMG$Put_Line (ScreenDisplay,
            Action
            +' which item? (1-'
            +String(Character.No_of_items,1)
            +', [RETURN] exits)', 0);
        Choices:=['1'..CHR(Character.No_of_Items+ZeroOrd),CHR(13)];
        Answer:=Make_Choice(Choices);
        If Answer=CHR(13) then Answer:='0';
        Choose_Item:=Ord(Answer)-ZeroOrd;
     End
   Else
     Choose_Item:=0;
End; { Choose Item }


(******************************************************************************)

Function Choose_Character (Txt: Line; Party: Party_Type;  Party_Size: Integer; HP: Boolean:=False;
                           Items: Boolean:=False): [Volatile]Integer;

Var
   StatusName: [External]Array [Status_Type] of Varying [14] of char;
   Character,Temp: Integer;
   Options: Char_Set;
   Answer: Char;

Begin { Choose Character }
   Temp:=0;
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay,14,1);
   SMG$Set_Cursor_ABS (ScreenDisplay,15,1);
   Options:=['1'..CHR(Party_Size+48)]+[CHR(13)];
   For Character:=1 to Party_size do
     Begin
        SMG$Put_Chars (ScreenDisplay,
            CHR(Character+48)
            +') '
            +Pad(Party[Character].Name, ' ',20));
        If HP then
           Begin
              SMG$Put_Chars (ScreenDisplay,
                 '  '
                 +String(Party[Character].Curr_HP,4)
                 +'/'
                 +String(Party[Character].Max_HP,4));
              SMG$Put_Chars (ScreenDisplay,
                 '  '
                 +StatusName[Party[Character].Status][1]);
              SMG$Put_Chars (ScreenDisplay,
                 StatusName[Party[Character].Status][2]);
           End;
        If Items and not HP then SMG$Put_Chars (ScreenDisplay,
            ' ('
            +String(Party[Character].No_of_Items)
            +' items )  ');
        If (Character mod 2)=0 then
           SMG$Put_Line (ScreenDisplay,
              '')
        Else
           Begin
              SMG$Put_Chars (ScreenDisplay,
                  ' ');
              If Not (Items or HP) then SMG$Put_Chars (ScreenDisplay,
                  Pad('',' ',13));
           End;
     End;
  SMG$Put_Line (ScreenDisplay,
     '');
  SMG$Put_Chars (ScreenDisplay,Txt,19,1);
  SMG$End_Display_Update (ScreenDisplay);
  Answer:=Make_Choice (Options);
  If Answer=CHR(13) then Temp:=0
  Else                   Temp:=Ord(Answer)-48;
  Choose_Character:=Temp;
End;  { Choose Character }

(******************************************************************************)



{ TODO: Enter this code }

(******************************************************************************)

{ TODO: Enter this code }


Procedure Equip_Character (Var Character: Character_Type);

Begin
   { TODO: Enter this code }
End;


Procedure Identify_Object (Var Character: Character_Type);

Begin
   { TODO: Enter this code }
End;


Procedure Get_Rid_Of_Item (Var Character: Character_Type; Which_Item: Integer);

Begin
  { TODO: Enter this code }
End;

Procedure Drop_Item (Var Character: Character_Type);

Begin
  { TODO: Enter this code }
End;


Procedure Item_Breaks (Character: Character_Type; Var Equipment: Equipment_Type);

Begin
  { TODO: Enter this code }
End;

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

{ TODO: Enter this code }

Procedure Print_Spell_Points (Character: Character_Type);

Begin
  { TODO: Enter this code }
End;

{ TODO: Enter this code }

Procedure Print_Books (Character: Character_Type);

Begin
  { TODO: Enter this code }
End;


{ TODO: Enter this code }

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

(******************************************************************************)

Procedure Trade_Gold (Var Character: Character_Type; TradeTo: Integer;  Var Party: Party_Type;  Party_Size: Integer);

Var
   Amount: Integer;

Begin { Trade Gold }
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay,19,1);
   SMG$Put_Line (ScreenDisplay,
       'Trade how much gold?');
   SMG$Put_Chars (ScreenDisplay,
        '--->');
   SMG$End_Display_Update (ScreenDisplay);
   Cursor;
   Get_Num (Amount,ScreenDisplay);
   No_Cursor;
   If Character.Gold<Amount then
      Begin
         SMG$Put_Line (ScreenDisplay,
             'Thou don''t have that much!',0);
             Delay(4);
      End
   Else
      Begin
         Character.Gold:=Character.Gold-Amount;
         Party[TradeTo].Gold:=Party[TradeTo].Gold+Amount;
         Print_Top (Character);
      End;
   SMG$Erase_Line (ScreenDisplay,20);
End;  { Trade Gold }

(******************************************************************************)

Procedure Give_Character_Item (Var Giver,Receiver: Character_Type;  Item_number: Integer);

Begin { Give Character Item }
   Receiver.No_of_items:=Receiver.No_of_items+1;
   Receiver.Item[Receiver.No_of_Items]:=Giver.Item[Item_Number];
   Get_Rid_of_Item (Giver, Item_Number);
End;  { Give Character Item }

(******************************************************************************)

Procedure Trade_Equipment (Var Character: Character_Type; TradeTo: Integer; Var Party: Party_Type);

Var
  Item_Number: Integer;

Begin { Trade Equipment }
   Item_Number:=0;
   Repeat
      Begin
         Item_Number:=Choose_Item (Character,
            'Trade');
         If Item_Number>0 then
            If Character.Item[Item_Number].Cursed then
               Begin
                  SMG$Put_Line (ScreenDisplay,
                     'That item is cursed!');
                  Ring_Bell (ScreenDisplay, 2);
                  Delay(2);
               End
            Else
               If Character.Item[Item_Number].Equipted then
                  Begin
                     SMG$Put_Line (ScreenDisplay,
                        'That item is equipped.');
                     Ring_Bell (ScreenDisplay);
                     Delay(2);
                  End
               Else
                  Give_Character_Item (Character,Party[Tradeto],Item_Number);
      End;
   Until Item_Number=0;
End;  { Trade Equipment }

(******************************************************************************)

Procedure Trade_Stuff (Var Character: Character_Type;  Var Party: Party_Type;  Party_Size: Integer);

Var
   Number: Integer;

Begin { Trade Stuff }
   Number:=Choose_Character(
      'Trade with whom?',
      Party,
      Party_Size,
      False,
      True);
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay,19,1);
   Print_Equipment (Character);
   SMG$End_Display_Update (ScreenDisplay);
   If Number<>0 then
      Begin
         If Character.Gold>0 then Trade_Gold (Character,Number,Party,Party_Size);
         If (Character.No_of_items>0) and (Party[Number].No_of_Items<8) then Trade_Equipment (Character,Number,Party);
      End;
End;  { Trade Stuff }

(******************************************************************************)

Procedure Item_Is_Used (Var Character: Character_Type;  Item_Num: Integer; Var Leave_Maze: Boolean;
                        Direction: Direction_Type;  Var Party: Party_Type;  Var Party_Size: Integer);

Var
   Item: Item_Record;

Begin { Item Is Used }
   Item:=Item_List[Character.Item[Item_Num].Item_Num];
   If Not No_Magic then
      If Item.Spell_Cast<>NoSp then
         Handle_Spell (Character,Item.Spell_Cast,0,0,Leave_Maze,Direction,Party,Party_Size,Item_Spell:=True)
      Else
         Special_Occurance (Character,Item.Special_Occurance_No)
   Else
      Begin
         SMG$Put_Line (ScreenDisplay,
             '* * * The spell fizzeled out! * * *');
         Delay(2);
      End;
   If Made_Roll (Item.Percentage_Breaks) then Item_Breaks (Character,Character.Item[Item_Num]);
End;  { Item Is Used }

(******************************************************************************)

Procedure Use_Item (Var Character: Character_Type;  Var Leave_Maze: Boolean;  Direction: Direction_Type;
                    Var Party: Party_Type;  Var Party_Size: Integer);

{ This procedure allows a character to use a magical item to cast a spell }

Var
   Answer:   Char;
   Choices:  Set of Char;
   Num:      Integer;
   Item:     Item_Record;

Begin { Use Item }
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay,19,1);
   SMG$Put_Line (ScreenDisplay,
       'Use which item? (1-'
       +String(Character.No_of_items,1)
       +', 0 exits)',0);
   SMG$End_Display_Update (ScreenDisplay);

   Choices:=['0'..CHR(Character.No_of_Items+ZeroOrd)];
   Answer:=Make_Choice(Choices);
   Num:=Ord(Answer)-ZeroOrd;
   If Num<>0 then
     If Not Can_Use (Character,Character.Item[Num]) then
        Begin
           SMG$Put_Line (ScreenDisplay,
               '* * * Powerless * * *',
               0);
           Delay(2);
        End
     Else
        Begin
           Item:=Item_List[Character.Item[Num].Item_Num];
           If Not(Item.Spell_Cast in Camp_Spells) and (Item.Special_Occurance_No=0) then
              Begin
                 SMG$Put_Line (ScreenDisplay,
                     'Thou canst not use that here! * * *', 0);
                 Delay(2);
              End
           Else
              Item_is_used (Character,Num,Leave_Maze,Direction,Party,Party_Size);
        End;
End;  { Use Item }

(******************************************************************************)

Procedure Show_Options (Character: Character_Type; Var Choices: Char_Set;  Party: Party_Type;  Party_Size: Integer);

Var
   T: Line;

Begin { Show Options }
  Choices:=[];
  T:='Thou may: ';
  If (Location<>TrainingGrounds) then
     Begin
        If (Character.No_of_items>0) then
           Begin
              T:=T+'E)quip, D)rop item, ';
              Choices:=Choices+['E','D'];
           End;
        If Can_Trade (Character,Party_Size) then
           Begin
              T:=T+'T)rade stuff, ';
              Choices:=Choices+['T'];
           End;
     End;
  If (Character.Status in [Healthy,Poisoned]) then
     Begin
        If (Location=TheMaze) then
           Begin
              T:=T+'U)se an item, cast a S)pell, ';
              Choices:=Choices+['U','S'];
              If Can_Identify (Character) then
                 Begin
                    T:=T+'I)dentify object, ';
                    Choices:=Choices+['I'];
                 End;
           End;
           T:=T+'R)ead spell books, ';
           Choices:=Choices+['R'];
     End;
  T:=T+'L)eave';
  SMG$Put_Line (ScreenDisplay,T,0,Wrap_Flag:=SMG$M_WRAP_WORD);
  Choices:=Choices+['L'];
End;  { Show Options }

(******************************************************************************)

Procedure Print_The_Rest (Character: Character_Type; Var Choices: Char_Set;  Party: Party_Type;  Party_Size: Integer);

Begin { Print the Rest }
   Print_Spell_Points (Character);                      { Print out the remaining spell points }
   Print_Equipment (Character);                         { Print out the equipment list }
   Show_Options (Character,Choices,Party,Party_Size);   { Show the player's options }
End;  { Print the Rest }

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
   if Answer=' ' then
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

   If Not((Answer='L') or Automatic or Leave_Maze) then SMG$Begin_Display_Update (ScreenDisplay);
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

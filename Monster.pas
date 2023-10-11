[Inherit ('Types','SMGRTL')]Module Edit_Monster;

Type
   Attack_Set = Set of Attack_Type;

Var
   Number:        Integer;
   Attack_Name:   Array [Attack_Type] of Packed Array [1..11] of char;
   Propty:        Array [0..12] of Packed Array [1..16] of char;
   Cat:           Array [1..31] of Packed Array [1..28] of char;
   MonsterType:   Array [Monster_Type] of Packed Array [1..13] of char;
   ScreenDisplay: [External]Unsigned;
   Pics:          [External]Pic_List;
   Monsters:      [Local]List_of_Monsters;

Value
   Cat[1]:='Number';
   Cat[2]:='Unidentified Name';
   Cat[3]:='Unidentified Plural';
   Cat[4]:='Real Name';
   Cat[5]:='Real Plural';
   Cat[6]:='Alignment';

   Cat[7]:='Number appearing';
   Cat[8]:='Hit points';
   Cat[9]:='Monster type';
   Cat[10]:='Armor Class';
   Cat[11]:='Treas. in lair';
   Cat[12]:='Treas. wandering';
   Cat[13]:='Levels drained';
   Cat[14]:='Years aged';
   Cat[15]:='Regenerates';
   Cat[16]:='Highest cleric';
   Cat[17]:='Highest wizard';
   Cat[18]:='Magic resistance';
   Cat[19]:='Chance of Chum %';
   Cat[20]:='Chum number';
   Cat[21]:='Breath Weapon';
   Cat[22]:='# of attacks';
   Cat[23]:='Damage per attack';
   Cat[24]:='Resists';
   Cat[25]:='Monster Properties';
   Cat[26]:='Picture Number';
   Cat[27]:='Hates';
   Cat[28]:='Gaze Weapon';
   Cat[29]:='Weapon plus needed';

   MonsterType[Warrior]:='Fighters';
   MonsterType[Mage]:='Wizards';
   MonsterType[Priest]:='Clerics';
   MonsterType[Pilferer]:='Thieves';
   MonsterType[Karateka]:='Monks';
   MonsterType[Midget]:='Midgets';
   MonsterType[Giant]:='Giants';
   MonsterType[Myth]:='Myths';
   MonsterType[Reptile]:='Reptiles';
   MonsterType[Animal]:='Animals';
   MonsterType[Lycanthrope]:='Lycanthropes';
   MonsterType[Undead]:='Undead';
   MonsterType[Demon]:='Demons';
   MonsterType[Insect]:='Insects';
   MonsterType[Enchanted]:='Magical';
   MonsterType[Plant]:='Plant';
   MonsterType[Multiplanar]:='Multi-planar';
   MonsterType[Dragon]:='Dragon';
   MonsterType[Statue]:='Statue';

   Propty[0]:='Stones';            Propty[1]:='Poisons';
   Propty[2]:='Paralyzes';         Propty[3]:='AutoKills';
   Propty[4]:='Can be slept';      Propty[5]:='Can run';
   Propty[6]:='Gates';             Propty[7]:='Can''t befriend';
   Propty[8]:='Can be surprised';  Propty[9]:='Teleports away';
   Propty[10]:='Can''t be turned'; Propty[11]:='Can''t escape';
   Propty[12]:='Causes Fear';

   Attack_Name[Fire]:='Fire';
   Attack_Name[Frost]:='Cold';
   Attack_Name[Poison]:='Poison';
   Attack_Name[LvlDrain]:='Level Drain';
   Attack_Name[Stoning]:='Stoning';
   Attack_Name[Magic]:='Magic';
   Attack_Name[Death]:='Death Magic';
   Attack_Name[CauseFear]:='Fear';
   Attack_Name[Electricity]:='Electricity';
   Attack_Name[Charming]:='Charming';
   Attack_Name[Insanity]:='Insanity';
   Attack_Name[Aging]:='Aging';
   Attack_Name[Sleep]:='Sleep';

(******************************************************************************)
[External]Procedure Read_Monsters (Var Monster: List_of_Monsters);External;
[External]Procedure Save_Monsters (Monster: List_of_Monsters);External;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;
[External]Procedure Get_Num (Var Number: Integer; Display: Unsigned);External;
[External]Function Make_Choice (Choices: Char_Set;  Time_Out:  Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
(******************************************************************************)

Procedure Display_Image (Image: Image_Type);

{ This procedure will display the image at 57, 3 }

Var
  X,Y: Integer;

Begin { Display Image }
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Put_Chars (ScreenDisplay,
       '+-----------------------+',3,57);
   For Y:=1 to 9 do
      Begin
         SMG$Put_Chars (ScreenDisplay,
             '|',3+Y,57);
         For X:=1 to 23 do
             SMG$Put_Chars (ScreenDisplay,
                 Image[X,Y]
                 +'',Y+3,X+56,0);
         SMG$Put_Chars (ScreenDisplay,
             '|',13,57);
      End;
   SMG$Put_Chars (ScreenDisplay,
       '+-----------------------+',13,57);
   SMG$End_Display_Update (ScreenDisplay);
End;  { Display Image }

(******************************************************************************)

[Global]Procedure Change_Class_Set (Var ClassSet: Class_Set; T1: Line);

Var
   Name: Line;
   Pos,ClassNum: Integer;
   Temp,Loop: Class_Type;
   Answer: Char;
   T: Line;
   ClassName: [External]Array [Class_Type] of Varying [13] of char;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,T1,1,0);
         Pos:=1;
         T:='';
         For Loop:=NoClass to Barbarian do
                 If Loop in ClassSet then
                         Begin
                            If Loop<>NoClass then Name:=ClassName[Loop]
                            Else Name:='No-class';
                            T:=T+Pad(Name,' ',20);
                            If Odd(Pos) then
                               T:=T+'    '
                            Else
                               Begin
                                  SMG$Put_Line (ScreenDisplay,T);
                                  T:='';
                               End;
                            Pos:=Pos+1;
                         End;
         SMG$Put_Line (ScreenDisplay,T);
         SMG$Set_Cursor_ABS (ScreenDisplay,15,1);
         SMG$Put_Line (ScreenDisplay,
             'Change which Class?');
         Pos:=1;
         T:='';
         For Loop:=NoClass to Barbarian do
                 If Loop in ClassSet then
                         Begin
                            If Loop<>NoClass then Name:=ClassName[Loop]
                            Else Name:='No-class';
                            T:=T
                                +(CHR(Ord(Loop)+65)
                                +'  '
                                +Pad(Name,' ',20);
                            If Odd(Pos) then
                               T:=T+'    '
                            Else
                               Begin
                                  SMG$Put_Line (ScreenDisplay,T);
                                  T:='';
                               End;
                            Pos:=Pos+1;
                         End;
         SMG$Put_Line (ScreenDisplay,T,0);
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice (['A'..CHR(Ord(Barbarian)+65),' ']);
         If Answer<>' ' then
                 Begin
                    ClassNum:=Ord(Answer)-65;
                    Temp:=NoClass;
                    While Ord(Temp)<>ClassNMum do Temp:=Succ(Temp);
                    If Temp in ClassSet then
                       ClassSet:=ClassSet-[Temp]
                    Else
                       ClassSet:=ClassSet+[Temp];
                 End;
      End;
   Until Answer=' ';
End;

(******************************************************************************)

[Global]Procedure Change_Attack_Set (Var AttackSet: Attack_Set; T1: Line);

Var
   Name: Line;
   Pos,ClassNum: Integer;
   Temp,Loop: Attack_Type;
   Answer: Char;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,T1);
         Pos:=1;
         For Loop:=Fire to Sleep do
                 If Loop in AttackSet then
                         Begin
                            SMG$Put_Chars (ScreenDisplay,Pad(Attack_Name[Loop],' ',20);
                            If Odd(Pos) then
                               SMG$Put_Chars (ScreenDisplay,'    ');
                            Else
                               Begin
                                  SMG$Put_Line (ScreenDisplay,'');
                               End;
                            Pos:=Pos+1;
                         End;
         SMG$Set_Cursor_ABS (ScreenDisplay,15,1);
         SMG$Put_Line (ScreenDisplay,T);
             'Change which attack?');
         Pos:=1;
         For Loop:=NoClass to Barbarian do
                 If Loop in ClassSet then
                         Begin
                            SMG$Put_Chars (ScreenDisplay,(CHR(Ord(Loop)+65)
                                 +'  '
                                 +Pad(Attack_Name[Loop],' ',20);
                            If Odd(Pos) then
                               SMG$Put_Chars (ScreenDisplay,'    ');
                            Else
                               SMG$Put_Line (ScreenDisplay,'');
                            Pos:=Pos+1;
                         End;
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice (['A'..CHR(Ord(Sleep)+65),' ']);
         If Answer<>' ' then
                 Begin
                    AttackNum:=Ord(Answer)-65;
                    Temp:=Fire;
                    While Ord(Temp)<>ClassNMum do Temp:=Succ(Temp);
                    If Temp in AttackSet then
                       AttackSet:=AttackSet-[Temp]
                    Else
                       AttackSet:=AttackSet+[Temp];
                 End;
      End;
   Until Answer=' ';
End;

(******************************************************************************)

Procedure Change_Screen1 (Number: Integer);

Type
   TreasureSet = Set of T_Type;

Var
   Keyboard: [External]Unsigned;
{ TODO: Enter this code }




(******************************************************************************)


{ TODO: Enter this code }

[Global]Procedure Edit_Monster;
  { TODO: Enter this code }
Begin

{ TODO: Enter this code }

End;
End.  { Edit Monster }

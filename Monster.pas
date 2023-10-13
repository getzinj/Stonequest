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
   Attack_Name[Poisons]:='Poison';
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
                                +CHR(Ord(Loop)+65)
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
                    While Ord(Temp)<>ClassNum do Temp:=Succ(Temp);
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
   Pos,AttackNum: Integer;
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
         SMG$Put_Line (ScreenDisplay,
             'Change which attack?');
         Pos:=1;
         For Loop:=Fire to Sleep do
                 If Loop in AttackSet then
                         Begin
                            SMG$Put_Chars (ScreenDisplay,CHR(Ord(Loop)+65)
                                 +'  '
                                 +Pad(Attack_Name[Loop],' ',20);
                            If Odd(Pos) then
                               SMG$Put_Chars (ScreenDisplay,'    ')
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
                    While Ord(Temp)<>ClassNum do Temp:=Succ(Temp);
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
   Options: Char_Set;
   X1,Y1,Z1,Num,Loop: Integer;
   Answer: Char;
   Strng,T: Line;
   AlignName: [External]Array [Align_Type] of Packed Array [1..73] of Char;

Procedure Treasure_Types (Var Treasure: TreasureSet);

Var
  Pos: Integer;
  Loop: T_Type;
  T: Line;

Begin
  Repeat
     Begin
        SMG$Begin_Display_Update (ScreenDisplay);
        SMG$Put_Line (ScreenDisplay,
            'The monster has these treasure types');
        Pos:=1;
        T:='';
        For Loop:=1 to 150 do
           If Loop in Treasure then
              Begin
                 T:=T+String (Loop,0);
                 If (Pos/4)<>(Pos div 4) then
                    T:=T+'     '
                 Else
                    Begin
                       SMG$Put_Line (ScreenDisplay,T);
                       T:='';
                    End;
                 Pos:=Pos+1;
              End;
        SMG$Put_Line (ScreenDisplay,T,0);
        SMG$End_Display_Update (ScreenDisplay);
        SMG$Put_Chars (ScreenDisplay,
            'Change which type? (1-150)',15,1);
        Get_Num (Num, ScreenDisplay);
        If Num>150 then
           Num:=0
        Else
           If Num>0 then
              If Num in Treasure then
                 Treasure:=Treasure-[Num]
              Else
                 Treasure:=Treasure+[Num];
     End;
  Until Num=0;
End;

Begin
   Loop:=0;
   Monsters[Number].Monster_number:=Number;
   Repeat
      Begin { Initial repeat }
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Home_Cursor (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,
             'Monster #'
             +String(Number,3) );
         SMG$Put_Line (ScreenDisplay,
             '------- ----',1,0);
         For Loop:=1 to 12 do
            Begin (* Do Loop *)
                T:=CHR(Loop+64)
                    +'  '
                    +Cat[Loop]+': ';
                Case Loop of
                    1: T:=T+String(Monsters[Number].Monster_Number,0);
                    2: T:=T+Monsters(Number].Name;
                    3: T:=T+Monsters(Number].Plural;
                    4: T:=T+Monsters(Number].Real_Name;
                    5: T:=T+Monsters(Number].Real_Plural;
                    6: T:=T+AlignName[Monsters[Number].Alignment];
                    7: Begin
                          T:=T+String(Monsters[Number].Number_Appearing.X,0)
                             +'D'
                             +String(Monsters[Number].Number_Appearing.Y,0);
                          If Monsters[Number].Number_Appearing.Z>=0 then
                             T:=T+'+'
                          Else
                             T:=T+'-';
                          T:=T+String(Monsters[Number].Number_Appearing.Z,0);
                       End;
                    8: Begin
                          T:=T+String(Monsters[Number].Hit_Points.X,0)
                             +'D'
                             +String(Monsters[Number].Hit_Points.Y,0);
                          If Monsters[Number].Hit_Points.Z>=0 then
                             T:=T+'+'
                          Else
                             T:=T+'-';
                          T:=T+String(Monsters[Number].Hit_Points.Z,0);
                       End;
                    9: T:=T+MonsterType[Monsters[Number].Kind];
                    10: T:=T+String(Monsters[Number].Armor_Class,0);
                    11: If Monsters[Number].Treasure.In_Lair=[] then
                         T:=T+'None'
                       Else
                         T:=T+'Type ''K'' to edit list';
                    12: If Monsters[Number].Treasure.Wandering=[] then
                         T:=T+'None'
                       Else
                         T:=T+'Type ''L'' to edit list';
                End;
            SMG$Put_Line (ScreenDisplay,T);
         End;  (* Do Loop *)
         Options:=['A'..'N',' '];
         SMG$Put_Line (ScreenDisplay, '');
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice (Options);
         Case ORD(Answer)-64 of
             2,3,4,5:  Begin
                         SMG$Set_Cursor_ABS (ScreenDisplay,15,1);
                         SMG$Put_Line (ScreenDisplay
                             'Enter a string of'
                             +' up to 60 characters',1,0);
                         Cursor;
                         SMG$Read_String (Keyboard,Strng,Display_ID:=ScreenDisplay);
                         No_Cursor;
                         If Strng.length>60 then
                            Strng:=Substr (Strng,1,60);
                         Case Ord(Answer)-64 of
                                 2: Monsters[Number].Name:=Strng;
                                 3: Monsters[Number].Plural:=Strng;
                                 4: Monsters[Number].Real_Name:=Strng;
                                 5: Monsters[Number].Real_Plural:=Strng;
                         End;
                       End;  (* 2, 3, 4, 5 *)
             11,12:    If Ord(answer)-64=11 then
                          Treasure_Types(Monsters[Number].Treasure.In_Lair)
                       Else
                          Treasure_Types(Monsters[Number].Treasure.Wandering);
             10: Begin
                    SMG$Set_Cursor_ABS (ScreenDisplay,16,1);
                    SMG$Put_Line (ScreenDisplay,
                        'Enter an integer ');
                    Get_Num (Num,ScreenDisplay);
                    IF ABS(num)<128 then Monsters[Number].Armor_Class:=Num;
                 End;
             6:   If Monsters[Number].Alignment=Evil then
                     Monsters[Number].Alignment:=NoAlign
                  Else
                     Monsters[Number].Alignment:=Succ(Monsters[Number].Alignment);
             9:   If Monsters[Number].Kind=Enchanted then
                     Monsters[Number].Kind:=Warrior
                  Else
                     Monsters[Number].Kind:=Succ(Monsters[Number].Kind);
            7,8: Begin
                      SMG$Put_Chars (ScreenDisplay, 'Enter X: ',15,1);
                      Get_Num (X1,ScreenDisplay);
                      SMG$Put_Chars (ScreenDisplay, 'Enter Y: ',15,1);
                      Get_Num (Y1,ScreenDisplay);
                      SMG$Put_Chars (ScreenDisplay, 'Enter Z: ',15,1);
                      Get_Num (Z1,ScreenDisplay);
                      Case Ord(Answer)-64 of
                          8: Begin
                                Monsters[Number].Hit_Points.X:=X1;
                                Monsters[Number].Hit_Points.Y:=Y1;
                                Monsters[Number].Hit_Points.Z:=Z1;
                            End;
                          7: Begin
                                Monsters[Number].Number_Appearing.X:=X1;
                                Monsters[Number].Number_Appearing.Y:=Y1;
                                Monsters[Number].Number_Appearing.Z:=Z1;
                            End;
                      End;
                 End;
         End;  (* Other case *)
      End;  (* Initial Repeat *)
   Until Answer=' ';
End;  (* Screen1 *)

(******************************************************************************)

Procedure Change_Screen2 (Number: Integer);

Type
   Property_Set=Set of Property_Type;
   Damagetypes = Array [1..20] of die_type;

Var
   Options: Char_Set;
   Num,Loop: Integer;
   Answer: Char;
   T: Line;

Procedure PropertiesP (Var Props: Property_Set);

Var
  Pos: Integer;
  Loop: Property_Type;
  Temp: Property_Type;
  AttackNum: Integer;
  Answer: Char;
  T: Line;

Begin
   Repeat
      Begin
        SMG$Begin_Display_Update (ScreenDisplay);
        SMG$Erase_Display (ScreenDisplay);
        SMG$Put_Line (ScreenDisplay,
            'The monster has these properties');
        Pos:=1;
        T:=''
        For Loop:=Stones to Cause_Fear do
                If Loop in props then
                        Begin
                           T:=T+Pad(Propty[Ord(Loop)]
                               ,' ',20);
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
        SMG$Set_Cursor_ABS (ScreenDisplay,15,1);
        SMG$Put_Line (ScreenDisplay,'Change which property?');
        Pos:=1;
        T:='';
        For Loop:=Stones to Cause_Fear do
           Begin
                T:=T+CHR(Ord(Loop)+65)
                   +'  '
                   +Pad(Propty[Ord(Loop)],' ',20);
                If Odd(Pos) then
                   T:=T+'    '
                Else
                   Begin
                      SMG$Put_Line (ScreenDisplay,T);
                      T:='';
                   End;
                Pos:=Pos+1;
           End;
        SMG$Put_Line (ScreenDisplay,T,1,0);
        SMG$End_Display_Update (ScreenDisplay);
        Answer:=Make_Choice(['A'..CHR(Ord(Cause_Fear)+65,CHR(32)]);
        IF Answer<>CHR(32) then
               Begin
                   AttackNum:=Ord(Answer)-65;
                   Temp:=stones;
                   While Ord(Temp)<>AttackNum do
                       Temp:=Succ(Temp);
                   If Temp in props then
                      Props:=Props-[Temp]
                   Else
                      Props:=Props+[Temp];
               End;
      End;
   Until Answer=' ';
End;


Procedure Edit_Attacks (Var Attack: DamageTypes);

Var
  X1,Y1,Z1,Number,Loop: Integer;
  T: Line;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,'Edit Attacks',,1);
         SMG$Put_Line (ScreenDisplay,'---- -------',,1);
         For Loop:=1 to 20 do
            Begin
               T:=String(Loop,1)
                   +') ';
               T:=T+String(Attack[Loop].X,0)
                   +'D';
               T:=T+String(Attack[Loop].Y,0)
                   +'+';
               T:=T+String(Attack[Loop].Z,0);
               If Odd (Loop) then
                  SMG$Set_Cursor_ABS (ScreenDisplay, (Loop div 2) + 1, 1)
               Else
                  SMG$Set_Cursor_ABS (ScreenDisplay, (Loop div 2), 40);
               SMG$Put_Line (ScreenDisplay,T,0);
            End;
         SMG$End_Display_Update (ScreenDisplay);
         SMG$Put_Chars (ScreenDisplay,
             'Change which attack? >',1,4,1);
         Get_Num (Number,ScreenDisplay);
         If (Number<=20) and (Number>=1) then
            Begin
               SMG$Put_Chars (ScreenDisplay,
                   'Enter X: ',16,1);
               Get_Num (X1,ScreenDisplay);
               SMG$Put_Chars (ScreenDisplay,
                   'Enter Y: ',17,1);
               Get_Num (Y1,ScreenDisplay);
               SMG$Put_Chars (ScreenDisplay,
                   'Enter Z: ',18,1);
               Get_Num (Z1,ScreenDisplay);
               Attack[Number].X:=X1;
               Attack[Number].Y:=Y1;
               Attack[Number].Z:=Z1;
            End;
      End;
   Until Number=0;
End;


Begin
   Loop:=0;
   Repeat
      Begin (* Initial Repeat *)
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Home_Cursor (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,
             'Monster #'
             +String(Number,3)
             +' ('
             +Monsters[Number].Real_Name
             +')';
         SMG$Put_Line (ScreenDisplay,
             '------- ----');
         For Loop:=13 to 29 do
            Begin (* Do Loop *)
                T:=CHR(Loop+52)
                    +'  '
                    +Cat[Loop]+':';
                Case Loop of
                    13: T:=T+String(Monsters[Number].Levels_Drained);
                    14: T:=T+String(Monsters[Number].Years_ages);
                    15: T:=T+String(Monsters[Number].Regenerates)
                        +' HP/Round';
                    16: T:=T+String(Monsters[Number].Highest.Cleric_Spell);
                    17: T:=T+String(Monsters[Number].Highest.Wizard_Spell);
                    18: T:=T+String(Monsters[Number].Magic_Resistance)
                        + '%';
                    19: T:=T+String(Monsters[Number].gate_Success_percentage,0)
                        + '%';
                    20: If Monsters[Number].Monster_Called=0 then
                            T:=T+'None'
                        Else
                            T:=T+'('+String(Monsters[Number].Monster_Called)+')'+Monsters[Monsters[Number].Monster_Called].Real_Name);
                    21: If Monsters[Number].Breath_Weapon=Charming then
                            T:=T+'None'
                        Else
                            T:=T+Attack_Name[Monsters[Number].Breath_Weapon];
                    22: If Monsters[Number].No_of_Attacks>0 then
                            T:=T+String(Monsters[Number].No_of_Attacks)
                        Else
                            T:=T+'None';
                    23: If Monsters[Number].No_of_Attacks=0 then
                            T:=T+'None'
                        Else
                            T:=T+'Type ''K'' to edit list';
                    24: If Monsters[Number].Resists=[] then
                            T:=T+'Nothing'
                        Else
                            T:=T+'Type ''L'' to edit list';
                    25: If Monsters[Number].Properties=[] then
                            T:=T+'Nothing'
                        Else
                            T:=T+'Type ''M'' to edit list';
                    26: T:=T+String(Monsters[Number].Picture_Number);
                    27: If Monsters[Number].Extra_Damage=[] then
                            T:=T+'Nobody'
                        Else
                            T:=T+'Type ''O'' to edit list';
                    28: If Monsters[Number].Gaze_Weapon=Charming then
                            T:=T+'None' (* TODO: Vampires charm with their gaze, don't they? *)
                        Else
                            T:=T+Attack_Name[Monsters[Number].Gaze_Weapon];
                    29: T:=T+String(Monsters[Number].Weapon_Plus_Needed);
                End; (* Case )
            SMG$Put_Line (ScreenDisplay, T);
         End; (* Do Loop *)
         SMG$Put_Line (ScreenDisplay,'');
         Display_Image (Pics[Monsters[Number].Picture_Number].Image);
         SMG$End_Display_Update (ScreenDisplay);

         Options:=['A'..'Q',' '];
         Answer:=Make_Choice (Options);
         Case ORD(Answer)-52 of
            13,14,15,16,17,18,19,20,22,26,29: Begin
                 SMG$Set_Cursor_ABS (ScreenDisplay,22,1);
                 SMG$Put_Line (ScreenDisplay,
                     'Enter an Integer.');
                 Get_Num (Num,ScreenDisplay);
                 Case ORD(Answer)-52 of
                        13: If ABS(Num)<32768 then
                               Monsters[Number].Levels_Drained:=Num;
                        14: Monsters[Number].Years_ages:=Num;
                        15: If ABS(Num)<32768 then
                               Monsters[Number].Regenerates:=Num;
                        16: If (Num>-1) and (Num<10) then
                               Monsters[Number].Highest.Cleric_Spell:=Num;
                        17: If (Num>-1) and (Num<10) then
                               Monsters[Number].Highest.Wizard_Spell:=Num;
                        18: If (Num>-1) and (Num<201) then
                               Monsters[Number].Magic_Resistance:=Num;
                        19: If (Num>-1) and (Num<101) then
                               Monsters[Number].Gate_Success_Percentage:=Num;
                        20: If (Num>-1) and (Num<451) then
                               Monsters[Number].Monster_Called:=Num;
                        22: If (Num>-1) and (Num<21) then
                               Monsters[Number].No_of_Attacks:=Num;
                        26: If (Num>-1) and (Num<251) then
                               Monsters[Number].Picture_Number:=Num;
                        29: Monsters[Number].Weapon_Plus_Needed:=Num;
                 End; (* Case ord *)
                 End;
            21:  If Monsters[Number].Breath_Weapon=Sleep then
                    Monsters[Number].Breath_Weapon:=Fire
                 Else
                    Monsters[Number].Breath_Weapon:=Succ(Monsters[Number].Breath_Weapon);
            23:  Edit_Attacks (Monsters[Number].Damage);
            24:  Change_Attack_Set (Monsters[Number].Resists,
                'The monster is resistant to these attack forms');
            25: Propertiesp (Monsters[Number].Properties);
            27: Change_Class_Set (Monsters[Number].Extra_Damage,
                'The monster does more damage on these classes');
            28:  If Monsters[Number].Gaze_Weapon=Sleep then
                    Monsters[Number].Gaze_Weapon:=Fire
                 Else
                    Monsters[Number].Gaze_Weapon:=Succ(Monsters[Number].Gaze_Weapon);
         End; (* Other case *)
      End;  (* initial repeat *)
   Until Answer=' ';
End; (* Screen2 *)

(******************************************************************************)

Procedure Change_Monster (Number: Integer);

Var
   Answer: Char;
   Options: Char_Set;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);

{ TODO: Enter this code }




(******************************************************************************)


{ TODO: Enter this code }

[Global]Procedure Edit_Monster;
  { TODO: Enter this code }
Begin

{ TODO: Enter this code }

End;
End.  { Edit Monster }

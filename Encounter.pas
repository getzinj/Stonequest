[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','StrRtl')]Module Encounter;

{ This is the main module for combat. It handles all phases of combat,
  including treasure and fleeing. }

Const
   MonY       = 2;      MonX    = 26;
   SpellsY    = 7;      SpellsX = 26;
   ViewY      = 2;      ViewX   =  2;

   ZeroOrd = Ord ('0');

   Cler_Spell = 1;     Wiz_Spell = 2;

Type
   Place_Ptr   = ^Place_Node;
   Place_Node  = Record
                    PosX,PosY: Horizontal_Type;
                    PosZ: Vertical_Type;
                    Next: Place_Ptr;
                 End;
   Place_Stack = Record
                    Front: Place_Ptr;
                    Length: Integer;
                 End;
   ClassSet   = Set of Item_Type;
   Spell_List = Packed Array [1..9] of Set of Spell_Name;

Var
  Bool_String                                           : Array [Boolean] of Line;
  Show_Messages                                         : Boolean;
  Keyboard,Pasteboard,FightDisplay,CharacterDisplay     : [External]Unsigned;
  MonsterDisplay,CommandsDisplay,ViewDisplay            : [External]Unsigned;
  MessageDisplay,SpellsDisplay                          : [External]Unsigned;
  SpellListDisplay,OptionsDisplay                       : [External]Unsigned;
  WizSpells,ClerSpells                                  : [External]Spell_List;
  Spell                                                 : [External]Array [Spell_Name] of Varying [4] of Char;
  Maze                                                  : [External]Level;
  PosX,PosY                                             : [External]Horizontal_Type;
  PosZ                                                  : [External]Vertical_Type;
  Leave_Maze                                            : [External]Boolean;
  Delay_Constant                                        : [External]Real;
  Party_Spell,Person_Spell,Caster_Spell,All_Monsters_Spell,Group_Spell,Area_Spell: [External]Set of Spell_Name;
  Item_List                                             : [External]List_of_Items;
  Pics                                                  : [External]Pic_List;
  Places                                                : [External]Place_Stack;
  Time_Stop_Monsters,Time_Stop_Players                  : [Global]Boolean;
  Encounter_Spells                                      : Set of Spell_Name;
  Silenced,Can_Attack                                   : [Global]Party_Flag;
  NotSurprised,Yikes,NoMagic                            : [Global]Boolean;
  Bells_On                                              : [External,Volatile]Boolean;

Value
  Bool_String[True]:='On';        Bool_String[False]:='Off';

(******************************************************************************)
[External]Procedure Get_Num (Var Number: Integer; Display: Unsigned);External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Function Zero_Through_Six (Var Number: Integer; Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): Char;External;
[External]Function Pick_Character_Number (Party_Size: Integer; Current_Party_Size: Integer:=0;
                                          Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): [Volatile]Integer;External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function Alive (Character: Character_Type): Boolean;external;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Procedure Delay (Seconds: Real);External;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
[External]Function Compute_Party_Size (Member: Party_Type;  Party_Size: Integer): Integer;External;
[External]Procedure Print_Party_Line (Member: Party_Type;  Party_Size,Position: Integer);External;
[External]Procedure Time_Effects (Position: Integer; Var Member: Party_Type; Party_Size: Integer);External;
[External]Procedure Dead_Character (Position: Integer; Var Member: Party_Type; Party_Size: Integer);External;
(******************************************************************************)

Function Insane_Leader (Party: Party_Type; Var Name: Line): Boolean;

Begin { Insane Leader }
   If Party[1].Status=Insane then
      Begin
         Name:=Party[1].Name;
         Insane_Leader:=True;
      End
   Else
      Insane_Leader:=False;
End;  { Insane Leader }

(******************************************************************************)

Function Party_Dead (Party: Party_type; Size: Integer): Boolean;

{ This function will return TRUE if every member in the party is dead, and FALSE otherwise }

Var
   Temp: Boolean;
   Index: Integer;

Begin { Party Dead }
   Temp:=False;
   Index:=0;

   { Repeat until all members checked or one living found }

   Repeat
      Begin
         Index:=Index+1;
         Temp:=Temp or Alive (Party[Index]);
      End;
   Until Temp or (Index=6);
   Party_Dead:=Not Temp;
End;  { Party Dead }

(******************************************************************************)

[Global]Function Monster_Name (Monster: Monster_Record; Number: Integer; Identified: Boolean): Monster_Name_Type;

{ This function returns the name of the monster as influenced by whether or not the monsters have been identified, and whether there
  is just one, or many. }

Begin { Monster Name }
   If Identified then  { If the monster is known... }
      If Number>1 then { and there's more than one.... }
         Monster_Name:=Monster.Real_Plural  { Use the correct plural name }
      Else
         Monster_Name:=Monster.Real_Name    { Otherwise use the correct singular name }
   Else                 { Otherwise, if it isn't known... }
      If Number>1 then { and there's more than one.... }
         Monster_Name:=Monster.Plural  { Use the unidentified plural name }
      Else
         Monster_Name:=Monster.Name;    { Otherwise use the unidentified singular name }
End;  { Monster Name }

(******************************************************************************)

[Global]Procedure Slay_Character (Var Character: Character_Type; Var Can_Attack: Flag);

{ This procedure kills CHARACTER, if he or she is not already dead }

Begin { Slay Character }
   If Not (Character.Status in [Dead,Ashes,Deleted]) then
       Begin
          Character.Regenerates:=0;  Character.Armor_Class:=12;  Character.Status:=Dead;  Character.Curr_HP:=0;
          Can_Attack:=False;
          SMG$Put_Line (MessageDisplay,
              Character.Name
              +' is slain!',0,1);
          Ring_Bell (MessageDisplay,3);
       End;
End;  { Slay Character }

(******************************************************************************)

Function Update_Can_Attacks (Member: Party_Type; Party_Size: Integer): Party_Flag;

{ This procedure will determine who in the party can still attack }

Var
   Individual: Integer;
   Can_Attack: Party_Flag;

Begin { Update Can Attacks }
   For Individual:=1 to Party_Size do
      Can_Attack[Individual]:=(Member[Individual].Status in [Healthy,Poisoned,Zombie]);
   Update_Can_Attacks:=Can_Attack;
End;  { Update Can Attacks }

(******************************************************************************)

Procedure Combat_Message;

{ Print "An encounter..." on the screen }

Begin { Combat Message }
   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Chars (MessageDisplay,
       'An encounter...',2,1,,1);
   SMG$End_Display_Update (MessageDisplay);
   Delay (2);
End;  { Combat Message }

(******************************************************************************)

Procedure Compute_AC_And_Regenerates (Var Character: Character_Type);

[External]Function Compute_AC (Character: Character_Type; PosZ: Integer:=0): Integer;external;

Begin { Compute AC and Regenerates }
   Character.Armor_Class:=Compute_AC(Character,PosZ);
   Character.Regenerates:=Regenerates(Character,PosZ);
End;  { Compute AC and Regenerates }

(******************************************************************************)

Procedure Initialize_Character (Var Character: Character_Type; Position: Integer);

Begin { Initialize Character }
  Compute_AC_And_Regenerates (Character);
  Character.Attack.Berserk:=False;
  Silenced[Position]:=False
End;  { Initialize Character }

(******************************************************************************)

Procedure Initialize (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                      Var Can_Attack: Party_Flag;  Var Alarm_Off: Boolean;  Time_Delay: Integer);

{ This procedure initializes the encounter module. }

Var
   Character: Integer;

Begin { Initialize }
   Combat_Message;
   Show_Messages:=True;

   { Establish the delay constant for pacing messages }

   Delay_Constant:=Time_Delay/500;

   { Initialize some displays }

   SMG$Create_Virtual_Display (22,78,SpellListDisplay,1);
   SMG$Erase_Display (SpellListDisplay);

   Encounter_Spells := Party_Spell + Person_Spell + Caster_Spell + All_Monsters_Spell + Group_Spell + Area_Spell;

   Can_Attack:=Update_Can_Attacks (Member,Party_Size);
   Time_Stop_Monsters:=False;  Time_Stop_Players:=False;

   For Character:=1 to Current_Party_Size do
      Initialize_Character(Member[Character],Character);

   Alarm_Off:=False;   NotSurprised:=False;
   Yikes:=False;
End;  { Initialize }

(******************************************************************************)

Procedure Switch_Characters (Character1,Character2: Integer; Var Member: Party_Type;  Var Can_Attack: Party_Flag);

{ This function switches the positions of two characters in the party.  Notice that, in case of a silenced person, it is
  not the person that is silenced, but the area occupied by the person. Therefore, if a non-silenced person person switches with
  a silenced person, the non-silenced person becomes silenced and visa versa. }

Var
   Temp: Character_Type;
   Temp1: Boolean;

Begin { Switch Characters }
   Temp:=Member[Character1];
   Member[Character1]:=Member[Character2];
   Member[Character2]:=Temp;

   Temp1:=Can_Attack[Character1];
   Can_Attack[Character1]:=Can_Attack[Character2];
   Can_Attack[Character2]:=Temp1;
End;  { Switch Character }

(******************************************************************************)

Procedure Berserk_Characters (Var Member: Party_Type; Current_Party_Size: Party_Size_Type;  Var Can_Attack: Party_Flag);

{ This procedure will advance a berserk character in the ranks }

Var
   Loop: Integer;

Begin { Berserk Characters }
  For Loop:=2 to Current_Party_Size do
     If (Member[Loop].Status in [Healthy,Poisoned]) and Member[Loop].Attack.Berserk then
        Switch_Characters (Loop,Loop-1,Member,Can_Attack);
End;  { Berserk Characters }

(******************************************************************************)

Function Need_to_Switch_Characters (Character2,Character1: Status_Type):Boolean;

Var
   Temp: Boolean;

Begin { Need to Switch Characters }
   Temp:=False;
   Case Character2 of
        Healthy,Poisoned,Zombie:  Temp:=Not (Character1 in [Insane,Healthy,Poisoned,Zombie]);
        Asleep:                   Temp:=Not(Character1 in [Zombie,Insane,Healthy,Poisoned,Asleep]);
        Petrified,Paralyzed:      Temp:=Character1 in [Dead,Ashes,Deleted];
        Dead,Ashes,Deleted:       Temp:=False;
        Insane:                   Temp:=True;
        Afraid:                   Temp:=Not (Character1 in [Zombie,Insane,Healthy,Poisoned,Afraid,Paralyzed,Petrified]);
        Otherwise                 Temp:=False;
   End;
   Need_To_Switch_Characters:=Temp;
End;  { Need to Switch Characters }

(******************************************************************************)

[Global]Procedure Dead_Characters (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                                   Var Can_Attack: Party_Flag);

{ This procedure will move dead characters and/or inactive characters to the back of the party.  The algorithm is basically a
  bubblesort, which is O(n^2), but since there are most six slots, the time is negligable. }

Var
  Done: Boolean;
  Loop: Integer;

Begin { Dead Characters }
   Can_Attack:=Update_Can_Attacks (Member,Party_Size);
   Repeat
     Begin
        Done:=True;
        For Loop:=Party_Size downto 2 do
           If Need_to_Switch_Characters (Member[Loop].Status,Member[Loop-1].Status) then
              Begin
                 Switch_Characters (Loop,Loop-1,Member,Can_Attack);
                 Done:=False;
              End;
     End;
   Until Done;

   Current_Party_Size:=Compute_Party_Size (Member,Party_Size);
End; { Dead Characters }

(******************************************************************************)

Function Index_of_Living_Aux (Group: Monster_Group): Integer;

{ This function returns the slot of the first living monster in GROUP }

Var
   Index: Integer;

Begin { Index of Living Aux }
   Index:=1;
   While (Index<=Group.Curr_Group_Size) and (Group.Status[Index]=Dead) do
      Index:=Index+1;
   If Index>Group.Curr_Group_Size then
      Index_of_Living_Aux:=0
   Else
      Index_of_Living_Aux:=Index;
End;  { Index of Living Aux }

(******************************************************************************)

[Global]Function Index_of_Living (Group: Monster_Group): [Volatile]Integer;

Var
   Person: Integer;

Begin { Index of Living }
   If Index_of_Living_Aux (Group)=0 then
      Index_of_Living:=0
   Else
      Begin
         Repeat
            Person:=Roll_Die(Group.Curr_Group_Size)
         Until Group.Status[Person]<>Dead;
         Index_of_Living:=Person;
      End;
End;  { Index of Living }

(******************************************************************************)

Function Number_Active (Group: Monster_Group): Integer;

{ This function determines how many monsters can attack in GROUP }

Var
   Temp,Loop: Integer;

Begin { Number Active }
   Temp:=0;
   For Loop:=1 to Group.Curr_Group_Size do
      If Group.Status[Loop] in [Healthy,Poisoned,Afraid,Zombie] then
         Temp:=Temp+1;
   Number_Active:=Temp;
End;  { Number Active }

(******************************************************************************)

Procedure Print_Monster_Line (Group_Number: Integer; Group: Monster_Group);

{ This procedure will print out the GROUP_NUMBERth group's status line }

Var
   Name: Line;

Begin
   Name:='';
   If Group.Curr_Group_Size>0 then
      Begin
         Name:=Monster_Name (Group.Monster,Group.Curr_Group_Size,Group.Identified);
         SMG$Put_Chars (MonsterDisplay,
             CHR(Group_Number+ZeroOrd)
             +'  '
             +String(Group.Curr_Group_Size),Group_Number,1,1);
         SMG$Put_Chars (MonsterDisplay,' '
             +Name
             +' ('
             +String(Number_Active (Group))
             +')');
      End
   Else
      SMG$Put_Chars (MonsterDisplay,
          '',Group_Number,1,1);
End;

(******************************************************************************)

Procedure Switch_Monsters (Var Group: Monster_Group; One,Two: Integer);

{ This procedure switches the position of two monsters in GROUP }

Var
   TempStat: Status_Type;
   TempMax,TempCurr: Integer;

Begin
   TempStat:=Group.Status[One];
   TempMax:=Group.Max_HP[One];
   TempCurr:=Group.Curr_HP[One];

   Group.Status[One]:=Group.Status[Two];
   Group.Max_HP[One]:=Group.Max_HP[Two];
   Group.Curr_HP[One]:=Group.Curr_HP[Two];

   Group.Status[Two]:=TempStat;
   Group.Max_HP[Two]:=TempMax;
   Group.Curr_HP[Two]:=TempCurr;
End;

(******************************************************************************)

Function Need_to_Swap (Group: Monster_Group; Pos1,Pos2: Integer): Boolean;

{ This function determines whether or not two monsters need to be switched in the marching order }

Var
   Temp: Boolean;

Begin
   Temp:=(Group.Status[Pos1]=Dead);
   Temp:=Temp and (Group.Status[Pos2]<>Dead);
   Need_to_Swap:=Temp;
End;

(******************************************************************************)

Procedure Update_Monster_Group (Var Group: Monster_Group);

{ This procedure will update the current monster group.  Updated are the positions of the monsters, and the current group size }

Var
   Slot: Integer;
   Done: Boolean;

Begin
  If Group.Orig_Group_Size>1 then
     Repeat
        Begin
           Done:=True;
           For Slot:=Group.Orig_Group_Size downto 2 do
              If Need_to_Swap (Group,Slot-1,Slot) then
                 Begin
                    Switch_Monsters (Group,Slot-1,Slot);
                    Done:=False;
                 End;
        End;
    Until Done;

    Group.Curr_Group_Size:=0;  Slot:=1;
    While (Group.Status[Slot]<>Dead) and (Slot<=Group.Orig_Group_Size) do
       Begin
          Group.Curr_Group_Size:=Group.Curr_Group_Size+1;
          Slot:=Slot+1;
       End
End;

(******************************************************************************)

Procedure Print_Monsters (Var Group: Encounter_Group);

{ This procedure will print the monster status lines to the monster display }

Var
   Num: Integer;

Begin
  SMG$Begin_Display_Update (MonsterDisplay);
  SMG$Erase_Display (MonsterDisplay);
  For Num:=4 downto 1 do
     Begin
        Group[Num].Identified:=Group[Num].Identified or Made_Roll (15); { TODO: Make method taking past encounters into consideration }
        Update_Monster_Group (Group[Num]);
        Print_Monster_Line (Num,Group[Num]);
     End;
  SMG$End_Display_Update (MonsterDisplay);
End;

(******************************************************************************)

[Global]Procedure Show_Monster_Image (Number: Pic_Type; Var Display: Unsigned);

Var
   Pic: Picture;

[External]Procedure Show_Image (Number: Pic_Type; Var Display: Unsigned);External;

Begin
   SMG$Begin_Display_Update (Display);
   Show_Image (Number, Display);
   Pic:=Pics[Number];
   If Yikes then
      Begin
         If (Pic.Right_Eye.X>0) and (Pic.Right_Eye.Y>0) then
            SMG$Put_Chars (Display,Pic.Eye_Type+'',Pic.Right_Eye.Y+0,Pic.Right_Eye.X+0);
         If (Pic.Left_Eye.X>0) and (Pic.Left_Eye.Y>0) then
            SMG$Put_Chars (Display,Pic.Eye_Type+'',Pic.Left_Eye.Y+0,Pic.Left_Eye.X+0);
      End;
   SMG$End_Display_Update (Display);
End;

(******************************************************************************)

Procedure They_Advance (Name: Monster_Name_Type);

Begin
   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Line (MessageDisplay,
       'The '
       +Name
       +' advance!');
   Ring_Bell (MessageDisplay, 2);
   SMG$End_Display_Update (MessageDisplay);
   Delay (2*Delay_Constant);
End;

(******************************************************************************)

Procedure Swap_Groups (Var Group: Encounter_Group; Group1, Group2: Integer; Var Advance: Boolean;
                       Var Name: Monster_Name_Type);

Var
   Temp: Monster_Group;

Begin
   Advance:=False;
   If Group[Group1].Curr_Group_Size>0 then
      Begin
         Name:=Monster_Name(Group[Group2].Monster,2,Group[Group2].Identified);
         Advance:=True;
      End;
   Temp:=Group[Group1];
   Group[Group1]:=Group[Group2];
   Group[Group2]:=Temp;
End;

(******************************************************************************)

Function Want_to_Pass (Group: Encounter_Group; Pos1,Pos2: Integer): [Volatile]Boolean;

Begin
{ TODO: This looks wrong. }
   Want_to_Pass:=(Group[Pos1].Curr_Group_Size=Group[Pos2].Curr_Group_Size) and (Group[Pos2].Curr_Group_Size<>0) and Made_Roll(15);
End;

(******************************************************************************)

Procedure Update_Monster_Box (Var Group: Encounter_Group);

{ This procedure will allow monsters groups to switch positions for more favorable attack advantages }

Var
   i,j: Integer;
   Name: Monster_Name_Type;
   Advance: Boolean;

Begin
   Print_Monsters (Group);
   For i:=1 to 3 do
      For j:=4 downto i+1 do
         If (Group[j-1].Curr_Group_Size<Group[j].Curr_Group_Size) or Want_to_Pass (Group,j-1,j) then
            Begin
               Swap_Groups (Group,j-1,j,Advance,Name);

               SMG$Begin_Display_Update (MonsterDisplay);
               Print_Monster_Line (j-1,Group[j-1]);
               Print_Monster_Line (j,Group[j]);
               SMG$End_Display_Update (MonsterDisplay);

               If Advance then
                  They_Advance (Name);

               If Group[1].Curr_Group_Size>0 then
                  Show_Monster_Image (Group[1].Monster.Picture_Number,FightDisplay);
            End;
End;

(******************************************************************************)

[Global]Procedure Update_Character_Box (Member: Party_Type; Party_Size: Integer; Var Can_Attack: Party_Flag);

Var
   Num: Integer;

Begin
   Can_Attack:=Update_Can_Attacks (Member,Party_Size);
   SMG$Begin_Display_Update (CharacterDisplay);
   For Num:=1 to Party_size do
      Print_Party_Line (Member,Party_Size,Num);
   SMG$End_Display_Update (CharacterDisplay);
End;

(******************************************************************************)

Function Item_Attacker_Level (Attacker: Character_Type): Integer;

Var
   Critical_Flag: Boolean;
   Item_Num: Integer;

Begin
  Critical_Flag:=False;
  For Item_Num:=1 to Attacker.No_of_Items do
     If Attacker.Item[Item_num].Equipted then
        If Item_List[Attacker.Item[Item_Num].Item_Num].Auto_Kill then { TODO: Make the items stack so multiple items equals better chance of critical }
           Critical_Flag:=True;

  If Critical_Flag then Item_Attacker_Level:=Max(Attacker.Level,Attacker.Previous_Lvl)
  Else                  Item_Attacker_Level:=0;
End;

(******************************************************************************)

Function Class_Attacker_Level (Attacker: Character_Type): Integer;

Var
   Attacker_Level: Integer;

Begin
   Attacker_Level:=0;
   If Attacker.Class in [Monk, Ninja, Assassin] then
      If Attacker.PreviousClass in [Monk, Ninja, Assassin] then
         Class_Attacker_Level:=Max(Attacker.Level,Attacker.Previous_Lvl)
      Else
         Class_Attacker_Level:=Attacker.Level
   Else if Attacker.PreviousClass in [Monk, Ninja, Assassin] then
           Class_Attacker_Level:=Attacker.Previous_Lvl
        Else
           Class_Attacker_Level:=0;
End;

(******************************************************************************)

[Global]Function Critical_hit (Attacker: Character_Type; Defender_Level: Integer): [Volatile]Boolean;

Var
   Base,Attacker_Level: Integer;

Begin
   Attacker_Level:=Max(Class_Attacker_Level(Attacker),Item_Attacker_Level(Attacker));
   If Attacker_Level>0 then
      Begin
         Base:=10+ (5* ((Attacker_Level-Defender_Level) div 2));
         Critical_Hit:=Made_Roll(Base);
      End
   Else
      Critical_Hit:=False;
End;

(******************************************************************************)

Function Luck_Adjustment (Luck: Integer): Integer;

Begin
   Case Luck of
                  3: Luck_Adjustment:=-3;
                  4: Luck_Adjustment:=-2;
                  5: Luck_Adjustment:=-1;
              6..15: Luck_Adjustment:=0;
                 16: Luck_Adjustment:=1;
                 17: Luck_Adjustment:=2;
           18,19,20: Luck_Adjustment:=3;
           21,22,23: Luck_Adjustment:=4;
              24,25: Luck_Adjustment:=5;
           Otherwise Luck_Adjustment:=0;
   End;
End;

(******************************************************************************)

Function Natural_Adjustment (Character: Character_Type; Attack: Attack_Type): Integer;

Var
   Constitution,Luck: Integer;
   Race: Race_Type;
   Temp: Integer;

Begin
   Temp:=0;  Race:=Character.Race;  Constitution:=Character.Abilities[5];  Luck:=Character.Abilities[7];

   If Attack=Poison then
      If Race in [LizardMan,HfOgre,Dwarven,Hobbit] then
         Temp:=Temp+Trunc (Constitution / 3.5)
      Else
         If (Constitution>18) then
            Temp:=Temp+(Constitution-18);

   If (Race in [Dwarven,Hobbit]) and (Attack in [Magic,Death,CauseFear]) then
      Temp:=Temp+Trunc (Constitution / 3.5);

   Temp:=Temp+Luck_Adjustment (Luck);

   Natural_Adjustment:=Temp;
End;

(******************************************************************************)

Function Magical_Adjustment (Character: Character_Type; Attack: Attack_Type): Integer;

Var
   Temp,Item_No: Integer;

Begin
   Temp:=0;
   If Character.No_of_Items>0 then
      For Item_No:=1 to Character.No_of_Items do
          If Character.Item[Item_No].Equipted then
             If (Attack in Item_List[Character.Item[Item_No].Item_Num].Resists) or
                ((Attack in [Stoning,LvlDrain]) and (Magic in Item_List[Character.Item[Item_No].Item_Num].Resists)) then
                   Temp:=Temp+1;
   Magical_Adjustment:=Temp;
End;

(******************************************************************************)

Function Class_Save (Class: Class_Type; Level: Integer): Integer;

Var
   Temp: Integer;

Begin
   Case Class of
       Cleric,Monk:                                Temp:=10- (((Level-1) div 3));
       Fighter,Ranger,Samurai,Paladin,AntiPaladin: Temp:=10- (((Level-1) div 2));
       Wizard:                                     Temp:=11- (((Level-1) div 5));
       Thief,Ninja,Assassin,Bard:                  Temp:=11- (((Level-1) div 4));
       Otherwise                                   Temp:=12- (((Level-1) div 5));
   End;
   Class_Save:=Temp;
End;

(******************************************************************************)

Function Base_Save (Character: Character_Type): Integer;

Var
   Temp1,Temp2: Integer;

Begin
   Temp1:=Class_Save (Character.Class,Character.Level);
   Temp2:=Class_Save (Character.PreviousClass,Character.Previous_Lvl);
   Base_Save:=Min (Temp1,Temp2);
End;

(******************************************************************************)

Function Class_Adjustment (Class: Class_Type;  Attack: Attack_Type): Integer;

Begin
  Class_Adjustment:=0;
  Case Attack of
       Poison: If Class=Assassin then Class_Adjustment:=1;
       Magic:  If Class=Wizard   then Class_Adjustment:=1;
       Death:  If Class=AntiPaladin then Class_Adjustment:=1;
       CauseFear: If Class=AntiPaladin then Class_Adjustment:=-3
                  Else If Class=Barbarian then Class_Adjustment:=5;
       Aging,Sleep: If Class=Monk then Class_Adjustment:=1;
  End;
End;

(******************************************************************************)

Function Saving_Throw (Character: Character_Type; Attack: Attack_Type): Integer;

Var
   Roll_Needed: Integer;

Begin
   Roll_Needed:=Base_Save (Character);
   Roll_Needed:=Roll_Needed
       -Natural_Adjustment (Character,Attack)
       -Magical_Adjustment (Character,Attack)
       -Class_Adjustment (Character.Class,Attack)
       -Class_Adjustment (Character.PreviousClass,Attack);
  Saving_Throw:=Max(Roll_Needed,2);
End;

(******************************************************************************)

[Global]Function Made_Save (Character: Character_Type; Attack: Attack_Type): [Volatile]Boolean;

Var
   Temp_Save: Boolean;

Begin
   Temp_Save:=(Roll_Die(20)>=Saving_Throw(Character,Attack));
   If Attack=Charming then
      If Character.Race in [Elven,Drow] then
         Temp_Save:=Temp_Save or Made_Roll (90)
      Else
         If Character.Race=HfElf then
            Temp_Save:=Temp_Save or Made_Roll(30);
   Made_Save:=Temp_Save;
End;

(******************************************************************************)

[Global]Function Monster_Save (Monster: Monster_Record;  Attack: Attack_Type): [Volatile]Boolean;

Var
   Temp: Integer;

Begin
   Temp:=10-(((Monster.Hit_Points.X-1) div 2));
   If Attack in Monster.Resists then
      Temp:=Temp-4;
   Monster_Save:=(Roll_Die(20)>Temp);
End;

(******************************************************************************)

Function Class_Base_Chance (Class: Class_Type; Level: Integer): Integer;

Begin
   Case Class of
        Cleric:                                                    Class_Base_Chance:=10- (2*((level-1) div 3));
        Fighter,Ranger,Monk,Samurai,Barbarian,Paladin,AntiPaladin: Class_Base_Chance:=10- (2*((level-1) div 2));
        Wizard:                                                    Class_Base_Chance:=11- (2*((level-1) div 5));
        Thief,Assassin,Bard:                                       Class_Base_Chance:=11- (2*((level-1) div 4));
        Otherwise                                                  Class_Base_Chance:= 0;
   End;
End;

(******************************************************************************)

Function Weapon_Plus_To_Hit (Character: Character_Type; Kind: Monster_Type;  PosZ: Integer): Integer;

Var
   Temp_Item: Item_Record;
   Weapon_Plus,Item_No,Plus: Integer;

[External]Procedure Plane_Difference (Var Plus: Integer; PosZ: Integer);External; { TODO: Make this a function. }

Begin
   Weapon_Plus:=0;
   If Character.No_of_Items>0 then
      For Item_No:=1 to Character.No_of_Items do
         If Character.Item[Item_No].Equipted then
            Begin
               Temp_Item:=Item_List[Character.Item[Item_No].Item_Num];
               Plus:=Temp_Item.Plus_To_Hit;
               If Kind in Temp_Item.Versus then
                  Plus:=Plus+(4 * Plus);
               Plane_Difference (Plus,PosZ);
               Weapon_Plus:=Weapon_Plus+Plus;
            End;
   Weapon_Plus_to_Hit:=Weapon_Plus;
End;

(******************************************************************************)

Function Strength_Adjustment (Strength: Integer): Integer;

Begin
   Case Strength of
                  3: Strength_Adjustment:=-3;
                4,5: Strength_Adjustment:=-2;
                6,7: Strength_Adjustment:=-1;
              8..14: Strength_Adjustment:=0;
                 15: Strength_Adjustment:=1;
              16,17: Strength_Adjustment:=2;
                 18: Strength_Adjustment:=3;
                 19: Strength_Adjustment:=4;
                 20: Strength_Adjustment:=5;
                 21: Strength_Adjustment:=6;
                 22: Strength_Adjustment:=7;
              23,24: Strength_Adjustment:=8;
                 25: Strength_Adjustment:=9;
           Otherwise Strength_Adjustment:=0;
   End;
End;

(******************************************************************************)

[Global]Function To_hit_Roll (Character: Character_Type; AC: Integer; Monster: Monster_Record): Integer;

Var
   Weapon_Plus,Temp: Integer;
   Cant_Hit: Boolean;

Begin
   Weapon_Plus:=Weapon_Plus_to_Hit (Character,Monster.Kind,PosZ);
   Cant_Hit:=(Weapon_Plus<Monster.Weapon_Plus_Needed);
   If Cant_Hit then
      Temp:=MaxInt div 2
   Else
      Begin
         Temp:=Min(Class_Base_Chance(Character.Class,Character.Level),
                   Class_Base_Chance(Character.PreviousClass,Character.Previous_Lvl));
         If Character.Attack.Berserk then Temp:=Temp-4;
         If Character.Status=Zombie then Temp:=Class_Base_Chance (Fighter,Character.Level);
         Temp:=Temp-(AC-10);
         Temp:=Temp-Strength_plus_to_Hit (Character.Abilities[1]);

         Temp:=Temp-Weapon_Plus;

         If Temp>20 then Temp:=20
         Else if Temp<2 then Temp:=2;
      End;
   To_Hit_Roll:=Temp;
End;

(******************************************************************************)

Function Surprised (Monster: Monster_Record; Member: Party_Type): [Volatile]Surprise_Type;

Var
   Die: Integer;
   Surprise,Be_Surprised: Set of 1..12;

Begin
   Be_Surprised:=[11,12];
   Surprise:=[1,2];
   If ([Member[1].Class,Member[1].PreviousClass]*[Samurai,Monk,Ranger]<>[])
      or (Member[1].Race in [Elven,Drow]) then
         Begin
            Surprise:=[1];
            Be_Surprised:=[9,10,11,12];
         End;
   If (Member[1].Abilities[7]>15) then Be_Surprised:=Be_Surprised-[1];
   If (Member[1].Abilities[7]>17) then Surprise:=Surprise+[10];
   Case Monster.Kind of
      Karateka,Demon: Be_Surprised:=Be_Surprised+[3,4];
      Dragon: Surprise:=Surprise+[6];
      Insect: Surprise:=[];
      Otherwise ;
   End;
   If Not (CanBeSurprised in Monster.Properties) then Surprise:=[];

   Die:=Roll_Die(12);
   If Die in Be_Surprised then
      Surprised:=PartySurprised
   Else
      If Die in Surprise then
         Surprised:=MonsterSurprised
      Else
         Surprised:=NoSurprise;
End;

(******************************************************************************)

Function Empty (A: PriorityQueue): Boolean;

Begin
   Empty:=(A.Last=0)
End;

(******************************************************************************)

Procedure MakeNull (Var A: PriorityQueue);

Begin
   A:=Zero;
End;

(******************************************************************************)

Function P (A: Attacker_Type): Integer;

Begin
   P:=A.Priority;
End;

(******************************************************************************)

Procedure Insert (X: Attacker_Type; Var A: PriorityQueue);

Var
   NotDone: Boolean;
   i: Integer;
   Temp: Attacker_Type;

Begin
   If A.Last>4007 then
      Begin
        SMG$Erase_Display (CharacterDisplay);
        SMG$Put_Line (CharacterDisplay,
            'Error: heap insert overflow.');
        Delay(13);
      End
   Else
      Begin
         A.Last:=A.Last + 1;
         A.Contents[A.Last] := x;
         i := A.Last; { i is index of current position of x }
         If I>1 then NotDone:=(P(A.Contents[i])<P(A.Contents[i div 2]))
         Else        NotDone:=False;
         While NotDone do
            Begin { Push x up the tree by exchanging it with its parent of larger priority. Recall p computes the priority of a
                    Attacker_Type element }
               Temp:=A.Contents[i];
               A.Contents[i]:=A.Contents[i div 2];
               A.Contents[i div 2]:=Temp;

               i:=i div 2;

               If I>1 then
                   NotDone:=(P(A.Contents[i])<P(A.Contents[i div 2]))
               Else
                   NotDone:=False
            End
      End
End;

(******************************************************************************)

Function DeleteMin (Var A: PriorityQueue): Attacker_Type;

Var
   i,j: Integer;
   Temp,minimum: Attacker_Type;

Begin
  If A.last>0 then
     Begin
        Minimum:=A.Contents[1];
        A.Contents[1]:=A.Contents[A.Last];
        A.Last:=A.Last-1;

        i:=1;
        While (i <= (A.Last div 2)) do
           Begin
              If 2*i=A.last then J:=2*i
              Else If P(A.Contents[2*i])<P(A.Contents[2*i+1]) then
                      j:=2*i
                   Else
                      j:=2*i+1;

              If P(A.Contents[i]) > P(A.Contents[j]) then
                 Begin
                    Temp:=A.Contents[i];
                    A.Contents[i]:=A.Contents[j];
                    A.Contents[j]:=Temp;
                    i:=j;
                 End
              Else
                 Begin
                    DeleteMin:=Minimum;
                    i:=(A.Last div 2)+1;
                 End
           End;
        DeleteMin:=Minimum;
     End
  Else
     Begin
        Temp.Group:=0;
        DeleteMin:=Temp;
     End;
End;

(******************************************************************************)

[Global]Function Know_Monster (Monster_Number: Integer; Member: Party_Type; Current_Party_Size: Party_Size_Type): [Volatile]Boolean;

Var
   Chance,CharNo: Integer;
   In_Partys_Set: Boolean;

Begin
  In_Partys_Set:=False;
  For CharNo:=1 to Current_Party_Size do
     In_Partys_Set:=In_Partys_Set or Member[CharNo].Monsters_Seen[Monster_Number];

  If In_Partys_Set then Chance:=85
  Else                  Chance:= 5;

  Know_Monster:=Made_Roll(Chance);
End;

(******************************************************************************)

[Global]Procedure Change_Status (Var Character: Character_Type; Status: Status_Type; Var Changed: Boolean);

Begin
   Changed:=False;
   Case Character.Status of
      Healthy,Afraid,Asleep,Insane:  Changed:=True;
      Paralyzed:                    Changed:=(Status in [Petrified,Dead]);
      Petrified:                    Changed:=(Status=Dead);
      Poisoned:                     Changed:=(Status in [Asleep,Insane,Healthy]);
      Zombie:                       Changed:=(Status in [Ashes,Deleted]);
      Otherwise                     Changed:=False;
   End;

   If Changed then
      Begin
         Character.Status:=Status;
         Character.Attack.Berserk:=False;
         If Character.Curr_HP>Character.Max_HP then
            Character.Curr_HP:=Character.Max_HP;
      End;
   If (Character.Status=Dead) or (Character.Status=Ashes) or (Character.Status=Deleted) then
      Character.Curr_HP:=0;
   If Character.Status=Deleted then
      Character.Max_HP:=0;
End;

(******************************************************************************)

Procedure Check_Attack (Var Character: Character_Type; Attack: Attack_Type; Var T: Line; CharNum: Integer);

Var
   Changed: Boolean;

Begin
   Changed:=False;
   Case Attack of
        Poison: Begin
                   Change_Status (Character,Poisoned,Changed);
                   Character.Regenerates:=Regenerates (Character,PosZ);
                   If Changed then
                      T:=T
+' is poisoned!'
                   Else
                      T:=T
+' is unaffected!';
                End;
        Stoning: Begin
                   Change_Status (Character,Petrified,Changed);
                   If Changed then
                      T:=T
+' is turned into stone!'
                   Else
                      T:=T
+' is unaffected!';
                 End;
        Death:   Begin
                    Change_Status (Character,Dead,Changed);
                    If Changed then
                       Begin
                          Slay_Character (Character,Can_Attack[CharNum]);
                          T:=
'';
                       End
                    Else
                       T:=T
+' is unaffected';
                  End;
        Insanity: Begin
                    Change_Status (Character,Insane,Changed);
                    If Changed then
                       T:=T
+' is driven mad!'
                    Else
                       T:=T
+' is unaffected!';
                  End;
        Aging:    Begin
                    Character.Age:=Character.Age+(Roll_Die (4) * 3650);
                    T:=T
+' is aged!';
                  End;
        Sleep:    Begin
                    Change_Status (Character,Asleep,Changed);
                    If Changed then
                       T:=T
+' is driven slept!'
                    Else
                       T:=T
+' is unaffected!';
                  End;
        CauseFear:Begin
                    Change_Status (Character,Afraid,Changed);
                    If Changed then
                       T:=T
+' is made afraid!'
                    Else
                       T:=T
+' is unaffected!';
                  End;
        Otherwise ;
   End;
End;

(******************************************************************************)

[Global]Procedure Attack_Effects (Attack: Attack_Type; CharNum: Integer; Var Member: Party_Type; Var Can_Attack: Party_Flag);

Var
   Save: Boolean;
   Character: Character_Type;
   T: Line;

Begin
   Character:=Member[CharNum];
   T:=Character.Name;
   Save:=Made_Save (Character,Attack);
   If Save then
      T:=T+' is unaffected!'
   Else
      Check_Attack (Character,Attack,T,CharNum);
   SMG$Set_Cursor_ABS (MessageDisplay,2,1);
   If T<>'' then
      SMG$Put_Line (MessageDisplay,T);
   Can_Attack[CharNum]:=(Character.Status in [Healthy,Poisoned,Zombie]);
   Member[CharNum]:=Character;
End;

(******************************************************************************)

[Global]Function Spell_Damage (Spell: Spell_Name;  Caster_Level: Integer:=0): Die_Type;

Var
   Temp: Die_Type;

Begin
   Temp:=Zero;
   Case Spell of
    CsLt: With Temp do
             Begin
               X:=1;
               Y:=8;
             End;
    CsSe: With Temp do
             Begin
               X:=2;
               Y:=8;
             End;
    CsVs: With Temp do
             Begin
               X:=3;
               Y:=8;
             End;
    CsCr: With Temp do
             Begin
               X:=4;
               Y:=8;
             End;
    Wrth: With Temp do
             Begin
               X:=1;
               Y:=12;
             End;
    GrWr: With Temp do
             Begin
               X:=2;
               Y:=12;
             End;
    HoWr: With Temp do
             Begin
               X:=4;
               Y:=12;
             End;
    DiWr: With Temp do
             Begin
               X:=7;
               Y:=12;
             End;
    MaMs: With Temp do
             Begin
               X:=Round(Caster_Level / 2.0);
               Y:=4;
               Z:=Round(Caster_Level / 2.0);
             End;
    CoCd: With Temp do
             Begin
               X:=Caster_Level;
               Y:=4;
               Z:=Caster_Level;
             End;
    LiBt: With Temp do
             Begin
               X:=Caster_Level;
               Y:=6;
             End;
    FiBl: With Temp do
             Begin
               X:=Caster_Level;
               Y:=6;
             End;
    MgFi: With Temp do
             Begin
               X:=Caster_Level;
               Y:=6;
               Z:=Caster_Level;
             End;
    Holo: With Temp do
             Begin
               X:=25;
               Y:=5;
             End;
   End;
   Spell_Damage:=Temp;
End;

(******************************************************************************)

Function Uh_Oh (Group: Encounter_Group; Current_Party_Size: Party_Size_Type): [Volatile]Boolean;

Var
   GroupNum: Integer;
   Orig,Curr: Integer;
   Chance: Integer;

Begin
   Orig:=0; Curr:=0; Chance:=0;
   For GroupNum:=1 to 4 do
      Begin
         Orig:=Orig+Group[GroupNum].Orig_Group_Size;
         Curr:=Curr+Group[GroupNum].Curr_Group_Size;
      End;
   If (Current_Party_Size=0) or (Curr=0) or (Curr>(Current_Party_Size*2)) then
      Uh_Oh:=False
   Else
      Begin
         If Curr<(Orig*3/4) then Chance:=Chance+25;
         If Curr<(Orig*1/2) then Chance:=Chance+25;
         If Curr<(Orig*1/4) then Chance:=Chance+25;
         Uh_Oh:=Made_Roll(Chance);
      End;
End;

(******************************************************************************)
[External]Procedure Drain_Levels_from_Character (Var Character: Character_Type; Levels: Integer:=1);External;
[External]Procedure Handle_Monster_Attack (Attacker: Attacker_Type;  Var Monster_Group1: Encounter_Group;
                                                 Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                                                 Party_Size: Integer; Var Can_Attack: Party_Flag);external;
[External]Procedure Handle_Character_Attack (Attacker_Record: Attacker_Type; Var MonsterGroup: Encounter_Group;
                                             Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type);External;
(******************************************************************************)

Procedure Character_Attack (Attacker: Attacker_Type; Var Monster_Group: Encounter_Group; Var Member: Party_Type;
                       Var Current_Party_Size: Party_Size_Type; Var Can_Attack: Party_Flag);

Var
   Character: Character_Type;
   Position: Integer;

Begin
   Position:=Attacker.Attacker_Position;  Character:=Member[Position];

   If (Can_Attack[Position]) and (Attacker.Action<>Parry) and (Character.Status in [Healthy,Poisoned,Zombie]) then
      Begin
         Handle_Character_Attack (Attacker,Monster_Group,Member,Current_Party_Size);
         Delay ((3/2) * Delay_Constant)
      End
End;

(******************************************************************************)

Procedure Monster_Attack (Attacker: Attacker_Type; Var Monster_Group: Encounter_Group; Var Member: Party_Type;
                                                Var Current_Party_Size: Party_Size_Type; Party_Size: Integer; Var Can_Attack: Party_Flag);

Begin
   If (Monster_Group[Attacker.Group].Status[Attacker.Attacker_Position]=Healthy) then
      Begin
         Handle_Monster_Attack (Attacker,Monster_Group,Member,Current_Party_Size,Party_Size,Can_Attack);
         Delay ((3/2)*Delay_Constant)
      End
End;

(******************************************************************************)

Procedure Handle_Attack (    Attacker: Attacker_Type;
                                 Var Monster_Group: Encounter_Group;
                                 Var Member: Party_Type;
                                 Var Current_Party_Size: Party_Size_Type;
                                     Party_Size: Integer;
                                 Var Can_Attack: Party_Flag);

Begin
   SMG$Erase_Display (MessageDisplay);
   If (attacker.Group=5) and (Not Time_Stop_Players) then
      Character_Attack (Attacker,Monster_Group,Member,Current_Party_Size,Can_Attack)
   Else
      If Not Time_Stop_Monsters then
         Monster_Attack (Attacker,Monster_Group,Member,Current_Party_size,Party_Size,Can_Attack);
End;

(******************************************************************************)

Procedure End_of_Round_Update (Var Monster_Group: Encounter_Group;
                                       Var Member: Party_Type;
                                       Var Current_Party_Size: Party_Size_Type;
                                           Party_Size: Integer;
                                       Var Can_Attack: Party_Flag);

Begin
   If Not Leave_Maze then
      Begin
         Update_Monster_Box (Monster_Group);

         SMG$Begin_Display_Update (CharacterDisplay);
         Berserk_Characters (Member,Current_Party_Size,Can_Attack);
         Dead_Characters (Member,Current_Party_Size,Party_Size,Can_Attack);
         Update_Character_Box (Member, Party_Size, Can_Attack);
         SMG$End_Display_Update (CharacterDisplay);

         Time_Stop_Players:=False;  Time_Stop_Monsters:=False;
      End;
End;

(******************************************************************************)

Procedure One_Round (Var Attacks: PriorityQueue;  Var Monster_Group: Encounter_Group;  Var Member: Party_Type;
                             Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;  Var Can_Attack: Party_Flag);

{ This procedure will run one round of combat, getting the individual of the highest priority, run his/her attack, and then deleting
  him/her.  It will repeat until the heap is empty }

Var
   Next: Attacker_Type;
   Store_Delay_Constant: Real;
   Store_Bells: Boolean;

Begin
   Store_Delay_Constant:=0;  Store_Bells:=False;
   If Not Show_Messages then
      Begin
         Store_Delay_Constant:=Delay_Constant; Delay_Constant:=0;
         Store_Bells:=Bells_On;  Bells_On:=False;
         SMG$Begin_Display_Update (MessageDisplay);
      End;

   While Not ( Empty(Attacks) or Leave_Maze ) do
      Begin
         Next:=DeleteMin (Attacks);
         If Next.Group<>0 then Handle_Attack (Next,Monster_Group,Member,Current_Party_Size,Party_Size,Can_Attack);
         If Party_Dead (Member,Current_Party_Size) then MakeNull (Attacks);
      End;

   If Not Show_Messages then
      Begin
         Delay_Constant:=Store_Delay_Constant;
         SMG$Erase_Display (MessageDisplay);
         SMG$End_Display_Update (MessageDisplay);
         Bells_On:=Store_Bells;
      End;

   End_of_Round_Update (Monster_Group,Member,Current_Party_Size,Party_Size,Can_Attack);
End;

(******************************************************************************)

Procedure Get_Group_Number (Group: Encounter_Group;  Var Group1: Group_Type; Var Take_Back: Boolean);

Var
  Done: Boolean;
  T: Line;
  Temp: Integer;

Begin
   Take_Back:=False;
   If Group[2].Curr_Group_Size>0 then
      Begin
         SMG$Begin_Display_Update (OptionsDisplay);
         SMG$Erase_Display (OptionsDisplay);
         T:='Cast spell on what group?';
         SMG$Put_Chars (OptionsDisplay,T,3,27-(T.Length div 2));
         SMG$End_Display_Update (OptionsDisplay);
         Repeat
            Begin
              Done:=False;  Temp:=0;
              Zero_Through_Six (Temp);
              Done:=(Temp<5); { TODO: This is lazy programming }
              If Done and (Temp>0) then
                 Done:=Done and (Group[Temp].Curr_Group_Size>0);
              If Done and (Temp>0) then
                 Group1:=Temp;
            End;
         Until Done;
         Take_Back:=(Temp=0);
      End
   Else
      Group1:=1;
End;

(******************************************************************************)

Function Get_Character_Number (Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                                       Var Take_Back: Boolean): [Volatile]Integer;

Var
   T: Line;
   Number: Integer;

Begin
   If Current_Party_Size>1 then
      Begin
         SMG$Begin_Display_Update (OptionsDisplay);
         SMG$Erase_Display (OptionsDisplay);
         T:='Cast spell on whom?';
         SMG$Put_Chars (OptionsDisplay,T,3,27-(T.Length div 2));
         SMG$End_Display_Update (OptionsDisplay);
         Number:=Pick_Character_Number (Party_Size);
         If Number=0 then
            Take_Back:=True;
      End
   Else
      Number:=1;

   Get_Character_Number:=Number;
End;

(******************************************************************************)

Procedure Get_Spell_Info (Spell: Spell_Name; Group: Encounter_Group; Caster: Integer; Current_Party_Size: Party_Size_Type;
                           Party_Size: Integer;  Var Group1: Group_Type;  Var Number: Individual_Type;
                           Var Take_Back: Boolean);

Begin
   Take_Back:=False;
   Group1:=0;  Number:=0;
   If Spell in Caster_Spell then
      Begin
         Group1:=5;
         Number:=Caster;
      End
   Else
      If Spell in Party_Spell+All_Monsters_Spell+Area_Spell then
         Get_Group_Number (Group,Group1,Take_Back)
      Else
         If Spell in Group_Spell then
            Get_Group_Number (Group,Group1,Take_Back)
         Else
            If Spell in Person_Spell then
               Begin
                  Group1:=5;
                  Number:=Get_Character_Number (Current_Party_Size,Party_Size,Take_Back);
               End;
End;

(******************************************************************************)

Function Can_Use (Character: Character_Type;  Stats: Equipment_Type): Boolean;

Var
  Temp: Boolean;

Begin
   Temp:=(Character.Class in Item_List[Stats.Item_Num].Usable_By) or
         (Character.PreviousClass in Item_List[Stats.Item_Num].Usable_By);

   Temp:=Temp and (Stats.Equipted or (Item_List[Stats.Item_Num].Kind=Scroll));
                                   { If the item is equipped... }

   If Item_List[Stats.Item_Num].Alignment<>NoAlign then
      Temp:=Temp and (Character.Alignment=Item_List[Stats.Item_Num].Alignment);

   Temp:=Temp and (Item_List[Stats.Item_Num].Spell_Cast<>NoSp);
   Can_Use:=Temp
End;

(******************************************************************************)

Function Choose_Item_Num (Var Character: Character_Type): [Volatile]Integer;

Var
   Answer: Char;
   Options: Char_Set;
   Item: Integer;

Begin
   Options:=[CHR(13)];
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Label_Border (OptionsDisplay,
       'Use which item? ([RETURN] exits)',
       SMG$K_BOTTOM);
   If Character.No_of_Items>0 then
      For Item:=1 to Character.No_of_Items do
         If Can_Use (Character,Character.Item[Item]) then
            Begin
               Options:=Options+[CHR(Item+ZeroOrd)];
               SMG$Set_Cursor_ABS (OptionsDisplay,((Item+1) div 2),23-(22*(Item Mod 2)));
               SMG$Put_Chars (OptionsDisplay,
                  String(Item,1)
                  +') ');
               If Character.Item[Item].Ident then
                  SMG$Put_Chars (OptionsDisplay,Item_List[Character.Item[Item].Item_Num].True_Name)
               Else
                  SMG$Put_Chars (OptionsDisplay,Item_List[Character.Item[Item].Item_Num].Name);
            End;
   SMG$End_Display_Update (OptionsDisplay);
   Answer:=Make_Choice (Options);
   SMG$Label_Border (OptionsDisplay,
      '');
   If Answer=CHR(13) then
      Choose_Item_Num:=0
   Else
      Choose_Item_Num:=Ord(Answer)-ZeroOrd;
End;

(******************************************************************************)

Procedure Print_List_of_Spells (Character: Character_Type; Spell_Type: Integer);

Var
   Loop: Spell_Name;
   Level,X,Y: Integer;
   SpellList: Set of Spell_Name;
   Long_Spell: [External]Array [Spell_Name] of Varying[25] of Char;

[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;

Begin
   SMG$Begin_Display_Update (SpellListDisplay);
   SMG$Erase_Display (SpellListDisplay);
   Case Spell_Type of
      Wiz_Spell: Begin
                   SMG$Label_Border (SpellListDisplay,
                      ' '
                      +Character.Name
                      +'''s available wizard spells ',
                      SMG$K_TOP);
                   SpellList:=Character.Wizard_Spells;
                 End;
      Cler_Spell: Begin
                   SMG$Label_Border (SpellListDisplay,
                      ' '
                      +Character.Name
                      +'''s available cleric spells ',
                      SMG$K_TOP);
                   SpellList:=Character.Cleric_Spells;
                 End;
      Otherwise SpellList:=[];
   End;
   SpellList:=SpellList*Encounter_Spells;
   For Level:=1 to 9 do
      Begin
         If (Spell_Type=Wiz_Spell) and (Character.SpellPoints[Wiz_Spell,Level]=0) then
            Begin
               { TODO: This was cut off in the printout. $$$ }
               { SpellList:=SpellList-(WizSpells[Level]-Chara }
            End;
         If (Spell_Type=Cler_Spell) and (Character.SpellPoints[Cler_Spell,Level]=0) then
            Begin
               { TODO: This was cut off in the printout. $$$ }
               { SpellList:=SpellList-(ClerSpells[Level]-Cha }
            End;
      End;

   { SpellList now contains a set of all usable spells }

   If SpellList=[] then
      Begin
         Case Spell_Type of
            Cler_Spell: SMG$Put_Chars (SpellListDisplay,
               'Thou have no usable cleric spells.',,23);
            Wiz_Spell: SMG$Put_Chars (SpellListDisplay,
               'Thou have no usable wizard spells.',,23);
         End;
      End
   Else
      Begin
         X:=1;  Y:=1;
         For Loop:=CrLt to DetS do
            If Loop in SpellList then
               Begin
                  SMG$Put_Chars (SpellListDisplay,Long_Spell[Loop],y,x);
                  SMG$Put_Chars (SpellListDisplay,
                     ' ('
                     +Spell[Loop]
                     +')');
                  Y:=Y+1;
                  If Y>21 then
                     Begin
                        Y:=1;
                        X:=X+33;
                     End;
               End;
      End;
   SMG$Put_Chars (SpellListDisplay,'Press any key to continue...',22,23,1);
   SMG$End_Display_Update (SpellListDisplay);

   Case Spell_Type of
      Wiz_Spell: ;
      Otherwise  SMG$Paste_Virtual_Display (SpellListDisplay,Pasteboard,2,2); { TODO: This case statement is bizarre! $$$ }

      { TODO: Oh, I see. In List_Spells() below, we print the cleric spells first, so we paste it on the first call, which is
        for Cler_Spells. Ugly code, Jeff. Ugly code!!!

        We should do a Begin_Pasteboard_Update instead, or just move this code to the end of List_Spells(). }
   End;
   Wait_Key;
End;

(******************************************************************************)

Procedure List_Spells (Character: Character_Type);

Begin
   Print_List_of_Spells (Character,Cler_Spell);
   Print_List_of_Spells (Character,Wiz_Spell);
   SMG$Put_Chars (OptionsDisplay,' ',3,5); { Get rid of Question mark }
   SMG$Unpaste_Virtual_Display (SpellListDisplay,Pasteboard);
End;

(******************************************************************************)

Procedure Select_Combat_Spell (Var SpellChosen: Spell_Name;  Character: Character_Type);

Var
   SpellName: Line;
   Done: Boolean;
   Location,Loop: Spell_Name;
   Long_Spell: [External]Array [Spell_Name] of Varying[25] of Char;

Begin
  Done:=False;
  Location:=NoSp;
  SpellName:='';
  Repeat
     Begin
        SMG$Set_Cursor_ABS (OptionsDisplay,3,1);
        Cursor;
        SMG$Read_String (Keyboard,SpellName,Display_Id:=OptionsDisplay,
           Prompt_String:='--->');
        No_Cursor;
        If SpellName<>'?' then
           Begin
              For Loop:=CrLt to DetS do
                 If (STR$Case_Blind_Compare(Spell[Loop]+'',SpellName)=0) or
                    (STR$Case_Blind_Compare(Long_Spell[Loop]+'',SpellName)=0) then
                       Location:=Loop;
              Done:=True;
           End
        Else
           List_Spells (Character);
     End;
  Until Done;
  SpellChosen:=Location;
End;

(******************************************************************************)

Procedure Character_Berserks (Var Stats: Attacker_Type; Var Flee: Boolean; Group: Encounter_Group);

Begin
   Stats.Action:=Berserker_Rage;
   Stats.WhatSpell:=NoSp;
   Flee:=False;
   Stats.Target_Group:=1;
End;

(******************************************************************************)

Procedure Character_Runs (Var Stats: Attacker_Type; Var Flee: Boolean);

Begin
  Stats.Action:=Run;
  Stats.Target_Group:=1;
  Stats.WhatSpell:=NoSp;
  Flee:=True;
End;


(******************************************************************************)

Procedure Character_Parries (Var Stats: Attacker_Type; Var Flee: Boolean);

Begin
  Stats.Action:=Parry;
  Stats.Target_Group:=1;
  Stats.WhatSpell:=NoSp;
  Flee:=False;
End;

(******************************************************************************)

Procedure Character_Fights (Var Stats: Attacker_Type; Group: Encounter_Group; Var Flee: Boolean;  Var Take_Back: Boolean);

Var
   T: Line;
   DoAgain: Boolean;
   GroupNum: Integer;

Begin
   Flee:=False;
   If Group[2].Curr_Group_Size>0 then
      Begin
         SMG$Begin_Display_Update (OptionsDisplay);
         SMG$Erase_Display (OptionsDisplay);
         T:='Attack which group?';
         SMG$Put_Chars (OptionsDisplay,T,3,27-(T.Length div 2));
         SMG$End_Display_Update (OptionsDisplay);
         DoAgain:=False;
         Repeat
            Begin
               Repeat
                  Zero_through_Six (GroupNum)
               Until (GroupNum<3);
               If GroupNum=0 then
                  Take_Back:=True
               Else
                  DoAgain:=(Group[GroupNum].Curr_Group_Size=0);
            End;
         Until Not DoAgain;
      End
   Else
      GroupNum:=1;

   Stats.Action:=Attack;
   Stats.Target_Group:=GroupNum;
   Stats.WhatSpell:=NoSp;
End;

(******************************************************************************)

Procedure Spell_Mistake (Message: Line; Var Take_Back: Boolean);

Begin
   Take_Back:=True;
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Put_Chars (OptionsDisplay,Message,3,1+27-(Message.Length div 2));
   SMG$End_Display_Update (OptionsDisplay);
   Delay (2.5);
End;

(******************************************************************************)

Procedure Character_Casts_a_Spell (Var Stats: Attacker_Type; Group: Encounter_Group; Var Member: Party_Type;
                                           Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                                           Var Fee,Take_Back: Boolean; Character_Number: Integer);

Var
  Spell_Chosen: Spell_Name;
  Character: Character_Type;
  Class,Level: Integer;

[External]Procedure Find_Spell_Group (Spell: Spell_Name; Character: Character_Type; Var Class,Level: Integer);external;
[External]Function Caster_Level (Cls: Integer; Character: Character_Type):Integer;external;

Begin
   Character:=Member[Stats.Attacker_Position];
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Put_Chars (OptionsDisplay,
       'Cast what spell? (''?'' lists)',2,1);
   Select_Combat_Spell (Spell_Chosen, Character);

   Stats.Action:=CastSpell;
   Stats.WhatSpell:=NoSp;
   Stats.Target_Group:=0;
   Stats.WhatSpell:=Spell_Chosen;

   If Spell_Chosen=NoSp then
      Spell_Mistake (
         '* * * What? * * *',
         Take_Back)
   Else
      If Spell_Chosen=ReDo then
         Take_Back:=True
      Else
         Begin
            Find_Spell_Group (Spell_Chosen,Character,Class,Level);
            Take_Back:=Not(Spell_Chosen in Character.Cleric_Spells+Character.Wizard_Spells);
            Take_Back:=Take_Back or ((Class<>Cler_Spell) and (Class<>Wiz_Spell)) or (Level=0) or (Level=10);
            If Take_Back then
               Spell_Mistake (
                  '* * * Thou don''t know that spell * * *',Take_Back)
            Else
               If Character.SpellPoints[Class,Level]<1 then
               Spell_Mistake (
                  '* * * Spell Points exhausted * * *',Take_Back)
            Else
               If Not (Spell_Chosen in Encounter_Spells) then
                  Spell_Mistake (
                     '* * * Thou can''t cast that now! * * *',Take_Back)
               Else
                  Begin
                     Get_Spell_Info (Spell_Chosen,Group,Character_Number,Current_Party_Size,Party_Size,Stats.Target_Group,
                                     Stats.Target_Individual,Take_Back);
                     Stats.Caster_Level:=Caster_Level (Class,Character);
                  End;
         End;
End;

(******************************************************************************)

Function More_Than_One_Active_Group (Group: Encounter_Group): Boolean;

Begin
   More_Than_One_Active_Group:=Group[2].Curr_Group_Size > 0;
End;


(******************************************************************************)

Procedure Character_Turns_Undead (Var Stats: Attacker_Type; Group: Encounter_Group; Var Flee,Take_Back: Boolean);

Var
   T: Line;
   GroupNum: Integer;

Begin
   Flee:=False;

   if More_Than_One_Active_Group(Group) then
      Begin
         SMG$Begin_Display_Update (OptionsDisplay);
         SMG$Erase_Display (OptionsDisplay);
         T:='Turn which group?';
         SMG$Put_Chars (OptionsDisplay,T,3,27-(T.Length div 2));
         SMG$End_Display_Update (OptionsDisplay);
         Repeat
            Zero_Through_Six (GroupNum)
         Until (GroupNum=0) or ((Group[GroupNum].Curr_Group_Size>0) and (GroupNum<3));
         Take_Back:=(GroupNum=0);
      End
   Else
      GroupNum:=1;

   Stats.Action:=TurnUndead;
   Stats.Target_Group:=GroupNum;
   Stats.WhatSpell:=NoSp;
End;

(******************************************************************************)

Procedure Character_Uses_Item (Var Stats: Attacker_Type; Group: Encounter_Group; Var Member: Party_Type;
                                  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                                  Var Flee,Take_Back: Boolean;  Character_Number: Integer);

Var
   Character: Character_Type;
   Item_Choice: Integer;

Begin { Use an item }
  Take_Back:=False;
  Stats.WhatSpell:=NoSp;
  Character:=Member[Character_Number];
  Item_Choice:=Choose_Item_Num (Character);
  If Item_Choice>0 then
     Begin
        Stats.WhatSpell:=Item_List[Character.Item[Item_Choice].Item_Num].Spell_Cast;
        Get_Spell_Info (Stats.WhatSpell,Group,Character_Number,Current_Party_Size,Party_Size,Stats.Target_Group,
                        Stats.Target_Individual,Take_Back);
        Stats.Action:=UseItem;
        Stats.Caster_Level:=8;
        Stats.Old_Item:=Item_Choice;
        Member[Character_Number]:=Character;
     End
  Else
     Take_Back:=True;
End;

(******************************************************************************)

Procedure Character_Is_Berserk (Var Stats: Attacker_Type;  Group: Encounter_Group;  Var Flee: Boolean;  Number: Integer);

Begin
   Stats.WhatSpell:=NoSp;
   If Number=1 then
      Begin
         Stats.Action:=Attack;
         Stats.Target_Group:=1;
      End
   Else
      Begin
         Stats.Action:=Parry; { Parries as he makes his way to the front }
         Stats.Target_Group:=0;
      End
End;

(******************************************************************************)

Function Can_Equip (Character: Character_Type; Stats: Equipment_Type;  Classes: ClassSet): Boolean;

Var
   Temp: Boolean;

Begin
   Temp:=(Character.Class in Item_List[Stats.Item_Num].Usable_By); { If usable }
   Temp:=Temp or (Character.PreviousClass in Item_List[Stats.Item_Num].Usable_By);

   If Item_List[Stats.Item_Num].Alignment<>NoAlign then
      Temp:=Temp and (Character.Alignment=Item_List[Stats.Item_Num].Alignment);

   Temp:=Temp and (Item_List[Stats.Item_Num].Kind in [Weapon,Ring,Helmet]*Classes);
   Can_Equip:=Temp;
End;

(******************************************************************************)

Procedure Unequipp_Ring (Var Stats: Attacker_Type; Character: Character_Type);

Var
   Item: Integer;

Begin
   Stats.New_Item:=0;
   Stats.Old_Item:=0;
   If Character.No_of_Items>0 then
      For Item:=1 to Character.No_of_Items do
         If Item_List[Character.Item[Item].Item_Num].Kind=Ring then
            Stats.Old_Item:=Item;
End;

(******************************************************************************)

Procedure Unequipp_Weapon (Var Stats: Attacker_Type; Character: Character_Type);

Var
   Item: Integer;

Begin
   Stats.New_Item:=0;
   Stats.Old_Item:=0;
   If Character.No_of_Items>0 then
      For Item:=1 to Character.No_of_Items do
         If Item_List[Character.Item[Item].Item_Num].Kind=Weapon then
            Stats.Old_Item:=Item;
End;

(******************************************************************************)

Procedure Character_Changes_Items (Var Stats: Attacker_Type; Character: Character_Type;  Var Redo: Boolean);

Var
  Choice: Integer;
  Answer: Char;
  Options: Char_Set;
  Item: Integer;
  One_Usable: Boolean;
  T: Line;
  Classes: ClassSet;

Begin
   Stats.Action:=SwitchItems;
   Classes:=[Weapon,Ring];
   One_Usable:=False;
   Options:=[CHR(13)];
   If Character.No_of_items>0 then
      For Item:=1 to Character.No_of_items do
         If Character.Item[Item].Cursed then
            Classes:=Classes-[Item_List[Character.Item[Item].Item_Num].Kind];

   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Label_Border (OptionsDisplay,
      '[RETURN] exits',SMG$K_BOTTOM);
   SMG$Put_Line (OptionsDisplay,
       'Equip which item? (R=No Ring, W=No Weapon)');
   T:='';
   If Character.No_of_Items>0 then
      Begin
         For Item:=1 to Character.No_of_items do
            Begin
               If (Item mod 2)<>0 then
                  T:=''  { Beginning of a new line }
               Else
                  T:=T+'     ';
               If Can_Equip (Character,Character.Item[Item],Classes) then
                  Begin
                     If Character.Item[Item].Equipted then
                        T:=T+'*) '
                     Else
                        Begin
                           Options:=Options+[CHR(Item+ZeroOrd)];
                           T:=T+String (Item,1)
                              +') ';
                           One_Usable:=True;
                        End;
                     If Character.Item[Item].Ident then
                        T:=T+Item_List[Character.Item[Item].Item_Num].True_Name
                     Else
                        T:=T+Item_List[Character.Item[Item].Item_Num].Name;
                  End
               Else
                  T:=T+'                       ';
               If (Item mod 2)=0 then
                  Begin
                     SMG$Put_Line (OptionsDisplay,T);
                     T:='';
                  End;
            End;
      End;
   If (Character.No_of_Items) mod 2<>0 then
      SMG$Put_Line (OptionsDisplay,T,0);
   If Not One_Usable then
      Begin
         T:='Thou have no items that thou can equip.';
         SMG$Set_Cursor_ABS (OptionsDisplay,3,27-(t.Length div 2));
         SMG$Put_Line (OptionsDisplay,T);
      End;
   SMG$End_Display_Update (OptionsDisplay);
   Options:=Options+['R','W'];
   Answer:=Make_Choice (Options);
   SMG$Label_Border (OptionsDisplay,'');
   ReDo:=False;
   If Answer=CHR(13) then
      ReDo:=True
   Else
      If Answer='W' then
         Unequipp_Weapon (Stats,Character)
      Else
         If Answer='R' then
            Unequipp_Ring (Stats,Character)
         Else
            Begin
               Choice:=Ord(Answer)-ZeroOrd;
               Stats.New_Item:=Choice;
               If Character.No_of_Items>0 then
                  For Item:=1 to Character.No_of_Items do
                     If Item<>Choice then
                        If Item_List[Character.Item[Choice].Item_Num].Kind=Item_List[Character.Item[Item].Item_Num].Kind then
                           Stats.Old_Item:=Item;
            End;
End;

(******************************************************************************)

Function Has_Spell_Points (Character: Character_Type): Boolean;

Var
  Y,X: Integer;
  Temp: Boolean;

Begin
  Temp:=False;
  For Y:=1 to 2 do { type of spell }
     For X:=1 to 9 do
        Temp:=Temp or (Character.SpellPoints[Y,X]>0);
  Has_Spell_Points:=Temp;
End;

(******************************************************************************)

Function Has_Spells (Character: Character_Type): Boolean;

Var
  Temp: Boolean;

Begin
   Temp:=(Character.Wizard_Spells+Character.Cleric_Spells)<>[];
   Temp:=Temp and Has_Spell_Points (Character);
   Has_Spells:=Temp;
End;

(******************************************************************************)

Procedure Print_Fight_Option (Option: Line; Var Y,X: Integer);

Begin
   SMG$Put_Chars (OptionsDisplay,Option,Y,X);
   X:=X+11;
   If X>44 then
      Begin
         X:=1;
         Y:=Y+1;
      End;
End;

(******************************************************************************)

Procedure Print_Combat_Help;

Var
  HelpMeDisplay: Unsigned;

[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;

Begin
   SMG$CREATE_VIRTUAL_DISPLAY (22,78,HelpMeDisplay,1);
   SMG$ERASE_DISPLAY (HelpMeDisplay);

   SMG$PUT_LINE (HelpMeDisplay,'Combat Options:',2);
   SMG$PUT_LINE (HelpMeDisplay,' Fight       - This allows you to engage in hand-to-hand combat with a');
   SMG$PUT_LINE (HelpMeDisplay,'               monster in the first two ranks.');
   SMG$PUT_LINE (HelpMeDisplay,' Parry       - Perform no action for this round, but just defend');
   SMG$PUT_LINE (HelpMeDisplay,'               against attacks.');
   SMG$PUT_LINE (HelpMeDisplay,' Use Item    - Invoke the magic (if any) of an item owned by the character.');
   SMG$PUT_LINE (HelpMeDisplay,' Change Item - Allows the character to put down one item and/or pick up one.');
   SMG$PUT_LINE (HelpMeDisplay,' Berserk     - Allows a barbarian to go into a battle range. Once a char-');
   SMG$PUT_LINE (HelpMeDisplay,'               acter has gone berserk, he/she can not stop until he/she is');
   SMG$PUT_LINE (HelpMeDisplay,'               rendered incapable, or all enemies are dead.');
   SMG$PUT_LINE (HelpMeDisplay,' Turn        - Allows a character with clerical abilities to attempt to');
   SMG$PUT_LINE (HelpMeDisplay,'               dispel undead creatures or creatures from other planes.');
   SMG$PUT_LINE (HelpMeDisplay,' Spell       - Allows a spell-using character to cast a spell he/she knows.');
   SMG$PUT_LINE (HelpMeDisplay,' Run         - Allows the leader of the group to turn tail and run, dragging');
   SMG$PUT_LINE (HelpMeDisplay,'               the rest of the part with him/her.  Attempting to run does');
   SMG$PUT_LINE (HelpMeDisplay,'               not ensure a getaway. If you do not get away, the monsters');
   SMG$PUT_LINE (HelpMeDisplay,'               will have a free round of attacks.');
   SMG$PUT_LINE (HelpMeDisplay,'',3);
   SMG$PUT_LINE (HelpMeDisplay,'Press any key to continue...');
   SMG$PASTE_VIRTUAL_DISPLAY (HelpMeDisplay,Pasteboard,2,2);
   Wait_Key;
   SMG$UNPASTE_VIRTUAL_DISPLAY (HelpMeDisplay,Pasteboard);
   SMG$DELETE_VIRTUAL_DISPLAY (HelpMeDisplay);
End;

(******************************************************************************)

{ TODO: Enter this code }

(******************************************************************************)

Procedure Insert_Monster_Attacks (Var Group: Encounter_Group; Var Attacks: PriorityQueue);

Var
  Mon_Group,Monster,Dex_Adj: Integer;
  Individual: Attacker_Type;
  Monster_Rec: Monster_Record;

Begin
   For Mon_Group:=1 to 4 do
      If Group[Mon_Group].Curr_Group_Size>0 then
         Begin
            Monster_Rec:=Group[Mon_Group].Monster;
            For Monster:=1 to Group[Mon_Group].Curr_Group_Size do
               Begin
                  Dex_Adj:=Monster_Rec.No_of_attacks+(-1 * (10-Monster_Rec.Armor_Class)); { TODO: Make a function }
                  Individual.Priority:=Roll_Die (6000)-(Dex_Adj*400)-(Monster_Rec.Hit_Points.X*200); { TODO: Make a function }

                  Individual.Caster_Level:=Monster_Rec.Hit_Points.X;
                  Individual.Group:=Mon_Group;
                  Individual.Attacker_Position:=Monster;
                  Insert (Individual,Attacks);
               End;
         End;
End;

{ TODO: Enter this code }

(******************************************************************************)

Procedure Friendly_Monsters (Lead_Monster: Monster_Group;  Var Killer_Party: Boolean; Var NotSurprised: Boolean;
                             Var Member: Party_Type;  Current_Party_Size: Integer);

{ This procedure handles friendly monsters. It gives a party a chance to attack the monsters anyway, and if this is the case,
  KILLER_PARTY is set to be true. }

Var
   Peace: Char;
   DummyName: Line;

Begin
   NotSurprised:=True;  { By being friendly, they blew their chance of surprise }
   Print_Hailing (Lead_Monster);
   Peace:=Make_Choice (['F','L']); { F)ight or L)eave in peace }
   If Insane_Leader (Member,DummyName) then
      Begin
         If Peace='F' then
            SMG$Put_Line (MessageDisplay,
                DummyName
                +' charges ahead of thee into battle!')
         Else
            SMG$Put_Line (MessageDisplay,
                DummyName
                +' charges insanely into battle!');
         Peace:='F';
         Delay(1);
      End;
   Killer_Party:=(Peace='F');
   If Killer_Party then Alignment_Drift (Evil,Member,Current_Party_Size)
   Else                 Alignment_Drift (Good,Member,Current_Party_Size);
End;



(******************************************************************************)

Procedure Init_Combat_Display (Var Encounter: Encounter_Group);

Var
   Pic_Number: Pic_Type;

{ This procedure initializes the screen for combat-mode }

Begin { Init Combat Display }
   Pic_Number:=Encounter[1].Monster.Picture_Number;
   Show_Monster_Image (Pic_Number,FightDisplay);
   SMG$Erase_Display (MonsterDisplay);
   SMG$Erase_Display (MessageDisplay);

   SMG$Paste_Virtual_Display (FightDisplay,Pasteboard,ViewY,ViewX);
   SMG$Paste_Virtual_Display (MonsterDisplay,Pasteboard,MonY,MonX);
End;  { Init Combat Display }

(******************************************************************************)

Procedure Restore_Screen;

{ This procedure restores the non-combat mode to the pasteboard, by removing combat-oriented displays.  If LEAVE_MAZE is true
  (because of death, WOrd of REcall, or other reason), all of the maze displays are removed. }

Begin
   SMG$Erase_Display (MessageDisplay);
   SMG$Begin_Pasteboard_Update (Pasteboard);
   SMG$Unpaste_Virtual_Display (MonsterDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (FightDisplay,Pasteboard);
   If Leave_Maze then
      Begin
        SMG$Unpaste_Virtual_Display (OptionsDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (CharacterDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (CommandsDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (SpellsDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (MessageDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (MonsterDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (ViewDisplay,Pasteboard);
      End;
   SMG$End_Pasteboard_Update (Pasteboard);
End;

(******************************************************************************)

Procedure Combat_Over (Var Member: Party_Type;  Current_Party_Size: Party_Size_Type);

{ This procedure ties up loose ends in the combat module, such as deleting the created display, and returning characters to their
  non-combat state (e.g. no longer berserking) }

Var
   Character: Integer;

Begin { Combat Over }
   Restore_Screen;                                  { Remove all the combat-oriented displays }
   SMG$Delete_Virtual_Display (SpellListDisplay);   { Get rid of the temp }

   { Turn characters back to their non-combat state }

   If Current_Party_Size>0 then
      For Character:=1 to Current_Party_Size do
         Begin
            Compute_AC_and_Regenerates (Member[Character]);
            Member[Character].Attack.Berserk:=False;
            If Member[Character].Status=Afraid then
               Member[Character].Status:=Healthy;
         End;
End;  { Combat Over }

(******************************************************************************)

[Global]Procedure Run_Encounter (Monster_Number:Integer;  Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                                 Party_Size: Integer;  Var Alarm_Off: Boolean;  Location: Area_Type:=Corridor;
                                 NoMagic: Boolean:=False;  Var Time_Delay: Integer);

{ This procedure will run  the combat simulation. }

Var
   Homicidal_Party: Boolean;
   Encounter: Encounter_Group;
   Monster_Reaction: Reaction_Type;
   Can_Attack: Party_Flag;

Begin { Run Encounter }
   Homicidal_Party:=False;
   Initialize (Member,Current_Party_Size,Party_Size,Can_Attack,Alarm_Off,Time_Delay);
   Init_Encounter (Monster_Number,Encounter,Member,Current_Party_Size);
   Init_Combat_Display (Encounter);
   Monster_Reaction:=Reaction (Encounter[1].Monster,Member,Party_Size);  { How do the monsters react? }

   { Handle friendly monsters }

   If Monster_Reaction=Friendly then
      Friendly_Monsters (Encounter[1],Homicidal_Party,NotSurprised,Member,Current_Party_Size);

   { Handle combat if necessary }

   If (Monster_Reaction=Hostile) or Homicidal_Party then
       Fight (Encounter,Member,Current_Party_Size, Party_Size,
           NotSurprised,Location,Time_Delay,Alarm_Off,Can_Attack);

   Combat_Over (Member,Current_Party_Size);  { Restore things to non-combat }
End;  { Run Encounter }
End.  { Encounter }

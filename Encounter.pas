(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','StrRtl','PriorityQueue')]Module Encounter;

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
                    PosX: Horizontal_Type;
PosY: Horizontal_Type;
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
[External]Function Get_Num (Display: Unsigned): Integer;External;
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
[External]Function Empty (A: PriorityQueue): Boolean;External;
[External]Procedure MakeNull (Var A: PriorityQueue);External;
[External]Function P (A: AttackerType): Integer;External;
[External]Procedure Insert (X: AttackerType; Var A: PriorityQueue);External;
[External]Function DeleteMin (Var A: PriorityQueue): AttackerType;External;
[External]Function Read_Items: [Volatile]List_of_Items;External;
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
         Index:=Index + 1;
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
   SMG$Put_Chars (MessageDisplay, 'An encounter...',2,1,,1);
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
      Index:=Index + 1;
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
   Temp: Integer;
Loop: Integer;

Begin { Number Active }
   Temp:=0;
   For Loop:=1 to Group.Curr_Group_Size do
      If Group.Status[Loop] in [Healthy,Poisoned,Afraid,Zombie] then
         Temp:=Temp + 1;
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
             CHR(Group_Number + ZeroOrd)
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
   TempMax: Integer;
   TempCurr: Integer;

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
          Group.Curr_Group_Size:=Group.Curr_Group_Size + 1;
          Slot:=Slot + 1;
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
            SMG$Put_Chars (Display,Pic.Eye_Type+'',Pic.Right_Eye.Y + 0,Pic.Right_Eye.X + 0);
         If (Pic.Left_Eye.X>0) and (Pic.Left_Eye.Y>0) then
            SMG$Put_Chars (Display,Pic.Eye_Type+'',Pic.Left_Eye.Y + 0,Pic.Left_Eye.X + 0);
      End;
   SMG$End_Display_Update (Display);
End;

(******************************************************************************)

Procedure They_Advance (Name: Monster_Name_Type);

Begin
   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Line (MessageDisplay, 'The ' + Name + ' advance!');
   SMG$End_Display_Update (MessageDisplay);
   Ring_Bell (MessageDisplay, 2);
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
   i: Integer;
   j: Integer;
   Name: Monster_Name_Type;
   Advance: Boolean;

Begin
   Print_Monsters (Group);
   For i:=1 to 3 do
      For j:=4 downto i + 1 do
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
     If Attacker.Item[Item_num].isEquipped then
        If Item_List[Attacker.Item[Item_Num].Item_Num].autoKill then { TODO: Make the items stack so multiple items equals better chance of critical }
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
   Base: Integer;
   Attacker_Level: Integer;

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
   Constitution: Integer;
   Luck: Integer;
   Race: Race_Type;
   Temp: Integer;

Begin
   Temp:=0;  Race:=Character.Race;  Constitution:=Character.Abilities[5];  Luck:=Character.Abilities[7];

   If Attack=Poison then
      If Race in [LizardMan,HfOgre,Dwarven,Hobbit] then
         Temp:=Temp + Trunc (Constitution / 3.5)
      Else
         If (Constitution>18) then
            Temp:=Temp+(Constitution-18);

   If (Race in [Dwarven,Hobbit]) and (Attack in [Magic,Death,CauseFear]) then
      Temp:=Temp + Trunc (Constitution / 3.5);

   Temp:=Temp + Luck_Adjustment (Luck);

   Natural_Adjustment:=Temp;
End;

(******************************************************************************)

Function Magical_Adjustment (Character: Character_Type; Attack: Attack_Type): Integer;

Var
   Temp: Integer;
   Item_No: Integer;

Begin
   Temp:=0;
   If Character.No_of_Items>0 then
      For Item_No:=1 to Character.No_of_Items do
          If Character.Item[Item_No].isEquipped then
             If (Attack in Item_List[Character.Item[Item_No].Item_Num].Resists) or
                ((Attack in [Stoning,LvlDrain]) and (Magic in Item_List[Character.Item[Item_No].Item_Num].Resists)) then
                   Temp:=Temp + 1;
   Magical_Adjustment:=Temp;
End;

(******************************************************************************)

Function Class_Save (Class: Class_Type; Level: Integer): Integer;

Var
   Temp: Integer;

Begin
   Case Class of
       Cleric,Monk:                                Temp:=10 - (((Level - 1) div 3));
       Fighter,Ranger,Samurai,Paladin,AntiPaladin: Temp:=10 - (((Level - 1) div 2));
       Wizard:                                     Temp:=11 - (((Level - 1) div 5));
       Thief,Ninja,Assassin,Bard:                  Temp:=11 - (((Level - 1) div 4));
       Otherwise                                   Temp:=12 - (((Level - 1) div 5));
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
       Poison: If Class=Assassin then
                  Class_Adjustment:=1;
       Magic:  If Class=Wizard then
                  Class_Adjustment:=1;
       Death:  If Class=AntiPaladin then
                  Class_Adjustment:=1;
       CauseFear: If Class=AntiPaladin then
                     Class_Adjustment:=-3
                  Else If Class=Barbarian then
                     Class_Adjustment:=5;
       Aging,Sleep: If Class=Monk then
                      Class_Adjustment:=1;
  End;
End;

(******************************************************************************)

Function Saving_Throw (Character: Character_Type; Attack: Attack_Type): Integer;

Var
   Roll_Needed: Integer;

Begin
   Roll_Needed:=Base_Save (Character);
   Roll_Needed:=Roll_Needed
       - Natural_Adjustment (Character,Attack)
       - Magical_Adjustment (Character,Attack)
       - Class_Adjustment (Character.Class,Attack)
       - Class_Adjustment (Character.PreviousClass,Attack);
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
        Cleric:                                                    Class_Base_Chance:=10 - (2 * ((level - 1) div 3));
        Fighter,Ranger,Monk,Samurai,Barbarian,Paladin,AntiPaladin: Class_Base_Chance:=10 - (2 * ((level - 1) div 2));
        Wizard:                                                    Class_Base_Chance:=11 - (2 * ((level - 1) div 5));
        Thief,Assassin,Bard:                                       Class_Base_Chance:=11 - (2 * ((level - 1) div 4));
        Otherwise                                                  Class_Base_Chance:= 0;
   End;
End;

(******************************************************************************)

Function Weapon_Plus_To_Hit (Character: Character_Type; Kind: Monster_Type;  PosZ: Integer): Integer;

Var
   Temp_Item: Item_Record;
   Weapon_Plus: Integer;
   Item_No: Integer;
   Plus: Integer;

[External]Procedure Plane_Difference (Var Plus: Integer; PosZ: Integer);External; { TODO: Make this a function. }

Begin
   Weapon_Plus:=0;
   If Character.No_of_Items>0 then
      For Item_No:=1 to Character.No_of_Items do
         If Character.Item[Item_No].isEquipped then
            Begin
               Temp_Item:=Item_List[Character.Item[Item_No].Item_Num];
               Plus:=Temp_Item.Plus_To_Hit;
               If Kind in Temp_Item.Versus then
                  Plus:=Plus + (4 * Plus);
               Plane_Difference (Plus,PosZ);
               Weapon_Plus:=Weapon_Plus + Plus;
            End;
   Weapon_Plus_to_Hit:=Weapon_Plus;
End;

(******************************************************************************)

Function Strength_Plus_to_Hit (Strength: Integer): Integer;

Begin
   Case Strength of
                  3: Strength_Plus_to_Hit:=-3;
                4,5: Strength_Plus_to_Hit:=-2;
                6,7: Strength_Plus_to_Hit:=-1;
              8..14: Strength_Plus_to_Hit:=0;
                 15: Strength_Plus_to_Hit:=1;
              16,17: Strength_Plus_to_Hit:=2;
                 18: Strength_Plus_to_Hit:=3;
                 19: Strength_Plus_to_Hit:=4;
                 20: Strength_Plus_to_Hit:=5;
                 21: Strength_Plus_to_Hit:=6;
                 22: Strength_Plus_to_Hit:=7;
              23,24: Strength_Plus_to_Hit:=8;
                 25: Strength_Plus_to_Hit:=9;
           Otherwise Strength_Plus_to_Hit:=0;
   End;
End;

(******************************************************************************)

[Global]Function To_hit_Roll (Character: Character_Type; AC: Integer; Monster: Monster_Record): Integer;

Var
   Weapon_Plus: Integer;
   Temp: Integer;
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

[Global]Function Know_Monster (Monster_Number: Integer; Member: Party_Type; Current_Party_Size: Party_Size_Type): [Volatile]Boolean;

Var
   Chance: Integer;
   CharNo: Integer;
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
                      T:=T + ' is poisoned!'
                   Else
                      T:=T + ' is unaffected!';
                End;
        Stoning: Begin
                   Change_Status (Character,Petrified,Changed);
                   If Changed then
                      T:=T + ' is turned into stone!'
                   Else
                      T:=T + ' is unaffected!';
                 End;
        Death:   Begin
                    Change_Status (Character,Dead,Changed);
                    If Changed then
                       Begin
                          Slay_Character (Character,Can_Attack[CharNum]);
                          T:='';
                       End
                    Else
                       T:=T + ' is unaffected';
                  End;
        Insanity: Begin
                    Change_Status (Character,Insane,Changed);
                    If Changed then
                       T:=T + ' is driven mad!'
                    Else
                       T:=T + ' is unaffected!';
                  End;
        Aging:    Begin
                    Character.Age:=Character.Age+(Roll_Die (4) * 3650);
                    T:=T + ' is aged!';
                  End;
        Sleep:    Begin
                    Change_Status (Character,Asleep,Changed);
                    If Changed then
                       T:=T + ' is slept!'
                    Else
                       T:=T + ' is unaffected!';
                  End;
        CauseFear:Begin
                    Change_Status (Character,Afraid,Changed);
                    If Changed then
                       T:=T + ' is made afraid!'
                    Else
                       T:=T + ' is unaffected!';
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
   If T <> '' then
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
   Orig: Integer;
   Curr: Integer;
   Chance: Integer;

Begin
   Orig:=0; Curr:=0; Chance:=0;
   For GroupNum:=1 to 4 do
      Begin
         Orig:=Orig + Group[GroupNum].Orig_Group_Size;
         Curr:=Curr + Group[GroupNum].Curr_Group_Size;
      End;

   If (Current_Party_Size=0) or (Curr=0) or (Curr>(Current_Party_Size*2)) then
      Uh_Oh:=False
   Else
      Begin
         If Curr < (Orig * 3 / 4) then
            Chance:=Chance + 25;
         If Curr < (Orig * 1 / 2) then
            Chance:=Chance + 25;
         If Curr < (Orig * 1 / 4) then
            Chance:=Chance + 25;
         Uh_Oh:=Made_Roll(Chance);
      End;
End;

(******************************************************************************)
[External]Procedure Drain_Levels_from_Character (Var Character: Character_Type; Levels: Integer:=1);External;
[External]Procedure Handle_Monster_Attack (Attacker: AttackerType;  Var Monster_Group1: Encounter_Group;
                                                 Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                                                 Party_Size: Integer; Var Can_Attack: Party_Flag);external;
[External]Procedure Handle_Character_Attack (Attacker_Record: AttackerType; Var MonsterGroup: Encounter_Group;
                                             Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type);External;
(******************************************************************************)

Procedure Character_Attack (Attacker: AttackerType; Var Monster_Group: Encounter_Group; Var Member: Party_Type;
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

Procedure Monster_Attack (Attacker: AttackerType; Var Monster_Group: Encounter_Group; Var Member: Party_Type;
                                                Var Current_Party_Size: Party_Size_Type; Party_Size: Integer; Var Can_Attack: Party_Flag);

Begin
   If (Monster_Group[Attacker.Group].Status[Attacker.Attacker_Position]=Healthy) then
      Begin
         Handle_Monster_Attack (Attacker,Monster_Group,Member,Current_Party_Size,Party_Size,Can_Attack);
         Delay ((3/2) * Delay_Constant)
      End
End;

(******************************************************************************)

Procedure Handle_Attack (    Attacker: AttackerType;
                                 Var Monster_Group: Encounter_Group;
                                 Var Member: Party_Type;
                                 Var Current_Party_Size: Party_Size_Type;
                                     Party_Size: Integer;
                                 Var Can_Attack: Party_Flag);

Begin
   SMG$Erase_Display (MessageDisplay);
   If (attacker.Group = 5) and (Not Time_Stop_Players) then
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
   Next: AttackerType;
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
         If Next.Group<>0 then
             Handle_Attack (Next,Monster_Group,Member,Current_Party_Size,Party_Size,Can_Attack);
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
              Done:=(Temp < 5); { TODO: This is lazy programming }
              If Done and (Temp > 0) then
                 Done:=Done and (Group[Temp].Curr_Group_Size>0);
              If Done and (Temp > 0) then
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
   If Current_Party_Size > 1 then
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
   Else If Spell in Party_Spell + All_Monsters_Spell + Area_Spell then
      Group1:=5
   Else If Spell in Group_Spell then
      Get_Group_Number (Group,Group1,Take_Back)
   Else If Spell in Person_Spell then
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

   Temp:=Temp and (Stats.isEquipped or (Item_List[Stats.Item_Num].Kind=Scroll));
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
   SMG$Label_Border (OptionsDisplay, 'Use which item? ([RETURN] exits)', SMG$K_BOTTOM);

   If Character.No_of_Items>0 then
      For Item:=1 to Character.No_of_Items do
         If Can_Use (Character,Character.Item[Item]) then
            Begin
               Options:=Options+[CHR(Item + ZeroOrd)];
               SMG$Set_Cursor_ABS (OptionsDisplay,((Item + 1) div 2),23-(22*(Item Mod 2)));
               SMG$Put_Chars (OptionsDisplay, String(Item,1) + ') ');
               If Character.Item[Item].Ident then
                  SMG$Put_Chars (OptionsDisplay,Item_List[Character.Item[Item].Item_Num].True_Name)
               Else
                  SMG$Put_Chars (OptionsDisplay,Item_List[Character.Item[Item].Item_Num].Name);
            End;

   SMG$End_Display_Update (OptionsDisplay);

   Answer:=Make_Choice (Options);
   SMG$Label_Border (OptionsDisplay, '');
   If Answer = CHR(13) then
      Choose_Item_Num:=0
   Else
      Choose_Item_Num:=Ord(Answer) - ZeroOrd;
End;

(******************************************************************************)

Procedure Print_List_of_Spells (Character: Character_Type; Spell_Type: Integer);

Var
   Loop: Spell_Name;
   Level: Integer;
   X: Integer;
   Y: Integer;
   SpellList: Set of Spell_Name;
   Long_Spell: [External]Array [Spell_Name] of Varying[25] of Char;

[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;

Begin
   SMG$Begin_Display_Update (SpellListDisplay);
   SMG$Erase_Display (SpellListDisplay);

   Case Spell_Type of
      Wiz_Spell: Begin
                   SMG$Label_Border (SpellListDisplay, ' ' + Character.Name + '''s available wizard spells ', SMG$K_TOP);
                   SpellList:=Character.Wizard_Spells;
                 End;
      Cler_Spell: Begin
                   SMG$Label_Border (SpellListDisplay, ' ' + Character.Name +'''s available cleric spells ', SMG$K_TOP);
                   SpellList:=Character.Cleric_Spells;
                 End;
      Otherwise SpellList:=[ ];
   End;
   SpellList:=SpellList*Encounter_Spells;

   For Level:=1 to 9 do
      Begin
         If (Spell_Type = Wiz_Spell) and (Character.SpellPoints[Wiz_Spell,Level] = 0) then
           SpellList:=SpellList - (WizSpells[Level] - Character.Cleric_Spells);
         If (Spell_Type = Cler_Spell) and (Character.SpellPoints[Cler_Spell,Level] = 0) then
           SpellList:=SpellList - (ClerSpells[Level] - Character.Wizard_Spells);
      End;

   { SpellList now contains a set of all usable spells }

   If SpellList = [ ] then
      Begin
         Case Spell_Type of
            Cler_Spell: SMG$Put_Chars (SpellListDisplay,'Thou have no usable cleric spells.',,23);
            Wiz_Spell:  SMG$Put_Chars (SpellListDisplay,'Thou have no usable wizard spells.',,23);
         End;
      End
   Else
      Begin
         X:=1;  Y:=1;
         For Loop:=MIN_SPELL_NAME to MAX_SPELL_NAME do
            If Loop in SpellList then
               Begin
                  SMG$Put_Chars (SpellListDisplay,Long_Spell[Loop],y,x);
                  SMG$Put_Chars (SpellListDisplay, ' (' +Spell[Loop] +')');
                  Y:=Y + 1;
                  If Y > 21 then
                     Begin
                        Y:=1;
                        X:=X + 33;
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
   Location: Spell_Name;
   Loop: Spell_Name;
   Long_Spell: [External]Array [Spell_Name] of Varying[25] of Char;

Begin
  Done:=False;
  Location:=NoSp;
  SpellName:='';
  Repeat
     Begin
        SMG$Set_Cursor_ABS (OptionsDisplay,3,1);

        Cursor;
        SMG$Read_String (Keyboard,SpellName,Display_Id:=OptionsDisplay, Prompt_String:='--->');
        No_Cursor;

        If SpellName <> '?' then
           Begin
              For Loop:=MIN_SPELL_NAME to MAX_SPELL_NAME do
                 If (STR$Case_Blind_Compare(Spell[Loop]+'',SpellName) = 0) or
                    (STR$Case_Blind_Compare(Long_Spell[Loop]+'',SpellName) = 0) then
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

Procedure Character_Berserks (Var Stats: AttackerType; Var Flee: Boolean; Group: Encounter_Group);

Begin
   Stats.Action:=Berserker_Rage;
   Stats.WhatSpell:=NoSp;
   Flee:=False;
   Stats.Target_Group:=1;
End;

(******************************************************************************)

Procedure Character_Runs (Var Stats: AttackerType; Var Flee: Boolean);

Begin
  Stats.Action:=Run;
  Stats.Target_Group:=1;
  Stats.WhatSpell:=NoSp;
  Flee:=True;
End;


(******************************************************************************)

Procedure Character_Parries (Var Stats: AttackerType; Var Flee: Boolean);

Begin
  Stats.Action:=Parry;
  Stats.Target_Group:=1;
  Stats.WhatSpell:=NoSp;
  Flee:=False;
End;

(******************************************************************************)

Procedure Character_Fights (Var Stats: AttackerType; Group: Encounter_Group; Var Flee: Boolean;  Var Take_Back: Boolean);

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
   SMG$Put_Chars (OptionsDisplay,Message,3,1 + 27-(Message.Length div 2));
   SMG$End_Display_Update (OptionsDisplay);
   Delay (2.5);
End;

(******************************************************************************)

Procedure Character_Casts_a_Spell (Var Stats: AttackerType; Group: Encounter_Group; Var Member: Party_Type;
                                           Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                                           Var Fee,Take_Back: Boolean; Character_Number: Integer);

Var
  Spell_Chosen: Spell_Name;
  Character: Character_Type;
  Class: Integer;
  Level: Integer;

[External]Procedure Find_Spell_Group (Spell: Spell_Name; Character: Character_Type; Var Class,Level: Integer);external;
[External]Function Caster_Level (Cls: Integer; Character: Character_Type):Integer;external;

Begin
   Character:=Member[Stats.Attacker_Position];
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Put_Chars (OptionsDisplay, 'Cast what spell? (''?'' lists)',2,1);
   SMG$End_Display_Update (OptionsDisplay);

   Select_Combat_Spell (Spell_Chosen, Character);

   Stats.Action:=CastSpell;
   Stats.WhatSpell:=NoSp;
   Stats.Target_Group:=0;
   Stats.WhatSpell:=Spell_Chosen;

   If Spell_Chosen=NoSp then
      Spell_Mistake ('* * * What? * * *', Take_Back)
   Else If Spell_Chosen=ReDo then
      Take_Back:=True
   Else
      Begin
        Find_Spell_Group (Spell_Chosen,Character,Class,Level);

        Take_Back:=Not(Spell_Chosen in Character.Cleric_Spells + Character.Wizard_Spells);
        Take_Back:=Take_Back or ((Class <> Cler_Spell) and (Class <> Wiz_Spell)) or (Level = 0) or (Level = 10);

        If Take_Back then
           Spell_Mistake ('* * * Thou don''t know that spell * * *',Take_Back)
        Else If Character.SpellPoints[Class,Level] < 1 then
           Spell_Mistake ('* * * Spell Points exhausted * * *',Take_Back)
        Else If Not (Spell_Chosen in Encounter_Spells) then
           Spell_Mistake ('* * * Thou can''t cast that now! * * *',Take_Back)
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

Procedure Character_Turns_Undead (Var Stats: AttackerType; Group: Encounter_Group; Var Flee,Take_Back: Boolean);

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

Procedure Character_Uses_Item (Var Stats: AttackerType; Group: Encounter_Group; Var Member: Party_Type;
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
  If Item_Choice > 0 then
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

Procedure Character_Is_Berserk (Var Stats: AttackerType;  Group: Encounter_Group;  Var Flee: Boolean;  Number: Integer);

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

Procedure Unequipp_Ring (Var Stats: AttackerType; Character: Character_Type);

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

Procedure Unequipp_Weapon (Var Stats: AttackerType; Character: Character_Type);

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

Procedure Character_Changes_Items (Var Stats: AttackerType; Character: Character_Type;  Var Redo: Boolean);

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
   Classes:=[ Weapon,Ring ];
   One_Usable:=False;
   Options:=[ CHR(13) ];
   If Character.No_of_items>0 then
      For Item:=1 to Character.No_of_items do
         If Character.Item[Item].Cursed then
            Classes:=Classes-[Item_List[Character.Item[Item].Item_Num].Kind];

   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Label_Border (OptionsDisplay,'[RETURN] exits',SMG$K_BOTTOM);

   SMG$Put_Line (OptionsDisplay, 'Equip which item? (R=No Ring, W=No Weapon)');

   T:='';
   If Character.No_of_Items>0 then
      Begin
         For Item:=1 to Character.No_of_items do
            Begin
               If (Item mod 2) <> 0 then
                  T:=''  { Beginning of a new line }
               Else
                  T:=T+'     ';
               If Can_Equip (Character,Character.Item[Item],Classes) then
                  Begin
                     If Character.Item[Item].isEquipped then
                        T:=T+'*) '
                     Else
                        Begin
                           Options:=Options+[CHR(Item + ZeroOrd)];
                           T:=T + String (Item,1) + ') ';
                           One_Usable:=True;
                        End;
                     If Character.Item[Item].Ident then
                        T:=T + Item_List[Character.Item[Item].Item_Num].True_Name
                     Else
                        T:=T + Item_List[Character.Item[Item].Item_Num].Name;
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

   Options:=Options + [ 'R', 'W' ];
   Answer:=Make_Choice (Options);

   SMG$Label_Border (OptionsDisplay,'');

   ReDo:=False;
   If Answer=CHR(13) then
      ReDo:=True
   Else If Answer='W' then
      Unequipp_Weapon (Stats,Character)
   Else If Answer='R' then
      Unequipp_Ring (Stats,Character)
   Else
      Begin
           Choice:=Ord(Answer)-ZeroOrd;
           Stats.New_Item:=Choice;
           If Character.No_of_Items>0 then
              For Item:=1 to Character.No_of_Items do
                 If Item<>Choice then
                    If Item_List[Character.Item[Choice].Item_Num].Kind = Item_List[Character.Item[Item].Item_Num].Kind then
                       Stats.Old_Item:=Item;
      End;
End;

(******************************************************************************)

Function Has_Spell_Points (Character: Character_Type): Boolean;

Var
  Y: Integer;
  X: Integer;
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
   Temp:=(Character.Wizard_Spells + Character.Cleric_Spells)<>[];
   Temp:=Temp and Has_Spell_Points (Character);
   Has_Spells:=Temp;
End;

(******************************************************************************)

Procedure Print_Fight_Option (Option: Line; Var Y,X: Integer);

Begin
   SMG$Put_Chars (OptionsDisplay,Option,Y,X);
   X:=X + 11;
   If X>44 then
      Begin
         X:=1;
         Y:=Y + 1;
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

Procedure Put_Options (Number: Integer; Var Options: Char_Set;  Member: Party_Type);

Var
  X: Integer;
Y: Integer;
  Character: Character_Type;
  Classes: Set of Class_Type;

Begin
   Character:=Member[Number];
   Classes:=[Character.Class]+[Character.PreviousClass];

   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Put_Line (OptionsDisplay,Member[Number].Name + CHR(39)+'s options:',2);
   Options:=[];  X:=1;  Y:=3;
   If (Number<4) and (Character.Status in [Healthy,Poisoned,Zombie]) then
      Begin
         Print_Fight_Option ('F)ight',Y,X);
         Options:=Options+['F'];
      End;
   If (Character.Status in [Healthy,Poisoned,Afraid,OnProbation]) then
      Begin
         Print_Fight_Option ('P)arry',Y,X);
         Print_Fight_Option ('U)se item',Y,X);
         Print_Fight_Option ('C)hange',Y,X);
         Options:=Options+['P','U','C'];
      End;
   If ((Classes * [Barbarian])<>[]) and (Character.Status in [Healthy,Poisoned]) then
      Begin
         Print_Fight_Option ('B)erserk',Y,X);
         Options:=Options+['B'];
      End;
   If ((Classes * [Cleric,Paladin,AntiPaladin])<>[]) and (Character.Status in [Healthy,Poisoned,OnProbation]) then
      Begin
         Print_Fight_Option ('T)urn',Y,X);
         Options:=Options+['T'];
      End;
   If Has_Spells(Character) and (Character.Status in [Healthy,Poisoned,OnProbation]) then
      Begin
         Print_Fight_Option ('S)pell',Y,X);
         Options:=Options+['S'];
      End;
   If (Number=1) and (Character.Status in [Healthy,Poisoned,Afraid,OnProbation]) then
      Begin
         Print_Fight_Option ('R)un',Y,X);
         Options:=Options+['R'];
      End;
   Print_Fight_Option ('? = Help',Y,X);
   Options:=Options+['?'];
   SMG$End_Display_Update (OptionsDisplay);
End;

(******************************************************************************)

Procedure Get_Character_Commands (Character_Number: Integer;  Var Stats: AttackerType;  Group: Encounter_Group;
                                         Member: Party_Type;  Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                                         Var Flee: Boolean);

Var
  Options: Char_Set;
  Answer: Char;
  Take_Back: Boolean;

Begin
  Stats.Attacker_Position:=Character_Number;
  Stats.Group:=5;
  If Not Member[Character_Number].Attack.Berserk then
     If (Character_Number=1) and (Member[Character_Number].Status=Afraid) and Made_Roll (35) then
        Character_Runs (Stats,Flee) { 35% chance afraid leaders will flee }
     Else
        Repeat
           Begin
              Take_Back:=False;
              Options:=[];

              Put_Options (Character_Number,Options,Member);
              Answer:=Make_Choice (Options);
              Case Answer of
                'B': Character_Berserks (Stats,Flee,Group);
                'C': Character_Changes_Items (Stats,Member[Character_Number],Take_Back);
                'R': Character_Runs (Stats,Flee);
                'P': Character_Parries (Stats,Flee);
                'F': Character_Fights (Stats,Group,Flee,Take_Back);
                'S': Character_Casts_a_Spell (Stats,Group,Member,Current_Party_Size,Party_Size,Flee,Take_Back,Character_Number);
                'T': Character_Turns_Undead (Stats,Group,Flee,Take_Back);
                'U': Character_Uses_Item (Stats,Group,Member,Current_Party_Size,Party_Size,Flee,Take_Back,Character_Number);
                '?': Begin
                        Print_Combat_Help;
                        Take_Back:=True;
                     End;
                Otherwise Take_Back:=True;
              End;
           End;
        Until Not (Take_Back)
  Else
     Character_is_Berserk (Stats,Group,Flee,Character_Number);
End;

(******************************************************************************)

Procedure Init_Options (Var Commands: Party_Commands_Type);

Var
   Person: Integer;

Begin
   For Person:=1 to 6 do
      Begin
         Commands[Person].Attacker_Position:=1;
         Commands[Person].Group:=5; { TODO: Create constant }
         Commands[Person].Action:=Parry;
         Commands[Person].Target_Group:=0;
      End;
End;

(******************************************************************************)

Procedure Change_Delay (Var Time_Delay: Integer);

Var
  Change: Integer;

Begin
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Line (MessageDisplay,'Current time delay: '+String(Time_Delay));
   SMG$Put_Chars (MessageDisplay,'New delay (0-999, -1 exits):');
   Change:=Get_Num(MessageDisplay);
   If (Change>-1) and (change<1000) then
      Time_Delay:=Change;
   SMG$Erase_Display (MessageDisplay);
   Delay_Constant:=Time_Delay/500;  { TODO: This is unexpected behavior. Abstract it to a method or class or something? }
End;

(******************************************************************************)

Function Return_or_Change (Var Time_Delay: Integer): [Volatile]Char;

Var
   Answer: Char;
   T: Line;

Begin
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);

   T:='T)ake back instructions, C)hange Time Delay';
   SMG$Put_Chars (OptionsDisplay,T,2,(54 div 2)-(T.Length div 2));

   T:='Turn combat M)essages '+Bool_String[Not Show_Messages]+', or [RETURN] to fight';
   SMG$Put_Chars (OptionsDisplay,T,3,(54 div 2)-(T.Length div 2));

   SMG$End_Display_Update (OptionsDisplay);

   Answer:=Make_Choice(['M', 'C', 'T', CHR(13)]);

   If Answer='C' then
      Change_Delay (Time_Delay)
   Else
     If Answer='M' then
        Show_Messages:=Not Show_Messages;

   Return_or_Change:=Answer;
End;

(******************************************************************************)

Procedure Get_Party_Commands (Var Commands: Party_Commands_Type;
                                          Group: Encounter_Group;
                                          Member: Party_Type;
                                          Current_Party_Size: Party_Size_Type;
                                          Party_Size: Integer;
                                      Var Flee: Boolean;
                                      Var Time_Delay: Integer;
                                      Var Can_Attack: Party_Flag);

Var
   Answer: Char;
   Person: Integer;
   Ready: Boolean;

Begin
   Init_Options (Commands);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Paste_Virtual_Display (OptionsDisplay,Pasteboard,SpellsY,SpellsX);
   Ready:=False;
   Answer:=' ';
   Repeat
      Begin
         For Person:=1 to Current_Party_Size do
            If Not (Flee) and (Can_Attack[Person]) then
                Get_Character_Commands (Person,Commands[Person],Group,Member,Current_Party_Size,Party_Size,Flee);
        If Not Flee then
           Repeat
              Answer:=Return_or_Change (Time_Delay);
           Until Not (Answer in ['C','M'])
        Else
           Ready:=True;
        Ready:=(Answer=CHR(13));
      End;
   Until Ready or Flee;
   SMG$Unpaste_Virtual_Display (OptionsDisplay,Pasteboard);
End;

(******************************************************************************)

Function Dex_Adjustment (Character: Character_Type): Integer;

Var
   Temp: Integer;

Begin
   Case Character.Abilities[4] of
         3: Temp:=-4;
         4: Temp:=-3;
         5: Temp:=-2;
         6: Temp:=-1;
         17: Temp:=1;
         18: Temp:=2;
         19: Temp:=3;
         20,21: Temp:=4;
         22,23: Temp:=5;
         24,25: Temp:=6;
         Otherwise Temp:=0;
   End;
   Dex_Adjustment:=Temp*500;
End;

(******************************************************************************)

Function Character_Priority (Character: Character_Type): [Volatile]Integer;

Var
   Level: Integer;

Begin
   Level:=Max(Character.Level,Character.Previous_Lvl);
   Character_Priority:=Roll_Die (6000)-Dex_Adjustment (Character)-(Level*200);
End;

(******************************************************************************)

Procedure Insert_Character_Action (Individual: AttackerType;  Var Attacks: PriorityQueue;  Group: Encounter_Group;
                                        Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Var
   Character: Integer;

Begin
   Character:=Individual.Attacker_Position;
   If Individual.Action<>Parry then
      Begin
         Individual.Priority:=Character_Priority (Member[Character]);
         Insert (Individual,Attacks);
         If (Character=1) and (Member[Character].Attack.Berserk) then
            Begin
               { Berserk barbarians get double attacks }
               Individual.Target_Group:=1;
               Individual.Priority:=Character_Priority (member[Character]);
               Insert (Individual,Attacks);
            End
      End
End;

(******************************************************************************)

Procedure Insert_Party (Var Attacks: PriorityQueue; Group: Encounter_Group; Member: Party_Type;
                                Current_Party_Size: Party_Size_Type;  Party_Size: Integer; Var Flee: Boolean;
                                Var Time_Delay: Integer; Var Can_Attack: Party_Flag);

Var
   Party_Actions: Party_Commands_Type;
   Character: Integer;

Begin
   Get_Party_Commands (Party_Actions,Group,Member,Current_Party_Size,Party_Size,Flee,Time_Delay,Can_Attack);
   For Character:=1 to Current_Party_Size do
      If (Not Flee) and (Can_Attack[Character]) then
          Insert_Character_Action (Party_Actions[Character],Attacks,Group,Member,Current_Party_Size);
End;

(******************************************************************************)

Function Successful_Flee_Chance (Group: Encounter_Group;  Current_Party_Size: Party_Size_Type;
                                      Party_Size: Integer): [Volatile]Integer;

Var
  Temp: Integer;
Group_num: Integer;

Begin { Successful Flee }
   Temp:=100-(5*(Party_Size-Current_Party_Size))+Party_Size;
   For Group_Num:=1 to 4 do
      If (CantEscape in group[Group_Num].Monster.Properties) or (Temp<0) then
         Temp:=-65035
      Else
         Begin
            Temp:=Temp+(20*(Group[Group_Num].Orig_Group_Size-Group[Group_Num].Curr_Group_Size));
            Temp:=Temp-(5*Group[Group_Num].Curr_Group_Size);
         End;
   If Temp<0 then Temp:=0;
   Successful_Flee_Chance:=Temp;
End;  { Successful Flee }

(******************************************************************************)

Procedure Insert_Monster_Attacks (Var Group: Encounter_Group; Var Attacks: PriorityQueue);

Var
  Mon_Group: Integer;
Monster: Integer;
Dex_Adj: Integer;
  Individual: AttackerType;
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

(******************************************************************************)

Procedure Melee_Round (Var Group: Encounter_Group; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                          Party_Size: Integer;  Var Flee: Boolean; Var Time_Delay: Integer;  Var Can_Attack: Party_Flag);

{ This procedure will semi-randomly put the combatants onto a priority queue for combat purposes.  If a DELETEMIN produces an inactive
  individual, it is simply ignored, and the next attacker is access via DELETEMIN. }

{ Scheme: Assign each combatant a semi-random priority, and then insert him or her into the appropriate place in the queue. Total time complexity:
  O(n log n). Oh well. }

Var
   Attacks: PriorityQueue;
   Pic: Picture;

Begin
   Flee:=False;
   MakeNull (Attacks);
   SMG$Erase_Display (MessageDisplay);
   Insert_Monster_Attacks (Group,Attacks);
   Insert_Party (Attacks,Group,Member,Current_Party_Size,Party_Size,Flee,Time_Delay,Can_Attack);
   Flee:=Flee and Made_Roll(Successful_Flee_Chance(Group,Current_Party_Size,Party_Size));

   If Not Flee then
      One_Round (Attacks,Group,Member,Current_Party_Size,Party_Size,Can_Attack);

   Yikes:=Yikes or Uh_Oh(Group,Current_Party_Size);
   If (Not Flee) and Yikes then
      Begin
         Pic:=Pics[Group[1].Monster.Picture_Number];

         SMG$Begin_Display_Update (FightDisplay);
         If (Pic.Right_Eye.X>0) and (Pic.Right_Eye.Y>0) then
            SMG$Put_Chars (FightDisplay,Pic.Eye_Type+'',Pic.Right_Eye.Y + 0,Pic.Right_Eye.X + 0);
         If (Pic.Left_Eye.X>0) and (Pic.Left_Eye.Y>0) then
            SMG$Put_Chars (FightDisplay,Pic.Eye_Type+'',Pic.Left_Eye.Y + 0,Pic.Left_Eye.X + 0);
         SMG$End_Display_Update (FightDisplay);
      End;
End;

(******************************************************************************)

Function Return_or_Change_Time (Var Time_Delay: Integer): [Volatile]Char;

Var
   Answer: Char;
   T: Line;

Begin
   T:='Turn combat M)essages '+Bool_String[Not Show_Messages]+', or [RETURN] to fight';

   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Put_Chars (OptionsDisplay,'C)hange Time Delay',2,20);
   SMG$Put_Chars (OptionsDisplay,T,3,(54 div 2)-(T.Length div 2));
   SMG$End_Display_Update (OptionsDisplay);

   Answer:=Make_Choice (['M','C',CHR(13)]);

   If Answer='C' then
      Change_Delay (Time_Delay)
   Else
      If Answer='M' then
         Show_Messages:=Not Show_Messages;

   Return_or_Change_Time:=Answer;
End;

(******************************************************************************)

Procedure Monster_attacks_first (Var Group: Encounter_Group;  Var Time_Delay: Integer;  Var Member: Party_Type;
                                        Var Current_Party_Size: Party_Size_Type; Party_Size: Integer; Var Can_Attack: Party_Flag);

Var
   Attacks: PriorityQueue;

Begin
   MakeNull (Attacks);
   Insert_Monster_Attacks (Group,Attacks);

   SMG$Erase_Display (OptionsDisplay);
   SMG$Paste_Virtual_Display (OptionsDisplay,Pasteboard,SpellsY,SpellsX);
   Repeat
   Until Return_or_Change_Time(Time_Delay)=CHR(13);
   SMG$Unpaste_Virtual_Display (OptionsDisplay,Pasteboard);

   One_Round (Attacks,Group,Member,Current_Party_Size,Party_Size,Can_Attack);
End;

(******************************************************************************)

Procedure Party_attacks_first (Var Group: Encounter_Group;  Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                               Party_Size: Integer; Var Flee: boolean;  Var Time_Delay: Integer;  Var Can_Attack: Party_Flag);

Var
   Attacks: PriorityQueue;

Begin
   SMG$Erase_Display (OptionsDisplay);
   MakeNull (Attacks);
   Flee:=False;
   Insert_Party (Attacks,Group,Member,Current_Party_Size,Party_Size,Flee,Time_Delay,Can_Attack);
   If Flee then
      Flee:=Made_Roll (Successful_Flee_Chance(Group,Current_Party_Size,Party_Size))
   Else
      One_Round (Attacks,Group,Member,Current_Party_Size,Party_Size,Can_Attack);
End;

(******************************************************************************)

Function Have_Monster_Item (Monster_Name: Monster_Name_Type; Member: Party_Type; Party_Size: Integer): Boolean;

Var
   Person: Integer;
Item: Integer;

Begin
   For Person:=1 to Party_Size do
      If Member[Person].No_of_Items>0 then
         For Item:=1 to Member[Person].No_of_Items do
            If STR$POSITION(Monster_Name,Item_List[Member[Person].Item[Item].Item_Num].True_Name)<>0 then
               Have_Monster_Item:=True; { TODO: What the heck is this FOR?!?!? }
End;

(******************************************************************************)

Function Reaction (Monster: Monster_Record; Member: Party_Type; Party_Size: Integer;
                   Friends: Boolean:=False): Reaction_Type;

Var
   Chance: Integer;
Person: Integer;
   Best_Align: Align_Type;
Worst_Align: Align_Type;

Begin
   Best_Align:=Monster.Alignment;  Worst_Align:=Monster.Alignment;
   For Person:=1 to Party_Size do
      If ABS(Ord(Best_Align)-Ord(Member[Person].Alignment)) > ABS(Ord(Best_Align)-Ord(Worst_Align)) then
         Worst_Align:=Member[Person].Alignment;

   Case Best_Align of
      Good: Case Worst_Align of
              Good: Chance:=95;
              Neutral: Chance:=10;
              Evil: Chance:=5;
              Otherwise Chance:=0;
            End;
      Neutral: Case Worst_Align of
                 Good: Chance:=15;
                 Neutral: Chance:=20;
                 Evil: Chance:=10;
                 Otherwise Chance:=0;
               End;
      Evil:   Case Worst_Align of
                 Good: Chance:=5;
                 Neutral: Chance:=5;
                 Evil: Chance:=10;
                 Otherwise Chance:=0;
              End;
      Otherwise Chance:=0;
   End;

   If Have_Monster_Item (Monster.Real_Name,Member,Party_Size) then
      Chance:=Chance + 50;

   If Friends then
      Chance:=Chance + 60;
   If Chance>99 then
      Chance:=99;

   If Made_Roll(Chance) then
      Reaction:=Friendly
   Else
      Reaction:=Hostile;

   If CantBeFriend in Monster.Properties then
      Reaction:=Hostile;
End;

(******************************************************************************)

[Global]Procedure Init_Encounter (Number: Integer; Var Encounter: Encounter_Group;  Member: Party_Type;
                                  Current_Party_Size: Party_Size_Type);

Var
  Chara: Integer;
A_Monster: Integer;
Group: Integer;
  Done: Boolean;

[External]Function Get_Monster (Monster_Number: Integer): Monster_Record;External;

Begin
   Encounter:=Zero;
   Group:=1;
   Done:=False;
   Repeat
      If (Group<5) then
         Begin { If we do not already have four groups }
            If (Number<1) or (Number>450) then
               Number:=1;  { Error! }

            Encounter[Group].Monster:=Get_Monster(Number);

            Encounter[Group].Orig_Group_Size:=Random_Number(Encounter[Group].Monster.Number_Appearing);
            Encounter[Group].Curr_Group_Size:=Encounter[Group].Orig_Group_Size;

            Encounter[Group].Identified:=Know_Monster (Group,Member,Current_Party_Size);

            For Chara:=1 to Current_Party_Size do
               Member[Chara].Monsters_Seen[Number]:=True;

            For A_Monster:=1 to Encounter[Group].Orig_Group_Size do
               Begin
                  Encounter[Group].Curr_HP[A_Monster]:=Random_Number(Encounter[Group].Monster.Hit_Points);
                  Encounter[Group].Max_HP[A_Monster]:=Encounter[Group].Curr_HP[A_Monster];
                  Encounter[Group].Status[A_Monster]:=Healthy;
               End;

            If Made_Roll (Encounter[Group].Monster.Gate_Success_Percentage) then
               Begin
                  Number:=Encounter[Group].Monster.Monster_Called;
                  Group:=Group + 1;
                  If Group=5 then
                     Done:=True;
               End
            Else
               Done:=True;
         End;
   Until Done;
End;

(******************************************************************************)
[External]Function Experience (Number: Integer; Group: Monster_Group): Real;external;
(******************************************************************************)

Function Group_Experience (Group: Monster_Group; Party_Size: Integer): Real;

Var
   Temp: Real;
   Loop: Integer;

Begin
   Temp:=0;

   If Group.Orig_Group_Size > 0 then
      For Loop:=1 to Group.Orig_Group_Size do
         Temp:=Temp + Experience(Loop, Group);

   If Group.Orig_Group_Size > (4 * Party_size) then
      Temp:=Temp + Round(Temp * (1 / 5))
   Else If Group.Orig_Group_Size > (2 * Party_Size) then
      Temp:=Temp + Round(Temp * (3 / 20));

   Group_Experience:=Temp;
End;

(******************************************************************************)

Function Encounter_Experience (Encounter: Encounter_Group; Party_Size: Integer): Real;

Var
   Temp: Real;
   Loop: Integer;

Begin
   Temp:=0;
   For Loop:=1 to 4 do
      Temp:=Temp + Group_Experience(Encounter[Loop], Party_Size);

   Encounter_Experience:=Temp;
End;

(******************************************************************************)

Procedure Award_Experience (Encounter: Encounter_Group; Var Member: Party_Type;  Current_Party_Size,Party_Size: Integer);

Var
  Character: Integer;
  XP: Real;
XP_Sum: Real;

Begin
  XP_Sum:=Encounter_Experience (Encounter,Party_Size);
  XP:=XP_Sum/Current_Party_Size;

  SMG$Erase_Display (MessageDisplay);

  SMG$Begin_Display_Update (MonsterDisplay);

  SMG$Erase_Display (MonsterDisplay);
  SMG$Put_Line (MonsterDisplay,' For defeating thine enemies, each survivor gets');
  SMG$Put_Line (MonsterDisplay,' '+String (Trunc(XP))+' experience points.',0);

  SMG$End_Display_Update(MonsterDisplay);

  For Character:=1 to Current_Party_Size do
     If Alive (Member[Character]) and (Member[Character].Status<>Zombie) then
        Member[Character].Experience:=Member[Character].Experience + XP;

  Delay (2);

  SMG$Erase_Display (MonsterDisplay);
End;

(******************************************************************************)
[External]Procedure Give_Treasure (Encounter: Encounter_Group; Area: Area_Type; Var Member: Party_Type;
                                           Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;  Var Alarm_Off: Boolean);external;
(******************************************************************************)

Procedure Party_is_Surprised (Var Encounter: Encounter_Group; Var Member: Party_Type;
                                         Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer; Var Time_Delay: Integer;
                                         Var Can_Attack: Party_Flag);

Begin
   SMG$Put_Line (MessageDisplay,'The monsters surprised thee!',0);
   Ring_Bell (MessageDisplay);
   Monster_Attacks_First (Encounter,Time_Delay,Member,Current_Party_Size,Party_Size,Can_Attack);
End;

(******************************************************************************)

Procedure Monsters_Return_Hailing;

Begin
  Delay(1);

  SMG$Begin_Display_Update (MessageDisplay);
  SMG$Erase_Display (MessageDisplay);
  SMG$Put_Line (MessageDisplay,'They return thine hailing and leave thee in peace!');
  SMG$End_Display_Update (MessageDisplay);

  Delay(1);
End;


(******************************************************************************)

Procedure Dont_Accept_Hailing;

Var
  T: Line;

Begin
  Delay(1);

  SMG$Begin_Display_Update (MessageDisplay);
  SMG$Erase_Display (MessageDisplay);

  Case Roll_Die (12) of
    1: T:='Shove off, kobold breath!';
    2: T:='Eat steal, carrion crawler!';
    3: T:='Die, scum!';
    4: T:='Meet thy maker, paladin-lover!';
    5: T:='Die, knave!';
    6: T:='I think not.';
    7: T:='Thou''re not getting away that easy...';
    8: T:='Grrrrrrr....';
    9: T:='The game master''s put a warrant out on thee...';
   10: T:='Not a chance, muck-sucker!';
   11: T:='No way, Jose!';
   12: T:='Yeah, right?';
   Otherwise T:='Thou''re going down!';
  End;

  SMG$Put_Line (MessageDisplay,T);
  SMG$End_Display_Update (MessageDisplay);

  Delay(1);
End;

(******************************************************************************)

Procedure Check_Class_and_Alignment_Aux (Var Class: Class_Type; Alignment: Align_Type);

Begin
   Case Class of
      Ranger: If Alignment<>Good then Class:=Fighter;
      Paladin: If Alignment=Evil then
                   Class:=Antipaladin
               Else
                  If Alignment=Neutral then Class:=Fighter;
      Antipaladin: If Alignment<>Evil then Class:=Fighter;
      Barbarian: If Alignment=Good then Class:=Fighter;
      Assassin: If Alignment<>Evil then Class:=Thief;
   End;
End;

(******************************************************************************)

Procedure Check_Class_And_Alignment (Var Character: Character_Type);

Begin
  Check_Class_And_Alignment_Aux (Character.Class,Character.Alignment);
  Check_Class_And_Alignment_Aux (Character.PreviousClass,Character.Alignment);
End;

(******************************************************************************)

Procedure Alignment_Drift (Drift_Alignment: Align_Type; Var Member: Party_Type; Current_Party_Size: Integer);

Var
  Person: Integer;
Chance: Integer;

Begin
   For Person:=1 to Current_Party_Size do
      If Member[Person].Alignment<>Drift_Alignment then
         Begin
            If Member[Person].Alignment=Neutral then Chance:=2 else Chance:=1;
            If Made_Roll (Chance) then
               Begin
                  If Ord(Drift_Alignment)<Ord(Member[Person].Alignment) then
                     Member[Person].Alignment:=Pred(Member[Person].Alignment)
                  Else
                     Member[Person].Alignment:=Succ(Member[Person].Alignment);
                  Check_Class_and_Alignment (Member[Person]);
               End;
         End;
End;

(******************************************************************************)

Procedure Monsters_Are_Surprised (Var Encounter: Encounter_Group; Var Member: Party_Type;
                                             Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                                             Var Flee,Friends: Boolean;  Var Time_Delay: Integer; Var Can_Attack: Party_Flag);

Var
   Decision: Char;
   Hail: Boolean;

Begin
   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Line (MessageDisplay,'Thou surprised the monsters!');
   Ring_Bell (MessageDisplay);
   SMG$Put_Line (MessageDisplay,'Dost thou wish to F)ight them, or H)ail them in welcome?');
   SMG$End_Display_Update (MessageDisplay);
   Decision:=Make_Choice (['F','H']);
   Hail:=(Decision='H');
   If Hail then Alignment_Drift (Good,Member,Party_Size);

   Friends:=Hail and (Reaction(Encounter[1].Monster,Member,Party_Size,Friends:=True)=Friendly);
   If Friends then
      Monsters_Return_Hailing
   Else
      If Hail then
         Begin
            Dont_Accept_Hailing;
            Melee_Round (Encounter,Member,Current_Party_Size,Party_Size,Flee,Time_Delay,Can_Attack)
         End
      Else
         Party_Attacks_First (Encounter,Member,Current_Party_Size,Party_Size,Flee,Time_Delay,Can_Attack)
End;

(******************************************************************************)

Function Monsters_Left (Encounter: Encounter_Group): Integer;

{ This function returns the number of monsters left in the encounter }

Var
  MonstersRemaining: Integer;
Group_Num: Integer;

Begin
   MonstersRemaining:=0;
   For Group_Num:=1 to 4 do
      MonstersRemaining:=MonstersRemaining + Encounter[Group_Num].Curr_Group_Size;
   Monsters_Left:=MonstersRemaining;
End;

(******************************************************************************)

Procedure Post_Encounter_Revertion (Var Member: Party_Type; Party_Size: Integer);

{ Now that the fight is over, combat spells wear off }

Var
   Loop: Integer;
   Can_Attack: Party_Flag;

Begin
  Can_Attack:=Zero;
  For Loop:=1 to Party_Size do
     Begin {Change characters back to normal }
       Compute_AC_And_Regenerates (Member[Loop]);
       Member[Loop].Curr_HP:=Min(Member[Loop].Curr_HP,Member[Loop].Max_HP);
       Member[Loop].Attack.Berserk:=False;
     End;
  Update_Character_Box (Member,Party_Size,Can_Attack);
End;

(******************************************************************************)

Procedure Kill_Image (Image_Num: Pic_Type);

Var
   Pic: Picture;

Begin
   Pic:=Pics[Image_Num];

   SMG$Begin_Display_Update (FightDisplay);
   Show_Monster_Image (Image_Num, FightDisplay);
   If (Pic.Right_Eye.X>0) and (Pic.Right_Eye.Y>0) then SMG$Put_Chars (FightDisplay,'x',Pic.Right_Eye.Y + 0,Pic.Right_Eye.X + 0);
   If (Pic.Left_Eye.X>0) and (Pic.Left_Eye.Y>0) then SMG$Put_Chars (FightDisplay,'x',Pic.Left_Eye.Y + 0,Pic.Left_Eye.X + 0);
   SMG$End_Display_Update (FightDisplay);
End;

(******************************************************************************)

Procedure Spoils_of_Victory (Encounter: Encounter_Group; Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                                Party_Size: Integer; Place: Area_Type; Var Alarm_Off: Boolean;  Var Can_Attack: Party_Flag);

{ This procedure delivers experience and treasure to the party.  In addition, it 'x's the eyes of the monster picture, restoring
  later after the display has been unpasted. }

Begin
   Kill_Image (Encounter[1].Monster.Picture_Number);
   Update_Character_Box (Member,Party_Size,Can_Attack);
   Award_Experience (Encounter,Member,Current_Party_Size,Party_Size);
   Give_Treasure (Encounter,Place,Member,Current_Party_Size,Party_Size,Alarm_Off);
   SMG$Unpaste_Virtual_Display (FightDisplay,Pasteboard);
End;

(******************************************************************************)

Procedure Time_Flies (Var Encounter: Encounter_Group; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                          Party_Size: Integer; Var Can_Attack: Party_Flag);

{ This procedure marks time.  It implements the effect of poison, the effect of regeneration, and the effect of time-dependent
  spells. }

Var
   Individual: Integer;
Group: Integer;

Begin
   For Group:=1 to 4 do
      For Individual:=1 to Encounter[Group].Curr_Group_Size do
         Begin
            Encounter[Group].Curr_HP[Individual]:=Min(
                Encounter[Group].Curr_HP[Individual] + Encounter[Group].Monster.Regenerates,
                Encounter[Group].Max_HP[Individual]
            );
            If Encounter[Group].Curr_HP[Individual]<1 then
               Encounter[Group].Status[Individual]:=Dead;
         End;

   For Individual:=1 to Current_Party_Size do
      Time_Effects (Individual, Member, Party_Size);
   Dead_Characters (Member,Current_Party_Size,Party_Size,Can_Attack);

   Update_Character_Box (Member,Party_Size,Can_Attack);
End;

(******************************************************************************)

Procedure Handle_Combat (Var Encounter: Encounter_Group; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                                                 Party_Size: Integer; Var Flee: Boolean; Var Time_Delay: Integer; Var Can_Attack: Party_Flag);

Var
   Round_Count: Integer;
MonstersRemaining: Integer;
   Finished: Boolean;

Begin
   Round_Count:=1;
   MonstersRemaining:=Monsters_Left (Encounter);
   Finished:=(Current_Party_Size=0) or (MonstersRemaining=0);

   While Not (Finished or Flee or Leave_Maze) do
      Begin
         Melee_Round (Encounter,Member,Current_Party_Size,Party_Size,Flee,Time_Delay,Can_Attack);
         MonstersRemaining:=Monsters_Left (Encounter);
         Round_Count:=Round_Count + 1;
         If Round_Count=3 then
            Begin
               Time_Flies (Encounter,Member,Current_Party_Size,Party_Size,Can_Attack);
               Round_Count:=0;
            End;
         Finished:=(Current_Party_Size=0) or (MonstersRemaining=0);
      End;
End;

(******************************************************************************)

Procedure Handle_Flight (Var Places: Place_Stack);

Var
  X: Integer;
Num: Integer;
  P1,P2: Horizontal_Type;
  P3: Vertical_Type;

[External]Procedure POP (Var PosX,PosY: Horizontal_Type; Var PosZ: Vertical_Type; Var Stack: Place_Stack);external;
[External]Function Get_Level (Level_Number: Integer; Maze: Level; PosZ: Vertical_Type:=0): [Volatile]Level;External;
[External]Function Empty_Stack (Stack: Place_Stack): Boolean;external;

Begin
  P1:=PosX;  P2:=PosY;  P3:=PosZ;
  Num:=Roll_Die(Places.Length);
  For X:=1 to Num do
     If Not Empty_Stack(Places) then
        POP(P1,P2,P3,PLACES);
  Maze:=Get_Level (P3,Maze,PosZ); { TODO: This may be a bug in that planned monsters slain may return }
  PosX:=P1; PosY:=P2; PosZ:=P3;
End;

(******************************************************************************)

Procedure Fight (Var Encounter: Encounter_Group; Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                     Party_Size: Integer; NotSurprised: Boolean; Place: Area_Type;  Var Time_Delay: Integer;
                 Var Alarm_Off: Boolean;  Var Can_Attack: Party_Flag);

{ This procedure is called when combat is joined.  It checks surprise, and handles it if it occurs, runs combat, and then delivers
  experience and treasure. }

Var
  Surprise_Status: Surprise_Type;
  Friends: Boolean;
Flee: Boolean;

Begin
   SMG$Erase_Display (MessageDisplay);
   Flee:=False;  Friends:=False;
   If NotSurprised then { If the monsters blew their surprise chance... }
      Surprise_Status:=NoSurprise  { ... no one is surprised }
   Else
      Surprise_Status:=Surprised (Encounter[1].Monster,Member);

   If Surprise_Status=PartySurprised then
      Party_is_Surprised (Encounter,Member,Current_Party_Size,Party_Size,Time_Delay,Can_Attack)
   Else
      If Surprise_Status=MonsterSurprised then
         Monsters_Are_Surprised (Encounter,Member,Current_Party_Size,Party_Size,Flee,Friends,Time_Delay,Can_Attack);

   If Not (Flee or Friends) then
      Handle_Combat (Encounter,Member,Current_Party_Size,Party_Size,Flee,Time_Delay,Can_Attack);

   Post_Encounter_Revertion (Member,Party_Size);

   If Not (Flee or Friends or Leave_Maze) and (Current_Party_Size>0) then
      Spoils_of_Victory (Encounter,Member,Current_Party_Size,Party_Size,Place,Alarm_Off,Can_Attack);

   Update_Character_Box (Member,Party_Size,Can_Attack);

   If Flee then Handle_Flight (Places)
   Else
      If Current_Party_Size=0 then
         SMG$Begin_Pasteboard_Update (Pasteboard);  { SMG$END_PASTEBOARD_UPDATE is in grave routine }
End;

(******************************************************************************)

Procedure Print_Hailing (Lead_Monster: Monster_Group);

Var
  T: Line;
  Name: Monster_Name_Type;

Begin { Print Hailing }
   Name:=Monster_Name (Lead_Monster.Monster,Lead_Monster.Orig_Group_Size,Lead_Monster.Identified);
   If Lead_Monster.Orig_Group_Size>1 then
      T:=Name+' hail'
   Else
      T:=Name+' hails';
   T:='The ' + T + ' thee in welcome.  Thou may:';

   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Line (MessageDisplay,T);
   SMG$Put_Line (MessageDisplay, 'F)ight or L)eave in peace');
   SMG$End_Display_Update (MessageDisplay);
End;  { Print Hailing }

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

   Update_Monster_Box (Encounter);
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
   Item_List := Read_Items;

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

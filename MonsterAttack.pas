[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','PriorityQueue')]Module Monster_Attack;

Type
   Prop_Set       = Set of Property_Type;
   Resist_Set     = Set of Attack_Type;
   Property_Set   = Set of Property_Type;

Var
   Item_List                 : [External]List_of_Items;
   Silenced,Can_Attack       : [External]Party_Flag;
   Time_Stop_Players         : [External]Boolean;
   NoMagic                   : [External]Boolean;
   MessageDisplay            : [External]Unsigned;
   Seed                      : [External,Volatile]Unsigned;
   Delay_Constant            : [External]Real;
   AttackName                : Array [Monster_Type,1..2] of Attack_String;

Value
   AttackName [Warrior,1]:='thrusts';          AttackName[Warrior,2]:='slashes';
   AttackName [Mage,1]:='stabs';               AttackName[Mage,2]:='slices';
   AttackName [Priest,1]:='smashes';           AttackName[Priest,2]:='swings';
   AttackName [Pilferer,1]:='stabs';           AttackName[Pilferer,2]:='slices';
   AttackName [Karateka,1]:='punches';         AttackName[Karateka,2]:='kicks';
   AttackName [Midget,1]:='swings';            AttackName[Midget,2]:='stabs';
   AttackName [Giant,1]:='smashes';            AttackName[Giant,2]:='swings';
   AttackName [Myth,1]:='bites';               AttackName[Myth,2]:='claws';
   AttackName [Animal,1]:='bites';             AttackName[Animal,2]:='claws';
   AttackName [Lycanthrope,1]:='bites';        AttackName[Lycanthrope,2]:='claws';
   AttackName [Undead,1]:='claws';             AttackName[Undead,2]:='swings';
   AttackName [Demon,1]:='bites';              AttackName[Demon,2]:='swings';
   AttackName [Insect,1]:='bites';             AttackName[Insect,2]:='bites';
   AttackName [Plant,1]:='bites';              AttackName[Plant,2]:='grabs';
   AttackName [MultiPlanar,1]:='swings';       AttackName[MultiPlanar,2]:='slashes';
   AttackName [Dragon,1]:='claws';             AttackName[Dragon,2]:='bites';
   AttackName [Statue,1]:='smashes';           AttackName[Statue,2]:='swings';
   AttackName [Reptile,1]:='lashes out';       AttackName[Reptile,2]:='strikes';
   AttackName [Enchanted,1]:='swings';         AttackName[Enchanted,2]:='thrusts';


[External]Function  Alive (Character: Character_Type): Boolean;External;
[External]Function  Compute_Hit_Die (Character: Character_Type): Integer;external;
[External]Function  Know_Monster (Monster_Number: Integer; Member: Party_Type; Current_Party_Size: Party_Size_Type): [Volatile]Boolean;External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  Made_Save (Character: Character_Type; Attack: Attack_Type): [Volatile]Boolean;External;
[External]Function  Monster_Name (Monster: Monster_Record; Number: Integer; Identified: Boolean): Monster_Name_Type;External;
[External]Function  Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function  Spell_Damage (Spell: Spell_Name;  Caster_Level: Integer:=0): Die_Type;External;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
[External]Function  XP_Needed (Class: Class_Type; Level: Integer):Real;External;
[External]Procedure Attack_Effects (Attack: Attack_Type; CharNum: Integer; Var Member: Party_Type; Var Can_Attack: Party_Flag);External;
[External]Procedure Change_Status (Var Character: Character_Type;  Status: Status_Type;  Var Changed: Boolean);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Procedure Slay_Character (Var Character: Character_Type; Var Can_Attack: Flag);External;
[Asynchronous,External]Function MTH$RANDOM (%Ref Seed: Unsigned): Real;external;
[External]Procedure Monster_Spell (Attacker: Attacker_Type; Var Group: Encounter_Group; Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type);External;

(**********************************************************************************************************************)

Procedure Special_Damage (Attack: Attack_Type;  CharNum,Damage: Integer; Var Member: Party_Type);

Var
   Character: Character_Type;
   ItemNum: Integer;
   Sum_Damage: Real;
   T: Line;

Begin
  Character:=Member[CharNum];
  Sum_Damage:=Damage;

  If Character.No_of_Items > 0 then
     For ItemNum:= 1 to Character.No_of_Items do
        If Character.Item[ItemNum].Equipted and (Attack in Item_List[Character.Item[ItemNum].Item_Num].Resists) then
           Sum_Damage := Sum_Damage / 2;

  If Made_Save (Character,Attack) then
     Sum_Damage := Sum_Damage / 2;

  If Round(Sum_Damage)<1 then
     T:=Character.Name + ' is unaffected!'
  Else
     T:=Character.Name + ' takes ' + String(Round(Sum_Damage)) + ' damage!';

  SMG$Set_Cursor_ABS (MessageDisplay,2,1);
  SMG$Put_Line (MessageDisplay, T);

  Character.Curr_Hp:=Character.Curr_Hp - Round(Sum_Damage);

  If (Character.Status = Asleep) and (Sum_Damage>0) then
     Character.Status := Healthy;

  If (Character.Curr_HP < 1) and Alive(Character) then
     Slay_Character (Character,Can_Attack[CharNum]);

  Character.Curr_HP := Max(Character.Curr_HP, 0);

  Member[CharNum] := Character;
End;

(**********************************************************************************************************************)

[Global]Function Undead_Party_Member (Member: Party_Type;  Current_Party_Size: Party_Size_Type; Var Position: Integer): Boolean;

Var
   Slot: Integer;

Begin
   Position:=0;
   If Current_Party_Size > 0 then
      For Slot:= Current_Party_Size downto 1 do
         If Member[Slot].Status = Zombie then
            Begin
               Position := Slot;
               Undead_Party_Member := True;
            End;
End;

(**********************************************************************************************************************)

Function Special_Attack_Name (Attack: Attack_Type): Line;

Begin
  Case Attack of
    Fire: Special_Attack_Name := ' fire';
    Frost: Special_Attack_Name := ' frost';
    Poison: Special_Attack_Name := ' a poisonous gas';
    Electricity: Special_Attack_Name := ' lightning';
    Otherwise Special_Attack_Name := '';
  End;
End;

(**********************************************************************************************************************)

Procedure Monster_Gazes_or_Breathes (Attacker: Attacker_Type;  Encounter: Encounter_Group;  Var Member: Party_Type;
                                     Var Current_Party_Size: Party_Size_Type;  Var Can_Attack: Party_Flag;
                                     Gaze: Boolean:=False);

Var
   Monster: Monster_Record;
   Attack: Attack_Type;
   Character,Damage_Inflicted: Integer;
   T: Line;

Begin
   Monster:=Encounter[Attacker.Group].Monster;
   Damage_Inflicted:=Encounter[Attacker.Group].Curr_HP[Attacker.Attacker_Position];
   T:=Monster_Name (Monster,1,Encounter[Attacker.Group].Identified);

   If Not Gaze then
      Begin
         Attack:=Monster.Breath_Weapon;
         T:=T+' breathes';
      End
   Else
      Begin
         Attack:=Monster.Gaze_Weapon;
         T:=T+' gazes';
      End;

   T:=T + Special_Attack_Name (Attack);
   T:=T + ' at the party!';

   SMG$Put_Line (MessageDisplay,T,0);

   For Character:=1 to Current_Party_Size do
       If Alive(Member[Character]) then
          Begin
            SMG$Erase_Display (MessageDisplay,2,1,4);
            Case Attack of
               Fire,Frost,LvlDrain,Electricity: Special_Damage (Attack,Character,Damage_Inflicted,Member);
               Otherwise                        Attack_Effects (Attack,Character,Member,Can_Attack);
            End;
            Delay (Delay_Constant);
          End;

   Delay (1 / 2 * Delay_Constant);
   SMG$Erase_Display (MessageDisplay);
End;

(**********************************************************************************************************************)

[Global]Procedure Drain_Levels_From_Character (Var Character: Character_Type; Levels: Integer:=1);

Var
   Level,That_Level,Hits_Lost: Integer;

Begin
   That_Level:=Max(Character.Level - Levels, 0);

   Character.Experience:=XP_Needed (Character.Class,That_Level);
   Hits_Lost:=0;

   If That_Level < Character.Level then
   For Level:=(Character.Level - 1) downto That_Level do
      Begin
        Hits_Lost := Hits_Lost + Compute_Hit_Die (Character);
        Character.Level := Level;
      End;

   Character.Max_HP := Max(Character.Max_HP - Hits_Lost, 1);

   Character.Curr_HP := Min(Character.Curr_HP, Character.Max_HP);
End;

(**********************************************************************************************************************)

Function Critical_Hit (Attacker_Level,Defender_Level: Integer): Boolean;

Var
  Base: Integer;

Begin
   If Attacker_Level > 0 then
      Begin
         Base := 10 + (5 * ((Attacker_Level - Defender_level) div 2) );
         Critical_Hit := Made_Roll (Base);
      End
   Else
      Critical_Hit := False;
End;

(**********************************************************************************************************************)

Procedure Drain_Levels (Var Character: Character_Type; Drained: Integer);

Var
   That_Level: Integer;
   T: Line;

Begin
   T:='';
   That_Level := Character.Level - Drained;  { TODO: Handle PREVIOUS LEVEL, TOO! }

   If That_Level<1 then
      Begin
         T:=Character.Name + ' is destroyed!';
         Character.Status:=Deleted;
         Character.Max_HP:=0;
         Character.Curr_HP:=0;
      End
   Else
      Begin
        T:=String(Drained) + ' levels are drained!';
        Drain_Levels_From_Character (Character,Drained);
      End;

   SMG$Put_Line (MessageDisplay,T,0,1);
   Delay (3 * Delay_Constant);
End;

(**********************************************************************************************************************)

Procedure Age_Character (Var Character: Character_Type;  Years: Integer:=1);

Begin
   If Alive (Character) then
      Begin
         Character.Age:=Character.Age+(365 * Years);

         SMG$Put_Line (MessageDisplay,Character.Name + ' is aged ' + String(years) + 'years!',0,1);
         Delay (2 * Delay_Constant);
      End;
End;

(**********************************************************************************************************************)

Procedure Check_Critical_Hit (Monster: Monster_Record; Props: Property_Set; Var Character: Character_Type);

Begin
   If (Autokills in Props) and Alive (Character) then
      If Critical_Hit (Monster.Hit_Points.X,Max(Character.Level,Character.Previous_Lvl)) then { TODO: Should these be combined? I think so. }
         Begin
            Character.Curr_HP := 0;

            SMG$Put_Line (MessageDisplay,'A critical hit!', 0, 1);
            Ring_Bell (MessageDisplay, 3);

            Delay (3 * Delay_Constant);
         End;
End;

(**********************************************************************************************************************)

Procedure Check_Level_Drain (Var Character: Character_Type; Levels_Drained: Integer;  Resists: Resist_Set);

Var
  Changed: boolean;

Begin
   If (Levels_Drained<>0) and Alive(Character) then
      Begin
         If LvlDrain in resists then
            Changed:=Made_Roll(25)
         Else
            Changed := True;

         If Changed then
            Drain_Levels (Character,Levels_Drained);

         Delay (3 * Delay_Constant);
      End;
End;

(**********************************************************************************************************************)

Procedure Check_Aging (Var Character: Character_Type; Years_Aged: Integer;  Resists: Resist_Set);

Var
  Changed: boolean;

Begin
   If (Years_Aged<>0) and Alive(Character) then
      Begin
         If Aging in resists then
            Changed:=Made_Roll(25)
         Else
            Changed := True;

         If Changed then
            Age_Character (Character, Years_Aged);

         Delay (3 * Delay_Constant);
      End;
End;

(**********************************************************************************************************************)

Function Check_Stoning (Var Character: Character_Type; Var T: Line): Boolean;

Var
  Changed: boolean;

Begin
   Changed := False;

   If Alive(Character) then
      Begin
         If Not Made_Save (Character,Stoning) then
            Change_Status (Character,Petrified,Changed);

         If Changed then
            T:=Character.Name + ' is turned into stone!';
      End;

   Check_Stoning:=Changed;
End;

(**********************************************************************************************************************)

Function Check_Poison (Var Character: Character_Type; Var T: Line): Boolean;

Var
  Changed: boolean;

Begin
   Changed := False;

   If Alive(Character) then
      Begin
         If Not Made_Save (Character,Poison) then
               Change_Status (Character,Poisoned,Changed);

         If Changed then
            T:=Character.Name + ' is poisoned!';
      End;

   Check_Poison:=Changed;
End;

(**********************************************************************************************************************)

Function Check_Paralysis (Var Character: Character_Type; Var T: Line): Boolean;

Var
  Changed: boolean;

Begin
   Changed := False;

   If Alive(Character) then
      Begin
         If Not Made_Save (Character,Stoning) then
               Change_Status (Character,Paralyzed,Changed);

         If Changed then
            T:=Character.Name + ' is paralyzed!';
      End;

   Check_Paralysis:=Changed;
End;

(**********************************************************************************************************************)

Function Character_Resists (Character: Character_Type): Resist_set;

Var
  Resists: Set of Attack_Type;
  Item_No: Integer;

Begin
  Resists:=[ ];

  If Character.No_of_Items > 0 then
     For Item_No:=1 to Character.No_of_Items do
        If Character.Item[Item_No].Equipted then
           Resists := Resists + Item_List[Character.Item[Item_No].Item_Num].Resists; { TODO: Multiple items should stack }

  Character_Resists:=Resists;
End;

(**********************************************************************************************************************)

Procedure Hit_Effects (Monster: Monster_Record; Var Character: Character_Type);

Var
   Resists: Resist_Set;
   Props: Prop_Set;
   Changed: Boolean;
   T: Line;

Begin
   Props:=Monster.Properties;

   Changed:=False;  T:='';

   If Stones in Props then
      Changed:=Check_Stoning (Character, T);
   If Poisons in Props then
      Changed:=Changed or Check_Poison (Character, T);
   If Paralyzes in Props then
      Changed:=Changed or Check_Paralysis (Character, T);

   If Changed then
      Begin
         SMG$Put_Line (MessageDisplay,T,0,1);
         Delay (3 * Delay_Constant);
      End;

   Resists:=Character_Resists (Character); { TODO: Check resists for above as well. }

   Check_Aging (Character,Monster.Years_Ages,Resists);
   Check_Level_Drain (Character,Monster.Levels_Drained,Resists);
   Check_Critical_Hit (Monster,Props,Character);
End;

(**********************************************************************************************************************)

Function Flee_Chance (Group: Monster_Group; Member: Party_Type; Current_Party_Size,Party_Size: Integer): Integer;

Var
   Temp: Integer;
   Person: Integer;
   Av_Hit_Dice: Integer;

Begin
   Temp:=0;  AV_Hit_Dice:=0;
   For Person:=1 to Current_Party_Size do
      AV_Hit_Dice:=AV_Hit_Dice + Member[Person].Level + Member[Person].Previous_Lvl;
   AV_Hit_Dice := AV_Hit_Dice div Current_Party_Size;

   If AV_Hit_Dice > (1 / 4 * Group.Monster.Hit_Points.X) then
      Temp := Temp + 15
   Else If Group.Curr_Group_Size <= (1 / 4 * Group.Orig_Group_Size) then
      Temp := Temp + 5;

   Temp := Temp - (10 * ABS(Current_Party_Size - Party_Size));

   If (Current_Party_Size=Party_Size) and (Group.Orig_Group_Size > Group.Curr_Group_Size) then
      Temp := Temp + 10
   Else If (Current_Party_Size < Party_Size) and (Group.Orig_Group_Size = Group.Curr_Group_Size) then
      Temp := Temp + 5;

   If Current_Party_Size > Group.Curr_Group_Size * 3 then
      Temp := Temp + 20
   Else If Group.Curr_Group_Size > Current_Party_Size * 3 then
      Temp := Temp - 20;

   If Not((CanRun in Group.Monster.Properties) or (TeleportsAway in Group.Monster.Properties)) then
      Temp:=0;

   Flee_Chance:=Temp;
End;

(**********************************************************************************************************************)

Function Action (Group: Monster_Group;  Position: Integer;  Member: Party_Type;
                 Current_Party_Size, Party_Size:  Integer): Option_Type;

{ This procedure (sic) will determine the action of any a monster (sic) in group, GROUP }

Var
   BreathChance,SpellChance,RunChance: Integer;

Begin
   BreathChance:=0;  SpellChance:=0;
   RunChance:=Flee_Chance(Group,Member,Current_Party_Size,Party_Size);

   If Group.Monster.Breath_Weapon <> Charming then { let's not be silly }
      BreathChance:=50;

   If (Group.Monster.Highest.Cleric_Spell>0) or (Group.Monster.Highest.Wizard_Spell>0) then
      SpellChance:=85;

   If Group.Status[Position] = Afraid then
      Begin
         RunChance:=RunChance + 75;
         BreathChance:=BreathChance - 50;
         SpellChance:=0;
      End;

   If Made_Roll (BreathChance) then
      Action:=Breathe
   Else if Made_Roll (SpellChance) then
      Action:=CastSpell
   Else if Made_Roll (RunChance) then
      Action:=Run
   Else if Made_Roll (RunChance) and (Gates in Group.Monster.Properties) then
      Action:=Gate
   Else if Group.Monster.No_of_Attacks > 0 then
      Action:=Attack
   Else
      Action:=Run;
End;

(**********************************************************************************************************************)

Function Monster_to_Hit_Roll (HD: Integer;  Character: Character_Type; Monster: Monster_Record): Integer;

Var
  Temp: Integer;
  AC: Integer;

Begin
   AC := Character.Armor_Class;

   Temp:=10 - (2 * ((HD - 1) div 2));
   Temp:=Temp - (AC - 10);

   Temp:=Max(Min(Temp, 20), 2); { You can always hit on a 20 and always miss on a 1 }

   Case Character.Class of
      Paladin: If (Monster.Kind in [Demon,Undead,MultiPlanar]) and (Monster.Alignment = Evil) then
                  Temp:=21; { Can't hit 'em }
      AntiPaladin: If (Monster.Kind in [Demon,Undead,MultiPlanar]) and (Monster.Alignment = Good) then
                  Temp:=21; { Can't hit 'em }
   End;
   Case Character.PreviousClass of
      Paladin: If (Monster.Kind in [Demon,Undead,MultiPlanar]) and (Monster.Alignment = Evil) then
                  Temp:=21; { Can't hit 'em }
      AntiPaladin: If (Monster.Kind in [Demon,Undead,MultiPlanar]) and (Monster.Alignment = Good) then
                  Temp:=21; { Can't hit 'em }
   End;

   Monster_to_Hit_Roll:=Temp;
End;

(**********************************************************************************************************************)

Procedure Monster_Attacks (Var MonsterGroup: Monster_Group;  Var CharNo: Integer; Var Member: Party_Type;
                           Var Current_Party_Size: Party_Size_Type);

Var
   Monster: Monster_Record;
   NumAttacks: Integer;
   TempDam,Hits,Damage,HD: Integer;
   Character: Character_Type;
   T: Varying [390] of Char;

Begin
   Character:=Member[CharNo];
   Monster:=MonsterGroup.Monster;

   If Alive(Character) then
      Begin
         Damage:=0;   Hits:=0;
         HD:=Monster.Hit_Points.X;
         For NumAttacks:=1 to Monster.No_of_Attacks do
            If Roll_Die (20) >= Monster_to_Hit_Roll (HD,Character,Monster) then
               Begin
                  TempDam:=Random_Number (Monster.Damage[NumAttacks]);

                  If [Character.Class,Character.PreviousClass] * Monster.Extra_Damage <> [ ] then
                     TempDam:=TempDam * 2;

                  Damage:=Damage + TempDam;
                  Hits:=Hits + 1;
               End;

         T:=Monster_Name(Monster,1,MonsterGroup.Identified)
             + ' '
             + AttackName[Monster.Kind, Roll_Die(2)]
             + ' at '
             + Character.Name + ' and ';

         If Hits > 0 then
            Begin
               T:=T + 'hits ';
               If Hits = 1 then
                  T:=T + 'once'
               Else
                  T:=T + String(hits) + ' times ';
               T:=T + 'for ' + String(Damage) + ' damage!';

               SMG$Put_Line (MessageDisplay, T, Wrap_Flag:=SMG$M_WRAP_WORD);

               If (Character.Status=Asleep) and (Damage > 0) then
                  Character.Status := Healthy;

               Hit_Effects (Monster,Character);

               If Character.Curr_HP < 1 then
                  Slay_Character (Character, Can_Attack[CharNo]);

               Character.Curr_HP:=Max(Character.Curr_HP, 0);

               Can_Attack[CharNo] := Character.Status in [Healthy,Zombie,Poisoned];
            End
         Else
            SMG$Put_Line (MessageDisplay,T + 'misses!',Wrap_Flag:=SMG$M_WRAP_WORD);
     End;

     Member[CharNo] := Character;
End;

(**********************************************************************************************************************)

Function Available_Spot (Encounter: Encounter_Group;  Var Group: Integer): Boolean;

Var
  Spot_Found: Boolean;

Begin
  Spot_Found:=False;
  While Not (Spot_Found) and (Group < 5) do
     If Encounter[Group].Orig_Group_Size = 0 then Spot_Found := True
     Else                                         Group := Group + 1;

  Available_Spot := Spot_Found;
End;

(**********************************************************************************************************************)

Procedure Monster_Gates (Var Encounter: Encounter_Group;  Member: Party_Type;  Current_Party_Size: Party_Size_Type;
                         Group,Position: Integer);

Var
   Success,Spot_Found: Boolean;
   Monster_Called,Chance,Caller_Number,Chara,A_Monster: Integer;

[External]Function Get_Monster (Monster_Number: Integer): Monster_Record; External;

Begin
   Caller_Number := Encounter[Group].Monster.Monster_Number;  Monster_Called:=Encounter[Group].Monster.Monster_Called;
   Chance:=Encounter[Group].Monster.Gate_Success_Percentage;  Success:=False;

   SMG$Put_Line (MessageDisplay,Monster_Name (Encounter[Group].Monster,1,Encounter[Group].Identified) + ' calls for help');
   If Made_Roll (Chance) and Not(Encounter[Group].Silenced[Position]) then
      Begin
         If Monster_Called=Caller_Number then
            Begin
               Success:=True;
               Encounter[Group].Orig_Group_Size:=Encounter[Group].Orig_Group_Size + 1; { TODO: Check for overflow }
               Encounter[Group].Curr_Group_Size:=Encounter[Group].Curr_Group_Size + 1;

               A_Monster:=Encounter[Group].Curr_Group_Size;
               Encounter[Group].Curr_HP[A_Monster]:=Random_Number(Encounter[Group].Monster.Hit_Points);
               Encounter[Group].Max_HP[A_Monster]:=Encounter[Group].Curr_HP[A_Monster];
               Encounter[Group].Status[A_Monster]:=Healthy;
            End
         Else
            Begin
               Spot_Found:=Available_Spot(Encounter,Group);
               If Spot_Found then
                  Begin
                     Success:=True;

                     Encounter[Group].Monster := Get_Monster(Monster_Called);
                     Encounter[Group].Orig_Group_Size:=1;
                     Encounter[Group].Curr_Group_Size:=1;
                     Encounter[Group].Identified := Encounter[Group].Identified or Know_Monster (Group,Member,Current_Party_Size);

                     For Chara:=1 to Current_Party_Size do
                        Member[Chara].Monsters_Seen[Monster_Called] := True;

                     For A_Monster:=1 to Encounter[Group].Orig_Group_Size do
                        Begin
                           Encounter[Group].Curr_HP[A_Monster] := Random_Number (Encounter[Group].Monster.Hit_Points);
                           Encounter[Group].Max_HP[A_Monster] := Encounter[Group].Curr_HP[A_Monster];
                           Encounter[Group].Status[A_Monster] := Healthy;
                        End
                  End
            End
      End;

   If Success then SMG$Put_Line (MessageDisplay,'and is heard!', 0)
   Else            SMG$Put_Line (MessageDisplay,'but none comes!', 0)
End;

(**********************************************************************************************************************)

Function Flee_Name (Number: Integer): [Volatile]Line;

Begin
   Case Roll_Die (3) of
      1: Flee_Name := 'flees';
      2: Flee_Name := 'runs';
      3: If Number > 1 then Flee_Name:='abandons the fight and flees'
         Else               Flee_Name := 'flees';
   End;
End;

(**********************************************************************************************************************)

Procedure Monster_Chickens_Out (Var Monsters: Monster_Group; Individual: Integer);

Var
  T: Line;

Begin
   Monsters.Status[Individual]:=Dead;
   T:=Monster_Name(Monsters.Monster,1,Monsters.Identified);

   If TeleportsAway in Monsters.Monster.Properties then T:=T + ' teleports away!'
   Else                                                 T:=T + ' ' + Flee_Name (Monsters.Curr_Group_Size) + '!';

   SMG$Put_Line (MessageDisplay, T);
End;

(**********************************************************************************************************************)

Procedure Monster_Causes_Fear (Var Member: Party_Type;  Current_Party_Size: Party_Size_Type;  Party_Size: Integer);

Var
  Character: Integer;

Begin
  For Character:=1 to Current_Party_Size do
     If Alive(Member[Character]) then
        Begin
           SMG$Erase_Display (MessageDisplay, 1, 1, 4);

           Attack_Effects (CauseFear, Character, Member, Can_Attack);

           Delay (Delay_Constant);
        End;
  Delay (1 / 2 * Delay_Constant);
End;

(**********************************************************************************************************************)

[Global]Procedure Handle_Monster_Attack (Attacker: Attacker_Type;  Var Monster_Group1: Encounter_Group;  Var Member: Party_Type;
                                         Var Current_Party_Size:  Party_Size_Type;  Party_Size: Integer;  Var Can_Attack: Party_Flag);

Var
   Monsters: Monster_Group;
   Target,Individual,Group,Max_Target: Integer;
   Method: Option_Type;

Begin { Handle Monster Attack }
   Group:=Attacker.Group;     Individual:=Attacker.Attacker_Position;
   Monsters:=Monster_Group1[Group];

   If (Monsters.Status[Individual] in [Zombie,Healthy,Poisoned,Afraid]) then
      Begin
         If Monsters.Monster.Gaze_Weapon<>Charming then
            Monster_Gazes_or_Breathes (Attacker,Monster_Group1,Member,Current_Party_Size,Can_Attack,Gaze:=True);

         If Cause_Fear in Monsters.Monster.Properties then
            Monster_Causes_Fear (Member,Current_Party_Size,Party_Size);

         Method:=Action(Monsters,Individual,Member,Current_Party_Size,Party_Size);

         Case Method of
            Run:       Monster_Chickens_Out (Monsters, Individual);
            Gate:      Monster_Gates (Monster_Group1,Member,Current_Party_Size,Group,Individual);
            Breathe:   Monster_Gazes_or_Breathes (Attacker,Monster_Group1,Member,Current_Party_Size,Can_Attack,Gaze:=False);
            CastSpell: Monster_Spell (Attacker,Monster_Group1,Member,Current_Party_Size);
            Otherwise  If Group < 3 then
                          Begin
                            Max_Target := Min(Current_Party_Size, 3);
                            Target:=Roll_Die (Max_Target);

                            Monster_Attacks (Monsters,Target,Member,Current_Party_Size);
                          End;
         End;
      End;
   Monster_Group1[Group]:=Monsters;
End;  { Handle Monster Attack }
End.  { Monster Attack }

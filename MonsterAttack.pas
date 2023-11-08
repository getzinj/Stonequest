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

Function Undead_Party_Member (Member: Party_Type;  Current_Party_Size: Party_Size_Type; Var Position: Integer): Boolean;

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

{ TODO: Enter this code }

[Global]Procedure Handle_Monster_Attack (Attacker: Attacker_Type;  Var Monster_Group1: Encounter_Group;  Var Member: Party_Type;
                                         Var Current_Party_Size:  Party_Size_Type;  Party_Size: Integer;  Var Can_Attack: Party_Flag);

Begin { Handle Monster Attack }

{ TODO: Enter this code }

End;  { Handle Monster Attack }
End.  { Monster Attack }

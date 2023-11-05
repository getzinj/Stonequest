[Inherit ('SYS$LIBRARY:STARLET','Types','Librtl','SmgRtl','StrRtl','PriorityQueue')]Module Character_Attacks;

Type
   Long_Line = Varying [390] of Char;

Var
   Attacker           : Attacker_Type;
   Delay_Constant     : [External]Real;
   Time_Stop_Monsters : [External]Boolean;
   Silenced           : [External]Party_Flag;
   NoMagic            : [External]Boolean;
   MessageDisplay     : [External]Unsigned;
   Rounds_Left        : [External]Array [Spell_Name] of Unsigned;
   PosZ               : [External,Byte]0..20;
   Leave_Maze         : [External]Boolean;
   CharAttack         : Array [1..7] of Attack_String;
   Item_List          : [External]List_of_Items;

Value
   CharAttack[1]:='swings';    CharAttack[2]:='slices';   CharAttack[3]:='stabs';  CharAttack[4]:='chops';  CharAttack[5]:='hacks';
   CharAttack[6]:='thrusts';   CharAttack[7]:='smashes';


[External]Function  Alive (Character: Character_Type): Boolean;external;
[External]Function  Compute_AC (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function  Critical_hit (Attacker: Character_Type; Defender_Level: Integer): [Volatile]Boolean;External;
[External]Function  Index_of_Living (Group: Monster_Group): [Volatile]Integer;External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  Monster_Name (Monster: Monster_Record; Number: Integer; Identified: Boolean): Monster_Name_Type;External;
[External]Function  Monster_Save (Monster: Monster_Record;  Attack: Attack_Type): [Volatile]Boolean;External;
[External]Function  Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function  Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function  Spell_Damage (Spell: Spell_Name;  Caster_Level: Integer:=0): Die_Type;External;
[External]Function  Spell_Duration (Spell: Spell_Name; Caster_Level: Integer):Integer;External;
[External]Function  String(Num: Integer; Len: Integer:=0):Line;external;
[External]Function  To_hit_Roll (Character: Character_Type; AC: Integer; Monster: Monster_Record): Integer;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Drain_Levels_from_Character (Var Character: Character_Type; Levels: Integer:=1);External;
[External]Procedure Find_Spell_Group (Spell: Spell_Name;  Character: Character_Type;  Var Class,Level: Integer);External;
[External]Procedure Plane_Difference (Var Plus: Integer; PosZ: Integer);External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
(**********************************************************************************************************************)

Function Weapon_Used (Character: Character_Type): Integer;

{ This function returns the position of the equipted (sic) weapon. If none are (sic) equipted (sic), a zero is returned }

Var
   Temp,WeaponUsed: Integer;

Begin
   WeaponUsed:=0;
   If Character.No_of_Items>0 then
      For Temp:=1 to Character.No_of_Items do
         If (Character.Item[Temp].Equipted) and (Item_List[Character.Item[Temp].Item_Num].Kind=Weapon) then
            WeaponUsed:=Temp;
   Weapon_Used:=WeaponUSed;
End;

(**********************************************************************************************************************)

Function Weapon_Used_Name (Character: Character_Type): Name_Type;

Var
   Weapon_Number: Integer;

Begin
   Weapon_Number:=Weapon_Used (Character);
   If Weapon_Number = 0 then
      Weapon_Used_Name := 'bare hands'
   Else If Character.Item[Weapon_Number].Ident then
      Weapon_Used_Name := Item_List[Character.Item[Weapon_Number].Item_Num].True_Name
   Else
      Weapon_Used_Name := Item_List[Character.Item[Weapon_Number].Item_Num].Name;
End;

(**********************************************************************************************************************)

Function Strength_Plus_on_Damage (Character: Character_Type): Integer;

Begin
   Case Character.Abilities[1] of
      3:        Strength_Plus_on_Damage := -3;
      4,5:      Strength_Plus_on_Damage := -2;
      6,7:      Strength_Plus_on_Damage := -1;
      8..14:    Strength_Plus_on_Damage := 0;
      15:       Strength_Plus_on_Damage := 1;
      16,17:    Strength_Plus_on_Damage := 2;
      18:       Strength_Plus_on_Damage := 3;
      19:       Strength_Plus_on_Damage := 4;
      20:       Strength_Plus_on_Damage := 5;
      21:       Strength_Plus_on_Damage := 6;
      22:       Strength_Plus_on_Damage := 7;
      23,24:    Strength_Plus_on_Damage := 8;
      25:       Strength_Plus_on_Damage := 9;
      Otherwise Strength_Plus_on_Damage := 0;
   End;
End;

(**********************************************************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Handle_Character_Attack(   Attacker_Record: Attacker_Type;
                                          Var MonsterGroup: Encounter_Group;
                                          Var Member: Party_Type;
                                          Var Current_Party_Size: Party_Size_Type);

Begin { Handle Character Attack }

{ TODO: Enter this code }

End;  { Handle Character Attack }
End.  { Character Attacks }

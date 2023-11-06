[Inherit ('SYS$LIBRARY:STARLET','Types','Librtl','SmgRtl','StrRtl','PriorityQueue')]Module Character_Attacks_Spells;

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

Function Magic_Resistance (Monster: Monster_Record; Level: Integer): Integer;

Var
  Mod_Resist: Integer;

Begin
  Mod_Resist:=Monster.Magic_Resistance;
  If Mod_Resist > 0 then
     Mod_Resist:=Mod_Resist - (5 * (Level - 1));

  Magic_Resistance:=Mod_Resist;
End;

(**********************************************************************************************************************)

{ TODO: Handle_Group_Spell_1 }

{ TODO: Handle_Group_Spell_2 }

{ TODO: Handle_Party_Spell }

{ TODO: Handle_Caster_Spell }

{ TODO: Handle_All_Monsters_Spell }

{ TODO: Handle_Fire_Ball }

{ TODO: Handle_ID_Spell }

{ TODO: Handle_Heal_Spell }

{ TODO: Handle_Death_Spells }

{ TODO: Handle_Interrupt_Spells }

{ TODO: Handle_Light_Spell }

{ TODO: Handle_Levitate_Spell }

{ TODO: Handle_DetS_Spell }

{ TODO: Handle_Time_Stop_Spell }

{ TODO: Handle_Non_Terminal }

{ TODO: Deux_Ex_Machina }

{ TODO: Compass }

{ TODO: DeSp }

{ TODO: Animate_Dead_Spell }

Procedure Handle_Combat_Spell (Var Group: Encounter_Group;  Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type);

Begin
   { TODO: Implement this. }
End;

(**********************************************************************************************************************)

[Global]Procedure Character_Casts_Spell (Var Group: Encounter_Group;  Var Member: Party_Type;
                                         Var Current_Party_Size: Party_Size_Type);

Begin
   { TODO: Implement this. }
End;
End.

[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','PriorityQueue')]Module Monster_Attack_Spells;

Var
   Item_List                 : [External]List_of_Items;
   Silenced,Can_Attack       : [External]Party_Flag;
   Time_Stop_Players         : [External]Boolean;
   NoMagic                   : [External]Boolean;
   MessageDisplay            : [External]Unsigned;
   Seed                      : [External,Volatile]Unsigned;
   Delay_Constant            : [External]Real;


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
[External]Function  XP_Needed (Class: Class_Type; Level: Integer):Real;Forward;External;
[External]Procedure Attack_Effects (Attack: Attack_Type; CharNum: Integer; Var Member: Party_Type; Var Can_Attack: Party_Flag);External;
[External]Procedure Change_Status (Var Character: Character_Type;  Status: Status_Type;  Var Changed: Boolean);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Procedure Slay_Character (Var Character: Character_Type; Var Can_Attack: Flag);External;
[Asynchronous,External]Function MTH$RANDOM (%Ref Seed: Unsigned): Real;external;
{ TODO: Enter this code }

End.  { Monster Attack Spells }

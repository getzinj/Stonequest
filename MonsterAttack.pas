[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','PriorityQueue')]Module Monster_Attack;

Type
   Prop_Set       = Set of Property_Type;
   Resist_Set     = Set of Attack_Type;

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


{ TODO: Enter this code }

[Global]Procedure Drain_Levels_From_Character (Var Character: Character_Type; Levels: Integer:=1);

Begin
   { TODO: Enter this code }
End;

{ TODO: Enter this code }

[Global]Procedure Handle_Monster_Attack (Attacker: Attacker_Type;  Var Monster_Group1: Encounter_Group;  Var Member: Party_Type;
                                         Var Current_Party_Size:  Party_Size_Type;  Party_Size: Integer;  Var Can_Attack: Party_Flag);

Begin { Handle Monster Attack }

{ TODO: Enter this code }

End;  { Handle Monster Attack }
End.  { Monster Attack }

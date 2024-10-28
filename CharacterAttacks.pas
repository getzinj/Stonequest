(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('SYS$LIBRARY:STARLET','Types','Librtl','SmgRtl','StrRtl','PriorityQueue')]Module Character_Attacks;

Type
   Long_Line = Varying [390] of Char;

Var
   Attacker           : [Global]AttackerType;
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


[External]Function  Compute_AC (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function  Critical_hit (Attacker: Character_Type; Defender_Level: Integer): [Volatile]Boolean;External;
[External]Function  Index_of_Living (Group: Monster_Group): [Volatile]Integer;External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  Monster_Name (Monster: Monster_Record; Number: Integer; Identified: Boolean): Monster_Name_Type;External;
[External]Function  Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function  Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function  String(Num: Integer; Len: Integer:=0):Line;external;
[External]Function  To_hit_Roll (Character: Character_Type; AC: Integer; Monster: Monster_Record): Integer;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Plane_Difference (Var Plus: Integer; PosZ: Integer);External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Procedure Character_Casts_Spell (Var Group: Encounter_Group;  Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type);External;
(**********************************************************************************************************************)

Function Weapon_Used (Character: Character_Type): Integer;

{ This function returns the position of the equipped weapon. If none is equipped, a zero is returned }

Var
   Temp,WeaponUsed: Integer;

Begin
   WeaponUsed:=0;
   If Character.No_of_Items>0 then
      For Temp:=1 to Character.No_of_Items do
         If (Character.Item[Temp].isEquipped) and (Item_List[Character.Item[Temp].Item_Num].Kind=Weapon) then
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

Function Open_Hand_Damage (Class1,Class2: Class_Type; Level1,Level2: Integer): Integer;

Var
   Class: Class_Type;
   DamLoop,Calc,Temp,Level: Integer;

Begin
   Temp:=0;

   If Class1 in [Ninja,Monk] then
      If Class2 in [Ninja,Monk] then
         Begin
            Level:=Max(Level1,Level2);
            Class:=Class1;
         End
      Else
         Begin
            Level:=Level1;
            Class:=Class1;
         End
   Else If Class2 in [Ninja,Monk] then
     Begin
        Level:=Level2;
        Class:=Class2;
     End
   Else
     Begin
        Class:=Fighter;
        Level:=0;
     End;

   If Class in [Ninja,Monk] then
      Begin
         Temp:=Roll_Die(6);
         Calc:=Max(Level div (7 div 2), 1);
         DamLoop:=0;
         While DamLoop<>Calc do
            Begin
               Temp:=Temp + Roll_Die(6);
               DamLoop:=DamLoop + 1;
            End;
      End
   Else
      Temp:=Roll_Die (4);

   Open_Hand_Damage:=Temp;
End;

(**********************************************************************************************************************)

Function Weapon_Damage (Item: Item_Record; Kind: Monster_Type): Integer;

Var
   Dam_Die: Die_Type;
   Temp: Integer;

Begin
   Dam_Die:=Item.Damage;
   Plane_Difference (Dam_Die.Z,PosZ);
   Temp:=Random_Number (Dam_Die);
   If Kind in Item.Versus then
      Temp:=3 * Temp;
   Weapon_Damage:=Temp;
End;

(**********************************************************************************************************************)

Function Class_Bonuses_to_Damage (Class: Class_Type; Level,WeaponUsed: Integer; Kind: Monster_Type): Integer;

Var
   Temp: Integer;

Begin
   Temp:=0;

   Case Class of
        Samurai: Begin
                    Temp:=2;
                    If Kind=Warrior then
                       Temp:=Temp + Level div 2;
                 End;
           Monk: If WeaponUsed>0 then
                    Temp:=Level div 2;
         Ranger: If Kind=Giant then
                     Temp:=Level;
        Paladin: If Kind=Demon then
                     Temp:=Level div 2;
        Otherwise ;
   End;

   Class_Bonuses_to_Damage:=Temp;
End;

(**********************************************************************************************************************)

Function Damage_Inflicted (Character: Character_Type; Group: Monster_Group): Integer;

Var
  Class1,Class2: Class_Type;
  WeaponUsed,Temp,Level1,Level2: Integer;

Begin
   Temp:=0;
   Class1:=Character.Class;           Level1:=Character.Level;
   Class2:=Character.PreviousClass;   Level2:=Character.Previous_Lvl;

   WeaponUsed:=Weapon_Used (Character);
   If WeaponUsed = 0 then
      Temp:=Open_Hand_Damage (Class1,Class2,Level1,Level2)
   Else
      Temp:=Weapon_Damage (Item_List[Character.Item[WeaponUsed].Item_Num],Group.Monster.Kind);  { TODO: Really should make "Item_List[Character.Item[WeaponUsed].Item_Num]" a function. }

   Temp:=Temp + Class_Bonuses_to_Damage (Class1,Level1,WeaponUsed,Group.Monster.Kind);
   Temp:=Temp + Class_Bonuses_to_Damage (Class2,Level2,WeaponUsed,Group.Monster.Kind);

   If Character.Attack.Berserk then Temp:=Temp * 2;

   Temp:=Temp + Strength_Plus_on_Damage (Character);

   Damage_Inflicted:=Max(Temp, 0);
End;

(**********************************************************************************************************************)

Procedure KilL_Off (Var Group: Monster_Group;  Var Number: Integer);

Var
   Count,Index: Integer;

Begin
  Index:=0; Count:=0;
  Repeat
     Begin
        Index:=Index + 1;
        If (Group.Status[Index] in [Healthy,Afraid,Poisoned]) then
           Begin
              Group.Status[Index]:=Dead;
              Count:=Count + 1;
           End;
     End;
  Until (Count=Number) or (Index=Group.Curr_Group_Size);
  Number:=Count;
End;

(**********************************************************************************************************************)

Function getTurnLevel(Class1,Class2: Class_Type; Level1,Level2: Integer): Integer;

Begin
  Case Class1 of
     Cleric: Case Class2 of
                Cleric: getTurnLevel:=Max(Level1,Level2);
                Paladin,AntiPaladin: getTurnLevel:=Max(Level1,Level2 - 3);
                Otherwise getTurnLevel:=Level1;
             End;
     AntiPaladin,Paladin: Case Class2 of
                Cleric: getTurnLevel:=Max(Level1-3,Level2);
                Paladin,AntiPaladin: getTurnLevel:=Max(Level1, Level2) - 3;
                Otherwise getTurnLevel:=Level1 - 3;
             End;
     Otherwise Case Class2 of
              Cleric: getTurnLevel:=Level2;
              Paladin,AntiPaladin: getTurnLevel:=Level2 - 3;
              Otherwise getTurnLevel:=0;
           End;
  End;
End;

(**********************************************************************************************************************)

Procedure Turn_Undead (Member: Party_Type; Var Group: Encounter_Group);

Var
   Level: Integer;
   Which_Group,Which_Character: Integer;
   Monster: Monster_Record;
   C1,C2: Class_Type;
   Roll_Needed,Amount: Integer;
   Character: Character_Type;
   T: Varying [390] of Char;

Begin
   Which_Group:=Attacker.Target_Group;
   Monster:=Group[Which_Group].Monster;

   Which_Character:=Attacker.Attacker_Position;
   Character:=Member[Which_Character];

   T:=Character.Name+' turns ';

   If (Monster.Kind in [Undead,Demon,MultiPlanar]) and Not (NoTurn in Monster.Properties) then
      Begin
         Level:=getTurnLevel(Character.Class,Character.PreviousClass,Character.Level,Character.Previous_Lvl);

         Roll_Needed:=(13 - (3 * Level)) + (Monster.Hit_Points.X * 3);

         If Monster.Kind in [Demon,MultiPlanar] then
             Roll_Needed:=Roll_Needed + 8;

         Amount:=(Level + 1) div 2;

         If (Roll_Die(20) >= Roll_Needed) and (Amount>0) then
            Begin
              Kill_Off (Group[Which_Group],Amount);
              If Amount<1 then
                 T:=T+'to no avail!'
              Else
                 Begin
                    T:=T + 'and ' + String(Amount);
                    If Amount = 1 then
                       T:=T+' is'
                    Else
                       T:=T+' are';
                    T:=T+' dispelled!';
                 End
            End
         Else
            T:=T+'to no avail!';
      End
   Else
      T:=T+'to no avail!';

   SMG$Put_Line (MessageDisplay,T,Wrap_Flag:=SMG$M_WRAP_WORD);
End;

(**********************************************************************************************************************)

[Global]Function Max_Group (Group: Encounter_Group): Integer;

Var
   Temp: Integer;

Begin
   Temp:=0;
   Repeat
      Temp:=Temp + 1;
   Until (Group[Temp].Curr_Group_Size = 0) or (Temp = 4);
   Max_Group := Temp;
End;

(**********************************************************************************************************************)

[Global]Procedure Check_Death (Var Group: Encounter_Group; Mon_Group,i: Integer; Var T: Long_Line);

Begin
   SMG$Put_Line (MessageDisplay,T,Wrap_Flag:=SMG$M_WRAP_WORD);
   If Group[Mon_Group].Curr_HP[i]<1 then
      Begin
         Group[Mon_Group].Status[i]:=Dead;
         SMG$Put_Line (MessageDisplay,Monster_Name (Group[Mon_Group].Monster,1,Group[Mon_Group].Identified) + ' dies!',Wrap_Flag:=SMG$M_WRAP_WORD);
      End;
End;

(**********************************************************************************************************************)

[Global]Function Takes_Damage_Message (Damage: Integer): Line;

Var
   T: Line;

Begin
  If Damage>0 then
    Begin
       T:=' takes ' + String(Damage) + ' hit point';
       If Damage > 1 then
          T:=T+'s';
       T:=T + ' damage!';
    End
  Else
    T:=' is unaffected!';

  Takes_Damage_Message:=T;
End;

(**********************************************************************************************************************)

Function Compute_Num_of_Attacks (Class: Class_Type; Level,WeaponUsed: Integer): Integer;

Var
   Temp: Integer;

Begin
   Case Class of
      Samurai:                                       Temp := 1 + ((Level - 6) div 7);
      Barbarian,Fighter,Ranger,AntiPaladin,Paladin:  Temp := 1 + ((Level - 7) div 8);
      Ninja,Monk:                                    If WeaponUsed = 0 then
                                                        Temp := 1 + ((Level - 5) div 6)
                                                     Else
                                                        Temp := 1;
      Otherwise                                      Temp:=1;
   End;

   Compute_Num_of_Attacks := Max(Temp, 1);
End;

(**********************************************************************************************************************)

Function Num_of_Attacks (Character: Character_Type): Integer;

Var
   Temp,Temp1,Temp2: Integer;
   ItemNum,WeaponUsed,Plus: Integer;

Begin
   WeaponUsed:=Weapon_Used (Character);

   Temp1 := Compute_Num_of_Attacks (Character.Class,         Character.Level,        WeaponUsed);
   Temp2 := Compute_Num_of_Attacks (Character.PreviousClass, Character.Previous_Lvl, WeaponUsed);

   Temp := Max(Temp1,Temp2);

   If Character.Abilities[4]>15 then
      If Made_Roll ((Character.Abilities[4] - 15) * 5) then
         Temp := Temp * 2;

   If Character.Status=Zombie then
      Temp := 1;

   If Character.No_of_Items > 0 then
      For ItemNum := 1 to Character.No_of_Items do
         If Character.Item[ItemNum].isEquipped then
            Begin
               Plus:=Item_List[Character.Item[ItemNum].Item_Num].Additional_Attacks;

               Plane_Difference (Plus,PosZ := PosZ);

               Temp := Temp + Plus;
            End;

   Num_of_Attacks := Temp;
End;

(**********************************************************************************************************************)

Procedure Attempt_to_Hit (Var Mon_Group: Monster_Group; i: Integer; Var Character: Character_Type);

Var
   Number_of_Attacks,Loop,Hits,Damage,Roll_Needed: Integer;
   Monster: Monster_Record;
   T: Varying [390] of Char;

Begin
   Damage := 0;   Hits := 0;  Monster := Mon_Group.Monster;

   SMG$Begin_Display_Update (MessageDisplay);

   T:=Character.Name + ' ' + CharAttack[Roll_Die(7)] + ' at ';
   T:=T + Monster_Name (Monster,1,Mon_Group.Identified) + ' with ';
   T:=T + Weapon_Used_Name (Character);

   Number_of_Attacks := Num_of_Attacks(Character);
   Roll_Needed := To_Hit_Roll (Character,Monster.Armor_Class,Monster);

   If Number_of_Attacks > 0 then
      For Loop := 1 to Number_of_Attacks do
         If Roll_Die(20) >= Roll_Needed then
            Begin
               Hits := Hits + 1;
               Damage := Damage + Damage_Inflicted (Character,Mon_Group);
            End;

   T := T + ' and ';

   If Hits > 0 then
      Begin
         T := T + 'hits ';
         If Hits = 1 then
            T := T + 'once '
         Else
            T := T + String(Hits) + ' times ';

         T := T + 'for ' + String(Damage) + ' hit point';
         If Damage > 1 then
            T := T + 's';
         T := T + ' of damage!';
         SMG$Put_Line (MessageDisplay,T,Wrap_Flag := SMG$M_WRAP_WORD);
         SMG$End_Display_Update (MessageDisplay);

         If Critical_Hit (Character,Mon_Group.Monster.Hit_Points.X) then
            Begin
               SMG$Put_Line (MessageDisplay,'A critical hit!',0,1);

               Ring_Bell (MessageDisplay, 3);

               Delay ((2 * Delay_Constant) + 1);

               Mon_Group.Status[i] := Dead;
            End
      End
   Else
      Begin
         T := T + 'misses!';
         SMG$Put_Line (MessageDisplay,T,Wrap_Flag:=SMG$M_WRAP_WORD);
         SMG$End_Display_Update (MessageDisplay);
      End;

   Mon_Group.Curr_HP[i]:=Mon_Group.Curr_HP[i] - Damage;
   If (Mon_Group.Curr_HP[i] < 1) or (Mon_Group.Status[i]=Dead) then
      Begin
         Mon_Group.Status[i] := Dead;

         SMG$Set_Cursor_ABS (MessageDisplay,,1);
         SMG$Put_Line (MessageDisplay,Character.Name+' kills it!',,1,Wrap_Flag := SMG$M_WRAP_WORD);
      End;

   Delay (Delay_Constant);
End;

(**********************************************************************************************************************)

Procedure Character_Attacks (Var Group: Encounter_Group; Var Member: Party_Type);

Var
   Character: Character_Type;
   Mon_Group,I: Integer;

Begin
   Mon_Group:=Attacker.Target_Group;
   Character:=Member[Attacker.Attacker_Position];
   i:=Index_of_Living (Group[Mon_Group]);

   If i > 0 then
      Attempt_to_Hit (Group[Mon_Group],i,Character);
End;

(**********************************************************************************************************************)

Procedure Switch_Items (Attacker_Record: AttackerType; Var Member: Party_Type);

Var
  Character: Character_Type;
  T: Varying [390] of Char;

Begin
   Character := Member[Attacker.Attacker_Position];
   T := Character.Name;

   If Attacker.Old_Item > 0 then
      Character.Item[Attacker.Old_Item].isEquipped := False;

   If Attacker.New_Item > 0 then
      Begin
         Character.Item[Attacker.New_Item].isEquipped := True;

         If Item_List[Character.Item[Attacker.New_Item].Item_Num].Cursed then
            Character.Item[Attacker.New_Item].Cursed := True;

         If Item_List[Character.Item[Attacker.New_Item].Item_Num].Kind = Weapon then
            Begin
               Character.Attack.WeaponUsed := Attacker.New_Item;

               If Attacker.Old_Item > 0 then
                  SMG$Put_Line (MessageDisplay,T + ' switches weapons!',Wrap_Flag:=SMG$M_WRAP_WORD)
               Else
                  SMG$Put_Line (MessageDisplay,T + ' picks up a weapon!',Wrap_Flag:=SMG$M_WRAP_WORD)
            End
         Else If Attacker.Old_Item > 0 then
              SMG$Put_Line (MessageDisplay,T + ' switches items!',Wrap_Flag:=SMG$M_WRAP_WORD)
         Else
              SMG$Put_Line (MessageDisplay,T + ' puts on an item!',Wrap_Flag:=SMG$M_WRAP_WORD);
      End
   Else If Item_List[Character.Item[Attacker.New_Item].Item_Num].Kind=Weapon then
        SMG$Put_Line (MessageDisplay,T + ' drops a weapon!',Wrap_Flag:=SMG$M_WRAP_WORD)
   Else
        SMG$Put_Line (MessageDisplay,T + ' takes off an item!',Wrap_Flag:=SMG$M_WRAP_WORD);

   Character.Regenerates := Regenerates (Character,PosZ);
   Character.Armor_Class := Compute_AC (Character,PosZ);

   Member[Attacker.Attacker_Position] := Character;

   Delay (Delay_Constant);
End;

(**********************************************************************************************************************)

[Global]Procedure Handle_Character_Attack(   Attacker_Record: AttackerType;
                                          Var MonsterGroup: Encounter_Group;
                                          Var Member: Party_Type;
                                          Var Current_Party_Size: Party_Size_Type);

Begin { Handle Character Attack }
   Attacker:=Attacker_Record;  { Make it module-global }
   Case Attacker.Action of
      TurnUndead:        Turn_Undead (Member,MonsterGroup);
      CastSpell,UseItem: Character_Casts_Spell (MonsterGroup,Member,Current_Party_Size);
      SwitchItems:       Switch_Items (Attacker,Member);
      Berserker_Rage:    Begin
                            Attacker.Action := Attack;

                            Member[Attacker.Attacker_Position].Armor_Class := Member[Attacker.Attacker_Position].Armor_Class + 2;
                            Member[Attacker.Attacker_Position].Attack.Berserk := True;
                            If Attacker.Attacker_Position = 1 then
                               Character_Attacks (MonsterGroup,Member);
                         End;
      Otherwise          Character_Attacks (MonsterGroup, Member);
   End;
End;  { Handle Character Attack }
End.  { Character Attacks }

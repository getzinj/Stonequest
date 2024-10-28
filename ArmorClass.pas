(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types','SMGRTL','STRRTL')]Module ArmorClass;

Var
   Item_List:                  [External]List_of_items;


(******************************************************************************)
[External]Procedure Plane_Difference (Var Plus: Integer; PosZ: Integer);External;
(******************************************************************************)

Function Dexterity_Change (Dexterity: Integer): Integer;

{ This function returns the amount that should be subtracted from the Armor Class of a person whose dexterity is DEXTERITY. }

Begin { Dexterity_Change }
   Case Dexterity of  { Dexterity provides base Armor Class }
                  3: Dexterity_Change := -4;
                  4: Dexterity_Change := -3;
                  5: Dexterity_Change := -2;
                  6: Dexterity_Change := -1;
              7..14: Dexterity_Change :=  0;
                 15: Dexterity_Change :=  1;
                 16: Dexterity_Change :=  2;
                 17: Dexterity_Change :=  3;
           18,19,20: Dexterity_Change :=  4;
           21,22,23: Dexterity_Change :=  5;
              24,25: Dexterity_Change :=  6;
           Otherwise Dexterity_Change :=  0;
   End;
End;  { Dexterity_Change }

(******************************************************************************)

Function Compute_Monk_Level (Character: Character_Type; wearingArmor: boolean): Integer;

{ This function computes the level of monk-like skills CHARACTER has. }

Begin { Compute Monk Level }
  If wearingArmor or (Character.Status = Zombie) then
     Compute_Monk_Level := 0
  Else If Character.Class in [Monk,Ninja] then
          If Character.PreviousClass in [Monk,Ninja] then
             Compute_Monk_Level := Max (Character.Level,Character.Previous_Lvl)
          Else
             Compute_Monk_Level := Character.Level
  Else If Character.PreviousClass in [Monk,Ninja] then
          Compute_Monk_Level := Character.Previous_Lvl
       Else
          Compute_Monk_Level := 0;
End;  { Compute Monk Level }

(******************************************************************************)

Function Item_AC_Bonus(character: Character_Type; PosZ: Integer; Var Wearing_Armor: Boolean): Integer;

Var
   plus: Integer;
   Total_Plus: Integer;
   Item: Item_Record;
   ItemNo: Integer;

Begin
   Total_Plus := 0;
   If Character.No_of_Items > 0 then
      For ItemNo:=1 to Character.No_of_Items do
         If Character.Item[ItemNo].isEquipped then
            Begin
               Item:=Item_List[Character.Item[ItemNo].Item_Num];

               If Item.Kind in [ Armor, Helmet, Gloves, Shield ] then
                  Wearing_Armor:=True;

               Plus:=Item.AC_Plus;
               Plane_Difference (Plus,PosZ);

               Total_Plus := Total_Plus + Plus;
            End;

   Item_AC_Bonus := Total_Plus;
End;

(******************************************************************************)

Function Monk_Armor_Class(Monk_Level: Integer): Integer;

Var
   Monk_AC: Integer;

Begin
   If Monk_Level > 0 then
      Monk_Armor_Class := 10 - (2 * (Monk_Level div 2))
   Else
      Monk_Armor_Class := MaxInt;
End;

(******************************************************************************)

Function Spells_AC_Bonus: [Volatile]Integer;

Var
   Rounds_Left: [External]Array [Spell_Name] of Unsigned;
   Bonus: Integer;

Begin
   Bonus := 0;

   If Rounds_Left[DiPr]>0 then
       Bonus:=Bonus + 2;
   If Rounds_Left[HgSh]>0 then
       Bonus:=Bonus + 4;

   Spells_AC_Bonus := Bonus;
End;

(******************************************************************************)

[Global]Function Compute_AC (Character: Character_Type; PosZ: Integer:=0): Integer;

{ This function will return the Armor Class value for CHARACTER }

Var
   Dexterity,AC,Monk_AC: Integer;
   Wearing_Armor: Boolean;
   dexterityBonus: integer;
   itemsBonus: integer;

Begin { Compute AC }
   Dexterity := Character.Abilities[4];
   If Character.Status=Zombie then
      Dexterity := Min(Dexterity, 5);

   Wearing_Armor:=False;
   itemsBonus := Item_AC_Bonus(Character, PosZ, Wearing_Armor);

   If Character.Status in [Healthy,Poisoned,Zombie,Afraid] then
      Begin
        AC := Min (10, Monk_Armor_Class(Compute_Monk_Level (Character, Wearing_Armor)));
        AC := AC - Dexterity_Change (Dexterity);
      End
   Else
      AC := 12;

   AC := AC - itemsBonus;      { Everybody gets protection from armor and magic items }
   AC := AC - Spells_AC_Bonus; { Everybody gets spells bonuses }

   Compute_AC := Max(AC, -15);
End;  { Compute AC }
End.  { ArmorClass }

(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types')]Module Experience;

Type
  AttackSet = Set of Attack_Type;

(******************************************************************************)

Function Special_Attacks (Monster: Monster_Record): Boolean;

Begin
   Special_Attacks:=(Monster.No_of_Attacks > 1) or (Monster.Armor_Class < 2) or (Monster.Highest.Cleric_Spell > 0);
End;

(******************************************************************************)

Function Maximum_Damage (Monster: Monster_Record): Integer;

Var
  AttackNum: Integer;
  Attack: Die_Type;
  Temp: Integer;

Begin
  Temp := 0;
  For AttackNum := 1 to Monster.No_of_Attacks do
     Begin
        Attack := Monster.Damage[AttackNum];
        Temp := Temp + Max((Attack.X * Attack.Y) + Attack.Z, 0);
     End;

  Maximum_Damage := Temp;
End;

(******************************************************************************)

Function Exceptional_Attacks (Monster: Monster_Record): Boolean;

Begin
   Exceptional_Attacks:= (Monster.Levels_Drained>0)        or ([Paralyzes,Autokills,Stones,Poisons,NoTurn,Cause_Fear] * Monster.Properties<>[ ]) or
                         (Monster.Magic_Resistance>0)      or (Monster.Highest.Wizard_Spell>0)                                                   or
                         (Monster.Years_Ages>0)            or (Monster.No_of_Attacks>3)                                                          or
                         (Monster.Armor_Class<-1)          or (Monster.Resists<>[ ])                                                             or
                         (Monster.Breath_Weapon<>NoAttack) or (Monster.Highest.Cleric_Spell>3)                                                   or
                         (Monster.Regenerates>0)           or (Monster.Gaze_Weapon<>NoAttack);
End;

(******************************************************************************)

Function Resists_XP_Bonus (hd: integer; resists: AttackSet): Integer;

Begin
   Case HD of
             0: Resists_XP_Bonus :=    2 * Card(Resists);
             1: Resists_XP_Bonus :=    4 * Card(Resists);
             2: Resists_XP_Bonus :=    8 * Card(Resists);
             3: Resists_XP_Bonus :=   25 * Card(Resists);
             4: Resists_XP_Bonus :=   40 * Card(Resists);
             5: Resists_XP_Bonus :=   75 * Card(Resists);
             6: Resists_XP_Bonus :=  125 * Card(Resists);
             7: Resists_XP_Bonus :=  175 * Card(Resists);
             8: Resists_XP_Bonus :=  450 * Card(Resists);
             9: Resists_XP_Bonus :=  700 * Card(Resists);
      10 .. 11: Resists_XP_Bonus :=  950 * Card(Resists);
      12 .. 13: Resists_XP_Bonus := 1250 * Card(Resists);
      14 .. 15: Resists_XP_Bonus := 1550 * Card(Resists);
      16 .. 17: Resists_XP_Bonus := 2100 * Card(Resists);
      18 .. 19: Resists_XP_Bonus := 2600 * Card(Resists);
      Otherwise Resists_XP_Bonus := 3100 * Card(Resists);
   End;
End;

(******************************************************************************)

Function Hit_Points_XP_Bonus (hd: integer; hp: integer): Integer;

Begin
   Case HD of
             0: Hit_Points_XP_Bonus :=   2 * HP;
             1: Hit_Points_XP_Bonus :=   4 * HP;
             2: Hit_Points_XP_Bonus :=   6 * HP;
             3: Hit_Points_XP_Bonus :=   8 * HP;
             4: Hit_Points_XP_Bonus :=  10 * HP;
             5: Hit_Points_XP_Bonus :=  12 * HP;
             6: Hit_Points_XP_Bonus :=  16 * HP;
             7: Hit_Points_XP_Bonus :=  20 * HP;
             8: Hit_Points_XP_Bonus :=  28 * HP;
             9: Hit_Points_XP_Bonus :=  32 * HP;
      10 .. 11: Hit_Points_XP_Bonus :=  36 * HP;
      12 .. 13: Hit_Points_XP_Bonus :=  40 * HP;
      14 .. 15: Hit_Points_XP_Bonus :=  50 * HP;
      16 .. 17: Hit_Points_XP_Bonus :=  60 * HP;
      18 .. 19: Hit_Points_XP_Bonus :=  70 * HP;
      Otherwise Hit_Points_XP_Bonus :=  80 * HP;
   End;
End;

(******************************************************************************)

Function Hit_Die_XP_Bonus (hd: integer): Integer;

Begin
   Case HD of
             0: Hit_Die_XP_Bonus :=     5;
             1: Hit_Die_XP_Bonus :=    10;
             2: Hit_Die_XP_Bonus :=    35;
             3: Hit_Die_XP_Bonus :=    60;
             4: Hit_Die_XP_Bonus :=    90;
             5: Hit_Die_XP_Bonus :=   150;
             6: Hit_Die_XP_Bonus :=   225;
             7: Hit_Die_XP_Bonus :=   375;
             8: Hit_Die_XP_Bonus :=   600;
             9: Hit_Die_XP_Bonus :=   900;
      10 .. 11: Hit_Die_XP_Bonus :=  1300;
      12 .. 13: Hit_Die_XP_Bonus :=  1800;
      14 .. 15: Hit_Die_XP_Bonus :=  2400;
      16 .. 17: Hit_Die_XP_Bonus :=  3000;
      18 .. 19: Hit_Die_XP_Bonus :=  4000;
      Otherwise Hit_Die_XP_Bonus :=  5000;
   End;
End;

(******************************************************************************)

Function Special_Attacks_XP_Bonus (hd: integer): Integer;

Begin
   Case HD of
             0: Special_Attacks_XP_Bonus :=     20;
             1: Special_Attacks_XP_Bonus :=     40;
             2: Special_Attacks_XP_Bonus :=     80;
             3: Special_Attacks_XP_Bonus :=    250;
             4: Special_Attacks_XP_Bonus :=    400;
             5: Special_Attacks_XP_Bonus :=    750;
             6: Special_Attacks_XP_Bonus :=   1250;
             7: Special_Attacks_XP_Bonus :=   1750;
             8: Special_Attacks_XP_Bonus :=   4500;
             9: Special_Attacks_XP_Bonus :=   7000;
      10 .. 11: Special_Attacks_XP_Bonus :=   9500;
      12 .. 13: Special_Attacks_XP_Bonus :=  12500;
      14 .. 15: Special_Attacks_XP_Bonus :=  15500;
      16 .. 17: Special_Attacks_XP_Bonus :=  17000;
      18 .. 19: Special_Attacks_XP_Bonus :=  19000;
      Otherwise Special_Attacks_XP_Bonus :=  21000;
   End;
End;

(******************************************************************************)

Function Exceptional_Attacks_XP_Bonus (hd: integer): Integer;

Begin
   Case HD of
             0: Exceptional_Attacks_XP_Bonus :=    50;
             1: Exceptional_Attacks_XP_Bonus :=    70;
             2: Exceptional_Attacks_XP_Bonus :=    90;
             3: Exceptional_Attacks_XP_Bonus :=    90;
             4: Exceptional_Attacks_XP_Bonus :=   150;
             5: Exceptional_Attacks_XP_Bonus :=   250;
             6: Exceptional_Attacks_XP_Bonus :=   350;
             7: Exceptional_Attacks_XP_Bonus :=   550;
             8: Exceptional_Attacks_XP_Bonus :=  1200;
             9: Exceptional_Attacks_XP_Bonus :=  1500;
      10 .. 11: Exceptional_Attacks_XP_Bonus :=  1700;
      12 .. 13: Exceptional_Attacks_XP_Bonus :=  2000;
      14 .. 15: Exceptional_Attacks_XP_Bonus :=  2300;
      16 .. 17: Exceptional_Attacks_XP_Bonus :=  2800;
      18 .. 19: Exceptional_Attacks_XP_Bonus :=  3300;
      Otherwise Exceptional_Attacks_XP_Bonus :=  3800;
   End;
End;

(******************************************************************************)

Function Breath_and_Gaze_XP_Bonus (hd: integer; HP: integer): Integer;

Begin
   Case HD of
             0: Breath_and_Gaze_XP_Bonus :=  HP * 10;
             1: Breath_and_Gaze_XP_Bonus :=  HP * 10;
             2: Breath_and_Gaze_XP_Bonus :=  HP * 10;
             3: Breath_and_Gaze_XP_Bonus :=  HP * 10;
             4: Breath_and_Gaze_XP_Bonus :=  HP * 10;
             5: Breath_and_Gaze_XP_Bonus :=  HP * 10;
             6: Breath_and_Gaze_XP_Bonus :=  HP * 10;
             7: Breath_and_Gaze_XP_Bonus :=  HP * 10;
             8: Breath_and_Gaze_XP_Bonus :=  HP * 10;
             9: Breath_and_Gaze_XP_Bonus :=  HP * 10;
      10 .. 11: Breath_and_Gaze_XP_Bonus :=  HP * 10;
      12 .. 13: Breath_and_Gaze_XP_Bonus :=  HP * 10;
      14 .. 15: Breath_and_Gaze_XP_Bonus :=  HP * 10;
      16 .. 17: Breath_and_Gaze_XP_Bonus :=  HP * 10;
      18 .. 19: Breath_and_Gaze_XP_Bonus :=  HP * 10;
      Otherwise Breath_and_Gaze_XP_Bonus :=  HP * 10;
   End;
End;

(******************************************************************************)

Function Maximum_Damage_Bonus (hd: integer; maximumDamage: integer): Integer;

Begin
   Case HD of
             0: Maximum_Damage_Bonus :=  maximumDamage * 1;
             1: Maximum_Damage_Bonus :=  maximumDamage * 2;
      Otherwise Maximum_Damage_Bonus :=  Maximum_Damage_Bonus(HD - 2, maximumDamage)
                                       + Maximum_Damage_Bonus(HD - 1, maximumDamage);
   End;
End;

(******************************************************************************)

[Global]Function Experience (Number: Integer; Group: Monster_Group): Real;

Const
  Damaging_Attacks = [Fire, Frost, Electricity, LvlDrain, Magic];

Var
  Temp: Real;
  Monster: Monster_Record;
  HP: Integer;
  HD: Integer;

Begin { Experience }
  Monster:=Group.Monster;

  HD:=Monster.Hit_Points.X;
  HP:=Group.MAX_HP[Number];

  Temp := Hit_Die_XP_Bonus (HD);
  Temp := Temp + Max(Maximum_Damage_Bonus(HD, Maximum_Damage(Monster)), 0);
  Temp := Temp + Max(Hit_Points_XP_Bonus(HD, HP), 0);
  Temp := Temp + Max(Resists_XP_Bonus(HD, Monster.Resists), 0);

  If (Special_Attacks (Monster)) then
     Temp := Temp + Max(Special_Attacks_XP_Bonus(HD), 0);

  If (Exceptional_Attacks (Monster)) then
     Temp := Temp + Max(Exceptional_Attacks_XP_Bonus(HD), 0);

  If Monster.Breath_Weapon in Damaging_Attacks then
     Temp:=Temp + Max(Breath_and_Gaze_XP_Bonus(HD, HP), 0);

  If Monster.Gaze_Weapon in Damaging_Attacks then
     Temp:=Temp + Max(Breath_and_Gaze_XP_Bonus(HD, HP), 0);

  Temp:=Temp + (200 * Monster.highest.Cleric_Spell);
  Temp:=Temp + (300 * Monster.highest.Wizard_Spell);
  Temp:=Temp + Max((-15) * (Monster.Armor_Class - 10), 0);

  Experience:=Temp;
End;  { Experience }
End.  { Experience }

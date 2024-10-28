(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','PriorityQueue')]Module Monster_Attack_Spells;

Var
   Item_List                 : [External]List_of_Items;
   Silenced,Can_Attack       : [External]Party_Flag;
   Time_Stop_Players         : [External]Boolean;
   NoMagic                   : [External]Boolean;
   MessageDisplay            : [External]Unsigned;
   Seed                      : [External,Volatile]Unsigned;
   Delay_Constant            : [External]Real;


(**********************************************************************************************************************)
[External]Function  Alive (Character: Character_Type): Boolean;External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  Made_Save (Character: Character_Type; Attack: Attack_Type): [Volatile]Boolean;External;
[External]Function  Monster_Name (Monster: Monster_Record; Number: Integer; Identified: Boolean): Monster_Name_Type;External;
[External]Function  Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function  Spell_Damage (Spell: Spell_Name;  Caster_Level: Integer:=0): Die_Type;External;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
[External]Function Undead_Party_Member (Member: Party_Type;  Current_Party_Size: Party_Size_Type; Var Position: Integer): Boolean;External;
[External]Procedure Change_Status (Var Character: Character_Type;  Status: Status_Type;  Var Changed: Boolean);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Slay_Character (Var Character: Character_Type; Var Can_Attack: Flag);External;
[Asynchronous,External]Function MTH$RANDOM (%Ref Seed: Unsigned): Real;external;
(**********************************************************************************************************************)

Function Choose_Wizard (Level: Integer): Spell_Name;

Var
   Temp: Spell_Name;

Begin
   Case Level of
      1: Temp:=MaMs;
      2: Case Roll_Die (2) of
            1: Temp:=MaMs;
            2: Temp:=Fear;
         End;
      3: Case Roll_Die (7) of
            1,2,3,5: Temp:=FiBl;
                6,7: Temp:=LiBt;
                  4: Temp:=BiSh;
         End;
      4: Case Roll_Die (7) of
             1,2,3: Temp:=FiBl;
           4,5,6,7: Temp:=GrSh;
         End;
      5: Temp:=CoCd;
      6: Case Roll_Die (5) of
           1,2: Temp:=DeSp;
             3: Temp:=HgSh;
           4,5: Temp:=CoCd;
          End;
      7: Case Roll_Die (4) of
             1: Temp:=Slep;
           2..4: Temp:=MgFi;
         End;
      8: Case Roll_Die (3) of
             1,2: Temp:=MgFi;
             3: Temp:=Slay;
         End;
      9: Case Roll_Die (5) of
             1: Temp:=Kill;
             2,4: Temp:=Holo;
             5: Temp:=TiSt;
             3: Temp:=Harm;
         End;
   End;

   Choose_Wizard:=Temp;
End;

(**********************************************************************************************************************)

Function Choose_Cleric (Level: Integer; Member: Party_Type; Current_Party_Size: Integer): Spell_Name;

Var
   Temp: Spell_Name;
   Dummy: Integer;

Begin
   Case Level of
      1: Temp:=CsLt;
      2: Case Roll_Die (4) of
            1: Temp:=CsLt;
            2,3,4: If Undead_Party_Member (Member,Current_Party_Size,Dummy) then
                      Temp:=Dspl
                   Else
                      Temp:=CsLt;
         End;
      3: Temp:=CsSe;
      4: Case Roll_Die (6) of
                 1: Temp:=CsVs;
             3,4,5: Temp:=Wrth;
               6,2: Temp:=Sile;
         End;
      5: Case Roll_Die (5) of
                 1: Temp:=CsCr;
             2,3,4: Temp:=GrWr;
                 5: Temp:=Slay;
         End;
      6: Case Roll_Die (7) of
           1..3: Temp:=Harm;
             4: Temp:=DiPr;
           5..7: Temp:=HoWr;
          End;
      7: Temp:=Dest;
      8: Case Roll_Die (4) of
         1,2,3: Temp:=DiWr;
             4: Temp:=RaDe;
         End;
      9: Case Roll_Die (4) of
             1..3: Temp:=DiWr;
             4: Temp:=DiDe;
         End;
   End;

   Choose_Cleric:=Temp;
End;

(**********************************************************************************************************************)

Function Random_Spell_Level (Level: Integer): Integer;

{ This function simulates some sort of intelligence on the part of a spell caster: an Arch Mage isn't going to waste much time with
  first level spells most of the time }

Var
  R1: Integer;
  Rand: Real;

Begin
{  MTH$RANDOM -> 0-.999999 }

  Rand:=Sqrt(MTH$RANDOM(Seed));
  R1:=Trunc (Level * (Rand)) + 1;

  { Shift the scale toward 1 }

  Random_Spell_Level := R1;
End;

(**********************************************************************************************************************)

Function Random_Spell (ClerLevel,WizLevel: Integer; Member: Party_Type; Current_Party_Size: Integer): Spell_Name;

Var
   ClerChance,WizChance,Class: Integer;
   Temp: Spell_Name;

Begin
   ClerChance:=0;  WizChance:=0;
   If ClerLevel > 0 then
      ClerChance:=50;

   If WizLevel > 0 then
      WizChance:=50;

   If WizLevel > ClerLevel -2 then ClerChance:=ClerChance-20;

   If ClerLevel>WizLevel + 2 then WizChance:=WizChance-10;

   Class:=Roll_Die (WizChance + ClerChance);

   If Class<=ClerChance then
      Class:=1
   Else
      Class:=2;

   If Class=1 then
      Temp:=Choose_Cleric (Random_Spell_Level (ClerLevel),Member,Current_Party_Size)
   Else
      Temp:=Choose_Wizard (Random_Spell_Level (WizLevel));

   Random_Spell:=Temp;
End;

(**********************************************************************************************************************)

Procedure Handle_Monster_Group_Spell_1 (Attacker: AttackerType;  Var Member: Party_Type;  Current_Party_Size: Integer);

Var
   Form: Attack_Type;
   Loop,CharPosition,Damage: Integer;
   Dam: Die_Type;
   Character: Character_Type;
   T: Line;

Begin
   Dam.X:=1;  Dam.Y:=1;
   Dam.Z:=-1;  Damage:=0;

   CharPosition:=Roll_Die (Current_Party_Size);
   Character:=Member[CharPosition];
   T:=Character.Name;

   Case Attacker.WhatSpell of
      MaMs:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (MaMs,Attacker.Caster_Level);
             End;
      CsLt:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (CsLt);
             End;
      CsSe:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (CsSe);
             End;
      CsVs:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (CsVs);
             End;
      CsCr:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (CsCr);
             End;
      Harm:  Begin
                Form:=Magic;
                If Made_Save (Character, Magic) then
                   Damage:=0
                Else
                   Damage:=Character.Curr_HP - Roll_Die(4);
             End;
      Slay:  Begin
                Form:=Death;
                If Made_Save (Character, Death) then
                   Damage:=0
                Else
                   Damage:=Character.Curr_HP;
             End;
      Dest:  Begin
                Form:=Death;
                Damage:=Character.Curr_HP;
                If Made_Save (Character, Death) then
                   Damage:=Min(Roll_Die(30), Character.Curr_HP);
             End;
      Kill:  Begin
                Form:=Death;
                If Character.Curr_HP<61 then
                   Damage:=Character.Curr_HP
                Else
                   Damage:=0;
             End;
   End;

   Damage := Damage + Random_Number (Dam);

   If Character.No_of_Items > 0 then
      For Loop:=1 to Character.No_of_items do
         If Character.Item[Loop].isEquipped then
            If Form in Item_List[Character.Item[Loop].Item_Num].Resists then
               Damage:=Trunc(Damage / 2);

   Character.Curr_HP := Character.Curr_HP - Damage;

   If Damage>0 then
      Begin
         If (Character.Status=Asleep) then
            Character.Status:=Healthy;

         T := T + ' takes ' + String (Damage) + ' hit point';
         If Damage > 1 then
            T:=T + 's';
         T:=T + ' damage!';
      End
   Else
      T := T + ' is unaffected!';

   If Alive (Character) then
      Begin
         SMG$Put_Line (MessageDisplay, T);

         If (Character.Curr_HP < 1) then
             Slay_Character (Character,Can_Attack[CharPosition]);
      End;

   Character.Curr_HP := Max(Character.Curr_HP, 0);

   Member[CharPosition] := Character;
End;

(**********************************************************************************************************************)

Function Magic_Resistance (Character: Character_Type; Level: Integer): Integer;

Var
   Mod_Resist: Integer;

Begin
   Mod_Resist := Character.Magic_Resistance;

   If Mod_Resist > 0 then
      Mod_Resist:=Mod_Resist - (5 * (Level - 11));

   Magic_Resistance := Mod_Resist;
End;

(**********************************************************************************************************************)

Procedure Handle_Monster_Group_Spell_2 (Attacker: AttackerType;  Var Member: Party_Type;  Current_Party_Size: Integer);

Var
   Form: Attack_Type;
   Loop,Damage,i: Integer;
   Dam: Die_Type;
   Character: Character_Type;
   T: Line;

Begin
   Form := Magic;  Dam:=Zero;  Damage:=0;

   Case Attacker.WhatSpell of
      Wrth:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (Attacker.WhatSpell);
             End;
      GrWr:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (Attacker.WhatSpell);
             End;
      HoWr:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (Attacker.WhatSpell);
             End;
      DiWr:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (Attacker.WhatSpell);
             End;
      Holo:  Begin
                Form:=Magic;
                Dam:=Spell_Damage (Attacker.WhatSpell);
             End;
      CoCd:  Begin
                Form:=Frost;
                Dam:=Spell_Damage (Attacker.WhatSpell,Attacker.Caster_Level);
             End;
      LiBt:  Begin
                Form:=Electricity;
                Dam:=Spell_Damage (Attacker.WhatSpell,Attacker.Caster_Level);
             End;
      FiBl:  Begin
                Form:=Fire;
                Dam:=Spell_Damage (Attacker.WhatSpell,Attacker.Caster_Level);
             End;
      MgFi:  Begin
                Form:=Fire;
                Dam:=Spell_Damage (Attacker.WhatSpell,Attacker.Caster_Level);
             End;
      DeSp:  ;
   End;

   For i := 1 to Current_Party_Size do
      Begin
         Character:=Member[i];
         If Attacker.WhatSpell=DeSp then
            If Max(Character.Level,Character.Previous_Lvl)<3 then { TODO: It should be the sum }
               Damage:=Character.Curr_HP
            Else
               Damage:=0;

         T:=Character.Name;

         Damage := Damage + Random_Number (Dam);
         If Made_Save (Character,Form) then
            Damage := Trunc (Damage / 2);

         If Character.No_of_Items > 0 then
            For Loop:=1 to Character.No_of_items do
               If Character.Item[Loop].isEquipped then
                  If Form in Item_List[Character.Item[Loop].Item_Num].Resists then
                     Damage:=Trunc(Damage / 2);

         If Attacker.WhatSpell in [FiBl,MgFi] then
            Damage:=Round(Damage*(1 / i));

         If Made_Roll (Magic_Resistance (Character,Attacker.Caster_Level)) then
            Damage:=0;

         Character.Curr_HP := Character.Curr_HP - Damage;

         If (Character.Status=Asleep) and (Damage > 0) then
            Character.Status:=Healthy;

         SMG$Begin_Display_Update (MessageDisplay);
         SMG$Set_Cursor_ABS (MessageDisplay, 2, 1);
         SMG$Put_Line (MessageDisplay,'');
         SMG$Put_Line (MessageDisplay,'',0);
         SMG$Set_Cursor_ABS (MessageDisplay, 2, 1);
         SMG$End_Display_Update (MessageDisplay);

         If Damage>0 then
            Begin
              T := T + ' takes ' + String (Damage) + ' hit point';
              If Damage > 1 then
                  T:=T + 's';
              T:=T + ' damage!';
            End
         Else
             T := T + ' is unaffected!';

         If Alive (Character) then
            SMG$Put_Line (MessageDisplay, T);

         If Alive(Character) and (Character.Curr_HP<1) then
            Slay_Character (Character,Can_Attack[i]);

         Character.Curr_HP := Max(Character.Curr_HP, 0);

         Delay (Delay_Constant);
         Member[i]:=Character;
      End;
End;

(**********************************************************************************************************************)

Procedure Handle_Monster_Protection_Spell (Attacker: AttackerType; Var Group: Monster_Group);

Var
   Amount: Integer;

Begin
   Amount:=0;

   Case Attacker.WhatSpell of
      GrSh,DiPr: Amount:=2;
           BiSh: Amount:=1;
           HgSh: Amount:=4;
   End;

   Group.Monster.Armor_Class:=Group.Monster.Armor_Class - Amount;
End;

(**********************************************************************************************************************)

Procedure Handle_Monster_Death_Spells (Var Member: Party_Type;  Current_Party_Size: Integer; Level: Integer);

Var
   T: Line;
   Chosen: Integer;
   Worked: Boolean;
   Character: Character_Type;

Begin
   Worked:=False;

   Chosen := Roll_Die (Current_Party_Size);

   Character:=Member[Chosen];

   T:=Character.Name + ' is ';

   Worked:=Not(Made_Save (Character,Death)) and Alive(Character);
   Worked:=Worked and Not Made_Roll (Magic_Resistance(Character,Level));

   If (Worked) then
      Begin
         Character.Status := Dead;
         Character.Curr_HP :=0;
         Member[Chosen]:=Character;
      End
   Else
      T:=T+'not ';

   T:=T+'slain!';
   SMG$Put_Line (MessageDisplay,T,0);
End;

(**********************************************************************************************************************)

Procedure Handle_Monster_Displ (Var Member: Party_Type; Current_Party_Size: Integer);

Var
   T: Line;
   Chosen: Integer;

Begin
   If Undead_Party_Member (Member,Current_Party_Size,Chosen) then
      Begin
         T:=Member[Chosen].Name + ' is dispelled!';

         Member[Chosen].Status := Ashes;
         Member[Chosen].Curr_HP:=0;
      End
   Else
      T:='but nothing happens!';

   SMG$Put_Line (MessageDisplay,T,0);
End;

(**********************************************************************************************************************)

Procedure Handle_Monster_Non_Lethal (Attacker: AttackerType; Var Member: Party_Type; Current_Party_Size: Integer);

Var
   T, verb: Line;
   Char_Num: Integer;
   Attack: Attack_Type;
   Affected, Saved: Boolean;
   Character: Character_Type;

Begin
   If Attacker.WhatSpell in [Slep,Sile] then Attack := Magic
   Else                                      Attack := CauseFear;

   Case Attacker.WhatSpell of
       Slep: verb:='slept';
       Fear: verb:='made afraid';
       Sile: verb:='silenced';
   End;

   For Char_Num := 1 to Current_Party_Size do
      Begin
         Affected := False;

         Character:=Member[Char_Num];

         T := Character.Name + ' is ';

         SMG$Erase_Display (MessageDisplay, 2, 1);
         SMG$Set_Cursor_ABS (MessageDisplay, 2, 1);
         SMG$End_Display_Update (MessageDisplay);

         Saved:=Made_Save (Character,Attack);
         Saved:=Saved or Made_Roll (Magic_Resistance (Character,Attacker.Caster_Level));

         If Not Saved then
            Case Attacker.WhatSpell of
               Slep: Change_Status (Member[Char_Num],Asleep,Affected);
               Fear: Change_Status (Member[Char_Num],Afraid,Affected);
               Sile: Begin
                      Affected := True;
                      Silenced[Char_Num] := True;
                     End;
            End;

            Saved := Saved or Not(Affected);

            If Saved then
               T:=T + 'not ';

            T:=T + verb + '!';

            SMG$Put_Line (MessageDisplay, T, 0);

            Delay (Delay_Constant);
         End;
End;


(**********************************************************************************************************************)

Procedure Implement_Spell (Attacker: AttackerType;  Spell_Chosen: Spell_Name;  Var Member: Party_Type;
                           Var Current_Party_Size: Party_Size_Type;  Var Group: Encounter_Group);

Begin
   Attacker.WhatSpell:=Spell_Chosen;

   Case Spell_Chosen of
     LiBt,MaMs,CsLt,CsSe,CsVs,CsCr,Harm,Kill,Slay,Dest: Handle_Monster_Group_Spell_1 (attacker,Member,Current_Party_Size);
          HoWr,DiWr,DeSp,Holo,FiBl,MgFi,Wrth,GrWr,CoCd: Handle_Monster_Group_Spell_2 (Attacker, Member, Current_Party_Size);
                                   DiPr,BiSh,GrSh,HgSh: Handle_Monster_Protection_Spell (Attacker,Group[Attacker.Group]);
                                        Slep,Sile,Fear: Handle_Monster_Non_Lethal (Attacker,Member,Current_Party_Size);
                                             DiDe,RaDe: Handle_Monster_Death_Spells (Member,Current_Party_Size,Attacker.Caster_Level);
                                                  Dspl: Handle_Monster_Displ (Member, Current_Party_Size);
                                                  TiSt: If Made_Roll (85) then Time_Stop_Players:=True
                                                        Else SMG$Put_Line (MessageDisplay,'but Time Stop failed!');
   End;
End;

(**********************************************************************************************************************)

[Global]Procedure Monster_Spell (Attacker: AttackerType; Var Group: Encounter_Group; Var Member: Party_Type;
                                 Var Current_Party_Size: Party_Size_Type);

Var
   Spell_Chosen: Spell_Name;
   Cler_Level,Wiz_Level: Integer;

Begin
  Cler_Level:=Group[Attacker.Group].Monster.Highest.Cleric_Spell;
  Wiz_Level:=Group[Attacker.Group].Monster.Highest.Wizard_Spell;

  SMG$Put_Chars (MessageDisplay,Monster_Name(Group[Attacker.Group].Monster,1,Group[Attacker.Group].Identified)+' casts a spell ');

  Spell_Chosen:=Random_Spell (Cler_Level,Wiz_Level,Member,Current_Party_Size);

  If NoMagic then
     SMG$Put_Line (MessageDisplay,'but it fizzles out!')
  Else If Group[Attacker.Group].Silenced[Attacker.Attacker_Position] then
     SMG$Put_Line (MessageDisplay,'that fails to become audible!')
  Else
     Begin
        SMG$Put_Line (MessageDisplay,'');
        Implement_Spell (Attacker,Spell_Chosen,Member,Current_Party_Size,Group);
     End;

  Delay (Delay_Constant);
End;
End.  { Monster Attack Spells }

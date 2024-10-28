(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('SYS$LIBRARY:STARLET','Types','Librtl','SmgRtl','StrRtl','PriorityQueue')]Module Character_Attacks_Spells;

Type
   Long_Line = Varying [390] of Char;

Var
   Attacker           : [External]AttackerType;
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
[External]Function  Max_Group (Group: Encounter_Group): Integer;External;
[External]Function  Monster_Name (Monster: Monster_Record; Number: Integer; Identified: Boolean): Monster_Name_Type;External;
[External]Function  Monster_Save (Monster: Monster_Record;  Attack: Attack_Type): [Volatile]Boolean;External;
[External]Function  Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function  Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function  Spell_Damage (Spell: Spell_Name;  Caster_Level: Integer:=0): Die_Type;External;
[External]Function  Spell_Duration (Spell: Spell_Name; Caster_Level: Integer):Integer;External;
[External]Function  String(Num: Integer; Len: Integer:=0):Line;external;
[External]Function  Takes_Damage_Message (Damage: Integer): Line;External;
[External]Function  To_hit_Roll (Character: Character_Type; AC: Integer; Monster: Monster_Record): Integer;External;
[External]Procedure Check_Death (Var Group: Encounter_Group; Mon_Group,i: Integer; Var T: Long_Line);External;
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

Procedure Handle_Group_Spell_1 (Var Group: Encounter_Group;  Var Member: Party_Type);

Var
  Mod_Resist: Integer;
  Form: Attack_Type;
  Mon_Group,Damage,i: Integer;
  Dam: Die_Type;
  Monster: Monster_Record;
  T: Long_Line;

Begin
   Mon_Group:=Attacker.Target_Group;
   Monster:=Group[Mon_Group].Monster;
   i:=Index_of_Living (Group[Mon_Group]);

   Damage:=0;
   If i > 0 then
      Begin
         T:=Monster_Name (Monster, 1, Group[Mon_Group].Identified);

         Dam.X:=0;   Dam.Y:=0;  Dam.Z:=0;

         Case Attacker.WhatSpell of
           MaMs:  Begin
                    Form:=Magic;
                    Dam:=Spell_Damage (MaMs,Attacker.Caster_Level);
                  End;
           LiBt:  Begin
                    Form:=Electricity;
                    Dam:=Spell_Damage (LiBt,Attacker.Caster_Level);
                    If Monster_Save (Monster,Electricity) then
                       Dam.X := Round(Dam.X / 2);
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
                    If Monster_Save (Group[Mon_Group].Monster,Magic) then
                       Damage:=0
                    Else
                       Damage:=Group[Mon_Group].Curr_HP[i] - Roll_Die(4);
                   End;
           Slay:  Begin
                    Form:=Death;
                    If Monster_Save (Group[Mon_Group].Monster,Death) then
                       Damage:=10
                    Else
                       Damage:=Group[Mon_Group].Curr_HP[i];
                   End;
           Dest:  Begin
                    Form:=Death;
                    If Monster_Save (Group[Mon_Group].Monster,Death) then
                        Damage:=Roll_Die(30)
                    Else
                        Damage:=Group[Mon_Group].Curr_HP[i];
                  End;
           Kill:  Begin
                    Form:=Death;
                    If Group[Mon_Group].Curr_HP[i] < 61 then
                        Damage:=Group[Mon_Group].Curr_HP[i]
                    Else
                        Damage:=0;
                  End;
         End;

         Damage:=Damage + Random_Number (Dam);

         Mod_Resist:=Magic_Resistance (Group[Mon_Group].Monster,Attacker.Caster_Level);

         If Made_Roll (Mod_Resist) then
            Damage:=0;

         If Form in Group[Mon_Group].Monster.Resists then
            Damage:=Round (Damage / 2);

         Group[Mon_Group].Curr_HP[i]:=Group[Mon_Group].Curr_HP[i] - Damage;

         T := T + Takes_Damage_Message (Damage);

         Check_Death (Group,Mon_Group,i,T);
      End;
End;

(**********************************************************************************************************************)

Procedure Handle_Group_Spell_2 (Var Group: Encounter_Group;
                                Var Member: Party_Type);

Var
  Mod_Resist: Integer;
  Form: Attack_Type;
  Mon_Group,Damage,i,Last,Temp: Integer;
  Dam: Die_Type;
  Monster: Monster_Record;
  T: Long_Line;

Begin
   Mon_Group:=Attacker.Target_Group;
   Monster:=Group[Mon_Group].Monster;

   For i:=1 to Group[Mon_Group].Curr_Group_Size do
      If Group[Mon_Group].Curr_HP[i] > 0 then
         Begin
            SMG$Erase_Line (MessageDisplay, 3);
            SMG$Erase_Line (MessageDisplay, 2);
            SMG$Set_Cursor_ABS (MessageDisplay,2,1);

            T:=Monster_Name (Group[Mon_Group].Monster,1,Group[Mon_Group].Identified);

            Damage:=0;
            Dam.X:=0;  Dam.Y:=0;  Dam.Z:=0;

            Case Attacker.WhatSpell of
               Wrth: Begin
                        Form:=Magic;
                        Dam:=Spell_Damage (Wrth);
                     End;
               GrWr: Begin
                        Form:=Magic;
                        Dam:=Spell_Damage (GrWr);
                     End;
               CoCd: Begin
                        Form:=Frost;
                        Last:=Attacker.Caster_Level;
                        For Temp:=1 to Last do
                           Damage:=Damage + Roll_Die(4)+1;

                        If Monster_Save (Monster,Frost) then
                           Damage:=Round (Damage / 2);
                     End;
            End;

            Damage:=Damage + Random_Number (Dam);

            Mod_Resist:=Magic_Resistance (Group[Mon_Group].Monster,Attacker.Caster_Level);

            If Made_Roll (Mod_Resist) then
               Damage:=0;

            If Form in Group[Mon_Group].Monster.Resists then
               Damage:=Round (Damage / 2);

            Group[Mon_Group].Curr_HP[i]:=Group[Mon_Group].Curr_HP[i] - Damage;

           T := T + Takes_Damage_Message (Damage);

           Check_Death (Group,Mon_Group,i,T);

           Delay (Delay_Constant);

           SMG$Erase_Display (MessageDisplay,2,1);
         End;
End;

(**********************************************************************************************************************)

Procedure Handle_Party_Spell (Var Member: Party_Type;
                              Current_Party_Size: Integer);

Var
  Temp,Prot,Loop: Integer;

Begin
   { TODO: Make sure target is alive before affecting him or her. }
   If Attacker.WhatSpell<>PaHe then
      Begin
         Prot:=0;
         Case Attacker.WhatSpell of
            DiPr: Begin
                    Prot:=2;
                    Rounds_Left[DiPr]:=Rounds_Left[DiPr]+Spell_Duration (DiPr,Attacker.Caster_Level);
                  End;
            BiSh: Prot:=1;
            GrSh: Prot:=2;
            HgSh: Begin
                    Prot:=4;
                    Rounds_Left[HgSh]:=Rounds_Left[HgSh]+Spell_Duration (HgSh,Attacker.Caster_Level);
                  End;
         End;
         For Loop:=1 to Current_Party_Size do
            Member[Loop].Armor_Class := Member[Loop].Armor_Class - Prot;
      End
   Else
      For Loop:=1 to Current_Party_Size do
          Begin
             Temp:=(Member[Loop].Max_HP)-(Member[Loop].Curr_HP);
             Temp:=Trunc (Temp / 2);
             Member[Loop].Curr_HP := Member[Loop].Curr_HP + Temp;
             If Alive(Member[Loop]) and (Member[Loop].Status<>Zombie) then
                Member[Loop].Status:=Healthy;
          End;
End;

(**********************************************************************************************************************)

Procedure Handle_Caster_Spell (Var Member: Party_Type);

Var
  Caster_Position: Integer;
  Character: Character_Type;

Begin
   Caster_Position := Attacker.Attacker_Position;
   Character := Member[Caster_Position];

   Case Attacker.WhatSpell of
       Prot:  Character.Armor_Class:=Character.Armor_Class - 2;
       Shld:  Character.Armor_Class:=Character.Armor_Class - 1;
       Besk:  Begin
                Character.Armor_Class := Character.Armor_Class - 4;
                Character.Attack.Berserk := True;
                Character.Curr_HP := Character.Curr_HP * 2;
              End;
   End;
   Member[Caster_Position] := Character;
End;

(**********************************************************************************************************************)

Procedure Handle_All_Monsters_Spell (Var Group: Encounter_Group; Var Member: Party_Type);

Var
  Mod_Resist: Integer;
  Form: Attack_Type;
  Mon_Group,Damage,i: Integer;
  Dam: Die_Type;
  Monster: Monster_Record;
  T: Long_Line;

Begin
  For Mon_Group:=1 to 4 do
     If Group[Mon_Group].Curr_Group_Size > 0 then
        Begin
           Monster:=Group[Mon_Group].Monster;
           For i:=1 to Group[Mon_Group].Curr_Group_Size do
              If Group[Mon_Group].Curr_HP[i]>0 then
                 Begin
                    T:=Monster_Name (Monster,1,Group[Mon_Group].Identified);

                    Dam.X := 0;  Dam.Y := 0;  Dam.Z := 0;

                    Case Attacker.WhatSpell of
                        HoWr: Begin
                                Form:=Magic;
                                Dam:=Spell_Damage (HoWr);
                              End;
                        DiWr: Begin
                                Form:=Magic;
                                Dam:=Spell_Damage (DiWr);
                              End;
                        Holo: Begin
                                Form:=Magic;
                                Dam:=Spell_Damage (Holo);
                              End;
                    End;

                    Damage:=Damage + Random_Number (Dam);

                    Mod_Resist:=Magic_Resistance (Group[Mon_Group].Monster,Attacker.Caster_Level);

                    If Made_Roll (Mod_Resist) then
                       Damage:=0;

                    If Form in Group[Mon_Group].Monster.Resists then
                       Damage:=Round (Damage / 2);

                    Group[Mon_Group].Curr_HP[i]:=Group[Mon_Group].Curr_HP[i] - Damage;

                   T := T + Takes_Damage_Message (Damage);

                   Check_Death (Group,Mon_Group,i,T);

                   Delay (Delay_Constant);

                   SMG$Erase_Display (MessageDisplay, 2, 1);
                 End;
        End;
End;

(**********************************************************************************************************************)

Procedure Handle_Fire_Ball (Var Group: Encounter_Group; Member: Party_Type);

Var
   Mod_Resist: Integer;
   Target,Caster_Level,Mon_Group,Damage,Actual_Damage,i: Integer;
   Dam: Die_Type;
   Monster: Monster_Record;
   T: Long_Line;

Begin
   Caster_Level:=Attacker.Caster_Level;
   Target:=Attacker.Target_Group;
   Dam:=Zero;
   Damage:=0;

   Dam := Spell_Damage (Attacker.WhatSpell, Caster_Level);
   Damage:=Random_Number (Dam);

   For Mon_Group:=1 to 4 do
     If Group[Mon_Group].Curr_Group_Size>0 then
        Begin
           Monster:=Group[Mon_Group].Monster;
           For i:=1 to Group[Mon_Group].Curr_Group_Size do
              If Group[Mon_Group].Curr_HP[i] > 0 then
                 Begin
                    Actual_Damage := Damage;

                    SMG$Erase_Line (MessageDisplay, 3);
                    SMG$Erase_Line (MessageDisplay, 2);
                    SMG$Set_Cursor_ABS (MessageDisplay, 2, 1);

                    T := Monster_Name (Monster,1,Group[Mon_Group].Identified);

                    Mod_Resist := Magic_Resistance (Monster, Attacker.Caster_Level);

                    If Made_Roll (Mod_Resist) then
                       Actual_Damage := 0
                    Else
                       Begin
                           If Fire in Monster.Resists then
                               Actual_Damage := Round (Actual_Damage / 2);

                           If Monster_Save (Monster, Fire) then
                               Actual_Damage := Round (Actual_Damage / 2);

                           If Mon_Group <> Target then
                               Actual_Damage := Round(Actual_Damage / (2 * ABS(Mon_Group - Target)));
                       End;

                    Group[Mon_Group].Curr_HP[i] := Group[Mon_Group].Curr_HP[i] - Actual_Damage;

                    T := T + Takes_Damage_Message (Actual_Damage);

                    Check_Death (Group,Mon_Group,i,T);

                    Delay (Delay_Constant);

                    SMG$Erase_Display (MessageDisplay,2,1);
                 End;
        End;
End;

(**********************************************************************************************************************)

Procedure Handle_ID_Spell (Var Group: Encounter_Group);

Var
   Percentage_Chance: Integer;

Begin
   Percentage_Chance:=0;
   Case Attacker.WhatSpell of
        LtId: Percentage_Chance:=15;
        BgId: Percentage_Chance:=35;
   End;

   If Made_Roll (Percentage_Chance) then
      Group[Attacker.Target_Group].Identified := True;
End;

(**********************************************************************************************************************)

Procedure Handle_Heal_Spell (Var Member: Party_Type);

Var
   Recipient,Healed,Damage: Integer;
   Healing: Die_Type;
   Amount: (Fully,Partially,None);
   T: Varying [390] of Char;

Begin
   Recipient:=Attacker.Target_Individual;
   Damage:=Member[Recipient].Max_HP - Member[Recipient].Curr_HP;

   Case Attacker.WhatSpell of
      CrLt: With Healing do
                 Begin
                    X := 1;
                    Y := 8;
                    Z := 0;
                 End;
      CrSe: With Healing do
                 Begin
                    X := 2;
                    Y := 8;
                    Z := 0;
                 End;
      CrVs: With Healing do
                 Begin
                    X := 3;
                    Y := 8;
                    Z := 0;
                 End;
      CrCr: With Healing do
                 Begin
                    X := 4;
                    Y := 8;
                    Z := 0;
                 End;
      Heal: Begin
              With Healing do
                 Begin
                    X := 0;
                    Y := 0;
                    Z := Damage - Roll_Die(4);
                 End;
              If Alive(Member[Recipient]) then
                 Member[Recipient].Status := Healthy;

              Member[Recipient].Regenerates := Regenerates (Member[Recipient]);
            End;
      CrPs: Begin
               Healing := Zero;
               If Member[Recipient].Status = Poisoned then
                   Member[Recipient].Status := Healthy;
               Member[Recipient].Regenerates := Regenerates (Member[Recipient]);
            End;
      CrPa: Begin
               Healing := Zero;
               If Member[Recipient].Status = Paralyzed then
                   Member[Recipient].Status := Healthy;
               Member[Recipient].Regenerates := Regenerates (Member[Recipient]);
            End;
      ReFe: Begin
               Healing := Zero;
               If Member[Recipient].Status = Afraid then
                   Member[Recipient].Status := Healthy;
               Member[Recipient].Regenerates := Regenerates (Member[Recipient]);
            End;

   End;

   If Alive (Member[Recipient]) then
      Healed := Random_Number (Healing)
   Else
      Healed := 0;

   If Healed < 0 then
      Healed := 0;

   Member[Recipient].Curr_HP := Member[Recipient].Curr_HP + Healed;

   Amount := Partially;

   If Member[Recipient].Attack.Berserk then
      Begin
        Member[Recipient].Curr_HP := Min(Member[Recipient].Curr_HP, Member[Recipient].Max_HP * 2); { Berserk characters }
        If Member[Recipient].Curr_HP = Member[Recipient].Max_HP * 2 then
           Amount := Fully;
      End
   Else
      Begin
        Member[Recipient].Curr_HP := Min(Member[Recipient].Curr_HP, Member[Recipient].Max_HP); { Non-Berserk characters }
        If Member[Recipient].Curr_HP = Member[Recipient].Max_HP then
           Amount := Fully;
      End;

   If (Damage = 0) or (Healed = 0) then
      Amount := None;

   T:=Member[Recipient].Name+' is';
   If Not (Attacker.WhatSpell in [CrPs,CrPa,ReFe]) then
      Begin
         Case Amount of
            None:      T:=T+' not';
            Partially: T:=T+' partially';
            Fully:     T:=T+' fully';
         End;
         T := T + ' healed!';
      End
   Else If Attacker.WhatSpell = CrPs then
      T := T + ' unpoisoned!'
   Else if Attacker.WhatSpell = CrPa then
      T := T + ' unparalyzed!'
   Else if Attacker.WhatSpell = ReFe then
      T := T + ' made unafraid!';

   SMG$Put_Line (MessageDisplay,T,Wrap_Flag := SMG$M_WRAP_WORD);
End;

(**********************************************************************************************************************)

Procedure Handle_Death_Spell (Var Group: Encounter_Group);

Var
   Mod_Resist: Integer;
   Monster: Monster_Record;
   Mon_Group: Integer;
   Worked: Boolean;
   T: Varying [390] of Char;

Begin
   Worked := False;

   Case Attacker.WhatSpell of
      DiDe,Dspl,Bani: Mon_Group:=Attacker.Target_Group;
      RaDe: Mon_Group:=Roll_Die (Max_Group(Group));
   End;

   Monster := Group[Mon_Group].Monster;

   If Index_of_Living (Group[Mon_Group]) > 0 then
      Begin
         T:=Monster_Name (Monster,1,Group[Mon_Group].Identified) + ' is';

         Case Attacker.WhatSpell of
            DiDe,RaDe: If Not (Monster_Save (Monster,Death)) then
                          Worked:=True;
                 Dspl: If (Not(NoTurn in Monster.Properties) or Monster_Save(Monster,Death)) and (Monster.Kind=Undead) then
                          Worked:=True;
                 Bani: If Not(Monster_Save(Monster,Death)) and (Monster.Kind=Demon) then
                          Worked:=True;
         End;

         If (Attacker.WhatSpell in [Dspl,Bani]) and (PosZ > 10) then
            Worked:=False; { Can't dispel in Hell }

         Mod_Resist := Magic_Resistance (Monster,Attacker.Caster_Level);

         If Made_Roll (Mod_Resist) then
            Worked := False;

         If Not worked then
            T := T + ' not';

         Case Attacker.WhatSpell of
            DiDe,RaDe: T := T + ' destroyed!';
                 Dspl: T := T + ' dispelled!';
                 Bani: T := T + ' banished!';
         End;

         If Worked then
            Group[Mon_Group].Status[Group[Mon_Group].Curr_Group_Size] := Dead;
      End
   Else
      T:='but nothing happens!';

   SMG$Put_Line (MessageDisplay, T, Wrap_Flag:=SMG$M_WRAP_WORD);
End;

(**********************************************************************************************************************)

Procedure Handle_Interrupt_Spell;

Begin
   SMG$Put_Line (MessageDisplay,'but is disrupted!',Wrap_Flag:=SMG$M_WRAP_WORD);
End;

(**********************************************************************************************************************)

Procedure Handle_Light_Spell (Level: Integer);

Begin
   Rounds_Left[Attacker.WhatSpell] := Rounds_Left[Attacker.WhatSpell] + Spell_Duration (Attacker.WhatSpell, Level);
End;

(**********************************************************************************************************************)

Procedure Handle_Levitate_Spell (Level: Integer);

Begin
   Rounds_Left[Attacker.WhatSpell] := Rounds_Left[Attacker.WhatSpell] + Spell_Duration (Attacker.WhatSpell, Level);
End;

(**********************************************************************************************************************)

Procedure Handle_DetS_Spell (Level: Integer);

Begin
   Rounds_Left[Attacker.WhatSpell] := Rounds_Left[Attacker.WhatSpell] + Spell_Duration (Attacker.WhatSpell, Level);
End;

(**********************************************************************************************************************)

Procedure Handle_Time_Stop_Spell;

Begin
  If Made_Roll (85) then
     Time_Stop_Monsters := True
  Else
     SMG$Put_Line (MessageDisplay,'but nothing happens!',Wrap_Flag:=SMG$M_WRAP_WORD);
End;

(**********************************************************************************************************************)

Procedure Handle_Non_Terminal(Var Group: Monster_Group);

Var
   Monster_Num: Integer;
   Attack: Attack_Type;
   T: Varying [390] of Char;

Begin
   Case Attacker.WhatSpell of
        Slep: Attack := Sleep;
        Fear: Attack := CauseFear;
        Sile: Attack := Magic;
   End;

   If Group.Curr_Group_Size > 0 then
      For Monster_Num:=1 to Group.Curr_Group_Size do
         If Group.Status[Monster_num] <> Dead then
            Begin
               SMG$Set_Cursor_ABS (MessageDisplay, 2, 1);

               T := Monster_Name (Group.Monster, 1, Group.Identified);

               If Group.Status[Monster_Num]=Healthy then
                  If Not Monster_Save (Group.Monster, Attack) then
                     Case Attack of
                        Magic:     Begin
                                      T:=T+' is silenced!';
                                      Group.Silenced[Monster_Num]:=True;
                                   End;
                        CauseFear: Begin
                                      T:=T+' is made afraid!';
                                      Group.Status[Monster_Num]:=Afraid;
                                   End;
                        Sleep:     Begin
                                      T:=T+' is made slept!';
                                      Group.Status[Monster_Num]:=Asleep;
                                   End;
                     End
                  Else
                     T := T + ' is unaffected!';

                  SMG$Put_Line (MessageDisplay, T, Wrap_Flag := SMG$M_WRAP_WORD);

                  Delay (Delay_Constant);

                  SMG$Erase_Display (MessageDisplay, 2, 1);
            End;
End;

(**********************************************************************************************************************)

Procedure Deus_Ex_Machina (Var Monsters: Encounter_Group; Var Member: Party_Type;  Current_Party_Size: Integer);

Var
   Character: Character_Type;
   Die: Integer;
   Group: Integer;
   Person,Monster: Integer;
   T: Long_Line;

Begin
  Die := Roll_Die (65);
  Case die of
        1..5:    Begin
                  For Group:=1 to 4 do
                     For Monster:=1 to Monsters[Group].Curr_Group_Size do
                         Monsters[Group].Curr_HP[Monster]:=Monsters[Group].Max_HP[Monster];
                  T := 'All monsters are healed!';
                 End;
        6..10:   Begin
                    For Person:=1 to Current_Party_Size do
                        If Alive (Member[Person]) then
                           If Member[Person].Attack.Berserk then
                              Member[Person].Curr_HP := Member[Person].Max_HP * 2
                           Else
                              Member[Person].Curr_HP := Member[Person].Max_HP;
                    T := 'The party is healed!';
                End;
        11..20: Begin
                    For Person:=1 to Current_Party_Size do
                        Member[Person].Attack.Berserk := True;
                    T := 'The party goes berserk!';
                End;
        { TODO: 21 to 35 is missing in the printout! }
        36..46:    Begin
                  For Group:=1 to 4 do
                     For Monster:=1 to Monsters[Group].Curr_Group_Size do
                         Monsters[Group].Curr_HP[Monster]:=1;
                  T := 'All monsters are drained!';
                 End;
        47..57:   Begin
                    For Person:=1 to Current_Party_Size do
                        Begin
                            If Member[Person].Max_HP > 0 then
                               Begin
                                  Member[Person].Status:=Healthy;

                                  Member[Person].Curr_HP := Max(Member[Person].Curr_HP, 1);
                               End;
                        End;
                    T := 'The party is restored!';
                  End;
        58..65:  Begin
                  For Group:=1 to 4 do
                     For Monster:=1 to Monsters[Group].Curr_Group_Size do
                         If (Monsters[Group].Status[Monster]=Healthy) then
                            Monsters[Group].Status[Monster] := Asleep;
                  T := 'All monsters are slept!';
                 End;
        66..69:  Begin
                   Character := Member[Roll_Die(Current_Party_Size)];
                   Drain_Levels_From_Character (Character); { TODO: Is this a value copy? If so, this won't be reflected in the actual character. }
                   T:=Character.Name + ' loses a level!';
                 End;
        Otherwise T:='Nothing happens!';
  End;

  SMG$Put_Line (MessageDisplay,T,0,1,Wrap_Flag := SMG$M_WRAP_WORD);
End;

(**********************************************************************************************************************)

Procedure Compass (Level: Integer);

Begin
   Rounds_Left[Attacker.WhatSpell] := Rounds_Left[Attacker.WhatSpell] + Spell_Duration (Attacker.WhatSpell, Level);
End;

(**********************************************************************************************************************)

Procedure Handle_DeSp (Var Monster: Encounter_Group);

Var
   T: Varying [390] of Char;
   Individual,Group: Integer;

Begin
   T:='';
   For Group:=1 to 4 do
      Begin
         If Monster[Group].Curr_Group_Size > 0 then
            Begin
               T:='The ';
               T:=T + Monster_Name (Monster[Group].Monster,2,Monster[Group].Identified);
               T:=' are ';
               If (Monster[Group].Monster.Hit_Points.X < 3) and
                  Not (Death in Monster[Group].Monster.Resists) then
                     For Individual:=1 to Monster[Group].Curr_Group_Size do
                        Monster[Group].Status[Individual] := Dead
               Else
                  T := T + 'not ';
            End;
         T := T + 'destroyed!';

         SMG$Set_Cursor_ABS (MessageDisplay,2,1);
         SMG$Put_Line (MessageDisplay,T,1,Wrap_Flag:=SMG$M_WRAP_WORD);

         Delay (Delay_Constant);

         SMG$Erase_Display (MessageDisplay,2,1);
      End;
End;

(**********************************************************************************************************************)

Procedure Handle_Animate_Dead_Spell (Var Member: Party_Type);

Var
   Recipient: Integer;
   T: Varying [390] of Char;

Begin
   Recipient:=Attacker.Target_Individual;

   T:=Member[Recipient].Name + ' is ';

   If Member[Recipient].Status = Dead then
      Begin
          Member[Recipient].Status := Zombie;

          Member[Recipient].Curr_HP := Roll_Die (8) + Roll_Die (8);
          Member[Recipient].Armor_Class:=Compute_AC(Member[Recipient]);
          Member[Recipient].Regenerates := Regenerates(Member[Recipient]);
          T := T + 'animated!';
      End
   Else
      T := T + 'not animated!';

   SMG$Put_Line (MessageDisplay,T,0,Wrap_Flag:=SMG$M_WRAP_WORD);
End;

(**********************************************************************************************************************)

Procedure Handle_Combat_Spell (Var Group: Encounter_Group;  Var Member: Party_Type;
                                         Var Current_Party_Size: Party_Size_Type);

Begin
   Case Attacker.WhatSpell of
      LiBt,MaMs,CsLt,CsSe,CsVs,CsCr,Harm,Kill,Slay,Dest:    Handle_Group_Spell_1 (Group,Member);
      Wrth,GrWr,CoCd:                                       Handle_Group_Spell_2 (Group,Member);
      DiPr,BiSh,GrSh,HgSh,PaHe:                             Handle_Party_Spell (Member, Current_Party_Size);
      Prot,Shld,Besk:                                       Handle_Caster_Spell (Member);
      Comp:                                                 Compass (Attacker.Caster_Level);
      Levi:                                                 Handle_Levitate_Spell (Attacker.Caster_Level);
      Lght,CoLi:                                            Handle_Light_Spell (Attacker.Caster_Level);
      WoRe:                                                 Leave_Maze:=True;
      Deus:                                                 Deus_Ex_Machina (Group,Member,Current_Party_Size);
      Sile,Slep,Fear:                                       Handle_Non_Terminal (Group[Attacker.Target_Group]);
      CrLt,CrSe,CrVs,CrCr,Heal,CrPs,CrPa,ReFe:              Handle_Heal_Spell (Member);
      HoWr,DiWr,Holo:                                       Handle_All_Monsters_Spell (Group,Member);
      TiSt:                                                 Handle_Time_Stop_Spell;
      DeSp:                                                 Handle_DESP (Group);
      FiBl,MgFi:                                            Handle_Fire_Ball (Group,Member);
      LtId,BgId:                                            Handle_ID_Spell (Group);
      DiDe,RaDe,Dspl,Bani:                                  Handle_Death_Spell (Group);
      Raze,Ress,DuBl,Tele:                                  Handle_Interrupt_Spell;
      AnDe:                                                 Handle_Animate_Dead_Spell (Member);
      DetS:                                                 Handle_DetS_Spell (Attacker.Caster_Level);
   End;
End;

(**********************************************************************************************************************)

[Global]Procedure Character_Casts_Spell (Var Group: Encounter_Group;  Var Member: Party_Type;
                                 Var Current_Party_Size: Party_Size_Type);

Var
  Character: Character_Type;
  Class,Level: Integer;
  Silenced_Out: Boolean;
  T: Varying [390] of Char;
  Long_Spell: [External]Array [Spell_Name] of Varying [25] of Char;

Begin
   Character:=Member[Attacker.Attacker_Position];
   If Attacker.Action<>UseItem then
      T:=Character.Name + ' casts ' + Long_Spell[Attacker.WhatSpell]
   Else
      T:=Character.Name + CHR(39) +'s item casts a spell ';

   If Attacker.Action=CastSpell then
      Begin
         Find_Spell_Group (Attacker.WhatSpell,Character,Class,Level);
         Character.SpellPoints [Class,Level]:=Max(Character.SpellPoints[Class, Level] - 1, 0);
      End
   Else If Made_Roll (Item_List[Character.Item[Attacker.Old_Item].Item_Num].Percentage_Breaks) then
      With Character.Item[Attacker.Old_Item] do
         Begin
            Item_Num:=Item_List[Character.Item[Attacker.Old_Item].Item_Num].Turns_Into;
            Ident:=False;
            isEquipped:=False;
            Usable:=False;
            Cursed:=False;
         End;

   Member[Attacker.Attacker_Position]:=Character;

   Silenced_Out:=Silenced[Attacker.Attacker_Position];

   If NoMagic then
      Begin
         T:=T+'which fizzle out!';
         SMG$Put_Line (MessageDisplay,T,Wrap_Flag:=SMG$M_WRAP_WORD);

         Delay (Delay_Constant);
      End
   Else If Silenced_Out then
      Begin
         T:=T+'which fails to be become audible!';
         SMG$Put_Line (MessageDisplay,T,Wrap_Flag:=SMG$M_WRAP_WORD);

         Delay (Delay_Constant);
      End
   Else
      Begin
         SMG$Put_Line (MessageDisplay,T,Wrap_Flag:=SMG$M_WRAP_WORD);
         Handle_Combat_Spell (Group,Member,Current_Party_Size);
      End;
End;
End.

(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types','SMGRTL','STRRTL')]Module Compute;

Const
   Cler_Spell = 1;
   Wiz_Spell  = 2;

Type
   Spell_List         = Packed Array [1..9] of Set of Spell_Name;
   SpellPoints_Type   = Packed Array [1..2,1..9] of [Byte]0..9;
   Score_List         = Array [1..7] of Ability_Score;

Var
   WizSpells,ClerSpells:       [External]Spell_List;
   Spell:                      [External]Array [Spell_Name] of Varying [4] of Char;
   Item_List:                  [External]List_of_items;

  { MinScore is a matrix of Class x Abilities, which tells Stonequest what the minimum ability scores are for each class.  So, for
    example, if MinScore[Cleric]:=(0 0 9 0 0 0 0), this would be that to be a cleric, a character would have to have a 9 or higher
    in wisdom (wisdom's the third ability score) and that all the other scores have to be 0 or better, i.e., any valid ability score. }

   MinScore:          Array [Class_Type,1..7] of Integer;

  { Experience is a matrix of Class x Level, which is used by Stonequest to compute the experience needed for each level of a
    class.  The function, XP_NEEDED, is a doubly recursive function, and as most computer scientists will tell you, doubly recursive
    functions get VERY SLOW as they reach higher numbers.  One of the problems is that it makes many unnecessary calls. For
    example:

    XP_Needed (Fighter,6) = n*XP_Needed (Fighter,5)-XP_Needed(Fighter,4);
    XP_Needed (Fighter,5) = n*XP_Needed (Fighter,4)-XP_Needed(Fighter,3);

    As you notice, XP_N (Fighter,6) and XP_N (Fighter, 5) BOTH make calls to XP_N (Fighter, 4).  This is an example where the same
    value is computed more than once, which makes the function unnecessaril slow.

    WHAT EXPERIENCE_NEEDED deos, is keep track of all compute XP_NEEDEDs, so that whenever we need a value, we check the matrix
    first to see if we've already computed it.  If we have, we return that value, and tell all those recursive calls to go to
    Hell!  }

  Experience_Needed: [External]Array [Class_Type,1..50] of Real;


Value
   {                          S   I   W   D   C  CH   LU   }
   MinScore[Cleric]       :=( 0,  0,  9,  0,  0,  0,  0);
   MinScore[Fighter]      :=( 9,  0,  0,  0,  9,  0,  0);
   MinScore[Barbarian]    :=(15,  0,  0,  0,  9,  0,  0);
   MinScore[Paladin]      :=( 8,  9, 12,  0,  9, 17,  0);
   MinScore[AntiPaladin]  :=( 8,  9, 12,  0,  9, 17,  0);
   MinScore[Samurai]      :=(11,  0,  0, 13,  9, 15,  0);
   MinScore[Ranger]       :=( 9, 11,  0,  0,  9,  0,  0);
   MinScore[Wizard]       :=( 0,  9,  0, 10,  0,  0,  0);
   MinScore[Thief]        :=( 0,  9,  0, 12,  0,  0,  0);
   MinScore[Assassin]     :=(10,  0,  0, 12,  0,  0,  0);
   MinScore[Monk]         :=(12, 11, 13, 12, 15,  0,  0);
   MinScore[Ninja]        :=(12, 15, 13, 12, 17,  0,  0);
   MinScore[Bard]         :=(15, 12,  0, 16, 10, 15,  0);

(******************************************************************************)
[External]Procedure Plane_Difference (Var Plus: Integer; PosZ: Integer);External;
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
(******************************************************************************)

[Global]Function String (Num: Integer; Len: Integer:=0): Line;

{ This function will convert an Integer into a string }

Var
   Temp: Line;

Begin { String }
   Temp:='';
   WriteV (Temp,Num:Len);  { Write the integer onto the string }
   String:=Temp;           { Return the string }
End;  { String }

(******************************************************************************)

Function Get_Spell_Level (Spell: Spell_Name; Spells: Spell_List): Integer;

{ This function returns the level of SPELL in the list of spells, SPELLS. If SPELL is not in SPELLS, the number 10 is returned
  as the function result. }

Var
   Level: Integer;

Begin { Get Spell Level }
   Level:=10;
   Repeat
      Level:=Level - 1;
   Until (Spell in Spells[Level]) or (Level = 1);
   If Not (Spell in Spells[1]) and (Level = 1) then Level:=10;
   Get_Spell_Level:=Level;
End;  { Get Spell Level }

(******************************************************************************)

[Global]Procedure Find_Spell_Group (Spell: Spell_Name;  Character: Character_Type;  Var Class,Level: Integer);

{ This procedure will locate the position (Class and Level) of SPELL, and return it via the VAR parameters, CLAS and LEVEL.  If the
  spell is not found, or it is not in the character's spell book, level 10 is returned. }

Var
   Wizard_Level,Cleric_Level: 1..10;  { 10 being non existant }
   Wiz_Points,Cler_Points: 0..9;

Begin { Find Spell Group }
   Wizard_Level:=10;  Cleric_Level:=10;  { So far, it can't be casted }

        { Search for the spell level in wizard spells }

   If (Spell in Character.Wizard_Spells) then Wizard_Level:=Get_Spell_Level (Spell,WizSpells);

        { Search for the spell level in Cleric spells }

   If (Spell in Character.Cleric_Spells) then Cleric_Level:=Get_Spell_Level (Spell,ClerSpells);

   If Cleric_Level < 10 then
      If (Character.SpellPoints[Cler_Spell,Cleric_Level]<1) and (Wizard_level < 10) then
        Cleric_Level:=10;  { No cleric points to cast it }

   If Wizard_Level < 10 then
      If (Character.SpellPoints[Wiz_Spell,Wizard_Level]<1) and (Cleric_level < 10) then
        Wizard_Level:=10;  { No wizard points to cast it }

   { Find out which of the possible spell-types to use }

   If Min(Cleric_Level,Wizard_Level) < 10 then
      Begin { If can cast from at least one }
         If Cleric_Level<Wizard_Level then
            Begin { If the cleric spell is lower level than the wizard }
               Level:=Cleric_Level;
               Class:=Cler_Spell;
            End   { If the cleric spell is lower level than the wizard }
         Else
            If Wizard_Level<Cleric_Level then
               Begin { If the wizard spell is lower level than the cleric }
                  Level:=Wizard_Level;
                  Class:=Wiz_Spell;
               End   { If the wizard spell is lower level than the cleric }
            Else
               Begin { Otherwise take the one with the most spell points }
                  Wiz_Points  := Character.SpellPoints[Wiz_Spell,Wizard_Level];
                  Cler_Points := Character.SpellPoints[Cler_Spell,Cleric_Level];
                  If Cler_Points>Wiz_Points then
                     Begin
                        Level:=Cleric_Level;
                        Class:=Cler_Spell;
                     End
                  Else
                     Begin
                        Level:=Wizard_Level;
                        Class:=Wiz_Spell;
                     End
               End   { Otherwise take the one with the most spell points }
      End
   Else  { Otherwise... }
      Begin { Can't be casted }
         Level:=10;
         Class:=0;
      End;  { Can't be casted }
End;  { Find Spell Group }


(******************************************************************************)

Procedure Get_Class_And_Level (Class: Class_Type; Level: Integer; Var Cls: Class_Type; Var Lvl: Integer);

{ This procedure determines what kind of spell caster the given class is, and what level in spell use as well.  If the
  Given class and level can not cast a spell, then LVL is returned as zero, otherwise CLS contains the spell caster
  type (CLERIC, or WIZARD) and LVL contains the equivalent caster-level }

Begin { Get Class and Level }
   Case Class of
        Cleric: Begin
                   Cls:=Cleric;
                   Lvl:=Level;
                End;
        Paladin,AntiPaladin: Begin
                   Cls:=Cleric;
                   Lvl:=Level - 7;
                End;
        Bard:   Begin
                   Cls:=Wizard;
                   Lvl:=Level - 4;
                End;
        Ranger: Begin
                   Cls:=Wizard;
                   Lvl:=Level - 7;
                End;
        Wizard: Begin
                   Cls:=Wizard;
                   Lvl:=Level;
                End;
        Otherwise Lvl:=0;
   End;
   If Lvl < 0 then lvl:=0;
End;  { Get Class and Level }

(******************************************************************************)

[Global]Function Caster_Level (Cls: Integer; Character: Character_Type): Integer;

{ This function returns the caster level of the character trying to cast a spell of type Cls (1=Cleric, 2=Wizard) }

Var
  Class1,Class2,Class: Class_Type;
  Level1,Level2: Integer;

Begin { Caster_Level }
   Level1:=0;  Level2:=0;

   { Determine what spell class is specified }

   If Cls=1 then Class:=Cleric
   Else          Class:=Wizard;

   { Get the primary class's level }

   Get_Class_And_Level (Character.Class,        Character.Level,       Class1,Level1);
   Get_Class_And_Level (Character.PreviousClass,Character.Previous_Lvl,Class2,Level2);

   { Return the greater of the two levels if class-type are the same }

   If (Class2=Class1) and (Class=Class1) then
      Caster_Level:=Max(level1,level2)
   Else
      If Class=Class1 then
         Caster_Level:=Level1
      Else
         Caster_Level:=Level2;
End;  { Caster_Level }

(******************************************************************************)

[Global]Function Max_Spell_Level (Class: Class_Type; Level: Integer): Integer;

{ This function returns the maximum spell level for class, CLASS, and level, LEVEL }

Var
   Max_Level: Integer;

Begin { Max Spell Level }
    Case Class of
       Cleric,Wizard:   Max_Level:=Round (level / 2);
       Bard: Begin
                Max_Level:=Max(Round((Level - 4) / 2), 0);
             End;
       AntiPaladin,Paladin,Ranger:
             Begin
                Max_Level:=Max(Round((level - 7)/2), 0);
             End;
       Otherwise Max_Level:=0;
    End;

    Max_Spell_Level:=Min(Max_Level, 9);
End;  { Max Spell Level }

(******************************************************************************)

[Global]Function Spells_Known (Class: Class_Type; Level: Integer): Spell_Set;

{ This function will return the set of all spells known by a character of class, CLASS, and of level, LEVEL }

Var
   SpellSet: Spell_Set;
   Max_Lvl,Lvl: Integer;

Begin { Spells Known }
   SpellSet:=[ ];       { No spells so far }

   { Find the maximum level spell known }

   Max_Lvl:=Max_Spell_Level (Class,Level);

   { If the character has ANY spells, add them to the set by level }

   If Max_Lvl > 0 then   { If knows at least first level spells... }
      For Lvl:=1 to Max_Lvl do    { ... for each level known ... }
          Case Class of  { Add the spells of that level to the set }
             Cleric,AntiPaladin,Paladin: Spellset:=Spellset + ClerSpells[Lvl];
             Wizard,Ranger,Bard:         Spellset:=SpellSet + WizSpells[Lvl];
             Otherwise ;
          End;

   { Remember: Antipaladins don't have healing spells, so ... }

   If Class=Antipaladin then
       SpellSet:=SpellSet-[CrLt,CrPs,CrSe,CrVs,Raze,Ress,PaHe,Heal,CrPa,ReFe];

   { Remove the spells not implemented at this time.  (May be added later) }

   Spells_Known:=SpellSet-[ReDo];
End;  { Spells Known }

(******************************************************************************)

Function Critical_Addition (SpellPoints: SpellPoints_Type;  SpellType,Crit: Integer): SpellPoints_Type;

Var
  C1: Integer;

Begin { Critical Addition }
   If Crit > 12 then
      For C1:=13 to Crit do
         Case Crit of
            13:  If (SpellPoints[SpellType,1] in [1..8]) then SpellPoints[SpellType,1]:=SpellPoints[SpellType,1]+1;
            14:  If (SpellPoints[SpellType,1] in [1..8]) then SpellPoints[SpellType,1]:=SpellPoints[SpellType,1]+1;
            15:  If (SpellPoints[SpellType,2] in [1..8]) then SpellPoints[SpellType,2]:=SpellPoints[SpellType,2]+1;
            16:  If (SpellPoints[SpellType,2] in [1..8]) then SpellPoints[SpellType,2]:=SpellPoints[SpellType,2]+1;
            17:  If (SpellPoints[SpellType,3] in [1..8]) then SpellPoints[SpellType,3]:=SpellPoints[SpellType,3]+1;
            18:  If (SpellPoints[SpellType,2] in [1..8]) then SpellPoints[SpellType,2]:=SpellPoints[SpellType,2]+1;
            19:  If (SpellPoints[SpellType,1] in [1..8]) then SpellPoints[SpellType,1]:=SpellPoints[SpellType,1]+1;
            20:  If (SpellPoints[SpellType,4] in [1..8]) then SpellPoints[SpellType,4]:=SpellPoints[SpellType,4]+1;
            21:  If (SpellPoints[SpellType,2] in [1..8]) then SpellPoints[SpellType,2]:=SpellPoints[SpellType,2]+1;
            22:  If (SpellPoints[SpellType,4] in [1..8]) then SpellPoints[SpellType,4]:=SpellPoints[SpellType,4]+1;
            33:  Begin
                     SpellPoints[SpellType, 3] := Min(SpellPoints[SpellType, 3] + 1, 9);
                     SpellPoints[SpellType, 4] := Min(SpellPoints[SpellType, 4] + 1, 9);
                     SpellPoints[SpellType, 5] := Min(SpellPoints[SpellType, 5] + 1, 9);
                     SpellPoints[SpellType, 6] := Min(SpellPoints[SpellType, 6] + 2, 9);
                 End;
            24: SpellPoints[SpellType,6] := Min(SpellPoints[SpellType, 6] + 2, 9);
            25: Begin
                    SpellPoints[SpellType, 6] := Min(SpellPoints[SpellType, 6] + 2, 9);
                    SpellPoints[SpellType, 7] := Min(SpellPoints[SpellType, 7] + 2, 9);
                End;
            Otherwise ;
         End;
   Critical_Addition:=SpellPoints;
End;  { Critical Addition }

(******************************************************************************)

[Global]Procedure Add_Bonus (Var Caster: Character_Type; SpellType,Max_Level: Integer);

{ This procedure will add the bonus spell points a character gets when his or her primary ability (determined by the class) is very
  high. }

Var
  Crit,Level: Integer;

Begin { Add Bonus }
   { Determine what the CRITical ability score is for the SPELLTYPE }

   Case SpellType of
        Cler_Spell: Crit := Caster.Abilities[3]; { For Clerics, it's Wisdom }
        Wiz_Spell:  Crit := Caster.Abilities[2]; { For Wizards, it's Intelligence }
        Otherwise   Crit := 0;
   End;

   Caster.SpellPoints:=Critical_Addition (Caster.SpellPoints,SpellType,Crit);

   { Make sure that there are no points above 9, which is the maximum, and none below 0, which is the minimum }

   For Level:=1 to 9 do
      Begin
         If Level > Max_Level then
            Caster.SpellPoints[SpellType, Level] := 0
         Else
            Caster.SpellPoints[SpellType, Level] := Max ( (Min (Caster.SpellPoints[SpellType, Level], 9)), 0 );
      End;
End;  { Add Bonus }

(******************************************************************************)

Procedure Restore (Var Character: Character_Type; Class: Class_Type; Level: Integer);

{ This procedure restores all spells to Character of Class, CLASS, and level, LEVEL }

Var
   TempNum,Level_Loop,Max_Level,Max_Number: Integer;
   Spell_Type: 1..2;

Begin { Restore }
   Max_Level:=Max_Spell_Level (Class,Level);  { Get the maximum spell level }

   { Determine how many spells of the highest level are known }

   Max_Number:=1;                                  { Usually, it's 1... }
   If Max_Level > 9 then                           { But if the caster is REALLY powerful... }
      Begin { More than nine levels }
         Max_Number:=1 + ((Max_Level - 9) div 2);  { ... he gets more 9th level spells ... }
         Max_Level:=9;                             { ... but he can still only cast up to 9th level spells }
      End;  { More than nine levels }

  { Determine what spell group we're working with... }

  Case Class of
     AntiPaladin,Paladin,Cleric: Spell_Type:=Cler_Spell;
     Wizard,Ranger,Bard:         Spell_Type:=Wiz_Spell;
     Otherwise                   Spell_Type:=Cler_Spell;
  End;

  { Assign all the spell points now, by level, starting from the highest level, and working our way to 1st }

  TempNum:=Max_Number;
  For Level_Loop:=Max_Level downto 1 do
     Begin { For Each Level }
        TempNum:=Min(TempNum, 9);
        Character.SpellPoints[Spell_Type,Level_Loop] := Character.SpellPoints[Spell_Type,Level_Loop] + TempNum;
        TempNum := TempNum + 1;                                       { Each lower level has one more point }
     End;  { For each level }

  { Add bonus spell points for high ability scores }

  Add_Bonus (Character,Spell_Type,Max_Level);
End; { Restore }

(******************************************************************************)

[Global]Procedure Restore_Spells (Var Character: Character_Type);

{ This procedure will restore all spell points CHARACTER has.  All spells of the Previous class will be restored, then all spells of
  the current class will be restored, with any conflict in points (e.g., Cleric/Paladin multi-class be resolved by adding the
  amount together. }

Begin { Restore_Spells }
   Character.SpellPoints:=Zero;

   If Character.PreviousClass in [Bard,Cleric,Paladin,Ranger,AntiPaladin,Wizard] then
      Restore (Character,Character.PreviousClass,Character.Previous_Lvl);

   If Character.Class in [Bard,Cleric,Paladin,Ranger,AntiPaladin,Wizard] then
      Restore (Character,Character.Class,Character.Level);
End;  { Restore_Spells }

(******************************************************************************)

Function Con_Adjustment (Constitution: Integer): Integer;

Begin { Con Adjustment }
   Case Constitution of
            3: Con_Adjustment:=-2;
         4..6: Con_Adjustment:=-1;
        7..14: Con_Adjustment:=0;
           15: Con_Adjustment:=1;
           16: Con_Adjustment:=2;
           17: Con_Adjustment:=3;
           18: Con_Adjustment:=4;
        19,20: Con_Adjustment:=5;
     21,22,23: Con_Adjustment:=6;
        24,25: Con_Adjustment:=7;
        Otherwise Con_Adjustment:=0;
   End;
End;  { Con Adjustment }

(******************************************************************************)

[Global]Function Compute_Hit_Die (Character: Character_Type): [Volatile]Integer;

{ This function computed how many hit points a character gains (or loses) for his current level, class, and constitution }

Var
  Base_HP,Die_Type: Integer;

Begin { Compute Hit Die }

   { Compute the base hit point change as a function of the character's class }

   Case Character.Class of
      Barbarian:                       Die_Type:=12;
      Fighter,Paladin,AntiPaladin:     Die_Type:=10;
      Cleric,Ranger,Samurai,Monk:      Die_Type:=8;
      Thief,Assassin,Bard,Ninja:       Die_Type:=6;
      Wizard:                          Die_Type:=4;
      Otherwise                        Die_Type:=1;
   End;

   Base_HP:=Roll_Die(Die_Type);

   { If the class is Ranger, Monk, or Samurai, the character gets another hit die at first level }

   If (Character.Class in [Ranger,Samurai,Monk]) and (Character.Level=1) then Base_Hp:=Base_HP + Roll_Die(Die_Type);

   { After 15th level, the number of hit points gained or lost is constant the class }

   If Character.Level>15 then
      Case Character.Class of
          Fighter,Paladin,AntiPaladin:  Base_HP:=3;
          Wizard:                       Base_HP:=1;
          Otherwise                     Base_HP:=2;
      End;

   { Add the constitution bonus }

   Base_HP:=Base_HP + Con_Adjustment (Character.Abilities[5]);

   { Add the second die's worth to the hit points }

   If (Character.Class in [Ranger,Samurai,Monk]) and (Character.Level = 1) then
      Base_HP:=Base_HP + Con_Adjustment(Character.Abilities[5]);

   { If, with all these adjustments, the HPs turn out to be less than one, make it equal to one }

   If Base_HP < 1 then Base_HP:=1;

   { Return the result }

   Compute_Hit_Die:=Base_HP;
End;  { Compute Hit Die }

(******************************************************************************)

[Global]Function Alive (Character: Character_Type): Boolean;

{ This function returns TRUE if the character is alive, and false if the character is dead.  If the character is undead,
  he or she is treated as alive for the sake of this function.  }

Begin { Alive }
   Alive:=Not (Character.Status in [Ashes,Dead,Deleted])
End;  { Alive }

(******************************************************************************)

[Global]Function Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;

{ This function will compute how many hit points CHARACTER will regenerate }

Var
   Temp,Regen,Loop: Integer;

Begin { Regenerates }

   { An extremely high constitution can cause regeneration }

   Case Character.Abilities[5] of
        23:       Regen:=1;
        24:       Regen:=2;
        25:       Regen:=3;
        Otherwise Regen:=0;
   End;
   If Character.Psionics then Regen:=Regen + Character.Regenerate;

   { A poisoned character LOSES hit points... }

   If Character.Status=Poisoned then Regen:=Regen - 1;

   { Magic items can affect regeneration }

   If Character.No_of_Items>0 then
      For Loop:=1 to Character.No_Of_Items do
         If Character.Item[Loop].isEquipped then
            Begin
               Temp:=Item_List[Character.Item[Loop].Item_Num].Regenerates;
               Plane_Difference (Temp,PosZ);
               Regen:=Regen + Temp;
            End;

   { Return function result }

   If Character.Status=Asleep then Regen:=Regen + 1;
   If Not Alive(Character) then Regen:=0;
   Regenerates:=Regen;
End;  { Regenerates }

(******************************************************************************)

Function Base_XP (Class: Class_Type): Real;

{ This function returns the amount of experience a character of class, CLASS needs to go up to 2nd level from 1st }

Begin { Base XP }
   Case Class of
      Thief:                           Base_XP := 1051;
      Cleric,Assassin:                 Base_XP := 1300;
      Fighter,Bard:                    Base_XP := 1800;
      Ranger,Monk,Ninja:               Base_XP := 2051;
      Barbarian:                       Base_XP := 2100;
      Wizard:                          Base_XP := 2300;
      Paladin,AntiPaladin,Samurai:     Base_XP := 2551;
      Otherwise                        Base_XP := 0;
   End;
End;  { Base XP }

(******************************************************************************)
[Global]Function XP_Needed (Class: Class_Type; Level: Integer):Real;Forward;
(******************************************************************************)

[Global]Function XP_Needed_Aux (Class: Class_Type; Level: Integer): Real;

{ This function recursively determines how much experience is required to be a Level, LEVEL, Class, CLASS character }

Const
   Level_Factor = 49/25;  { Change this constant with care, as even slight adjustments will have radical effects on the
                            amount of experience required }

Var
  L1,L2: Real;

Begin { XP Needed Auxiliary }
   If Level < 2 then   { This should be called for level=0,1 but if it is... }
        XP_Needed_Aux := 0
   Else
      If Level=2 then  { The experience needed for level 2 is a constant }
         XP_Needed_Aux := Base_XP (Class)
      Else
         If Level>13 then
            Begin { Greater than 13th level }
               L1 := XP_Needed(Class,Level - 1);
               L2 := XP_Needed(Class,Level - 2);

               XP_Needed_Aux := L1 + (L1 - L2);
            End   { Greater than 13th level }
         Else
            XP_Needed_Aux:=Level_Factor*XP_Needed(Class,Level-1);
End;  { XP Needed Auxiliary }


(******************************************************************************)

Function XP_Needed {Class: Class_Type; Level: Integer): Real};

{ This function will compute the experience points needs to be a LEVELth level character, of class CLASS.  See VAR documentation
  regarding EXPERIENCE_NEEDED.  }

Var
  XP: Real;

Begin { XP Needed }
   If (Level < 50) and (Level>1) then  { If it COULD be in the table... }
      If Experience_Needed [Class,Level] > 0 then  { ...and it IS there... }
         XP:=Experience_Needed [Class,Level]     { ...return the value }
      Else
         Begin { If it's not in the table }
            XP:=XP_Needed_Aux (Class,Level);      { If not there, compute it }
            Experience_Needed [Class,Level] := XP;  { and store it for later use! }
         End   { If it's not in the table }
   Else
      XP:=XP_Needed_Aux (Class,Level);   { If it can't be there, compute it! }
   XP_Needed:=XP;
End;  { XP Needed }

(******************************************************************************)

[Global]Function Character_Exists (CharName: Name_Type; Var Spot: Integer): Boolean;

{ This function does two things.  First of all, it verifies the existence of CHARNAME in the array ROSTER.   If the name
  DOES occur in ROSTER, the position it was found in is returned via the Var parameter, SPOT. }

Var
   Roster: [External]Roster_Type;
   Slot: Integer;
   Found: Boolean;

Begin { Character Exists }
   Found:=False;                                                                { So far, we haven't found it }
   If CharName <> '' then                                                       { If the name isn't the empty string }
      For Slot:=1 to 20 do                                                      { For each slot in the roster... }
         If Roster[Slot].Status <> Deleted then                                 { If the slot is used... }
            Begin { Not deleted }
               If (STR$Case_Blind_Compare(Roster[Slot].Name,CharName) = 0) then { If this is the name... }
                  Begin { The Same }
                     Found := True;                                             { ...we've found it. }
                     Spot := Slot;                                              { Mark the position }
                  End  { The Same }
            End;  { Not deleted }

   Character_Exists := Found  { Return the function value }
End;  { Character Exists }

(******************************************************************************)

Function Scores_Qualify (Scores: Score_List;  Class: Class_Type): Boolean;

Var
   x: Integer;
   Sum_List: Score_List;
   Made_It: Boolean;

Begin { Scores Qualify }
   Made_it := True;
   If Class <> AntiPaladin then
      For X := 1 to 7 do
         Begin
            Sum_List[X] := Scores[X] - MinScore[Class, X];
            If Sum_List[X] < 0 then
               Made_It:=False;
         End
   Else
      Begin
         For X := 1 to 5 do
            Begin
               Sum_List[X] := Scores[X] - MinScore[Class, X];
               If Sum_List[X] < 0 then
                  Made_It:=False;
            End;
         If Made_It then
            Begin
               Sum_List[7] := Scores[7] - MinScore[Class,7]; { TODO: LUCK?!?!?!? }
               If Sum_List[7] < 0 then
                   Made_It:=False;
            End;
         Made_It:=Made_It and ((Scores[6] < 5) or (Scores[6] > 16));
      End;

   Scores_Qualify:=Made_It;
End;  { Scores Qualify }

(******************************************************************************)

[Global]Function Class_Choices (Character: Character_Type): Class_Set;

Var
   Possibilities: Set of Class_Type;
   Class: Class_Type;

Begin { Class Choices }
   Possibilities:=[];   { So far no possibilities }

   { Add all classes made eligable by ability scores }

   For Class:=Cleric to Barbarian do
      If Scores_Qualify (Character.Abilities,Class) then
         Possibilities:=Possibilities + [ Class ];

   { Subtract all classes made impossible because of race }

   Case Character.Race of
      Drow:                    Possibilities:=Possibilities*[Cleric,Wizard,Thief,Assassin,AntiPaladin];
      HfOrc,HfOgre:            Possibilities:=Possibilities*[Cleric,Monk,Fighter,Thief,Barbarian,Assassin];
      Gnome,Hobbit,Dwarven:    Possibilities:=Possibilities*[Cleric,fighter,Thief,Assassin];
      Elven:                   Possibilities:=Possibilities-[Ninja,Samurai,Barbarian,AntiPaladin];
      HfElf:                   Possibilities:=Possibilities-[Barbarian,Paladin,AntiPaladin];
      LizardMan:               Possibilities:=Possibilities*[Monk,Barbarian,Fighter,Cleric];
      Centaur:                 Possibilities:=Possibilities*[Fighter,Cleric,Bard,Wizard,Samurai];
      Numenorean:              Possibilities:=Possibilities*[Fighter,Bard,Wizard];
      Otherwise ;
   End;

   { Subtract all classes made impossible because of alignment }

   Case Character.Alignment of { if just making character, will be NoAlign }
      Good:     Possibilities:=Possibilities - [AntiPaladin,Barbarian,Thief,Assassin,Ninja];
      Neutral:  Possibilities:=Possibilities - [Paladin,Ranger,Cleric,Assassin,AntiPaladin];
      Evil:     Possibilities:=Possibilities - [Paladin,Ranger,Barbarian];
      Otherwise ;
   End;

   { The resulting set is the set of all class choices }

   Class_Choices:=Possibilities;
End;  { Class Choices }

(******************************************************************************)

[Global]Function Made_Roll (Needed: Integer): [Volatile]Boolean;

{ This function is used to determine percentages. So, if NEEDED is the parameter, there is a NEEDED% chance the function
  will be TRUE, and the rest of the time the function will be FALSE. }

Begin { Made Roll }
   Made_Roll:=Roll_die(100) <= Needed
End;  { Made Roll }

(******************************************************************************)

[Global]Function Spell_Duration (Spell: Spell_Name; Caster_Level: Integer):Integer;

Begin { Spell Duration }
   Case Spell of
      DiPr,HgSh: Spell_Duration:=(5  * Caster_Level);
      Comp,Dets: Spell_Duration:=(2  * Caster_Level);
      Lght,Levi: Spell_Duration:=(10 * Caster_Level);
      Coli:      Spell_Duration:=(Maxint - 22000);  { To prevent overflow }
      Wore:      Spell_Duration:=1;
      Otherwise  Spell_Duration:=1;
   End;
End;  { Spell Duration }
End.  { Compute }

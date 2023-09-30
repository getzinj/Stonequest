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
      Level:=Level-1;
   Until (Spell in Spells[Level]) or (Level=1);
   If Not (Spell in Spells[1]) and (Level=1) then Level:=10;
   Get_Spell_Level:=Level;
End;  { Get Spell Level }

(******************************************************************************)

[Global]Procedure Find_Spell_Group (Spell: Spell_Name;  Character: Character_Type;  Var Class,Level: Integer);

Begin { Find Spell Group }
   { TODO: Enter this code }
End;  { Find Spell Group }


[Global]Function Caster_Level (Cls: Integer; Character: Character_Type): Integer;

Begin { Caster_Level }
   { TODO: Enter this code }
   Caster_Level:=0;
End;  { Caster_Level }

[Global]Function Max_Spell_Level (Class: Class_Type; Level: Integer): Integer;

Begin { Max Spell Level }
   { TODO: Enter this code }
   Max_Spell_Level:=0;
End;  { Max Spell Level }


[Global]Function Spells_Known (Class: Class_Type; Level: Integer): Spell_Set;

Begin { Spells Known }
   { TODO: Enter this code }
   Spells_Known:=[];
End;  { Spells Known }

[Global]Procedure Add_Bonus (Var Caster: Character_Type; SpellType,Max: Integer);

Begin { Add Bonus }
   { TODO: Enter this code }
End;  { Add Bonus }


[Global]Procedure Restore_Spells (Var Character: Character_Type);

Begin { Restore_Spells }
   { TODO: Enter this code }
End;  { Restore_Spells }


[Global]Function Compute_AC (Character: Character_Type; POSZ: Integer:=0): Integer;

Begin { Compute AC }
   { TODO: Enter this code }
   Compute_AC:=0;
End;  { Compute AC }

[Global]Function Compute_Hit_Die (Character: Character_Type): [Volatile]Integer;

Begin { Compute Hit Die }
   { TODO: Enter this code }
   Compute_Hit_Die:=0;
End;  { Compute Hit Die }


[Global]Function Alive (Character: Character_Type): Boolean;

Begin { Alive }
   { TODO: Enter this code }
   Alive:=true;
End;  { Alive }


[Global]Function Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;

Begin { Regenerates }
   { TODO: Enter this code }
   Regenerates:=0;
End;  { Regenerates }

(******************************************************************************)

Function Base_XP (Class: Class_Type): Real;

{ This function returns the amount of experience a character of class, CLASS needs to go up to 2nd level from 1st }

Begin { Base XP }
   Case Class of
      Thief:                           Base_XP:=1051;
      Cleric,Assassin:                 Base_XP:=1300;
      Fighter,Bard:                    Base_XP:=1800;
      Ranger,Monk,Ninja:               Base_XP:=2051;
      Barbarian:                       Base_XP:=2100;
      Wizard:                          Base_XP:=2300;
      Paladin,AntiPaladin,Samurai:     Base_XP:=2551;
      Otherwise                        Base_XP:=0;
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
   If Level<2 then   { This should be called for level=0,1 but if it is... }
        XP_Needed_Aux:=0
   Else
      If Level=2 then  { The experience needed for level 2 is a constant }
         XP_Needed_Aux:=Base_XP (Class)
      Else
         If Level>13 then
            Begin { Greater than 13th level }
               L1:=XP_Needed(Class,Level-1);
               L2:=XP_Needed(Class,Level-2);
               XP_Needed_Aux:=L1+(L1-L2);
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
   If (Level<50) and (Level>1) then  { If it COULD be in the table... }
      If Experience_Needed [Class,Level]>0 then  { ...and it IS there... }
         XP:=Experience_Needed [Class,Level]     { ...return the value }
      Else
         Begin { If it's not in the table }
            XP:=XP_Needed_Aux (Class,Level);      { If not there, compute it }
            Experience_Needed [Class,Level]:=XP;  { and store it for later use! }
         End   { If it's not in the table }
   Else
      XP:=XP_Needed_Aux (Class,Level);   { If it can't be there, compute it! }
   XP_Needed:=XP;
End;  { XP Needed }

(******************************************************************************)

[Global]Function Character_Exists (CharName: Name_Type; Var Spot: Integer): Boolean;

{ This function does two things.  First of all, it verifies the existance of CHARNAME in the array ROSTER.   If the name DOES occurs
  in ROSTER, the position it was found in is returned via the Var parameter, SPOT. }

Var
   Roster: [External]Roster_Type;
   Slot: Integer;
   Found: Boolean;

Begin { Character Exists }
   Found:=False;                                                                { So far, we haven't found it }
   If CharName<>'' then                                                         { If the name isn't the empty string }
      For Slot:=1 to 20 do                                                      { For each slot in the roster... }
         If Roster[Slot].Status<>Deleted then                                   { If the slot is used... }
            Begin { Not deleted }
               If (STR$Case_Blind_Compare(Roster[Slot].Name,CharName)=0) then   { If this is the name... }
                  Begin { The Same }
                     Found:=True;                                               { ...we've found it. }
                     Spot:=Slot;                                                { Mark the position }
                  End  { The Same }
            End;  { Not deleted }
   Character_Exists:=Found  { Return the function value }
End;  { Character Exists }

(******************************************************************************)

Function Scores_Qualify (Scores: Score_List;  Class: Class_Type): Boolean;

Var
   x: Integer;
   Sum_List: Score_List;
   Made_It: Boolean;

Begin { Scores Qualify }
   Made_it:=True;
   If Class<>AntiPaladin then
      For X:=1 to 7 do
         Begin
            Sum_List[X]:=Scores[X]-MinScore[Class,X];
            If Sum_List[X]<0 then Made_It:=False;
         End
   Else
      Begin
         For X:=1 to 5 do
            Begin
               Sum_List[X]:=Scores[X]-MinScore[Class,X];
               If Sum_List[X]<0 then Made_It:=False;
            End;
         If Made_It then
            Begin
               Sum_List[7]:=Scores[7]-MinScore[Class,7];
               If Sum_List[7]<0 then Made_It:=False;
            End;
         Made_It:=Made_It and ((Scores[6]<5) or (Scores[6]>16));
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
         Possibilities:=Possibilities+[Class];

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
      Good:     Possibilities:=Possibilities-[AntiPaladin,Barbarian,Thief,Assassin,Ninja];
      Neutral:  Possibilities:=Possibilities-[Paladin,Ranger,Cleric,Assassin,AntiPaladin];
      Evil:     Possibilities:=Possibilities-[Paladin,Ranger,Barbarian];
      Otherwise ;
   End;

   { The resulting set is the set of all class choices }

   Class_Choices:=Possibilities;
End;  { Class Choices }

(******************************************************************************)

[Global]Function Made_Roll (Needed: Integer): [Volatile]Boolean;

{ This function is used to determine percentages. So, if NEEDED is the parameter, there is a NEEDED% chance the function will be
  TRUE, and the rest of the time the function will be FALSE. }

Begin { Made Roll }
   Made_Roll:=Roll_die(100)<=Needed
End;  { Made Roll }

(******************************************************************************)

[Global]Function Spell_Duration (Spell: Spell_Name; Caster_Level: Integer):Integer;

Begin { Spell Duration }
   Case Spell of
      DiPr,HgSh: Spell_Duration:=(5 * Caster_Level);
      Comp,Dets: Spell_Duration:=(2 * Caster_Level);
      Lght,Levi: Spell_Duration:=(10* Caster_Level);
      Coli:      Spell_Duration:=(Maxint - 22000);  { To prevent overflow }
      Wore:      Spell_Duration:=1;
      Otherwise  Spell_Duration:=1;
   End;
End;  { Spell Duration }
End.  { Compute }

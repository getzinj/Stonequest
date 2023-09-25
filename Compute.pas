[Inherit ('Types','SMGRTL','STRRTL')]Module Compute;

Type
   { TODO: Enter this code }

   Score_List         = Array [1..7] of Ability_Score;

Var
   { TODO: Enter this code }

  { MinScore is a matrix of Class x Abilities, which tells Stonequest what the minimum ability scores are for each class.  So, for
    example, if MinScore[Cleric]:=(0 0 9 0 0 0 0), this would be that to be a cleric, a character would have to have a 9 or higher
    in wisdom (wisdom's the third ability score) and that all the other scores have to be 0 or better, i.e., any valid ability score. }

   MinScore:          Array [Class_Type,1..7] of Integer;
   { TODO: Enter this code }

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

{ TODO: Enter this code }

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

{ TODO: Enter this code }

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


[Global]Function XP_Needed (Class: Class_Type; Level: Integer):Real;Forward;

[Global]Function XP_Needed_Aux (Class: Class_Type; Level: Integer): Real;

Begin { XP Needed Aux }
   { TODO: Enter this code }
   XP_Needed_Aux:=0;
End;  { XP Needed Aux }


Function XP_Needed;

Begin { XP Needed }
   { TODO: Enter this code }
   XP_Needed:=0;
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

Function  Scores_Qualify (Scores: Score_List;  Class: Class_Type): Boolean;

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


[Global]Function Made_Roll (Needed: Integer): [Volatile]Boolean;

Begin { Made Roll }
   { TODO: Enter this code }
   Made_Roll:=True;
End;  { Made Roll }


[Global]Function Spell_Duration (Spell: Spell_Name; Caster_Level: Integer):Integer;

Begin { Spell Duration }
   { TODO: Enter this code }
   Spell_Duration:=0;
End;  { Spell Duration }
End.  { Compute }

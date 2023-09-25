[Inherit ('Types','SMGRTL','STRRTL')]Module Compute;

{ TODO: Enter this code }

[Global]Function String (Num: Integer; Len: Integer:=0): Line;

Begin { String }
   { TODO: Enter this code }
   String:='';
End;  { String }

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

[Global]Function Class_Choices (Character: Character_Type): Class_Set;

Begin { Class Choices }
   { TODO: Enter this code }
   Class_Choices:=[];
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

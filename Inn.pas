(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types','SMGRTL')]Module Inn;

Type
   Addition_Type = -25..25;
   Age_Addition_Matrix = Array [Age_Type,1..7] of Addition_Type;

Var
   Cost,Healing: Array [1..6] of Integer;
   Room_Name: Array [1..6] of Packed Array [1..42] of char;
   Person: Integer;
   Age_Matrix: Array [Race_Type,Age_Type] of Integer;
   Age_Additions: Age_Addition_Matrix;
   Location:                  [External]Place_Type;
   BottomDisplay,TopDisplay:  [External]Unsigned;

Value
  {                                  Effects       }
  {                  Age        S I  W DEX CO CH L }
  {             -----------     -------------------}
   Age_Additions[YoungAdult]:=( 0,0,-1, 0, 1, 0, 0);
   Age_Additions[Mature]    :=( 1,0, 1, 0, 0, 0, 0);
   Age_Additions[MiddleAged]:=(-1,1, 1, 0,-1, 0, 0);
   Age_Additions[Old]       :=(-2,0, 1,-2,-1, 0, 1);
   Age_Additions[Venerable] :=(-1,1, 1,-1,-1, 0, 1);
   Age_Additions[Croak]     :=( 0,0, 1, 0,-1, 0, 0);

   Room_Name[1]:='The stables         '
       +'         *** FREE ***';    Cost[1]:=0;    Healing[1]:=0;
   Room_Name[2]:='The basement floor  '
       +'         10 gold/week';    Cost[2]:=10;   Healing[2]:=1;
   Room_Name[3]:='My mother''s room   '
       +'          20 gold/week';   Cost[3]:=20;   Healing[3]:=2;
   Room_Name[4]:='Our "Budget" rooms  '
       +'         50 gold/week';    Cost[4]:=50;   Healing[4]:=5;
   Room_Name[5]:='Our finest accomadat'
       +'ions    200 gold/week';    Cost[5]:=200;  Healing[5]:=10;
   Room_Name[6]:='The whole first floo'
       +'r       500 gold/week';    Cost[6]:=500;  Healing[6]:=20;

   Age_Matrix[HfOgre]     :=(0,   12,   19,  30,  45,    60);
   Age_Matrix[HfOrc]      :=(0,   15,   30,  45,   60,   80);
   Age_Matrix[LizardMan]  :=(0,   15,   30,  45,   60,   80);
   Age_Matrix[Quickling]  :=(0,   15,   30,  45,   60,   80);
   Age_Matrix[Human]      :=(0,   20,   40,  60,   90,  120);
   Age_Matrix[HfElf]      :=(0,   40,  100, 175,  250,  325);
   Age_Matrix[Dwarven]    :=(0,   50,  150, 250,  350,  450);
   Age_Matrix[Numenorean] :=(0,   50,  150, 250,  350,  450);
   Age_Matrix[Gnome]      :=(0,   90,  300, 450,  600,  750);
   Age_Matrix[Hobbit]     :=(0,   90,  300, 450,  600,  750);
   Age_Matrix[Centaur]    :=(0,   90,  300, 450,  600,  750);
   Age_Matrix[Elven]      :=(0,  175,  550, 875, 1200, 1600);
   Age_Matrix[Drow]       :=(0,  175,  550, 875, 1200, 1600);

   Person:=0;

(******************************************************************************)
[External]Procedure Restore_Spells (Var Character: Character_Type);external;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  Max_Spell_Level (Class: Class_Type; Level: Integer):Integer;external;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Function  Compute_Hit_Die (Character: Character_Type): Integer;external;
[External]Function  Spells_Known (Class: Class_Type; Level: Integer): Spell_Set;external;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Change_Score (Var Character: Character_Type; Score_Num, Inc: Integer);External;
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function  Alive (Character: Character_Type): Boolean;external;
[External]Function String (Num: Integer; Len: Integer:=0):Line;external;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Procedure Zero_Through_Six (Var Number: Integer; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' ');External;
[External]Procedure Print_Character_Line (CharNo: Integer; Party: Party_Type; Party_Size: Integer);External;
[External]Function Can_play: [Volatile]Boolean;External;
(******************************************************************************)

Function Age_Class (CharRace: Race_Type;  CharAge: Integer): Age_Type;

Begin
   If CharAge>Age_Matrix[CharRace,Croak] then
      Age_Class:=Croak
   Else If CharAge>Age_Matrix[CharRace,Venerable] then
      Age_Class:=Venerable
   Else If CharAge>Age_Matrix[CharRace,Old] then
      Age_Class:=Old
   Else If CharAge>Age_Matrix[CharRace,MiddleAged] then
      Age_Class:=MiddleAged
   Else If CharAge>Age_Matrix[CharRace,Mature] then
      Age_Class:=Mature
   Else
      Age_Class:=YoungAdult;
End;

(******************************************************************************)

Function Gains_Level (Character: Character_Type): Boolean;

{ This function will return TRUE if CHARACTER has enough experience to go up a level, and FALSE otherwise. }

Var
   Class: Class_Type;
   Level,Next_Level: Integer;
   XP: Real;

[External]Function XP_Needed (Class: Class_Type; Level: Integer): Real;external;

Begin
  Class:=Character.Class;  Level:=Character.Level;  XP:=Character.Experience;

  Next_Level:=Level + 1;

  Gains_Level:=(XP>=XP_Needed(Class,Next_Level));
End;

(******************************************************************************)

Procedure Age_Effects (Var Character: Character_Type;  Age_Status: Age_Type);

Var
   T: Line;
   Name: Name_Type;
   i: Integer;
   AbilName: [External]Array [1..7] of Packed Array [1..12] of char;

Begin
   Name:=Character.Name;
   For I:=1 to 7 do
      Change_Score (Character, i, Age_Additions[Age_Status, i]);

   If (Age_Status=Croak) and Not (Roll_Die(20)<=Character.Abilities[5]) then
     Begin
       Character.Status:=Deleted;
       SMG$Put_Line (BottomDisplay,Name+' has died of old age.');
       Delay (5);
     End
   Else
     For I:=1 to 7 do
        If Age_Additions[Age_Status,i]<>0 then
           Begin
              If Age_Additions[Age_Status, i]>0 then T:='gained'
              Else                                   T:='lost';
              T:=Name+' '+T+' '+AbilName[i]+'!';
              SMG$Put_Line (BottomDisplay,T);
           End;
End;

(******************************************************************************)

Procedure Age_Character (Var Character: Character_Type);

Var
   Age_Status: Age_Type;

Begin
   Age_Status:=Age_Class (Character.Race,Trunc(Character.Age/365));
   If Character.Age_Status<>Age_Status then
      Begin
        Age_Effects (Character,Age_Status);
        Character.Age_Status:=Age_Status;
      End;
End;

(******************************************************************************)

Procedure New_Spells (Var Character: Character_Type;  Class: Class_Type;  Level: Integer);

Var
   Temp: Set of Spell_Name;

Begin
   Temp:=Spells_Known (Class,Level);
   Case Class of
     AntiPaladin,Paladin: Character.Cleric_Spells:=Character.Cleric_Spells + Temp;
     Bard,Ranger: Character.Wizard_Spells:=Character.Wizard_Spells + Temp;
     Wizard: Character.Wizard_Spells:=Character.Wizard_Spells + Temp;
     Cleric: Character.Cleric_Spells:=Character.Cleric_Spells + Temp;
     Otherwise ;
   End;
End;

(******************************************************************************)

Procedure More_Spells (Var Character: Character_Type);

{ This procedure tacks on the spells known at this level. If these spells were already known, this procedure is redundant. }

Begin
   New_Spells (Character,Character.Class,Character.Level);
   New_Spells (Character,Character.PreviousClass,Character.Previous_Lvl);
End;

(******************************************************************************)

Procedure Check_for_More_Psionics (Var Character: Character_Type);

Var
   Improved: Boolean;

Begin
   If Character.Psionics then
      Begin
        Improved:=False;
        If Made_Roll (5) then
           Begin Character.DetectTrap:=Character.DetectTrap + Roll_Die(5); Improved:=True; End;
        If Made_Roll (5) then
           Begin Character.Regenerates:=Character.Regenerates + 1; Improved:=True; End;
        If Made_Roll (5) then
           Begin Character.DetectSecret:=Character.DetectSecret + Roll_Die(5); Improved:=True; End;

        If Improved then
           SMG$Put_Line (BottomDisplay,Character.Name+' gained in psionic ability!',0,1);
      End;
End;

(******************************************************************************)

Procedure Promote (Var Character: Character_Type);

Begin
  Character.Level:=Character.Level + 1;
  Character.Max_HP:=Character.Max_HP + Compute_Hit_Die(Character);

  SMG$Erase_Display (BottomDisplay);
  SMG$Put_Line (BottomDisplay,Character.Name+' gained a level!!!!!!',1,1);
  Ring_Bell (BottomDisplay,3);

  Age_Character (Character);

  If Max_Spell_Level (Character.Class,Character.Level) > Max_Spell_Level (Character.Class,Character.Level - 1) then
     SMG$Put_Line (BottomDisplay,Character.Name+' gained new spells!',1,1);
  Check_for_More_Psionics (Character);
End;

(******************************************************************************)

Procedure Rest_Effects (Var Character: Character_Type;  Room_Number: Integer);

Begin
   More_Spells (Character);
   Restore_Spells (Character);

   If Alive (Character) then
      Character.Curr_HP:=Min(Character.Curr_HP+Healing[Room_Number]+(Character.Regenerates*7),Character.MAX_HP);

      If (Character.Curr_HP<1) and Alive(Character) then
         Begin
            Character.Status:=Dead;
            Character.Curr_HP:=0;
         End;
End;

(******************************************************************************)

Procedure Stay_in_Room (Room_Number: Integer; Person,Party_Size: Integer; Var Party: Party_Type;  Var Answer: Char);

Var
  XP,Next: Real;
  T: Line;
  Lvl,Gold: Integer;
  Character: Character_Type;
  Class: Class_Type;
  Name: Line;

[External]Function XP_Needed (Class: Class_Type; Level: Integer): Real;External;

Begin
   Character:=Party[Person];  { NOTE: value copy! }
   Name:=Character.Name;  Gold:=Character.Gold;

   SMG$Erase_Display (BottomDisplay);

   SMG$Put_Chars (BottomDisplay,Name,2,1);
   SMG$Put_Line (BottomDisplay,', thou have '+String(Gold)+' gold pieces');
   SMG$Put_Line (BottomDisplay,Room_Name[Room_Number]+'',3);

   If Gains_Level (Character) then
      Begin
        Delay(1);
        SMG$Erase_Display (BottomDisplay);
        Promote (Character);
      End
   Else
      Begin
         XP:=Character.Experience;  Lvl:=Character.Level + 1;

         Class:=Character.Class;
         Next:=XP_Needed (Class,Lvl);

         T:='Thou need '+String(Round(Next-XP))+' XP to make a level.';
         SMG$Put_Line (BottomDisplay,T);
      End;

   Rest_Effects (Character,Room_Number);

   Party[Person]:=Character;

   Print_Character_Line (Person,Party,Party_Size);

   SMG$Set_Cursor_ABS (BottomDisplay,12,1);
   SMG$Put_Line (BottomDisplay,'Stay another week?',0);

   Answer:=Yes_or_No;
End;

(******************************************************************************)

Procedure Pool_Gold (Pooler: Integer; Var Party: Party_Type; Party_Size: Integer);

Var
   Person,Temp: Integer;

Begin
   Temp:=0;

   For Person:=1 to Party_Size do
      Begin
         Temp:=Temp + Party[Person].Gold;
         Party[Person].Gold:=0;
      End;

   { If Temp has overflowed, bring back to maximum possible value }

   If Temp<0 then Temp:=MaxInt;

   Party[Pooler].Gold:=Temp;
End;

(******************************************************************************)

Procedure Cant_Pay (Var Character: Character_Type; Var Answer: Char);

Begin
   SMG$Put_Line (BottomDisplay,'* * * Thou canst not pay!! * * *',0);
   Ring_Bell (BottomDisplay,2);

   Character.Gold:=0;

   Answer:='N';

   Delay(2);
End;

(******************************************************************************)

Procedure Enter_Inn (Person: Integer; Var Party: Party_Type;  Party_Size: Integer);

Var
  Room_Number,Room_Selected: Integer;
  Name: Line;
  Answer: Char;

Begin
   Name:=Party[Person].Name;
   Repeat
      Begin
         SMG$Begin_Display_Update (BottomDisplay);
         SMG$Erase_Display (BottomDisplay);
         SMG$Put_Chars (BottomDisplay,'Welcome ',2,1,1);
         SMG$Put_Chars (BottomDisplay,Name,2,9,0,1);
         SMG$Set_Cursor_ABS (BottomDisplay,3,1);

         For Room_Number:=1 to 6 do
            SMG$Put_Line(BottomDisplay,'['+CHR(Room_Number + 64)+']   '+Room_Name[Room_Number]);

         SMG$Put_Line (BottomDisplay,'Thou have '+String(Party[Person].Gold)+' Gold Pieces.');
         SMG$Put_Line (BottomDisplay,'Which room?  (P)ool, [RET] exits)',0);
         SMG$End_Display_Update(BottomDisplay);

         Answer:=Make_Choice(['A'..'F',CHR(13),'P']);

         If Not (Answer in [CHR(13),'P']) then
            Begin
               Room_Selected:=Ord(Answer)-64;
               Repeat
                  Begin
                     Party[Person].Age:=Party[Person].Age + 7;
                     Party[Person].Gold:=Party[Person].Gold-Cost[Room_Selected];

                     If Party[Person].Gold>=0 then
                        Stay_In_Room (Room_Selected,Person,Party_Size,Party,Answer)
                     Else
                        Cant_Pay (Party[Person],Answer);
                  End;
               Until Answer='N';
            End
         Else
            If Answer='P' then
               Pool_Gold (Person,Party,Party_Size);
      End;
   Until Answer=CHR(13);
End;

(******************************************************************************)

Procedure Print_Heading (Party_Size: Integer);

Begin
   SMG$Begin_Display_Update (BottomDisplay);
   SMG$Erase_Display (BottomDisplay);

   SMG$Set_Cursor_ABS (BottomDisplay,2,1);
   SMG$Put_Line (BottomDisplay,'Welcome to the Adventurer''s Inn!');
   SMG$Put_Line (BottomDisplay,'Who will stay here?');
   SMG$Put_Line (BottomDisplay,'(1-'+String(Party_Size,1)+', [RETURN] exits)',0);
   SMG$End_Display_Update (BottomDisplay);
End;

(******************************************************************************)

Function Get_Boarder (Party_Size: Integer): [Volatile]Integer;

Var
   Person: Integer;

Begin
  Person:=0;
  Repeat
    If Can_Play then
       Zero_Through_Six (Person)
  Until (Person<=Party_Size);

  Get_Boarder:=Person;
End;

(******************************************************************************)

[Global]Procedure Run_Inn (Var Party: Party_Type; Party_Size: Integer);

Begin { Run Inn }
   Repeat
      Begin
         Print_Heading (Party_Size);

         Person:=Get_Boarder (Party_Size);
         If Person<>0 then
            If Party[Person].Status in [Healthy,Asleep,Poisoned,Afraid,Insane] then
               Enter_Inn (Person,Party,Party_Size)
      End;
   Until Person=0;
   Location:=InKyrn;
End;  { Run Inn }
End.  { Inn }

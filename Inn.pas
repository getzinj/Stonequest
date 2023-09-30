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

{ TODO: Enter this code }

[Global]Procedure Run_Inn (Var Party: Party_Type; Party_Size: Integer);

Begin { Run Inn }

{ TODO: Enter this code }

End;  { Run Inn }
End.  { Inn }

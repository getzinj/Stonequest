[Inherit ('SYS$LIBRARY:STARLET','Types','LIBRTL','SMGRTL')]Module Pick_Pockets;

Const
   BrownE=1;  HazelE=2;   GreenE=3;  BlackE=4;  BlueE=5;  WhiteE=6; BrownE=7;
   BrownH=1;  BlackH=2;   RedH=3;  BlondeH=4;  WhiteH=5;  NoH=6;  BlueH=7;

   Beggar=1;
   Jester=2;
   Drunk=3;
   Prostitute=4;
   Pimp=5;
   CommonThief=6;
   Bully=7;
   Gambler=8;
   Brawler=9;
   Clerk=10;
   Soldier=11;
   Cleric_C=12;
   Gentleman=13;
   Lady=14;
   Militia=15;
   Noble=16;
   Magus=17;
   Official=18;
   Royalty=19;

   MaleS=1;  FemaleS=2;

   HumanR=1;
   HfOrcR=2;
   DwarfR=3;
   ElvenR=4;
   HfOgreR=5;
   GnomeR=6;
   HobbitR=7;
   HfElfR=8;
   LizardManR=9;
   CentaurR=10;
   QuicklingR=11;
   DrowR=12;
   NumenoreanR=13;

Type
  Description_Type = (HairColor,EyeColor,Build,Sex,Height,Job,Race,Weight,Armors,Weapons,Clothes,Money,DetectChance,Distraction);
  Description_Record = Array [Description_Type] of Integer;

Var
   Pasteboard,BottomDisplay: [External]Unsigned;
   Location: [External]Place_Type;
   Hair__Color,Eye__Color: Array [1..7] of Lines;
   Race_Name: Array [1..14] of Line;

Value
   Hair__Color[BrownH]:='brown
   Hair__Color[BlackH]:='black
   Hair__Color[RedH]:='red
   Hair__Color[BlondeH]:='blonde
   Hair__Color[WhiteH]:='white
   Hair__Color[NoH]:='no
   Hair__Color[BlueH]:='blue

   Eye__Color[BrownE]:='brown
   Eye__Color[HazelE]:='hazel
   Eye__Color[GreenE]:='green
   Eye__Color[BlackE]:='black
   Eye__Color[BlueE]:='blue
   Eye__Color[WhiteE]:='white
   Eye__Color[YellowE]:='yellow

   Race_Name[HumanR]:='Human ';
   Race_Name[HfOrcR]:='Half-Orc ';
   Race_Name[DwarfR]:='Dwarven ';
   Race_Name[ElvenR]:='Elven ';
   Race_Name[HfOgreR]:='Half-Ogre ';
   Race_Name[GnomeR]:='Gnome ';
   Race_Name[HobbitR]:='Hobbit ';
   Race_Name[HfElfR]:='Half-Elven ';
   Race_Name[LizardManR]:='Lizard-';
   Race_Name[CentaurR]:='Centaur ';
   Race_Name[QuicklingR]:='Quickling ';
   Race_Name[DrowR]:='Drow ';
   Race_Name[NumenoreanR]:='Númenórean ';

(******************************************************************************)
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function User_Name: Line;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function Pick_Character_Number (Party_Size: Integer; Current_Party_Size: Integer:=0;
                                          Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): [Volatile]Integer;External;
[External]Function Can_Play: [Volatile]Boolean;External;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Function  String (Num: Integer; Len: Integer:=0):Line;external;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Print_Character_Line (CharNo: Integer; Party: Party_Type; Party_Size: Integer);External;
[External]Procedure Backup_Party (Party: Party_Type;  Party_Size: Integer);External;
(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Pick_Pockets (Var Party: Party_Type;  Var Party_Size: Integer);

Begin

{ TODO: Enter this code }

End;
End.  { Pick Pockets }

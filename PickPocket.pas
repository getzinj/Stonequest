[Inherit ('SYS$LIBRARY:STARLET','Types','LIBRTL','SMGRTL')]Module Pick_Pockets;

Const
   BrownE=1;  HazelE=2;   GreenE=3;  BlackE=4;  BlueE=5;  WhiteE=6; YellowE=7;
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
   Nobleman=16;
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
   Hair__Color,Eye__Color: Array [1..7] of Line;
   Race_Name: Array [1..14] of Line;

Value
   Hair__Color[BrownH]:='brown';
   Hair__Color[BlackH]:='black';
   Hair__Color[RedH]:='red';
   Hair__Color[BlondeH]:='blonde';
   Hair__Color[WhiteH]:='white';
   Hair__Color[NoH]:='no';
   Hair__Color[BlueH]:='blue';

   Eye__Color[BrownE]:='brown';
   Eye__Color[HazelE]:='hazel';
   Eye__Color[GreenE]:='green';
   Eye__Color[BlackE]:='black';
   Eye__Color[BlueE]:='blue';
   Eye__Color[WhiteE]:='white';
   Eye__Color[YellowE]:='yellow';

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

Function Weapon_and_Armor (Temp: Description_Record): Line;

Var
  T: Line;

Begin
  T:='';
  Case Temp[Armors] of
     0: T:='no';
     3..7: T:='little';
     8..11: T:='some';
     12..14: T:='a good amount of';
     15..18: T:='a lot of';
     Otherwise T:='a ton of';
  End;
  T:=T+' armor, ';

  Case Temp[Weapons] of
     0: T:=T+'is unarmed';
     1,2: T:=T+'has a bludgeon';
     3..5: T:=T+'has a dagger';
     6..13: T:=T+'has a sword';
     14..18: T:=T+'is heavily armed';
     Otherwise T:=T+'has a knife';
  End;

  Weapon_And_Armor:=T;
End;

(******************************************************************************)

Function Clothes_String (Clothes: Integer): Line;

Begin
   Case Clothes of
      0: Clothes_String:='is nude';
      1: Clothes_String:='is almost completely nude';
      2: Clothes_String:='is barely covered';
      3..5: Clothes_String:='is shabbily dressed';
      6: Clothes_String:='is very poorly dressed';
      7: Clothes_String:='is poorly dressed';
      8..11: Clothes_String:='is dressed in common clothes';
      12..13: Clothes_String:='is dressed in nice clothes';
      14..15: Clothes_String:='is dressed in very nice clothes';
      16..17: Clothes_String:='is dressed in extremely nice clothes';
      18: Clothes_String:='is extremely well-dressed';
      Otherwise Clothes_String:='is dressed in gaudy and tacky clothes';
   End;
End;

(******************************************************************************)

Function Detected_Thief (Job: Integer;  Subject,Object,Possessive: Line;  Race: Integer): [Volatile]Line;

Var
   T: Line;

Begin
   Case Job of
      Beggar: T:=Subject+' says, "Canst thou spare '+String(Roll_Die(3)+1)+' gold pieces?"';
      Jester: Case Roll_Die (4) of
                1: T:=Subject+' throws a pie in thine face.';
                2: T:=Subject+' tells thee a joke.';
                3: T:=Subject+' does a handstand for thee.';
                4: T:=Subject+' sings for thee.';
              End;
      Drunk: Case Roll_Die (3) of
                1: T:=Subject+' offers thee a drink from a filthy bottle.';
                2: T:=Subject+' begins to sing drunkenly to thee.';
                3: T:=Subject+' belches at thee. "Oh! Excuuuuse me!"';
              End;
      Pimp: T:=Subject+' says, "Art thou interested in a broad? A man? Both?"';
      Prostitute: Begin
                      Case Roll_Die (3) of
                        1: T:=Subject+' jiggles her breasts at thee.';
                        2: T:=Subject+' winks at thee.';
                        3: T:=Subject+' says, "Art though lonely tonight?"';
                      End;
                      Case Race of
                         HfOgreR,HfOrcR: T:=T+' (UG!!!)';
                         CentaurR: T:=T+' (but she''s a horse!)';
                         DwarfR: T:=T+' (she has a lovely beard)';
                         ElvenR,NumenoreanR: T:=T+' (wow!)';
                         Otherwise ;
                      End;
                    End;
      Cleric_C: Case Roll_Die (3) of
                1: T:=Subject+' meekly says hello.';
                2: T:=Subject+' begins to preach about '+Possessive+' deity to you.';
                3: T:=Subject+' asks you, "Have you ever thought about converting?"';
              End;
      Militia: Case Roll_Die (3) of
                1: T:=Subject+' nods hello to thee.';
                2: T:=Subject+' tells you, "Be safe and have a nice day."';
                3: T:=Subject+' tilts his watch cap to thee in greeting.';
              End;
      Gentleman: T:=Subject+' walks past thee holding his nose.';
      Lady: T:=Subject+' walks past thee holding her nose.';
      Magus: T:=Subject+' nods hell to thee.';
      Official,Nobleman: T:=Subject+' says, "Be off with thee!"';
      Royalty: T:=Subject+' tells '+Possessive+' guards to get rid of thee.';
      Otherwise T:=Subject+' smiles at thee.';
   End;
   Detected_Thief:=T;
End;

(******************************************************************************)

Function Busy_Person (Job: Integer;  Subject,Object,Possessive: Line): [Volatile]Line;

Var
   T: Line;

Begin
   T:='';
   Case Job of
      Beggar: T:=Subject+' is busy begging for money.';
      Jester: Case Roll_Die (3) of
                1: T:=Subject+' is busy doing tricks and cracking jokes.';
                2: T:=Subject+' is singing a song.';
                3: T:=Subject+' is doing acrobatics.';
              End;
      Drunk: T:=Subject+' is busy singing drunkenly to '+object+'self.';
      Prostitute: T:=Subject+' is busy coming on to people.';
      CommonThief: T:=Subject+' is eyeing the crowd warily.';
      Bully: T:=Subject+' is beating up a wimpy-looking man.';
      Gambler: T:=Subject+' is busy bragging about'+Possessive+' Zowie Slot winnings.';
      Clerk: Case Roll_Die (3) of
                1: T:=Subject+' is buying some Ice Creame.';
                2: T:=Subject+' watching two ruffians fight each other.';
                3: T:=Subject+' is singing quietly to'+object+'self.';
              End;
      Pimp: Case Roll_Die (3) of
                1: T:=Subject+' is shooting craps with some guys.';
                2: T:=Subject+' is beating up a naked man, demanding money.';
                3: T:=Subject+' is slapping a half-dressed woman.';
              End;
      Soldier: Case Roll_Die (3) of
                1: T:=Subject+' is leaning against a lamppost.';
                2: T:=Subject+' is shooting craps with some guys.';
                3: T:=Subject+' is busy trying to start a fight.';
              End;
      Cleric_C: T:=Subject+' is praying.';
      Gentleman: T:=Subject+' is entertaining a group of ladies.';
      Lady: T:=Subject+' is surrounded by a group of admirers.';
      Militia: T:=Subject+' is surveying the crowd, looking for trouble.';
      Nobleman: T:=Subject+' is strutting down the street pompously.';
      Magus: T:=Subject+' is lost in contemplative thought.';
      Official: T:=Subject+' is busy talking to a militia officer.';
      Royalty: T:=Subject+' is giving a speech to '+possessive+' subjects.';
      Otherwise T:=Subject+' is daydreaming.';
   End;
   Busy_Person:=T;
End;

(******************************************************************************)

Function Display_Person (Person: Description_Record): [Volatile]Boolean;

Var
  T: Varying [390] of Char;
  Subject,Object,Possessive: Line;
  Noticed: Boolean;

Begin
   Noticed:=False;
   SMG$Begin_Display_Update (BottomDisplay);
   SMG$Erase_Display (BottomDisplay);

   T:='You see a '+Race_Name[Person[Race]];
   If Person[Sex]=MaleS then
      Begin
         T:=T+'man';
         Subject:='He'; Object:='him';  Possessive:='his';
      End
   Else
      Begin
         T:=T+'woman';
         Subject:='She'; Object:='her';  Possessive:='her';
      End;

   T:=T+' with '+Hair__Color[Person[HairColor]]+' hair and '+Eye__Color[Person[EyeColor]]+' eyes.  ';
   T:=T+Subject+' '+Weapon_and_Armor(Person)+' and '+Clothes_String(Person[Clothes])+'.  ';

   If Roll_Die(100)<=Person[DetectChance] then
      Begin
         T:=T+Detected_Thief (Person[Job],Subject,Object,Possessive,Person[Race]);
         Noticed:=True;
      End
   Else
      T:=T+Busy_Person (Person[Job],Subject,Object,Possessive);

   SMG$Put_Line (BottomDisplay,T,1,Wrap_Flag:=SMG$M_WRAP_WORD);
   SMG$Put_Line (BottomDisplay,'',2);
   SMG$End_Display_Update (BottomDisplay);

   Display_Person:=Noticed;
End;

(******************************************************************************)

Function Get_EyeColor: [Volatile]Integer;

Begin
   Get_EyeColor:=Min(Roll_Die(YellowE),Roll_Die(YellowE));
End;

(******************************************************************************)

Function Get_HairColor: [Volatile]Integer;

Begin
   Get_HairColor:=Min(Roll_Die(BlueH),Roll_Die(BlueH));
End;


(******************************************************************************)

Function Get_Job: [Volatile]Integer;

Begin
   Get_Job:=Min(Roll_Die(Royalty),Roll_Die(Royalty));
End;

(******************************************************************************)

Function Get_Sex (Job: Integer): [Volatile]Integer;

Begin
  Case Job of
     Brawler,Bully,CommonThief,Magus,Drunk,Militia,Soldier: Get_Sex:=Min(Roll_Die(FemaleS),Roll_Die(FemaleS));
     Prostitute: Get_Sex:=FemaleS;
     Clerk,Gentleman,Jester,Nobleman,Official,Pimp: Get_Sex:=MaleS;
     Cleric_C,Beggar,Gambler,Royalty: Get_Sex:=Roll_Die(FemaleS);
     Otherwise Get_Sex:=Roll_Die (FemaleS);
  End;
End;

(******************************************************************************)

Function Get_Race (Job: Integer): [Volatile]Integer;

Var
  Temp1,Temp2: Integer;

Begin
   Temp1:=Roll_Die(NumenoreanR);
   Temp2:=Roll_Die(NumenoreanR);
   Temp1:=Min(Temp1,Temp2);

   Case Job of
      Beggar,Drunk,Gambler,Brawler,Prostitute,Pimp,Cleric_C,Soldier,Militia,Magus: ;
      Clerk,Jester: If Temp1 in [HfOrcR,DwarfR,HfOgreR,LizardManR,CentaurR,DrowR,NumenoreanR] then Temp1:=HumanR;
      CommonThief,Bully: If Temp1=NumenoreanR then Temp1:=HumanR;
      Gentleman,Lady,Nobleman,Official,Royalty: Temp1:=HumanR;
      Otherwise Temp1:=HumanR;
   End;
   Get_Race:=Temp1;
End;

(******************************************************************************)

Procedure Get_Physical (Var Temp: Description_Record; Sex,Race,Job: Integer);

Var
  B1,H1,W1: Integer;

Begin
  B1:=0;  H1:=0;  W1:=0;
  B1:=Roll_Die(6)+Roll_Die(6)+Roll_Die(6);
  H1:=Roll_Die(6)+Roll_Die(6)+Roll_Die(6);
  W1:=Roll_Die(6)+Roll_Die(6)+Roll_Die(6);

  Case Race of
     HumanR,HfElfR:  ;
     HfOrcR:          Begin  B1:=B1+2;  H1:=H1-1;   W1:=W1+2;   End;
     DwarfR:          Begin  B1:=B1+1;  H1:=H1-8;   W1:=W1-4;   End;
     ElvenR,DrowR:    Begin  B1:=B1-1;  H1:=H1-2;   W1:=W1-2;   End;
     HfOgreR:         Begin  B1:=B1+4;  H1:=H1+4;   W1:=W1+8;   End;
     GnomeR,HobbitR:  Begin  B1:=B1-2;  H1:=H1-8;   W1:=W1-6;   End;
     LizardManR:      Begin  B1:=B1+2;  H1:=H1+1;   W1:=W1+1;   End;
     CentaurR:        Begin  B1:=B1+1;  H1:=H1-1;   W1:=W1+4;   End;
     QuicklingR:      Begin  B1:=B1+6;  H1:=H1-12;  W1:=W1-12;  End;
     NumenoreanR:     Begin  W1:=W1-2;  End;
     Otherwise ;
  End;

  Case Sex of
     MaleS:  Begin  B1:=B1+1;    H1:=H1+1;  W1:=W1+1;  End;
     FemaleS:  Begin  B1:=B1-1;  H1:=H1-1;  W1:=W1-1;  End;
  End;

  Case Job of
     Beggar,Drunk,Prostitute,CommonThief,Bully,Gambler,Gentleman,Lady,Official,Magus: ;
     Jester: Begin  B1:=B1+1;  W1:=8;  End;
     Brawler,Cleric_c,Soldier,Militia: B1:=B1+2;
     Clerk:  B1:=B1-1;
     Nobleman,Royalty: W1:=W1+3;
     Otherwise ;
  End;

  Temp[Build]:=B1;
  Temp[Height]:=H1;
  Temp[Weight]:=W1;
End;

(******************************************************************************)

Function Get_Money (Job: Integer): [Volatile]Integer;

Begin
   Case Job of
      Beggar: Get_Money:=2-Roll_Die(2);
      Jester: Get_Money:=Roll_Die(3)*Roll_Die(6);
      Pimp,Prostitute: Get_Money:=(Roll_Die(8)*Roll_Die(100))-1;
      CommonThief: Get_Money:=2*Roll_Die(20)-2;
      Bully,Brawler: Get_Money:=Roll_Die(3)*Roll_Die(20);
      Clerk: Get_Money:=3 * Roll_Die(7);
      Soldier,Militia: Get_Money:=Roll_Die(20)+Roll_Die(20);
      CLeric_C,Gentleman,Lady,Official,Gambler: Get_Money:=Max(Roll_Die(20),Roll_Die(100));
      Nobleman,magus: Get_Money:=(Roll_Die(4)*Roll_Die(1000))+Roll_Die(100);
      Royalty: Get_Money:=Roll_Die(12000);
      Otherwise Get_Money:=0;
   End;
End;

(******************************************************************************)

Procedure Get_Equiptment (Var Temp: Description_Record;  Job: Integer);

Begin
   Case Job of
       Beggar:                   Begin  Temp[Armors]:=0;   Temp[Weapons]:=0;  Temp[Clothes]:=3;   End;
       Jester:                   Begin  Temp[Armors]:=0;   Temp[Weapons]:=0;  Temp[Clothes]:=9;   End;
       Drunk:                    Begin  Temp[Armors]:=0;   Temp[Weapons]:=0;  Temp[Clothes]:=3;   End;
       Prostitute:               Begin  Temp[Armors]:=0;   Temp[Weapons]:=0;  Temp[Clothes]:=3+Roll_Die(3);   End;
       Pimp:                     Begin  Temp[Armors]:=0;   Temp[Weapons]:=3;  Temp[Clothes]:=21;   End;
       CommonThief:              Begin  Temp[Armors]:=3;   Temp[Weapons]:=3;  Temp[Clothes]:=8;   End;
       Bully:                    Begin  Temp[Armors]:=(Roll_Die(2)-1)*(Roll_Die(6)*3);
                                        Temp[Weapons]:=(Roll_Die(2)-1)*(Roll_Die(6)*3);
                                        Temp[Clothes]:=9;
                                 End;
       Gambler:                  Begin  Temp[Armors]:=0;   Temp[Weapons]:=3;  Temp[Clothes]:=7+Roll_Die(Temp[Money] div 10);   End;
       Brawler:                  Begin  Temp[Armors]:=0;   Temp[Weapons]:=0;  Temp[Clothes]:=9;   End;
       Clerk:                    Begin  Temp[Armors]:=0;   Temp[Weapons]:=0;  Temp[Clothes]:=8;   End;
       Cleric_c,Soldier,Militia: Begin  Temp[Armors]:=16;  Temp[Weapons]:=16; Temp[Clothes]:=5+Roll_Die(9);   End;
       Gentleman,Lady,Official:  Begin  Temp[Armors]:=0;   Temp[Weapons]:=0;  Temp[Clothes]:=16;   End;
       Nobleman,Royalty:         Begin  Temp[Armors]:=0;   Temp[Weapons]:=0;  Temp[Clothes]:=18;   End;
       Magus:                    Begin  Temp[Armors]:=0;   Temp[Weapons]:=3;  Temp[Clothes]:=15;   End;
       Otherwise                 Begin  Temp[Armors]:=0;   Temp[Weapons]:=0;  Temp[Clothes]:=0;   End;
   End;
End;

(******************************************************************************)

Function Get_Distraction (Job: Integer): [Volatile]Integer;

Var
  D1: Integer;

Begin
   D1:=Roll_Die(6)+Roll_Die(6)+Roll_Die(6);

   Case Job of
     Beggar: D1:=D1+3;
     Jester: D1:=3;
     Drunk: D1:=D1+12;
     Prostitute: D1:=3;
     Pimp: D1:=D1-1;
     CommonThief: D1:=-12;
     Bully,Brawler,Cleric_C: D1:=D1+2;
     Clerk,Soldier,Militia: ;
     Gambler: D1:=D1+1;
     Gentleman,Lady: D1:=D1+3;
     Nobleman: D1:=D1+1;
     Official: D1:=D1+2;
     Royalty,Magus: D1:=D1+10;
     Otherwise ;
   End;
   Get_Distraction:=D1;
End;


(******************************************************************************)

Function Get_Detect (Temp: Description_Record): [Volatile]Integer;

{ Chance the person will see the character. This reduces, but does not eliminate the chance of picking pockets }

Var
  D1: Integer;

Begin
   Case Temp[Job] of
     Beggar: D1:=99;
     Jester: D1:=80;
     Drunk: D1:=40;
     Prostitute: D1:=80;
     Pimp: D1:=80;
     CommonThief: D1:=90;
     Bully: D1:=50;
     Gambler,Cleric_c: D1:=20;
     Brawler: D1:=50;
     Clerk: D1:=10;
     Soldier,Militia: D1:=85;
     Gentleman,Lady: D1:=80;
     Nobleman: D1:=90;
     Official: D1:=70;
     Royalty: D1:=99;
     Magus: D1:=75;
     Otherwise D1:=65;
   End;
   D1:=D1-(Temp[Distraction]*2);
   Get_Detect:=D1;
End;

(******************************************************************************)

Function Get_Townsperson: Description_Record;

Var
  Temp: Description_Record;

Begin
   Temp:=Zero;
   Temp[EyeColor]:=Get_Eyecolor;
   Temp[HairColor]:=Get_Haircolor;
   Temp[Job]:=Get_Job;
   Temp[Sex]:=Get_Sex (Temp[Job]);
   Temp[Race]:=Get_Race (Temp[Job]);

   Get_Physical (Temp,Temp[Sex],Temp[Race],Temp[Job]);

   Temp[Money]:=Get_Money (Temp[Job]);

   Get_Equiptment (Temp,Temp[Job]);

   Temp[Distraction]:=Get_Distraction (Temp[Job]);
   Temp[DetectChance]:=Get_Detect (Temp);

  Get_Townsperson:=Temp;
End;

(******************************************************************************)

Function Class_Chance (Class: Class_Type; Level: Integer): Integer;

Var
   Chance: Integer;

Begin
   Case Class of
      Thief,Ninja:          Chance:=20+(5*Level);
      Antipaladin,Assassin: Chance:=5+(5*Level);
      Paladin:              Chance:=1;
      Bard:                 Chance:=5*Level;
      NoClass:              Chance:=0;
      Otherwise             Chance:=Level;
   End;
   Class_Chance:=Chance;
End;

(******************************************************************************)

Function Pick_Pocket_Chance (Character: Character_Type; Person: Description_Record; Noticed: Boolean): Integer;

Var
   Chance: Integer;
   Class1,Class2: Class_Type;
   Level1,Level2: Integer;

Begin
   Class1:=Character.Class;            Level1:=Character.Level;
   Class2:=Character.PreviousClass;    Level2:=Character.Previous_Lvl;
   Chance:=Max(Class_Chance(Class1,Level1),Class_Chance(Class2,Level2));

   Case Character.Race of
       Dwarven:   Chance:=Chance+15;
       Gnome:     Chance:=Chance+10;
       Hobbit,HfOrc: Chance:=Chance+5;
       HfOgre:    Chance:=Chance-10;
       Quickling,Drow,Elven:  Chance:=Chance+20;
   End;

   Case Character.Abilities[4] of
       3..8: Chance:=Chance-20;
       9,10: Chance:=Chance-10;
       11: Chance:=Chance-5;
       18: Chance:=Chance+5;
       19,20: Chance:=Chance+10;
       21,22: Chance:=Chance+15;
       23,24: Chance:=Chance+20;
       25: Chance:=Chance+25;
   End;

   Chance:=Chance-Round(1.25 * Person[Job]);
   Chance:=Chance-Person[DetectChance];
   Chance:=Chance+(2*(Character.Abilities[7]-9));  { add luck into it }
   If Noticed then Chance:=Chance-80
   Else Chance:=Chance+(2*Person[Distraction]);

   If Chance>96 then Chance:=95;
   Pick_Pocket_Chance:=Chance;
End;

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Pick_Pockets (Var Party: Party_Type;  Var Party_Size: Integer);

Begin

{ TODO: Enter this code }

End;
End.  { Pick Pockets }

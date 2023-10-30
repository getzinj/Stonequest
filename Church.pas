[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL')]Module Church;

Var
   RosterDisplay:                     Unsigned;
   BottomDisplay,Keyboard,Pasteboard: [External]Unsigned;
   Location:                          [External]Place_Type;
   StatusName:                        [External]Array [Status_Type] of Varying [14] of char;
   ClassName:                         [External]Array [Class_Type] of Varying [13] of char;
   AlignName:                         [External]Array [Align_Type] of Packed Array [1..7] of char;
   Roster:                            [External]Roster_Type;
   Cleric_Name:                       Array [1..8] of Line;

Value
   Cleric_Name[1]:='Geoff, the Magnificent';
   Cleric_Name[2]:='Irene, the Pious';
   Cleric_Name[3]:='Christine, the Beautiful';
   Cleric_Name[4]:='Mozark, the Powerful';
   Cleric_Name[5]:='Frederick, the Fine';
   Cleric_Name[6]:='Mawara, the Steadfast';
   Cleric_Name[7]:='Mistophastes, the Mysterious';
   Cleric_Name[8]:='Karina, the Truthful';

(******************************************************************************)
[External]Function User_Name: Line;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Change_Score (Var Character: Character_Type; Score_Num, Inc: Integer);External;
[External]Function  Regenerates (Character: Character_Type; PosZ: Integer:=0):Integer;external;
[External]Function Alive (Character: Character_Type): Boolean;External;
[External]Function  String (Num: Integer; Len: Integer:=0):Line;external;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Function Can_Play: [Volatile]Boolean;External;
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function Zero_Through_Six (Var Number: Integer; Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): Char;External;
[External]Function Pick_Character_Number (Party_Size: Integer; Current_Party_Size: Integer:=0;
                                          Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): [Volatile]Integer;External;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Function Character_Exists (CharName: Name_Type; Var Spot: Integer):Boolean;external;
[External]Procedure Update_High_Scores (Username:Line);external;
(******************************************************************************)

Procedure Mumbo_Jumbo;

Var
   Phrase: Array [1..31] of Line;
   Pass: Integer;
   Choice: Integer;
   Max,Finale: Integer;
   T: Line;

Begin
  Max:=29;  { Number of magical phrases }
  Finale:=30; { The start of the finales }

  Phrase[1]:='Spiratus Mundi';          Phrase[2]:='Magnum PIum';
  Phrase[3]:='Kyrie Eleison';           Phrase[4]:='Sanctus';
  Phrase[5]:='Bless yous';              Phrase[6]:='Evocare';
  Phrase[7]:='Jinus nottus';            Phrase[8]:='Imperiti';
  Phrase[9]:='Multa Pecunia';           Phrase[10]:='Schlocti';
  Phrase[11]:='Burma Shava';            Phrase[12]:='Fiat Lux';
  Phrase[13]:='E Pluribus Unum';        Phrase[14]:='Deux Ex Machina';
  Phrase[15]:='Ipso Facto';             Phrase[16]:='Habeus corpus';
  Phrase[17]:='Quod erat demonstratum'; Phrase[18]:='Cum Sanctu spiritu';
  Phrase[19]:='Medicus Qui';            Phrase[20]:='Gettum Wellum';
  Phrase[21]:='Hallmarkus';             Phrase[22]:='Quacti Sumus';
  Phrase[23]:='No candous';             Phrase[24]:='Verbatim';
  Phrase[25]:='Igpe Atinle';            Phrase[26]:='Nobody expects the Spanish Inquisition';
  Phrase[27]:='Cogito Ergo Sum';        Phrase[28]:='Qui Quae Quod';
  Phrase[29]:='Tempus Fugit';
  Phrase[30]:='Presto!';                Phrase[31]:='Voila!';

  For pass:=1 to 3 do
     Begin
        Choice:=Roll_Die(Max);
        T:=Phrase[choice]+'...';
        SMG$Put_Chars (BottomDisplay,T,11,40-(T.Length div 2),1,0,1);

        Phrase[Choice]:=Phrase[Max];
        Max:=Max-1;

        Delay(3);
     End;

     SMG$Begin_Display_Update (BottomDisplay);
     SMG$Erase_Line (BottomDisplay,11,1);

     T:=Phrase[Finale+Roll_die(2)-1];
     SMG$Put_Chars (BottomDisplay,T,11,40-(T.Length div 2),1,0,1);

     SMG$End_Display_Update (BottomDisplay);

     Delay (4);
End;

(******************************************************************************)

Procedure Lost_Him (Character: Character_Type);

Var
   T: Line;

Begin
   Case Roll_Die(7) of
      1: T:='Oops!  Sorry...';
      2: T:='Egads! How dreadfully embarrassing...';
      3: T:='Uh oh.  Sorry about that...';
      4: T:='Thou have our condolences...';
      5: If Character.Status=Ashes then
           T:='We can get thee a jar for these ashes...'
         Else
           T:='This is not thy lucky day...';
      6: Case Character.Sex of
            Male:  T:='Was he a dear friend?';
            Female: T:='Was she a dear friend?';
            Otherwise T:='Was it a dear friend?';
         End;
      7: T:='Momma told me I''d have days like this...';
      Otherwise T:='';
   End;

   SMG$Put_Chars (BottomDisplay,T,11,40-(T.length div 2),1);
   Delay (2);
End;

(******************************************************************************)

Procedure Gone_for_Good;

Begin
   SMG$Put_Chars (BottomDisplay,'The gods have taken thy friend away from us.',12,17,1,1);
   Delay (3);
End;

(******************************************************************************)

Procedure Resurrection_Failed (Var Character: Character_Type);

{ This is called when the resurrection has failed. A DEAD character will
  be turned to ASHES; an ASHES character will be deleted.  Therefore, a
  character failing two consecutive resurrections is lost forever. }

Begin
   Case Character.Status of
      Dead: Character.Status:=Ashes;
      Ashes: Character.Status:=Deleted;
      Otherwise ;
   End;
   Character.Curr_HP:=0;

   Lost_Him (Character);
   If Character.Status=Deleted then
      Gone_for_Good;
End;

(******************************************************************************)

Procedure Resurrection_Succeeded (Var Character: Character_Type);

{ When raising a dead character, there is a 10% chance that the character will lose a point of constitution. }

Begin
   Case Character.Status of
      Dead: Begin
               Character.Curr_HP:=1;
               If Roll_Die(100)<=10 then
                  Change_Score (Character,5, -1);
            End;
      Ashes: Character.Curr_HP:=Character.Max_HP;
   End;

   Character.Status:=Healthy;
   Character.Experience:=Character.Experience+100;

   SMG$Put_Chars (BottomDisplay,'Jubilations! Thy friend lives again!',11,21);
   Delay (2);
End;

(******************************************************************************)

Procedure Raise_Character (Var Character: Character_Type);

Const
   Chance_of_Success = 75;

Var
   Die: Integer;

Begin
  Die:=Roll_Die (100);
  If (Die<=Chance_of_Success) and (Character.Status in [Dead,Ashes]) and
     (Character.Age_Status<>Croak) and (Character.Max_HP>0) then
       Resurrection_Succeeded (Character)
  Else
       Resurrection_Failed (Character);
End;

(******************************************************************************)

Function Cost (Character: Character_Type): [Volatile]Integer;

Var
  Price: Integer;

Begin
   Case Character.Status of
      Healthy,Deleted: Price:=0;
      Zombie: Price:=200*Character.Max_HP;
      Dead: Price:=950*(Character.Level + Character.Previous_Lvl);
      Ashes: Price:=Round(1353.3 * (Character.Level + Character.Previous_Lvl));
      Afraid,Asleep: Price:=150*(Character.Level + Character.Previous_Lvl);
      Paralyzed,Petrified: Price:=250*(Character.Level + Character.Previous_Lvl);
      Insane: Price:=200*(Character.Max_HP);
      Poisoned: Price:=100*Round(1.5 * (Character.Level + Character.Previous_Lvl));
      Otherwise Price:=0;
   End;
   Cost:=Price + (Roll_Die (Price div 10)-1);
End;

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Run_Church (Var Party: Party_Type; Party_Size: Integer);

Begin { Church }

{ TODO: Enter this code }

End;  { Church }
End.  { Church }

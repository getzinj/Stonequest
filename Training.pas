[Inherit ('Types','SYS$LIBRARY:STARLET','LIBRTL','SMGRTL','STRRTL')]Module TrainingGrounds;

Type
   Race_Set  = Set of Race_Type;
   Align_Set = Set of Align_Type;

Var
   Party:                               Party_Type;
   Party_Size:                          Integer;
   Leave_Maze:                          Boolean;
   ClassChoiceDisplay:                  Unsigned;
   ScreenDisplay,Keyboard,Pasteboard:   [External]Unsigned;
   Location:                            [External]Place_Type;
   Roster:                              [External]Roster_Type;
   ClassName:                           [External]Array [Class_Type] of Varying [13] of char;
   Maze:                                [External]Level;
   PosX,PosY,PosZ:                      [External, Byte]0..20;
   Rounds_Left:                         [External]Array [Spell_Name] of Unsigned;

Value
   Leave_Maze:=False;
   Party_Size:=0;

{******************************************************************************)
[External]Function  Character_Exists (CharName: Name_Type; Var Spot: Integer):Boolean;external;
[External]Procedure Print_Roster;External;
[External]Function  Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function  String (Num: Integer; Len: Integer:=0):Line;external;
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function  Class_Choices (Character: Character_Type): Class_Set;external;
[External]Function  Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Update_High_Scores (Username: Line);external;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Procedure Print_Character (Var Party: Party_Type;  Party_Size: Integer;  Var Character: Character_Type;
                                     Var Leave_Maze: Boolean; Automatic: Boolean:=False);external;
[External]Procedure Change_Score (Var Character: Character_Type; Score_Num, Inc: Integer);External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  Compute_Hit_Die (Character: Character_Type): Integer;external;
[External]Function  Regenerates (Character: Character_Type):Integer;external;
[External]Procedure Restore_Spells (Var Character: Character_Type);external;
[External]Procedure Store_Character (Var Character: Character_Type);external;
{******************************************************************************)

Procedure Update_Class_Choices (Character: Character_Type);

{ This procedure will print the list of classes that CHARACTER is qualified for }

Var
   Possibilities: Set of Class_Type;
   Each: Class_Type;

Begin { Update Class Choices }

 { Get a list of possibilities }

   Possibilities:=Class_Choices (Character);

 { Print them to the window }

   SMG$Begin_Display_Update (ClassChoiceDisplay);
   SMG$Erase_Display (ClassChoiceDisplay);
   For Each:=Cleric to Barbarian do
      If Each in Possibilities then SMG$Put_Line (ClassChoiceDisplay,ClassName[Each]);
   SMG$End_Display_Update (ClassChoiceDisplay);
End;  { Update Class Choices }

{******************************************************************************)

Function Random_Ability_Score: [Volatile]Integer;

{ This function will return a random number between 3 to 18, with a bias around 10.5 }

Var
  Dice: Array [1..4] of Integer;
  Die,Sum: Integer;

Begin { Random Ability Score }
   Sum:=0;  { The sum of the dice is zero so far }
   For Die:=1 to 4 do
      Begin
         Dice[Die]:=Roll_Die(6);
         Sum:=Sum+Dice[Die];  { Sum the dice }
      End;

 { Return the sum minus the lowest die }

  Random_Ability_Score:=Sum-Min(Dice[1],Dice[2],Dice[3],Dice[4]);
End;  { Random Ability Score }

{******************************************************************************)

Procedure Roll_Scores (Var Character: Character_Type);

{ This procedure will allow a player to roll his character's ability scores }

Var
   FirstTime,Satisfied: Boolean;
   Answer: Char;
   Score: Integer;
   AbilName: [External]Array [1..7] of Packed Array [1..12] of char;

Begin { Roll Scores }
   Satisfied:=False;  FirstTime:=True;
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Chars (ScreenDisplay,'Name: '
            +Character.name,1,1);
         SMG$Set_Cursor_ABS (ScreenDisplay,3,1);
       { Get and print some ability scores }

         For Score:=1 to 7 do
            Begin
               Character.Abilities[Score]:=Random_Ability_Score;
               SMG$Put_Line (ScreenDisplay,
                   AbilName[Score]
                   +': '
                   +String(Character.Abilities[Score],2));
            End;

       { Show users which classes are made available by the scores }

         Update_Class_Choices (Character);

       { Ask user if he/she wants to accept these rolls }

         SMG$Put_Chars (ScreenDisplay,
             'Keep these scores? (Y/N)',10,1);
         SMG$End_Display_Update (ScreenDisplay);
         If FirstTime then
            Begin
               SMG$End_Pasteboard_Update (Pasteboard);
               FirstTime:=False;
            End;
         Answer:=Yes_or_No;
         SMG$Erase_Line (ScreenDisplay,10,1);

       { If the answer is "yes" then we're done }

         If Answer='Y' then Satisfied:=True;
      End;
   Until Satisfied;
   SMG$Begin_Pasteboard_Update (Pasteboard);  { End in printcharacter }

 { Print the character }

   Print_Character (Party,Party_Size,Character,Leave_Maze,Automatic:=True)
End;  { Roll Scores }

{******************************************************************************)

[Global]Procedure Race_Adjustments (Var Character: Character_Type; Race: Race_Type);

{ This procedure will change CHARACTER's abilities according to what RACE he/she wishes to be }

Begin { Race Adjustments }
   If Race<>Character.Race then
      Case Race of
        Human:       ;
        HfOrc:       Begin
                         Change_Score(Character,1,1);
                         Change_Score(Character,5,1);
                         Change_Score(Character,6,-2);
                    End;
        Numenorean: Begin
                        Change_Score(Character,2,1);
                        Change_Score(Character,6,1);
                        Change_Score(Character,3,-2);
                    End;
        Dwarven:    Begin
                        Change_Score(Character,5,1);
                        Change_Score(Character,6,-1);
                    End;
        Drow:       Begin
                        Change_Score(Character,1,-2);
                        Change_Score(Character,2,1);
                        Change_Score(Character,4,1);
                    End;
        HfOgre:     Begin
                        Change_Score(Character,1,2);
                        Change_Score(Character,5,2);
                        Change_Score(Character,2,-2);
                        Change_Score(Character,6,-2);
                    End;
        Gnome:      Begin
                        Change_Score(Character,1,-1);
                        Change_Score(Character,5,1);
                    End;
        Hobbit:     Begin
                        Change_Score(Character,1,-1);
                        Change_Score(Character,4,1);
                    End;
        LizardMan:  Begin
                        Change_Score(Character,1,1);
                        Change_Score(Character,4,1);
                        Change_Score(Character,5,1);
                        Change_Score(Character,6,-3);
                    End;
        Centaur:    Begin
                        Change_Score(Character,1,1);
                        Change_Score(Character,5,1);
                        Change_Score(Character,4,-2);
                    End;
        Quickling:  Begin
                        Change_Score(Character,4,4);
                        Change_Score(Character,1,-2);
                        Change_Score(Character,5,-2);
                    End;
      End;
End;  { Race Adjustments }

{******************************************************************************)

Function Race_Choices (Var Character: Character_Type): Race_Set;

{ This function returns the set of all races CHARACTER can be with the class he/she is. }

Var
   Temp: Race_Set;

Begin { Race Choices }
  Temp:=[Human..Numenorean];
  Case Character.Class of
     NoClass: ;
     Cleric:           Temp:=Temp-[Numenorean];
     Fighter:          Temp:=Temp-[Numenorean,Drow];
     Paladin:          Temp:=Temp-[HfOrc,HfOgre,Gnome,Hobbit,Dwarven,HfElf,LizardMan,Centaur,Numenorean,Drow];
     Ranger:           Temp:=Temp-[HfOrc,HfOgre,Gnome,Hobbit,Dwarven,HfElf,LizardMan];
     Wizard:           Temp:=Temp-[LizardMan,Centaur,Numenorean];
     Thief:            Temp:=Temp-[Elven,LizardMan,Centaur,Numenorean];
     Assassin:         Temp:=Temp-[HfOrc,HfOgre,Gnome,Hobbit,Dwarven,Numenorean,Drow];
     Monk:             Temp:=Temp-[HfOrc,HfOgre,Gnome,Hobbit,Dwarven,Elven,HfElf,LizardMan,Centaur,Numenorean];
     AntiPaladin:      Temp:=Temp-[HfOrc,HfElf,Centaur,Human,Numenorean];
     Bard:             Temp:=[Elven,HfElf,Centaur,Human,Numenorean];
     Samurai:          Temp:=[Human,HfElf,Centaur];
     Ninja:            Temp:=[Human,HfElf,Drow];
     Barbarian:        Temp:=Temp-[Gnome,Hobbit,Dwarven,Elven,HfElf,Centaur,Numenorean];
  End;
  Race_Choices:=Temp;
End;  { Race Choices }

{******************************************************************************)

Procedure Choose_Race (Var Character: Character_Type);

{ This procedure allows the player to choose a race for CHARACTER }

Var
   Options:       Char_Set;
   Chosen,Choice_Loop:   Race_Type;
   Possibilities: Set of Race_Type;
   Choices:       Array [1..13] of Race_Type;
   Max_Num,Pos:   Integer;
   Answer:        Char;
   T:             Line;
   RaceName:      [External]Array [Race_Type] of Packed Array [1..12] of char;

Begin { Choose Race }
   Max_Num:=0;  Options:=[];  Pos:=1;  Choices:=Zero;

 { Get a set of all possible choices }

   Possibilities:=Race_Choices (Character);

 { Display the list of choices }

   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Set_Cursor_ABS (ScreenDisplay,,12);
   SMG$Put_Line (ScreenDisplay,
                 'Choose a Race: ');
   T:='';
   For Choice_Loop:=Human to Numenorean do
      If Choice_Loop in Possibilities then
         Begin
            Max_Num:=Max_Num+1;
            Options:=Options+[CHR(Max_Num+64)];
            Choices[Max_Num]:=Choice_Loop;
            T:=T+
                '     ['
                +CHR(Max_Num+64)
                +']'
                +'    '
                +Pad(RaceName[Choices[Max_Num]],' ',13);
                If Odd(pos) then
                   T:=T+'      '
                Else
                   Begin
                      SMG$Put_Line (ScreenDisplay,T);
                      T:='';
                   End;
                Pos:=Pos+1;
         End;
   SMG$Put_Line (ScreenDisplay,T,0);
   SMG$End_Display_Update (ScreenDisplay);

 { Get the player's choice }

   Answer:=Make_Choice (Options);
   Chosen:=Choices[Ord(Answer)-64];

 { Adjust the character's ability score because of race }

   Race_Adjustments (Character,Chosen);
   Character.Race:=Chosen;
   SMG$Begin_Pasteboard_Update (Pasteboard);  { End in print character }
   Print_Character (Party,Party_Size,Character,Leave_Maze,Automatic:=True);
End;  { Choose Race }

{******************************************************************************)

Procedure Sex_Effects (Var Character: Character_Type);

{ This procedure adds the effects of sex vs. race to CHARACTER }

Begin { Sex Effects }
   Case Character.Sex of
        Male:   Case Character.Race of
                   Drow:        Change_Score (Character,1,1);
                   Hobbit:      Change_Score (Character,3,1);
                   Human:       Change_Score (Character,1,1);
                   Elven:       Change_Score (Character,7,1);
                   LizardMan:   Change_Score (Character,4,1);
                   Numenorean:  Change_Score (Character,5,2);
                   Otherwise    Change_Score (Character,5,1);
                End;
        Female: Case Character.Race of
                   Drow:        Change_Score (Character,2,1);
                   Numenorean:  Change_Score (Character,6,2);
                   Hobbit:      Change_Score (Character,6,1);
                   Elven:       Change_Score (Character,6,1);
                   LizardMan:   Change_Score (Character,2,1);
                   Dwarven:     Change_Score (Character,3,1);
                   Otherwise    Change_Score (Character,4,1);
                End;
   End;
End;  { Sex Effects }

{******************************************************************************)

Procedure Choose_Sex (Var Character: Character_Type);

{ This procedure lets the player choose his or her CHARACTER's sex. }

Var
   Answer: Char;

Begin { Choose Sex }

 { Display list of choices }

   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay,14,1);
   SMG$Put_Chars (ScreenDisplay,
       'Choose thine sex: ',16,18);
   SMG$Put_Chars (ScreenDisplay,
       '[A]   Male',17,18);
   SMG$Put_Chars (ScreenDisplay,
       '[B]   Female',18,18);
   SMG$End_Display_Update (ScreenDisplay);

 { Handle the user's choice }

   Answer:=Make_Choice(['A'..'B']);
   Case Answer of
        'A': Character.Sex:=Male;
        'B': Character.Sex:=Female;
   End;

 { Plop on the advantages of the chosen sex }

   Sex_Effects (Character);

   SMG$Begin_Pasteboard_Update (Pasteboard);  { End in print character }
   Print_Character (Party,Party_Size,Character,Leave_Maze,Automatic:=True);
End;  { Choose Sex }

{******************************************************************************)

Procedure Choose_Class (Var Character: Character_Type);

{ This procedure allows the player to choose CHARACTER's class }

Var
   Options: Char_Set;
   Choice_Loop: Class_Type;
   Possibilities: Set of Class_Type;
   Choices:       Array [1..13] of Class_Type;
   Max_Num,Pos:   Integer;
   Answer:        Char;
   T:             Line;

Begin { Choose Class }
   Max_Num:=0;  Options:=[];  Pos:=1;  Choices:=Zero;

 { Get the classes for which CHARACTER is qualified }

   Possibilities:=Class_Choices (Character);

 { If CHARACTER can't be anything, let 'em be a fighter }

   If Possibilities=[] then Possibilities:=[Fighter];

 { Print the list of choices }

   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Set_Cursor_ABS (ScreenDisplay,,12);
   SMG$Put_Line (ScreenDisplay,
                 'Choose a class: ');
   T:='';
   For Choice_Loop:=Cleric to Barbarian do
      If Choice_Loop in Possibilities then
         Begin
            Max_Num:=Max_Num+1;
            Options:=Options+[CHR(Max_Num+64)];
            Choices[Max_Num]:=Choice_Loop;
            T:=T+
                '     ['
                +CHR(Max_Num+64)
                +']'
                +'    '
                +Pad(ClassName[Choices[Max_Num]],' ',13);
                If Odd(pos) then
                   T:=T+'      '
                Else
                   Begin
                      SMG$Put_Line (ScreenDisplay,T);
                      T:='';
                   End;
                Pos:=Pos+1;
         End;
   SMG$Put_Line (ScreenDisplay,T,0);
   SMG$End_Display_Update (ScreenDisplay);

 { Get the player's selection }

   Answer:=Make_Choice (Options);

 { Assign the selected class to CHARACTER }

   Character.Class:=Choices[Ord(Answer)-64];

   SMG$Begin_Pasteboard_Update (Pasteboard);  { End in print character }
   Print_Character (Party,Party_Size,Character,Leave_Maze,Automatic:=True);
End;  { Choose Class }

{******************************************************************************)

Function Alignment_Choices (Character: Character_Type): Align_Set;

{ This function returns the set of all alignments CHARACTER can be }

Var
   Temp: Align_Set;

Begin { Alignment Choices }
   Temp:=[Good,Neutral,Evil];
   Case Character.Class of
        Barbarian:   Temp:=[Neutral];
        AntiPaladin: Temp:=[Evil];
        Cleric:      Temp:=[Good,Evil];
        Paladin:     Temp:=[Good];
        Ranger:      Temp:=[Good];
        Thief,Ninja: Temp:=[Neutral,Evil];
        Assassin:    Temp:=[Evil];
   End;
   Case Character.Race of
        Numenorean: Alignment_Choices:=Temp*[Good,Neutral];
        Drow:       Alignment_Choices:=Temp*[Evil];
        Otherwise   Alignment_Choices:=Temp;
   End;
End;  { Alignment Choices }

{******************************************************************************)

Procedure Choose_Alignment (Var Character: Character_Type);

{ This procedure allows the player to choose an alignment for CHARACTER }

Var
   Options:  Char_Set;
   Choices:  Align_Set;
   Possibilities: Array [1..3] of Align_Type;
   Max_Num:  Integer;
   Lp: Align_Type;
   Answer:        Char;
   AlignName: [External]Array [Align_Type] of Packed Array [1..7] of char;

Begin
   Max_Num:=0;  Options:=[];  Choices:=Zero;

 { Get the alignments that CHARACTER is can be }

   Choices:=Alignment_Choices (Character);

 { Print the list of choices }

   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Set_Cursor_ABS (ScreenDisplay,,19);
   SMG$Put_Line (ScreenDisplay,
                 'Choose an alignment: ');
   For Lp:=Good to Evil do
      If Lp in Choices then
         Begin
            Max_Num:=Max_Num+1;
            Possibilities[Max_Num]:=Lp;
            Options:=Options+[CHR(Max_Num+64)];
            SMG$Set_Cursor_ABS (ScreenDisplay,,17);
            SMG$Put_Line (ScreenDisplay,
                '['
                +CHR(Max_Num+64)
                +']    '
                +AlignName[Possibilities[Max_Num]]);
         End;
   SMG$End_Display_Update (ScreenDisplay);

 { Get the player's selection }

   Answer:=Make_Choice (Options);

 { Assign it to CHARACTER }

   Character.Alignment:=Possibilities[Ord(Answer)-64];

   SMG$Begin_Pasteboard_Update (Pasteboard);  { End in print character }
   Print_Character (Party,Party_Size,Character,Leave_Maze,Automatic:=True);
End;  { Choose Alignment }

{******************************************************************************)

Function Character_Age (Race: Race_Type): [Volatile]Integer;

Begin
   Case Race of
     Human: Character_age:=17+Roll_Die(4);
     HfOrc: Character_age:=13+Roll_Die(4);
     Dwarven,Numenorean: Character_age:=40+(4*Roll_Die(20))+Roll_Die(20);
     Elven,Drow: Character_age:=100+(5*Roll_Die(6))+Roll_Die(6);
     HfOgre: Character_age:=12+Roll_Die(4);
     Gnome: Character_age:=60+(4*Roll_Die(4))+Roll_Die(4);
     Hobbit: Character_age:=100+Roll_Die(20);
     HfElf: Character_age:=22+Roll_Die(4)+Roll_Die(4)+Roll_Die(4);
     LizardMan: Character_age:=24+Roll_Die(5);
     Centaur: Character_age:=145+Roll_Die(5);
     Quickling: Character_age:=55+Roll_Die(3);
   End;
End;

{******************************************************************************)

Function Psionics_Chance (Character: Character_Type): Integer;

Var
   Intelligence,Wisdom,Charisma: Integer;

Begin
   Intelligence:=Character.Abilities[2]-15;  Wisdom:=Character.Abilities[3]-15;  Charisma:=Character.Abilities[6]-15;

   Psionics_Chance:=(2*Intelligence)+(2*Wisdom)+Charisma;
End;

{******************************************************************************)

Procedure Determine_Psionics (Var Character: Character_Type);

Begin
  Character.Psionics:=True;
  Character.DetectTrap   :=(3*Roll_Die(25))-3;
  Character.DetectSecret :=(3*Roll_Die(25))-3;
  Character.Regenerate:=Roll_Die(4)-1;
End;

{******************************************************************************)

Procedure Finish_Character (Var Character: Character_Type);

{ This procedure adds all the finishing touches to CHARACTER. }

[External]Function User_Name: Line; External;
[External]Function  Spells_Known (Class: Class_Type; Level: Integer): Spell_Set;external;
[External]Function  Compute_AC (Character: Character_Type; PosZ:  Integer:=0): Integer;external;

Begin { Finish Character }
   Character.Username:=Substr(User_Name,1,6);

 { Compute the character's age in days }

   Character.Age:=365 * Character_Age (Character.Race);

 { Character was in the young adult age bracket }

   Character.Age_Status:=YoungAdult;

 { No previous class }

   Character.Previous_Lvl:=0;
   Character.PreviousClass:=NoClass;

 { Character is first level, give him/her the appropriate hit points }

   Character.Level:=1;
   Character.Curr_HP:=Compute_Hit_Die(Character);
   Character.Max_HP:=Character.Curr_HP;

   Character.Status:=Healthy;
   Character.Gold:=(Roll_Die(6)*Roll_Die(100))+Roll_Die(2);  { Starts with 1-400 GP }
   Character.No_of_Items:=0;

 { Zero spell points }

   Character.SpellPoints:=Zero;

 { Give spell books to spell casters }

   Character.Wizard_Spells:=[];  Character.Cleric_Spells:=[];

   If Character.Class=Wizard then
      Character.Wizard_Spells:=Spells_Known(Character.Class,Character.Level)
   Else
      If Character.Class=Cleric then
         Character.Cleric_Spells:=Spells_Known(Character.Class,Character.Level);

 { Compute AC and regeneration }

   Character.Armor_Class:=Compute_AC (Character);
   Character.Regenerates:=Regenerates (Character);

 { Restore spell }

   Restore_Spells(Character);

   If Made_Roll (Psionics_Chance(Character)) then Determine_Psionics (Character);
   SMG$Begin_Pasteboard_Update (Pasteboard);  { End in print character }
   Print_Character (Party,Party_Size,Character,Leave_Maze,Automatic:=True);

End;  { Finish Character }

{******************************************************************************)

Function Room_in_Roster: [Volatile]Boolean;

{ This procedure returns TRUE if there is room in ROSTER for another character, or false otherwise }

Var Slot: Integer;

Begin { Room }
   For Slot:=1 to 20 do
      If Roster[Slot].Status=Deleted then
         Room_in_Roster:=True;
End;  { Room }

{******************************************************************************)

Procedure No_Room_in_Roster;

Begin
   SMG$Put_line (ScreenDisplay,
      'There is no room for new '
      +'characters now.  Delete '
      +'some old characters first.',
      0, 0);
   Delay (2);
End;

{******************************************************************************)

Procedure Create_Character (CharName: Name_Type);

{ This procedure will roll up a character with the name, CHARNAME, and store it in the roster, if there is room }

Var
   Answer: Char;
   TmpChr: Character_Type;

Begin { Create Character }

 { If there is room, we can make a character }

   If Room_in_Roster then
      Begin

       { Initialize the character }

         TmpChr:=Zero;
         TmpChr.Name:=CharName;

       { Paste the choices display }

         SMG$Begin_Pasteboard_Update (Pasteboard);  { end update is in roll scores }
         SMG$Paste_Virtual_Display (ClassChoiceDisplay,Pasteboard,2,50);

       { Roll Ability Scores }

         Roll_Scores (TmpChr);

       { Choose features of the character }

         SMG$Unpaste_Virtual_Display (ClassChoiceDisplay,Pasteboard);
         Choose_Class     (TmpChr);
         Choose_Race      (TmpChr);
         Choose_Sex       (TmpChr);
         Choose_Alignment (TmpChr);

       { Add all remaining details such as gold and hit points to character }

         Finish_Character (TmpChr);

       { Check to see if the player wants to keep the character }

         SMG$Put_Chars (ScreenDisplay,
             'Dost thou wish to keep this character?',
             22, 1);
         Answer:=Yes_or_No;

       { If he/she does, store it in the roster }

         If Answer='Y' then Store_Character (TmpChr);
      End
   Else
      No_Room_in_Roster;
End;  { Create Character }

{ TODO: Enter this code }
{******************************************************************************)

Procedure Print_Available_Characters;

{ This procedure will print a list of available characters when the question mark is entered at the ---> prompt. }

Begin { Print Available Characters }
   SMG$Begin_Display_Update (ScreenDisplay);
   Print_Roster;
   SMG$Put_Chars (ScreenDisplay,
       'Press any key',23,33,0,1);
   SMG$End_Display_Update (ScreenDisplay);
   Wait_Key
End;  { Print Available Characters }

{******************************************************************************)

Procedure New_Character (New_Name: Line);

{ This procedure is called when NEW_NAME is the name of a non-existent character.  It asks the player if he or she wants to make a
  character with that name, and if so, does it }

Var
   Answer: Char;

Begin { New Character }
   If New_Name.Length>20 then New_Name:=Substr (New_Name,1,20);
   SMG$Put_Line (ScreenDisplay, '');
   SMG$Put_Chars (ScreenDisplay,
       New_Name
       +': '
       +'that name doesn''t exist. Dost thou '
       +'wish to create it?',0);
   Answer:=Yes_or_No;
   SMG$Put_Chars (ScreenDisplay,'');
   If Answer='Y' then Create_Character (New_Name);
End;  { New Character }

{******************************************************************************)

Function Get_Name: [Volatile]Line;

{ This procedure will prompt for the name of a character, whether or not he/she exists }

Var
   NameTxt: Line;

[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;

Begin { Get Name }
  NameTxt:='';

  SMG$Begin_Display_Update (ScreenDisplay);
  SMG$Erase_Display (ScreenDisplay);
  SMG$Put_Line (ScreenDisplay,
      'Thou art at Cyntila''s Training Grounds.  Thou '
      +'cant enter the name of an exist-');
  SMG$Put_Line (ScreenDisplay,
      'ing character, or a non-existant character if '
      +'thou wishes to create one.  "?"');
  SMG$Put_Line(ScreenDisplay,
      'gives a list of existing characters.  [RETURN]'
      +' exits.');
  SMG$End_Display_Update (ScreenDisplay);

  Cursor;
  SMG$Read_String (Keyboard,NameTxt,Display_Id:=ScreenDisplay,
      Prompt_String:='--->');
  No_Cursor;

  Get_Name:=NameTxt;
End;  { Get Name }

{******************************************************************************)

Procedure Handle_Name (Var NameTxt: Line);

{ This procedure handes the name that was entered.  If it's a "?" it will display a roster of available characters.  If it is the
  name of an existing character, it will go to the Examine Character sub-menu, otherwise, it had to be the name of a new character,
  and it will be made }

Var
   Slot: Integer;

Begin { Handle Name }
   SMG$Set_Cursor_ABS (ScreenDisplay,6,1);
   If NameTxt='?' then
      Print_Available_Characters
   Else
      If NameTxt<>'' then
         If Character_Exists (NameTxt,Slot) then
            { TODO: Uncomment this Examine_Character (Slot) }
         Else
            New_Character (NameTxt);
End;  { Handle Name }

{******************************************************************************)

Procedure Initialize;

{ This procedure will initialize the Training Grounds module.  All that is done is the creation of labelling of the Class Choice
  Display, which is used for creation of characters }

Begin { Initialize }
  SMG$Create_Virtual_Display (13,11,ClassChoiceDisplay,1);
  SMG$Label_Border (ClassChoiceDisplay,
      ' Classes ',
      SMG$K_TOP)
End;  { Initialize }

{******************************************************************************)

[Global]Procedure Run_Training_Grounds;

{ In this module, a player can make up, view, delete, or otherwise change a character.  If the name entered below does not refer to
  an existing character, the player has the option to create a character with that name  }

Var
  NameTxt: Line;

[External]Function Can_Play: [Volatile]Boolean;External;

Begin { Run Training Grounds }
   Initialize;
   Repeat
      If Can_Play then
         Begin
            NameTxt:=Get_Name;
            Handle_Name (NameTxt);
         End
      Else
         NameTxt:='';
   Until NameTxt='';
   SMG$Delete_Virtual_Display (ClassChoiceDisplay);
   Location:=InKyrn;
End;  { Run Training Grounds }
End.  { Training Grounds }

[Inherit ('Types','SMGRTL','STRRTL')]Module TrainingGrounds;

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
   Rounds_Level:                        [External]Array [Spell_Name] of Unsigned;

Value
   Leave_Maze:=False;

{******************************************************************************)
[External]Function  Character_Exists (CharName: Name_Type; Var Spot: Integer):Boolean;external;
[External]Procedure Print_Roster;External;
[External]Function  Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): Char;External;
[External]Function  String (Num: Integer; Len: Integer:=0):Line;external;
[External]Function  Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function  Class_Choices (Character: Character_Type): Class_Set;external;
[External]Function  Yes_or_No (Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Update_High_Scores (Username: Line);external;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Procedure Print_Character (Var Party: Party_Type;  Party_Size: Integer;  Var Character: Character_Type;
                                     Var Leave_Maze: Boolean; Automatic: Boolean:=False);external;
[External]Procedure Change_Score (Var Character: Character_Type; Score_Num, Inc: Integer);External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  Compute_Hit_Die (Character: Character_Type): Integer;external;
[External]Function  Regenerates (Character: Character_Type);external;
[External]Procedure Restore_Spells (Var Character: Character_Type);external;
[External]Procedure Store_Character (Character: Character_Type);external;
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
        HfOrgre:    Begin
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
     Assassin:         Temp:=Temp-[HfOrc,HfOrgre,Gnome,Hobbit,Dwarven,Numenorean,Drow];
     Monk:             Temp:=Temp-[HfOrc,HfOrgre,Gnome,Hobbit,Dwarven,Elven,HfElf,LizardMan,Centaur,Numenorean];
     AntiPaladin:      Temp:=Temp-[HfOrc,HfElf,Centaur,Human,Numenorean];
     Bard:             Temp:=[Elven,HfElf,Centaur,Human,Numenorean];
     Samurai:          Temp:=[Human,HfElf,Centaur];
     Ninja:            Temp:=[Human,HfElf,Drow];
     Barbarian:        Temp:=Temp-[Gnome,Hobbit,Dwarven,Elven,HfElf,Centaur,Numenorean];
  End;
  Race_Choices:=Temp;
End;  { Race Choices }

{ TODO: Enter this code }

[Global]Procedure Run_Training_Grounds;

Begin { Run Training Grounds }

{ TODO: Enter this code }

End;  { Run Training Grounds }
End.  { Training Grounds }

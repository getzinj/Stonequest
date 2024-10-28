(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types','SMGRTL')]Module Kyrn;

Var
   Screendisplay,Pasteboard,TopDisplay,BottomDisplay:   [External]Unsigned;
   Location:                                            [External]Place_Type;
   Auto_Load,Auto_Save:                                 [External]Boolean;
   Roster:                                              [External]Roster_Type;
   PlaceName:                                           Array [Place_Type] of Line;

Value
   PlaceName[Church]          := 'Church of Devoted Healers';
   PlaceName[Tavern]          := 'Dor''s Goodwill Tavern';
   PlaceName[Inn]             := 'Adventurers'' Inn';
   PlaceName[TheMaze]         := 'The Maze';
   PlaceName[TrainingGrounds] := 'Cytila''s Training Grounds';
   PlaceName[InKyrn]          := 'Streets of Kyrn';
   PlaceName[TradingPost]     := 'Gisele''s Trading Post';
   PlaceName[Casino]          := 'Five Aces Casino';
   PlaceName[MainStreet]      := 'Picking Pockets';

Const
   Party_Heading = ' #  Character Name      '
       +'Level    Class            AC    Hits   Status';

   SMG$M_WRAP_CHAR = 1; { Just guessing because it's a bitmap }
   SMG$M_WRAP_WORD = 2; { Just guessing because it's a bitmap }

(******************************************************************************)
[External]Procedure Write_Roster(Roster: Roster_Type);External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Function Character_Exists (CharName: Name_Type; Var Spot: Integer):Boolean;external;
[External]Function Can_Play: [Volatile]Boolean;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Function Alive (Character: Character_Type): Boolean;External;
[External]Function String (Num: Integer; Len: Integer:=0): Line;External;
(******************************************************************************)

Function Character_Record_Exists (Name: Name_Type; Var Slot: Integer): Boolean;

{ This procedure returns TRUE if a record for NAME, deleted or otherwise, exists, and false otherwise }

Var
   Found_It,Last_Slot: Boolean;

Begin { Character Record Exists }
   Slot:=0;
   Found_It:=False;  Last_Slot:=False;
   Repeat
      Begin
         Slot:=Slot + 1;
         Last_Slot:=(Slot=20);
         Found_It:=(Roster[Slot].Name=Name);
      End;
   Until Found_It or Last_Slot;
   Character_Record_Exists:=Found_It;
End;  { Character Record Exists }

(******************************************************************************)

Procedure Put_Character_in_Slot (Character: Character_Type; Slot: Integer);

Begin { IF the character already exists in the roster }
   Roster[Slot]:=Character;  { Store an updated copy }
   Roster[Slot].Lock:=False; { And mark that the person is available }
End;  { If the character already exists in the roster }

(******************************************************************************)

[Global]Procedure Store_Character (Character: Character_Type);

{ This procedure will store CHARACTER in the roster }

Var
   Slot: Integer;
   Name: Line;

Begin  { Store Character }
   Name:=Character.Name;
   If Character_Exists (Name,Slot) then
      Put_Character_In_Slot (Character,Slot)
   Else
      If Character_Record_Exists (Name, Slot) then
         Put_Character_In_Slot (Character, Slot)
      Else
         Begin { If the character doesn't exist }

            { Search for an available slot and store the character there }

            Slot:=0;
            Repeat  Slot:=Slot + 1  Until Roster[Slot].Status=Deleted;
            Put_Character_In_Slot (Character,Slot);

         End    { If the character doesn't exists}
End;  { Store Character }

(******************************************************************************)

Procedure Store_Character_Without_Lock (Character: Character_Type);

{ This procedure will store CHARACTER in the roster }

Var
   Slot: Integer;
   Name: Line;

Begin  { Store Character without Lock }
   Name:=Character.Name;
   If Character_Exists (Name,Slot) then
      Roster[Slot]:=Character  { Store an updated copy }
   Else
      If Character_Record_Exists (Name, Slot) then
         Roster[Slot]:=Character
      Else
         Begin { If the character doesn't exist }

            { Search for an available slot and store the character there }

            Slot:=0;
            Repeat  Slot:=Slot + 1  Until Roster[Slot].Status=Deleted;
            Roster[Slot]:=Character;

         End;  { If the character doesn't exists }
  Roster[Slot].Lock:=True;
End;  { Store Character Without Lock }

(******************************************************************************)

[Global]Procedure Backup_Party (Party: Party_Type; Party_Size: Integer);

Var
   Character: Integer;

Begin { Backup Party }
  For Character:=1 to Party_Size do  Store_Character_Without_Lock (Party[Character]);
  Write_Roster (Roster);
End;  { Backup Party }

(******************************************************************************)

[Global]Procedure Save_Characters (Party: Party_Type;  Var Party_Size: Integer);

{ This procedure removes every member of the current party, and stores them back in the roster so that it can be saved at the end
  of play   }

Var
   Character: Integer;

Begin { Save Characters }
  If Party_Size<>0 then  { If there are any characters in the party }
     For Character:=1 to Party_Size do  { Store each one }
         Store_Character(Party[Character]);
  Party_Size:=0;          { Nobody left in the party }
End;  { Save Characters }

(******************************************************************************)

[Global]Procedure Print_Character_Line (CharNo: Integer; Party: Party_Type; Party_Size: Integer);

{ This procedure will print the statistics of the CHARNOth member of PARTY in the window, TopDisplay }

Var
   StatusName: [External]Array [Status_Type] of Varying [14] of char;
   ClassName:  [External]Array [Class_Type] of Varying [13] of char;
   AlignName:  [External]Array [Align_Type] of Packed Array [1..7] of char;

Begin
   SMG$Begin_Display_Update (TopDisplay);
   SMG$Put_Chars (TopDisplay, String(CharNo, 1), 3 + CharNo, 2, 1);
   If CharNo <= Party_Size then
      Begin { Slot is filled }
         SMG$Put_Chars (TopDisplay, '  ' + Pad(Party[CharNo].Name, ' ', 20));
         SMG$Put_Chars (TopDisplay, '  ' + String(Party[CharNo].Level, 3));
         SMG$Put_Chars (TopDisplay, '    ' + AlignName[Party[CharNo].Alignment][1]);
         SMG$Put_Chars (TopDisplay, '-' + Pad(ClassName[Party[CharNo].Class], ' ', 13));
         SMG$Put_Chars (TopDisplay, ' ' + String(Party[CharNo].Armor_Class, 3));
         SMG$Put_Chars (TopDisplay, '   ' + String(Party[CharNo].Curr_HP, 5));
         SMG$Put_Chars (TopDisplay, '     ');
         If Party[CharNo].Status <> Healthy then
            SMG$Put_Chars (TopDisplay, StatusName[Party[CharNo].Status])
         Else
            SMG$Put_Chars (TopDisplay, String(Party[CharNo].Max_HP, 5));
      End;
   SMG$End_Display_Update (TopDisplay);
End;

(******************************************************************************)

Procedure Update_Screen;

{ This procedure prints the current place at the top of the screen, and erases the bottom message display }

Var
  Indent: Integer;

Begin { Update Screen }
   Indent:=40-(PlaceName[Location].Length div 2);
   SMG$Put_Chars (TopDisplay,PlaceName[Location],1,Indent,1,1);
   SMG$Erase_Display (BottomDisplay);
End;  { Update Screen }

(******************************************************************************)
[External]Procedure Pick_Pockets (Var Party: Party_Type;  Party_Size: Integer);External;
[External]Procedure Run_Church (Var Party: Party_Type; Party_Size: Integer);External;
[External]Procedure Run_Trading_Post (Var Party: Party_Type; Party_Size: Integer);External;
[External]Procedure Run_Training_Grounds;External;
[External]Procedure Run_Inn (Var Party: Party_Type; Party_Size: Integer);External;
[External]Procedure Run_Tavern (Var Party: Party_Type; Var Party_Size: Integer);External;
[External]Procedure Enter_Maze (Party_Size: Integer; Var Member: Party_Type);External;
[External]Procedure Run_Casino (Var Party: Party_Type; Party_Size: Integer);External;
(******************************************************************************)

Function Where_to_Go: [Volatile]Place_Type;

Var
   Answer: Char;

Begin
   SMG$Begin_Display_Update (BottomDisplay);
   Location:=Leave;
   Update_Screen;
   SMG$Put_Line (BottomDisplay,'');
   SMG$Put_Line (BottomDisplay,'Art thou sure thou want to leave?');
   SMG$Put_Chars (BottomDisplay,'Y)es or N)o');
   SMG$End_Display_Update (BottomDisplay);
   Cursor; Answer:=Yes_or_No;  No_Cursor;
   If Answer='Y' then Where_to_Go:=Leave
   Else               Where_to_Go:=InKyrn;
End;

(******************************************************************************)

Procedure Print_Kyrn_Options (Party_Size: Integer);

Var
   T: Varying [390] of Char;

Begin
   SMG$Begin_Display_Update (BottomDisplay);
   SMG$Put_Line (BottomDisplay,'');
   SMG$Put_Line (BottomDisplay,'Thou art on Kyrn''s main street. ',2);
   T:='Thou canst go to the T)avern, ';
   If Party_Size>0 then
      Begin
         SMG$Put_Line (BottomDisplay,T
                       +'the Gambling H)all, the S)tore, '
                       +'the I)nn, the Training G)rounds, '
                       +'the M)aze, or the C)hurch. ', Wrap_Flag:=SMG$M_WRAP_WORD);
         SMG$Put_Line (BottomDisplay,'');
         SMG$Put_Line (BottomDisplay,'Thou may also attempt '
                       +'to P)ick pockets, or L)eave the game. ');
      End
   Else
      SMG$Put_Line (BottomDisplay,T
                    +'the Training G)rounds, or L)eave '
                    +'the game.',Wrap_Flag:=SMG$M_WRAP_WORD);
   SMG$End_Display_Update (BottomDisplay);
End;

(******************************************************************************)

Procedure Run_Kyrn (Party_Size: Integer);

{ This procedure will simulate Kyrn's main street.  From here the party can go:

                  Leave  Maze  Pick Pockets (main street)
                        \  |  /
                Tavern - Kyrn - Store
                        /    \
                  Church      Casino     }

Var
   Choices: Char_Set;
   Answer: Char;

Begin { Run Kyrn }

   { Print options }

   Print_Kyrn_Options (Party_Size);

   { Handle selections }

   Choices:=['G','L','T'];
   If Party_Size>0 then Choices:=Choices+['C','I','S','H','P','M'];
   Answer:=Make_Choice(Choices);
   Case Answer of
      'P': Location:=MainStreet;
      'H': Location:=Casino;
      'S': Location:=TradingPost;
      'C': Location:=Church;
      'T': Location:=Tavern;
      'I': Location:=Inn;
      'G': Location:=TrainingGrounds;
      'M': Location:=TheMaze;
      'L': If Can_Play then Location:=Where_to_Go
           Else             Location:=Leave;
   End  { Case }
End;  { Run Kyrn }

(******************************************************************************)

Procedure Update_Party (Var Party: Party_Type; Var Party_Size: Integer);

{ This procedure will update the party after returning from the maze.  Any dead characters will be removed from the party so that
  they can be brought back from the dead at the church }

Var
   Member,Person: Integer;

[External]Function User_Name:Line;External;
[External]Procedure Update_High_Scores (Username:Line);external;

Begin { Update Party }
   For Member:=Party_Size downto 1 do
      If Not Alive (Party[Member]) then
         Begin { Dead character }
            Store_Character (Party[Member]);  { remove from the party }
            If Party_Size>1 then
               For Person:=Member to Party_Size-1 do
                  Party[Person]:=Party[Person + 1];
            Party_Size:=Party_Size-1;  { The party is smaller now }
         End;

   { Print the current roster }

   For Member:=1 to 6 do  Print_Character_Line (Member,Party,Party_Size);
   Update_High_Scores (User_name);
End;  { Update Party }

(******************************************************************************)

Procedure Run_Maze (Var Party: Party_Type; Var Party_Size: Integer);

{ This procedure calls the maze simulation.  It updates all displays and writes the roster to disk to preserve the characters }

Begin { Run Maze }
   If Not Auto_Load then
      Begin
         SMG$Begin_Display_Update (TopDisplay);
         SMG$Begin_Display_Update (BottomDisplay);
         Update_Screen;
         SMG$Put_Chars (BottomDisplay,
                        'Entering the Dungeons of Barrat!',3,23,1,1);
         SMG$End_Display_Update (BottomDisplay);
         SMG$End_Display_Update (TopDisplay);

      { Preserve the characters before entering maze }

         Backup_Party (Party,Party_Size);
      End;

   Enter_Maze (Party_Size,Party);           { Run the maze simulation }

   If Not Auto_Save then  { If we're not saving the game }
      Begin { Not in Auto-Save }
         SMG$Begin_Display_Update (TopDisplay);
         Update_Party (Party,Party_Size);  { Update the roster }
         SMG$End_Display_Update (TopDisplay);
         Location:=InKyrn;
         Backup_Party (Party,Party_Size);  { Store updated version of characters }
      End;  { Not in Auto-Save }
End;  { Run Maze }

(******************************************************************************)

Procedure Go_Training_Grounds (Var Party: Party_Type;  Var Party_Size: Integer);

{ This procedure calls the training grounds routine.  It saves the current party back into the roster so that they can be changed.
  Then, afterwords, the roster is written to the disk so that changes will be saved, even if the game, or the system crashes.  }

Var
   Person: Integer;

Begin { Go Training Grounds }

   { Paste necessary display }

   SMG$Erase_Display (ScreenDisplay);
   Save_Characters (Party,Party_Size);
   SMG$Paste_Virtual_Display(ScreenDisplay,Pasteboard,1,1);

   { Save party and run training grounds }

   Run_Training_Grounds;

   { Save roster and update TopDisplay to indicate of characters }

   Write_Roster (Roster);
   For Person:=1 to 6 do  Print_Character_Line (Person,Party,Party_Size);

   { Remove the added display and erase it for future use }

   SMG$Erase_Display (BottomDisplay);
   SMG$Unpaste_Virtual_Display (ScreenDisplay,Pasteboard);
   SMG$Erase_Display (ScreenDisplay);
End;  { Go Training Grounds }

(******************************************************************************)

Procedure Location_Driver (Var Party: Party_Type; Var Party_Size: Integer);

{ This procedure handles all the locations.  It will branch to the appropriate subroutine depending on where the party is }

Begin { Location Driver }
  Repeat
       If Auto_Load then  { If we're in the middle of an auto-load... }
          Run_Maze (Party,Party_Size)  { ...go straight to the maze. }
       Else
          Begin { Not in an auto-load }

             { Update the positional information }

             SMG$Begin_Display_Update (TopDisplay);
             If Location<>TrainingGrounds then Update_Screen;
             SMG$End_Display_Update (TopDisplay);
             SMG$Home_Cursor (BottomDisplay);

             { Go to the appropriate subroutine }

             If Not Can_Play then Location:=Leave
             Else
                Case Location of
                       TradingPost: Run_Trading_Post (Party,Party_Size);
                            Church: Run_Church (Party,Party_Size);
                            Tavern: Run_Tavern (Party,Party_Size);
                            Casino: Run_Casino (Party,Party_Size);
                            InKyrn: Run_Kyrn (Party_Size);
                               Inn: Run_Inn (Party,Party_Size);
                           TheMaze: Run_Maze (Party,Party_Size);
                   TrainingGrounds: Go_Training_Grounds (Party,Party_Size);
                        MainStreet: Pick_Pockets (Party,Party_Size);
                End;
          End;  { Not in Auto-load }
  Until (Location=Leave) or Auto_Save;
End;  { Location Driver }

(******************************************************************************)

Procedure Initialize_Kyrn (Var Party: Party_Type; Var Party_Size: Integer);

{ This procedure initializes some module-local variables, and draws the screen.  Although, the procedure DRAW_SCREEN does much
  the same thing, it is done in this procedure so that the output may be batched. }

Var
   Loop: Integer;
   Saved_Game: Save_Record;

[External]Function Load_Saved_Game: [Volatile]Save_Record;External;
[External]Function Screen_Line (LineWidth: Integer:=80): Line;External;


Begin { Initialize Kyrn }
   Location:=InKyrn;  { The action starts out in Kyrn }
   Party_Size:=0;     { No party loaded yet }

   If Auto_Load then   { If we're in an auto-load... }
      Begin  { Auto-load }
         Saved_Game:=Load_Saved_Game;           { Get the saved information... }
         Party_Size:=Saved_Game.Party_Size;    { Load the party information... }
         Party:=Saved_Game.Characters;
         Location:=TheMaze;                   { ...and go straight to the maze }
      End;   { Auto-load }

   { Initialize the screen }

   SMG$Erase_Display (TopDisplay);
   Update_Screen;
   SMG$Put_Chars (TopDisplay,Screen_Line(78),2,1);
   SMG$Put_Chars (TopDisplay,Party_Heading,3,1);

   { Print the current roster, if any }

   SMG$Put_Chars (TopDisplay,Screen_Line(78),10,1);
   if Not Auto_Load then
      Begin
         For Loop:=1 to 6 do  Print_Character_Line (Loop,Party,Party_Size);
         SMG$Unpaste_Virtual_Display (ScreenDisplay,Pasteboard);
         SMG$Erase_Display (ScreenDisplay);
         SMG$End_Pasteboard_Update (Pasteboard);
      End;
End;  { Initialize Kyrn }

(******************************************************************************)

Procedure Quit (Party: Party_Type; Var Party_Size: Integer);

{ This procedure is called when the player elects to leave the game.  All it does is save off the party, if not in an auto-save,
  and unpastes the pasted displays }

Begin { Quit }
   If Not Auto_Save then Save_Characters (Party,Party_Size);
   SMG$Unpaste_Virtual_Display (TopDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (BottomDisplay,Pasteboard);
End;  { Quit }

(******************************************************************************)

[Global]Procedure Kyrn;

{ This procedure simulates the town Kyrn; the center of events in Stonequest.  From here, players can make, edit, and delete
  characters, heal them, buy things for them, and go into the maze. }

Var
   Party_Size: Integer;
   Party: Party_Type;

Begin { Kyrn }
   Initialize_Kyrn (Party,Party_Size);
   Location_Driver (Party,Party_Size);
   Quit            (Party,Party_Size)
End;  { Kyrn }
End.  { Kyrn }

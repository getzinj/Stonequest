[Inherit ('Types','SYS$LIBRARY:STARLET','LIBRTL','SMGRTL')]Module Tavern;

Const
   ZeroOrd=Ord('0');

Type
   Party_File_Type      = File of Name_Type;

Var
   Roster:                                          [External]Roster_Type;
   RosterDisplay:                                   Unsigned;
   Pasteboard,BottomDisplay,Keyboard,ScreenDisplay: [External]Unsigned;
   PartyFile:                                       [External]Party_File_Type;
   StatusName:                                      [External]Array [Status_Type] of Varying [14] of char;
   ClassName:                                       [External]Array [Class_Type] of Varying [13] of char;
   AlignName:                                       [External]Array [Align_Type] of Packed Array [1..7] of char;
   Location:                                        [External]Place_Type;
   Rounds_Left:                                     [External]Array [Spell_Name] of Unsigned;
   Maze:                                            [External]Level;
   PosX,PosY,PosZ:                                  [External,Byte]0..20;

(******************************************************************************)
[External]Procedure No_ControlY;External;
[External]Procedure ControlY;External;
[External]Procedure Error_Window (FileType: Line);External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Function Make_Choice (Choices: Char_Set;  Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '):Char;External;
[External]Function Pick_Character_Number (Party_Size: Integer;  Current_Party_Size: Integer:=0;
                                       Time_Out: Integer:=-1;
    Time_Out_Char: Char:='0'): [Volatile]Integer;External;
[External]Function Can_Play: [Volatile]Boolean;External;
[External]Procedure Print_Character (Var Party: Party_Type;  Party_Size: Integer;  Var Character: Character_Type;
                                     Var Leave_Maze: Boolean; Automatic: Boolean:=False);external;
[External]Function  Character_Exists (CharName: Name_Type; Var Spot: Integer):Boolean;external;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Function  Compute_AC (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Print_Character_Line (CharNo: Integer; Party: Party_Type; Party_Size: Integer);External;
[External]Procedure Store_Character (Var Character: Character_Type);External;
[External]Procedure Backup_Party (Party: Party_Type;  Party_Size: Integer);External;
(******************************************************************************)

Function Party_Compatable (Character: Character_Type; Party: Party_Type;  Party_Size: Integer): Boolean;

{ This function returns TRUE if CHARACTER is of an appropriate alignment to joing PARTY, and FALSE otherwise }

Var
   Member: Integer;
   Alignment: Align_Type;

Begin { Party Compatable }

   { Copy the character's alignment }

   Alignment:=Character.Alignment;

   { If nobody's in the party, of course he/she can join }

   Party_Compatable:=True;  { Let's assume compatable for the moment... }
   If Party_Size<>0 then
      For Member:=1 to Party_Size do
         If ABS(ORD(Party[Member].Alignment)-ORD(Alignment))>1 then Party_Compatable:=False;
End;  { Party Compatable }

(******************************************************************************)

Procedure Show_Available_Character (Character: Character_Type; Party: Party_Type; Party_Size: Integer);

Begin
   If (Character.Status<>Deleted) and (Character.Lock<>True) and Party_Compatable(Character,Party,Party_Size) then
         Begin
            SMG$Put_Chars (RosterDisplay,
                '   '
                +Pad(Character.Name,' ',20));
            SMG$Put_Chars (RosterDisplay,
                ' '
                +AlignName[Character.Alignment][1]
                +'-');
            SMG$Put_Chars (RosterDisplay,
                Pad(ClassName[Character.Class],' ',13));
            SMG$Put_Chars (RosterDisplay,
                '   '
                +String(Character.Level,3));
            SMG$Put_Chars (RosterDisplay,
                '       '
                +StatusName[Character.Status]);
         End;
End;

(******************************************************************************)

Procedure Print_Avail (Party: Party_Type; Party_Size: Integer);

{ This procedure prints the stats for any character that can join PARTY from ROSTER }

Var
   Character: Integer;

Begin { Print Avail }

   { Initialize display }

   SMG$Erase_Display (RosterDisplay);
   SMG$Label_Border (RosterDisplay,
       ' Available Characters ',
       SMG$K_TOP);
   SMG$Put_Line (RosterDisplay, '   Name       '
       +'          Class '
       +'           Level '
       +'     Status');

   { For each character in roster, print the stats if he or she can join }

   For Character:=1 to 20 do Show_Available_Character (Roster[Character],Party,Party_Size);
End;  { Print Avail }

(******************************************************************************)

Procedure Print_Available_Characters (Party: Party_Type;  Party_Size: Integer);

{ This procedure will print a list of available and compatable characters }

Begin { Print Available Characters }

   { Print the characters to the display }

   Print_Avail (Party, Party_Size);

   { Prompt for a keypress }

   SMG$Put_Chars (RosterDisplay,
       'Press any key to continue',
       21,28,,1);

   { stuff }

   SMG$Paste_Virtual_Display (RosterDisplay,Pasteboard,2,2);
   SMG$Put_Chars (BottomDisplay,
      ' ',7,5);

   { Wait for a key, then unpaste the display }

   Wait_Key;

   SMG$Unpaste_Virtual_Display (RosterDisplay,Pasteboard);
End;  { Print Available Characters }

(******************************************************************************)

Procedure Add_Character (Var Character: Character_Type; Var Party: Party_Type;  Var Party_Size: Integer);

{ This procedure will add CHARACTER to PARTY }

Begin { Add Character }
   Character.Armor_Class:=Compute_AC (Character);
   Party_Size:=Party_Size+1;                               { Increase the party size }
   Party[Party_Size]:=Character;                           { Add the character }
   Character.Lock:=True;                                   { Lock out further copies of this character }
   Print_Character_Line (Party_Size,Party,Party_Size);     { Print the new line }
End;  { Add Character }

(******************************************************************************)

Procedure Incompatable_Alignments;

Begin { incompatable alignments }
  SMG$Put_Line (BottomDisplay,
      '* * * Alignments are not compatable!! * * *',
      0);
  Delay (2);
End;  { incompatable alignments }

(******************************************************************************)

Procedure Character_Is_Out;

Begin { Character is Out }
  SMG$Put_Line (BottomDisplay,
      '* * * That character is out * * *',
      0);
  Delay (2);
End;  { Character is Out }

(******************************************************************************)

Procedure Never_Heard_of_Him;

Begin { Never Heard of Him }
  SMG$Put_Line (BottomDisplay,
      '* * * Who? * * *',
      0);
  Delay (2);
End;  { Never Heard of Him }

(******************************************************************************)

Procedure Too_Many_Characters;

Begin { Too Many Characters }
  SMG$Put_Line (BottomDisplay,
      '* * * Thou already has six characters!!! * * *',
      0);
  Delay (2);
End;  { Too Many Characters }

(******************************************************************************)

Function In_Party (Character: Character_Type; Party: Party_Type; Party_Size: Integer): Boolean;

Var
  InParty: Boolean;
  N: Integer;

Begin
  InParty:=False;
  If Party_Size > 0 then
     For N:=1 to Party_Size do
        InParty:=InParty or (Character.Name=Party[n].Name);
  In_Party:=InParty;
End;

(******************************************************************************)

Procedure Already_in_Party;

Begin { Already in Party }
  SMG$Put_Line (BottomDisplay,
      '* * * That character is already in thine party!!! * * *',
      0);
  Delay (2);
End;  { Already in Party }

(******************************************************************************)

Procedure Try_to_add_Character (Var Character: Character_Type;  Var Party: Party_Type;  Var Party_Size: Integer);

Begin
   If Not Character.Lock then
      If Party_Compatable (Character,Party,Party_Size) then
         Add_Character (Character,Party,Party_Size)
      Else
         Incompatable_Alignments
   Else
      If In_Party (Character,Party,Party_Size) then
         Already_in_Party
      Else
         Character_Is_Out
End;

(******************************************************************************)

Procedure Attempt_to_Add_Character (Var Party: Party_Type; Var Party_Size: Integer);

{ This procedure will allow the player to add a character.  If he/she types a question mark, a list will be shown.  Incompatable
  and non-existant character names will be dealt with with an error message.  Return alone exits }

Var
  New_Name: Line;
  FoundNo: Integer;

Begin { Attempt to add Character }
   Repeat
      Begin
         SMG$Set_Cursor_ABS (BottomDisplay,6,1);
         SMG$Put_Line (BottomDisplay,
             'Whom dost thou wish to add?  (? for list)');
         Cursor;
         SMG$Read_String (Keyboard,
             New_Name,
             Display_Id:=BottomDisplay,
             Prompt_string:='--->');
         No_Cursor;

         If New_Name.length>20 then New_Name:=SubStr(New_Name,1,20);

         { If it's a question mark, print list }

         If New_Name='?' then
            Print_Available_Characters (Party,Party_Size)
         Else
            If Character_Exists (New_Name,FoundNo) then
               Try_to_add_Character (Roster[FoundNo],Party,Party_Size)
            Else
               If New_Name<>'' then Never_Heard_of_Him;
      End;
   Until New_Name<>'?'  { Repeat until a load is attempted }
End;  { Attempt to add Character }

(******************************************************************************)

Procedure Add_Member (Var Party: Party_Type; Var Party_Size: Integer);

{ This procedure allows the player to add a character to the PARTY }

Begin { Add Member }
   If Party_Size<6 then  { If there's room in the party }
      Attempt_to_Add_Character (Party,Party_Size)
   Else
      Too_Many_Characters;  { Otherwise, complain a bit... }
   SMG$Erase_Display (BottomDisplay);
End;  { Add Member }

(******************************************************************************)

Procedure Remove_Member (Var Party: Party_Type;  Var Party_Size: Integer);

{ This procedure allows a player to remove a member from the adventuring party }

Var
  Number,Loop: Integer;
  Temp: Character_Type;

Begin { Remove Member }

   { Prompt for character's number }

   SMG$Begin_Display_Update (BottomDisplay);
   SMG$Erase_Display (BottomDisplay);
   SMG$Set_Cursor_ABS (BottomDisplay,2,1);
   SMG$Put_Line (BottomDisplay,
       'Remove which character (1-'
       +String(Party_Size)
       +')?');
   SMG$Put_Line (BottomDisplay,
       '([RETURN] exits)  --->',
       0);

   { Get it }

   Number:=Pick_Character_Number (Party_Size);

   { If it's a valid number, remove that character }

   If Number>0 then
      Begin
         Temp:=Party[Number];
         If Number<>Party_Size then
            For Loop:=Number to Party_Size-1 do
               Party[Loop]:=Party[Loop+1];
         Party_Size:=Party_Size-1;
         Store_Character(Temp);
        { Backup_Party (Party,Party_Size); }
         For Loop:=Number to Party_Size+1 do Print_Character_Line(Loop,Party,Party_Size);

         { Return the character to the roster }
      End;
End;  { Remove Character }

(******************************************************************************)

Procedure View_Character (Var Party: Party_Type; Var Party_Size: Integer;  Character_Num: Integer);

{ This procedure allows a player to view his or her character.  This procedure simply calls PRINT_CHARACTER, after making some
  preparations }

Var
  Dummy: Boolean;

Begin { View Character }
   Dummy:=False;
   SMG$Begin_Pasteboard_Update (Pasteboard);

   { End_Pasteboard_Update will be in Print_Character }

   SMG$Paste_Virtual_Display (ScreenDisplay,Pasteboard,1,1);
   Print_Character (Party,Party_Size,Party[Character_Num],
       Leave_Maze:=Dummy,
       Automatic:=False);

   Print_Character_Line (Character_Num,Party,Party_Size);

   SMG$Erase_Display (BottomDisplay);
   SMG$Unpaste_Virtual_Display (ScreenDisplay,Pasteboard);
   SMG$Erase_Display (ScreenDisplay);
End;  { View Character }

(******************************************************************************)

Procedure Print_Options (Var T: Line; InText: Line);

{ This procedure is used to print a variable nuymber of options sequentially.  If the text to be printed exceeds the line, T, it
  'flushes' the output by printing T, and then set t to be the new input }

Begin { Print Options }
  If T.Length+inText.Length>80 then
     Begin
        SMG$Put_Line (BottomDisplay, T);
        T:='';
     End;
  T:=T+InText;
End;  { Print Options }

(******************************************************************************)

Procedure Load_Party (Var Party: Party_Type; Var Party_Size: Integer);

{ This procedure loads a party from the file STONE_PARTY.DAT }

Var
   TempName: Line;
   Loaded: Boolean;
   Position: Integer;

Begin { Load Party }
   Party_Size:=0;  Loaded:=False;

   { Open file }

   Open (PartyFile,
       'SYS$LOGIN:Stone_Party.Dat',History:=OLD,error:=Continue);

   { If it exists... }

   If Status(PartyFile)=PAS$K_SUCCESS then
      Begin

         { Open it }

         Reset (PartyFile,Error:=Continue);

         { And while there are names... }

         While Not EOF(PartyFile) do
            Begin

               { Read a name and add him/her to the party }

               Read (PartyFile,TempName);
               If Character_Exists (TempName,Position) then           { if it exists }
                  If Party_Compatable (Roster[Position],Party,Party_Size) then       { and compatable }
                     If Not Roster[Position].Lock then  { If the character's not out }
                        Begin { All conditions met }
                           Add_Character (Roster[Position],Party,Party_Size);
                           Loaded:=True;    { Yes, we have loaded at least one }
                        End;    { All conditions met }
            End;
         Close (PartyFile); { Close the open file }
      End;
   If Loaded then  { if we loaded at least one character... }
      SMG$Put_Chars (BottomDisplay,
          '* * * Loaded * * *',12,31)
   Else
      SMG$Put_Chars (BottomDisplay,
         '* * * No party loaded * * *',
         12, 26);
   Delay (1);
End;  { Load Party }

(******************************************************************************)

Procedure Save_Party (Party: Party_Type; Party_Size: Integer);

{ This procedure saves the current party to the disk file STONE_PARTY.DAT }

Var
   Character: Integer;
   Error: Boolean;

Begin { Save Party }
   Error:=False;

   { Open the save file }

   No_ControlY;
   Open (PartyFile,'SYS$LOGIN:Stone_Party.dat',History:=UNKNOWN,Error:=Continue);
   Error:=(Status(PartyFile)<>PAS$K_SUCCESS);

   Rewrite (PartyFile,Error:=Continue);
   Error:=Error or ((Status(PartyFile)<>PAS$K_SUCCESS) and (Status(PartyFile)<>PAS$K_EOF));

   { Write the character's name }

   For Character:=1 to Party_Size do
      Begin
         Write (PartyFile,Party[Character].Name,Error:=Continue);
         Error:=Error or ((Status(PartyFile)<>PAS$K_SUCCESS) and (Status(PartyFile)<>PAS$K_EOF));
      End;

   { Close the file and indicate success }

   Close (PartyFile,Error:=Continue);
   Error:=Error or ((Status(PartyFile)<>PAS$K_SUCCESS) and (Status(PartyFile)<>PAS$K_EOF));
   ControlY;

   If Not Error then
      SMG$Put_Chars (BottomDisplay,
          '* * * The party roster (but '
          +'not the characters themselves) '
          +'has been Saved * * *',
          12,1)
   Else
      Error_Window ('Party');
End;  { Save Party }

(******************************************************************************)

Procedure Print_Choices (Var Choices: Char_Set; Party_Size: Integer);

{ This procedure prints out the available options at the tarven, and stores the valid key-choices in the set CHOICES }

Var
   T: Line;

Begin { Print Choices }
   SMG$Begin_Display_Update (BottomDisplay);
   SMG$Erase_Display (BottomDisplay);
   SMG$Set_Cursor_ABS (BottomDisplay,2,1);
   SMG$Put_Line (BottomDisplay,
       'Welcome to the tavern of '
       +'the Archmage, Dor!',2);
   Choices:=['L','?'];
   T:='Thou canst: ';
   If Party_Size<6 then  { If there's room for more... }
      Begin
         Print_Options (T,
            'A)dd a member, ');
            Choices:=Choices+['A'];
      End;
   If Party_Size=0 then  { If no characters have been added yet... }
      Begin
         Print_Options (T,
            'load P)arty, ');
            Choices:=Choices+['P'];
      End;
   If Party_Size>0 then  { If there are characters in the party... }
      Begin
         Print_Options (T,
            'R)emove a member, ');
         Print_Options (T,
            '#)inspect a member, ');
         Print_Options (T,
            'S)ave party,, ');
         Choices:=Choices+['R','S'];
         Choices:=Choices+['1'..CHR(Party_Size+ZeroOrd)];
      End;
   Print_Options (T,
       'L)eave, or "?" for help');
   SMG$Put_Line (BottomDisplay,T);
   SMG$End_Display_Update (BottomDisplay);
End;  { Print Choices }

(******************************************************************************)

Procedure Print_Help;

Var
   HelpMeDisplay: Unsigned;

Begin
   SMG$Create_Virtual_Display (22,78,HelpMeDisplay,1);
   SMG$Erase_Display (HelpMeDisplay);
   SMG$Put_Line (HelpMeDisplay,
       'Options:');
   SMG$Put_Line (HelpMeDisplay,
       ' 1-6    = This option allows '
       +'you to access your character '
       +'sheet, and');
   SMG$Put_Line (HelpMeDisplay,
       '          perform such options'
       +' as putting on or taking off '
       +'equipment,');
   SMG$Put_Line (HelpMeDisplay,
       '          trading items, and '
       +'reading spellbooks.');
   SMG$Put_Line (HelpMeDisplay,
       ' Add    = Allows you to add a'
       +' previously created character'
       +' to the current');
   SMG$Put_Line (HelpMeDisplay,
       '          party.');
   SMG$Put_Line (HelpMeDisplay,
       ' Remove = Allows you to remove '
       +'a previously A)dded character');
   SMG$Put_Line (HelpMeDisplay,
       ' Save   = Allows you to save a '
       +'default party. Subsequent L)oads'
       +' will then');
   SMG$Put_Line (HelpMeDisplay,
       '          load the current party.  '
       +'Note that this doesn''t back up '
       +'the char-');
   SMG$Put_Line (HelpMeDisplay,
       '          acter file, it only '
       +'keeps track of who''s in the '
       +'default party.');
   SMG$Put_Line (HelpMeDisplay,
       ' Leave  = Allows you to leave '
       +'the tavern and go to the main '
       +'streets of Kyrn',10);
   SMG$Put_Line (HelpMeDisplay,
      'Press any key to continue...');
   SMG$Paste_Virtual_Display (HelpMeDisplay,Pasteboard,2,2);
   Wait_Key;
   SMG$Unpaste_Virtual_Display (HelpMeDisplay,Pasteboard);
   SMG$Delete_Virtual_Display (HelpMeDisplay);
End;

(******************************************************************************)

[Global]Procedure Run_Tavern (Var Party: Party_Type; Var Party_Size: Integer);

Var
   Choices:  Char_Set;
   Answer: Char;

{ This procedure runs the Tavern simulation.  In it a player can add, remove, or inspect members of the current adventuring party.
  ROSTERDISPLAY is a locally used virtual display used to print out the available characters.  It is created at the beginning of
  the procedure, and deleted at the end. }

Begin { Run Tavern }

  { Create the display to print the roster }

  SMG$Create_Virtual_Display (22,78,RosterDisplay,1);

  { Repeat until the player says leave the tavern }

  Repeat
     Begin
        Print_Choices (Choices,Party_Size);  { Print out the available options }
        If Not Can_Play then Answer:='L'
        Else                 Answer:=Make_Choice (Choices);
        Case Answer of
           '1'..'6': View_Character (Party,Party_Size,Ord(Answer)-ZeroOrd);    { Examine character }
                'A': Add_Member (Party,Party_Size);                            { Add a character to the party }
                'R': Remove_Member (Party,Party_Size);                         { Remove a character }
                'P': Load_Party (Party,Party_Size);                            { Load a saved party }
                'S': Save_Party (Party,Party_Size);                            { Save a party }
                '?': Print_Help;                                               { Print a help screen }
                'L':  ;                                                        { Leave the Tavern }
        End;
     End;
  Until Answer='L';
  Location:=InKyrn;  { Indicate that we are returning to Kyrn }
  SMG$Delete_Virtual_Display (RosterDisplay);  { Delete the created display }
End;  { Run Tavern }
End.  { Tavern }

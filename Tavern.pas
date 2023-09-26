[Inherit ('Types','LIBRTL','SMGRTL')]Module Tavern;

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
[External]Procedure Print_Character_Line (CharNo: Integer; Party: Party_Type; Party_Size: Integer):External;
[External]Procedure Store_Character (Character: Character_Type);External;
[External]Procedure Backup_Party (Party: Party_Type;  Party_Size: Integer);External;
(******************************************************************************)

{ TODO: Enter this code }

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
                'S': Save_Party (Party,Party_Size }                            { Save a party }
                '?': Print_Help;                                               { Print a help screen }
                'L'L  ;                                                        { Leave the Tavern }
        End;
     End;
  Until Answer='L';
  Location:=InKyrn;  { Indicate that we are returning to Kyrn }
  SMG$Delete_Virtual_Display (RosterDisplay);  { Delete the created display }
End.  { Tavern }

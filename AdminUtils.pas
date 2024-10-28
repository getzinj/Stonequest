(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit('TYPES', 'SYS$LIBRARY:STARLET','LIBRTL','SMGRTL','STRRTL')]
Module AdminUtils;

Const
   Owner_Account = 'SYSTEM';

Var
   DataModified:           [External]Boolean;
   Logging:                [External]Boolean;
   ScenarioDisplay:        [External]Unsigned;
   ScreenDisplay:          [External]Unsigned;
   Pasteboard:             [External]Unsigned;
   LogFile:                [External]Packed file of Line;

{**********************************************************************************************************************************}
[External]Function User_Name: Line;External;
[External]Procedure Player_Utilities(Var Pasteboard: Unsigned);External;
[External]Function Make_Choice (Choices: Char_Set;  Time_Out:  Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Clear_Log_File;External;
{**********************************************************************************************************************************}

Procedure Clear_Log;

{ This procedure clears the log file }

Begin { Clear Log }
   Clear_Log_File;

   { Notify user that log has been cleared }

   SMG$Put_Chars (ScreenDisplay,'* * * User-log Cleared * * *',23,22);
   Delay(1);
End;  { Clear Log }


[External]Function View_log_File (ScenarioDisplay: Unsigned): Boolean;External;
{**********************************************************************************************************************************}

Procedure View_log;

{ This procedure allows the user to view the log }

Var
   FirstTime: Boolean;

Begin { View Log }
   FirstTime := View_Log_File (ScenarioDisplay);
   If FirstTime then
      SMG$Paste_Virtual_Display (ScenarioDisplay,Pasteboard,2, 2);
   Wait_Key;
   SMG$Unpaste_Virtual_Display (ScenarioDisplay,Pasteboard);
End;  { View Log }

{**********************************************************************************************************************************}

Procedure Handle_Key (Var Exit: Boolean;              Var Pics: Pic_List;                   Var MazeFile: LevelFile;
                      Var Roster: Roster_Type;        Var Treasure: List_of_Treasures);

{ This procedure gets and handles a key and runs the selected utility }

Var
   Key_Stroke: Char;
   Choices: Char_Set;

[External]Procedure Pic_Edit (Var Pics: Pic_List);external;
[External]Procedure Edit_Maze (Var MazeFile: LevelFile);external;
[External]Procedure Edit_Players_Character;external;
[External]Procedure Edit_Treasures(Var Treasure: List_of_Treasures);external;
[External]Procedure Edit_Monster;external;
[External]Procedure Edit_Item;external;
[External]Procedure Edit_Character (Var Roster: Roster_Type);external;
[External]Procedure Edit_messages;external;
[External]Procedure Clear_High_Scores;external;

Begin { Handle Key }
    Choices:=['U','H','A','V','T','S','M','I','E','C','F','P','L'];
    If User_Name<>Owner_Account then Choices:=['F','E'];
    Key_Stroke:=Make_Choice (Choices);
    Case Key_Stroke of
         'H': Begin
               Clear_High_Scores;
               SMG$Put_Chars (ScreenDisplay,
                   '* * * Scores Cleared * * *',23,22);
               Delay (1);
              End;
         'L': If Logging then Clear_Log;
         'V': If Logging then View_Log;
         'U': Player_Utilities (Pasteboard);
         'P': Pic_Edit (Pics);
         'F': Begin
               SMG$Put_Chars (ScreenDisplay,
                   '* * * Loading Maze Editor * * *',23,22);
               Edit_Maze  (MazeFile);
              End;
         'C': Edit_Character (Roster);
         'T': Edit_Treasures (Treasure);
         'S': Begin
                 SMG$Put_Chars (ScreenDisplay,
                     '* * * Loading Message Editor * * *',23,22);
                 Edit_Messages;
              End;
         'M': Begin
                 SMG$Put_Chars (ScreenDisplay,
                     '* * * Loading Monster Editor * * *',23,22);
                 Edit_Monster;
              End;
         'I': Edit_Item;
         'A': Edit_Players_Character;
         'E': Exit:=True;
         Otherwise ;
    End;
End;  { Handle Key }

{**********************************************************************************************************************************}

[Global]Procedure Utilities (Var Pics: Pic_List;  Var MazeFile: LevelFile;  Var Roster: Roster_Type;
                     Var Treasure: List_of_Treasures);

{ This procedure runs the main utility menu }

Var
   Done: Boolean;

Begin { Utilities }
   DataModified:=True;
   Repeat
        Begin
           Done:=False;
           SMG$Begin_Display_Update (ScreenDisplay);
           SMG$Erase_Display (ScreenDisplay);
           SMG$Put_Chars (ScreenDisplay,'Utilities Main Menu',5,28,,1);
           SMG$Put_Chars (ScreenDisplay,'-------- ---- ----',6,28,,1);
           SMG$Put_Chars (ScreenDisplay,' A)lter player''s characters',7,28);
           SMG$Put_Chars (ScreenDisplay,' C)haracter edit',8,28);
           SMG$Put_Chars (ScreenDisplay,' F)loorplan edit',9,28);
           SMG$Put_Chars (ScreenDisplay,' H)igh Score Clear',10,28);
           SMG$Put_Chars (ScreenDisplay,' I)tem edit',11,28);
           SMG$Put_Chars (ScreenDisplay,' M)onster edit',12,28);
           SMG$Put_Chars (ScreenDisplay,' P)icture edit',13,28);
           SMG$Put_Chars (ScreenDisplay,' S)cenario message edit',14,28);
           SMG$Put_Chars (ScreenDisplay,' T)reasure edit',15,28);
           SMG$Put_Chars (ScreenDisplay,' V)iew Userlog',16,28);
           SMG$Put_Chars (ScreenDisplay,' L)og clear',17,28);
           SMG$Put_Chars (ScreenDisplay,' E)xit',19,28);
           SMG$Put_Chars (ScreenDisplay,' U)tilities (player)',18,28);
           SMG$Put_Chars (ScreenDisplay,' Which?',20,28);
           SMG$End_Display_Update (ScreenDisplay);
           Handle_Key (Done,Pics,MazeFile,Roster,Treasure);
        End;
   Until Done
End;  { Utilities }
End.  { AdminUtils }

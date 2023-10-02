[Inherit ('Types','SMGRTL','LibRtl')]Module Files;

Var
   MazeFile:                    [External]LevelFile;


(******************************************************************************)

[Global]Function Read_Level_from_Maze_File(Var fileVar: LevelFile; filename: Line): Level;

Var
  returnValue: Level;

Begin
  Open (fileVar,File_Name:=filename,History:=READONLY,Error:=CONTINUE,Sharing:=READONLY);
  If (Status(fileVar) = 0) then
     Begin { successful read }
        Reset (fileVar);
        Read (fileVar,returnValue);
        Close (fileVar);
        Read_Level_from_Maze_File:=returnValue;
     End { successful read }
  Else
     Begin { failed to read; create a new one }
         Open (fileVar,file_name:=filename,History:=NEW,Error:=CONTINUE,Sharing:=READONLY);
         If (Status(fileVar) = 0) then
            Begin
               returnValue:=Zero;
               ReWrite(fileVar,error:=Continue);
               Write (fileVar,returnValue);
               Close (fileVar);
               Read_Level_from_Maze_File:=returnValue;
            End { TODO: Handle failure case }
         Else
            Begin
               Read_Level_from_Maze_File:=Zero;
            End;
     End; { failed to read; create a new one }
End;


(******************************************************************************)

[Global]Procedure Save_Level_to_Maze_File(Var fileVar: LevelFile; filename: Line; Floor: Level);

Begin
    Open (MazeFile,
         file_name:=filename,
         History:=OLD);
    ReWrite (MazeFile);
    Write (MazeFile,Floor);
    Close (MazeFile);
End;
End.

[Inherit ('Types','SMGRTL','LibRtl','STRRTL')]Module Files;

Var
   MazeFile:                   [External]LevelFile;
   TreasFile:                  [External]Treas_File;
   Char_File:                  [External]Character_File;              { Character records }
   Item_File:                  [External]Equip_File;                  { Item records }
   Monster_File:               [External]Monst_File;                  { Monster records }
   PicFile:                    [External]Picture_File_Type;           { Pictures }
   Message_File:               [External]Text;                        { Game text }
   SaveFile:                   [External]Save_File_Type;
   AmountFile:                 [External]Number_File;

[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;


{**********************************************************************************************************************}

[Global]Procedure Save_Messages (Messages: Message_Group);

{ This procedure saves the messages to the disk }

Const
  Filename = 'Messages.dat;1';

Var
   Loop: Integer;

Begin { Save Messages }
   Open (Message_File,
         file_name:=Filename,
         History:=OLD,
         Sharing:=READONLY);
   Rewrite (Message_File);
   For Loop:=1 to 999 do
     Begin
        Writeln (Message_File,Messages[Loop]);
     End;
   Close (Message_File);
End;  { Save Messages }

{**********************************************************************************************************************}

[Global]Procedure Save_Pictures(Pics: Pic_List);

{ This procedure will write an updated set of pictures if the user is authorized to do so. }

Const
  Filename = 'Pictures.Dat;1';

Var
   Loop: Integer;

Begin { Save Pictures }
   Open (PicFile,
         file_name:=Filename,
         History:=OLD,
         Sharing:=READONLY);
   ReWrite (PicFile);
   For Loop:=1 to 150 do
      Begin
         Write (PicFile,Pics[Loop]);
      End;
   Close (PicFile);
End;  { Save Pictures }

{**********************************************************************************************************************}

[Global]Procedure Save_Items(Item_List: List_of_Items);

{ This procedure will save the updated item records if the current user is authorized to do so. }

Const
  Filename = 'Items.Dat;1';

Var
   Loop: Integer;

Begin { Save Items }
   Open (Item_File,
         file_name:=Filename,
         History:=OLD,
         Sharing:=READONLY);
   ReWrite (Item_File);
   For Loop:=0 to 449 do
      Begin
         Write (Item_File,Item_List[Loop]);
      End;
   Close (Item_File);
End;  { Save Items }

{**********************************************************************************************************************************}

[Global]Procedure Save_Monsters (Monster: List_of_monsters);

{ This procedure will save the updates monster records if the current user is authorized to do so. }

Const
  Filename = 'Monsters.Dat;1';

Var
   Loop: Integer;

Begin { Save Monsters }
   Open (Monster_File,
         file_name:=Filename,
         History:=OLD,
         Sharing:=READONLY);
   ReWrite (Monster_File,Error:=Continue);
   For Loop:=1 to 450 do
      Begin
         Write (Monster_File,Monster[Loop]);
      End;
   Close (Monster_File);
End;  { Save Monsters }

{**********************************************************************************************************************************}

[Global]Procedure Save_Treasure(Treasure: List_of_Treasures);

{ This procedure will save the updated treasure list if the current user is authorized to do so. }

Const
  Filename = 'Treasure.Dat;1';

Var
   Loop: Integer;

Begin { Save Treasure }
    Open (TreasFile,
         file_name:=Filename,
         History:=OLD);
   ReWrite (TreasFile);
   For Loop:=1 to 150 do
      Begin
         Write (TreasFile,Treasure[Loop]);
      End;
   Close (TreasFile);
End;  { Save_Treasure }

{**********************************************************************************************************************************}

[Global]Function Read_Treasures: List_of_Treasures;

{ This procedure will read in the treasure types }

Const
  Filename = 'Treasure.Dat;1';

Var
   Loop: Integer;
   returnValue: List_of_Treasures;

Begin { Read Treasures }
  returnValue:=Zero;

  Open (TreasFile,File_Name:=Filename,History:=READONLY,Error:=CONTINUE,Sharing:=READONLY);
  If (Status(TreasFile) = 0) then
     Begin { successful read }
         Reset (TreasFile,Error:=Continue);
         For Loop:=1 to 150 do
            Begin
               Read (TreasFile,returnValue[Loop]);
            End;
         Close (TreasFile);
         Read_Treasures:=returnValue;
     End { successful read }
  Else
     Begin { failed to read; create a new one }
        Open (TreasFile,file_name:=Filename,History:=NEW,Error:=CONTINUE,Sharing:=READONLY);
        If (Status(TreasFile) = 0) then
           Begin
              For Loop:=1 to 150 do
                 Begin
                    returnValue[Loop]:=Zero;
                 End;
              Close (TreasFile);
              Save_Treasure (returnValue);
              Read_Treasures:=returnValue;
           End
        Else
           Begin
              Read_Treasures:=Zero;
           End;
     End;
End;  { Read Treasures }

(******************************************************************************)

[Global]Function Read_Monsters: List_of_monsters;

{ This procedure will read in the monsters from the file into the array, MONSTERS }

Const
  Filename = 'Monsters.dat;1';

Var
   Max_Monsters: Integer;
   returnValue: List_of_monsters;

Begin { Read Monsters }
   returnValue:=Zero;

   Open (Monster_File,
         file_name:=Filename,
         History:=READONLY,
         Error:=CONTINUE,
         Sharing:=READWRITE);
  If (Status(Monster_File) = 0) then
     Begin { successful read }
         Reset (Monster_File,Error:=Continue);
         For Max_Monsters:=1 to 450 do
            Begin
               Read (Monster_File,returnValue[Max_Monsters]);
            End;
         Close (Monster_File);
         Read_Monsters:=returnValue;
     End { successful read }
  Else
     Begin { failed to read; create a new one }
        Open (Monster_File,
              file_name:=Filename,
              History:=NEW,
              Error:=CONTINUE,
              Sharing:=READONLY);
        If (Status(Monster_File) = 0) then
           Begin
              For Max_Monsters:=1 to 450 do
                 Begin
                    returnValue[Max_Monsters]:=Zero;
                 End;
              Close (Monster_File);
              Save_Monsters (returnValue);
              Read_Monsters:=returnValue;
           End
        Else
           Begin
              Read_Monsters:=Zero;
           End;
     End;
End;  { Read_Monsters }

(******************************************************************************)

[Global]Function Read_Items: List_of_Items;

{ This procedure will read in the items from the file, and then randomly adjust their prices to simulate increasing and decreasing
  values of items in a market place. }

Const
  Filename = 'Items.dat;1';

Var
   Flux: Real;  { Some times you just have to say, "what's the flux?" }
   Max_Items: Integer;
   returnValue: List_of_Items;

Begin { Read Items }
   returnValue:=Zero;

   Open (Item_File,
         file_name:=Filename,
         History:=READONLY,
         Error:=CONTINUE,
         Sharing:=READWRITE);

  If (Status(Item_File) = 0) then
     Begin { successful read }
         Reset (PicFile,Error:=Continue);

         Max_Items:=-1;  { So far, no items read }
         While Not EOF(Item_File) do
            Begin { More data }

               { Increase counter and read item }

               Max_Items:=Max_Items+1;
               Read (Item_File,returnValue[Max_Items]);
               STR$TRIM (returnValue[Max_Items].Name,returnValue[Max_Items].Name);
               STR$TRIM (returnValue[Max_Items].True_Name,returnValue[Max_Items].True_Name);

               { Calculate the price fluctuation, FLUX }

               Flux:=returnValue[Max_Items].Gp_Value;
               Flux:=Flux * Roll_Die(10) / 100;
               If Roll_Die(2)=2 then Flux:=Flux*(-1);

               { Add flux to the current price }

               returnValue[Max_Items].Current_Value:=Round(returnValue[Max_Items].GP_Value+Flux);

               { Making sure items aren't given away... }

               If returnValue[Max_Items].Current_Value<1 then returnValue[Max_Items].Current_Value:=1;
            End;  { More Data }
         Close (Item_File);
         Save_Items (returnValue);
         Read_Items:=returnValue;
     End { successful read }
  Else
     Begin { failed to read; create a new one }
        Open (Item_File,
              file_name:=Filename,
              History:=NEW,
              Error:=CONTINUE,
              Sharing:=READONLY);
        If (Status(Item_File) = 0) then
           Begin
              For Max_Items:=1 to 449 do
                 Begin
                    returnValue[Max_Items]:=Zero;
                 End;
              Close (Item_File);
              Save_Items (returnValue);
              Read_Items:=returnValue;
           End
        Else
           Begin
              Read_Items:=Zero;
           End;
     End;
End;  { Read Items }


(******************************************************************************)

[Global]Function Get_Store_Quantity(slot: Integer): Integer;

Begin
    Open(AmountFile,
       file_name:='STORE.DAT;1',History:=Unknown,
       Access_Method:=DIRECT,Sharing:=READWRITE);

    Find(AmountFile,slot+1);
    Get_Store_Quantity:=AmountFile^;

    Close(AmountFile);
End;

(******************************************************************************)

[Global]Procedure Write_Store_Quantity(slot: Integer; amount: Integer);

Begin
    Open(AmountFile,
        file_name:='STORE.DAT;1',History:=Unknown,
        Access_Method:=DIRECT,Sharing:=READWRITE);

    Find(AmountFile,slot+1);

    AmountFile^:=amount;
    Update(AmountFile);

    Close(AmountFile);
End;

(******************************************************************************)

[Global]Function Read_Pictures: Pic_List;

Const
  Filename = 'Pictures.Dat;1';

Var
   Loop: Integer;
   returnValue: Pic_List;

Begin { Read Pictures }
   returnValue:=Zero;

   Open (PicFile,
         file_name:=Filename,
         History:=READONLY,
         Error:=CONTINUE,
         Sharing:=READWRITE);
  If (Status(PicFile) = 0) then
     Begin { successful read }
         Reset (PicFile,Error:=Continue);
         Loop:=0;
         While (Loop<=150) and Not EOF(PicFile) do
            Begin
               Read(PicFile,returnValue[Loop]);
               Loop:=Loop+1;
            End;
         Close (PicFile);
         Read_Pictures:=returnValue;
     End { successful read }
  Else
     Begin { failed to read; create a new one }
        Open (PicFile,
              file_name:=Filename,
              History:=NEW,
              Error:=CONTINUE,
              Sharing:=READONLY);
        If (Status(PicFile) = 0) then
           Begin
              For Loop:=1 to 150 do
                 Begin
                    returnValue[Loop]:=Zero;
                 End;
              Close (PicFile);
              Save_Pictures (returnValue);
              Read_Pictures:=returnValue;
           End
        Else
           Begin
              Read_Pictures:=Zero;
           End;
     End;
End;

(******************************************************************************)

[Global]Function Read_Messages: Message_Group;

{ This procedure reads in the text from the message file }

Const
  Filename = 'Messages.dat;1';

Var
   Loop: Integer;
   returnValue: Message_Group;

Begin { Read Messages }
   returnValue:=Zero;

   Open (Message_File,
         file_name:=Filename,
         History:=READONLY,
         Error:=CONTINUE,
         Sharing:=READWRITE);
  If (Status(Message_File) = 0) then
     Begin { successful read }
         Reset (Message_File,Error:=Continue);
         For Loop:=1 to 999 do
            Begin
                 Readln (Message_File,returnValue[Loop],Error:=Continue);
                 If Not ((Status(Message_File)=PAS$K_SUCCESS) or (Status(Message_File)=PAS$K_EOF)) then
                    Begin
                       returnValue[Loop]:='';
                    End;
            End;
         Close (Message_File);
         Read_Messages:=returnValue;
     End { successful read }
  Else
     Begin { failed to read; create a new one }
        Open (Message_File,
              file_name:=Filename,
              History:=NEW,
              Error:=CONTINUE,
              Sharing:=READONLY);
        If (Status(Message_File) = 0) then
           Begin
              For Loop:=1 to 999 do
                 Begin
                    returnValue[Loop]:=Zero;
                 End;
              Close (Message_File);
              Save_Messages (returnValue);
              Read_Messages:=returnValue;
           End
        Else
           Begin
              Read_Messages:=Zero;
           End;
     End;
End;  { Read Messages }

{**********************************************************************************************************************************}

[Global]Procedure Write_Roster (Roster: Roster_Type);

{ This procedure is used to write the current roster to the character file }

Const
  Filename = 'SYS$LOGIN:Character.Dat;1';

Var
   Loop: Integer;
   Error: Boolean;

Begin { Write Roster }
    Open (Char_File,
         file_name:=filename,
         History:=OLD);
    ReWrite (Char_File);
    For Loop:=1 to 20 do
        Begin
           Write (Char_File,Roster[Loop]);
        End;
    Close (Char_File);
End;  { Write Roster }

{**********************************************************************************************************************************}

[Global]Function Read_Roster: Roster_Type;

Const
  Filename = 'SYS$LOGIN:Character.Dat;1';

Var
   Loop: Integer;
   Roster: Roster_Type;

Begin { Read Roster }
  Roster:=Zero;

  Open (Char_File,File_Name:=Filename,History:=READONLY,Error:=CONTINUE,Sharing:=READONLY);
  If (Status(Char_File) = 0) then
     Begin { successful read }
         Reset (Char_File,Error:=Continue);
         For Loop:=1 to 20 do
            Begin
               Read (Char_File,Roster[Loop]);
            End;
         Close (Char_File);
         Read_Roster:=Roster;
     End
  Else
     Begin { failed to read; create a new one }
        Open (Char_File,file_name:=Filename,History:=NEW,Error:=CONTINUE,Sharing:=READONLY);
        If (Status(Char_File) = 0) then
           Begin
              ReWrite (Char_File);

              For Loop:=1 to 20 do
                Begin
                  Roster[Loop].Status:=Deleted;
                  Write (Char_File,Roster[Loop]);
                End;

              Close (Char_File);

              Read_Roster:=Roster;
           End
        Else
           Begin
              Read_Roster:=Zero;
           End
     End;
End;  { Read Roster }

(******************************************************************************)

[Global]Function Get_Maze_File_Name (levelCharacter: Char): Line;

Begin
  Get_Maze_File_Name:='MAZE'
      +levelCharacter
      +'.DAT;1'
End;

(******************************************************************************)

Function createEmptyLevel(levelNumber: Integer): Level;

Var
  returnValue: Level;
  x,y: 1..20;
  encounterIndex: 1..3;
  specialNumber: 0..15;

Begin
  returnValue:=Zero;
  returnValue.Level_Number:=levelNumber;

  for x:=1 to 20 do
    for y:=1 to 20 do
       begin
         returnValue.Room[x][y].North:=Passage;
         returnValue.Room[x][y].South:=Passage;
         returnValue.Room[x][y].East:=Passage;
         returnValue.Room[x][y].West:=Passage;
         returnValue.Room[x][y].Contents:=0;
         returnValue.Room[x][y].Kind:=Corridor;
       end;

  for encounterIndex:=1 to 3 do
     Begin
       returnValue.Monsters[encounterIndex].Base_Monster_Number:=0;
       returnValue.Monsters[encounterIndex].Addition.X:=0;
       returnValue.Monsters[encounterIndex].Addition.Y:=0;
       returnValue.Monsters[encounterIndex].Addition.Z:=0;
       returnValue.Monsters[encounterIndex].Probability:=0;
     End;

  for specialNumber:=0 to 15 do
    Begin
      returnValue.Special_Table[specialNumber].Pointer1:=0;
      returnValue.Special_Table[specialNumber].Pointer2:=0;
      returnValue.Special_Table[specialNumber].Pointer3:=0;
      returnValue.Special_Table[specialNumber].Special:=Nothing;
    End;

  createEmptyLevel:=returnValue;
End;

(******************************************************************************)

[Global]Function Read_Level_from_Maze_File(Var fileVar: LevelFile; levelNumber: Integer): Level;

Var
  returnValue: Level;
  filename: Line;

Begin
  filename:=Get_Maze_File_Name(CHR(levelNumber + 64));
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
               returnValue:=createEmptyLevel(levelNumber);
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

[Global]Procedure Create_Null_SaveFile;

Const
  Filename = 'SYS$LOGIN:STONE_SAVE.DAT;1';

Begin
   Open (SaveFile,file_name:=filename,History:=Unknown);
   ReWrite (SaveFile);
   Close (SaveFile);
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

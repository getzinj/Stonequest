(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Ranges','Types','SMGRTL','LibRtl','STRRTL')]Module Files;

Const
  Items_Filename = 'Items.dat;1';
  Log_Filename = 'Stone_Data:Stone_Log.dat;1';
  Messages_Filename = 'Messages.dat;1';
  Monsters_Filename = 'Monsters.Dat;1';
  Treasure_Filename = 'Treasure.Dat;1';

Var
   ScoresFile:                 [External]Score_File;
   MazeFile:                   [External]LevelFile;
   TreasFile:                  [External]Treas_File;
   Char_File:                  [External]Character_File;              { Character records }
   Item_File:                  [External]Equip_File;                  { Item records }
   Monster_File:               [External]Monst_File;                  { Monster records }
   PicFile:                    [External]Picture_File_Type;           { Pictures }
   Message_File:               [External]Text;                        { Game text }
   SaveFile:                   [External]Save_File_Type;
   AmountFile:                 [External]Number_File;
   LogFile:                    [External]Packed file of Line;

[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;


(**********************************************************************************************************************)
(******************************************************** LOG *********************************************************)
(**********************************************************************************************************************)

[Global]Procedure Clear_Log_File;


Begin
   { Open the file }

   Repeat
      Open (LogFile, Log_Filename, History:=Unknown, Sharing:=READONLY, Error:=CONTINUE);
   Until (Status(LogFile)=PAS$K_SUCCESS);

   { Rewrite it }

   Rewrite (LogFile, Error:=Continue);
   Write (LogFile, '',Error:=Continue);
   Close (LogFile ,Error:=Continue);
End;

(**********************************************************************************************************************)

[Global]Function View_log_File (ScenarioDisplay: Unsigned; Pasteboard: Unsigned): boolean;

{ This procedure allows the user to view the log }

Const
   Length=20;                     { Maximum number of lines allowed }

Var
   FirstTime: Boolean;
   LineCount: Integer;
   L: Line;
   Rendition: Unsigned;  { Rendition set for line }

[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;

Begin { View Log File }

   { Open the file }

   Repeat
      Open (LogFile, Log_Filename, History:=UNKNOWN, Sharing:=Readwrite, Error:=CONTINUE)
   Until (Status(LogFile)=PAS$K_SUCCESS);
   Reset (LogFile);
   FirstTime:=True;

   LineCount:=0;
   SMG$Erase_Display (ScenarioDisplay);
   SMG$Begin_Display_Update (ScenarioDisplay);
   SMG$Erase_Display (ScenarioDisplay);
   SMG$Home_Cursor (ScenarioDisplay);

   { While there are still names on the list }

   While Not EOF (LogFile) do
      Begin

         { Read a name and print it }

         Read (LogFile, L, Error:=Continue);
         SMG$Put_Line (ScenarioDisplay, L);
         LineCount:=LineCount + 1;
         If LineCount=Length then
            Begin
                LineCount:=0;
                Rendition:=1;  L:='Press a key for more';
                SMG$Set_Cursor_ABS (ScenarioDisplay, 22, 39 - (L.Length div 2));
                SMG$Put_Line (ScenarioDisplay, L, 0, Rendition);
                SMG$End_Display_Update (ScenarioDisplay);
                If FirstTime then
                    SMG$Paste_Virtual_Display (ScenarioDisplay, Pasteboard, 2, 2);
                FirstTime:=False;
                Wait_Key;
                SMG$Begin_Display_Update (ScenarioDisplay);
                SMG$Erase_Display (ScenarioDisplay);
            End;
      End;
   L:='Press a key to continue';
   SMG$Put_Chars (ScenarioDisplay, L, 22, 39 - (L.Length div 2), 1, 1);

   Close (LogFile, Error:=Continue);

   View_Log_File := FirstTime;
End;  { View Log File }

(**********************************************************************************************************************)
(**************************************************** MESSAGES ********************************************************)
(**********************************************************************************************************************)

Function Create_New_Messages_File: Message_Group;

Var
   Loop: Integer;
   returnValue: Message_Group;

 Begin { failed to read; create a new one }
    returnValue:=Zero;
    For Loop:=MIN_MESSAGE_NUMBER to MAX_MESSAGE_NUMBER do
        returnValue[Loop]:='';

    Open (Message_File, file_name:=Messages_Filename, History:=NEW);
    Rewrite (Message_File);
    For Loop:=MIN_MESSAGE_NUMBER to MAX_MESSAGE_NUMBER do
       Writeln (Message_File, returnValue[Loop]);
    Close (Message_File);

    Create_New_Messages_File:=returnValue;
 End;

(******************************************************************************)

[Global]Function Read_Messages: Message_Group;

{ This procedure reads in the text from the message file }

Var
   Loop: Integer;
   returnValue: Message_Group;

Begin { Read Messages }
   returnValue:=Zero;

   Open (Message_File, file_name:=Messages_Filename, History:=READONLY, Error:=CONTINUE, Sharing:=READWRITE);
   If (Status(Message_File) = 0) then
      Begin { successful read }
          Reset (Message_File);
          For Loop:=MIN_MESSAGE_NUMBER to MAX_MESSAGE_NUMBER do
             Begin
                  Readln (Message_File, returnValue[Loop],Error:=Continue);
                  If Not ((Status(Message_File)=PAS$K_SUCCESS) or (Status(Message_File)=PAS$K_EOF)) then
                     Begin
                        returnValue[Loop]:='';
                     End;
             End;
          Close (Message_File);
          Read_Messages:=returnValue;
      End { successful read }
   Else
      Read_Messages:=Create_New_Messages_File;
End;  { Read Messages }

{**********************************************************************************************************************}

[Global]Procedure Save_Messages (Messages: Message_Group);

{ This procedure saves the messages to the disk }

Var
   Loop: Integer;

Begin { Save Messages }
   Open (Message_File, file_name:=Messages_Filename, History:=Unknown, Sharing:=READONLY);
   { TODO: Error handling }
   Rewrite (Message_File);
   For Loop:=MIN_MESSAGE_NUMBER to MAX_MESSAGE_NUMBER do
        Writeln (Message_File, Messages[Loop]);
   Close (Message_File);
End;  { Save Messages }

(**********************************************************************************************************************)
(**************************************************** MONSTERS ********************************************************)
(**********************************************************************************************************************)

[Global]Procedure Save_Monsters (Monster: List_of_monsters);

{ This procedure will save the updates monster records if the current user is authorized to do so. }

Var
   Loop: Integer;

Begin { Save Monsters }
   Open (Monster_File, file_name:=Monsters_Filename, History:=OLD, Sharing:=READONLY); { TODO: Error handling }
   ReWrite (Monster_File);

   For Loop:=MIN_MONSTER_NUMBER to MAX_MONSTER_NUMBER do
         Write (Monster_File, Monster[Loop]);

   Close (Monster_File);
End;  { Save Monsters }

{**********************************************************************************************************************************}

Function Create_New_Monster_file: List_of_monsters;

Var
   Loop: Integer;
   returnValue: List_of_monsters;

Begin
    returnValue:=Zero;
    For Loop:=MIN_MONSTER_NUMBER to MAX_MONSTER_NUMBER do
        returnValue[Loop]:=Zero;

    Open (Monster_File, file_name:=Monsters_Filename, History:=NEW, Sharing:=READONLY);
    ReWrite (Monster_File);

    For Loop:=MIN_MONSTER_NUMBER to MAX_MONSTER_NUMBER do
          Write (Monster_File, returnValue[Loop]);

    Close (Monster_File);

    Create_New_Monster_file:=returnValue;
End;

(******************************************************************************)

[Global]Function Read_Monsters: List_of_monsters;

{ This procedure will read in the monsters from the file into the array, MONSTERS }

Var
   Max_Monsters: Integer;
   returnValue: List_of_monsters;

Begin { Read Monsters }
   returnValue:=Zero;

   Open (Monster_File, file_name:=Monsters_Filename, History:=READONLY, Error:=CONTINUE, Sharing:=READWRITE);
   If (Status(Monster_File) = 0) then
     Begin { successful read }
         Reset (Monster_File);

         For Max_Monsters:=MIN_MONSTER_NUMBER to MAX_MONSTER_NUMBER do
             Read (Monster_File, returnValue[Max_Monsters]);

         Close (Monster_File);

         Read_Monsters:=returnValue;
     End { successful read }
   Else
     Read_Monsters:=Create_New_Monster_file;
End;  { Read_Monsters }

{**********************************************************************************************************************************}

[Global]Function Get_Monster (Monster_Number: Integer): Monster_Record;

{ This function returns the Monster_Number'th monster from the
  Monster_File. }

Begin { Get Monster }
   Open (Monster_File, Monsters_Filename, History:=READONLY, Access_Method:=DIRECT, Sharing:=READWRITE, Error:=CONTINUE);
   If (Status(Monster_File) = 0) then
     Begin
       Find (Monster_File, Monster_Number);
       Get_Monster:=Monster_File^;
       Unlock (Monster_File);
       Close (Monster_File);
     End
   Else
     Get_Monster:=Create_New_Monster_file[Monster_Number];
End;  { Get Monster }

(**********************************************************************************************************************)
(**************************************************** TREASURE ********************************************************)
(**********************************************************************************************************************)

[Global]Procedure Save_Treasure(Treasure: List_of_Treasures);

{ This procedure will save the updated treasure list if the current user is authorized to do so. }

Var
   Loop: Integer;

Begin { Save Treasure }
   Open (TreasFile, file_name:=Treasure_Filename, History:=OLD); { TODO: Error handling }
   ReWrite (TreasFile);

   For Loop:=MIN_TREASURE_NUMBER to MAX_TREASURE_NUMBER do
       Write (TreasFile, Treasure[Loop]);

   Close (TreasFile);
End;  { Save_Treasure }

{**********************************************************************************************************************************}

Function Create_New_Treasure_File: List_of_Treasures;

Var
   Loop: Integer;
   returnValue: List_of_Treasures;

Begin
    returnValue:=Zero;
    For Loop:=MIN_TREASURE_NUMBER to MAX_TREASURE_NUMBER do
        Begin
           returnValue[Loop]:=Zero;
        End;

    Open (TreasFile, file_name:=Treasure_Filename, History:=NEW);
    ReWrite (TreasFile);

    For Loop:=MIN_TREASURE_NUMBER to MAX_TREASURE_NUMBER do
          Write (TreasFile, returnValue[Loop]);

    Close (TreasFile);

    Create_New_Treasure_File:=returnValue;
End;

{**********************************************************************************************************************************}

[Global]Function Read_Treasures: List_of_Treasures;

{ This procedure will read in the treasure types }

Var
   Loop: Integer;
   returnValue: List_of_Treasures;

Begin { Read Treasures }
  returnValue:=Zero;

  Open (TreasFile, File_Name:=Treasure_Filename, History:=READONLY, Error:=CONTINUE, Sharing:=READONLY);
  If (Status(TreasFile) = 0) then
     Begin { successful read }
         Reset (TreasFile);
         For Loop:=MIN_TREASURE_NUMBER to MAX_TREASURE_NUMBER do
             Read (TreasFile, returnValue[Loop]);
         Close (TreasFile);

         Read_Treasures:=returnValue;
     End { successful read }
  Else
     Read_Treasures:=Create_New_Treasure_File;
End;  { Read Treasures }

(**********************************************************************************************************************)
(****************************************************** ITEMS *********************************************************)
(**********************************************************************************************************************)

[Global]Procedure Save_Items(Item_List: List_of_Items);

{ This procedure will save the updated item records if the current user is authorized to do so. }

Var
   Loop: Integer;

Begin { Save Items }
   Open (Item_File, file_name:=Items_Filename, History:=UNKNOWN, Sharing:=READONLY);
   ReWrite (Item_File);
   For Loop:=MIN_ITEM_NUMBER to MAX_ITEM_NUMBER do
      Begin
         Item_List[Loop].Item_Number := Loop;
         Write (Item_File, Item_List[Loop]);
      End;
   Close (Item_File);
End;  { Save Items }

(******************************************************************************)

Function Create_New_Items_File: List_of_Items;

Var
   Loop: Integer;
   returnValue: List_of_Items;

Begin
   returnValue:=Zero;
   For Loop:=MIN_ITEM_NUMBER to MAX_ITEM_NUMBER do
      Begin
         returnValue[Loop]:=Zero;
         returnValue[Loop].Item_Number := Loop;
      End;

    Open (Item_File, file_name:=Items_Filename, History:=NEW, Organization:=SEQUENTIAL, Access_Method:=SEQUENTIAL);
    ReWrite (Item_File);

    For Loop:=MIN_ITEM_NUMBER to MAX_ITEM_NUMBER do
       Write (Item_File, returnValue[Loop]);

    Close (Item_File);

    Create_New_Items_File:=returnValue;
End;

(******************************************************************************)

[Global]Function Read_Items: [Volatile]List_of_Items;

{ This procedure will read in the items from the file, and then randomly adjust their prices to simulate increasing and decreasing
  values of items in a market place. }

Var
   Flux: Real;  { Some times you just have to say, "what's the flux?" }
   Max_Items, Loop: Integer;
   returnValue: List_of_Items;

Begin { Read Items }
   returnValue:=Zero;

   Open (Item_File, file_name:=Items_Filename, ACCESS_METHOD:=SEQUENTIAL, History:=READONLY, Error:=CONTINUE, Sharing:=READWRITE);
   If (Status(Item_File) = 0) then
     Begin { successful read }
         Reset (Item_File);

         For Loop:=MIN_ITEM_NUMBER to MAX_ITEM_NUMBER do
            Begin { More data }
               Read (Item_File, returnValue[Loop]);
               STR$TRIM (returnValue[Loop].Name, returnValue[Loop].Name);
               STR$TRIM (returnValue[Loop].True_Name, returnValue[Loop].True_Name);

               { Calculate the price fluctuation, FLUX }

               Flux:=returnValue[Loop].Gp_Value;
               Flux:=Flux * Roll_Die(10) / 100;
               If Roll_Die(2)=2 then
                   Flux:=Flux*(-1);

               { Add flux to the current price }

               returnValue[Loop].Current_Value:=Max(Round(returnValue[Loop].GP_Value + Flux), 1);
            End;  { More Data }
         Close (Item_File);
         Read_Items:=returnValue;
     End { successful read }
  Else
     Read_Items:=Create_New_Items_File;
End;  { Read Items }

{**********************************************************************************************************************************}

[Global]Function Get_Item (Item_Number: Integer): Item_Record;

{ This function returns the Item_Number'th item from the item_file }

Begin { Get Item }
   Open (Item_File, File_Name:=Items_Filename, History:=READONLY, Access_Method:=DIRECT, Sharing:=READWRITE, Error:=Continue);
   If (Status(Item_File) = 0) then
      Begin
        Find (Item_File, Item_Number + 1);
        Get_Item:=Item_File^;
        Unlock (Item_File);
        Close (Item_File);
      End
   Else
      Get_Item:=Create_New_Items_File[Item_Number];
End;  { Get Item }

(**********************************************************************************************************************)
(************************************************* STORE QUANTITIES ***************************************************)
(**********************************************************************************************************************)

Procedure Create_New_Quantity_File (Filename: Line);

Var
   Loop: Integer;

Begin
    Open (AmountFile, file_name:=Filename, History:=NEW, Error:=CONTINUE, Sharing:=READONLY);
    If (Status(AmountFile) = 0) then
       Begin
          ReWrite (AmountFile);
          For Loop:=MIN_QUANTITY_NUMBER to MAX_QUANTITY_NUMBER Do
             Write (AmountFile, 0);

          Close (AmountFile);
       End;
End;

(******************************************************************************)

[Global]Procedure Access_Item_Quantity_Record (N: Integer);

{ Finds the Nth item and hold it so that others can't access it until it is UPDATED or UNLOCKED }

Begin
   Repeat
     Find (AmountFile, N + 1, Error:=CONTINUE)
   Until Status(AmountFile)=PAS$K_SUCCESS;  { TODO: What if the file does not exist or is corrupted? }
End;

(******************************************************************************)

[Global]Function Item_Count (Item_Number: Integer): [Volatile]Integer;

{ This function assumes that AMOUNTFILE has already been opened for DIRECT access. TODO: Move to Files.pas }

Begin
   Access_Item_Quantity_Record (Item_Number);

   Item_Count:=AmountFile^;

   { Unlock the record so that others can use it }

   Unlock (AmountFile);
End;

(******************************************************************************)

[Global]Function Get_Store_Quantity(slot: Integer): Integer;

Begin
   Find(AmountFile, slot + 1);

   Get_Store_Quantity:=AmountFile^;
End;

(******************************************************************************)

[Global]Procedure Write_Store_Quantity_Aux(slot: Integer; amount: Integer);

Begin
    Find(AmountFile, slot + 1);

    AmountFile^:=amount;

    Update(AmountFile);
End;

(******************************************************************************)

[Global]Procedure Open_Quantity_File_For_Write;

Const
  Filename = 'STORE.DAT;1';

Begin
    Open(AmountFile, file_name:=Filename, History:=Unknown, Access_Method:=DIRECT, Sharing:=READWRITE, Error:=CONTINUE);
    If (Status(AmountFile) <> 0) then
      Begin
        Create_New_Quantity_File (Filename);

        Open(AmountFile, file_name:=Filename, History:=Unknown, Access_Method:=DIRECT, Sharing:=READWRITE); { This time, crash on failure }
      End;
End;

(******************************************************************************)

[Global]Procedure Open_Quantity_File_For_Read;

Const
  Filename = 'STORE.DAT;1';

Begin
    Open(AmountFile, file_name:=Filename, History:=READONLY, Access_Method:=DIRECT, Sharing:=READWRITE, Error:=CONTINUE);
    If (Status(AmountFile) <> 0) then
      Begin
        Create_New_Quantity_File (Filename);

        Open(AmountFile, file_name:=Filename, History:=READONLY, Access_Method:=DIRECT, Sharing:=READWRITE); { This time, crash on failure }
      End;
End;

(******************************************************************************)

[Global]Procedure increment_item_quantity(slot: integer);

Begin
  Access_Item_Quantity_Record (slot);
  If AmountFile^ <> -1 then
    Begin
       AmountFile^:=AmountFile^ + 1;
       Update (AmountFile);
    End;
End;

(******************************************************************************)

[Global]Procedure Close_Quantity_File;

Begin
  Close (AmountFile);
End;

(******************************************************************************)

[Global]Procedure Write_Store_Quantity(slot: Integer; amount: Integer);

Begin
  Open_Quantity_File_For_Write;
  Write_Store_Quantity_Aux(slot, amount);
  Close(AmountFile);
End;

(******************************************************************************)

[Global]Procedure Decrement_Quantity (slot: Integer);

Begin
  Find(AmountFile, slot + 1);

  If AmountFile^>0 then
      AmountFile^:=AmountFile^ - 1;

  Update (AmountFile);
End;

(**********************************************************************************************************************)
(****************************************************** PICTURES ******************************************************)
(**********************************************************************************************************************)

[Global]Procedure Save_Pictures(Pics: Pic_List);

{ This procedure will write an updated set of pictures if the user is authorized to do so. }

Const
  Filename = 'Pictures.Dat;1';

Var
   Loop: Integer;

Begin { Save Pictures }
   Open (PicFile, file_name:=Filename, History:=OLD, Sharing:=READONLY);
   ReWrite (PicFile);
   For Loop:=MIN_PICTURE_NUMBER to MAX_PICTURE_NUMBER do
       Write (PicFile, Pics[Loop]);
   Close (PicFile);
End;  { Save Pictures }

(******************************************************************************)

Function Create_New_Pictures_File(Filename: Line): Pic_List;

Var
  Loop: Integer;
  returnValue: Pic_List;

Begin
   returnValue:=Zero;
   For Loop:=MIN_PICTURE_NUMBER to MAX_PICTURE_NUMBER do
        returnValue[Loop]:=Zero;

   Open (PicFile, file_name:=Filename, History:=NEW, Error:=CONTINUE, Sharing:=READONLY);
        If (Status(PicFile) = 0) then
           Begin
              ReWrite (PicFile);

              For Loop:=MIN_PICTURE_NUMBER to MAX_PICTURE_NUMBER do
                 Write(PicFile, ReturnValue[Loop]);

               Close (PicFile);

              Create_New_Pictures_File:=returnValue;
           End
        Else
           Create_New_Pictures_File:=returnValue;
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
         Reset (PicFile, Error:=Continue);
         Loop:=MIN_PICTURE_NUMBER;
         While (Loop<=MAX_PICTURE_NUMBER) and Not EOF(PicFile) do
            Begin
               Read(PicFile, returnValue[Loop]);
               Loop:=Loop + 1;
            End;
         Close (PicFile);

         Read_Pictures:=returnValue;
     End { successful read }
  Else
     Read_Pictures:=Create_New_Pictures_File(Filename);
End;

(**********************************************************************************************************************)
(******************************************************* ROSTER *******************************************************)
(**********************************************************************************************************************)

[Global]Procedure Write_Roster (Roster: Roster_Type);

{ This procedure is used to write the current roster to the character file }

Const
  Filename = 'SYS$LOGIN:Character.Dat;1';

Var
   Loop: Integer;
   Error: Boolean;

Begin { Write Roster }
    Open (Char_File, file_name:=filename, History:=Unknown);
    ReWrite (Char_File);
    For Loop:=MIN_ROSTER_NUMBER to MAX_ROSTER_NUMBER do
        Begin
           Write (Char_File, Roster[Loop]);
        End;
    Close (Char_File);
End;  { Write Roster }

{**********************************************************************************************************************************}

Function Create_New_Character_File (filename: line): Roster_Type;

Var
   Loop: Integer;
   Roster: Roster_Type;

Begin { failed to read; create a new one }
   Roster:=Zero;
   For Loop:=MIN_ROSTER_NUMBER to MAX_ROSTER_NUMBER do
       Roster[Loop].Status:=Deleted;

   Open (Char_File, file_name:=Filename, History:=NEW, Error:=CONTINUE, Sharing:=READONLY);
   If (Status(Char_File) = 0) then
      Begin
         ReWrite (Char_File);
          For Loop:=MIN_ROSTER_NUMBER to MAX_ROSTER_NUMBER do
             Write (Char_File, Roster[Loop]);
          Close (Char_File);

          Create_New_Character_File:=Roster;
      End
   Else
      Create_New_Character_File:=Roster;
End;

{**********************************************************************************************************************************}

[Global]Function Read_Roster: Roster_Type;

Const
  Filename = 'SYS$LOGIN:Character.Dat;1';

Var
   Loop: Integer;
   Roster: Roster_Type;

Begin { Read Roster }
  Roster:=Zero;

  Open (Char_File, File_Name:=Filename, History:=READONLY, Error:=CONTINUE, Sharing:=READONLY);
  If (Status(Char_File) = 0) then
     Begin { successful read }
         Reset (Char_File, Error:=Continue);
         For Loop:=MIN_ROSTER_NUMBER to MAX_ROSTER_NUMBER do
             Read (Char_File, Roster[Loop]);
         Close (Char_File);

         Read_Roster:=Roster;
     End
  Else
     Read_Roster:=Create_New_Character_File(Filename);
End;  { Read Roster }

(**********************************************************************************************************************)
(**************************************************** SAVE FILE *******************************************************)
(**********************************************************************************************************************)

[Global]Procedure Create_Null_SaveFile;

Const
  Filename = 'SYS$LOGIN:STONE_SAVE.DAT;1';

Begin
   Open (SaveFile, file_name:=filename, History:=Unknown);
   ReWrite (SaveFile);
   Close (SaveFile);
End;

(******************************************************************************)

[Global]Function Write_Save_File (saveRecord: Save_Record): Boolean;

Var
   Error: Boolean;

Begin
   Open (SaveFile, 'SYS$LOGIN:STONE_SAVE.DAT;1',HISTORY:=NEW, Error:=Continue);
   Error:=(Status(SaveFile)<>PAS$K_SUCCESS);

   ReWrite (SaveFile);
   Error:=Error or ((Status(SaveFile)<>PAS$K_SUCCESS) and (Status(SaveFile)<>PAS$K_EOF));

   Write (SaveFile, saveRecord, Error:=Continue);
   Error:=Error or ((Status(SaveFile)<>PAS$K_SUCCESS) and (Status(SaveFile)<>PAS$K_EOF));

   Close (SaveFile, Error:=Continue);

   Write_Save_File:=Error or ((Status(SaveFile) <> PAS$K_SUCCESS) and (Status(SaveFile) <> PAS$K_EOF));
End;

(**********************************************************************************************************************)
(**************************************************** LEVEL FILE ******************************************************)
(**********************************************************************************************************************)

[Global]Function Get_Maze_File_Name (levelCharacter: Char): Line;

Begin
   Get_Maze_File_Name:='MAZE' + levelCharacter + '.DAT;1'
End;

(******************************************************************************)

Function createEmptyLevel (levelNumber: Integer): Level;

Var
  returnValue: Level;
  x, y: 1..20;
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

Function Create_New_Level_File(Var fileVar: LevelFile; filename: Line; levelNumber: Integer): Level;

Var
  returnValue: Level;

Begin
     Open (fileVar, file_name:=filename, History:=NEW, Error:=CONTINUE, Sharing:=READONLY);
     If (Status(fileVar) = 0) then
        Begin
           returnValue:=createEmptyLevel(levelNumber);
           ReWrite(fileVar);
           Write (fileVar, returnValue);
           Close (fileVar);

           Create_New_Level_File:=returnValue;
        End { TODO: Handle failure case }
     Else
        Create_New_Level_File:=createEmptyLevel(levelNumber);
End;

(******************************************************************************)

[Global]Function Read_Level_from_Maze_File(Var fileVar: LevelFile; levelNumber: Integer): Level;

Var
  returnValue: Level;
  filename: Line;

Begin
  filename:=Get_Maze_File_Name(CHR(levelNumber + 64));
  Open (fileVar, File_Name:=filename, History:=READONLY, Error:=CONTINUE, Sharing:=READONLY);
  If (Status(fileVar) = 0) then
     Begin { successful read }
        Reset (fileVar);
        Read (fileVar, returnValue);
        Close (fileVar);

        Read_Level_from_Maze_File:=returnValue;
     End { successful read }
  Else
     Read_Level_from_Maze_File:=Create_New_Level_File(fileVar, filename, levelNumber);
End;

(******************************************************************************)

[Global]Procedure Save_Level_to_Maze_File(Var fileVar: LevelFile; filename: Line; Floor: Level);

Begin
    Open (MazeFile, file_name:=filename, History:=OLD);
    ReWrite (MazeFile);
    Write (MazeFile, Floor);
    Close (MazeFile);
End;

{**********************************************************************************************************************************}

[Global]Function Get_Level (Level_Number: Integer; Maze: Level; PosZ: Vertical_Type:=0): [Volatile]Level;

{ This function will return a level of the dungeon.  If the level of the dungeon is the same as POSZ, i.e., the same level, the
  current level will be returned.  If POSZ is omitted, this will ALWAYS load a new level even if it's simply loading the same level
  as the one in memory }

Begin { Get Level }
   If (Level_Number <> PosZ) and (Level_Number > 0) then
      Get_Level:=Read_Level_from_Maze_File(MazeFile, Level_Number)
   Else
      Get_Level:=Maze;  { Otherwise, return the current level }
End;  { Get Level }

{**********************************************************************************************************************************}
{****************************************************** HIGH SCORE LIST ***********************************************************}
{**********************************************************************************************************************************}

[Global]Function Read_Score_List: High_Score_List;

Var
  Score_List: High_Score_List;

Begin
   Open(ScoresFile, file_name:='SCORES.DAT', History:=UNKNOWN, Sharing:=READWRITE, Error:=Continue);

   If (Status(ScoresFile)=PAS$K_SUCCESS) or (Status(ScoresFile)=PAS$K_EOF) then
      Begin
         Reset (ScoresFile);
         If EOF (ScoresFile) then
            Score_List:=Zero
         Else
            Read (ScoresFile, Score_List);
         Close (ScoresFile);
      End
   Else
      Score_List:=Zero;

   Read_Score_List := Score_List;
End;

(******************************************************************************)

[Global]Procedure Write_Score_List (Score_List: High_Score_List);

Begin
   Open(ScoresFile, file_name:='SCORES.DAT',History:=UNKNOWN, Sharing:=READWRITE, Error:=Continue);
   If (Status(ScoresFile)=PAS$K_SUCCESS) or (Status(ScoresFile)=PAS$K_EOF) then
      Begin
        Rewrite (ScoresFile);
        Write (ScoresFile, Score_List);
        Close (ScoresFile);
      End;
End;

(******************************************************************************)

[Global]Procedure Clear_High_Scores;

Var
   Score_List: High_Score_List;

Begin { Clear High Scores }
  Score_List:=Zero;
  Write_Score_List (Score_List);
End;  { Clear High Scores }
End.

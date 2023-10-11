[Inherit ('Types','SMGRTL','LibRtl')]Module Edit_Maze;

{ This module facilitates the editing of a level of a maze }

Const
   Space_Char        = '.';
   Transparent_Char  = '*';
   Walk_Through_Char = ':';
   Door_Char         = '+';
   Secret_Char       = '$';
   Wall_Char         = '#';

   ZeroOrd = Ord('0');
   Up_Arrow          = CHR(18);                Down_Arrow      = CHR(19);
   Left_Arrow        = CHR(20);                Right_Arrow     = CHR(21);

Type
   Floor_Type = Array [1..20,1..20] of Room_Record;
   Print_Mode = (Specials,Rooms,Normal);

Var
   Monster:                     List_of_monsters;
   ScreenDisplay:               [External]Unsigned;
   PrintMazeFile:               [External]Text;
   MazeFile:                    [External]LevelFile;
   Print_Queue:                 [External,Volatile]Line;
   Answer:                      Char;
   Level_Loaded:                Integer;
   Need_to_Load,Need_to_Save:   Boolean;
   SPKind_Name:                 [Readonly]Array [SPKind] of Packed Array [1..15] of char;
   Special_Kind_Name:           [Readonly]Array [Special_Kind] of Packed Array [1..15] of char;
   Floor_Number:                Integer;
   Floor:                       Level;
   Need_to_load_Monsters:       Boolean;

Value
   Level_Loaded:=0;
   Need_to_Load:=True;   Need_to_Save:=False;   Need_to_Load_Monsters:=True;

SPKind_Name[NothingSpecial]     := 'Nothing';
SPKind_Name[Msg]                := 'Message';
SPKind_Name[Msg_Item_Given]     := 'Msg/Item';
SPKind_Name[Msg_Pool]           := 'Msg/Pool';
SPKind_Name[Msg_Hidden_Item]    := 'Msg/Hddn item';
SPKind_Name[Msg_Need_Item]      := 'Msg/need_item';
SPKind_Name[Msg_Lower_AC]       := 'Msg/Lower AC';
SPKind_Name[Msg_Raise_AC]       := 'Msg/Raise AC';
SPKind_Name[Msg_Goto_Castle]    := 'Msg/goto_castle';
SPKind_Name[Msg_Encounter]      := 'Msg/encounter';
SPKind_Name[Riddle]             := 'Riddle';
SPKind_Name[Fee]                := 'Fee';
SPKind_Name[Msg_Trade_Item]     := 'Trade items';
SPKind_Name[Msg_Picture]        := 'Msg/Picture';
SPKind_Name[Unknown]            := 'Unknown';
Special_Kind_Name[Nothing]      := 'Nothing';
Special_Kind_Name[Stairs]       := 'Stairs';
Special_Kind_Name[Pit]          := 'Pit';
Special_Kind_Name[Chute]        := 'Chute';
Special_Kind_Name[Rotate]       := 'Rotate';
Special_Kind_Name[Darkness]     := 'Darkness';
Special_Kind_Name[Teleport]     := 'Teleport';
Special_Kind_Name[Damage]       := 'Damage';
Special_Kind_Name[Elevator]     := 'Elevator';
Special_Kind_Name[Rock]         := 'Rock';
Special_Kind_Name[Antimagic]    := 'AntiMagic';
Special_Kind_Name[SPFeature]    := 'Special Feature';
Special_Kind_Name[An_Encounter] := 'Encounter';
Special_Kind_Name[Cliff]        := 'Cliff';

(******************************************************************************)
[External]Procedure Delay (Seconds: Real);External;
[External]Function String (Num: Integer; Len: Integer:=0):Line;external;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Procedure Get_Num (Var Number: Integer; Display: Unsigned);External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
(******************************************************************************)

Procedure Print_Level;

{ This procedure will print the name of the current level on the screen }

Begin { Print Level }
   If Level_Loaded>0 then SMG$Put_Chars (ScreenDisplay,
       'Current Level:  '
       +String(Level_Loaded),1,1)
End;  { Print Level }

(******************************************************************************)

Procedure Print_Load_Choices;

{ This procedure will print a menu of levels to choose from }

Begin { Print Load Choices }
   SMG$Put_Chars (ScreenDisplay,
       'Load Level',5,22,,1);
   SMG$Put_Chars (ScreenDisplay,
       '---- -----',6,22,,1);
   SMG$Put_Chars (ScreenDisplay,
       ' A) Load level 1',7,22);
   SMG$Put_Chars (ScreenDisplay,
       ' B) Load level 2',8,22);
   SMG$Put_Chars (ScreenDisplay,
       ' C) Load level 3',9,22);
   SMG$Put_Chars (ScreenDisplay,
       ' D) Load level 4',10,22);
   SMG$Put_Chars (ScreenDisplay,
       ' E) Load level 5',11,22);
   SMG$Put_Chars (ScreenDisplay,
       ' F) Load level 6',12,22);
   SMG$Put_Chars (ScreenDisplay,
       ' G) Load level 7',13,22);
   SMG$Put_Chars (ScreenDisplay,
       ' H) Load level 8',14,22);
   SMG$Put_Chars (ScreenDisplay,
       ' I) Load level 9',15,22);
   SMG$Put_Chars (ScreenDisplay,
       ' J) Load level 10',16,22);
   SMG$Put_Chars (ScreenDisplay,
       ' K) Load level Hell 1',17,22);
   SMG$Put_Chars (ScreenDisplay,
       ' L) Load level Hell 2',18,22);
   SMG$Put_Chars (ScreenDisplay,
       ' M) Load level Hell 3',7,42);
   SMG$Put_Chars (ScreenDisplay,
       ' N) Load level Hell 4',8,42);
   SMG$Put_Chars (ScreenDisplay,
       ' O) Load level Hell 5',9,42);
   SMG$Put_Chars (ScreenDisplay,
       ' P) Load level Hell 6',10,42);
   SMG$Put_Chars (ScreenDisplay,
       ' Q) Load level Hell 7',11,42);
   SMG$Put_Chars (ScreenDisplay,
       ' R) Load level Hell 8',12,42);
   SMG$Put_Chars (ScreenDisplay,
       ' S) Load level Hell 9',13,42);
   SMG$Put_Chars (ScreenDisplay,
       ' T) Don''t load a level',14,42);
   SMG$Put_Chars (ScreenDisplay,
       ' Which?',19,32);
End;  { Print Load Choices }

(******************************************************************************)
[External]Function Read_Level_from_Maze_File(Var fileVar: LevelFile; levelNumber: Integer): Level;External;
[External]Procedure Save_Level_to_Maze_File(Var fileVar: LevelFile; filename: Line; Floor: Level);External;
[External]Function Get_Maze_File_Name (levelCharacter: Char): Line;External;
(******************************************************************************)

Procedure Load_Floor (Number: Integer; Typed_Char: Char);

{ This procedure will load a specified floor.  If the floor file doesn't
  exist, a blank one will be created. }

Begin { Load Floor }

  { Set the appropriate flags, and build the filename for the specified level }

   Floor_Number:=Number;  Level_Loaded:=Number;  Need_to_Load:=False;

  { Attempt to open the level file }

  Floor:=Read_Level_from_Maze_File(MazeFile,Number);

  SMG$Put_Chars (ScreenDisplay,
      'Loaded.',23,36,,1);
  Delay (1);
End;  { Load Floor }

(******************************************************************************)

Procedure Load_Level (Var Floor: Level);

{ This procedure will allow the user to load a level to be edited }

Var
   Answer: Char;

Begin { Load Level }

  { Print a menu of choices }

   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay);
   Print_Level;
   Print_Load_Choices;
   SMG$End_Display_Update(ScreenDisplay);

  { Make and handle choice }

   Answer:=Make_Choice(['A'..'T']);
   If Answer<>'T' then
      If (Ord(Answer)-64)<>Floor_Number then
      Load_Floor (Ord(Answer)-64,Answer)
End;  { Load Level }

(******************************************************************************)

Procedure Save_Level (Floor: Level);

Var
  Answer: Char;
  Name: Line;

Begin
  SMG$Begin_Display_Update (ScreenDisplay);
  SMG$Erase_Display (ScreenDisplay);
  Print_Level;
  SMG$Put_Chars (ScreenDisplay,
      'Save Level',5,32,,1);
  SMG$Put_Chars (ScreenDisplay,
      '---- -----',6,32,,1);
  SMG$Put_Chars (ScreenDisplay,
      ' A) Save level '+String(Level_Loaded),7,32);
  SMG$Put_Chars (ScreenDisplay,
      ' Q) Don''t save a level',8,32);
  SMG$Put_Chars (ScreenDisplay,
      ' Which?',10,32);
  SMG$End_Display_Update (ScreenDisplay);
  Answer:=Make_Choice (['A'..'J', 'Q']);
  If Answer<>'Q' then
     Begin
        Answer:=Chr(Level_loaded+64);
        Name:=Get_Maze_File_Name(Answer);
        Save_Level_to_Maze_File(MazeFile,Name, Floor);
        SMG$Put_Chars (ScreenDisplay,
            'Saved.',23,36,,1);
        Need_to_Save:=False;
        Delay(1);
     End;
End;

(******************************************************************************)

Procedure Check_Monsters;

[External]Procedure Read_Monsters (Var Monster: List_of_Monsters);External;

Begin
  If Need_to_Load_Monsters then
     Begin
        Read_Monsters (Monster);  Need_to_Load_Monsters:=False;
     End;
End;

(******************************************************************************)

Procedure Print_Encounter_Menu (Index: Integer;  Var Enc: Encounter);

Var
   T: Line;

Begin
   Check_Monsters;
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay);
   SMG$Set_Cursor_ABS (ScreenDisplay,3,1);
   SMG$Put_Line (ScreenDisplay,
       '        Edit Encounter '+String(Index,1),1,1);
   T:='        A) Base Monster: '
       +String(Enc.Base_Monster_Number)
       +'(';
   If Enc.Base_Monster_Number>0 then
      T:=T
          +Monster[Enc.Base_Monster_Number].Real_Name
          +')'
   Else
      T:=T+'None)';
   SMG$Put_Line (ScreenDisplay, T);
   T:='        B) Random addition:  '
       +String(Enc.addition.X)
       +'D'
       +String(Enc.addition.Y);
   If Enc.Addition.Z>-1 then
       T:=T+'+';
   T:=T+String (Enc.Addition.Z);
   SMG$Put_Line (ScreenDisplay,T);
   SMG$Put_Line (ScreenDisplay,
       '         C) Probability: '
       +String(Enc.Probability));
   SMG$Put_Line (ScreenDisplay,
       '         E) Exit',2);
   SMG$Put_Line (ScreenDisplay,
       '         Which?');
   Print_Level;
   SMG$End_Display_Update (ScreenDisplay);
End;

(******************************************************************************)

Procedure Edit_Encounter (Index: Integer; Var Enc: Encounter);

Var
  Number: Integer;
  Answer: Char;

Begin
   Repeat
      Begin
         Print_Encounter_Menu (Index,Enc);
         Answer:=Make_Choice (['A'..'C','E']);
         If Answer in ['A','C'] then
            Begin
               SMG$Put_Chars (ScreenDisplay,
                   'Enter an integer: ',13,1);
               Get_Num (Number,ScreenDisplay);
               Case Answer of
                  'A': If (Number<=450) and (Number>=0) then
                         Enc.Base_Monster_Number:=Number
                       Else
                         Enc.Base_Monster_Number:=450;
                  'C': If (Number<=200) and (Number>=0) then
                         Enc.Probability:=Number
                       Else
                         Enc.Probability:=200;
               End
            End
         Else
            If Answer='B' then
               Begin
                  SMG$Put_Chars(ScreenDisplay,'Enter X: ',13,1);
                  Get_Num (Enc.Addition.X,ScreenDisplay);
                  SMG$Put_Chars(ScreenDisplay,'Enter Y: ',14,1);
                  Get_Num (Enc.Addition.Y,ScreenDisplay);
                  SMG$Put_Chars(ScreenDisplay,'Enter Z: ',15,1);
                  Get_Num (Enc.Addition.Z,ScreenDisplay);
               End;
      End;
   Until Answer='E'
End;

(******************************************************************************)

Procedure Print_Range (Enc: Encounter);

Var
  T: Line;
  First,Last: Integer;

Begin
   T:='';
   Check_Monsters;
   First:=Enc.Base_Monster_Number;  Last:=First+(Enc.Addition.X*Enc.Addition.Y)+Enc.Addition.Z;
   If (First>0) and (Last<451) then
       T:='['
       +Monster[First].Real_Name
       +'-'
       +Monster[Last].Real_Name
       +']';
   SMG$Put_Chars (ScreenDisplay, T);
End;

(******************************************************************************)

Procedure Encounter_Edit (Var Table: Encounter_Table);

Var
   Answer: Char;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         Print_Level;
         SMG$Put_Chars (ScreenDisplay,
             'Encounter Edit',5,29,,1);
         SMG$Put_Chars (ScreenDisplay,
             '--------- ----',6,29,,1);
         SMG$Put_Chars (ScreenDisplay,
             ' 1) Edit Encounter one  '
             +' (wandering) ',7,1);
         Print_Range (Table[1]);
         SMG$Put_Chars (ScreenDisplay,
             ' 2) Edit Encounter two  '
             +' (lair)      ',8,1);
         Print_Range (Table[2]);
         SMG$Put_Chars (ScreenDisplay,
             ' 3) Edit Encounter three '
             +'(?special?) ',9,1);
         Print_Range (Table[3]);
         SMG$Put_Chars (ScreenDisplay,
             ' 0) Exit',10,1);
         SMG$Put_Chars (ScreenDisplay,
             ' Which?',12,1);
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice (['0'..'3']);
         If Answer<>'0' then Edit_Encounter (Ord(Answer)-ZeroOrd,Table[Ord(Answer)-ZeroOrd]);
      End;
   Until (Answer='0');
End;

(******************************************************************************)

Procedure Print_Item (Table: Special_Table_Type; Position: Integer);

Var
   T: Line;
   Item: Integer;

Begin
   Item:=Position;
   T:=' '+CHR(Position+65);
   T:=T+' '+Special_Kind_Name[Table[Item].Special];
   T:=T+' ';
   If Table[Item].Special=SPFeature then
      T:=T+SPKind_Name[Table[Item].Feature]
   Else
      T:=T+Pad('Nothing',' ',15);
   T:=T+' ';
   T:=T+String (table[Item].Pointer1,10);
   T:=T+' ';
   T:=T+String (table[Item].Pointer2,10);
   T:=T+' ';
   T:=T+String (table[Item].Pointer3,10);
   SMG$Put_Chars (ScreenDisplay,T,Position+5,1);
End;

(******************************************************************************)

Procedure Print_Special_Item (Special: SpKind; Position: Integer);

Begin
   SMG$Put_Chars (ScreenDisplay,SpKind_Name[Special],Position+5,20);
ENd;


(******************************************************************************)

Procedure Print_Feature_Item (Feature: Special_Kind; Position: Integer);

Begin
   SMG$Put_Chars (ScreenDisplay,Special_Kind_Name[Feature],Position+5,4);
ENd;

(******************************************************************************)

Procedure Feature_Edit (Var Feature: SPKind; Number: Integer);

Var
   Answer: Char;

Begin
   Repeat
      Begin
         SMG$Put_Chars (ScreenDisplay,
             '<-- -->, space exits',22,1,1);
         Answer:=Make_Choice ([Left_Arrow,Right_Arrow,CHR(32)]);
         Case Answer of
             Left_Arrow: If (Feature=NothingSpecial) then
                            Begin
                               Feature:=Unknown;
                            End
                         Else
                            Begin
                               Feature:=Pred(Feature);
                            End;
            Right_Arrow: If (Feature=Unknown) then
                            Begin
                               Feature:=NothingSpecial;
                            End
                         Else
                            Begin
                               Feature:=Succ(Feature);
                            End;
         End;
         Print_Special_Item (Feature,Number);
      End;
   Until Answer=CHR(32);
End;

(******************************************************************************)

Procedure Kind_Edit (Var Special: Special_Kind; Number: Integer);

Var
   Answer: Char;

Begin
   Repeat
      Begin
         SMG$Put_Chars (ScreenDisplay,
             '<-- -->, space exits',22,1,1);
         Answer:=Make_Choice ([Left_Arrow,Right_Arrow,CHR(32)]);
         Case Answer of
             Left_Arrow: If (Special=Nothing) then
                            Begin
                               Special:=Cliff;
                            End
                         Else
                            Begin
                               Special:=Pred(Special);
                            End;
            Right_Arrow: If (Special=Cliff) then
                            Begin
                               Special:=Nothing;
                            End
                         Else
                            Begin
                               Special:=Succ(Special);
                            End;
         End;
         Print_Feature_Item (Special, Number);
      End;
   Until (Answer=CHR(32));
End;

(******************************************************************************)

Procedure Special_Edit (Var Table: Special_Table_Type);

Var
   Answer: Char;
   Options: Char_Set;
   T: Line;
   Number: Integer;
   Item: Integer;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Chars (ScreenDisplay,
             'Special Editor',1,37,,1);
         SMG$Put_Chars (ScreenDisplay,
             '------- ------',2,37,,1);
         Print_Level;
         SMG$Set_Cursor_ABS (ScreenDisplay,3,1);
         SMG$Put_Line (ScreenDisplay,
             '#  Kind            Special  '
             +'         Pointer1   Pointer'
             +'2   Pointer3');
         SMG$Put_Line (ScreenDisplay,
             '-- --------------- ---------'
             +'------ ---------- ---------'
             +'- ----------');
         For Item:=0 to 15 do
            Begin
               Print_Item (Table, Item);
            End;
         SMG$End_Display_Update (ScreenDisplay);
         SMG$Put_Chars (ScreenDisplay,
             'Edit which special? (Q exi'
             +'ts) --',22,1);
         Cursor;
         Answer:=Make_Choice (['A'..'Q']);
         No_Cursor;
         Number:=Ord(Answer)-65;
         If (Number<=15) then
            Repeat
               Begin
                  Options:=['K','P','E'];
                  T:='Edit: K)ind, ';
                  If (Table[Number].Special=SPFeature) then
                     Begin
                        T:=T+'F)eature, ';
                        Options:=Options+['F'];
                     End;
                  T:=T+'P)ointers, or E)xit edit';
                  SMG$Put_Chars (ScreenDisplay,T,22,1,1);
                  Answer:=Make_Choice (Options);
                  Case Answer of
                        'E': ;
                        'F': Feature_Edit   (Table[Number].Feature,Number);
                        'K': Kind_Edit      (Table[Number].Special,Number);
                        'P': Begin
                                SMG$Put_Chars (ScreenDisplay,
    'Enter Pointer1: ',22,1,1);
                                Get_Num (Table[Number].Pointer1, ScreenDisplay);
                                SMG$Put_Chars (ScreenDisplay,
    'Enter Pointer2: ',22,1,1);
                                Get_Num (Table[Number].Pointer2, ScreenDisplay);
                                SMG$Put_Chars (ScreenDisplay,
    'Enter Pointer3: ',22,1,1);
                                Get_Num (Table[Number].Pointer3, ScreenDisplay);
                                Print_Item (Table,Number);
                             End;
                  End; { Case }
               End; { Repeat }
            Until (Answer='E');
      End;
   Until (Number=16);
End;

(******************************************************************************)

Function Top_Row (Spot: Room_Record): Line;

Var
  T: Line;

Begin
   T:='';
   If (Spot.North<>Passage) or (Spot.West<>Passage) then
       T:=T+Wall_Char
   Else
       T:=T+' ';

   Case Spot.North of
      Passage:      T:=T+' ';
      Transparent:  T:=T+Transparent_Char;  { w }
      Walk_Through: T:=T+Walk_Through_Char;  { ~ }
      Wall:         T:=T+Wall_Char;  { - }
      Door:         T:=T+Door_Char;  { ^ }
      Secret:       T:=T+Secret_Char;
      Otherwise     T:=T+Space_Char;
   End;

   If (Spot.North<>Passage) or (Spot.East<>Passage) then
       T:=T+Wall_Char
   Else
       T:=T+' ';
   Top_Row:=T;
End;

(******************************************************************************)

Function Middle_Row (Spot: Room_Record; Mode: Print_Mode): Line;

Var
  T: Line;

Begin
  T:='';
  Case Spot.West of
     Passage:      T:=' ';
     Transparent:  T:=Transparent_Char;  { left curly bracket }
     Wall:         T:=Wall_Char;         { | }
     Walk_Through: T:=Walk_Through_Char; { S }
     Door:         T:=Door_Char;         { < }
     Secret:       T:=Secret_Char;       { $ }
     Otherwise     T:=Space_Char;
  End;

  Case Mode of
     Normal:                           T:=T+Space_Char;
     Rooms:  If Spot.Kind=Room then    T:=T
         +'R'
             Else                      T:=T
         +'C';
     Specials:                         T:=T+CHR(Ord(Spot.Contents)+65);
     Otherwise                         T:=T+Space_Char;
  End;

  Case Spot.East of
     Passage:      T:=T+' ';
     Transparent:  T:=T+Transparent_Char;  { left curly bracket }
     Wall:         T:=T+Wall_Char;         { | }
     Walk_Through: T:=T+Walk_Through_Char; { S }
     Door:         T:=T+Door_Char;         { < }
     Secret:       T:=T+Secret_Char;       { $ }
     Otherwise     T:=T+Space_Char;
  End;
  Middle_Row:=T;
End;

(******************************************************************************)

Function Bottom_Row (Spot: Room_Record): Line;

Var
  T: Line;

Begin
   T:='';
   If (Spot.South<>Passage) or (Spot.West<>Passage) then
       T:=T+Wall_Char { + }
   Else
       T:=T+' ';

   Case Spot.South of
      Passage:      T:=T+' ';
      Transparent:  T:=T+Transparent_Char;  { w }
      Walk_Through: T:=T+Walk_Through_Char;  { ~ }
      Wall:         T:=T+Wall_Char;  { - }
      Door:         T:=T+Door_Char;  { ^ }
      Secret:       T:=T+Secret_Char;
      Otherwise     T:=T+Space_Char;
   End;
   If (Spot.South<>Passage) or (Spot.East<>Passage) then
       T:=T+Wall_Char { + }
   Else
       T:=T+' ';
   Bottom_Row:=T;
End;

(******************************************************************************)

Procedure Print_Key;

Begin
   SMG$Put_Chars (ScreenDisplay,
       'Key',
       16,62);
   SMG$Put_Chars (ScreenDisplay,
       '---',
       17,62);
   SMG$Put_Chars (ScreenDisplay,
       'Space       = "'
       +Space_Char
       +'"',
       18,62);
   SMG$Put_Chars (ScreenDisplay,
       'Trans. Wall = "'
       +Transparent_Char
       +'"',
       19,62);
   SMG$Put_Chars (ScreenDisplay,
       'Walkthrough = "'
       +Walk_Through_Char
       +'"',
       20,62);
   SMG$Put_Chars (ScreenDisplay,
       'Door        = "'
       +Door_Char
       +'"',
       21,62);
   SMG$Put_Chars (ScreenDisplay,
       'Secret Door = "'
       +Secret_Char
       +'"',
       22,62);
   SMG$Put_Chars (ScreenDisplay,
       'Wall        = "'
       +Wall_Char
       +'"',
       23,62);
End;

(******************************************************************************)

Procedure Print_Screen (Maze: Floor_Type;  CursorX,CursorY,TopX,TopY: Integer;  Mode: Print_Mode:=Normal);

Type
   Row_Type = (Top,Middle,Bottom);

Var
  T: Line;
  Row: Row_Type;
  RoomX,RoomY,SpotY,LastX,LastY: Integer;
  Spot: Room_Record;
  Spot_Special: Special_Kind;
  SP: SPKind;

Begin
  LastX:=1+20;  If LastX>20 then LastX:=20; LastY:=TopY+6;  { TODO: Looks like a logic error }
  For RoomY:=TopY to LastY do
     For Row:=Top to Bottom do
        Begin
           For RoomX:=1 to LastX do
              Begin
                 Spot:=Maze[RoomX,RoomY];
                 Case Row of
                       Top: SMG$Put_Chars (ScreenDisplay,Top_Row (Spot));
                    Middle: SMG$Put_Chars (ScreenDisplay,Middle_Row (Spot,Mode));
                    Bottom: SMG$Put_Chars (ScreenDisplay,Bottom_Row (Spot));
                 End;
              End;
           SMG$Put_Line (ScreenDisplay,'');
        End;
  Spoty:=(CursorY-TopY)+1;
  Spot:=Maze[CursorX,CursorY];
  Case Mode of
       Normal:  T:=Space_Char;
       Rooms:   If Spot.Kind=Room then
          T:='R'
                Else
         T:='C';
       Specials: T:=CHR(Ord(Spot.Contents)+65);
  End;
  SMG$Put_Chars (ScreenDisplay,T,(SpotY*3),(CursorX*3)-1,0,2);
  Print_Key;
  Spot_Special:=Floor.Special_Table[Spot.Contents].Special;
  If Spot_Special=SPFeature then
     Begin
        SP:=Floor.Special_Table[Spot.Contents].Feature;
        SMG$Put_Chars (ScreenDisplay,
            SpKind_Name[SP]
            +'',13,62);
     End
  Else
     SMG$Erase_Line (ScreenDisplay,13,62);
  SMG$Put_Chars (ScreenDisplay,
      String(Floor.Special_Table[Spot.Contents].Pointer1)
          +' '+
      String(Floor.Special_Table[Spot.Contents].Pointer2)
          +' '+
      String(Floor.Special_Table[Spot.Contents].Pointer3),14,62);
End;

(******************************************************************************)

Procedure Move_Up (Var CurrentY,TopY: Integer);

{ This procedure moves the cursor up, and wraps if off the edge }

Begin { Move Up }
   If CurrentY>1 then  { If still on screen... }
      Begin { If on screen }
         CurrentY:=CurrentY-1;
         If CurrentY<TopY then
            TopY:=CurrentY;
      End   { If on screen }
   Else
      Begin { Wrap }
         CurrentY:=20;
         TopY:=20-6;
      End;  { Wrap }
End;  { Move Up }

(******************************************************************************)

Procedure Move_Left (Var CursorX,CursorY,TopY: Integer);

{ This procedure moves the cursor to the left, and wraps if off the edge }

Begin { Move Left }
   CursorX:=CursorX-1;
   If CursorX<1 then
      Begin
         CursorX:=20;
         Move_UP (CursorY,TopY);
      End;
End;  { Move Left }

(******************************************************************************)

Procedure Move_Down (Var CurrentY,TopY: Integer);

{ This procedure moves the cursor down, and wraps if off the edge }

Begin { Move Down }
   If CurrentY<20 then  { If still on screen... }
      Begin { Move down }
         CurrentY:=CurrentY+1;
         If CurrentY>TopY+6 then
            TopY:=TopY+1;
      End
   Else { Otherwise, wrap to top of screen }
      Begin { Move to top }
         CurrentY:=1;
         TopY:=1;
      End;  { Move to top }
End;  { Move Down }

(******************************************************************************)

Procedure Move_Right (Var CursorX,CursorY,TopY: Integer);

{ This procedure moves the cursor to the right, and wraps if off the edge }

Begin { Move Right }
   CursorX:=CursorX+1;
   If CursorX>20 then
      Begin
         CursorX:=1;
         Move_Down (CursorY,TopY);
      End;
End;  { Move Right }

(******************************************************************************)

Procedure Room_or_Corridor (Var Maze: Floor_Type;  Var CursorX,CursorY,TopY: Integer);

{ This procedure enters the Room/Corridor mode, which allows the user to maneuver over any spot in the maze and assign it as a
  room or as a corridor. }

Const
    Room_Command_Line = 'Room/Corridor '
        +'options. Use Arrows. T)oggle '
        +'or E)xit';

Var
   Answer: Char;

Begin { Room or Corridor }
   Repeat
      Begin { Repeat }
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Put_Chars (ScreenDisplay,Room_Command_Line,1,1,1,1);
         SMG$Set_Cursor_ABS (ScreenDisplay,2,1);
         Print_Screen (Maze,CursorX,CursorY,1,TopY,Rooms);  { Print level }
         SMG$Put_Chars (ScreenDisplay,
            'X: '
            + String(CursorX, 2)
            + ' Y: '
            + String(CursorY, 2)
            + ' Z: '
            + String(Level_Loaded,2),
            2, 66);
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice ([Down_Arrow,Up_Arrow,Left_Arrow,Right_Arrow,'T','E']);
         Case Answer of
             'T': Begin
                    If Maze[CursorX,CursorY].Kind=Room then
                       Begin
                          Maze[CursorX,CursorY].Kind:=Corridor;
                       End
                    Else
                       Begin
                          Maze[CursorX,CursorY].Kind:=Room;
                       End;
                    Move_Right (CursorX,CursorY,TopY);
                  End;
             Left_Arrow: If (CursorX>1) then
                Begin
                   Move_Left (CursorX,CursorY,TopY);
                End;
             Right_Arrow: If (CursorX<20) then
                Begin
                   Move_Right (CursorX,CursorY,TopY);
                End;
             Up_Arrow: If (CursorY>1) then
                Begin
                   Move_Up (CursorY,TopY);
                End;
             Down_Arrow: If (CursorY<20) then
                Begin
                   Move_Down (CursorY,TopY);
                End;
         End; { Case }
      End; { Repeat }
   Until (answer='E');  { Until user wants to E)xit this mode }
End;  { Room or Corridor }

(******************************************************************************)

Procedure Change_Room_Special (Var Maze: Floor_Type;  Var CursorX,CursorY,TopY: Integer);

{ This procedure lets the user place a special in the room by typing its letter code }

Var
   Special: Char;

Begin { Change Room Special }

   { Get the special }

   SMG$Put_Chars (ScreenDisplay,
       'Enter special letter, <SPACE> exits',
       23,1,,1);
   Special:=Make_Choice(['A'..'P',CHR(32)]);

   { If not exiting mode, place the special }

   If (Special<>CHR(32)) then
      Begin
         Maze[CursorX,CursorY].Contents:=ORD(Special)-65;
      End;

   SMG$Erase_Line (ScreenDisplay,23,1);
   Move_Right (CursorX,CursorY,TopY);
End;   { Change Room Special }

(******************************************************************************)

Procedure Special_Placement (Var Maze: Floor_Type;  Var CursorX,CursorY,TopY: Integer);

{ This procedure runs the Special Placement mode.  It allows the user to maneuver the cursor over the maze, and place specials
  wherever he or she feels like }

Const
   Special_Command_Line = 'Specials o'
   +'ptions: Use Arrows, P)lace a spec'
   +'ial or E)xit';

Var
   Answer: Char;

Begin { Special Placement }
   Repeat
      Begin { Repeat }
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Put_Chars (ScreenDisplay,Special_Command_Line,1,1,1,1);

         { Print the floor plan, mode=2 (indicating specials) }

         SMG$Set_Cursor_ABS (ScreenDisplay,2,1);
         Print_Screen (Maze,CursorX,CursorY,1,TopY,Specials);
         SMG$Put_Chars (ScreenDisplay,
             'X: '
             +String(CursorX,2)
             +' Y: '
             +String(CursorY,2)
             +' Z: '
             +String(Level_Loaded,2),2,66);
         SMG$End_Display_Update (ScreenDisplay);

         { Get the choice and handle it }

         Answer:=Make_Choice ([Down_Arrow,Up_Arrow,Left_Arrow,Right_Arrow,'P','E']);
         Case Answer of
                     'E': ;
                     'P': Change_Room_Special (Maze,CursorX,CursorY,TopY);
              Left_Arrow: Move_Left (CursorX,CursorY,TopY);
             Right_Arrow: Move_Right (CursorX,CursorY,TopY);
                Up_Arrow: Move_Up (CursorY,TopY);
              Down_Arrow: Move_Down (CursorY,TopY);
         End;
      End;  { Repeat }
   Until answer='E';  { Until user wants to E)xit this menu }
End;  { Special Placement }

(******************************************************************************)

Procedure Change_Room (Var Room: Room_Record; Item: Exit_Type);

{ This procedure allows the user to place an ITEM (door, passage, etc) in the ROOM.  This procedure will ask the user where he/she
  wants to put the ITEM (north,south,...) and place it there. }

Var
   Answer: Char;

Begin { Change Room }

   { The the direction to place the ITEM }

   SMG$Put_Chars (ScreenDisplay,'Put it where? (<SPACE> exits)',23,1,1,1);
   Answer:=Make_Choice([Left_Arrow,Right_Arrow,Up_arrow,Down_Arrow,CHR(32)]);

   { Place it }

   Case Answer of
        Left_Arrow: Room.West:=Item;
        Right_Arrow: Room.East:=Item;
        Up_Arrow: Room.North:=Item;
        Down_Arrow: Room.South:=Item;
   End;
End;  { Change Room }

(******************************************************************************)

Procedure Print_Level_To_File (Maze: Floor_Type);

Type
   Row_Type = (Top,Middle,Bottom);

Var
   Command: Line;
   Row: Row_Type;
   X,RoomX,RoomY: Integer;
   Spot: Room_Record;

Begin
   Open (PrintMazeFile,
       'SYS$LOGIN:Level_'
       +String(Level_Loaded)
       +'.Pic',Unknown,Error:=Continue);
   Rewrite (PrintMazeFile,Error:=Continue);
   Writeln (PrintMazeFile,
       'Level: '+String(Level_Loaded));
   Write (PrintMazeFile,'+');
   For RoomY:=1 to 20 do
      For Row:=Top to Bottom do
         Begin
            For RoomX:=1 to 20 do
               Begin
                  Spot:=Maze[RoomX,RoomY];
                  Case Row of
                        Top: Write (PrintMazeFile,Top_Row (Spot),Error:=Continue);
                     Middle: Write (PrintMazeFile,Middle_Row (Spot,Normal),Error:=Continue);
                     Bottom: Write (PrintMazeFile,Bottom_Row (Spot),Error:=Continue);
                  End;
               End;
            Writeln (PrintMazeFile,Error:=Continue);
         End;
   Close (PrintMazeFile,Error:=Continue);
   Command:='PRINT/DELETE/NOLOG/NONOTIFY/QUEUE='
       +Print_Queue
       +' SYS$LOGIN:Level_'
       +String(Level_Loaded)
       +'.PIC';
    { LIB$SPAWN (Command); TODO: Not currently in LibRtl.pas and since we're not printing to VAX printers ... }
   SMG$Put_Line (ScreenDisplay,'',2);
   SMG$Put_Line (ScreenDisplay,'Printing queued.',0,1);
   Delay(1);
End;

(******************************************************************************)

Procedure Floor_Plan_Edit (Var Maze: Floor_Type);

{ This procedure allows the user to edit the physical floor plant.  Also, the user can elect to enter the Feature edit mode, or the
  room-corridor edit mode }

Const
    Command_Line = 'Arrows, '
        +'F)eat, P)ass, R)m,'
        +' X=Wlk-thr, T)ran'
        +'s, D)oor, W)all, '
        +'S)ecr, E)xit';

Var
  Answer: Char;
  TopY,CursorX,CursorY: Integer;

Begin { Floor Plan Edit }
  TopY:=1;  CursorX:=1;  CursorY:=1;  { Initialize positional pointers }
  Repeat
     Begin { Repeat }

        { Print the floor plan on the screen }

        SMG$Begin_Display_Update (ScreenDisplay);
        SMG$Erase_Display (ScreenDisplay);
        SMG$Put_Chars (ScreenDisplay,Command_Line,1,1,1,1);
        SMG$Set_Cursor_ABS (ScreenDisplay,2,1);
        Print_Screen (Maze,CursorX,CursorY,1,TopY);
        SMG$Put_Chars (ScreenDisplay,
            'X:'
            +String(CursorX,2)
            +' Y: '
            +String(CursorY,2)
            +' Z: '
            +String(Level_Loaded,2),2,66);
        SMG$End_Display_Update (ScreenDisplay);

        { Get user response }

        Answer:=Make_Choice (['X',Down_Arrow,Up_Arrow,Left_Arrow,'T',Right_Arrow,'P','S','D','W','F','E','R']);
        Case Answer of
                    'E': ;
                    'F': Special_Placement (Maze,CursorX,CursorY,TopY);
                    'R': Room_or_Corridor (Maze,CursorX,CursorY,TopY);
                    'T': Change_Room (Maze[CursorX,CursorY],Transparent);  { Add transparenmt }
                    'W': Change_Room (Maze[CursorX,CursorY],Wall);  { Add wall }
                    'D': Change_Room (Maze[CursorX,CursorY],Door);  { Add door }
                    'S': Change_Room (Maze[CursorX,CursorY],Secret);  { Add sec. door }
                    'P': Change_Room (Maze[CursorX,CursorY],Passage);  { Add passage }
                    'X': Change_Room (Maze[CursorX,CursorY],Walk_Through);
             Left_Arrow: Move_Left (CursorX,CursorY,TopY);
            Right_Arrow: Move_Right (CursorX,CursorY,TopY);
               Up_Arrow: Move_Up (CursorY,TopY);
             Down_Arrow: Move_Down (CursorY,TopY);
        End;
     End;  { Repeat }
  Until answer='E'; { Until the user wants to E)xit this menu }
End;  { Floor Plan Edit }

(******************************************************************************)

Procedure Edit_Level (Var Floor: Level);

{ This procedure allows the user to edit the current level, FLOOR }

Var
   Answer: Char;

Begin { Edit Level }
  Repeat
     Begin { Repeat }
        SMG$Begin_Display_Update (ScreenDisplay);
        SMG$Erase_Display (ScreenDisplay);
        Print_Level;
        SMG$Put_Chars (ScreenDisplay,'Edit Level',5,28,,1);
        SMG$Put_Chars (ScreenDisplay,'---- -----',6,28,,1);
        SMG$Put_Chars (ScreenDisplay,' E)ncounter Table edit',7,28);
        SMG$Put_Chars (ScreenDisplay,' S)pecial Table edit',8,28);
        SMG$Put_Chars (ScreenDisplay,' F)loorplan edit',9,28);
        SMG$Put_Chars (ScreenDisplay,' L)eave this menu',10,28);
        SMG$Put_Chars (ScreenDisplay,' Which?',12,28);
        SMG$End_Display_Update (ScreenDisplay);
        Answer:=Make_Choice (['F','S','E','L']);
        Case Answer of
               'F': Floor_Plan_Edit (Floor.Room);
               'S': Special_Edit (Floor.Special_Table);
               'E': Encounter_Edit (Floor.Monsters);
               'L': ;
        End;
        If Answer<>'L' then Need_to_Save:=True;
     End;  { Repeat }
  Until Answer='L';  { Until the user wants to L)eave this }
End;  { Edit Level }

(******************************************************************************)

Procedure Print_Main_Menu;

Begin
   SMG$Put_Chars (ScreenDisplay,'Maze Editor   ',5,33,,1);
   SMG$Put_Chars (ScreenDisplay,'---- ------   ',6,33,,1);
   SMG$Put_Chars (ScreenDisplay,' L)oad a level',7,33);
   SMG$Put_Chars (ScreenDisplay,' S)ave current level',8,33);
   SMG$Put_Chars (ScreenDisplay,' E)dit current level',9,33);
   SMG$Put_Chars (ScreenDisplay,' P)rint current level to file',10,33);
   SMG$Put_Chars (ScreenDisplay,' Q)uit editor',11,33);
   SMG$Put_Chars (ScreenDisplay,' Which?',12,33);
   SMG$End_Display_Update (ScreenDisplay);
End;

(******************************************************************************)

Procedure Ask_to_Load_Level;

Begin
  If (Need_to_Save) then
     Begin
       SMG$Put_Line (ScreenDisplay,'');
       SMG$Put_Line (ScreenDisplay,'Throw away changes? (Y/N)');
       If YES_OR_NO='Y' then Load_Level (Floor);
     End
  Else
     Load_Level (Floor);
End;

(******************************************************************************)

Procedure Ask_To_Save_Level (Var Answer: Char);

Begin
   If Need_to_Save then
      Begin
         SMG$Put_Line (ScreenDisplay,'');
         SMG$Put_Line (ScreenDisplay,'Throw away changes? (Y/N)');
         If YES_OR_NO='N' then Answer:='*';
      End;
End;

(******************************************************************************)

[Global]Procedure Edit_Maze (Var MazeFile: LevelFile);

Begin { Edit Maze }
   Repeat
      Begin { Repeat }
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         Print_Level;  { Print the level number (if any) at top of screen }
         Print_Main_Menu;
         Answer:=Make_Choice (['L','S','E','Q','P']);  { Get the command }
         Case Answer of
                'L':  Ask_to_load_Level;
                'P': If Not Need_to_Load then Print_Level_to_File (Floor.Room);
                'S': If Not Need_to_Load then Save_Level (Floor);
                'E': If Not Need_to_Load then Edit_Level (Floor);
                'Q': Ask_to_Save_Level (Answer);
         End;
      End;  { Repeat }
   Until Answer='Q';  { Until the user wants to Q)uit editting }
   Need_to_Save:=False;
End;  { Edit Maze }
End.  { Edit Maze }

[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','STRRTL')]Module Maze;

Const
   debug = true;
   CharY  = 17;  CharX  =  2;
   MonY   =  2;  MonX   = 26;
   SpellsY=  7;  SpellsX= 26;
   ViewY  =  2;  ViewX  =  2;
   MsgY   = 12;  MsgX   =  2;

  Up_Arrow          = CHR(18);               Down_Arrow    = CHR(19);
  Left_Arrow        = CHR(20);               Right_Arrow   = CHR(21);
  ZeroOrd=Ord('0');

Type
    Coordinate_Matrix = Array [1..6] of Integer;
    Place_Ptr  = ^Place_Node;
    Place_Node = Record
                    PosX,PosY: Horizontal_Type;
                    PosZ: Vertical_Type;
                    Next,Previous: Place_Ptr;
                 End;
    Place_Stack  = Record
                    Length: Integer;
                    Front,Rear: Place_Ptr;
                 End;

Var
   Dont_Draw:                                       Boolean;
   Game_Saved,Leave_Maze,Auto_Load,Auto_Save:       [External]Boolean;
   Places:                                          [Global]Place_Stack;
   Plane_Name:                                      Array [0..9] of Line;
   Direction:                                       [External]Direction_Type;
   Rounds_Left:                                     [External]Array [Spell_Name] of Unsigned;
   Maze:                                            [External]Level;
   PosX,PosY,PosZ:                                  [Byte,External]0..20;
   Minute_Counter:                                  [External]Real;
   DirectionName:                                   Array [Direction_Type] of Line;
   SaveFile:                                        [External]Save_File_Type;
   Item_List:                                       [External]List_of_Items;
   Messages:                                        Message_Group;

   ScreenDisplay,BottomDisplay,OptionsDisplay,Pasteboard,CharacterDisplay,CommandsDisplay,SpellsDisplay: [External]Unsigned;
   MonsterDisplay,Keyboard,WinDisplay,GraveDisplay,MessageDisplay,ViewDisplay: [External]Unsigned;

   DemonPic,AngelPic: Array [1..20] of Line;

Value
   DemonPic[1]  :='                          _^___^_         |  |';
   DemonPic[2]  :='             |||| |      /       \       ---<)';
   DemonPic[3]  :='             |||| |      | @   @ |       ---<)';
   DemonPic[4]  :='             ####/       |       |       ---<)';
   DemonPic[5]  :='             {   ||     /|\     /|\      ---<)';
   DemonPic[6]  :='              \( )\/   ^v^v^v^v^v^v^    / |  |';
   DemonPic[7]  :='               \( )\  /             \  /( |  |';
   DemonPic[8]  :='                \  (\/      | |      \/(  |  |';
   DemonPic[9]  :='                 \(         | |          )|  |';
   DemonPic[10] :='                  \    \   /   \   /     /|  |';
   DemonPic[11] :='                   \()/\            /\()/ |  |';
   DemonPic[12] :='                    \/  \   / \    /  \/  |  |';
   DemonPic[13] :='          $             /          \      |  |';
   DemonPic[14] :='        $  $    $    \\/     ^      \//   |  |';
   DemonPic[15] :='       $$  $     $   \/     / \  $   \/$  |  |  $';
   DemonPic[16] :='       $ v  $   $     \     > <   $  /  $ |  | $';
   DemonPic[17] :='       $/ \  /\/\$    /    <   >/\$  \ $  |  |$';
   DemonPic[18] :='       $   \% ^\$\    \ $ $ >/\/ $\$ /\$ /\  | $/\';
   DemonPic[19] :='      /$     ^  %%    ^ $$ </  \$  \/  \/  \/\$/  \';
   DemonPic[20] :='    / $          #\/^\^$ ^/    \  \   \   \$/    \';

   AngelPic[1]  :='       / / / /                     \ \ \ \  \';
   AngelPic[2]  :='                    ~~~~~~~~           ^ ';
   AngelPic[3]  :='          ((\      /--------\        //|\';
   AngelPic[4]  :='        (((  \    /  /-----\ \      / |||';
   AngelPic[5]  :='       ((((   \   | / `   '' \ |    /  |||)';
   AngelPic[6]  :='       ((((    |  | | *   * | |  |   ||| )';
   AngelPic[7]  :='      (((((    |  | |   ^   | |  |   ||| ))';
   AngelPic[8]  :='      v  (      \/  |\ <_> /|  \/    |||  ) )';
   AngelPic[9]  :='     }*{ (      /___|/-----\|___\   \|+|/ ) )';
   AngelPic[10] :='      ^\        -----        ----    {=} )) )';
   AngelPic[11] :='     (  |      /                 \  /{=} )) )';
   AngelPic[12] :='     (( |     /    /|   |    |\   \/ /=  )) )';
   AngelPic[13] :='     ( / \   /    / | _/ \_  | \    / + ))) )';
   AngelPic[14] :='      ( \ ---    /  |        |  \  /    ))) )';
   AngelPic[15] :='      ((|\      /  /| /   \  |\  \/    )))) ';
   AngelPic[16] :='       (| \____/  / \________/ \      ))))';
   AngelPic[17] :='        ((       /  |        |  \     ))))';
   AngelPic[18] :='         ((    _/   |        |   \_   ))';
   AngelPic[19] :='          (___/     |   ^    |     \__)';
   AngelPic[20] :='';

   Plane_Name[0]:='The Prime';
   Plane_Name[1]:='Avernus';    Plane_Name[2]:='Dis';    Plane_Name[3]:='Minauros';
   Plane_Name[4]:='Phlegethos'; Plane_Name[5]:='Stygia'; Plane_Name[6]:='Malbolge';
   Plane_Name[7]:='Maladomini'; Plane_Name[8]:='Caina';  Plane_Name[9]:='Nessus';

   DirectionName[North]:= ' North ';   DirectionName[South]:=' South ';
   DirectionName[East]:=  ' East ';    DirectionName[West]:= ' West ';

(******************************************************************************)
[External]Procedure Get_Num (Var Number: Integer; Display: Unsigned);External;
[External]Procedure Show_Image (Number: Pic_Type; Var Display: Unsigned);External;
[External]Function Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '):Char;External;
[External]Function Rendition_Set (Var T: Line): Unsigned;External;
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;
[External]Function Compute_AC (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function Get_Level (Level_Number: Integer; Maze: Level; PosZ: Vertical_Type:=0): [Volatile]Level;External;
[External]Function Pick_Character_Number (Party_Size: Integer; Current_Party_Size: Integer:=0;  Time_Out: Integer:=-1;
                                          Time_Out_Char: Char:='0'):[Volatile]Integer;External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Procedure Change_Status (Var Character: Character_Type; Status: Status_Type; Var Changed: Boolean);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Function Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function Alive (Character: Character_Type): Boolean;external;
[External]Procedure Backup_Party (Party: Party_Type; Party_Size: Integer);External;
[External]Function  Empty_Stack (Stack: Place_Stack):Boolean;external;
[External]Procedure Init_Stack (Var Stack: Place_Stack);External;
[External]Procedure Remove_Nodes (Var Stack: Place_Stack);External;
[External]Procedure Insert_Place (PosX,PosY: Horizontal_Type; PosZ: Vertical_Type; Var Stack: Place_Stack);External;
(******************************************************************************)

Function Has_Light: [Volatile]Boolean;

Begin { Has Light }
   Has_Light:=(Rounds_Left[Lght]>0) or (Rounds_Left[CoLi]>0);
End;  { Has Light }

(******************************************************************************)

Procedure Unpaste_All;

Begin { Unpaste All }
   SMG$unpaste_virtual_display(OptionsDisplay,Pasteboard);
   SMG$unpaste_virtual_display(CharacterDisplay,Pasteboard);
   SMG$unpaste_virtual_display(CommandsDisplay,Pasteboard);
   SMG$unpaste_virtual_display(SpellsDisplay,Pasteboard);
   SMG$unpaste_virtual_display(MessageDisplay,Pasteboard);
   SMG$unpaste_virtual_display(MonsterDisplay,Pasteboard);
   SMG$unpaste_virtual_display(ViewDisplay,Pasteboard);
End;  { Unpaste All }

(******************************************************************************)

[Global]Function Compute_Party_Size (Member: Party_Type;  Party_Size: Integer): Integer;

Var
   Temp,Character: Integer;

Begin { Compute Party Size }
   Temp:=0;
   For Character:=1 to Party_Size do
      If Alive (Member[Character]) then
         Temp:=Temp+1;
   Compute_Party_Size:=Temp;
End;  { Compute Party Size }

(******************************************************************************)

[Global]Function Show_Special (Member: [Unsafe]Party_Type:=0; Current_Party_Size: Integer:=0): Boolean;

Var
   Person,Psi_Chance: Integer;
   Temp: Boolean;

Begin { Show Special }
   PSI_Chance:=0;
   Temp:=(Rounds_Left[DetS]>0);
   If Current_Party_Size>0 then
      Begin
         For Person:=1 to Current_Party_Size do
            If Member[Person].Psionics then
               Psi_Chance:=Psi_Chance+Member[Person].DetectTrap; { TODO: Should check if character is alive and conscious }
         Temp:=Temp or Made_Roll (PSI_Chance);
      End;
   Show_Special:=Temp;
End;  { Show Special }

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Time_Effects (Position: Integer; Var Member: Party_Type; Party_Size: Integer);

Begin { Time Effects }
   { TODO: Enter this code }
End;  { Time Effects }

(******************************************************************************)

Procedure Ouch;

Begin { Ouch }
   SMG$Put_Chars (ViewDisplay,'Ouch!',5,8);
   Ring_Bell (ViewDisplay);
   Delay (0.5);
   SMG$Put_Chars (ViewDisplay,'     ',5,8);
End; { Ouch }

(******************************************************************************)

Procedure Get_New_Position (Direction: Direction_Type;  PosX,PosY: Horizontal_Type;  Var TempX,TempY: Horizontal_Type);

Begin
   TempX:=PosX;  Tempy:=PosY;
   Case direction of
        North:  TempY:=PosY-1;
        South:  TempY:=PosY+1;
        East:   TempX:=PosX+1;
        West:  TempX:=PosX-1;
   End;
   If TempX<1 then TempX:=20;
   If TempY<1 then TempY:=20;
   If TempX>20 then TempX:=1;
   If TempY>20 then TempY:=1;
End;

(******************************************************************************)

Procedure Attempt_to_Move (Cant_Move: Boolean;  TempX,TempY: Horizontal_Type; Var PosX,PosY: Horizontal_Type;
                           Var Previous_Spot: Area_Type;  Var New_Spot: Boolean);

Begin
   If Cant_Move then Ouch
   Else
      Begin
         Previous_Spot:=Maze.Room[PosX,PosY].Kind;
         PosX:=TempX;
         PosY:=TempY;
         Insert_Place (PosX,PosY,PosZ,Places);
         New_Spot:=True;
      End;
   SMG$Erase_Display (MessageDisplay);
End;

(******************************************************************************)

Procedure Move_Forward (Direction: Direction_Type;  Var New_Spot: Boolean; Var Previous_Spot: Area_Type);

Var
   Cant_Move: Boolean;
   TempX,TempY: Horizontal_Type;

Begin { Move Forward}
   Get_New_Position (Direction,PosX,PosY,TempX,TempY);
   Case Direction of
      North:      Cant_Move:=Not(Maze.Room[PosX,PosY].North in [Passage,Walk_Through]);
      South:      Cant_Move:=Not(Maze.Room[PosX,PosY].South in [Passage,Walk_Through]);
      East:       Cant_Move:=Not(Maze.Room[PosX,PosY].East in [Passage,Walk_Through]);
      West:       Cant_Move:=Not(Maze.Room[PosX,PosY].West in [Passage,Walk_Through]);
      Otherwise   Cant_Move:=True;
   End;

   Attempt_to_Move (Cant_Move,TempX,TempY,PosX,PosY,Previous_Spot,New_Spot);
End;  { Move Forward }

(******************************************************************************)

Procedure Kick_Door (Direction: Direction_Type;  Var New_Spot: Boolean; Var Just_Kicked: Boolean; Var Previous_Spot: Area_Type);

Var
  Cant_Move: Boolean;
  TempX,TempY: Horizontal_Type;

Begin { Move Forward}
  Get_New_Position (Direction,PosX,PosY,TempX,TempY);
  Cant_Move:=False;
  Case Direction of
     North:      If Maze.Room[PosX,PosY].North in [Wall,Transparent] then
                    Cant_Move:=True
                 Else
                    Just_Kicked:=Maze.Room[PosX,PosY].North in [Walk_Through,Door,Secret];
     South:      If Maze.Room[PosX,PosY].South in [Wall,Transparent] then
                    Cant_Move:=True
                 Else
                    Just_Kicked:=Maze.Room[PosX,PosY].South in [Walk_Through,Door,Secret];
     East:       If Maze.Room[PosX,PosY].East in [Wall,Transparent] then
                    Cant_Move:=True
                 Else
                    Just_Kicked:=Maze.Room[PosX,PosY].East in [Walk_Through,Door,Secret];
     West:       If Maze.Room[PosX,PosY].West in [Wall,Transparent] then
                    Cant_Move:=True
                 Else
                    Just_Kicked:=Maze.Room[PosX,PosY].West in [Walk_Through,Door,Secret];
     Otherwise Cant_Move:=True;
  End;

  Attempt_to_Move (Cant_Move,TempX,TempY,PosX,PosY,Previous_Spot,New_Spot);
End;  { Move Forward }

(******************************************************************************)

Procedure Move_Backward (Direction: Direction_Type;  Var New_Spot: Boolean);

Var
   Just_Kicked: Boolean;
   Previous_Spot: Area_Type;

Begin
   Case Direction of
        North:  Kick_Door (South,New_Spot,Just_Kicked,Previous_Spot);
        South:  Kick_Door (North,New_Spot,Just_Kicked,Previous_Spot);
        East:  Kick_Door (West,New_Spot,Just_Kicked,Previous_Spot);
        West:  Kick_Door (East,New_Spot,Just_Kicked,Previous_Spot);
   End;
End;

(******************************************************************************)

[Global]Function Detected_Secret_Door (Member: Party_Type; Current_Party_Size: Party_Size_Type;
                                       Rounds_Left: Spell_Duration_List): [Volatile]Boolean;

Var
   Character: Integer;
   Chance: Integer;

Begin
   Chance:=5;
   For Character:=1 to Current_Party_Size do
      Begin
         If Member[Character].Psionics then Chance:=Chance+Member[Character].DetectSecret;
         If Member[Character].Race in [Drow,Elven] then Chance:=Chance+35
         Else If Member[Character].Race=HfElf then Chance:=Chance+15;
      End;
      If (Rounds_Left[Lght]>0) or (Rounds_Left[CoLi]>0) then Chance:=Chance+50;

      If Made_Roll(Chance) then Detected_Secret_Door:=True
      Else                      Detected_Secret_Door:=False;
End;

(******************************************************************************)

Procedure Draw_View (Direction: Direction_Type;  New_Spot: Boolean; Member: Party_Type; Current_Party_Size: Party_Size_Type);

[External]Procedure Print_View (Direction: Direction_Type; Member: Party_Type;  Current_Party_Size: Party_Size_Type);External;

Begin
   SMG$Begin_Display_Update (ViewDisplay);
   SMG$Erase_Display (ViewDisplay);
   Print_View (Direction,Member,Current_Party_Size);
   If Not Has_Light and (Minute_Counter<46) and (Minute_Counter>9) then
      SMG$PUT_CHARS (ViewDisplay, ' A torch would be nice ',1,1);
   SMG$End_Display_Update(ViewDisplay);
   If New_Spot then SMG$Erase_Display (MessageDisplay);
End;

(******************************************************************************)

Procedure Spells_Box (Rounds_Left: Spell_Duration_List);

Var
   Rendition: Unsigned;
   Detect,Protection,Light,Compass,Levitate: Boolean;
   WeakDetect,WeakProtection,WeakLight,WeakCompass,WeakLevitate: Boolean;

Begin { Spells Box }
   Detect:=(Rounds_Left[DetS]>0);
   WeakDetect:=Detect and (Rounds_Left[DetS]<10);

   Light:=Has_Light;
   WeakLight:=Light and ((Rounds_Left[CoLi]<10) and (Rounds_Left[Lght]<10));

   Protection:=(Rounds_Left[DiPr]>0) or (Rounds_Left[HgSh]>0);
   WeakProtection:=Protection and ((Rounds_Left[DiPr]<10) or (Rounds_Left[HgSh]<10));

   Compass:=(Rounds_Left[Comp]>0);
   WeakCompass:=Compass and (Rounds_Left[Comp]<10);

   Levitate:=(Rounds_Left[Levi]>0);
   WeakLevitate:=Levitate and (Rounds_Left[levi]<10);

   SMG$Begin_Display_Update (SpellsDisplay);
   SMG$Erase_Display (SpellsDisplay);
   SMG$Put_Chars (SpellsDisplay,'Spells:',2,2);

   Rendition:=0;  If WeakLight then rendition:=SMG$M_REVERSE;
   If Light then        SMG$Put_Chars (SpellsDisplay,'Light',3,12,,Rendition)
   Else                 SMG$Put_Chars (SpellsDisplay,'     ',3,12);

   Rendition:=0;  If WeakCompass then rendition:=SMG$M_REVERSE;
   If Compass then      SMG$Put_Chars (SpellsDisplay,'Compass',4,12,,Rendition)
   Else                 SMG$Put_Chars (SpellsDisplay,'       ',4,12);

   Rendition:=0;  If WeakProtection then rendition:=SMG$M_REVERSE;
   If Protection then   SMG$Put_Chars (SpellsDisplay,'Protection',3,22,,Rendition)
   Else                 SMG$Put_Chars (SpellsDisplay,'          ',3,22);

   Rendition:=0;  If WeakLevitate then rendition:=SMG$M_REVERSE;
   If Levitate then     SMG$Put_Chars (SpellsDisplay,'Levitate',4,22,,Rendition)
   Else                 SMG$Put_Chars (SpellsDisplay,'        ',4,22);

   Rendition:=0;  If WeakDetect then rendition:=SMG$M_REVERSE;
   If Detect then       SMG$Put_Chars (SpellsDisplay,'Detect',3,36,,Rendition)
   Else                 SMG$Put_Chars (SpellsDisplay,'      ',3,36);

   SMG$End_Display_Update (SpellsDisplay);
   SMG$Set_Cursor_ABS (SpellsDisplay);
End; { Spells Box }

(******************************************************************************)

Procedure Print_A_Character_Line (Character: Character_Type; Position: Integer);

Var
   Rendition: Unsigned;
   AlignName: [External,Readonly]Array [Align_Type] of Packed Array [1..7] of char;
   ClassName: [External,Readonly]Array [Class_Type] of Varying [13] of char;
   StatusName: [External,Readonly]Array [Status_Type] of Varying [14] of char;

Begin { Print a Character Line }
   SMG$Put_Chars (CharacterDisplay,
       '   '
       +Pad(Character.Name,' ',20)
       +'  ');
   SMG$Put_Chars (CharacterDisplay,
       '  '
       +String(Character.Level,3)
       +'  '
       +AlignName[Character.Alignment][1]
       +'-' );
   SMG$Put_Chars (CharacterDisplay,
       Pad(ClassName[Character.Class],
           ' ',14));
   SMG$Put_Chars (CharacterDisplay,
       String(10-Character.Armor_Class,3)
       +'     '
       +String(Character.Curr_HP,5) );
   If Character.Regenerates>0 then
      SMG$Put_Chars (CharacterDisplay,
          '+')
   Else
      If Character.Regenerates<0 then
         SMG$Put_Chars (CharacterDisplay,
             '-')
      Else
         SMG$Put_Chars (CharacterDisplay,
             ' ');
   SMG$Put_Chars (CharacterDisplay,
       '  ');
   If (Character.Status=Healthy) then
      SMG$Put_Line (CharacterDisplay,
      Substr(String(Character.Max_HP,4),1,4),0 )
   Else
      Begin
         SMG$Put_Chars (CharacterDisplay,
             ' ');
         Rendition:=0;
         Case Character.Status of
                NoStatus,Healthy,Afraid,Asleep,Zombie,Insane: ;
                Dead,Deleted,Paralyzed,Petrified,Ashes: Rendition:=SMG$M_REVERSE;
                Poisoned: Rendition:=SMG$M_BLINK+SMG$M_BOLD+SMG$M_REVERSE;
                Otherwise Rendition:=SMG$M_REVERSE;
         End;
         SMG$Put_Line (CharacterDisplay,StatusName[Character.Status],0,Rendition);
      End;
End;  { Print a Character Line }

(******************************************************************************)

[Global]Procedure Print_Party_Line (Member: Party_Type;  Party_Size,Position: Integer);

Begin { Print Party Line }
   SMG$Put_Chars (CharacterDisplay,CHR(Position+ZeroOrd),Position+1,2,1);
   If Position<=Party_Size then
      Print_A_Character_Line (Member[Position],Position);
End;  { Print Party Line }

(******************************************************************************)

[Global]Procedure Party_Box (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                             Var Leave_Maze: Boolean);

Const
    Character_Window_Heading = ' #   Character '
        +'Name         Level  Class            '
        +'AC     Hits   Status';

Var
  Person: Integer;

Begin { Party Box }
   SMG$Begin_Display_Update (CharacterDisplay);
   SMG$Put_Chars(CharacterDisplay,Character_Window_Heading,1,1);
   For Person:=1 to 6 do
      Print_Party_Line (Member,Party_Size,Person);
   SMG$End_Display_Update (CharacterDisplay);
   Current_Party_Size:=Compute_Party_Size (Member,Party_Size);
   Leave_Maze:=Leave_Maze or (Current_Party_Size=0);
End;  { Party Box }

(******************************************************************************)

{ TODO: Enter this code }

Function Party_Movable (Member: Party_Type; Current_Party_Size: Party_Size_Type): Boolean;

Var
   Temp: Boolean;
   Charnum: Integer;

Begin { Party Movable }
  Temp:=False;
  For CharNum:=1 to Current_Party_Size do
     If Member[CharNum].Status in [Healthy,Poisoned,Insane] then
        Temp:=True;
  Party_Movable:=Temp;
End;  { Party Movable }

(******************************************************************************)

Procedure Check_For_Encounter (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                               Var New_Spot: Boolean;  Just_Kicked: Boolean; Var Time_Delay: Integer);

Begin
   { TODO: Enter this code }
End;


Procedure Enter_Grave_Yard (Var Member: Party_Type; Party_Size: Integer);

Begin
   { TODO: Enter this code }
End;

Function Game_Won (Member: Party_Type; Party_Size: Integer): Boolean;

Begin
   { TODO: Enter this code }
  Game_Won:=False;
End;

{ TODO: Enter this code }

(******************************************************************************)

Procedure Init_Windows (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                                Var Leave_Maze: Boolean;  NewSpot: Boolean);

Begin { Init Windows }
  SMG$Label_Border (ViewDisplay);
  If Not Dont_Draw then Draw_View (Direction,NewSpot,Member,Current_Party_Size);
  Party_Box (Member,Current_Party_Size,Party_Size,Leave_Maze);
  Spells_Box (Rounds_Left);
End;  { Init Windows }

(******************************************************************************)

Procedure Draw_Screen (New_Spot: Boolean; Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                               Party_Size: Integer);

Begin { Draw Screen }
   Init_windows (Member,Current_Party_Size,Party_Size,Leave_Maze,New_Spot);
   SMG$Paste_Virtual_Display (CharacterDisplay,Pasteboard,CharY,CharX);
   SMG$Paste_Virtual_Display (CommandsDisplay,Pasteboard,MonY,MonX);
   SMG$Paste_Virtual_Display (SpellsDisplay,Pasteboard,SpellsY,SpellsX);
   SMG$Paste_Virtual_Display (ViewDisplay,Pasteboard,ViewY,ViewX);
   SMG$Paste_Virtual_Display (MessageDisplay,Pasteboard,MsgY,MsgX);
End;  { Draw Screen }

(******************************************************************************)

[External]Procedure Camp (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                                 Var Leave_Maze,Auto_Save: Boolean; Var Time_Delay: Integer);external;

(******************************************************************************)

{ TODO: Enter this code }

(******************************************************************************)

Procedure Initialize_Party (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type; Party_Size: Integer);

Var
   Character: Integer;

Begin { Initialize Party }
   For Character:=1 to Party_Size do
      Begin
         Member[Character].Regenerates:=Regenerates (Member[Character],PosZ);
         Member[Character].Armor_Class:=Compute_Ac (Member[Character],PosZ);
         Member[Character].Attack.Berserk:=False;
      End;
   Current_Party_Size:=Compute_Party_Size (Member,Party_Size);
End;  { Initialize Party }

(******************************************************************************)
[External]Procedure Create_Null_SaveFile;External;
(******************************************************************************)

Procedure Initialize (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;  Var Maze: Level;
                      Var Time_Delay: Integer;  Var Round_Counter: Integer; Var Previous_Spot: Area_Type);

[External]Procedure Kill_Save_File;External;
[External]Procedure Read_Messages (Var Messages: Message_Group);External;
[External]Function Load_Saved_Game: [Volatile]Save_Record;External;

Var
   Saved_Game_Record: Save_Record;
   Show_Place: Boolean;

Begin { Initialize }
   Leave_Maze:=False;        Direction:=North;
   Time_Delay:=300;
   Maze:=Zero; PosX:=1;     PosY:=20;    PosZ:=1;


   Previous_Spot:=Corridor;
   Round_Counter:=1;         Minute_Counter:=1;

   Read_Messages (Messages);
   Init_Stack (Places);
   Rounds_Left:=Zero;
   Initialize_Party (Member,Current_Party_Size,Party_Size);

   Maze:=Get_Level (1,Maze);

   Show_Place:=Auto_Load;
   Dont_Draw:=Not Show_Place;
   If Auto_Load then
      Begin
         Saved_Game_Record:=Load_Saved_Game;
         Initialize_Party (Member,Current_Party_Size,Party_Size);
         Rounds_Left:=Saved_Game_Record.Spells_Casted;
         Time_Delay:=Saved_Game_Record.Time_Delay;
         Direction:=Saved_Game_Record.Direction;

         Maze:=Saved_Game_Record.Current_Level;
         PosX:=Saved_Game_Record.PosX;  PosY:=Saved_Game_Record.PosY;  PosZ:=Saved_Game_Record.PosZ;
         Game_Saved:=False;  Auto_load:=False;

         Create_Null_SaveFile;

         Kill_Save_File;
         SMG$Unpaste_Virtual_Display (ScreenDisplay,Pasteboard);
         SMG$Erase_Display(ScreenDisplay);
      End
   Else
      SMG$Begin_Pasteboard_Update (Pasteboard);
   Insert_Place (PosX,PosY,PosZ,Places);
   Draw_Screen (TRUE,Member,Current_Party_Size,Party_Size);
   If Not Show_Place then Show_Image (37,ViewDisplay);
   Party_Box (Member,Current_Party_Size,Party_Size,Leave_Maze);
   If Rounds_Left[Comp]>0 then SMG$Label_Border (ViewDisplay,DirectionName[Direction],SMG$K_TOP);

 { SMG$END_PASTEBOARD_UPDATE in CAMP module }

End;  { Initialize }

(******************************************************************************)

{ TODO: Enter this code }

Procedure Handle_Completed_Quest (Var Member: Party_Type;  Party_Size: Integer);
Begin
   { TODO: Enter this code }
End;

{ TODO: Enter this code }

Procedure Fix_Compass (Direction: Direction_Type;  Rounds_Left: Spell_Duration_List);

Begin { Fix Compass }
  If Rounds_Left[Comp]>0 then SMG$Label_Border (ViewDisplay,DirectionName[Direction],SMG$K_TOP)
  Else                        SMG$Label_Border (ViewDisplay);
End;  { Fix Compass }

(******************************************************************************)

Procedure Update_Status (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                               Var Leave_Maze: Boolean; Rounds_Left: Spell_Duration_List);

Begin
   Spells_Box (Rounds_Left);
   Party_Box (Member,Current_Party_Size,Party_Size,Leave_Maze);
End;

{ TODO: Enter this code }

(******************************************************************************)

Procedure New_Round (Var Round_Counter: Integer; Var Member: Party_Type; Current_Party_Size,Party_Size: Integer);

Var
   Character: Integer;
   Spell: Spell_Name;

Begin
  Round_Counter:=1;
  For Spell:=Crlt to DetS do
     If Rounds_Left[Spell]>0 then
        Rounds_Left[Spell]:=Rounds_Left[Spell]-1;

  For Character:=1 to Current_Party_Size do
     Time_Effects (Character,Member,Party_Size);

  Party_Box (Member,Current_Party_Size,Party_Size,Leave_Maze);
  Spells_Box (Rounds_Left);
End;

(******************************************************************************)

Procedure Set_Up_Camp (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                               Var Leave_Maze: Boolean;  Var Auto_Save,New_Spot: Boolean;  Var Time_Delay: Integer);

Var
   OldZ: Vertical_Type;

Begin
   OldZ:=PosZ;

   SMG$Begin_Pasteboard_Update (Pasteboard);
   Camp (Member,Current_Party_Size,Party_Size,Leave_Maze,Auto_Save,Time_Delay);
   If Not Auto_Save then
      Begin
         New_Spot:=True;
         Maze:=Get_Level (PosZ,Maze,OldZ);
         SMG$Begin_Pasteboard_Update (Pasteboard);
         SMG$Set_Cursor_Mode (Pasteboard,1);
         Spells_Box (Rounds_Left);
         Party_Box (Member, Current_Party_Size,Party_Size,Leave_Maze);
         Draw_View (Direction,New_Spot,Member,Current_Party_Size);
         SMG$End_Pasteboard_Update (Pasteboard);
      End;
End;

(******************************************************************************)

Procedure Turn_Left (Var Direction: Direction_Type);

Begin
   If Direction=North then Direction:=West
   Else                    Direction:=Pred (Direction);
End;

(******************************************************************************)

Procedure Turn_Right (Var Direction: Direction_Type);

Begin
   If Direction=West then Direction:=North
   Else                   Direction:=Succ(Direction);
End;

(******************************************************************************)

Procedure Change_Time (Var Time_Delay: Integer);

Var
   Change: Integer;

Begin
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Line (MessageDisplay,'Current time delay: '+String(Time_Delay));
   SMG$Put_Chars (MessageDisplay,'New Delay (0-999, -1 exits) :');
   Get_Num (Change,MessageDisplay);
   If (Change>-1) and (change<1000) then
      Time_Delay:=Change;
   SMG$Erase_Display (MessageDisplay);
End;


Function Print_Exit (exit: Exit_Type): Line;
Begin
  case exit of
    Passage: return 'Passage';
    Wall: return 'Wall';
    Door: return 'Door';
    Secret: return 'Secret';
    Transparent: return 'Transparent';
    Walk_Through: return 'Walk_Through';
    otherwise return 'Unknown';
  end;
End;

(******************************************************************************)

Procedure Print_Debug_Room_Info(PosX,PosY: Horizontal_Type);

Var
   Spot: Room_Record;

Begin
   Spot:=Maze.Room[PosX,PosY];
   SMG$Put_Line (MessageDisplay,
      'North: '
      +Print_Exit(Spot.North)
      +', South: '
      +Print_Exit(Spot.South)
      +', East: '
      +Print_Exit(Spot.East)
      +', West: '
      +Print_Exit(Spot.West));
End;

function print_direction(Direction: Direction_Type): Line;

Begin
   Case Direction of
      North: return 'North';
      South: return 'South';
      East: return 'East';
      West: return 'West';
      Otherwise return 'Unknown';
   End;
End;


(******************************************************************************)

Procedure Display_Location_Info (Direction: Direction_Type);

Begin
  SMG$Put_Line (MessageDisplay,
      'Location is X:'
      +String(PosX)
      +', Y: '
      +String(PosY)
      +', Z: '
      +String(PosZ));
   SMG$Put_line(MessageDisplay,'Facing: ' + print_direction(direction));

  Print_Debug_Room_Info(PosX,PosY);
End;

Procedure Make_Move (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                             Var Leave_Maze: Boolean; Var Time_Delay: Integer;  Var Auto_Save: Boolean;
                             Var Direction: Direction_Type;  Var Round_Counter: Integer;  Var Minute_Counter: Real;
                             Var New_Spot,Just_Kicked: Boolean; Var Previous_Spot: Area_Type);

Var
   Options: Char_Set;
   Answer: Char;

Begin
   Options:=['T','K','F',Up_Arrow,'L','R','C','S',Left_Arrow,Right_Arrow,'E'];
   If Not Party_Movable (Member,Current_Party_Size) then Options:=['S','T'];
   Answer:=Make_Choice (Options,Time_Out:=5,Time_Out_Char:='S');
   Just_Kicked:=False;
   Round_Counter:=Round_Counter+1;
   If Round_Counter=5 then New_Round (Round_Counter,Member,Current_Party_Size,Party_Size);
   Minute_Counter:=Minute_Counter+1;
   Case Answer of
                    'S': Update_Status (Member,Current_Party_Size,Party_Size,Leave_Maze,Rounds_Left);
                    'C': Set_Up_Camp   (Member,Current_Party_Size,Party_Size,Leave_Maze,Auto_Save,New_Spot,Time_Delay);
                    'K': Kick_Door     (Direction,New_Spot,Just_Kicked,Previous_Spot);
          Up_Arrow, 'F': Move_Forward  (Direction,New_Spot,Previous_Spot);
        Left_Arrow, 'L': Turn_Left     (Direction);
       Right_Arrow, 'R': Turn_Right    (Direction);
                    'T': Change_Time   (Time_Delay);
   End;
   If Not Auto_Save then Fix_Compass (Direction,Rounds_Left);
   If debug then
      Begin
         Display_Location_Info (Direction);
      End;
End;

(******************************************************************************)

Procedure Handle_Room_Special (Var New_Spot: Boolean; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                                           Party_Size: Integer;  Var Leave_Maze: Boolean;  Var Previous_Spot: Area_Type;
                                       Var Time_Delay: Integer);

Begin
{ TODO: Enter this code }
End;

(******************************************************************************)

Procedure Spend_Time_In_Maze (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                                      Var Time_Delay: Integer;  Var Previous_Spot: Area_Type;  Var Round_Counter: Integer;
                                      Var Alarm_Off: Boolean);

Var
   Just_Kicked,New_Spot: Boolean;

Begin
   New_Spot:=True;  Just_Kicked:=False;
   Repeat
      Begin
         SMG$Begin_Display_Update (CharacterDisplay);
         Update_Status (Member,Current_Party_Size,Party_Size,Leave_Maze,Rounds_Left);
         SMG$End_Display_Update (CharacterDisplay);
         { If Not (New_Spot or Leave_Maze or Dont_Draw) then TODO: Debug only. }
            Draw_View (Direction,New_Spot,Member,Current_Party_Size);
         Dont_Draw:=False;
         Handle_Room_Special (New_Spot,Member,Current_Party_Size,Party_Size,Leave_Maze,Previous_Spot,Time_Delay);

         { Whatever special checking will occur here }

         If (Current_Party_Size=0) or ((PosX=0) and (PosY=0) and (PosZ=0)) then
            Leave_Maze:=True;
         If Not (Leave_Maze) then
            Make_Move (Member,Current_Party_Size,Party_Size,Leave_Maze,Time_Delay,Auto_Save,Direction,Round_Counter,Minute_Counter,
                       New_Spot,Just_Kicked,Previous_Spot);
         Leave_Maze:=Leave_Maze or (Current_Party_Size=0) or ((PosX=0) and (PosY=0) and (PosZ=0));
         If Not (Leave_Maze or Auto_Save) then
            Check_For_Encounter (Member,Current_Party_Size,Party_Size,New_Spot,Just_Kicked,Time_Delay);
      End;
   Until Leave_Maze or Auto_Save;
End;

(******************************************************************************)

Procedure Set_Up_Windows (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                                  Var Maze: Level);

Begin
   If Not Dont_Draw then Draw_View (Direction,TRUE,Member,Current_Party_Size);
   Party_Box (Member,Current_Party_Size,Party_Size,Leave_Maze);
End;

(******************************************************************************)

Procedure Get_Out_of_Maze (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type; Party_Size: Integer);

Var
   Character: Integer;

[External]Procedure Print_Character_Line (CharNo: Integer; Party: Party_Type; Party_Size: Integer);External;

Begin
   Rounds_Left:=Zero;
   For Character:=1 to Current_Party_Size do
      Time_Effects (Character,Member,Party_Size);

   Current_Party_Size:=Compute_Party_Size (Member,Party_Size);
   For Character:=1 to 6 do
       Print_Character_Line (Character,Member,Current_Party_Size);

   If Current_Party_Size=0 then
      Begin
         SMG$Begin_Pasteboard_Update (Pasteboard);
         Enter_Grave_Yard (Member,Party_Size)
      End
   Else
      If Game_Won (Member,Party_Size) then
         Handle_Completed_Quest (Member,Party_Size)
      Else
         Begin
            SMG$Begin_Pasteboard_Update (Pasteboard);
            Unpaste_All;
            SMG$End_Pasteboard_Update (Pasteboard);
         End;
End;

(******************************************************************************)

[Global]Procedure Enter_Maze (Party_Size: Integer; Var Member: Party_Type);

Var
   Current_Party_Size: Party_Size_Type;
   Round_Counter,Time_Delay: Integer;
   Previous_Spot: Area_Type;
   Alarm_Off: Boolean;

Begin { Enter Maze }
   Initialize (Member,Current_Party_Size,Party_Size,Maze,Time_Delay,Round_Counter,Previous_Spot);
   Camp (Member, Current_Party_Size,Party_Size,Leave_Maze,Auto_Save,Time_Delay);
   If Not Auto_Save then
      Begin
         Set_Up_Windows    (Member,Current_Party_Size,Party_Size,Maze);
         Spend_Time_In_Maze (Member,Current_Party_Size,Party_Size,Time_Delay,Previous_Spot,Round_Counter,Alarm_Off);
         Get_out_of_Maze    (Member,Current_Party_Size,Party_Size);
      End
   Else
      Unpaste_All;
   Remove_Nodes (Places);
End;  { Enter Maze }
End.  { Maze }

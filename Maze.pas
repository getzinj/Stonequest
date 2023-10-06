[Inherit ('Types','SMGRTL','STRRTL')]Module Maze;

{ TODO: Enter this code }

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
         Insert_Place (PosX,PosY,Places);
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

Procedure Draw_View (Direction: Direction_Type;  New_Spot: Boolean; Member: Party_Type; Current_Party_Size; Party_Size_Type);

[External]Procedure Print_View (Direction: Direction_Type; Member: Party_Type;  Current_Party_Size: Party_Size_Type);External;

Begin
   SMG$Begin_Display_Update (ViewDisplay);
   SMG$Erase_Display (ViewDisplay);
   Print_View (Direction,Member,Current_Party_Size);
   If Not Has_Light and (Minute_Counter<46) and (Minute_Counter>9) then
      SMG$PUT_CHARS (ViewDisplay, ' A touch would be nice ',1,1);
   SMG$End_Display_Update(ViewDisplay);
   If New_Spot then SMG$Erase_Display (MessageDisplay);
End;

(******************************************************************************)

[Global]Procedure Party_Box (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                             Var Leave_Maze: Boolean);

Begin
   { TODO: Enter this code }
End;


{ TODO: Enter this code }

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
         SMG$Erase_Display);
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

[Global]Procedure Enter_Maze (Party_Size: Integer; Var Member: Party_Type);

Begin { Enter Maze }

{ TODO: Enter this code }

End;  { Enter Maze }
End.  { Maze }

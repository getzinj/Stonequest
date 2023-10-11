[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','STRRTL')]Module ViewShared;

Const
  debug = true;


Var
   Rounds_Left: [External]Array [Spell_Name] of Unsigned;
   Direction: [External]Direction_Type;
   Maze: [External]Level;

(******************************************************************************)

[Global]Function Sight_Blocked (Exit: Exit_Type): Boolean;

Begin
   Sight_Blocked:=Not debug and Not (Exit in [Transparent,Passage]);
End;

(******************************************************************************)

[Global]Function Is_Special (Spot: Room_Record): Boolean;

Begin
   Is_Special:=(Maze.Special_Table[Spot.Contents].Special<>Nothing);
End;

(******************************************************************************)

[Global]Function Is_Stairs (Spot: Room_Record): Boolean;

Begin
   Is_Stairs:=(Maze.Special_Table[Spot.Contents].Special=Stairs);
End;

(******************************************************************************)

[Global]Procedure Get_Bearings (Spot: Room_Record; Var Up,Down,Left,Right: Exit_Type);

Begin
   Case Direction of
        North: Begin
                  Up:=Spot.North;
                  Down:=Spot.South;
                  Left:=Spot.West;
                  Right:=Spot.East;
               End;
        South: Begin
                  Up:=Spot.South;
                  Down:=Spot.North;
                  Left:=Spot.East;
                  Right:=Spot.West;
               End;
        East: Begin
                  Up:=Spot.East;
                  Down:=Spot.West;
                  Left:=Spot.North;
                  Right:=Spot.South;
               End;
        West: Begin
                  Up:=Spot.West;
                  Down:=Spot.East;
                  Left:=Spot.South;
                  Right:=Spot.North;
               End;
   End;
End;

(******************************************************************************)

[Global]Function Has_Light: [Volatile]Boolean;

Begin
   Has_Light:=debug or (Rounds_Left[Lght]>0) or (Rounds_Left[CoLi]>0);
End;
End. { View Shared }

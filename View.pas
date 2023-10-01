[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','STRRTL')]Module View;

Type
    Section_Type = (Top,Middle,Bottom);
    Horizontal_Section_Type = (Left_S,Center,Right_S);
    Side = Varying[3] of char;
    View_Line = Packed Array [1..9] of Char;
    View_Matrix = Array [1..9] of View_Line;

Var
   Rounds_Left: [External]Array [Spell_Name] of Unsigned;
   Direction: [External]Direction_Type;
   Maze: [External]Level;
   PosX,PosY,PosZ: [Byte,External]0..20;

   ViewDisplay:  [External]Unsigned;

(******************************************************************************)
[External]Function Show_Special (Member: [Unsafe]Party_Type:=0;  Current_Party_Size: Integer:=0):Boolean;External;
[External]Function Detected_Secret_Door (Member: Party_Type;  Current_Party_Size: Party_Size_Type;Rounds_Left: SpellDurationList):[Volatile]Boolean;External;
(******************************************************************************)

Function Sight_Blocked (Exit: Exit_Type): Boolean;

Begin
   Sight_Blocked:=Not (Exit in [Transparent,Passage]);
End;

(******************************************************************************)

Function Is_Special (Spot: Room_Record): Boolean;

Begin
   Is_Special:=(Maze.Special_Table[Spot.Contents].Special<>Nothing);
End;

(******************************************************************************)

Function Is_Stairs (Spot: Room_Record): Boolean;

Begin
   Is_Stairs:=(Maze.Special_Table[Spot.Contents].Special=Stairs);
End;

(******************************************************************************)

Procedure Get_Bearings (Spot: Room_Record; Var Up,Down,Left,Right: Exit_Type);

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

Function Symbol_Type (Symbol: Exit_Type; Member: Party_Type;  Current_Party_Size: Integer): [Volatile]Char;

Begin
   Case Symbol of
            Passage:  Symbol_Type:=' ';
        Transparent:  If Not Show_Special (Member, Current_Party_Size) then
                         Symbol_Type:=' '
                      Else
                         Symbol_Type:='*';
             Secret:  If Detected_Secret_Door (Member,Current_Party_Size,Rounds_Left) then
                         Symbol_Type:='$'
                      Else
                         Symbol_Type:='#';
               Wall:  Symbol_Type:='#';
       Walk_Through:  If Not Show_Special (Member,Current_Party_Size) then
                         Symbol_Type:='#'
                      Else
                         Symbol_Type:=':';
              Door:  Symbol_Type:='+';
   End;
End;

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Print_View (Direction: Direction_Type; Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Begin { Print View }

{ TODO: Enter this code }

End;  { Print View }
End.  { View }

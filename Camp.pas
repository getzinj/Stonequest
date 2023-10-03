[Inherit ('Types','SMGRTL','SYS$LIBRARY:STARLET')]Module Camp;

{ This module allows the adventuring party to set up camp inside the maze, and perform such tasks as casting spells or re-
  ordering the party.  By the way, does anybody out there have any idea on why they call that stupid file STARLET? }

Const
   ZeroOrd=ORD('0');

Type
   ItemSet   = ^ItemNode;                    { Pointer to a linked list of items }
   ItemNode  = Record
                 Identified:   Boolean;      { Does anybody know what it is? }
                 Owner_Number: 1..6;         { Who owns the item? }
                 Item_Number:  Integer;      { Which item is it? }
                 Next_Item:    ItemSet;      { Pointer to the rest of the items }
               End;
   Item_Pool = Array [Item_Type] of ItemSet; { List for each type of item }

Var { External }
   CharacterDisplay,Pasteboard,CommandsDisplay,SpellsDisplay,ViewDisplay,MessageDisplay,CampDisplay: [External]Unsigned;
   MonsterDisplay,ScreenDisplay:        [External]Unsigned;
   Maze:                                [External]Level;
   PosX,PosY,PosZ:                      [External,Byte]0..20;
   Direction:                           [External]Direction_Type;
   Auto_Load,Game_Saved,Leave_Maze:     [External]Boolean;
   Minute_Counter:                      [External]Real;
   Item_List:                           [External]List_of_Items;
   Rounds_Left:                         [External]Array [Spell_Name] of Unsigned;

(******************************************************************************)
[External]Procedure Party_Box (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                             Var Leave_Maze: Boolean);External;
[External]Procedure Error_Window (FileType: Line);External;
[External]Procedure Read_Error_Window (FileType: Line; Code: Integer:=0);External;
[External]Procedure Restore_Spells (Var Character: Character_Type);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Function Alive (Character: Character_Type): Boolean;External;
[External]Function Make_Choice (Choices: Char_Set;  Time_Out:  Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
(******************************************************************************)

Procedure Unpaste_All;

{ This procedure will unpaste the maze displays from the screen.  This is used in such a case when we want to go from camp directly
  to Kyrn without showing the maze, e.g. when teleporting. }

Begin { Unpaste All }
   SMG$Unpaste_Virtual_Display (CharacterDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (CommandsDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (SpellsDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (ViewDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (MessageDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (CampDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (MonsterDisplay,Pasteboard);
End;  { Unpaste All }

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Camp (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                        Var Leave_Maze,Auto_Save: Boolean; Var Time_Delay: Integer);

Begin { Camp }

{ TODO: Enter this code }

End;  { Camp }
End.  { Camp }

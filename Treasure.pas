[Inherit ('Types','SMGRTL')]Module Edit_Treasure_Types;

Type
   Traps_Set = Set of Trap_Type;

Var
   ScreenDisplay: [External]Unsigned;
   Item_List: [External]List_of_Items;
   TrapName: [External]Array [Trap_Type] of Varying [20] of Char;
   Cat:      Array [1..5] of Packed Array [1..24] of char;

(******************************************************************************)
[External]Function String(Num: Integer; Len: Integer:=0): Line;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): Char;External;
[External]Function Get_Num (Display: Unsigned):Integer;External;
(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Edit_Treasures (Var Treasure: List_of_treasures);
Begin { Edit Treasures }

{ TODO: Enter this code }

End;  {Edit Treasures }
End.  { Edit Treasure Types }

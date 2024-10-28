(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('LIBRTL', 'SMGRTL')]Module Demo;

Type
   Line = Varying [80] of Char;

Var
   Version_Number:  [External]Line;
   ScreenDisplay:   [External]Unsigned;

(*****************************************************************************)

Procedure Go_Up (Title: Line);

Var
  Y: Integer;

Begin { Go Up }
   For Y:=22 downto 1 do
      Begin
         SMG$Put_Chars (ScreenDisplay,Title,Y,32);
         LIB$WAIT (2/100);
      End;
End;  { Go Up }

(*****************************************************************************)

Procedure Trail;

Var
   Y: Integer;

Begin { Trail }
   For Y:=23 downto 2 do
      Begin
         SMG$Erase_Line (ScreenDisplay,Y,1);
         LIB$Wait (4/100);
      End;
End;  { Trail }

(*****************************************************************************)

Procedure Go_Down (Title: Line);

Var
   Y: Integer;
   Rendition:  Unsigned;

Begin { Go Down }
   For Y:=1 to 5 do
      Begin
         Rendition:=0;
         If Y=5 then Rendition:=1;
         SMG$Put_Chars (ScreenDisplay,Title,Y,32,Rendition);
         LIB$WAIT (2/100);
      End;
End;  { Go Down }

(*****************************************************************************)

Procedure Erase_Trail;

Var
   Y: Integer;

Begin { Erase Trail }
   For Y:=1 to 4 do
      Begin
         SMG$Erase_Line (ScreenDisplay,Y,1);
         LIB$Wait (4/100);
      End;
End;  { Erase Trail }

(*****************************************************************************)

Procedure Finish;

Begin { Finish }
   SMG$Put_Chars (ScreenDisplay,'------ ----- ----',56,32);
   Erase_Trail;
End;  { Finish }

(*****************************************************************************)

Procedure Initialize (Heading: Line);

Begin { Initialize }
   SMG$Erase_Display (ScreenDisplay);
   SMG$Put_Chars (ScreenDisplay,Heading,23,32);
End;  { Initialize }

(*****************************************************************************)

[Global]Procedure Demo;


Begin { Demo }
  Initialize ('Stone Quest '+Version_Number);
  Go_up      ('Stone Quest '+Version_Number);
  Trail;
  Go_Down    ('Stone Quest '+Version_Number);
  Finish;
End;  { Demo }
End.  { Demo }

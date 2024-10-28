(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types','SYS$LIBRARY:STARLET','LIBRTL','SMGRTL')]Module Help;

{ This module enables the on-line help function, which can be received by typing the HELP key when in Stonequest }

Var
   HelpDisplay,Pasteboard: [External]Unsigned;
   Authorized:             [External]Boolean;

(******************************************************************************)
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[Asynchronous,External]Function Oh_No (Var SA: Array [$u1..$u2:Integer] of Integer;  Var MA: Array [$u3..$u4:Integer] of [Unsafe]Integer):[Unsafe]Integer;external;
[Asynchronous,Unbound,External]Function LBR$OUTPUT_HELP (
                %Ref Output_Routine: Unsigned;
                %Ref Output_Width: Unsigned:=%Immed 0;
                %StDescr Line_Desc: Packed Array [$l1..$u1:integer] of char:=%immed 0;
                %StDescr Library_Name: Packed Array [$l2..$u2:integer] of char:=%immed 0;
                %Ref Flags: Unsigned:=%Immed 0;
                %Ref Input_Routine: Unsigned:=%Immed 0)
                     : Integer;External;
[Asynchronous,External]Function Lib$Put_Output (%StDescr output: Packed Array [$l3..$u3:Integer] of char)
                     : Unsigned;External;
[Asynchronous,External]Function Lib$Get_Input (%StDescr output: Packed Array [$l4..$u4:Integer] of char)
                     : Unsigned;External;
(******************************************************************************)

[Global]Procedure Help;

{ This procedure calls the HELP routine, LBR$OUTPUT_HELP to print out Stonequest's help.  Note: the output from LBR$OUTPUT_HELP is
  not sent to the SMG$ pasteboard, so SMG$ does not know it's there.  Therefore, a SMG$REPAINT_SCREEN is called to wipe off the non-
  SMG$ output }

Const
   Flag = HLP$M_PROMPT + HLP$M_HELP;

Var
   Width: Unsigned;
   FileTxt,HelpTxt: Line;

Begin { Help }
   SMG$Erase_Display (HelpDisplay);
   SMG$Paste_Virtual_Display (HelpDisplay,Pasteboard,1,1);

   Width:=80;

   FileTxt:='STONEQUEST.HLB';

   HelpTxt:=' ';

   { If Not Authorized then } Revert;  { Turn off Moria's condition handler }

   Cursor;

   { Run LBR$OUTPUT_HELP }

   LBR$OUTPUT_HELP (%Immed LIB$Put_Output,Width,HelpTxt+'',FileTxt+'',Flags:=Flag,Input_Routine:=%Immed LIB$GET_INPUT);

   No_Cursor;

   { If Not Authorized then } { Establish (Oh_No); } { Turn Moria's condition handler back on }

   { Unpaste the screen, and get rid of the non-SMG$ garbage printed by LBR$OUTOUT_HELP }

   SMG$Unpaste_Virtual_Display (HelpDisplay,Pasteboard);
   SMG$Repaint_Screen (Pasteboard);
End;  { Help }
End.  { Help }

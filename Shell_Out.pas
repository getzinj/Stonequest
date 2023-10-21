[Inherit ('Types','LIBRTL','SMGRTL')]Module Shell_Out;

Var
   Pasteboard,ShellDisplay: [External]Unsigned;
   Authorized,Trap_Authorized_Error: [External]Boolean;

(******************************************************************************)
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Procedure Dont_Trap_Out_of_Bands;External;
[External]Procedure Trap_Out_of_Bands;External;
[External,Unbound]Procedure Message_Trap;external;
{ 2023-09-21 JHG: Located the missing definition at https://github.com/dungeons-of-moria/vms-moria/blob/55058f595a810fb8576f898e76a4eb2937fa362c/source/moria.pas#L26 }
[Asynchronous,External]Function Oh_No (Var SA: Array [$u1..$u2:Integer] of Integer;  Var MA: Array [$u3..$u4:Integer] of [Unsafe]Integer):[Unsafe]Integer;external;
[External]Procedure No_Controly;External;
[External]Procedure Controly;External;
(******************************************************************************)


[Global]Procedure Shell_Out;

Begin { Shell Out }
  Dont_Trap_Out_of_Bands;
  SMG$Disable_Broadcast_Trapping (Pasteboard);

  { If Not Authorized or Trap_Authorized_Error then Revert; } { Turn off Moria's condition handler }

  SMG$Erase_Display (ShellDisplay);
  SMG$Put_Line (ShellDisplay,'[Entering DCL subprocess; type "EOJ" or "LOGOUT" to return to Stonequest]',2);
  SMG$Paste_Virtual_Display (ShellDisplay,Pasteboard,1,1);
  Cursor; LIB$SPAWN; No_Cursor;

  SMG$Begin_Pasteboard_Update (Pasteboard);
  SMG$Unpaste_Virtual_Display (ShellDisplay,Pasteboard);
  SMG$Repaint_Screen (Pasteboard);
  SMG$Set_Broadcast_Trapping (pasteboard,%Immed Message_Trap,0);
  SMG$End_Pasteboard_Update (Pasteboard);

  { If Not Authorized or Trap_Authorized_Error then Establish (Oh_No); } { Turn Moria's condition handler back on }
  Trap_Out_of_Bands;
End;  { Shell Out }
End.  { Shell Out }

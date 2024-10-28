(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


Module IO_Routines;

{ The routines in the module were taken from the public domain program, Moria, whose manipulation of Input/Output are
  magnificent. }

(********************************************************************************************************************************)

[Global]Procedure No_ControlY;

Var
   Bit_Mask : unsigned;

[External(LIB$DISABLE_CTRL)]Function y_off(var mask: unsigned;  old_mask: integer:=%immed 0):integer;external;

Begin
   bit_mask  := %X'02000000';    { No Control-Y }
   Y_off(mask:=bit_mask);
End;

(********************************************************************************************************************************)

[Global]Procedure ControlY;

Var
   Bit_Mask : unsigned;

[External(LIB$ENABLE_CTRL)]Function y_on(var mask: unsigned;  old_mask: integer:=%immed 0):integer;external;

Begin
   bit_mask  := %X'02000000';    { No Control-Y }
   Y_on(mask:=bit_mask);
End;

(********************************************************************************************************************************)

[Global]Procedure Exit (xstatus: integer:=1);

{ Immediate exit from program }

[External(SYS$EXIT)]Function $exit(%immed status: integer:=%immed 1):integer;external;

Begin
   controly;            { Turn control-y back on }
   $exit(xstatus);      { exit from game }
End;
End.  { IO Routines }

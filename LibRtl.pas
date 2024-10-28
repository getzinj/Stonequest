(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Environment('librtl')]
MODULE librtl;


[HIDDEN]
TYPE
  $bool = [BIT] BOOLEAN;
  $ubyte = [BYTE, UNSAFE] CHAR;
  $byte = [BYTE, UNSAFE] -127 .. 127;
  $uword = [WORD, UNSAFE] 0 .. 65535;
  $word = [WORD, UNSAFE] -32768 .. 32767;
  $unspecified = [LONG, UNSAFE] UNSIGNED;
  $quad = [UNSAFE] Record
                     lsl,msl:  [UNSAFE] INTEGER;
                   End;
  $uquad = [UNSAFE] Record
                      lsl,msl:  [UNSAFE] INTEGER;
                    End;

[ASYNCHRONOUS, UNBOUND]FUNCTION lib$wait
  (          duration: Real ) : UNSIGNED;
        EXTERNAL;


[ASYNCHRONOUS, UNBOUND]FUNCTION lib$delete_file
  (%descr filename: VARYING [$len3] OF CHAR ) : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION lib$do_command
  (%descr command: VARYING [$len4] OF CHAR ) : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION lib$spawn : UNSIGNED;
        EXTERNAL;


[ASYNCHRONOUS, UNBOUND]FUNCTION lib$find_file
  (%descr filename: VARYING [$len5] OF CHAR;
  %descr resultantFilespec: VARYING [$len6] OF CHAR;
  %Ref   attributes: UNSIGNED := %immed 0) : UNSIGNED;
        EXTERNAL;
END.

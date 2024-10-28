(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Environment('strrtl')]
MODULE strrtl;


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

[ASYNCHRONOUS, UNBOUND]FUNCTION str$trim
  (%descr string: VARYING [$len3] OF CHAR;
   %descr output: VARYING [$len4] OF CHAR) : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION STR$Case_Blind_Compare
  (%descr string: VARYING [$len5] OF CHAR;
   %descr compare_string: VARYING [$len6] OF CHAR) : UNSIGNED;
        EXTERNAL;


[ASYNCHRONOUS, UNBOUND]FUNCTION STR$Position
  (%descr string: VARYING [$len7] OF CHAR;
   %descr compare_string: VARYING [$len8] OF CHAR) : UNSIGNED;
        EXTERNAL;

[ASYNCHRONOUS, UNBOUND]FUNCTION STR$Upcase
  (%descr string: VARYING [$len7] OF CHAR;
   %descr compare_string: VARYING [$len8] OF CHAR) : UNSIGNED;
        EXTERNAL;
END.

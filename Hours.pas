(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types','SYS$LIBRARY:STARLET','LIBRTL')]Module Hours;

Type
   $UQuad = [Unsafe,Quad]Record
                           L1,L2: Unsigned;
                         End;

Var
   HoursFile:   [External]Text; { TODO: Move to Files.pas }
   Days:        Array [1..7] of Line;

Value
{                 1         111       111
                  21234567890123456789012 }
   Days [1]:='SUN:xxxxxxxxxxxxxxxxxxxxxxxx!';
   Days [2]:='MON:xxxxxxxxx.........xxxxxx!';
   Days [3]:='TUE:xxxxxxxxx.........xxxxxx!';
   Days [4]:='WED:xxxxxxxxx.........xxxxxx!';
   Days [5]:='THU:xxxxxxxxx.........xxxxxx!';
   Days [6]:='FRI:xxxxxxxxx.........xxxxxx!';
   Days [7]:='SAT:xxxxxxxxxxxxxxxxxxxxxxxx!';

(******************************************************************************)

Procedure Create_Hours_File;

Var
   i1: Integer;

[External]Procedure exit (xstatus: Integer:=1);External;

Begin
   Open(HoursFile,file_name:='HOURS.DAT',organization:=SEQUENTIAL,history:=NEW,sharing:=READWRITE,error:=CONTINUE);
   If Status(HoursFile) = PAS$K_SUCCESS then
      Begin
         ReWrite(HoursFile,error:=continue);
         Writeln(HoursFile,'   Stonequest operating hours are:');
         Writeln(HoursFile,'   |    AM     |    PM     |');
         Writeln(HoursFile,'   1         111         111');
         Writeln(HoursFile,'   2123456789012123456789012');
         For i1:=1 to 7 do
            Writeln(HoursFile,Days[i1]);
         Writeln (HoursFile,'     (X=Open;  .=Closed)');
         Close(HoursFile,error:=CONTINUE);
      End
   Else
      Exit;
End;

(******************************************************************************)

Procedure Read_Hours_From_File;

Var
   Day_Test,In_Line: Line;

Begin
   Reset (HoursFile);
   Repeat
      Begin
         ReadLn (HoursFile,in_line,error:=CONTINUE);
         If in_Line.length>3 then
            Begin
               day_test:=substr(in_line,1,4);
               If       (day_test='SUN:') then days[1]:=in_line
               Else if  (day_test='MON:') then days[2]:=in_line
               Else if  (day_test='TUE:') then days[3]:=in_line
               Else if  (day_test='WED:') then days[4]:=in_line
               Else if  (day_test='THU:') then days[5]:=in_line
               Else if  (day_test='FRI:') then days[6]:=in_line
               Else if  (day_test='SAT:') then days[7]:=in_line;
            End;
      End;
   Until EOF(HoursFile);
   Close (HoursFile,error:=CONTINUE);
End;

(******************************************************************************)

Procedure Read_In_Hours;

Begin
   Open(HoursFile,'HOURS.DAT',history:=READONLY,sharing:=READWRITE,error:=CONTINUE);
   If Status(HoursFile)=PAS$K_SUCCESS then Read_Hours_From_File
   Else                                    Create_Hours_File;
End;

(******************************************************************************)
[External]Function SYS$GETTIM (%Ref Time:$UQuad): Integer;External;
[External]Function LIB$DAY_OF_WEEK (%Ref Time:$UQuad; Var Day1: Unsigned):unsigned;External;
(******************************************************************************)

Procedure Get_Time (Var Day,Hour,Minutes: [Unsafe]Integer);

Var
  Day1: Unsigned;
  TimeQ: $UQuad;
  TimeX: Packed Array [1..11] of Char;

Begin
   Time(TimeX);
   ReadV (SubStr(TimeX,1,2),Hour);
   ReadV (SubStr(TimeX,4,2),Minutes);
   SYS$GETTIM (TimeQ);
   LIB$DAY_OF_WEEK (TimeQ,Day1);
   Day1:=Day1 + 1;
   If Day=8 then Day:=1;
End;

(******************************************************************************)

Function Valid_Time (Day,Hour: Integer;  Minute: Integer:=0):Boolean;

Var
  Temp: Line;

Begin
  Temp:=Days[Day];
  Valid_Time:=Temp[Hour + 5]='x';
End;

(******************************************************************************)

[Global]Function Legal_Time: [Volatile]Boolean;

Var
  Day,Hour,Minutes: Integer;

Begin
  Read_in_Hours;
  Get_Time (Day,Hour,Minutes);
  Legal_Time:=Valid_Time (Day,Hour,Minutes);
End;

(******************************************************************************)

Procedure Next_Hour (Var Day,Hour: Integer);

Begin
   If Hour=23 then
      Begin
         If Day=7 then Day:=1
         Else          Day:=Day + 1;
         Hour:=0;
      End
   Else
      Hour:=Hour + 1;
End;

(******************************************************************************)

[Global]Function Minutes_Until_Closing: [Volatile]Integer;

Var
  Legal_Time: Boolean;
  Day,Hour,Minutes: Integer;

Begin
   Read_in_Hours;
   Get_Time (Day,Hour,Minutes);

   Next_Hour (Day,Hour);

   Legal_Time:=Valid_Time(Day,Hour);

   If Legal_Time then Minutes_Until_Closing:=0
   Else               Minutes_Until_Closing:=60-Minutes;
End;
End.  { Hours }

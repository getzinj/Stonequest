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


{ TODO: Enter this code }

[Global]Function Legal_Time: [Volatile]Boolean;

Begin
  { TODO: Enter this code }
  Legal_Time:=True;
End;


[Global]Function Minutes_Until_Closing: [Volatile]Integer;

Begin
  { TODO: Enter this code }
   Minutes_Until_Closing:=0;
End;
End.  { Hours }

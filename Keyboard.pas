(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit('TYPES', 'SYS$LIBRARY:STARLET','LIBRTL','SMGRTL','STRRTL')]
Module Keyboard;

Type
   Unsigned_Word       = [Word]0..65535;

Var
  Keyboard:               [External]Unsigned;
  Minutes_Left:           [External]Integer;
  Keypresses:             [External]Integer;
  Authorized:             [External]Boolean;                             { Can current user use Utilities? }

[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Procedure Special_Keys (Key_Code: Unsigned_Word);External;

{**********************************************************************************************************************************}

[Global]Function Get_Key (Time_Out: Integer:=-1;  Time_Out_Char:  Integer:=32): [Volatile]Integer;

[External]Function Minutes_Until_Closing:[Volatile]Integer;External;
[External]Procedure Closing_Warning (Minutes_Remaining: Integer; Var Minutes_Left: Integer);External;

{ Ths function will read a keystroke from the virtual keyboard, and will return the ascii code of the key. It will also intercept
  and handle such keys as HELP and DO.  }

Var
  MUC:  Integer;        { Kinda a catch name, don't you think? }
  Temp: Unsigned_Word;  { Variable into which the keypress is read }
  Result: Unsigned;     { Was a key entered in time? }

Begin { Get Key }
  Temp:=0; Get_Key:=0;
  If Time_Out=-1 then SMG$Read_Keystroke(Keyboard, Temp) { If there's no time delay }
  Else
     Begin
        Result:=SMG$Read_Keystroke(Keyboard,Temp,Timeout:=Time_Out);
        If Result=SS$_TIMEOUT then Temp:=Time_Out_Char;
     End;

 { Is it time to check for closing? }

  Keypresses:=Keypresses + 1;
  If Keypresses=Maxint then Keypresses:=0;
  If Not Authorized then
     If (Keypresses mod 4)=0 then
        Begin
           MUC:=Minutes_Until_Closing;
           If (MUC>0) and (MUC<30) then Closing_Warning (MUC, Minutes_Left);
        End;

 { Check to see if it's a special key, and handle it if it is }

  Special_Keys (Temp);
  Get_Key:=Temp;
End;  { Get Key }

{**********************************************************************************************************************************}

[Global]Function Get_Response (
    Time_Out: Integer:=-1;  Time_Out_Char: Char:=' '):[Volatile]Char;

{ This procedure will read in a letter from 'A' to 'Z' and return it as the function value.  Note:  All lower case letters are
  converted to uppercase, so if lower case letters are needed, another function must be used.  HELPs are removed since they serve
  one purpose throughout the program. }

Var
   Num: Integer;

Begin { Get Response }
   Repeat { Keep reading keys ... }
      Begin { Key loop }
         Num:=Get_Key (Time_Out,Ord(Time_Out_Char));  { Get a key }
         If (CHR(Num) in ['a'..'z']) then Num:=Num-32; { Convert to U/C }
      End;  { Key loop }
   Until (Num<>SMG$K_TRM_HELP) and (Num<>SMG$K_TRM_DO);
   Get_Response:=CHR(Num);
End;  { Get Response }

{**********************************************************************************************************************************}

[Global]Function Make_Choice (Choices: Char_Set;  Time_Out:  Integer:=-1; Time_Out_Char: Char:=' '): Char;

{ This function will keep reading the keyboard until a valid character, determined by CHOICES, is typed, and will return that
  character as the function result }

Var
   Response: Char;

Begin { Make Choice }
   Response:=' ';
   Repeat
      Response:=Get_Response (Time_Out,Time_Out_Char) { Read keys until a valid key is read }
   Until Response in Choices;
   Make_Choice:=Response { Return that key }
End;

{**********************************************************************************************************************************}

[Global]Function Yes_or_No (Time_Out: Integer:=-1;  Time_Out_Char: Char:=' '): [Volatile]Char;

{ This function will return a keystroke, 'Y' or 'N' }

Begin { Yes or No }
   Yes_Or_No:=Make_Choice (['Y','N'],Time_Out,Time_Out_Char);
End;  { Yes or No }

{**********************************************************************************************************************************}

[Global]Procedure Zero_Through_Six (Var Number: Integer;  Time_Out: Integer:=-1;  Time_Out_Char: Char:='0');

{ This procedure will read in an Integer from zero to six.  A <CR> will be treated as a '0'. }

Var
   Answer: Char;

Begin { Zero Through Six }
   Answer:=Make_Choice(['0'..'6',CHR(13),CHR(32)],Time_Out,Time_Out_Char);
   If Answer in [CHR(13),CHR(32)] then Answer:='0';                          { Convert <CR> to '0' }
   Number:=Ord(Answer)-48  { Convert CHAR to INT and return }
End;  { Zero Through Six }

{**********************************************************************************************************************************}

[Global]Function Pick_Character_Number (Party_Size: Integer;  Current_Party_Size: Integer:=0;
                                        Time_Out: Integer:=-1;  Time_Out_Char: Char:='0'):[Volatile]Integer;

{ This function will return the number entered by the player that corresponds
  to one of the characters in the party. }

Var
   Temp: Integer;

Begin { Pick Character Number }
   If Current_Party_Size=0 then Current_Party_Size:=Party_Size
   Else                         If Current_Party_Size<Party_Size then Party_Size:=Current_Party_Size;
   Repeat
      Zero_Through_Six (temp,Time_Out,Time_Out_Char)
   Until Temp<=Party_Size;
   Pick_Character_Number:=Temp;
End;  { Pick Character Number }

{**********************************************************************************************************************************}

[Global]Procedure Wait_Key (Time_Out: Integer:=-1);

{ This procedure simply waits for a key to be typed before it exits}

Begin { Wait Key }
  Get_Response (Time_Out);
End;

{**********************************************************************************************************************************}

[Global]Function Get_Num (Display: Unsigned): Integer;

{ This procedure will get a number and store it in NUMBER, echoing to DISPLAY }

Var
   Response: Line;
   Position: Integer;
   Number: Integer;

Begin { Get Num }

   { Read the number string }

   Cursor;
   SMG$Read_String (Keyboard,Response,Display_ID:=Display);
   No_Cursor;

   If Response.Length=0 then
      Response:='0'
   Else
      For Position:=1 to Response.Length do
          If Not(Response.Body[Position] in ['0'..'9','+','-']) then
             Response.Body[Position]:='0';

   ReadV (Response,Number,Error:=Continue);

   Get_Num:=Number;
End;  { Get Num }
End.  { Keyboard }

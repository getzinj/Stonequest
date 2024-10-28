(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit('TYPES', 'SYS$LIBRARY:STARLET','LIBRTL','SMGRTL','STRRTL')]
Module Random;

Const
   ZeroOrd=ORD('0');

Type
   Time_Type           = Packed Array [1..11] of char;

Var
  Seed:                   [External,Volatile]Unsigned;                           { Seed for random number }

[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;


[Global]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;

[Asynchronous,External]Function MTH$RANDOM (%Ref Seed: Unsigned): Real;external;

{ This function will return a random number from one to DIE_TYPE. }

begin { Roll_Die }
   Roll_Die:=Trunc(MTH$RANDOM(Seed)*Die_Type)+1  { Get a random number }
end;  { Roll_Die }

{**********************************************************************************************************************************}

[Global]Function Random_Number (Die: Die_Type): [Volatile]Integer;

{ This function will return a random number by rulling xDy + z as determined by DIE }

Var
   Sum,Loop: Integer;

Begin { Random Number }
   Sum:=0;
   If (Die.X>0) and (Die.Y>0) then { If there are dice to roll... }
      For Loop:=1 to Die.X do  { Roll each die }
         Sum:=Sum + Roll_Die (Die.Y);
   Random_Number:=Sum + Die.Z;  { ... and return the result }
End;  { Random Number }

{**********************************************************************************************************************************}

[Global]Function Get_Seed: [Volatile]Integer;

{ This function returns a random seed for use with the random number generator. The randomness is achieved by making the seed a
  function of the time the program is run at. }

Var
   Seed: Integer;
   Timex: Time_Type;

Begin { Get Seed }

   { Put the current time in the Packed Array, TIMEX }

   Time(Timex);

   { Get a seed from the time }

   Seed:=Ord(Timex[8])-ZeroOrd+(ord(timex[7])-ZeroOrd)*10;
   Seed:=Seed*Ord(Timex[6]);

   { Return it }

   Get_Seed:=Seed mod Maxint;
End;  { Get Seed }

(******************************************************************************)

[Global]Function GetDieString (die: Die_Type): Line;

Var
   T: Line;

Begin
  T:=String(die.X) + 'D' + String(die.Y);

  if die.Z<0 then
     T:=T + '-'
  Else
     T:=T + '+';

  T:=T + String(die.Z);

  GetDieString := T;
End;
End.

(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit('Types'),Environment]Module PriorityQueue;

Type
  Group_Choice    = [Byte]1..5; { Group 5 is the party }
  Group_Type      = 0..4;
  Individual_Type = 0..6;
  AttackerType = Record
                     Priority: Integer;                           { order of attacks }
                     Attacker_Position: [Word]1..999;             { Which monsters }
                     Caster_Level: Integer;                       { For spell casting }
                     Case Group: Group_Choice of                  { Which monster group }
                          5: (Action: Option_Type;                { What action }
                             Target_Group: Group_Type;            { Who is being attacked }
                             Target_Individual: Individual_Type;  {  "  "   "      "      }
                             WhatSpell: Spell_Name;
                             Old_Item,New_Item: Integer)
                  End;
  Party_Commands_Type = Array [1..6] of AttackerType;
  PriorityQueue = Record
                     Contents: Array [1..4008] of AttackerType;
                     Last:  Integer;
                  End;



(******************************************************************************)

[Global]Function Empty (A: PriorityQueue): Boolean;

Begin
   Empty:=(A.Last=0)
End;

(******************************************************************************)

[Global]Procedure MakeNull (Var A: PriorityQueue);

Begin
   A:=Zero;
End;

(******************************************************************************)

[Global]Function P (A: AttackerType): Integer;

Begin
   P:=A.Priority;
End;

(******************************************************************************)

[Global]Procedure Insert (X: AttackerType; Var A: PriorityQueue);

Var
   NotDone: Boolean;
   i: Integer;
   Temp: AttackerType;

Begin
   If A.Last>4007 then
      HALT
   Else
      Begin
         A.Last:=A.Last + 1;
         A.Contents[A.Last] := x;
         i := A.Last; { i is index of current position of x }
         If I>1 then NotDone:=(P(A.Contents[i])<P(A.Contents[i div 2]))
         Else        NotDone:=False;
         While NotDone do
            Begin { Push x up the tree by exchanging it with its parent of larger priority. Recall p computes the priority of a
                    AttackerType element }
               Temp:=A.Contents[i];
               A.Contents[i]:=A.Contents[i div 2];
               A.Contents[i div 2]:=Temp;

               i:=i div 2;

               If I>1 then
                   NotDone:=(P(A.Contents[i])<P(A.Contents[i div 2]))
               Else
                   NotDone:=False
            End
      End
End;

(******************************************************************************)

[Global]Function DeleteMin (Var A: PriorityQueue): AttackerType;

Var
   i,j: Integer;
   Temp,minimum: AttackerType;

Begin
  If A.last>0 then
     Begin
        Minimum:=A.Contents[1];
        A.Contents[1]:=A.Contents[A.Last];
        A.Last:=A.Last-1;

        i:=1;
        While (i <= (A.Last div 2)) do
           Begin
              If 2*i=A.last then J:=2*i
              Else If P(A.Contents[2*i])<P(A.Contents[2*i+1]) then
                      j:=2*i
                   Else
                      j:=2*i+1;

              If P(A.Contents[i]) > P(A.Contents[j]) then
                 Begin
                    Temp:=A.Contents[i];
                    A.Contents[i]:=A.Contents[j];
                    A.Contents[j]:=Temp;
                    i:=j;
                 End
              Else
                 Begin
                    DeleteMin:=Minimum;
                    i:=(A.Last div 2)+1;
                 End
           End;
        DeleteMin:=Minimum;
     End
  Else
     Begin
        Temp.Group:=0;
        DeleteMin:=Temp;
     End;
End;
End.

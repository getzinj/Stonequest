[Inherit('Types','SMGRTL')]Module Casino;

Var
   BottomDisplay:      [External]Unsigned;
   Location:           [External]Place_Type;

(*********************************************************************************************************************************)
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;
[External]Function Can_Play: [Volatile]Boolean;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): Char;External;
[External]Function Zero_Through_Six (Var Number: Integer; Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): Char;External;
[External]Function Pick_Character_Number (Party_Size: Integer; Current_Party_Size: Integer:=0;
                                          Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): [Volatile]Integer;External;
Procedure Play_Slots (Var Character: Character_Type);external;
(*********************************************************************************************************************************)

Function Pool_Gold (Var Character: Character_Type;  Var Party: Party_Type;  Party_Size: Integer): Integer;

{ The function returns the total amount of gold the party has, and then clears each member's purse.  For this reason, it is only
  to be used in an assignment statement and never like the following:

           If Pool_Gold(Party,Party_Size)>0 then ...

  because this will clear the party's wealth, and not store it anywhere ... }

Var
   N,Sum: Integer;

Begin
  Sum:=Character.Gold;  Character.Gold:=0;
  For N:=1 to Party_Size do
     Begin
        If Party[N].Name<>Character.Name then Sum:=Sum+Party[N].Gold;
        Party[N].Gold:=0;
     End;
  Pool_Gold:=Sum;
End;

(*********************************************************************************************************************************)

Procedure Character_Entered (Var Character: Character_Type;  Var Party: Party_Type;  Party_Size: Integer);

Var
  Answer: Char;
  Options: Char_Set;

Begin { Character Entered }
   Repeat
      Begin
        SMG$Begin_Display_Update (BottomDisplay);
        SMG$Erase_Display (BottomDisplay);
        SMG$Set_Cursor_ABS (BottomDisplay, 2, 1);
        SMG$Put_Chars (BottomDisplay, 'Welcome, ');
        SMG$Put_Chars (BottomDisplay, Character.Name,,,,1);
        SMG$Put_Line (BottomDisplay, ', thou have');
        SMG$Put_Line (BottomDisplay,String(Character.Gold)+' Gold Pieces.  Thou may: ',2);
        SMG$Put_Line (BottomDisplay, '[S] Play Slots');
        SMG$Put_Line (BottomDisplay, '[P] Pool gold',2);
        SMG$Put_Line (BottomDisplay, 'Which? [Return exits]');
        SMG$End_Display_Update (BottomDisplay);

        Options:=['S', 'P', CHR(13)];
        Answer:=Make_Choice(Options);
        Case Answer of
          'P': Character.Gold:=Pool_Gold(Character,Party,Party_Size);
          'S': Play_Slots (Character);
          CHR(13): ;
        End
      End
  Until Answer=CHR(13);
End;

(*****************************************************************************)

Function Get_Person (Party_Size: Integer): [Volatile]Integer;

Var
   Person: Integer;

Begin
  Person:=0;
  If Can_Play then Repeat  Zero_Through_Six (Person)  Until (Person<=Party_Size);
  Get_Person:=Person;
End;

(*********************************************************************************************************************************)

[Global]Procedure Run_Casino (Var Party: Party_Type;  Party_Size: Integer);

Var
   Character: Character_Type;
   Person: Integer;

Begin
   Person:=0;
   Repeat
      Begin
         SMG$Erase_Display (BottomDisplay);
         Smg$Set_Cursor_ABS (BottomDisplay,2,1);
         Smg$Put_line (BottomDisplay, 'Welcome to the Five Aces Casino!  Who will tempt the winds of fate?');
         Person:=Get_Person (Party_Size);
         If (Person<>0) Then
            If (Party[Person].Status in [Healthy,Poisoned,Insane]) then
               Begin
                  Character:=Party[Person];
                  Character_Entered (Character,Party,Party_Size);
               End;
      End;
   Until Person=0;
   Location:=InKyrn;
End;
End.

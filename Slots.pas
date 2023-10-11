[Inherit ('Types','SMGRTL')]Module Slots;

Type
  Symbol_Type = 1..8;

Var
   Symbol: Array [1..8] of Varying [10] of Char;
   Net_Winnings: Real;
   MachineDisplay,ScreenDisplay,CharacterDisplay,
   BetDisplay,OptionsDisplay: Unsigned;
   Wins,Bet: Integer;
   Answer: Char;
   Pasteboard: [External]Unsigned;

Value
   Symbol[1]:='Lemon';
   Symbol[2]:='Orange';
   Symbol[3]:='Bar';
   Symbol[4]:='Bell';
   Symbol[5]:='Plum';
   Symbol[6]:='Cherries';
   Symbol[7]:='Anchor';
   Symbol[8]:='Crown';


(******************************************************************************)
[External]Procedure Get_Num (Var Number: Integer; Display: Unsigned);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): Char;External;
(******************************************************************************)

Procedure Print_Character (Character: Character_Type);

Begin
  SMG$PUT_CHARS (CharacterDisplay,
      'Charisma:  '
      +String(Character.Abilities[6]),1,1);
  SMG$PUT_CHARS (CharacterDisplay,
      'Luck: '
      +String(Character.Abilities[7]),2,1);
  SMG$PUT_CHARS (CharacterDisplay,
      'Gold: '
      +String(Character.Gold)+' GP',4,1,1);
End;

(******************************************************************************)

Procedure Quit;

Begin
   SMG$BEGIN_PASTEBOARD_UPDATE (Pasteboard);
   SMG$DELETE_VIRTUAL_DISPLAY (MachineDisplay);
   SMG$DELETE_VIRTUAL_DISPLAY (ScreenDisplay);
   SMG$DELETE_VIRTUAL_DISPLAY (CharacterDisplay);
   SMG$DELETE_VIRTUAL_DISPLAY (BetDisplay);
   SMG$DELETE_VIRTUAL_DISPLAY (OptionsDisplay);
   SMG$END_PASTEBOARD_UPDATE (Pasteboard);
End;

(******************************************************************************)

Function All_Three_Same (First,Second,Third: Symbol_Type): Boolean;

Begin
  All_Three_Same:=(First=Second) and (Second=Third);
End;

(******************************************************************************)

Function Pays_Combination (First,Second,Third: Symbol_Type): Integer;

Var
   Pays: Integer;

Begin
   If All_Three_Same (First,Second,Third) then
      Case First of
         1: Pays:=8;
         2: Pays:=12;
         3: Pays:=14;
         4: Pays:=16;
         5: Pays:=20;
         6: Pays:=24;
         7: Pays:=50;
         8: Pays:=100;
      End
   Else
      If (First=6) and (Second=6) then
         Case Third of
            1: Pays:=2;
            2: Pays:=4;
            3: Pays:=6;
            4: Pays:=8;
            5: Pays:=10;
            6: Pays:=24;
            7: Pays:=12;
            8: Pays:=15;
         End
      Else
         Pays:=0;

   Pays_Combination:=Pays;
End;

(******************************************************************************)

Function Pays (First,Second,Third: Symbol_Type): Integer;

Begin
   Pays:=Max(Pays_Combination(First,Second,Third),
             Pays_Combination(First,Third,Second),
             Pays_Combination(Second,First,Third),
             Pays_Combination(Second,Third,First),
             Pays_Combination(Third,Second,First),
             Pays_Combination(Third,First,Second));
End;

(******************************************************************************)

Procedure Print_Symbol (Number: Integer);

Var
   T: Varying [10] of char;
   P,L: Integer;

Begin
  T:=Symbol[Number];
  L:=T.Length;
  If L<10 then
     For P:=1 to (5-(1 div 2)) do
        T:=' ' + T;
 L:=t.Length;
 If L<10 then
    T:=Pad(T, ' ',10);
    SMG$Put_Chars (MachineDisplay,T,,,,2);
End;

(******************************************************************************)

Procedure Print_Roll (First,Second,Third: Symbol_Type);

Begin
   SMG$Begin_Display_Update (MachineDisplay);
   SMG$Set_Cursor_ABS (MachineDisplay,5,1);
   Print_Symbol (First);
   SMG$Set_Cursor_ABS (MachineDisplay,5,12);
   Print_Symbol (Second);
   SMG$Set_Cursor_ABS (MachineDisplay,5,23);
   Print_Symbol (Third);
   SMG$End_Display_Update (MachineDisplay);
End;

(******************************************************************************)

Procedure Initialize (Character: Character_Type);

Begin
   SMG$CREATE_VIRTUAL_DISPLAY (13,32,MachineDisplay,1);
   SMG$LABEL_BORDER (MachineDisplay,
       '> ZOWIE <');

   SMG$CREATE_VIRTUAL_DISPLAY (22,78,ScreenDisplay,1);
   SMG$LABEL_BORDER (ScreenDisplay,
       ' Zowie Slots ');

   SMG$CREATE_VIRTUAL_DISPLAY (5,20,CharacterDisplay,1);
   SMG$LABEL_BORDER (CharacterDisplay,CHARACTER.NAME);
   SMG$CREATE_VIRTUAL_DISPLAY (3,11,BetDisplay,1);
   SMG$LABEL_BORDER (BetDisplay,
       ' Bet ');
   SMG$CREATE_VIRTUAL_DISPLAY (5,20,OptionsDisplay,1);
   SMG$LABEL_BORDER (OptionsDisplay,
       ' Options ');
   SMG$PUT_CHARS (MachineDisplay,
       '----------+----------+'
       +'-----------',4,1);
   SMG$PUT_CHARS (MachineDisplay,
       '          |          |           ',5,1);
   SMG$PUT_CHARS (MachineDisplay,
       '----------+----------+'
       +'-----------',6,1);
   SMG$PUT_CHARS (MachineDisplay,
   '          | Pays   x |',7,1);
   SMG$PUT_CHARS (MachineDisplay,
   '          +----------+',8,1);
   SMG$PUT_CHARS (MachineDisplay,
   '                           '
   +'  ---',12,1);
   SMG$PUT_CHARS (MachineDisplay,
   '                           '
   +' |XXX',13,1);

   SMG$BEGIN_PASTEBOARD_UPDATE (Pasteboard);
   Print_Character (Character);
   Print_Roll (Roll_Die(8),Roll_Die(8+0),Roll_Die(8+0+0));
   SMG$PASTE_VIRTUAL_DISPLAY (ScreenDisplay,Pasteboard,2,2);
   SMG$PASTE_VIRTUAL_DISPLAY (CharacterDisplay,Pasteboard,2,2);
   SMG$PASTE_VIRTUAL_DISPLAY (MachineDisplay,Pasteboard,9,25);
   SMG$PASTE_VIRTUAL_DISPLAY (BetDisplay,Pasteboard,5,65);
   SMG$PASTE_VIRTUAL_DISPLAY (OptionsDisplay,Pasteboard,14,3);
   SMG$END_PASTEBOARD_UPDATE (Pasteboard);
   Net_Winnings:=0;
End;

(******************************************************************************)

Function Get_Third_Roll (First,Second: Symbol_Type; Character: Character_Type): [Volatile]Integer;

Var
  Roll,Best_Roll,Loop,Bests: Integer;

Begin
   Bests:=0;  Best_Roll:=0;
   Bests:=Bests+((Character.Abilities[6]-10) div 2);
   Bests:=Bests+((Character.Abilities[7]-10) div 2);
   Loop:=1;
   Repeat
      Begin
         Roll:=Roll_Die(8);
         If Loop=1 then Best_Roll:=Roll
         Else
            Begin
               If Bests<0 then If Pays(First,Second,Roll)<Pays(First,Second,Best_Roll) then Best_Roll:=Roll;
               If Bests>0 then If Pays(First,Second,Roll)>Pays(First,Second,Best_Roll) then Best_Roll:=Roll;
            End;
         Loop:=Loop+1;
      End;
   Until (Bests=0) or (Loop>ABS(Bests));
   Get_Third_Roll:=Best_Roll;
End;

(******************************************************************************)

Procedure Roll_Slots (Var First,Second,Third: Symbol_Type; Character: Character_Type);

Var
   Rolls: Integer;
   Roll: Integer;
   Got1,Got2: Boolean;

Begin
  Got1:=False;  Got2:=False;
  Rolls:=Roll_Die (50)+55;
  For Roll:=1 to Rolls do
     Begin
        If not Got1 then First:=Roll_Die(8);
        If not Got2 then Second:=Roll_Die(8);
        Third:=Get_Third_Roll (First,Second,Character);
        If Roll=Rolls div 2 then got1:=True;
        If Roll=(Rolls * 3) div 4 then got2:=True;
        Print_Roll (First,Second,Third);
     End;
  SMG$Put_Chars (MachineDisplay,String(Pays(First,Second,Third),2),7,18);
End;

(******************************************************************************)

Procedure Player_Won;

Begin
   SMG$PUT_CHARS (MachineDisplay,
       '          '
       +'         '
       +'         |ooo',13,1,0,4);
   Ring_Bell (MachineDisplay,5);
   Delay (2);
   SMG$PUT_CHARS (MachineDisplay,
       '          '
       +'         '
       +'         |XXX',13,1);
End;

(******************************************************************************)

Function Plays_And_Wins (Bet: Integer; Character: Character_Type): Integer;

Var
   First,Second,Third: Symbol_Type;
   Temp: Integer;

Begin
  Roll_Slots (First,Second,Third,Character);
  Temp:=Bet*Pays(First,Second,Third);
  Plays_and_Wins:=Temp;
  If Temp>0 then Player_Won;
End;

(******************************************************************************)

Procedure Get_Bet (Money: Integer; Var Bet: Integer);

Begin
 Repeat
  Begin
    SMG$Erase_Display (BetDisplay);
    SMG$Put_Line (BetDisplay,
        'How much?');
    SMG$Put_Chars (BetDisplay,
        '--->');
    Get_Num (Bet,BetDisplay);
  End;
 Until (Bet>=0) and (Bet<=Money) and (Bet<=100);
 SMG$Begin_Display_Update (BetDisplay);
 SMG$Put_Chars (BetDisplay,
     String(Bet,6)
     +' GP',2,1);
 SMG$End_Display_Update (BetDisplay);
End;

(******************************************************************************)

Function Get_Option: Char;

Begin
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Put_Line (OptionsDisplay,
        ' ');
   SMG$Put_Line (OptionsDisplay,
       ' P)ull the lever');
   SMG$Put_Line (OptionsDisplay,
       ' S)et the stakes');
   SMG$Put_Line (OptionsDisplay,
       ' Q)uit');
   SMG$End_Display_Update (OptionsDisplay);
   Get_Option:=Make_Choice (['P','S','Q']);
End;

(******************************************************************************)

[Global]Procedure Play_Slots (Var Character: Character_Type);

Begin { Play Slots }
  Initialize (Character);
  Bet:=0;  Net_Winnings:=0;
  Repeat
     Begin
        Print_Character (Character);
        Answer:=Get_Option;
        Case Answer of
           'P': Begin
                   If Bet>0 then
                      Begin
                         Character.Gold:=Character.Gold-Bet;
                         Wins:=Plays_And_Wins(Bet,Character)-Bet;
                         Net_Winnings:=(Net_Winnings+Wins)-Bet;
                         Character.Gold:=Character.Gold+Bet+Wins;
                      End;
                   If Bet>Character.Gold then Bet:=0;
                End;
           'S': Get_Bet (Character.Gold,Bet);
           'Q': ;
        End;
     End;
  Until (Answer='Q');
  Quit;
End;  { Play Slots }
End.  { Slots }

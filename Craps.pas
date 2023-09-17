[Inherit ('Types', 'SMGRTL')]Module Craps;
[Global]Procedure Play_Craps (Var Character: Character_Type);

Const
   Table_Height = 20;
   Table_Width  = 10;

Type
   Die_Type = 1..6;

Var
   Net_Winnings: Real;

   TableDisplay,ScreenDisplay,CharacterDisplay,
   SideBetDisplay,BetDisplay,OptionsDisplay: Unsigned;
   Answer: Char;

(*****************************************************************************)

Procedure Print_Character (Character: Character_Type);

Begin
   SMG$PUT_CHARS (CharacterDisplay,
'Charisma:  '+String(Character.Abilities[6]),1,1);
   SMG$PUT_CHARS (CharacterDisplay,
'Luck:  '+String(Character.Abilities[7]),2,1);
   SMG$PUT_CHARS (CharacterDisplay,
'Gold:  '+String(Character.Gold)+' GP',4,1,1);
End;

(*****************************************************************************)

Procedure Quit;

Begin
   SMG$BEGIN_PASTEBOARD_UPDATE (Pasteboard);
   SMG$DELETE_VIRTUAL_DISPLAY (TableDisplay);
   SMG$DELETE_VIRTUAL_DISPLAY (ScreenDisplay);
   SMG$DELETE_VIRTUAL_DISPLAY (CharacterDisplay);
   SMG$DELETE_VIRTUAL_DISPLAY (BetDisplay);
   SMG$DELETE_VIRTUAL_DISPLAY (OptionsDisplay);
   SMG$END_PASTEBOARD_UPDATE (Pasteboard);
End;

(*****************************************************************************)

Procedure Print_One (X,Y: Integer);

Begin
   If (Y>0) and (Y<=Table_Width) then
        SMG$Put_Chars (TableDisplay,
'     ',Y,X,2);
   If (Y>-1) and (Y<Table_Width) then
        SMG$Put_Chars (TableDisplay,
'  o  ',Y+1,X,2);
   If (Y>-2) and (Y<Table_Width-1) then
        SMG$Put_Chars (TableDisplay,
'     ',Y+2,X,2);
End;

(*****************************************************************************)

Procedure Print_Two (X,Y: Integer);

Begin
   If (Y>0) and (Y<=Table_Width) then
        SMG$Put_Chars (TableDisplay,'  o  ',Y,X,2);
   If (Y>-1) and (Y<Table_Width) then
        SMG$Put_Chars (TableDisplay,'     ',Y+1,X,2);
   If (Y>-2) and (Y<Table_Width-1) then
        SMG$Put_Chars (TableDisplay,'  o  ',Y+2,X,2);
End;

(*****************************************************************************)

Procedure Print_Three (X,Y: Integer);

Begin
   If (Y>0) and (Y<=Table_Width) then
        SMG$Put_Chars (TableDisplay,'  o  ',Y,X,2);
   If (Y>-1) and (Y<Table_Width) then
        SMG$Put_Chars (TableDisplay,'  o  ',Y+1,X,2);
   If (Y>-2) and (Y<Table_Width-1) then
        SMG$Put_Chars (TableDisplay,'  o  ',Y+2,X,2);
End;

(*****************************************************************************)

Procedure Print_Four (X,Y: Integer);

Begin
   If (Y>0) and (Y<=Table_Width) then
        SMG$Put_Chars (TableDisplay,'o   o',Y,X,2);
   If (Y>-1) and (Y<Table_Width) then
        SMG$Put_Chars (TableDisplay,'     ',Y+1,X,2);
   If (Y>-2) and (Y<Table_Width-1) then
        SMG$Put_Chars (TableDisplay,'o   o',Y+2,X,2);
End;

(*****************************************************************************)

Procedure Print_Five (X,Y: Integer);

Begin
   If (Y>0) and (Y<=Table_Width) then
        SMG$Put_Chars (TableDisplay,'o   o',Y,X,2);
   If (Y>-1) and (Y<Table_Width) then
        SMG$Put_Chars (TableDisplay,'  o  ',Y+1,X,2);
   If (Y>-2) and (Y<Table_Width-1) then
        SMG$Put_Chars (TableDisplay,'o   o',Y+2,X,2);
End;

(*****************************************************************************)

Procedure Print_Six (X,Y: Integer);

Begin
   If (Y>0) and (Y<=Table_Width) then
        SMG$Put_Chars (TableDisplay,'o o o',Y,X,2);
   If (Y>-1) and (Y<Table_Width) then
        SMG$Put_Chars (TableDisplay,'     ',Y+1,X,2);
   If (Y>-2) and (Y<Table_Width-1) then
        SMG$Put_Chars (TableDisplay,'o o o',Y+2,X,2);
End;

(*****************************************************************************)

Procedure Print_Die (Faces: Integer; X,Y: Integer);

Begin
  Case Faces of
       1: Print_One (X,Y);
       2: Print_Two (X,Y);
       3: Print_Three (X,Y);
       4: Print_Four (X,Y);
       5: Print_Five (X,Y);
       6: Print_Six (X,Y);
  End;
End;

(*****************************************************************************)

Procedure Initialize;

Begin
   SMG$CREATE_VIRTUAL_DISPLAY (Table_Height,Table_Width,TableDisplay,1);

   SMG$CREATE_VIRTUAL_DISPLAY (22,78,ScreenDisplay,1);
   SMG$LABEL_BORDER (ScreenDisplay,' Craps ');

   SMG$CREATE_VIRTUAL_DISPLAY (5,20,CharacterDisplay,1);
   SMG$LABEL_BORDER (CharacterDisplay,CHARACTER.NAME);
   SMG$CREATE_VIRTUAL_DISPLAY (3,11,BetDisplay,1);
   SMG$LABEL_BORDER (BetDisplay,' Bet ');
   SMG$CREATE_VIRTUAL_DISPLAY (5,20,OptionsDisplay,1);
   SMG$LABEL_BORDER (OptionsDisplay,' Options ');
   SMG$CREATE_VIRTUAL_DISPLAY (5,20,SideBetDisplay);

   SMG$BEGIN_PASTEBOARD_UPDATE (Pasteboard);
   Print_Character (Character);
   SMG$PASTE_VIRTUAL_DISPLAY (ScreenDisplay,Pasteboard,2,2);
   SMG$PASTE_VIRTUAL_DISPLAY (CharacterDisplay,Pasteboard,2,2);
   SMG$PASTE_VIRTUAL_DISPLAY (TableDisplay,Pasteboard,9,25);
   SMG$PASTE_VIRTUAL_DISPLAY (BetDisplay,Pasteboard,5,65);
   SMG$PASTE_VIRTUAL_DISPLAY (SideBetsDisplay,Pasteboard,10,65);
   SMG$PASTE_VIRTUAL_DISPLAY (OptionsDisplay,Pasteboard,14,3);
   SMG$END_PASTEBOARD_UPDATE (Pasteboard);
   Net_Winnings:=0;
End;

(*****************************************************************************)

Procedure Player_Won;

Begin
   Ring_Bell (MachineDisplay, 5);
   Delay(2);
End;

(*****************************************************************************)

Function Plays_And_Wins (Bet: Integer): Integer;

Var
   First,Second,Third: Symbol_Type;
   Temp: Integer;

Begin
   If Temp>0 then Player_Won;
End;

(*****************************************************************************)

Procedure Get_Bet (Money: Integer; Var Bet: Integer);

Begin
 Repeat
  Begin
    SMG$Erase_Display (BetDisplay);
    SMG$Put_Line (BetDisplay,'How much?');
    SMG$Put_Chars (BetDisplay,'--->');
    Get_Num (Bet,BetDisplay);
  End;
 Until (Bet>=0) and (Bet<=Money) and (Bet<=100);
 SMG$Begin_Display_Update (BetDisplay);
 SMG$Erase_Display (BetDisplay);
 SMG$Put_Chars (BetDisplay,String(Bet,6)+' GP',2,1);
 SMG$End_Display_Update (BetDisplay);
End;

(*****************************************************************************)

Function Get_Option: Char;

Begin
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$End_Display_Update (OptionsDisplay);
   Get_Option:=Make_Choice (['G ']);
End;

(*****************************************************************************)

Begin
   Initialize;
   Bet:=0;
   Repeat
      Begin
         Print_Character (Character);
         Answer:=Get_Option;
      End;
   Until (Answer='G');
   Quit;
End;
End.



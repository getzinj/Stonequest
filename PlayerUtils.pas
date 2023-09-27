[Inherit('TYPES', 'SYS$LIBRARY:STARLET','LIBRTL','SMGRTL','STRRTL')]
Module PlayerUtils;

Var
   Main_Menu,In_Utilities: [External]Boolean;
   Broadcast_On:           [External,Volatile]Boolean;
   Bells_On:               [External,Volatile]Boolean;
   ScreenDisplay,Pasteboard,Keyboard         : [External]Unsigned;
   Roster:                     [External]Roster_Type;         { All characters }
  Print_Queue:            [External,Volatile]Line;
  Game_Saved:             [External]Boolean;                             { Is there a previous game saved? }

[External]Function Make_Choice (Choices: Char_Set;  Time_Out:  Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Procedure Extend_LogFile (Out_Message: Line);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Procedure Wait_Key (Time_Out: Integer:=-1);External;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Function User_Name: Line;External;

{**********************************************************************************************************************************}

Procedure Recover_Heading;

Begin { Recover Heading }
   SMG$Begin_Display_Update (screendisplay);
   SMG$Erase_Display (screendisplay);
   SMG$Put_Line (screendisplay,
       'Recover Characters',1);
   SMG$Put_Line (screendisplay,
       '------------------',2);
   SMG$Put_Line (screendisplay,
       'This process will attempt to recover characters '
       +'lost through system crashes of',3);
   SMG$Put_Line (screendisplay,
       'accidental ^C or ^Y.',4);
   SMG$Put_Line (screendisplay,
       '',5);
   SMG$Put_Line (screendisplay,
       'NOTE: This will age recovered characters 5 years',7);
   SMG$Put_Line (screendisplay,
       'Continue?  (Y/N)',7);
   SMG$End_Display_Update (screendisplay);
End;  { Recover Heading }

{**********************************************************************************************************************************}

Procedure Recover_Character (Var ScreenDisplay: Unsigned);

{ This procedure will recover accidentally lost characters, aging them five
  years each, to prevent repeat cheaters! }

Const
   FiveYears = 365*5; { The # of days in 5 years }

Var
   Slot: Integer;
   Any_Recovered: Boolean;

Begin  { Recover Character }
   Any_Recovered:=False; { So far, nobody recovered }
   Recover_Heading;
   If YES_OR_NO='Y' then
      Begin
         SMG$Begin_Display_Update (screendisplay);
         SMG$Erase_Display (screendisplay);
         SMG$Put_Line (screendisplay,'Recovering:');
         SMG$Put_Line (screendisplay,'-----------');
         For Slot:=1 to 20 do  { For each character }
            If Roster[Slot].lock then  { If this character was lost... }
               Begin
                  Any_Recovered:=True;  { We have recovered one }
                  Roster[Slot].Lock:=False;  { Recover him (or her) }
                  Roster[Slot].Age:=Roster[slot].Age+FiveYears;  { And age him }
                  SMG$Put_Line (screendisplay,
                                Roster[Slot].Name
                                +': saved!');
               End;
         If Not Any_Recovered then
             SMG$Put_Line (screendisplay,'Nobody.');
         SMG$Put_Chars (screendisplay,'Press a key',23,35);
         SMG$End_Display_Update (screendisplay);
         Wait_Key;
      End;
End;   { Recover Character }

{**********************************************************************************************************************************}

Procedure Change_Queue (Var ScreenDisplay: Unsigned);

{ This procedure allows the user to change the current print queue }

Var
   Temp: Line;

Begin { Change Queue }
   SMG$Put_Line (screendisplay,
       '');
   SMG$Put_Line (screendisplay,
       'The current print queue is: '+Print_Queue);
   SMG$Put_Line (screendisplay,
       'Enter the new print queue. ("-" sets default, [RETURN] exists)');
   Cursor;  SMG$Read_String (Keyboard,Temp,Display_ID:=screendisplay,
                             Prompt_String:='--->');  No_Cursor;
   If Temp<>'' then
      If Temp='' then Print_Queue:='SYS$PRINT'
      Else Print_Queue:=Temp;
End;  { Change Queue }

{**********************************************************************************************************************************}

Procedure Change_Print_Queue (Var ScreenDisplay: Unsigned);

{ This procedure allows the user to change the print queue }

Begin { Change Print Queue }
   SMG$Begin_Display_Update (screendisplay);
   SMG$Erase_Display (screendisplay);
   SMG$Put_Line (screendisplay,
       'Change Print Queue');
   SMG$Put_Line (screendisplay,
       '------------------');
   SMG$Put_Line (screendisplay,
       'This process will change the print queue to which '
       +'the screen is sent when a');
   SMG$Put_Line (screendisplay,
       '^P is typed.  The default is SYS$PRINT.');
   SMG$Put_Line (screendisplay,
       '');
   SMG$Put_Line (screendisplay,
       'NOTE: Setting this to a non-existant queue will have '
       +'unpredictable results. ');
   SMG$Put_Line (screendisplay,
       'Continue? (Y/N)');
   SMG$End_Display_Update (screendisplay);
   If Yes_or_No='Y' then Change_Queue (ScreenDisplay);
End;  { Change Print Queue }

{**********************************************************************************************************************************}

Procedure Leave_Feedback (Var ScreenDisplay: Unsigned);

{ This procedure allows the user to leave feedback to the author, i.e. me,
  or any other person who is operating Stonequest, i.e. you }

Var
   Response: Varying [1024] of Char;

Begin { Leave Feedback }
   SMG$Begin_Display_Update (screendisplay);
   SMG$Erase_Display (screendisplay);
   SMG$Put_Line (screendisplay,
       'Leave Feedback to Author');
   SMG$Put_Line (screendisplay,
       '------------------------');
   SMG$Put_Line (screendisplay,
       'This process will allow you to leave a message to the '
       +'author, if he is on the system. ');
   SMG$Put_Line (screendisplay,
       'Enter up to 60 characters of text at the prompt.  '
       +'[RETURN] alone aborts.');
   SMG$Put_Chars (ScreenDisplay,
       '--->');
   SMG$Put_Chars (ScreenDisplay,
       '____________________________________________________________',,,SMG$M_UNDERLINE);
   SMG$Set_Cursor_ABS (ScreenDisplay,,5);
   SMG$End_Display_Update (screendisplay);
   Cursor;
   SMG$Read_String (Keyboard,Response,Display_ID:=ScreenDisplay,Rendition_Set:=SMG$M_Underline);
   No_Cursor;
   If Response.Length>60 then Response:=Substr(Response,1,60);
   If Response.Length>0 then
      Begin
         SMG$Put_Line (ScreenDisplay,Response);
         SMG$Put_Chars (ScreenDisplay,'Enter above line as feedback?');
         Cursor;
         If Yes_or_No='Y' then
            Begin
               SMG$Put_Line (ScreenDisplay,'');
               Extend_Logfile (User_Name+' '+Response);
               SMG$Put_Line (ScreenDisplay,'Feedback entered.');
               Delay(2);
            End
         Else
            Begin
               SMG$Put_Line (ScreenDisplay,'');
               SMG$Put_Line (ScreenDisplay,'Aborted.');
               Delay(2);
            End;
         No_Cursor;
      End;
End;  { Leave Feedback }

{**********************************************************************************************************************************}

[Global]Procedure Player_Utilities (Var Pasteboard: Unsigned);

{ This procedure contains all sorts of goodies for the player of Stonequest! }

Var
   UtilitiesDisplay: Unsigned;
   Response: Char;
   Toggle: Array [Boolean] of Line;

Begin { Player Utilities }
   In_Utilities:=True;
   SMG$Create_Virtual_Display (24,80,UtilitiesDisplay,0);
   SMG$Erase_Display (UtilitiesDisplay);
   SMG$Paste_Virtual_Display (UtilitiesDisplay,Pasteboard,1,1);

   Toggle[TRUE]:='on';   Toggle[False]:='off';
   Repeat
      Begin
         SMG$Begin_Display_Update (Utilitiesdisplay);
         SMG$Erase_Display (Utilitiesdisplay);
         SMG$Put_Chars (UtilitiesDisplay,
             'Player Utilities Menu',   ,6,27,,1);
         SMG$Put_Chars (UtilitiesDisplay,
             '------ --------- ----',   ,7,27,,1);
         SMG$Put_Chars (UtilitiesDisplay,
             ' C)hange print queue'     ,8,27);
         SMG$Put_Chars (UtilitiesDisplay,
             ' B)ells '+Toggle[Bells_On],9,27);
         SMG$Put_Chars (UtilitiesDisplay,
             ' T)ermimal broadcast '+Toggle[Broadcast_On],10,27);
         SMG$Put_Chars (UtilitiesDisplay
             ,' L)eave feedback'         ,11,27);
         If (Not Game_Saved) and Main_Menu then
             SMG$Put_Chars (Utilitiesdisplay,
                 ' R)ecover lost characters',12,27);
         SMG$Put_Chars (UtilitiesDisplay,
             ' E)xit'                       ,13,27);
         SMG$Put_Chars (UtilitiesDisplay,
             ' Which?'                      ,15,27);
         SMG$End_Display_Update (Utilitiesdisplay);
         Response:=Make_Choice (['R','E','C','T','B','L']);
         Case Response of
            'L': Leave_Feedback (UtilitiesDisplay);
            'B': Bells_On:=Not Bells_On;
            'T': Broadcast_On:=Not Broadcast_On;
            'C': Change_Print_Queue (UtilitiesDisplay);
            'R': If (Not Game_Saved) and Main_Menu then Recover_Character (UtilitiesDisplay);
            Otherwise ;
         End;
      End;
   Until (Response='E');
   SMG$Unpaste_Virtual_Display (UtilitiesDisplay,Pasteboard);
   SMG$Delete_Virtual_Display (UtilitiesDisplay);
   In_Utilities:=False;
End;  { Player Utilities }
End. { PlayerUtils }

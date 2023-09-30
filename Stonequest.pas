[Inherit('TYPES', 'SYS$LIBRARY:STARLET','LIBRTL','SMGRTL','STRRTL')]
Program Stonequest (Input,Output,Char_File,Item_File,Monster_File,Message_File,TreasFile,
                   MazeFile,SaveFile,PicFile,AmountFile,
                   ScoresFile,LogFile,HoursFile,PrintMazeFile);

{ This is Stonequest, a game.  But it's not just any game - far from it!  This
  game was originally based on the Sir-Tech game, "Wizardry", for the Apple II
  computer.  At the time, "Wizardry" was the best.  I wrote "Stonequest" just
  to see if it could be done.  It could.  (But it ain't easy, let me tell you!)

  But then I was inspired by other games that were becoming legends, such as
  "The Bard's Tale" by Electronic Arts, and Moria, a public domain game.  I
  attempted to capture the best of these games within the framework of
  "Wizardry".  The result is a game that I feel is the best fantasy/simulation
  around, and the biggest source of plagerized material in the world!  I feel
  that this game contains the best of all three of the above games, plus all
  the other little odds and ends I threw in on a warped whim.

  I apologize for the sorry lack of documentation in this game.  When I first
  started there was none; I've tried to add some since then.  I've also tried
  to make my variable and procedure names more self-explanatory.  I wish the
  best of luck to all those who try to modify it!

  This game is dedicated to the memory of my late grandmother, Jenny Mayer on this day, 10/13/1988 }

Const
   Owner_Account = 'JGETZIN';

   Up_Arrow          = CHR(18);         Down_Arrow      = CHR(19);
   Left_Arrow        = CHR(20);         Right_Arrow     = CHR(21);

   ZeroOrd=ORD('0');                    AOrd=ORD('A');

   Cler_Spell = 1;                      Wiz_Spell  = 2;

Type
   AST_Arg_Type        = Record
                               Pasteboard:  [Long]Unsigned;
                               Argument:    [Long]Unsigned;
                               Control_Key: [Byte]0..255;
                         End;
   Spell_List          = Packed Array [1..9] of Set of Spell_Name;
   Signed_Word         = [Word]-32767..32767;
   Unsigned_Word       = [Word]0..65535;
   Time_Type           = Packed Array [1..11] of char;
   Party_File_Type     = File of Name_Type;
   SpName_Type         = Cler_Spell..Wiz_Spell;

Var
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Files~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
   PrintMazeFile:              [Global]Text;                { A pictoral representation of a level of levels }
   HoursFile:                  [Global]Text;                { The stonequest schedule }
   TreasFile:                  Treas_File;                  { Treasure Types }
   Monster_File:               Monst_File;                  { Monster records }
   Item_File:                  Equip_File;                  { Item records }
   Char_File:                  [Global]Character_File;      { Character records }
   Message_File:               Text;                        { Game text }
   MazeFile:                   [Global]LevelFile;           { The maze }
   PartyFile:                  [Global]Party_File_Type;     { Save party file }
   SaveFile:                   [Global]Save_File_Type;      { Save game file }
   PicFile:                    Picture_File_Type;           { Pictures }
   AmountFile:                 [Global]Number_File;         { Item amounts }
   ScoresFile:                 [Global]Score_File;          { High scores }
   LogFile:                    [Global]Packed file of Line;         { Player log }
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Tables~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
   Roster:                     [Global]Roster_Type;         { All characters }
   Treasure:                   [Global]List_of_Treasures;   { All treasure types }
   Item_List:                  [Global]List_of_Items;       { All items }
   Pics:                       [Global]Pic_List;            { Graphic Images }
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Text~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
   TrapName:                   [External]Array [Trap_Type]            of Varying[20] of Char;
   Item_Name:                  [External]Array [Item_Type]            of Varying[7] of char;
   Spell:                      [External]Array [Spell_Name]         of Varying[4] of Char;
   Long_Spell:                 [External]Array [Spell_Name]           of Varying [25] of Char;
   StatusName:                 [External]Array [Status_Type]          of Varying [14] of char;
   ClassName:                  [External]Array [Class_Type]           of Varying [13] of char;
   AlignName:                  [External]Array [Align_Type]           of Packed Array  [1..7] of char;
   RaceName:                   [External]Array [Race_Type]            of Packed Array [1..12] of char;
   SexName:                    [External]Array [Sex_Type]             of Packed Array [1..11] of char;
   AbilName:                   [External]Array [1..7]                 of Packed Array [1..12] of char;
   WizSpells,ClerSpells:       [External]Spell_List;
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Virtual Devices for SMG$~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
  ViewDisplay,MonsterDisplay,SpellsDisplay,TextDisplay,CampDisplay,MessageDisplay,CommandsDisplay  : [Global]Unsigned;
  CharacterDisplay,TopDisplay,BottomDisplay,OptionsDisplay,GraveDisplay,ScenarioDisplay,WinDisplay : [Global]Unsigned;
  SpellListDisplay,ScreenDisplay,FightDisplay,ShellDisplay,HelpDisplay,Pasteboard,Keyboard         : [Global]Unsigned;
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~General~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
  Experience_Needed:      [Global]Array [Class_Type,1..50] of Real;
  Trap_Authorized_Error:  [Global]Boolean;
  Main_Menu,In_Utilities: [Global]Boolean;
  DataModified:           [Global]Boolean;
  ShowHours:              Boolean;
  Keypresses:             Integer;
  Print_Queue:            [Global,Volatile]Line;
  Minutes_Left:           [Global]Integer;
  Start_Priority:         Unsigned;                            { The priority at which Stonequest was run }
  Location:               [Global]Place_Type;                          { Which module we're in }
  Seed:                   [Global,Volatile]Unsigned;                           { Seed for random number }
  Answer:                 Char;                                        { User input from main program }
  Cursor_Mode:            [Global,Volatile]Boolean;                    { Is the cursor on or off? }
  Broadcast_On:           [Global,Volatile]Boolean;                    { Is the broadcast on ? }
  Bells_On:               [Global,Volatile]Boolean;                    { Are the bells on? }
  Authorized:             [Global]Boolean;                             { Can current user use Utilities? }
  Game_Saved:             [Global]Boolean;                             { Is there a previous game saved? }
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Game Loading and Saving Variables~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
  Auto_Load:              [Global]Boolean;                     { Auto-load in progress }
  Auto_Save:              [Global]Boolean;                     { Auto-save in progress }
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Externally Used Variables~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
  Delay_Constant:         [Global]Real;
  Leave_Maze:             [Global]Boolean;                             { Is there a forced leave maze? }
  Maze:                   [Global]Level;                               { The current level the party's on }
  Direction:              [Global]Direction_Type;                      { The direction the party's facing }
  Position:               [Global]Level;
  Minute_Counter:         [Global]Real;                                { Minutes since last CAMP in Maze }
  Rounds_Left:            [Global]Array [Spell_Name] of Unsigned;      { spell's time left }
  PosX,PosY,PosZ:         [Global,Byte]0..20;                          { Global position in maze }
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Used for Encounter Module~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
  Party_Spell,Person_Spell,Caster_Spell,All_Monsters_Spell,Group_Spell,Area_Spell: [External]Set of Spell_Name;

  Version_Number:         [Global]Line;
  Logging:                [Global]Boolean;  { Should users and errors be logged? }

Value
    Logging:=True;
    Version_Number:='V2.0';       { Current revision number }
    Trap_Authorized_Error:=True;  { Don't trap errors is user is authorized }
    DataModified:=False;          { Initially, data has not been modified }
    Keypresses:=0;                { No keypresses yet }
    Minutes_Left:=60;             { For use with hour-warnings }
    Authorized:=False;            { The user is not authorized by default! }
    Print_Queue:='SYS$PRINT';     { Where should print screen print to? }
    Main_Menu:=True;              { We start at the main menu }

{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~External DEClarations~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
{ 2023-09-21 JHG: Located the missing definition at https://github.com/dungeons-of-moria/vms-moria/blob/55058f595a810fb8576f898e76a4eb2937fa362c/source/moria.pas#L26 }
[Asynchronous,External]Function Oh_No (Var SA: Array [$u1..$u2:Integer] of Integer;  Var MA: Array [$u3..$u4:Integer] of [Unsafe]Integer):[Unsafe]Integer;external;
[External]Procedure No_Controly;External;
[External]Procedure Controly;External;
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;
[External]Procedure Player_Utilities(Var Pasteboard: Unsigned);External;
{**********************************************************************************************************************************}

[Global]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;

[Asynchronous,External]Function MTH$RANDOM (%Ref Seed: Unsigned): Real;external;

{ This function will return a random number from one to DIE_TYPE. }

begin { Roll_Die }
   Roll_Die:=Trunc(MTH$RANDOM(Seed)*Die_Type)+1  { Get a random number }
end;  { Roll_Die }

{**********************************************************************************************************************************}

[Global]Function Random_Number (Die: Die_Type): [Volatile]Integer;

{ This function will return a random number by rulling xDy+z as determined by DIE }

Var
   Sum,Loop: Integer;

Begin { Random Number }
   Sum:=0;
   If (Die.X>0) and (Die.Y>0) then { If there are dice to roll... }
      For Loop:=1 to Die.X do  { Roll each die }
         Sum:=Sum+Roll_Die (Die.Y);
   Random_Number:=Sum+Die.Z;  { ... and return the result }
End;  { Random Number }

{**********************************************************************************************************************************}

[Asynchronous]Procedure Print_Pasteboard (Var Arguments: AST_Arg_Type; Pasteboard: Unsigned);

[Asynchronous,External]Procedure Printing_Message;External;

begin { Print Pasteboard }
{ 2023-09-22 JHG - Couldn't get al the volatile params working. Not worth it.
   SMG$PRINT_PASTEBOARD (Pasteboard,Print_Queue);
   Printing_Message; }
End;  { Print Pasteboard }

{**********************************************************************************************************************************}

Procedure Special_Keys (Key_Code: Unsigned_Word);

[External]Procedure Help;external;
[External]Procedure Shell_Out;External;

Begin { Special Keys }
   If (Key_Code=SMG$K_TRM_CTRLU) and Not (Main_Menu or In_Utilities) then Player_Utilities(Pasteboard);
   If (Key_Code=SMG$K_TRM_HELP)  then Help;
   If (Key_Code=SMG$K_TRM_DO)    then Shell_Out;
End;  { Special Keys }

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

  Keypresses:=Keypresses+1;
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

[Global]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);

Begin { Ring Bell }
  If Bells_On then SMG$Ring_Bell (Display_ID,Number_of_Times);
End;  { Ring Bell }

{**********************************************************************************************************************************}

[Global]Procedure Cursor;

{ This procedure will turn the cursor on, and set CURSOR_MODE, the cursor's flag, to be true }

Begin { Cursor }
  Cursor_Mode:=True; { Set the cursor flag }
  SMG$Set_Cursor_Mode(Pasteboard, 0) { Turn on the cursor }
End;  { Cursor }

{**********************************************************************************************************************************}

[Global]Procedure No_Cursor;

{ This procedure will turn the cursor off, and set CURSOR_MODE, the cursor's flag, to be false }

Begin { No Cursor }
  Cursor_Mode:=False; { Clear the cursor flag }
  SMG$Set_Cursor_Mode(Pasteboard, 1) { Turn off the cursor }
End;  { No Cursor }

{**********************************************************************************************************************************}

[Global]Procedure Get_Num (Var Number: Integer; Display: Unsigned);

{ This procedure will get a number and store it in NUMBER, echoing to DISPLAY }

Var
   Response: Line;
   Position: Integer;

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
End;  { Get Num }

{**********************************************************************************************************************************}

[Global]Function User_Name: Line;

{ This function will return the USERNAME of the person using the game.  The
  code was provided by Denis Haskin, a great hacker, but a poor documenter,
  not unlike myself. ( *wink* ) }

Type
   Items=  record
               Buffer_Length,Item_Code:  Unsigned_word;
               Buffer_Address,Return_Length_Address: integer;
           End;
   Item_List_Type= Record
                        Item: Array [0..0] of Items;
                        Terminator: Integer;
                   End;
   Buffer_type = Array [0..0] of Line;

Var
   Item_list    : item_list_type;
   Buffer       : buffer_type;
   PID          : unsigned;

Begin { User Name }
  Buffer[0]:='';
  With Item_List.Item[0] do
    Begin
      Buffer_length:=12;
      Item_Code:=JPI$_Username; { Specify that we want the username }
      Buffer_Address:=Iaddress(Buffer[0].Body); { Send it the string buffer }
      Return_Length_Address:=IAddress(Buffer[0].Length) { And the length }
    End;
  Item_List.Terminator:=0;   { Indicate no more items }

  pid:=0;       { Indicate the current process }

  $getjpi(pidadr:=%ref pid,itmlst:=%ref item_list);

  { Return current username in Buffer[0] }

  User_Name:=Buffer[0];
End;  { User Name }

{**********************************************************************************************************************************}

Procedure Delete_All_Displays;

{ This procedure deletes all (?) of the virtual displays created by the game }

Begin { Delete All Displays }
   SMG$Delete_Virtual_Display(ScreenDisplay);

   SMG$Delete_Virtual_Display(HelpDisplay);
   SMG$Delete_Virtual_Display(ShellDisplay);
   SMG$Delete_Virtual_Display(CharacterDisplay);
   SMG$Delete_Virtual_Display(MonsterDisplay);
   SMG$Delete_Virtual_Display(CommandsDisplay);
   SMG$Delete_Virtual_Display(SpellsDisplay);
   SMG$Delete_Virtual_Display(OptionsDisplay);
   SMG$Delete_Virtual_Display(TextDisplay);
   SMG$Delete_Virtual_Display(ViewDisplay);
   SMG$Delete_Virtual_Display(FightDisplay);
   SMG$Delete_Virtual_Display(MessageDisplay);
   SMG$Delete_Virtual_Display(CampDisplay);
   SMG$Delete_Virtual_Display(ScenarioDisplay);
   SMG$Delete_Virtual_Display(GraveDisplay);
   SMG$Delete_Virtual_Display(TopDisplay);
   SMG$Delete_Virtual_Display(BottomDisplay);
End;  { Delete All Displays }

{**********************************************************************************************************************************}

Procedure Delete_Virtual_Devices;

{ This procedure deletes all of the virtual devices created by SMG$ }

Begin { Delete Virtual Devices }
   SMG$Disable_Broadcast_Trapping (Pasteboard); { Stop trapping }
   Cursor;  { Restore the cursor to the on position }

   SMG$Delete_Virtual_Keyboard (Keyboard);  { Delete the keyboard }
   Delete_All_Displays;  { Delete the displays created in Stonequest }

   SMG$Delete_Pasteboard (Pasteboard, 1); { Delete the pasteboard }
End;  { Delete Virtual Devices }

{**********************************************************************************************************************************}

[Global]Procedure Extend_LogFile (Out_Message: Line);

{ This procedure writes the supplied line to the logfile }

Begin { Extend LogFile }
   Repeat
      Open (LogFile,'Stone_Data:Stone_Log.Dat',History:=Unknown,Sharing:=READONLY,Error:=CONTINUE);
   Until (Status(LogFile)<>PAS$K_FILALROPE);
   Extend (LogFile,Error:=Continue);
   Write  (LogFile,Out_Message,Error:=Continue);
   Close  (LogFile,Error:=Continue);
End;  { Extend LogFile }

{**********************************************************************************************************************************}

[Global]Procedure Read_Error_Window (FileType: Line; Code: Integer:=0);

{ This procedure prints an error message and then exits Stonequest. }

[External]Procedure Exit (XStatus:  Integer:=1);External;

Var
  BroadcastDisplay:  Unsigned;  { Virtual keyboard and Broadcast }
  Msg: Line;

{ THIS CODE IS MISSING IN THE PRINT OUT. IT WILL NEED TO BE RECREATED. -- JHG 2023-09-15 }

Begin
{ THIS CODE IS MISSING IN THE PRINT OUT. IT WILL NEED TO BE RECREATED. -- JHG 2023-09-15 }
End;

{**********************************************************************************************************************************}

{[Global]?}
Procedure Message_Trap (Code: Integer; FileType: Line);

{ THIS CODE IS MISSING IN THE PRINT OUT. IT WILL NEED TO BE RECREATED. -- JHG 2023-09-15 }

[External]Procedure Exit (XStatus:  Integer:=1);External;

Var
   Msg: Line;
   BroadcastDisplay: Unsigned;

Begin { Message Trap }
   Msg:='* * * Error reading '+FileType+' file!';
   If Code<>0 then msg:=msg+'  Error #'+String(code);
   Msg:=Msg+' * * *';

   If Logging then Extend_LogFile (Msg);

   SMG$Create_Virtual_Display (5,78,BroadcastDisplay,1);
   SMG$Erase_Display (BroadcastDisplay);
   SMG$Label_Border (BroadcastDisplay, '> Yikes! <', SMG$K_TOP);

         { Print the message to the display }

   SMG$Put_Chars    (BroadcastDisplay,Msg,2,39-(Pas_Errors[Code].Length div 2));
   If (Code>-2) and (Code<129) then
      SMG$Put_Chars (BroadcastDisplay,Pas_Errors[Code],3,39-(Pas_Errors[Code].Length div 2));

         { Paste it onto the pasteboard }

   SMG$Paste_Virtual_Display (BroadcastDisplay,Pasteboard,2,2);

                { Wait and then delete all created virtual devices }

   LIB$WAIT (3);

   SMG$Unpaste_Virtual_Display (BroadcastDisplay,Pasteboard);
   SMG$Delete_Virtual_Display  (BroadcastDisplay);
   Delete_Virtual_Devices;
   Exit;  { Leave the game. (sorry! ) }
End;  { Message Trap }

{**********************************************************************************************************************************}

[Global]Function Load_Saved_Game: [Volatile]Save_Record;

{ This function returns the saved game, if there was one.  This function is not defined if the file doesn't exist so the checking
  must be performed before this. }

Var
   Temp: Save_Record;

Begin { Load Saved Game }
   With Temp do
      Begin { Make a dummy save record }
         PosX:=1;  PosY:=1;  PosZ:=0;
         Direction:=North;
         Party_Size:=1;
         Current_Size:=0;
      End;

   { Open the file, and if there's data, read it }

   Open (SaveFile, 'SYS$LOGIN:STONE_SAVE.DAT',History:=OLD,Error:=CONTINUE);
   If Status(SaveFile)=PAS$K_SUCCESS then
      Begin
        Reset (SaveFile,Error:=Continue);
        If Not EOF (SaveFile) then Read (SaveFile, Temp)
        Else                       Read_Error_Window ('save',Status(SaveFile));
        Close (SaveFile,Error:=Continue);
      End
   Else
      Read_Error_Window ('save',Status(SaveFile));

   { Return the data }

   Load_Saved_Game:=Temp;
End;  { Load Saved Game }

{**********************************************************************************************************************************}

[Global]Procedure Change_Score (Var Character: Character_Type; Score_Num, Inc: Integer);

{ This procedure changes an ability score of a character }

Begin { Change Score }
   If ((Character.Abilities[Score_Num]>3)  and (Inc<0)) or
      ((Character.Abilities[Score_Num]<25) and (Inc>0)) then
      Character.Abilities[Score_Num]:=Character.Abilities[Score_Num]+Inc;
End;  { Change Score }

{**********************************************************************************************************************************}

[Global]Procedure Special_Occurance (Var Character: Character_Type; Number: Integer);

[External]Function XP_Needed (Class: Class_Type; Level: Integer): Real;external;
[External]Function Made_Roll (Needed: Integer): [Volatile]Boolean;external;

{ This procedure implements the "special occurances" (kinda like Daka's special dinners) for an item or whatever. All it does it
  something hard-coded for each particular item }

Var
   X: Integer;

Begin { Special Occurance }
   Case Number of
        1: If Made_Roll (65) then
              If Not Made_Roll(Character.Level) then
                 Begin { Raise Character's level }
                     Character.Level:=Character.Level+1;
                     Character.Experience:=XP_Needed (Character.Class,Character.Level);
                 End;  { Raise Character's Level }
        2: Begin { Lower character's level }
              Character.Level:=Character.Level-1;
              If Character.Level<1 then
                 Begin
                    Character.Level:=1;
                    Character.Curr_HP:=0;
                    Character.Max_HP:=0;
                    Character.Status:=Deleted;
                 End
              Else
                 Character.Experience:=XP_Needed (Character.Class,Character.Level);
           End;  { Lower character's level }
        3: Begin { Reduce a character's age 2-20 years }
              Character.Age:=Character.Age-(Roll_Die(10)*2*365);
              If Character.Age<(10*365) then Character.Age:=10*365;
           End;  { Increase a characters age }

           { Raise the ability scores }
        4..10: Change_Score (Character,Number-3,Roll_Die(3));

           { Lower the ability scores }

        11..17: Change_Score (Character,Number-10,Roll_Die(3)*(-1));
        18: Begin
               For X:=1 to 12+Roll_Die(12) do
                   If Character.Class=Barbarian then
                      Character.Class:=Cleric
                   Else
                      Character.Class:=Succ(Character.Class);
               If Character.Class=Character.PreviousClass then
                   If Character.Class=Barbarian then
                      Character.Class:=Cleric
                   Else
                      Character.Class:=Succ(Character.Class);

            End;
        19: Begin
               Character.Alignment:=Evil;
               Character.Abilities[1]:=Max(Character.Abilities[1], 17);
            End;
        Otherwise ;
   End;
End;  { Special Occurance }

{**********************************************************************************************************************************}

[Global]Procedure Show_Image (Number: Pic_Type; Var Display: Unsigned);

{ This procedure will copy the NUMBERth picture onto DISPLAY }

Var
   X,Y: Integer;
   Pic: Picture;
   Image: Image_Type;

Begin { Show Image }

   { Get the appropriate image }

   Pic:=Pics[Number];
   Image:=Pic.Image;

   { Copy it onto the display }

   SMG$Begin_Display_Update (Display);
   For Y:=1 to 9 do
      For X:=1 to 23 do
         SMG$Put_Chars (Display,Image[X,Y],Y+0,X+0);
   SMG$End_Display_Update (Display);
End;  { Show Image }

{**********************************************************************************************************************************}

Function Time_And_Date_And_Name: [Volatile]Line;

{ This function returns the current time, date, and username of player }

Var
   T: Line;
   T1: Time_type;

Begin { Time and Date and Name }
   T1:='';  Time(T1);
   T:=User_Name+' '+T1;
   Date(T1);
   Time_and_Date_and_Name:=T+'     '+T1+'   '
End;  { Time and Date and Name }

{**********************************************************************************************************************************}

Procedure Log_Player_In;

{ This procedure records the time and date the user logged into the logfile. }

Begin { Log Player In }
   If Logging and (User_Name<>Owner_Account) then Extend_LogFile (Time_And_Date_And_name+'IN');
End;  { Log Player In }

{**********************************************************************************************************************************}

Procedure Log_Player_Out;

{ See above? }

Begin { Log Player Out }
   If Logging and (User_Name<>Owner_Account) then
      Extend_LogFile (Time_And_Date_And_name+'OUT');
End;  { Log Player Out }

{**********************************************************************************************************************************}
[Global]Procedure Write_Roster;Forward;
{**********************************************************************************************************************************}

Procedure Create_Roster_File;

{ Indicate the roster file will be created and make a null roster for that
  purpose.. }

Var
   Loop: Integer;

Begin { Create Roster File }

  { Indicate that the file will be created }

   SMG$Put_Chars (ScreenDisplay,'Creating: CHARACTER.DAT',23,1,1);

  { Initialize the characters }

  Roster:=Zero;
  For Loop:=1 to 20 do  Roster[Loop].Status:=Deleted;
  Write_Roster;
End;  { Create Roster File }

{**********************************************************************************************************************************}

Procedure Read_Roster;

{ This procedure reads in the current roster.  If no file exists, null characters are to be saved on exiting }

Var
   Loop: Integer;

Begin { Read Roster }
   Repeat
      Open (Char_File,'SYS$LOGIN:Character.Dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READONLY)
   Until (Status(Char_File)<>PAS$K_FILALROPE);

   { If the file doesn't exist, or is in an out-dated format }

   If Status(Char_File)=PAS$K_FILNOTFOU then
      Create_Roster_file
   Else
      Begin { File is there }
         Reset (Char_File,Error:=Continue);
         If Status(Char_File)<>PAS$K_SUCCESS then
            Begin { Can't open it }
               Read_Error_Window ('character',STATUS(Char_File));
               Close (Char_File);
               Create_Roster_file;
            End   { Can't Open it }
         Else
            Begin { Read the characters and then close the file }
               For Loop:=1 to 20 do Read (Char_File,Roster[Loop],Error:=Continue);
               If (Status(Char_File)<>PAS$K_EOF) then
                   Read_Error_Window ('Character',STATUS(Char_File));
               Close (Char_File);
             End;  { Read the characters and then close the file }
      End;  { File is there }
End;  { Read Roster }

{**********************************************************************************************************************************}

[Global]Function Get_Level (Level_Number: Integer; Maze: Level; PosZ: Vertical_Type:=0): [Volatile]Level;

{ This function will return a level of the dungeon.  If the level of the dungeon is the same as POSZ, i.e., the same level, the
  current level will be returned.  If POSZ is omitted, this will ALWAYS load a new level even if it's simply loading the same level
  as the one in memory }

Var
   Letter:  Char;
   Temp: Level;

Begin { Get Level }
   If (Level_Number<>PosZ) and (Level_Number>0) then
      Begin { If we need to load one ... }

         { Calculate the file name's suffix }

          Letter:=CHR(Level_Number+64);

        { Wait until the file is available and then open it }

         Repeat
            Open (MazeFile, 'Stone_Maze:Maze'+Letter,Error:=CONTINUE,History:=UNKNOWN,Sharing:=READWRITE);
         Until (Status(MazeFile)<>PAS$K_FILALROPE);

         If Status(MazeFile)<>PAS$K_SUCCESS then
             Read_Error_Window ('maze',Status(MazeFile));
         Reset (MazeFile);

         { If the level is defined load it, otherwise return the current level }

         If Not(Eof(MazeFile)) then
            Read (MazeFile,Temp)
         Else
            Temp:=Maze;

         { Close the file and return the level }

         Close (MazeFile);
         Get_Level:=Temp;
      End
   Else
      Get_Level:=Maze;  { Otherwise, return the current level }
End;  { Get Level }

{**********************************************************************************************************************************}

Procedure Read_Items;

{ This procedure will read in the items from the file, and then randomly adjust their prices to simulate increasing and decreasing
  values of items in a market place. }

Var
   Flux: Real;  { Some times you just have to say, "what's the flux?" }
   Max_Items: Integer;

Begin { Read Items }

   Max_Items:=-1;  { So far, no items read }

   { Wait until the file is available and then open it }

   Repeat
      Open (Item_File,'Stone_Data:Items.dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READWRITE)
   Until (Status(Item_File)<>PAS$K_FILALROPE);
   If Status(Item_File)<>PAS$K_SUCCESS then
       Read_Error_Window ('items',Status(Item_File));
   Reset (Item_File);

   While Not EOF(Item_File) do
      Begin { More data }

         { Increase counter and read item }

         Max_Items:=Max_Items+1;
         Read (Item_File,Item_List[Max_Items]);
         STR$TRIM (Item_List[Max_Items].Name,Item_List[Max_Items].Name);
         STR$TRIM (Item_List[Max_Items].True_Name,Item_List[Max_Items].True_Name);

         { Calculate the price fluctuation, FLUX }

         Flux:=Item_List[Max_Items].Gp_Value;
         Flux:=Flux * Roll_Die(10)/100;
         If Roll_Die(2)=2 then Flux:=Flux*(-1);

         { Add flux to the current price }

         Item_List[Max_Items].Current_Value:=Round(Item_List[Max_Items].GP_Value+Flux);

         { Making sure items aren't given away... }

         If Item_List[Max_Items].Current_Value<1 then Item_List[Max_Items].Current_Value:=1;
      End;  { More Data }

   { Close the file when no more data }

   Close (Item_File);
End;  { Read Items }

{**********************************************************************************************************************************}

Procedure Access_Item_Record (N: Integer);

{ This function finds the Nth record in the already opened item_file }

Begin { Access Item Record }
   Repeat
      Find (Item_File,N+1,Error:=CONTINUE)
   Until Status(Item_File)=PAS$K_SUCCESS;
End;  { Access Item Record }

{**********************************************************************************************************************************}

[Global]Function Get_Item (Item_Number: Integer): Item_Record;

{ This function returns the Item_Number'th item from the item_file }

Begin { Get Item }
   Repeat
      Open (Item_File,'STONE_DATA:ITEMS.DAT;1',History:=OLD,Access_Method:=DIRECT,Sharing:=READWRITE,Error:=Continue);
   Until Status(Item_File)=PAS$K_SUCCESS;
   Access_Item_Record (Item_Number);
   Get_Item:=Item_File^;
   Unlock (Item_File);
   Close (Item_File);
End;  { Get Item }

{**********************************************************************************************************************************}

Procedure Read_Monsters (Var Monster: List_of_monsters);

{ This procedure will read in the monsters from the file into the array, MONSTERS }

Var
   Max_Monsters: Integer;

Begin { Read Monsters }

   { Wait until the file is available and then open it }

   Repeat
      Open (Monster_File,'Stone_Data:Monsters.dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READWRITE)
   Until (Status(Monster_File)<>PAS$K_FILALROPE);
   If Status(Monster_File)<>PAS$K_SUCCESS then
       Read_Error_Window ('monster',Status(Monster_File));
   Reset (Monster_File); { Open the file }

   { Read in the monsters }

   For Max_Monsters:=1 to 450 do Read (Monster_File,Monster[Max_Monsters],Error:=Continue);
   Close (Monster_File); { Close the file }
End;  { Read_Monsters }

{**********************************************************************************************************************************}

Procedure Access_Monster_Record (N: Integer);

Begin { Access Monster Record }
   Repeat
      Find (Monster_File,N,Error:=CONTINUE)
   Until Status(Monster_File)=PAS$K_SUCCESS;
End;  { Access Monster Record }

{**********************************************************************************************************************************}

[Global]Function Get_Monster (Monster_Number: Integer): Monster_Record;

{ This function returns the Monster_Number'th monster from the
  Monster_File. }

Begin { Get Monster }
   Repeat
      Open (Monster_File,'STONE_DATA:MONSTERS.DAT;1',History:=OLD,Access_Method:=DIRECT,Sharing:=READWRITE,Error:=Continue);
   Until Status(Monster_File)=PAS$K_SUCCESS;
   Access_Monster_Record (Monster_Number);
   Get_Monster:=Monster_File^;
   Unlock (Monster_File);
   Close (Monster_File);
End;  { Get Monster }

{**********************************************************************************************************************************}

Procedure Read_Pictures;

{ This procedure reads in the set of pictures }

Var
   Loop: Integer;

Begin { Read Pictures }

   { Wait until the file is available and then open it }

   Repeat
      Open (PicFile,'Stone_Data:Pictures.Dat',History:=OLD,Error:=CONTINUE,Sharing:=READWRITE);
   Until Status(PicFile)<>PAS$K_FILALROPE;
   If Status(PicFile)<>PAS$K_SUCCESS then Read_Error_Window ('picture',Status(PicFile));
   Reset (PicFile);

   { Read in the pictures and close the file }

   Loop:=0;
   While Not EOF(PicFile) do
      Begin
         Read(PicFile,Pics[Loop]);
         Loop:=Loop+1;
      End;
   Close (PicFile);
End;  { Read Pictures }

{**********************************************************************************************************************************}

[Global]Procedure Read_Messages (Var Messages: Message_Group);

{ This procedure reads in the text from the message file }

Var
   Loop: Integer;

Begin { Read Messages }

   { Wait until the file is available and then open it }

   Repeat
      Open (Message_File,'Stone_Data:Messages.Dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READWRITE);
   Until Status(Message_File)<>PAS$K_FILALROPE;
   If Status(Message_File)<>PAS$K_SUCCESS then
       Read_Error_Window ('messages',Status(Message_File));
   Reset (Message_File);

   { Read in the messages and close the file }

   For Loop:=1 to 999 do
      Begin
         Readln (Message_File,Messages[Loop],Error:=Continue);
         If Not ((Status(Message_File)=PAS$K_SUCCESS) or (Status(Message_File)=PAS$K_EOF)) then Messages[Loop]:='';
      End;
   Close (Message_File);
End;  { Read Messages }

{**********************************************************************************************************************************}

Procedure Read_Treasures;

{ This procedure will read in the treasure types }

Var
   Loop: Integer;

Begin { Read Treasures }

   { Wait until the file is available and then open it }

   Repeat
      Open (TreasFile,'Stone_Data:Treasure.Dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READWRITE);
   Until Status(TreasFile)<>PAS$K_FILALROPE;
   If Status(TreasFile)<>PAS$K_SUCCESS then
       Read_Error_Window ('treasure',Status(TreasFile));
   Reset (TreasFile);

   { Read in the treasures and close the file }

   For Loop:=1 to 150 do Read (TreasFile,Treasure[Loop]);
   Close (TreasFile);
End;  { Read Treasures }

{**********************************************************************************************************************************}

[Global]Procedure Error_Window (FileType: Line);

{ Print a error message window }

Var
   BroadcastDisplay: Unsigned;  { Virtual keyboard and Broadcast }
   Msg: Line;

Begin { Error Window }
  Msg:='* * * Error writing '+FileType+' file! * * *';
  SMG$Create_Virtual_Display(5,78,BroadcastDisplay,1);
  SMG$Erase_Display (BroadcastDisplay);
  SMG$Label_Border (BroadcastDisplay,'> Yikes! <',SMG$K_TOP);

        { Print the message to the display }

  SMG$Put_Chars    (BroadcastDisplay,Msg,3,39-(Msg.Length div 2));

        { Paste it onto the pasteboard }

  SMG$Paste_Virtual_Display (BroadcastDisplay,Pasteboard,2,2);

               { Delete all created virtual devices }

  LIB$WAIT (3);

  SMG$Unpaste_Virtual_Display (BroadcastDisplay,Pasteboard);
  SMG$Delete_Virtual_Display (BroadcastDisplay);
End;  { Error Window }

{**********************************************************************************************************************************}

Function Successful (Result_Code: Integer): Boolean;

Begin { Successful }
   Successful:=(Result_Code=PAS$K_SUCCESS) or (Result_Code=PAS$K_EOF);
End;  { Successful }

{**********************************************************************************************************************************}

Procedure Write_Roster;

{ This procedure is used to write the current roster to the character file }

Var
   Loop: Integer;
   Error: Boolean;

Begin { Write Roster }
   No_ControlY;
   Error:=False;
   Repeat
      Open (Char_File,'SYS$LOGIN:Character.Dat;1',History:=UNKNOWN,Error:=CONTINUE,Sharing:=NONE)
   Until (Status(Char_File)<>PAS$K_FILALROPE);
   Error:=(Status(Char_File)<>PAS$K_SUCCESS);

   ReWrite (Char_File,Error:=Continue);
   Error:=Error or Not(Successful(Status(Char_File)));

   { Write the characters and close the file }

   For Loop:=1 to 20 do
      Begin
         Write (Char_File,Roster[Loop]{,Error:=continue});
         Error:=Error or Not(Successful(Status(Char_File)));
      End;

   Close (Char_File{,Error:=Continue});
   Error:=Error or Not(Successful(Status(Char_File)));

   If Error then Error_Window ('Character');        { Put a window declaring the error }
   ControlY;
End;  { Write Roster }

{**********************************************************************************************************************************}

[Global]Procedure Save_Pictures;

{ This procedure will write an updated set of pictures if the user is authorized to do so. }

Var
   Loop: Integer;

Begin { Save Pictures }

   { Wait until the file is available and then open it }

   Repeat
      Open (PicFile,'Stone_Data:Pictures.Dat',History:=OLD,Error:=CONTINUE,Sharing:=READONLY);
   Until (Status(PicFile)=PAS$K_SUCCESS);
   ReWrite (PicFile,Error:=Continue);

   { Write the pictures and close the file }

   For Loop:=1 to 150 do Write (PicFile,Pics[Loop]);
   Close (PicFile);
End;  { Save Pictures }

{**********************************************************************************************************************************}

[Global]Procedure Save_Monsters (Monster: List_of_monsters);

{ This procedure will save the updates monster records if the current user is authorized to do so. }

Var
   Loop: Integer;

Begin { Save Monsters }

   { Wait until the file is available and then open it }

   Repeat
      Open (Monster_File,'Stone_Data:Monsters.Dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READONLY)
   Until (Status(Monster_File)=PAS$K_SUCCESS);
   ReWrite (Monster_File,Error:=Continue);

   { Write the monsters }

   For Loop:=1 to 450 do Write (Monster_File,Monster[Loop]);

   { Close the file }

   Close (Monster_File);
End;  { Save Monsters }

{**********************************************************************************************************************************}

Procedure Save_Items;

{ This procedure will save the updated item records if the current user is authorized to do so. }

Var
   Loop: Integer;

Begin { Save Items }

   { Wait until the file is available and then open it }

   Repeat
      Open (Item_File,'Stone_Data:Items.Dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READONLY)
   Until (Status(Item_File)=PAS$K_SUCCESS);
   ReWrite (Item_File,Error:=Continue);

   { Write the items ... }

   For Loop:=0 to 449 do Write (Item_File,Item_List[Loop]);

   { Close the file }

   Close (Item_File);
End;  { Save Items }

{**********************************************************************************************************************************}

Procedure Save_Treasure;

{ This procedure will save the updated treasure list if the current user is authorized to do so. }

Var
   Loop: Integer;

Begin { Save Treasure }

   { Wait until the file is available and then open it }

   Repeat
      Open (TreasFile,'Stone_Data:Treasure.Dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READONLY)
   Until (Status(TreasFile)=PAS$K_SUCCESS);
   ReWrite (TreasFile);

   { Write the treasures ... }

   For Loop:=0 to 150 do Write (TreasFile,Treasure[Loop]);

   { Close the file }

   Close (TreasFile);
End;  { Save_Treasure }

{**********************************************************************************************************************************}

[Global]Procedure Delay (Seconds: Real);

{ This procedure will wait SECONDS seconmds.  This is good because the game
  hibernates, saving CPU time.  }

Begin { Delay }
   Lib$Wait(Seconds);
End;  { Delay }

{**********************************************************************************************************************************}

[Global]Procedure Print_Roster;

{ This procedure will print the roster of characters to SCREENDISPLAY }

Var
   Slot: Integer;
   T: Line;

Begin { Print Roster }

   { Erase and label the proper display }

   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay);
   T:='Roster of Characters';
   SMG$Set_Cursor_ABS (ScreenDisplay,1,40-(t.length div 2));
   SMG$Put_Line (ScreenDisplay,T,1,1);
   SMG$Put_Line (ScreenDisplay,
       ' #)  Name                 Class               Level       Status',1,0);

   { Print all the characters }

   For Slot:=1 to 20 do
      If Roster[Slot].Status<>Deleted then  { If the slot is used ... }
        Begin { Print the occupant }
          SMG$Put_Chars (ScreenDisplay,
                          String (Slot,2)
                          +')  ');
           SMG$Put_Chars (ScreenDisplay,Pad(Roster[Slot].Name,' ',21));
           SMG$Put_Chars (ScreenDisplay,AlignName[Roster[Slot].Alignment][1]
                          +'-');
           SMG$Put_Chars (ScreenDisplay,
                          Pad(ClassName[Roster[Slot].Class],' ',16));
           SMG$Put_Chars (ScreenDisplay,String (Roster[Slot].Level,3));
           SMG$Put_Chars (ScreenDisplay,'           '
                          +StatusName[Roster[Slot].Status]);
        End  { Print the occupant }
      Else { Otherwise print a blank line }
        SMG$Put_Line (ScreenDisplay,'');
    SMG$End_Display_Update (ScreenDisplay);
End;  { Print Roster }

{**********************************************************************************************************************************}

[Global]Procedure Plane_Difference (Var Plus: Integer; PosZ: Integer);

Var
   Lower_Bound,Upper_Bound: Integer;

Begin { Plane Difference }
   If PosZ>10 then
      If Plus>0 then
         Begin
            Lower_Bound:=0;
            Plus:=Plus-(PosZ-10);
            If Plus<Lower_Bound then Plus:=Lower_Bound;
         End
   Else
      If Plus<0 then
         Begin
            Upper_Bound:=0;
            Plus:=Plus+(PosZ-10);
            If Plus>Upper_Bound then Plus:=Upper_Bound;
         End;
End;  { Plane Difference }

{**********************************************************************************************************************************}

[Global]Function Screen_Line (LineWidth: Integer:=80): Line;

{ This function returns a line of the format:

        +------------+

  of width LINEWIDTH.  This is used primarily for KYRN, but other uses may arise. }

Var
   Temp: Line;
   Loop: Integer;

Begin { Screen Line }
   Temp:='+';  { Left '+' }
   For Loop:=2 to (LineWidth-1) do
        Temp:=Temp+'-';  { Intermediate '-'s }
   Screen_Line:=Temp+'+'; { Right '+' }
End;  { Screen Line }

{**********************************************************************************************************************************}

Procedure Initialize_Displays;

{ This procedure creates virtual displays for use with SMG$.  If any displays, for example a command window, never changes, it is
  initialized here with the proper text. }

Begin { Initialize Displays }

   { Create the displays }

   SMG$Create_Virtual_Display (7,78,CharacterDisplay,1);
   SMG$Create_Virtual_Display (4,54,MonsterDisplay,1);
   SMG$Create_Virtual_Display (4,54,CommandsDisplay,1);
   SMG$Create_Virtual_Display (4,54,SpellsDisplay,1);
   SMG$Create_Virtual_Display (4,54,OptionsDisplay,1);
   SMG$Create_Virtual_Display (4,54,TextDisplay,1);
   SMG$Create_Virtual_Display (9,23,ViewDisplay,1);
   SMG$Create_Virtual_Display (9,23,FightDisplay,1);
   SMG$Create_Virtual_Display (4,78,MessageDisplay,1);
   SMG$Create_Virtual_Display (22,78,CampDisplay,1);
   SMG$Create_Virtual_Display (22,78,GraveDisplay,1);
   SMG$Create_Virtual_Display (22,78,ScenarioDisplay,1);
   SMG$Create_Virtual_Display (22,78,WinDisplay,1);
   SMG$Create_Virtual_Display (24,80,HelpDisplay,0);
   SMG$Create_Virtual_Display (24,80,ShellDisplay,0);
   SMG$Create_Virtual_Display (10,78,TopDisplay,1);
   SMG$Create_Virtual_Display (12,80,BottomDisplay);

   { Label the proper borders }

   SMG$Label_Border(ScenarioDisplay,
       '=*> The Quest of the Stone <*=',SMG$K_TOP);
   SMG$Label_Border(WinDisplay,
       '=*> The Quest of the Stone <*=',SMG$K_TOP);
   SMG$Label_Border(GraveDisplay,
       ' Warrior''s Gate ',SMG$K_TOP);
   SMG$Label_Border(CampDisplay,
       ' Camp ',SMG$K_TOP);
   SMG$Label_Border(MonsterDisplay,
       ' Combat ',SMG$K_TOP);
   SMG$Label_Border(TopDisplay,
       'Kyrn',SMG$K_RIGHT);
   SMG$Label_Border(ViewDisplay);

   { Initialize the proper borders }

   SMG$Put_Chars(CommandsDisplay,
       'F)orward         C)amp          S)tay 1 round',1,3);
   SMG$Put_Chars(CommandsDisplay,
       'L)eft            T)ime Delay          ^       ',2,3);
   SMG$Put_Chars(CommandsDisplay,
       'R)ight           HELP                 |       ',3,3);
   SMG$Put_Chars(CommandsDisplay,
       'K)ick            DO            <------+------>',4,3);
End;  { Initialize Displays }

{**********************************************************************************************************************************}

Procedure Add_Dot (Var X: Integer);

{ This procedure adds a dot to the line of dots on the screen }

Begin { Add Dot }
   SMG$Put_Chars (ScreenDisplay,'. ',11,X);
   X:=X+1;
End;  { Add Dot }

{**********************************************************************************************************************************}

{ 2023-09-22 JHG - Couldn't get all the volatile parms working.  [Asynchronous,Global]}Procedure Out_of_Band_AST (Var Arguments: AST_Arg_Type);

{ This procedure handles any control characters typed by the users during
  the game }

Begin { Out of Band AST }
   Case Arguments.Control_Key of
         SMG$K_TRM_CTRLW,SMG$K_TRM_CTRLR:  SMG$Repaint_Screen (Pasteboard); { 2023-09-22 JHG - Did not take Arguments as a parameter }
         SMG$K_TRM_CTRLP:                  Print_Pasteboard  (Arguments,Pasteboard);
         Otherwise ;
   End;
End;  { Out of Band AST }

{**********************************************************************************************************************************}

[Global]Procedure Trap_Out_of_Bands;

{ This procedure enables the trapping of special keys }

Const  { Trap these characters }
   Trap = 2**SMG$K_TRM_CTRLW+
          2**SMG$K_TRM_CTRLR+
          2**SMG$K_TRM_CTRLP;

Begin { Trap Out of Bands }
   SMG$Set_Out_Of_Band_ASTs (Pasteboard,Trap,AST_Routine:=%Immed OUT_OF_BAND_AST);
End;  { Trap Out of Bands }

{**********************************************************************************************************************************}

[Global]Procedure Dont_Trap_Out_of_Bands;

Begin { Dont Trap Out of Bands }
   SMG$Set_Out_Of_Band_ASTs (Pasteboard,0);
End;  { Dont Trap Out of Bands }

{**********************************************************************************************************************************}

Procedure Create_Virtual_Devices;

{ This procedure creates two virtual devices for use with SMG$.  The first is PASTEBOARD, which handles all screen output and is a
  virtual screen.  The display SCREENDISPLAY is pasted on it to start out with, but other displays may be pasted and removed during
  the course of game play.  The second device is the Virtual Keyboard, through which keys are read. }

[External,Unbound]Procedure Message_trap;external;

Begin { Create Virtual Devices }

   { Create the virtual terminal and keyboard }

   SMG$Create_Pasteboard (Pasteboard);
   SMG$Create_Virtual_Keyboard(keyboard);

   { Turn off the cursor }

   No_Cursor;

   { Enable message trapping }

   SMG$Set_Broadcast_Trapping (pasteboard,%Immed Message_Trap,0);

   { Enable screen repainting on ^W }

   Trap_Out_of_Bands;

   { Create and clear the primary screen display }

   SMG$Create_Virtual_Display (24, 80,ScreenDisplay,0);
   SMG$Erase_Display (ScreenDisplay);

   { Print the initialization message to the display }

   SMG$Put_Chars (ScreenDisplay, 'Initializing Game',10,33,,1);
   SMG$Put_Chars (ScreenDisplay, 'Please Wait. ',11,35);

   { Paste the display onto the pasteboard }

   SMG$Paste_Virtual_Display (ScreenDisplay,Pasteboard,1,1);
End;  { Create Virtual Devices }

{**********************************************************************************************************************************}

Function Get_Seed: [Volatile]Integer;

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

{**********************************************************************************************************************************}

[Global]Function Saved_Game: [Volatile]Boolean;

{ This function returns TRUE is there is a previous game saved, and FALSE otherwise. }

Var
   Temp: Boolean;

Begin { Saved Game }

   { Open the save file }

   Open (SaveFile,'SYS$LOGIN:STONE_SAVE.DAT',History:=OLD,Error:=CONTINUE,Sharing:=NONE);

   { No data in the file => No saved game }

   Temp:=NOT(Status(SaveFile)=PAS$K_FILNOTFOU);
   Saved_Game:=Temp;

   { Close the save file }

   If Temp then Close (SaveFile);
End;  { Saved Game }

{**********************************************************************************************************************************}

Procedure Initialize_Globals;

{ This procedure initializes all globals and externally used variables.  This is so that when a call is mode to, say,
  Print_Character, MAZE is defined even though it may not be used. }

Begin { Initialize Globals }
   Experience_Needed:=Zero;

   { We're not leaving the maze when we haven't entered it... }

   Leave_Maze:=False;

   { The current "level" has no contents... }

   Maze.Room:=Zero;

   { The backup level is the same... }

   Position:=Maze;

   { We're arbitrarily facing North... }

   Direction:=North;

   { We've spent zero minutes in the maze... }

   Minute_Counter:=0;

   { We've casted no spells }

   Rounds_Left:=Zero;

   { ... and we're at maze coordinates (0,0,0) }

   PosX:=0;   PosY:=0;  PosZ:=0;
End;  { Initialize Globals }

{**********************************************************************************************************************************}

Procedure Initialize;

{ This procedure initializes the game. Initialized are virtual devices, string constants, and virtual displays.  Information from
  the disk is brought in at this point. }

Var
   X: Integer;

Begin { Initialize }
   If Not (Authorized or (User_name=Owner_Account)) then $SETPRI (Pri:=4,PrvPri:=Start_Priority);
   Log_Player_In;
   X:=47;                                  { Initialize X for ADD_DOT }
   Cursor_Mode:=True;                      { The cursor is on at the moment }
   Create_Virtual_Devices;  Add_Dot(X);    { Create pasteboard and keyboard }
   Read_Pictures;           Add_Dot(X);    { Read in the picture images }
   Read_Roster;             Add_Dot(X);    { Read in the characters }
   Read_Treasures;          Add_Dot(X);    { Read in the treasure types }
   Read_Items;              Add_Dot(X);    { Read in items }
   Initialize_Displays;     Add_Dot(X);    { Create and initialize displays }
   Initialize_Globals;      Add_Dot(X);    { Initialize external variables }
   Broadcast_On:=True;      Add_Dot(X);
   Bells_On:=True;          Add_Dot(X);
   Game_Saved:=Saved_Game;  Add_Dot(X);    { Is there a saved game? }
   Auto_Load:=False;        Add_Dot(X);
   Auto_Save:=False;        Add_Dot(X);
   Seed:=Get_Seed;          Add_Dot(X);    { Get a seed for the rand. #s }
End;  { Initialize }

{**********************************************************************************************************************************}

[Global]Function Rendition_Set (Var T: Line): Unsigned;

{ This function scans T for special characters, and then returns the renditionset for SMG$ to print out T with the right
  renditions }

Var
  New_Line: Line;
  Position: Integer;
  Blinking,Bold,Inverse,Underline: Boolean;
  Temp: Unsigned;

Begin { Rendition_Set }
   New_Line:='';
   Bold:=False;  Inverse:=False;  Underline:=False;  Blinking:=False;
   For Position:=1 to T.Length do
     Case T[Position] of
        '^': Bold:=True;
        '_': Underline:=True;
        '`': Inverse:=True;
        '{': Blinking:=True;
        Otherwise New_Line:=New_Line+T[Position];
     End;
   T:=New_Line;      Temp:=SMG$M_NORMAL;
   If Bold then      Temp:=Temp+SMG$M_BOLD;
   If Inverse then   Temp:=Temp+SMG$M_REVERSE;
   If Blinking then  Temp:=Temp+SMG$M_BLINK;
   If Underline then Temp:=Temp+SMG$M_UNDERLINE;
   Rendition_Set:=Temp;
End;  { Rendition Set }

{**********************************************************************************************************************************}

Procedure View_Scenario;

{ This procedure prints the scenario to a bordered display }

Const
   Length=21;    { Maximum number of lines allowed }

Var
   LineCount: Integer;
   L,Msg: Line;
   Rendition: Unsigned;  { Rendition set for line }

Begin { View Scenario }
   Repeat
      Open (Message_File,'Stone_Data:Messages.dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READWRITE)
   Until (Status(Message_File)<>PAS$K_FILALROPE);
   If Status(Message_File)<>PAS$K_SUCCESS then
       Read_Error_Window ('messages',Status(Message_File));
   Reset (Message_File);

   LineCount:=0;
   SMG$Erase_Display (ScenarioDisplay);
   SMG$Paste_Virtual_Display (ScenarioDisplay,Pasteboard,2,2);

   SMG$Begin_Display_Update (ScenarioDisplay);
   SMG$Erase_Display (ScenarioDisplay);
   Readln (Message_File,Msg);
   While Msg<>'~' do        { the '~' is the end of the message mark }
      Begin
         Rendition:=Rendition_Set (Msg);  { Determine print options for line }
         SMG$Put_Line (ScenarioDisplay,Msg,1,Rendition);
         Readln (Message_File, Msg);
         LineCount:=LineCount+1;
         If LineCount=Length then
            Begin
               LineCount:=0;
               Rendition:=1;  L:='Press a key for more';
               SMG$Put_Chars (ScenarioDisplay,L,22,39-(L.Length div 2),,1);
               SMG$End_Display_Update (ScenarioDisplay);
               Wait_Key;
               SMG$Begin_Display_Update (ScenarioDisplay);
               SMG$Erase_Display (ScenarioDisplay);
            End;
      End;
   Close (Message_File);
   L:='Press a key to continue';
   SMG$Put_Chars (ScenarioDisplay,L,22,39-(L.length div 2),1,1);
   SMG$End_Display_Update (ScenarioDisplay);
   Wait_Key;
   SMG$Unpaste_Virtual_Display (ScenarioDisplay,Pasteboard);
End;  { View Scenario }

{**********************************************************************************************************************************}

[Global]Procedure Draw_Menu;

{ This procedure draws the main menu }

Var
   T: Line;

Begin { Draw Menu }
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay);
   SMG$Put_Chars (ScreenDisplay,
       'Stone Quest '+Version_Number,5,32,1,1);
   SMG$Put_Chars (ScreenDisplay,
       '----- ----- ----',6,32,1,1);
   SMG$Put_Chars (ScreenDisplay,
       'Based on Sir-Tech''s Wizardry',7,26);
   SMG$Put_Chars (ScreenDisplay,
       'By Jeffrey Getzin',8,31);
   SMG$Put_Chars (ScreenDisplay,
       'Graphics designed by David Corn and Jeffrey Getzin',9,15);
   T:='Hit the HELP key at any time for on-line help';
   SMG$Put_Chars (ScreenDisplay,T,10,(40-(T.length div 2)));
   T:='S)tart Game, L)look at high scores';
   If Authorized then
      T:=T+', run U)tilities'
   Else
      T:=T+', run P)layer utilities';
   SMG$Put_Chars (ScreenDisplay,T,13,(40-(T.length div 2)));
   T:='V)iew scenario';
   If Game_Saved then T:=T+', R)estore saved game';
   T:=T+', or Q)uit (? = help)';
   SMG$Put_Chars (ScreenDisplay,T,14,(40-(T.length div 2)));
   SMG$End_Display_Update (ScreenDisplay);
End;  { Draw Menu }

[External]Procedure Utilities (Var Pics: Pic_List;  Var MazeFile: LevelFile;  Var Roster: Roster_Type;
                     Var Treasure: List_of_Treasures;  Var Item_List: List_of_Items);External;

{**********************************************************************************************************************************}

Procedure Set_Up_Kyrn;

{ This procedure sets up the pasteboard et al for Kyrn }

Begin { Set up Kyrn }
   Main_Menu:=False;
   SMG$Begin_Pasteboard_Update (Pasteboard);           { End_Pasteboard_Update occurs in TOWN/INITIALIZE }
   SMG$Paste_Virtual_Display (TopDisplay,Pasteboard,2,2);
   SMG$Paste_Virtual_Display (BottomDisplay,Pasteboard,13,1);
   SMG$Unpaste_Virtual_Display (ScreenDisplay,Pasteboard);
End;  { Set up Kyrn }

{**********************************************************************************************************************************}

Procedure Exit_Kyrn;

{ This does all the stuff that needs to be done (like updating the high scores)
  when leaving Kyrn }

[External]Procedure Update_High_Scores (Username: Line);external;

Begin { Exit Kyrn }
   Update_High_Scores (User_Name);
   SMG$Erase_Display (ScreenDisplay);
   If Not Auto_Save then SMG$Paste_Virtual_Display (ScreenDisplay,Pasteboard,1,1);
   SMG$Unpaste_Virtual_Display (TopDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (BottomDisplay,Pasteboard);
   Main_Menu:=False;
End;  { Exit Kyrn }

{**********************************************************************************************************************************}

Procedure Start_Game;

{ This procedure enters the game play mode.  It pastes two necessary displays onto the pasteboard before entering, and then removes
  them when done.  }

[External]Procedure Kyrn (Var Roster: Roster_Type);external;

Begin { Start Game }
  Set_up_Kyrn;

  Kyrn (Roster);

  Exit_Kyrn;
End;  { End Game }

{**********************************************************************************************************************************}

Procedure Restore_Game;

{ This procedure begins restoration of a previously saved game }

[External]Procedure Kyrn (Var Roster: Roster_Type);external;

Begin { Restore Game }
   Auto_load:=True;
   SMG$Put_Chars (ScreenDisplay,
                  '* * * Resuming where you left off * * *',23,20);

   Set_Up_Kyrn;

   Kyrn (Roster);

   Exit_Kyrn;  { For when the user exits Kyrn after saving }
End;  { Restore Game }

{**********************************************************************************************************************************}

Procedure Handle_Auto_Save;

{ This procedure handles the tail end of an already-started saving }

Begin { Handle Auto Save }
   SMG$Paste_Virtual_Display   (ScreenDisplay,Pasteboard,1,1);
   SMG$Unpaste_Virtual_Display (TopDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (BottomDisplay,Pasteboard);
   SMG$End_Pasteboard_Update   (Pasteboard);
   Auto_Save:=False;
End;  { Handle Auto Save }

{**********************************************************************************************************************************}

Procedure Print_Help_Screen;

Var
  HelpMeDisplay: unsigned;

Begin
  SMG$CREATE_VIRTUAL_DISPLAY (22,78,HelpMeDisplay,1);
  SMG$Erase_Display (HelpMeDisplay);

  SMG$Put_Line (HelpMeDisplay,
      'Options:');
  SMG$Put_Line (HelpMeDisplay,
      '--------');
  SMG$Put_Line (HelpMeDisplay,
       '    Start Game          = Begin playing.  If you have never '
       +'played before,');
  SMG$Put_Line (HelpMeDisplay,
      '                          this should be one of your first options.');
  SMG$Put_Line (HelpMeDisplay,
      '    Quit                = Stop playing for now.  All characters '
      +'and situations:');
  SMG$Put_Line (HelpMeDisplay,
      '                          will be saved for the next time you play.');
  SMG$Put_Line (HelpMeDisplay,
      '    Player Utilities    = Activate the player utilities.  The'
      +' player utilities');
  SMG$Put_Line (HelpMeDisplay,
      '                          allow such activities as recovering'
      +' accidentally lost');
  SMG$Put_Line (HelpMeDisplay,
      '                          characters, the changing of default '
      +'print queues, and');
  SMG$Put_Line (HelpMeDisplay,
      '                          the turning on and off of message '
      +'trapping and bells.');
  SMG$Put_Line (HelpMeDisplay,
      '    Look at High Scores = Allows you to see how you rank '
      +'against the other');
  SMG$Put_Line (HelpMeDisplay,
      '                          players of Stonequest.');
  SMG$Put_Line (HelpMeDisplay,
      '    View Scenario       = The option will print a couple '
      +'of pages of text');
  SMG$Put_Line (HelpMeDisplay,
      '                          explaining the goal of the game. ');
  SMG$Put_Line (HelpMeDisplay,
      '    Restore saved game  = Allows you to resume play at the '
      +'point your previous-');
  SMG$Put_Line (HelpMeDisplay,
      '                          ly saved.  This option will not '
      +'appear unless you');
  SMG$Put_Line (HelpMeDisplay,
      '                          have saved a game');
  SMG$Put_Line (HelpMeDisplay,
      '', 4);
  SMG$Put_Line (HelpMeDisplay,
      'Press any key to continue...', 0);
  SMG$Paste_Virtual_Display (HelpMeDisplay,Pasteboard,2,2);
  Wait_Key;
  SMG$Unpaste_Virtual_Display (HelpMeDisplay,Pasteboard);
  SMG$Delete_Virtual_Display (HelpMeDisplay);
End;

{**********************************************************************************************************************************}

Procedure Handle_Response (Var Answer: Char);

{ This procedure handles the user's choice.  If the person is an authorized user, i.e., me, an extra option, 'U' for utilities is
  allowed }

Var
   Options: Char_Set;

[External]Procedure Print_Scores;external;

Begin { Handle Response }
   Options:=['V','Q','S','L','P','?'];
   If Authorized then Options:=Options+['U']-['P'];
   If Game_Saved then Options:=Options+['R'];
   Answer:=Make_Choice (Options);
   Case Answer of
      '?': Print_Help_Screen;
      'L': Print_Scores;                                                                  { View High scores }
      'P': Player_Utilities (Pasteboard);                                                 { Access player utilities }
      'R': Restore_Game;                                                                  { Restore the saved game }
      'V': View_Scenario;                                                                 { See what the game's all about }
      'S': Start_Game;                                                                    { Play the game }
      'U': Utilities (Pics,MazeFile,Roster,Treasure,Item_List);                           { Go to Utilities sub-menu }
      'Q': ;                                                                              { Quit }
      Otherwise ;
   End;
End;  { Handle Response }

{**********************************************************************************************************************************}

[Global]Procedure Save_Messages (Messages: Message_Group);

{ This procedure saves the messages to the disk }

Var
   Loop: Integer;

Begin { Save Messages }
   Repeat
      Open (Message_File,'Stone_Data:Messages.dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READONLY)
   Until (Status(Message_File)=PAS$K_SUCCESS);
   Rewrite (Message_File);
   For Loop:=1 to 999 do  Writeln (Message_File,Messages[Loop]);
   Close (Message_File);
End;  { Save Messages }

{**********************************************************************************************************************************}

Procedure Quit;

{ This procedure disables trapping of broadcast messages, returns the cursor to normal, and saves the data used in the game. }

Var
   T: Line;
   X: Integer;

Begin { Quit }

   { Disable screen refreshing and stop intercepting ^C and ^Y }

   Dont_Trap_Out_of_Bands;
   No_ControlY;  { Control-Y during a save is VERY dangerous! Don't let 'em! }

   X:=45;
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay);
   T:='Updating Files';
   SMG$Put_Chars (ScreenDisplay, T, 10,40-(t.length div 2),1);
   T:='Please Wait.';
   SMG$Put_Chars (ScreenDisplay, T, 11,40-(t.length div 2),1);
   SMG$End_Display_Update (ScreenDisplay);
   Write_Roster;                                   Add_Dot (X);
   No_ControlY;  { Control-Y is turned on again in Write Roster, so turn it off! }
   Log_Player_Out;
   If (User_Name=Owner_Account) and DataModified then { Only I can save! Hahaha! }
      Begin
         Save_Items;                               Add_Dot (X);
         Save_Pictures;                            Add_Dot (X);
         Save_Treasure;                            Add_Dot (X);
      End;
   Delete_Virtual_Devices;

   if Not Authorized then $SETPRI (Pri:=Start_Priority);
   ControlY;
End;  { Quit }

{**********************************************************************************************************************************}

[Global]Procedure Kill_Save_File;

{ This procedure will delete the save file }

Begin { Kill Save File }
   LIB$DELETE_FILE ('SYS$LOGIN:STONE_SAVE.DAT;*');
End;  { Kill Save File }


{**********************************************************************************************************************************}

[Global]Function Can_Play: [Volatile]Boolean;

{ Can the user play at this particular time? }

[External]Function Legal_Time: [Volatile]Boolean;External;

Begin { Can Play }
   Can_Play:=False;
   Can_Play:=Authorized;
   If Not Authorized then Can_Play:=Legal_Time;
End;  { Can Play }

{**********************************************************************************************************************************}
[External]Procedure Demo;External;
{**********************************************************************************************************************************}


{ This program is the main driving procedure for STONEQUEST.  It reads the data at the start of the game, and saves it when
  exiting for fast action. }

Begin { Stonequest }
  ShowHours:=False;  Main_Menu:=True;  In_Utilities:=False;
  Authorized:=(User_Name=Owner_Account) or (User_Name='DCORN');
{ If Not Authorized and Trap_Authorized_Error then Establish (Oh_No); }
  If Can_Play then
     Begin
         Initialize;                    { Initialize variables and read in data }
         If Not Authorized then Demo;
         Repeat
            If Can_Play then
               Begin { Legal hours }
                  Draw_Menu;                                    { Print the MAIN_MENU options }
                  Handle_Response (answer);                     { Get the user's choice }
                  Main_Menu:=True;
               End  { Legal hours }
            Else
               Begin { Not legal hours }
                  Answer:='Q';
                  ShowHours:=True;
               End;  { Not legal hours }
         Until Answer='Q';                                      { Quit if it's a "Q" }
         Quit;                                                  { Update files }
         If Not Game_Saved then Kill_Save_File;
     End
  Else
     ShowHours:=True;

  If Not Authorized and Trap_Authorized_Error then Revert;                              { Turn off MORIA's error handler }
  If ShowHours then LIB$DO_COMMAND ('TYPE STONE_DATA:HOURS.DAT');
End.  { StoneQuest }

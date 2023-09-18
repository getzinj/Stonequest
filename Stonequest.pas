[Inherit('TYPES', 'SYS$LIBRARY:STARLET','SYS$LIBRARY:LIBRTL','SMGRTL','SYS$:LIBRARY:STRRTL')]
Program Stonequest (Input,Output,Char_File,Item_File,Monster_File,Message_File,TreasFile,MazeFile,SaveFile,PickFile,AmountFile,
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
   Logging               = True;  { Should users and errors be logged? }

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
   LevelFile           = File of Level;
   Time_Type           = Packed Array [1..11] of char;
   Party_File_Type     = File of Name_Type;
   SpName_Type         = Cler_Spell..Wiz_Spell;

Var
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Files~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
   PrintMazeFile:              [Global]Text;                { A pictoral representation of a level of levels }
   HouseFile:                  [Global]Text;                { The stonequest schedule }
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
   LogFile:                    Packed file fo Line;         { Player log }
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Tables~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
   Roster:                     [Global]Roster_Type;         { All characters }
   Treasure:                   [Global]List_of_Treasures;   { All treasure types }
   Item_List:                  [Global]List_of_Items;       { All items }
   Pics:                       [Global]Pic_List;            { Graphic Images }
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Text~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
   TrapName:                   [Global]Array [Trap_Type]            of Varying[20] of Char;
   Item_Name:                  [Global]Array [Item_Type]            of Varying[7] of char;
   Spell:                      [Global]Array [Spell_Name]           of Varying[4] of Char;
   Long_Spell:                 [Global]Array [Spell_Name]           of Varying [25] of Char;
   StatusName:                 [Global]Array [Status_Type]          of Varying [14] of char;
   ClassName:                  [Global]Array [Class_Type]           of Varying [13] of char;
   AlignName:                  [Global]Array [Align_Type]           of Packed Array  [1..7] of char;
   RaceName:                   [Global]Array [Race_Type]            of Packed Array [1..12] of char;
   SexName:                    [Global]Array [Sex_Type]             of Packed Array [1..11] of char;
   AbilName:                   [Global]Array [1..7]                 of Packed Array [1..12] of char;
   WizSpells,ClerSpells:       [Global]Spell_List;
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Virtual Devices for SMG$~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
  ViewDisplay,MonsterDisplay,SpellsDisplay,TextDisplay,CampDisplay,MessageDisplay,CommandsDisplay  : [Global]Unsigned;
  CharacterDisplay,TopDisplay,BottomDisplay,OptionsDisplay,GraveDisplay,ScenarioDisplay,WinDisplay : [Global]Unsigned;
  SpellListDisplay,ScreenDisplay,FightDisplay,ShellDisplay,HelpDisplay,Pasteboard,Keyboard         : [Global]Unsigned;
{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~General~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
  Experience_Needed:      [Global]Array [Class_Type,1..50] of Real;
  Trap_Authorized_Error:  [Global]Boolean;
  Main_Menu,In_Utilities: Boolean;
  DataModified:           Boolean;
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
  Auth_Size:              [Global]Boolean;                     { Auto-save in progress }
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
  Party_Spell,Person_Spell,Caster_Spell,All_Monster_Spell,Group_Spell,Area_Spell: [Global]Set of Spell_Name;

  Version_Number:         [Global]Line;

Value { We got a lot of 'em! }

    Version_Number:='V2.0';       { Current revision number }
    Trap_Authorized_Error:=True;  { Don't trap errors is user is authorized }
    DataModified:=False;          { Initially, data has not been modified }
    Keypresses:=0;                { No keypresses yet }
    Minutes_Left:=60;             { For use with hour-warnings }
    Authorized:=False;            { The user is not authorized by default! }
    Print_Queue:='SYS$PRINT';     { Where should print screen print to? }
    Main_Menu:=True;              { We start at the main menu }

   { Define the abreviated text for each spell }

  Spell[CrLt]:='CrLt'; Spell[CsLt]:='CsLt'; Spell[Lght]:='Lght'; Spell[Prot]:='Prot'; Spell[Dspl]:='Dspl'; Spell[CrPs]:='CrPs';
  Spell[AnDe]:='AnDe'; Spell[CrSe]:='CrSe'; Spell[CsSe]:='CsSe'; Spell[CoLi]:='CoLi'; Spell[CrVs]:='CrVs'; Spell[CsVs]:='CsVs';
  Spell[Wrth]:='Wrth'; Spell[CrCr]:='CrCr'; Spell[CsCr]:='CsCr'; Spell[Raze]:='Raze'; Spell[Slay]:='Slay'; Spell[GrWr]:='GrWr';
  Spell[Heal]:='Heal'; Spell[Harm]:='Harm'; Spell[DiPr]:='DiPr'; Spell[HoWr]:='HoWr'; Spell[Ress]:='Ress'; Spell[Dest]:='Dest';
  Spell[WoRe]:='WoRe'; Spell[PaHe]:='PaHe'; Spell[DiWr]:='DiWr'; Spell[RaDe]:='RaDe'; Spell[DiDe]:='DiDe'; Spell[Deus]:='Deus';
  Spell[MaMs]:='MaMs'; Spell[Shld]:='Shld'; Spell[Loct]:='Loct'; Spell[Fear]:='Fear'; Spell[ChTr]:='ChTr'; Spell[FiBl]:='FiBl';
  Spell[LiBt]:='LiBt'; Spell[BiSh]:='BiSh'; Spell[GrSh]:='GrSh'; Spell[DuBl]:='DuBl'; Spell[CoCd]:='CoCd'; Spell[Tele]:='Tele';
  Spell[Bani]:='Bani'; Spell[DeSp]:='DeSp'; Spell[HgSh]:='HgSh'; Spell[Besk]:='Besk'; Spell[Slep]:='Slep'; Spell[MgFi]:='MgFi';
  Spell[Rein]:='Rein'; Spell[Kill]:='Kill'; Spell[Holo]:='Holo'; Spell[Sile]:='Sile'; Spell[TiSt]:='TiSt'; Spell[Levi]:='Levi';
  Spell[CrPa]:='CrPa'; Spell[UnCu]:='UnCu'; Spell[ReDo]:='';     Spell[LtId]:='LtId'; Spell[BgId]:='BgId'; Spell[Comp]:='Comp';
  Spell[ReFe]:='ReFe'; Spell[DetS]:='DetS';

   { Define the fill text for each spell }

  Long_Spell[CrLt]:='Cure Light Wounds';
  Long_Spell[CsLt]:='Cause Light Wounds';
  Long_Spell[Lght]:='Light';
  Long_Spell[Prot]:='Protection';
  Long_Spell[Dspl]:='Dispel';
  Long_Spell[CrPs]:='Cure Poison';
  Long_Spell[AnDe]:='Animate Dead';
  Long_Spell[CrSe]:='Cure Serious Wounds';
  Long_Spell[CsSe]:='Cause Serious Wounds';
  Long_Spell[CoLi]:='Continual Light';
  Long_Spell[CrVs]:='Cure Very Serious Wounds';
  Long_Spell[CsVs]:='Cause Very Serious Wounds';
  Long_Spell[Wrth]:='Wrath';
  Long_Spell[CrCr]:='Cure Critical Wounds';
  Long_Spell[CsCr]:='Cause Critical Wounds';
  Long_Spell[Raze]:='Raise Dead';
  Long_Spell[Slay]:='Slay Living';
  Long_Spell[GrWr]:='Great Wrath';
  Long_Spell[Heal]:='Heal';
  Long_Spell[Harm]:='Harm';
  Long_Spell[DiPr]:='Divine Protection';
  Long_Spell[HoWr]:='Holy Wrath';
  Long_Spell[Ress]:='Resurrection';
  Long_Spell[Dest]:='Destruction';
  Long_Spell[WoRe]:='Word of Recall';
  Long_Spell[PaHe]:='Party Heal';
  Long_Spell[DiWr]:='Divine Wrath';
  Long_Spell[RaDe]:='Random Death';
  Long_Spell[DiDe]:='Directed Death';
  Long_Spell[Deus]:='Deus Ex Machina';
  Long_Spell[MaMs]:='Magic Missile';
  Long_Spell[Shld]:='Shield';
  Long_Spell[Loct]:='Location';
  Long_Spell[Fear]:='Fear';
  Long_Spell[ChTr]:='Check Traps';
  Long_Spell[FiBl]:='Fireball';
  Long_Spell[LiBt]:='Lightning Bolt';
  Long_Spell[BiSh]:='Big Shield';
  Long_Spell[GrSh]:='Great Shield';
  Long_Spell[DuBl]:='Dungeon Blink';
  Long_Spell[CoCd]:='Cone of Cold';
  Long_Spell[Tele]:='Teleport';
  Long_Spell[Bani]:='Banish';
  Long_Spell[DeSp]:='Death Spell';
  Long_Spell[HgSh]:='Huge Shield';
  Long_Spell[Besk]:='Berserk';
  Long_Spell[Slep]:='Sleep';
  Long_Spell[MgFi]:='Mega-Fireball';
  Long_Spell[Rein]:='Reincarnate';
  Long_Spell[Kill]:='Kill';
  Long_Spell[Holo]:='Holocaust';
  Long_Spell[Sile]:='Silence';
  Long_Spell[TiSt]:='Time Stop';
  Long_Spell[Levi]:='Levitate';
  Long_Spell[CrPa]:='Cure Paralysis';
  Long_Spell[UnCu]:='Uncurse Object';
  Long_Spell[ReDo]:='';
  Long_Spell[LtId]:='Little Identification';
  Long_Spell[BgId]:='Big Identification';
  Long_Spell[Comp]:='Compass';
  Long_Spell[ReFe]:='Remove Fear';
  Long_Spell[DetS]:='Detect Special';

{ Define what spells can be casted where }

  Party_Spell        :=[DiPr,WoRe,PaHe,BiSh,GrSh,DuBl,Tele,HgSh];
  Person_Spell       :=[AnDe,CrLt,CrPs,CrPa,CrVs,CrSe,CrCr,Raze,Heal,Ress,ReFe];
  Caster_Spell       :=[Prot,Shld,Besk];
  All_Monsters_Spell :=[HoWr,DiWr,DeSp,Holo];
  Group_Spell        :=[Sleep,CsLt,Dspl,CsSe,CsVs,Wrth,CsCr,Slay,GrWr,Harm,Dest,MaMs,Fear,FiBl,LiBt,CoCd,Bani,MgFi,Kill,DiDe,LtId,
                        BgId,Sile];
  Area_Spell         :=[Comp,Lght,Levi,ColI,Deu,RaDe,TiSt,DetS];

{ Define what classes get what spell at what spell level: format is
     Spell_Class_Type [Spell_Level]:=[Set of all spells of this level }

  WizSpells[1]:=[MaMs..Loct,Lght];     WizSpells[2]:=[Fear..ChTr,CoLi,Levi];   WizSpells[3]:=[FiBl..BiSh]+[Comp];
  WizSpells[4]:=[GrSh..DuBl,ChTr];     WizSpells[5]:=[CoCd..Bani];             WizSpells[6]:=[DeSp..Besk,Rein];
  WizSpells[7]:=[Slep..MgFi]+[AnDe];   WizSpells[8]:=[Raze,Slay]+[UnCu];       WizSpells[9]:=[Kill,Holo,Heal,Harm,TiSt];

  ClerSpells[1]:=[CrLt..Prot,ReFe]-[Levi];
  ClerSpells[2]:=[Dspl,CrPs]+[CoLi];
  ClerSpells[3]:=[CrSe..CoLi,Loct]-[CoLi]+[ChTr];
  ClerSpells[4]:=[CrVs..Wrth,Fear]+[CrPa];                                  ClerSpells[7]:=[Ress..PaHe,Bani];
  ClerSpells[8]:=[DiWr..RaDe];                                              ClerSpells[9]:=[DiDe..Deus];

              { The names of the chest traps }

  TrapName[Trapless]:='Trapless Chest';     TrapName[PoisonNeedle]:='Poisoned Need';    TrapName[Alarm]:='Alarm';
  TrapName[Teleporter]:='Teleporter';       TrapName[CrossbowBolt]:='Crossbow bolt';    TrapName[Blades]:='Blades';
  TrapName[SnoozeAlarm]:='Snooze Alarm';    TrapName[GasCloud]:='Gas Cloud';            TrapName[Acid]:='Acid';
  TrapName[Paralyzer]:='Paralyzer';         TrapName[BoobyTrap]:='Booby-Trap';          TrapName[Sleeper]:='Sleeper';
  TrapName[AntiWizard]:='Anti-Wizard';      TrapName[AntiCleric]:='Anti-Cleric';        TrapName[Darts]:='Darts';
  TrapName[ExplodingBox]:='Exploding box';  TrapName[Splinters]:='Splinters';           TrapName[Stunner]:='Stunner';

              { Types of items that can be found }

  Item_Name[Weapon]:='Weapon';              Item_Name[Armor]:='Armor';           Item_Name[Gloves]:='Gloves';
  Item_Name[Shield]:='Shield';              Item_Name[Helmet]:='Helmet';         Item_Name[Scroll]:='Scroll';
  Item_Name[Misc]:='Misc';                  Item_Name[Ring]:='Ring';             Item_Name[Boots]:='Boots';
  Item_Name[Amulet]:='Amulet';              Item_Name[Cloak]:='Cloak';

                       { Alignments }

  AlignName[NoAlign]:='None';   AlignName[Good]:='Good';        AlignName[Neutral]:='Neutral';   AlignName[Evil]:='Evil';


                   { Character Classes }

  ClassName[NoClass]:='';       ClassName[Cleric]:='Cleric';    ClassName[Fighter]:='Fighter';   ClassName[Paladin]:='Paladin';
  ClassName[Ranger]:='Ranger';  ClassName[Wizard]:='Wizard';    ClassName[Thief]:='Thief';       ClassName[Assassin]:='Assassin';
  ClassName[Monk]:='Monk';      ClassName[Ninja]:='Ninja';      ClassName[Bard]:='Bard';         ClassName[Samurai]:='Samurai';
  ClassName[Barbarian]:='Barbarian';                            ClassName[AntiPaladin]:='AntiPaladin';

                   { Character Sexes }

  SexName[NoSex]:=''; SexName[Male]:='Male';  SexName[Female]:='Female';      SexName[Androgynous]:='Androgynous';

                { Character Status Types }

  StatusName[NoStatus]    :='';       StatusName[Healthy]      :='Healthy'; StatusName[Dead]          :='Dead';
  StatusName[Deleted]     :='Lost';   StatusName[Afraid]       :='Afraid';  StatusName[Paralyzed]     :='Paralyzed';
  StatusName[Ashes]       :='Ashes';  StatusName[Asleep]       :='Asleep';  StatusName[Petrified]     :='Petrified';
  StatusName[Insane]      :='Insane'; StatusName[Zombie]       :='Zombie';  StatusName[Poisoned]      :='Poisoned';

               { Character Races }

  RaceName[NoRace]:='';
  RaceName[Human]:='Human';           RaceName[HfOrc]:='Half-Orc';
  RaceName[Dwarven]:='Dwarf';         RaceName[Elven]:='High Elf';
  RaceName[HfOgre]:='Half-Ogre';      RaceName[Gnome]:='Gnome';
  RaceName[Hobbit]:='Hobbit';         RaceName[HfElf]:='Half-Elf';
  RaceName[LizardMan]:='Lizard Man';  RaceName[Centaur]:='Centaur';
  RaceName[Quickling]:='Quickling';   RaceName[Drow]:='Drow';
  RaceName[Numenorean]:='Númenórean';

               { Character Abilities }

  AbilName[1]:='Strength;         AbilName[2]:='Intelligence';        AbilName[3]:='Wisdom';       AlbilName[4]:='Dexterity';
  AbilName[5]:='Contitution';     AbilName[6]:='Charisma';            AbilName[7]:='Luck';

{*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~External DEClarations~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*}
[Asynchronous,External]Function Oh_No (Var SA: Array [$u1..$u2:Integer] of Integer;  Var MA: Array [$u3..$u4:Integer] of [Unsafe]Integer;
[External]Procedure No_Controly;External;
[External]Procedure Controly;External;
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;

[Global]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;

[Asynchronous,External]Function MTH$RANDOM (%Ref Seed: Unsigned): Real;external;

{ This function will return a random number from one to DIE_TYPE. }

begin { Roll_Die }
   Roll_Die:=Trunc(MTH$RANDOM(Seed)*Die_Type)+1  { Get a random number }
end;  { Roll_Die }

{**********************************************************************************************************************}

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

{**********************************************************************************************************************}

[Asynchronous]Procedure Print_Pasteboard (Pasteboard: Unsigned);

[Asynchronous,External]Procedure Printing_Message;External;

begin { Print Pasteboard }
   SMG$PRINT_PASTEBOARD (Pasteboard,Print_Queue);
   Printing_Message;
End;  { Print Pasteboard }

{**********************************************************************************************************************}
Procedure Player_Utilities (Var Pasteboard: Unsigned);Forward;
{**********************************************************************************************************************}

Procedure Special_Keys (Key_Code: Unsigned_Word);

[External]Procedure Help;external;
[External]Procedure Shell_Out;External;

Begin { Special Keys }
   If (Key_Code=SMG$K_TRM_CTRLU) and Not (Main_Menu or In_Utilities) then PlayerUtilities(Pasteboard);
   If (Key_Code=SMG$K_TRM_HELP)  then Help;
   If (Key_Code=SMG$K_TRM_DO)    then Shell_Out;
End;  { Special Keys }

{**********************************************************************************************************************}

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
  If Time_Out=-1 then SMG$Read_Keystroke(Keyboard, Temp); { If there's no time delay }
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

{**********************************************************************************************************************}

[Global]Function Get_Response (Time_Out: Integer:=-1;  Time_Out_Char: Char:=' '):[Volatile]Char;

{ This procedure will read in a letter from 'A' to 'Z' and return it as the function value.  Note:  All lower case letters are
  converted to uppercase, so if lower case letters are needed, another function must be used.  HELPs are removed since they serve
  one purpose throughout the program. }

Var
   Num: Integer;

Begin { Get Response }
   Repeat { Keep reading keys ... }
      Begin { Key loop }
         Num:=Get_Key (Time_Out,Org(Time_Out_Char));  { Get a key }
         If (CHR(Num) in ['a'..'z'] then Num:=Num-32; { Convert to U/C }
      End;  { Key loop }
   Until (Num<>SMG$K_TRM_HELP) and (Num<>SMG$K_TRM_DO);
   Get_Response:=CHR(Num);
End;  { Get Response }

{**********************************************************************************************************************}

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

{**********************************************************************************************************************}

[Global]Function Yes_or_No (Time_OPut: Integer:=-1;  Time_Out_Char: Char:=' '): [Volatile]Char;

{ This function will return a keystroke, 'Y' or 'N' }

Begin { Yes or No }
   Yes_Or_No:=Make_Choice (['Y','N']),Time_Out,Time_Out_Char);
End;  { Yes or No }

{**********************************************************************************************************************}

[Global]Procedure Zero_Through_Six (Var Number: Integer;  Time_Out: Integer:=-1;  Time_Out_Char: Char:='0');

{ This procedure will read in an Integer from zero to six.  A <CR> will be treated as a '0'. }

Var
   Answer: Char;

Begin { Zero Through Six }
   Answer:=Make_Choice(['0'..'6',CHR(13),CHR(32)],Time_Out,Time_Out_Char);
   If Answer in [CHR(13),CHR(32)] then Answer:='0';                          { Convert <CR> to '0' }
   Number:=Order(Answer)-48  { Convert CHAR to INT and return }
End.  { Zero Through Six }

{**********************************************************************************************************************}

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

{**********************************************************************************************************************}

[Global]Procedure Wait_Key (Time_Out: Integer:=-1);

{ This procedure simply waits for a key to be typed before it exits}

Begin { Wait Key }
  Get_Response (Time_Out);
End;

{**********************************************************************************************************************}

[Global]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);

Begin { Ring Bell }
  If Bells_On then SMG$Ring_Bell (Display_ID,Number_of_Times);
End;  { Ring Bell }

{**********************************************************************************************************************}

[Global]Procedure Cursor;

{ This procedure will turn the cursor on, and set CURSOR_MODE, the cursor's flag, to be true }

Begin { Cursor }
  Cursor_Mode:=True; { Set the cursor flag }
  SMG$Set_Cursor_Mode(Pasteboard, 0) { Turn on the cursor }
End;  { Cursor }

{**********************************************************************************************************************}

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
      Response:='0';
   Else
      For Position:=1 to Response.Length do
          If Not(Response.Body[Position] in ['0'..'9','+','-]]) then
             Response.Body[Position]:='0';

   ReadV (Response.Number,Error:=Continue);
End;  { Get Num }

{**********************************************************************************************************************}

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

  $getjpi(pidadr:=%ref pid,itmlst:=%rref item_list);

  { Return current username in Buffer[0] }

  User_Name:=Buffer[0];
End;  { User Name }

{**********************************************************************************************************************}

Procedure Delete_All_Displays;

{ This procedure deletes all (?) of the virtual displays created by the game }

Begin { Delete All Displays }
   SMG$Delete_Virtual_Display(ScreenDisplay);

   SMG$Delete_Virtual_Display(HelpDisplay);
   SMG$Delete_Virtual_Display(ShellDisplay);
   SMG$Delete_Virtual_Display(CharacterDisplay);
   SMG$Delete_Virtual_Display(MonsterDisplay);
   SMG$Delete_Virtual_Display(CommandDisplay);
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

{**********************************************************************************************************************}

Procedure Delete_Virtual_Devices;

{ This procedure deletes all of the virtual devices created by SMG$ }

Begin { Delete Virtual Devices }
   SMG$Disable_Broadcast_Trapping (Pasteboard); { Stop trapping }
   Cursor;  { Restore the cursor to the on position }

   SMG$Delete_Virtual_Keyboard (Keyboard);  { Delete the keyboard }
   Delete_All_Displays;  { Delete the displays created in Stonequest }

   SMG$Delete_Pasteboard (Pasteboard, 1); { Delete the pasteboard }
End;  { Delete Virtual Devices }

{**********************************************************************************************************************}

Procedure Extend_LogFile (Out_Message: Line);

{ This procedure writes the supplied line to the logfile }

Begin { Extend LogFile }
   Repeat
      Open (LogFile,'Stone_Data:Stone_Log.Dat',History:=Unknown,Sharing:=READONLY,Error:=CONTINUE);
   Until (Status(LogFile)<>PAS$K_FILALROPE);
   Extend (LogFile,Error:=Continue);
   Write  (LogFile,Out_Message,Error:=Continue);
   Close  (LogFile,Error:=Continue);
End;  { Extend LogFile }

{**********************************************************************************************************************}

[Global]Procedure Read_Error_Window (FileType: Line; Code: Integer:=0);

{ This procedure prints an error message and then exits Stonequest. }

Var
  BroadcastDisplay:  Unsigned;  { Virtual keyboard and Broadcast }
  Msg: Line;

{ THIS CODE IS MISSING IN THE PRINT OUT. IT WILL NEED TO BE RECREATED. -- JHG 2023-09-15 }

Begin
{ THIS CODE IS MISSING IN THE PRINT OUT. IT WILL NEED TO BE RECREATED. -- JHG 2023-09-15 }
End;

{**********************************************************************************************************************}

{[Global]?}Procedure Message_Trap ();

{ THIS CODE IS MISSING IN THE PRINT OUT. IT WILL NEED TO BE RECREATED. -- JHG 2023-09-15 }

Begin { Message Trap }
   Msg:='* * * Error reading '+FileType+' file!';
   If Code<>0 then msg:=msg+'  Error #'String(code);
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
   Exit;  { Leve the game. (sorry! ) }
End;  { Message Trap }

{**********************************************************************************************************************}

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

{**********************************************************************************************************************}

[Global]Procedure Change_Score (Var Character: Character_Type; Score_Num, Inc: Integer);

{ This procedure changes an ability score of a character }

Begin { Change Score }
   If ((Character.Abilities[Score_Num]>3)  and (Inc<0)) or
      ((Character.Abilities[Score_Num]<25) and (Inc>0)) then
      Character.Abilities[Score_Num]:=Character.Abilities[Score_Num]+Inc;
End;  { Change Score }

{**********************************************************************************************************************}

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
        3. Begin { Reduce a character's age 2-20 years }
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
                      Caracter.Class:=Succ(Character.Class);
               If Character.Class=Character.PreviousClass then
                   If Character.Class=Barbarian then
                      Character.Class:=Cleric
                   Else
                      Caracter.Class:=Succ(Character.Class);

            End;
        19: Begin
               Character.Alignment:=Evil;
               Character.Abilities[1]:=Max(Character.Abilities[1], 17);
            End;
        Otherwise ;
   End;
End;  { Special Occurance }

{**********************************************************************************************************************}

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

{**********************************************************************************************************************}

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

{**********************************************************************************************************************}

Procedure Log_Player_In;

{ This procedure records the time and date the user logged into the logfile. }

Begin { Log Player In }
   If Logging and (User_Name<>'JGETZIN') then Extend_LogFile (Time_And_Date_And_name+'IN');
End;  { Log Player In }

{**********************************************************************************************************************}

Procedure Log_Player_Out;

{ See above? }

Begin { Log Player Out }
   If Logging and (User_Name<>'JGETZIN') then Extend_LogFile (Time_And_Date_And_name+'OUT');
End;  { Log Player Out }

{**********************************************************************************************************************}
[Global]Procedure Write_Roster;Forward;
{**********************************************************************************************************************}

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

{**********************************************************************************************************************}

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
      Create_Roster_file;
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
               If (Status(Char_File)<>PAS$K_EOF) then Read_Error_Window ('Character',STATUS(Char_File));
               Close (Char_File);
             End;  { Read the characters and then close the file }
      End;  { File is there }
End;  { Read Roster }

{**********************************************************************************************************************}

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

         If Status(MazeFile)<>PAS$K_SUCCESS then Read_Error_Window ('maze',Status(MazeFile));
         Reset (MazeFile);

         { If the level is defined load it, otherwise return the current level }

         If Not(Eof(MazeFile)) then
            Read (MazeFile,Temp);
         Else
            Temp:=Maze;

         { Close the file and return the level }

         Close (MazeFile);
         Get_Level:=Temp;
      End;
   Else
      Get_Level:=Maze;  { Otherwise, return the current level }
End;  { Get Level }


{ $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ }

[Global]Procedure Save_Messages (Messages: Message_Group);

{ This procedure saves the messages to the disk }

Var
   Loop: Integer;

Begin { Save Messages }
   Repeat
      Open (Message_File,'Stone_Data:Messages.dat;1',History:=OLD,Error:=CONTINUE,Sharing:=READONLY)
   Until (Status(Message_File))=PAS$K_SUCCESS);
   Rewrite (Message_File);
   For Loop:=1 to 999 do  Writeln (Message_File,Messages[Loop]);
   Close (Message_File);
End;  { Save Messages }

{**********************************************************************************************************************}

Procedure Quit;

{ This procedure disables trapping of broadcast messages, returns the cursor to normal, and saves the data used in the game. }

Var
   l: Line;
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
   If (User_Name='JGETZIN') and DataModified then { Only I can save! Hahaha! }
      Begin
         Save_Items;                               Add_Dot (X);
         Save_Pictures;                            Add_Dot (X);
         Save_Treasure;                            Add_Dot (X);
      End;
   Delete_Virtual_Devices;

   if Not Authorized then $SETPRI (Pri:=Start_Priority);
   ControlY;
End;  { Quit }

{**********************************************************************************************************************}

[Global]Procedure Kill_Save_File;

{ This procedure will delete the save file }

Begin { Kill Save File }
   LIB$DELETE_FILE ('SYS$LOGIN:STONE_SAVE.DAT;*');
End;  { Kill Save File }


{**********************************************************************************************************************}


[Global]Function Can_Play: [Volatile]Boolean;

{ Can the user play at this particular time? }

[External]Function Legal_Time: [Volatile]Boolean;External;

Begin { Can Play }
   Can_Play:=False;
   Can_Play:=Authorized;
   If Not Authorized then Can_Play:=Legal_Time;
End;  { Can Play }

{**********************************************************************************************************************}
[External]Procedure Demo;External;
{**********************************************************************************************************************}


{ This program is the main driving procedure for STONEQUEST.  It reads the data at the start of the game, and saves it when
  exiting for fast action. }

Begin { Stonequest }
  ShowHours:=False;  Main_Menu"=True;  In_Utilities:=False;
  Authorized:=(User_Name='JGETZIN') or (User_Name='DCORN');
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
               End;  { Legal hours }
            Else
               Begin { Not legal hours }
                  Answer:='Q';
                  ShowHours:=True;
               End;  { Not legal hours }
         Until Answer='Q';                                      { Quit if it's a "Q" }
         Quit;                                                  { Update files }
         If Not Game_Saved then Kill_Save_File;
     End;
  Else
     ShowHours:=True;

  If Not Authorized and Trap_Authorized_Error then Revert;                              { Turn off MORIA's error handler }
  If ShowHours then LIB$DO_COMMAND ('TYPE STONE_DATA:HOURS.DAT');
End.  { StoneQuest }


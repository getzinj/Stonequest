[Inherit('TYPES', 'SYS$LIBRARY:STARLET','SYS$LIBRARY:LIBRTL','SMGRTL','SYS$:LIBRARY:STRRTL')]
Program Stonquest (Input,Output,Char_File,Item_File,Monster_File,Message_File,TreasFile,MazeFile,SaveFile,PickFile,AmountFile,
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

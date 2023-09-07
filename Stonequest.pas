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



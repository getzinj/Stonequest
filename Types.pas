[Environment]Module Types;
Const

(* These values are returned by the predefined STATUS function. *)

    PAS$K_EOF        =  -1;      (* file is at end-of-file *)
    PAS$K_SUCCESS    =   0;      (* last operation successful *)

    PAS$K_FILALROPE  =   1;      (* file is already open *)
    PAS$K_ERRDUROPE  =   2;      (* error during OPEN *)
    PAS$K_FILNOTFOU  =   3;      (* file not found *)
    PAS$K_INVFILSYN  =   4;      (* invalid filename syntax *)
    PAS$K_ACCMETINC  =   5;      (* ACCESS_METHOD specified is incompatible with this file *)
    PAS$K_RECLENINC  =   6;      (* RECORD_LENGTH specified is inconsistent with this file *)
    PAS$K_RECTYPINC  =   7;      (* RECORD_TYPE specified is inconsistent with this file *)
    PAS$K_ORGSPEINC  =   8;      (* ORGANIZATION specified is inconsistent with this file *)
    PAS$K_INVKEYDEF  =   9;      (* invalid key definition *)
    PAS$K_KEYDEFINC  =  10;      (* KEY(<n>) definition is inconsistent with this file. *)
    PAS$K_KEYNOTDEF  =  11;      (* KEY(<n>) definition is not defined in this file. *)
    PAS$K_INVRECLEN  =  12;      (* invalid record length of <n> *)
    PAS$K_TEXREGSEG  =  13;      (* textfiles require sequential organization and access *)
    PAS$K_FILNAMREG  =  14;      (* FILE_NAME required for this HISTORY or DISPOSITION *)
    PAS$K_FILALRCLO  =  15;      (* file is already closed *)
    PAS$K_ERRDURCLO  =  16;      (* error during CLOSE *)
    PAS$K_AMBVALENU  =  30;      (* "<string>" is an ambiguous value for enumerated type "<type>" *)
    PAS$K_INVSYNENU  =  31;      (* "<string>" is invalid syntax for an enumerated value *)
    PAS$K_INVSYNINT  =  32;      (* "<string>" is invalid syntax for an integer value *)
    PAS$K_INVSYNREA  =  33;      (* "<string>" is invalid syntax for a real value *)
    PAS$K_INVSYNUNS  =  34;      (* "<string>" is invalid syntax for an unsigned value *)
    PAS$K_NOTVALTYP  =  35;      (* "<string>" is not a value of type "<type>" *)
    PAS$K_ERRDURPRO  =  36;      (* error during prompting *)
    PAS$K_INVSYNBIN  =  37;      (* "<string>" is invalid syntax for a binary value *)
    PAS$K_INVSYNHEX  =  38;      (* "<string>" is invalid syntax for a hexadecimal value *)
    PAS$K_INVSYNOCT  =  39;      (* "<string>" is invalid syntax for an octal value *)
    PAS$K_ERRDURWRI  =  50;      (* error during WRITELN *)
    PAS$K_INVFIESPE  =  51;      (* invalid field specification for WRITE *)
    PAS$K_LINTOOLON  =  52;      (* line is too long, exceeded record length by <n> character(s) *)
    PAS$K_NEGWIDDIG  =  53;      (* negative Width or Digits specification is not allowed *)
    PAS$K_WRIINVENU  =  54;      (* WRITE of an invalid enumerated value *)
    PAS$K_KEYVALINC  =  70;      (* key value is incompatible with this file's key <n> *)
    PAS$K_KEYDUPNOT  =  71;      (* key field duplication is not allowed *)
    PAS$K_KEYCHANOT  =  72;      (* key field change is not allowed *)
    PAS$K_CURCOMUND  =  73;      (* current component is undefined for DELETE or UPDATE *)
    PAS$K_FAIGETLOC  =  74;      (* failed to GET locked component *)
    PAS$K_DELNOTALL  = 100;      (* DELETE is not allowed for a sequential organization file *)
    PAS$K_ERRDURDEL  = 101;      (* error during DELETE *)
    PAS$K_ERRDURFIN  = 102;      (* error during FIND or FINDK *)
    PAS$K_ERRDURGET  = 103;      (* error during GET *)
    PAS$K_ERRDURPUT  = 104;      (* error during PUT *)
    PAS$K_ERRDURRES  = 105;      (* error during RESET or RESETK *)
    PAS$K_ERRDURREW  = 106;      (* error during REWRITE *)
    PAS$K_ERRDURTRU  = 107;      (* error during TRUNCATE *)
    PAS$K_ERRDURUNL  = 108;      (* error during UNLOCK *)
    PAS$K_ERRDURUPD  = 109;      (* error during UPDATE *)
    PAS$K_FILNOTDIR  = 110;      (* file is not opened for direct access *)
    PAS$K_FILNOTGEN  = 111;      (* file is not in Generation mode *)
    PAS$K_FILNOTINS  = 112;      (* file is not Inspection mode *)
    PAS$K_FILNOTKEY  = 113;      (* file is not opened for keyed access *)
    PAS$K_FILNOTOPE  = 114;      (* file is not open *)
    PAS$K_FILNOTSEQ  = 115;      (* file is not in sequential organization *)

    PAS$K_FILNOTTEX  = 116;      (* failed to GET locked component *)
    PAS$K_GENNOTALL  = 117;      (* failed to GET locked component *)
    PAS$K_GETAFTEOF  = 118;      (* failed to GET locked component *)
    PAS$K_INSNOTALL  = 119;      (* failed to GET locked component *)
    PAS$K_INSVIRMEM  = 120;      (* failed to GET locked component *)
    PAS$K_INVARGPAS  = 121;      (* failed to GET locked component *)
    PAS$K_LINVALEXC  = 122;      (* failed to GET locked component *)
    PAS$K_REWNOTALL  = 123;      (* failed to GET locked component *)
    PAS$K_RESNOTALL  = 124;      (* failed to GET locked component *)
    PAS$K_TRUNOTALL  = 125;      (* failed to GET locked component *)
    PAS$K_UPDNOTALL  = 126;      (* failed to GET locked component *)
    PAS$K_ERRDUREXT  = 127;      (* failed to GET locked component *)
    PAS$K_EXTNOTALL  = 128;      (* failed to GET locked component *)

Type

   { Possible coordinates in the Maze }

   Vertical_Type   = [Byte]0..19;
   Horizontal_Type = [Byte]0..20;

   { Possible directions to be facing in the maze }

   Direction_Type = (North, East, South, West);

   { Possible treasure types }

   T_Type         = 1..150;

   Four_Letters   = Varying [4] of char;  { guess }
   Char_Set       = Set of Char;  { Set of characters }

   Ordinate       = 0..28;
   Coordinate     = Record
                        X, Y:  [Byte]Ordinate;
                    End;
   Die_Type       = Record
                        X, Y, Z: Integer;  { format: xDy+z }
                    End;

   { Possible age brackets a character can be in }

   Age_Type       = (YoungAdult,Mature,MiddleAged,Old,Venerable,Croak);

   { Properties a monster can have }

   Property_Type  = (Stones,Poisons,Paralyzes,Autokills,CanBeSlept,CanRun,Gates,CantBefriend,CanbeSurprised,TeleportsAway,NoTurn,
                     CantEscape,Cause_Fear);

  { Classification of monsters }

  Monster_Type   = (Warrior,Mage,Priest,Pilferer,Karateka,Midget,Giant,Myth,Animal,Lycanthrope,Undead,Demon,Insect,Plant,
                    MultiPlanar,Dragon,Statue,Reptile,Enchanted);

  { The different attack types in Stonequest.  Note: Some are not used.
    In general, CHARMING is used as a null attack when one is needed.   }

  Attack_Type    = (Fire,Frost,Posion,LvlDrain,Stoning,Magic,Death,CauseFear,Electricity,Charming,Insanity,Aging,Sleep);

  { Classification of items }

  Item_Type      = (Weapon,Armor,Shield,Helmet,Gloves,Scroll,Misc,Ring,Boots,Amulet,Cloak);

  Name_Type      = Varying[20] of Char;

  { The spells in Stonequest }

  Spell_Name     =(NoSp,CrLt,CsLt,Lght,Levi,Prot,Dspl,CrPs,AnDe,
                   CrSe,CsSe,CoLi,TiSt,CrVs,CsVs,Sile,Wrth,CrCr,
                   CsCr,Raze,Slay,GrWr,Heal,ReDo,Harm,DiPr,HoWr,
                   Ress,Dest,WoRe,PaHe,DiWr,RaDe,DiDe,Deus,MaMs,
                   Shld,Loct,Fear,LtId,ChTr,FiBl,LiBt,BiSh,GrSh,
                   DuBl,UnCu,Comp,CoCd,Tele,Bani,CrPa,DeSp,BgId,
                   HgSh,Besk,Slep,MgFi,Rein,Kill,Holo,ReFe,DetS);

  { Classes a character can be }

  Class_Type     = (NoClass,Cleric,Fighter,Paladin,Ranger,Wizard,Thief,Assassin,Monk,AntiPaladin,Bard,Samurai,Ninja,Barbarian);

  Class_Set      = Set of Class_Type;

  { Alignments a character can be }

  Align_Type     = (NoAlign,Good,Neutral,Evil);

  { The traps a chest can have }

  Trap_Type      = (Trapless,PoisonNeedle,Alarm,Teleporter,Darts,Blades,SnoozeAlarm,GasCloud,Acid,Paralyzer,BoobyTrap,Sleeper,
                    AntiWizard,AntiCleric,CrossbowBolt,ExplodingBox,Splinters,Stunner);

  { The races a character can be }

  Race_Type      = (NoRace,Human,HfOrc,Dwarven,Elven,HfOgre,Gnome,Hobbit,HfElf,LizardMan,Centaur,Quickling,Drow,Numenorean);

  { The sexes a character can be }

  Sex_Type       = (NoSex,Male,Female,Androgynous);

  { The conditions a character can be in }

  Status_Type    = (NoStatus,Healthy,Dead,Deleted,Afraid,Paralyzed,Petrified,Ashes,Asleep,Insane,Zombie,Poisoned,OnProbation);

  { The places the party can be in Kyrn }

  Place_Type     = (Church,Tavern,Inn,TheMaze,TrainingGrounds,InKyrn,Leave,TradingPost,Casino,MainStreet);

  Ability_Score  = [Byte]0..25;

  { A set of integers from 0 to 250 }

  Int_Set        = Packed Array [0..999] of Boolean;

  Item_Record    = Record { Item Record }
                      Item_Number: [Byte]0..250;        { Its # }
                      Name: Name_Type;                  { Unidentified name }
                      True_Name: Name_Type;             { Identified name }
                      Alignment: Align_Type;            { It's alignment if any }
                      Kind: Item_Type;                  { What classification is it in? }
                      Cursed: boolean;                  { Is it a cursed item? }
                      Special_Occurance_No: Integer;    { Have a purpose? }
                      Percentage_Breaks: [Byte]0..100;  { Can it break? }
                             Turns_Into: [Byte]0..250;  { to what result? }
                      GP_Value: Integer;                { how much is it worth? }
                      Current_Value: Integer;           { ...currently? }
                      Spell_Cast: Spell_Name;           { Does it cast a spell? }
                      Usable_By: Class_Set;             { Who can use it? }
                      Regenerates: [Word]-16383..16383; { How much does it heal? }

                      { What monsters or attack-types does it protect
                        against? }

                      Protects_Against: Set of Monster_Type;
                      Resists: Set of Attack_Type;

                       { What equiped, what properties does it have? }

                      Versus: Set of Monster_Type;      { What does it hate? }
                      Damage: Die_Type;                 { How much damage does it do? }
                      Additional_Attacks: Integer;      { Any additional attacks? }
                      Plus_to_hit: [Byte]-127..127;     { What plus to hit? }
                      AC_Plus: [Byte]-20..20;           { What adjustment to AC? }
                      Auto_Kill: Boolean;               { Does it critical hit? }
                   End;

  { A record for each item carried by a character }

  Item_Number_Type = [Byte]0..250;

  Old_Equipment_Type = record
                      Item: Item_Record;                        { The item itself }
                      Ident,Equipted,Usable,Cursed: Boolean;    { Identified? Equipted? Usable? Cursed? }
                   End;

  Equipment_Type = record
                      Item_Num: Item_Number_Type;                        { The item itself }
                      Ident,Equipted,Usable,Cursed: Boolean;    { Identified? Equipted? Usable? Cursed? }
                   End;

  { The information concerning a character }

  Old_Equipments = Array [1..8] of Old_Equipment_Type;
  Equipments = Array [1..8] of Equipment_Type;

  Old_Character_Type = Record
                      Name:            Name_Type;                { The name }
                      Username:        Varying [6] of char;      { Username 6 chars }
                      Lock:            Boolean;                  { Is the character in use? }
                      Race:            Race_Type;                { Human, elven, et al }
                      Sex:             Sex_Type;                 { The sex }
                      Age:             Integer;                  { Age in days }
                      Age_Status:      Age_Type;                 { Young, mature, et al }
                      Class,PreviousClass:  Class_Type;          { The class }
                      Level,Previous_Lvl:   [Word]-32767..32767; { The level }
                      Alignment:       Align_Type;               { Good, evil, neutral }
                      Experience:      Real;                     { Experience points }
                      Curr_HP,MAX_HP:  Integer;                  { Hit points }
                      Armor_Class:     [Byte]-127..127;          { How hard is the character to hit? }
                      Regenerates:     Integer;                  { Healing abilities }
                      Abilities:       Array [1..7] of Ability_Score;
                      Status:          Status_Type;              { Healthy, asleep, etc }
                      Gold:            Integer;                  { Money }
                      No_of_Items:     [Byte]0..8;               { # of items }
                      Item:            Old_Equipments;
                      SpellPoints:     Packed Array [1..2, 1..9] of [Byte]0..9;
                      Wizard_Spells:   Set of Spell_Name;        { spells known }
                      Cleric_Spells:   Set of Spell_Name;
                      Items_Seen:      Int_Set;                  { What items can be identified }
                      Monsters_Seen:   Int_Set;                  {  ""  monsters  ""     ""     }
                      Scenarios_Won:   Int_Set;                  { What scenarios have been won }
                      Attack:          Record
                                          WeaponUsed:  [Byte]0..8;
                                          ArmorWorn:   [Byte]0..8;
                                          Autokill:    Boolean;
                                          Berserk:     Boolean;
                                       End;
                      Magic_Resistance: Integer;                 { What chance does the character have of resisting magic? }
                      Case Psionics: Boolean of
                           True: (DetectTrap:     Integer;
                                  Regenerate:     Integer;
                                  DetectSecret:   Integer);
                  End;

  Character_Type = Record
                      Name:            Name_Type;                { The name }
                      Username:        Varying [6] of char;      { Username 6 chars }
                      Lock:            Boolean;                  { Is the character in use? }
                      Race:            Race_Type;                { Human, elven, et al }
                      Sex:             Sex_Type;                 { The sex }
                      Age:             Integer;                  { Age in days }
                      Age_Status:      Age_Type;                 { Young, mature, et al }
                      Class,PreviousClass:  Class_Type;          { The class }
                      Level,Previous_Lvl:   [Word]-32767..32767; { The level }
                      Alignment:       Align_Type;               { Good, evil, neutral }
                      Experience:      Real;                     { Experience points }
                      Curr_HP,MAX_HP:  Integer;                  { Hit points }
                      Armor_Class:     [Byte]-127..127;          { How hard is the character to hit? }
                      Regenerates:     Integer;                  { Healing abilities }
                      Abilities:       Array [1..7] of Ability_Score;
                      Status:          Status_Type;              { Healthy, asleep, etc }
                      Gold:            Integer;                  { Money }
                      No_of_Items:     [Byte]0..8;               { # of items }
                      Item:            Equipments;
                      SpellPoints:     Packed Array [1..2, 1..9] of [Byte]0..9;
                      Wizard_Spells:   Set of Spell_Name;        { spells known }
                      Cleric_Spells:   Set of Spell_Name;
                      Items_Seen:      Int_Set;                  { What items can be identified }
                      Monsters_Seen:   Int_Set;                  {  ""  monsters  ""     ""     }
                      Scenarios_Won:   Int_Set;                  { What scenarios have been won }
                      Attack:          Record
                                          WeaponUsed:  [Byte]0..8;
                                          ArmorWorn:   [Byte]0..8;
                                          Autokill:    Boolean;
                                          Berserk:     Boolean;
                                       End;
                      Magic_Resistance: Integer;                 { What chance does the character have of resisting magic? }
                      Case Psionics: Boolean of
                           True: (DetectTrap:     Integer;
                                  Regenerate:     Integer;
                                  DetectSecret:   Integer);
                  End;

  { The information concerning a character }

  { Types of treasures }

  Treasure_Kind = (Cash_Given,Item_Given);

  { A record of each particular item in a treasure }

  Treasure_record= Record
                     Case Kind: Treasure_Kind of
                        Cash_given: (Initial_Random: Die_Type;
                                     Initial_Base:   Integer;
                                     Multiplier:     Die_Type);
                        Item_Given: (Item_Number:        Die_Type;
                                     Range:              [Byte]0..250;
                                     Appear_Probability: [Byte]0..100);
                 End;

  { A list of items in the treasure }

  List_of_TreasureType=Array [1..9] of Treasure_record;

  { A treasure... }

  Treasure_Table = Record
                      Treasure_No: [Byte]0..255;
                      In_Chest: Boolean;
                      Possible_Traps: Set of Trap_Type;
                      Max_No_of_Treasures: [Byte]1..9;
                      Treasure: List_of_treasureType;
                  End;

  { a list of possible picture... }

  Pic_Type      = [Byte]0..150;
  Monster_Name_Type = Varying[60] of char;
  Monster_Record    = Record
                          Monster_Number:          [Word]0..65535;
                          Picture_Number:          Pic_Type;
                          Name,Plural:             Monster_Name_Type;
                          Real_Name,Real_Plural:   Monster_Name_Type;
                          Alignment:               Align_Type;
                          Number_Appearing:        Die_Type;
                          Hit_Points:              Die_Type;
                          Kind:                    Monster_Type;
                          Armor_Class:             [Byte]-127..127;
                          Treasure:                Record
                                                      In_Lair: Set of T_Type;
                                                      Wandering: Set of T_Type;
                                                   End;
                          Levels_Drained:          [Word]-32767..32767;
                          Regenerates:             [Word]-32767..32767;
                          Highest:                 Record
                                                       Cleric_Spell: [Byte]0..9;
                                                       Wizard_Spell: [Byte]0..9;
                                                   End;
                          Magic_Resistance:        [Byte]0..200;
                          Gate_Success_Percentage: [Byte]0..100;
                          Monster_Called:          [Word]0..65535;
                          Breath_Weapon:           Attack_Type;
                          Gaze_Weapon:             Attack_Type;
                          Years_Ages:              Integer;
                          Weapon_Plus_Needed:      Integer;
                          No_of_attacks:           [Byte]0..20;
                          Damage:                  Array [1..200] of Die_Type;
                          Extra_Damage:            Set of Class_Type;
                          Resists:                 Set of Attack_Type;
                          Properties:              Set of Property_Type;
                      End;

  Spell_Set         = Set of Spell_Name;
  Line              = Varying [80] of char;

  { Ways surrounding a room }

  Exit_Type        = (Passage,Wall,Door,Secret,Transparent,Walk_Through);

  { Area type for encounter purposes }

  Area_Type       = (Room,Corridor);

  { Basic special kind }

  Special_Kind    = (Nothing,Stairs,Pit,Chute,Rotate,Darkness,Teleport,Damage,Elevator,Rock,Antimagic,SPFeature,An_Encounter,
                     Cliff);

  { Special special types... See the difference? }

  SPKind          = (NothingSpecial,Msg,Msg_Item_Given,Msg_Pool,
                     Msg_Hidden_Item,Msg_Need_Item,Msg_Lower_AC,
                     Msg_Raise_AC,Msg_Goto_Castle,Msg_Encounter,Riddle,
                     Fee,Msg_Trade_Item,Msg_Picture,Unknown);

  { Entry on the special table }

  Special_Type    = Record
                       Pointer1,Pointer2,Pointer3: Integer;
                       Case Special: Special_Kind of
                           SpFeature: (Feature: SpKind)
                    End;

  { Table of specials for each level }

  Special_Table_Type = Array [0..15] of Special_Type;

  { A record for each room }

  Room_Record    = Record
                          North,South,East,West: Exit_Type;
                          Contents: [Byte]0..15; {index of Special_Table}
                          Kind: Area_Type;
                   End;

  { Random encounter }

  Encounter      = Record
                      Base_Monster_Number: [Byte]0..250;
                      Addition: Die_Type;
                      Probability: [byte]0..200;
                   End;

  { Table of encounters for each level }

  Encounter_Table = Array [1..3] of Encounter;
                     { 1 = wandering in corridor }
                     { 2 = wandering in room }
                     { 3 = ???? }

  { Combined level. }

  Level           = Record
                       Level_Number: [Byte]1..255;
                       Room: Array [1..20, 1..20] of Room_Record;
                       Monsters: Encounter_Table;
                       Special_Table: Special_Table_Type;
                    End;

  { Group of messages. }

  Message_group    = Array [1..999] of line;

  { A 27 x 9 text picture. }

  Image_Type        = Packed Array [1..27, 1..9] of Char;

  { Total information for each picture }

  Picture           = Record
                          Image: Image_Type;
                          Left_Eye,Right_Eye: Coordinate;
                          Eye_Type: Char;
                      End;

  Pic_List          = Array [0..150]  of Picture;
  Roster_Type       = Array [1..20]  of Character_Type;
  Party_Type        = Array [1..6]   of Character_Type;
  Character_list    = Array [1..6]   of Character_Type;
  List_of_monsters  = Array [1..450] of Monster_record;
  List_of_items     = Array [0..449] of Item_record;
  List_of_Amounts   = Array [0..449] of Integer;
  List_of_Treasures = Array [1..150] of Treasure_Table;

  Picture_File_Type = Packed File of Picture;
  Number_File       = Packed File of Integer;
  Character_File    = File of Character_Type;
  Equip_File        = File of Item_Record;
  Monst_File        = File of Monster_Record;
  Treas_File        = File of Treasure_Table;
  LevelFile         = File of Level;

  Spell_Duration_List  = Array [Spell_Name] of Unsigned;
  Party_Size_Type = 0..6;
  Save_Record     = Record
                       PosX,PosY:  [Byte]1..20; { Party's location }
                       PosZ:       [Byte]1..19;
                       Direction:  [Byte]Direction_Type;
                       Spells_Casted:  Spell_Duration_List;  { Spells Casted }
                       Party_Size: [Byte]1..6;
                       Current_Size: [Byte]Party_Size_Type;
                       Characters: Character_List;
                       Current_Level:  Level;
                       Time_Delay: Integer;
                    End;
  Save_File_Type    = Packed File of Save_Record;

  $uquadword        = Quadruple;
  Score             = Record
                          Name,User_Name: Name_Type;
                          Lvl1,Lvl2: Integer;
                          Class1,Class2: Class_Type;
                          Experience: $uquadword;
                          Defeated_Barrat: Boolean;
                      End;

        High_Score_List   = Array [1..20] of Score;
        Score_File        = Packed File of High_Score_List;
        Combined_List     = Array [1..40] of Score;

{ Here are the combat data structures }

  Amount_Type       = (None,One,Many);
  Chest_Status_Type = (Opened,Closed);
  Trap_set          = Set of trap_Type;
  Option_Type       = (Run,Gate,Breathe,CastSpell,Attack,UseItem,TurnUndead,
                       Parry,Berserker_Rage,SwitchItems);

  Group_Choice    = [Byte]1..5;
  Group_Type      = 0..4;
  Individual_Type = 0..6;
  Attacker_Type = Record
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
  Party_Commands_Type = Array [1..6] of Attacker_Type;
  PriorityQueue = Record
                     Contents: Array [1..4008] of Attacker_Type;
                     Last:  Integer;
                  End;

  Surprise_Type = (PartySurprised,MonsterSurprised,NoSurprise);
  Reaction_Type = (Friendly,Hostile);

  Flag            = [Bit]Boolean;
  Monster_Group   = Record
                       Monster: Monster_Record;
                       Origin_Group_Size,Curr_Group_Size: [Word]0..999;
                       Max_HP,Curr_HP: Array [1..999] of Integer;
                       Status: Array [1..999] of Status_Type;
                       Silenced: Array [1..999] of Flag;
                       Identified: Flag;
                    End;
  Encounter_Group = Array [1..4] of Monster_Group;
  Party_Flag      = Array [1..6] of Flag;
  Attack_String   = Varying [10] of Char;

  ISpot = Record
    front: Exit_Type;
    left: Exit_Type;
    right: Exit_Type;
    contents: Integer;
    kind: Area_Type;
  End;

Var
   Pas_Errors: [Global]Array [-1..128] of Line;

{
Value
    Pas_Errors[
  PAS$K_EOF        ]:='End of file encountered';
    Pas_Errors[
  PAS$K_SUCCESS    ]:='';
    Pas_Errors[
  PAS$K_SUCCESS    ]:='';
    Pas_Errors[
  PAS$K_FILALROPE  ]:='File is already opened';
    Pas_Errors[
  PAS$K_ERRDUROPE  ]:='Error occured while opening';
    Pas_Errors[
  PAS$K_FILNOTFOU  ]:='File not found';
    Pas_Errors[
  PAS$K_INVFILSYN  ]:='Invalid file syntax';
    Pas_Errors[
  PAS$K_ACCMETINC  ]:='';
    Pas_Errors[
  PAS$K_RECLENINC  ]:='';
    Pas_Errors[
  PAS$K_RECTYPINC  ]:='';
    Pas_Errors[
  PAS$K_ORGSPEINC  ]:='';
    Pas_Errors[
  PAS$K_INVKEYDEF  ]:='';
    Pas_Errors[
  PAS$K_KEYDEFINC  ]:='';
    Pas_Errors[
  PAS$K_KEYNOTDEF  ]:='';
    Pas_Errors[
  PAS$K_INVRECLEN  ]:='Invalid record length';
    Pas_Errors[
  PAS$K_TEXREGSEG  ]:='';
    Pas_Errors[
  PAS$K_FILNAMREG  ]:='';
    Pas_Errors[
  PAS$K_FILALRCLO  ]:='File already closed';
    Pas_Errors[
  PAS$K_ERRDURCLO  ]:='Error during close';
    Pas_Errors[
  PAS$K_AMBVALENU  ]:='';
    Pas_Errors[
  PAS$K_INVSYNENU  ]:='';
    Pas_Errors[
  PAS$K_INVSYNINT  ]:='';
    Pas_Errors[
  PAS$K_INVSYNREA  ]:='';
    Pas_Errors[
  PAS$K_INVSYNUNS  ]:='';
    Pas_Errors[
  PAS$K_NOTVALTYP  ]:='';
    Pas_Errors[
  PAS$K_ERRDURPRO  ]:='';
    Pas_Errors[
  PAS$K_INVSYNBIN  ]:='';
    Pas_Errors[
  PAS$K_INVSYNHEX  ]:='';
    Pas_Errors[
  PAS$K_INVSYNOCT  ]:='';
    Pas_Errors[
  PAS$K_ERRDURWRI  ]:='';
    Pas_Errors[
  PAS$K_INVFIESPE  ]:='';
    Pas_Errors[
  PAS$K_LINTOOLON  ]:='';
    Pas_Errors[
  PAS$K_NEGWIDDIG  ]:='';
    Pas_Errors[
  PAS$K_WRIINVENU  ]:='';
    Pas_Errors[
  PAS$K_KEYVALINC  ]:='';
    Pas_Errors[
  PAS$K_KEYDUPNOT  ]:='';
    Pas_Errors[
  PAS$K_KEYCHANOT  ]:='';
    Pas_Errors[
  PAS$K_CURCOMUND  ]:='';
    Pas_Errors[
  PAS$K_FAIGETLOC  ]:='';
    Pas_Errors[
  PAS$K_DELNOTALL  ]:='';
    Pas_Errors[
  PAS$K_ERRDURDEL  ]:='Error during delete';
    Pas_Errors[
  PAS$K_ERRDURFIN  ]:='Error during find';
    Pas_Errors[
  PAS$K_ERRDURGET  ]:='Error during get';
    Pas_Errors[
  PAS$K_ERRDURPUT  ]:='Error during put';
    Pas_Errors[
  PAS$K_ERRDURRES  ]:='Error during reset';
    Pas_Errors[
  PAS$K_ERRDURREW  ]:='Error during rewrite';
    Pas_Errors[
  PAS$K_ERRDURTRU  ]:='';
    Pas_Errors[
  PAS$K_ERRDURUNL  ]:='Error during unlock';
    Pas_Errors[
  PAS$K_ERRDURUPD  ]:='Error during update';
    Pas_Errors[
  PAS$K_FILNOTDIR  ]:='File not opened for direct access';
    Pas_Errors[
  PAS$K_FILNOTGEN  ]:='File is not in generation mode';
    Pas_Errors[
  PAS$K_FILNOTINS  ]:='';
    Pas_Errors[
  PAS$K_FILNOTKEY  ]:='';
    Pas_Errors[
  PAS$K_FILNOTOPE  ]:='File not open';
    Pas_Errors[
  PAS$K_FILNOTSEQ  ]:='File not sequential';
    Pas_Errors[
  PAS$K_FILNOTTEX  ]:='';
    Pas_Errors[
  PAS$K_GENNOTALL  ]:='';
    Pas_Errors[
  PAS$K_GETAFTEOF  ]:='';
    Pas_Errors[
  PAS$K_INSNOTALL  ]:='';
    Pas_Errors[
  PAS$K_INSVIRMEM  ]:='';
    Pas_Errors[
  PAS$K_INVARGPAS  ]:='';
    Pas_Errors[
  PAS$K_LINVALEXC  ]:='';
    Pas_Errors[
  PAS$K_REWNOTALL  ]:='';
    Pas_Errors[
  PAS$K_RESNOTALL  ]:='';
    Pas_Errors[
  PAS$K_TRUNOTALL  ]:='';
    Pas_Errors[
  PAS$K_UPDNOTALL  ]:='';
    Pas_Errors[
  PAS$K_ERRDUREXT  ]:='Error during extend';
    Pas_Errors[
  PAS$K_EXTNOTALL  ]:='';}
End.

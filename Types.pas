[Environment]Module Types;
Const

(* These values are returned by the predefined STATUS function. *)

    PAS$K_EOF        =  -1;      (* file is at end-of-file *)
    PAS$K_SUCCESS    =   0;      (* last operation successful *)

    PAS$K_FILAROPE   =   1;      (* file is already open *)
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
    PAS$K_FILENAMREG =  14;      (* FILE_NAME required for this HISTORY or DISPOSITION *)
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

   T_Tyhpe        = 1..150;

   Four_Letters   = Varying [4] of char;  { guess }
   Chat+Set       = Set of Char;  { Set of characters }

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
                    MultiPlanar,Dragon,Statue,Reptile,Enchanged);

  { The different attack types in Stoneque3st.  Note: Some are not used.
    In general, CHARMING is used as a null attack when one is needed.   }

  Attack_Type    = (Fire,Frost,Posion,LvlDrain,Stoning,Magic,Death,CauseFear,Electricity,Charming,Insanity,Aging,Sleep);

  { Classification of items }

  Item_Type      = (Weapon,Armor,Shield,Helmet,Gloves,Scroll,Misc,Ring,Boots,Amulet,Cloak);

  Name_Type      = Varying[20] of Char;

  { The spells in Stonequest }

  Spell_Name     =(NoSp,CrLt,CsLt,Lght,Levi,Prot,Dspl,CrPs,AnDe,CrSe,CsSe,CoLi,TiSt,CrVs,CsVs,Sile,Wrth,CrCr,CsCr,Raze,Slay,GrWr
                   Heal,ReDo,Harm,DiPr,HoWr,Ress,Dest,WoRe,PaHe,DiWr,RaDe,DiDe,Deus,MaMs,Shld,Loct,Fear,LtId,ChTr,FiBl,
                   LiBt,BiSh,GrSh,DuBl,UnCu,Comp,CoCd,Tele,Bani,CrPa,DeSp,BgId,HgSh,Besk,Slep,MgFi,Rein,Kill,Holo,ReFe,DetS);

  { Classes a character can be }

  Class_Type     = (NoClass,Cleric,Fighter,Paladin,Ranger,Wizard,Thief,Assassin,Monk,AntiPaladin,Bard,Samurai,Ninja,Barbarian);

  Class_Set      = Set of Class_Type;

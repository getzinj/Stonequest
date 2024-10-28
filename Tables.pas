(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit('TYPES', 'SYS$LIBRARY:STARLET','LIBRTL','SMGRTL','STRRTL')]
Module Tables;

Type
   Spell_List          = Packed Array [1..9] of Set of Spell_Name;

Var
   TrapName:                   [Global,Readonly]Array [Trap_Type]            of Varying[20] of Char;
   Item_Name:                  [Global,Readonly]Array [Item_Type]            of Varying[7] of char;
   Spell:                      [Global,Readonly]Array [Spell_Name]         of Varying[4] of Char;
   Long_Spell:                 [Global,Readonly]Array [Spell_Name]           of Varying [25] of Char;
   StatusName:                 [Global,Readonly]Array [Status_Type]          of Varying [14] of char;
   ClassName:                  [Global,Readonly]Array [Class_Type]           of Varying [13] of char;
   AlignName:                  [Global,Readonly]Array [Align_Type]           of Packed Array  [1..7] of char;
   RaceName:                   [Global,Readonly]Array [Race_Type]            of Packed Array [1..12] of char;
   SexName:                    [Global,Readonly]Array [Sex_Type]             of Packed Array [1..11] of char;
   AbilName:                   [Global,Readonly]Array [1..7]                 of Packed Array [1..12] of char;
   Party_Spell,Person_Spell,Caster_Spell,All_Monsters_Spell,Group_Spell,Area_Spell: [Global,Readonly]Set of Spell_Name;
   WizSpells,ClerSpells:       [Global,Readonly]Spell_List;


Value { We got a lot of 'em! }
   { Define the abreviated text for each spell }

  Spell[CrLt]:='CrLt'; Spell[CsLt]:='CsLt';
  Spell[Lght]:='Lght'; Spell[Prot]:='Prot';
  Spell[Dspl]:='Dspl'; Spell[CrPs]:='CrPs';
  Spell[AnDe]:='AnDe'; Spell[CrSe]:='CrSe';
  Spell[CsSe]:='CsSe'; Spell[CoLi]:='CoLi';
  Spell[CrVs]:='CrVs'; Spell[CsVs]:='CsVs';
  Spell[Wrth]:='Wrth'; Spell[CrCr]:='CrCr';
  Spell[CsCr]:='CsCr'; Spell[Raze]:='Raze';
  Spell[Slay]:='Slay'; Spell[GrWr]:='GrWr';
  Spell[Heal]:='Heal'; Spell[Harm]:='Harm';
  Spell[DiPr]:='DiPr'; Spell[HoWr]:='HoWr';
  Spell[Ress]:='Ress'; Spell[Dest]:='Dest';
  Spell[WoRe]:='WoRe'; Spell[PaHe]:='PaHe';
  Spell[DiWr]:='DiWr'; Spell[RaDe]:='RaDe';
  Spell[DiDe]:='DiDe'; Spell[Deus]:='Deus';
  Spell[MaMs]:='MaMs'; Spell[Shld]:='Shld';
  Spell[Loct]:='Loct'; Spell[Fear]:='Fear';
  Spell[ChTr]:='ChTr'; Spell[FiBl]:='FiBl';
  Spell[LiBt]:='LiBt'; Spell[BiSh]:='BiSh';
  Spell[GrSh]:='GrSh'; Spell[DuBl]:='DuBl';
  Spell[CoCd]:='CoCd'; Spell[Tele]:='Tele';
  Spell[Bani]:='Bani'; Spell[DeSp]:='DeSp';
  Spell[HgSh]:='HgSh'; Spell[Besk]:='Besk';
  Spell[Slep]:='Slep'; Spell[MgFi]:='MgFi';
  Spell[Rein]:='Rein'; Spell[Kill]:='Kill';
  Spell[Holo]:='Holo'; Spell[Sile]:='Sile';
  Spell[TiSt]:='TiSt'; Spell[Levi]:='Levi';
  Spell[CrPa]:='CrPa'; Spell[UnCu]:='UnCu';
  Spell[ReDo]:='';     Spell[LtId]:='LtId';
  Spell[BgId]:='BgId'; Spell[Comp]:='Comp';
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
  Group_Spell        :=[Slep,CsLt,Dspl,CsSe,CsVs,Wrth,CsCr,Slay,GrWr,Harm,Dest,
                        MaMs,Fear,FiBl,LiBt,CoCd,Bani,MgFi,Kill,DiDe,LtId,BgId,
                        Sile];
  Area_Spell         :=[Comp,Lght,Levi,ColI,Deus,RaDe,TiSt,DetS];

{ Define what classes get what spell at what spell level: format is
     Spell_Class_Type [Spell_Level]:=[Set of all spells of this level }

  WizSpells[1]:=[MaMs..Loct,Lght];
  WizSpells[2]:=[Fear..ChTr,CoLi,Levi];
  WizSpells[3]:=[FiBl..BiSh]+[Comp];
  WizSpells[4]:=[GrSh..DuBl,ChTr];
  WizSpells[5]:=[CoCd..Bani];
  WizSpells[6]:=[DeSp..Besk,Rein];
  WizSpells[7]:=[Slep..MgFi]+[AnDe];
  WizSpells[8]:=[Raze,Slay]+[UnCu];
  WizSpells[9]:=[Kill,Holo,Heal,Harm,TiSt];

  ClerSpells[1]:=[CrLt..Prot,ReFe]-[Levi];
  ClerSpells[2]:=[Dspl,CrPs]+[CoLi];
  ClerSpells[3]:=[CrSe..CoLi,Loct]-[CoLi]+[ChTr];
  ClerSpells[4]:=[CrVs..Wrth,Fear]+[CrPa];
  ClerSpells[5]:=[CrCr..GrWr,Levi]+[AnDe];
  ClerSpells[6]:=[Heal..HoWr,DetS]-[ReDo];
  ClerSpells[7]:=[Ress..PaHe,Bani];
  ClerSpells[8]:=[DiWr..RaDe];
  ClerSpells[9]:=[DiDe..Deus];

              { The names of the chest traps }

  TrapName[Trapless]:='Trapless Chest';
  TrapName[PoisonNeedle]:='Poisoned Needle';
  TrapName[Alarm]:='Alarm';
  TrapName[Teleporter]:='Teleporter';
  TrapName[CrossbowBolt]:='Crossbow bolt';
  TrapName[Blades]:='Blades';
  TrapName[SnoozeAlarm]:='Snooze Alarm';
  TrapName[GasCloud]:='Gas Cloud';
  TrapName[Acid]:='Acid';
  TrapName[Paralyzer]:='Paralyzer';
  TrapName[BoobyTrap]:='Booby-Trap';
  TrapName[Sleeper]:='Sleeper';
  TrapName[AntiWizard]:='Anti-Wizard';
  TrapName[AntiCleric]:='Anti-Cleric';
  TrapName[Darts]:='Darts';
  TrapName[ExplodingBox]:='Exploding box';
  TrapName[Splinters]:='Splinters';
  TrapName[Stunner]:='Stunner';

              { Types of items that can be found }

  Item_Name[Weapon]:='Weapon';
  Item_Name[Armor]:='Armor';
  Item_Name[Gloves]:='Gloves';
  Item_Name[Shield]:='Shield';
  Item_Name[Helmet]:='Helmet';
  Item_Name[Scroll]:='Scroll';
  Item_Name[Misc]:='Misc';
  Item_Name[Ring]:='Ring';
  Item_Name[Boots]:='Boots';
  Item_Name[Amulet]:='Amulet';
  Item_Name[Cloak]:='Cloak';

                       { Alignments }

  AlignName[NoAlign]:='None';     AlignName[Good]:='Good';
  AlignName[Neutral]:='Neutral';  AlignName[Evil]:='Evil';


                   { Character Classes }

  ClassName[NoClass]:='';            ClassName[Cleric]:='Cleric';
  ClassName[Fighter]:='Fighter';     ClassName[Paladin]:='Paladin';
  ClassName[Ranger]:='Ranger';       ClassName[Wizard]:='Wizard';
  ClassName[Thief]:='Thief';         ClassName[Assassin]:='Assassin';
  ClassName[Monk]:='Monk';           ClassName[Ninja]:='Ninja';
  ClassName[Bard]:='Bard';           ClassName[Samurai]:='Samurai';
  ClassName[Barbarian]:='Barbarian'; ClassName[AntiPaladin]:='AntiPaladin';

                   { Character Sexes }

  SexName[NoSex]:='';         SexName[Male]:='Male';
  SexName[Female]:='Female';  SexName[Androgynous]:='Androgynous';

                { Character Status Types }

  StatusName[NoStatus]    :='';
  StatusName[Healthy]     :='Healthy';
  StatusName[Dead]        :='Dead';
  StatusName[Deleted]     :='Lost';
  StatusName[Afraid]      :='Afraid';
  StatusName[Paralyzed]   :='Paralyzed';
  StatusName[Ashes]       :='Ashes';
  StatusName[Asleep]      :='Asleep';
  StatusName[Petrified]   :='Petrified';
  StatusName[Insane]      :='Insane';
  StatusName[Zombie]      :='Zombie';
  StatusName[Poisoned]    :='Poisoned';

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

  AbilName[1]:='Strength';     AbilName[2]:='Intelligence';
  AbilName[3]:='Wisdom';       AbilName[4]:='Dexterity';
  AbilName[5]:='Constitution'; AbilName[6]:='Charisma';
  AbilName[7]:='Luck';


End.  { Tables }

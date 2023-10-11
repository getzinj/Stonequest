[Inherit ('Types','SMGRTL')]Module Edit_Monster;

Type
   Attack_Set = Set of Attack_Type;

Var
   Number:        Integer;
   Attack_Name:   Array [Attack_Type] of Packed Array [1..11] of char;
   Propty:        Array [0..12] of Packed Array [1..16] of char;
   Cat:           Array [1..31] of Packed Array [1..28] of char;
   MonsterType:   Array [Monster_Type] of Packed Array [1..13] of char;
   ScreenDisplay: [External]Unsigned;
   Pics:          [External]Pic_List;
   Monsters:      [Local]List_of_Monsters;

Value
   Cat[1]:='Number';
   Cat[2]:='Unidentified Name';
   Cat[3]:='Unidentified Plural';
   Cat[4]:='Real Name';
   Cat[5]:='Real Plural';
   Cat[6]:='Alignment';

   Cat[7]:='Number appearing';
   Cat[8]:='Hit points';
   Cat[9]:='Monster type';
   Cat[10]:='Armor Class';
   Cat[11]:='Treas. in lair';
   Cat[12]:='Treas. wandering';
   Cat[13]:='Levels drained';
   Cat[14]:='Years aged';
   Cat[15]:='Regenerates';
   Cat[16]:='Highest cleric';
   Cat[17]:='Highest wizard';
   Cat[18]:='Magic resistance';
   Cat[19]:='Chance of Chum %';
   Cat[20]:='Chum number';
   Cat[21]:='Breath Weapon';
   Cat[22]:='# of attacks';
   Cat[23]:='Damage per attack';
   Cat[24]:='Resists';
   Cat[25]:='Monster Properties';
   Cat[26]:='Picture Number';
   Cat[27]:='Hates';
   Cat[28]:='Gaze Weapon';
   Cat[29]:='Weapon plus needed';

   MonsterType[Warrior]:='Fighters';
   MonsterType[Mage]:='Wizards';
   MonsterType[Priest]:='Clerics';
   MonsterType[Pilferer]:='Thieves';
   MonsterType[Karateka]:='Monks';
   MonsterType[Midget]:='Midgets';
   MonsterType[Giant]:='Giants';
   MonsterType[Myth]:='Myths';
   MonsterType[Reptile]:='Reptiles';
   MonsterType[Animal]:='Animals';
   MonsterType[Lycanthrope]:='Lycanthropes';
   MonsterType[Undead]:='Undead';
   MonsterType[Demon]:='Demons';
   MonsterType[Insect]:='Insects';
   MonsterType[Enchanted]:='Magical';
   MonsterType[Plant]:='Plant';
   MonsterType[Multiplanar]:='Multi-planar';
   MonsterType[Dragon]:='Dragon';
   MonsterType[Statue]:='Statue';

   Propty[0]:='Stones';            Propty[1]:='Poisons';
   Propty[2]:='Paralyzes';         Propty[3]:='AutoKills';
   Propty[4]:='Can be slept';      Propty[5]:='Can run';
   Propty[6]:='Gates';             Propty[7]:='Can''t befriend';
   Propty[8]:='Can be surprised';  Propty[9]:='Teleports away';
   Propty[10]:='Can''t be turned'; Propty[11]:='Can''t escape';
   Propty[12]:='Causes Fear';

   Attack_Name[Fire]:='Fire';
   Attack_Name[Frost]:='Cold';
   Attack_Name[Poison]:='Poison';
   Attack_Name[LvlDrain]:='Level Drain';
   Attack_Name[Stoning]:='Stoning';
   Attack_Name[Magic]:='Magic';
   Attack_Name[Death]:='Death Magic';
   Attack_Name[CauseFear]:='Fear';
   Attack_Name[Electricity]:='Electricity';
   Attack_Name[Charming]:='Charming';
   Attack_Name[Insanity]:='Insanity';
   Attack_Name[Aging]:='Aging';
   Attack_Name[Sleep]:='Sleep';

   { TODO: Enter this code }

[Global]Procedure Edit_Monster;

Begin

{ TODO: Enter this code }

End;
End.  { Edit Monster }

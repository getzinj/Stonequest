[Inherit ('Types','SMGRTL','STRRTL')]Module Edit_Items;

Type
   Attack_Set = Set of Attack_Type;
   Monster_Set = Set of Monster_Type;

Const
   Table_Size = 250;

Var
   Keyboard,ScreenDisplay: [External]Unsigned;
   Number: Integer;
   Cat: Array [1..22] of Packed Array [1..24] of char;
   Monster_T: Array [Monster_Type] of Packed Array [1..13] of char;
   Spell: [External]Array [Spell_Name] of Varying [4] of Char;
   Item_Name: [External]Array [Item_Type] of Varying [7] of Char;
   AlignName: [External]Array [Align_Type] of Packed Array [1..7] of char;
   Item_List: [External]List_of_Items;

Value
        Cat[1]:='Item Number';
        Cat[2]:='Unidentified Name';
        Cat[3]:='Actual Name';
        Cat[4]:='Alignment';
        Cat[5]:='Item type';
        Cat[6]:='Cursed?';
        Cat[7]:='Special occurance number';
        Cat[8]:='Percentage of breaking';
        Cat[9]:='Turns into';
        Cat[10]:='GP sale value';
        Cat[11]:='Number in store';
        Cat[12]:='Cast spell';
        Cat[13]:='Usable by';
        Cat[14]:='Regenerates';
        Cat[15]:='Protects against';
        Cat[16]:='Resists';
        Cat[17]:='Hates';
        Cat[18]:='Damage';
        Cat[19]:='Plus to-hit';
        Cat[20]:='AC adjustment';
        Cat[21]:='Auto Kill?';
        Cat[22]:='Additional Attacks';
        Monster_T[Warrior]:='Fighters';
        Monster_T[Mage]:='Wizards';
        Monster_T[Priest]:='Clerics';
        Monster_T[Pilferer]:='Thieves';
        Monster_T[Karateka]:='Monks';
        Monster_T[Midget]:='Midgets';
        Monster_T[Giant]:='Giants';
        Monster_T[Myth]:='Myths';
        Monster_T[Animal]:='Animals';
        Monster_T[Lycanthrope]:='Lycanthropes';
        Monster_T[Undead]:='Undead';
        Monster_T[Demon]:='Demons';
        Monster_T[Insect]:='Insects';
        Monster_T[Multiplanar]:='Multi-Planar';
        Monster_T[Dragon]:='Dragon';
        Monster_T[Statue]:='Statue';
        Monster_T[Reptile]:='Reptile';
        Monster_T[Enchanted]:='Enchanted';

[External]Procedure Get_Num (Var Number: Integer; Display: Unsigned);External;
[External]Procedure Change_Class_Set (Var ClassSet: Class_Set; T1: Line);external;
[External]Procedure Change_Attack_Set (Var AttackSet: Attack_Set; T1: Line);External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function String (Num: Integer; Len: Integer:=0):Line;external;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
(******************************************************************************)

Procedure Select_Item_Spell (Var SpellChosen: Spell_Name);

Var
   SpellName: Line;
   Location,Loop: Spell_Name;

Begin
   SpellName:='';
   Location:=NoSp;
   Cursor;
   SMG$Read_String (Keyboard,Spellname,Display_ID:=ScreenDisplay);
   No_Cursor;
   For Loop:=Crlt to DetS do
      If (STR$Case_Blind_Compare(Spell[Loop]+'',SpellName)=0) then
         Location:=Loop;
   SpellChosen:=Location;
End;

(******************************************************************************)

Procedure SpellCast (Var Curr_Spell: Spell_Name);

Begin
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay,15);
   SMG$Put_Line (ScreenDisplay,
       'Item currently casts spell '
       +Spell[Curr_Spell]);
   SMG$Put_Line (ScreenDisplay,'Cast which spell now?');
   SMG$End_Display_Update (ScreenDisplay);
   Select_Item_Spell (Curr_Spell);
   SMG$Erase_Display (ScreenDisplay,15);
   SMG$End_Display_Update (ScreenDisplay);
End;

(******************************************************************************)



{ TODO: Enter this code }

[Global]Procedure Edit_Item;

Begin { Edit Item }

{ TODO: Enter this code }

End;  { Edit Item }
End.  { Edit Items }

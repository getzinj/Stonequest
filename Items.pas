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

Procedure HatesP (Var CantStand: Monster_Set);

Var
   Pos: Integer;
   Loop: Monster_Type;
   Temp: Monster_Type;
   Answer: Char;
   T: Line;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Home_Cursor (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,
             'The item does extra damage '
             +'to these monster-types: ');
         Pos:=1;
         T:='';
         For Loop:=Warrior to Enchanted do
                 If Loop in CantStand then
                    Begin
                        T:=T+{ad(Monster_T[Loop],' ',20);
                        If Pos/3<>Pos div 3 then
                           T:=T+'    '
                        Else
                           Begin
                              SMG$Put_Line (ScreenDisplay,T);
                              T:='';
                           End;
                        Pos:=Pos+1;
                    End;
         SMG$Put_Line (ScreenDisplay,T,0);
         SMG$Set_Cursor_ABS (ScreenDisplay,15,1);
         SMG$Put_Line (ScreenDisplay,'Change which monster?');
         Pos:=1;
         T:='';
         For Loop:=Warrior to Enchanted do
             Begin
                 T:=T
                     +CHR(Ord(Loop)+65)
                     +'  '
                     +Pad(Monster_T[Loop],' ',20);
                 If Pos/3<>pos div 3 then
                     T:=T+'    '
                 Else
                     Begin
                        SMG$Put_Line (ScreenDisplay, T);
                        T:='';
                     End;
                 Pos:=Pos+1;
             End;
         SMG$Put_Line(ScreenDisplay,T,0);
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice (
             ['A'..CHR(Ord(Enchanted)+65),
              ' ']);
         If Answer<>' ' then
                 Begin
                    MonsterNum:=Ord(Answer)-65;
                    Temp:=Warrior;
                    While Ord(Temp)<>MonsterNum do
                         Temp:=Succ(Temp);
                    If Temp in CantStand then
                       CantStand:=CantStand-[Temp]
                    Else
                       CantStand:=CantStand+[Temp];
                 End;
      End;
   Until Answer=' ';
End;


(******************************************************************************)

Procedure ProtectsAgainst (Var CantHurt: Monster_Set);

Var
   Pos: Integer;
   Loop: Monster_Type;
   Temp: Monster_Type;
   Answer: Char;
   T: Line;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Home_Cursor (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,
             'The item protects against '
             +'these monster-types: ');
         Pos:=1;
         T:='';
         For Loop:=Warrior to Enchanted do
                 If Loop in CantHurt then
                    Begin
                        T:=T+{ad(Monster_T[Loop],' ',20);
                        If Pos/3<>Pos div 3 then
                           T:=T+'    '
                        Else
                           Begin
                              SMG$Put_Line (ScreenDisplay,T);
                              T:='';
                           End;
                        Pos:=Pos+1;
                    End;
         SMG$Put_Line (ScreenDisplay,T,0);
         SMG$Set_Cursor_ABS (ScreenDisplay,15,1);
         SMG$Put_Line (ScreenDisplay,'Change which monster?');
         Pos:=1;
         T:='';
         For Loop:=Warrior to Enchanted do
             Begin
                 T:=T
                     +CHR(Ord(Loop)+65)
                     +'  '
                     +Pad(Monster_T[Loop],' ',20);
                 If Pos/3<>pos div 3 then
                     T:=T+'    '
                 Else
                     Begin
                        SMG$Put_Line (ScreenDisplay, T);
                        T:='';
                     End;
                 Pos:=Pos+1;
             End;
         SMG$Put_Line(ScreenDisplay,T,0);
         SMG$End_Display_Update (ScreenDisplay);
         Answer:=Make_Choice (
             ['A'..CHR(Ord(Enchanted)+65),
              ' ']);
         If Answer<>' ' then
                 Begin
                    MonsterNum:=Ord(Answer)-65;
                    Temp:=Warrior;
                    While Ord(Temp)<>MonsterNum do
                         Temp:=Succ(Temp);
                    If Temp in CantHurt then
                       CantHurt:=CantHurt-[Temp]
                    Else
                       CantHurt:=CantHurt+[Temp];
                 End;
      End;
   Until Answer=' ';
End;

(******************************************************************************)

Procedure Print_Characteristic (Item: Item_Record; Position: Integer; Items: List_of_items;  Allow_Number_Change: Boolean);

Begin
   SMG$Put_Chars (ScreenDisplay,
       CHR(Position+64)
       +'  '
       +Cat[Position]
       +': ');
   Case Position of
      1: SMG$Put_Chars (ScreenDisplay,String(Item, Item_Number));
      2: SMG$Put_Chars (ScreenDisplay,Item, Item.Name);
      3: SMG$Put_Chars (ScreenDisplay,Item, Item.True_Name);
      4: SMG$Put_Chars (ScreenDisplay,Item, AlignName[Item.Alignment]);
      5: SMG$Put_Chars (ScreenDisplay,Item, Item_Name[Item.Kind]);
      6: If Item.Cursed=True then
             SMG$Put_Chars (ScreenDisplay,'Yes')
         Else
             SMG$Put_Chars (ScreenDisplay,'No');
      7: SMG$Put_Chars (ScreenDisplay,Item, String(Item.Special_Occurance_No));
      8: SMG$Put_Chars (ScreenDisplay,Item, String(Item.Percentage_Breaks));
      9: SMG$Put_Chars (ScreenDisplay,Item, Items[Item.Turns_Into].True_Name);
      10: SMG$Put_Chars (ScreenDisplay,Item, String(Item.GP_Value));
      11: If AmountFile^=0 then
             SMG$Put_Chars (ScreenDisplay,'None')
         Else
             If AmountFile^=-1 then
                     SMG$Put_Chars (ScreenDisplay,'Unlimited')
             Else
                     SMG$Put_Chars (ScreenDisplay,String(AmountFile^));
      12: If Ord(Item.Spell_Cast)=0 then
             SMG$Put_Chars (ScreenDisplay,'None')
         Else
             SMG$Put_Chars (ScreenDisplay,Spell[Item.Spell_Cast]);
      13: If Item.Usable_By=[] then
             SMG$Put_Chars (ScreenDisplay,'No one')
         Else
             SMG$Put_Chars (ScreenDisplay,'Press "'+CHR(13+64)+'" to edit list');
      14: SMG$Put_Chars (ScreenDisplay,Item, String(Item.Regenerates));
      15: If Item.Protects_Against=[] then
             SMG$Put_Chars (ScreenDisplay,'Nothing')
         Else
             SMG$Put_Chars (ScreenDisplay,'Press "'+CHR(15+64)+'" to edit list');
      16: If Item.Resists=[] then
             SMG$Put_Chars (ScreenDisplay,'Nothing')
         Else
             SMG$Put_Chars (ScreenDisplay,'Press "'+CHR(16+64)+'" to edit list');
      17: If Item.Versus=[] then
             SMG$Put_Chars (ScreenDisplay,'Nothing')
         Else
             SMG$Put_Chars (ScreenDisplay,'Press "'+CHR(17+64)+'" to edit list');
      18: Begin
             SMG$Put_Chars (ScreenDisplay,String(Item.Damage.X)+'D');
             SMG$Put_Chars (ScreenDisplay,String(Item.Damage.Y));
             if Item.Damage.Z<0 then
                SMG$Put_Chars (ScreenDisplay,'-')
             Else
                SMG$Put_Chars (ScreenDisplay,'+');
             SMG$Put_Chars (ScreenDisplay,String(Item.Damage.Z));
          End;
      19: SMG$Put_Chars (ScreenDisplay,Item, String(Item.Plus_to_hit));
      20: SMG$Put_Chars (ScreenDisplay,Item, String(Item.AC_Plus));
      21: If Item.Auto_Kill then
             SMG$Put_Chars (ScreenDisplay,'Yes')
         Else
             SMG$Put_Chars (ScreenDisplay,'No');
      22: SMG$Put_Chars (ScreenDisplay,Item, String(Item.Additional_Attacks));
   End;
   SMG$Put_Line (ScreenDisplay,'');
End;

(******************************************************************************)

Procedure Handle_Choice (Var Item: Item_Record; Choice_Num: Integer; Item_Number: Integer;  Allow_Number_Change: Boolean);

Var
   Num: Integer;
   Strng: Line;

Begin
   Case Choice_Num of
      2,3:  Begin
                SMG$Set_Cursor_ABS (ScreenDisplay,1,40);
                SMG$Put_Line (ScreenDisplay,
                    'Enter a string of up to 20 characters');
                Cursor; SMG$Read_String(Keyboard,Strng,Display_ID:=ScreenDisplay); No_Cursor;
                If Strng.Length>20 then Strng:=Substr(Strng,1,20);
                If Choice_Num= 2 then
                   Item.Name:=Strng
                Else
                   Item.True_Name:=Strng;
       4: If Item.Alignment=Evil then
             Item.Alignment:=NoAlign
          Else
             Item.Alignment:=Succ(Item.Alignment);
       5: If Item.Kind=Cloak then
             Item.Kind:=Weapon
          Else
             Item.Kind:=Succ(Item.Kind);
       6: Item.Cursed:=Not (Item.Cursed);
       1,7,8,9,10,11,14,19,20,22:
          Begin
             SMG$Set_Cursor_ABS (ScreenDisplay,1,40);
             SMG$Put_Line (ScreenDisplay,
                 'Enter an integer.');
             SMG$Set_Cursor_ABS (ScreenDisplay,2,40);
             Get_Num (Num,ScreenDisplay);
             Case Choice_Num of
                1: If Num<251 then Item.Item_Number:=Num;
                7: Item.Special_Occurance_No:=Num;
                8: If (Num>-1) and (Num<101) then
                   Item.Percentage_Breaks:=Num;
                9: If (Num>-1) and (Num<451) then
                   Item.Turns_Into:=Num;
               10: Item.GP_Value:=Num;
               11: If Allow_Number_Change then
                    Begin
                       Repeat
                          Find (AmountFile,Item_Number+1, Error:=Continue)
                       Until Status(AmountFile)=0;
                       AmountFile^:=Num;
                       Update (AmountFile);
                    End;
               14:  Item.Regenerates:=Num;
               19: If (Num>-128) and (Num<128) then
                      Item.Plus_to_hit:=Num;
               20: If (Num>-21) and (Num<21) then
                      Item.AC_Plus:=Num;
               22: Item.Additional_Attacks:=Num;
             End;
          End;
       18: Begin
             SMG$Put_Chars (ScreenDisplay,'Enter X: ',1,40);
             Get_Num (Item.Damage.X, ScreenDisplay);
             SMG$Put_Chars (ScreenDisplay,'Enter Y: ',2,40);
             Get_Num (Item.Damage.Y, ScreenDisplay);
             SMG$Put_Chars (ScreenDisplay,'Enter Z: ',3,40);
             Get_Num (Item.Damage.Z, ScreenDisplay);
           End;
       12: SpellCast (Item.Spell_Cast);
       13: Change_Class_Set (Item.Usable_By,
              'The item can be used by these classes');
       15: Protectsagainst (Item.Protects_Against);
       16: Change_Attack_Set (Item.Resists,
               'The item is resistant to these attack forms');
       17: HatesP (Item.Versus);
       21: Item.Auto_Kill:=Not (Item.Auto_Kill);
   End;
End;

(******************************************************************************)

[Global]Procedure Item_Change_Screen (Var Item: Item_Record;  Number: Integer;
                                      Var Items: List_of_Items;  Allow_Number_Change: Boolean:=True);

Var
   Loop: Integer;
   Answer: Char;

Begin
  Open(AmountFile,
     file_name:='store.dat;1',History:=Unknown,Access_Method:=DIRECT,
     Sharing:=READWRITE);

  Loop:=0;
  Repeat
     Begin
        Find(AmountFile,Number+1);

        SMG$Begin_Display_Update (ScreenDisplay);
        SMG$Erase_Display (ScreenDisplay);
        SMG$Home_Cursor (ScreenDisplay);
        SMG$Put_Line (ScreenDisplay,'Item #'+String(Number,3));
        SMG$Put_Line (ScreenDisplay,'---- ----');
        For Loop:=1 to 22 do
           Print_Characteristic (Item,Loop,Items,Allow_Number_Changes);
        SMG$End_Display_Update (ScreenDisplay);
        Answer:=Make_Choice (['A'..'V',' ']);
        If Answer<>' ' then
           Handle_Choice (Item,Ord(Answer)-64,Number,Allow_Number_Change);
        Unlock (AmountFile);
     End;
  Until Answer=' ';
  Close (AmountFile);
End;

(******************************************************************************)

Procedure Change_Item (Number: Integer; Var Item_List: List_of_Items);

Begin
   SMG$Erase_Display (ScreenDisplay);
   SMG$Home_Cursor (ScreenDisplay);
   Item_Change_Screen (Item_List[Number],Number,Item_list,True);
End;

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Edit_Item;

Begin { Edit Item }

{ TODO: Enter this code }

End;  { Edit Item }
End.  { Edit Items }

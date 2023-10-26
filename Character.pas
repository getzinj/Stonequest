[Inherit ('Types','SYS$LIBRARY:Starlet','Librtl','SmgRtl','StrRtl')]Module Character_Editor;

Const
   ZeroOrd = Ord('0');
   Up_Arrow   = CHR(18);   Down_Arrow = CHR(19);
   Left_Arrow = CHR(20);   Right_Arrow = CHR(21);

Type
   Category_Type   = Array [1..29]     of Packed Array [1..16] of Char;
   Age_Class_Type   = Array [Age_Type] of Packed Array [1..16] of Char;

Var
   ScreenDisplay,Keyboard: [External]Unsigned;
   Spell: [External]Array [Spell_Name] of Varying [4] of Char;
   StatusName: [External]Array [Status_Type] of Varying [14] of char;
   ClassName: [External]Array [Class_Type] of Varying [13] of char;
   AlignName: [External]Array [Align_Type] of Packed Array [1..7] of char;
   RaceName: [External]Array [Race_Type] of Packed Array [1..12] of char;
   SexName: [External]Array [Sex_Type] of Packed Array [1..11] of char;
   AbilName: [External]Array [1..7] of Packed Array [1..12] of char;
   Char_File: [External]Character_File; { TODO: Use methods in Files.pas }
   Item_List: [External]List_of_Items;
   Cat: Category_Type;
   Age_Class: Age_Class_Type;

Value
   Cat[1]:='Character Number';       Cat[2]:='Name';
   Cat[3]:='Sex';                    Cat[4]:='Race';
   Cat[5]:='Alignment';              Cat[6]:='Class';
   Cat[7]:='Previous Class';         Cat[8]:='Age';
   Cat[9]:='Strength';               Cat[10]:='Intelligence';
   Cat[11]:='Wisdom';                Cat[12]:='Dexterity';
   Cat[13]:='Constitution';          Cat[14]:='Charisma';
   Cat[15]:='Luck';                  Cat[16]:='Gold';
   Cat[17]:='Experience';            Cat[18]:='Level';
   Cat[19]:='Previous Level';        Cat[20]:='Lock Status';
   Cat[21]:='Current HP';            Cat[22]:='Max HP';
   Cat[23]:='Armor Class';           Cat[24]:='Status';
   Cat[25]:='# of items';            Cat[26]:='Items';
   Cat[27]:='Spells';                Cat[28]:='Age Status';
   Cat[29]:='Psionics';

    Age_Class[YoungAdult]:='Young Adult';
    Age_Class[Mature]:='Mature';
    Age_Class[MiddleAged]:='Middle Aged';
    Age_Class[Old]:='Old';
    Age_Class[Venerable]:='Venerable';
    Age_Class[Croak]:='Croak';

[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): Char;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;
[External]Function Get_Num (Display: Unsigned): Integer;External;
[External]Procedure No_Controly;External;
[External]Procedure Controly;External;
(******************************************************************************)

Procedure Home;

Begin
   SMG$Erase_Display (ScreenDisplay);
   SMG$Home_Cursor (ScreenDisplay);
End;

(******************************************************************************)

Procedure Print_Edit_Roster (Roster: Roster_Type);

Var
  Loop: Integer;
  T: Line;

Begin
   Home;
   SMG$Put_Line (ScreenDisplay,'                      Roster of Characters',1,1);
   SMG$Put_Line (ScreenDisplay,' #)  Name                   Class            Level      Status');
   For Loop:=1 to 20 do
      Begin
         T:=String(Loop,2)+')  '+Pad(Roster[Loop].Name,' ',20)+' '+AlignName[Roster[Loop].Alignment][1]+'-';
         T:=T+Pad(ClassName[Roster[Loop].Class],' ',13)+'   '+String(Roster[Loop].Level,3)+'       ';
         T:=T+StatusName[Roster[Loop].Status];
         SMG$Put_line (ScreenDisplay,T);
      End;
End;

(******************************************************************************)

Function Get_Item_Number (Current_Item_Num: Integer): [Volatile]Integer;

Var
  Temp: Integer;

Begin
   SMG$Put_Line (ScreenDisplay,'Enter a number between 0 and 250. ');
   SMG$Put_Chars (ScreenDisplay,'--->');
   Temp:=Get_Num (ScreenDisplay);
   If (Temp>-1) and (Temp<251) then
      Get_Item_Number:=Temp
   Else
      Get_Item_Number:=Current_Item_Num;
End;

(******************************************************************************)

Procedure Edit_Character_Item (Var Item: Equipment_Type);

Var
   Answer: Char;
   Options: Char_Set;
   Bool_String: Array[Boolean] of Line;

Begin
   Bool_String[False]:='No';   Bool_String[True]:='Yes';
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,'Edit which field?');
         SMG$Put_Line (ScreenDisplay,'-----------------');
         SMG$Put_Line (ScreenDisplay,'C)ursed = '+Bool_String[Item.Cursed]);
         SMG$Put_Line (screenDisplay,'U)sable = '+Bool_String[Item.Usable]);
         SMG$Put_Line (screenDisplay,'E)quipped = '+Bool_String[Item.Equipted]);
         SMG$Put_Line (screenDisplay,'I)dentified = '+Bool_String[Item.Ident]);
         SMG$Put_Line (screenDisplay,'N)umber = '+String(Item.Item_Num)+' ('+Item_List[Item.Item_Num].True_Name+')');
         SMG$End_Display_Update (ScreenDisplay);

         Options:=['C','U','E','I','N',CHR(32)];
         Answer:=Make_Choice(Options);

         Case Answer of
            'C':  Item.Cursed:=Not Item.Cursed;
            'U':  Item.Usable:=Not Item.Usable;
            'E':  Item.Equipted:=Not Item.Equipted;
            'I':  Item.Ident:=Not Item.Ident;
            'N':  Item.Item_Num:=Get_Item_Number (Item.Item_Num);
            ' ': ;
         End;
      End;
   Until Answer=CHR(32);
End;

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Edit_Character (Var Roster: Roster_Type);
Begin

   { TODO: Enter this code }

End;


[Global]Procedure Edit_Players_Characters;
Begin { Edit Players Character }

   { TODO: Enter this code }

End;  { Edit Players Character }
End.  { Character Editor }

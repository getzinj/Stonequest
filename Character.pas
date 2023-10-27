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

Procedure Edit_Psionics (Var Character: Character_Type);

Var
   Num: Integer;
   Answer: Char;
   Options: Char_Set;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,'Edit which field?');
         SMG$Put_Line (ScreenDisplay,'-----------------');
         SMG$Put_Line (ScreenDisplay,'R)egeneration = '+String (Character.Regenerate));
         SMG$Put_Line (ScreenDisplay,'S)ecret detection = '+String (Character.DetectSecret));
         SMG$Put_Line (ScreenDisplay,'T)Trap and Special detection = '+String (Character.DetectTrap));
         SMG$End_Display_Update (ScreenDisplay);

         Options:=['R','S','T',CHR(32)];
         Answer:=Make_Choice(Options);

         If Answer<>CHR(32) then
            Begin
               SMG$Put_Chars (ScreenDisplay,'--->');
               Num:=Get_Num (ScreenDisplay);

               Case Answer of
                  'R':  Character.Regenerates:=Num;
                  'S':  Character.DetectSecret:=Num;
                  'T':  Character.DetectTrap:=Num;
                 End;
            End;
      End;
   Until Answer=CHR(32);
   Character.Psionics:=(Character.DetectTrap<>0) or (Character.DetectSecret<>0) or (Character.Regenerate<>0);
End;

(******************************************************************************)

Procedure Print_Item_Line (Character: Character_Type; Pos: Integer);

Var
   Item: Item_Record;

Begin
   Item:=Item_List[Character.Item[Pos].Item_Num];
   SMG$Put_Line (ScreenDisplay,String(Pos)+')  '+Item.True_Name);
End;

(******************************************************************************)

Procedure Change_Character_Items (Var Character: Character_Type);

Var
  i: Integer;
  Options: Char_Set;
  Answer: Char;

Begin
  Repeat
    Begin
       SMG$Begin_Display_Update (ScreenDisplay);
       SMG$Erase_Display (ScreenDisplay);

       SMG$Put_Line (ScreenDisplay,'Edit which item?');
       SMG$Put_Line (ScreenDisplay,'----------------');

       For i:=1 to Character.No_of_Items do
          Print_Item_Line (Character, i);

       SMG$End_Display_Update(ScreenDisplay);

       Options:=['1'..CHR(Character.No_of_Items+ZeroOrd),CHR(13)];
       Answer:=Make_Choice (Options);

       If Answer<>CHR(32) then
          Begin
             i:=ORD(answer)-ZeroOrd;
             Edit_Character_Item (Character.Item[i]);
          End;
    End;
  Until Answer=CHR(32);
End;

(******************************************************************************)

Procedure Change_Screen1 (Number: Integer; Var Character: Character_Type);

Var
   Options: Char_Set;
   Num,Loop: Integer;
   Answer: Char;
   T,Strng: Line;

Begin
   Loop:=0;
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Home_Cursor (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,'Character #'+String(Number,3));
         SMG$Put_Line (ScreenDisplay,'--------------');
         For Loop:=1 to 15 do
            Begin
               T:=CHR(Loop+64)+'  '+Cat[Loop]+': ';

               Case Loop of
                    1:  T:=T+String(Number);
                    2:  T:=T+Character.Name;
                    3:  T:=T+SexName[Character.Sex];
                    4:  T:=T+RaceName[Character.Race];
                    5:  T:=T+AlignName[Character.Alignment];
                    6:  T:=T+ClassName[Character.Class];
                    7:  T:=T+ClassName[Character.PreviousClass];
                    8:  T:=T+String((Character.Age div 365));
                    9:  T:=T+String(Character.Abilities[1],2);
                    10:  T:=T+String(Character.Abilities[2],2);
                    11:  T:=T+String(Character.Abilities[3],2);
                    12:  T:=T+String(Character.Abilities[4],2);
                    13:  T:=T+String(Character.Abilities[5],2);
                    14:  T:=T+String(Character.Abilities[6],2);
                    15:  T:=T+String(Character.Abilities[7],2);
               End;
               SMG$Put_Line (ScreenDisplay, T);
            End;
         SMG$End_Display_Update(ScreenDisplay);

         Options:=['A'..'O',' '];
         Answer:=Make_Choice(Options);

         Case Ord(Answer)-64 of
            2: Begin
                SMG$Set_Cursor_ABS (ScreenDisplay,18,1);
                SMG$Put_Line (ScreenDisplay,'Enter a string of up to 20 characters');
                Cursor;
                SMG$Read_String (Keyboard,Strng,'--->',Display_Id:=ScreenDisplay);
                No_Cursor;
                If Strng.Length > 20 then
                   Strng:=Substr (Strng,1,20);
                Character.Name:=Strng;
              End;
            3: If Character.Sex=Androgynous then
                  Character.Sex:=Male
               Else
                  Character.Sex:=Succ(Character.Sex);
            4: If Character.Race=Numenorean then
                  Character.Race:=Human
               Else
                  Character.Race:=Succ(Character.Race);
            5: If Character.Alignment=Evil then
                  Character.Alignment:=Good
               Else
                  Character.Alignment:=Succ(Character.Alignment);
            6: If Character.Class=Barbarian then
                  Character.Class:=NoClass
               Else
                  Character.Class:=Succ(Character.Class);
            7: If Character.PreviousClass=Barbarian then
                  Character.PreviousClass:=NoClass
               Else
                  Character.PreviousClass:=Succ(Character.PreviousClass);
            8..15: Begin
                     SMG$Set_Cursor_ABS (ScreenDisplay,18,1);
                     SMG$Put_Line (ScreenDisplay,'Enter an integer.');
                     SMG$Put_Chars (ScreenDisplay,'--->',19,1);

                     Num:=Get_Num(ScreenDisplay);

                     Case Ord(Answer)-64 of
                       8: Character.Age:=Num*365;
                       9..15: If (Num>2) and (Num<26) then
                          Character.Abilities[Ord(answer)-72]:=Num;
                     End;
                   End;
         End;
      End;
   Until Answer=' ';
End;

(******************************************************************************)

Procedure Print_Spell (Book: Spell_Set; Column,Cursor: Spell_Name; X,Y: Integer);

Var
  R: Unsigned;

Begin
  R:=0;
  If Column in Book then R:=R+1;
  If Column=Cursor then R:=R+2;
  SMG$Put_Chars (ScreenDisplay,Spell[Column],Y,X,,R);
End;

(******************************************************************************)

Procedure Print_Book (Book: Spell_Set;  Cursor: Spell_Name);

Var
  Column: Spell_Name;
  X,Y: Integer;

Begin
   SMG$Begin_Display_Update (ScreenDisplay);
   SMG$Erase_Display (ScreenDisplay);

   X:=1;  Y:=1;
   For Column:=CrLt to Heal do
      Begin
         Print_Spell (Book,Column,Cursor,X,Y);
         Y:=Y+1;
      End;

   X:=20;  Y:=1;
   For Column:=Harm to Dubl do
      Begin
         Print_Spell (Book,Column,Cursor,X,Y);
         Y:=Y+1;
      End;

   X:=40;  Y:=1;
   For Column:=Succ(DuBl) to DetS do
      Begin
         Print_Spell (Book,Column,Cursor,X,Y);
         Y:=Y+1;
      End;

   SMG$End_Display_Update (ScreenDisplay);
End;

(******************************************************************************)

Procedure Edit_Book (Var Book: Spell_Set);

Var
   Cursor: Spell_Name;
   Key: Char;

Begin
   Cursor:=CrLt;
   Repeat
      Begin
         Print_Book (Book,Cursor);

         Key:=Make_Choice ([Up_arrow,Down_Arrow,' ',CHR(13)]);

         Case Key of
            Up_Arrow:  If Cursor=CrLt then
                          Cursor:=DetS
                       Else
                          Cursor:=Pred(Cursor);
            Down_Arrow: If Cursor=DetS then
                           Cursor:=CrLt
                        Else
                           Cursor:=Succ(Cursor);
            ' ': If Cursor in Book then
                    Book:=Book-[Cursor]
                 Else
                    Book:=Book+[Cursor];
            CHR(13): ;
         End;
      End;
   Until Key=CHR(13);
End;

(******************************************************************************)

Procedure Edit_Spell_Book (Var Character: Character_Type);

Var
   Leave: Boolean;

Begin
   Leave:=False;
   Repeat
      Begin
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,'Edit: W)izard spells, C)leric spells, or L)eave');
         Case Make_Choice(['W','C','L']) of
           'L': Leave:=True;
           'W': Edit_Book (Character.Wizard_Spells);
           'C': Edit_Book (Character.Cleric_Spells);
         End;
      End;
   Until Leave;
End;

(******************************************************************************)

Procedure Print_Spell_Points (Character: Character_Type; PosX,PosY: Integer);

Var
  Y,Y1,X: Integer;
  T: Line;
  R: Unsigned;

Begin
   For Y:=1 to 2 do
      Begin
         If Y=1 then T:='Cleric  /'
         Else        T:='Wizard  /';

         SMG$Put_Chars (ScreenDisplay,T);

         For X:=1 to 9 do
            Begin
               If (X=PosX) and (Y=PosY) then
                  R:=2 { TODO: Calculate using SMG constants for clarity }
               Else
                  R:=0;
               Y1:=Y;

               SMG$Put_Chars (ScreenDisplay,String(Character.SpellPoints[Y,X]),Y1,7+(X*2),,R);
               SMG$Put_Chars (ScreenDisplay,'/');
            End;
         SMG$Put_Line (ScreenDisplay,'');
      End;
End;

(******************************************************************************)

Procedure Edit_Spell_Points (Var Character: Character_Type);

Var
  PosX,PosY: Integer;
  Answer: Char;

Begin
  PosX:=1; PosY:=1;
  Repeat
     Begin
        SMG$Begin_Display_Update (ScreenDisplay);
        SMG$Erase_Display (ScreenDisplay);

        Print_Spell_Points (Character,PosX,PosY);
        SMG$End_Display_Update (ScreenDisplay);

        Answer:=Make_Choice(['+','-',Up_Arrow,Down_Arrow,Left_Arrow,Right_Arrow,' ']);

        Case Answer of
             Left_Arrow: Begin
                           PosX:=PosX-1;
                           If PosX<1 then PosX:=9;
                         End;
             Right_Arrow: Begin
                           PosX:=PosX+1;
                           If PosX>9 then PosX:=1;
                         End;
             Up_Arrow,Down_Arrow: If PosY=1 then
                                     PosY:=2
                                  Else
                                     PosY:=1;
             '+': Character.SpellPoints[PosY,PosX]:=Min(Character.SpellPoints[PosY,PosX] + 1, 9);
             '-': Character.SpellPoints[PosY,PosX]:=Max(Character.SpellPoints[PosY,PosX] - 1, 0);

             ' ': ;
        End;
     End;
  Until Answer=' ';
End;

(******************************************************************************)

Procedure Edit_Spells (Var Character: Character_Type);

Var
   Leave: Boolean;

Begin
   Leave:=False;
   Repeat
      Begin
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,'Edit: 1=Spell Book, 2=Spell Points, 0=Exit');
         Case Make_Choice(['0','1','2']) of
            '0': Leave:=True;
            '1': Edit_Spell_Book (Character);
            '2': Edit_Spell_Points (Character);
         End;
      End;
   Until Leave;
End;

(******************************************************************************)

Procedure Change_Screen2 (Number: Integer; Var Character: Character_Type);

Var
   T: Line;
   Options: Char_Set;
   Num,Loop: Integer;
   Answer: Char;

Begin
   Loop:=0;
   Repeat
      Begin
         SMG$Begin_Display_Update (ScreenDisplay);
         SMG$Erase_Display (ScreenDisplay);
         SMG$Put_Line (ScreenDisplay,'Character #'+String(Number,3));
         SMG$Put_Line (ScreenDisplay,'--------------');
         For Loop:=16 to 29 do
            Begin
               T:=CHR(Loop+64)+'  '+Cat[Loop]+': ';

               Case Loop of
                    16:  T:=T+String(Character.Gold);
                    17:  T:=T+String(Trunc(Character.Experience));
                    18:  T:=T+String(Character.Level);
                    19:  T:=T+String(Character.Previous_Lvl);
                    20:  If Character.Lock then
                           T:=T+'Out'
                         Else
                           T:=T+'In';
                    21:  T:=T+String(Character.Curr_HP);
                    22:  T:=T+String(Character.Max_HP);
                    23:  T:=T+String(Character.Armor_Class);
                    24:  T:=T+StatusName[Character.Status];
                    25:  T:=T+String(Character.No_of_Items);
                    26:  If Character.No_of_items=0 then
                            T:=T+'None'
                         Else
                            T:=T+'Type ''K'' to edit list';
                    27:  T:=T+'Type ''L'' to edit list';
                    28:  T:=T+Age_Class[Character.Age_Status];
                    29:  If Character.Psionics then
                            T:=T+'Type ''N'' to edit'
                         Else
                            T:=T+'None';
               End;
               SMG$Put_Line (ScreenDisplay, T);
            End;
         SMG$End_Display_Update(ScreenDisplay);

         Options:=['A'..'O',' '];
         Answer:=Make_Choice(Options);

         Case Ord(Answer)-49 of
            26: Change_Character_Items (Character);
            27: EDIT_SPELLS (Character);
            29: If Not Character.Psionics then Character.Psionics:=True
                Else EDIT_PSIONICS (Character);
            16..19,21..23,25: Begin
                     SMG$Set_Cursor_ABS (ScreenDisplay,17,1);
                     SMG$Put_Line (ScreenDisplay,'Enter an integer.');
                     SMG$Put_Chars (ScreenDisplay,'--->',18,1);
                     Num:=Get_Num (ScreenDisplay);
                     Case Ord(Answer)-49 of
                        16: Character.Gold:=Num;
                        17: Character.Experience:=Num;
                        18: If ABS(Num)<32768 then Character.Level:=Num;
                        19: If ABS(Num)<32768 then Character.Previous_Lvl:=Num;
                        21: Character.Curr_HP:=Num;
                        22: Character.Max_HP:=Num;
                        23: If ABS(Num)<128 then Character.Armor_Class:=Num;
                        25: If (Num>-1) and (Num<9) then Character.No_of_items:=Num;
                     End;
                 End;
            20: Character.Lock:=Not (Character.Lock);
            24: If Character.Status=Poisoned then
                   Character.Status:=Healthy
                Else
                   Character.Status:=Succ(Character.Status);
            28: If Character.Age_Status=Croak then
                   Character.Age_Status:=YoungAdult
                Else
                   Character.Age_Status:=Succ(Character.Age_Status);
         End;
      End;
   Until Answer=' ';
End;

(******************************************************************************)

{ TODO: Enter code }

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

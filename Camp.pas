(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types','SMGRTL','SYS$LIBRARY:STARLET')]Module Camp;

{ This module allows the adventuring party to set up camp inside the maze, and perform such tasks as casting spells or re-
  ordering the party.  By the way, does anybody out there have any idea on why they call that stupid file STARLET? }

Const
   ZeroOrd=ORD('0');

Type
   ItemSet   = ^ItemNode;                    { Pointer to a linked list of items }
   ItemNode  = Record
                 Identified:   Boolean;      { Does anybody know what it is? }
                 Owner_Number: 1..6;         { Who owns the item? }
                 Item_Num:     Integer;      { Which item is it? }
                 Next_Item:    ItemSet;      { Pointer to the rest of the items }
               End;
   Item_Pool = Array [Item_Type] of ItemSet; { List for each type of item }

Var { External }
   CharacterDisplay,Pasteboard,CommandsDisplay,SpellsDisplay,ViewDisplay,MessageDisplay,CampDisplay: [External]Unsigned;
   MonsterDisplay,ScreenDisplay:        [External]Unsigned;
   Maze:                                [External]Level;
   PosX,PosY,PosZ:                      [External,Byte]0..20;
   Direction:                           [External]Direction_Type;
   Auto_Load,Game_Saved,Leave_Maze:     [External]Boolean;
   Minute_Counter:                      [External]Real;
   Item_List:                           [External]List_of_Items;
   Rounds_Left:                         [External]Array [Spell_Name] of Unsigned;

(******************************************************************************)
[External]Function Write_Save_File (saveRecord: Save_Record): Boolean;External;
[External]Procedure Party_Box (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                             Var Leave_Maze: Boolean);External;
[External]Procedure Error_Window (FileType: Line);External;
[External]Procedure Read_Error_Window (FileType: Line; Code: Integer:=0);External;
[External]Procedure Restore_Spells (Var Character: Character_Type);External;
[External]Procedure Delay (Seconds: Real);External;
[External]Function Alive (Character: Character_Type): Boolean;External;
[External]Function Make_Choice (Choices: Char_Set;  Time_Out:  Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
(******************************************************************************)

Procedure Unpaste_All;

{ This procedure will unpaste the maze displays from the screen.  This is used in such a case when we want to go from camp directly
  to Kyrn without showing the maze, e.g. when teleporting. }

Begin { Unpaste All }
   SMG$Unpaste_Virtual_Display (CharacterDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (CommandsDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (SpellsDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (ViewDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (MessageDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (CampDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display (MonsterDisplay,Pasteboard);
End;  { Unpaste All }

(******************************************************************************)

Procedure Switch_Characters (Var Character1,Character2: Character_Type);

{ This procedure will swap two characters.  Although it is a general-use procedure, this is mainly meant to be used with
  REORDER_PARTY, when two characters must be switched in order. }

Var
   Temp: Character_Type;

Begin { Switch Characters }
   Temp:=Character1;
   Character1:=Character2;
   Character2:=Temp;
End;  { Switch Characters }

(******************************************************************************)

Procedure Dead_Characters (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type; Party_Size: Integer);

{ This procedure will check the characters in MEMBER to see if they are still alive, and an updated CURRENT_PARTY_SIZE is
  returned.  Also, the party is Bubblesorted (why not?) so that the dead characters are pushed to the read of the party. }

Var
   Done: Boolean;
   Character: Integer;

Begin { Dead Characters }
   Current_Party_Size:=0;
   For Character:=1 to Party_Size do
     If (Alive(Member[Character])) then  { For every living member }
        Begin
           Current_Party_Size:=Current_Party_Size + 1;  { Increment survivor count }
        End;

   { With only six items, we might as well use a Bubblesort as any other sort.  This will put the dead characters at the rear of
     the party. }

   Repeat
      Begin { Repeat }
         Done:=True;
         For Character:=Party_Size downto 2 do
            Begin { For }
               If (Alive(Member[Character]) and Not(Alive(Member[Character-1]))) then
                  Begin { Need to swap }
                     Switch_Characters (Member[Character],Member[Character-1]);
                     Done:=False;
                  End;  { Need to swap }
            End; { For }
      End;  { Repeat }
   Until Done;
End;  { Dead Characters }

(******************************************************************************)

Procedure Pool_Items (Var Member: Party_Type;  Party_Size: Integer; Var Choices: Item_Pool);

{ This sub-procedure will make a list of all available items, and return it in CHOICES.  Then all characters are temporarilly "un-
  equipped" so that duplicate items do not result. }

Var
   Character: Character_Type;
   Kind,Item_Kind: Item_Type;
   Person,Item_No,Num: Integer;
   Temp: ItemSet;
   Item: Item_Record;

Begin { Pool Items }
   For Kind:=Weapon to Cloak do
      Begin
         Choices[Kind]:=Nil; { initialize lists }
      End;

   For Person:=1 to Party_Size do  { For every character }
      Begin { For each person }
         Character:=Member[Person];  { Create a temp character }
         Num:=Character.No_Of_Items; { Kee[ track of his/her # of items }
         For Item_No:=Num downto 1 do  { For each item ... }
            Begin { For }
               If (Not (Character.item[Item_No].Cursed)) then  { If not cursed }
                  Begin { Not cursed }
                     Item:=Item_List[Character.Item[Item_No].Item_Num];
                     Item_Kind:=Item.Kind;
                     New (Temp);  { Make a node for the list }

                     { Copy relevant data }

                     Temp^.Identified:=Character.Item[Item_No].Ident;
                     Temp^.Item_Num:=Item.Item_Number;
                     Temp^.Owner_Number:=Person;

                     Temp^.Next_Item:=Choices[Item_Kind];
                     Choices[Item_Kind]:=Temp;

                     { Remove the item from the character }

                     Character.Item[Item_No]:=Character.Item[Num];
                     Num:=Num-1;
                  End;  { Not Cursed }
            End; { For }
         Character.No_of_Items:=Num;  { Return the updated # of items }
         Member[Person]:=Character;   { Copy the character back to the party }
      End;  { For Each Person }
End;  { Pool Items }

(******************************************************************************)

Procedure Delete (Node: ItemSet; Var List: ItemSet);

{ This procedure recursively deletes the node pointed to by NODE from the list, LIST }

Var
   remainder: ItemSet;

Begin { Delete }
   If List <> Nil then
      Begin
         If List = Node then
            List:=List^.Next_Item
         Else
            Begin
               remainder:=List^.Next_Item;

               Delete (Node, remainder);

               List^.Next_Item:=remainder;
            End;
      End;
End;  { Delete }

(******************************************************************************)

Procedure Print_Item_Node (Node: ItemSet; Choice_Num: Integer);

{ This procedure prints the name of the item pointed to by NODE.  It also gives the letter equivalent of CHOICE_NUM so that the
  user can select it. }

Var
   Item: Item_Record;

Begin { Print Item Node }
   Item:=Item_List[Node^.Item_Num];
   SMG$Put_Chars (CampDisplay, '[' +CHR(Choice_Num + 64) + ']   ');

   If (Node^.Identified) then
      Begin
         SMG$Put_Line (CampDisplay, Item.True_Name);
      End
   Else
      Begin
         SMG$Put_Line (CampDisplay, '?' + Item.Name);
      End;
End;  { Print Item Node }

(******************************************************************************)
[External]Function Usable_Item (Character: Character_Type; Item: Item_Record): Boolean;External;
(******************************************************************************)

Function Print_Usable_And_Return_Choices (Character: Character_Type; Choice_List: ItemSet): Char_Set;

Var
   Options: Set of char;
   TempPtr: ItemSet;
   Position: Integer;
   Item: Item_Record;

Begin
   Position:=0;
   TempPtr:=Choice_list;  { The temporary pointer points to beginning of list }

   While (TempPtr <> Nil) do  { While there are items on list }
      Begin
         Item:=Item_List[TempPtr^.Item_Num];

         If Usable_Item(Character, Item) then
            Begin
               Position:=Position + 1;                  { Increment the line counter }
               Options:=Options + [CHR(Position + 64)]; { Add it to the set of choices }

               Print_Item_Node (TempPtr, Position);     { Print the choice }
            End;

         TempPtr:=TempPtr^.Next_Item;           { Go to next item }
      End;

   Print_Usable_And_Return_Choices := Options;
End;

(******************************************************************************)

Function Character_Equips_Item (character: Character_Type; itemNumber: Integer; Var Choice_List: ItemSet): ItemSet;

Var
   Item: Item_Record;
   Temp: ItemSet;
   Position: Integer;
   TempPtr: ItemSet;

Begin
     Position:=0;
     TempPtr:=Choice_List;
     Temp:=Nil;

     While (TempPtr <> Nil) and (Position < itemNumber) do  { Until found }
        Begin { For each item }
           Item:=Item_List[TempPtr^.Item_Num];  { Get the item }

           If Usable_Item(Character, Item) then
                 Begin
                    Position:=Position + 1;  { Advance the counter }
                    Temp:=TempPtr;           { Get the current ptr. }
                 End;
           TempPtr:=TempPtr^.Next_Item;      { Go to next item }
        End;  { For each item }

     If (Temp <> Nil) then
        Begin
           Delete (Temp, Choice_List);  { delete the node from the list }
        End;

     Character_Equips_Item := Temp;
End;

(******************************************************************************)

Function Choose_From_List (Character: Character_Type; Var Choice_List: ItemSet): ItemSet;

{ This function will display a list of viable choices for a character, and return the one (if any) he selects.  If nothing is
  chosen, the value NUL is returned, otherwise the pointer to the selected item_node is returned. }

Var
   Chosen: Integer;
   Options: Set of char;
   Answer: Char;

[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;

Begin { Choose from List }
   Options:= Print_Usable_And_Return_Choices(Character, Choice_List);

   SMG$Put_Line (CampDisplay, 'Which?', 0);

   Options := Options + [ CHR(13) ];

   Cursor;
   Answer:=Make_Choice (Options);               { Get the choice }
   No_Cursor;

   If (Answer <> CHR (13)) then   { If the player chose an item... }
      Begin
         Chosen:=Ord(Answer) - 64;  { Find the number desired }

         Choose_From_List := Character_Equips_Item(Character, Chosen, Choice_List);
      End
   Else
      Choose_From_List:=Nil;  { Otherwise, return Nil }
End;  { Choose from List }

(******************************************************************************)

Function One_Usable (Choices: ItemSet; Character: Character_Type): Boolean;

{ This function returns TRUE if there one item in CHOICES that CHARACTER can use, and FALSE otherwise.  And item is usable by a
  character if the alignments match (or if the item has NoAlign) and CHARACTER's class is one thatr can use the item (in .USABLE_BY).  }

Var
   Align: Align_Type;
   Class,Class1: Class_Type;
   At_Least_One: Boolean;
   Traveller: ItemSet;
   Item: Item_Record;

Begin { One Usable }
   Align:=Character.Alignment; Class:=Character.Class; Class1:=Character.PreviousClass;
   At_Least_One:=False;  Traveller:=Choices;
   While ((Not At_Least_One) and (Traveller<>Nil)) do
      Begin { At Least One means that there is >=1 equippable item }
         Item:=Item_List[Traveller^.Item_Num];
         At_Least_One:=(Class in Item.Usable_By) or (Class1 in Item.Usable_By);
         At_Least_one:=At_Least_one and ((Align=Item.Alignment) or (Item.Alignment=NoAlign));
         Traveller:=Traveller^.Next_item;
      End;
   One_Usable:=At_Least_One;
End;  { One Usable }

(******************************************************************************)

Procedure Select_Item (Var Character: Character_Type; Kind: Item_Type; Var Choices: ItemSet);

{ This procedure will print out a list of items and allow a character to choose one, or none. }

Var
   T: Line;
   ItemPtr: ItemSet;
   Num: Integer;
   Item: Item_Record;
   Item_Name: [External]Array [Item_Type] of Varying [7] of char;

Begin { Select Item }
   If (One_Usable (Choices,Character)) then  { If there is a usable item in list }
      Begin { at least one usable }
         SMG$Erase_Display (CampDisplay);

         T:='[RETURN] for none';
         SMG$Put_Chars (CampDisplay,T,23,39-(t.length div 2));

         T:='Please select a ' + Item_Name[Kind] + ' for ' + Character.Name;
         SMG$Set_Cursor_ABS (CampDisplay,1,39-(t.length div 2));
         SMG$Put_Line (CampDisplay,T,1);
         { SMG$END_DISPLAY_UPDATE (CAMPDISPLAY) in Choose_from_list }

         { Get the item chosen }

         ItemPtr:=Choose_From_List(Character, Choices);

         If (ItemPtr<>Nil) then  { If there WAS an item chosen }
            Begin { Item selected }

                  { Add the item to the character's collection }

               Item:=Item_List[ItemPtr^.Item_Num];
               Character.No_of_Items:=Character.No_of_Items + 1;
               Num:=Character.No_of_Items;
               Character.Item[Num].Item_Num:=ItemPtr^.Item_Num;
               Character.Item[Num].Ident:=ItemPtr^.Identified;
               Character.Item[Num].Cursed:=Item.cursed;
               Character.Item[Num].isEquipped:=True;

               If (Character.Item[Num].Cursed) then
                  Begin { Cursed }
                     SMG$Put_Line (CampDisplay, 'Cursed!!!!');
                     Ring_Bell (CampDisplay,3);
                     Delay (2);
                  End;  { Cursed }
               Dispose (ItemPtr);  { Dispose of the node }
            End { Item selected }
      End { One usable }
End;  { Select Item }

(******************************************************************************)

Function Not_stuck (Character: Character_Type; Kind: Item_Type): Boolean;

{ This function will determine if can select an item of type KIND, or if he is stuck with the one he has, e.g. cursed item }

Var
   Item: Integer;
   Temp: Boolean;
   Character_Item: Item_Record;

Begin { Not Stuck }
   If (Character.No_of_items=0) then  { If the character has NO items... }
      Begin
         Not_Stuck:=True              { He can choose one }
      End
   Else
      Begin { Has items }
         Temp:=True;                  { So far, he can choose one }
         For Item:=1 to Character.No_Of_Items do  { For each item }
            Begin
               Character_Item:=Item_List[Character.Item[Item].Item_Num];
               If (Character_Item.Kind=Kind) then  { If of the right type }
                  Begin
                     Temp:=Temp AND Not(Character.Item[Item].Cursed);  { Cursed? }
                  End
            End;
         Not_Stuck:=Temp;  { Return the function value }
      End;  { Has items }
End;  { Not Stuck }

(******************************************************************************)

Procedure Store_Item (Item_Ptr: ItemSet; Var Member: Party_Type; Party_Size: Integer);

{ This procedure will attempt to give the item pointed to by ITEM_TR to
  its owner.  If the owner has too many items, the procedure will find someone
  who has room and give it to him/her.  It bears mentioning that there MUST
  be room for the item SOMEWHERE in the party since all the items where taken
  from the party, and new items can be added during the equip. }

Var
   CharNo: Integer;
   Done: Boolean;

Begin { Store Item }
   Done:=False; { We haven't found a place yet }
   CharNo:=Item_Ptr^.Owner_Number;  { Get the person who owns the item }
   Repeat
      If (Member[CharNo].No_of_items<8) then  { If this person has room... }
         Begin { Has room }

                { Give the item to this person }

            Member[CharNo].No_of_Items:=Member[CharNo].No_of_Items + 1;
            With Member[CharNo].Item[Member[CharNo].No_of_Items] do
               Begin
                  Ident:=Item_Ptr^.Identified;
                  Cursed:=False;
                  isEquipped:=False;
                  Item_Num:=Item_Ptr^.Item_Num;
               End;
            Done:=True; { We have found a place }
         End  { Has room }
      Else
         Begin { Doesn't have room }
            CharNo:=CharNo + 1;  { Go to next character }
            If (CharNo>Party_Size) then
               Begin { Loop around to beginning }
                  CharNo:=1;
               End;  { Loop around to beginning }
         End;  { Doesn't have room }
   Until Done;  { Do this until we've found a place for the item }
End;  { Store Item }

(******************************************************************************)

Procedure Redistribute_Remainders (Var Member: Party_Type;  Party_Size: Integer;  Var Choices: Item_Pool);

{ This procedure will take the remaining items, the ones not selected, and return them to their owners (if possible) or to someone
  else (if the owner doesn't have room) }

Var
   Kind: Item_Type;
   Traveller: ItemSet;
   Temp: ItemSet;

Begin { Redistribute Remainders }
   For Kind:=Weapon to cloak do  { For each item list... }
      Begin { For each item kind }
         Traveller:=Choices[Kind];
         While (Traveller<>Nil) do  { For each item IN the list... }
            Begin { Traverse list }
               Store_Item (Traveller,Member,Party_Size);  { Give the item to a character }
               Temp:=Traveller;
               Traveller:=Traveller^.Next_Item; { Move to next node }
               Dispose (Temp);  { Delete this node }
            End;
         Choices[Kind]:=Nil; { Kill the list }
      End;  { For each item kind }
End;  { Redistribute Remainders }

(******************************************************************************)

Function Wants_To_Invoke (Character: Character_Type; Item_No: Integer): Boolean;

{ This function will ask the player if he or she wishes to invoke the special power of CHARACTER's ITEM_NOth item.  If the
  player responds with a 'Y' then the function value is TRUE, if the response is 'N' then the value is FALSE. }

Var
   T: Line;
   Item: Item_Record;

Begin { Wants_To_Invoke }
   Item:=Item_List[Character.Item[Item_No].Item_Num];
   T:=Character.Name
       +', dost though wish to invoke the '
       +'special power of thine ';
   If (Character.Item[Item_No].Ident) then
      Begin
         T:=T + Item.True_Name;
      End
   Else
      Begin
         T:=T + Item.Name;
      End;
   T:=T+'?';

   { Print the question }

   SMG$Begin_Display_Update (CampDisplay);
   SMG$Erase_Display (CampDisplay);
   SMG$Put_Chars (CampDisplay,T,1,39-(t.length div 2));
   SMG$End_Display_Update (CampDisplay);

   { The function value is returned }

   Wants_to_Invoke:=(Yes_or_No='Y');
End;  { Wants to Invoke ]

(******************************************************************************)

Procedure Special_Occurances (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type);

{ This procedure will check each item is equipped with to see if it has a possible special occurance.  If so, it will
  ask the character if he/she wishes to invoke it, and handle it if he/she does. }

Var
   Character: Character_Type;
   Character_No,Item_No: Integer;
   New_Item,Item: Item_Record;

[External]Procedure Special_Occurance (Var Character: Character_Type; Number: Integer);External;

Begin { Special Occurances }
   For Character_No:=1 to Current_party_Size do  { For each character... }
      Begin { For each character }
         Character:=Member[Character_No];  { Get the character }
         For Item_No:=1 to Character.No_of_items do  { For each item owned... }
            Begin

               { If the item is equipped and has a special occurance number, it can be invoked. }

               Item:=Item_List[Character.Item[Item_No].Item_Num];  { Make a copy of the item }

               If (Item.Special_Occurance_No>0) and (Character.Item[Item_No].isEquipped) then
                 Begin { Can be invoked }
                    If Wants_to_Invoke (Character,Item_No) then  { Will he invoke? }
                       Begin { Character invokes item }

                          { If the item is invoked, handle it... }

                          Special_Occurance(Character,Item.Special_Occurance_No);

                          { Check to see if the item makes it break percentage. If it does, change it into whatever it's supposed to
                            turn into. }

                            If Made_Roll (Item.Percentage_Breaks) then
                               Begin { Item Breaks }
                                  New_Item:=Item_List[Item.Turns_Into];
                                  With Character.Item[Item_No] do
                                     Begin { Change Item }
                                        isEquipped:=False;  { No longer equipped }
                                        Ident:=False;  { No longer knows what it is }
                                        Cursed:=False;  { Not cursed }
                                        Item_Num:=Item.Turns_Into;
                                        Usable:=(Character.Class in New_Item.Usable_By) or (Character.PreviousClass in New_Item.Usable_By);
                                     End;  { Change item }
                               End;  { Item Breaks }
                       End;  { Character invokes item }
                    Member[Character_No]:=Character;  { Return updated character }
                 End;  { Can be invoked }
            End;
      End; { For each character }
End;  { Special Occurances }

(******************************************************************************)

Procedure Update_Roster (Var Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Var
   Character: Integer;

[External]Function  Regenerates (Character: Character_Type; PosZ:integer:=0): Integer;external;
[External]Function  Compute_AC (Character: Character_Type; PosZ:integer:=0): Integer;external;

Begin
   For Character:=1 to Current_Party_Size do
      Begin
         Member[Character].Regenerates:=Regenerates(Member[Character],PosZ);
         Member[Character].Armor_Class:=Compute_AC (Member[Character],PosZ);
      End;
End;

(******************************************************************************)

Procedure Equip_Party (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type; Party_Size: Integer);

{ This procedure will allow an entire party to pool their items, and equip themselves from the pool.  When the equip is done,
  unselected items will be distributed to the person who owns it, or, if there's no room, to someone else with room }

Var
   Choices: Item_Pool; { A list for each item type }
   Kind: Item_Type;
   Person: Integer;

Begin { Equip Party }
   { Collect all the items into lists }

   Pool_Items (Member,Party_Size,Choices);

   { Have each player select an item for each item class (Sword,Armor, etc) available.  If the player is stuck with a particular
     item, such as the case when he or she has a cursed item, he or she can not choose another in its place. }

   For Kind:=Weapon to cloak do  { For each item type... }
      If Kind<>Scroll then  { You can't equip a scroll }
         For Person:=1 to Current_Party_Size do  { For each character }
            If Member[Person].No_of_items<8 then
               If Not_Stuck (Member[Person],Kind) and (Choices[Kind]<>Nil) then
                  Select_Item (Member[Person],Kind,Choices[Kind]);

   { Give back whatever's not selected }

   Redistribute_Remainders (Member,Party_Size,Choices);

   { Check items for special powers }

   Special_Occurances (Member, Current_Party_Size);

   { Recompute Armor Classes and Regeneration }

   Update_Roster (Member,Party_Size);
End;  { Equip Party }

(******************************************************************************)

Function Party_Has_Items (Member: Party_Type; Party_Size: Integer):Boolean;

Var
   Char_Num: Integer;

Begin
   Party_Has_Items:=False;
   For Char_Num:=1 to Party_Size do
      If Member[Char_Num].No_of_items>0 then
          Party_Has_Items:=True;
End;

(******************************************************************************)

Procedure Print_Character_Line_Aux (CharNo: Integer; Member: Party_Type;  Party_Size: Integer);

Var
  AlignName: [External]Array [Align_Type] of Packed Array [1..7] of char;
  StatusName: [External]Array [Status_Type] of Varying [14] of char;
  ClassName: [External]Array [Class_Type] of Varying [13] of char;

Begin
  If CharNo<=Party_Size then { If there is a CHARNOth Person }
     Begin { Print status line }
        SMG$Put_Chars (CampDisplay,
            String(CharNo,1),,,1);
        SMG$Put_Chars (CampDisplay,
            '  '
            +Pad(Member[CharNo].Name,' ',22));
        SMG$Put_Chars (CampDisplay,
            String(Member[CharNo].Level,3));
        SMG$Put_Chars (CampDisplay,
            '     '
            +AlignName[member[CharNo].Alignment][1]);
        SMG$Put_Chars (CampDisplay,
            '-'
            +Pad(ClassName[member[CharNo].Class],' ',14));
        SMG$Put_Chars (CampDisplay,
            String(Member[CharNo].Armor_Class,3));
        SMG$Put_Chars (CampDisplay,
            '   '
            +String(Member[CharNo].Curr_HP,5));
        If Alive(Member[CharNo]) then
           If (Member[CharNo].Regenerates>0) then
              SMG$Put_Chars (CampDisplay,
                  '+')
           Else
              If (Member[CharNo].Regenerates<0) then
                 SMG$Put_Chars (CampDisplay,
                     '-')
        Else
           SMG$Put_Chars (CampDisplay,
               ' ');
        If Member[CharNo].Status<>Healthy then
           SMG$Put_Chars (CampDisplay,
               '    '
               +StatusName[Member[CharNo].Status])
        Else
           SMG$Put_Chars (CampDisplay,
               '    '
               +String(Member[CharNo].Max_HP,5));
     End;  { Print Status line }
End;

(******************************************************************************)

Procedure Print_Character_Line (CharNo: Integer; Member: Party_Type;  Party_Size: Integer);

{ This procedure will print the CHARNOth party member's statistics int eh CHARNO + 3 row. }

Begin { Print Character Line }
   SMG$SET_CURSOR_ABS (CampDisplay,CharNo + 3,2);
   Print_Character_Line_Aux (CharNo,Member,Party_Size);
End;  { Print Character Line }

(******************************************************************************)

Procedure Print_Camp_Roster (Member: Party_Type; Party_Size:Integer);

{ This procedure will print out the roster of the adventuring party by printing a heading labeling the columns, and then printing
  the status line of each character in the party. }

Const
   Roster_Heading = ' #  Character Name      Level     Class            AC    Hits   Status';

Var
   Character: 1..6;

Begin { Print Roster }
  SMG$Erase_Display (CampDisplay);
  SMG$Put_Chars (CampDisplay,Roster_Heading,3,1);
  For Character:=1 to 6 do
     Begin
        Print_Character_Line (Character,Member,Party_Size);
     End;
End;  { Print Roster }

(******************************************************************************)

Procedure Print_Lower_Character_Line (CharNo: Integer;  Member: Party_Type;  Party_Size: Integer);

{ This procedure will print out the roster of the adventuring party by printing a heading labeling the columns, and then printing
  the status line of each character in the party. }

Begin { Print_Lower_Character_Line }
  SMG$SET_CURSOR_ABS (CampDisplay,CharNo + 15,2);
  Print_Character_Line_Aux (CharNo,Member,Party_Size);
End;  { Print_Lower_Character_Line }

(******************************************************************************)

Procedure Reorder_Party (Var Member: Party_Type; Party_Size: Integer; Current_Party_Size: Integer);

{ This procedure allows the player to update the marching order of the party. }

Var
   Options: Char_Set;
   Number,Position: 1..6;
   Temp_Party: Party_Type;
   T: Line;

Begin { Reorder party }
   Options:=['1'..CHR(Party_Size + ZeroOrd)];  { Characters that can be selected }

   { This will ask for the position of all but one character.  The position of the last character is not asked because it will simply
     go in the only remaining spot. }

   SMG$Erase_Display (CampDisplay,12,1);
   For Position:=1 to Party_size-1 do    { For each position in the new party }
      Begin { Each Position }
         T:='Choose character for position #'
             +String(Position,1);
         SMG$Put_Chars (CampDisplay,T,13,2,1);
         Number:=Ord (Make_Choice(Options))-ZeroOrd;  { get the character number }
         Options:=Options-[CHR(Number + ZeroOrd)];  { No longer a choice now }
         Temp_Party[Position]:=Member[Number];
         Print_Lower_Character_Line (Position,Temp_Party,Party_Size);
      End;  { Each position }

   { This following section will place the remaining character last in order }

   For Position:=1 to Party_Size do
      If CHR(Position + ZeroOrd) in Options then { If this is the remaining char. }
         Temp_Party[Party_Size]:=Member[Position];  { Add him... }
   Print_Lower_Character_Line (Party_Size,Temp_Party,Party_Size);  { ... and print him }
   Delay (1/2);
   Member:=Temp_Party;  { Copy the new party over the current party }

   { Move dead characters to rear again }

   Dead_Characters (Member,Current_Party_Size,Party_Size);
End;  { Reorder party }

(******************************************************************************)

Procedure View_Character (Character_Number: Integer; Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                                  Party_Size: Integer);

{ This procedure allows a player to view his/her character via PRINT_CHARACTER.  A call to DEAD_CHARACTERS is made afterwords, since
  the number of living characters may increase or decrease depending on what happens in PRINT_CHARACTER. }

[External]Procedure Print_Character (Var Party: Party_Type;  Party_Size: Integer;  Var Characters: Character_Type;
                                     Var Leave_Maze: Boolean; Automatic: Boolean:=False);external;

Begin { View Character }

   { Put the necessary display on }

   SMG$Erase_Display (ScreenDisplay);
   SMG$Begin_Pasteboard_Update (Pasteboard);
   SMG$Paste_Virtual_Display (ScreenDisplay,Pasteboard,1,1);

   { Call Print_Character to display the character }

   Print_Character (Member,Party_Size,Member[Character_Number],Leave_Maze,Automatic:=False);
   { SMG$END_PASTEBOARD_UPDATE is in PRINT_CHARACTER }

   { Update the party }

   Dead_Characters (Member,Current_Party_Size,Party_Size);
   Update_Roster (Member,Current_Party_Size);
   Print_Camp_Roster (Member,Party_Size);  { Print the roster }

   { Remove the SCREENDISPLAY }

   SMG$Unpaste_Virtual_Display (ScreenDisplay,Pasteboard);
   SMG$Erase_Display (ScreenDisplay);
End;  { View Character }

(******************************************************************************)

Procedure Print_Camp_Options (Member: Party_Type; Party_Size: Integer);

{ This procedure prints the party's options }

Var
   T: Varying [390] of Char;

Begin { Print Camp Options }
   T:='Thou may ';
   If Not Game_Saved then T:=T+'S)ave the game, ';  { only one saved game allowed }
   T:=T+'R)eorder party, ';
   If Party_Has_Items (Member,Party_Size) then T:=T+'E)quip party, ';
   T:=T+'#) to inspect a party member, or L)eave the camp.';
   SMG$Set_Cursor_ABS (CampDisplay,13,1);
   SMG$Put_Line (CampDisplay,T,Wrap_Flag:=SMG$M_WRAP_WORD);
End;  { Print Camp Options }

(******************************************************************************)

Procedure Camp_Sleep (Var Member: Party_Type; Current_Party_Size: Integer);

{ This procedure checks to see if any days have gone by.  If so, the rest will benefit the character in terms of one hit point per
  half-day, and a restoration of spells every half day.  }

Var
   Slot: Integer;
   Days: Integer;

Begin
   Days:=Trunc(Minute_Counter/100);
   For Slot:=1 to Current_Party_Size do
      Begin
         Member[Slot].Curr_HP:=Member[Slot].Curr_HP + Days;
         If Member[Slot].Curr_HP>Member[Slot].Max_HP then Member[Slot].Curr_HP:=Member[Slot].Max_HP;
         If Minute_Counter>(3*100) then Restore_Spells (Member[Slot]);
      End;
   Minute_Counter:=Minute_Counter-(100* (Trunc (Minute_Counter / 100)));
End;



(******************************************************************************)

Procedure Save_the_Game (Member: Party_Type;  Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                                 Var Auto_Save: Boolean;  Time_Delay: Integer);

{ This procedure will save the current game for use later }

Var
   Temp: Save_Record;
   Error: Boolean;

[External]Procedure ControlY;External;
[External]Procedure No_ControlY;External;

Begin { Save The Game }
   SMG$Set_Cursor_ABS (CampDisplay,21,25);
   SMG$Put_Line (CampDisplay,
       '* * * Saving the game * * *',0);

   { Record position and direction }

   Temp.PosX:=PosX;  Temp.PosY:=PosY;  Temp.PosZ:=PosZ;
   Temp.Direction:=Direction;

   Temp.Time_Delay:=Time_Delay;

   Temp.Spells_Casted:=Rounds_Left;  { What spells were in effect }

   { Save the current party }

   Temp.Party_Size:=Party_Size;
   Temp.Current_Size:=Current_Party_Size;
   Temp.Characters:=Member;

   { Save the current level of the dungeon }

   Temp.Current_Level:=Maze;

   { Write the save record to STONE_SAVE.DAT }

   No_ControlY;

   Error := Write_Save_File(Temp);

   ControlY;

   If Error then
      Error_Window ('Save')
   Else
      Begin

         { Update related flags }

         Game_Saved:=True;
         Auto_Save:=True;
         Auto_Load:=False;
      End;
End;

(******************************************************************************)

[Global]Procedure Camp (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                        Var Leave_Maze,Auto_Save: Boolean; Var Time_Delay: Integer);

{ This procedure allows the adventuring party to set up camp inside the maze, and perform such tasks as casting spells or re-
  ordering the party }

Var
   FirstTime: Boolean;
   Character_Number: 1..6;
   Choices: Set of Char;
   Answer: Char;

[External]Procedure Time_Effects (Position: Integer; Var Member: Party_Type; Party_Size: Integer);External;
[External]Function  Can_Play: [Volatile]Boolean;External;
[External]Procedure Backup_Party (Party: Party_Type; Party_Size: Integer);External;

Begin { Camp }
   If Minute_Counter>=100 then Camp_Sleep (Member,Current_Party_Size);  { Add the effects of sleep }
   Update_Roster (Member,Current_Party_Size);

       { Paste the necessary display onto the screen }

   SMG$Paste_Virtual_Display (CampDisplay,Pasteboard,2,2);

        { This is the first pass. When called, we are in a BEGIN_PASTEBOARD_UPDATE (set by caller) so we must END it on the first
          pass, but not on the following passes. }

   FirstTime:=True;
   Repeat
      Begin { CAMP Main Menu }
         If Not FirstTime then SMG$Begin_Display_Update (CampDisplay);
         Print_Camp_Roster (Member,Party_Size);  { Print the roster }
         Print_Camp_Options (Member,Party_Size); { Display the party's options }
         If Not FirstTime then  { If not first pass, we are in display batch }
            SMG$End_Display_Update (CampDisplay)  { So end it... }
         Else
            SMG$End_Pasteboard_Update (Pasteboard);
            { Otherwise, pasteboard batch }

         FirstTime:=False;  {Now we are starting the >= 2nd batch }
         Choices:=['1'..CHR(Party_Size + ZeroOrd),'R','L'];
         If Not Game_Saved then Choices:=Choices+['S'];
         If Party_Has_Items (Member,Party_Size) then Choices:=Choices+['E'];
         Answer:=Make_Choice (Choices);                                     { Get the player's choice }

         If Not Can_Play then Answer:='S';
         Case Answer of
            '1'..'6': View_Character (Ord(answer)-ZeroOrd,Member,Current_Party_Size,Party_Size);
                 'R': Reorder_Party (Member,Party_Size,Current_Party_Size);
                 'E': Equip_Party (Member,Current_Party_Size,Party_Size);
                 'S': Save_The_Game (Member,Current_Party_Size,Party_Size,Auto_Save,Time_Delay);
                 'L': ;
         End;  { Input case }
      End;  { Camp Main Menu }
   Until Auto_Save or Leave_Maze or (Answer='L');

   Party_Box (Member,Current_Party_Size,Party_Size,Leave_Maze);

   If Not Auto_Save then   { If not massive POP }
      For Character_Number:=Party_Size downto 1 do  { For each character... }
         Time_Effects (Character_Number,Member,Party_Size)     {  Age him/her }
   Else
      SMG$Paste_Virtual_Display (ScreenDisplay,Pasteboard,1,1);

   { Remove the display }

   Backup_Party (Member,Party_Size);
   SMG$Unpaste_Virtual_Display (CampDisplay,Pasteboard);
End;  { Camp }
End.  { Camp }

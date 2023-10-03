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
                 Item_Number:  Integer;      { Which item is it? }
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
           Current_Party-Size:=Current_Party_Size+1;  { Increment survivor count }
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
   Temp: ItemSet;

Begin { Delete }
   If List<> Nil then
      Begin { Not Nil }
         If List=Node then
            Begin
               List:=List^.Next_Item;
            End
         Else
            Begin
               Temp:=List^.Next_Item;
               Delete (Node, Temp);
               List^.Next_Item:=Temp;
            End;
      End;  { Not Nil }
End;  { Delete }

(******************************************************************************)

Procedure Print_Item_Node (Node: ItemSet; Choice_Num: Integer);

{ This procedure prints the name of the item pointed to by NODE.  It also gives the letter equivalent of CHOICE_NUM so that the
  user can select it. }

Var
   Item: Item_Record;

Begin { Print Item Node }
   Item:=Item_List[Node^.Item_Num];
   SMG$Put_Chars (CampDisplay,
       '['+CHR(Choice_Num+64)+']   ');
   If (Node^.Identified) then
      Begin
         SMG$Put_Line (CampDisplay,
             Item.True_Name);
      End
   Else
      Begin
         SMG$Put_Line (CampDisplay,
            '?'+Item.Name);
      End;
End;  { Print Item Node }

(******************************************************************************)

Function Choose_From_List (Class,Class1: Class_Type; Align: Align_Type; Var Choice_List: ItemSet): ItemSet;

{ This function will display a list of viable choices for a character, and return the one (if any) he selects.  If nothing is
  chosen, the value NUL is returned, otherwise the pointer to the selected item_node is returned. }

Var
   Position,Chosen: Integer;
   TempPtr,Temp: ItemSet;
   Options: Set of char;
   Answer: Char;
   Item: Item_Record;

Begin { Choose from List }
   Options:=[CHR(113)];  { So far, no options }
   Position:=0;
   TempPtr:=Choice_list;  { The temporary pointer points to beginning of list }
   While (TmpPtr<>Nil) do  { While there are items on list }
      Begin { For each item }
         Item:=Item_List[TempPtr^.Item_Num];
         If (((Class in Item.Usable_By) or (Class1 in Item.Usable_By)) and  { if the item is usable }
            (((Align=Item.Alignment) or (Item.Alignment=NoAlign))) then
            Begin { Usable item }
               Position:=Position+1;                 { Increment the line counter }
               Print_Item_Node (TempPtr,Position);  { Print the choice }
               Options:=Options+[CHR(Position+64)]; { Add it to the set of choices }
            End;  { Usable item }
         TempPtr:=TempPtr^.Next_Item;           { Go to next item }
      End;  { For each item }
   SMG$Put_Line (CampDisplay,
       'Which?',0);
   SMG$End_Display_Update (CampDisplay);
   Answer:=Make_Choice (Options);               { Get the choice }
   If (Answer<>CHR (13)) then   { If the player chose an item... }
      Begin { Item chosen }
         Chosen:=Ord(Answer)-64;  { Find the number desired }

         Position:=0;
         TempPtr:=Choice_List;  Temp:=Nil;
         While (TempPtr<>Nil) and (Position>Chosen) do  { Until found }
            Begin { For each item }
               Item:=Item_List[TempPtr^.Item_Num];  { Get the item }
               If (((Class in Item.Usable_By) or (Class1 in Item.Usable_By)) and  { If the item is usable }
                  (((Align=Item.Alignment) or (Item.Alignment=NoAlign))) then
                     Begin
                        Position:=Position+1;  { Advance the counter }
                        Temp:=TempPtr;         { Get the current ptr. }
                     End;
               TempPtr:=TempPtr^.Next_Item;          { Go to next item }
            End;  { For each item }
         If (Temp<>Nil) then
            Begin
               Delete (Temp,Choice_List);  { delete the node from the list }
            End;
      End { Item chosen }
   Else
      Begin
         Temp:=Nil;  { Otherwise, return Nil }
      End;
   Choose_From_List:=Temp;
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
   While ((Not At_LeastOne) and (Traveller<>Nil)) do
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
         SMG$Begin_Display_Update (CampDisplay);
         SMG$Erase_Display (CampDisplay);
         T:='[RETURN] for none';
         SMG$Put_Chars (CampDisplay,1,23,39-(t.length div 2));
         T:='Please select a '
             +Item_Name[Kind]
             +' for '
             +Character.Name;
         SMG$Set_Cursor_ABS (CampDisplay,1,39-(t.length div 2));
         SMG$Put_Line (CampDisplay,T,1);
         { SMG$END_DISPLAY_UPDATE (CAMPDISPLAY) in Choose_from_list }

         { Get the item chosen }

         ItemPtr:=Choose_From_List(Character.Class,Character.PreviousClass,Character.Alignment,Choices);
         If (ItemPtr<>Nil) then  { If there WAS an item chosen }
            Begin { Item selected }

                  { Add the item to the character's collection }

               Item:=Item_List[ItemPtr^.Item_Num];
               Character.No_of_Items:=Character.No_of_Items+1;
               Num:=Character.No_of_Items;
               Character.Item[Num].Item_Num:=ItemPtr^.Item_Num;
               Character.Item[Num].Ident:=ItemPtr^.Identified;
               Character.Item[Num].Cursed:=Item.cursed;
               Character.Item[Num].Equipted:=True;

                  { Check to see if it's cursed }

               If (Character.Item[Num].Cursed) then
                  Begin { Cursed }
                     SMG$Put_Line (CampDisplay,
                         'Cursed!!!!');
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
               Character_Item:=Item_List[Character.Item].Item_Num];
               If (Character_Item.Kind=Kind) then  { If of the right type }}
                  Begin
                     Temp:=Temp AND Not(Character.Item[Item].Cursed);  { Cursed? }
                  End
            End;
         Not_Stuck:=Temp;  { Return the function value }
      End;  { Has items }
End;  { Not Stuck }

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Camp (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                        Var Leave_Maze,Auto_Save: Boolean; Var Time_Delay: Integer);

Begin { Camp }

{ TODO: Enter this code }

End;  { Camp }
End.  { Camp }

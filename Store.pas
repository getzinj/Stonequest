(*
  Copyright (C) 2024 Jeffrey Getzin.
  Licensed under the GNU General Public License v3.0 with additional terms.
  See the LICENSE file in the repository root for details.
*)


[Inherit ('Types','SYS$LIBRARY:STARLET','SMGRTL')]Module Trading_Post;

Type
   Choice_List = Array [1..10] of Item_Record;

Var
   BottomDisplay: [External]Unsigned;
   Item_List:     [External]List_of_Items;


(******************************************************************************)
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '):Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Function Can_Play: [Volatile]Boolean;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
[External]Procedure increment_item_quantity(slot: integer);External;
[External]Procedure Close_Quantity_File;External;
(******************************************************************************)

Function Item_Has_Value (Item: Item_Record): Boolean;

Var
   Temp: Boolean;

Begin
   Temp:=False;
   Temp:=Temp or (Item.Special_Occurance_No<>0);
   Temp:=Temp or (Item.Spell_Cast<>NoSp);
   Temp:=Temp or (Item.Regenerates>0);
   Temp:=Temp or (Item.Protects_Against<>[]);
   Temp:=Temp or (Item.Resists<>[]);
   Temp:=Temp or (Item.Versus<>[]);
   Temp:=Temp or (Item.Damage.X + Item.Damage.Z>0);
   Temp:=Temp or (Item.Additional_Attacks>0);
   Temp:=Temp or (Item.Plus_to_Hit>0);
   Temp:=Temp or (Item.AC_plus<0);
   Temp:=Temp or (Item.autoKill);
   Temp:=Temp AND (Item.Usable_By<>[]);
   Item_Has_Value:=Temp;
End;

(******************************************************************************)

Procedure Print_Message (Message_Text: Line);

Begin
   SMG$Begin_Display_Update (BottomDisplay);
   SMG$Erase_Display (BottomDisplay,,1);
   SMG$Set_Cursor_ABS (BottomDisplay,,40-(Message_Text.length div 2));
   SMG$Put_Line (BottomDisplay,Message_Text,0);
   SMG$End_Display_Update (BottomDisplay);
End;

(******************************************************************************)

Procedure Attach_Item_to_Character (Item: Item_Record;  Var Character: Character_Type);

Begin
   Character.No_of_Items:=Character.No_of_Items + 1;
   Character.Item[Character.No_of_Items].Item_Num:=Item.Item_Number;
   Character.Item[Character.No_of_Items].Ident:=True;
   Character.Item[Character.No_of_Items].Usable:=(Character.Class in Item.Usable_By) or (Character.PreviousClass in Item.Usable_By);
   Character.Item[Character.No_of_Items].Cursed:=False;
   Character.Item[Character.No_of_Items].isEquipped:=False;
   Character.Items_Seen[Character.No_of_Items]:=True;
End;

(******************************************************************************)

Procedure Its_Been_a_Pleasure;

Begin
   Print_Message ('* * * It''s a pleasure doing business with thee * * *');
   Delay (2);
End;

(******************************************************************************)
[External]Procedure Access_Item_Quantity_Record (N: Integer);External;
[External]Function Item_Count (Item_Number: Integer): [Volatile]Integer;External;
[External]Procedure Decrement_Quantity (slot: Integer);External;
[External]Function Get_Store_Quantity(slot: Integer): Integer;External;
[External]Procedure Open_Quantity_File_For_Write;External;
(******************************************************************************)

Procedure Get_Item (Var Character: Character_Type; Item: Item_Record);

{ Gives an item to a character. It is assumed he/she can afford it and has room. }

Begin
   Character.Gold:=Max(Character.Gold-Item.Current_Value,0);

   Attach_Item_to_Character (Item,Character);

   If Get_Store_Quantity(Item.Item_Number) = 1 then
      Begin
         Print_Message ('* * * That was the last one we had in stock * * *');
         Delay(1);
      End
   Else if Not(Character.Item[Character.No_of_Items].Usable) then
      Begin
        Print_Message ('* * * It''s thy money... * * *');
        Delay(1);
      End
   Else
      Its_Been_a_Pleasure;

   { If the item is not in unlimited supply, decrement the amount available }

   Decrement_Quantity(item.Item_Number);
End;

(******************************************************************************)

Procedure Too_Expensive;

Begin { Too Expensive }
   Print_Message ('* * * Thou canst not afford it! * * *');
   Ring_Bell (BottomDisplay);
   Delay (2);
End;

(******************************************************************************)

Procedure Sold_Out;

Begin
   Print_Message ('* * * Sorry, we just sold our last one! * * *');
   Delay(2);
End;

(******************************************************************************)

Procedure No_Room;

Begin
   Print_Message ('* * * Thou canst not carry any more! * * *');
   Delay(2);
End;

(******************************************************************************)

Procedure Add_Item (Item: Item_Record; Var Character: Character_Type);

{ This procedure assumes AMOUNTFILE has been oppened for DIRECT access. TODO: Move to Files.pas }

Begin
   If Get_Store_Quantity(Item.Item_Number) = 0 then
      Sold_Out
   Else if Character.Gold<Item.Current_Value then
      Too_Expensive
   Else If Character.No_of_Items=8 then
      No_Room
   Else
      Get_Item (Character,Item);
End;


(******************************************************************************)

Procedure Page_Backwards (Var First: Integer; Amount: Integer:=10);

Var
   Temp: Integer;

Begin
   Temp:=0;
   Repeat
      Begin
         First:=First-1;
         If First<1 then
            First:=249;
         If Item_Count(First)<>0
            then Temp:=Temp + 1;
      End;
   Until Temp=Amount;  { TODO: If there aren't ten items in the store, this will loop forever. }
End;

(******************************************************************************)

Procedure Purchase_Item (Choices: Choice_List; Var Buyer: Character_Type);

Var
   Answer: Char;
   INum: Integer;

Begin
   SMG$Put_Line (BottomDisplay,'Purchase which item?',0);
   Answer:=Make_Choice (['A'..'J',' ',CHR(13)]);
   If Buyer.Status=Insane then
      Answer:=CHR(Roll_Die(10)+64);
   If Not (Answer in [' ',CHR(13)]) then
      Begin
         INum:=Ord(Answer)-64;

         Access_Item_Quantity_Record (Choices[INum].Item_Number);

         If Not ((Buyer.Class in Choices[INum].Usable_By) or (Buyer.PreviousClass in Choices[INum].Usable_By)) then
            Begin
               SMG$Put_Line (BottomDisplay,'Unusable item. Confirm purchase? (Y/N)',0);
               If Yes_or_No='Y' then
                  Add_Item(Choices[INum],Buyer);
            End
         Else
            Add_Item (Choices[INum],Buyer);
      End;
End;

(******************************************************************************)

Procedure Print_List (Choices: Choice_List; Buyer: Character_Type);

Var
   Loop: Integer;

Begin
   For Loop:=1 to 10 do { TODO: Use a constant }
      Begin
         SMG$Put_Chars (BottomDisplay,'['+CHR(Loop + 64)+']    '+Pad(Choices[Loop].True_Name,' ',20)+'  ');
         SMG$Put_Chars (BottomDisplay,String(Choices[Loop].Current_Value,12)+' GP');
         If Not ((Buyer.Class in Choices[Loop].Usable_By) or (Buyer.PreviousClass in Choices[Loop].Usable_By)) then
            SMG$Put_Chars (BottomDisplay,' (Unusable)');
         SMG$Put_Line (BottomDisplay,'');
      End;
   SMG$Put_Line (BottomDisplay,'Thou hast '+String(Buyer.Gold)+' GP');
   SMG$Put_Line (BottomDisplay,'F)orward, B)ack, P)urchase, E)xit',0);
End;

(******************************************************************************)

Function Compute_Items_on_Page (First: Integer; Var Choices: Choice_List): Integer;

Var
   Last,Loop: Integer;

Begin
   Last:=First;
   For Loop:=1 to 10 do
      Begin
         While (Item_Count(Last)=0) or Not(Item_Has_Value(Item_List[Last])) do
            Begin
               Last:=Last + 1;
               If Last=450 then Last:=1; { TODO: This may be a bug. I think 450 is a valid index }
            End;
         Choices[Loop]:=Item_List[Last];
         Last:=Last + 1;
         If Last>249 then  { TODO: These two constants---450 and 249---seem confusing to me. Is 450 the maximum item in the item list and 249 is the maximum number of items *in the store*? }
            Last:=1;
      End;
   Compute_Items_On_Page:=Last;
End;

(******************************************************************************)

Procedure Buy_Item (Var Buyer: Character_Type);

Var
   First,Last: Integer;
   Answer: Char;
   Choices: Choice_List;

Begin
   First:=1;  Choices:=Zero;

   Open_Quantity_File_For_Write;

   Repeat
      Begin
         { For a list of 10 items in the store for sale }

         Last:=Compute_Items_on_Page (First,Choices);

         SMG$Begin_Display_Update (BottomDisplay);
         SMG$Erase_Display (BottomDisplay);
         Print_List (Choices,Buyer);
         SMG$End_Display_Update (BottomDisplay);

         Answer:=Make_Choice (['B','F','P','E']);

         Case Answer of
            'B': Page_Backwards (First);
            'F': First:=Item_List[Last].Item_Number;  { TODO: Is this correct? Shouldn't first = last? }
            'P': Purchase_Item (Choices,Buyer);
            'E': ;
         End;
      End;
   Until (Answer='E');

   Close_Quantity_File;
End;

(******************************************************************************)

Procedure Print_Sale_Items (Seller: Character_Type; NumItems: Integer;  Var Options,Dont_Want: Char_Set);

Var
   TempItem1: Item_Record;
   Current_Value,Loop: Integer;
   T: Line;

Begin
   For Loop:=1 to NumItems do
      Begin
         Options:=Options+[CHR(Loop + 64)];
         T:=T+'['+CHR(Loop + 64)+']  ';
         If Seller.Item[Loop].Cursed then
            T:=T+'-'
         Else if Seller.Item[Loop].isEquipped then
            T:=T+'*'
         Else if Not Seller.Item[Loop].Ident then
            T:=T+'?'
         Else
            T:=T+' ';

         TempItem1:=Item_List[Seller.Item[Loop].Item_Num];
         Current_Value:=TempItem1.Current_Value;

         If (Seller.Item[Loop].Ident) and not (TempItem1.Cursed) and Item_Has_Value(TempItem1) then
            Begin
               T:=T + Pad(TempItem1.True_Name,' ',20)+'   '+String (Current_Value div 2,12)+' GP';
               SMG$Put_Line (BottomDisplay, T);
            End
         Else
            Begin
               Dont_Want:=Dont_Want+[CHR(Loop + 64)];
               If (Not(Seller.Item[Loop].Ident)) then
                  T:=T + Pad(TempItem1.Name,' ',20)
               Else
                  T:=T + Pad(TempItem1.True_Name,' ',20);
               T:=T+'         '+String(0,7)+' GP';
               SMG$Put_Line (BottomDisplay,T);
            End;
      End;

   SMG$Set_Cursor_ABS (BottomDisplay,11,1);
   SMG$Put_Line (BottomDisplay,'Thou has '+String(Seller.Gold)+' GP');
   SMG$Put_Line (BottomDisplay,'Sell which item?');
   SMG$End_Display_Update (BottomDisplay);
End;

(******************************************************************************)

Procedure Sell_Items (Var Seller: Character_Type;  Var NumItems: Integer; Var Answer: Char);

Var
   Current_Value,Num,Loop: Integer;
   Options,Dont_Want: Char_Set;
   TempItem: Item_Record;

Begin
   Options:=[CHR(13),CHR(32)];  Dont_Want:=[];

   Print_Sale_Items (Seller,NumItems,Options,Dont_Want);

   Answer:=Make_Choice (Options);
   If Not (Answer in [CHR(13),CHR(32)]) then { TODO: This code seems suspect. Double-check source in printout. }
      Begin
         Num:=ORD(Answer)-64;
         TempItem:=Item_List[Seller.Item[Num].Item_Num];
         Current_Value:=TempItem.Current_Value;

         If Num=NumItems then
            NumItems:=NumItems-1
         Else
            Begin
               For Loop:=Num to NumItems-1 do
                  Seller.Item[Loop]:=Seller.Item[Loop + 1];
               NumItems:=NumItems-1;
            End;

         increment_item_quantity(TempItem.Item_Number);

         Seller.Gold:=Min(Seller.Gold+(Current_Value div 2),MaxInt);
         Its_Been_A_Pleasure;
      End
   Else
      Begin
         Print_Message ('* * * We''re not interested in that! * * *');
         Delay (2);
      End;
End;

(******************************************************************************)

Procedure Sell_Item (Var Seller: Character_Type);

Var
  NumItems: Integer;
  Answer: Char;

Begin
   Open_Quantity_File_For_Write;

   Repeat
      Begin
         SMG$Begin_Display_Update (BottomDisplay);
         SMG$Erase_Display (BottomDisplay);
         SMG$Set_Cursor_ABS (BottomDisplay,2,1);
         NumItems:=Seller.No_of_Items;
         If NumItems<>0 then
            Begin
               Sell_Items (Seller,NumItems,Answer);
               Seller.No_of_Items:=NumItems;
            End
         Else
            Begin
               Answer:=CHR(13);
               SMG$End_Display_Update (BottomDisplay);
            End;
      End;
   Until Answer in [CHR(13),CHR(32)];

   Close_Quantity_File;
End;

(******************************************************************************)

Procedure Print_Uncurse_Items (Customer: Character_Type; NumItems: Integer; Var Options: Char_Set);

Var
  Current_Value,Loop: Integer;
  T: Line;

Begin
   For Loop:=1 to NumItems do
      Begin
         Options:=Options+[CHR(Loop + 64)];
         T:='['+CHR(Loop + 64)+']  ';
         If Customer.Item[Loop].Cursed then
            T:=T+'-'
         Else
            T:=T+' ';

         If (Customer.Item[Loop].Ident) then
            T:=T + Pad(Item_List[Customer.Item[Loop].Item_Num].True_Name,' ',20)+'   '
         Else
            T:=T + Pad(Item_List[Customer.Item[Loop].Item_Num].Name,' ',20)+'   ';

         Current_Value:=Item_List[Customer.Item[Loop].Item_Num].Current_Value;

         If Not Customer.Item[Loop].Cursed then
            Current_Value:=0;

         T:=T + String(Current_Value)+' GP';
         SMG$Put_Line (BottomDisplay,T);
      End;

   SMG$Set_Cursor_ABS (BottomDisplay,11,1);
   SMG$Put_Line (BottomDisplay,'Thou hast '+String(Customer.Gold)+' GP');
   SMG$Put_Line (BottomDisplay,'Uncurse which item?',0);
   SMG$End_Display_Update (BottomDisplay);
End;

(******************************************************************************)

Procedure Uncurse_Items (Var Customer: Character_Type;  Var NumItems: Integer;  Var Answer: Char);

Var
   Options: Char_Set;
   Current_Value,Loop,Num: Integer;
   TempItem: Item_Record;

Begin
   Options:=[CHR(13),CHR(33)];

   Print_Uncurse_Items (Customer,NumItems,Options);

   Answer:=Make_Choice (Options);

   If Not(Answer in [CHR(13),CHR(32)]) then
      Begin
         Num:=ORD(Answer)-64;
         TempItem:=Item_List[Customer.Item[Num].Item_Num];
         Current_Value:=TempItem.Current_Value;

         If Customer.Gold>=Current_Value then
            Begin
               If Num<>NumItems then
                  For Loop:=Num to NumItems-1 do
                      Customer.Item[Loop]:=Customer.Item[Loop + 1];

               NumItems:=NumItems-1;

               Customer.Gold:=Max(Customer.Gold-Current_Value,0);

               Its_Been_a_Pleasure;
            End
         Else
            Too_Expensive;
      End;
End;

(******************************************************************************)

Procedure Uncurse_Item (Var Customer: Character_Type);

Var
  NumItems: Integer;
  Answer: Char;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (BottomDisplay);
         SMG$Erase_Display (BottomDisplay,1,1,12,80);
         SMG$Set_Cursor_ABS (BottomDisplay,2,1);

         NumItems:=Customer.No_of_Items;

         If NumItems<>0 then
            Begin
               Uncurse_Items (Customer,NumItems,Answer);
               Customer.No_of_Items:=NumItems;
            End
         Else
            Begin
               Answer:=CHR(13);
               SMG$End_Display_Update (BottomDisplay);
            End;
      End;
   Until Answer in [CHR(13),CHR(32)];
End;

(******************************************************************************)

Procedure Print_ID_Items (Customer: Character_Type);

Var
   Current_Value,NumItems,Loop: Integer;
   T: Line;

Begin
   NumItems:=Customer.No_of_Items;
   For Loop:=1 to NumItems do
      Begin
         T:='['+CHR(Loop + 64)+']  ';
         If Customer.Item[Loop].Cursed then
            T:=T+'-'
         Else if Customer.Item[Loop].Ident then
            T:=T+' '
         Else
            T:=T+'?';

         If (Customer.Item[Loop].Ident) then
            T:=T + Pad(Item_List[Customer.Item[Loop].Item_Num].True_Name,' ',21)
         Else
            T:=T + Pad(Item_List[Customer.Item[Loop].Item_Num].Name,' ',21);

         Current_Value:=Item_List[Customer.Item[Loop].Item_Num].Current_Value;

         If Customer.Item[Loop].Ident then
            Current_Value:=0;

         T:=T+'   '+String(Current_Value)+' GP';
         SMG$Put_Line (BottomDisplay,T);
      End;
   SMG$Set_Cursor_ABS (BottomDisplay,11,1);
   SMG$Put_Line (BottomDisplay,'Thou hast '+String(Customer.Gold)+' GP');
   SMG$Put_Line (BottomDisplay,'Identify which item?',0);
   SMG$End_Display_Update (BottomDisplay);
End;

(******************************************************************************)

Procedure Identify_Items (Var Customer: Character_Type;  Var Answer: Char);

Var
   Num,Current_Value,NumItems: Integer;
   Options: Char_Set;
   TempItem: Item_Record;

Begin
   NumItems:=Customer.No_of_Items;

   Print_ID_Items (Customer);

   Options:=['A'..CHR(NumItems + 64),CHR(13),CHR(32)];
   Answer:=Make_Choice (Options);

   If Not(Answer in [CHR(13),CHR(32)]) then
      Begin
         Num:=ORD(Answer)-64;
         TempItem:=Item_List[Customer.Item[Num].Item_Num];

         Current_Value:=TempItem.Current_Value;
         If Customer.Item[Num].Ident then
            Current_Value:=0;
         If Customer.Gold>=Current_Value then
            Begin
               Num:=Ord(Answer)-64;
               Customer.Item[Num].Ident:=True;
               Customer.Gold:=Max(Customer.Gold-Current_Value,0);
               If TempItem.Item_Number<251 then
                  Customer.Items_Seen[TempItem.Item_Number]:=True;
               Its_Been_a_Pleasure;
            End
         Else
            Too_Expensive;
      End;
End;

(******************************************************************************)

Procedure Identify_Item (Var Customer: Character_Type);

Var
   NumItems: Integer;
   Answer: Char;

Begin
   Repeat
      Begin
         SMG$Begin_Display_Update (BottomDisplay);
         SMG$Erase_Display (BottomDisplay, 1,1,12,80);
         SMG$Set_Cursor_ABS (BottomDisplay,2,1);
         NumItems:=Customer.No_of_Items;
         If NumItems<>0 then
            Identify_Items (Customer,Answer)
         Else
           Begin
             Answer:=CHR(13);
             SMG$End_Display_Update (BottomDisplay);
           End
      End
   Until Answer in [CHR(13),CHR(32)];
End;

(******************************************************************************)

Function Pool_Gold (Var Party: Party_Type;  Party_Size: Integer): Integer;

{ The function returns the total amount of gold the party has, and then clears each member's purse.  For this reason, it is only
  to be used in an assignment statement and never like the following:

           If Pool_Gold(Party,Party_Size)>0 then ...

  because this will clear the party's wealth, and not store it anywhere ... }

Var
   N,Sum: Integer;

Begin
  Sum:=0;
  For N:=1 to Party_Size do
     Begin
        Sum:=Sum + Party[N].Gold;
        Party[N].Gold:=0;
     End;
  If Sum<0 then Sum:=MaxInt;  { If overflow }
  Pool_Gold:=Sum;
End;

(******************************************************************************)

Procedure Print_Menu (Character: Character_Type);

Begin
   SMG$Begin_Display_Update (BottomDisplay);
   SMG$Erase_Display (BottomDisplay);
   SMG$Set_Cursor_ABS (BottomDisplay,2,1);
   SMG$Put_Line (BottomDisplay,'Welcome ',2);
   SMG$Put_Chars (BottomDisplay,Character.Name+'',2,9,0,1);
   SMG$Put_Line (BottomDisplay,', thou hast '+ String(Character.Gold)+' Gold Pieces.');
   SMG$Put_Line (BottomDisplay,'What wouldst thou like to do?',2);
   SMG$Put_Line (BottomDisplay,'[B]  Buy an item');
   SMG$Put_Line (BottomDisplay,'[S]  Sell an item');
   SMG$Put_Line (BottomDisplay,'[U]  Have an item uncursed');
   SMG$Put_Line (BottomDisplay,'[I]  Have an item identified');
   SMG$Put_Line (BottomDisplay,'[P]  Pool thine party''s gold');
   SMG$Put_Line (BottomDisplay,'[E]  Exit my shop',2);
   SMG$Put_Line (BottomDisplay,'Which?',0);
   SMG$End_Display_Update (BottomDisplay);
End;

(******************************************************************************)

Procedure Enter_Store (Var Character: Character_Type; Var Party: Party_Type;  Party_Size: Integer);

Var
   Answer: Char;

Begin
   Repeat
      Begin

          { Print a menu of available options }

          Print_Menu (Character);

          { Get Sophie's choice }

          Answer:=Make_Choice(['B','S','U','I','P','E']);

          { Handle it }

          Case Answer of
             'B': Buy_Item (Character);
             'S': Sell_Item (Character);
             'U': Uncurse_Item (Character);
             'I': Identify_Item (Character);
             'P': Character.Gold:=Pool_Gold (Party,Party_Size);
             'E': ;
          End;
      End;
   Until Answer='E';
End;

(******************************************************************************)

Procedure Print_Store_Heading (Party_Size: Integer);

Begin
   SMG$Begin_Display_Update (BottomDisplay);
   SMG$Erase_Display (BottomDisplay);
   SMG$Set_Cursor_ABS (BottomDisplay,2,1);
   SMG$Put_Line (BottomDisplay,'Welcome to Gisele''s Trading Post!  Who will enter and try my wares?');
   SMG$Put_Line (BottomDisplay,'(1-'+String(Party_Size,1)+', [RETURN] exists)',0);
   SMG$End_Display_Update (BottomDisplay);
End;

(******************************************************************************)

[Global]Procedure Run_Trading_Post (Var Party: Party_Type;  Party_Size: Integer);

Var
   Person: Integer;
   Location: [External]Place_Type;

[External]Function Pick_Character_Number (Party_Size: Integer; Current_Party_Size: Integer:=0;
                                          Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): [Volatile]Integer;External;

Begin { Run Trading Post }
   Person:=0;
   Repeat
      Begin
         Print_Store_Heading (Party_Size);

         If Not Can_Play then Person:=0
         Else                 Person:=Pick_Character_Number (Party_Size);

         If Person<>0 then
            If (Party[Person].Status in [Healthy,Poisoned,Insane]) then
               Enter_Store (Party[Person],Party,Party_Size);
      End;
   Until Person=0;
   Location:=InKyrn;
End;  { Run Trading Post }
End.  { Trading Post }

[Inherit ('Types','SYS$LIBRARY:STARLET','SMGRTL')]Module Trading_Post;

Type
   Choice_List = Array [1..10] of Item_Record;

Var
   BottomDisplay: [External]Unsigned;
   Item_List:     [External]List_of_Items;
   AmountFile:    [External]Number_File;  { TODO: Move to Files.pas }

(******************************************************************************)
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1; Time_Out_Char: Char:=' '):Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1; Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Function Can_Play: [Volatile]Boolean;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;

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
   Temp:=Temp or (Item.Damage.X+Item.Damage.Z>0);
   Temp:=Temp or (Item.Additional_Attacks>0);
   Temp:=Temp or (Item.Plus_to_Hit>0);
   Temp:=Temp or (Item.AC_plus<0);
   Temp:=Temp or (Item.Auto_Kill);
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
   Character.No_of_Items:=Character.No_of_Items+1;
   Character.Item[Character.No_of_Items].Item_Num:=Item.Item_Number;
   Character.Item[Character.No_of_Items].Ident:=True;
   Character.Item[Character.No_of_Items].Usable:=(Character.Class in Item.Usable_By) or (Character.PreviousClass in Item.Usable_By);
   Character.Item[Character.No_of_Items].Cursed:=False;
   Character.Item[Character.No_of_Items].Equipted:=False;
   Character.Items_Seen[Character.No_of_Items]:=True;
End;

(******************************************************************************)

Procedure Its_Been_a_Pleasure;

Begin
   Print_Message ('* * * It''s a pleasure doing business with thee * * *');
   Delay (2);
End;

(******************************************************************************)

Procedure Get_Item (Var Character: Character_Type; Item: Item_Record);

{ Gives an item to a character. It is assumed he/she can afford it and has room. }

Begin
   Character.Gold:=Max(Character.Gold-Item.Current_Value,0);

   Attach_Item_to_Character (Item,Character);

   If AmountFile^=1 then    { TODO: Move this to Files.pas }
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

   If AmountFile^>0 then
      AmountFile^:=AmountFile^ - 1;  { TODO: Move this to Files.pas }
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
   If AmountFile^=0 then
      Sold_Out
   Else if Character.Gold<Item.Current_Value then
      Too_Expensive
   Else If Character.No_of_Items=8 then
      No_Room
   Else
      Get_Item (Character,Item);
End;

(******************************************************************************)

Procedure Access_Record (N: Integer);  { TODO: Move to Files.pas }

{ Finds the Nth item and hold it so that others can't access it until it is UPDATED or UNLOCKED }

Begin
   Repeat
     Find (AmountFile,N+1,Error:=CONTINUE)
   Until Status(AmountFile)=PAS$K_SUCCESS;  { TODO: What if the file does not exist or is corrupted? }
End;

(******************************************************************************)

Function Item_Count (Item_Number: Integer): [Volatile]Integer;

{ This function assumes that AMOUNTFILE has already been opened for DIRECT access. TODO: Move to Files.pas }

Begin
   Access_Record (Item_Number);

   Item_Count:=AmountFile^;

   { Unlock the record so that others can use it }

   Unlock (AmountFile);
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
            then Temp:=Temp+1;
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

         Access_Record (Choices[INum].Item_Number);

         If Not ((Buyer.Class in Choices[INum].Usable_By) or (Buyer.PreviousClass in Choices[INum].Usable_By)) then
            Begin
               SMG$Put_Line (BottomDisplay,'Unusable item. Confirm purchase? (Y/N)',0);
               If Yes_or_No='Y' then
                  Add_Item(Choices[INum],Buyer);
            End
         Else
            Add_Item (Choices[INum],Buyer);

         Update (AmountFile);
      End;
End;

(******************************************************************************)

Procedure Print_List (Choices: Choice_List; Buyer: Character_Type);

Var
   Loop: Integer;

Begin
   For Loop:=1 to 10 do { TODO: Use a constant }
      Begin
         SMG$Put_Chars (BottomDisplay,'['+CHR(Loop+64)+']    '+Pad(Choices[Loop].True_Name,' ',20)+'  ');
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
               Last:=Last+1;
               If Last=450 then Last:=1; { TODO: This may be a bug. I think 450 is a valid index }
            End;
         Choices[Loop]:=Item_List[Last];
         Last:=Last+1;
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

   { TODO: This will crash if store file does not exist. }
   Open(AmountFile,'STORE.DAT;1',History:=OLD,Access_Method:=DIRECT,Sharing:=READWRITE,Error:=Continue);

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

   Close (AmountFile);
End;

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Run_Trading_Post (Var Party: Party_Type;  Party_Size: Integer);

Begin { Run Trading Post }

{ TODO: Enter this code }

End;  { Run Trading Post }
End.  { Trading Post }

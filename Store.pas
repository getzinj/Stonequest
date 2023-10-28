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

{ TODO: Enter this code }

[Global]Procedure Run_Trading_Post (Var Party: Party_Type;  Party_Size: Integer);

Begin { Run Trading Post }

{ TODO: Enter this code }

End;  { Run Trading Post }
End.  { Trading Post }

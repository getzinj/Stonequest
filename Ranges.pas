[Environment]Module Ranges;

Const
   MIN_TREASURE_NUMBER = 1;
   MAX_TREASURE_NUMBER = 150;

   MIN_ITEM_NUMBER = 0;
   MAX_ITEM_NUMBER = 449;

   MIN_QUANTITY_NUMBER = MIN_ITEM_NUMBER;
   MAX_QUANTITY_NUMBER = MAX_ITEM_NUMBER;

   MIN_PICTURE_NUMBER = 0;
   MAX_PICTURE_NUMBER = 150;

   MIN_ROSTER_NUMBER = 1;
   MAX_ROSTER_NUMBER = 20;

   MIN_PARTY_NUMBER = 1;
   MAX_PARTY_NUMBER = 6;

   MIN_MONSTER_NUMBER = 1;
   MAX_MONSTER_NUMBER = 450;

   MIN_MESSAGE_NUMBER = 1;
   MAX_MESSAGE_NUMBER = 999;

{
  Message_group    = Array [1..999] of line;
  List_of_items     = Array [0..449] of Item_record;
  List_of_Amounts   = Array [0..449] of Integer;
}
End.

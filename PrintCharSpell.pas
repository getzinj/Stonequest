[Inherit ('SYS$LIBRARY:STARLET','Types','LIBRTL','SMGRTL','STRRTL')]
Module PrintCharacterSpell;

Const
    Success = '* * * Success! * * *';
    Failure = '* * * Failure * * *';
    Done_It = '* * * Done! * * *';

Var
   Spell:                       [External]Array [Spell_Name] of Varying [4] of Char;
   PosX,PosY,PosZ:              [Byte,External]0..20;
   ScreenDisplay,keyboard:      [External]Unsigned;

(******************************************************************************)
[External]Function Choose_Item (Character: Character_Type; Action: Line): [Volatile]Integer;External;
[External]Function Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Function Alive (Character: Character_Type): Boolean;External;
[External]Procedure No_Cursor;External;
[External]Procedure Cursor;External;
[External]Function Center_Text (Txt: Line;  Line_Length: Integer:=80): Integer;External;
[External]Function Choose_Character (Txt: Line; Party: Party_Type;  Party_Size: Integer; HP: Boolean:=False;
                                   Items: Boolean:=False): [Volatile]Integer;External;
[External]Function  Regenerates (Character: Character_Type; PosZ: Integer:=0):Integer;external;
(******************************************************************************)

Procedure Select_Camp_Spell (Var SpellChosen: Spell_Name);

Var
  SpellName: Line;
  Location,Loop: Spell_Name;
  Long_Spell: [External]Array [Spell_Name] of Varying[25] of Char;

Begin { Select Camp Spell }
   Location:=NoSp;
   SMG$Set_Cursor_ABS (ScreenDisplay,20,1);
   Cursor;
   SMG$Read_String (Keyboard,SpellName,Display_ID:=ScreenDisplay,
       prompt_string:='--->');
   No_Cursor;
   If SpellName.Length<4 then SpellName:=Pad(SpellName,' ',4);
   For Loop:=CrLt to DetS do
       If (STR$Case_Blind_Compare(Spell[Loop]+'',SpellName)=0) or
          (STR$Case_Blind_Compare(Long_Spell[Loop]+'',SpellName)=0) then
          Location:=Loop;
   SpellChosen:=Location;
   SMG$Erase_Line (ScreenDisplay,20);
End;  { Select Camp Spell }

(******************************************************************************)

Procedure Handle_ID_Spell (Spell: Spell_Name;  Var Character: Character_Type; Var Casted: Boolean);

Var
   Item: Integer;
   Chance: Integer;

Begin
   Casted:=False;
   Item:=Choose_Item (Character,'Identify');
   If Item>0 then
      If Not (Character.Item[Item].Ident) then
         Begin
            Casted:=True;
            Case Spell of
               LtID: Chance:=35;
               BgID: Chance:=85;
               Otherwise Chance:=0;
            End;
            If Made_Roll (Chance) then
               Begin
                  SMG$Put_Chars (ScreenDisplay,Success,23,Center_Text(Success));
                  Character.Item[Item].Ident:=True;
               End
            Else
               SMG$Put_Chars (ScreenDisplay,Failure,23,Center_Text(Failure));
         End;
End;

(******************************************************************************)

Function Cure_Amount (Spell: Spell_Name;  Target: Character_Type): [Volatile]Die_Type;

Var
   Amount: Die_Type;

Begin
  Amount:=Zero;
  Amount.Y:=8;
  Case Spell of
     CrLt:  Amount.X:=1;
     CrSe:  Amount.X:=2;
     CrVs:  Amount.X:=3;
     CrCr:  Amount.X:=4;
     Heal:  With Amount do
              Begin
                 Y:=0;
                 Z:=Max((Target.Max_HP-Target.Curr_HP)-Roll_Die(4), 0);
              End;
  End;
  Cure_Amount:=Amount;
End;

(******************************************************************************)

Function Cure_Result (Spell: Spell_Name; Healed: Integer; Cured: Boolean; Target: Character_Type): Line;

Begin
   Case Spell of
      CrPs: If Cured then
              Cure_Result:='unpoisoned'
            Else
              Cure_Result:='not helped';
      CrPa: If Cured then
              Cure_Result:='unparalyzed'
            Else
              Cure_Result:='not helped';
      ReFe: If Cured then
              Cure_Result:='made unafraid'
            Else
              Cure_Result:='not helped';
      Heal: If Healed=0 then
               If Cured then
                 Cure_Result:='cured'
               Else
                 Cure_Result:='not helped'
            Else
               If Cured then
                 Cure_Result:='cured and partially healed'
               Else
                 Cure_Result:='partially healed';
      Otherwise If Healed=0 then
                   Cure_Result:='not helped'
                Else If Target.Curr_HP=Target.Max_HP then
                   Cure_Result:='fully healed'
                Else
                   Cure_Result:='partially healed';
   End;
End;

(******************************************************************************)

Procedure Handle_Heal_Spell (Spell: Spell_Name; Var Casted: Boolean;  Var Party: Party_Type;  Party_Size: Integer);

Var
   Recipient,Healed:  Integer;
   Target: Character_Type;
   T: Line;
   Amount: Die_Type;
   Cured: Boolean;

Begin
   Cured:=False;
   Casted:=False;
   Recipient:=Choose_Character ('Cast spell on whom?',Party,Party_Size,HP:=TRUE);
   If Recipient>0 then
      Begin
         Casted:=True;
         Target:=Party[Recipient];

         Case Spell of
            Heal:  If Not (Target.Status in [Deleted,Ashes,Dead,Zombie]) then
               Begin
                  Cured:=Not (Target.Status in [Deleted,Ashes,Dead,Zombie,Healthy]);
                  Target.Status:=Healthy;
               End;
            CrPs: If Target.Status=Poisoned then
               Begin
                  Target.Status:=Healthy;
                  Cured:=True;
               End;
            CrPa:  If Target.Status=Paralyzed then
               Begin
                  Target.Status:=Healthy;
                  Cured:=True;
               End;
            ReFe: If Target.Status=Afraid then
               Begin
                  Target.Status:=Healthy;
                  Cured:=True;
               End;
         End;
         Target.Regenerates:=Regenerates(Target,PosZ);

         { Compute how much the character is ACTUALLY healed, e.g., you can't cure a dead guy! }

         Amount:=Cure_Amount (Spell,Target);                { Find how much the spell heals }
         Healed:=Random_Number (Amount);                    { And get a random number from within that range }
         If Healed<0 then Healed:=0;                        { You can't be healed a negative amount }
         If Not Alive(target) then Healed:=0;               { Dead people ain't very lucky }
         If Target.Curr_HP=target.Max_HP then Healed:=0;    { You can't get cured over your maximum }

         { Add the amount healed points and make sure it's not more than the character's maximum }

         Target.Curr_HP:=Min(Target.Curr_HP+Healed,Target.Max_HP);

         { Let the player know how successful the spell was }

         T:='* * * '+Target.Name+' is '+Cure_Result (Spell,Healed,Cured,Target)+'! * * *';
         SMG$Put_Chars (ScreenDisplay,T,23,Center_Text(T));

         Party[Recipient]:=target;
      End;
End;

(******************************************************************************)

Procedure Handle_Animate_Dead_Spell (Var Casted: Boolean; Var Party: Party_Type; Party_Size: Integer);

Var
   Recipient: Integer;
   Target: Character_Type;
   T: Line;

Begin
   Casted:=False;
   Recipient:=Choose_Character ('Cast spell on whom?',Party,Party_Size,HP:=TRUE);
   If Recipient>0 then
      Begin
         Casted:=True;
         Target:=Party[Recipient];
         T:='* * * '+Target.Name+' is ';
         If Target.Status=Dead then
            Begin
               T:=T+'animated! * * *';
               Target.Status:=Zombie;
               Target.Curr_HP:=Roll_Die(8)+Roll_Die(8);
            End
         Else
            T:=T+'not animated! * * *';
         SMG$Put_Chars (ScreenDisplay,T,23,Center_Text(T));
         Party[Recipient]:=Target;
      End;
End;

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Cast_Camp_Spell (Var Character: Character_Type; Var Leave_Maze: Boolean;  Direction: Direction_Type;
                          Var Party: Party_Type;  Var Party_Size: Integer);

Begin
   { TODO: Enter this code }
End;


[Global]Procedure Handle_Spell (Var Character: Character_Type; Spell: Spell_Name;  Class,Spell_Level: Integer;  Var Leave_Maze: Boolean;
                                  Direction: Direction_Type;  Var Party: Party_Type;  Var Party_Size: Integer;  Item_Spell: Boolean:=False);

Begin
   { TODO: Enter this code }
End;

End.

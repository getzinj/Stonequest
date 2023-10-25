[Inherit ('Types','SMGRTL','STRRTL')]Module Treasure;

Const
    SpellsY = 7;   SpellsX = 26;
    ZeroOrd = Ord ('0');

Var
   Silenced,Can_Attack:                                            [External]Party_Flag;
   Looked,Disarmed:                                                Party_Flag;
   NoMagic:                                                        [External]Boolean;
   OptionsDisplay,Pasteboard,Keyboard,MessageDisplay,FightDisplay: [External]Unsigned;
   Treasure:                                                       [External]List_of_Treasures;
   Item_List:                                                      [External]List_of_Items;
   TrapName:                                                       [External]Array [Trap_Type] of Varying [20] of Char;


(******************************************************************************)
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Procedure Delay (Seconds: Real);External;
[External]Function String(Num: Integer; Len: Integer:=0):Line;External;
[External]Function Make_Choice (Choices: Char_Set;  Time_Out:  Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Procedure Zero_Through_Six (Var Number: Integer; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' ');External;
[External]Function Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
(******************************************************************************)

Function Get_Person (Action_Text: Line;  Member: Party_Type;  Current_Party_Size: Integer): [Volatile]Integer;

Var
   Looker: Integer;
   Answer: Char;
   Done: Boolean;

Begin
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Set_Cursor_ABS (OptionsDisplay,3,27-(Action_Text.Length div 2));
   SMG$Put_Line (OptionsDisplay,Action_Text);
   SMG$End_Display_Update (OptionsDisplay);

   Done:=False;
   Repeat
      Begin
         Looker:=0;
         Answer:=Make_Choice ([CHR(13),'1'..CHR(Current_Party_Size+ZeroOrd)]);
         If Answer<>CHR(13) then
            Looker:=Ord(Answer)-ZeroOrd;
         If Looker>0 then
            Done:=Member[Looker].Status in [Healthy,Poisoned,Zombie]
         Else
            Done:=True;
      End;
   Until Done;

   Get_Person:=Looker;
End;

(******************************************************************************)

Procedure Open_Chest (Var Opener: Integer; Member: Party_Type; Current_Party_Size: Party_Size_Type;
                      Var Chest_Status: Chest_Status_Type);

Begin
   Opener:=Get_Person ('Who will open it?',Member,Current_Party_Size);
   If Opener>0 then
      Chest_Status:=Opened;
End;

(******************************************************************************)

Procedure Print_Message (T: Line);

Begin
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Put_Chars (OptionsDisplay,T,3,27-(T.length div 2));
   SMG$End_Display_Update (OptionsDisplay);

   Delay(2);

   SMG$Erase_Display (OptionsDisplay);
End;

(******************************************************************************)

Procedure Cant_Cast_It;

Begin
   Print_Message ('* * * Thou can''t cast it! * * *');
End;

(******************************************************************************)

Procedure Print_Trap (Trap: Trap_Type);

Begin
   Print_Message (TrapName[Trap]);
End;

(******************************************************************************)

Procedure Check_Traps_Spell (Trap: Trap_Type; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type);

Var
   Character: Character_Type;
   Looker: Integer;
   Class,Level: Integer;

[External]Procedure Find_Spell_Group (Spell: Spell_Name; Character: Character_Type;  Var Class,Level: Integer);External;

Begin
   Looker:=Get_Person ('Who will cast ChTr?', Member,Current_Party_Size);
   If Looker>0 then
      If Member[Looker].Status in [Healthy,Poisoned] then
         Begin
            Character:=Member[Looker];
            Find_Spell_Group (ChTr,Character,Class,Level);
            If (Level<10) and (Level>0) and (Character.SpellPoints[Class,Level]>0) then
               Begin
                  Looked[Looker]:=True;
                  Print_Trap (Trap);
                  Character.Experience:=Character.Experience+15*Ord(Trap);
                  Character.SpellPoints[Class,Level]:=Character.SpellPoints[Class,Level]-1;
                  Member[Looker]:=Character;
               End
            Else
               Cant_Cast_It;
         End;
End;

(******************************************************************************)

Procedure Init_Window;

Begin
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$Put_Line (OptionsDisplay,' A chest!  Thou may:',2,1);
   SMG$Put_Line (OptionsDisplay,' O)pen it      S)earch it for traps    C)hTr it');
   SMG$Put_Line (OptionsDisplay,' L)eave it     D)isarm trap',0);
   SMG$End_Display_Update (OptionsDisplay);
   SMG$Paste_Virtual_Display (OptionsDisplay,Pasteboard,SpellsY,SpellsX);
End;

(******************************************************************************)

Function Choose_Trap (Possible_Traps: Trap_Set): Trap_Type;

Var
   List: Array [1..18] of Trap_Type;
   Max: Integer;
   Loop: Trap_Type;

Begin
   Max:=0;  List:=Zero;
   For Loop:=PoisonNeedle to Stunner do
      If Loop in Possible_Traps then
         Begin
            Max:=Max+1;
            List[Max]:=Loop;
         End;
   If Max=0 then
      Choose_Trap:=Trapless
   Else
      Choose_Trap:=List[Roll_Die(Max)];
End;

(******************************************************************************)

Function Class_Chance (Class: Class_Type; Level: Integer): Integer;

Begin
   Case Class of
     Thief,Ninja:            Class_Chance:=15+(5*Level);
     Antipaladin,Assassin:   Class_Chance:=5+(4*Level);
     Bard:                   Class_Chance:=3*Level;
     NoClass:                Class_Chance:=0;
     Otherwise               Class_Chance:=Level;
   End;
End;

(******************************************************************************)

Function Detect_Trap_Chance (Character: Character_Type; Trap: Trap_Type): Integer;

Var
  Chance: Integer;

Begin
   Chance:=Max(Class_Chance(Character.Class, Character.Level),
               Class_Chance(Character.PreviousClass,Character.Previous_Lvl));

   Case Character.Race of
      Dwarven:              Chance:=Chance+15;
      Gnome:                Chance:=Chance+10;
      Hobbit,HfOrc:         Chance:=Chance+5;
      HfOgre:               Chance:=Chance-10;
      Quickling,Drow,Elven: Chance:=Chance+20;
   End;

   Case Character.Abilities[4] of
        3..8: Chance:=Chance-20;
        9,10: Chance:=Chance-10;
          11: Chance:=Chance-5;
          18: Chance:=Chance+5;
       19,20: Chance:=Chance+10;
       21,22: Chance:=Chance+15;
       23,24: Chance:=Chance+20;
          25: Chance:=Chance+25;
   End;

   Chance:=Chance - Round(1.25 * Ord(Trap));

   Chance:=Chance + (2 * (Character.Abilities[7]-9));  { Add luck into it }

   If Character.Psionics then
      Chance:=Chance + Character.DetectTrap;

   If Character.Status=Zombie then
      Chance:=0;

   Detect_Trap_Chance:=Max(0, Min(Chance, 95));
End;


(******************************************************************************)

Procedure Already_Looked;

Begin
   Print_Message ('* * * Thou already looked! * * *');
End;

(******************************************************************************)

Procedure Search_Chest (Trap: Trap_Type; Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type);

Var
   Chance,Looker: Integer;
   TS: Trap_Set;

Begin
   Looker:=Get_Person ('Who will look?',Member,Current_Party_Size);
   If Looker>0 then
      If Looked[Looker] then
         Already_Looked
      Else
         Begin
            Looked[Looker]:=True;

            Chance:=Detect_Trap_Chance (Member[Looker],Trap);

            SMG$Begin_Display_Update (OptionsDisplay);
            SMG$Erase_Display (OptionsDisplay);

            TS:=[Trapless .. Stunner]-[Trap];

            If Made_Roll (Chance) then
               Member[looker].Experience:=Member[Looker].Experience+15
            Else
               Trap:=Choose_Trap(TS);  { If didn't make chance, give a false(?) trap }
            Print_Trap (Trap);
         End;
End;

(******************************************************************************)

Procedure Trap_Damage (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer; Victim: Integer;
                       Trap_Used: Trap_Type);

Var
   Character: Character_Type;
   Dummy: Boolean;
   Damage: Integer;

[External]Procedure Change_Status (Var Character: Character_Type;  Status: Status_Type;  Var Changed: Boolean);External;
[External]Procedure Dead_Characters (Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                                     Var Can_Attack: Party_Flag);External;

Begin
   Damage:=0;
   Character:=Member[Victim];

   Case Trap_Used of
      Darts:         Damage:=(Roll_Die(5)*RolL_Die(3));
      Blades:        Damage:=(4 * Roll_Die (6));
      Acid:          Damage:=(3 * Roll_Die (10));
      CrossbowBolt:  Damage:=Roll_Die (6) + 1;
      Splinters:     Damage:=(Roll_Die(2)*Roll_Die(3));
      ExplodingBox:  Damage:=(3 * Roll_Die(6));
   End;

   If (Character.Status=Asleep) and (Damage>0) then
      Character.Status:=Healthy;

   Character.Curr_HP:=Character.Curr_HP-Damage;
   If Character.Curr_HP<1 then
      Begin
         Character.Curr_HP:=0;
         Change_Status (Character,Dead,Dummy);
      End;
   Member[Victim]:=Character;
   Dead_Characters (Member,Current_Party_Size,Party_Size,Can_Attack);
End;

(******************************************************************************)

Procedure Handle_Random_Teleport;

Var
   Safe: Boolean;
   NewX,NewY,NewZ: Integer;
   Temp: Level;
   Maze: [External]Level;
   PosX,PosY: [External]Horizontal_Type;
   PosZ: [External]Vertical_Type;

[External]Function Get_Level (Level_Number: Integer; Maze: Level; PosZ: Vertical_Type:=0): [Volatile]Level;External;

Begin
   Repeat
      Begin
         NewX:=Roll_Die(20);  NewY:=Roll_Die(20);  NewZ:=Roll_Die(9);
         Temp:=Get_Level (NewZ,Maze,PosZ);
         Safe:=(Temp.Special_Table[Temp.Room[NewX,NewY].Contents].Special=Nothing);
      End;
   Until Safe;
   Maze:=Temp;
   PosX:=NewX;  PosY:=NewY;  PosZ:=NewZ;
End;

(******************************************************************************)

Procedure Trap_Off (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;
                    Trap_Given: Trap_Type; Victim: Integer; Var CantHave: Boolean;  Var Alarm_Off: Boolean);

Var
   T: Line;
   Dummy: Boolean;
   Wizards,Clerics: Set of Class_Type;

[External]Function Made_Save (Character: Character_Type; Attack: Attack_Type): [Volatile]Boolean;External;
[External]Procedure Change_Status (Var Character: Character_Type; Status: Status_Type; Var Changed: Boolean);External;
[External]Function Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Procedure Update_Character_Box (Member: Party_Type; Party_Size: Integer; Var Can_Attack: Party_Flag);External;

Begin
   Wizards:=[Ranger,Wizard,Bard]; { TODO: Repeated code }
   Clerics:=[Cleric,Paladin,Antipaladin];

   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);

   Case Roll_Die(10) of
      1: T:='Yikes';
      2: T:='Zoinks';
      3: T:='Argh';
      4: T:='Whoops';
      5: T:='Egads';
      6: T:='Uh uh';
      7: T:='Gasp';
      8: T:='Zounds';
      9: T:='Gads';
     10: T:='Jinkies';
   End;

   T:=T+'!  ';
   T:=T+TrapName[Trap_Given]+'!';

   SMG$Set_Cursor_ABS (OptionsDisplay,3,(27-(T.length div 2)));
   SMG$Put_Line (OptionsDisplay,T,0,1);

   Case Trap_Given of
        PoisonNeedle: Change_Status (Member[victim],Poisoned,Dummy);
        Alarm: Alarm_Off:=True;
        Teleporter:
            Begin
               Handle_Random_Teleport;
               CantHave:=True;
            End;
        Darts: Trap_Damage (Member,Current_Party_Size,Party_Size,
                            Roll_Die(Current_Party_Size),Darts);
        Blades: Trap_Damage (Member,Current_Party_Size,Party_Size,Victim,Blades);
        SnoozeAlarm: Begin
                        If Not (Made_Save(Member[Victim],Sleep)) then
                            Change_Status (Member[Victim],Asleep,Dummy);
                        Alarm_Off:=True;
                     End;
        GasCloud: For Victim:=1 to Current_Party_Size do
                     If Not (Made_Save(Member[Victim],Poison)) then
                         Change_Status (Member[Victim],Poisoned,Dummy);
        Acid: Trap_Damage (Member,Current_Party_Size,Party_Size,Victim,Acid);
        Paralyzer: If Not (Made_Save(Member[Victim],Magic)) then
                            Change_Status (Member[Victim],Paralyzed,Dummy);
        BoobyTrap: If Not (Made_Save(Member[Victim],Insanity)) then
                            Change_Status (Member[Victim],Insane,Dummy);
        Sleeper: For Victim:=1 to Current_Party_Size do
                     If Not (Made_Save(Member[Victim],Sleep)) then
                         Change_Status (Member[Victim],Asleep,Dummy);
        AntiWizard: For Victim:=1 to Current_Party_Size do
                      If (Member[Victim].Class in Wizards) or (Member[Victim].PreviousClass in Wizards) then
                         If Not (Made_Save(Member[Victim],Poison)) then
                             Change_Status (Member[Victim],Paralyzed,Dummy);
        AntiCleric: For Victim:=1 to Current_Party_Size do
                      If (Member[Victim].Class in Clerics) or (Member[Victim].PreviousClass in Clerics) then
                         If Not (Made_Save(Member[Victim],Poison)) then
                             Change_Status (Member[Victim],Paralyzed,Dummy);
        CrossbowBolt: Trap_Damage (Member,Current_Party_Size,Party_Size,Roll_Die(Current_Party_Size),CrossbowBolt);
        ExplodingBox: Begin
                          For Victim:=1 to Current_Party_Size do
                             Trap_Damage (Member,Current_Party_Size,Party_Size,Victim,ExplodingBox);
                          CantHave:=True;
                      End;
        Splinters: Trap_Damage (Member,Current_Party_Size,Party_Size,Victim,Splinters);
        Stunner: If Not (Made_Save(Member[Victim],Magic)) then
                            Change_Status (Member[Victim],Petrified,Dummy);
   End;

   Member[Victim].Regenerates:=Regenerates (Member[Victim]);
   SMG$End_Display_Update (OptionsDisplay);
   Delay(2.5);
   Update_Character_Box (Member,Party_Size,Can_Attack);
End;

(******************************************************************************)

Procedure Already_Tried;

Begin
   Print_Message ('* * * Thou already tried! * * *');
End;

(******************************************************************************)

Function Get_Trap_Name: [Volatile]Line;

Var
  TrapToDisarm: Line;

[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;

Begin
   SMG$Begin_Display_Update (OptionsDisplay);
   SMG$Erase_Display (OptionsDisplay);
   SMG$End_Display_Update (OptionsDisplay);
   SMG$Put_Chars (OptionsDisplay,'Disarm what trap? >',3,2);

   Cursor;
   SMG$Read_String (Keyboard,TrapToDisarm,Display_ID:=OptionsDisplay);
   No_Cursor;

   Get_Trap_Name:=TrapToDisarm;
End;

(******************************************************************************)

Procedure Attempt_to_Disarm (Opener: Integer; Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                             Party_Size: Integer; Var Trap: Trap_Type; Var Blown: Boolean; Var Alarm_Off: Boolean);

Var
  TrapToDisarm: Line;
  Chance: Integer;
  Right_Trap,Yikes: Boolean;

Begin
   Yikes:=False;
   If Disarmed[Opener] then
      Already_Tried
   Else
      Begin
         Disarmed[Opener]:=True;
         Chance:=Detect_Trap_Chance (Member[Opener],Trap);
         TrapToDisarm:=Get_Trap_Name;

         Right_Trap:=(STR$Case_Blind_Compare(TrapToDisarm,TrapName[Trap]+'')=0);

         If Right_Trap and Made_Roll(Chance) then
            Begin
               Trap:=Trapless;
               Print_Message('* * * Thou disarmed it! * * *');
               Member[Opener].Experience:=Member[Opener].Experience+15*Ord(Trap);
            End
         Else
            Begin
               Chance:=Round(Chance * 75/100);
               If Made_Roll (Chance) then
                  Print_Message ('* * * Thine attempt failed! * * *')
               Else
                  Begin
                     Print_Message  ('* * * Thou set it off! * * *');
                     Yikes:=True;
                  End;
            End;

         If Yikes and (Trap<>Trapless) then
            Begin
               Trap_Off (Member,Current_Party_Size,Party_Size,Trap,Opener,Blown,Alarm_Off);
               Trap:=Trapless;
            End
      End
End;

(******************************************************************************)

Procedure Disarm_Trap (Var Trap: Trap_Type;  Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                       Party_Size: Integer;  Var Blown: Boolean;  Var Alarm_Off: Boolean);

{ This procedure allows a character to disarm a trap on a chest.  It does not actually say if the trap the character is trying to
  disarm is the trap that is actually on the chest. }

Var
   Opener: Integer;

Begin
   Opener:=Get_Person ('Who will attempt to disarm?',Member,Current_Party_Size);
   If Opener>0 then Attempt_to_Disarm (Opener,Member,Current_Party_Size,Party_Size,Trap,Blown,Alarm_Off);
End;

(******************************************************************************)

Procedure Init_Chest (Current_PArty_Size: Party_Size_Type;  Var BlownItem,BlownMoney: Treasure_Record;  Var Trap: Trap_Type;
                      Var Chest_Status: Chest_Status_Type;  Chest: Treasure_Table);

Begin
  Looked:=Zero;
  Disarmed:=Zero;
  Chest_Status:=Closed;
  With BlownItem do
     Begin
        Kind:=Item_Given;
        Item_Number:=Zero;
     End;
  With BlownMoney do
     Begin
        Kind:=Cash_Given;
        Initial_Random:=Zero;
        Initial_Base:=0;
        Multiplier:=Zero;
     End;
  Trap:=Choose_Trap (Chest.Possible_Traps);
End;

(******************************************************************************)

Procedure Handle_Chest (Var Chest: Treasure_Table;  Var Member: Party_Type; Var Current_Party_Size: Party_Size_Type;
                            Party_Size: Integer;  Var Leave: Boolean;  Var Alarm_Off: Boolean);

Var
   Chest_Status: Chest_Status_Type;
   Trap: Trap_Type;
   BlownItem,BlownMoney: Treasure_Record;
   Options: Char_Set;
   Answer: Char;
   Opener: Integer;

Begin
   Options:=['O','S','C','L','D'];  Opener:=0;
   Init_Chest (Current_Party_Size,BlownItem,BlownMoney,Trap,Chest_Status,Chest);
   Repeat
     Begin
        Init_Window;
        Answer:=Make_Choice (Options);
        Case Answer of
            'D': Disarm_Trap (Trap,Member,Current_Party_Size,Party_Size,Leave,Alarm_Off);
            'S': Search_Chest (Trap,Member,Current_Party_Size);
            'O': Open_Chest (Opener,Member,Current_Party_Size,Chest_Status);
            'C': Check_Traps_Spell (Trap,Member,Current_Party_Size);
            'L': Leave:=True;
        End;
     End;
   Until (Chest_Status=Opened) or Leave;

   If (Chest_Status=Opened) and (Trap<>Trapless) then
      Trap_Off (Member,Current_Party_Size,Party_Size,Trap,Opener,Leave,Alarm_Off);

   SMG$Unpaste_Virtual_Display (OptionsDisplay,Pasteboard);
End;

(******************************************************************************)

Procedure Give_Money (Amount: Integer; Var Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Var
  Recipient: Integer;

Begin
  SMG$Erase_Display (MessageDisplay);
  Recipient:=Roll_Die (Current_Party_Size);
  SMG$Put_Line (MessageDisplay,Member[Recipient].Name+' found a sack of '+String(Amount)+' gold pieces!');
  Member[Recipient].Gold:=Member[Recipient].Gold+Amount;
  Delay(2);
End;

(******************************************************************************)

Function Character_With_Room (Member: Party_Type; Current_Party_Size: Party_Size_Type): Integer;

Var
   Person,Num: Integer;

Begin
   Person:=0;  Num:=0;

   For Person:=1 to Current_Party_Size do
      Num:=Num+Member[Person].No_of_Items;

   If Num<>(Current_Party_Size * 8) then
      Repeat
         Person:=Roll_Die (Current_Party_Size);
      Until (Member[Person].No_of_Items<8)
   Else
      Person:=0;

   Character_with_Room:=Person;
End;

(******************************************************************************)

Procedure Give_Item (Item_No: Integer;  Var Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Var
   Num,Person: Integer;

Begin
   Person:=Character_With_Room (Member,Current_Party_Size);
   If Person<>0 then
      Begin
         Member[Person].No_of_Items:=Member[Person].No_of_Items+1;
         Num:=Member[Person].No_of_Items;
         With Member[Person].Item[Num] do
            Begin
                Ident:=false;
                Equipted:=False;
                Cursed:=False;
                Usable:=(Member[Person].Class in Item_List[Item_No].Usable_By)
                    or (Member[Person].PreviousClass in Item_List[Item_No].Usable_By);
                Item_Num:=Item_no;
            End;

         SMG$Erase_Display (MessageDisplay);
         SMG$Put_Line (MessageDisplay,Member[Person].Name+' found a '+Item_List[Item_No].Name, 0);
         If (Num = 8) then
            SMG$Put_Line (MessageDisplay,'Thou can not carry any more items until thou drops something...');

        Delay(2);
        SMG$Erase_Display(MessageDisplay);
      End;
End;

(******************************************************************************)

Procedure Deliver_Gold_And_Money (Treasure: Treasure_Record; Var Member: Party_Type;  Current_Party_Size: Party_Size_Type);

Var
   Money,Item_No,Temp: Integer;

Begin
   If Treasure.Kind=Cash_Given then
      Begin
         Money:=Treasure.Initial_Base+Random_Number(Treasure.Initial_Random);
         Temp:=Random_Number(Treasure.Multiplier);
         If Temp<>0 then
            Money:=Money * Temp;
         Give_Money (Money,Member,Current_Party_Size);
      End
   Else
      Begin
         Item_No:=Random_Number(Treasure.Item_Number);
         If Made_Roll (Treasure.Appear_Probability) then
            Give_Item (Item_No,Member,Current_Party_Size);
      End;
End;

(******************************************************************************)

Procedure Deliver_Treasure (Number: Integer;  Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                            Party_Size: Integer;  Var Alarm_Off: Boolean);

Const
  Chest_Picture_Number = 18;
  Gold_Picture_Number = 19;

Var
   Group: Integer;
   CantHave: Boolean;

[External]Procedure Show_Monster_Image (Number: Pic_Type;  Var Display: Unsigned);External;

Begin { Deliver Treasure }
  CantHave:=False;
  If Treasure[Number].In_Chest then
     Begin
        Show_Monster_Image (Chest_Picture_Number,FightDisplay);
        SMG$Erase_Display (MessageDisplay);
        Handle_Chest (Treasure[Number],Member,Current_Party_Size,Party_Size,CantHave,Alarm_Off);
     End;

  { Opened the chest if there was one }

  If (Not CantHave) and (Treasure[Number].Max_No_of_Treasures > 0) then
     Begin
        Show_Monster_Image (Gold_Picture_Number,FightDisplay);
        For Group:=1 to Treasure[Number].Max_no_of_Treasures do
          Deliver_Gold_And_Money (Treasure[Number].Treasure[Group],Member,Current_Party_Size);
     End;
End;

(******************************************************************************)


[Global]Procedure Give_Treasure (Encounter: Encounter_Group;  Area: Area_Type;  Var Member: Party_Type;
                                 Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;  Var Alarm_Off: Boolean);

Var
  Group, Treasure_Type: Integer;
  Monster: Monster_Record;
  TreasureSet: Set of T_Type;

Begin { Give Treasure }
   For Group:=1 to 4 do
      If Encounter[Group].Orig_Group_Size > 0 then
         Begin
            Monster:=Encounter[Group].Monster;
            If Area=Room then TreasureSet:=Monster.Treasure.In_Lair
            Else              TreasureSet:=Monster.Treasure.Wandering;

            For Treasure_Type:=1 to 150 do
               If Treasure_Type in TreasureSet then
                  Deliver_Treasure (Treasure_Type,Member,Current_Party_Size,Party_Size,Alarm_Off);
         End;
End;  { Give Treasure }
End.  { Treasure }

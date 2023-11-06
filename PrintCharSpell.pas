[Inherit ('SYS$LIBRARY:STARLET','Types','LIBRTL','SMGRTL','STRRTL')]
Module PrintCharacterSpell;

Const
    Success = '* * * Success! * * *';
    Failure = '* * * Failure * * *';
    Done_It = '* * * Done! * * *';

    Up_Arrow         = CHR(18);            Down_Arrow         = CHR(19);
    Left_Arrow       = CHR(20);            Right_Arrow        = CHR(21);

    Cler_Spell = 1;                        Wiz_Spell  = 2;

Var
   No_Magic:                    [External]Boolean;
   Maze:                        [External]Level;
   Spell:                       [External]Array [Spell_Name] of Varying [4] of Char;
   PosX,PosY,PosZ:              [Byte,External]0..20;
   Rounds_Left:                 [External]Array [Spell_Name] of Unsigned;
   SpellDisplay: Unsigned;
   ScreenDisplay,keyboard,pasteboard,campdisplay,optionsdisplay,characterdisplay: [External]Unsigned;
   CommandsDisplay,spellsdisplay,messagedisplay,monsterdisplay,viewdisplay,GraveDisplay: [External]Unsigned;
   Camp_Spells:                 [External]Set of Spell_Name;

(******************************************************************************)
[External]Function Spell_Duration (Spell: Spell_Name; Caster_Level: Integer):Integer;External;
[External]Function Get_Level (Level_Number: Integer; Maze: Level; PosZ: Vertical_Type:=0): [Volatile]Level;External;
[External]Function Choose_Item (Character: Character_Type; Action: Line): [Volatile]Integer;External;
[External]Function Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Function Roll_Die (Die_Type: Integer): [Volatile]Integer;External;
[External]Procedure Race_Adjustments (Var Character: Character_Type; Race: Race_Type);External;
[External]Function Alive (Character: Character_Type): Boolean;External;
[External]Procedure No_Cursor;External;
[External]Procedure Cursor;External;
[External]Procedure Delay (Seconds: Real);External;
[External]Function Make_Choice (Choices: Char_Set;  Time_Out:  Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
[External]Function Center_Text (Txt: Line;  Line_Length: Integer:=80): Integer;External;
[External]Function Choose_Character (Txt: Line; Party: Party_Type;  Party_Size: Integer; HP: Boolean:=False;
                                   Items: Boolean:=False): [Volatile]Integer;External;
[External]Function  Regenerates (Character: Character_Type; PosZ: Integer:=0):Integer;external;
[External]Procedure Get_Rid_of_Item (Var Character: Character_Type; Which_Item: Integer);External;
[External]Procedure Find_Spell_Group (Spell: Spell_Name;  Character: Character_Type;  Var Class,Level: Integer);External;
[External]Function Caster_Level (Cls: Integer; Character: Character_Type): Integer;External;
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

Procedure Handle_Party_Spell (Caster_Level: Integer; Spell: Spell_Name; Var Party: Party_Type; Party_Size: Integer);

Var
  Add: Integer;
  Position: Integer;

Begin
   Case Spell of
        DiPr: Add:=2;
        HgSh: Add:=4;
   End;
   Rounds_Left[Spell]:=Rounds_Left[Spell]+Spell_Duration (Spell,Caster_Level);
   For Position:=1 to Party_Size do
      Party[Position].Armor_Class:=Party[Position].Armor_Class-Add;
   SMG$Put_Chars (ScreenDisplay,Done_It,23,32);
End;

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

Procedure Handle_Uncurse_Spell (Spell: Spell_Name; Var Casted: Boolean; Var Party: Party_Type;  Var Party_Size: Integer);

Var
   Char_Num,Item,Chance: Integer;
   Character: Character_Type;

Begin
   Casted:=False;
   Char_Num:=Choose_Character ('Cast spell on whose item?',Party,Party_Size);
   If Char_num>0 then
      Begin
         Character:=Party[Char_Num];
         Item:=Choose_Item (Character,'Uncurse');
         If (Item>0) and (Character.Item[Item].Cursed) then
            Begin
                 Casted:=True;
                 Chance:=85; { TODO: Make constant }
                 If Made_Roll (Chance) then
                    Begin
                        SMG$Put_Chars (ScreenDisplay,Success,23,Center_Text(Success));
                        Get_Rid_of_Item (Character,Item);

                        Party[Char_Num]:=Character;
                    End
                 Else
                    SMG$Put_Chars (ScreenDisplay,Failure,23,Center_Text(Failure));
            End
         Else
            SMG$Put_Chars (ScreenDisplay,'* * * That item is not cursed * * *',23,40-(35 div 2));
      End;
End;

(******************************************************************************)

Procedure Change_Race (Var Race: Race_Type);

Var
  Advance: Integer;

Begin
  For advance:=1 to Roll_Die(20) do
    If Ord(Race)=1 then
       Race:=Numenorean
    Else
       Race:=Pred(Race);
End;

(******************************************************************************)

Procedure Handle_Raise_Spell (Spell: Spell_Name; Var Casted: Boolean; Var Party: Party_Type; Party_Size: Integer);

Var
  Temp: Race_Type;
  Recipient,Chance: Integer;
  Target: Character_Type;
  MadeIt,LostIt: Array [1..5] of Line;
  T: Line;

Begin
   Casted:=False;
   MadeIt[1]:='* * * Excelsior! * * *';   LostIt[1]:='* * * Oops! * * *';
   MadeIt[2]:='* * * Mazel tov! * * *';   LostIt[2]:='* * * Yikes! * * *';
   MadeIt[3]:='* * * Hallelujah! * * *';  LostIt[3]:='* * * Uh oh! * * *';
   MadeIt[4]:='* * * Yippee! * * *';      LostIt[4]:='* * * Whoops! * * *';
   MadeIt[5]:='* * * Hooray! * * *';      LostIt[5]:='* * * Gads! * * *';

   Recipient:=Choose_Character ('Cast spell on whom?',Party,Party_Size,TRUE);

   If Recipient>0 then
      Begin
         Target:=Party[Recipient];

         Case Spell of
              Rein: Case Target.Status of
                        Healthy: Chance:=0;
                        Ashes: Chance:=5;
                        Dead: Chance:=85;
                        Otherwise Chance:=0;
                    End;
              Raze: Case Target.Status of
                       Healthy: Chance:=0;
                       Ashes: Chance:=0;
                       Dead: Chance:=90;
                       Otherwise Chance:=0;
                   End;
              Ress: Case Target.Status of
                     Healthy: Chance:=0;
                     Ashes,Dead: Chance:=90;
                     Otherwise Chance:=0;
                 End;
         End;

         If (Target.Age_Status=Croak) or (Target.Max_HP<1) then
            Chance:=0;

         If Chance>0 then
            Begin
               If Made_Roll (Chance) then
                  Begin
                     If Spell=Rein then
                        Begin
                           Temp:=Target.Race;
                           Change_Race (Temp);
                           Race_Adjustments (Target,Temp);
                           Target.Race:=Temp;
                        End;

                     Target.Status:=Healthy;
                     Target.Experience:=Target.Experience+100;

                     Case Spell of
                        Rein,Ress: Target.Curr_HP:=Target.Max_HP;
                        Raze:      Target.Curr_HP:=1;
                     End;

                     T:=MadeIt[Roll_Die(5)];
                  End
               Else
                  Begin
                     Case Target.Status of
                       Dead: Target.Status:=Ashes;
                       Ashes: Target.Status:=Deleted;
                     End;
                     T:=LostIt[Roll_Die(5)];
                  End
            End
         Else
            T:='* * * Unaffected! * * *';

         SMG$Put_Chars (ScreenDisplay,T,23,Center_Text(T));

         Party[Recipient]:=Target;

         Casted:=True;
      End;
End;

(******************************************************************************)

Procedure Handle_Party_Heal (Var Party: Party_Type;  Party_Size: Integer);

Var
  Temp,Loop: Integer;

Begin
   For Loop:=1 to Party_Size do
      Begin
         Temp:=(Party[Loop].Max_HP)-(Party[Loop].Curr_HP); { Number of points needed to bring to character to full health }
         Temp:=Temp div 2;
         If Not(Alive(Party[Loop])) or (Party[Loop].Status=Zombie) then
            Temp:=0
         Else
            Party[Loop].Status:=Healthy;

         Party[Loop].Curr_HP:=Min(Party[Loop].Curr_HP + Temp,Party[Loop].Max_HP);
      End;
   SMG$Put_Chars (ScreenDisplay,Done_It,23,32);
End;

(******************************************************************************)

Procedure Compass (Caster_Level: Integer; Var Casted: Boolean);

Begin
   Rounds_Left[Comp]:=Rounds_Left[Comp]+Spell_Duration(Comp,Caster_Level);
   Casted:=True;
   SMG$Put_Chars (ScreenDisplay,Done_It,23,32);
End;

(******************************************************************************)

Procedure Handle_Light_Spell (Caster_Level: Integer; Spell: Spell_Name);

Begin
   Rounds_Left[Spell]:=Rounds_Left[Spell]+Spell_Duration(Spell,Caster_Level);
   SMG$Put_Chars (ScreenDisplay,Done_It,23,32);
End;

(******************************************************************************)

Procedure Handle_Levitate_Spell (Caster_Level: Integer);

Begin
   Rounds_Left[Levi]:=Rounds_Left[Levi]+Spell_Duration(Levi,Caster_Level);
   SMG$Put_Chars (ScreenDisplay,Done_It,23,32);
End;

(******************************************************************************)

Procedure Handle_Detect_Special (Caster_Level: Integer; Var Casted: Boolean);

Begin
   Rounds_Left[DetS]:=Rounds_Left[DetS]+Spell_Duration(DetS,Caster_Level);
   Casted:=True;
   SMG$Put_Chars (ScreenDisplay,Done_It,23,32);
End;

(******************************************************************************)

Procedure Fizzled_out;

Begin
   SMG$Put_Chars (ScreenDisplay,'* * * It Fizzeled Out! * * *',23,26);
End;

(******************************************************************************)

Procedure Handle_Location_Spell (Direction: Direction_Type);

Var
   T: Line;

Begin
   SMG$Create_Virtual_Display (7,78,SpellDisplay,1);
   SMG$Label_Border (SpellDisplay,'Location',SMG$K_TOP);

   If PosZ<>10 then
      Begin
         SMG$Put_Chars (SpellDisplay,'The party is facing ');
         Case Direction of
            North: SMG$Put_Chars (SpellDisplay,'north');
            South: SMG$Put_Chars (SpellDisplay,'south');
            East: SMG$Put_Chars (SpellDisplay,'east');
            West: SMG$Put_Chars (SpellDisplay,'west');
         End;
         T:='.  Thou art ' + String(PosX - 1) + ' square';
         If (PosX -1 > 1) then
           T:=T+'s';

         T:=T+' East, '+ String(20 - PosY) + ' square';
         If (20 - PosY > 1) then
           T:=T+'s';

         T:=T+' North, and ' + String(PosZ) + ' level';
         If (PosZ > 1) then
            T:=T+'s';

         T:=T+' down.';

         SMG$Put_Line (SpellDisplay,T, Wrap_Flag:=SMG$M_WRAP_WORD);
      End
   Else
      Begin
        T:='Powerful magiks prevent this spell from working here.';
        SMG$Put_Chars (SpellDisplay,T,2,Center_Text(T,78));
      End;

   SMG$Put_Chars (SpellsDisplay,'Press [RETURN] to exit',7,1);

   SMG$Paste_Virtual_Display (SpellDisplay,Pasteboard,2,2);

   Make_Choice([CHR(13)]);

   SMG$Unpaste_Virtual_Display (SpellDisplay,Pasteboard);
   SMG$Delete_Virtual_Display (SpellDisplay);
End;

(******************************************************************************)

Procedure Word_of_Recall (Var Leave_Maze: Boolean);

Begin
   Leave_Maze:=True;
   Rounds_Left[WoRe]:=1;

   SMG$Unpaste_Virtual_Display(CampDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display(OptionsDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display(CharacterDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display(CommandsDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display(SpellsDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display(MessageDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display(MonsterDisplay,Pasteboard);
   SMG$Unpaste_Virtual_Display(ViewDisplay,Pasteboard);
End;

(******************************************************************************)

Procedure Bounced (Var Squished: Boolean; Var T: Line);

Begin
  Squished:=False;
  T:='* * * Thou bounced back to where thou were! * * *';
End;


(******************************************************************************)

Procedure In_Rock (Var Squished: Boolean; Var T: Line);

Begin
  Squished:=True;
  T:='* * * Thou materialized in rock! * * *';
End;

(******************************************************************************)

Procedure Too_High (Var Squished: Boolean; Var T: Line);

Begin
  Squished:=True;
  T:='* * * Thou materialized above Kyrn and fell to thy death! * * *';
End;

(******************************************************************************)

Function Teleport_To (X,Y,Z: Integer; Var Squished: Boolean; Var Leave_Maze: Boolean): Line;

Var
   T: Line;
   Temp: Level;
   Spec: Special_Type;

Begin
  T:='';
  Squished:=False;
  If (X<1) or (X>20) or (Y<1) or (Y>20) or (Z>19) then
      In_Rock (Squished, T)
  Else If Z<0 then
      Too_High (Squished, T)
  Else If (Z=0) and (((X=1) and (Y=20)) or ((X=0) and (Y=0))) then
     Word_of_Recall (Leave_Maze) { Teleported to Kyrn }
  Else
     Begin
        Temp:=Get_Level (Z,Maze,PosZ);
        Spec:=Temp.Special_Table[Temp.Room[X,Y].Contents];
        If Spec.Special=Rock then
           In_Rock (Squished,T)
        Else if (Spec.Special=AntiMagic) or ((Z>9) and (PosZ<>Z)) then
           Bounced (Squished,T)
        Else
           Begin
              T:=Done_It;
              PosX:=X;  PosY:=Y;  PosZ:=Z;
              Maze:=Temp;
              No_Magic:=False;
           End;
     End;
  Teleport_To:=T;
End;

(******************************************************************************)

Procedure Print_Place (Delta_X, Delta_Y, Delta_Z: Integer);

Begin
  SMG$Begin_Display_Update (SpellsDisplay);
  SMG$Erase_Display (SpellsDisplay);

  If Delta_Y>0 then
     Begin
        SMG$Put_Chars (SpellDisplay,'South: ');
        SMG$Put_Line  (SpellDisplay,String(Delta_Y,2) + '  (  Up arrow / Down arrow )');
     End
  Else
     Begin
        SMG$Put_Chars (SpellDisplay,'North: ');
        SMG$Put_Line  (SpellDisplay,String((Delta_Y * (-1)),2) + '  (  Up arrow / Down arrow )');
     End;

  If Delta_X>-1 then
     Begin
        SMG$Put_Chars (SpellDisplay,'East: ');
        SMG$Put_Line  (SpellDisplay,String(Delta_X,2) + '  (  Left arrow / Right arrow )');
     End
  Else
     Begin
        SMG$Put_Chars (SpellDisplay,'West: ');
        SMG$Put_Line  (SpellDisplay,String((Delta_X * (-1)),2) + '  (  Left arrow / Right arrow )');
     End;

  If Delta_Z>-1 then
     Begin
        SMG$Put_Chars (SpellDisplay,'Down: ');
        SMG$Put_Line  (SpellDisplay,String(Delta_Z,2) + '  (  U / D )');
     End
  Else
     Begin
        SMG$Put_Chars (SpellDisplay,'Up:   ');
        SMG$Put_Line  (SpellDisplay,String((Delta_Z * (-1)),2) + '  (  U / D )');
     End;

  SMG$Put_Chars (SpellDisplay,'Arrows + U,D to select relative position. [RETURN] accepts, <SPACE> aborts!');
  SMG$End_Display_Update (SpellDisplay);
End;

(******************************************************************************)

Procedure Handle_Teleport_Spell (Var Leave_Maze: Boolean;  Var Party: Party_Type; Var Party_Size: Integer);

Var
   Crapped: Boolean;
   T: Line;
   Answer: Char;
   CharNo: Integer;
   Delta_X,Delta_Y,Delta_Z: Integer;

Begin
  Delta_X:=0;  Delta_Y:=0;  Delta_Z:=0;  Crapped:=False;
  SMG$Create_Virtual_Display (7,78,SpellDisplay,1);
  SMG$Label_Border (SpellDisplay,'Party Teleport',SMG$K_TOP);

  SMG$Paste_Virtual_Display (SpellDisplay,Pasteboard,2,2);
  Repeat
     Begin
        Print_Place (Delta_X,Delta_Y,Delta_Z);

        Answer:=Make_Choice (['U','D',Left_Arrow,Right_Arrow,Up_Arrow,Down_Arrow,CHR(32),CHR(13)]);

        Case Answer of
                  'U': Delta_Z:=Delta_Z-1;
                  'D': Delta_Z:=Delta_Z+1;

                  Left_Arrow: Delta_X:=Delta_X-1;
                  Right_Arrow: Delta_X:=Delta_X+1;

                  Up_Arrow: Delta_Y:=Delta_Y-1;
                  Down_Arrow: Delta_Y:=Delta_Y+1;

                  CHR(32),CHR(13): ;
        End;
     End;
  Until (Answer=CHR(32)) or (Answer=CHR(13));

  SMG$Pop_Virtual_Display (SpellDisplay,Pasteboard);
  If Answer=CHR(13) then
     Begin
        T:=Teleport_To (PosX+Delta_X,PosY+Delta_Y,PosZ+Delta_Z,Crapped,Leave_Maze);
        SMG$Put_Chars (ScreenDisplay,T,21,Center_Text (T,78));
        Delay (1);
     End;
  If Crapped then
     Begin
        Delay (1);
        For CharNo:=1 to Party_Size do
           Party[CharNo].Status:=Deleted;
        Rounds_Left[WoRe]:=1;  { Indicates an interrupt. TODO: Not exactly intuitive, is this? }

        Leave_Maze:=True;

        SMG$Paste_Virtual_Display (GraveDisplay,Pasteboard,2,2);

        SMG$Unpaste_Virtual_Display (CampDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (OptionsDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (CharacterDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (CommandsDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (SpellsDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (MessageDisplay,Pasteboard);
        SMG$Unpaste_Virtual_Display (ViewDisplay,Pasteboard);
     End;
End;

(******************************************************************************)

[Global]Procedure Random_Teleport;

Var
   Safe: Boolean;
   NewX,NewY,NewZ: Integer;
   Temp: Level;

Begin
   Repeat
      Begin
        NewX:=Roll_Die(20); NewY:=Roll_Die(20);  NewZ:=Roll_Die(9);
        Temp:=Get_Level (NewZ,Maze,PosZ);
        Safe:=(Temp.Special_Table[Temp.Room[NewX,NewY].Contents].Special=Nothing);
      End;
   Until Safe;

   Maze:=Temp;

   PosX:=NewX;  PosY:=NewY;  PosZ:=NewZ;
End;

(******************************************************************************)

Procedure Handle_Dungeon_Blink;

Begin
   Random_Teleport;
   SMG$Put_Chars (ScreenDisplay,Done_It,23,29);
   Delay(3);
End;

(******************************************************************************)

[Global]Procedure Handle_Spell (Var Character: Character_Type; Spell: Spell_Name;  Class,Spell_Level: Integer;  Var Leave_Maze: Boolean;
                                  Direction: Direction_Type;  Var Party: Party_Type;  Var Party_Size: Integer;  Item_Spell: Boolean:=False);

Var
  Casted: Boolean;
  Level: Integer;

Begin
   Level:=Caster_Level (Class,Character);
   If Item_Spell then
      Level:=8;

    Casted:=True;

   If Not No_Magic then
       Case Spell of
            PaHe:                                     Handle_Party_Heal (Party,Party_Size);
            DiPr,HgSh:                                Handle_Party_Spell (Level,Spell,Party,Party_Size);
            BgId,LtId:                                Handle_ID_Spell (Spell,Character,Casted);
            UnCu:                                     Handle_Uncurse_Spell (Spell,Casted,Party,Party_Size);
            Levi:                                     Handle_Levitate_Spell (Level);
            Lght,CoLi:                                Handle_Light_Spell (Level,Spell);
            WoRe:                                     Word_of_Recall (Leave_Maze);
            Tele:                                     Handle_Teleport_Spell(Leave_Maze,Party,Party_Size);
            Loct:                                     Handle_Location_Spell (Direction);
            Comp:                                     Compass (Level,Casted);
            ReFe,CrPa,CrPs,CrLt,CrSe,CrVs,CrCr,Heal:  Handle_Heal_Spell (Spell,Casted,Party,Party_Size);
            Rein,Ress,Raze:                           Handle_Raise_Spell (Spell,Casted,Party,Party_Size);
            AnDe:                                     Handle_Animate_Dead_Spell (Casted,Party,Party_Size);
            DuBl:                                     Handle_Dungeon_Blink;
            DetS:                                     Handle_Detect_Special (Level,Casted);
            Otherwise                                 ;
       End
   Else
       Fizzled_Out;

   If Casted and Not Item_Spell then
      Character.SpellPoints[Class,Spell_Level]:=Max(Character.SpellPoints[Class,Spell_Level]-1,0);

   If Casted and not (Spell in [WoRe,Tele,Loct]) then Delay (2);
End;

(******************************************************************************)

Procedure Doesnt_Know_Spell;

Var
  T: Line;

Begin
  T:='* * * Thou don''t know that spell * * *';
  SMG$Put_Chars (ScreenDisplay,T,19,Center_Text(T));
  Delay (2.5);
End;

(******************************************************************************)

Procedure No_More_SpellPoints;

Var
  T: Line;

Begin
   T:='* * * Spell Points exhausted * * *';
   SMG$Put_Chars (ScreenDisplay,T,19,Center_Text(T));
   Delay(2.5);
End;

(******************************************************************************)

Procedure Not_Camp_Spell;

Var
  T: Line;

Begin
   T:='* * * Thou canst not cast that spell while in camp * * *';
   SMG$Put_Chars (ScreenDisplay,T,19,Center_Text(T));
   Delay(2.5);
End;

(******************************************************************************)

[Global]Procedure Cast_Camp_Spell (Var Character: Character_Type; Var Leave_Maze: Boolean;  Direction: Direction_Type;
                          Var Party: Party_Type;  Var Party_Size: Integer);

Var
  What_Spell: Spell_Name;
  Class,Spell_Level: Integer;
  Spell_Error: Boolean;

Begin
  Spell_Error:=False;
  SMG$Erase_Display (ScreenDisplay,19,1);
  SMG$Put_Line (ScreenDisplay,'Cast what spell?');

  Select_Camp_Spell (What_Spell);
  SMG$Erase_Display (ScreenDisplay,19,1);

  If What_Spell=NoSp then
     Begin
        SMG$Put_Chars (ScreenDisplay,'* * *  What?  * * *',19,20);
        Delay(1);
        Spell_Error:=True;
     End
  Else If What_Spell<>ReDo then
     Begin
        Find_Spell_Group (What_Spell,Character,Class,Spell_Level);

        Spell_Error:=(Spell_Level=10) or (Spell_Level=0);
        Spell_Error:=Spell_Error or (Class=Cler_Spell) and Not (What_Spell in Character.Cleric_Spells);
        Spell_Error:=Spell_Error or (Class=Wiz_Spell)  and Not (What_Spell in Character.Wizard_Spells);

        If Spell_Error then
           Doesnt_Know_Spell
        Else If Character.SpellPoints[Class,Spell_Level]<1 then
           No_More_SpellPoints
        Else If Not (What_Spell in Camp_Spells) then
           Not_Camp_Spell
        Else
           Handle_Spell (Character,What_Spell,Class,Spell_Level,Leave_Maze,Direction,Party,Party_Size);
     End;
End;
End.

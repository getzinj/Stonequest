[Inherit ('SYS$LIBRARY:STARLET','Types','SMGRTL','StrRtl')]Module Encounter;

{ This is the main module for combat. It handles all phases of combat,
  including treasure and fleeing. }

Const
   MonY       = 2;      MonX    = 26;
   SpellsY    = 7;      SpellsX = 26;
   ViewY      = 2;      ViewX   =  2;

   ZeroOrd = Ord ('0');

   Cler_Spell = 1;     Wiz_Spell = 2;

Type
   Place_Ptr   = ^Place_Node;
   Place_Node  = Record
                    PosX,PosY: Horizontal_Type;
                    PosZ: Vertical_Type;
                    Next: Place_Ptr;
                 End;
   Place_Stack = Record
                    Front: Place_Ptr;
                    Length: Integer;
                 End;
   ClassSet   = Set of Item_Type;
   Spell_List = Packed Array [1..9] of Set of Spell_Name;

Var
  Bool_String                                           : Array [Boolean] of Line;
  Show_Messages                                         : Boolean;
  Keyboard,Pasteboard,FightDisplay,CharacterDisplay     : [External]Unsigned;
  MonsterDisplay,CommandsDisplay,ViewDisplay            : [External]Unsigned;
  MessageDisplay,SpellsDisplay                          : [External]Unsigned;
  SpellListDisplay,OptionsDisplay                       : [External]Unsigned;
  WizSpells,ClerSpells                                  : [External]Array [Spell_Name] of Varying [4] of Char;
  Maze                                                  : [External]Level;
  PosX,PosY                                             : [External]Horizontal_Type;
  PosZ                                                  : [External]Vertical_Type;
  Leave_Maze                                            : [External]Boolean;
  Delay_Constant                                        : [External]Real;
  Party_Spell,Person_Spell,Caster_Spell,All_Monsters_Spell,Group_Spell,Area_Spell: [External]Set of Spell_Name;
  Item_List                                             : [External]List_of_Items;
  Pics                                                  : [External]Pic_List;
  Places                                                : [External]Place_Stack;
  Time_Stop_Monsters,Time_Stop_Players                  : [Global]Boolean;
  Encounter_Spells                                      : Set of Spell_Name;
  Silenced,Can_Attack                                   : [Global]Party_Flag;
  NotSurprised,Yikes,NoMagic                            : [Global]Boolean;
  Bells_On                                              : [External,Volatile]Boolean;

Value
  Bool_String[True]:='On';        Bool_String[False]:='Off';

(******************************************************************************)
[External]Procedure Get_Num (Var Number: Integer; Display: Unsigned);External;
[External]Procedure Cursor;External;
[External]Procedure No_Cursor;External;
[External]Function Make_Choice (Choices: Char_Set; Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): Char;External;
[External]Function Yes_or_No (Time_Out: Integer:=-1;
    Time_Out_Char: Char:=' '): [Volatile]Char;External;
[External]Function Zero_Through_Six (Var Number: Integer; Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): Char;External;
[External]Function Pick_Character_Number (Party_Size: Integer; Current_Party_Size: Integer:=0;
                                          Time_Out: Integer:=-1; Time_Out_Char: Char:='0'): [Volatile]Integer;External;
[External]Procedure Ring_Bell (Display_Id: Unsigned; Number_of_Times: Integer:=1);External;
[External]Function Random_Number (Die: Die_Type): [Volatile]Integer;External;
[External]Function Regenerates (Character: Character_Type; PosZ: Integer:=0): Integer;external;
[External]Function Alive (Character: Character_Type): Boolean;external;
[External]Function  Made_Roll (Needed: Integer): [Volatile]Boolean;external;
[External]Procedure Delay (Seconds: Real);External;
[External]Function  String(Num: Integer;  Len: Integer:=0):Line;External;
[External]Function Compute_Party_Size (Member: Party_Type;  Party_Size: Integer): Integer;External;
[External]Procedure Print_Party_Line (Member: Party_Type;  Party_Size,Position: Integer);External
[External]Procedure Time_Effects (Position: Integer; Var Member: Party_Type; Party_Size: Integer);External;
[External]Procedure Dead_Character (Position: Integer; Var Member: Party_Type; Party_Size: Integer);External;
(******************************************************************************)

Function Insane_Leader (Party: Party_Type; Var Name: Line): Boolean;

Begin { Insane Leader }
   If Party[1].Status=Insane then
      Begin
         Name:=Party[1].Name;
         Insane_Leader:=True;
      End
   Else
      Insane_Leader:=False;
End;  { Insane Leader }

(******************************************************************************)

Function Party_Dead (Party: Party_type; Size: Integer): Boolean;

{ This function will return TRUE if every member in the party is dead, and FALSE otherwise }

Var
   Temp: Boolean;
   Index: Integer;

Begin { Party Dead }
   Temp:=False;
   Index:=0;

   { Repeat until all members checked or one living found }

   Repeat
      Begin
         Index:=Index+1;
         Temp:=Temp or Alive (Party[Index]);
      End;
   Until Temp or (Index=6);
   Party_Dead:=Not Temp;
End;  { Party Dead }

(******************************************************************************)

[Global]Function Monster_Name (Monster: Monster_Record; Number: Integer; Identified): Monster_Name_Type;

{ This function returns the name of the monster as influenced by whether or not the monsters have been identified, and whether there
  is just one, or many. }

Begin { Monster Name }
   If Identified then  { If the monster is known... }
      If Number>1 then { and there's more than one.... }
         Monster_Name:=Monster.Real_Plural  { Use the correct plural name }
      Else
         Monster_Name:=Monster.Real_Name    { Otherwise use the correct singular name }
   Else                 { Otherwise, if it isn't known... }
      If Number>1 then { and there's more than one.... }
         Monster_Name:=Monster.Plural  { Use the unidentified plural name }
      Else
         Monster_Name:=Monster.Name;    { Otherwise use the unidentified singular name }
End;  { Monster Name }

(******************************************************************************)

[Global]Procedure Slay_Character (Var Character: Character_Type; Var Can_Attack: Flag);

{ This procedure kills CHARACTER, if he or she is not already dead }

Begin { Slay Character }
   If Not (Character.Status in [Dead,Ashes,Deleted]) then
       Begin
          Character.Regenerates:=0;  Character.Armor_Class:=12;  Character.Status:=Dead;  Character.Curr_HP:=0;
          Can_Attack:=False;
          SMG$Put_Line (MessageDisplay,
              Character.Name
              +' is slain!',0,1);
          Ring_Bell (MessageDisplay,3);
       End;
End;  { Slay Character }

(******************************************************************************)

Function Update_Can_Attacks (Member: Party_Type; Party_Size: Integer): Party_Flag;

{ This procedure will determine who in the party can still attack }

Var
   Individual: Integer;
   Can_Attack: Party_Flag;

Begin { Update Can Attacks }
   For Individual:=1 to Party_Size do
      Can_Attack[Individual]:=(Member[Individual].Status in [Healthy,Poisoned,Zombie]);
   Update_Can_Attacks:=Can_Attack;
End;  { Update Can Attacks }

(******************************************************************************)

Procedure Combat_Message;

{ Print "An encounter..." on the screen }

Begin { Combat Message }
   SMG$Begin_Display_Update (MessageDisplay);
   SMG$Erase_Display (MessageDisplay);
   SMG$Put_Chars (MessageDisplay,
       'An encounter...',2,1,,1);
   SMG$End_Display_Update (MessageDisplay);
   Delay (2);
End;  { Combat Message }

(******************************************************************************)

Procedure Compute_AC_And_Regenerates (Var Character: Character_Type);

[External]Function Compute_AC (Character: Character_Type; PosZ: Integer:=0): Integer;external;

Begin { Compute AC and Regenerates }
   Character.Armor_Class:=Compute_AC(Character,PosZ);
   Character.Regenerates:=Regenerates(Character,PosZ);
End;  { Compute AC and Regenerates }

(******************************************************************************)

Procedure Initialize_Character (Var Character: Character_Type; Position: Integer);

Begin { Initialize Character }
  Compute_AC_And_Regenerates (Character);
  Character.Attack.Berserk:=False;
  Silenced[Position]:=False
End;  { Initialize Character }

(******************************************************************************)

Procedure Initialize (Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type; Party_Size: Integer;
                      Var Can_Attack: Party_Flag;  Var Alarm_Off: Boolean;  Time_Delay: Integer);

{ This procedure initializes the encounter module. }

Var
   Character: Integer;

Begin { Initialize }
   Combat_Message;
   Show_Messages:=True;

   { Establish the delay constant for pacing messages }

   Delay_Constant:=Time_Delay/500;

   { Initialize some displays }

   SMG$Create_Virtual_Display (22,78,SpellListDisplay,1);
   SMG$Erase_Display (SpellListDisplay);

   Encounter_Spells := Party_Spell + Person_Spell + Caster_Spell + All_Monster_Spell + Group_Spell + Area_Spell;

   Can_Attack:=Update_Can_Attacks (Member,Party_Size);
   Time_Stop_Monsters:=False;  Time_Stop_Players:=False;

   For Character:=1 to Current_Party_Size do
      Initialize_Character(Member[Character],Character);

   Alarm_Off:=False;   NotSurprised:=False;
   Yikes:=False;
End;  { Initialize }

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Run_Encounter (Monster_Number:Integer;  Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                                 Party_Size: Integer;  Var Alarm_Off: Boolean;  Location: Area_Type:=Corridor;
                                 NoMagic: Boolean:=False;  Var Time_Delay: Integer);

Begin { Run Encounter }

{ TODO: Enter this code }

End;  { Run Encounter }
End.  { Encounter }

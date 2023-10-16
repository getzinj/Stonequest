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


{ TODO: Enter this code }

[Global]Procedure Run_Encounter (Monster_Number:Integer;  Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                                 Party_Size: Integer;  Var Alarm_Off: Boolean;  Location: Area_Type:=Corridor;
                                 NoMagic: Boolean:=False;  Var Time_Delay: Integer);

Begin { Run Encounter }

{ TODO: Enter this code }

End;  { Run Encounter }
End.  { Encounter }

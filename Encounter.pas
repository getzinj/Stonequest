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
  










{ TODO: Enter this code }

[Global]Procedure Run_Encounter (Monster_Number:Integer;  Var Member: Party_Type;  Var Current_Party_Size: Party_Size_Type;
                                 Party_Size: Integer;  Var Alarm_Off: Boolean;  Location: Area_Type:=Corridor;
                                 NoMagic: Boolean:=False;  Var Time_Delay: Integer);

Begin { Run Encounter }

{ TODO: Enter this code }

End;  { Run Encounter }
End.  { Encounter }

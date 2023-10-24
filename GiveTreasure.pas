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


{ TODO: Enter code }

(******************************************************************************)

{ TODO: Enter this code }

[Global]Procedure Give_Treasure (Encounter: Encounter_Group;  Area: Area_Type;  Var Member: Party_Type;
                                 Var Current_Party_Size: Party_Size_Type;  Party_Size: Integer;  Var Alarm_Off: Boolean);
Begin { Give Treasure }

{ TODO: Enter this code }

End;  { Give Treasure }
End.  { Treasure }

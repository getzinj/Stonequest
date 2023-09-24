[Inherit ('Types','SMGRTL','STRRTL')]Module TrainingGrounds;

Type
   Race_Set  = Set of Race_Type;
   Align_Set = Set of Align_Type;

Var
   Party:                               Party_Type;
   Party_Size:                          Integer;
   Leave_Maze:                          Boolean;
   ClassChoiceDisplay:                  Unsigned;
   ScreenDisplay,Keyboard,Pasteboard:   [External]Unsigned;
   Location:                            [External]Place_Type;
   Roster:                              [External]Roster_Type;
   ClassName:                           [External]Array [Class_Type] of Varying [13] of char;
   Maze:                                [External]Level;
   PosX,PosY,PosZ:                      [External, Byte]0..20;
   Rounds_Level:                        [External]Array [Spell_Name] of Unsigned;

Value
   Leave_Maze:=False;

   
{ TODO: Enter this code }

[Global]Procedure Run_Training_Grounds;

Begin { Run Training Grounds }

{ TODO: Enter this code }

End;  { Run Training Grounds }
End.  { Training Grounds }

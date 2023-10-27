[Inherit ('SYS$LIBRARY:STARLET','Types','LIBRTL','SMGRTL')]Module High_Score;

Var
   ScoreDisplay: Unsigned;
   Roster:       [External]Roster_Type;
   Pasteboard:   [External]Unsigned;
   ScoresFile:   [External]Score_File; { TODO: Put in Files.pas }
   ClassName:    [External]Array [Class_Type] of Varying [13] of char;


(******************************************************************************)
[External]Function XP_Needed (Class: Class_Type; Level: Integer): Real;external;
[External]Function  Alive (Character: Character_Type): Boolean;external;
[External]Function String(Num: Integer; Len: Integer:=0):Line;external;
[External]Function Get_Response (Time_Out: Integer:=-1;  Time_Out_Char: Char:=' '):[Volatile]Char;External;
(******************************************************************************)

Procedure Read_Score_List (Var ScoresFile: Score_File; Var Score_List: High_Score_List);

Begin
   Open(ScoresFile,file_name:='SCORES.DAT',History:=UNKNOWN,Sharing:=READONLY,Error:=Continue);
   If (Status(ScoresFile)=PAS$K_SUCCESS) or (Status(ScoresFile)=PAS$K_EOF) then
      Begin
         Reset (ScoresFile);
         If EOF (ScoresFile) then
            Score_List:=Zero
         Else
            Read (ScoresFile, Score_List);
      End
   Else
      Score_List:=Zero;
End;

(******************************************************************************)

Procedure Insert (Character: Character_Type;  Var Temp: Combined_List;  Username: Line);

Var
  Pos,X: Integer;
  Found: Boolean;

Begin { TODO: Add a unique id to each character so we don't have to do this guesswork to identify the same character }
  If Character.Previous_Lvl>0 then
     Character.Experience:=Character.Experience+XP_Needed (Character.PreviousClass,Character.Previous_Lvl);
  If Not Alive(Character) then Character.Experience:=0;

  Pos:=0;  X:=0;
  Found:=False;
  Repeat
     Begin
        X:=X+1;
        If (Character.Name=Temp[X].Name) and (Username=Temp[X].User_Name) then
           Found:=True;
     End;
  Until (X=40) or Found;

  { Look for the same character so that we can update it }

  If Not Found then { If we didn't find character, search for any empty slot. }
     Begin
        Pos:=0;  X:=0;
        Found:=False;
        Repeat
           Begin
              X:=X+1;
              If (Temp[X].Lvl1=0) or (Temp[X].Experience=0) then
                 Found:=True;
           End;
        Until (X=40) or (Found);
     End;

  { In either case, X should equal the spot to insert }

  Pos:=X;
  With Temp[Pos] do
     Begin
        Name:=Character.Name;
        User_Name:=Username;
        Lvl1:=Character.Level;
        Lvl2:=Character.Previous_Lvl;
        Class1:=Character.Class;
        Class2:=Character.PreviousClass;
        Experience:=Character.Experience;
        Defeated_Barrat:=Character.Scenarios_Won[0];
     End;
End;

(******************************************************************************)

Function Make_Combined_Score_List (Score_List: High_Score_List; Username: Line): Combined_List;

Var
   X: Integer;
   Temp: Combined_List;
   Character: Character_Type;

Begin
  { Copy the current high scores to the first 20 slots }

  For X:=1 to 20 do   Temp[X]:=Score_List[X];

  { Initialize t he last twenty slots }

  For X:=21 to 40 do Temp[X]:=Zero;

  { Now insert all the new characters }

  For X:=1 to 20 do
     Begin
        Character:=Roster[X];
        Insert(Character,Temp,Username);
     End;

  Make_Combined_Score_List:=Temp;
End;

(******************************************************************************)

Procedure Swap (Var Combined_Score_List: Combined_List; I,J: Integer);

Var
   Save: Score;

Begin
   Save:=Combined_Score_List[I];
   Combined_Score_List[I]:=Combined_Score_List[J];
   Combined_Score_List[J]:=Save;
End;

(******************************************************************************)

Procedure Sort_Combined_List (Var Combined_Score_List: Combined_List; First: Integer:=1;  Last: Integer:=40);

Var
   I: Integer;
   Done: Boolean;

Begin
  Repeat
     Begin
        Done:=True;
        For I:=First to Last-1 do
           If Combined_Score_List[I].experience<Combined_Score_List[I+1].experience then
              Begin
                 Swap (Combined_Score_List, I, I+1);
                 Done:=False;
              End;
     End;
  Until Done;
End;

(******************************************************************************)

Function Top_Twenty (Combined_Score_List: Combined_List): High_Score_List;

Var
   Temp: High_Score_List;
   X: Integer;

Begin
   For X:=1 to 20 do
      Temp[X]:=Combined_Score_List[X];
   Top_Twenty:=Temp;
End;

(******************************************************************************)

Procedure Write_Score_List (Var ScoresFile: Score_File;  Score_List: High_Score_List); { TODO: Move to Files.pas }

Begin
   Rewrite (ScoresFile);
   Write (ScoresFile,Score_List);
End;

(******************************************************************************)

[Global]Procedure Update_High_Scores (UserName: Line);

Var
   Combined_Score_List: Combined_List;
   Score_List: High_Score_List;

Begin
   Read_Score_List (ScoresFile,Score_List);
   Combined_Score_List:=Make_Combined_Score_List (Score_List, Username);
   Sort_Combined_List (Combined_Score_List);
   { TODO: Is code missing? }
End;

(*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*)

Procedure Initialize;

Const
   High_Score_Title = 'Character Name       Username        Level   Class          Experience';

Begin
   SMG$Create_Virtual_Display (22,78,ScoreDisplay,1);
   SMG$Label_Border (ScoreDisplay,'-=*> High Scores <*=-',SMG$K_TOP);
   SMG$Erase_Display (ScoreDisplay);
   SMG$Put_Line (ScoreDisplay, High_Score_Title);
End;

(******************************************************************************)

Procedure Print_List (Score_List: High_Score_List);

Var
   Rendition: Unsigned;
   X: Integer;
   T: Line;
   C1,C2: Line;

Begin
   For X:=1 to 19 do
      If (Score_List[X].Lvl1>0) and (Score_List[X].Experience>0) then
         Begin
            T:=Pad(Score_List[X].Name,' ',21)+Pad(Score_List[X].USer_Name,' ',16);

            C1:=String(Score_List[X].Lvl1);
            If Score_List[X].Lvl2>0 then C1:=C1+'/'+String(Score_List[X].Lvl2);
            If C1.Length<8 then T:=T+Pad(C1,' ',8)
            Else                T:=T+C1;

            C1:=ClassName[Score_List[X].Class1];
            C2:=ClassName[Score_List[X].Class2];
            if Score_List[X].Class2<>NoClass then C1:=C1+'/'+C2;
            If C1.Length<18 then T:=T+Pad(C1,' ',18)
            Else                 T:=T+SubStr(C1,1,18);

            T:=T+String(Trunc(Score_List[X].Experience),12);

            Rendition:=0;
            If Score_List[X].Defeated_Barrat then Rendition:=SMG$M_Bold;  { T:=T+'*' }
            SMG$Put_Line (ScoreDisplay,T,,Rendition);
         End;

   SMG$Put_Chars (ScoreDisplay,'Characters in ',21,7);
   SMG$Put_Chars (ScoreDisplay,'Boldface',,,,SMG$M_Bold);
   SMG$Put_Chars (ScoreDisplay,' have completed ');
   SMG$Put_Chars (ScoreDisplay,'the Quest of the Stone',,,,SMG$M_Underline+SMG$M_Reverse);

   SMG$Put_Chars (ScoreDisplay,'Press any key',22,32);

   SMG$Paste_Virtual_Display (ScoreDisplay,Pasteboard,2,2);

   Get_Response;

   SMG$Unpaste_Virtual_Display (ScoreDisplay,Pasteboard);
   SMG$Delete_Virtual_Display (ScoreDisplay);
End;

(******************************************************************************)

[Global]Procedure Print_Scores;

Var
   Score_List: High_Score_List;

Begin { Print Scores }
  Initialize;
  Read_Score_List (ScoresFile,Score_List);
  Close (ScoresFile);
  Print_List (Score_List);
End;  { Print Scores }

(******************************************************************************)

[Global]Procedure Clear_High_Scores;

Var
   Score_List: High_Score_List;

Begin { Clear High Scores }
  Score_List:=Zero;
  Open (ScoresFile,'SCORES.DAT',History:=UNKNOWN,Sharing:=READONLY,Error:=Continue);
  Write_Score_List (ScoresFile,Score_List);
  Close (ScoresFile);
End;  { Clear High Scores }
End.  { High Score }

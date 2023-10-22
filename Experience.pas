[Inherit ('Types')]Module Experience;
Function Special_Attacks (Monster: Monster_Record): Boolean;

Begin
   Special_Attacks:=(Monster.No_of_Attacks>1) or (Monster.Armor_Class<2) or (Monster.Highest.Cleric_Spell>0);
End;

(******************************************************************************)

Function Exceptional_Attacks (Monster: Monster_Record): Boolean;

Begin
   Exceptional_Attacks:= (Monster.Levels_Drained>0)        or ([Paralyzes,Autokills,Stones,Poisons,NoTurn,Cause_Fear] * Monster.Properties<>[ ]) or
                         (Monster.Magic_Resistance>0)      or (Monster.Highest.Wizard_Spell>0)                                                   or
                         (Monster.Years_Ages>0)            or (Monster.No_of_Attacks>3)                                                          or
                         (Monster.Armor_Class<-1)          or (Monster.Resists<>[ ])                                                             or
                         (Monster.Breath_Weapon<>Charming) or (Monster.Highest.Cleric_Spell>3)                                                   or
                         (Monster.Regenerates>0)           or (Monster.Gaze_Weapon<>Charming);
End;

(******************************************************************************)

[Global]Function Experience (Number: Integer; Group: Monster_Group): Real;

Var
  SA,EA: Boolean;
  Temp: Real;
  Monster: Monster_Record;
  HP,HD: Integer;

Begin { Experience }
   Monster:=Group.Monster;
   SA:=Special_Attacks (Monster);   EA:=Exceptional_Attacks (Monster);
   HP:=Group.MAX_HP[Number];        HD:=Monster.Hit_Points.X;
   HP:=HP*2; { $$ }
   Temp:=0;

   If HD<1 then
      Begin
          Temp:=5+HP;
          Temp:=Temp+(2*Card(Monster.Resists));
          If SA then Temp:=Temp+2;
          If EA then Temp:=Temp+25;
      End
   Else
      If HD<2 then
         Begin
            Temp:=10+HP;
            Temp:=Temp+(4*(Card(Monster.Resists)));
            If SA then Temp:=Temp+4;
            If EA then Temp:=Temp+35;
         End
      Else
         If HD<3 then
            Begin
               Temp:=35+(3*HP);
               Temp:=Temp+(8*(Card(Monster.Resists)));
               If SA then Temp:=Temp+8;
               If EA then Temp:=Temp+45;
            End
         Else
            If HD<4 then
                Begin
                   Temp:=60+(4*HP);
                   Temp:=Temp+(25*(Card(Monster.Resists)));
                   If SA then Temp:=Temp+25;
                   If EA then Temp:=Temp+45;
                End
            Else
              If HD<5 then
                Begin
                   Temp:=90+(5*HP);
                   Temp:=Temp+(40*(Card(Monster.Resists)));
                   If SA then Temp:=Temp+40;
                   If EA then Temp:=Temp+75;
                End
              Else
                If HD<6 then
                    Begin
                       Temp:=150+(6*HP);
                       Temp:=Temp+(75*(Card(Monster.Resists)));
                       If SA then Temp:=Temp+75;
                       If EA then Temp:=Temp+125;
                    End
                Else
                    If HD<7 then
                        Begin
                           Temp:=225+(8*HP);
                           Temp:=Temp+(125*(Card(Monster.Resists)));
                           If SA then Temp:=Temp+125;
                           If EA then Temp:=Temp+175;
                        End
                    Else
                        If HD<8 then
                            Begin
                               Temp:=375+(10*HP);
                               Temp:=Temp+(175*(Card(Monster.Resists)));
                               If SA then Temp:=Temp+175;
                               If EA then Temp:=Temp+275;
                            End
                        Else
                            If HD<9 then
                                Begin
                                   Temp:=600+(14*HP);
                                   Temp:=Temp+(450*(Card(Monster.Resists)));
                                   If SA then Temp:=Temp+450;
                                   If EA then Temp:=Temp+600;
                                End
                            Else
                                If HD<10 then
                                    Begin
                                       Temp:=900+(16*HP);
                                       Temp:=Temp+(700*(Card(Monster.Resists)));
                                       If SA then Temp:=Temp+700;
                                       If EA then Temp:=Temp+850;
                                    End
                                Else
                                    If HD<12 then
                                        Begin
                                           Temp:=1300+(18*HP);
                                           Temp:=Temp+(950*(Card(Monster.Resists)));
                                           If SA then Temp:=Temp+950;
                                           If EA then Temp:=Temp+1200;
                                        End
                                    Else
                                        If HD<14 then
                                            Begin
                                               Temp:=1800+(20*HP);
                                               Temp:=Temp+(1250*(Card(Monster.Resists)));
                                               If SA then Temp:=Temp+1250;
                                               If EA then Temp:=Temp+1600;
                                            End
                                        Else
                                            If HD<16 then
                                                Begin
                                                   Temp:=2400+(25*HP);
                                                   Temp:=Temp+(1550*(Card(Monster.Resists)));
                                                   If SA then Temp:=Temp+1550;
                                                   If EA then Temp:=Temp+2000;
                                                End
                                            Else
                                                If HD<18 then
                                                    Begin
                                                       Temp:=3000+(30*HP);
                                                       Temp:=Temp+(2100*(Card(Monster.Resists)));
                                                       If SA then Temp:=Temp+2100;
                                                       If EA then Temp:=Temp+2500;
                                                    End
                                                Else
                                                    If HD<20 then
                                                        Begin
                                                           Temp:=4000+(35*HP);
                                                           Temp:=Temp+(2600*(Card(Monster.Resists)));
                                                           If SA then Temp:=Temp+2600;
                                                           If EA then Temp:=Temp+3000;
                                                        End
                                                    Else
                                                        Begin
                                                           Temp:=5000+(40*HP);
                                                           Temp:=Temp+(3100*(Card(Monster.Resists)));
                                                           If SA then Temp:=Temp+3100;
                                                           If EA then Temp:=Temp+3500;
                                                        End;
  If Monster.Breath_Weapon in [Fire,Frost,Electricity,LvlDrain,Magic] then Temp:=Temp+(Group.Max_HP[Number]*10);
  If Monster.Gaze_Weapon in [Fire,Frost,Electricity,LvlDrain,Magic] then Temp:=Temp+(Group.Max_HP[Number]*10);
  Temp:=Temp+(200*Monster.highest.Cleric_Spell);
  Temp:=Temp+(300*Monster.highest.Wizard_Spell);
  Temp:=Temp+(-15)*(Monster.Armor_Class-10);
  Experience:=Temp;
End;  { Experience }
End.  { Experience }

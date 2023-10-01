$      write sys$output "Compiling LibRtl.pas"
$      pas [jgetzin]LibRtl
$      write sys$output "Compiling SmgRtl.pas"
$      pas [jgetzin]SmgRtl
$      write sys$output "Compiling StrRtl.pas"
$      pas [jgetzin]StrRtl
$      write sys$output "Compiling Types.pas"
$      pas [jgetzin]Types
$      write sys$output "Compiling Stonequest.pas"
$      pas [jgetzin]Stonequest
$      write sys$output "Compiling AdminUtils.pas"
$      pas [jgetzin]AdminUtils
$      write sys$output "Compiling Camp.pas"
$      pas [jgetzin]Camp
$      write sys$output "Compiling Casino.pas"
$      pas [jgetzin]Casino
$      write sys$output "Compiling Character.pas"
$      pas [jgetzin]Character
$      write sys$output "Compiling CharacterAttacks.pas"
$      pas [jgetzin]CharacterAttacks
$      write sys$output "Compiling Church.pas"
$      pas [jgetzin]Church
$      write sys$output "Compiling Compute.pas"
$      pas [jgetzin]Compute
$      write sys$output "Compiling Craps.pas"
$      pas [jgetzin]Craps
$      write sys$output "Compiling Demo.pas"
$      pas [jgetzin]Demo
$      write sys$output "Compiling EditMaze.pas"
$      pas [jgetzin]EditMaze
$      write sys$output "Compiling Encounter.pas"
$      pas [jgetzin]Encounter
$      write sys$output "Compiling Experience.pas"
$      pas [jgetzin]Experience
$      write sys$output "Compiling GiveTreasure.pas"
$      pas [jgetzin]GiveTreasure
$      write sys$output "Compiling Help.pas"
$      pas [jgetzin]Help
$      write sys$output "Compiling Hours.pas"
$      pas [jgetzin]Hours
$      write sys$output "Compiling Inn.pas"
$      pas [jgetzin]Inn
$      write sys$output "Compiling Io.pas"
$      pas [jgetzin]Io
$      write sys$output "Compiling Items.pas"
$      pas [jgetzin]Items
$      write sys$output "Compiling Keyboard.pas"
$      pas [jgetzin]Keyboard
$      write sys$output "Compiling Kyrn.pas"
$      pas [jgetzin]Kyrn
$      write sys$output "Compiling Maze.pas"
$      pas [jgetzin]Maze
$      write sys$output "Compiling Messages.pas"
$      pas [jgetzin]Messages
$      write sys$output "Compiling Monster.pas"
$      pas [jgetzin]Monster
$      write sys$output "Compiling MonsterAttack.pas"
$      pas [jgetzin]MonsterAttack
$      write sys$output "Compiling PicEdit.pas"
$      pas [jgetzin]PicEdit
$      write sys$output "Compiling PickPocket.pas"
$      pas [jgetzin]PickPocket
$      write sys$output "Compiling PlaceStack.pas"
$      pas [jgetzin]PlaceStack
$      write sys$output "Compiling PrintChar.pas"
$      pas [jgetzin]PrintChar
$      write sys$output "Compiling PrintCharSpell.pas"
$      pas [jgetzin]PrintCharSpell
$      write sys$output "Compiling Random.pas"
$      pas [jgetzin]Random
$      write sys$output "Compiling Scores.pas"
$      pas [jgetzin]Scores
$      write sys$output "Compiling Shell_Out.pas"
$      pas [jgetzin]Shell_Out
$      write sys$output "Compiling Slots.pas"
$      pas [jgetzin]Slots
$      write sys$output "Compiling Store.pas"
$      pas [jgetzin]Store
$      write sys$output "Compiling Tables.pas"
$      pas [jgetzin]Tables
$      write sys$output "Compiling Tavern.pas"
$      pas [jgetzin]Tavern
$      write sys$output "Compiling Training.pas"
$      pas [jgetzin]Training
$      write sys$output "Compiling Treasure.pas"
$      pas [jgetzin]Treasure
$      write sys$output "Compiling View.pas"
$      pas [jgetzin]View
$      write sys$output "Compiling Windows.pas"
$      pas [jgetzin]Windows
$      write sys$output "Compiling PlayerUtils.pas"
$      pas [jgetzin]PlayerUtils
$      write sys$output "Assembling Handler.mar"
$      mac [jgetzin]Handler
$!
$      write sys$output "Purging old OBJ files..."
$      purge *.obj
$!
$      write sys$output "Linking ..."
$!
$!
$      Link Camp,Casino,Character,CharacterAttacks,Church,Compute,Craps,-
       Demo,EditMaze,Encounter,Experience,Keyboard,Random,-
       GiveTreasure,Help,Hours,Inn,Io,Items,Tables,PrintCharSpell,-
       Kyrn,LibRtl,Maze,Messages,Monster,MonsterAttack,PicEdit,PickPocket,-
       PlaceStack,PrintChar,Scores,Shell_Out,Slots,SmgRtl,Stonequest,-
       AdminUtils,PlayerUtils,Store,StrRtl,Tavern,Training,Treasure,-
       Types,View,Windows,Handler /EXE=StoneQuest.exe
$!
$      write sys$output "Purging old EXE files..."
$      purge *.exe
$!
$      write sys$output "Done!"
$!

$      write sys$output "Compiling LibRtl.pas"
$      pas/DEBUG/NOOPTIMIZE LibRtl
$      write sys$output "Compiling SmgRtl.pas"
$      pas/DEBUG/NOOPTIMIZE SmgRtl
$      write sys$output "Compiling StrRtl.pas"
$      pas/DEBUG/NOOPTIMIZE StrRtl
$      write sys$output "Compiling Types.pas"
$      pas/DEBUG/NOOPTIMIZE Types
$      write sys$output "Compiling PriorityQueue.pas"
$      pas/DEBUG/NOOPTIMIZE PriorityQueue
$      write sys$output "Compiling Stonequest.pas"
$      pas/DEBUG/NOOPTIMIZE Stonequest
$      write sys$output "Compiling AdminUtils.pas"
$      pas/DEBUG/NOOPTIMIZE AdminUtils
$      write sys$output "Compiling Camp.pas"
$      pas/DEBUG/NOOPTIMIZE Camp
$      write sys$output "Compiling Casino.pas"
$      pas/DEBUG/NOOPTIMIZE Casino
$      write sys$output "Compiling Character.pas"
$      pas/DEBUG/NOOPTIMIZE Character
$      write sys$output "Compiling CharacterAttacks.pas"
$      pas/DEBUG/NOOPTIMIZE CharacterAttacks
$      write sys$output "Compiling Church.pas"
$      pas/DEBUG/NOOPTIMIZE Church
$      write sys$output "Compiling Compute.pas"
$      pas/DEBUG/NOOPTIMIZE Compute
$      write sys$output "Compiling Craps.pas"
$      pas/DEBUG/NOOPTIMIZE Craps
$      write sys$output "Compiling Demo.pas"
$      pas/DEBUG/NOOPTIMIZE Demo
$      write sys$output "Compiling EditMaze.pas"
$      pas/DEBUG/NOOPTIMIZE EditMaze
$      write sys$output "Compiling Encounter.pas"
$      pas/DEBUG/NOOPTIMIZE Encounter
$      write sys$output "Compiling Experience.pas"
$      pas/DEBUG/NOOPTIMIZE Experience
$      write sys$output "Compiling Files.pas"
$      pas/DEBUG/NOOPTIMIZE Files
$      write sys$output "Compiling GiveTreasure.pas"
$      pas/DEBUG/NOOPTIMIZE GiveTreasure
$      write sys$output "Compiling Help.pas"
$      pas/DEBUG/NOOPTIMIZE Help
$      write sys$output "Compiling Hours.pas"
$      pas/DEBUG/NOOPTIMIZE Hours
$      write sys$output "Compiling Inn.pas"
$      pas/DEBUG/NOOPTIMIZE Inn
$      write sys$output "Compiling Io.pas"
$      pas/DEBUG/NOOPTIMIZE Io
$      write sys$output "Compiling Items.pas"
$      pas/DEBUG/NOOPTIMIZE Items
$      write sys$output "Compiling Keyboard.pas"
$      pas/DEBUG/NOOPTIMIZE Keyboard
$      write sys$output "Compiling Kyrn.pas"
$      pas/DEBUG/NOOPTIMIZE Kyrn
$      write sys$output "Compiling Maze.pas"
$      pas/DEBUG/NOOPTIMIZE Maze
$      write sys$output "Compiling MazeSpecial.pas"
$      pas/DEBUG/NOOPTIMIZE MazeSpecial
$      write sys$output "Compiling Messages.pas"
$      pas/DEBUG/NOOPTIMIZE Messages
$      write sys$output "Compiling Monster.pas"
$      pas/DEBUG/NOOPTIMIZE Monster
$      write sys$output "Compiling MonsterAttack.pas"
$      pas/DEBUG/NOOPTIMIZE MonsterAttack
$      write sys$output "Compiling PerspectiveGeometry.pas"
$      pas/DEBUG/NOOPTIMIZE PerspectiveGeometry
$      write sys$output "Compiling PicEdit.pas"
$      pas/DEBUG/NOOPTIMIZE PicEdit
$      write sys$output "Compiling PickPocket.pas"
$      pas/DEBUG/NOOPTIMIZE PickPocket
$      write sys$output "Compiling PlaceStack.pas"
$      pas/DEBUG/NOOPTIMIZE PlaceStack
$      write sys$output "Compiling PlayerUtils.pas"
$      pas/DEBUG/NOOPTIMIZE PlayerUtils
$      write sys$output "Compiling PrintChar.pas"
$      pas/DEBUG/NOOPTIMIZE PrintChar
$      write sys$output "Compiling PrintCharSpell.pas"
$      pas/DEBUG/NOOPTIMIZE PrintCharSpell
$      write sys$output "Compiling Random.pas"
$      pas/DEBUG/NOOPTIMIZE Random
$      write sys$output "Compiling Scores.pas"
$      pas/DEBUG/NOOPTIMIZE Scores
$      write sys$output "Compiling Shell_Out.pas"
$      pas/DEBUG/NOOPTIMIZE Shell_Out
$      write sys$output "Compiling Slots.pas"
$      pas/DEBUG/NOOPTIMIZE Slots
$      write sys$output "Compiling Store.pas"
$      pas/DEBUG/NOOPTIMIZE Store
$      write sys$output "Compiling Tables.pas"
$      pas/DEBUG/NOOPTIMIZE Tables
$      write sys$output "Compiling Tavern.pas"
$      pas/DEBUG/NOOPTIMIZE Tavern
$      write sys$output "Compiling Training.pas"
$      pas/DEBUG/NOOPTIMIZE Training
$      write sys$output "Compiling Treasure.pas"
$      pas/DEBUG/NOOPTIMIZE Treasure
$      write sys$output "Compiling View.pas"
$      pas/DEBUG/NOOPTIMIZE View
$      write sys$output "Compiling View3d.pas"
$      pas/DEBUG/NOOPTIMIZE View3d
$      write sys$output "Compiling ViewShared.pas"
$      pas/DEBUG/NOOPTIMIZE ViewShared
$      write sys$output "Compiling Windows.pas"
$      pas/DEBUG/NOOPTIMIZE Windows
$      write sys$output "Assembling Handler.mar"
$      mac Handler
$!
$      write sys$output "Purging old OBJ files..."
$      purge *.obj
$!
$      write sys$output "Linking ..."
$!
$!
$      Link/debug Camp,Casino,Character,CharacterAttacks,Church,Compute,Craps,-
       Demo,EditMaze,Encounter,Experience,Keyboard,Random,Files,View3d,-
       GiveTreasure,Help,Hours,Inn,Io,Items,Tables,PrintCharSpell,-
       Kyrn,LibRtl,Maze,Messages,Monster,MonsterAttack,PicEdit,PickPocket,-
       PlaceStack,PrintChar,Scores,Shell_Out,Slots,SmgRtl,Stonequest,-
       AdminUtils,PlayerUtils,Store,StrRtl,Tavern,Training,Treasure,-
       ViewShared,PriorityQueue,MazeSpecial,-
       PerspectiveGeometry,Types,View,Windows,Handler /EXE=StoneQuest.exe
$!
$      write sys$output "Purging old EXE files..."
$      purge *.exe
$!
$      write sys$output "Done!"
$!

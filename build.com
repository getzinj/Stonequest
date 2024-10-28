! Copyright (C) 2024 Jeffrey Getzin.
! Licensed under the GNU General Public License v3.0 with additional terms.
! See the LICENSE file in the repository root for details.

$      write sys$output "Compiling LibRtl.pas"
$      pas LibRtl
$      write sys$output "Compiling SmgRtl.pas"
$      pas SmgRtl
$      write sys$output "Compiling StrRtl.pas"
$      pas StrRtl
$      write sys$output "Compiling Ranges.pas"
$      pas Ranges
$      write sys$output "Compiling Types.pas"
$      pas Types
$      write sys$output "Compiling PriorityQueue.pas"
$      pas PriorityQueue
$      write sys$output "Compiling Stonequest.pas"
$      pas Stonequest
$      write sys$output "Compiling AdminUtils.pas"
$      pas AdminUtils
$      write sys$output "Compiling ArmorClass.pas"
$      pas ArmorClass
$      write sys$output "Compiling Camp.pas"
$      pas Camp
$      write sys$output "Compiling Casino.pas"
$      pas Casino
$      write sys$output "Compiling Character.pas"
$      pas Character
$      write sys$output "Compiling CharacterAttacks.pas"
$      pas CharacterAttacks
$      write sys$output "Compiling CharacterAttacksSpells.pas"
$      pas CharacterAttacksSpells
$      write sys$output "Compiling Church.pas"
$      pas Church
$      write sys$output "Compiling Compute.pas"
$      pas Compute
$      write sys$output "Compiling Craps.pas"
$      pas Craps
$      write sys$output "Compiling Demo.pas"
$      pas Demo
$      write sys$output "Compiling EditMaze.pas"
$      pas EditMaze
$      write sys$output "Compiling Encounter.pas"
$      pas Encounter
$      write sys$output "Compiling Experience.pas"
$      pas Experience
$      write sys$output "Compiling Files.pas"
$      pas Files
$      write sys$output "Compiling GiveTreasure.pas"
$      pas GiveTreasure
$      write sys$output "Compiling Help.pas"
$      pas Help
$      write sys$output "Compiling Hours.pas"
$      pas Hours
$      write sys$output "Compiling Inn.pas"
$      pas Inn
$      write sys$output "Compiling Io.pas"
$      pas Io
$      write sys$output "Compiling Items.pas"
$      pas Items
$      write sys$output "Compiling Keyboard.pas"
$      pas Keyboard
$      write sys$output "Compiling Kyrn.pas"
$      pas Kyrn
$      write sys$output "Compiling Maze.pas"
$      pas Maze
$      write sys$output "Compiling MazeSpecial.pas"
$      pas MazeSpecial
$      write sys$output "Compiling Messages.pas"
$      pas Messages
$      write sys$output "Compiling Monster.pas"
$      pas Monster
$      write sys$output "Compiling MonsterAttack.pas"
$      pas MonsterAttack
$      write sys$output "Compiling MonsterAttackSpells.pas"
$      pas MonsterAttackSpells
$      write sys$output "Compiling PerspectiveGeometry.pas"
$      pas PerspectiveGeometry
$      write sys$output "Compiling PicEdit.pas"
$      pas PicEdit
$      write sys$output "Compiling PickPocket.pas"
$      pas PickPocket
$      write sys$output "Compiling PlaceStack.pas"
$      pas PlaceStack
$      write sys$output "Compiling PlayerUtils.pas"
$      pas PlayerUtils
$      write sys$output "Compiling PrintChar.pas"
$      pas PrintChar
$      write sys$output "Compiling PrintCharSpell.pas"
$      pas PrintCharSpell
$      write sys$output "Compiling Random.pas"
$      pas Random
$      write sys$output "Compiling Scores.pas"
$      pas Scores
$      write sys$output "Compiling Shell_Out.pas"
$      pas Shell_Out
$      write sys$output "Compiling Slots.pas"
$      pas Slots
$      write sys$output "Compiling Store.pas"
$      pas Store
$      write sys$output "Compiling Tables.pas"
$      pas Tables
$      write sys$output "Compiling Tavern.pas"
$      pas Tavern
$      write sys$output "Compiling Training.pas"
$      pas Training
$      write sys$output "Compiling Treasure.pas"
$      pas Treasure
$      write sys$output "Compiling View.pas"
$      pas View
$      write sys$output "Compiling View3d.pas"
$      pas View3d
$      write sys$output "Compiling ViewShared.pas"
$      pas ViewShared
$      write sys$output "Compiling Windows.pas"
$      pas Windows
$      write sys$output "Assembling Handler.mar"
$      mac Handler
$!
$      write sys$output "Purging old OBJ files..."
$      purge *.obj
$!
$      write sys$output "Linking ..."
$!
$!
$      Link Camp,Casino,Character,CharacterAttacks,Church,Compute,Craps,-
       Demo,EditMaze,Encounter,Experience,Keyboard,Random,Files,View3d,-
       GiveTreasure,Help,Hours,Inn,Io,Items,Tables,PrintCharSpell,-
       Kyrn,LibRtl,Maze,Messages,Monster,MonsterAttack,PicEdit,PickPocket,-
       PlaceStack,PrintChar,Scores,Shell_Out,Slots,SmgRtl,Stonequest,-
       AdminUtils,PlayerUtils,Store,StrRtl,Tavern,Training,Treasure,-
       ViewShared,PriorityQueue,MazeSpecial,Ranges,CharacterAttacksSpells,-
       MonsterAttackSpells,ArmorClass, -
       PerspectiveGeometry,Types,View,Windows,Handler /EXE=StoneQuest.exe
$!
$      write sys$output "Purging old EXE files..."
$      purge *.exe
$!
$      write sys$output "Done!"
$!

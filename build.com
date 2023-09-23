$      pas LibRtl
$      pas SmgRtl
$      pas StrRtl
$      pas Types
$      pas Stonequest
$      pas Camp
$      pas Casino
$      pas Character
$      pas CharacterAttacks
$      pas Church
$      pas Compute
$      pas Craps
$      pas Demo
$      pas EditMaze
$      pas Encounter
$      pas Experience
$      pas GiveTreasure
$      pas Help
$      pas Hours
$      pas Inn
$      pas Io
$      pas Items
$      pas Kyrn
$      pas Maze
$      pas Messages
$      pas Monster
$      pas MonsterAttack
$      pas PicEdit
$      pas PickPocket
$      pas PlaceStack
$      pas PrintChar
$      pas Scores
$      pas Shell_Out
$      pas Slots
$      pas Store
$      pas Tavern
$      pas Training
$      pas Treasure
$      pas View
$      pas Windows
$      pas Handler


$      Link Camp,Casino,Character,CharacterAttacks,Church,Compute,Craps,-
       Demo,EditMaze,Encounter,Experience,-
       GiveTreasure,Help,Hours,Inn,Io,Items,-
       Kyrn,LibRtl,Maze,Messages,Monster,MonsterAttack,PicEdit,PickPocket,-
       PlaceStack,PrintChar,Scores,Shell_Out,Slots,SmgRtl,Stonequest,-
       Store,StrRtl,Tavern,Training,Treasure,-
       Types,View,Windows,Handler /EXE=StoneQuest.exe


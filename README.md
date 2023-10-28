# StoneQuest

This is Stonequest, a game.  But it's not just any game - far from it!  This
game was originally based on the Sir-Tech game, "Wizardry", for the Apple II
computer.  At the time, "Wizardry" was the best.  I wrote "Stonequest" just
to see if it could be done.  It could.  (But it ain't easy, let me tell you!)

But then I was inspired by other games that were becoming legends, such as
"The Bard's Tale" by Electronic Arts, and Moria, a public domain game.  I
attempted to capture the best of these games within the framework of
"Wizardry".  The result is a game that I feel is the best fantasy/simulation
around, and the biggest source of plagerized *(sic)* material in the world!  I feel
that this game contains the best of all three of the above games, plus all
the other little odds and ends I threw in on a warped whim.

I apologize for the sorry lack of documentation in this game.  When I first
started there was none; I've tried to add some since then.  I've also tried
to make my variable and procedure names more self-explanatory.  I wish the
best of luck to all those who try to modify it!

This game is dedicated to the memory of my late grandmother, Jenny Mayer 
on this day, 10/13/1988.

## Build/Run Environment

This application is written for VAX/VMS, so you must find an emulator. I use
the OpenVMS hobbyist license, but other options exist, such as
[The Computer History Simulation Project](https://github.com/simh/simh).

## Building

To build on a VAX/VMS-type system, simply execute the BUILD.COM DCL script by
typing ```@Build```.

If you've manually recompiled one of the files, you can skip recompilation and
go write to the linking by running @Link.com by typing ```@Link```.

## Running

Execute the command ```run stonequest```.

## Debugging

### Building
To build a debug build and run it, execute the BUILDDEBUG.COM DCL script by
typing ```@BuildDebug```.

### Executing
To execute a build created for debugging, simply execute the command `run stonequest`
as normal. You will automatically enter the debugger.

To execute a debug build without debugging, you can execute the command
`run/nodebug stonequest`.

For more information on debugging on the VAX, please check out
the [OpenVMS Debugger Manual](https://docs.vmssoftware.com/docs/HP_OpenVMS_Debugger.pdf).



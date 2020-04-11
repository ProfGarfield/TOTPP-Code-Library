Development Readme.  This will have notes that can be removed once development is complete.

Search for ==IMPLEMENT== to find known places where code is incomplete


==========================================================

Readme for the legacyEventEngine for TOTPP with Lua Events.

The event engine comes with the following files:

events.lua
getLegacyEvents.lua
legacyEventEngine.lua
readme.txt

It also depends on having access to 
functions.lua
civlua.lua
in the lua directory of Test of Time

====================================

events.lua

====================================

The events.lua file is where you will write any additional lua code for your events (unless you decide to 'require' code from other files.  The events.lua file provided here has all the required references and integration with legacyEventEngine.lua in order to use a converted events.txt (see getLegacyEvents.lua)

====================================

legacyEventEngine.lua

====================================

The legacyEventEngine.lua file takes a converted events.txt and makes it work with the TOTPP Lua events system.  These are the following things you may need to change in this file:


local legacyEventTableName = "getLegacyEvents.lua"

This variable tells what the file name is for the converted events.txt, so the legacy Event Engine can find and use it.  It tries to find the file name in the folder it is in.  If you leave the value as "getLegacyEvents.lua", the events will be converted by "getLegacyEvents.lua" at the time you load the scenario.  This may be desirable during development and testing, but is probably not a good idea for the final product.  (see getLegacyEvents.lua for conversion information)



local failSearchWithError=false

If you change this variable to true, then if a text-to-game-object function fails to find the object corresponding to a name, it will print an error to the lua console, rather than fail gracefully and invisibly.  This may be useful for debugging, or so that players actually know an event failed.




=======================================

getLegacyEvents.lua

=======================================

This file converts one or more (in the case of scenarios using batch files to change events) legacy events.txt files into a Legacy Events Table usable by the Legacy Event Engine.

You may need to change the following lines in this file:


--
-- set writeTextFile=true if you want to output the table into a text file,
-- false if it should just be returned
local writeTextFile=false
-- set showEventParsed=true to print the @ENDIF line number every time an event is
-- parsed without an error.  This could help for debugging 
local showEventParsed = true
-- Change this if the events text file you are converting has a different name
-- file is relative to the current directory
local eventTextFileName="events.txt"
-- Change this if you don't want to use the default name for the output file
-- The OS time should hopefully prevent file overwrites
local eventOutputFileName=tostring(os.time()).."legacyEvents.lua"
-- If the scenario has a batch file, and the batch file changes the events,
-- put the turns that these events are valid into batchInfo
local batchInfo = nil
-- For example
-- batchInfo = {{[1]=firstValidTurn,[2]=lastValidTurn}}
-- batchInfo = {{[1]=firstValidTurn1,[2]=lastValidTurn1},{[1]=firstValidTurn2,[2]=lastValidTurn2},}
-- Then the trigger will only run on turns between a firstValidTurn and a LastValidTurn
-- If events change for some reason other than the turn, ask for help in the forums to make the events work

-- If you are trying to convert several sets of events changed by a batch file, add extra entries to the 
-- eventsToConvert table
local eventsToConvert={{eTFN=eventTextFileName,bI=batchInfo},--[[{eTFN=fileName2,bI=batchInfo2},]]}


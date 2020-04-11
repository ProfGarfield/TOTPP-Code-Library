-- This events.lua file is set up integrated with the legacyEventEngine
-- If you want to update an older scenario with Lua events, or leverage
-- your existing knowledge of the old events system, begin with this
-- sample events file

-- If you want to make functions available in the console, copy them
-- into the console table (which is a global variable)
-- e.g. console.myFunction = myFunction
console={}

-- This pulls in code and functionality from other .lua files
-- Files are checked for in Test of Time\lua and the directory
-- in which this event file is located
-- If extra functions are in myExtraFunctions.lua
-- local xtr=require("myExtraFunctions")
-- local myExtraOutput = xtr.myExtraFunction(input1,input2)
local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
local scenarioFolderPath = string.gsub(eventsPath, "events.lua", "?.lua")
if string.find(package.path, scenarioFolderPath, 1, true) == nil then
   package.path = package.path .. ";" .. scenarioFolderPath
end

local civlua = require "civlua"
local func = require "functions"
local legacy = require("legacyEventEngine")

-- the "state table" contains data to be saved in the saved game file
-- Anything you do to the state table in this script will be overwritten
-- when the game is loaded.  Put anything that has to be done to initialize
-- the state table in the civ.scen.onLoad function
-- Everything must also go here, to initialize for the first time
local state = {}
state.legacyState=state.legacyState or {}
g_LegacyState = state.legacyState

local justOnce = function (key, f) civlua.justOnce(civlua.property(state, key), f)
end





civ.scen.onCityProduction(function (city, prod) 
    legacy.doCityProductionEvents(city,prod)
end)
  

civ.scen.onNegotiation(function (talker,listener)
    legacy.doNegotiationEvents(talker,listener)
    return legacy.canNegotiate(talker,listener)
end)

civ.scen.onTurn(function (turn)
    legacy.onTurnEventsAndMaintenance(turn)
end)

civ.scen.onUnitKilled(function (loser, winner)
   legacy.doUnitKilledEvents(loser,winner) 
end)

civ.scen.onBribeUnit(function (unit, previousOwner) 
    legacy.doBribeUnitEvents(unit,previousOwner)   
end)

civ.scen.onCityTaken(function (city,defender)
    legacy.doCityTakenEvents(city,defender)
end)

civ.scen.onCityDestroyed(function (city) 
   legacy.doCityDestroyedEvents(city) 
end)

civ.scen.onSchism(function(tribe)
    -- must return a boolean in this function
    return legacy.doNoSchismEvents(tribe)
end)

civ.scen.onLoad(function (buffer) 
    state = civlua.unserialize(buffer)
    state.legacyState = state.legacyState or {}
    -- g_LegacyState is supposed to be a global variable
    -- that way, the legacyEventEngine has access to the state table
    g_LegacyState = state.legacyState
end)
civ.scen.onCentauriArrival(function (tribe) 
    legacy.doAlphaCentauriArrivalEvents(tribe)
end)

civ.scen.onGameEnds(function(reason)
    return legacy.endTheGame(reason)
end)

 civ.scen.onSave(function () return civlua.serialize(state) end) 
 civ.scen.onScenarioLoaded(function ()
    legacy.doScenarioLoadedEvents()
end)

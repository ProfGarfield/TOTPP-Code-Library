-- Events Template For Scenarios
print "You should see this in lua console if this worked"

local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
local scenarioFolderPath = string.gsub(eventsPath, "events.lua", "?.lua")
if string.find(package.path, scenarioFolderPath, 1, true) == nil then
   --package.path = package.path .. ";" .. scenarioFolderPath
   package.path =scenarioFolderPath
end

--[[
console={}
musicFolder= string.gsub(eventsPath,civ.getToTDir(),"..")
musicFolder= string.gsub(musicFolder,"events.lua","").."\\Music"
console.musicFolder = musicFolder
]]

local civlua = require "civlua"
local func = require "functions"
local gen = require("generalLibrary")
local flag = require("flag")
local counter = require("counter")
local text = require("text")
local legacy = require("legacyEventEngine")
local legacyEventsTable = require("getLegacyEvents")
legacy.supplyLegacyEventsTable(legacyEventsTable)
local promotion = require("promotion")
local state = {}
local object = require("object")
--local munitions = require("munitions")
--local kAttack = require("munitionsPrimaryAttack")
--local backspaceAttack = require("munitionsSecondaryAttack")
local keyboard = require("keyboard")
local canBuildFunctions = require("canBuild")
local canBuildSettings = require("canBuildSettings")
-- define flags and counters here
for i=0,7 do
    flag.define("tribe"..tostring(i).."AfterProductionNotDone",true)
end


-- This function is is a place for functions that link to the
-- state table (usually module.linkState) as well as anything
-- else that should be done both onLoad and during the event
-- initialization
local function linkStateTableToModules()
    -- link the state table to the flags module
    state.flagTable = state.flagTable or  {}
    flag.linkState(state.flagTable)
    flag.initializeFlags()
    -- link the state table to the counter module
    state.counterTable = state.counterTable or {}
    counter.linkState(state.counterTable)
    counter.initializeCounters()
    -- link the state table to the text module
    state.textTable = state.textTable or {}
    text.linkState(state.textTable)
    -- create a justOnce part of the state table (so there is no risk of conflicting keys)
    state.justOnce = state.justOnce or {}
    -- link the state table to the legacyEventEngine
    state.legacyState = state.legacyState or {}
    legacy.linkState(state.legacyState)
end
linkStateTableToModules()

local justOnce = function (key, f) civlua.justOnce(civlua.property(state.justOnce, key), f)
end


local param = require("parameters")-- parameters.lua is a separate file to store scenario parameters in.
-- You could have them here as well, but it might contribute to cluttering this file
-- If you put some of your code in other files, you may also need to require the parameters there also


local object = require("object") -- object.lua is a file with names for unitTypes, improvementTypes, tribes, etc.

local function doOnTurn(turn)--> void
    -- this makes doAfterProduction work
    for i=0,7 do
        flag.setTrue("tribe"..tostring(i).."AfterProductionNotDone")
    end
    legacy.onTurnEventsAndMaintenance(turn)

end

-- Occurs when the first unit is activated after production
-- If a tribe has no active unit after production, this
-- event will not run.  If this is likely in your scenario,
-- you will have to compensate.
-- Perhaps create a unit for the next tribe in line, and then delete that unit
-- when it is activated
local function doAfterProduction(turn,tribe)-->void

end


-- This will only run when a unit is killed in combat (i.e. not when an event
-- 'kills' a unit)
-- note that if the aggressor loses, aggressor.location will not work
local function doWhenUnitKilledInCombat(loser,winner,aggressor,victim,aggressorLocation,
    victimVetStatus,aggressorVetStatus)-->void
    --promotion.unitKilledInCombat(loser,winner,aggressor,victim,aggressorLocation,
    --victimVetStatus,aggressorVetStatus)

end

-- this will run any time a unit is killed, either in combat or by event
-- this will be necessary in any other event that 'kills' a unit
local function doOnUnitKilled(loser,winner)--> void
   legacy.doUnitKilledEvents(loser,winner) 

end

local function doOnBribeUnit(unit,previousOwner)
    legacy.doBribeUnitEvents(unit,previousOwner)
end

-- This is done when the game is loaded, before the rules.txt
-- are loaded
local function doOnLoad(buffer)-->void
    state = civlua.unserialize(buffer)
    linkStateTableToModules()

end

-- This is done when the game is loaded, after the rules.txt
-- are loaded
local function doOnScenarioLoaded()-->void
    legacy.doScenarioLoadedEvents()

end

local function doOnSave() --> string

    return civlua.serialize(state)
end

local function doOnCityTaken(city,defender) -->void
    legacy.doCityTakenEvents(city,defender)

end

local function doOnCityDestroyed(city) --> void
    legacy.doCityDestroyedEvents(city)
end

local function doOnCityProduction(city,prod) -->void
    legacy.doCityProductionEvents(city,prod)
end

local function doOnActivateUnit(unit,source) --> void

end

local function doOnKeyPress(keyCode)
    print(keyCode)
    if keyCode == 72 --[[h]] then
    end
    if keyCode == 73 --[[i]] then
    end
    if keyCode == keyboard.k --[[k]] and civ.getActiveUnit() then
        --munitions.doMunition(civ.getActiveUnit(),kAttack,doOnActivateUnit)
        return
    end
    if keyCode == keyboard.backspace and civ.getActiveUnit() then
        --munitions.doMunition(civ.getActiveUnit(),backspaceAttack,doOnActivateUnit)
        return
    end
end


local function doOnCityFounded(city) --> void

end

-- if true, city can build item, if false, city can't build item
local function doOnCanBuild(defaultBuildFunction,city,item) --> boolean

    return canBuildFunctions.customCanBuild(defaultBuildFunction,city,item)
end

-- these variables expand the functionality and information for combat
--
-- this variable tells doOnResolveCombat if this is the first round of
-- combat (it is reset by the onUnitKilled function)
local firstRoundOfCombat = true
local aggressorVeteranStatusBeforeCombat = false
local aggressorLocation = nil -- if the aggressor dies, this information isn't available in onUnitKilled
local victimVeteranStatusBeforeCombat = false
local function doOnResolveCombat(defaultResolutionFunction,defender,attacker)
    -- this if statement will only be executed once per combat
    if firstRoundOfCombat then
        firstRoundOfCombat = false
        aggressorVeteranStatusBeforeCombat = attacker.veteran
        aggressorLocation = attacker.location
        victimVeteranStatusBeforeCombat = defender.veteran

    end -- firstRoundOfCombat
    return defaultResolutionFunction(defender,attacker)
end

civ.scen.onUnitKilled(function(loser,winner)
    -- reset the first round of combat information
    firstRoundOfCombat = true
    if loser.owner == civ.getCurrentTribe() then
        aggressor = loser
        victim = winner
    else
        aggressor = winner
        victim = loser
    end
    doWhenUnitKilledInCombat(loser,winner,aggressor,victim,aggressorLocation,victimVeteranStatusBeforeCombat,
        aggressorVeteranStatusBeforeCombat)
    doOnUnitKilled(loser,winner)
end)

civ.scen.onCityTaken(doOnCityTaken)

civ.scen.onResolveCombat(doOnResolveCombat)

civ.scen.onCityProduction(doOnCityProduction)

civ.scen.onKeyPress(doOnKeyPress)

civ.scen.onLoad(doOnLoad)

civ.scen.onSave(doOnSave) 

civ.scen.onScenarioLoaded(doOnScenarioLoaded)

civ.scen.onActivateUnit(function(unit,source)     
    -- this if statement makes doAfterProduction work
    if flag.value("tribe"..tostring(civ.getCurrentTribe().id).."AfterProductionNotDone") then
        doAfterProduction(civ.getTurn(),civ.getCurrentTribe())
        flag.setFalse("tribe"..tostring(civ.getCurrentTribe().id).."AfterProductionNotDone")
    end
    doOnActivateUnit(unit,source)
end)
gen.linkActivationFunction(doOnActivateUnit)

civ.scen.onCityFounded(doOnCityFounded)

civ.scen.onBribeUnit(doOnBribeUnit)

civ.scen.onCanBuild(doOnCanBuild)

-- Note: there have been reports of the onNegotiation event
-- not forbidding contact when it should.  Beware.
civ.scen.onNegotiation(function (talker,listener)
    legacy.doNegotiationEvents(talker,listener)
    return legacy.canNegotiate(talker,listener)
end)

civ.scen.onSchism(function(tribe)
    -- must return a boolean in this function
    return legacy.doNoSchismEvents(tribe)
end)

civ.scen.onCentauriArrival(function (tribe) 
    legacy.doAlphaCentauriArrivalEvents(tribe)
end)

civ.scen.onGameEnds(function(reason)
    return legacy.endTheGame(reason)
end)

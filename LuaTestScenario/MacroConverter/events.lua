-- minimal converter of legacy events to lua,
-- designed so that events can use lua and avoid any bugs
-- introduced by TOTPP (though there may be bugs in the Lua implementation
-- and functions, particularly the negotiation event)
print "You should see this in lua console if this worked"

local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
local scenarioFolderPath = string.gsub(eventsPath, "events.lua", "?.lua")
if string.find(package.path, scenarioFolderPath, 1, true) == nil then
   package.path = package.path .. ";" .. scenarioFolderPath
end

local currentFolder = string.gsub(eventsPath,"events.lua","")
-- get road multiplier, and put it back into the game
local function restoreRoadMultiplier()
    local function removeTrailingSpaces(line)
        while line:sub(-1)==" " do
            line = line:sub(0,-2)
        end
        return line
    end
    -- make true when the line "@COSMIC" is read, since the
    -- very next line is the Road Movement Multiplier
    local cosmicRead = false
    -- if cosmic2 is found, we probably don't want to mess with the multipliers
    -- since the scenario designer has probably already accounted for them
    local cosmic2Found = false
    local roadMultiplier = nil
    for line in io.lines(currentFolder.."\\".."rules.txt") do
        -- must remove everything after the semicolon, as it is not needed
        local semicolonLoc = string.find(line,";")
        if semicolonLoc then
            line = line:sub(1,semicolonLoc-1)
        end
        line = removeTrailingSpaces(line)
        if line == "@COSMIC" then
            cosmicRead = true
        elseif cosmicRead then
            -- the first line of @COSMIC is the road multiplier
            -- since everything after the semicolon is removed, and then
            -- the trailing spaces were removed, all that is left in line
            -- is a string only with the road multiplier
            roadMultiplier = tonumber(line)
            cosmicRead = false
        elseif line == "@COSMIC2" then
            cosmic2Found = true
        end
    end
    if roadMultiplier and (not cosmic2Found) then
        totpp.movementMultipliers.road = roadMultiplier
        totpp.movementMultipliers.alpine = roadMultiplier
        totpp.movementMultipliers.river = roadMultiplier
    end
end


local civlua = require "civlua"
local func = require "functions"
local legacy = require("legacyEventEngine")
local getLegacy = require("getLegacyEvents")
legacy.supplyLegacyEventsTable(getLegacy)
local hashes = require("secureHashAlgorithm")
local state = {}
local function linkStateTableToModules()
    -- create a justOnce part of the state table (so there is no risk of conflicting keys)
    state.justOnce = state.justOnce or {}
    -- link the state table to the legacyEventEngine
    state.legacyState = state.legacyState or {}
    legacy.linkState(state.legacyState)
end
linkStateTableToModules()

local justOnce = function (key, f) civlua.justOnce(civlua.property(state.justOnce, key), f)
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
    --restoreRoadMultiplier()
    legacy.doScenarioLoadedEvents(hashes.hash224(civlua.serialize(getLegacy)))

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

civ.scen.onTurn(function(turn)
    legacy.onTurnEventsAndMaintenance(turn)
end)

civ.scen.onUnitKilled(function(loser,winner)
    doOnUnitKilled(loser,winner)
end)

civ.scen.onCityTaken(doOnCityTaken)


civ.scen.onCityProduction(doOnCityProduction)


civ.scen.onLoad(doOnLoad)

civ.scen.onSave(doOnSave) 

civ.scen.onScenarioLoaded(doOnScenarioLoaded)

civ.scen.onBribeUnit(doOnBribeUnit)


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

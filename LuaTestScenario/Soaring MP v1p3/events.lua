-- Events Template For Scenarios
print "You should see this in lua console if this worked"

local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
local scenarioFolderPath = string.gsub(eventsPath, "events.lua", "?.lua")
if string.find(package.path, scenarioFolderPath, 1, true) == nil then
   package.path = package.path .. ";" .. scenarioFolderPath
end


console={}
--[[
musicFolder= string.gsub(eventsPath,civ.getToTDir(),"..")
musicFolder= string.gsub(musicFolder,"events.lua","").."\\Music"
console.musicFolder = musicFolder
]]

local civlua = require "civluaModified"
local func = require "functions"
local gen = require("generalLibrary")
local flag = require("flag")
local counter = require("counter")
local text = require("text")
local legacy = require("legacyEventEngine")
local legacyEventsTable = require("getLegacyEvents")
legacy.supplyLegacyEventsTable(legacyEventsTable)
local state = {}
local object = require("object")
local munitions = require("munitions")
local kAttack = require("munitionsPrimaryAttack")
local backspaceAttack = require("munitionsSecondaryAttack")
local keyboard = require("keyboard")
local canBuildFunctions = require("canBuild")
local canBuildSettings = require("canBuildSettings")
local log = require("log")
local helpkey = require("helpkey")
local diplomacy = require("diplomacy")
local diplomacySettings = require("diplomacySettings")
local cityNames = require("soaringCityNames")

local param = require("parameters")-- parameters.lua is a separate file to store scenario parameters in.
-- You could have them here as well, but it might contribute to cluttering this file
-- If you put some of your code in other files, you may also need to require the parameters there also


local object = require("object") -- object.lua is a file with names for unitTypes, improvementTypes, tribes, etc.
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
    state.logTable = state.logTable or {}
    log.linkState(state.logTable)
end
linkStateTableToModules()

local justOnce = function (key, f) civlua.justOnce(civlua.property(state.justOnce, key), f)
end

-- changes the stats of certain units so they are different for the
-- AI and for Humans
-- use in onScenarioLoaded and AfterProduction
local function setUnitStats(tribe)
    -- AI won't attack powerful rich villages, so reduce their defense
    -- for the AI
    -- AI can't use the strategos attack bonus, so give it a powerful
    -- attack value, HP, and FP, and make it ignore walls 
    -- the equivalent of the old stratego stats, except defense is still 0
    -- 
    if tribe.isHuman then
        object.uRichVillage.defense = 12
        object.uRichVillage.role = 1
        object.uStrategos.attack = 0
        object.uStrategos.firepower = 1
        object.uStrategos.hitpoints = 10
    else
        object.uRichVillage.defense = 0
        object.uRichVillage.role = 6
        object.uStrategos.attack = 28
        object.uStrategos.firepower = 8
        object.uStrategos.hitpoints = 40
    end
end


local function doOnTurn(turn)--> void
    -- this makes doAfterProduction work
    for i=0,7 do
        flag.setTrue("tribe"..tostring(i).."AfterProductionNotDone")
    end
    legacy.onTurnEventsAndMaintenance(turn)
    -- makes sure fertility is set to 0 for all tiles except
    -- colony sites
    for tile in civlua.iterateTiles() do
        if tile.terrainType % 16 == 7 and (not tile.city) then
            tile.fertility = 15
        else
            tile.fertility = 0
        end
    end

end



-- upgrade a colony site, depending on the existing stuff on the tile
local function upgradeColonySite(tile)
    if tile.terrainType % 16 ~= 7 then
        -- tile not a colony site
        return 
    end
    if tile.defender and tile.defender ~= object.tMinorCities then
        -- tile is covered by a tribe's unit
        return
    end
    if tile.city then
        -- tile already has a city, so no upgrades
        return
    end
    if gen.unitTypeOnTile(tile,object.uFortress) and cityNames[gen.getTileID(tile)] then
        local newCity = civ.createCity(object.tMinorCities,tile)
        newCity.name = cityNames[gen.getTileID(newCity.location)]
        civ.addImprovement(newCity,object.iCityWalls)
        -- remove the rich villages
        for unit in newCity.location.units do
            if unit.type == object.uRichVillage then
                civ.deleteUnit(unit)
            end
        end
        return
    end
    local richVillages = 0
    for unit in tile.units do
        if unit.type == object.uRichVillage then
            richVillages = richVillages+1
        end
    end
    if richVillages >= 3 then
        local newUnit = civ.createUnit(object.uFortress,object.tMinorCities,tile)
        newUnit.homeCity = nil
        return
    elseif richVillages >= 1 then
        local newVillage = civ.createUnit(object.uRichVillage,object.tMinorCities,tile)
        newVillage.homeCity = nil
        local newVillage = civ.createUnit(object.uRichVillage,object.tMinorCities,tile)
        newVillage.homeCity = nil
        return
    else
        local newVillage = civ.createUnit(object.uRichVillage,object.tMinorCities,tile)
        newVillage.homeCity = nil
        return
    end
end

-- the AI has a tendency to disband eastern fortresses, so this
-- restores them each turn
local function restoreEasternFortresses(turn)
    local function restoreFortressIfAbsent(x,y,z)
        if not gen.unitTypeOnTile(civ.getTile(x,y,z),object.uEasternFortress) then
            civ.createUnit(object.uEasternFortress,object.tLydians,civ.getTile(x,y,z))
        end
    end
    -- this is where the first Persian Invasion originates on turn 42
    -- The city must be capturable to stop the invasion
    if turn <= 44 then
        -- Magnesia
        restoreFortressIfAbsent(311,75,0)
    else
        for unit in civ.getTile(311,75,0) do
            if unit.type == object.uEasternFortress then
                civ.deleteUnit(unit)
            end
        end
    end
    --Thyatira
    restoreFortressIfAbsent(315,71,0)
    --Sardis
    restoreFortressIfAbsent(318,78,0)
    --Tralles
    restoreFortressIfAbsent(316,94,0)
    --Mylasa
    restoreFortressIfAbsent(319,103,0)
    --Xanthus
    restoreFortressIfAbsent(348,114,0)
    --Colossae
    restoreFortressIfAbsent(352,98,0)
    --Rhoas
    restoreFortressIfAbsent(348,92,0)
    --Celaenae
    restoreFortressIfAbsent(356,88,0)
    --Ipsus
    restoreFortressIfAbsent(356,74,0)
    --Dorylaeum
    restoreFortressIfAbsent(344,64,0)
end

local function tribesWithTech(tech)
    local count = 0
    for i=1,7 do
        if civ.getTribe(i):hasTech(tech) then
            count = count+1
        end
    end
    return count
end

-- allows tribe to receive technologies already
-- discovered by other tribes
local function techProliferation(tribe)
    -- keep a list, so that a prerequisite and
    -- a tech itself are not both learned the same turn
    local techsToReceive = {}
    for i = 0,99 do
        local tech = civ.getTech(i)
        
        if (not tribe:hasTech(tech)) and
            (tech.prereq1 == nil or tribe:hasTech(tech.prereq1)) and
            (tech.prereq2 == nil or tribe:hasTech(tech.prereq2)) and
            (not diplomacySettings.forbiddenTechTransfer[i]) then
            if math.random() < tribesWithTech(tech)*param.techProliferationChance then
                techsToReceive[#techsToReceive+1] = tech
            end
        end
    end
    for __,tech in pairs(techsToReceive) do
        tribe:giveTech(tech)
    end
end


-- Occurs when the first unit is activated after production
-- If a tribe has no active unit after production, this
-- event will not run.  If this is likely in your scenario,
-- you will have to compensate.
-- Perhaps create a unit for the next tribe in line, and then delete that unit
-- when it is activated
local function doAfterProduction(turn,tribe)-->void
    -- spend 1/6 of a ship's movement.  Fractions of remaining movement keep track
    -- of how many more times a ship can 'recharge' its movement allowance
    for unit in civ.iterateUnits() do
        if unit.type.domain == 2 and unit.owner == tribe then
            unit.moveSpent = math.max(unit.moveSpent,1)
        end
    end
    for tileID,name in pairs(cityNames) do
        if math.random() < param.colonySiteUpgradeChance then
            upgradeColonySite(gen.getTileFromID(tileID))
        end
    end
    setUnitStats(tribe)
    restoreEasternFortresses(turn)
    techProliferation(tribe)

end
console.afterProduction = doAfterProduction



-- This will only run when a unit is killed in combat (i.e. not when an event
-- 'kills' a unit)
-- note that if the aggressor loses, aggressor.location will not work
local function doWhenUnitKilledInCombat(loser,winner,aggressor,victim,aggressorLocation,
    victimVetStatus,aggressorVetStatus)-->void
    --promotion.unitKilledInCombat(loser,winner,aggressor,victim,aggressorLocation,
    --victimVetStatus,aggressorVetStatus)
   if loser.type == object.uRichVillage then
       civ.ui.text(text.substitute("The citizens are rounded up and enslaved, and %STRING1 %STRING2 of plunder makes its way to the %STRING3 treasury.  This looks like a perfect location to found a new colony!",{param.richVillagePlunder,param.currencyPlural,winner.owner.adjective}))
       civ.createUnit(object.uSlave,winner.owner,winner.location)
       winner.owner.money=winner.owner.money+param.richVillagePlunder
       if not gen.unitTypeOnTile(winner.location,{object.uStrategos}) then
            winner.damage = winner.type.hitpoints-1
        end
   end
   if loser.type.role == 5 then
       -- capture slaves
       if loser == victim then
           if loser.type == object.uSlave then
               text.simple(text.substitute("We have captured some %STRING1 "..loser.type.name.."s.",{loser.owner.adjective}))
               local newSlave = civ.createUnit(object.uSlave,winner.owner,winner.location)
               newSlave.homeCity = nil
           elseif loser.type == object.uColonist or loser.type == object.uCitizen 
               or loser.type == object.uEngineer or loser.type == object.uHelot then
               text.simple(text.substitute("We have captured and enslaved some %STRING1 %STRING2s",
                {loser.owner.adjective,loser.type.name}))
               local newSlave = civ.createUnit(object.uSlave,winner.owner,winner.location)
               newSlave.homeCity = nil
           end
       elseif loser == aggressor then
           text.simple(text.substitute("Our %STRING1s have been defeated and enslaved by the %STRING2.",
           {loser.type.name,winner.owner.name}))
           local newSlave = civ.createUnit(object.uSlave,winner.owner,winner.location)
           newSlave.homeCity = nil
       end
   end

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
    setUnitStats(civ.getCurrentTribe())

end

local function doOnSave() --> string

    return civlua.serialize(state)
end

local function doOnCityTaken(city,defender) -->void
    legacy.doCityTakenEvents(city,defender)
    log.onCityTaken(city,defender)
    gen.rehomeUnitsInCapturedCity(city,defender)

end

local function doOnCityDestroyed(city) --> void
    legacy.doCityDestroyedEvents(city)
    log.onCityDestroyed(city)
    gen.rehomeUnitsInCapturedCity(city,city.owner)
end

local function doOnCityProduction(city,prod) -->void
    -- if the master builder improvement is sold or otherwise lost somehow, the wonder
    -- will not be completed.  This doesn't apply to the AI
    if civ.isWonder(prod) and city.owner.isHuman and (not city:hasImprovement(object.iMasterBuilder)) then
        prod.city = nil
        text.simple(text.substitute("Without the supervision of a Master Builder, our %STRING1 in %STRING2 has collapsed!",{prod.name,city.name}),"Construction Disaster")
        return
    end
    if civ.isWonder(prod) then
        for otherCity in civ.iterateCities() do
            if otherCity.owner == city.owner and otherCity:hasImprovement(object.iMasterBuilder) then
                city:removeImprovement(object.iMasterBuilder)
            end
        end
    end
    if civ.isImprovement(prod) and prod == object.iMasterBuilder then
        for otherCity in civ.iterateCities() do
            if otherCity.owner == city.owner and otherCity:hasImprovement(object.iMasterBuilder)
                and otherCity ~= city then
                otherCity:removeImprovement(object.iMasterBuilder)
                text.simple("Our Master Builder has relocated to "..city.name..".")
            end
        end
    end
    legacy.doCityProductionEvents(city,prod)
end

local function doOnActivateUnit(unit,source) --> void
    -- recharge ship movement for AI
    --local moveMult = totpp.movementMultipliers.aggregate
    --local remainingCharges = (unit.type.move-unit.moveSpent)%moveMult
    --print(unit.type.move-unit.moveSpent,2*moveMult,remainingCharges,unit.type.domain,gen.printBits(unit.attributes,16))
    --if (not (unit.owner.isHuman)) and unit.type.domain == 2 and 
    --    (unit.type.move-unit.moveSpent < 2*moveMult) and remainingCharges > 0 then
    --    remainingCharges = remainingCharges - 1
    --    unit.moveSpent =  moveMult - remainingCharges
    --    unit.attributes = 0
    --    --unit.attributes = gen.setBit0(unit.attributes,7)
    --end


    
end

-- returns true if the unit is on a land tile, or is adjacent to one
-- or, if the unit doesn't have the trireme flag set
local function landAdjacent(unit)
    if not(gen.isCoastal(unit.type)) then
        return true
    end
    local offsets = {{0,0},{0,2},{1,1},{2,0},{1,-1},{0,-2},{-1,-1},{-2,0},{-1,1}}
    local center = unit.location
    for __,offset in pairs(offsets) do
        local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
        if t.terrainType%16~=10 then
            return true
        end
    end
    return false
end

-- checks if there is a ship with an attack value "near"
-- (param.shipInterceptionDistance) a unit
-- returns the unit if there is, returns false if not
local function nearbyEnemyShip(unit)
    local unitTribe = unit.owner
    for otherUnit in civ.iterateUnits() do
        if otherUnit.type.domain == 2 and otherUnit.type.attack > 0 and
            (diplomacy.warExists(unitTribe,otherUnit.owner) or otherUnit.owner == object.tLydians
            or otherUnit.owner == object.tMinorCities) and 
            gen.distance(unit,otherUnit) <= param.shipInterceptionDistance then
            return otherUnit
        end
    end
    return false
end
        


local function rechargeShipMovement(unit)
    local moveMult = totpp.movementMultipliers.aggregate
    local remainingCharges = (unit.type.move-unit.moveSpent)%moveMult
    local nearbyShip = nearbyEnemyShip(unit)
    if nearbyShip then
        text.simple(text.substitute("Our %STRING1 cannot replenish its movement points due to the nearby %STRING2 %STRING3.  Ships can't replenish their movement points within %STRING4 squares of an enemy warship.",
        {unit.type.name,nearbyShip.owner.adjective,nearbyShip.type.name,tostring(param.shipInterceptionDistance)}),"Seafaring Rules: Movement Replenishment")
    elseif remainingCharges > 0 and landAdjacent(unit) then
        remainingCharges = remainingCharges - 1
        unit.moveSpent =  moveMult - remainingCharges
        text.simple(text.substitute("Our %STRING1 has had its movement allowance replenished.",{unit.type.name}),"Movement Replenishment")
    elseif remainingCharges == 0 then
        text.simple(text.substitute("Our %STRING1 has used up its full allotment of movement replenishment for the current turn.  Only sea units with fractional movement points remaining can restore their movement allowance.",{unit.type.name}),"Seafaring Rules: Movement Replenishment")

    else
        text.simple(text.substitute("Our %STRING1 is not adjacent to a land square.  Sea units must be adjacent to land squares in order to restore their movement allowance",{unit.type.name}),"Seafaring Rules: Movement Replenishment")
    end
end

local helpTextByUnitTypeID = {
[object.uColonist.id]="Can found new cities on colony sites, and join existing cities.",
[object.uCitizen.id]="Can join existing cities.",

[object.uTransportShip.id]="Press K to restore movement when adjacent to land.",
[object.uTransportGalley.id]="Press K to restore movement when adjacent to land.",
[object.uTrireme.id]="Press K to restore movement (even if not adjacent to land).",
[object.uPunicGalley.id]="Press K to restore movement when adjacent to land.",
[object.uBireme.id]="Press K to restore movement when adjacent to land.",
[object.uLiburnae.id]="Press K to restore movement when adjacent to land.",
[object.uPentreconter.id]="Press K to restore movement when adjacent to land.",
}
local function helpFunction(unit) return nil end

local function doOnKeyPress(keyCode)
    --print(keyCode)
    local activeUnit = civ.getActiveUnit()
    if keyCode % 256 == keyboard.b and activeUnit and activeUnit.location.city
        and activeUnit.location.city.size < civ.cosmic.sizeAquaduct and activeUnit.type.role == 5 and 
        not (activeUnit.type == object.uColonist or activeUnit.type == object.uCitizen) then
        local cityLoc = activeUnit.location
        cityLoc.city.size = cityLoc.city.size-1
        local replacementUnit = civ.createUnit(activeUnit.type,activeUnit.owner,activeUnit.location)
        replacementUnit.homeCity = activeUnit.homeCity
        replacementUnit.moveSpent = activeUnit.moveSpent
        replacementUnit.attributes = activeUnit.attributes
        replacementUnit.damage = activeUnit.damage
        gen.activate(replacementUnit)
        text.simple(text.substitute("Only %STRING1s and %STRING2s can join cities.",
        {object.uCitizen.name,object.uColonist.name}))
        return
    end
    --if activeUnit then
    --    local activeUnitType = activeUnit.type
    --    local activeUnitOwner = activeUnit.owner
    --    local activeUnitLocation = activeUnit.location
    --    print(activeUnitType,activeUnitOwner,activeUnitLocation)
    --end
    if keyCode == keyboard.tab then
        helpkey.helpKey(keyCode,keyboard.tab,{},helpTextByUnitTypeID,helpFunction)
        return
    end
    if keyCode == keyboard.one then
        text.openArchive()
    end
    if keyCode == keyboard.escape then
        log.combatReportFunction()
        return
    end
    if keyCode == keyboard.k --[[k]] and civ.getActiveUnit() then
        munitions.doMunition(civ.getActiveUnit(),kAttack,doOnActivateUnit)
        local activeUnit = civ.getActiveUnit()
        if activeUnit.type.domain == 2 then
            rechargeShipMovement(activeUnit)
        end
        return
    end
    -- Only citizens and colonists can join cities
    if keyCode == keyboard.backspace and civ.getActiveUnit() then
        munitions.doMunition(civ.getActiveUnit(),backspaceAttack,doOnActivateUnit)
        return
    end
    if keyCode == keyboard.two then
        local options = {forbidTileGiveaway = diplomacySettings.forbidTileGiveaway(civ.getCurrentTile()),giftTechNotTrade=diplomacySettings.giftTechNotTrade}
        diplomacy.diplomacyMenu(options)
        return
    end
end


local function doOnCityFounded(city) --> void
    --civ.ui.text("City Location is "..tostring(city.location.x)..","..tostring(city.location.y))
    city.name = cityNames[gen.getTileID(city.location)] or "Do Not Build"
    if city.location.terrainType%16 ~= 7 then
        if city.owner.isHuman then
            text.simple("This colony will fail due to a poor choice of location.  Colonies can only be successfully founded by Colonist units on \'Colony Site\' terrain.","Game Concepts: Colony Sites")
        end
        civ.deleteCity(city)
    end
    local activeUnitType = civ.getActiveUnit() and civ.getActiveUnit().type
    if activeUnitType and city.owner.isHuman and activeUnitType.role == 5 and activeUnitType ~= object.uColonist then
        text.simple("This colony will fail due to a lack of supplies.  Only colonist units carry enough supplies to successfully found cities on \'Colony Site\' terrain.","Game Concepts: Colonists")
        city.name = "Do Not Build"
        civ.deleteCity(city)
    end
    civ.addImprovement(city,object.iCityWalls)
    if city and not city.owner.isHuman then
        city.name = cityNames[gen.getTileID(city.location)] or " "
    end
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
local defenderStratego = false
local function doOnResolveCombat(defaultResolutionFunction,defender,attacker)
    -- this if statement will only be executed once per combat
    if firstRoundOfCombat then
        firstRoundOfCombat = false
        aggressorVeteranStatusBeforeCombat = attacker.veteran
        aggressorLocation = attacker.location
        victimVeteranStatusBeforeCombat = defender.veteran
        if gen.unitTypeOnTile(attacker.location,{object.uStrategos}) then
            defender.damage = defender.damage+math.floor(defender.type.hitpoints*param.strategosAttack)
        end
        if gen.unitTypeOnTile(defender.location,{object.uStrategos}) then
            defenderStratego = true
            -- this makes sure that if there is a stratego on both sides of the conflict, 
            -- the defender won't survive with negative hp
            if defender.damage >= defender.type.hitpoints then
                defender.damage = defender.type.hitpoints -1
            end
        else
            defenderStratego = false
        end
    end -- firstRoundOfCombat
    if defenderStratego and defender.hitpoints < attacker.type.firepower then
        attacker.damage = attacker.damage + math.floor(param.strategosDefense*defender.type.firepower)
    end
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
    log.onUnitKilled(winner,loser)
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

civ.scen.onTurn(doOnTurn)

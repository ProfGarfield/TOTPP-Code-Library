--  This file provides a basic framework for reactions.
--  You should probably require (or copy, but using require is better so you only have to make
--  changes in one place) your table of unit types.
--  e.g.
--  local object = require("object")
--
--  You will need the reactionBase module
local reactionBase = require("reactionBase")
--  (reactionBase also needs the text module)
--  You will need the General Library,
local gen = require("generalLibrary")
--  specifically the threshold table functionality
--  
        -- A threshold table is a table where if a numerical key is indexed, and that
        -- numerical key doesn't correspond to an index, the value of the largest
        -- numerical index less than the key is used.
        -- If there is no numerical index smaller than the key, false is returned
        -- (nil is returned for non-numerical keys not in table)
        -- Use an index -math.huge to provide values for arbitrarily small numerical keys
        -- example 
        -- myTable = gen.makeThresholdTable({[-1]=-1,[0]=0,[1]=1,})
        -- myTable[-2] = false
        -- myTable[-1] = -1
        -- myTable[-0.6] = -1
        -- myTable[3.5]=1
        -- myTable["three"] = nil
        -- myTable[0.5]=0
        --
        -- gen.makeThresholdTable(table or nil)-->thresholdTable
        -- makes an input a threshold table or creates an empty thresholdTable
        -- Also returns the table value
    -- Damage from reactions is specified with threshold tables, which will be
    -- indexed by randomly generated numbers from 0 to 1.
-- You will need the diplomacy module (unless you comment out diplomatic checks for reactions)
local diplomacy = require("diplomacy")
--
-- reactionDetail
--      The basic data structure in this framework is the 'reactionDetail'
--      A reactionDetail specifies how a unit type will react to certain other
--      unit types
--      a reactionDetail has the following keys
--          triggerUnitTypes = table of unitTypes
--              These are the triggering unit types for which this reaction detail applies
--              Must be a table, even if there is only one unit type
--              Must Exist
--          forbiddenTerrainReactionUnit = {[terrainTypeIndex]=bool or nil}
--              if the value for terrainTypeIndex is true, the unit can't react if it is on
--              that terrain type
--          forbiddenTerrainTriggerUnit = {[terrainTypeIndex]=bool or nil}
--              if the value for terrainTypeIndex is true, the unit can't react if 
--              the trigger unit is on that terrain type
--          forbiddenUnitTypesOnTileReactionUnit = table of unitTypes
--              if exists, must be a table, even if only one unit type
--              Unit can't react if it shares a tile with these types of units (e.g. carriers)
--              absent means no restriction
--          forbiddenUnitTypesOnTileTriggerUnit = table of unitTypes
--              if exists, must be a table, even if only one unit type
--              Unit can't react if trigger unit shares a tile with these types of units (e.g. carriers)
--              absent means no restriction
--          reactionRange = integer
--              the maximum number of squares between the trigger unit and the reacting unit
--              Must Exist
--          mapDistance = nil or mapDistanceTable[reactionUnitLocZ][triggerUnitLocZ]=integer
--              add the value of mapDistanceTable[reactionUnitLocZ][triggerUnitLocZ] to the
--              horizontal distance between the two units to determine if the units are in
--              reaction range (can increase the reaction range by using negative number)
--              nil for any entry means that the units are automatically out of range
--              if they are not on the same map (if they are on the same map, the distance is 0 unless specified otherwise)
--          hitChance = number 0-1
--              probability that the reacting unit will score a hit on the trigger unit
--              Must Exist
--          hitChanceTerrainReactionUnit = {[terrainTypeIndex]=number 0-1 or nil}
--              if the reacting unit is on a tile with terrainTypeIndex, and the entry is not
--              nil, then override hitChance with this value instead
--              absent means use hitChance (or hitChanceTerrainTriggerUnit)
--          hitChanceTerrainTriggerUnit = {[terrainTypeIndex]=number 0-1 or nil}
--              if the triggering unit is on a tile with terrainTypeIndex, and the entry is not
--              nil, then override hitChance with this value instead
--              absent means use hitChance (or hitChanceTerrainReactionUnit)
--          hitChancePriority = "average" or "max" or "min" or "base"
--              must exist if both hitChanceTerrain keys also exist, to resolve a situation
--              where both the reacting unit and triggering unit override the base based on terrain
--              "average" means take the average of the hit chances
--              "max" means take the larger hit chance
--              "min" means take the smaller hit chance
--              "base" means revert to the hitChance entry
--          damageSchedule = thresholdTable
--              Governs the damage done IF a hit is scored
--              thresholdTable must return a number for damageSchedule[0]
--              consider myDamageSchedule = makeThresholdTable({[0]=6,[0.3]=3,[0.8]=0,[.85]=1})
--              30% chance of 6 damage ('roll' between 0 and .3)
--              50% chance of 3 damage ('roll' between .3 and .8)
--              5% chance of 0 damage ('roll' between .8 and .85)
--              15% chance of 1 damage ('roll' between .85 and 1)
--          destroyMunitionsWithKill = bool or nil
--              if true, the generated munitions are destroyed if the trigger unit is destroyed
--              false or nil means don't kill
--          moneyCost = integer
--              gold cost for the reaction
--              absent means 0
--          minTreasury = integer
--              don't react if treasury below this amount
--              absent means 0
--          protectedTreasury = integer
--              a reaction won't reduce the treasury below this amount, even if it happens
--              absent means 0
--
-- The data given by the scenario designer is processed into a different form for use
-- in the program.  All keys in a reactionDetail must, therefore, be in this list,
-- EXCEPT "triggerUnitTypes"
local reactionDetailKeyNames = {}
reactionDetailKeyNames["triggerUnitTypes"] = nil -- nil instead of true, since this shouldn't be in the table
reactionDetailKeyNames["forbiddenTerrainReactionUnit"] = true
reactionDetailKeyNames["forbiddenTerrainTriggerUnit"]=true
reactionDetailKeyNames["forbiddenUnitTypesOnTileReactionUnit"]=true
reactionDetailKeyNames["forbiddenUnitTypesOnTileTriggerUnit"]=true
reactionDetailKeyNames["reactionRange"]=true
reactionDetailKeyNames["mapDistance"]=true
reactionDetailKeyNames["hitChance"]=true
reactionDetailKeyNames["hitChanceTerrainReactionUnit"]=true
reactionDetailKeyNames["hitChanceTerrainTriggerUnit"]=true
reactionDetailKeyNames["hitChancePriority"]=true
reactionDetailKeyNames["damageSchedule"]=true
reactionDetailKeyNames["destroyMunitionsWithKill"]=true
reactionDetailKeyNames["moneyCost"]=true
reactionDetailKeyNames["minTreasury"]=true
reactionDetailKeyNames["protectedTreasury"]=true

--  reactionInformation = 
--      A reactionInformation data type provides information about a unit's reactions as a whole
--          details = table of reactionDetail
--              The reactionDetails should not have duplicate unit types
--              If none of the reactionDetails in the reactionInformation cover a particular unit type,
--              then that unit type will not trigger a reaction for unit(s) governed by this
--              reactionInformation
--              this must be a table, even if there is only one reactionDetail within
--              must exist
--          reactionsPerTurn = integer or nil
--              gives the maximum number of reactions this unit can make in a single turn
--              absent means unlimited reactions
--      for the keys which have the same name as keys in a reactionDetail,
--      if a reactionDetail is missing the corresponding entry,
--      the value here will be used instead
--          defaultForbiddenTerrainReactionUnit = {[terrainTypeIndex]=bool or nil}
--              if the value for terrainTypeIndex is true, the unit can't react if it is on
--              that terrain type
--          forbiddenTerrainTriggerUnit = {[terrainTypeIndex]=bool or nil}
--              if the value for terrainTypeIndex is true, the unit can't react if 
--              the trigger unit is on that terrain type
--          forbiddenUnitTypesOnTileReactionUnit = table of unitTypes
--              if exists, must be a table, even if only one unit type
--              Unit can't react if it shares a tile with these types of units (e.g. carriers)
--              absent means no restriction
--          forbiddenUnitTypesOnTileTriggerUnit = table of unitTypes
--              if exists, must be a table, even if only one unit type
--              Unit can't react if trigger unit shares a tile with these types of units (e.g. carriers)
--              absent means no restriction
--          reactionRange = integer
--              the maximum number of squares between the trigger unit and the reacting unit
--              Must Exist
--          mapDistance = nil or mapDistanceTable[reactionUnitLocZ][triggerUnitLocZ]=integer
--              add the value of mapDistanceTable[reactionUnitLocZ][triggerUnitLocZ] to the
--              horizontal distance between the two units to determine if the units are in
--              reaction range (can increase the reaction range by using negative number)
--              nil for any entry means that the units are automatically out of range
--              if they are not on the same map (if they are on the same map, the distance is 0 unless specified otherwise)
--              NOTE: if anything is specified for mapDistance in the reactionDetail, this will be
--              ignored entirely.  You can't just override a specific entry, the entire mapDistance must be
--              re-written
--          hitChance = number 0-1
--              probability that the reacting unit will score a hit on the trigger unit
--              Must Exist
--          hitChanceTerrainReactionUnit = {[terrainTypeIndex]=number 0-1 or nil}
--              if the reacting unit is on a tile with terrainTypeIndex, and the entry is not
--              nil, then override hitChance with this value instead
--              absent means use hitChance (or hitChanceTerrainTriggerUnit)
--          hitChanceTerrainTriggerUnit = {[terrainTypeIndex]=number 0-1 or nil}
--              if the triggering unit is on a tile with terrainTypeIndex, and the entry is not
--              nil, then override hitChance with this value instead
--              absent means use hitChance (or hitChanceTerrainReactionUnit)
--          hitChancePriority = "average" or "max" or "min" or "base"
--              must exist if both hitChanceTerrain keys also exist, to resolve a situation
--              where both the reacting unit and triggering unit override the base based on terrain
--              "average" means take the average of the hit chances
--              "max" means take the larger hit chance
--              "min" means take the smaller hit chance
--              "base" means revert to the hitChance entry
--          damageSchedule = thresholdTable
--              Governs the damage done IF a hit is scored
--              thresholdTable must return a number for damageSchedule[0]
--              consider myDamageSchedule = makeThresholdTable({[0]=6,[0.3]=3,[0.8]=0,[.85]=1})
--              30% chance of 6 damage ('roll' between 0 and .3)
--              50% chance of 3 damage ('roll' between .3 and .8)
--              5% chance of 0 damage ('roll' between .8 and .85)
--              15% chance of 1 damage ('roll' between .85 and 1)
--          destroyMunitionsWithKill = bool or nil
--              if true, the generated munitions are destroyed if the trigger unit is destroyed
--              false or nil means don't kill
--          moneyCost = integer
--              gold cost for the reaction
--              absent means 0
--          minTreasury = integer
--              don't react if treasury below this amount
--              absent means 0
--          protectedTreasury = integer
--              a reaction won't reduce the treasury below this amount, even if it happens
--              absent means 0
--
-- this is the list of keys in a reactionInformation specification that are not also part
-- of the reactionDetail specification (usually things global to all units that can be reacted to)
-- EXCEPT the details key
local reactionInformationKeys = {}
reactionInformationKeys["details"]=nil -- don't want the details key in this table
reactionInformationKeys["reactionsPerTurn"]=true

-- Here, you may want to specify values (such as tables of units, reactionDetails, etc.) that will
-- be re-used frequently in the reactInfo table that you will populate below
-- Of course, you might also just specify them right before you get 





local reactInfo = {}
-- this table is indexed by unitTypeID numbers of the reacting unit, and has reactionInformation as values
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--


local globalReactionParameters = {}
--globalReactionParameters.maxReactionsPerTrigger = 4 -- sets the maximum number of units that can react to a
--  trigger unit, absent means unlimited reactions
--  
--  These parameters determine the diplomatic states under which a reaction will occur
--  The canReact function will check (in this order) for the following possible diplomatic states
--  alliance; peace treaty; cease fire; contact, but no peace treaty, cease fire, or state of war; no contact
--  The first match that is found, the game will check the corresponding parameter below, if the parameter
--  is false, there will be no reaction from the unit.  If true, no other diplomatic state will be checked,
--  and the unit will react (provided the other necessary conditions are met)
--
globalReactionParameters.reactIfInAlliance = false -- unit reacts even if there is an alliance in place between the two tribes.  Maybe you want this if the alliance is to prevent 'direct' war, but indirect skirmishes are possible
globalReactionParameters.reactIfAtPeace = false -- unit reacts if in range even if tribes are at peace
globalReactionParameters.reactIfCeaseFire = true -- unit reacts if in range and reactingUnit are at ceaseFire (but not peace)
globalReactionParameters.reactIfContactAndNoWar = true -- unit reacts if in range if there is no peace treaty or ceaseFire, but also no war declared with a contacted civ
globalReactionParameters.reactIfNoContact = true -- unit reacts to trigger units with which the tribe has not established contact





-- reactGovernor is the internal data structure for the simpleReactions module
local reactGovernor = {}
-- reactGovernor[reactingUnitTypeID][triggeringUnitTypeID] = reactionDetail
-- reactGovernor[reactingUnitTypeID]["reactionsPerTurn"] = integer (the reactions that unit can make each turn)
--              nil means unlimited reactions
--
--  reactionDetail modified specification for reactGovernor
--  * means changed from designer input
-- reactionDetail
--      The basic data structure in this framework is the 'reactionDetail'
--      A reactionDetail specifies how a unit type will react to certain other
--      unit types
--      a reactionDetail has the following keys
--          *triggerUnitTypes Removed
--          forbiddenTerrainReactionUnit = {[terrainTypeIndex]=bool or nil}
--              if the value for terrainTypeIndex is true, the unit can't react if it is on
--              that terrain type
--          forbiddenTerrainTriggerUnit = {[terrainTypeIndex]=bool or nil}
--              if the value for terrainTypeIndex is true, the unit can't react if 
--              the trigger unit is on that terrain type
--          *forbiddenUnitTypesOnTileReactionUnit = {[unitTypeID]=bool or nil}
--              Unit can't react if it shares a tile with any of these types of units (e.g. carriers)
--              absent means no restriction
--          *forbiddenUnitTypesOnTileTriggerUnit = {[unitTypeID]=bool or nil}
--              Unit can't react if trigger unit shares a tile with these types of units (e.g. carriers)
--              absent means no restriction
--          reactionRange = integer
--              the maximum number of squares between the trigger unit and the reacting unit
--              Must Exist
--          mapDistance = nil or mapDistanceTable[reactionUnitLocZ][triggerUnitLocZ]=integer
--              add the value of mapDistanceTable[reactionUnitLocZ][triggerUnitLocZ] to the
--              horizontal distance between the two units to determine if the units are in
--              reaction range (can increase the reaction range by using negative number)
--              nil for any entry means that the units are automatically out of range
--              if they are not on the same map (if they are on the same map, the distance is 0 unless specified otherwise)
--          hitChance = number 0-1
--              probability that the reacting unit will score a hit on the trigger unit
--              Must Exist
--          hitChanceTerrainReactionUnit = {[terrainTypeIndex]=number 0-1 or nil}
--              if the reacting unit is on a tile with terrainTypeIndex, and the entry is not
--              nil, then override hitChance with this value instead
--              absent means use hitChance (or hitChanceTerrainTriggerUnit)
--          hitChanceTerrainTriggerUnit = {[terrainTypeIndex]=number 0-1 or nil}
--              if the triggering unit is on a tile with terrainTypeIndex, and the entry is not
--              nil, then override hitChance with this value instead
--              absent means use hitChance (or hitChanceTerrainReactionUnit)
--          hitChancePriority = "average" or "max" or "min" or "base"
--              must exist if both hitChanceTerrain keys also exist, to resolve a situation
--              where both the reacting unit and triggering unit override the base based on terrain
--              "average" means take the average of the hit chances
--              "max" means take the larger hit chance
--              "min" means take the smaller hit chance
--              "base" means revert to the hitChance entry
--          damageSchedule = thresholdTable
--              Governs the damage done IF a hit is scored
--              thresholdTable must return a number for damageSchedule[0]
--              consider myDamageSchedule = makeThresholdTable({[0]=6,[0.3]=3,[0.8]=0,[.85]=1})
--              30% chance of 6 damage ('roll' between 0 and .3)
--              50% chance of 3 damage ('roll' between .3 and .8)
--              5% chance of 0 damage ('roll' between .8 and .85)
--              15% chance of 1 damage ('roll' between .85 and 1)
--          destroyMunitionsWithKill = bool or nil
--              if true, the generated munitions are destroyed if the trigger unit is destroyed
--              false or nil means don't kill
--          moneyCost = integer
--              gold cost for the reaction
--              absent means 0
--          minTreasury = integer
--              don't react if treasury below this amount
--              absent means 0
--          protectedTreasury = integer
--              a reaction won't reduce the treasury below this amount, even if it happens
--              absent means 0

local function convertReactionInformation(reactingUnitTypeID)
    reactGovernor[reactingUnitTypeID]={}
    local rGUT = reactGovernor[reactingUnitTypeID]
    local reactionInformation = reactInfo[reactingUnitTypeID]
    local tableOfReactionDetails = reactionInformation.details
    for __,reactionDetail in pairs(tableOfReactionDetails) do
        for __,triggerUnitType in pairs(reactionDetail.triggerUnitTypes) do
            if rGUT[triggerUnitType.id] then
                error("Reaction Module: the unit type "..tostring(reactingUnitTypeID).." ("..
                civ.getUnit(reactingUnitTypeID)..name..") appears to have two reaction details for unit type "..
                tostring(triggerUnitType.id).." ("..triggerUnitType.name..").")
            end
            rGUT[triggerUnitType.id]={}
            local triggerUnitReactionDetail = rGUT[triggerUnitType.id]
            for key,__ in pairs(reactionDetailKeyNames) do
                -- get the information for the key from the reaction detail
                -- if not there, check reactionInformation instead
                triggerUnitReactionDetail[key] = reactionDetail[key] or reactionInformation[key]
                if ((key =="forbiddenUnitTypesOnTileReactionUnit") or (key == "forbiddenUnitTypesOnTileTriggerUnit"))
                    and triggerUnitReactionDetail[key] then
                    -- this converts the format to {[unitTypeID]=bool or nil}
                    local newValue = {}
                    for __,unitType in pairs(triggerUnitReactionDetail[key]) do
                        newValue[unitType.id] = true
                    end
                    triggerUnitReactionDetail[key] = newValue
                end
            end
        end
    end
    for key,__ in pairs(reactionInformationKeys) do
        reactGovernor[reactingUnitTypeID][key] = reactionInformation[key]
    end
end

local simpleReactions = {}

local function canReact(triggerUnit,reactingUnit)
    local triggerTribe = triggerUnit.owner
    local reactingTribe = reactingUnit.owner
    if diplomacy.allianceExists(triggerTribe,reactingTribe) then
        if not globalReactionParameters.reactIfInAlliance then
            return false
        end
    elseif diplomacy.peaceTreatyExists(triggerTribe,reactingTribe) then
        if not globalReactionParameters.reactIfAtPeace then
            return false
        end
    elseif diplomacy.ceaseFireExists(triggerTribe,reactingTribe) then
        if not globalReactionParameters.reactIfCeaseFire then
            return false
        end
    elseif diplomacy.contactExists(triggerTribe,reactingTribe) and (not diplomacy.warExists(triggerTribe,reactingTribe)) then
        if not globalReactionParameters.reactIfContactAndNoWar then
            return false
        end
    elseif not diplomacy.contactExists(triggerTribe,reactingTribe) then
        if not globalReactionParameters.reactIfNoContact then
            return false
        end
    end
    if reactionBase.getReactionsMade > (reactGovernor[reactingUnit.type.id]["reactionsPerTurn"] or math.huge) then
        -- this condition can exist even if there is no limit to reactions per turn
        -- if there is a limit, and it is exceeded, return false, so the unit will not react
        return false
    end
    local reactionDetail = reactGovernor[reactingUnit.type.id][triggerUnit.type.id]
    local reactingUnitTerrain = reactingUnit.location.terrainType%16
    local triggerUnitTerrain = triggerUnit.location.terrainType%16
    if reactionDetail.forbiddenTerrainReactionUnit and reactionDetail.forbiddenTerrainReactionUnit[reactingUnitTerrain] then
        --forbidden terrain, so return false
        return false
    end
    if reactionDetail.forbiddenTerrainTriggerUnit and reactionDetail.forbiddenTerrainTriggerUnit[triggerUnitTerrain] then
        -- forbidden terrain, so return false
        return false
    end
    if reactionDetail.forbiddenUnitTypesOnTileReactionUnit then
        local forbiddenTable = reactionDetail.forbiddenUnitTypesOnTileReactionUnit
        for possibleSpoilerUnit in reactingUnit.location.units do
            if forbiddenTable[possibleSpoilerUnit.type.id] then
                return false
            end
        end
    end
    if reactionDetail.forbiddenUnitTypesOnTileTriggerUnit then
        local forbiddenTable = reactionDetail.forbiddenUnitTypesOnTileTriggerUnit
        for possibleSpoilerUnit in reactingUnit.location.units do
            if forbiddenTable[possibleSpoilerUnit.type.id] then
                return false
            end
        end
    end
    local tULoc = triggerUnit.location
    local rULoc = reactingUnit.location
    local unitDistance = (math.abs(tULoc.x-rULoc.x)+math.abs(tULoc.y-rULoc.y))//2
    if reactionDetail.mapDistance and reactionDetail.mapDistance[rULoc.z]
        and reactionDetail.mapDistance[tULoc.z] then
        unitDistance = unitDistance + reactionDetail.mapDistance[rULoc.z][tULoc.z]
    elseif tULoc.z ~= rULoc.z then
        -- different maps, and no entry in reactionDetail.mapDistance, so units can't fight
        return false
    end
    if unitDistance > reactionDetail.reactionRange then
        return false
    end
    if reactingUnit.owner.money < (reactionDetail.minTreasury or 0) then
        -- not enough money, so return false
        return false
    end
    -- If we get here, the reaction can happen
    return "Attack From Map "..tostring(rULoc.z)
end

local function hitProbability(triggerUnit,reactingUnit)
    local reactionDetail = reactGovernor[reactingUnit.type.id][triggerUnit.type.id]
    local reactingUnitTerrain = reactingUnit.location.terrainType%16
    local triggerUnitTerrain = triggerUnit.location.terrainType%16
    local hitChance = reactionDetail.hitChance
    if reactionDetail.hitChanceTerrainReactionUnit and reactionDetail.hitChanceTerrainReactionUnit[reactingUnitTerrain]
        and reactionDetail.hitChanceTerrainTriggerUnit and reactionDetail.hitChanceTerrainTriggerUnit[triggerUnitTerrain]
        then
        local priorityString = reactionDetail.hitChancePriority
        local reactTerrainHitChance = reactionDetail.hitChanceTerrainReactionUnit[reactingUnitTerrain]
        local triggerTerrainHitChance = reactionDetail.hitChanceTerrainTriggerUnit[triggerUnitTerrain]
        if priorityString == "average" then
            return (reactTerrainHitChance + triggerTerrainHitChance)/2
        elseif priorityString == "max" then
            return math.max(reactTerrainHitChance,triggerTerrainHitChance)
        elseif priorityString == "min" then
            return math.min(reactTerrainHitChance,triggerTerrainHitChance)
        elseif priorityString == "base" then
            return hitChance
        else
            error("hitProbability: reacting unit type "..reactingUnit.type.name.." and trigger unit type "
            ..triggerUnit.type.name.." both have a terrain modifier, but the reaction detail for them "..
            "does not have a hitChancePriority specified, or it is not an allowable value.")
        end
    elseif reactionDetail.hitChanceTerrainReactionUnit and reactionDetail.hitChanceTerrainReactionUnit[reactingUnitTerrain] then
        return reactionDetail.hitChanceTerrainReactionUnit[reactingUnitTerrain]
    elseif reactionDetail.hitChanceTerrainTriggerUnit and reactionDetail.hitChanceTerrainTriggerUnit[triggerUnitTerrain] then
        return reactionDetail.hitChanceTerrainTriggerUnit[triggerUnitTerrain]
    else
        return hitChance
    end
end

local function damageSchedule(triggerUnit,reactingUnit)
    local reactionDetail = reactGovernor[reactingUnit.type.id][triggerUnit.type.id]
    if type(reactionDetail.damageSchedule[0]) ~= "number" then
            error("damageSchedule: reacting unit type "..reactingUnit.type.name.." and trigger unit type "
            ..triggerUnit.type.name.." do not produce a damage schedule defined for a key of 0.")
    return reactionDetail.damageSchedule
end

local function reactionPriority(triggerUnit,reactingUnit,hitProbability,damageSchedule)
    -- computing the expected remaining hitpoints means that damage beyond what it will
    -- take to kill the trigger unit is ignored (e.g. if trigger unit has 1 hp, a unit with 50%
    -- chance to do 1 damage is a better attacker than a unit with 25% chance to do 10 damage)
    -- a higher score is considered better, but a lower expected hp is better, so we negate
    -- the expected remaining hp to align to larger is better
    return -reactionBase.expectedRemainingHitpoints(triggerUnit,hitProbability,damageSchedule)
end

local function munitionEffect(triggerUnitBeforeDamage,reactingUnit,tableOfMunitionsGenerated,triggerUnitHit,damageToBeDoneToTriggerUnit)
    local reactionDetail = reactGovernor[reactingUnit.type.id][triggerUnitBeforeDamage.type.id]
    if reactDetail.destroyMunitionsWithKill and (triggerUnitBeforeDamage.hitpoints-damageToBeDoneToTriggerUnit <=0)
    then
        -- delete the munitions
        for __,munition in pairs(tableOfMunitionsGenerated) do
            civ.deleteUnit(munition)
        end
    end
end

local function afterReaction(triggerUnitAfterDamageBeforeDeletion,reactingUnit,damageDone,triggerUnitHit,triggerUnitKilled,triggerUnitDemoted)
    local reactionDetail = reactGovernor[reactingUnit.type.id][triggerUnitAfterDamageBeforeDeletion.type.id]
    -- spend any money for the reaction
    -- tribe's money won't go below protected amount, unless it is below that amount already
    reactingUnit.owner.money = math.min (reactingUnit.owner.money,
                                            math.max((reactionDetail.protectedTreasury or 0),
                                            reactingUnit.owner.money-(reactionDetail.moneyCost or 0)))
    -- if there is no limit on the number of reactions for a unit, this doesn't matter, since the total
    -- number of reactions is compared elsewhere to math.huge if there is no maximum number specified
    reactionBase.incrementReactions(reactingUnit)
end

local doWhenUnitKilledFn = function(loser,winner) return end

local function linkDoWhenUnitKilled(unitKilledFn)
    doWhenUnitKilledFn = unitKilledFn
end

local function doReaction(triggerUnit,tableOfMunitionsGenerated)
    reactionBase.reactionEngine(triggerUnit,tableOfMunitionsGenerated,canReact,hitProbability,damageSchedule,
        reactionPriority,munitionEffect,afterReaction,doWhenUnitKilledFn,
        (globalReactionParameters.maxReactionsPerTrigger or math.huge))
end

local function doAfterProduction(tribe)
    reactionBase.clearReactionsIfNecessary(tribe,true)
end


simpleReactions.linkDoWhenUnitKilled = linkDoWhenUnitKilled
simpleReactions.doReaction = doReaction
simpleReactions.doAfterProduction = doAfterProduction

    
return simpleReactions


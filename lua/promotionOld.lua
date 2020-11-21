-- This module deals with units being 'promoted' to new units, 'demoted' (instead of destroyed) to other units, and any other related functionality.
--
--
--
--  Functionality
--  Change Promotion Chances
--  Promotions for Munitions Users
--  Promoting Units to a new unit type upon combat victory
--  Demoting units to a new unit type upon defeat (instead of destroying the unit)
--
local gen = require("generalLibrary") 
local text = require("text")
local gamePromotionChance = 0.5 -- Don't change this, it is here so there are not a lot of 'magic' 0.5 floating around

local promotion = {}
local promotionState = "promotionStateNotLinked"

-- links the state table with this module
local function linkState(tableInStateTable)
    if type(tableInStateTable) == "table" then
        promotionState = tableInStateTable
        promotionState.lastMunitionUnit = promotionState.lastMunitionUnit or nil
        promotionState.lastMunitionsCreated = promotionState.lastMunitionsCreated or {}
    else
        error("linkState: linkState takes a table as an argument.")
    end
end
promotion.linkState = linkState

local globalPromotionChance = 0.5

local function setGlobalPromotionChance(chance)
    if type(chance)~="number" then
        error("setGlobalPromotionChance requires a number (between 0 and 1) as its argument.")
    else
        globalPromotionChance = chance
    end
end
promotion.setGlobalPromotionChance = setGlobalPromotionChance

-- promotionChance[unitType.id] = chanceOfPromotion
local promotionChance = {}

local function setIndividualPromotionChances(promotionChanceTable)
    if type(promotionChanceTable) ~="table" then
        error("setIndividualPromotionChances requires a table as an argument")
    else
        promoteChance = promotionChanceTable
    end
end
promotion.setIndividualPromotionChances = setIndividualPromotionChances


-- promoteMunitionUser[munitionUserUnitType.id]=chanceOfPromotion
local promoteMunitionUser = {}

-- use this to link the promoteMunitionUser table to this module
local function linkPromoteMunitionUser(table)
    if type(table) == "table" then
        promoteMunitionUser = table
    else
        error("linkPromoteMunitionUser: argument is not a table.")
    end
end


local function recordLastMunitionUser(munitionUnit,tableOfUnitsCreated)
    if munitionUnit == promotionState.lastMunitionUnit then
        for __,createdUnit in pairs(tableOfUnitsCreated) do
            promotionState.lastMunitionsCreated[#promotionState.lastMunitionsCreated+1] = createdUnit
        end
    else
        promotionState.lastMunitionUnit = munitionUnit
        promotionState.lastMunitionsCreated = {}
        for __,createdUnit in pairs(tableOfUnitsCreated) do
            promotionState.lastMunitionsCreated[#promotionState.lastMunitionsCreated+1] = createdUnit
        end
    end
end
promotion.recordLastMunitionUser = recordLastMunitionUser

local munitionPromotionMessage = "For valor in combat, our %STRING0 unit has been promoted to Veteran status."

local function linkMunitionPromotionMessage(value)
    if type(value) == "string" then
        munitionPromotionMessage = value
    elseif type(value) == "function" then
        munitionPromotionMessage = value
    else
        error("linkMunitionPromotionMessage takes a string or function(promotedUnit,winningMunition)-->string as argument.")
    end
end
promotion.linkMunitionPromotionMessage =linkMunitionPromotionMessage

local showPromotionMessage = true
local showCancelledPromotionMessage = true

function promotion.hideLuaPromotionMessage()
    showPromotionMessage = false
end

function promotion.hideLuaCancelledPromotionMessage()
    showCancelledPromotionMessage = false
end

local luaPromotionMessage = "For valor in combat, our %STRING0 unit has been promoted to Veteran status."
local cancelPromotionMessage = "In this scenario, the chance of promotion to veteran status is less than 50%.  Unfortunately, that means that your %STRING0 unit has not become a veteran."

function promotion.linkLuaPromotionMessage(value)
    if type(value) == "string" then
        munitionPromotionMessage = value
    elseif type(value) == "function" then
        munitionPromotionMessage = value
    else
        error("linkLuaPromotionMessage takes a string or function(promotedUnit,winningMunition)-->string as argument.")
    end
end
function promotion.linkCancelPromotionMessage(value)
    if type(value) == "string" then
        munitionPromotionMessage = value
    elseif type(value) == "function" then
        munitionPromotionMessage = value
    else
        error("linkCancelPromotionMessage takes a string or function(promotedUnit,winningMunition)-->string as argument.")
    end
end


local upgradeSpecifics = {["default"]={}}
-- unit combat upgrade specification
-- upgradeSpecifics is indexed by unitType ID numbers
-- upgradeSpecifics[myUnitType.id] = combatUpgradeSpecification
-- upgradeSpecifics["default"] = combatUpgradeSpecification, used to provide default values for other specifications
--  .upgradeUnitType = unitType or table[loser.type.id]=(unitType or nil) or function(loser,winner,aggressor,victim,aggressorLocation,victimVetStatus,aggressorVetStatus)-->unitType or nil
--          the unit type that the upgraded unit will be replaced by
--          a table allows to specify the upgrade unit type based on what the loser is
--              e.g. defeat unit with horses, become unit with horses,
--                  defeat unit with muskets, become unit with muskets
--          function allows more flexibility still, or easier specification maybe
--          no entry means error, nil from table or function return means no upgrade
--  .nonVetUpgrade = bool or nil
--          if true, unitType can upgrade without being veteran
--          if false, units must be veteran
--          nil means upgradeSpecifics["default"].nonVetUpgrade
--          still nil means false
--  .aggressorOnlyUpgrade = bool or nil
--          if true, unitType can only upgrade if it was the aggressor
--          false means unitType can upgrade either way
--          nil means upgradeSpecifics["default"].aggressorOnlyUpgrade
--          still nil means false
--  .victimOnlyUpgrade = bool or nil
--          if true, unitType can only upgrade if it was the victim
--          false means unitType can upgrade either way
--          nil means upgradeSpecifics["default"].victimOnlyUpgrade
--          still nil means false
--  .upgradeChance = number (between 0 and 1)
--          probability of upgrade if the unit is successful in combat
--          nil means upgradeSpecifics["default"].upgradeChance
--          still nil means error (unless upgradeChanceFunction is specified)
--  .upgradeChanceSunTzu = number (between 0 and 1)
--          probability of upgrade if unit's owner has active Sun Tzu wonder
--          nil means upgradeSpecifics["default"].upgradeChanceSunTzu
--          still nil means use regular upgradeChance
--  .upgradeChanceFunction = function(loser,winner,aggressor,victim,aggressorLocation,victimVetStatus,aggressorVetStatus)-->number (between 0 and 1)
--          a function to give the upgrade chance instead of relying on built in functionality
--          overrides upgradeChance and upgradeChanceSunTzu
--          nil means no effect
--  
--  .preserveDamage = bool
--          if true, upgrade unit has same damage as upgraded unit
--          if false, upgrade unit has full hp
--          nil means upgradeSpecifics["default"].preserveDamage
--          still nil means false
--  .preserveMoveSpent = bool
--          if true, upgrade unit has same moveSpent as upgraded unit
--          if false, upgrade unit is created with full movement
--          nil means upgradeSpecifics["default"].preserveMoveSpent
--          still nil means false
--  .spendAllMove = bool
--          happens after preserveMoveSpent
--          if true, upgrade unit has all its movement points spent
--          if false, it does not 
--          nil means upgradeSpecifics["default"].preserveMoveSpent
--          still nil means false
--  .preserveVetStatus = bool
--          if true, upgradeUnit is veteran if upgraded unit is already veteran
--          false means unit not veteran (giveVetStatus applies below)
--          nil means upgradeSpecifics["default"].preserveVetStatus
--          still nil means false
--  .giveVetStatus = bool
--          if true, upgraded unit is automatically veteran
--          false means refer to preserveVetStatus
--          nil means upgradeSpecifics["default"].giveVetStatus
--          still nil means false
--  .clearHomeCity = bool
--          if true, new unit has home city of NONE,
--          false means keep home city of upgraded unit
--          nil means upgradeSpecifics["default"].clearHomeCity
--          still nil means false
--  .clearAttributes = bool
--          if true, unit.attributes are not copied to the new unit
--          false means they are (except veteran status, which is handled separately)
--          nil means upgradeSpecifics["default"].clearAttributes
--          still nil means false
--  .clearOrder = bool
--          if true, unit.order is set to 0xFF (i.e. no order)
--          false means the upgrade unit inherits the order of the upgraded unit
--          nil means upgradeSpecifics["default"].clearOrder
--          still nil means false
--  .clearGotoTile = bool
--          if true, the upgraded unit won't have a goto order
--          false means the upgrade unit inherits the order of the upgraded unit
--          nil means upgradeSpecifics["default"].clearGotoTile
--          still nil means false
--  .modifyNewUnitFunction = function(newUnit,loser,winner,aggressor,victim,aggressorLocation, victimVetStatus,aggressorVetStatus)
--          allows modification of the new unit based on arbitrary criteria,
--          happens after all other modifications
--          nil means no effect
--  .upgradeMessage = string or function(newUnit,loser,winner,aggressor,victim,aggressorLocation, victimVetStatus,aggressorVetStatus)-->string
--          displays a message about the upgrade if the unit owner is the current player
--          if function, the message is generated
--          %STRING0 is replaced by the old unit type name, %STRING1 is replaced by the new unit type name
--          nil means check upgradeSpecifics["default"].upgradeMessage
--          still nil means no message

function promotion.linkUpgradeSpecification(specificationTable)
    if type(specificationTable)~="table" then
        error("linkUpgradeSpecificationTable requires a table as an argument.")
    else
        upgradeSpecifics = specificationTable
        -- must have a "default" key and value for upgradeWinner to work
        upgradeSpecifics["default"] = upgradeSpecifics["default"] or {}
    end
end


local function upgradeWinner(loser,winner,aggressor,victim,aggressorLocation,
        victimVetStatus,aggressorVetStatus)
    local replacementWinner = winner
    local upgradeInfo = upgradeSpecifics[winner.type.id]
    if not upgradeInfo then
        return replacementWinner
    end
    local upgradeUnitType = nil
    if civ.isUnitType(upgradeInfo.upgradeUnitType) then
        upgradeUnitType = upgradeInfo.upgradeUnitType
    elseif type(upgradeInfo.upgradeUnitType) == "table" then
        upgradeUnitType = upgradeInfo.upgradeUnitType[loser.type.id]
    elseif type(upgradeInfo.upgradeUnitType) == "function" then
        upgradeUnitType = upgradeInfo.upgradeUnitType(loser,winner,aggressor,victim,aggressorLocation,victimVetStatus,aggressorVetStatus)
    else
        error("The upgrade specification for unit type "..winner.type.name.." with type id "..winner.type.id..
                "has an incorrect specification for key upgradeUnitType.  The value should be a unit type or a table or a function.")
    end
    if not upgradeUnitType then
        -- no unit type to upgrade
        return replacementWinner
    end
    local defaultUpgradeInfo = upgradeSpecifics["default"]
    if not (winner.veteran or upgradeInfo.nonVetUpgrade or defaultUpgradeInfo.nonVetUpgrade) then
        --upgrade disqualified because winner not veteran
        return replacementWinner
    end
    if winner ~= aggressor and (upgradeInfo.aggressorOnlyUpgrade or defaultUpgradeInfo.aggressorOnlyUpgrade) then
        -- only the aggressor can upgrade
        return replacementWinner
    end
    if winner ~= victim and (upgradeInfo.victimOnlyUpgrade or defaultUpgradeInfo.victimOnlyUpgrade) then
        -- only the victim can upgrade
        return replacementWinner
    end
    local upgradeChance = nil




end


-- Demotion 

-- unit demotion after defeat specification
-- demotionSpecifics is indexed by unitType ID numbers
-- demotionSpecifics[myUnitType.id] = demotionSpecification
-- demotionSpecifics["default"] = demotionSpecification, used to provide default values for other specifications
--
--  .demotionUnitType = unitType
--          If the unit is defeated in combat, a unit of this type will be created in its place
--          nil means no unit is created upon defeat (unless the override provides one)
--  .demotionUnitTypeOverride = table[winner.type.id] = unitType or false or nil
--                              or function(loser,winner,aggressor,victim,aggressorLocation,victimVetStatus,aggressorVetStatus) --> unitType or false or nil
--
--          If a unit type is provided, that unit type is created instead of the one specified by demotionUnitType
--          If false is returned, no replacement unit is created
--          If nil is returned, use the unitType specified by demotionUnitType
--
--  .demoteOnlyIfVeteran = bool or nil
--          If true, a demotion unit is created only if the loser is a veteran unit
--
--  .preserveVeteranStatus = bool or nil
--          If true, a demoted unit retains its veteran status
--          If false or nil, the new unit is not veteran
--
--  .aggressorOnlyDemotion = bool or nil
--          if true, unitType can only upgrade if it was the aggressor
--          false means unitType can upgrade either way
--          nil means upgradeSpecifics["default"].aggressorOnlyUpgrade
--          still nil means false
--  .victimOnlyUpgrade = bool or nil
--          if true, unitType can only upgrade if it was the victim
--          false means unitType can upgrade either way
--          nil means upgradeSpecifics["default"].victimOnlyUpgrade
--          still nil means false
--  .upgradeChance = number (between 0 and 1)
--          probability of upgrade if the unit is successful in combat
--          nil means upgradeSpecifics["default"].upgradeChance
--          still nil means error (unless upgradeChanceFunction is specified)
--  .upgradeChanceSunTzu = number (between 0 and 1)
--          probability of upgrade if unit's owner has active Sun Tzu wonder
--          nil means upgradeSpecifics["default"].upgradeChanceSunTzu
--          still nil means use regular upgradeChance
--  .upgradeChanceFunction = function(loser,winner,aggressor,victim,aggressorLocation,victimVetStatus,aggressorVetStatus)-->number (between 0 and 1)
--          a function to give the upgrade chance instead of relying on built in functionality
--          overrides upgradeChance and upgradeChanceSunTzu
--          nil means no effect
--  
--  .preserveDamage = bool
--          if true, upgrade unit has same damage as upgraded unit
--          if false, upgrade unit has full hp
--          nil means upgradeSpecifics["default"].preserveDamage
--          still nil means false
--  .preserveMoveSpent = bool
--          if true, upgrade unit has same moveSpent as upgraded unit
--          if false, upgrade unit is created with full movement
--          nil means upgradeSpecifics["default"].preserveMoveSpent
--          still nil means false
--  .spendAllMove = bool
--          happens after preserveMoveSpent
--          if true, upgrade unit has all its movement points spent
--          if false, it does not 
--          nil means upgradeSpecifics["default"].preserveMoveSpent
--          still nil means false
--  .preserveVetStatus = bool
--          if true, upgradeUnit is veteran if upgraded unit is already veteran
--          false means unit not veteran (giveVetStatus applies below)
--          nil means upgradeSpecifics["default"].preserveVetStatus
--          still nil means false
--  .giveVetStatus = bool
--          if true, upgraded unit is automatically veteran
--          false means refer to preserveVetStatus
--          nil means upgradeSpecifics["default"].giveVetStatus
--          still nil means false
--  .clearHomeCity = bool
--          if true, new unit has home city of NONE,
--          false means keep home city of upgraded unit
--          nil means upgradeSpecifics["default"].clearHomeCity
--          still nil means false
--  .clearAttributes = bool
--          if true, unit.attributes are not copied to the new unit
--          false means they are (except veteran status, which is handled separately)
--          nil means upgradeSpecifics["default"].clearAttributes
--          still nil means false
--  .clearOrder = bool
--          if true, unit.order is set to 0xFF (i.e. no order)
--          false means the upgrade unit inherits the order of the upgraded unit
--          nil means upgradeSpecifics["default"].clearOrder
--          still nil means false
--  .clearGotoTile = bool
--          if true, the upgraded unit won't have a goto order
--          false means the upgrade unit inherits the order of the upgraded unit
--          nil means upgradeSpecifics["default"].clearGotoTile
--          still nil means false
--  .modifyNewUnitFunction = function(newUnit,loser,winner,aggressor,victim,aggressorLocation, victimVetStatus,aggressorVetStatus)
--          allows modification of the new unit based on arbitrary criteria,
--          happens after all other modifications
--          nil means no effect
--  .upgradeMessage = string or function(newUnit,loser,winner,aggressor,victim,aggressorLocation, victimVetStatus,aggressorVetStatus)-->string
--          displays a message about the upgrade if the unit owner is the current player
--          if function, the message is generated
--          %STRING0 is replaced by the old unit type name, %STRING1 is replaced by the new unit type name
--          nil means check upgradeSpecifics["default"].upgradeMessage
--          still nil means no message









local function unitKilledInCombat(loser,winner,aggressor,victim,aggressorLocation,
        victimVetStatus,aggressorVetStatus)
    local loserVetStatus = nil
    local winnerVetStatus = nil
    if loser == aggressor then
        loserVetStatus = aggressorVetStatus
        winnerVetStatus = victimVetStatus
    else
        loserVetStatus = victimVetStatus
        winnerVetStatus = aggressorVetStatus
    end
    if loser.hitpoints <= 0 then
        -- this is a unit that has not died in a stack kill
        -- most promotion stuff should go here
        -- munition promotion
        if gen.isDestroyedAfterAttacking(winner.type) then
            if gen.isValueInTable(winner,promotionState.lastMunitionsCreated) then
                local munitionUser = promotionState.lastMunitionUnit
                if (not munitionUser.veteran) and math.random() < (promoteMunitionUser[munitionUser.type.id] or 0) then
                    local pMessage = munitionPromotionMessage
                    if type(pMessage) == "function" then
                        pMessage = pMessage(munitionUser,winner)
                        if type(pMessage) ~="string" then
                            error("When supplying linkMunitionPromotionMessage with a function, that function must return a string.")
                        end
                    end
                    pMessage = text.substitute(pMessage,{[0]=munitionUser.type.name})
                    munitionUser.veteran = true
                    if munitionUser.owner == civ.getPlayerTribe() then
                        text.simple(pMessage,"Defense Minister")
                    end
                end
            end
        end
        -- promotion override
        -- winner was not a veteran before combat and Sun Tzu is not a consideration
        if not winnerVetStatus and not(civ.getWonder(7).city and civ.getWonder(7).city.owner == winner.owner) then
            local winnerPromotionChance = promotionChance[winner.type.id] or globalPromotionChance
            if winnerPromotionChance < gamePromotionChance then
                -- sometimes a unit will get promoted by the game when we don't want it to, so we must compensate
                if winner.veteran and math.random() < (gamePromotionChance-winnerPromotionChance)/gamePromotionChance then
                    winner.veteran = false
                    if winner.owner == civ.getPlayerTribe() then
                        local pMessage = cancelPromotionMessage
                        if type(pMessage) == "function" then
                            pMessage = pMessage(munitionUser,winner)
                            if type(pMessage) ~="string" then
                                error("When supplying linkCancelPromotionMessage with a function, that function must return a string.")
                            end
                        end
                        pMessage = text.substitute(pMessage,{[0]=munitionUser.type.name})
                        text.simple(pMessage,"Defense Minister")
                    end
                end
            else -- winnerPromotionChance >= gamePromotionChance
                -- sometimes the game won't promote a unit that we want to be promoted
                if (not winner.veteran) and math.random() < (winnerPromotionChance-gamePromotionChance)/(1-gamePromotionChance) then
                    winner.veteran = true
                    if winner.owner == civ.getPlayerTribe() then
                        local pMessage = luaPromotionMessage
                        if type(pMessage) == "function" then
                            pMessage = pMessage(munitionUser,winner)
                            if type(pMessage) ~="string" then
                                error("When supplying linkLuaPromotionMessage with a function, that function must return a string.")
                            end
                        end
                        pMessage = text.substitute(pMessage,{[0]=munitionUser.type.name})
                        text.simple(pMessage,"Defense Minister")
                    end
                end
            end
        end
        -- upgrade unit for success in combat
    else
        -- this means loser's hitpoints >0, so this stuff only applies in a stack kill


    end
    -- this stuff applies for all unit kills, regardless of whether the loser was killed
    -- in a stack


    -- downgrade defeated unit (i.e. put replacement 'worse' unit in its place)
end
promotion.unitKilledInCombat = unitKilledInCombat




return promotion

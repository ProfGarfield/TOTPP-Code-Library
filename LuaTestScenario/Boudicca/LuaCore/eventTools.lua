-- This is a module that contains stuff to make other events work,
-- so as not to clutter the general library
local eventTools = {}

local eventToolsState = "state not linked"


local function linkState(stateTable)
    if type(stateTable) == "table" then
        eventToolsState = stateTable
    else
        error("eventTools.linkState: linkState takes a table as an argument.")
    end
    -- eventToolsState.activationUnitIDs[unitID] = true if the unit is an activation guarantor
    eventToolsState.activationUnitIDs = eventToolsState.activationUnitIDs or {}
    -- eventToolsState.tribeActivationUnit[tribeID] = unitID or nil
    -- gives the unit (if it exists) that is guaranteeing that the tribe will have an active unit
    eventToolsState.tribeActivationUnit = eventToolsState.tribeActivationUnit or {}
end
eventTools.linkState = linkState

local activationUnitType = nil

-- set the unit type to be created for the unit that will
-- ensure a unit activation event will occur
local function setGuaranteeUnitActivationType(unitType)
    if not civ.isUnitType(unitType) then
        error("setGuaranteeUnitActivationType: argument must be a unit type")
    end
    if unitType.move == 0 then
        error("setGuaranteeUnitActivationType: unit must have movement allowance greater than 0.")
    end
    activationUnitType = unitType

end
eventTools.setGuaranteeUnitActivationType = setGuaranteeUnitActivationType

local activationGuaranteeUnitPlacementLocationFunction = function(tribe) error("eventTools: the function setGuaranteeActivationUnitLocationFunction has not been run.") end

local function setGuaranteeActivationUnitLocationFunction(func)
    activationGuaranteeUnitPlacementLocationFunction = func
end
eventTools.setGuaranteeActivationUnitLocationFunction = setGuaranteeActivationUnitLocationFunction

local function guaranteeUnitActivation(tribe)
    -- there is already an activation unit
    if eventToolsState.tribeActivationUnit and eventToolsState.tribeActivationUnit[tribe.id] then
        return
    end
    local actUnit = civ.createUnit(activationUnitType,tribe,activationGuaranteeUnitPlacementLocationFunction(tribe))
    eventToolsState.tribeActivationUnit = eventToolsState.tribeActivationUnit or {}
    eventToolsState.activationUnitIDs = eventToolsState.activationUnitIDs or {}
    eventToolsState.tribeActivationUnit[tribe.id]=actUnit.id
    eventToolsState.activationUnitIDs[actUnit.id]=true
end
eventTools.guaranteeUnitActivation = guaranteeUnitActivation

local function guaranteeUnitActivationForNextActiveTribe(currentTribe)
    local currentTribeID = currentTribe.id
    for i=1,8 do
        if civ.getTribe((currentTribeID+i)%8).active then
            guaranteeUnitActivation(civ.getTribe((currentTribeID+i)%8))
            return
        end
    end
end
eventTools.guaranteeUnitActivationForNextActiveTribe = guaranteeUnitActivationForNextActiveTribe


local function unitActivation(unit,source)
    local tribeID = unit.owner.id
    if eventToolsState.tribeActivationUnit[tribeID] then
        eventToolsState.activationUnitIDs[eventToolsState.tribeActivationUnit[tribeID]] = nil
        civ.deleteUnit(civ.getUnit(eventToolsState.tribeActivationUnit[tribeID]))
        eventToolsState.tribeActivationUnit[tribeID] = nil
    end
end
eventTools.unitActivation = unitActivation

local function unitDeletion(dyingUnit)
    if eventToolsState.activationUnitIDs[dyingUnit.id] then
        eventToolsState.activationUnitIDs[dyingUnit.id] = nil
        eventToolsState.tribeActivationUnit[dyingUnit.owner.id] = nil
    end
    guaranteeUnitActivation(dyingUnit.owner)
end
eventTools.unitDeletion = unitDeletion

return eventTools

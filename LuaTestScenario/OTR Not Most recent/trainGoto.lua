-- File for OTR to enable train units to use the GOTO command over
-- longer distances, where the in game goto command will fail due to
-- most terrain being impassible
--

-- method: If eligible unit (a train) is activated and has a goto order, save the tile
-- the train is travelling to, and the train itself, and give it a new goto order
-- for one square beyond its movement allowance for the turn.  The train can likely
-- figure out how to reach that destination, and will move to it.
-- When the next unit is activated, reset the goto order to the actual destination
--

local eligibleUnit = {}
eligibleUnit[6] = true -- freight train
eligibleUnit[11] = true -- flak train
local previousUnit = nil
local previousUnitDestination = nil
local pathfind = require("pathfind")

local trainCanCrossTerrain = {
    [0]=true,
    [1]=true,
    [4]=true,
    [6]=true,
    [8]=true,
    [9]=true,
    [12]=true,
    [13]=true,
    [14]=true,
}
-- trainGoto
-- sets the unit's goto order to 1 square beyond its 
-- movement allowance to the destination, or to the destination
-- itself if it is within the movement allowance
local trainGoto = {}

local function isTrain(unit)
    return eligibleUnit[unit.type.id] or false
end
trainGoto.isTrain = isTrain

local function trainGotoGuts(unit,destination)
    -- reset the final destination of previous unit if applicable
    if previousUnit and previousUnitDestination then
        previousUnit.gotoTile = previousUnitDestination
    end
    previousUnit = nil
    previousUnitDestination = nil
    local pathTable = pathfind.breadthFirstSearchFixedCost(unit.location,{destination},trainCanCrossTerrain,{})
    if pathTable and pathTable[1] then 
        -- a path to the destination was found, get the tile 1 square beyond the maximum movement allowance
        local tempDestination = pathTable[1][unit.type.move+1]
        if tempDestination then
            -- this means the path to the destination is longer than the unit
            -- can reach in one turn
            previousUnit = unit
            previousUnitDestination = destination
            unit.gotoTile = tempDestination
        else  
            -- there is a path to the destination, and it is within this turn's movement
            -- allowance, so just go
            unit.gotoTile = destination
            previousUnit = nil
            previousUnitDestination = nil
        end
    else
       -- no path to the destination
       local destString = nil
       if destination.city then
           destString = destination.city.name
       else
           destString = "("..tostring(destination.x)..","..tostring(destination.y)..","..tostring(destination.z)..")"
       end
       civ.ui.text("There does not appear to be a route for this train to reach its destination at "..destString..".")
        unit.gotoTile = unit.location
    end
end
trainGoto.trainGotoGuts = trainGotoGuts

local function trainGotoOnActivate(unit)
    -- reset the final destination of previous unit if applicable
    if previousUnit and previousUnitDestination then
        previousUnit.gotoTile = previousUnitDestination
    end
    previousUnit = nil
    previousUnitDestination = nil
    if not eligibleUnit[unit.type.id] then
        -- not a train, so nothing to be done
        return
    end
    if not unit.gotoTile then
        -- no goto order, so return
        return
    end
    trainGotoGuts(unit,unit.gotoTile)
end

trainGoto.trainGotoOnActivate = trainGotoOnActivate


return trainGoto

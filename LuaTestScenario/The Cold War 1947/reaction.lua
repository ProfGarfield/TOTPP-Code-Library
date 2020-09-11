local debugFeatures = false

local function debugPrint(printobject)
    if debugFeatures then
        print(printobject)
    end
end
-- Required functions for usage
--      (these will probably draw the necessary data from tables)
-- canReactFunction(triggerUnit,reactingUnit) --> bool
--      Takes a pair of units and determines if the reacting unit can target the trigger unit
--      allied/enemy status, range, etc, should be considered in this function

-- targetReactionDamage(triggerUnit,reactingUnit) --> integer
--      computes the damage that triggerUnit will take from reactingUnit
--      If this is random, the randomness should be generated in this function

-- willReact(triggerUnit,reactingUnit,reactingUnitsTable,otherNearbyUnitsTable) --> bool
--      Determines if the reactingUnit will attack the triggerUnit
--      For example, if the unit is an areaDamageUnit and more damage would be done to allied units, the areaDamageUnit might not attack

-- isAreaDamageUnit(triggerUnit reactingUnit) --> bool
--      return true if reactingUnit does reaction damage to units other than the trigger unit

-- areaDamageToReactingUnit(otherReactingUnit,areaDamageUnit,triggerUnit) --> integer
--      computes the damage that a unit reacting to a trigger unit will receive from the AreaDamageUnit
--      If this is random, the randomness should be generated in this function
--      an areaDamageUnit will NOT have the opportunity to damage itself through this function
--      if the unit is not an area damage unit return 0 (but this shouldn't trigger anyway)

-- areaDamageToNotReactingUnit(nearbyUnit,areaDamageUnit,triggerUnit) --> integer
--      computes the damage to nearbyUnit (that is not the trigger unit) from areaDamageUnit
--      If this is random, the randomness should be generated in this function
--      enemy/neutral/allied status should be considered in this function
--      if the unit is not an area damage unit return 0 (but this shouldn't trigger anyway)



-- reactionPriority(triggerUnit,reactingUnit) --> number
--      provides a number that will be used to determine what units will "attack" first
--      (important in case the attacking unit is killed)
--      Higher number increases priority

-- postReactionFunction(triggerUnit,reactingUnit) --> void
--      does stuff after the reacting unit has reacted (e.g. update saturation table, spend money)

-- killFunction(deadUnit,reactingUnit) --> unit or false
--      does stuff (including deleting the unit) if the reactingUnit kills the trigger unit
--      perhaps a table has to be updated or a replacement unit created
--      if the unit is replaced (e.g. a damaged bomber in OTR3) return that unit
--      otherwise, return false






local function addUnitsAtLocationToTable(unitTable,tile)
    for unit in tile.units do
        table.insert(unitTable,unit)
    end
end
-- adds tile (x,y,z) to tileTable if that tile exists
-- if allMaps is true, adds tile (x,y) for maps 0-3 if they exist
local function addTileToTable(x,y,z,tileTable,allMaps)
    if allMaps then
        for i=0,3 do
            if civ.getTile(x,y,i) then
                table.insert(tileTable,civ.getTile(x,y,i))
            end
        end
    else
        if civ.getTile(x,y,z) then
            table.insert(tileTable,civ.getTile(x,y,z))
        end
    end
end

--tileRing(tile,int,table,bool)
-- Center tile is the tile at the center of the ring
-- dist means the distance (in unit movement points) from the center tile
-- tileTable is the table to add the tiles to
-- useAllMaps is true if you want to get the tile from all maps in the game,
-- false means only the map corresponding to centerTile
local function tileRing(centerTile,dist,tileTable,useAllMaps)
    local twodist = 2*dist
    local x = centerTile.x
    local y = centerTile.y
    local z = centerTile.z
    -- start at 1 instead of 0 since i=0 yields the last tile in 
    -- the previous loop (or, the 4 loop in the case of the first)
    for i=1,twodist do
        addTileToTable(x+i,y+twodist-i,z,tileTable,useAllMaps)
    end
    for i=1,twodist do
        addTileToTable(x+twodist-i,y-i,z,tileTable,useAllMaps)
    end
    for i=1,twodist do
        addTileToTable(x-i,y-twodist+i,z,tileTable,useAllMaps)
    end
    for i=1,twodist do
        addTileToTable(x-twodist+i,y+i,z,tileTable,useAllMaps)
    end
    if dist == 0 then
        -- above code fails to capture center tile if dist is 0
        addTileToTable(x,y,z,tileTable,useAllMaps)
    end
end

-- puts all tiles within dist of centerTile into tileTable (tileTable indexed by integers)
-- allMaps is a bool that when true gets tiles from every map, not just the one where centerTile is
local function diamond(centerTile,dist,tileTable,allMaps)
    for i=0,dist do
        tileRing(centerTile,i,tileTable,allMaps)
    end
end


-- finds all the units that are within rangeToCheck of the triggering unit,
-- including the triggering unit itself
local function unitsInRange(triggerUnit,unitTable, rangeToCheck)
    local tilesToCheck = {}
    diamond(triggerUnit.location,rangeToCheck,tilesToCheck,true)
    for index, tile in pairs(tilesToCheck) do
        addUnitsAtLocationToTable(unitTable,tile)
    end
end

local function makeReactionTables(triggerUnit,unitsInRangeTable,reactingUnitsTable,otherNearbyUnitsTable,canReactFunction,reactionPriority)
    for __, unit in pairs(unitsInRangeTable) do
            debugPrint("Result of canReactFunction")
            debugPrint(canReactFunction(triggerUnit,unit))
        if unit==triggerUnit then
        
        elseif canReactFunction(triggerUnit,unit) then
            debugPrint("This unit inserted into reactingUnitsTable")
            debugPrint(unit)
            table.insert(reactingUnitsTable,unit)
        else
            debugPrint("This unit inserted into otherNearbyUnitsTable")
            debugPrint(unit)
            table.insert(otherNearbyUnitsTable,unit)
        end
    end
    table.sort(reactingUnitsTable,function(a,b) return reactionPriority(triggerUnit,a) >= reactionPriority(triggerUnit,b) end)
    if debugFeatures then
        debugPrint("units in InRangeTable")
        for __,unit in pairs(unitsInRangeTable) do
            print(unit)
        end
        debugPrint("units in ractingUnitsTable")
        for __,unit in pairs(reactingUnitsTable) do
            print(unit)
        end
        debugPrint("units in otherNearbyUnitsTable")
        for __,unit in pairs(otherNearbyUnitsTable) do
            debugPrint(unit)
        end
    
    end
end


-- Performs the reaction of a single unit
-- Performs the kill functions for any unit killed, and the postReactionFunction
-- Returns the triggerUnit (either original or replaced) or false if the attack should
-- not continue (i.e. if the trigger unit was destroyed and not replaced)
local function individualReaction(triggerUnit,reactingUnit,reactingUnitsTable,otherNearbyUnitsTable,
                    targetReactionDamage, postReactionFunction,killFunction)

    -- effect on other units

    -- This is moved after the effect on other units because if the trigger unit is killed (and hence deleted), that affects other calculations involving that unit
    -- the other 
    local returnUnit = triggerUnit
    local mainDamage = targetReactionDamage(triggerUnit,reactingUnit)
    -- effect on the trigger unit
    if mainDamage >= triggerUnit.hitpoints then
        returnUnit = killFunction(triggerUnit,reactingUnit)
    else
        triggerUnit.damage = triggerUnit.damage + mainDamage
    end
    
    
    postReactionFunction(triggerUnit,reactingUnit)
    return returnUnit
end -- function individualReaction
    
local function reaction(triggerUnit,rangeToCheckForReactingUnits,
                canReactFunction,targetReactionDamage,willReact,
                 reactionPriority,
                postReactionFunction,killFunction)
    local unitsInRangeTable = {}
    unitsInRange(triggerUnit,unitsInRangeTable,rangeToCheckForReactingUnits)
    local reactingUnitsTable ={}
    local otherNearbyUnitsTable={}
    makeReactionTables(triggerUnit,unitsInRangeTable,reactingUnitsTable,
                          otherNearbyUnitsTable,canReactFunction,reactionPriority)

    table.sort(reactingUnitsTable, function(a,b) return reactionPriority(triggerUnit,a) >= reactionPriority(triggerUnit,b) end)
    local numberReactingUnits = #reactingUnitsTable
    local currentTriggerUnit = triggerUnit
    for index = 1,numberReactingUnits do
        if reactingUnitsTable[index] ~= nil then
           reactingUnit = reactingUnitsTable[index]
            if willReact(currentTriggerUnit,reactingUnit,reactingUnitsTable,otherNearbyUnitsTable) then
                currentTriggerUnit = individualReaction(currentTriggerUnit,reactingUnit,reactingUnitsTable,
                                    otherNearbyUnitsTable,targetReactionDamage, postReactionFunction,killFunction)
            end
            if currentTriggerUnit == false then
                break -- stop reactions once the currentTriggerUnit is killed and not replaced
            end
        end --if reactingUnitsTable[index] ~= nil
    end --for index = 1,numberReactingUnits do                
end -- function reaction
    
return{ reaction=reaction}
















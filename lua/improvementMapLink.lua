-- A module to link city improvements with units and terrain on the map
-- For example, for strategic bombing
--

local gen = require("generalLibrary")


local improvementMapLink = {}
-- Preset Target System
-- Every target is specified ahead of time
-- The same target unit can be used for multiple city improvements
-- as long as they are on different tiles
-- An improvement can have targets on multiple tiles, if a sinlge
-- target unit is killed, the improvement is deleted, the other targets
-- are deleted, and terrain is changed if applicable

-- Target Specification
--  TargetTable[i] = table with keys listed below
--      i index doesn't matter, table will be programmatically processed
--  keys
--      .city = cityObject or locationObject or {integer,integer} or {integer,integer,integer}
--          specifies the city associated with the particular target
--          must be specified
--      .improvement = improvementObject or wonderObject
--          specifies the improvement (or wonder) associated with the target
--          must be specified
--      .destroyWonder = bool or false
--          if true, and .improvement is a wonder, the wonder is destroyed when the
--          target is killed.  If false, the wonder can be built again
--          nil means false
--      .targetTiles =table of tables with following keys 
--              .tile = tileObject or {integer,integer} or {int, int, int}
--                  a tile associated with the city and improvement   
--              .targetUnitType = unitTypeObject or nil
--                  chooses a unitType to act as a target on the tile
--                  nil means no unit on this tile
--              .targetHomeCity = bool or nil
--                  if true, set the target unit's home city to the city
--                  false or nil means target has no home city
--              .buildTerrain = nil or integer between 0 and 15 (inclusive)
--                  change the terrainType to this number when the improvement is built
--                  nil means don't change the terrain when the improvement is built
--              .destroyTerrain = nil or integer between 0 and 15 (inclusive)
--                  change the terrainType to this number when the improvement is destroyed
--                  (or discovered to be sold)
--                  nil means don't change the terrain when the improvement is destroyed
--              .buildFunction = nil or function(tileObject,cityObject,improvementObject)
--                  function to run when the improvement is built
--                  (e.g. could change tile improvements or something)
--                  nil means don't do anything
--              .destroyFunction = nil or function(tileObject,cityObject,improvementObject)
--                  function to run when the improvement is destroyed (or discovered destroyed)
--                  (e.g. could change tile improvements or something)
--                  nil means don't do anything


--      INTERNAL DATA SYSTEMS
--      End user doesn't need to understand these
--
--      constructionTable[gen.getTileID(cityLocation)][improvementObject or wonderObject] = table of
--          {tile=tileObject,targetUnitType=unitTypeObject or nil,targetHomeCity = bool or nil,
--          buildTerrain=integer or nil, buildFunction = function or nil}
--          note: The second key is the userData of improvement or wonder, not an integer id.
--          this is because the id numbers of these two things overlap, and table keys don't
--          have to be integers or strings
--          nil means the improvement/city has no associated changes
--
--
--      destructionTable[gen.getTileID(location)][unitType.id] = table with keys
--          .cityLocation = locationObject
--          .improvement = improvementObject or wonderObject
--          .tiles = table of {tile = tileObject, targetUnitType = unitTypeObject,
--                              destroyTerrain = nil or integer,destroyFunction = nil or function}

local function buildConstructionTable(targetTable)
    local constructionTable = {}
    for key,targetDetails in pairs(targetTable) do
        local cityLocation = nil
        local cityInfo = targetDetails.city
        if civ.isCity(cityInfo) then
            cityLocation = cityInfo.location
        elseif civ.isTile(cityInfo) then
            cityLocation = cityInfo
        elseif type(cityInfo) == "table" then
            local xVal = cityInfo[1]
            local yVal = cityInfo[2]
            local zVal = cityInfo[3] or 0
            if not (type(xVal) == "number" and type(yVal) == "number" and type(zVal) == "number") then
                error("buildConstructionTable: The target information table key "..tostring(key).." doesn't have a valid city or location specified.")
            end
            cityLocation = civ.getTile(xVal,yVal,zVal)
        end
        if not cityLocation then
            error("buildConstructionTable: The target information table key "..tostring(key).." doesn't have a valid city or location specified.")
        end
        if not (civ.isImprovement(targetDetails.improvement) or civ.isWonder(targetDetails.improvement)) then
            error("buildConstructionTable: The target information table key "..tostring(key).." doesn't have a valid improvement specified.")
        end
        local valueTable = {}
        local vTIndex = 1
        if targetDetails.targetTiles.tile then
            -- a single tile of information is specified instead of a table of tables
            valueTable[vTIndex] = {}
            valueTable[vTIndex].tile = gen.toTile(targetDetails.targetTiles.tile)
            valueTable[vTIndex].targetUnitType = targetDetails.targetTiles.targetUnitType
            valueTable[vTIndex].targetHomeCity = targetDetails.targetTiles.targetHomeCity
            valueTable[vTIndex].buildTerrain = targetDetails.targetTiles.buildTerrain
            valueTable[vTIndex].buildFunction = targetDetails.targetTiles.buildFunction
            vTIndex = vTIndex+1
        else
            -- there is a table of tiles
            for index,targetTileInfo in pairs(targetDetails.targetTiles) do
                valueTable[vTIndex] = {}
                valueTable[vTIndex].tile = gen.toTile(targetTileInfo.tile)
                valueTable[vTIndex].targetUnitType = targetTileInfo.targetUnitType
                valueTable[vTIndex].targetHomeCity = targetTileInfo.targetHomeCity
                valueTable[vTIndex].buildTerrain = targetTileInfo.buildTerrain
                valueTable[vTIndex].buildFunction = targetTileInfo.buildFunction
                vTIndex = vTIndex+1
            end
        end
        constructionTable[gen.getTileID(cityLocation)][targetDetails.improvement] = valueTable
    end
    return constructionTable
end

            
local function buildDestructionTable(targetTable)
    local destructionTable = {}
    for key,targetDetails in pairs(targetTable) do
        local targetTiles = targetTable

end




        


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
--      constructionTable[gen.getTileID(cityLocation)][improvementObject.id] = table of
--          {tile=tileObject,targetUnit=unitTypeObject or nil,targetHomeCity = bool or nil,
--          buildTerrain=integer or nil, buildFunction = function or nil}
--
--      destructionTable[gen.getTileID(location)][unitType.id] = table with keys
--          .cityLocation = locationObject
--          .improvement = improvementObject
--          .tiles = table of {tile = tileObject, targetUnit = unitTypeObject,
--                              destroyTerrain = nil or integer,destroyFunction = nil or function}


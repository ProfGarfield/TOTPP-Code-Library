-- The Map Library
-- This Library provides tools related to the
-- game maps and individual tiles
--
-- Any function here that accepts a tile will also
-- accept a table {[1]=x,[2]=y,[3]=z}, a table 
-- {[1]=x,[2]=y} and assume z = 0, or a table
-- {x=x,y=y,z=z}, or a table {x=x,y=y} and assume
-- z = 0
--
-- LIST OF FUNCTIONS
-- * means planned but not implemented
-- # means needs testing
--
--#hasIrrigation(tile)-->boolean
--#placeIrrigation(tile)-->void
--#removeIrrigation(tile)-->void
--*hasMine(tile)-->boolean
--*placeMine(tile)-->void
--*removeMine(tile)-->void
--*hasFarmland(tile)-->boolean
--*placeFarmland(tile)-->void
--*removeFarmland(tile)-->void
--*hasRoad(tile)-->boolean
--*placeRoad(tile)-->void
--*removeRoad(tile)-->void
--*hasRailroad(tile)-->boolean
--*placeRailroad(tile)-->void
--*removeRailroad(tile)-->void
--*hasFortress(tile)-->boolean
--*placeFortress(tile)-->void
--*removeFortress(tile)-->void
--*hasAirbase(tile)-->boolean
--*placeAirbase(tile)-->void
--*removeAirbase(tile)-->void
--*hasPollution(tile)-->boolean
--*placePollution(tile)-->void
--*removePollution(tile)-->void
--*hasTransporter(tile)-->boolean
--*placeTransporter(tile)-->void
--*removeTransporter(tile)-->void
--*irrigateAnywhere(nil or function(unitType)-->boolean)-->void
local map = {}
-- FUNCTION IMPLEMENTATIONS
--
-- 
-- toTile(tile or table)-->tile
-- If given a tile object, returns the tile
-- If given coordinates for a tile, returns the tile
-- Causes error otherwise
-- Helper Function
local function toTile(input)
    if civ.isTile(input) then
        return input
    elseif type(input) == "table" then
        local xVal = input[1] or input["x"]
        local yVal = input[2] or input["y"]
        local zVal = input[3] or input["z"] or 0
        if type(xVal)=="number" and type(yVal)=="number" and type(zVal)=="number" then
            if civ.getTile(xVal,yVal,zVal) then
                return civ.getTile(xVal,yVal,zVal)
            else
                error("Table with values {"..tostring(xVal)..","..tostring(yVal)..
                        ","..tostring(zVal).."} does not correspond to a valid tile.")
            end
        else
            error("Table did not correspond to tile coordinates")
        end
    else
        error("Did not receive a tile object or table of coordinates.")
    end
end

-- hasIrrigation(tile)-->boolean
-- returns true if tile has irrigation but no farm
-- returns false otherwise
local function hasIrrigation(tile)
    tile = toTile(tile)
    local improvements = tile.improvements
    -- irrigation, but no mining, so not farmland
    if improvements & 0x04 == 0x04 and improvements & 0x08 == 0 then
        return true
    else
        return false
    end
end
map.hasIrrigation = hasIrrigation

-- placeIrrigation(tile)-->void
-- places irrigation on the tile provided
-- removes mines and farmland if present
-- does nothing if tile has a city
local function placeIrrigation(tile)
    tile = toTile(tile)
    if tile.city then
        return
    end
    -- Set irrigation bit to 1
    tile.improvements = tile.improvements | 0x04
    -- Set mining bit to 0
    tile.improvements = tile.improvements & ~0x08
end
map.placeIrrigation = placeIrrigation

-- removeIrrigation(tile)-->void
-- If tile has irrigation but no farmland, removes the irrigation
-- Does nothing to farmland
-- Does nothing if tile has a city
local function removeIrrigation(tile) 
    tile = toTile(tile)
    -- if tile has a city or farmland, do nothing
    if tile.city or tile.improvements & 0x0C == 0x0C then
        return
    end
    -- set irrigation bit to 0
    tile.improvements = tile.improvements & ~0x04
end
map.removeIrrigation = removeIrrigation

-- hasMine(tile)-->boolean
-- local function hasMine(tile) end
-- map.hasMine = hasMine

-- placeMine(tile)-->void
-- local function placeMine(tile) end
-- map.placeMine = placeMine

-- removeMine(tile)-->void
-- local function removeMine end
-- map.removeMine = removeMine

-- hasFarmland(tile)-->boolean
-- local function hasFarmland(tile) end
-- map.hasFarmland = hasFarmland

-- placeFarmland(tile)-->void
-- local function placeFarmland(tile) end
-- map.placeFarmland = placeFarmland

-- removeFarmland(tile)-->void
-- local function removeFarmland(tile) end
-- map.removeFarmland = removeFarmland

-- hasRoad(tile)-->boolean
-- local function hasRoad(tile) end
-- map.hasRoad = hasRoad

-- placeRoad(tile)-->void
-- local function placeRoad(tile) end
-- map.placeRoad = placeRoad

-- removeRoad(tile)-->void
-- local function removeRoad(tile) end
-- map.removeRoad = removeRoad

-- hasRailroad(tile)-->boolean
-- local function hasRailroad(tile) end
-- map.hasRailroad = hasRailroad

-- placeRailroad(tile)-->void
-- local function placeRailroad(tile) end
-- map.placeRailroad = placeRailroad

-- removeRailroad(tile)-->void
-- local function removeRailroad(tile) end
-- map.removeRailroad = removeRailroad

-- hasFortress(tile)-->boolean
-- local function hasFortress(tile) end
-- map.hasFortress = hasFortress

-- placeFortress(tile)-->void
-- local function placeFortress(tile) end
-- map.placeFortress = placeFortress

-- removeFortress(tile)-->void
-- local function removeFortress(tile) end
-- map.removeFortress = removeFortress

-- hasAirbase(tile)-->boolean
-- local function hasAirbase(tile) end
-- map.hasAirbase = hasAirbase

-- placeAirbase(tile)-->void
-- local function placeAirbase(tile) end
-- map.placeAirbase = placeAirbase

-- removeAirbase(tile)-->void
-- local function removeAirbase(tile) end
-- map.removeAirbase = removeAirbase

-- hasPollution(tile)-->boolean
-- local function hasPollution(tile) end
-- map.hasPollution = hasPollution

-- placePollution(tile)-->void
-- local function placePollution(tile) end
-- map.placePollution = placePollution

-- removePollution(tile)-->void
-- local function removePollution(tile) end
-- map.removePollution = removePollution

-- hasTransporter(tile)-->boolean
-- local function hasTransporter(tile) end
-- map.hasTransporter = hasTransporter

-- placeTransporter(tile)-->void
-- local function placeTransporter(tile) end
-- map.placeTransporter = placeTransporter

-- removeTransporter(tile)-->void
-- local function removeTransporter(tile) end
-- map.removeTransporter = removeTransporter
--
-- irrigateAnywhere(nil or function(unitType)-->boolean)-->void
-- Allows units to irrigate without access to water
-- Default means all settlers can do it
-- If canIrrigateAnywhereFn returns true for the active unit,
-- That unit can irrigate the current square, even if it is
-- not a unit with role 5 (although such a unit will keep the
-- irrigation order after it finishes irrigating)
-- Usage: 
-- In civ.scen.onKeyPress(function(keyCode)
--      if keyCode == 73 --[[i]] then
--          map.irrigateAnywhere()
--      end
--      end)
-- In civ.scen.onKeyPress(function(keyCode)
--      if keyCode == 73 --[[i]] then
--          map.irrigateAnywhere(canIrrigateAnywhereFn)
--      end
--      end)
local function irrigateAnywhere(canIrrigateAnywhereFn)
    if not canIrrigateAnywhereFn then
        canIrrigateAnywhereFn = function(unitType)
            return unitType.role ==5
        end
    end
    local activeUnit = civ.getActiveUnit()
    if activeUnit and canIrrigateAnywhereFn(activeUnit.type)
        and not hasIrrigation(activeUnit.location) then
        activeUnit.order = 0x06
    end
    return
end
map.irrigateAnywhere = irrigateAnywhere

-- preventIrrigation(nil or function(unit)-->bool)
--
-- If preventFromIrrigatingFn(unit) returns true, the
-- unit is prevented from irrigating
local function preventIrrigation(preventFromIrrigatingFn)
    if not preventFromIrrigatingFn then
        preventFromIrrigatingFn = function(unit) return true end
    end
    local activeUnit = civ.getActiveUnit()
    if activeUnit and preventFromIrrigatingFn(activeUnit) then
        activeUnit:activate()
    end
end
map.preventIrrigation = preventIrrigation

return map

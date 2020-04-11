-- Radar Functionality Library by Prof. Garfield (except where otherwise stated)
-- Usage


-- Returns a single-value numeric key that uniquely identifies a tile on any map
--[[ by Knighttime ]]
local function getTileId (tile)
	if tile == nil then
		print("ERROR: \"getTileId\" function called with an invalid tile (input parameter is nil)")
		return nil
	end
	local mapWidth, mapHeight, mapQuantity = civ.getMapDimensions()
	local mapOffset = tile.z * mapWidth * mapHeight
	local tileOffset = tile.x + (tile.y * mapWidth)
	return mapOffset + tileOffset
end

-- Returns the tile associated with a unique identifier integer
-- (undoes Knighttime's getTileID)
-- Return nil if no tile corresponds to the ID
local function getTileFromId(ID)
    local mapWidth, mapHeight, mapQuantity = civ.getMapDimensions()
    local baseMapOffset = mapWidth*mapHeight
    local z = math.floor(ID/baseMapOffset)
    if z < 0 or z >3 then
        print("getTileFromID: did not receive a valid ID")
        return nil
    end
    local tileOffset = ID % baseMapOffset
    local y = math.floor(tileOffset/mapWidth)
    local x = tileOffset % mapWidth
    return civ.getTile(x,y,z)
end

return{getTileId = getTileId,
        getTileFromId = getTileFromId,}

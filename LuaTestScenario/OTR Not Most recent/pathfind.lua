
local pathfind = {}

-- Returns a single-value numeric key that uniquely identifies a tile on any map
--[[ by Knighttime ]]
-- Modification: if input is a number, that number is returned
-- this way, we don't have to worry about inputs already being in the correct form
local function getTileId (tile)
    if type(tile) == "number" then
        return tile
    end
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
-- (undoes Knighttime's getTileId)
-- Return nil if no tile corresponds to the ID
-- if a tile is input, the tile is returned
local function getTileFromId(ID)
    if civ.isTile(ID) then
        return ID
    end
    local mapWidth, mapHeight, mapQuantity = civ.getMapDimensions()
    local baseMapOffset = mapWidth*mapHeight
    local z = math.floor(ID/baseMapOffset)
    if z < 0 or z >3 then
        print("getTileFromId: did not receive a valid ID")
        return nil
    end
    local tileOffset = ID % baseMapOffset
    local y = math.floor(tileOffset/mapWidth)
    local x = tileOffset % mapWidth
    return civ.getTile(x,y,z)
end

local function manhattan(tile1,tile2)
    return (math.abs(tile1.x-tile2.x)+math.abs(tile1.y-tile2.y))//2
end

local function getNeighbours(tile)
   local neighbourList = {}
   local offsets = {{0,2},{1,1},{2,0},{1,-1},{0,-2},{-1,-1},{-2,0},{-1,1}}
   local neighbourListIndex = 1
   for __,offset in pairs(offsets) do
       neighbourList[neighbourListIndex] = civ.getTile(tile.x+offset[1],tile.y+offset[2],tile.z)
       neighbourListIndex=neighbourListIndex+1
   end
   return neighbourList
end


-- breadthFirstSearchFixedCost(source,destinationTable,canTraverse,excludedTiles) --> table of table of tiles
-- Searches for best paths from source to each destination using the breadthFristSearch algorithm
--      cost between tiles is fixed at 1
-- source is the tile to start searching from
-- destinationTable is a table of destinations that we wish to find distances and paths to
-- canTraverse is a table indexed 0 to 15, where canTraverse[i]= true if the ith terrain
-- type can be traversed.
-- Or, it is a function(tile)--> bool
-- that returns true if the tile can be traversed, and false otherwise
-- excludedTiles is a table of tiles (or single-value tileIds) that are not to be traversed
-- even if canTraverseFn says they can be
-- returns paths from each destination to the original source,
-- as a table of tiles from the source to the destination, including the
-- destination tile and the source tile
-- returns nil for the destination key if no path was found
-- the path should be a shortest path

local function breadthFirstSearchFixedCost(source,destinationTable,canTraverse,excludedTiles)
    local canTraverseTable = {}
    local function canTraverseFromTable(tile)
        return canTraverseTable[(tile.terrainType % 16)]
    end
    local canTraverseFn = nil
    if type(canTraverse) == "table" then
        for index,value in pairs(canTraverse) do
            canTraverseTable[index] = value
        end
        canTraverseFn = canTraverseFromTable
    elseif type(canTraverse) == "function" then
        canTraverseFn = canTraverse
    else
        error("breadthFirstSearchFixedCost: canTraverse must be either a table or function.")
    end
    -- traversedTiles values
    -- true means the tile was an excluded tile
    -- number is the tileId of the tile that the traversed tile was explored "from"
    -- following the traversed tiles gives a path from the source to the destination
    local traversedTiles = {}
    for __, tile in pairs(excludedTiles) do
        traversedTiles[getTileId(tile)] = true
    end
    print(#traversedTiles,#excludedTiles)
    -- futureTiles has values of tileIDs that are to be explored
    traversedTiles[getTileId(source)]=getTileId(source)
    local futureTiles = {[1]=getTileId(source),}
    -- nextTileIndex is the index of futureTiles that should be examined next
    -- lastUsedIndex is the last index in futureTiles that has an entry
    -- I run this recursion so many times, that it appears I need
    -- to invoke manual garbage collection
    local function BFSFC(currentTile,currentTileIndex,lastUsedIndex)
        local neighbourList = getNeighbours(currentTile)
        for __,tile in pairs(neighbourList) do
            local idOfTile = getTileId(tile)
            if not(traversedTiles[idOfTile]) and canTraverseFn(tile) then
                traversedTiles[idOfTile] = getTileId(currentTile)
                lastUsedIndex = lastUsedIndex+1
                futureTiles[lastUsedIndex] = idOfTile
            end
        end
        if currentTileIndex >= lastUsedIndex then
            -- this means there are no more tiles to explore
            return
        end
        futureTiles[currentTileIndex]=nil
        currentTileIndex = currentTileIndex+1
        currentTile = getTileFromId(futureTiles[currentTileIndex])
        return BFSFC(currentTile,currentTileIndex,lastUsedIndex,initialMemoryAllocation)
    end
    BFSFC(source,1,1,collectgarbage("count"))
    local function reverseTable(table)
        local tableLength = #table
        for i=0,(tableLength//2-1) do
            local spare = table[tableLength-i]
            table[tableLength-i] = table[1+i]
            table[1+i] = spare
        end
    end
    local function getSourceToDestination(destinationTile)
        local destVal = traversedTiles[getTileId(destinationTile)]
        if destVal == true
            -- this means the tile was excluded
            or not destVal then
            -- this means the tile was never reached, or was not
            -- traversable
            return nil
        end
        local pathTable = {}
        local pathTableIndex = 1
        local previousTile = nil
        local currentTile = destinationTile
        while currentTile ~= previousTile do
            pathTable[pathTableIndex] = currentTile
            pathTableIndex=pathTableIndex+1
            previousTile = currentTile
            currentTile = getTileFromId(traversedTiles[getTileId(currentTile)])
        end
        reverseTable(pathTable)
        return pathTable
    end

    local sourceToDestTable={}
    for index,tile in pairs(destinationTable) do
        sourceToDestTable[index] = getSourceToDestination(tile)
    end
    return sourceToDestTable
end
pathfind.breadthFirstSearchFixedCost=breadthFirstSearchFixedCost

return pathfind

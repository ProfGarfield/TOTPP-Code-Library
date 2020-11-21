func = require("functions")

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

local function hasRadarMarker(tile, markerType)
    if tile.city then
        -- if the tile has a city, then it definitely doesn't have a radar marker
        return false
    end
    local lowerCaseMarkerType = string.lower(markerType)
    if lowerCaseMarkerType == "pollution" then
        -- pollution flag is the -128 bit
        -- transporter flag is the -128 bit and the 2 bit together, so must exclude the case where both
        -- the -128 bit and the 2 bit are both set to 1
        return tile.improvements & -126 == -128
    elseif lowerCaseMarkerType == "farmland" then
        -- farmland flag is the 4 bit (irrigation flag) and the 8 bit (mining flag)
        -- both set to 1 at the same time
        return tile.improvements & 12 == 12
    elseif lowerCaseMarkerType == "railroad" then
        -- railroad flag is the 32 bit, but it also needs the road flag (the 16 bit) set in order to display
        -- so we check if those two bits together are both set to 1
        return tile.improvements & 48 == 48
    elseif lowerCaseMarkerType == "fortress" then
        -- fortress flag is the 64 bit
        -- airbase flag is the 64 bit and the 2 bit together, so must exclude the case where both
        -- the 64 bit and the 2 bit are both set to 1
        return tile.improvements & 66 == 64
    else
        error(tostring(markerType).." is not a valid radar marker type.",2)
    end
end


-- removalInfo = {tileImprovements = int, tribe0Vision = bool, tribe1Vision = bool, tribe2Vision = bool, ..., tribe7Vision = bool}
-- tileImprovements is the integer specifying what the improvements for a particular tile should be
--      (since they may have to be changed to place the radar marker)
-- tribeIVision means that the tribe had units close enough to see the radar marker being placed, and so a spotter unit will have to be created for that tribe to clear the vision.


-- tile is the tile where the radar marker will be placed
-- markerType is one of these four strings
-- "pollution" "railroad" "fortress" "farmland"
-- safe tile is the center of 9 tiles where units can be safely teleported while vision of the radar marker is being given to the radar user.
-- removalInfoTable is the state table that stores the info needed to remove the radar marker
local function placeRadarMarker(tile, radarTribe, markerType, safeTile, removalInfoTable, spotterUnit)
    if tile.city then
        -- Will not place radarMarker on a city in any circumstances
        -- Other conditions should be guarded against elsewhere
        return
    end
    local tileId = getTileId(tile)
    -- save the existing tile improvements
    -- If this tile already has an entry in removalInfoTable, it probably has a radar marker
    -- so we don't want to replace any data in the table (but we may add more).  If nothing
    -- at this particular tile entry, save the existing tile improvements.
    removalInfoTable[tileId] = removalInfoTable[tileId] or {tileImprovements = tile.improvements}
    local withinTwoSquares = {}
    -- If a tribe has units on the same map within 2 squares, it is possible they will see
    -- the radar marker, and, therefore, will need a spotter created when that
    -- marker is removed
    diamond(tile, 2, withinTwoSquares, false)
    for __, nearTile in pairs(withinTwoSquares) do
        if nearTile.defender then
            removalInfoTable[tileId]["tribe"..tostring(nearTile.defender.id).."Vision"] = true
        end
    end
    -- the radar tribe will also need a spotter when the marker is removed
    removalInfoTable[tileId]["tribe"..tostring(radarTribe.id).."Vision"] = true
    -- move all units on square and surrounding squares to the safe are
    -- we'll need to create a spotter unit so that the radar marker will show
    local nineSquares = {}
    diamond(tile,1,nineSquares,false)
    local nineSafeSquares = {}
    diamond(safeTile,1,nineSafeSquares,false)
    for i=1,9 do
        if nineSquares[i] then
            for unit in nineSquares[i].units do
                civ.teleportUnit(unit,nineSafeSquares[i])
            end
        end
    end
    -- now place the radar marker
    local lowerCaseMarkerType = string.lower(markerType)
    if lowerCaseMarkerType == "pollution" then
        if tile.improvements & 2 == 2 then
            -- remove the 'city' flag, because that would make it a transporter
            tile.improvements = tile.improvements & -3
        end
        -- set the -128 bit to put out the pollution/marker
        tile.improvements = tile.improvements | -128
    elseif lowerCaseMarkerType == "farmland" then
        -- make sure the 4 and 8 bits are set to 1
        tile.improvements = tile.improvements | 12
    elseif lowerCaseMarkerType == "railroad" then
        -- make sure the 16 and 32 bits are set to 1
        tile.improvements = tile.improvements | 48
    elseif lowerCaseMarkerType == "fortress" then
        if tile.improvements & 2 == 2 then
            -- remove the 'city' flag, since otherwise it would be an airbase
            tile.improvements = tile.improvements & -3
        end
        -- make sure the 64 bit is set to 1
        tile.improvements = tile.improvements | 64
    else
       error(tostring(markerType).." is not a valid radar marker type.",2)
    end 
    -- create and delete the spotter unit
    civ.deleteUnit(civ.createUnit(spotterUnit,radarTribe,tile))
    -- return the nearby units to their proper squares
    for i=1,9 do
        for unit in nineSafeSquares[i].units do
            civ.teleportUnit(unit,nineSquares[i])
        end
    end
end

local function removeRadarMarker(tile,markerType,safeTile,removalInfoTable,spotterUnit)
    if hasRadarMarker(tile,markerType) then
        local tileId = getTileId(tile)
        local nineSquares = {}
        diamond(tile,1,nineSquares,false)
        local nineSafeSquares = {}
        diamond(safeTile,1,nineSafeSquares,false)
        -- remove nearby units in preparation for 'spotters'
        local removalInfo = removalInfoTable[tileId]
        if removalInfo then
            for i=1,9 do
                if nineSquares[i] then
                    for unit in nineSquares[i].units do
                        civ.teleportUnit(unit,nineSafeSquares[i])
                    end
                end
            end
            -- restore improvements that existed before the radar marker was placed
           tile.improvements = removalInfo.tileImprovements
            -- put spotter units for each tribe that might have 'seen' the radar marker
            for i=0,7 do
                if removalInfo["tribe"..tostring(i).."Vision"] then
                    civ.deleteUnit(civ.createUnit(spotterUnit,civ.getTribe(i),tile))
                end
            end
            -- return units to their proper square
            for i=1,9 do
                for unit in nineSafeSquares[i].units do
                    civ.teleportUnit(unit,nineSquares[i])
                end
            end
        else
            -- if no removal info, just clear the tile as best possible
            if string.lower(markerType) == "railroad" then
                tile.improvements = tile.improvements & -33
            elseif string.lower(markerType) == "pollution" then
                tile.improvements = tile.improvements & 127
            elseif string.lower(markerType) == "farmland" then
                tile.improvements = tile.improvements & -9
            elseif string.lower(markerType) == "fortress" then
                tile.improvements = tile.improvements &-65
            end
        end
        removalInfoTable[tileId] = nil
        return
    else
        return
    end --if hasRadarMarker
end


-- radarSweep
-- return true if an enemy is detected, false otherwise
local function radarSweep(radarUser,rangeFunction,detectionFunction,markerType,removalInfoTable,spotterUnit,safeTile)
    local range, maps = rangeFunction(radarUser)
    local detectionTiles = {}
    for __,map in pairs(maps) do
        diamond(civ.getTile(radarUser.location.x,radarUser.location.y,map),range,detectionTiles,false)
    end
    local enemyDetected = false
    for __,tile in pairs(detectionTiles) do
        local radarMarkTile = detectionFunction(radarUser,tile,range)
        if radarMarkTile then
            placeRadarMarker(radarMarkTile,radarUser.owner,markerType,safeTile,removalInfoTable,spotterUnit)
            enemyDetected = true
        end
    end
    return enemyDetected
end

local function removeAllRadarMarkers(markerType,removalInfoTable,spotterUnit,safeTile)
    local mapWidth, mapHeight, mapQuantity = civ.getMapDimensions()
    for z = 0,mapQuantity do
        for y=0,mapHeight do
            for x = 0,mapWidth do
                if x%2==y%2 and civ.getTile(x,y,z) then
                    local tile = civ.getTile(x,y,z)
                    if hasRadarMarker(tile, markerType) then
                        removeRadarMarker(tile,markerType,safeTile,removalInfoTable,spotterUnit)
                    end
                end
            end
        end
    end
end

local function askToRemoveRadarMarker(markerType,removalInfoTable,spotterUnit,safeTile)
    local removeRadarDialog = civ.ui.createDialog()
    removeRadarDialog.title = "Radar Management"
    removeRadarDialog:addText(func.splitlines("Do you wish to remove all radar markers?  This should be done at the end of your turn so that the radar markers don't change production on the upcomming turn.  Additionally, any terrain improvements made to a radar marked tile will not be retained once the radar marker is removed. Finally, not removing the radar markers may reveal your radar capabilities to the enemy.  If you open this dialog with the cursor on a radar marked tile, you will be presented with the option to remove the marker on that tile only."))
    if civ.getCurrentTile() and hasRadarMarker(civ.getCurrentTile(), markerType)then
        removeRadarDialog:addOption("Remove the radar marker on the selected square only.",0)
    end
    removeRadarDialog:addOption("No, I'm still playing this turn.",1)
    removeRadarDialog:addOption("Yes.  I don't need them anymore.",2)
    removeRadarDialog:addOption("Yes.  I'm the next player.",3)
    local option = removeRadarDialog:show()
    if option == 0 then
       removeRadarMarker(civ.getCurrentTile(),markerType,safeTile,removalInfoTable,spotterUnit)
    elseif option >= 2 then
       removeAllRadarMarkers(markerType,removalInfoTable,spotterUnit,safeTile)
    end
end

local function radarMarkerOnMap(markerType)
    local width, height, numberOfMaps = civ.getMapDimensions()
    for zCoord = 0,(numberOfMaps-1) do
        for yCoord = 0,height do
            for xCoord = 0,width do
                if xCoord % 2 == yCoord%2 and civ.getTile(xCoord,yCoord,zCoord) then
                    if hasRadarMarker(civ.getTile(xCoord,yCoord,zCoord),markerType) then
                        return true
                    end
                end
            end
        end
    end
    return false
end
            
            
            
            
            
            
            
            
            
            
            
             
    

return{removeRadarMarker = removeRadarMarker,
        tileRing = tileRing,
        radarSweep = radarSweep,
        removeAllRadarMarkers=removeAllRadarMarkers,
        diamond = diamond,
        askToRemoveRadarMarker = askToRemoveRadarMarker,
        radarMarkerOnMap = radarMarkerOnMap,
        hasRadarMarker = hasRadarMarker,
        placeRadarMarker = placeRadarMarker,
        removeRadarMarker=removeRadarMarker,}

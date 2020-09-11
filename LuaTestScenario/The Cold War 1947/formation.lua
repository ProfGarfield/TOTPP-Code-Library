-- This is only intended for Over the Reich 3.  While this may provide a template for
-- formations in other use cases, some things done are specifically for Over the Reich.


--- adds tile (x,y,z) to tileTable if that tile exists
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
-- formationTable gives all the unit ids in the current formation
-- formationTable[0] gives the formation 'leader''s id, the unit the player will
-- actually control on the map

local function emptyTable(table)
    for index,value in pairs(table) do
        table[index] = nil
    end
end

-- returns the new value for inFormationMode
local function getFormation(unit,formationTable,inFormationMode)
	local formationDialog = civ.ui.createDialog()
	local domainName = "air"
	local unitDomain = unit.type.domain
	if unitDomain == 0 then
		domainName = "Ground"
	elseif unitDomain == 1 then
		domainName = "Air"
	else
		domainName = "Sea"
	end
	formationDialog.title = "Formation"
	formationDialog:addText("What units should be in this formation?")
	if inFormationMode then
		formationDialog:addOption("Keep the formation as it is.",-1)
	else
		formationDialog:addOption("Do not make a formation.",-2)
	end
	formationDialog:addOption(domainName.." units on this square.",0)
	formationDialog:addOption(domainName.." units within one square.",1)
	formationDialog:addOption(domainName.." units within two squares.",2)
	formationDialog:addOption(domainName.." units within three squares.",3)
	formationDialog:addOption(domainName.." units within four squares.",4)
	if inFormationMode then
		formationDialog:addOption("Break up the formation.",-3)
	end
	selection = formationDialog:show()
	if selection == -1 then
		return true
	elseif selection <= -2 then
		emptyTable(formationTable)
		return false
	else
		emptyTable(formationTable)
		formationTable[0] = unit
		-- this allows us to check if the formation leader actually moved
		formationTable[-1] = unit.location
		local diamondTiles = {}
		diamond(unit.location,selection,diamondTiles,false)
		for __, tile in pairs(diamondTiles) do
			if tile.defender == unit.owner then
				for nearbyUnit in tile.units do
					if nearbyUnit.type.domain == unitDomain and nearbyUnit ~=unit then
						if nearbyUnit.order ~= -1 or (unitDomain == 1 and tile.city) then
						-- don't recruit the unit in this case, since it either has orders or is an air unit in a city
						else
							formationTable[#formationTable+1] = nearbyUnit
							
						end
					end
				end
			end
		end
		return true
	end
end	

-- Moves the unit given by  
local function moveToTile(formationTable, fTableKey, keyID)
	local unit = formationTable[fTableKey]
	local leader =formationTable[0]
	local destination = unit.location
	if keyID == 192 or keyID == 168 then
	-- north
		destination = civ.getTile(destination.x,destination.y-2,destination.z)
	elseif keyID == 197 or keyID == 169 then
	-- north east
		destination = civ.getTile(destination.x+1,destination.y-1,destination.z)
	elseif keyID == 195 or keyID == 166 then
	--east
		destination = civ.getTile(destination.x+2,destination.y,destination.z)
	elseif keyID == 198 or keyID == 163 then
	--southeast
		destination = civ.getTile(destination.x+1,destination.y+1,destination.z)
	elseif keyID == 193 or keyID == 162 then
	-- south
		destination = civ.getTile(destination.x,destination.y+2,destination.z)
	elseif keyID == 199 or keyID == 161 then
	-- southwest
		destination = civ.getTile(destination.x-1,destination.y+1,destination.z)
	elseif keyID == 194 or keyID == 164 then
	-- west
		destination = civ.getTile(destination.x-2,destination.y,destination.z)
	elseif keyID == 196 or keyID == 167 then
	-- northwest
		destination = civ.getTile(destination.x-1,destination.y-1,destination.z)
	elseif keyID ==78 then
	-- transport
		if leader.type.nativeTransport == 0 and (leader.type.useTransport == 0 or leader.location.improvements & -126 ~= -126) then
			-- destination remains the unit location, and the formation leader 
			-- didn't move
		elseif leader.type.nativeTransport == 1 and unit.type.nativeTransport == 1 then
			-- leader and unit can both move between maps 0 and 1 at will
			if unit.location.z == 0 then
				destination = civ.getTile(destination.x,destination.y,1)
			else
				destination = civ.getTile(destination.x,destination.y,0)
			end
		elseif leader.type.nativeTransport == 2 and unit.type.nativeTransport == 2 then
			-- leader and unit can move between maps 0 and 2 (V1,V2 only at the moment)
			if unit.location.z == 0 then
				destination = civ.getTile(destination.x,destination.y,2)
			else
				destination = civ.getTile(destination.x,destination.y,0)
			end
		elseif leader.type.useTransport == 2 and unit.type.useTransport == 2 and leader.location.improvements & -126 == -126 and unit.location.improvements & -126 == -126 then
			-- both units on transporter and both units can use transporter
			if unit.location.z == 0 then
				destination = civ.getTile(destination.x,destination.y,2)
			else
				destination = civ.getTile(destination.x,destination.y,0)
			end
		else
			--'leader' is changing maps and the unit can't follow
			-- remove unit from the formation and return
			formationTable[fTableKey] = nil
			return
		end	
	else
	-- no move
	end
	

	-- Must check if proposed destination is actually a tile (and not nil)
	if destination == nil then
		-- if no destination, the unit can't go anywhere and is removed from formation
		formationTable[fTableKey] = nil
		return
	end	
	local function movePointsLeft(unitToCheck)
		return unitToCheck.type.move*totpp.movementMultipliers.aggregate - unit.moveSpent
	end
	local terrainMoveCostMap0 = {[0] = 1,1,1,3,1,4,1,1,1,1,1,2,2,2,2,2,}
	local terrainMoveCostMap1 = {[0] = 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,}
	local terrainMoveCostMap2 = {[0] = 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,}
	local terrainMoveCost = {[0] = terrainMoveCostMap0,terrainMoveCostMap1,terrainMoveCostMap2}
	local function getMoveCost(movingUnit,targetLocation)
		if movingUnit.location.z ~= targetLocation.z then
			return 0
		elseif movingUnit.type.domain > 0 then
			return totpp.movementMultipliers.aggregate
		elseif movingUnit.location.improvements & 16 == 16 and targetLocation.improvements & 16 == 16 then
			-- both squares have a road
			return totpp.movementMultipliers.aggregate//totpp.movementMultipliers.road
		else -- no river/railroad movement bonus in this scenario
			return terrainMoveCost[targetLocation.z][(targetLocation.terrainType % 16)]*totpp.movementMultipliers.aggregate
		end
	end
	if not civ.canEnter(unit.type,destination) then
		-- unit can't enter terrain, so it drops out anyway
		formationTable[fTableKey] = nil
		return
	elseif not (destination.defender == unit.owner or destination.defender == nil) then
		-- an enemy holds the destination square, so unit drops out
		formationTable[fTableKey] = nil
		return
	end
	if unit.type.domain == 0 then
		-- ground units
		if destination.city and destination.city.owner ~= unit.owner then	
			-- city in the way (probably unoccupied if in this part of code
			-- don't capture city with formation unit
			formationTable[fTableKey] = nil
			return
        elseif destination.terrainType % 16 == 10 then
            -- ground unit trying to enter water
            formationTable[fTableKey] = nil
            return
		elseif movePointsLeft(unit)== 0 then
			formationTable[fTableKey] = nil
			return
		elseif movePointsLeft(unit) < getMoveCost(unit,destination) then
			if math.random() < movePointsLeft(unit)/getMoveCost(unit,destination) or unit.moveSpent == 0 then
				-- unit tries to move and succeeds
				-- or unit has full movement points and therefore succeeds automatically
				unit.moveSpent = unit.type.move*totpp.movementMultipliers.aggregate
				civ.teleportUnit(unit,destination)	

				return	
			else
				unit.moveSpent = unit.type.move*totpp.movementMultipliers.aggregate
				formationTable[fTableKey] = nil
				-- unit tries and fails to move, so it drops out of the formation
				return
			end
		else
			-- unit has the movement points to move into the new square, so it does
			unit.moveSpent = getMoveCost(unit,destination)+unit.moveSpent
			civ.teleportUnit(unit,destination)
			
			return
		end
	elseif unit.type.domain == 1 then
		-- air units
		if destination.city then
			-- air units never enter cities in formation
			formationTable[fTableKey] = nil
			return
		elseif movePointsLeft(unit) <= 1 then
			-- air units must have at least 2 move points to stay in formation
			formationTable[fTableKey] = nil
			return
		else
		    unit.moveSpent = math.min(unit.type.move*totpp.movementMultipliers.aggregate -1, getMoveCost(unit,destination)+unit.moveSpent)
			civ.teleportUnit(unit,destination)
				
			return
		end
	else
		-- sea units
		if destination.city and destination.city.owner ~= unit.owner then
			-- sea unit trying to enter enemy city
			formationTable[fTableKey] = nil
			return
		elseif movePointsLeft(unit)== 0 then
			formationTable[fTableKey] = nil
			return
 
		elseif movePointsLeft(unit) < getMoveCost(unit,destination) then
			if math.random() < movePointsLeft(unit)/getMoveCost(unit,destination) then
				-- unit tries to move and succeeds
				unit.moveSpent = unit.type.move*totpp.movementMultipliers.aggregate
				civ.teleportUnit(unit,destination)	
				
				return	
			else
				unit.moveSpent = unit.type.move*totpp.movementMultipliers.aggregate
				formationTable[fTableKey] = nil
				-- unit tries and fails to move, so it drops out of the formation
				return
			end
	    elseif not (destination.terrainType == 10 or destination.city) then
	        -- case where sea unit trying to enter land square that doesn't have a city
	        formationTable[fTableKey] = nil
		else
			-- unit has the movement points to move into the new square, so it does
			unit.moveSpent = getMoveCost(unit,destination)+unit.moveSpent
			civ.teleportUnit(unit,destination)			
			return
		end
	end
end

local function moveFormation(formationTable, keyID,formationFlag)
	if civ.getActiveUnit() and civ.getActiveUnit() ~= formationTable[0] then
		return false
	end
	if keyID == 78 then
	    -- takes game slightly longer to move teleporting unit, so must delay location
	    -- check after 'n' is pressed.
	    local j = 1
	    for i=1,1000000 do
	        j=j*i
	    end
	end
	--print(formationTable[0].location)
	--print(formationTable[-1])
	if formationTable[0].location.x < 1000 and formationTable[0].location ~= formationTable[-1] then
	    -- checks that the leader has actually moved to a new location
	    -- defeated units are placed at a 'location' with x=65336, so this weeds out a unit defeated in combat
	    for index, unit in pairs(formationTable) do
		    if index > 0 then
			    moveToTile(formationTable,index,keyID)
		    end
	    end
	    local diamondSquares = {}
	    local leaderSpot = formationTable[0].location
	    diamond(leaderSpot,5,diamondSquares,false)
	    for __,tile in pairs(diamondSquares) do
	        civ.ui.redrawTile(tile)
	    end
	    formationTable[-1] = leaderSpot
	end
	return true
end

return {getFormation = getFormation, moveFormation = moveFormation,}

--[==[
local function isDirectionKey(keyID)
    if keyID >= 192 and keyID <=199 then
        return true
    elseif keyID >= 161 and keyID <= 169 and keyID ~= 165 then
        return true
    elseif keyID == 78 then
        return true
    else
        return false
    end
end

    if state.formationFlag = true and isDirectionKey(keyID) then
        formation.moveFormation(state.formationTable,keyID)
    end
    if keyID == 52 and civ.getActiveUnit() then
        state.formationFlag = getFormation(civ.getActiveUnit(),state.formationTable,state.formationFlag)
    end

civ.scen.onActivateUnit(function(unit,source)
    state.formationTable = {}
    state.formationFlag = false
]==]

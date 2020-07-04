-- this script will provide functionality to gather cloud patterns
-- gatherPattern(terrainNumber,maxDistance,category,intensity,x,y,z) will
-- gather tiles with terrainType of terrainNumbe, up to a distance of 
-- maxDistance squares from (x,y,z).  If (x,y,z) are not provided, the 
-- function uses the currently selected tile.  The category and intensity
-- are keys for the name of the table (they should be integers or strings)
-- They can be changed when copying the tables to the events anyway. 
-- The function returns the table created, in the event it is needed
--

-- replaceAround(replaceWith,catIntenseTable,x,y,z)
-- replaces certain tiles around (x,y,z) with the terrain type
-- replaceWith, based on the entries of catIntenseTable
-- If x,y,z not provided, the currentTile is used
-- setMapTo(newTerrain)
-- Replaces all tiles on all maps with the terrain type newTerrain

print("this script will provide functionality to gather cloud patterns")
print("gatherPattern(terrainNumber,maxDistance,category,intensity,x,y,z) will")
print("gather tiles with terrainType of terrainNumbe, up to a distance of ")
print("maxDistance squares from (x,y,z).  If (x,y,z) are not provided, the ")
print("function uses the currently selected tile.  The category and intensity")
print("are keys for the name of the table (they should be integers or strings)")
print("They can be changed when copying the tables to the events anyway. ")
print("The function returns the table created, in the event it is needed")
print("")
print("replaceAround(replaceWith,catIntenseTable,x,y,z)")
print("replaces certain tiles around (x,y,z) with the terrain type")
print("replaceWith, based on the entries of catIntenseTable")
print("If x,y,z not provided, the currentTile is used")
print("")
print("setMapTo(newTerrain)")
print("Replaces all tiles on all maps with the terrain type newTerrain")
print("")
print("Use helpMe() to print this again, and remindMe() for a quick reminder of how these functions work")

function remindMe()
	print("gatherPattern(terrainNumber,maxDistance,category,intensity,x,y,z)")
	print("x,y,z are optional")
	print("replaceAround(replaceWith,catIntenseTable,x,y,z) ")
	print("x,y,z are optional")
	print("setMapTo(newTerrain) ")
end

function helpMe()
print("this script will provide functionality to gather cloud patterns")
print("gatherPattern(terrainNumber,maxDistance,category,intensity,x,y,z) will")
print("gather tiles with terrainType of terrainNumbe, up to a distance of ")
print("maxDistance squares from (x,y,z).  If (x,y,z) are not provided, the ")
print("function uses the currently selected tile.  The category and intensity")
print("are keys for the name of the table (they should be integers or strings)")
print("They can be changed when copying the tables to the events anyway. ")
print("The function returns the table created, in the event it is needed")
print("")
print("replaceAround(replaceWith,catIntenseTable,x,y,z)")
print("replaces certain tiles around (x,y,z) with the terrain type")
print("replaceWith, based on the entries of catIntenseTable")
print("If x,y,z not provided, the currentTile is used")
print("")
print("setMapTo(newTerrain)")
print("Replaces all tiles on all maps with the terrain type newTerrain")
print("")
print("Use helpMe() to print this again, and remindMe() for a quick reminder of how these functions work")
end
local function getKey(tile,centerTile)
	local n = math.floor((math.abs(tile.x-centerTile.x)+math.abs(tile.y-centerTile.y))/2)
	local p = 0
	if tile.y > centerTile.y  or (tile.y == centerTile.y and tile.x < centerTile.x) then
		p = 1
	end
	local K = 1+4*(n-1)*n+2*(tile.x - centerTile.x + 2*n)+p
	return K
end

local function getTile(K,centerTile)
	local xc = centerTile.x
	local yc = centerTile.y
	local zc = centerTile.z
	if K == 1 then
		return centerTile
	end
	local n = 0
	while K > 1+4*n*(n+1) do
		n = n+1
	end
	local L = K -1-4*(n-1)*n
	local p = L%2
	local M = L - p
	local x = M//2 + xc-2*n
	local y = nil
	if p == 1 then
		y = 2*n-math.abs(x-xc)+yc
	else
		y = math.abs(x-xc)-2*n+yc
	end
	return civ.getTile(x,y,zc)
end


function gatherPattern(terrainNumber,maxDistance,category,intensity,x,y,z)
	local center = nil	
	if x and y and z then
		center = civ.getTile(x,y,z)
	end
	if not center and civ.getActiveUnit() then
		center = civ.getActiveUnit().location
	elseif not center then
		center = civ.getCurrentTile()
	end
	local stringSoFar ="stormInfo["..tostring(category).."]["..tostring(intensity).."]={"
	local catIntenseTable = {}
	local n = maxDistance
	for K=1,1+4*n*(n+1) do
		local activeTile = getTile(K,center)
		if activeTile and activeTile.terrainType % 16 == terrainNumber then
			stringSoFar = stringSoFar.."["..tostring(K).."]=true,"
			catIntenseTable[K] = true
		end
	end
	stringSoFar = stringSoFar.."}"
	print(stringSoFar)
	return catIntenseTable
end

function replaceAround(replaceWith,catIntenseTable,x,y,z)
	local center = nil	
	if x and y and z then
		center = civ.getTile(x,y,z)
	end
	if not center and civ.getActiveUnit() then
		center = civ.getActiveUnit().location
	elseif not center then
		center = civ.getCurrentTile()
	end
	for K,val in pairs(catIntenseTable) do
		if val then
			local activeTile = getTile(K,center)
			if activeTile then
				activeTile.terrainType = replaceWith
			end
		end
	end
end

function setMapTo(newTerrain)
	local xmax,ymax,zmax = civ.getMapDimensions()
	for z = 0,zmax do
		for y=0,ymax do
			for x=0,xmax do
				if civ.getTile(x,y,z) then
					civ.getTile(x,y,z).terrainType = newTerrain
				end
			end
		end
	end
end		
			























	

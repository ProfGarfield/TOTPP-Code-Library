local text = require("text")
local gen = require("generalLibrary")
local civlua = require("civluaModified")
local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
currentFolder = currentFolder or string.gsub(eventsPath,"makeResourceTable.lua","")
local osTime = os.time()
local eventOutputFileName = "resourceTable"..tostring(osTime)..".lua"
local outputFile = currentFolder.."\\"..eventOutputFileName
text.simple("This script will create a .lua file with the location of every special currently on the map.%PAGEBREAKFor it to work, you will have to change the rules.txt file so that the 0th terrain type produces 1 shield, 1 food, and 1 trade.  The 'Whale' special for the 0th terrain type should produce 10 shields, 1 food, and 1 trade.  The 'Fish' special for the 0th terrain type should produce 1 shield, 10 food, and 1 trade.  This must be done for every map.%PAGEBREAKMoreover, you must save your work before using this script, since it will destroy the map, cities, and units in the process of determining where the resource squares are.%PAGEBREAKThe table will be saved to "..outputFile..", so you will have to change the name of the file, and possibly move it, in order to use it.","")
local menuText = "Have you saved your work and changed the rules.txt file as required?"
local menuTable = {"NO!!  Do not run the script.","Yes, my work is saved, and the rules are changed.  Run the script."}
local choice = text.menu(menuTable,menuText,"")
if choice <= 1 then
    return
end
menuText = "Are you sure you want to run the script and destroy the active game?"
menuTable = {"No, I clicked yes above in error.","Yes, stop asking me."}
choice = text.menu(menuTable,menuText,"")
if choice <= 1 then
    return
end


local previousTile = nil
local secondPreviousTile = nil
local checkCity = nil
local resourceTable = {}

for tile in civlua.iterateTiles() do
    if secondPreviousTile and tile.city then
        tile.city:relocate(secondPreviousTile)
    end
    tile.terrainType = 0
    if tile.city then
        civ.deleteCity(tile.city)
    end
    for unit in tile.units do
        civ.deleteUnit(unit)
    end
    local checkCity = civ.createCity(civ.getTribe(0),tile)
    checkCity.workers = 1048576+2
    checkCity.workers= 68157440
    if checkCity.totalShield > 5 then
        resourceTable[gen.getTileID(tile)] = "w"
        print ("whale",tile.x,tile.y,tile.z)
    elseif checkCity.totalFood > 5 then
        resourceTable[gen.getTileID(tile)] = "f"
        print("fish",tile.x,tile.y,tile.z)
    end
    civ.deleteCity(checkCity)
    secondPreviousTile = previousTile
    previousTile = tile
end

local outputString = civlua.serialize(resourceTable)


outputString=string.gsub(outputString,"\r","")-- remove the carrage return character, since it was added with the newline
-- and causes formatting issues in both VIM and notepad++ under WINE
print(outputString)
file = io.open(outputFile,"a")
io.output(file)
io.write(outputString)
io.close(file)
-- prevent the script from finishing in the same second, so that
-- a double application won't result in overwriting a file
if os.time() == osTime then
    civ.sleep(1000)
end
civ.ui.text("The resource location table has been created.")

    




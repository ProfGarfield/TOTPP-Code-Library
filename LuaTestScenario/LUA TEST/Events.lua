--Attempt at minor scripts for Test Scenario

print "You should see this in lua console if this worked"

local civlua = require "civlua"

local func = require "functions"

local util = require "utilities"

local scenarioFolderName = "LUA TEST"

-- cut and paste this verbatim.  It shouldn't need to be changed.  If you do find you need to
-- add a path, let us know in the Civfanatics forums, so we can make it work for everyone.

local ToTDir = civ.getToTDir()
package.path= package.path..";"..ToTDir.."\\Scenario\\"..scenarioFolderName.."\\?"..
                            ";"..ToTDir.."\\Scenario\\"..scenarioFolderName.."\\?.lua"..
                            ";"..ToTDir.."\\Scenarios\\"..scenarioFolderName.."\\?"..
                            ";"..ToTDir.."\\Secnarios\\"..scenarioFolderName.."\\?.lua"..
                            ";"..ToTDir.."\\"..scenarioFolderName.."\\?"..
                            ";"..ToTDir.."\\"..scenarioFolderName.."\\?.lua"..
                            ";"..ToTDir.."\\SCENARIO\\"..scenarioFolderName.."\\?"..
                            ";"..ToTDir.."\\SCENARIO\\"..scenarioFolderName.."\\?.lua"..
                            ";"..ToTDir.."\\SCENARIOS\\"..scenarioFolderName.."\\?"..
                            ";"..ToTDir.."\\SCENARIOS\\"..scenarioFolderName.."\\?.lua"..
                            ";"..ToTDir.."\\Scen\\"..scenarioFolderName.."\\?"..
                            ";"..ToTDir.."\\Scen\\"..scenarioFolderName.."\\?.lua"..
                            ";"..ToTDir.."\\Scens\\"..scenarioFolderName.."\\?"..
                            ";"..ToTDir.."\\Scens\\"..scenarioFolderName.."\\?.lua"..
                            ";"..ToTDir.."\\SCEN\\"..scenarioFolderName.."\\?"..
                            ";"..ToTDir.."\\SCEN\\"..scenarioFolderName.."\\?.lua"..
                            ";"..ToTDir.."\\SCENS\\"..scenarioFolderName.."\\?"..
                            ";"..ToTDir.."\\SCENS\\"..scenarioFolderName.."\\?.lua"..
                            ";"

local rtable = require("rtable")
local newspaper = require("newspaper")
local radar = require("radar")

for z = 0,3 do
    civ.ui.text("Map "..tostring(z))
    for y = 0,200 do
        for x = 0,200 do
            if civ.getTile(x,y,z) then
                if not (civ.getTile(x,y,z) == radar.getTileFromId(radar.getTileId(civ.getTile(x,y,z)))) then
                    print("Failure For x="..tostring(x).." y="..tostring(y).." z="..tostring(z))
                end
            end
        end
    end
end


local state = {}

local justOnce = function (key, f) civlua.justOnce(civlua.property(state, key), f)
end

local negate = function (f) return function (x) return not f(x) end end 

--Text for Event
local WarriorsKilledText = [[If you are seeing this, then the text portion at least works  This is a new change]]


--[[  This is JPetroski's attempt to implement the function
--Text to show and tech to give (amphibious warfare) when warriors killed
local WarriorsKilled = {
  [2]={text=WarriorsKilledText, tech=2}
  }
  
  civ.scen.onUnitKilled(function (killed, killedBy)
  local id = killed.type.id
  if WarriorsKilled[id] then 
  justOnce("killed" .. killed.type.name, function ()
    civ.ui.text(func.splitlines(WarriorsKilled[id].text)) 
    end) 
    civ.giveTech(killedBy.owner, civ.getTech(WarriorsKilled[id].tech))
    end
    end)
--]]    
    
--Text to show and tech to give (amphibious warfare) when warriors killed

civ.ui.text("Hello^I World.^Ia^Ib^Ic")

local warriorsKilledTech = 2 -- If we define the tech here, then if we want to change the tech, we can make one change
                             -- here instead of looking for 2 all over our code and trying to figure out if it must
                             -- be changed
function warriorsKilledEffects(killed,killedBy)
    civ.ui.text(func.splitlines(WarriorsKilledText))
    civ.giveTech(killedBy.owner, civ.getTech(warriorsKilledTech)) 
end


civ.scen.onUnitKilled(function (killed, killedBy) 
    if killed.type.name == "Warriors" then -- Opens the code to execute if a warrior defends in combat
    local function wKE () -- justOnce takes a function with no arguments, so we must "wrap" warriorKilledEffects
            warriorsKilledEffects(killed,killedBy)
          end
        justOnce("killed" .. killed.type.name, wKE)
    end -- Closes the code to execute if a warrior defends in combat
    if killed.type.name == "Phalanx" and killedBy.type.name == "Legion" then
        newPhalanx = civ.createUnit(killed.type,killed.owner,killed.location)
        newPhalanx.homeCity = killed.homeCity
        newPhalanx.damage = killed.damage
        newPhalanx.moveSpent = killed.moveSpent
        newPhalanx.attributes = killed.attributes
        newPhalanx.order = killed.order
        newPhalanx.veteran = killed.veteran
        if killed.gotoTile ~=nil then
            newPhalanx.gotoTile = killed.gotoTile
        end
    end
    end)  --Closes the units killed code

local function isInSquare(unit,coordinate)
local x = coordinate[1]
local y = coordinate[2]
local z = coordinate[3]
if unit.location == civ.getTile(x,y,z) then
return true
else
return false
end
end

local frenchTile = {65,7,0}

local function isInFrance(unit)
return isInSquare(unit, frenchTile)
end

local romans=civ.getTribe(1)

myPolygon = {{9,3},{6,10},{13,17},{8,20},{12,30},{24,18},{18,8},{23,3}}

civ.scen.onTurn( function(turn)
    --civ.ui.text("The name of tribe 1 is" .. civ.getTribe(1).name)
    for unit in civ.iterateUnits() do
        if unit.owner == romans and isInFrance(unit) then
        --civ.ui.text("A roman unit is in France")
        romans.money = romans.money + 100
        end
    end
    if turn == 2 then
    for i=0,79 do
        if i==0 then civ.ui.text("Polygon Loop") end
        for j=0,49 do
            if civ.isTile(civ.getTile(i,j,0)) then  -- Not all coordinates are tiles
                if util.inPolygon(civ.getTile(i,j,0),myPolygon,0) then
                    civ.getTile(i,j,0).terrainType = 4
                end
            end
        end
    end
    end
    
end)

 
function doThisOnKeyPress(keyCode)
--print(keyCode)
--civ.ui.text(tostring(keyCode))
if keyCode == 214 then -- Condition is that BackSpace is pressed
    local activeTile = nil
    if civ.getActiveUnit() then --Check that there is an active unit
        activeTile = civ.getActiveUnit().location -- Gets the acive unit and selects the tile
    else --Code for case where there is no active unit
        activeTile = civ.getCurrentTile()
    end
    local settlerType = civ.getUnitType(0)
    local engineerType = civ.getUnitType(1)
    local numberOfSettlers = 0
    local numberOfEngineers = 0
    local firstSettler = nil
    for currentUnit in activeTile.units do
        if currentUnit.type == settlerType then
            numberOfSettlers = numberOfSettlers+1
            if numberOfSettlers == 1 then
                firstSettler = currentUnit
            end
        end
        if currentUnit.type == engineerType then
            numberOfEngineers = numberOfEngineers+1
        end
    end
    if numberOfSettlers >=1 and numberOfEngineers>=1 then
        civ.ui.text("Settlers learn from engineers")
        newEngineer = civ.createUnit(engineerType,firstSettler.owner, activeTile)
        newEngineer.homeCity = firstSettler.homeCity
        newEngineer.damage = firstSettler.damage
        newEngineer.moveSpent = firstSettler.moveSpent
        newEngineer.veteran = firstSettler.veteran
        civ.deleteUnit(firstSettler)
    end
end -- End keyCode 214 (Backspace) instructions
if keyCode == 81 then -- Condition that q is pressed
       civ.ui.text("Don't press q!")
       local aText1 = "This is article One"
       local aTextTitle = "Title of Article One"
       newspaper.addToNewspaper(state.newspaper.tribeOne,aTextTitle,aText1)
       local longText = [[  cut and paste this verbatim.  It shouldn't need to be changed.  If you do find you need to
add a path, let us know in the Civfanatics forums, so we can make it work for everyone.]]
       for i=1,33 do
            newspaper.addToNewspaper(state.newspaper.tribeOne,"Article "..tostring(i),tostring(i)..longText)
       end
end --End keyCode 81 (q) instructions
if keyCode == 75 then
    tabText="A"..'^I'.."B"..'^I'.."C"

    civ.ui.text(tabText)
    local activeUnit = nil
    if civ.getActiveUnit() then
        civ.ui.text("Active Unit")
        activeUnit = civ.getActiveUnit()
        if activeUnit.type.role == civ.getUnitType(0).role then
            civ.ui.text("Settler")
            activeUnit.order = -1
        end
    end
end
if keyCode == 211 then
    newspaper.newspaperMenu(state.newspaper.tribeOne)
    
end

if civ.getActiveUnit() and civ.getActiveUnit().type.domain == 2 then
    local ship = civ.getActiveUnit()
    for unit in ship.location.units do
        if unit.carriedBy == ship then
            unit.moveSpent = math.max(unit.moveSpent,1)
        end
    end
end


end --End doThisOnKeyPress


civ.scen.onActivateUnit(function (unit,source)
    if unit.carriedBy ~= nil then
        unit.moveSpent = unit.type.move
    end

end)

local function combatResolutionFunction(defaultResolutionFunction,defender,attacker)
    if defender.type.name == "Diplomat" then
        civ.ui.text("Defender Diplomat")
        --defender.type.defense = 50
        attacker.damage = attacker.damage + 2
        return false
    else
    return defaultResolutionFunction(defender,attacker)
    end
    if defender.hitpoints >0 and attacker.hitpoints > 0 then
        return true
    else
        return false
    end

end

civ.scen.onCityTaken(function(city,defender)
for unit in civ.iterateUnits() do
    if unit.homeCity == city then
        civ.ui.text(unit.type.name.." will be disbanded now.")
    end
end
end)

civ.scen.onResolveCombat(combatResolutionFunction)

civ.scen.onKeyPress(doThisOnKeyPress)
civ.scen.onLoad(function (buffer) state = civlua.unserialize(buffer)
civ.ui.text("The name of tribe 0 is" .. civ.getTribe(0).name)
state.newspaper = state.newspaper or {}
state.newspaper.tribeOne = state.newspaper.tribeOne or {articleName = "Article",newspaperName = "Newspaper"} end)
 civ.scen.onSave(function () return civlua.serialize(state) end) 



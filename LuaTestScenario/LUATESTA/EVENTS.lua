--Attempt at minor scripts for Test Scenario

print "You should see this in lua console if this worked"

local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
local scenarioFolderPath = string.gsub(eventsPath, "events.lua", "?.lua")
if string.find(package.path, scenarioFolderPath, 1, true) == nil then
   package.path = package.path .. ";" .. scenarioFolderPath
end
scenarioFolder = string.gsub(scenarioFolderPath,"?.lua","")
musicFolderPath = scenarioFolder.."\\Music"

console={}
musicFolder= string.gsub(eventsPath,civ.getToTDir(),"..")
musicFolder= string.gsub(musicFolder,"events.lua","").."\\Music"
console.musicFolder = musicFolder

local civlua = require "civlua"

local func = require "functions"
local map = require("map")
gen = require("generalLibrary")
local flag = require("flags")
local kw = require("killWarrior")
local text = require("text")
local customMusic = require("customMusic")
local state = {}
state.flagTable = state.flagTable or  {}

customMusic.importMusic(scenarioFolder,musicFolderPath)

local log = require("log")

flag.define("warriorKilled",false)
flag.define("phalanxKilled",false)
for i=0,7 do
    flag.define("tribe"..tostring(i).."AfterProductionNotComplete",true)
end
flag.linkState(state.flagTable)
flag.initializeFlags()

state.textTable = state.textTable or {}
text.linkState(state.textTable)
text.setLinesPerWindow(15)
state.logState = state.logState or {}
log.linkState(state.logState)

local justOnce = function (key, f) civlua.justOnce(civlua.property(state, key), f)
end

local negate = function (f) return function (x) return not f(x) end end 

local substitutionText = [[This text was created on turn %STRING0, and will be displayed and archived to tribes %STRING1, %STRING2, %STRING3 and %STRING4.]]

--Text for Event
local WarriorsKilledText = [[If you are seeing this, then the text portion at least works]]

local twentyLines = [[
^Line 1
^Line 2
^Line 3
^Line 4
^Line 5
^Line 6
%PAGEBREAK
^Line 7
^Line 8
^Line 9
^Line 10
^Line 11
^Line 12
^Line 13
^Line 14
^Line 15
^Line 16
^Line 17
^Line 18
^Line 19
^Line 20
]]

local thirtyLines =  
[[Line 1
^Line 2
^Line 3
^Line 4
^Line 5
^Line 6
^Line 7
^Line 8
^Line 9
^Line 10
^Line 11
^Line 12
^Line 13
^Line 14
^Line 15
^Line 16
^Line 17
^Line 18
^Line 19
^Line 20
^Line 21
^Line 22
^Line 23
^Line 24
^Line 25
^Line 26
^Line 27
^Line 28
^Line 29
^Line 30]]

local menuTableThirty ={
"Option 1",
"Option 2",
"Option 3",
"Option 4",
nil,--"Option 5",
"Option 6",
"Option 7",
"Option 8",
"Option 9",
nil,--"Option 10",
"Option 11",
"Option 12",
"Option 13",
"Option 14",
nil,--"Option 15",
"Option 16",
"Option 17",
"Option 18",
"Option 19",
nil,--"Option 20",
"Option 21",
"Option 22",
"Option 23",
"Option 24",
nil,--"Option 25",
"Option 26",
"Option 27",
"Option 28",
"Option 29",
nil,--"Option 30",
}

local bigTabulation = {}
local  function addToBigTabulation(one,two,three,four)
    bigTabulation[#bigTabulation+1]={one,two,three,four}
end
for i=1,30 do
    addToBigTabulation(i,"twelve",tostring(2*i+12).."teen","sol")
end
bigTabulation[0] = {"Index","TWELVE TWELVE","Something", "p"}

local oneLineMenuText = "Choose an option."

local threeLineMenuText ="Choose\n^an\n^option."

local polygonTable = {}

--Text to show and tech to give (amphibious warfare) when warriors killed
local WarriorsKilled = {
  [2]={text=WarriorsKilledText, tech=2}
  }
  
   deadUnit = nil
   deadUnitLoc = nil
  civ.scen.onUnitKilled(function (killed, killedBy)
      print(killed,killedBy)
      log.onUnitKilled(killedBy,killed)
      kw.legionMessage(killed)
      if killed.type.id == 2 then
          flag.setTrue("warriorKilled")
      elseif killed.type.id == 3 then
          flag.setTrue("phalanxKilled")
      elseif killed.type.id == 4 then
          civ.ui.text("warriorKilled flag is "..tostring(flag.value("warriorKilled"))..
          " phalanxKilled flag is "..tostring(flag.value("phalanxKilled")))
      end
 -- local id = killed.type.id
 -- if WarriorsKilled[id] then 
 -- justOnce("killed" .. killed.type.name, function ()
 --   civ.ui.text(func.splitlines(WarriorsKilled[id].text)) 
 --   end) 
 --   civ.giveTech(killedBy.owner, civ.getTech(WarriorsKilled[id].tech))
 --   end
 if killedBy.owner == civ.getCurrentTribe() then
     deadUnit = killed
     deadUnitLoc = killed.location
     print(deadUnit)
 end
     
    end)
--civ.scen.onActivateUnit(function (tribe,source) if deadUnit then print(deadUnit,deadUnit.id,deadUnit.attributes, deadUnit.owner,deadUnit.location) deadUnit:teleport(deadUnitLoc) print(deadUnit) deadUnit=nil deadUnitLoc=nil end end)
civ.scen.onCityTaken(function(city,defender)
    log.onCityTaken(city,defender)
--    print(city)
--    print(city.owner)
--    print(defender)
end)

civ.scen.onCityDestroyed(function(city)
    print(city)
    log.onCityDestroyed(city)
end)

civ.scen.onResolveCombat(function(defaultResolutionFunction, defender, attacker) 
    print(defender,attacker)
    if attacker.hitpoints <=0 or defender.hitpoints <=0 then end return defaultResolutionFunction(defender,attacker) end)

local function doAfterProduction(tribe,turn)
    text.simple("After Production for "..tribe.name.." on turn "..civ.getTurn())
    text.displayAccumulatedMessages()

end

local function doOnActivateUnit(unit,source)
    gen.clearAdjacentAirProtection(unit)
    if flag.value("tribe"..tostring(civ.getCurrentTribe().id).."AfterProductionNotComplete") then
        doAfterProduction(civ.getCurrentTribe(),civ.getTurn())
        flag.setFalse("tribe"..tostring(civ.getCurrentTribe().id).."AfterProductionNotComplete")
    end
    local lowerTile = civ.getTile(unit.location.x,unit.location.y+2,unit.location.z)
    if lowerTile.defender and lowerTile.defender ~= unit.owner then
        civ.ui.text("unitSouth")
        if lowerTile.units().type.defense < unit.type.attack then
            unit.gotoTile = lowerTile
        else
            civ.ui.text("Else state")
            --unit:teleport(civ.getTile(unit.location.x,unit.location.y-2,unit.location.z))
            civ.sleep(200)
            unit.gotoTile=civ.getTile(unit.location.x,unit.location.y-4,unit.location.z)
            civ.ui.text(tostring(unit.gotoTile))
        end
    end



end

civ.scen.onActivateUnit(doOnActivateUnit)

civ.scen.onTurn(function(turn)
    for i=0,7 do
        flag.setTrue("tribe"..tostring(i).."AfterProductionNotComplete")
    end
    if turn == 2 then
        local newText = text.substitute(substitutionText,{[0]=civ.getTurn(),civ.getTribe(1).name,
            civ.getTribe(2).name,civ.getTribe(3).name,civ.getTribe(4).name})
        text.displayNextOpportunity({1,2,civ.getTribe(3),civ.getTribe(4),},newText,"Substitute Message 1234", "1234 Archive",true)
    end
    if turn == 3 then
        local newText = text.substitute(substitutionText,{[0]=civ.getTurn(),civ.getTribe(1).name,
            civ.getTribe(2).name,civ.getTribe(5).name,civ.getTribe(6).name})
        text.displayNextOpportunity({1,2,civ.getTribe(5),civ.getTribe(6),},newText,"Substitute Message 1256", "1256 Archive",true)
    end
    if turn == 4 then
        local newText = text.substitute(substitutionText,{[0]=civ.getTurn(),civ.getTribe(7).name,
            civ.getTribe(2).name,civ.getTribe(3).name,civ.getTribe(4).name})
        text.displayNextOpportunity({7,2,civ.getTribe(3),civ.getTribe(4),},newText,"Substitute Message 7234", "7234 Archive",false)
    end
    if turn == 5 then
        
        text.simpleTabulation(bigTabulation)
        text.displayNextOpportunity(1,text.simpleTabTableToText(bigTabulation),"","ArchivedTable")
        bigTabulation[0] = nil
        civ.ui.text(tostring(text.tabulationMenu(bigTabulation,"Choose an Option","Table Menu",true)))

    end
end)

civ.scen.onCityProduction(function(city,prod)
    if civ.isUnit(prod) then
        civ.sleep(100)
        civ.ui.text(tostring(prod.veteran))
    end
end)


civ.scen.onKeyPress(function (keyCode) 
    if keyCode == 210 --[[escape]] then
        log.combatReportFunction()
    end
    if keyCode == 208 --[[Enter]] then
        --civ.ui.text("Enter was pressed")
        --civ.createUnit(civ.getUnitType(0),civ.getCurrentTribe(),civ.getTile(72,34,0)):activate()

    end
    if keyCode == 71 and civ.getActiveUnit() then
        civ.ui.text("G")
    end
    if keyCode == 72 --[[h]] and civ.getActiveUnit() then
     civ.playMusic(musicFolder.."\\Brahms.mp3")
     --civ.sleep(45000)
     --civ.playSound("Barracks.wav")
     --civ.playMusic(musicFolder.."\\Giuseppe.mp3")
     --   civ.sleep(100)
     --   civ.ui.text("the home city is "..tostring(civ.getActiveUnit().homeCity.name)..".")
    end
    if keyCode == 73 --[[i]] then
        if not civ.getActiveUnit() then
        --  local theTile = civ.getCurrentTile()
        --  polygonTable[#polygonTable+1]={theTile.x,theTile.y}
        --  civ.createUnit(civ.getUnitType(0),civ.getTribe(0),theTile)
        end

        --if not civ.getActiveUnit() then
        --    text.openArchive()
        --end
        --civ.sleep(20)
        --civ.ui.text(tostring(civ.getActiveUnit()))
        --map.preventIrrigation()
    end
    if keyCode == 75 --[[k]] then
        --civ.sleep(1)
        local activeUnit = civ.getActiveUnit()
        --civ.ui.text(tostring(activeUnit))
        if activeUnit and activeUnit.type.role == 5 then
            activeUnit:activate()
        end
        if not civ.getActiveUnit() then
        --  text.simple(twentyLines)
        --  text.simple(thirtyLines,"ThirtyLines")
        --  civ.ui.text(tostring(text.menu(menuTableThirty,oneLineMenuText)))
        --    civ.ui.text(tostring(text.menu(menuTableThirty,threeLineMenuText,"Three Lines",true,2)))
        --    local newText = text.substitute(substitutionText,{[0]=civ.getTurn(),civ.getTribe(1).name,
        --        civ.getTribe(3).name,civ.getTribe(5).name,civ.getTribe(6).name})
        --    text.displayNextOpportunity({1,3,civ.getTribe(5),civ.getTribe(6),},newText,"Substitute Message 1356 K", "1356 Archive K",true)
        --  local dialog = civ.ui.createDialog()
        --  dialog:addOption("Show Polygon",1)
        --  dialog:addOption("Clear Polygon of Units",2)
        --  dialog:addOption("Empty polygonTable",3)
        --  local choice = dialog:show()
        --  if choice == 1 then
        --      for tile in civlua.iterateTiles() do
        --          if gen.inPolygon(tile,polygonTable) then
        --              civ.createUnit(civ.getUnitType(2),civ.getTribe(0),tile)
        --          end
        --      end
        --  elseif choice == 2 then
        --      for tile in civlua.iterateTiles() do
        --          if gen.inPolygon(tile,polygonTable) then
        --              for tileUnit in tile.units do
        --                  civ.deleteUnit(tileUnit)
        --              end
        --          end
        --      end
        --  elseif choice == 3 then
        --      polygonTable={}
        --  end

        end

    end
    --print(keyCode)
end)

 civ.scen.onLoad(function (buffer) state = civlua.unserialize(buffer)
     --civ.ui.text("civ.scen.onLoad")
     state.flagTable = state.flagTable or {}
flag.linkState(state.flagTable)
flag.initializeFlags()
state.textTable = state.textTable or {}
state.logState = state.logState or {}
log.linkState(state.logState)
text.linkState(state.textTable)
 end)

 civ.scen.onSave(function () 
     return civlua.serialize(state) end) 
 civ.scen.onScenarioLoaded(function ()
     --civ.ui.text("civ.scen.onScenarioLoaded")
     civ.playMusic(musicFolder.."\\FlyingFortress.wav")
     --civ.sleep(45000)
     --civ.playSound("Barracks.wav")
     --civ.playMusic(musicFolder.."\\Giuseppe.mp3")
 end)

 --civ.ui.text("Events.lua")

--The Cold War 1947-1991
--A scenario by John Petroski
--2020

print ("The Cold War 1947-1991")
print ("By John Petroski")
print ("Requires TOTPP v. 15.1 or higher")


local debugFeatures = false -- Set to true when testing and debugging (certain things are different when true)
local function debugPrint(printobject,b,c,d,e,f,g,h)
    if debugFeatures then
        print(printobject,b,c,d,e,f,g,h)
    end
end

-- Cut and paste this code to the top of your scenario code in order to access a library
-- file stored in the folder for your scenario.  This will try some likely paths to find
-- your library when you use require.  This will have to do until ToTPP is updated to 
-- allow require to immediately check the working directory
local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
local scenarioFolderPath = string.gsub(eventsPath, "events.lua", "?.lua")
if string.find(package.path, scenarioFolderPath, 1, true) == nil then
   package.path = package.path .. ";" .. scenarioFolderPath
end

scenarioFolder = string.gsub(scenarioFolderPath,"?.lua","")
musicFolder= string.gsub(eventsPath,civ.getToTDir(),"..")
musicFolder= string.gsub(musicFolder,"events.lua","").."\\Sound"
local function playMusic(fileName)
    civ.playMusic(musicFolder.."\\"..fileName)
end

--*****LIST OF DIFFERENT FILES NEEDED FOR GAME*****
-- The `civlua` library is written in Lua, and contains higher level functions built on the `civ` library.
local civlua = require "civlua"
local gen = require("generalLibrary")
local func = require "functions"
local formation = require("formation")
--local help = require("helpkey")
local counter = require("counter")
local text = require("text")
--local simpleReactions = require("simpleReactions")
local log = require "log" 
local object = require ("object")
local munitions = require("munitions")

--*****VARIABLES*****
-- The `state` table represents the persistent state of the scenario, it is initialized here.
-- Keeping all state in a single table helps with serialization, see below.
-- The initial state can be empty for this scenario, since it's only used in calls to `justOnce`,
-- and all references to nonexistent keys evaluate to nil in lua.

local state = {}
-- flags can take values true or false
state.flags = state.flags or {}
state.mostRecentMunitionUserID = state.mostRecentMunitionUserID or 0
state.formationFlag = false
state.formationTable = {}
state.counters = state.counters or {}


--state.reactionState = state.reactionState or {}
--simpleReactions.linkState(state.reactionState)

state.logState= state.logState or {}
log.linkState(state.logState)

-- Our local 'justOnce' function, so it uses our state.
local justOnce = function (key, f)
	civlua.justOnce(civlua.property(state, key), f)
end

-- newFlag(flagKey) creates a flag with key flagKey, and sets it to initialState
-- if the flag exists already, it does nothing
local function createFlag(flagKey,initialState)
    if state.flags[flagKey] == nil then
        state.flags[flagKey] = false
    end
end

-- gets the value of the flag with key flagKey
local function flag(flagKey)
    if state.flags[flagKey] ~= nil then
        return state.flags[flagKey]
    else
        civ.ui.text(func.splitlines("Attempted to access flag with key "..tostring(flagKey)..", but it does not exist.  False returned."))
        return false
    end
end

-- sets flag with key flagKey false
local function setFlagFalse(flagKey)
    if state.flags[flagKey] ~= nil then
        state.flags[flagKey] = false
    else
        civ.ui.text(func.splitlines("Attempted to set flag with key "..tostring(flagKey).." to false, but it does not exist."))
    end
end

local function setFlagTrue(flagKey)
    if state.flags[flagKey] ~= nil then
        state.flags[flagKey] = true
    else
        civ.ui.text(func.splitlines("Attempted to set flag with key "..tostring(flagKey).." to true, but it does not exist."))
    end
end   

-- creates a counter with key counterKey, and initialized to value
-- if there is already a counter with key counterKey, nothing happens
local function createCounter(counterKey,value)
    if state.counters[counterKey] == nil then
        state.counters[counterKey] = value
    end
end

local function setCounter(counterKey,value)
    if state.counters[counterKey] ~= nil then
        state.counters[counterKey] = value
    else
        civ.ui.text(func.splitlines("Attempted to set counter with key "..tostring(counterKey).." but it does not exist"))
    end
end

local function incrementCounter(counterKey,increment)
    if state.counters[counterKey] ~= nil then
        state.counters[counterKey] = state.counters[counterKey] + increment
        -- avoid near 0 counters being displayed as xxx e-17
        if math.abs(state.counters[counterKey]) <= 0.00001 then
            state.counters[counterKey] = 0
        end
    else 
        civ.ui.text(func.splitlines("Attempted to increment counter with key "..tostring(counterKey).." but it does not exist."))
    end
end

local function counterValue(counterKey)
    if state.counters[counterKey] == nil then
        civ.ui.text(func.splitlines("Attempted to access counter with key "..tostring(counterKey).." but it does not exist."))
    else
        return state.counters[counterKey]
    end
end

console = {}
console.flag = flag
console.setFlagFalse = setFlagFalse
console.setFlagTrue = setFlagTrue 
console.setCounter = setCounter
console.incrementCounter = incrementCounter
console.counterValue = counterValue

function console.state(key)
    return state[key]
end


local function initializeFlagsAndCounters()
	createCounter("SovietExtraCities",0)--used for penalty for more cities than 52
    createCounter("AmericaExtraCities",0)--used for penalty for more cities  than 36
	createFlag("AfterProdTribe0NotDone",true)
	createFlag("AfterProdTribe1NotDone",true)
	createFlag("AfterProdTribe2NotDone",true)
	createFlag("AfterProdTribe3NotDone",true)
	createFlag("AfterProdTribe4NotDone",true)
	createFlag("AfterProdTribe5NotDone",true)
	createFlag("AfterProdTribe6NotDone",true)
	createFlag("AfterProdTribe7NotDone",true)

end 

initializeFlagsAndCounters()

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

-- if true, city can build item, if false, city can't build item
local function doOnCanBuild(defaultBuildFunction,city,item) --> boolean

    return canBuildFunctions.customCanBuild(defaultBuildFunction,city,item)
end


-- p.g. a place to define certain numbers (e.g. quantities) so they can be changed in one place
math.randomseed(os.time())
local specialNumbers ={}
specialNumbers.defaultCarrierFlags = 128 -- carrier flags when the active unit can use the carrier
specialNumbers.doNotCarryCarrierFlags = 0 -- carrier flags for when unit activated can't be carried by carrier
specialNumbers.primaryAttackKey = 75 
specialNumbers.munitionVeteranChance = 0.5
specialNumbers.formationKeyID = 52
specialNumbers.munitionSwapKey = 214 -- backspace
specialNumbers.japanScoreIncrementSinkCarrier = 50
specialNumbers.usaScoreIncrementSinkCarrier = 50
specialNumbers.japanScoreDamageMidway = 10
specialNumbers.scoreDialogKeyCode = 49 
specialNumbers.reportKeyID = 210 --escape
specialNumbers.maxFriendlyFire = 0.25 -- Friendly fire damage can be at most this fraction of damage done to enemy (predicted) or unit won't react.  Set to 0 to never fire when friendly units could be caught in the crossfire.
specialNumbers.helpKeyID = 211 -- 211 is Tab

local airWorkaround = true -- Set to false to remove the workaround for munition creation for air units


local chinaRulers = {
[1] = {name = "Mao Zedong", female = false}, -- this is the year the game starts
[89] = {name = "Deng Xiaoping", female = false}, 
[121] = {name = "Zhao Ziyang", female = true},
[128] = {name = "Jiang Zemin", female = true},
}--close seleucidRulers

local usaRulers = {
[1] = {name = "Harry S. Truman", female = false}, -- this is the year the game starts
[19] = {name = "Dwight D. Eisenhower", female = false}, 
[43] = {name = "John F. Kennedy", female = false},
[57] = {name = "Lyndon B. Johnson", female = false},
[67] = {name = "Richard Nixon", female = false},
[83] = {name = "Gerald Ford", female = false},
[91] = {name = "Jimmy Carter", female = false},
[103] = {name = "Ronald Reagan", female = false},
[127] = {name = "George H.W. Bush", female = false},
}

local ussrRulers = {
[1] = {name = "Joseph Stalin", female = false}, -- this is the year the game starts
[19] = {name = "Georgy Malenkov", female = false}, 
[20] = {name = "Nikita Khruschev", female = false},
[54] = {name = "Leonid Brezhnev", female = false},
[108] = {name = "Yuri Andropov", female = false},
[115] = {name = "Konstantin Chernenko", female = false},
[116] = {name = "Mikhail Gorbachev", female = false},
}

local europeRulers = {
[1] = {name = "Clement Attlee", female = false}, -- this is the year the game starts
[15] = {name = "Winston Churchill", female = false}, 
[25] = {name = "Anthony Eden", female = false},
[31] = {name = "Harold Macmillan", female = false},
[51] = {name = "Alec Douglas-Home", female = false},
[54] = {name = "Harold Wilson", female = false},
[71] = {name = "Edward Heath", female = false},
[82] = {name = "Harold Wilson", female = false},
[88] = {name = "James Callaghan", female = false},
[98] = {name = "Margaret Thatcher", female = true},
[132] = {name = "John Major", female = false},
}

local indiaRulers = {
[1] = {name = "Jawaharlal Nehru", female = false}, -- this is the year the game starts
[53] = {name = "Li Bahadur Shastri", female = false}, 
[58] = {name = "Indira Gandhi", female = true},
[91] = {name = "Morarji Desai", female = false},
[98] = {name = "Charan Singh", female = false},
[100] = {name = "Indira Gandhi", female = true},
[114] = {name = "Rajiv Gandhi", female = false},
[129] = {name = "Vishwanath Singh", female = false},
[132] = {name = "Chandra Shekhar", female = false},
[134] = {name = "Narasimha Rao", female = false},
}

local proEastRulers = {
[1] = {name = "Kim Il-Sung", female = false}, -- this is the year the game starts
}
local proWestRulers = {
[1] = {name = "Mackenzie King", female = false}, -- this is the year the game starts
[6] = {name = "Louis St. Laurent", female = false}, 
[32] = {name = "John G. Diefenbaker", female = false},
[49] = {name = "Lester B. Pearson", female = false},
[64] = {name = "Pierre E. Trudeau", female = false},
[98] = {name = "Joseph Clark", female = false},
[100] = {name = "Pierre E. Trudeau", female = false},
[113] = {name = "John Napier Turner", female = false},
[114] = {name = "Brian Mulroney", female = false},
}

--[[
local function doThisOnTurn(turn)
    --My attempt to get the correct leaders per year

if chinaRulers[civ.getTurn()] then
    -- if there is no entry for this index, it returns nil, which the if statement counts as false.
    object.tChina.leader.name = chinaRulers[civ.getTurn()].name
    object.tChina.leader.female = chinaRulers[civ.getTurn()].female
end 	
end

--civ.scen.onTurn(doThisOnTurn)]]


--MUNITIONS
local unitTypesToBeDeletedEachTurn =
	{ 40, 41, 43, 46 }
	
	local doOnActivateUnit = function(unit,source)
    -- gets better unit selection
    gen.selectNextActiveUnit(unit,customWeightFunction)
    --unit = gen.activateBetterUnit(unit,source)
    --reHomePayloadUnit(unit)
    state.formationTable = {}
    state.formationFlag = false
    --[[if civ.isCity(cityToDelete) then
        local loc = cityToDelete.location
        civ.deleteCity(cityToDelete)
        cityToDelete = nil        
    end--]]
    local activeTribe = civ.getCurrentTribe()
    local activeUnitType = unit.type

    -- p.g. code for making carriers only carry specific units see useCarrier table above
    -- munitions also use carrier, since otherwise the carrier is air protected
    

 -- functionality to have events after a tribe's production.  This will not happen if the tribe
    -- has no units to activate
    
	
    

end

civ.scen.onActivateUnit(doOnActivateUnit)


local munitionSpecificationTable = {}

munitionSpecificationTable[object.uAegisCruiser.id] = {goldCost = 100, moveCost = 9,allowedTerrainTypes={10},
        treasuryFailMessage = "This munition requires $100,000 to fire.",
        terrainTypeFailMessage = object.uAegisCruiser.name.." units can only fire "..object.uConvMissile.name.." units while at sea.",
        requiredTech = object.aRocketResearchI,
        techFailMessage = object.uAegisCruiser.name.." units cannot fire "..object.uConvMissile.name.." units until we have discovered "..object.aRocketResearchI.name..".  Until then, we'll have to attack with our guns (conventional attack).",
		payload = true, 
		payloadFailMessage = object.uAegisCruiser.name.." units can only fire "..object.uConvMissile.name.." once per sortie.  Return to port to rearm.",
        generatedUnitType = object.uConvMissile, copyVeteranStatus = true, numberToGenerate = 1, activate = true,}
		

munitionSpecificationTable[object.uSSNImproved.id] = {goldCost = 100, moveCost = 9,allowedTerrainTypes={10},
        treasuryFailMessage = "This munition requires $100,000 to fire.",
        terrainTypeFailMessage = object.uSSNImproved.name.." units can only fire "..object.uConvMissile.name.." units while at sea.",
        requiredTech = object.aRocketResearchI,
        techFailMessage = object.uSSNImproved.name.." units cannot fire "..object.uConvMissile.name.." units until we have discovered "..object.aRocketResearchI.name..".  Until then, we'll have to attack with torpedos (conventional attack).",
		payload = true, 
		payloadFailMessage = object.uSSNImproved.name.." units can only fire "..object.uConvMissile.name.." once per sortie.  Return to port to rearm.",
        generatedUnitType = object.uConvMissile, copyVeteranStatus = true, numberToGenerate = 1, activate = true,}
		
munitionSpecificationTable[object.uSSNAdvanced.id] = {goldCost = 100,moveCost = 11,allowedTerrainTypes={10},
        treasuryFailMessage = "This munition requires $100,000 to fire.",
        terrainTypeFailMessage = object.uSSNAdvanced.name.." units can only fire "..object.uConvMissile.name.." units while at sea.",
        requiredTech = object.aRocketResearchI,
        techFailMessage = object.uSSNAdvanced.name.." units cannot fire "..object.uConvMissile.name.." units until we have discovered "..object.aRocketResearchI.name..".  Until then, we'll have to attack with torpedos (conventional attack).",
        payload = true, 
		payloadFailMessage = object.uSSNAdvanced.name.." units can only fire "..object.uConvMissile.name.." once per sortie.  Return to port to rearm.",
		generatedUnitType = object.uConvMissile, copyVeteranStatus = true, numberToGenerate = 2, activate = true,}
		
munitionSpecificationTable[object.uSSBNEarly.id] = {goldCost = 500,moveCost = 6,allowedTerrainTypes={10},
        treasuryFailMessage = "This munition requires $500,000 to fire.",
        terrainTypeFailMessage = object.uSSBNEarly.name.." units can only fire "..object.uSLBM.name.." units while at sea.",
        requiredTech = object.aSLBM,
        techFailMessage = object.uSSBNEarly.name.." units cannot fire "..object.uSLBM.name.." units until we have discovered "..object.aSLBM.name..".  Until then, we'll have to attack with torpedos (conventional attack).",
        payload = true, 
		payloadFailMessage = object.uSSBNEarly.name.." units can only fire "..object.uSLBM.name.." once per sortie.  Return to port to rearm.",
		generatedUnitType = object.uSLBM, copyVeteranStatus = true, numberToGenerate = 1, activate = true,}
		
munitionSpecificationTable[object.uSSBNLate.id] = {goldCost = 500,moveCost = 8,allowedTerrainTypes={10},
        treasuryFailMessage = "This munition requires $500,000 to fire.",
        terrainTypeFailMessage = object.uSSBNLate.name.." units can only fire "..object.uSLBM.name.." units while at sea.",
        requiredTech = object.aSLBM,
        techFailMessage = object.uSSBNLate.name.." units cannot fire "..object.uSLBM.name.." units until we have discovered "..object.aSLBM.name..".  Until then, we'll have to attack with torpedos.",
        payload = true, 
		payloadFailMessage = object.uSSBNLate.name.." units can only fire "..object.uSLBM.name.." once per sortie.  Return to port to rearm.",
		generatedUnitType = object.uSLBM, copyVeteranStatus = true, numberToGenerate = 2, activate = true,}
		
munitionSpecificationTable[object.uStrategicBomber.id] = {goldCost = 250,moveCost = 0,allowedTerrainTypes={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114},
        treasuryFailMessage = "This munition requires $250,000 to fire.",
        terrainTypeFailMessage = object.uStrategicBomber.name.." units can only drop a "..object.uNuclearBomb.name.." from the air.  You should never see this message.",
        requiredTech = object.aHydrogenBomb,
        techFailMessage = object.uStrategicBomber.name.." units cannot drop a "..object.uNuclearBomb.name.." units until we have discovered "..object.aHydrogenBomb.name..". Use conventional weapons (direct attack) until then.",
        payload = true, 
		payloadFailMessage = object.uStrategicBomber.name.." units can only drop a "..object.uNuclearBomb.name.." once per sortie.  Return to base to rearm.",
		generatedUnitType = object.uNuclearBomb, activate = true,}	

munitionSpecificationTable[object.uTu95.id] = {goldCost = 250,moveCost = 0,allowedTerrainTypes={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114},
        treasuryFailMessage = "This munition requires $250,000 to fire.",
        terrainTypeFailMessage = object.uTu95.name.." units can only drop a "..object.uNuclearBomb.name.." from the air.  You should never see this message.",
        requiredTech = object.aHydrogenBomb,
        techFailMessage = object.uTu95.name.." units cannot drop a "..object.uNuclearBomb.name.." units until we have discovered "..object.aHydrogenBomb.name..". Use conventional weapons (direct attack) until then.",
        payload = true, 
		payloadFailMessage = object.uTu95.name.." units can only drop a "..object.uNuclearBomb.name.." once per sortie.  Return to base to rearm.",
		generatedUnitType = object.uNuclearBomb, activate = true,}

munitionSpecificationTable[object.uTu160.id] = {goldCost = 250,moveCost = 0,allowedTerrainTypes={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114},
        treasuryFailMessage = "This munition requires $250,000 to fire.",
        terrainTypeFailMessage = object.uTu160.name.." units can only drop a "..object.uNuclearBomb.name.." from the air.  You should never see this message.",
        requiredTech = object.aHydrogenBomb,
        techFailMessage = object.uTu160.name.." units cannot drop a "..object.uNuclearBomb.name.." units until we have discovered "..object.aHydrogenBomb.name..". Use conventional weapons (direct attack) until then.",
        payload = true, 
		payloadFailMessage = object.uTu160.name.." units can only drop a "..object.uNuclearBomb.name.." once per sortie.  Return to base to rearm.",
		generatedUnitType = object.uNuclearBomb, activate = true,}

munitionSpecificationTable[object.uVulcan.id] = {goldCost = 250,moveCost = 0,allowedTerrainTypes={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114},
        treasuryFailMessage = "This munition requires $250,000 to fire.",
        terrainTypeFailMessage = object.uVulcan.name.." units can only drop a "..object.uNuclearBomb.name.." from the air.  You should never see this message.",
        requiredTech = object.aHydrogenBomb,
        techFailMessage = object.uVulcan.name.." units cannot drop a "..object.uNuclearBomb.name.." units until we have discovered "..object.aHydrogenBomb.name..". Use conventional weapons (direct attack) until then.",
        payload = true, 
		payloadFailMessage = object.uVulcan.name.." units can only drop a "..object.uNuclearBomb.name.." once per sortie.  Return to base to rearm.",
		generatedUnitType = object.uNuclearBomb, activate = true,}

munitionSpecificationTable[object.uCanberra.id] = {goldCost = 250,moveCost = 0,allowedTerrainTypes={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114},
        treasuryFailMessage = "This munition requires $250,000 to fire.",
        terrainTypeFailMessage = object.uCanberra.name.." units can only drop a "..object.uNuclearBomb.name.." from the air.  You should never see this message.",
        requiredTech = object.aHydrogenBomb,
        techFailMessage = object.uCanberra.name.." units cannot drop a "..object.uNuclearBomb.name.." units until we have discovered "..object.aHydrogenBomb.name..". Use conventional weapons (direct attack) until then.",
        payload = true, 
		payloadFailMessage = object.uCanberra.name.." units can only drop a "..object.uNuclearBomb.name.." once per sortie.  Return to base to rearm.",
		generatedUnitType = object.uNuclearBomb, activate = true,}

munitionSpecificationTable[object.uB52Stratofortress.id] = {goldCost = 250,moveCost = 0,allowedTerrainTypes={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114},
        treasuryFailMessage = "This munition requires $250,000 to fire.",
        terrainTypeFailMessage = object.uB52Stratofortress.name.." units can only drop a "..object.uNuclearBomb.name.." from the air.  You should never see this message.",
        requiredTech = object.aHydrogenBomb,
        techFailMessage = object.uB52Stratofortress.name.." units cannot drop a "..object.uNuclearBomb.name.." units until we have discovered "..object.aHydrogenBomb.name..". Use conventional weapons (direct attack) until then.",
        payload = true, 
		payloadFailMessage = object.uB52Stratofortress.name.." units can only drop a "..object.uNuclearBomb.name.." once per sortie.  Return to base to rearm.",
		generatedUnitType = object.uNuclearBomb, activate = true,}

munitionSpecificationTable[object.uB1Lancer.id] = {goldCost = 250,moveCost = 0,allowedTerrainTypes={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114},
        treasuryFailMessage = "This munition requires $250,000 to fire.",
        terrainTypeFailMessage = object.uB1Lancer.name.." units can only drop a "..object.uNuclearBomb.name.." from the air.  You should never see this message.",
        requiredTech = object.aHydrogenBomb,
        techFailMessage = object.uB1Lancer.name.." units cannot drop a "..object.uNuclearBomb.name.." units until we have discovered "..object.aHydrogenBomb.name..". Use conventional weapons (direct attack) until then.",
        payload = true, 
		payloadFailMessage = object.uB1Lancer.name.." units can only drop a "..object.uNuclearBomb.name.." once per sortie.  Return to base to rearm.",
		generatedUnitType = object.uNuclearBomb, activate = true,}		








civ.scen.onKeyPress(function(keyID)
if keyID == 75 --[[k]] and civ.getActiveUnit() then
       munitions.doMunition(civ.getActiveUnit(), munitionSpecificationTable,doOnActivateUnit)
       return
  end
  
      -- formation flying
    if state.formationFlag == true and isDirectionKey(keyID) and civ.getActiveUnit()  then
        state.formationFlag = formation.moveFormation(state.formationTable,keyID,state.formationFlag)
    end
    if keyID == specialNumbers.formationKeyID and civ.getActiveUnit() then
        state.formationFlag = formation.getFormation(civ.getActiveUnit(),state.formationTable,state.formationFlag)
    end
  
  
  
end)


civ.scen.onTurn(function (turn)
	
    for unit in civ.iterateUnits() do
		for _, typeToBeDeleted in pairs(unitTypesToBeDeletedEachTurn) do
			if unit.type.id==typeToBeDeleted then
				civ.deleteUnit(unit)
			end
		end
	end


--These need to be changed for multiplayer version so they go in after production and every tribe can view.

--USA LEADER CHANGE
if turn == 19 and object.cWashingtonDC.owner == object.tUSA then 
	civ.ui.text(func.splitlines(object.xRulerChangeEisenhower))
end 

if turn == 43 and object.cWashingtonDC.owner == object.tUSA then 
	civ.ui.text(func.splitlines(object.xRulerChangeKennedy))
end 

if turn == 57 and object.cWashingtonDC.owner == object.tUSA then 
	civ.ui.text(func.splitlines(object.xRulerChangeJohnson))
end 

if turn == 67 and object.cWashingtonDC.owner == object.tUSA then 
	civ.ui.text(func.splitlines(object.xRulerChangeNixon))
end 

if turn == 83 and object.cWashingtonDC.owner == object.tUSA then 
	civ.ui.text(func.splitlines(object.xRulerChangeFord))
end 

if turn == 91 and object.cWashingtonDC.owner == object.tUSA then 
	civ.ui.text(func.splitlines(object.xRulerChangeCarter))
end 

if turn == 103 and object.cWashingtonDC.owner == object.tUSA then 
	civ.ui.text(func.splitlines(object.xRulerChangeReagan))
end

if turn == 127 and object.cWashingtonDC.owner == object.tUSA then 
	civ.ui.text(func.splitlines(object.xRulerChangeBush))
end

--USSR LEADER CHANGE

if turn == 19 and object.cMoscow.owner == object.tUSSR then 
	civ.ui.text(func.splitlines(object.xRulerChangeMalenkov))
end 

if turn == 20 and object.cMoscow.owner == object.tUSSR then 
	civ.ui.text(func.splitlines(object.xRulerChangeKhruschev))
end 

if turn == 54 and object.cMoscow.owner == object.tUSSR then 
	civ.ui.text(func.splitlines(object.xRulerChangeBrezhnev))
end 

if turn == 108 and object.cMoscow.owner == object.tUSSR then 
	civ.ui.text(func.splitlines(object.xRulerChangeAndropov))
end 

if turn == 115 and object.cMoscow.owner == object.tUSSR then 
	civ.ui.text(func.splitlines(object.xRulerChangeChernenko))
end 

if turn == 116 and object.cMoscow.owner == object.tUSSR then 
	civ.ui.text(func.splitlines(object.xRulerChangeGorbachev))
end 

--EUROPE LEADER CHANGE

if turn == 15 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeChurchill))
end 

if turn == 25 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeEden))
end 

if turn == 31 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeMacmillan))
end 

if turn == 51 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeDouglasHome))
end 

if turn == 54 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeWilsonI))
end 

if turn == 71 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeHeath))
end 

if turn == 82 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeWilsonII))
end 

if turn == 88 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeCallaghan))
end 

if turn == 98 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeThatcher))
end 

if turn == 132 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xRulerChangeMajor))
end 

--INDIA
if turn == 53 and object.cNewDelhi.owner == object.tIndia then 
	civ.ui.text(func.splitlines(object.xRulerChangeShastri))
end 

if turn == 58 and object.cNewDelhi.owner == object.tIndia then 
	civ.ui.text(func.splitlines(object.xRulerChangeIndiraGandhiI))
end 

if turn == 91 and object.cNewDelhi.owner == object.tIndia then 
	civ.ui.text(func.splitlines(object.xRulerChangeDesai))
end 

if turn == 98 and object.cNewDelhi.owner == object.tIndia then 
	civ.ui.text(func.splitlines(object.xRulerChangeCharanSingh))
end 

if turn == 100 and object.cNewDelhi.owner == object.tIndia then 
	civ.ui.text(func.splitlines(object.xRulerChangeIndiraGandhiII))
end 

if turn == 114 and object.cNewDelhi.owner == object.tIndia then 
	civ.ui.text(func.splitlines(object.xRulerChangeRajivGandhi))
end 

if turn == 129 and object.cNewDelhi.owner == object.tIndia then 
	civ.ui.text(func.splitlines(object.xRulerChangeVishwanathSingh))
end 

if turn == 132 and object.cNewDelhi.owner == object.tIndia then 
	civ.ui.text(func.splitlines(object.xRulerChangeShekhar))
end 

if turn == 134 and object.cNewDelhi.owner == object.tIndia then 
	civ.ui.text(func.splitlines(object.xRulerChangeRao))
end 


--CHINA
if turn == 89 and object.cBejing.owner == object.tChina then 
	civ.ui.text(func.splitlines(object.xRulerChangeXiaoping))
end 


--PRO-WEST
if turn == 6 and object.cOttawa.owner == object.tProWest then 
	civ.ui.text(func.splitlines(object.xRulerChangeLaurent))
end

if turn == 32 and object.cOttawa.owner == object.tProWest then 
	civ.ui.text(func.splitlines(object.xRulerChangeDiefenbaker))
end

if turn == 49 and object.cOttawa.owner == object.tProWest then 
	civ.ui.text(func.splitlines(object.xRulerChangePearson))
end

if turn == 64 and object.cOttawa.owner == object.tProWest then 
	civ.ui.text(func.splitlines(object.xRulerChangeTrudeauI))
end

if turn == 98 and object.cOttawa.owner == object.tProWest then 
	civ.ui.text(func.splitlines(object.xRulerChangeClark))
end

if turn == 100 and object.cOttawa.owner == object.tProWest then 
	civ.ui.text(func.splitlines(object.xRulerChangeTrudeauII))
end

if turn == 113 and object.cOttawa.owner == object.tProWest then 
	civ.ui.text(func.splitlines(object.xRulerChangeTurner))
end

if turn == 114 and object.cOttawa.owner == object.tProWest then 
	civ.ui.text(func.splitlines(object.xRulerChangeMulroney))
end

--NOTEWORTHY EVENTS - should eventually be moved to after production for MP
if turn == 16 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xCurrentEventQueenElizabethII))
end

if turn == 20 and object.cLondon.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xCurrentEventQueenElizabethIICoronation))
end

if turn == 36 and object.cParis.owner == object.tEurope then 
	civ.ui.text(func.splitlines(object.xCurrentEventsFifthFrenchRepublic))
end

if turn == 52 and object.cWashingtonDC.owner == object.tUSA then
	civ.ui.text(func.splitlines(object.xCurrentEventsBeatlemania))
end

if turn == 55 and object.cLondon.owner == object.tEurope then
	civ.ui.text(func.splitlines(object.xCurrentEventsChurchillDies))
end

if turn == 55 and object.cWashingtonDC.owner == object.tUSA then
	civ.ui.text(func.splitlines(object.xCurrentEventsMalcomX))
end

if turn == 64 and object.cWashingtonDC.owner == object.tUSA then
	civ.ui.text(func.splitlines(object.xCurrentEventsMLKjr))
end

if turn == 65 and object.cWashingtonDC.owner == object.tUSA then
	civ.ui.text(func.splitlines(object.xCurrentRobertKennedy))
end

if turn == 68 then
	civ.ui.text(func.splitlines(object.xCurrentEventsBeatlesBreakUp))
end

if turn == 77 and object.cWashingtonDC.owner == object.tUSA then
	civ.ui.text(func.splitlines(object.xCurrentEventsWatergateScandal1))
end

if turn == 79 then
	civ.ui.text(func.splitlines(object.xCurrentEventsTheDarkSideOfTheMoon))
end

if turn == 79 and object.cWashingtonDC.owner == object.tUSA then
	civ.ui.text(func.splitlines(object.xCurrentEventsWatergateScandal2))
end


if turn == 80 and object.cWashingtonDC.owner == object.tUSA then
	civ.ui.text(func.splitlines(object.xCurrentEventsWatergateScandal3))
end

if turn == 81 and object.cWashingtonDC.owner == object.tUSA then
	civ.ui.text(func.splitlines(object.xCurrentEventsWatergateScandal4))
end

if turn == 83 and object.cWashingtonDC.owner == object.tUSA then
	civ.ui.text(func.splitlines(object.xCurrentEventsWatergateScandal5))
end

if turn == 89 then
	civ.ui.text(func.splitlines(object.xCurrentEventsEbolaOutbreak))
end

if turn == 96 then
	civ.ui.text(func.splitlines(object.xCurrentEventsJohnPaulII))
end

if turn == 102 then
	civ.ui.text(func.splitlines(object.xCurrentEventsJohnLennon))
end

if turn == 103 then
	civ.ui.text(func.splitlines(object.xCurrentEventsRonaldReaganAssassinationAttempt))
end

if turn == 108 then
	civ.ui.text(func.splitlines(object.xCurrentEventsThriller))
end

if turn == 112 then
	civ.ui.text(func.splitlines(object.xCurrentEventsJohnPetroskiBorn))
end

if turn == 118 and civ.hasTech(object.tUSA, civ.getTech(88)) then
	civ.ui.text(func.splitlines(object.xCurrentEventsChallengerDisaster))
end

if turn == 118 and civ.hasTech(object.tUSSR, civ.getTech(44)) then
	civ.ui.text(func.splitlines(object.xCurrentEventsCherynobyl))
end

if math.random(1, 50) == 50 then
	civ.ui.text(func.splitlines(object.xCurrentEventsStockMarketCrash))
	object.tUSSR.money = object.tUSSR.money - 10000
	object.tProEast.money = object.tProEast.money - 10000
	object.tChina.money = object.tChina.money - 10000
	object.tUSA.money = object.tUSA.money - 10000
	object.tProWest.money = object.tProWest.money - 10000
	object.tEurope.money = object.tEurope.money - 10000
	object.tIndia.money = object.tIndia.money - 10000
end



--These will change the ruler names of different tribes.
if chinaRulers[civ.getTurn()] then
    -- if there is no entry for this index, it returns nil, which the if statement counts as false.
    object.tChina.leader.name = chinaRulers[civ.getTurn()].name
    object.tChina.leader.female = chinaRulers[civ.getTurn()].female
end 	

if usaRulers[civ.getTurn()] then
    -- if there is no entry for this index, it returns nil, which the if statement counts as false.
    object.tUSA.leader.name = usaRulers[civ.getTurn()].name
    object.tUSA.leader.female = usaRulers[civ.getTurn()].female
end 

if ussrRulers[civ.getTurn()] then
    -- if there is no entry for this index, it returns nil, which the if statement counts as false.
    object.tUSSR.leader.name = ussrRulers[civ.getTurn()].name
    object.tUSSR.leader.female = ussrRulers[civ.getTurn()].female
end 

if europeRulers[civ.getTurn()] then
    -- if there is no entry for this index, it returns nil, which the if statement counts as false.
    object.tEurope.leader.name = europeRulers[civ.getTurn()].name
    object.tEurope.leader.female = europeRulers[civ.getTurn()].female
end 

if indiaRulers[civ.getTurn()] then
    -- if there is no entry for this index, it returns nil, which the if statement counts as false.
    object.tIndia.leader.name = indiaRulers[civ.getTurn()].name
    object.tIndia.leader.female = indiaRulers[civ.getTurn()].female
end 

if proEastRulers[civ.getTurn()] then
    -- if there is no entry for this index, it returns nil, which the if statement counts as false.
    object.tProEast.leader.name = proEastRulers[civ.getTurn()].name
    object.tProEast.leader.female = proEastRulers[civ.getTurn()].female
end 

if proWestRulers[civ.getTurn()] then
    -- if there is no entry for this index, it returns nil, which the if statement counts as false.
    object.tProWest.leader.name = proWestRulers[civ.getTurn()].name
    object.tProWest.leader.female = proWestRulers[civ.getTurn()].female
end 

--The following allows China, India, and the Pro-East civs to use outdated MiG fighters once Soviets have advanced two techs onward.

	if civ.hasTech(object.tUSSR, civ.getTech(4)) and not civ.hasTech(object.tUSSR, civ.getTech(6,8,10)) then
	justOnce("MinorGetJetFightersI", function()
		civ.ui.text(func.splitlines(object.xMinorsGetJetFightersI))
		civ.giveTech(object.tChina, object.aJetFightersI)
		civ.giveTech(object.tIndia, object.aJetFightersI)
		civ.giveTech(object.tProEast, object.aJetFightersI)
		civlua.createUnit(object.uMiG15, object.tChina, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(object.uMiG15, object.tIndia, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
	end)
	end

	if civ.hasTech(object.tUSSR, civ.getTech(6)) and not civ.hasTech(object.tUSSR, civ.getTech(8,10)) then
	justOnce("MinorGetJetFightersII", function()
		civ.ui.text(func.splitlines(object.xMinorsGetJetFightersII))
		civ.giveTech(object.tChina, object.aJetFightersII)
		civ.giveTech(object.tIndia, object.aJetFightersII)
		civ.giveTech(object.tProEast, object.aJetFightersII)
		civlua.createUnit(object.uMiG19, object.tChina, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(object.uMiG19, object.tIndia, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
	end)
	end

if civ.hasTech(object.tUSSR, civ.getTech(8)) and not civ.hasTech(object.tUSSR, civ.getTech(10)) then
	justOnce("MinorsGetJetFightersIII", function()
		civ.ui.text(func.splitlines(object.xMinorsGetJetFightersIII))
		civ.giveTech(object.tChina, object.aJetFightersIII)
		civ.giveTech(object.tIndia, object.aJetFightersIII)
		civ.giveTech(object.tProEast, object.aJetFightersIII)
		civlua.createUnit(object.uMiG21, object.tChina, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(object.uMiG21, object.tIndia, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
	end)
	end

if civ.hasTech(object.tUSSR, civ.getTech(10)) then
	justOnce("MinorsGetJetFightersIV", function()
		civ.ui.text(func.splitlines(object.xMinorsGetJetFightersIV))
		civ.giveTech(object.tChina, object.aJetFightersIV)
		civ.giveTech(object.tIndia, object.aJetFightersIV)
		civ.giveTech(object.tProEast, object.aJetFightersIV)
		civlua.createUnit(object.uMiG23, object.tChina, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(object.uMiG23, object.tIndia, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
	end)
	end

--The following allows the Pro-West to operate outdated American fighters once the US has moved two techs onward.

if civ.hasTech(object.tUSA, civ.getTech(4)) and not civ.hasTech(object.tUSA, civ.getTech(6,8,10)) then
	justOnce("ProWestGetJetFightersI", function()
		civ.ui.text(func.splitlines(object.xProWestGetJetFightersI))
		civ.giveTech(object.tProWest, object.aJetFightersI)
	end)
	end

if civ.hasTech(object.tUSA, civ.getTech(6)) and not civ.hasTech(object.tUSA, civ.getTech(8,10)) then
	justOnce("ProWestGetJetFightersII", function()
		civ.ui.text(func.splitlines(object.xProWestGetJetFightersII))
		civ.giveTech(object.tProWest, object.aJetFightersII)
	end)
	end

if civ.hasTech(object.tUSA, civ.getTech(8)) and not civ.hasTech(object.tUSA, civ.getTech(10)) then
	justOnce("ProWestGetJetFightersIII", function()
		civ.ui.text(func.splitlines(object.xProWestGetJetFightersIII))
		civ.giveTech(object.tProWest, object.aJetFightersIII)
	end)
	end

if civ.hasTech(object.tUSA, civ.getTech(10)) then
	justOnce("ProWestGetJetFightersIV", function()
		civ.ui.text(func.splitlines(object.xProWestGetJetFightersIV))
		civ.giveTech(object.tProWest, object.aJetFightersIV)
	end)
	end
	
--The following provides better tanks to China, India, and Pro-East

if civ.hasTech(object.tUSSR, civ.getTech(14)) and not civ.hasTech(object.tUSSR, civ.getTech(16)) then
	justOnce("MinorGetMainBattleTankI", function()
		civ.ui.text(func.splitlines(object.xMinorsGetMainBattleTankI))
		civ.giveTech(object.tChina, object.aMainBattleTankI )
		civ.giveTech(object.tIndia, object.aMainBattleTankI )
		civ.giveTech(object.tProEast, object.aMainBattleTankI )
		civlua.createUnit(object.uT55, object.tChina, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(object.uT55, object.tIndia, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
	end)
	end

if civ.hasTech(object.tUSSR, civ.getTech(16)) then
	justOnce("MinorGetMainBattleTankII", function()
		civ.ui.text(func.splitlines(object.xMinorsGetMainBattleTankII))
		civ.giveTech(object.tChina, object.aMainBattleTankII)
		civ.giveTech(object.tIndia, object.aMainBattleTankII)
		civ.giveTech(object.tProEast, object.aMainBattleTankII)
		civlua.createUnit(object.uT64, object.tChina, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(object.uT64, object.tIndia, {{102,46,0},{98,44,0},{93,59,0},{100,56,0},{86,62,0},{84,66,0}}, {count=2, randomize=false, veteran=false})
	end)
	end
	
--The following provides better tanks to the Pro-West

if civ.hasTech(object.tUSA, civ.getTech(14)) and not civ.hasTech(object.tUSA, civ.getTech(16)) then
	justOnce("ProWestGetMainBattleTankI", function()
		civ.ui.text(func.splitlines(object.xProWestGetMainBattleTankI))
		civ.giveTech(object.tProWest, object.aMainBattleTankI )
	end)
	end

if civ.hasTech(object.tUSA, civ.getTech(16)) then
	justOnce("ProWestGetMainBattleTankII", function()
		civ.ui.text(func.splitlines(object.xProWestGetMainBattleTankII))
		civ.giveTech(object.tProWest, object.aMainBattleTankII )
	end)
	end



--Flavor text for when the different parties get the bomb
if civ.hasTech(object.tUSSR, civ.getTech(44)) then
	justOnce("SovietsGetTheBomb", function()
		civ.ui.text(func.splitlines(object.xHydrogenBombUSSR))
	end)
	end	
	
if civ.hasTech(object.tUSA, civ.getTech(44)) then
	justOnce("USAGetsTheBomb", function()
		civ.ui.text(func.splitlines(object.xHydrogenBombUSA))
	end)
	end	
	
if civ.hasTech(object.tEurope, civ.getTech(44)) then
	justOnce("EuropeGetsTheBomb", function()
		civ.ui.text(func.splitlines(object.xHydrogenBombEurope))
	end)
	end	
	
if civ.hasTech(object.tIndia, civ.getTech(44)) then
	justOnce("IndiaGetsTheBomb", function()
		civ.ui.text(func.splitlines(object.xHydrogenBombIndia))
	end)
	end	
	
if civ.hasTech(object.tChina, civ.getTech(44)) then
	justOnce("ChinaGetsTheBomb", function()
		civ.ui.text(func.splitlines(object.xHydrogenBombChina))
	end)
	end	

	
	
end)

civ.enableTechGroup(object.tUSSR , 1, 0)
civ.enableTechGroup(object.tUSSR , 2, 2)
civ.enableTechGroup(object.tUSSR , 3, 2)
civ.enableTechGroup(object.tUSSR , 4, 2)
civ.enableTechGroup(object.tUSSR , 5, 0)
civ.enableTechGroup(object.tUSSR , 6, 2)
civ.enableTechGroup(object.tUSSR , 7, 2)

civ.enableTechGroup(object.tUSA , 1, 2)
civ.enableTechGroup(object.tUSA , 2, 0)
civ.enableTechGroup(object.tUSA , 3, 2)
civ.enableTechGroup(object.tUSA , 4, 2)
civ.enableTechGroup(object.tUSA , 5, 0)
civ.enableTechGroup(object.tUSA , 6, 2)
civ.enableTechGroup(object.tUSA , 7, 2)

civ.enableTechGroup(object.tEurope , 1, 2)
civ.enableTechGroup(object.tEurope , 2, 2)
civ.enableTechGroup(object.tEurope , 3, 2)
civ.enableTechGroup(object.tEurope , 4, 2)
civ.enableTechGroup(object.tEurope , 5, 0)
civ.enableTechGroup(object.tEurope , 6, 2)
civ.enableTechGroup(object.tEurope , 7, 0)

civ.enableTechGroup(object.tChina , 1, 2)
civ.enableTechGroup(object.tChina , 2, 2)
civ.enableTechGroup(object.tChina , 3, 0)
civ.enableTechGroup(object.tChina , 4, 2)
civ.enableTechGroup(object.tChina , 5, 2)
civ.enableTechGroup(object.tChina , 6, 2)
civ.enableTechGroup(object.tChina , 7, 2)

civ.enableTechGroup(object.tIndia , 1, 2)
civ.enableTechGroup(object.tIndia , 2, 2)
civ.enableTechGroup(object.tIndia , 3, 0)
civ.enableTechGroup(object.tIndia , 4, 2)
civ.enableTechGroup(object.tIndia , 5, 2)
civ.enableTechGroup(object.tIndia , 6, 0)
civ.enableTechGroup(object.tIndia , 7, 2)

civ.enableTechGroup(object.tProWest , 1, 2)
civ.enableTechGroup(object.tProWest , 2, 2)
civ.enableTechGroup(object.tProWest , 3, 2)
civ.enableTechGroup(object.tProWest , 4, 0)
civ.enableTechGroup(object.tProWest , 5, 2)
civ.enableTechGroup(object.tProWest , 6, 2)
civ.enableTechGroup(object.tProWest , 7, 2)

civ.enableTechGroup(object.tProEast , 1, 2)
civ.enableTechGroup(object.tProEast , 2, 2)
civ.enableTechGroup(object.tProEast , 3, 2)
civ.enableTechGroup(object.tProEast , 4, 0)
civ.enableTechGroup(object.tProEast , 5, 2)
civ.enableTechGroup(object.tProEast , 6, 2)
civ.enableTechGroup(object.tProEast , 7, 2)




civ.scen.onLoad(function (buffer)

state.formationTable = {}
state.formationFlag = false

for unit in civ.iterateUnits() do
		for _, typeToBeDeleted in pairs(unitTypesToBeDeletedEachTurn) do
			if unit.type.id==typeToBeDeleted then
				civ.deleteUnit(unit)
			end
		end
	end
	
	end)
	
	-- doOnActivateUnit is a local variable, but I want to reference it earlier in the code,
-- so I defined it as nil above
doOnActivateUnit = function(unit,source)
    -- gets better unit selection
    gen.selectNextActiveUnit(unit,customWeightFunction)
    --unit = gen.activateBetterUnit(unit,source)
   -- reHomePayloadUnit(unit)
    state.formationTable = {}
    state.formationFlag = false
    --[[if civ.isCity(cityToDelete) then
        local loc = cityToDelete.location
        civ.deleteCity(cityToDelete)
        cityToDelete = nil        
    end--]]
    local activeTribe = civ.getCurrentTribe()
    local activeUnitType = unit.type

 -- functionality to have events after a tribe's production.  This will not happen if the tribe
    -- has no units to activate
    
    if flag("AfterProdTribe"..tostring(activeTribe.id).."NotDone") then
        afterProduction(civ.getTurn(),activeTribe)
        setFlagFalse("AfterProdTribe"..tostring(activeTribe.id).."NotDone")
    end
	
	
	
	
	
end

civ.scen.onActivateUnit(doOnActivateUnit)

local cityID = {
	["Changchun"] = 147 
	,["Shenyang"] = 183
	,["Bejing"] = 181
	,["Shanghai"] = 194
	,["Nanking"] = 193
	,["Fuzhou"] = 196
	,["Taipei"] = 167
	

}



civ.scen.onCityTaken(function (city, defender)
local conqueror = civ.getCurrentTribe() 


--CHINA EVENTS MP AND SP
	
--Chinese forces capture Changchun in Civil War
if city == object.cChangchun and conqueror == object.tChina then
	justOnce("ChangchunCapturedCivilWar", function()
		civ.ui.text(func.splitlines(object.xFallOfChangchun))
		civlua.createUnit(object.uM26Pershing, object.tChina, {{101,51,0}}, {count=2, randomize=false, veteran=false})
	end)
	end 
	
--Chinese forces capture Shenyang in Civil War
if city == object.cShenyang  and conqueror == object.tChina then
	justOnce("ShenyangCapturedCivilWar", function()
		civ.ui.text(func.splitlines(object.xFallOfShenyang))
		civlua.createUnit(object.uFieldArtillery, object.tChina, {{100,56,0}}, {count=2, randomize=false, veteran=false})
	end)
	end

--Chinese forces capture Bejing in Civil War
if city == object.cBejing and conqueror == object.tChina then
	justOnce("BejingCapturedCivilWar", function()
		civ.ui.text(func.splitlines(object.xFallOfBejing))
		civlua.createUnit(object.uChineseInf, object.tChina, {{93,59,0}}, {count=5, randomize=false, veteran=false})
	end)
	end	
	
--Chinese forces capture Shanghai in Civil War
if city == object.cShanghai and conqueror == object.tChina then
	justOnce("ShanghaiCapturedCivilWar", function()
		civ.ui.text(func.splitlines(object.xFallOfShanghai))
		civlua.createUnit(object.uDestroyer, object.tChina, {{98,72,0}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tChina, {{98,72,0}}, {count=1, randomize=false, veteran=false})
	end)
	end	
	
	--Chinese forces capture Nanking in Civil War
if city == object.cNanking and conqueror == object.tChina then
	justOnce("NankingCapturedCivilWar", function()
		civ.ui.text(func.splitlines(object.xFallOfNanking))
		civlua.createUnit(object.uChineseInf, object.tChina, {{92,72,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(object.uM26Pershing, object.tChina, {{92,72,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uSpitfire, object.tChina, {{92,72,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uFieldArtillery, object.tChina, {{92,72,0}}, {count=2, randomize=false, veteran=false})
	end)
	end

--Chinese forces capture Fuzhou in Civil War
if city == object.cFuzhou and conqueror == object.tChina then
	justOnce("FuzhouCapturedCivilWar", function()
		civ.ui.text(func.splitlines(object.xFallOfFuzhou))
		civlua.createUnit(object.uNAsianNat, object.tProWest, {{100,84,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(object.uM26Pershing, object.tProWest, {{100,84,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uSpitfire, object.tProWest, {{100,84,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uFieldArtillery, object.tProWest, {{100,84,0}}, {count=1, randomize=false, veteran=false})
	end)
	end
	
if city == object.cLanzhou and conqueror == object.tChina then
	justOnce("LanzhouCapturedCivilWar", function()
		civ.ui.text(func.splitlines(object.xFallOfLanzhou))
		civlua.createUnit(object.uChineseInf, object.tChina, {{75,65,0},{74,64,0},{72,60,0},{78,64,0}}, {count=3, randomize=true, veteran=false})
		civlua.createUnit(object.uChineseInf, object.tChina, {{75,65,0},{74,64,0},{72,60,0},{78,64,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uChineseInf, object.tChina, {{75,65,0},{74,64,0},{72,60,0},{78,64,0}}, {count=2, randomize=true, veteran=false})
	end)
	end	

if city == object.cKunming or city == object.cNanning and conqueror == object.tChina then
	justOnce("ChinaReachesSouthEast", function()
		civ.ui.text(func.splitlines(object.xChinaReachesVietnamBorder))
		civlua.createUnit(object.uSEAsianRev, object.tProEast, {{82,94,0},{84,96,0},{86,98,0},{85,95,0},{85,105,0},{86,110,0},{88,104,0},{82,96,0},{83,97,0}}, {count=12, randomize=true, veteran=false})
	    civlua.createUnit(object.uGunTruck, object.tProEast, {{82,94,0},{84,96,0},{86,98,0},{85,95,0},{85,105,0},{86,110,0},{88,104,0},{82,96,0},{83,97,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uRPG, object.tProEast, {{82,94,0},{84,96,0},{86,98,0},{85,95,0},{85,105,0},{86,110,0},{88,104,0},{82,96,0},{83,97,0}}, {count=2, randomize=true, veteran=false})
	end)
	end 

if city == object.cYanan and conqueror == object.tProWest then
	justOnce("YananCapturedCivilWar", function()
		civ.ui.text(func.splitlines(object.xFallOfYanan))
		civlua.createUnit(object.uChineseInf, object.tChina, {{84,58,0},{82,60,0},{87,57,0},{85,57,0},{81,61,0}}, {count=6, randomize=true, veteran=false})
	end)
	end	
	

	
--Chinese forces capture Taipei in Civil War.  Different text for SP vs MP because in SP, the USA will respond greatly. 


--China captures Taipei SP
if city == object.cTaipei and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(2)) and not civ.hasTech(object.tUSA, civ.getTech(3,4,6,8,10)) then
	justOnce("TaipeiCapturedCivilWarEarlyJetTech", function()
		civ.ui.text(func.splitlines(object.xFallOfTaipeiSP))
		--civ.ui.text(func.splitlines(object.xFallOfTaipeiMP)) --MP 
		civlua.createUnit(object.uEarlyJet, object.tChina, {{100,84,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.cTaipei and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(3)) and not civ.hasTech(object.tUSA, civ.getTech(4,6,8,10)) then
justOnce("TaipeiCapturedCivilWarF86Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfTaipeiSP))
		civlua.createUnit(object.uF86Sabre, object.tChina, {{100,84,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.cTaipei and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(4)) and not civ.hasTech(object.tUSA, civ.getTech(6,8,10)) then
justOnce("TaipeiCapturedCivilWarF100Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfTaipeiSP))
		civlua.createUnit(object.uF100SuperSabre, object.tChina, {{100,84,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.cTaipei and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(6)) and not civ.hasTech(object.tUSA, civ.getTech(8,10)) then
justOnce("TaipeiCapturedCivilWarF4Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfTaipeiSP))
		civlua.createUnit(object.uF4PhantomII, object.tChina, {{100,84,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.cTaipei and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(8)) and not civ.hasTech(object.tUSA, civ.getTech(10)) then
justOnce("TaipeiCapturedCivilWarF14Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfTaipeiSP))
		civlua.createUnit(object.uF14Tomcat, object.tChina, {{100,84,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.cTaipei and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(10)) then
justOnce("TaipeiCapturedCivilWarF16Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfTaipeiSP))
		civlua.createUnit(object.uF16Falcon , object.tChina, {{100,84,0}}, {count=2, randomize=false, veteran=false})
	end)
	end	

--SP ONLY
--TAIWAN American Response Jet Fighter Component.  Will tie in attack craft simply to the fighter tech here to save time and space.
if city == object.cTaipei and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(2)) and not civ.hasTech(object.tUSA, civ.getTech(3,4,6,8,10)) then
	justOnce("TaipeiUSRespondsEarlyJetTech", function()
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=false})
		
	end)
elseif city == object.cTaipei and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(3)) and not civ.hasTech(object.tUSA, civ.getTech(4,6,8,10)) then
justOnce("TaipeiUSRespondsF86Tech", function()
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=false})
	end)
elseif city == object.cTaipei and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(4)) and not civ.hasTech(object.tUSA, civ.getTech(6,8,10)) then
justOnce("TaipeiUSRespondsF100Tech", function()
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=false})
	end)
elseif city == object.cTaipei and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(6)) and not civ.hasTech(object.tUSA, civ.getTech(8,10)) then
justOnce("TaipeiUSRespondsF4Tech", function()
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair , object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair , object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair , object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=false})
	end)
elseif city == object.cTaipei and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(8)) and not civ.hasTech(object.tUSA, civ.getTech(10)) then
justOnce("TaipeiUSRespondsF14Tech", function()
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair , object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair , object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair , object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=false})
	end)
elseif city == object.cTaipei and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(10)) then
justOnce("TaipeiUSRespondsF16Tech", function()
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair , object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{102,88,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair , object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair , object.tUSA, {{102,90,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{101,91,0}}, {count=1, randomize=false, veteran=false})
	end)
	end	
	
--TAIWAN - US Ground Response SP

if city == object.cTaipei and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(1)) and not civ.hasTech(object.tUSA, civ.getTech(12,13,14,16)) then
	justOnce("TaipeiCapturedTank1Tech", function()
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lTaiwanInvasionPoint1)
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint1 )
		
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lTaiwanInvasionPoint2)
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint2 )
		
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lTaiwanInvasionPoint3)
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint3 )
		
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lTaiwanInvasionPoint4)
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint4 )
		
	end)
	
elseif city == object.cTaipei and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(12)) and not civ.hasTech(object.tUSA, civ.getTech(13,14,16)) then
	justOnce("TaipeiCapturedTank2Tech", function()

		civ.createUnit(object.uM48Patton , object.tUSA,object.lTaiwanInvasionPoint1)
		civ.createUnit(object.uM48Patton , object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint1 )
		
		civ.createUnit(object.uM48Patton, object.tUSA,object.lTaiwanInvasionPoint2)
		civ.createUnit(object.uM48Patton, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint2 )
		
		civ.createUnit(object.uM48Patton, object.tUSA,object.lTaiwanInvasionPoint3)
		civ.createUnit(object.uM48Patton, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint3 )
		
		civ.createUnit(object.uM48Patton, object.tUSA,object.lTaiwanInvasionPoint4)
		civ.createUnit(object.uM48Patton, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint4 )
end)

elseif city == object.cTaipei and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(13)) and not civ.hasTech(object.tUSA, civ.getTech(14,16)) then
	justOnce("TaipeiCapturedTank3Tech", function()

		civ.createUnit(object.uM60A1 , object.tUSA,object.lTaiwanInvasionPoint1)
		civ.createUnit(object.uM60A1 , object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint1 )
		
		civ.createUnit(object.uM60A1, object.tUSA,object.lTaiwanInvasionPoint2)
		civ.createUnit(object.uM60A1, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint2 )
		
		civ.createUnit(object.uM60A1, object.tUSA,object.lTaiwanInvasionPoint3)
		civ.createUnit(object.uM60A1, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint3 )
		
		civ.createUnit(object.uM60A1, object.tUSA,object.lTaiwanInvasionPoint4)
		civ.createUnit(object.uM60A1, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint4 )
		
end) 

elseif city == object.cTaipei and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(14)) and not civ.hasTech(object.tUSA, civ.getTech(16)) then
	justOnce("TaipeiCapturedTank4Tech", function()

		civ.createUnit(object.uM60A3 , object.tUSA,object.lTaiwanInvasionPoint1)
		civ.createUnit(object.uM60A3 , object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint1 )
		
		civ.createUnit(object.uM60A3, object.tUSA,object.lTaiwanInvasionPoint2)
		civ.createUnit(object.uM60A3, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint2 )
		
		civ.createUnit(object.uM60A3, object.tUSA,object.lTaiwanInvasionPoint3)
		civ.createUnit(object.uM60A3, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint3 )
		
		civ.createUnit(object.uM60A3, object.tUSA,object.lTaiwanInvasionPoint4)
		civ.createUnit(object.uM60A3, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint4 )
		
end)

elseif city == object.cTaipei and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(16)) then
	justOnce("TaipeiCapturedTank5Tech", function()

		civ.createUnit(object.uM1Abrams , object.tUSA,object.lTaiwanInvasionPoint1)
		civ.createUnit(object.uM1Abrams , object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint1 )
		
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lTaiwanInvasionPoint2)
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint2 )
		
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lTaiwanInvasionPoint3)
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint3 )
		
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lTaiwanInvasionPoint4)
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lTaiwanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lTaiwanInvasionPoint4 )
		
end)


end 


--CHINA INVADES JAPAN MP
--Will give China a lot of money, but leaves things open ended for the human player to respond as they see fit.
--[[if city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA then
	justOnce("JapanInvadedMP", function()
	civ.ui.text(func.splitlines(object.xChinaInvadesJapanMP))
	object.tChina.money = object.tChina.money + 3000
	end)

end]]
 
--CHINA INVADES JAPAN SP
--Prompts large response from USA in SP ONLY.  Response dependent on US Tech Level and Washington DC remaining US control.


if city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(2)) and not civ.hasTech(object.tUSA, civ.getTech(3,4,6,8,10)) then
	justOnce("JapanUSRespondsEarlyJetTech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP1))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP2))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP3))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP4))
		object.tChina.money = object.tChina.money + 3000
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uWesternInf, object.tProWest, {{111,67,0},{114,66,0},{115,67,0},{115,61,0},{117,49,0},{115,49,0},{110,68,0},{107,73,0},{106,72,0},{116,48,0}}, {count=25, randomize=true, veteran=false})
	end)
elseif city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(3)) and not civ.hasTech(object.tUSA, civ.getTech(4,6,8,10)) then
justOnce("JapanUSRespondsF86Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP1))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP2))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP3))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP4))
		object.tChina.money = object.tChina.money + 3000
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uWesternInf, object.tProWest, {{111,67,0},{114,66,0},{115,67,0},{115,61,0},{117,49,0},{115,49,0},{110,68,0},{107,73,0},{106,72,0},{116,48,0}}, {count=25, randomize=true, veteran=false})
	end)
elseif city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(4)) and not civ.hasTech(object.tUSA, civ.getTech(6,8,10)) then
justOnce("JapanUSRespondsF100Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP1))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP2))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP3))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP4))
		object.tChina.money = object.tChina.money + 3000
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uWesternInf, object.tProWest, {{111,67,0},{114,66,0},{115,67,0},{115,61,0},{117,49,0},{115,49,0},{110,68,0},{107,73,0},{106,72,0},{116,48,0}}, {count=25, randomize=true, veteran=false})
	end)
elseif city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(6)) and not civ.hasTech(object.tUSA, civ.getTech(8,10)) then
justOnce("JapanUSRespondsF4Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP1))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP2))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP3))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP4))
		object.tChina.money = object.tChina.money + 3000
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uWesternInf, object.tProWest, {{111,67,0},{114,66,0},{115,67,0},{115,61,0},{117,49,0},{115,49,0},{110,68,0},{107,73,0},{106,72,0},{116,48,0}}, {count=25, randomize=true, veteran=false})
	end)
elseif city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(8)) and not civ.hasTech(object.tUSA, civ.getTech(10)) then
justOnce("JapanUSRespondsF14Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP1))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP2))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP3))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP4))
		object.tChina.money = object.tChina.money + 3000
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uWesternInf, object.tProWest, {{111,67,0},{114,66,0},{115,67,0},{115,61,0},{117,49,0},{115,49,0},{110,68,0},{107,73,0},{106,72,0},{116,48,0}}, {count=25, randomize=true, veteran=false})
	end)
elseif city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(10)) then
justOnce("JapanUSRespondsF16Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP1))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP2))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP3))
		civ.ui.text(func.splitlines(object.xChinaInvadesJapanSP4))
		object.tChina.money = object.tChina.money + 3000
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{118,72,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{113,77,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{120,60,0}}, {count=1, randomize=false, veteran=false})
		
		civlua.createUnit(object.uWesternInf, object.tProWest, {{111,67,0},{114,66,0},{115,67,0},{115,61,0},{117,49,0},{115,49,0},{110,68,0},{107,73,0},{106,72,0},{116,48,0}}, {count=25, randomize=true, veteran=false})
	end)
	end	
	
--JAPAN - US Ground Response SP

if city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(1)) and not civ.hasTech(object.tUSA, civ.getTech(12,13,14,16)) then
	justOnce("JapanCapturedTank1Tech", function()
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lJapanInvasionPoint1)
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint1 )
		
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lJapanInvasionPoint2)
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint2 )
		
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lJapanInvasionPoint3)
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint3 )
		
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lJapanInvasionPoint4)
		civ.createUnit(object.uM26Pershing, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint4 )
		
	end)
	
elseif city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(12)) and not civ.hasTech(object.tUSA, civ.getTech(13,14,16)) then
	justOnce("JapanCapturedTank2Tech", function()

		civ.createUnit(object.uM48Patton, object.tUSA,object.lJapanInvasionPoint1)
		civ.createUnit(object.uM48Patton, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint1 )
		
		civ.createUnit(object.uM48Patton, object.tUSA,object.lJapanInvasionPoint2)
		civ.createUnit(object.uM48Patton, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint2 )
		
		civ.createUnit(object.uM48Patton, object.tUSA,object.lJapanInvasionPoint3)
		civ.createUnit(object.uM48Patton, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint3 )
		
		civ.createUnit(object.uM48Patton, object.tUSA,object.lJapanInvasionPoint4)
		civ.createUnit(object.uM48Patton, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint4 )
end)

elseif city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(13)) and not civ.hasTech(object.tUSA, civ.getTech(14,16)) then
	justOnce("JapanCapturedTank3Tech", function()

		civ.createUnit(object.uM60A1, object.tUSA,object.lJapanInvasionPoint1)
		civ.createUnit(object.uM60A1, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint1 )
		
		civ.createUnit(object.uM60A1, object.tUSA,object.lJapanInvasionPoint2)
		civ.createUnit(object.uM60A1, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint2 )
		
		civ.createUnit(object.uM60A1, object.tUSA,object.lJapanInvasionPoint3)
		civ.createUnit(object.uM60A1, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint3 )
		
		civ.createUnit(object.uM60A1, object.tUSA,object.lJapanInvasionPoint4)
		civ.createUnit(object.uM60A1, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint4 )
		
end) 

elseif city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(14)) and not civ.hasTech(object.tUSA, civ.getTech(16)) then
	justOnce("JapanCapturedTank4Tech", function()

		civ.createUnit(object.uM60A3, object.tUSA,object.lJapanInvasionPoint1)
		civ.createUnit(object.uM60A3, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint1 )
		
		civ.createUnit(object.uM60A3, object.tUSA,object.lJapanInvasionPoint2)
		civ.createUnit(object.uM60A3, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint2 )
		
		civ.createUnit(object.uM60A3, object.tUSA,object.lJapanInvasionPoint3)
		civ.createUnit(object.uM60A3, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint3 )
		
		civ.createUnit(object.uM60A3, object.tUSA,object.lJapanInvasionPoint4)
		civ.createUnit(object.uM60A3, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint4 )
		
end)

elseif city == object.cTokyo or city == object.cOsaka or city == object.cKagoshima or city == object.cSapporo and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(16)) then
	justOnce("JapanCapturedTank5Tech", function()

		civ.createUnit(object.uM1Abrams, object.tUSA,object.lJapanInvasionPoint1)
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint1 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint1 )
		
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lJapanInvasionPoint2)
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint2 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint2 )
		
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lJapanInvasionPoint3)
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint3 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint3 )
		
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lJapanInvasionPoint4)
		civ.createUnit(object.uM1Abrams, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSInf, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uUSMarines, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFieldArtillery, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uFreighter, object.tUSA,object.lJapanInvasionPoint4 )
		civ.createUnit(object.uDestroyer, object.tUSA,object.lJapanInvasionPoint4 )
		
end)


end 


--Chinese forces capture Okinawa and gain US equipment for their trouble. 
if city == object.lOkinawa.city and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(2)) and not civ.hasTech(object.tUSA, civ.getTech(3,4,6,8,10)) then
	justOnce("OkinawaCapturedEarlyJetTech", function()
		civ.ui.text(func.splitlines(object.xFallOfOkinawa))
		civlua.createUnit(object.uEarlyJet, object.tChina, {{104,82,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.lOkinawa.city and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(3)) and not civ.hasTech(object.tUSA, civ.getTech(4,6,8,10)) then
justOnce("OkinawaCapturedF86Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfOkinawa))
		civlua.createUnit(object.uF86Sabre, object.tChina, {{104,82,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.lOkinawa.city and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(4)) and not civ.hasTech(object.tUSA, civ.getTech(6,8,10)) then
justOnce("OkinawaCapturedF100Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfOkinawa))
		civlua.createUnit(object.uF100SuperSabre, object.tChina, {{104,82,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.lOkinawa.city and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(6)) and not civ.hasTech(object.tUSA, civ.getTech(8,10)) then
justOnce("OkinawaCapturedF4Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfOkinawa))
		civlua.createUnit(object.uF4PhantomII, object.tChina, {{104,82,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.lOkinawa.city and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(8)) and not civ.hasTech(object.tUSA, civ.getTech(10)) then
justOnce("OkinawaCapturedF14Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfOkinawa))
		civlua.createUnit(object.uF14Tomcat, object.tChina, {{104,82,0}}, {count=2, randomize=false, veteran=false})
	end)
elseif city == object.lOkinawa.city and conqueror == object.tChina and civ.hasTech(object.tUSA, civ.getTech(10)) then
justOnce("OkinawaCapturedF16Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfOkinawa))
		civlua.createUnit(object.uF16Falcon , object.tChina, {{104,82,0}}, {count=2, randomize=false, veteran=false})
	end)
	end	
	
--Chinese forces invade Indonesia and liberate it from Europeans

if city == object.cSurabaya or city == object.cJakarta or city ==object.cPalembang or city ==object.cSorong or city ==object.cManado or city ==object.cMakassar or city ==object.cSumpit and conqueror == object.tChina and defender == object.tEurope then
	justOnce("ChineseInvasionOfIndonesia", function()
		civ.ui.text(func.splitlines(object.xChineseInvadeIndonesia))
		civlua.createUnit(object.uSEAsianRev, object.tChina, {{92,144,0},{89,131,0},{92,130,0},{96,130,0},{108,136,0},{106,138,0},{94,144,0},{88,142,0},{83,133,0},{82,136,0},{85,139,0},{82,132,0},{81,129,0},{79,129,0},{100,144,0},{89,143,0}}, {count=16, randomize=true, veteran=false})
	    civlua.createUnit(object.uGunTruck, object.tChina, {{92,144,0},{89,131,0},{92,130,0},{96,130,0},{108,136,0},{106,138,0},{94,144,0},{88,142,0},{83,133,0},{82,136,0},{85,139,0},{82,132,0},{81,129,0},{79,129,0},{100,144,0},{89,143,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uRPG, object.tChina, {{92,144,0},{89,131,0},{92,130,0},{96,130,0},{108,136,0},{106,138,0},{94,144,0},{88,142,0},{83,133,0},{82,136,0},{85,139,0},{82,132,0},{81,129,0},{79,129,0},{100,144,0},{89,143,0}}, {count=2, randomize=true, veteran=false})
	end)
	end 

--China occupies Lhasa
if city == object.cLhasa and conqueror == object.tChina then
	justOnce("LhasaCaptured", function()
		civ.ui.text(func.splitlines(object.xFallOfLhasa))
	end)
	end


--HONG Kong
--MP
--[[if city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope then
	justOnce("HongKongCapturedJet1Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfHongKongMP))
		object.tChina.money = object.tChina.money + 3000
	end)
end]]


--HONG KONG SINGLE PLAYER ONLY
--Chinese forces capture Hong Kong.  In single player game, this will prompt large response from Europe if London is still in European hands. 
if city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(2)) and not civ.hasTech(object.tEurope, civ.getTech(3,4,6,8,10)) then
	justOnce("HongKongCapturedJet1Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfHongKongSP))
		civlua.createUnit(object.uEarlyJet, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=3, randomize=true, veteran=true})
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(3)) and not civ.hasTech(object.tEurope, civ.getTech(4,6,8,10)) then
justOnce("HongKongCapturedJet2Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfHongKongSP))
		civlua.createUnit(object.uHunter, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=3, randomize=true, veteran=true})
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(4)) and not civ.hasTech(object.tEurope, civ.getTech(6,8,10)) then
justOnce("HongKongCapturedJet3Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfHongKongSP))
		civlua.createUnit(object.uSuperMystere, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=3, randomize=true, veteran=true})
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(6)) and not civ.hasTech(object.tEurope, civ.getTech(8,10)) then
justOnce("HongKongCapturedJet4Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfHongKongSP))
		civlua.createUnit(object.uMirageIII, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=3, randomize=true, veteran=true})
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(8)) and not civ.hasTech(object.tEurope, civ.getTech(10)) then
justOnce("HongKongCapturedJet5Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfHongKongSP))
		civlua.createUnit(object.uHarrier, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=3, randomize=true, veteran=true})
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(10)) then
justOnce("HongKongCapturedJet6Tech", function()
		civ.ui.text(func.splitlines(object.xFallOfHongKongSP))
		civlua.createUnit(object.uMirage2000, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=3, randomize=true, veteran=true})
	end)
	end	
--The Jabo component, based on techs.
if city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(1)) and not civ.hasTech(object.tEurope, civ.getTech(39,40)) then
	justOnce("HongKongCapturedJabo1Tech", function()
		civlua.createUnit(object.uF4UCorsair, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=3, randomize=true, veteran=true})
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(39)) and not civ.hasTech(object.tEurope, civ.getTech(40)) then
justOnce("HongKongCapturedJabo2Tech", function()
		civlua.createUnit(object.uFiatG91, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=3, randomize=true, veteran=true})
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(40)) then
justOnce("HongKongCapturedJabo3Tech", function()
		civlua.createUnit(object.uTornado, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=3, randomize=true, veteran=true})
	end)
	end	
	
	--The strategic component, based on techs.
if city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(1)) and not civ.hasTech(object.tEurope, civ.getTech(23,27)) then
	justOnce("HongKongCapturedStrat1Tech", function()
		civlua.createUnit(object.uStrategicBomber, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=2, randomize=true, veteran=true})
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(23)) and not civ.hasTech(object.tEurope, civ.getTech(27)) then
justOnce("HongKongCapturedStrat2Tech", function()
		civlua.createUnit(object.uCanberra, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=2, randomize=true, veteran=true})
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(27)) then
justOnce("HongKongCapturedStrat3Tech", function()
		civlua.createUnit(object.uVulcan, object.tEurope, {{94,94,0},{96,92,0},{96,90,0},{94,92,0}}, {count=2, randomize=true, veteran=true})
	end)
	end	
	

--The ground component, based on techs. 
if city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(1)) and not civ.hasTech(object.tEurope, civ.getTech(12,13,14,16)) then
	justOnce("HongKongCapturedTank1Tech", function()
		civ.createUnit(object.uCenturion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uCenturion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint1)
		
		civ.createUnit(object.uCenturion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uCenturion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint2)
		
		civ.createUnit(object.uCenturion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uCenturion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint3)
		
		civ.createUnit(object.uCenturion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uCenturion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint4)
		
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(12)) and not civ.hasTech(object.tEurope, civ.getTech(13,14,16)) then
justOnce("HongKongCapturedTank2Tech", function()
		
		civ.createUnit(object.uM47, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uM47, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint1)
		
		civ.createUnit(object.uM47, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uM47, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint2)
		
		
		civ.createUnit(object.uM47, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uM47, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint3)
		
		civ.createUnit(object.uM47, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uM47, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint4)
		
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(13)) and not civ.hasTech(object.tEurope, civ.getTech(14,16)) then
justOnce("HongKongCapturedTank3Tech", function()

		civ.createUnit(object.uLeopardI, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uLeopardI, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint1)
		
		civ.createUnit(object.uLeopardI, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uLeopardI, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint2)
		
		civ.createUnit(object.uLeopardI, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uLeopardI, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint3)
		
		civ.createUnit(object.uLeopardI, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uLeopardI, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint4)
		
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(14)) and not civ.hasTech(object.tEurope, civ.getTech(16)) then
justOnce("HongKongCapturedTank4Tech", function()

		civ.createUnit(object.uChieftan, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uChieftan, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint1)
		
		civ.createUnit(object.uChieftan, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uChieftan, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint2)
		
		civ.createUnit(object.uChieftan, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uChieftan, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint3)
		
		civ.createUnit(object.uChieftan, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uChieftan, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint4)
		
	end)
elseif city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(16)) then
justOnce("HongKongCapturedTank5Tech", function()
		
		civ.createUnit(object.uLeopardII, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uLeopardII, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint1)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint1)
		
		civ.createUnit(object.uLeopardII, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uLeopardII, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint2)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint2)
		
		civ.createUnit(object.uLeopardII, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uLeopardII, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint3)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint3)
		
		civ.createUnit(object.uLeopardII, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uLeopardII, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uEuroInf, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uForeignLegion, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFieldArtillery, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uFreighter, object.tEurope,object.lHKInvasionPoint4)
		civ.createUnit(object.uDestroyer, object.tEurope,object.lHKInvasionPoint4)
		
	end)
	end	
	
	--The naval component, regardless of techs.
if city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope then
	justOnce("HongKongCapturedNavalResponse", function()
		civlua.createUnit(object.uCarrier, object.tEurope, {{94,98,0},{110,90,0},{96,96,0},{105,93,0},{95,97,0},{93,99,0},{103,93,0},{98,90,0}}, {count=1, randomize=true, veteran=true})
		civlua.createUnit(object.uBattleship, object.tEurope, {{94,98,0},{110,90,0},{96,96,0},{105,93,0},{95,97,0},{93,99,0},{103,93,0},{98,90,0}}, {count=1, randomize=true, veteran=true})
		civlua.createUnit(object.uCruiser, object.tEurope, {{94,98,0},{110,90,0},{96,96,0},{105,93,0},{95,97,0},{93,99,0},{103,93,0},{98,90,0}}, {count=2, randomize=true, veteran=true})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{94,98,0},{110,90,0},{96,96,0},{105,93,0},{95,97,0},{93,99,0},{103,93,0},{98,90,0}}, {count=4, randomize=true, veteran=true})
		civlua.createUnit(object.uFrigate, object.tEurope, {{94,98,0},{110,90,0},{96,96,0},{105,93,0},{95,97,0},{93,99,0},{103,93,0},{98,90,0}}, {count=8, randomize=true, veteran=true})
	end)
	end	
	
	--The paratroop and insurrection component, regardless of techs
if city == object.cHongKong and conqueror == object.tChina and defender == object.tEurope and object.cLondon.owner == object.tEurope then
	justOnce("HongKongCapturedOtherResponse", function()
		civlua.createUnit(object.uUKParas, object.tEurope, {{92,90,0},{91,89,0},{94,88,0},{95,87,0},{94,86,0},{92,86,0},{92,86,0},{91,87,0},{90,90,0}}, {count=4, randomize=false, veteran=true})
		civlua.createUnit(object.uSpecialForces, object.tEurope, {{92,90,0},{91,89,0},{94,88,0},{95,87,0},{94,86,0},{92,86,0},{92,86,0},{91,87,0},{90,90,0}}, {count=1, randomize=false, veteran=true})
		
	end)
	end	
	
	--If China invades the Phillippinnes, there will be a large insurrection.
if city == object.cManilla or city == object.cDavao and conqueror == object.tChina and object.cLondon.owner == object.tEurope then
	justOnce("ChinaInvadesPhilippinnes", function()
		civ.ui.text(func.splitlines(object.xFallOfPhilippines))
	 	civlua.createUnit(object.uSEAsianNat, object.tProWest, {{98,98,0},{99,99,0},{99,101,0},{100,96,0},{100,102,0},{101,105,0},{101,113,0},{102,114,0},{99,115,0},{100,116,0},{98,116,0}}, {count=15, randomize=true, veteran=true})
		civlua.createUnit(object.uSEAsianNat, object.tProWest, {{98,98,0},{99,99,0},{99,101,0},{100,96,0},{100,102,0},{101,105,0},{101,113,0},{102,114,0},{99,115,0},{100,116,0},{98,116,0}}, {count=5, randomize=true, veteran=true})
		civlua.createUnit(object.uRPG, object.tProWest, {{98,98,0},{99,99,0},{99,101,0},{100,96,0},{100,102,0},{101,105,0},{101,113,0},{102,114,0},{99,115,0},{100,116,0},{98,116,0}}, {count=6, randomize=true, veteran=false})
		
	end)
	end	
	
--CHINESE INVASION OF AUSTRALIA MP
--[[if city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest then
	justOnce("AustraliaInvasionMP", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieMP))
		civlua.createUnit(object.uWesternInf, object.tProWest, {{120,178,0},{118,170,0},{119,189,0},{117,195,0},{116,206,0},{113,193,0},{104,156,0},{94,190,0},{118,186,0},{123,187,0},{118,172,0}}, {count=30, randomize=true, veteran=false})
	end)
end]]


--CHINESE INVASION OF AUSTRALIA SP	
--US Aircraft Response dependent on tech
if city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(2)) and not civ.hasTech(object.tUSA, civ.getTech(3,4,6,8,10)) then	
	justOnce("AustraliaInvasionUSResponseEarlyJetTech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP1))
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{128,194,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
		
		
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{124,206,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{133,185,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=3, randomize=true, veteran=false})
		
		
		
		civlua.createUnit(object.uEarlyJet, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{123,213,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
		
		
	end)
elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(3)) and not civ.hasTech(object.tUSA, civ.getTech(4,6,8,10)) then
	justOnce("AustraliaInvasionUSResponseF86Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP1))
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{128,194,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{124,206,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{133,185,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF86Sabre, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{123,213,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
	
	end) 
	
	elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(4)) and not civ.hasTech(object.tUSA, civ.getTech(6,8,10)) then
	justOnce("AustraliaInvasionUSResponseF100Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP1))
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{128,194,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{124,206,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{133,185,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF100SuperSabre, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tUSA, {{123,213,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
	
	end)
	
	elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(6)) and not civ.hasTech(object.tUSA, civ.getTech(8,10)) then
	justOnce("AustraliaInvasionUSResponseF4Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP1))
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{128,194,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{124,206,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{133,185,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF4PhantomII, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{123,213,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
	
	end)
	
	elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(8)) and not civ.hasTech(object.tUSA, civ.getTech(10)) then
	justOnce("AustraliaInvasionUSResponseF14Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP1))
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{128,194,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{124,206,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{133,185,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF14Tomcat, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{123,213,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
	
	end)


elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(10)) then
	justOnce("AustraliaInvasionUSResponseF16Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP1))
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{128,194,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{128,194,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{124,206,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{124,206,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{126,206,0},{128,206,0},{130,206,0},{127,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{133,185,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{133,185,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,196,0},{128,198,0},{128,200,0}}, {count=3, randomize=true, veteran=false})
		
		
		civlua.createUnit(object.uF16Falcon, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uA7Corsair, object.tUSA, {{123,213,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tUSA, {{123,213,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tUSA, {{128,194,0},{128,200,0},{130,200,0},{130,198,0}}, {count=3, randomize=true, veteran=false})
		
	
	end)

  end 
  --US ARMY RESPONSE
  if city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(1)) and not civ.hasTech(object.tUSA, civ.getTech(12,13,14,16)) then	
	justOnce("AustraliaInvasionUSResponseTank1Tech", function()
		civlua.createUnit(object.uUSInf, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=30, randomize=true, veteran=true})
		civlua.createUnit(object.uUSMarines, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=5, randomize=true, veteran=true})
		civlua.createUnit(object.uUSAirborne, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=3, randomize=true, veteran=true})
		civlua.createUnit(object.uFieldArtillery, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=8, randomize=true, veteran=true})
		civlua.createUnit(object.uM26Pershing , object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=16, randomize=true, veteran=true})
		
		
		
	end)

elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(12)) and not civ.hasTech(object.tUSA, civ.getTech(13,14,16)) then
	justOnce("AustraliaInvasionUSResponseTank2Tech", function()
		civlua.createUnit(object.uUSInf, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=30, randomize=true, veteran=true})
		civlua.createUnit(object.uUSMarines, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=5, randomize=true, veteran=true})
		civlua.createUnit(object.uUSAirborne, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=3, randomize=true, veteran=true})
		civlua.createUnit(object.uFieldArtillery, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=8, randomize=true, veteran=true})
		civlua.createUnit(object.uM48Patton, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=16, randomize=true, veteran=true})
		
end)

elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(13)) and not civ.hasTech(object.tUSA, civ.getTech(14,16)) then
	justOnce("AustraliaInvasionUSResponseTank3Tech", function()
		civlua.createUnit(object.uUSInf, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=30, randomize=true, veteran=true})
		civlua.createUnit(object.uUSMarines, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=5, randomize=true, veteran=true})
		civlua.createUnit(object.uUSAirborne, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=3, randomize=true, veteran=true})
		civlua.createUnit(object.uFieldArtillery, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=8, randomize=true, veteran=true})
		civlua.createUnit(object.uM60A1, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=16, randomize=true, veteran=true})
		civlua.createUnit(object.uAH1Cobra, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=6, randomize=true, veteran=true})
	

end)

elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(14)) and not civ.hasTech(object.tUSA, civ.getTech(16)) then
	justOnce("AustraliaInvasionUSResponseTank4Tech", function()
		civlua.createUnit(object.uUSInf, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=30, randomize=true, veteran=true})
		civlua.createUnit(object.uUSMarines, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=5, randomize=true, veteran=true})
		civlua.createUnit(object.uUSAirborne, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=3, randomize=true, veteran=true})
		civlua.createUnit(object.uFieldArtillery, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=8, randomize=true, veteran=true})
		civlua.createUnit(object.uM60A3, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=16, randomize=true, veteran=true})
		civlua.createUnit(object.uBradleyIFV, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=8, randomize=true, veteran=true})
		civlua.createUnit(object.uAH1Cobra, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=6, randomize=true, veteran=true})
	

end)


elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cWashingtonDC.owner == object.tUSA and civ.hasTech(object.tUSA, civ.getTech(16)) then
	justOnce("AustraliaInvasionUSResponseTank5Tech", function()
		civlua.createUnit(object.uUSInf, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=30, randomize=true, veteran=true})
		civlua.createUnit(object.uUSMarines, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=5, randomize=true, veteran=true})
		civlua.createUnit(object.uUSAirborne, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=3, randomize=true, veteran=true})
		civlua.createUnit(object.uFieldArtillery, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=8, randomize=true, veteran=true})
		civlua.createUnit(object.uM1Abrams, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=16, randomize=true, veteran=true})
		civlua.createUnit(object.uBradleyIFV, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=8, randomize=true, veteran=true})
		civlua.createUnit(object.uAH1Cobra, object.tUSA, {{119,183,0},{122,180,0},{114,194,0},{117,193,0},{111,193,0},{120,174,0},{115,183,0},{114,190,0},{111,191,0}}, {count=6, randomize=true, veteran=true})
	

end) 
end 

--European Response to Chinese Invasion of Australia

if city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and attacker == object.tChina and city.defender == object.tProWest and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(2)) and not civ.hasTech(object.tEurope, civ.getTech(3,4,6,8,10)) then	
	justOnce("AustraliaInvasionEuropeResponseEarlyJetTech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP2))
		civlua.createUnit(object.uEarlyJet, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{105,205,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		
		civlua.createUnit(object.uEarlyJet, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{100,198,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=3, randomize=true, veteran=false})
			
	end)
elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(3)) and not civ.hasTech(object.tEurope, civ.getTech(4,6,8,10)) then
	justOnce("AustraliaInvasionEuropeResponseHunterTech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP2))
		civlua.createUnit(object.uHunter, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{105,205,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		
		civlua.createUnit(object.uHunter, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{100,198,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=3, randomize=true, veteran=false})
			
	
	end) 
	
	elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(4)) and not civ.hasTech(object.tEurope, civ.getTech(6,8,10)) then
	justOnce("AustraliaInvasionEuropeResponseSuperMystereTech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP2))
		civlua.createUnit(object.uSuperMystere, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{105,205,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		
		civlua.createUnit(object.uSuperMystere, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uF4UCorsair, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{100,198,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=3, randomize=true, veteran=false})
			
	
	end)
	
	elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(6)) and not civ.hasTech(object.tEurope, civ.getTech(8,10)) then
	justOnce("AustraliaInvasionEuropeResponseMirageIIITech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP2))
		civlua.createUnit(object.uMirageIII, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uFiatG91, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{105,205,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		
		civlua.createUnit(object.uMirageIII, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uFiatG91, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{100,198,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=3, randomize=true, veteran=false})
			
	
	end)
	
	elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(8)) and not civ.hasTech(object.tEurope, civ.getTech(10)) then
	justOnce("AustraliaInvasionEuropeResponseHarrierTech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP2))
		civlua.createUnit(object.uHarrier, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uTornado, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{105,205,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		
		civlua.createUnit(object.uHarrier, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uTornado, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uCarrier, object.tEurope, {{100,198,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=3, randomize=true, veteran=false})
			
	
	end)


elseif city == object.cSydney or city == object.cMelbourne or city == object.cAdelaide or city == object.cHobart or city == object.cBrisbane or city == object.cPerth or city == object.cDarwin and conqueror == object.tChina and defender == object.tProWest and object.cLondon.owner == object.tEurope and civ.hasTech(object.tEurope, civ.getTech(10)) then
	justOnce("AustraliaInvasionEuropeResponseMirage2000Tech", function()
		civ.ui.text(func.splitlines(object.xChinaInvadesAussieSP2))
		civlua.createUnit(object.uMirage2000, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uTornado, object.tEurope, {{105,205,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tEurope, {{105,205,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{103,205,0},{106,206,0},{105,209,0}}, {count=3, randomize=true, veteran=false})
		
		
		
		civlua.createUnit(object.uMirage2000, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uTornado, object.tEurope, {{100,198,0}}, {count=2, randomize=false, veteran=true})
		civlua.createUnit(object.uNPCarrier, object.tEurope, {{100,198,0}}, {count=1, randomize=false, veteran=false})
		civlua.createUnit(object.uCruiser, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=1, randomize=true, veteran=false})
		civlua.createUnit(object.uDestroyer, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=2, randomize=true, veteran=false})
		civlua.createUnit(object.uFrigate, object.tEurope, {{98,198,0},{99,195,0},{102,198,0}}, {count=3, randomize=true, veteran=false})
			
	
	end)

  end 
  

	
	
end) --Ends the onCityTaken

 

--local function afterProduction(turn,tribe)
--simpleReactions.doAfterProduction(tribe)

--if turn == 2 and object.cLondon.owner == object.tEurope and tribe == object.tChina or tribe == object.tIndia then 
--	civ.ui.text(func.splitlines(object.xRulerChangeChurchill))
--end 



	
--	end --Should be the end for the whole after production event chain

--console.afterProduction = function() afterProduction(civ.getTurn(),civ.getCurrentTribe()) end

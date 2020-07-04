-- Events.lua
-- occupationScore = occupationScore+specialNumbers.
-- "Over the Reich"
-- A scenario by John P. Petroski and Prof. Garfield
-- v2018-12-20


print("")
print("Over the Reich")
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
--[[
-- Change this line, replacing MyScenario to whatever the scenario folder name is
local scenarioFolderName = "OTR3"

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
-- this ends the package path code that you need to add.  Use require = "mylibrary" to get the functionality of mylibrary.lua

--]]


-- ���������� External Packages: ������������������������������������������������������������������������������������������������������������������������������

-- The `civ` library is written in C, and contains, generally, lower level functions to interact with the game.
-- It is always in scope.

-- The `civlua` library is written in Lua, and contains higher level functions built on the `civ` library.
local civlua = require "civlua"

-- The `functions` library contains general purpose functions.
local func = require "functions"

local help = require("helpkey")

local radar = require("radar")

--local cr = require("combatReporting")
local log = require("log")

--local newspaper = require("newspaperv1")

local react = require("reaction")

local formation = require("formation")

local vetswap = require("vetswap")

local clouds = require("clouds")

local upkeep = require("upkeep")

local lualzw = require("lualzw")

local gen = require("generalLibrary")

local pathfind = require("pathfind")

local text = require("text")

local geographyTable = require("otrGeography")

local trainGoto = require("trainGoto")

local unitAliases = require("unitAliases")

local reactOTR = require("reactionsOTR")
local reactionBase = require("reactionBase")

-- ���������� Variables: ���������������������������������������������������������������������������������������������������������������������������������������

-- The `state` table represents the persistent state of the scenario, it is initialized here.
-- Keeping all state in a single table helps with serialization, see below.
-- The initial state can be empty for this scenario, since it's only used in calls to `justOnce`,
-- and all references to nonexistent keys evaluate to nil in lua.
local state = {}
-- Our local 'justOnce' function, so it uses our state.
local justOnce = function (key, f)
	civlua.justOnce(civlua.property(state, key), f)
end

state.logState = state.logState or {}
log.linkState(state.logState)
log.setGeographyTable(geographyTable)

state.textTable = state.textTable or {}
text.linkState(state.textTable)

state.newReactionsTable = state.newReactionsTable or {}
reactionBase.linkState(state.newReactionsTable)

state.DDayInvasion=state.DDayInvasion or false
state.AlliesRepulsed=state.AlliesRepulsed or false
state.cHistTable = state.cHistTable or {}
state.specialTargetsTable = state.specialTargetsTable or {}
state.newspaper = state.newspaper or {}
state.newspaper.allies = state.newspaper.allies or {articleName = "Report", newspaperName = "Allied Reports"}
state.newspaper.germans = state.newspaper.germans or {articleName="Report", newspaperName = "German Reports"}
state.reactions = state.reactions or {}
state.radarRemovalInfo = state.radarRemovalInfo or {}
state.cityDockings = state.cityDockings or {}
state.cityHasDoneTrainlift = state.cityHasDoneTrainlift or {}
state.formationFlag = false
state.formationTable = {}
state.mapStorageTable = state.mapStorageTable or {}
state.stormInfoTable = state.stormInfoTable or {}
state.map1FrontStatisticsTable = state.map1FrontStatisticsTable or {}
state.map2FrontStatisticsTable = state.map2FrontStatisticsTable or {}
state.mostRecentMunitionUserID = state.mostRecentMunitionUserID or 0
state.alliedReinforcementTrack = state.alliedReinforcementTrack or {}
state.alliedReinforcementsSent = state.alliedReinforcementsSent or 0

-- generate the weather Engine
--local updateClouds = clouds.generateWeatherUpdateFunction(state.mapStorageTable,state.stormInfoTable,state.map1FrontStatisticsTable,state.map2FrontStatisticsTable)

-- flags can take values true or false
state.flags = state.flags or {}

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

-- counters take numerical values
state.counters = state.counters or {}

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
function console.clearAllClouds()
    clouds.clearAllClouds(state.mapStorageTable)
end
    
function console.updateAllWeather()
    clouds.updateAllWeather(state.mapStorageTable,state.stormInfoTable,clouds.catInfoTable,state.map1FrontStatisticsTable,state.map2FrontStatisticsTable)
end
-- a table to put extra variables in, since we've reached 200 locals in the main function
local overTwoHundred = {}
overTwoHundred.currentUnitGotoOrder = nil
-- However, in some situations, it may be necessary/desirable to
--g initalize some variables/flags in state so they are never nil

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
math.randomseed(os.time())
-- p.g. a place to define certain numbers (e.g. quantities) so they can be changed in one place
local specialNumbers ={}
specialNumbers.engineFailureProbabilitySP = 0.1 -- probability that a plane can't take off on a given turn for the play versus yourself scenario (no effect in the multiplayer version)
specialNumbers.munitionFailureProbabilitySP = 0.25 -- probability that a munition attack will immediately fail and do no damage
--specialNumbers.freighterBonus = 1000
specialNumbers.maximumReactingUnits = 10 -- this is the number of units that can attack a trigger unit during a reaction
specialNumbers.newAirfieldImprovementId = 17
specialNumbers.defaultCarrierFlags = 128-- flags when AEGIS bonus given8320 -- carrier flags when the active unit can use the carrier
specialNumbers.doNotCarryCarrierFlags = 0-- flags when AEGIS bonus given 8192 -- carrier flags for when unit activated can't be carried by carrier
specialNumbers.primaryAttackKey = 75 -- 75 is key k
specialNumbers.secondaryAttackKey = 214 -- 214 is backspace, 86 is v, if that is preferred
specialNumbers.helpKeyID = 211 -- 211 is Tab
specialNumbers.wildeSauKeyID = 85 -- 85 is key u also used for trainlift
specialNumbers.radarSafeTile = {388,6,0}--coordinates of the center of 9 tiles where units can be teleported temporarily.  Chose a lake in Sweden
specialNumbers.scoreDialogKeyCode = 49 -- 49 is '1' above the letter keys
specialNumbers.newspaperKey = 50
specialNumbers.vetSwapKeyID = 51
specialNumbers.formationKeyID = 52
specialNumbers.updateCloudKey = 54
specialNumbers.reportKeyID = 210 --escape
--specialNumbers.backKeyID = 55 --7 above letters
--specialNumbers.reportKeyID = 56 -- 8 above letters
--specialNumbers.nextKeyID = 57 -- 9 above letters
specialNumbers.PoliticalSupportMoneyBonus = 6000 -- Reward for researching political support
specialNumbers.newEscortLosses = 30 -- number of bomber kills outside escort range required for escort Tech.
specialNumbers.ExpertenTrigger1 = 50 -- aircraft kill points for Germans to get Experten Egon Mayer
specialNumbers.reactionRangeToCheck = 6
specialNumbers.alliedScoreIncrementFreighter = 6
specialNumbers.alliedScoreIncrementDestroyPlane = 0.5
specialNumbers.alliedScoreIncrementKillIndustry = 7.5
specialNumbers.alliedScoreIncrementKillRefinery = 7.5
specialNumbers.alliedScoreIncrementKillFactory = 7.5 -- point bonus for killing aircraft factory
specialNumbers.alliedScoreIncrementKillRailyard = 2.5 
specialNumbers.alliedScoreIncrementKillGermanPort = 2.5
specialNumbers.alliedScoreIncrementKillGermanUrban = 7.5
specialNumbers.alliedScoreIncrementKillOccupiedUrban = -2
specialNumbers.alliedScoreIncrementOperationGomorrah = 52.5
specialNumbers.germanScoreIncrementOnTurn = 0
specialNumbers.germanScoreIncrementSinkFreighter = 15
specialNumbers.germanScoreIncrementKillHeavyBomber = 0.25
specialNumbers.germanScoreIncrementKillAlliedUrban = 30
specialNumbers.stalingradThreshold = 70 -- Germans and Allies get flavor text for Stalingrad
specialNumbers.huskyInvasionThreshold = 140 -- Germans and Allies get flavor text that Operation Husky has commenced
specialNumbers.avalancheThreshold = 190 -- Germans and Allies get flavor text that Operation Shingle has commenced
specialNumbers.invadeItalyThreshold = 240 -- point value for Allies to be given tech 73
specialNumbers.medBomberReinforcements1 = 400 -- Allies receive 15th Air Force reinforcements
specialNumbers.medBomberReinforcements1Deadline =40
specialNumbers.medBomberReinforcements2 = 610 -- Allies receive 15th Air Force reinforcements
specialNumbers.medBomberReinforcements2Deadline =60
specialNumbers.medBomberReinforcements3 = 810 -- Allies receive 15th Air Force reinforcements
specialNumbers.medBomberReinforcements3Deadline =80
specialNumbers.medBomberReinforcements4 = 1100 -- Allies receive 15th Air Force reinforcements
specialNumbers.medBomberReinforcements4Deadline =100
specialNumbers.medBomberReinforcements5 = 1210 -- Allies receive 15th Air Force reinforcements
specialNumbers.medBomberReinforcements5Deadline =120
specialNumbers.newAlliedArmyGroup1 = 225 -- Allies receive another Battle Group
specialNumbers.newAlliedArmyGroup1Deadline = 25
specialNumbers.newAlliedArmyGroup2 = 450 -- Allies receive another Battle Group
specialNumbers.newAlliedArmyGroup2Deadline =50
specialNumbers.newAlliedArmyGroup3 = 675 -- Allies receive another Battle Group
specialNumbers.newAlliedArmyGroup3Deadline =72
specialNumbers.newAlliedArmyGroup4 = 900 -- Allies receive another Battle Group
specialNumbers.newAlliedArmyGroup4Deadline =95
specialNumbers.newAlliedArmyGroup5 = 1125 -- Allies receive another Battle Group
specialNumbers.newAlliedArmyGroup5Deadline =117
specialNumbers.newAlliedTaskForce1 = 299 -- Allies receive another Task Force
specialNumbers.newAlliedTaskForce1Deadline =30
specialNumbers.newAlliedTaskForce2 = 599 -- Allies receive another Task Force
specialNumbers.newAlliedTaskForce2Deadline =60
specialNumbers.newAlliedTaskForce3 = 899 -- Allies receive another Task Force
specialNumbers.newAlliedTaskForce3Deadline =90
specialNumbers.newAlliedTaskForce4 = 1199 -- Allies receive another Task Force
specialNumbers.newAlliedTaskForce4Deadline =120
specialNumbers.newGermanArmyGroup1 = 151 -- Germans receive another Battle Group
specialNumbers.newGermanArmyGroup1Deadline =110
specialNumbers.newGermanArmyGroup2 = 301 -- Germans receive another Battle Group
specialNumbers.newGermanArmyGroup2Deadline =110
specialNumbers.newGermanArmyGroup3 = 451 -- Germans receive another Battle Group
specialNumbers.newGermanArmyGroup3Deadline =110
specialNumbers.newGermanArmyGroup4 = 601 -- Germans receive another Battle Group
specialNumbers.newGermanArmyGroup4Deadline =110
specialNumbers.newGermanArmyGroup5 = 751 -- Germans receive another Battle Group
specialNumbers.newGermanArmyGroup5Deadline =110
specialNumbers.newGermanArmyGroup6 = 901 -- Germans receive another Battle Group
specialNumbers.newGermanArmyGroup6Deadline =110
specialNumbers.newGermanArmyGroup7 = 1051 -- Germans receive another Battle Group
specialNumbers.newGermanArmyGroup7Deadline =110
specialNumbers.newGermanArmyGroup8 = 1301 -- Germans receive another Battle Group
specialNumbers.newGermanArmyGroup8Deadline =110
specialNumbers.newGermanTaskForce1 = 401 -- Germans receive another Task Force
specialNumbers.newGermanTaskForce1Deadline =110
specialNumbers.newGermanTaskForce2 = 801 -- Germans receive another Task Force
specialNumbers.newGermanTaskForce2Deadline =110
specialNumbers.newGermanTaskForce3 = 1201 -- Germans receive another Task Force
specialNumbers.newGermanTaskForce3Deadline =110
specialNumbers.germansCanInvade = 1501 -- German task forces can transport units 
specialNumbers.kievThreshold = 503 -- Germans and Allies get flavor text discussing Soviet Operations
specialNumbers.korsunThreshold = 853 -- Germans and Allies get flavor text discussing Soviet Operations
specialNumbers.overlordThreshold = 1003 -- point value for Allies to be given tech 74
specialNumbers.vistulaOderThreshold = 1500 -- point value for Allies to be given tech 76 Won't be given until after DDay
specialNumbers.continentCitiesForVistulaOder = 8 -- Allies must control this many cities (not airbases) on the European Mainland (continent 10) as a condition for the Russian Front to Open
specialNumbers.germanCitiesForVistulaOder = 1 -- Allies must have this many German (not occupied) cities (see isGermanCity function) for the Russian Front to open up
specialNumbers.germanVictoryThreshold = 513 -- point value for a German Victory Text
specialNumbers.minimumGermanPoints = 0 -- If Germans start turn with less points, they get boosted to this
specialNumbers.defaultUrbanDefenseValue = 24
specialNumbers.AdvancedRadarIUrbanDefenseDrop = 2
specialNumbers.AdvancedRadarIIUrbanDefenseDrop = 2
specialNumbers.munitionVeteranChance = 0.5 -- chance of vet status if a unit's munition kills an enemy
specialNumbers.bomberReinforcement1Threshold = 106
specialNumbers.bomberReinforcement2Threshold = 206
specialNumbers.bomberReinforcement3Threshold = 306
specialNumbers.bomberReinforcement4Threshold = 406
specialNumbers.bomberReinforcement5Threshold = 506
specialNumbers.USAAFReinforcement1Threshold = 74
specialNumbers.USAAFReinforcement2Threshold = 154
specialNumbers.USAAFReinforcement3Threshold = 224
specialNumbers.USAAFReinforcement4Threshold = 304
specialNumbers.USAAFReinforcement5Threshold = 374
specialNumbers.USAAFReinforcement6Threshold = 454
specialNumbers.USAAFReinforcement7Threshold = 524
specialNumbers.GermanExperten1Threshold = 200
specialNumbers.GermanExperten2Threshold = 400
specialNumbers.GermanExperten3Threshold = 600
specialNumbers.GermanExperten4Threshold = 800
specialNumbers.GermanAce1Threshold = 157
specialNumbers.GermanAce2Threshold = 307
specialNumbers.GermanAce3Threshold = 457
specialNumbers.GermanAce4Threshold = 507
specialNumbers.GermanAce5Threshold = 657
specialNumbers.GermanAce6Threshold = 707
specialNumbers.GermanAce7Threshold = 857
specialNumbers.GermanAce8Threshold = 1007
specialNumbers.GermanAce9Threshold = 1157
specialNumbers.GermanAce10Threshold = 1307


specialNumbers.AlliedAce1Threshold = 152
specialNumbers.AlliedAce2Threshold = 302
specialNumbers.AlliedAce3Threshold = 452
specialNumbers.AlliedAce4Threshold = 502
specialNumbers.AlliedAce5Threshold = 652
specialNumbers.AlliedAce6Threshold = 702
specialNumbers.AlliedAce7Threshold = 852
specialNumbers.AlliedAce8Threshold = 1002
specialNumbers.AlliedAce9Threshold = 1152
specialNumbers.AlliedAce10Threshold = 1302
--specialNumbers.convoyArrivalSquare1 = {5,15,0}
--specialNumbers.convoyArrivalSquare2 = {2,66,0}
--specialNumbers.convoyArrivalSquare3 = {4,126,0}
specialNumbers.convoyArrivalBox1 = {xMin=1,xMax=7,yMin=1,yMax=13}
specialNumbers.convoyArrivalBox2 = {xMin=1,xMax=7,yMin=59,yMax=71}
specialNumbers.convoyArrivalBox3 = {xMin=1,xMax=7,yMin=105,yMax=117}
specialNumbers.trainsPerConvoy = 4
specialNumbers.unloadTrainsPerCivilImprovement = 2
specialNumbers.unloadTrainsForPort = 1
specialNumbers.baseFuelPerConvoy = 300 -- basic fuel per convoy unloaded (before military port reduction)
specialNumbers.convoyRefineryFuelBonus = 300 -- bonus fuel per refinery when unloading a convoy in a city
specialNumbers.penaltyForMissingAlliedPort = 100 -- fuel penalty if allies have less than specialNumbers.maxAlliedPorts when unloading a convoy
--specialNumbers.minDestroyerCost = 20 -- minimum rows for destroyer cost
--specialNumbers.minSubmarineCost = 10 -- minimum rows for submarine cost
--specialNumbers.paymentPerAlliedPort = 100
--specialNumbers.penaltyPerGermanPort = 100
specialNumbers.maxGermanPorts = 19
specialNumbers.maxAlliedPorts = 13
specialNumbers.extraUBoatLoss = 0 -- Counts as extra enemy cities when determining chance of u-boat returning to port.
specialNumbers.maxFriendlyFire = 0.25 -- Friendly fire damage can be at most this fraction of damage done to enemy (predicted) or unit won't react.  Set to 0 to never fire when friendly units could be caught in the crossfire.
specialNumbers.beachLandingMoves = 2 -- maximum movement a unit with beachUnloadPenalty Status can have after unloading from a ship
specialNumbers.maxMunitionDamageToArmyGroup = 15 -- Munitions can't damage Army Groups and Depleted Army Groups if they already have this much damage (8 damage might be increased to 12 damage before this kicks in, however, for example)
specialNumbers.armyGroupOccupationValue = 1 -- value in the german occupation score of having an army unit in france
specialNumbers.batteredArmyGroupOccupationValue = 1 -- value in germano occupation score of having a battered army group in france

specialNumbers.armyGroupOccupationPenalty = 2 -- reduction of occupation score for allied battle group in Franceo
specialNumbers.batteredArmyGroupOccupationPenalty = 0 -- reduction of occupation score for allied depleted battle groups in france
specialNumbers.occupationScoreTrain1Threshold = 3 -- minimum occupation score for first train
specialNumbers.occupationScoreTrain2Threshold = 6 
specialNumbers.occupationScoreTrain3Threshold = 9 
specialNumbers.occupationScoreTrain4Threshold = 12 
specialNumbers.occupationScoreTrain5Threshold = 15
specialNumbers.occupationScoreTrain6Threshold = 18
-- exclude possibility of 7 trains at the moment
specialNumbers.occupationScoreTrain7Threshold = 21 -- minimum occupation score for seventh train
specialNumbers.maxExtractionLevel = 6 -- maximum number of trains germany can attempt to extract from France
specialNumbers.occupationCityRevelationChance1Train = 0 -- chance a city in France will be revealed if the extraction value is 1 trains
specialNumbers.occupationCityRevelationChance2Train = 0.25 -- chance a city in France will be revealed if the extraction value is 2 trains
specialNumbers.occupationCityRevelationChance3Train = 0.75 -- chance a city in France will be revealed if the extraction value is 3 trains
specialNumbers.occupationCityRevelationChance4Train = 1 -- chance a city in France will be revealed if the extraction value is 4 trains
specialNumbers.occupationCityRevelationChance5Train = 1 -- chance a city in France will be revealed if the extraction value is 5 trains
specialNumbers.occupationCityRevelationChance6Train = 1 -- chance a city in France will be revealed if the extraction value is 6 trains
specialNumbers.occupationCityRevelationChance7Train = 1 -- chance a city in France will be revealed if the extraction value is 6 trains
specialNumbers.occupationAirfieldRevelationChance1Train = 0 -- chance an airfield in france will be revealed if the extraction value is 1 trains
specialNumbers.occupationAirfieldRevelationChance2Train = 0 -- chance an airfield in france will be revealed if the extraction value is 2 trains
specialNumbers.occupationAirfieldRevelationChance3Train = 0 -- chance an airfield in france will be revealed if the extraction value is 3 trains
specialNumbers.occupationAirfieldRevelationChance4Train = 0.1 -- chance an airfield in france will be revealed if the extraction value is 4 trains
specialNumbers.occupationAirfieldRevelationChance5Train = 0.25 -- chance an airfield in france will be revealed if the extraction value is 5 trains
specialNumbers.occupationAirfieldRevelationChance6Train = 0.35 -- chance an airfield in france will be revealed if the extraction value is 6 trains
specialNumbers.occupationAirfieldRevelationChance7Train = 0.35 -- chance an airfield in france will be revealed if the extraction value is 6 trains
specialNumbers.occupationFirefighterDestructionChance1Train = 0 -- chance a firefighters improvement will be destroyed if the extraction value is 1 trains
specialNumbers.occupationFirefighterDestructionChance2Train = 0 -- chance a firefighters improvement will be destroyed if the extraction value is 2 trains
specialNumbers.occupationFirefighterDestructionChance3Train = 0 -- chance a firefighters improvement will be destroyed if the extraction value is 3 trains
specialNumbers.occupationFirefighterDestructionChance4Train = 0 -- chance a firefighters improvement will be destroyed if the extraction value is 4 trains
specialNumbers.occupationFirefighterDestructionChance5Train = 0 -- chance a firefighters improvement will be destroyed if the extraction value is 5 trains
specialNumbers.occupationFirefighterDestructionChance6Train = 0.05 -- chance a firefighters improvement will be destroyed if the extraction value is 6 trains
specialNumbers.occupationFirefighterDestructionChance7Train = 0.05 -- chance a firefighters improvement will be destroyed if the extraction value is 6 trains

specialNumbers.trainliftCityExclusionRadius = 5 -- Enemy can't "trainlift" using rails within this many squares of an enemy city
specialNumbers.trainliftBattleGroupExclusionRadius = 3 -- enemy trainlifts can't use rails within this many squares of a full strength battle group
specialNumbers.trainliftDepletedBattleGroupExclusionRadius = 2 -- enemy trainlifts can't use rails within this many squares of a depleted battle group
specialNumbers.trainliftFixedCost = 50 -- base cost in gold for any trainlift
specialNumbers.trainliftCostPerTile = 2 -- cost for each tile traversed by trainlift

specialNumbers.ExpertenKilledMoney = -500
specialNumbers.refineryKilledMoney = -100
specialNumbers.moneySafeFromRefineryKill = 500 -- also safe from experten kill
specialNumbers.alliedReinforcementGermanPortPenalty = 0.5 -- Every time a depleted battle group is sent to Europe to reinforce Allied losses, this number is added to the number of German ports for the purposes of Battle of the Atlantic calculations.  1 port is roughly 1/2 train per turn
specialNumbers.alliedReinforcementDelay = 10
specialNumbers.uBoatBonusThreshold = 3 -- if Germany below this many uBoats/Wolf Packs, they will get uboats with the Hamburg critical industry
specialNumbers.uBoatBonusPerTurn = 1 -- Germany gets this many uBoat/Wolf Packs per turn, if they qualify for the bonus
specialNumbers.uBoatDeployDamage = 5 -- Uboats take this much damage if they deploy to the Atlantic using the Blohm und Voss special function (with backspace)
specialNumbers.bonusME109 = 1 -- If the Regensburg critical industry is active, every ME109 produced gets this many extra 109s given at the same time (fractional parts are probability, e.g. .8 means 80% chance of extra 109, 1.2 means 1, and 20% chance of second bonus
specialNumbers.fighterParity = 0.35 -- ME109s (best kind available) will be created for the Germans if their total fighter count is below this fraction of the Allied fighter count (certain planes may be excluded from the count)
specialNumbers.messerschmidtAirbaseLocation = {341,117,0} -- location of airbase where 109s appear if germany falls below the fighter threshold vs the allies
specialNumbers.aircraftRecoveryBonus = 20 -- this much damage is healed off an aircraft that spends its entire turn in an airfield, if the Schweinfurt critical industry is active
specialNumbers.turnsForFreePeenemundeTech = 10 -- Peenemunde critical industry gives a technology after this many turns elapse
specialNumbers.berlinFuelFraction = 0.5 -- if the Berlin critical industry is active, the Germans only pay this fraction of the regular fuel cost for aircraft operations
specialNumbers.minDayBombersAllies = 6 -- Allies will receive B17Fs if they have fewer than this number of bombers on the day maps
specialNumbers.minDayBomberTurnIncrement = 0.05 -- increases the minimum number of day bombers by this much per turn (rounded down)
specialNumbers.minNightBombersAllies = 6 -- Allies will receive Stirlings if they have fewer than this number of bombers on the night map
specialNumbers.minNightBomberTurnIncrement = 0.05 -- increases the minimum number of night bombers by this much per turn (rounded down) e.g. increase by 1 every 20 turns

local reinforcementLocations = {}
reinforcementLocations.AlliedBattleGroups = {{110,72,0},{139,65,0}, {140,44,0}, {137,11,0}}
reinforcementLocations.AlliedTaskForces = {{110,72,0},{139,65,0}, {140,44,0}, {137,11,0}}
reinforcementLocations.GermanBattleGroups = {{293,59,0},{299,63,0}, {324,50,0}, {347,55,0}}
reinforcementLocations.GermanTaskForces = {{293,59,0},{299,63,0}, {324,50,0}, {347,55,0}}
specialNumbers.baseFlightDistance = 40 -- attacks more than this many squares away from a friendly airbase will cost more, and will be scaled based on baseCost*distance/specialNumbers.baseFlightDistance (base cost is still the minimum)
specialNumbers.italyDistanceAddition = 30 -- for the distance modification of munitions costs, 15th AF and red tails add this many squares from the 'Italy' city
specialNumbers.rocketPointsTurns = 3 -- the Allies are penalized in gaining new points for this many turns after their urban target in England has been killed 
specialNumbers.rocketPointMultiplier = 0 -- Multiply allied point gains from killing targets by this amount if they are being penalized for having rockets attack. 
specialNumbers.firestormChance = 0.02 -- probability that a firestorm will start when an urban center is destroyed without the firefighter improvement in the city
specialNumbers.cloudExclusionRadius = 3 -- radius around a city to check for clouds for firestorm mechanic
specialNumbers.maximumClouds = 2 -- maximum number of clouds (on both high and night map) within the exclusion radius for which a firestorm can still happen
specialNumbers.occupiedFirestormGermanPointBounus = 200 -- number of points the Germans get if the Allies start a firestorm in an occupied city
specialNumbers.dayAttackFirefightersKillChance = 0.5 -- the chance that destroying a target on the day map will destroy the firefighters improvement in the city (Military Ports don't apply)
specialNumbers.alliedSabotageChance = .02 -- chance an allied industrial building will burn down on a given turn if no firefighters improvement
specialNumbers.occupiedSabotageChance = 0.05 -- chance an industrial building in an 'occupied' German city will burn down on a given turn if no firefighters improvement
specialNumbers.germanSabotageChance = 0.02 -- chance an industrial building in Germany proper will burn down on a given turn if no firefighters improvement 
--[[
specialNumbers.earliestAlliedInvasionDateIfDelays = 80 -- if Allies research delays, they can't invade before this date
specialNumbers.invasionDelayExtension = 10 -- subsequent Allied research of delays will postpone earliest invasion date by this many turns
specialNumbers.minInvasionDelay = 10 -- Allied invasion will be postponed at least this many turns from the current turn (e.g. if delays is researched on turn 75, invasion can't happen until turn 85, even if earliest date would otherwise be 80
--]]
specialNumbers.defaultSurvivalChance = 0.8 -- the default probability that a unit that will be killed by a munition will survive.  See overTwoHundred.unitSurvivalChance
specialNumbers.survivalHP = 3 -- the remaining hitpoints of a unit that survives a munition attack that under standard combat rules should have been fatal

local airWorkaround = true -- Set to false to remove the workaround for munition creation for air units


-- put all flag and counter initializations in this function
local function initializeFlagsAndCounters()
    createFlag("ConvoyZone1Calculated", false)
    createFlag("FrenchOccupationCalculated",false)
    createCounter("AlliedScore",0)
    createCounter("GermanScore",0)
    createCounter("SunkAlliedFreighters",0)
    createCounter("KillsOutsideEscortRange",0)
    createCounter("PeenemundeResearchTurns",specialNumbers.turnsForFreePeenemundeTech)
	createFlag("AfterProdTribe0NotDone",true)
    createFlag("AfterProdTribe1NotDone",true)
    createFlag("AfterProdTribe2NotDone",true)
    createFlag("AfterProdTribe3NotDone",true)
    createFlag("AfterProdTribe4NotDone",true)
    createFlag("AfterProdTribe5NotDone",true)
    createFlag("AfterProdTribe6NotDone",true)
    createFlag("AfterProdTribe7NotDone",true)
    createFlag("OperationGomorrahActive",false)
    createFlag("OperationGomorrahDiscovered",false)
    createFlag("OperationGomorrahComplete",false)
    createFlag("OperationGomorrahDoVictoryAllies",false)
    createFlag("OperationGomorrahDoFailureAllies",false)
    createFlag("OperationGomorrahDoVictoryGermans",false)
    createFlag("OperationGomorrahDoFailureGermans",false)
    createCounter("OperationGomorrahTimeRemaining",-1)
    createFlag("OperationChastiseActive",false)
    createFlag("OperationChastiseDiscovered",false)
    createFlag("OperationChastiseComplete",false)
    createFlag("OperationChastiseDoAftermathAllies",false)
    createFlag("OperationChastiseDoAftermathGermans",false)
    createCounter("OperationChastiseTimeRemaining", -1)
    createCounter("OperationChastiseDamsDestroyed",0)
    createFlag("OperationChastiseFirstDamDestroyedShowGermanMessage",false)
    createFlag("OperationChastiseSecondDamDestroyedShowGermanMessage",false)
    createFlag("OperationChastiseThirdDamDestroyedShowGermanMessage",false)
    createCounter("ChastiseTrainsToDivert",0)
    createFlag("SchweinfurtRegensburgActive",false)
    createFlag("SchweinfurtDiscovered",false)
    createFlag("SchweinfurtDoVictoryAllies",false)
    createFlag("SchweinfurtVictory",false)
    createFlag("SchweinfurtDoFailureAllies",false)
    createFlag("SchweinfurtDoVictoryGermans",false)
    createFlag("SchweinfurtDoFailureGermans",false)
    createFlag("RegensburgDiscovered",false)
    createFlag("RegensburgDoVictoryAllies",false)
    createFlag("RegensburgVictory",false)
    createFlag("RegensburgDoFailureAllies",false)
    createFlag("RegensburgDoVictoryGermans",false)
    createFlag("RegensburgDoFailureGermans",false)
    createFlag("SchweinfurtRegensburgComplete",false)
    createCounter("SchweinfurtRegensburgTimeRemaining",-1)
    createFlag("OperationHydraActive",false)
    createFlag("OperationHydraDiscovered",false)
    createFlag("OperationHydraComplete",false)
    createFlag("OperationHydraDoVictoryAllies",false)
    createFlag("OperationHydraDoFailureAllies",false)
    createFlag("OperationHydraDoVictoryGermans",false)
    createFlag("OperationHydraDoFailureGermans",false)
    createCounter("OperationHydraTimeRemaining",-1)
    createFlag("BattleOfBerlinActive", false)
    createFlag("BattleOfBerlinDiscovered",false)
    createFlag("BattleOfBerlinComplete",false)
    createFlag("BattleOfBerlinDoDelaysGermany",false)
    createFlag("BattleOfBerlinDoWorkersStrikeGermany",false)
    createFlag("BattleOfBerlinDoAlbertSpeerDeathGermany",false)
    createCounter("BattleOfBerlinTimeRemaining",-1)
    createFlag("OperationJerichoActive",false)
    createFlag("OperationJerichoDiscovered",false)
    createFlag("OperationJerichoComplete",false)
    createFlag("OperationJerichoDoVictoryAllies",false)
    createFlag("OperationJerichoDoFailureAllies",false)
    createFlag("OperationJerichoDoVictoryGermans",false)
    createFlag("OperationJerichoDoFailureGermans",false)
    createCounter("OperationJerichoTimeRemaining",-1)
    createFlag("OperationCarthageActive",false)
    createFlag("OperationCarthageDiscovered",false)
    createFlag("OperationCarthageComplete",false)
    createFlag("OperationCarthageDoVictoryAllies",false)
    createFlag("OperationCarthageDoFailureAllies",false)
    createFlag("OperationCarthageDoDisasterAllies",false)
    createFlag("OperationCarthageDoVictoryGermans",false)
    createFlag("OperationCarthageDoFailureGermans",false)
    createFlag("OperationCarthageDoDisasterGermans",false)
    createCounter("OperationCarthageTimeRemaining",-1)
    createFlag("StandardGame",true)
    setFlagTrue("StandardGame")
    createFlag("BigWeek",false)
    createFlag("NeverWarnAlliesAboutUpkeep",false)
    createFlag("NeverWarnGermansAboutUpkeep",false)
    createFlag("NoUpkeepWarningThisTurn",false)
    createFlag("NoUpkeepWarningThisSession",false)
    createCounter("UpkeepWarningTreasuryLevel",10000)
    createCounter("GermanAircraftKills",0)
    createCounter("RocketPointDelay",-1)-- start at -1, since 0 shows message
    createFlag("PlayingVersusSelf",false) -- flag to determine if the game is in 'play versus self' mode
    createCounter("FloatMoney",0)
    createFlag("GermansCanInvade",false) -- determines if German Task Forces can carry units
    createFlag("AlliesCanInvade",true) -- determines if Allied Task Forces can carry units
    createCounter("EarliestAlliedInvasionDate",0) -- determines the earliest date allied task forces can carry units
    
    createCounter("GermanExtractionLevel",1) -- number of trains the Germans extract from France each turn
end

initializeFlagsAndCounters()


--Defines the different tribes: need to verify this is correct order
local tribeAliases={}
tribeAliases.Allies = civ.getTribe(1)
tribeAliases.Germans = civ.getTribe(2)

----------------------------------------------------------------------------------------------------
local technologyAliases={}

----------------------------------------------------------------------------------------------------
local cityAliases={}
--g TO BE FILLED: ENTER CITY IDs FROM LUA CONSOLE!!!
-- You can generate the list of city IDs in the Lua console by writing:
--		for c in civ.iterateCities() do print(c.id, c.name) end

cityAliases.Berlin 			 = civ.getCity(0)
cityAliases.Dresden   		 = civ.getCity(1)
cityAliases.Prague			 = civ.getCity(2)
cityAliases.Vienna			 = civ.getCity(3)
cityAliases.Leipzig			 = civ.getCity(4)
cityAliases.Merseburg		 = civ.getCity(5)
cityAliases.Rostock			 = civ.getCity(6)
cityAliases.Luneburg		 = civ.getCity(7)
cityAliases.Hannover		 = civ.getCity(8)
cityAliases.Bremen			 = civ.getCity(9)
cityAliases.Wilhelmshaven	 = civ.getCity(10)
cityAliases.Dusseldorf		 = civ.getCity(11)
cityAliases.Cologne			 = civ.getCity(12)
cityAliases.Essen			 = civ.getCity(13)
cityAliases.Dortmund		 = civ.getCity(14)
cityAliases.Hamburg			 = civ.getCity(15)
cityAliases.Kiel			 = civ.getCity(16)
cityAliases.Lubeck			 = civ.getCity(17)
cityAliases.Nurnburg		 = civ.getCity(18)
cityAliases.Munich			 = civ.getCity(19)
cityAliases.Friedrichshaven	 = civ.getCity(20)
cityAliases.Schweinfurt		 = civ.getCity(21)
cityAliases.Frankfurt		 = civ.getCity(22)
cityAliases.Aaarhus			 = civ.getCity(23)
cityAliases.Freiburg		 = civ.getCity(24)
cityAliases.Karlsruhe		 = civ.getCity(25)
cityAliases.Mannheim		 = civ.getCity(26)
cityAliases.Stuttgart		 = civ.getCity(27)
cityAliases.Regensburg		 = civ.getCity(28)
cityAliases.Linz			 = civ.getCity(29)
cityAliases.Brest			 = civ.getCity(30)
cityAliases.StNazaire		 = civ.getCity(31)
cityAliases.Nantes			 = civ.getCity(32)
cityAliases.LaRochelle		 = civ.getCity(33)
cityAliases.Bordeaux		 = civ.getCity(34)
cityAliases.Cherbourg		 = civ.getCity(35)
cityAliases.LeHavre			 = civ.getCity(36)
cityAliases.Tours			 = civ.getCity(37)
cityAliases.Rouen			 = civ.getCity(38)
cityAliases.Paris			 = civ.getCity(39)
cityAliases.Brussels		 = civ.getCity(40)
cityAliases.Amsterdam		 = civ.getCity(41)
cityAliases.TheHague		 = civ.getCity(42)
cityAliases.Rotterdam		 = civ.getCity(43)
cityAliases.Antwerp			 = civ.getCity(44)
cityAliases.Lille			 = civ.getCity(45)
cityAliases.Calais			 = civ.getCity(46)
cityAliases.Lyon			 = civ.getCity(47)
cityAliases.Brunswick		 = civ.getCity(48)
cityAliases.Peenemunde		 = civ.getCity(49)
cityAliases.London           = civ.getCity(50)
cityAliases.Dover			 = civ.getCity(99)


-- Checks if a city is German (i.e. not an 'occupied' city)
local function isGermanCity(city)
    local germanCityList = {cityAliases.Berlin, cityAliases.Dresden, cityAliases.Vienna, cityAliases.Leipzig,
cityAliases.Merseburg		 ,
cityAliases.Rostock			 ,
cityAliases.Luneburg		 ,
cityAliases.Hannover		 ,
cityAliases.Bremen			 ,
cityAliases.Wilhelmshaven	 ,
cityAliases.Dusseldorf		 ,
cityAliases.Cologne			 ,
cityAliases.Essen			 ,
cityAliases.Dortmund		 ,
cityAliases.Hamburg			 ,
cityAliases.Kiel			 ,
cityAliases.Lubeck			 ,
cityAliases.Nurnburg		 ,
cityAliases.Munich			 ,
cityAliases.Friedrichshaven	 ,
cityAliases.Schweinfurt		 ,
cityAliases.Frankfurt		 ,
cityAliases.Freiburg		 ,
cityAliases.Karlsruhe		 ,
cityAliases.Mannheim		 ,
cityAliases.Stuttgart		 ,
cityAliases.Regensburg		 ,
cityAliases.Linz			 ,
cityAliases.Brunswick		 ,
cityAliases.Peenemunde		 ,}
    for __,listCity in pairs(germanCityList) do
        if city == listCity then
            return true
        end
    end
    return false
end

local improvementAliases = {}
improvementAliases.militaryPort = civ.getImprovement(34)
improvementAliases.civilianI = civ.getImprovement(4)
improvementAliases.civilianII = civ.getImprovement(11)
improvementAliases.civilianIII = civ.getImprovement(14)
improvementAliases.refineryI = civ.getImprovement(5)
improvementAliases.refineryII = civ.getImprovement(10)
improvementAliases.refineryIII = civ.getImprovement(22)
improvementAliases.cityI = civ.getImprovement(8)
improvementAliases.airbase = civ.getImprovement(17)
improvementAliases.jagdfliegerschule = civ.getImprovement(32)
improvementAliases.railyards = civ.getImprovement(25)
improvementAliases.criticalIndustry = civ.getImprovement(13)
improvementAliases.firefighters = civ.getImprovement(28)
-- returns true if the allies have captured enough cities to open
-- the Russian Front (they will also need points as well, not covered
-- in this function)
function overTwoHundred.enoughCitiesCapturedForRussianFront()
    local germanCitiesHeld = 0
    local continentCitiesHeld = 0
    local europeanContinent = 10
    for city in civ.iterateCities() do
        if city.owner == tribeAliases.Allies and city.location.landmass == europeanContinent and city:hasImprovement(improvementAliases.cityI) then
            continentCitiesHeld = continentCitiesHeld+1
        end
        if city.owner == tribeAliases.Allies and isGermanCity(city) and city:hasImprovement(improvementAliases.cityI) then
            germanCitiesHeld = germanCitiesHeld+1
        end
    end
    print(continentCitiesHeld,germanCitiesHeld)
    return continentCitiesHeld>= specialNumbers.continentCitiesForVistulaOder and germanCitiesHeld >= specialNumbers.germanCitiesForVistulaOder
end

function overTwoHundred.germanCriticalIndustryActive(city)
    if city.owner == tribeAliases.Germans and city:hasImprovement(improvementAliases.criticalIndustry) then
        return true
    else
        return false
    end
end

----------------------------------------------------------------------------------------------------
local terrainAliases = {}

----------------------------------------------------------------------------------------------------
local textAliases = {}
	
textAliases.freighterText = [[Allied freighters approach England...]]
textAliases.firstTurn1 = [[This scenario is dedicated to Amber.]]
textAliases.firstTurn2 = [[Prof. Garfield and I would like to extend our special thanks to everyone who helped us create the scenario, and specifically TheNamelessOne, Knighttime, Grishnach, Fairline, Tanelorn, Civinator, and McMonkey.]]
textAliases.firstTurn3 = [[May 30, 1942]]
textAliases.firstTurn4 = [["Operation Millennium" has begun.]]
textAliases.firstTurn5 = [[Over 1,000 aircraft from the Royal Air Force's Bomber Command approach the ancient city of Cologne.  The first of Arthur Harris' "1000 Bomber Raids," it is hoped that such massive attacks will dramatically shorten the war.]]

textAliases.testEngine = [[this shows this worked (engine failure)]]

textAliases.thirdTurn1 = [[American forces under VIII Bomber Command begin a slow buildup in England as elements of the command staff and the first few squadrons begin to arrive.]]
textAliases.thirdTurn2 = [[Despite the sound advice of their British allies, American planners are determined to pursue a strategy of daylight strategic bombing.  It is expected that a force of roughly 300 bombers should be sufficient to strike any target in Germany, unescorted.]]
textAliases.thirdTurn3 = [[This theory will soon be put to the test...]]

textAliases.firstGermanTurn1 = [[Europe has been consumed by war for nearly three years.]]
textAliases.firstGermanTurn2 = [[While the early victories of the Blitzkrieg are fading memories, hope for "der Endsieg" remains strong.]]
textAliases.firstGermanTurn3 = [[In the east, the Second Battle of Kharkov has just ended with the encirclment or destruction of 280,000 Russian soldiers.  This is a favorable prelude to the coming summer offensive, "Case Blue."]]
textAliases.firstGermanTurn4 = [[To the south, Panzerarmee Afrika has engaged the British 8th Army near Bir Hakeim, with an aim to drive towards Tobruk.  All reports indicate that Rommel may soon have another resounding victory to his credit.]]
textAliases.firstGermanTurn5 = [[In the Atlantic, our Wolf Packs continue to harry Allied shipping, and are positioned to inflict horrifying losses in the coming months.]]
textAliases.firstGermanTurn6 = [[In the air, the Luftwaffe remains confident and fully capable of defending the Reich.  We have long since forced the RAF to abandon daylight bombing raids.  Now, the foolish Americans desire the same lesson...]]

textAliases.FiftySixthFighterGroup = [[The 56th Fighter Group has arrived in Kings Cliffe AFB in England with a brand new compliment of P-47 fighters.]]
textAliases.B17Reinforcements = [[VIII Bomber Command's buildup in England continues with the arrival of several squadrons of heavy bombers.]]
textAliases.BomberCommandReinforcements = [[Despite growing opposition within the Air Staff, Arthur Harris successfully presses for the production of additional strategic bombers.  Several new RAF squadrons are now operational.]]
textAliases.EgonMayer = [[Hptm. Egon Mayer of III/JG2 "Richthofen" has risen to fame for his propensity for attacking heavy bombers, shooting three of the giants down in one sortie.  He is available for combat and can be found with the rest of his Gruppe at Beaumont Airfield near Normandy.]]
textAliases.JosefPriller =[[Josef "Pips" Priller, Kommodore of JG26 "Schlageter" has recorded his 100th kill, and as a result has been awarded the prestigious Ritterkreuz des Eisernen Kreuzes mit Eichenlaub, Schwertern und Brillanten.  He is available for combat and can be found near Berlin.]]
textAliases.AdolfGalland = [[Adolf Galland, the former General der Jagdflieger, has been permitted to form a special jet fighter unit, Jagdverband 44, a unit comprised entirely of the finest Experten of the Luftwaffe.  This special unit has all the advantages of a jet fighter, but can also defend itself exceptionally well, making it very difficult to destroy.  It is now operational at Brandenburg-Briest airfield, west of Berlin. ]]
textAliases.HermannGraf = [[Hermann Graf, a hero from the Eastern Front and the first pilot to claim 200 victories, has been allowed to resume operational flying.  He has formed JG50, a high-altitude unit equipped with specialized Me109s.  He is available for combat and can be found near Berlin. ]]
textAliases.hwSchnaufer = [[Heinz-Wolfgang Schnaufer will go on to become the highest scoring night fighter pilot of the war, with 121 victories before all is said and done.  He is now available for combat at St. Trond Airfield on the night map.  ]]

textAliases.EgonMayerKilled = [[Egon Mayer, Gruppenkommandeur of III/JG2 "Richthofen," has been killed in combat! This is a terrible blow to the Luftwaffe! Desperate to make up the loss, they increase pilot training at the cost of 500 fuel.   ]]
textAliases.JosefPrillerKilled = [[Josef Priller, Geschwaderkommodore of JG26 "Schlageter," has been killed in combat! This is a terrible blow to the Luftwaffe! Desperate to make up the loss, they increase pilot training at the cost of 500 fuel.   ]]
textAliases.HermannGrafKilled = [[Hermann Graf, the first pilot to claim 200 victories, has been killed in combat! This is a terrible blow to the Luftwaffe! Desperate to make up the loss, they increase pilot training at the cost of 500 fuel.   ]]
textAliases.hwSchnauferKilled = [[Heinz-Wolfgang Schnaufer, Kommodore of NJG 4, has been killed in combat! This is a terrible blow to the Luftwaffe! Desperate to make up the loss, they increase pilot training at the cost of 500 fuel.   ]]
textAliases.AdolfGallandKilled = [[Adolf Galland, one of Germany's most dashing Experten, has fallen in combat.  This is a tremendous blow to the Luftwaffe, and costs them 500 units of fuel.  ]]

textAliases.ExpertenArrival = [[Another Luftwaffe pilot has earned the prestigious title, "Experten," for his prowess in combat.  He is available for combat near Berlin.]]

textAliases.secondTurn1 = [[Over the Reich takes advantage of lua scripting in several exciting ways that you should be aware of.]]
textAliases.secondTurn2 = [[Each turn, all of your heavy flak (88mm and 3.7-inch guns) will be fortified unless they are within two spaces of an enemy aircraft.  This is done to reduce the time it takes to play each turn.  If you were moving one of these units, you will want to go find it so you can unfortify it and move it towards its destination.]]
textAliases.secondTurn3 = [[Your heavy flak units that are near enemy aircraft will warn you that a raid is incoming by day or night.  Press 'k' to fire flak bursts at daylight targets, and press 'backspace' to fire them at nighttime targets.]]
textAliases.secondTurn4 = [[You are also able to scan the skies with all of your radar sets at once.  To do so, select any radar set and press 'backspace.'  It is recommended that you do this first thing each turn to help you identify enemy targets.]]
textAliases.secondTurn5 = [[It is also important to remember that bomb-carrying aircraft in Over the Reich have a limited payload and can only strike once per sortie.  Once they drop bombs, their home city will be set to "NONE."  To rearm them, you must re-home them.  Units with "NONE" for a home city cannot drop bombs.]]
textAliases.secondTurn6 = [[Aircraft that are activated within an airfield will automatically have their home city changed from "NONE" to that airfield, as long as the airfiled can support it.  It is important, however, to note that this only occurs if the game AUTOMATICALLY activates the unit.  In other words, you cannot enter the city screen and activate the unit manually--the game must cycle to that unit for this change to take effect.  Thus, if you are preparing to launch a bomber raid, and wish to manually select the lead bomber, you must change its home city manually before setting off on your sortie.]]

textAliases.thirdGermanTurn1 = [[Many Luftwaffe pilots greet the news of the Americans' arrival with gloom.  The Luftwaffe Chief of Staff Hans Jeschonnek, however, is less than impressed, stating: "Every four-engine bomber the Allies build makes me happy, for we will bring these four-engine bombers down just like we brought down the two-engine ones, and the destruction of a four-engine bomber constitutes a much greater loss to the enemy..."]]
textAliases.thirdGermanTurn2 = [[...It is widely whispered that he knows better, but makes this boast to keep favor with Hitler and Goering.]]

textAliases.flyingFortress1 = [[Seeing the B-17 in action, General der Jagdflieger, Adolf Galland, commented that the aircraft held "every possible advantage in one bomber: first, heavy armor; second, enormous altitude; third, colossal defensive armament; fourth, great speed."  These qualities combine to make the aircraft exceptionally difficult to destroy, and many are able to limp home despite tremendous damage.]]

textAliases.bomberText1 = [[General der Jagdflieger, Adolf Galland, sends the following memo detailing effective tactics against American heavy bombers to all Luftwaffe fighter units:]]
textAliases.bomberText2 = [["Attacks from the rear on close formations are seldom successful and bring heavy losses.  If it is necessary to attack from the rear, fire at engines and fuel tanks from a steep bank."]]
textAliases.bomberText3 = [["Attacks from the side can be effective.  These require training and a good firing angle."]]
textAliases.bomberText4 = [["Front attacks at low speed from straight ahead, above, or below are the most effective of all attacks.  Prerequisites for success are flying skill, good aim, and continuous fire up to the closest possible distance."]]
textAliases.bomberText5 = [["Withdrawal is permitted only by a tight diving bank in the direction of flight of the attacked bomber.  This maximizes the angular velocity and makes it impossible for the enemy gunners to draw the correct lead."]]
textAliases.bomberText6 = [["It is essential that the fighter units attack repeatedly in great strength and mass.  The defensive fire will then be dispersed and the bomber formation can be split apart."]]

textAliases.foggiaText1 = [[Allied forces capture a series of airbases in the province of Foggia, Italy.  The 15th Air Force can now commence operations from the south.]]
textAliases.foggiaText2 = [[For now, the 15th Air Force will have to undertake their missions without escort, but there is word that an experimental African-American unit, the 332nd Fighter Group, is due to eventually receive long-range escort aircraft.]]
textAliases.foggiaText3 = [[NOTE: The Allies cannot land any English-based aircraft in Italy, or vice versa.  Any attempt to do so will result in the deletion of the unit. There are no "shuttle runs" in this scenario.]]

textAliases.medBomberReinforcements = [[The 15th Air Force receives reinforcements.]]

textAliases.overlordText1 = [[Operation Pointblank, the Allied effort to destroy the Luftwaffe has been proceeding very well.  Allied High Command now feels that an invasion of the Continent can succeed.]]
textAliases.overlordText2 = [[It is now time to prepare for "Operation Overlord," the invasion of Western Europe.  Landing craft have been made available to ferry our troops across the sea.  Preparations should be made to gather our naval assets into an armada to liberate the old world.]]
textAliases.overlordText3 = [[While the exact location of the invasion is up to you, General, it is suggested that we land somewhere in France or the Low Countries.  An attempt to end the war early by landing in the Baltic would likely be far too risky.]]
textAliases.overlordText4 = [[We must land in force.  If the Germans throw our invasion into the sea, we will lose all support for the war at home and will need to seek terms.]]

textAliases.vistulaText1 = [[The Red Army's Vistula-Oder Offensive has carried them through Poland and to the edge of the Oder River, some 43 miles from Berlin.  Russian units now join this scenario!]]
textAliases.vistulaText2 = [[NOTE: The Allies cannot land any English- or Italian-based aircraft in Russia, or vice versa.  Any attempt to do so will result in the deletion of the unit. There are no "shuttle runs" in this scenario.]]

textAliases.stalingradAlliedText = [[Our Soviet Allies report that they have encircled and destroyed the German Sixth Army at Stalingrad, taking 235,000 prisoners in the process.]]
textAliases.stalingradGermanText = [[Disaster at Stalingrad! The Sixth Army has been completely destroyed! Generalfeldmarschall Friedrich Paulus becomes the highest ranking German officer ever to be captured! All of our gains from the summer offensive have been eradicated, as our surviving forces struggle to regroup!]]

textAliases.huskyAlliedText = [[The invasion of Sicily, "Operation Husky," has been a success.  150,000 Allied soldiers hit several beaches along the southern shores of the island, supported by 3,000 ships and 4,000 aircraft.  Strong winds dispersed much of the initial assault, but also gave the Allies the element of surprise, as no invasion was thought possible in such conditions.  A follow-up invasion of Italy is expected shortly, with the aim of securing airfields in Italy.]]
textAliases.huskyGermanText = [[The Allies have landed in Sicily! We were caught completely by surprise as powerful winds made an invasion appear impossible.  Our forces are struggling to hold on in the face of overwhelming Allied air superiority! While Sicilian airfields pose no danger to the Reich, should the Allies capture bases in Italy proper, our southern front will require air defenses!]]

textAliases.avalancheAlliedText = [[Elements of General Mark W. Clark's Fifth Army and General Bernard Montgomery's British Eighth Army have landed in Italy near Salerno, Calabria and Taranto!  Luftwaffe resistance was heavy, with Admiral Hewitt reporting, "Air situation here critical" as eighty-five Allied vessels were hit by German bombs near Salerno.  Nonetheless, the Allies managed to secure a beachhead with plans of pushing ever further into the Boot!]]
textAliases.avalancheGermanText = [[The Allies have landed in Italy near Salerno, Calabria and Taranto! Though the Luftwaffe responded ferociously, the invasion has succeeded and the Allies are firmly entrenched in Italy.  It is only a matter of time before they secure the airfields in the Foggia region, and directly threaten the Reich!]]

textAliases.kievAlliedText = [[The Soviets report that they have liberated Kiev! Their armies march forward!]]
textAliases.kievGermanText = [[Kiev has fallen in the wake of a huge Soviet offensive.  Thankfully, our forces were able to preserve the rail link with Army Group Center, and Army Group South has escaped destruction.  With that said, we are in a fighting retreat and all hope of regaining the initiative in the east appears lost.]]

textAliases.korsunAlliedText = [[The Soviets have launched a massive offensive against the German Army Group South, with the aim of retaking all of Ukraine and Moldavia.  The Stavka has committed four Fronts to the battle, significantly outnumbering the Germans.]]
textAliases.korsunGermanText =  [[The Soviets have launched a massive operation against Army Group South! Erich von Manstein will have his hands full attempting a dynamic defense, especially since Hitler has recently ordered that all available reinforcements head west to guard against the imminent Anglo-American invasion!]]

textAliases.DDayText = [[The Allied invasion of the continent, "Operation Neptune," has begun!  After years of planning, the fate of humanity rests on the brave Allied soldiers.  It is imperative that this invasion succeed.  If the Allies do not hold a port city on the coast between Bordeaux and Hamburg, their soldiers on the Continent will be unable to resupply and will be forced to surrender.  If the Allies suffer such an embarrasing defeat, the world "will sink into the abyss of a new dark age made more sinister, and perhaps more protracted, by the lights of perverted science." ]]
textAliases.secondFrontText1 = [[The Allies have crossed the channel in force! The initial attack took us by surprise, and it has been difficult to mount an effective counter-offensive as the skies are filled with Allied fighters.  We must move forces to oppose the invasion at once! If we can throw them back into the sea, they will never recover! If they are allowed to remain in Europe, our defeat is only a matter of time!]]

--old DDayText
--[[The Allied invastion of the continent, "Operation Neptune," has begun! After years of planning, the fate of humanity rest on the brave Allied soldiers.  It is imperative that this invasion succeed.  If it is repulsed in the next 10 turns, the Allies will suffer an embarrasing defeat, and the world "will sink into the abyss of a new dark age made more sinister, and perhaps more protracted, by the lights of perverted science."]]
textAliases.AlliedLoss = [[German defenders lead by Erwin Rommel have managed to repulse the Allied invasion of "Fortress Europe."  The failure is a mortal blow to Allied resolve.  FDR suffers a stroke at the news and Churchill is chased from office after his involvement in yet another disasterous adventure.  Their successors sue for favorable terms with Germany.  Britain will keep her fleet and independence in exchange for an Allied withdrawal from Italy.  Though the Russians carry on, the war in the west is officially lost."]]

textAliases.germanCityCapture1=[[The Germans have driven the Allies out of ]]
textAliases.germanCityCapture2=[[.  If they can capture all the port cities between Bordeaux and Hamburg, all Allied forces in Western Europe will be forced to surrender.  Such a catastrophic defeat might lead to a negotiated peace between Germany and the Western Allies.]]

textAliases.DDayInBaltic1=[[The Western Allies capture the Baltic city of ]]
textAliases.DDayInBaltic2=[[.  With resupply so difficult, a single setback could cause morale among the invaders to collapse and an entire army to surrender.  The Western Allies would be well advised to quickly capture a port nearer to England.]]

textAliases.airMunitions = [[Aircraft cannot load munitions if they have only 1 movement point remaining.]]

textAliases.primaryPayloadUsed = [[This unit has already expended the payload for its primary attack.  In Over the Reich, some attacks can only be made once per sortie.  When this unit uses its primary attack, its home city is set to NONE, and it must be homed to a city before it can use its primary attack again.]]

textAliases.secondaryPayloadUsed = [[This unit has already expended the payload for its secondary attack.  In Over the Reich, some attacks can only be made once per sortie.  When this unit uses its secondary attack, its home city is set to NONE, and it must be homed to a city before it can use its secondary attack again.]]

textAliases.nightAirfieldCapture = [[A midnight raid on an airfield by ground forces is defeated by the daytime security personnel. Some raiders escape with fuel and documents.  Airfields must be captured on the daytime map.]]

textAliases.defaultMunitionsFailure = [[This unit created 0 munitions in this attack]]

textAliases.AlliedPoliticalSupport = [[Allied High Command has been persuaded to put more resources into the Air War.  ]]..tostring(specialNumbers.PoliticalSupportMoneyBonus)..[[ units of fuel have been diverted from other fronts.]]

textAliases.GermanPoliticalSupport = [[The Fuhrer has been persuaded to put more resources into the Air War.  ]]..tostring(specialNumbers.PoliticalSupportMoneyBonus)..[[ units of fuel have been diverted from other fronts.]]

textAliases.heavyBomberLosses = [[German fighters have inflicted such heavy losses on Allied bombers that Allied High Command concedes the need for a long range escort fighter.  Funds and research personnel are authorized for this purpose.]]

textAliases.germanPointsVictory = [[After unsustainable losses in the air, on the high seas, and in their cities, the war weary British make peace with Germany, leaving the Soviets to their fate.  The Americans turn their attention to Japan.  The German player has won the game.]]

textAliases.noAirfieldsInSouthFrance = [[The High Command of the Luftwaffe has rejected a defence in depth, and insists that no new airfields be built in Southern France]]

textAliases.roamAtWillA = [[Destroying the Luftwaffe fighter force is our main objective.  James Doolittle makes an announcement at a staff meeting, that is quite unpopular with bomber pilots: "The figher role of protecting the bomber formations should not be minimized, but our fighter aircraft should be encouraged to meet the enemy and destroy him rather than be content to keep him away."]]
textAliases.roamAtWillB = [[Doolittle would later recount, "As soon as my decision was announced to the bomb groups, their commanders descended on me ... to tell me, in polite terms, of course, that I was a 'killer' and a 'murderer' ... There was no compromise as far as I was concerned, and many bomber crews remained very unhappy.  Some still are."]]

textAliases.Fw190D9Text = [[The latest in the 190 series, the Fw190D9 or "Dora," remedies the long-standing high-altitude performance issues.  You will find this is an excellent interceptor, more than capable of holding its own at any alt.]]

textAliases.wunderWaffenText = [[Despite Albert Speer's best efforts, the Reich has no hope to match the production capabilities of the United States.  We must instead focus on technological miracle weapons to turn the tide of war.  Our Wunderwaffe program will one day allow us to field jet and rocket fighters to defend our skies, as well as terrible vengeance weapons to strike back at England and force their capitulation!]]

textAliases.wildeSauText = [[We now have the ability to transfer our air forces from day to night operations and vice versa.  This will give us a considerable advantage over the Allies, as we can concentrate forces when and where needed.  Beware, however, that mismatched aircraft will struggle with reactive interceptions, and are considerably more vulnerable.  They are better utilized for direct attacks when flying at unfamiliar times.]]

-- special target text
-- Text box title for allied special target orders
textAliases.alliedSpecialTargetBoxTitle = [[Special Orders]]
-- This is the text box title for the german player when a special
-- target has been revealed to the Germans
textAliases.germanSpecialTargetRevealedBoxTitle = [[Air Defence Report]]
-- This is the title of the text box describing the results of special target missions
textAliases.specialTargetResultsBoxTitleAllies = [[Mission Results Report]]
textAliases.specialTargetResultsBoxTitleGermans = [[Air Defence Report]]

specialNumbers.gomorrahHalifaxes = 10
textAliases.gomorrahText1=[[OPERATION GOMORRAH]]
textAliases.gomorrahText2=[[Arthur Harris has ordered Bomber Command to prepare for a massive strike at Hamburg. It is hoped that a ferocious strike will cause German morale to collapse, ending the war.]]
textAliases.gomorrahText3=tostring(specialNumbers.gomorrahHalifaxes)..[[ Halifax bombers have been deployed to Ridgewell Airfield to support this attack. You have 8 turns to destroy the target at 317,57,2. Failure will embolden our enemy and they will receive substantial supplies.]]

textAliases.gomorrahDiscoveredText =[[The skies over Hamburg have been filled with enemy bombers! Fires are raging throughout the city and overwhelming our firefighters! We must scramble the Nachtjagdflieger to fend off the RAF before the city is completely destroyed!]]

textAliases.gomorrahSucceedsAlliesText1= [[Operation Gomorrah has been a frightening success worthy of its namesake. Days of bone-dry conditions coupled with overextension of the city's firefighters creates a recipe for disaster as a massive firestorm essentially destroys. Over 40,000 Germans lose their lives as a quarter million homes are destroyed. The scene is like something from the apocalypse. Civilians attempt to flee down the streets only to get stuck in the melting asphalt and boiled alive. The fires consume oxygen at such a rate that hurricane-force winds rip through the streets, as the stonework of buildings glowed red as the Devil's furnace.]]

textAliases.gomorrahSucceedsAlliesText2=[[The German high command is reportedly aghast at the destruction, with more than one top figure privately conceding that a few more strikes of this magnitude may force Germany out of the war.]]

textAliases.gomorrahSucceedsGermansText1 = [[Hamburg has been reduced to ashes by an Allied bombing raid over the past several nights.  42,600 civilians have been killed, a further 37,000 badly wounded.  Half the homes and apartments in the city were completely destroyed.]]

textAliases.gomorrahSucceedsGermansText2 = [[It was a thundering, blazing hell.  Survivors report horrifying tales of people stuck on all fours in the melted asphalt of roadways, screaming in pain as their lungs fill with fire...  We sowed the wind at Guernica, Rotterdam, and Coventry...  Now the whirlwind we reap has a terrifying name: firestorm.]]

specialNumbers.gomorrahFailsMoney=10000
textAliases.gomorrahFailsAlliesText1=[[Arthur Harris' dream of ending the war through area bombing has been dealt a great blow as "Operation Gomorrah" is an embarrassing failure.  Far from destroying German war capacity, a few schools and hospitals are the only large buildings destroyed, bringing very bad press to Harris and the Allies.]]

textAliases.gomorrahFailsGermansText1=[[German intelligence learns that the Luftwaffe has thwarted a major planned aerial assault on Hamburg. Hitler is so pleased with the victory that he pledges more resources to the Reichsverteidigung - ]]..tostring(specialNumbers.gomorrahFailsMoney)..[[ fuel points are siphoned from other fronts to strengthen the defense of the Reich.]]

specialNumbers.chastiseLancasters = 6
textAliases.chastiseText1=[[OPERATION CHASTISE]]
textAliases.chastiseText2=[[Orders have been received to target three dams in Germany southeast of the Ruhr.  ]]..tostring(specialNumbers.chastiseLancasters)..[[ Lancaster bomber units have been made available for the mission in addition to anything else you can muster. Destroying these dams will have a profound effect on German industry. Failure to destroy any dams will likely embolden our enemies.]]

textAliases.chastiseDiscoveredText=[[The British are attempting to destroy our dams southeast of the Ruhr.  Much damage will be done if they are successful.  We must send some night fighters to bolster our defences there.]]

specialNumbers.secondDamTrainsDiverted = 5
specialNumbers.thirdDamTrainsDiverted = 10

textAliases.firstDamDestroyedAlliedMessage = [[We've received a report that one of the dams targeted in "Operation Chastise" has been destroyed.  This will undoubtedly force the Germans to send many construction crews to the area to make repairs.]]

textAliases.firstDamDestroyedGermanMessage = [[We've just received a report that British bombers have destroyed an important dam.  Orders have already been sent to construction crews to converge on the site to repair the damage.]]

textAliases.secondDamDestroyedAlliedMessage = [["Operation Chastise" is looking like a success.  Aircrews have reported that a second dam was destroyed in the raid.  We expect that the Germans will have to divert substantial resources away from air defenses.]]
textAliases.secondDamDestroyedGermanMessage = [[We've received word that the British have destroyed a second dam.  We expect to divert ]]..tostring(specialNumbers.secondDamTrainsDiverted)..[[ trains of production away from air defense to help offset the damage.]]



textAliases.thirdDamDestroyedAlliedMessage = [[The preliminary reports for "Operation Chastise" are looking very good.  Aircrews have reported all three dams destroyed.  An official results report will be made next turn.]]
textAliases.thirdDamDestroyedGermanMessage = [[This is shaping up to be a bad night.  We've received word that the British have destroyed a third dam.  It looks like we'll have to divert ]]..tostring(specialNumbers.thirdDamTrainsDiverted)..[[ additional trains of production away from air defenses.  You will receive a full damage report shortly.]]

textAliases.newAlliedArmyGroupReinforcements = [[The Allied build up in England continues as another Battle Group arrives, ready for duty.]]
textAliases.newAlliedTaskForceReinforcements = [[Allied shipyards churn out another Task Force ready to defend the high seas.]]

textAliases.newGermanArmyGroupReinforcements = [[Another Battle Group has been formed, ready to defend the Reich!]]
textAliases.newGermanTaskForceReinforcements = [[German shipyards churn out another Task Force ready to challenge the Allies for naval superiority!]]


specialNumbers.chastiseZeroDamsMoney = 5000
textAliases.chastiseZeroDamsAlliesText=[["Operation Chastise" has failed to do any significant damage to any of the dams targeted. German propaganda has a field day mocking the Allied failure. Given the impressive defense by the Luftwaffe, additional supplies are made available for the Reich's defense.  (The German player will receive ]]..tostring(specialNumbers.chastiseZeroDamsMoney)..[[ additional fuel.)]]
textAliases.chastiseZeroDamsGermansText=[[The Allied attempts to destroy several dams has failed.  The loons attempted a low-level night attack with a few heavy bombers.  Some nights, they can barely hit a city with a thousand! As idiotic as the attacks were, they've provided us with a great propaganda opportunity - ]]..tostring(specialNumbers.chastiseZeroDamsMoney).. [[ fuel points are spared by the public in the latest fuel ration to strengthen the defense of the Reich.]]
textAliases.chastiseOneDamAlliesText=[["Operation Chastise" was partially successful as one of the three dams targeted was destroyed. This will divert German construction crews away from other activities.]]
textAliases.chastiseOneDamGermansText=[[We've suffered a minor setback last night as the Allies managed to destroy one of several dams they targeted.  We have had to send all our construction crews to the dam site to make the necessary repairs.]]
textAliases.chastiseTwoDamsAlliesText=[["Operation Chastise" is hailed as a success as two of the three dams targeted were destroyed.  Not only have the Germans been forced to divert construction crews from other projects to make the repairs, we believe they've also been forced to divert ]]..tostring(specialNumbers.secondDamTrainsDiverted)..[[ trains of war material away from air defense.]]
textAliases.chastiseTwoDamsGermansText=[[We've suffered a moderate setback last night as the Allies managed to destroy two of several dams they targeted.  We been forced to send all our construction crews to fix the dams, and ]]..tostring(specialNumbers.secondDamTrainsDiverted)..[[ trainloads of war material have been diverted from air defenses as well.]]
textAliases.chastiseThreeDamsAlliesText=[["Operation Chastise" is a smashing success! All three dams targeted by No. 617 Squadron RAF "Dambusters" have been destroyed. This is a significant blow to German production.  Not only have they been forced to divert all their construction crews to dam repair, we also believe they've been forced to divert ]]..tostring(specialNumbers.secondDamTrainsDiverted+specialNumbers.thirdDamTrainsDiverted)..[[ trainloads of war material away from air defense.]]
textAliases.chastiseThreeDamsGermansText=[[We've suffered a major setback last night as the Allies managed to destroy three dams they targeted.  We've been forced to send all our construction crews to fix the dams, and ]]..tostring(specialNumbers.secondDamTrainsDiverted+specialNumbers.thirdDamTrainsDiverted)..[[ trainloads of war material have been diverted from air defenses as well.]] 

specialNumbers.schweinfurtB17F = 12

textAliases.schweinfurtText1=[[SCHWEINFURT AND REGENSBURG]]

textAliases.schweinfurtText2=[[Orders have been received to target a series of ball bearing factories at Schweinfurt with a secondary attack to the Messerschmidt Factory at Regensburg. It is believed that successfully destroying these targets, and in particular the ball bearing factories, will have a profound effect on the German war effort. ]]..tostring(specialNumbers.schweinfurtB17F)..[[ B-17F units have been made available for this raid, plus whatever other forces you can muster.]]

textAliases.schweinfurtDiscovered=[[The Americans are attacking our ball bearing plants at Schweinfurt.  We could face a severe industrial bottleneck if the plant is destroyed before we can stockpile a reserve.]]

textAliases.regensburgDiscovered=[[The Americans are attacking the Messerschmidt Factory at Regensburg.  If the factory suffers too much damage, we will have to retool.]]

textAliases.schweinfurtVictoryTextAllies=[[The raid on Schweinfurt is a tremendous success and validates the American's confidence in daylight strategic bombing. The bottleneck caused by the shortage of ball bearings is exceptionally damaging to the German war effort. Their industrial technologies have been removed and they must reacquire them before they can build new factories until they have done so (factories currently being built are the exception). We should follow up this success by hitting their industry hard!]]
textAliases.schweinfurtVictoryTextGermans=[[The Allies have dealt us a crippling blow by severely damaging a series of critical ball bearing factories near Schweinfurt.  The affect on our industry is astronomical.  We will be unable to build new industries or rebuild destroyed ones until we research our industrial technologies over again.]]

textAliases.regensburgVictoryTextAllies=[[Our raid on the Messerschmidt factory at Regensburg was successful. Germany will now have to retool to continue producing the latest 109s (airfields already producing these are an exception).]]
textAliases.regensburgVictoryTextGermans=[[The Allies have destroyed a major Messerschmidt plant near Regensburg, destroying all plans for the design.  Although airfields that are currently building Me109 variants can continue to do so, we will not be able to build the design at new airfields until we research the appropriate technologies again.  This will also delay more advanced models.]]

textAliases.schweinfurtFailureTextAllies = [[The raid on Schweinfurt is a disaster. Emboldened by their success in bringing down the bombers, the Germans invest in more interceptors.]]
specialNumbers.schweinfurtFailureMoney=2500
textAliases.schweinfurtFailureTextGermans=[[The Luftwaffe has had tremendous success against a recent Allied raid against Schweinfurt, shooting down an incredible number of the "fat cars."  The Allies can't possibly keep up with these losses! Even so, the daring high-altitude raid convinces the Luftwaffe High Command that more high-altitude interceptors are necessary.  Hermann Graf, hero of the Eastern Front and first pilot to claim 200 victories has been charged with forming JG 50, a high-altitude squadron equipped with specialized Me109s.  He is available near Regensburg.  ]]..tostring(specialNumbers.schweinfurtFailureMoney)..[[ units of fuel are also diverted to air defense purposes.  Unfortunately, despite the success, the day also brings the sad news that Adolf Galland's brother, Wilhelm-Ferdinand "Wutz" Galland, was shot down and killed by P-47 fighters.]]

textAliases.regensburgFailureTextAllies=[[Our raid failed to destroy the Messerschmidt factory at Regensburg. Local resistance reports that several advanced 109s have left the factory and are being fitted for combat a nearby airfield.]]

specialNumbers.regensburgFailureMoney = 2500
textAliases.regensburgFailureTextGermans=[[We've shot down 60 bombers headed for Regensburg, and successfully defended the major Messerschmidt plant housed there.  This was good fortune, as this has allowed several advanced Me109 variants to leave the production line.  ]]..tostring(specialNumbers.regensburgFailureMoney)..[[ extra units of fuel has also been provided for air defense.]]


specialNumbers.hydraLancasters = 3
specialNumbers.hydraHalifaxes = 3
textAliases.hydraText1=[[OPERATION HYDRA]]

textAliases.hydraText2=[[Orders have been received for Bomber Command to target the ]]..cityAliases.Peenemunde.name..[[ Army Research Center.  ]]..tostring(specialNumbers.hydraLancasters)..[[ Lancaster and ]]..tostring(specialNumbers.hydraHalifaxes)..[[ Halifax bombers have been made available for this raid, along with any other forces you can muster.]]

textAliases.hydraDiscoveredText=[[The British are targeting the ]]..cityAliases.Peenemunde.name..[[ Army Research Center.  Our research will be delayed if the facility suffers too much damage.]]

textAliases.hydraVictoryTextAllies=[[Our raid against the ]]..cityAliases.Peenemunde.name..[[ Army Research Center was successful! This will delay the Germans' research efforts!]]
textAliases.hydraVictoryTextGermans=[[An Allied bombing raid has heavily damaged our ]]..cityAliases.Peenemunde.name..[[ Army Research Center.  This will cause significant research and development delays.]]
textAliases.hydraFailureTextAllies=[[Our raid against the ]]..cityAliases.Peenemunde.name..[[ Army Research Center has failed! German research is accelerated and new terror weapons are undergoing testing!]]
textAliases.hydraFailureTextGermans=[[We have successfully defended the ]]..cityAliases.Peenemunde.name..[[ Army Research Center from Allied air attack.  Our research efforts will accelerate as a result! The Fuhrer is deeply angered by this attack against our research facility and demands retribution.  Our engineers have scrambled to place our V2 rockets into production.  A V2 Launch site has been established within striking range of England, at tile %STRING1.]]

specialNumbers.battleOfBerlinLength = 50
textAliases.berlinText1=[[THE BATTLE OF BERLIN]]

textAliases.berlinText2=[[Arthur Harris has ordered a sustained campaign against the enemy capital, Berlin. For the next ]]..tostring(specialNumbers.battleOfBerlinLength)..[[ turns, it will be a primary target for Bomber Command. Each strike will have a chance to inflict crippling damage.]]

textAliases.berlinDiscovered=[[Intelligence suggests that the Allies plan to attack Berlin with frequency over the coming months.  We should increase our air defenses around the capital.]]

textAliases.berlinDelaysTextAllies=[[Angered at the ongoing assault on the capital, and despite the objections of the Jagdwaffe who plea for more fighters, Hitler orders additional research into bombers and other vengeance weapons to launch reprisals! As a result, German military research has been halted, and all "science beakers" reset to zero.]]

textAliases.berlinDelaysTextGermans=textAliases.berlinDelaysTextAllies



textAliases.workersStrikeTextAllies=[[Disenchanted by the Luftwaffe's inability to protect the capital, German workers everywhere are less industrious.  Specialists have now been reset, causing confusion and delays, and will need to be reestablished, if desired.]]
textAliases.workersStrikeTextGermans=textAliases.workersStrikeTextAllies

textAliases.albertSpeerDeathTextAllies=[[Allied bombs have struck a mortal blow to Germany tonight as Albert Speer was one of the casualties. The architect of important reforms, German war industry will never recover from his death.  The Albert Speer's Reforms wonder is now obsolete.]]

textAliases.albertSpeerDeathTextGermans=textAliases.albertSpeerDeathTextAllies

specialNumbers.jerichoTyphoons = 4
textAliases.jerichoText1= [[OPERATION JERICHO]]
textAliases.jerichoText2= [[We have received an urgent request from the French resistance movement to target the prison at Amiens (200,90,0). 100 prisoners there are scheduled to be executed tomorrow. Their only hope is an airstrike to break them free. While it will likely kill some of the prisoners, they will certainly die tomorrow.  ]]..tostring(specialNumbers.jerichoTyphoons)..[[ Typhoon fighter bombers have been appropriated for this task. God speed!]]
textAliases.jerichoVictoryTextAllies= [[Operation Jericho succeeds! Of the 717 prisoners, 102 were killed in the attack, 74 wounded, and 258 escaped, including 79 Resistance and political prisoners! The escape of these prisoners emboldens the Resistance and several railyards throughout the region are destroyed!]]
textAliases.jerichoVictoryTextGermans=[[The Allies have pulled off a plucky raid in broad daylight as several of their fighter bombers attacked Amiens Prison, freeing several of the Maquis held there.  Though we've managed to recapture many, the country side has erupted in partisan activity, with several railyards destroyed.]]

textAliases.jerichoFailureTextGermans=[[The Allies have failed in their ambitious effort to destroy the prison at Amiens.  They should leave such bold undertakings to the likes of Otto Skorzeny and not a bunch of amateurs.  Our spies report that local resistance has lost heart, allowing for an increase in freight train economic activity.]]
textAliases.jerichoFailureTextAllies= [[We have failed in our mission to free the prisoners of Amiens Prison. As a result, 100 Resistance members have been put to death.]]

specialNumbers.carthageLancasters = 6
textAliases.carthageText1= [[OPERATION CARTHAGE]]
textAliases.carthageText2= [[The Danish resistance has repeatedly requested that we target the Gestapo headquarters in Copenhagen - the 'Shellus.' Now, it is finally time to strike. You have 7 turns to destroy the target at 352,36,2 (night map).  ]] .. tostring(specialNumbers.carthageLancasters) .. [[ Lancaster units have been appropriated for this mission.]]
textAliases.carthageVictoryTextAllies= [[Operation Carthage succeeds! The attack on the Gestapo headquarters frees several prisoners of the Danish resistance movement! Local railyards are destroyed in the resulting increase in resistance activity.]]
textAliases.carthageVictoryTextGermans=[[Those dastardly Allies have struck a blow to the Gestapo in Copenhagen by destroying their headquarters.  This has emboldened resistance activity as several local railyards have been destroyed.]]
textAliases.carthageDisasterTextAllies= [[While Operation Carthage does destroy the Gestapo headquarters in Copenhagen, several of our bombers mistakenly target a school, killing 86 school children. There is an increase in Resistance attacks on local railyards, but the political fallout will have to be dealt with, delaying other endeavors.]]
textAliases.carthageDisasterTextGermans=[[It appears that the Allies intended to attack our Gestapo headquarters in Copenhagen, but their bombs have instead destroyed a local school, killing 86 children.  Our Propaganda Ministry will make good use of their sacrifice.]]
textAliases.carthageFailureTextAllies= [[We were unable to destroy the Gestapo headquarters in Copenhagen. As a result, local Resistance is less effective, and there has been an increase in German rail activity.]]
textAliases.carthageFailureTextGermans=[[Our spies report that an Allied attempt to destroy the Gestapo headquarters in Copenhagen has failed.  Our counter-partisan efforts will continue unhindered, allowing for greater freight train economic activity.]]
textAliases.carthageDiscovered = [[British bombers appear to be targeting the Gestapo headquarters in Copenhagen.  If successful, partisan activity in Denmark is likely to increase.]]

if specialNumbers.rocketPointMultiplier == 0 then
textAliases.rocketPolitics = [[Casualties are mounting from the German 'Vengeance Weapon' attacks.  Winston Churchill has ordered that stopping these attacks be made top priority.  We will not gain any points when we destroy strategic targets until %STRING1 or we kill a V1 or V2 Launch Site.]]
else
textAliases.rocketPolitics = [[Casualties are mounting from the German 'Vengeance Weapon' attacks.  Winston Churchill has ordered that stopping these attacks be made top priority.  We will only gain ]]..tostring(math.floor(specialNumbers.rocketPointMultiplier*100))..[[% of our regular points when we destroy strategic targets until %STRING1 or we kill a V1 or V2 Launch Site.]]
end
textAliases.launchSiteDestroyed = [[Destroying this %STRING1 should reduce civilian casualties in Britain.  We have convinced the politicians to restore our normal operational latitude.  We now gain full points from all targets.]]
textAliases.rocketPenaltyExpired = [[Since no Urban Centers have been destroyed by 'Vengeance Weapons' recently, we have been able to convince the politicians to restore our normal operational latitude.  We now gain full points from all targets.]]

textAliases.attackerFirestormText = [[Our attack against %STRING1 has overwhelmed the city's firefighting capabilities and has started a massive firestorm that has burnt down most of the city.]]

textAliases.defenderFirestormText = [[A recent %STRING2 attack against %STRING1 has overwhelmed the city's firefighters capabilities and a massive firestorm has burnt down most of the city.  Casualty figures are still unknown.]]

textAliases.firestormInOccupiedCityAllies = [[DISASTER! Our attack against %STRING1 has started a firestorm killing an unknown but very large number of civilians.  Our prestige in Occupied Europe has declined substantially, and the Germans have gained ]]..tostring(specialNumbers.occupiedFirestormGermanPointBounus)..[[ points.]]

textAliases.firestormInOccupiedCityGermans = [[For reasons unknown, the Allies have started a massive firestorm in %STRING1.  We're gaining more sympathisers in the occupied territories by the hour as news of this wanton attack spreads.  We have gained ]]..tostring(specialNumbers.occupiedFirestormGermanPointBounus)..[[ points.]]

textAliases.alliedMessageForAlliedFactoryFire = [[Enemy agents have taken advantage of our inadequate fire protection to burn down the %STRING1 in %STRING2.]]

textAliases.germanMessageForAlliedFactoryFire = [[Our saboteurs have taken advantage of inadequate enemy fire protection to burn down the %STRING1 in %STRING2.]]

textAliases.alliedMessageForOccupiedFactoryFire = [[Resistance members have taken advantage of German indifference to fire protection in occupied cities to burn down the %STRING1 in %STRING2.]]

textAliases.germanMessageForOccupiedFactoryFire = [[Resistance members have taken advantage of inadequate fire protection and burned down the %STRING1 in %STRING2.]]

textAliases.alliedMessageForGermanFactoryFire = [[Our saboteurs have taken advantage of inadequate enemy fire protection to burn down the %STRING1 in %STRING2.]]

textAliases.germanMessageForGermanFactoryFire = [[Enemy agents have taken advantage of our inadequate fire protection to burn down the %STRING1 in %STRING2.]]


textAliases.AlliedRAFAce = [[A daring pilot from the RAF has scored his 5th kill, earning the coveted "Ace" status.  He arrives ready for duty at Boxted.]]
textAliases.AlliedUSAAFAce = [[A daring pilot from the USAAF has scored his 5th kill, earning the coveted "Ace" status.  He arrives ready for duty at Duxford.]]
----------------------------------------------------------------------------------------------------
local recruitmentUnitTypes = {
	["Freighter unloads Tanks"] = { unitType=civ.getUnitType(115), unitRecruited=civ.getUnitType(75), allowedTerrain={0}, movementCostOfRecruitment=function (state) end, moneyCostOfRecruitment=-1000, regionOfRecruitment_Xmin=0, regionOfRecruitment_Xmax=406, regionOfRecruitment_Ymin=0, regionOfRecruitment_Ymax=144, conditionMet=function (state) return true end, displayText="American freighters reach England, offloading tanks and supplies for the coming invasion!"  }

}

----------------------------------------------------------------------------------------------------
--[[
local unitAliases = {}
-- Targets
unitAliases.Railyard			= civ.getUnitType(7)
unitAliases.MilitaryPort		= civ.getUnitType(19)
unitAliases.Industry1			= civ.getUnitType(45)
unitAliases.Industry2			= civ.getUnitType(46)
unitAliases.Industry3			= civ.getUnitType(47)
unitAliases.ACFactory1			= civ.getUnitType(85)
unitAliases.ACFactory2			= civ.getUnitType(86)
unitAliases.ACFactory3			= civ.getUnitType(87)
unitAliases.Refinery1			= civ.getUnitType(88)
unitAliases.Refinery2			= civ.getUnitType(89)
unitAliases.Refinery3			= civ.getUnitType(90)
unitAliases.Urban1				= civ.getUnitType(91)
unitAliases.Urban2				= civ.getUnitType(92)
unitAliases.Urban3				= civ.getUnitType(93)
unitAliases.V1Launch			= civ.getUnitType(121)
unitAliases.V2Launch			= civ.getUnitType(122)
unitAliases.SpecialTarget       = civ.getUnitType(109)


-- Ammo
unitAliases.Photos				= civ.getUnitType(8)
unitAliases.Hispanos			= civ.getUnitType(77)
unitAliases.FiftyCal			= civ.getUnitType(95)
unitAliases.TwentyMM			= civ.getUnitType(96)
unitAliases.ThirtyMM			= civ.getUnitType(97)
unitAliases.TwoHundredFiftylb	= civ.getUnitType(98)
unitAliases.FiveHundredlb		= civ.getUnitType(99)
unitAliases.Thousandlb			= civ.getUnitType(100)
unitAliases.Window				= civ.getUnitType(101)
unitAliases.A2ARockets			= civ.getUnitType(103)
unitAliases.FlakD				= civ.getUnitType(104)
unitAliases.Flak                = civ.getUnitType(104)
unitAliases.RadarD				= civ.getUnitType(106)
unitAliases.Radar               = civ.getUnitType(106)
unitAliases.Barrage             = civ.getUnitType(114)
--unitAliases.WurzburgN			= civ.getUnitType(109)
unitAliases.Torpedo				= civ.getUnitType(110)
-- p.g. type 110 now Defensive Fire
--unitAliases.DefensiveFire = civ.getUnitType(110)
-- Set transporter setting.  Can probably be removed after a game is saved after the script is loaded, but it should not hurt to keep it
--unitAliases.DefensiveFire.nativeTransport = 0 (I could not get this to work - JPP)

unitAliases.USAAFAce			= civ.getUnitType(112)
unitAliases.RAFAce			    = civ.getUnitType(113)
unitAliases.TwelveInch			= civ.getUnitType(114)
unitAliases.LightFlak			= civ.getUnitType(116)
unitAliases.V1					= civ.getUnitType(123)
unitAliases.V1.nativeTransport = 0
unitAliases.V2					= civ.getUnitType(124)

-- 'K' Units (ones which fire ammo)
unitAliases.EarlyRadar			= civ.getUnitType(3)
unitAliases.AdvancedRadar		= civ.getUnitType(4)
unitAliases.Fw200				= civ.getUnitType(5)
unitAliases.Sdkfz				= civ.getUnitType(9)
unitAliases.GermanFlak			= civ.getUnitType(10)
unitAliases.FlakTrain			= civ.getUnitType(11)
unitAliases.Me109G6				= civ.getUnitType(12)
unitAliases.Me109G14			= civ.getUnitType(13)
unitAliases.Me109K4				= civ.getUnitType(14)
unitAliases.Fw190A5				= civ.getUnitType(15)
unitAliases.Fw190A8				= civ.getUnitType(16)
unitAliases.Fw190D9				= civ.getUnitType(17)
unitAliases.Ta152				= civ.getUnitType(18)
unitAliases.Me110				= civ.getUnitType(20)
unitAliases.Me410				= civ.getUnitType(21)
unitAliases.Ju88C				= civ.getUnitType(22)
unitAliases.Ju88G				= civ.getUnitType(23)
unitAliases.He219				= civ.getUnitType(24)
unitAliases.He162				= civ.getUnitType(25)
unitAliases.Me163				= civ.getUnitType(26)
unitAliases.Me262				= civ.getUnitType(27)
unitAliases.Ju87G				= civ.getUnitType(28)
unitAliases.Fw190F				= civ.getUnitType(29)
unitAliases.Do335				= civ.getUnitType(30)
unitAliases.Do217				= civ.getUnitType(31)
unitAliases.He277				= civ.getUnitType(32)
unitAliases.Arado234			= civ.getUnitType(33)
unitAliases.Go229				= civ.getUnitType(34)
unitAliases.SpitfireIX			= civ.getUnitType(35)
unitAliases.SpitfireXII			= civ.getUnitType(36)
unitAliases.SpitfireXIV			= civ.getUnitType(37)
unitAliases.HurricaneIV			= civ.getUnitType(38)
unitAliases.Typhoon				= civ.getUnitType(39)
unitAliases.Tempest				= civ.getUnitType(40)
unitAliases.Meteor				= civ.getUnitType(41)
unitAliases.Beaufighter			= civ.getUnitType(42)
unitAliases.MosquitoII			= civ.getUnitType(43)
unitAliases.MosquitoXIII		= civ.getUnitType(44)
unitAliases.P47D11				= civ.getUnitType(50)
unitAliases.P47D25				= civ.getUnitType(51)
unitAliases.P47D40				= civ.getUnitType(52)
unitAliases.P38H				= civ.getUnitType(54)
unitAliases.P38J				= civ.getUnitType(55)
unitAliases.P38L				= civ.getUnitType(108)
unitAliases.P51B				= civ.getUnitType(56)
unitAliases.P51D				= civ.getUnitType(57)
unitAliases.P80					= civ.getUnitType(58)
unitAliases.Stirling			= civ.getUnitType(59)
unitAliases.Halifax				= civ.getUnitType(60)
unitAliases.Lancaster			= civ.getUnitType(61)
unitAliases.Pathfinder			= civ.getUnitType(62)
unitAliases.A20					= civ.getUnitType(63)
unitAliases.B26					= civ.getUnitType(64)
unitAliases.A26					= civ.getUnitType(65)
unitAliases.B17F				= civ.getUnitType(66)
unitAliases.B24J				= civ.getUnitType(67)
unitAliases.B17G				= civ.getUnitType(68)
unitAliases.EgonMayer			= civ.getUnitType(71) 
unitAliases.AlliedFlak			= civ.getUnitType(72)
unitAliases.He111				= civ.getUnitType(73)
unitAliases.Sunderland			= civ.getUnitType(76)
unitAliases.HermannGraf			= civ.getUnitType(78)
unitAliases.JosefPriller		= civ.getUnitType(79) 
unitAliases.AdolfGalland		= civ.getUnitType(80) 
unitAliases.GermanTaskForce		= civ.getUnitType(81)
unitAliases.AlliedTaskForce		= civ.getUnitType(82)
unitAliases.RedTails			= civ.getUnitType(83)
unitAliases.MedBombers			= civ.getUnitType(84)
unitAliases.FifteenthAF         = civ.getUnitType(84)
unitAliases.GunBattery			= civ.getUnitType(94)
unitAliases.Yak3				= civ.getUnitType(117)
unitAliases.Il2					= civ.getUnitType(118)
unitAliases.Ju188				= civ.getUnitType(120)
unitAliases.MossiePR			= civ.getUnitType(125)
unitAliases.Freighter			= civ.getUnitType(115)-- Should eventually search for this and remove/update
unitAliases.Convoy  			= civ.getUnitType(115)
unitAliases.GermanLightFlak		= civ.getUnitType(119)
unitAliases.AlliedLightFlak		= civ.getUnitType(2)
unitAliases.Carrier				= civ.getUnitType(111)
unitAliases.damagedB17F			= civ.getUnitType(105)
unitAliases.damagedB17G			= civ.getUnitType(107)
unitAliases.UBoat				= civ.getUnitType(126)
unitAliases.hwSchnaufer			= civ.getUnitType(102)
unitAliases.Experten			= civ.getUnitType(53)

-- Other Units
unitAliases.FreightTrain        = civ.getUnitType(6)
unitAliases.Schutzen            = civ.getUnitType(69)-- Should eventually search for this and remove/update
unitAliases.GermanArmyGroup     = civ.getUnitType(69)
unitAliases.Panzers             = civ.getUnitType(70) -- Should eventually search for this and remove/update reference
unitAliases.GermanBatteredArmyGroup   = civ.getUnitType(70)
unitAliases.RedArmyGroup        = civ.getUnitType(0)
unitAliases.AlliedArmyGroup     = civ.getUnitType(74)
unitAliases.AlliedBatteredArmyGroup = civ.getUnitType(75)
unitAliases.constructionTeam    = civ.getUnitType(1)
unitAliases.neutralTerritory = civ.getUnitType(106)
--]]



-- I need the function to run when units are activated, in order to use after the 
-- unit:activate() function, but I don't want to move the entire code here,
-- since that code also references other functions
local doOnActivateUnit = nil

local function runDoOnActivateUnit()
    doOnActivateUnit(civ.getActiveUnit(),true)
end


-- p.g. Indexed by unittype id.  If entry is true, the unit can use the carrier.  If missing or false, the unit can't.
-- Any carrier must also be in this list, with entry true
-- munitions also use carrier, to ensure carrier is not air stack protected by its cargo
-- munition use is set in the function, not in this table.
local useCarrier = {}
useCarrier[unitAliases.Carrier.id] = true
useCarrier[unitAliases.SpitfireIX.id] = true
useCarrier[unitAliases.SpitfireXII.id] = true
useCarrier[unitAliases.SpitfireXIV.id] = true
useCarrier[unitAliases.HurricaneIV.id] = true
useCarrier[unitAliases.Me109G6.id] = true
useCarrier[unitAliases.Me109G14.id] = true
useCarrier[unitAliases.Me109K4.id] = true
useCarrier[unitAliases.Ju87G.id] = true
useCarrier[unitAliases.HermannGraf.id] = true

local rearmOnCarrier ={}
rearmOnCarrier[unitAliases.Ju87G.id] = true
rearmOnCarrier[unitAliases.HurricaneIV.id] = true

-- allows carrier based payload aircraft to rearm without
-- returning to an airbase
local function rearmCarrierUnit(unit)
    if not rearmOnCarrier[unit.type.id] or unit.homeCity then
        return
    else
        for unitOnTile in unit.location.units do
            if unitOnTile.type == unitAliases.Carrier then
                unit.homeCity = unitOnTile.homeCity
                return
            end
        end
    end
end



----------------------------------------------------------------------------------------------------
-- Defines certain ammunition to be deleted at the end of each turn, so it doesn't stack up
local unitTypesToBeDeletedEachTurn =
	{ 8, 77, 95, 96, 97, 98, 99, 100, 103, 104, 110, 114, 116, 124,unitAliases.Window.id }
local unitTypesWhichCanBeDestroyedWithoutMovementReduction =
	{ 8, 77, 95, 96, 97, 98, 99, 100, 101, 103, 104, 106, 110, 114, 116, 124 }

-- Defines aircraft that should not be able to land in city squares or different theatre squares (Italian Theatre and Russian Front)
--First one is aircraft that can't land anywhere except an airbase city
--Second is for Italian Theatre aircraft
--Third is for Russian Front aircraft
--local cannotLandCityItalyRussia =
	--{ 5, 12, 13, 14, 15, 16, 17, 18, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 73, 76, 120, 125 }



--local cannotLandCityRussia = 
--	{ 83, 84 }
	
--local cannotLandCityItaly = 
--	{ 96, 99 }

---------------------------------------------------------------------------------------------------
local function moveToAdjacent(unit)
    local function findSafeTile(center)
        local offsets = {{0,2},{1,1},{2,0},{1,-1},{0,-2},{-1,-1},{-2,0},{-1,1}}
        for __,offset in pairs(offsets) do
            local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
            if t and (t.defender == nil or t.defender==center.defender) then
                return t
            end
        end
        -- This means there is no empty or friendly tile adjacent to the unit to be moved.
        -- Will have to move a stack of enemy units to make room, so must search for a tile
        -- without strategic targets and move all those units
        local unitDestination = nil
        local enemyDestination = nil
        local enemyGroundUnits = false
        for __,offset in pairs(offsets) do
            local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
            if t then
                local noTargetSoFar = true
                for tileUnit in t.units do
                    if tileUnit.type == unitAliases.Railyard	or tileUnit.type == unitAliases.MilitaryPort	
                    or tileUnit.type == unitAliases.Industry1 or tileUnit.type == unitAliases.Industry2
                    or tileUnit.type == unitAliases.Industry3 or tileUnit.type == unitAliases.ACFactory1
                    or tileUnit.type == unitAliases.ACFactory2 or tileUnit.type == unitAliases.ACFactory3
                    or tileUnit.type == unitAliases.Refinery1 or tileUnit.type == unitAliases.Refinery2
                    or tileUnit.type == unitAliases.Refinery3 or tileUnit.type == unitAliases.Urban1
                    or tileUnit.type == unitAliases.Urban2 or tileUnit.type == unitAliases.Urban3
                    or tileUnit.type == unitAliases.V1Launch or tileUnit.type == unitAliases.V2Launch
                    or tileUnit.type == unitAliases.SpecialTarget	then
                        noTargetSoFar = false
                        break
                    end
                end
                if noTargetSoFar then
                    unitDestination = t
                    for tileUnit in t.units do
                        if tileUnit.domain == 0 then
                            enemyGroundUnits = true
                            break
                        end
                    end
                    break
                end
            end
        end
        if unitDestination == nil then
            -- case where all surrounding squares have a target
            return false
        end
        for __,offset in pairs(offsets) do
            local t = civ.getTile(unitDestination.x+offset[1],unitDestination.y+offset[2],unitDestination.z)
            if t and (t.defender == nil or t.defender == unitDestination.defender) and (not enemyGroundUnits or not(t.terrainType % 16 == 10)) then
                enemyDestination = t
                break
            end
        end
        if enemyDestination == nil then
            -- case where no room for ground units (very unlikely), just move to an ocean square,
            -- this has to be possible, since original unit was surrounded by enemies
            for __,offset in pairs(offsets) do
                local t = civ.getTile(unitDestination.x+offset[1],unitDestination.y+offset[2],unitDestination.z)
                if t and (t.defender == nil or t.defender == unitDestination.defender) then
                    enemyDestination = t
                    break
                end
            end
        end
        for tileUnit in unitDestination.units do
            civ.teleportUnit(tileUnit,enemyDestination)
        end
        return unitDestination       
    end
    local destination=findSafeTile(unit.location)
    if destination == false then
        -- this means all adjacent squares have enemy targets
        civ.ui.text("The "..unit.type.name.." at ("..tostring(unit.location.x)..","..tostring(unit.location.y)..","..tostring(unit.location.z)..") is surrounded by strategic targets and cannot, therefore, be moved.  It has been deleted.")
        civ.deleteUnit(unit)
        return
    end
    civ.teleportUnit(unit,destination)
    return
end

----------------------------------------------------------------------------------------------------
-- FUNCTIONS and DATA for MUNITION QUANTITY FUNCTIONS

local healthMunitionQuantityTable = {
["B17F"] = {unitType = unitAliases.B17F, healthTable = {{.3,1},}},
["B17G"] = {unitType = unitAliases.B17G, healthTable = {{.3,1},{.7,1}}},
["B24J"] = {unitType = unitAliases.B24J, healthTable = {{.3,1},}},
["He111"] = {unitType = unitAliases.He111, healthTable = {{.3,1},}},
["Do217"] = {unitType = unitAliases.Do217, healthTable = {{.3,1},{.7,1}}},
["He277"] = {unitType = unitAliases.He277, healthTable = {{.3,1},{.7,1}}},
["Stirling"] = {unitType = unitAliases.Stirling, healthTable = {{.3,1},}},
["Halifax"] = {unitType = unitAliases.Halifax, healthTable = {{.3,1},{.7,1}}},
["Lancaster"] = {unitType = unitAliases.Lancaster, healthTable = {{.3,1},{.7,1}}},
["A20"] = {unitType = unitAliases.A20, healthTable = {{.5,1},}},
["B26"] = {unitType = unitAliases.B26, healthTable = {{.5,1},}},
["A26"] = {unitType = unitAliases.A26, healthTable = {{.5,1},{.7,1}}},
["MedBombers"] = {unitType = unitAliases.MedBombers, healthTable = {{.3,1},{.7,1}}},
["Pathfinder"] = {unitType = unitAliases.Pathfinder, healthTable = {{.3,3},{.6,3},{.9,3}}}

-- B17G produces 1 munition by default.  If unit has more than 30% health, give it an extra munition
-- if it has more than 70% health, give it an extra munition


}
local function healthMunitionQuantity(unitCreatingMunition,munitionTypeBeingCreated,munitionDestination)
    local fractionHealth = unitCreatingMunition.hitpoints/unitCreatingMunition.type.hitpoints
    local quantity = 1
    local refTable = healthMunitionQuantityTable
    local unitInRefTable = false
    for __,unitInfo in pairs(refTable) do
        if unitCreatingMunition.type == unitInfo.unitType then
            unitInRefTable = true
            for ___,thresholdTable in pairs(unitInfo.healthTable) do
                if fractionHealth >= thresholdTable[1] then
                    quantity= quantity + thresholdTable[2]
                end
            end
        end
    end
    local defaultHealthTable = {{.5,1}} -- this is the default for any unit specifying quantity = healthMunitionQuantity
    if not(unitInRefTable) then
        for ___,thresholdTable in pairs(defaultHealthTable) do
            if fractionHealth >= thresholdTable[1] then
                quantity=quantity+thresholdTable[2]
            end
        end
    end
    return quantity
end

-- RANGED ATTACKS ('k' Units)

-- p.g. 
-- optional settings
--.nightMunition=unittype 
-- fires specified munition if firing unit is on the night map
--
-- .quantity = integer or function(unitCreatingMunition,munitionTypeBeingCreated,munitionDestination) -> integer
-- unitCreatingMunition is type unit, munitionTypeBeingCreated is type unittype, munitionDestination is type tile
-- specifies the quantity of the munition to be created

-- .quantityNight = integer
-- overrides quantity if the munition destination is on the night map

-- .altMap = integer
-- creates munition on map given by .altMap

-- .munitionFailText
-- text to be displayed if quantity of munitions created happens to be 0
-- textAliases.defaultMunitionsFailure is the default message

--.payload=boolean (absent means payload=nil and is treated like false)
--If payload=true is set, then the unit can only conduct its primary attack if it has a home city, and conducting the primary attack will set the home city to NONE
-- .vetOverride = boolean or unitType (absent means nil, same as false
-- If true, veteran units of this type do not produce veteran munitions
-- If a unitType, veteran units produce this type of munition (non vet)
-- The nightMunition unit type overrides this if a unitType is chosen, and the night munition will not be vet.
--
-- .lowAltNoAttack=boolean (absent means nil, same as false)
-- if .lowAltNoAttack=true, the unit can't call up munitions on the low altitude daylight map (map 0)
local artilleryUnitTypes = {
--	["EarlyRadar"] = { unitType=civ.getUnitType(3), munitionCreated=civ.getUnitType(106), allowedTerrain={7, -121}, movementCostOfMunition=2, moneyCostOfMunition=0, displayText=nil },
--	["WurzburgRadar"] = { unitType=civ.getUnitType(4), munitionCreated=civ.getUnitType(108), allowedTerrain={7, -121}, movementCostOfMunition=2, moneyCostOfMunition=0, displayText=nil },
	["GermanFlak"] = { unitType=civ.getUnitType(10), munitionCreated=civ.getUnitType(104), allowedTerrain={0,7, -121, -128,6,4,8,9,12,13,14}, movementCostOfMunition=1, moneyCostOfMunition=0, displayText=nil, altMap = 1 },
	["AlliedFlak"] = { unitType=civ.getUnitType(72), munitionCreated=civ.getUnitType(104), allowedTerrain={0,7, -121, -128,6,4,8,9,12,13,14}, movementCostOfMunition=1, moneyCostOfMunition=0, displayText=nil, altMap = 1 },
	["V1Launch"] = { unitType=civ.getUnitType(121), munitionCreated=civ.getUnitType(123), allowedTerrain={7, -121}, movementCostOfMunition=4, moneyCostOfMunition=50, displayText=nil, altMap = 2 },
	["V2Launch"] = { unitType=civ.getUnitType(122), munitionCreated=civ.getUnitType(124), allowedTerrain={7, -121}, movementCostOfMunition=4, moneyCostOfMunition=75, displayText=nil, altMap = 2 },
	["FlakTrain"] = { unitType=civ.getUnitType(11), munitionCreated=civ.getUnitType(104), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114}, movementCostOfMunition=5, moneyCostOfMunition=0, displayText=nil, altMap = 1 },
	["Sdkfz"] = { unitType=civ.getUnitType(9), munitionCreated=civ.getUnitType(116), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114}, movementCostOfMunition=4, moneyCostOfMunition=0, displayText=nil },
	["Me109G6"] = { unitType=civ.getUnitType(12), munitionCreated=civ.getUnitType(95), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=10, moneyCostOfMunition=5, displayText=nil },
	["Me109G14"] = { unitType=civ.getUnitType(13), munitionCreated=civ.getUnitType(95), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=11, moneyCostOfMunition=5, displayText=nil },
	["Me109K4"] = { unitType=civ.getUnitType(14), munitionCreated=civ.getUnitType(95), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=12, moneyCostOfMunition=5, displayText=nil },
	["Fw190A5"] = { unitType=civ.getUnitType(15), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=10, moneyCostOfMunition=5, displayText=nil },
	["Fw190A8"] = { unitType=civ.getUnitType(16), munitionCreated=civ.getUnitType(77), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=11, moneyCostOfMunition=5, displayText=nil },
	["Fw190D9"] = { unitType=civ.getUnitType(17), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=12, moneyCostOfMunition=5, displayText=nil },
	["Ta152"] = { unitType=civ.getUnitType(18), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=13, moneyCostOfMunition=5, displayText=nil },
	["Me110"] = { unitType=civ.getUnitType(20), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=16, moneyCostOfMunition=5, displayText=nil, payload=true, },
	["Me410"] = { unitType=civ.getUnitType(21), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=18, moneyCostOfMunition=5, displayText=nil,  quantity=2, payload=true, },
	["Ju88C"] = { unitType=civ.getUnitType(22), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=11, moneyCostOfMunition=10, displayText=nil },
	["Ju88G"] = { unitType=civ.getUnitType(23), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=12, moneyCostOfMunition=10, displayText=nil },
	["He219"] = { unitType=civ.getUnitType(24), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=14, moneyCostOfMunition=10, displayText=nil },
	["He162"] = { unitType=civ.getUnitType(25), munitionCreated=civ.getUnitType(97), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=5, moneyCostOfMunition=25, displayText=nil },
	["Me163"] = { unitType=civ.getUnitType(26), munitionCreated=civ.getUnitType(97), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=2, moneyCostOfMunition=40, displayText=nil },
	["Me262"] = { unitType=civ.getUnitType(27), munitionCreated=civ.getUnitType(97), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=50, displayText=nil },
	["Ju87G"] = { unitType=civ.getUnitType(28), munitionCreated=civ.getUnitType(100), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=15, moneyCostOfMunition=10, displayText=nil, quantity=1, payload=true,nightAltNoAttack=true,  },
	["Fw190F"] = { unitType=civ.getUnitType(29), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=10, moneyCostOfMunition=5, displayText=nil },
	["Do335"] = { unitType=civ.getUnitType(30), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=13, moneyCostOfMunition=5, displayText=nil },
	["Do217"] = { unitType=civ.getUnitType(31), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=20, moneyCostOfMunition=10, displayText=nil, quantity=healthMunitionQuantity, payload=true, lowAltNoAttack=true   },
	["He277"] = { unitType=civ.getUnitType(32), munitionCreated=civ.getUnitType(99), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=23, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity, payload=true, lowAltNoAttack=true   },
	["Arado234"] = { unitType=civ.getUnitType(33), munitionCreated=civ.getUnitType(99), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=10, moneyCostOfMunition=50, displayText=nil, quantity=3, payload=true  },
	["Go229"] = { unitType=civ.getUnitType(34), munitionCreated=civ.getUnitType(100), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=12, moneyCostOfMunition=50, displayText=nil, quantity=6, payload=true, lowAltNoAttack=true   },
	["SpitfireIX"] = { unitType=civ.getUnitType(35), munitionCreated=civ.getUnitType(77), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=10, moneyCostOfMunition=5, displayText=nil },
	["SpitfireXII"] = { unitType=civ.getUnitType(36), munitionCreated=civ.getUnitType(77), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=11, moneyCostOfMunition=5, displayText=nil },
	["SpitfireXIV"] = { unitType=civ.getUnitType(37), munitionCreated=civ.getUnitType(77), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=12, moneyCostOfMunition=5, displayText=nil },
	["HurricaneIV"] = { unitType=civ.getUnitType(38), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=5, displayText=nil,  },
	["Typhoon"] = { unitType=civ.getUnitType(39), munitionCreated=civ.getUnitType(77), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=10, moneyCostOfMunition=5, displayText=nil },
	["Tempest"] = { unitType=civ.getUnitType(40), munitionCreated=civ.getUnitType(77), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=13, moneyCostOfMunition=5, displayText=nil },
	["Meteor"] = { unitType=civ.getUnitType(41), munitionCreated=civ.getUnitType(97), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=50, displayText=nil },
	["Beaufighter"] = { unitType=civ.getUnitType(42), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=20, moneyCostOfMunition=10, displayText=nil },
	["MosquitoII"] = { unitType=civ.getUnitType(43), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=20, moneyCostOfMunition=10, displayText=nil },
	["MosquitoXIII"] = { unitType=civ.getUnitType(44), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=23, moneyCostOfMunition=10, displayText=nil },
	["P47D11"] = { unitType=civ.getUnitType(50), munitionCreated=civ.getUnitType(95), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=15, moneyCostOfMunition=5, displayText=nil },
	["P47D25"] = { unitType=civ.getUnitType(51), munitionCreated=civ.getUnitType(95), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=17, moneyCostOfMunition=5, displayText=nil },
	["P47D40"] = { unitType=civ.getUnitType(52), munitionCreated=civ.getUnitType(95), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=17, moneyCostOfMunition=5, displayText=nil },
	["P38L"] = { unitType=civ.getUnitType(108), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=18, moneyCostOfMunition=10, displayText=nil },
	["P38H"] = { unitType=civ.getUnitType(54), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=10, moneyCostOfMunition=10, displayText=nil },
	["P38J"] = { unitType=civ.getUnitType(55), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=12, moneyCostOfMunition=10, displayText=nil },
	["P51B"] = { unitType=civ.getUnitType(56), munitionCreated=civ.getUnitType(95), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=20, moneyCostOfMunition=5, displayText=nil },
	["P51D"] = { unitType=civ.getUnitType(57), munitionCreated=civ.getUnitType(95), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=20, moneyCostOfMunition=5, displayText=nil },
	["P80"] = { unitType=civ.getUnitType(58), munitionCreated=civ.getUnitType(97), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=50, displayText=nil },
	["Stirling"] = { unitType=civ.getUnitType(59), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=20, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity, payload=true },
	["Halifax"] = { unitType=civ.getUnitType(60), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=22, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity, payload=true  },
	["Lancaster"] = { unitType=civ.getUnitType(61), munitionCreated=civ.getUnitType(99), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=25, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity, payload=true  },
	["Pathfinder"] = { unitType=civ.getUnitType(62), munitionCreated=civ.getUnitType(101), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=4, moneyCostOfMunition=0, displayText=nil, payload=true,quantity=healthMunitionQuantity },
	["A20"] = { unitType=civ.getUnitType(63), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=10, displayText=nil, quantity=1, payload=true  },
	["B26"] = { unitType=civ.getUnitType(64), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=10, displayText=nil, quantity=2, payload=true  },
	["A26"] = { unitType=civ.getUnitType(65), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=10, displayText=nil, quantity=3, payload=true  },
	["B17F"] = { unitType=civ.getUnitType(66), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=20, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity, payload=true, lowAltNoAttack=true  },
	["B24J"] = { unitType=civ.getUnitType(67), munitionCreated=civ.getUnitType(99), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=30, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity, payload=true, lowAltNoAttack=true   },
	["B17G"] = { unitType=civ.getUnitType(68), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=22, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity, payload=true, lowAltNoAttack=true   },
	["EgonMayer"] = { unitType=civ.getUnitType(71), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=9, moneyCostOfMunition=5, displayText=nil },
	["HermannGraf"] = { unitType=civ.getUnitType(78), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=9, moneyCostOfMunition=5, displayText=nil },
	["JosefPriller"] = { unitType=civ.getUnitType(79), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=10, moneyCostOfMunition=0, displayText=nil },
	["hwSchnaufer"] = { unitType=civ.getUnitType(102), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=9, moneyCostOfMunition=10, displayText=nil },
	["AdolfGalland"] = { unitType=civ.getUnitType(80), munitionCreated=civ.getUnitType(97), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=25, displayText=nil },
	["Experten"] = { unitType=civ.getUnitType(53), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=9, moneyCostOfMunition=5, displayText=nil },
	["He111"] = { unitType=civ.getUnitType(73), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=18, moneyCostOfMunition=10, displayText=nil, quantity=healthMunitionQuantity, payload=true, lowAltNoAttack=true   },
	["Fw200"] = { unitType=civ.getUnitType(5), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=60, moneyCostOfMunition=20, displayText=nil, quantity=1, payload=true  },
	["Sunderland"] = { unitType=civ.getUnitType(76), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=60, moneyCostOfMunition=10, displayText=nil, quantity=1, payload=true  },
	--["Artillery2"] = { unitType=civ.getUnitType(77), munitionCreated=civ.getUnitType(112), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=4, moneyCostOfMunition=0, displayText=nil },
	["UBoat"] = { unitType=civ.getUnitType(126), munitionCreated=civ.getUnitType(110), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=5, moneyCostOfMunition=0, displayText=nil },
	["GermanTaskForce"] = { unitType=civ.getUnitType(81), munitionCreated=civ.getUnitType(114), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=6, moneyCostOfMunition=0, displayText=nil },
	["AlliedTaskForce"] = { unitType=civ.getUnitType(82), munitionCreated=civ.getUnitType(114), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=6, moneyCostOfMunition=0, displayText=nil },
	["RedTails"] = { unitType=civ.getUnitType(83), munitionCreated=civ.getUnitType(95), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=13, moneyCostOfMunition=5, displayText=nil },
	["MedBombers"] = { unitType=civ.getUnitType(84), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=24, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity, payload=true, lowAltNoAttack=true   },
	["GunBattery"] = { unitType=civ.getUnitType(94), munitionCreated=civ.getUnitType(114), allowedTerrain={0, 7, -128, -121}, movementCostOfMunition=2, moneyCostOfMunition=0, displayText=nil },
	["Yak3"] = { unitType=civ.getUnitType(117), munitionCreated=civ.getUnitType(96), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=5, displayText=nil },
	["Il2"] = { unitType=civ.getUnitType(118), munitionCreated=civ.getUnitType(100), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=5, displayText=nil, quantity=1, payload=true  },
	["Ju188PR"] = { unitType=civ.getUnitType(120), munitionCreated=civ.getUnitType(8), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=40, moneyCostOfMunition=10, displayText=nil },
	["MossiePR"] = { unitType=civ.getUnitType(125), munitionCreated=civ.getUnitType(8), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=40, moneyCostOfMunition=10, displayText=nil },
	["GermanLightFlak"] = { unitType=civ.getUnitType(119), munitionCreated=civ.getUnitType(116), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114}, movementCostOfMunition=2, moneyCostOfMunition=0, displayText=nil },
	["AlliedLightFlak"] = { unitType=civ.getUnitType(2), munitionCreated=civ.getUnitType(116), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114}, movementCostOfMunition=2, moneyCostOfMunition=0, displayText=nil },
	--["Carrier"] = { unitType=civ.getUnitType(82), munitionCreated=civ.getUnitType(110), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=3, moneyCostOfMunition=0, displayText=nil },
	--["damagedB17F"] = { unitType=civ.getUnitType(105), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=20, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity },
	--["damagedB17G"] = { unitType=civ.getUnitType(107), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=20, moneyCostOfMunition=20, displayText=nil, quantity=healthMunitionQuantity },
	["GermanArmyGroup"] = { unitType=civ.getUnitType(69), munitionCreated=civ.getUnitType(114), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=0, displayText=nil },
	["GermanBatteredArmyGroup"] = { unitType=civ.getUnitType(70), munitionCreated=civ.getUnitType(114), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=6, moneyCostOfMunition=0, displayText=nil },
	["AlliedArmyGroup"] = { unitType=civ.getUnitType(74), munitionCreated=civ.getUnitType(114), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=0, displayText=nil },
	["AlliedBatteredArmyGroup"] = { unitType=civ.getUnitType(75), munitionCreated=civ.getUnitType(114), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=6, moneyCostOfMunition=0, displayText=nil },
	["RedArmyGroup"] = { unitType=civ.getUnitType(0), munitionCreated=civ.getUnitType(114), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=8, moneyCostOfMunition=0, displayText=nil },
	["USAAFAce"] = { unitType=civ.getUnitType(112), munitionCreated=civ.getUnitType(77), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=15, moneyCostOfMunition=5, displayText=nil },
	["RAFAce"] = { unitType=civ.getUnitType(113), munitionCreated=civ.getUnitType(77), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=10, moneyCostOfMunition=5, displayText=nil },
	
}

-- optional settings
--.nightMunition=unittype 
-- fires specified munition if firing unit is on the night map
--
-- .quantity = integer or function(unitCreatingMunition,munitionTypeBeingCreated,munitionDestination) -> integer
-- unitCreatingMunition is type unit, munitionTypeBeingCreated is type unittype, munitionDestination is type tile
-- specifies the quantity of the munition to be created

-- .quantityNight = integer
-- overrides quantity if the munition destination is on the night map

-- .altMap = integer
-- creates munition on map given by .altMap

-- .munitionFailText
-- text to be displayed if quantity of munitions created happens to be 0

--.payload=boolean (absent means payload=nil and is treated like false)
--If payload=true is set, then the unit can only conduct its secondary attack if it has a home city, and conducting the secondary attack will set the home city to NONE
-- .vetOverride = boolean or unitType (absent means nil, same as false
-- If true, veteran units of this type do not produce veteran munitions
-- If a unitType, veteran units produce this type of munition (non vet)
-- The nightMunition unit type overrides this if a unitType is chosen, and the night munition will not be vet.
-- if .lowAltNoAttack=true, the unit can't call up munitions on the low altitude daylight map (map 0)
-- if .nightAltNoAttack = true, the unit can't call up munitions on the night map

local secondaryAttackUnitTypes = {
--	["EarlyRadar"] = { unitType=civ.getUnitType(3), munitionCreated=unitAliases.Radar, allowedTerrain={7, -121}, movementCostOfMunition=2, moneyCostOfMunition=0, displayText=nil , altMap = 2},
--	["WurzburgRadar"] = { unitType=civ.getUnitType(4), munitionCreated=unitAliases.Wurzburg, allowedTerrain={7, -121}, movementCostOfMunition=2, moneyCostOfMunition=0, displayText=nil, altMap=2  },
	["GermanFlak"] = { unitType=civ.getUnitType(10), munitionCreated=unitAliases.Flak, allowedTerrain={0,7, -121, -128,6,4,8,9,12,13,14}, movementCostOfMunition=1, moneyCostOfMunition=0, displayText=nil, altMap = 2 },
	["AlliedFlak"] = { unitType=civ.getUnitType(72), munitionCreated=unitAliases.Flak, allowedTerrain={0,7, -121, -128,6,4,8,9,12,13,14}, movementCostOfMunition=1, moneyCostOfMunition=0, displayText=nil,altMap = 2 },
	["Fw190F"] = { unitType=civ.getUnitType(29), munitionCreated=civ.getUnitType(100), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=1, moneyCostOfMunition=5, displayText=nil, quantity=1, payload=true, highAltNoAttack=true, nightAltNoAttack=true,},
	["Do335"] = { unitType=civ.getUnitType(30), munitionCreated=civ.getUnitType(100), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=1, moneyCostOfMunition=5, displayText=nil, quantity=2, payload=true, highAltNoAttack=true,nightAltNoAttack=true, },
	["Typhoon"] = { unitType=civ.getUnitType(39), munitionCreated=civ.getUnitType(100), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=1, moneyCostOfMunition=5, displayText=nil, quantity=1, payload=true, highAltNoAttack=true, },
	["Tempest"] = { unitType=civ.getUnitType(40), munitionCreated=civ.getUnitType(100), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=1, moneyCostOfMunition=5, displayText=nil, quantity=2, payload=true, highAltNoAttack=true },
	["P47D25"] = { unitType=civ.getUnitType(51), munitionCreated=civ.getUnitType(99), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=16, moneyCostOfMunition=5, displayText=nil, quantity=1, payload=true, highAltNoAttack=true},
	["P47D40"] = { unitType=civ.getUnitType(52), munitionCreated=civ.getUnitType(99), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=16, moneyCostOfMunition=5, displayText=nil, quantity=2, payload=true, highAltNoAttack=true },
	["P47D11"] = { unitType=civ.getUnitType(50), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=15, moneyCostOfMunition=5, displayText=nil, payload=true, highAltNoAttack=true },
--	["Ju88C"] = { unitType=civ.getUnitType(22), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=21, moneyCostOfMunition=10, displayText=nil,  quantity=1, payload=true, nightAltNoAttack=true},
--	["Ju88G"] = { unitType=civ.getUnitType(23), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=23, moneyCostOfMunition=10, displayText=nil,  quantity=1, payload=true, nightAltNoAttack=true},
	["He219"] = { unitType=civ.getUnitType(24), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=27, moneyCostOfMunition=10, displayText=nil,  quantity=1, payload=true, nightAltNoAttack=true },
	["MosquitoII"] = { unitType=civ.getUnitType(43), munitionCreated=civ.getUnitType(98), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=0, quantity = 1, payload = true, displayText=nil },
	["MosquitoXIII"] = { unitType=civ.getUnitType(44), munitionCreated=civ.getUnitType(99), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=0, quantity = 1, payload = true, displayText=nil },
	["HurricaneIV"] = { unitType=civ.getUnitType(38), munitionCreated=civ.getUnitType(99), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=1, moneyCostOfMunition=5, displayText=nil, quantity=1, payload=true, highAltNoAttack=true},
	--["Light Cruiser"] = { unitType=civ.getUnitType(80), munitionCreated=unitAliases.Flak, allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=2, moneyCostOfMunition=0, displayText=nil },
	--["Heavy Cruiser"] = { unitType=civ.getUnitType(81), munitionCreated=civ.getUnitType(110), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=4, moneyCostOfMunition=0, displayText=nil },
	--["Battleship"] = { unitType=civ.getUnitType(82), munitionCreated=civ.getUnitType(110), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=3, moneyCostOfMunition=0, displayText=nil },
	["Fw190A8"] = { unitType=civ.getUnitType(16), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=5, displayText=nil, payload=true },
	["Me262"] = { unitType=civ.getUnitType(27), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=40, moneyCostOfMunition=50, displayText=nil, payload=true },
	["EgonMayer"] = { unitType=civ.getUnitType(71), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=5, displayText=nil, quantity=2, payload=true },
	["HermannGraf"] = { unitType=civ.getUnitType(78), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=5, displayText=nil, payload=true },
	["JosefPriller"] = { unitType=civ.getUnitType(79), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=0, displayText=nil, payload=true },
	["AdolfGalland"] = { unitType=civ.getUnitType(80), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=25, displayText=nil, payload=true },
	["hwSchnaufer"] = { unitType=civ.getUnitType(102), munitionCreated=civ.getUnitType(103), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115, -114}, movementCostOfMunition=0, moneyCostOfMunition=10, displayText=nil, payload=true },
	["FlakTrain"] = { unitType=civ.getUnitType(11), munitionCreated=civ.getUnitType(104), allowedTerrain={0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,  -128, -127, -126, -125, -124, -123, -122, -121, -120, -119, -118, -117, -116, -115 -114}, movementCostOfMunition=5, moneyCostOfMunition=0, displayText=nil, altMap = 2 },
}


function overTwoHundred.modifyMunitionCostForDistance(munitionUser,baseCost)
    local nearestFriendlyAirbase = nil
    local distanceToAirbase = math.huge
    local function distance(loc1,loc2) return (math.abs(loc1.x-loc2.x)+math.abs(loc1.y-loc2.y))//2 end
    for potentialAirbase in civ.iterateCities() do
        if potentialAirbase.owner == munitionUser.owner and distance(potentialAirbase.location,munitionUser.location) < distanceToAirbase and potentialAirbase:hasImprovement(improvementAliases.airbase) then
            nearestFriendlyAirbase = potentialAirbase
            distanceToAirbase = distance(potentialAirbase.location,munitionUser.location)
        end
    end
    local unit = munitionUser
    if unit.type == unitAliases.FifteenthAF or unit.type == unitAliases.RedTails then
        nearestFriendlyAirbase = civ.getTile(345,145,0).city
        distanceToAirbase = distance(nearestFriendlyAirbase.location,munitionUser.location)+specialNumbers.italyDistanceAddition
        --return maxRadius >= math.floor((math.abs(unit.location.x-345)+math.abs(unit.location.y-145))/2)
    end
    if unit.type == unitAliases.Il2 or unit.type == unitAliases.Yak3 then
        nearestFriendlyAirbase = civ.getTile(406,74,0).city
        distanceToAirbase = distance(nearestFriendlyAirbase.location,munitionUser.location)
        --return maxRadius >= math.floor((math.abs(unit.location.x-406)+math.abs(unit.location.y-74))/2)
    end
    local modifiedCost = math.max(baseCost,(distanceToAirbase*baseCost)//specialNumbers.baseFlightDistance)
    if munitionUser.owner == tribeAliases.Germans and overTwoHundred.germanCriticalIndustryActive(cityAliases.Berlin) then
        modifiedCost = math.ceil(specialNumbers.berlinFuelFraction*modifiedCost)
    end
    return modifiedCost
end

-- Counterattack table
-- default table of munitions for which heavy bombers will generate response
local validResponseHeavyBombers = {unitAliases.FiftyCal.id,unitAliases.TwentyMM.id,unitAliases.ThirtyMM.id,unitAliases.Hispanos.id}


-- prob means probability that each unit of defensiveFire will be created (0-1) (default=1)
-- quantity means quantity of defensiveFire that can be created (default = 1)
-- fractional quantities have probability of creation for last unit.  E.g. quantity=2.75 means 2 created for sure, 
-- third created with .75 probability
-- AFTER the program determines if 2 or 3 is the quantity, each one has a probability of being created based on the value of .prob
--[[local counterAttackUnitTypes = {
["Stirling"] = {unitType = unitAliases.Stirling, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 4},
["Halifax"] = {unitType = unitAliases.Halifax, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity=1, prob = 3},
["Lancaster"] = {unitType = unitAliases.Lancaster, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity=1, prob = 2},
["B17F"] = {unitType = unitAliases.B17F, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 1},
["B17G"] = {unitType = unitAliases.B17G, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 1},
["B24J"] = {unitType = unitAliases.B24J, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 2},
["MedBombers"] = {unitType = unitAliases.MedBombers, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 1},
["He111"] = {unitType = unitAliases.He111, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 4},
["Do217"] = {unitType = unitAliases.Do217, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 3},
["He277"] = {unitType = unitAliases.He277, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 2},
["damagedB17F"] = {unitType = unitAliases.damagedB17F, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 2},
["damagedB17G"] = {unitType = unitAliases.damagedB17G, munitionCreated=unitAliases.DefensiveFire, createdIfAttackedBy = validResponseHeavyBombers, quantity = 1, prob = 2},

}]]

-- These units will be replaced by other units (on the same tile) if defeated.
-- .unitType is the type of unit to be replaced
-- .replacingUnit has type unittype, and is the "replacing unit".  It must exist
-- .replacementVetStatus (optional) if true, replacement unit is veteran, if false it is not (absent means false)
-- .preserveVetStatus (optional) if true, replacement unit takes on original unit's veteran status, superseding .replacementVetStatus, 
-- if false, .replacementVetStatus determines vet status, (absent means false)
-- .replacingQuantity (optional) is the number of replacingUnits.  Fractional value means last one has a probability of being created (absent means 1)
-- .preserveHome (optional) preserves the home city of the replaced unit if true, sets home city to NONE if it is false (absent means false)
-- .bonusUnit (optional) creates an additional unit of this type (no home city, no vet status)
-- .bonusUnitQuantity (optional) creates quantity of .bonusUnit (absent means 1)
local survivingUnitTypes ={
["B17F"] = {unitType=unitAliases.B17F, replacingUnit = unitAliases.damagedB17F , --[[preserveVetStatus = true,]] bonusUnit=unitAliases.DefensiveFire, bonusUnitQuantity = 0, replacementVetStatus = true,preserveHome=true},
["B17G"] = {unitType=unitAliases.B17G, replacingUnit = unitAliases.damagedB17G , --[[preserveVetStatus = true,]] bonusUnit=unitAliases.DefensiveFire, bonusUnitQuantity = 0, replacementVetStatus = true,preserveHome=true}

}

----------------------------------------------------------------------------------------------------
-- LIMIT UNITS WHICH CAN BE CONSTRUCTED IN A CITY
local buildRestrictionsUnits = {
	["Me109G6"] = {unit=civ.getUnitType(12), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Me109G14"] = {unit=civ.getUnitType(13), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Me109K4"] = {unit=civ.getUnitType(14), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Fw190A5"] = {unit=civ.getUnitType(15), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Fw190A8"] = {unit=civ.getUnitType(16), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Fw190D9"] = {unit=civ.getUnitType(17), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Ta152"] = {unit=civ.getUnitType(18), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Me110"] = {unit=civ.getUnitType(20), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Me410"] = {unit=civ.getUnitType(21), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Ju88C"] = {unit=civ.getUnitType(22), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Ju88G"] = {unit=civ.getUnitType(23), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["He219"] = {unit=civ.getUnitType(24), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["He162"] = {unit=civ.getUnitType(25), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Me163"] = {unit=civ.getUnitType(26), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Me262"] = {unit=civ.getUnitType(27), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Ju87G"] = {unit=civ.getUnitType(28), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Fw190F"] = {unit=civ.getUnitType(29), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Do335"] = {unit=civ.getUnitType(30), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Do217"] = {unit=civ.getUnitType(31), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["He277"] = {unit=civ.getUnitType(32), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Arado234"] = {unit=civ.getUnitType(33), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Go229"] = {unit=civ.getUnitType(34), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Fw200"] = {unit=civ.getUnitType(5), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Ju188"] = {unit=civ.getUnitType(120), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["SpitfireIX"] = {unit=civ.getUnitType(35), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["SpitfireXII"] = {unit=civ.getUnitType(36), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["SpitfireXIV"] = {unit=civ.getUnitType(37), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["HurricaneIV"] = {unit=civ.getUnitType(38), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Typhoon"] = {unit=civ.getUnitType(39), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Tempest"] = {unit=civ.getUnitType(40), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Meteor"] = {unit=civ.getUnitType(41), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Beaufighter"] = {unit=civ.getUnitType(42), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["MosquitoII"] = {unit=civ.getUnitType(43), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["MosquitoXIII"] = {unit=civ.getUnitType(44), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["P47D11"] = {unit=civ.getUnitType(50), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["P47D25"] = {unit=civ.getUnitType(51), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["P47D40"] = {unit=civ.getUnitType(52), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["P38L"] = {unit=civ.getUnitType(108), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["P38H"] = {unit=civ.getUnitType(54), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["P38J"] = {unit=civ.getUnitType(55), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["P51B"] = {unit=civ.getUnitType(56), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["P51D"] = {unit=civ.getUnitType(57), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["P80"] = {unit=civ.getUnitType(58), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Stirling"] = {unit=civ.getUnitType(59), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Halifax"] = {unit=civ.getUnitType(60), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Lancaster"] = {unit=civ.getUnitType(61), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Pathfinder"] = {unit=civ.getUnitType(62), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["A20"] = {unit=civ.getUnitType(63), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["B26"] = {unit=civ.getUnitType(64), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["A26"] = {unit=civ.getUnitType(65), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["B17F"] = {unit=civ.getUnitType(66), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["B24J"] = {unit=civ.getUnitType(67), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["B17G"] = {unit=civ.getUnitType(68), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["MossiePR"] = {unit=civ.getUnitType(125), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["RedTails"] = {unit=civ.getUnitType(83), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(18)) or civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["MedBombers"] = {unit=civ.getUnitType(84), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(18)) or civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["Yak3"] = {unit=civ.getUnitType(117), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(3))) then return false end end},
	["Il2"] = {unit=civ.getUnitType(118), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(3))) then return false end end},
	["MfgGoods"] = {unit=civ.getUnitType(6), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(15))) then return false end end},
	["Sdkfz"] = {unit=civ.getUnitType(9), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(8))) then return false end end},
	["GermanFlak"] = {unit=civ.getUnitType(10), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(8))) then return false end end},
	["FlakTrain"] = {unit=civ.getUnitType(11), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(8))) then return false end end},
	["ProtoI"] = {unit=civ.getUnitType(48), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(8))) then return false end end},
	["ProtoII"] = {unit=civ.getUnitType(49), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(8))) then return false end end},
	["AlliedFlak"] = {unit=civ.getUnitType(72), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(8))) then return false end end},
	["He111"] = {unit=civ.getUnitType(73), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["GunBattery"] = {unit=civ.getUnitType(94), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(8))) then return false end end},
	["V1Launch"] = {unit=civ.getUnitType(121), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(8))) then return false end end},
	["V2Launch"] = {unit=civ.getUnitType(122), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(8))) then return false end end},
	["Carrier"] = {unit=civ.getUnitType(111), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(34))) or (city.owner == tribeAliases.Germans and not(isGermanCity(city))) then return false end end},
	["UBoat"] = {unit=civ.getUnitType(126), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(34))) then return false end end},
	["Sunderland"] = {unit=civ.getUnitType(76), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(17))) then return false end end},
	["LandingCraft"] = {unit=civ.getUnitType(78), conditionMet=function (city, state) if not(civ.hasImprovement(city, civ.getImprovement(34))) then return false end end},
}

local function civilImprovement(city,industry)
    local count = 0
    if civ.hasImprovement(city,civ.getImprovement(4)) then
        count = count+1
    end
    if civ.hasImprovement(city,civ.getImprovement(11)) then
        count = count+1
    end
    if civ.hasImprovement(city,civ.getImprovement(14)) then
        count = count+1
    end
    -- industry variable means checking for industry improvement,
    -- which is modified by schweinfurt critical industry
    if industry and city.owner == tribeAliases.Germans and
        overTwoHundred.germanCriticalIndustryActive(cityAliases.Schweinfurt) then
        count = count+1
    end
    return count
end
-- Critical Industry Table
-- NOTE: Changing cities requires changes in the cityCoordinates table
-- (and the onCityProduction function if changing Peenemunde)
overTwoHundred.criticalIndustryCitiesAndTiles = {}
overTwoHundred.criticalIndustryCitiesAndTiles[cityAliases.Berlin.id]={379,69}
overTwoHundred.criticalIndustryCitiesAndTiles[cityAliases.Regensburg.id] = {344,102}
overTwoHundred.criticalIndustryCitiesAndTiles[cityAliases.Hamburg.id] = {311,55}
overTwoHundred.criticalIndustryCitiesAndTiles[cityAliases.Schweinfurt.id] = {316,94}
overTwoHundred.criticalIndustryCitiesAndTiles[cityAliases.Peenemunde.id] = {372,56}
-- LIMIT IMPROVEMENTS WHICH CAN BE CONSTRUCTED IN A CITY

local buildRestrictionsImprovements={
	["TrainedPilots"] = {improvement=civ.getImprovement(32), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(8)) then return false else return nil end end},
	["CriticalIndustry"] = {improvement=civ.getImprovement(13), conditionMet=function (city, state) if not(overTwoHundred.criticalIndustryCitiesAndTiles[city.id]) then return false else return nil end end},
	["Airfield"] = {improvement=civ.getImprovement(17), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(8)) or civ.hasImprovement(city, civ.getImprovement(18)) or civ.hasImprovement(city, civ.getImprovement(3))  then return false else return nil end end},
	--["USAAFAiport"] = {improvement=civ.getImprovement(33), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(8)) then return false else return nil end end},
	["WildeSau"] = {improvement=civ.getImprovement(35), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(8)) then return false else return nil end end},
	["IndustryI"] = {improvement=civ.getImprovement(15), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) or civilImprovement(city,true)<1 then return false else return nil end end},
	["IndustryII"] = {improvement=civ.getImprovement(16), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) or civilImprovement(city,true)<2 then return false else return nil end end},
	["IndustryIII"] = {improvement=civ.getImprovement(29), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) or civilImprovement(city,true)<3 then return false else return nil end end},
	["AirFacI"] = {improvement=civ.getImprovement(6), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) or civilImprovement(city)<1 then return false else return nil end end},
	["AirFacII"] = {improvement=civ.getImprovement(12), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) or civilImprovement(city)<2 then return false else return nil end end},
	["AirFacIII"] = {improvement=civ.getImprovement(26), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) or civilImprovement(city)<3 then return false else return nil end end},
	["CivPopI"] = {improvement=civ.getImprovement(4), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) then return false else return nil end end},
	["CivPopII"] = {improvement=civ.getImprovement(11), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) then return false else return nil end end},
	["CivPopIII"] = {improvement=civ.getImprovement(14), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) then return false else return nil end end},
	["FuelI"] = {improvement=civ.getImprovement(5), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) or civilImprovement(city)<1 then return false else return nil end end},
	["FuelII"] = {improvement=civ.getImprovement(10), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) or civilImprovement(city)<2 then return false else return nil end end},
	["FuelIII"] = {improvement=civ.getImprovement(22), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) or civilImprovement(city)<3 then return false else return nil end end},
	["Port"] = {improvement=civ.getImprovement(34), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) then return false else return nil end end},
	["Railyards"] = {improvement=civ.getImprovement(25), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) then return false else return nil end end},
	["Rationing"] = {improvement=civ.getImprovement(24), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) then return false else return nil end end},
	["BombShelter"] = {improvement=civ.getImprovement(27), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) then return false else return nil end end},
	["Docks"] = {improvement=civ.getImprovement(30), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) then return false else return nil end end},
	["SabotagePort"] = {improvement=civ.getImprovement(28), conditionMet=function (city, state) if civ.hasImprovement(city, civ.getImprovement(18))  or civ.hasImprovement(city, civ.getImprovement(17)) or civ.hasImprovement(city, civ.getImprovement(3)) then return false else return nil end end},
																	

}

local buildRestrictionsWonders={
   ["TestWonder"] = {wonder=civ.getWonder(18), conditionMet=function (city, state) if state.thisCanBeBuilt==true then return true else return false end end}
}

----------------------------------------------------------------------------------------------------
-- Defines coordinates near each city that are linked to the construction of specific improvements in that city
-- ID numbers are used for table keys so we don't have to worry about renamed cities or improvements
--[[ structure by Knighttime ]]
local cityCoordinates = {
						-- Outer key is a city ID
								-- All nested (inner) keys are improvement IDs
--[[ Brest ]]           [30] = {[15] = {{89,91}}, [6]  = {{98,100}}, [5]  = {{88,96}}, [4]  = {{88,92}, {91,93}}, [25] = {{102,98}},
                                [16] = {{91,91}}, [12]  = {{99,93}}, [10] = {{89,97}}, [11] = {{90,92}, {89,91}},
                                [29] = {{92,92}}, [26] = {{92,94}}, [22] = {{90,96}}, [14] = {{93,95}, {93,93}}, [34] = {{88,94}} },

 --[[ St. Nazaire ]]     [31] = {[15] = {{115,107}}, [6]  = {{113,105}}, [5]  = {{118,106}}, [4]  = {{120,108}, {116,106}}, [25] = {{122,102}},
                                [16] = {{116,108}}, [12]  = {{110,106}}, [10] = {{120,106}}, [11] = {{119,107}, {117,105}},
                                [29] = {{117,107}}, [26] = {{115,109}}, [22] = {{121,107}}, [14] = {{117,119}, {119,105}}, [34] = {{117,111}} },


--[[ Nantes ]]          [32] = {[15] = {{126,114}}, [6]  = {{122,98}}, [5]  = {{124,108}}, [4]  = {{126,108}, {124,112}}, [25] = {{131,105}},
                                [16] = {{124,114}}, [12]  = {{120,100}}, [10] = {{125,109}}, [11] = {{127,111}, {123,111}},
                                [29] = {{123,113}}, [26] = {{130,118}}, [22] = {{127,109}}, [14] = {{126,112}, {122,112}}, [34] = {{124,110}} },


--[[ La Rochelle ]]     [33] = {[15] = {{126,128}}, [6]  = {{134,124}}, [5]  = {{130,124}}, [4]  = {{126,124}, {128,126}}, [25] = {{126,118}},
                                [16] = {{128,128}}, [12]  = {{131,121}}, [10] = {{129,123}}, [11] = {{128,124}, {127,123}},
                                [29] = {{129,127}}, [26] = {{128,120}}, [22] = {{128,122}}, [14] = {{129,125}, {126,122}}, [34] = {{127,127}} },


--[[ Bordeaux ]]        [34] = {[15] = {{131,145}}, [6]  = {{126,138}}, [5]  = {{128,142}}, [4]  = {{130,144}, {129,145}}, [25] = {{144,136}},
                                [16] = {{132,144}}, [12]  = {{136,138}}, [10] = {{127,141}}, [11] = {{129,143}, {128,144}},
                                [29] = {{133,143}}, [26] = {{141,141}}, [22] = {{128,140}}, [14] = {{131,143}, {127,143}}, [34] = {{130,140}} },


--[[ Cherbourg ]]       [35] = {[15] = {{145,85}}, [6]  = {{139,91}}, [5]  = {{141,87}}, [4]  = {{143,85}, {144,84}}, [25] = {{146,96}},
                                [16] = {{144,86}}, [12]  = {{145,87}}, [10] = {{140,86}}, [11] = {{142,86}, {140,84}},
                                [29] = {{143,87}}, [26] = {{148,94}}, [22] = {{139,85}}, [14] = {{141,85}, {139,83}}, [34] = {{141,83}} },


--[[ Tours ]]           [37] = {[15] = {{162,114}}, [6]  = {{159,123}}, [5]  = {{162,118}}, [4]  = {{162,116}, {164,116}}, [25] = {{165,111}},
                                [16] = {{164,114}}, [12]  = {{166,124}}, [10] = {{163,119}}, [11] = {{160,118}, {161,119}},
                                [29] = {{165,119}}, [26] = {{169,121}}, [22] = {{164,120}}, [14] = {{164,118}, {162,120}} },


--[[ Le Havre ]]        [36] = {[15] = {{164,92}}, [6]  = {{160,98}}, [5]  = {{165,93}}, [4]  = {{165,89}, {165,93}}, [25] = {{170,90}},
                                [16] = {{163,93}}, [12]  = {{167,93}}, [10] = {{167,91}}, [11] = {{166,90}, {167,91}},
                                [29] = {{162,92}}, [26] = {{168,98}}, [22] = {{167,89}}, [14] = {{166,88}, {167,89}}, [34] = {{163,89}} },


--[[ Rouen ]]           [38] = {[15] = {{179,91}}, [6]  = {{178,92}}, [5]  = {{173,91}}, [4]  = {{175,93, 177,93}}, [25] = {{183,93}},
                                [16] = {{175,95}}, [12]  = {{179,93}}, [10] = {{174,90}}, [11] = {{174,92}, {175,91}},
                                [29] = {{177,95}}, [26] = {{184,92}}, [22] = {{175,89}}, [14] = {{177,91}, {176,90}} },


--[[ Paris ]]           [39] = {[15] = {{194,98}}, [6]  = {{195,103}}, [5]  = {{197,101}}, [4]  = {{195,99}, {194,100}}, [25] = {{199,93}},
                                [16] = {{193,99}}, [12]  = {{194,104}}, [10] = {{198,100}}, [11] = {{193,101}, {196,98}},
                                [29] = {{192,100}}, [26] = {{193,103}}, [22] = {{197,99}}, [14] = {{196,104}, {196,100}} },

--[[ Brussels ]]        [40] = {[15] = {{229,81}}, [6]  = {{228,86}}, [5]  = {{231,87}}, [4]  = {{231,83}, {232,82}}, [25] = {{240,84}},
                                [16] = {{228,82}}, [12]  = {{230,82}}, [10] = {{232,86}}, [11] = {{232,84}, {233,83}},
                                [29] = {{227,83}}, [26] = {{231,81}}, [22] = {{233,85}}, [14] = {{230,86}, {229,87}} },

--[[ Lyon ]]            [47] = {[15] = {{210,138}}, [6]  = {{217,131}}, [5]  = {{211,141}}, [4]  = {{213,139}, {212,142}}, [25] = {{225,123}},
                                [16] = {{211,139}}, [12]  = {{210,136}}, [10] = {{210,142}}, [11] = {{212,138}, {211,143}},
                                [29] = {{209,139}}, [26] = {{221,139}}, [22] = {{209,141}}, [14] = {{214,142}, {213,143}} },


--[[ Antwerp ]]         [44] = {[15] = {{230,80}}, [6]  = {{232,76}}, [5]  = {{230,76}}, [4]  = {{229,77}, {229,79}}, [25] = {{236,78}},
                                [16] = {{232,80}}, [12]  = {{233,75}}, [10] = {{228,76}}, [11] = {{232,78}, {233,77}},
                                [29] = {{234,78}}, [26] = {{234,76}}, [22] = {{228,78}}, [14] = {{233,79}, {231,79}}, [34] = {{231,75}} },


--[[ Rotterdam ]]       [43] = {[15] = {{238,72}}, [6]  = {{238,70}}, [5]  = {{242,70}}, [4]  = {{243,71}, {242,72}}, [25] = {{252,68}},
                                [16] = {{239,71}}, [12]  = {{239,69}}, [10] = {{243,69}}, [11] = {{242,74}, {241,75}},
                                [29] = {{240,70}}, [26] = {{240,68}}, [22] = {{244,70}}, [14] = {{240,74}, {240,72}}, [34] = {{241,73}} },


--[[ The Hague ]]       [42] = {[15] = {{234,72}}, [6]  = {{232,70}}, [5]  = {{236,68}}, [4]  = {{236,70}, {232,70}}, [25] = {{236,74}},
                                [16] = {{232,72}}, [12]  = {{233,69}}, [10] = {{237,69}}, [11] = {{236,72}, {233,69}},
                                [29] = {{231,71}}, [26] = {{235,69}}, [22] = {{237,71}}, [14] = {{235,71}, {235,69}}, [34] = {{234,68}} },


--[[ Amsterdam ]]       [41] = {[15] = {{246,68}}, [6]  = {{252,62}}, [5]  = {{243,67}}, [4]  = {{245,63}, {244,68}}, [25] = {{241,67}},
                                [16] = {{247,67}}, [12]  = {{254,64}}, [10] = {{244,66}}, [11] = {{244,64}, {243,63}},
                                [29] = {{246,66}}, [26] = {{256,66}}, [22] = {{245,67}}, [14] = {{243,65}, {242,64}}, [34] = {{246,64}} },

--[[ Dusseldorf ]]      [11] = {[15] = {{268,78}}, [6]  = {{265,77}}, [5]  = {{271,81}}, [4]  = {{273,79}, {270,78}}, [25] = {{264,72}},
                                [16] = {{269,77}}, [12]  = {{270,72}}, [10] = {{272,80}}, [11] = {{273,81}, {270,80}},
                                [29] = {{270,76}}, [26] = {{274,70}}, [22] = {{272,82}}, [14] = {{272,78}, {270,82}} },


--[[ Essen ]]           [13] = {[15] = {{272,74}}, [6]  = {{277,69}}, [5]  = {{276,76}}, [4]  = {{275,77}, {275,73}}, [25] = {{286,74}},
                                [16] = {{273,73}}, [12]  = {{274,70}}, [10] = {{277,77}}, [11] = {{275,75}, {276,74}},
                                [29] = {{274,74}}, [26] = {{278,66}}, [22] = {{276,78}}, [14] = {{273,75}, {277,75}} },


--[[ Cologne ]]         [12] = {[15] = {{274,88}}, [6]  = {{271,87}}, [5]  = {{274,84}}, [4]  = {{273,85}, {272,84}}, [25] = {{269,89}},
                                [16] = {{273,87}}, [12]  = {{270,86}}, [10] = {{273,83}}, [11] = {{271,83}, {270,84}},
                                [29] = {{275,87}}, [26] = {{273,91}}, [22] = {{275,85}}, [14] = {{274,86}, {271,85}} },


--[[ Dortmund ]]        [14] = {[15] = {{278,74}}, [6]  = {{283,73}}, [5]  = {{282,78}}, [4]  = {{279,77}, {279,79}}, [25] = {{283,91}},
                                [16] = {{279,73}}, [12]  = {{285,75}}, [10] = {{283,75}}, [11] = {{278,76}, {281,79}},
                                [29] = {{280,74}}, [26] = {{284,78}}, [22] = {{282,74}}, [14] = {{279,75}, {280,78}} },


--[[ Freiburg ]]        [24] = {[15] = {{275,121}}, [6]  = {{269,117}}, [5]  = {{275,117}}, [4]  = {{276,120}, {278,122}}, [25] = {{282,110}},
                                [16] = {{276,122}}, [12]  = {{274,124}}, [10] = {{276,116}}, [11] = {{278,120}, {279,121}},
                                [29] = {{277,121}}, [26] = {{284,122}}, [22] = {{278,116}}, [14] = {{278,118}, {280,120}} },


--[[ Berlin ]]          [0] = {[15] = {{364,68}}, [6]  = {{367,69}}, [5]  = {{366,72}}, [4]  = {{362,70}, {365,71}}, [25] = {{356,68}},
                                [16] = {{365,69}}, [12]  = {{364,64}}, [10] = {{365,73}}, [11] = {{361,69}, {364,70}},
                                [29] = {{366,70}}, [26] = {{365,75}}, [22] = {{364,72}}, [14] = {{362,68}, {363,69}},
                                [improvementAliases.criticalIndustry.id]={overTwoHundred.criticalIndustryCitiesAndTiles[0]}},

--[[ Karlesruhe ]]      [25] = {[15] = {{285,105}}, [6]  = {{288,102}}, [5]  = {{288,106}}, [4]  = {{289,103}, {291,103}}, [25] = {{293,109}},
                                [16] = {{286,106}}, [12]  = {{289,101}}, [10] = {{289,107}}, [11] = {{289,105}, {290,104}},
                                [29] = {{287,107}}, [26] = {{290,102}}, [22] = {{290,106}}, [14] = {{286, 104}, {287,103}} },


--[[ Stuttgart ]]       [27] = {[15] = {{301,111}}, [6]  = {{298,112}}, [5]  = {{296,110}}, [4]  = {{297,109}, {298,108}}, [25] = {{298,116}},
                                [16] = {{300,112}}, [12]  = {{299,111}}, [10] = {{295,109}}, [11] = {{297,111}, {299,109}},
                                [29] = {{299,113}}, [26] = {{300,110}}, [22] = {{296,112}}, [14] = {{300,108}, {297,107}} },


--[[ Mannheim ]]        [26] = {[15] = {{291,101}}, [6]  = {{293,101}}, [5]  = {{289,99}}, [4]  = {{293,99}, {293,101}}, [25] = {{295,103}},
                                [16] = {{290,100}}, [12]  = {{294,100}}, [10] = {{292,98}}, [11] = {{294,98}, {294,100}},
                                [29] = {{292,102}}, [26] = {{294,102}}, [22] = {{291,99}}, [14] = {{295,99}, {294,102}} },


--[[ Frankfurt ]]       [22] = {[15] = {{292,96}}, [6]  = {{299,95}}, [5]  = {{296,98}}, [4]  = {{294,96}, {296,94}}, [25] = {{294,88}},
                                [16] = {{294,94}}, [12]  = {{295,91}}, [10] = {{297,93}}, [11] = {{296,96}, {297,95}},
                                [29] = {{294,92}}, [26] = {{292,92}}, [22] = {{296,92}}, [14] = {{295,93}, {294,94}} },


--[[ Schweinfurt ]]     [21] = {[15] = {{314,100}}, [6]  = {{317,101}}, [5]  = {{316,98}}, [4]  = {{314, 102}, {313,103}}, [25] = {{312,104}},
                                [16] = {{313,101}}, [12]  = {{315,105}}, [10] = {{317,99}}, [11] = {{316,102}, {315,103}},
                                [29] = {{312,100}}, [26] = {{314,98}}, [22] = {{315,99}}, [14] = {{316,100}, {314,98}},
                                [improvementAliases.criticalIndustry.id]={overTwoHundred.criticalIndustryCitiesAndTiles[21]}},

--[[ Friedrichshaven ]] [20] = {[15] = {{299,123}}, [6]  = {{301,123}}, [5]  = {{303,125}}, [4]  = {{301,125}}, [25] = {{305,121}},
                                [16] = {{298,122}}, [12]  = {{300,122}}, [10] = {{303,123}}, [11] = {{302,124}},
                                [29] = {{297,123}}, [26] = {{301,121}}, [22] = {{302,122}}, [14] = {{302,126}} },


--[[ Munich ]]          [19] = {[15] = {{329,121}}, [6]  = {{333,115}}, [5]  = {{335,119}}, [4]  = {{333,119}, {334,120}}, [25] = {{336,116}},
                                [16] = {{329,119}}, [12]  = {{322,120}}, [10] = {{334,118}}, [11] = {{333,121}, {332,122}},
                                [29] = {{330,118}}, [26] = {{341,119}}, [22] = {{333,117}}, [14] = {{330,122}, {330,120}} },


--[[ Nurnburg ]]        [18] = {[15] = {{326,108}}, [6]  = {{332,102}}, [5]  = {{329,105}}, [4]  = {{327,105}, {327,107}}, [25] = {{329,99}},
                                [16] = {{325,109}}, [12]  = {{331,107}}, [10] = {{325,103}}, [11] = {{325,105}, {325,105}},
                                [29] = {{324,108}}, [26] = {{329,101}}, [22] = {{327,103}}, [14] = {{323,105}, {323,107}} },


--[[ Regensburg ]]      [28] = {[15] = {{341,107}}, [6]  = {{339,111}}, [5]  = {{343,107}}, [4]  = {{345,107}, {344,106}}, [25] = {{337,109}},
                                [16] = {{342,106}}, [12]  = {{348,112}}, [10] = {{346,106}}, [11] = {{346,108}, {346,110}},
                                [29] = {{343,111}}, [26] = {{347,105}}, [22] = {{343,105}}, [14] = {{345,109}, {345,111}},
                                [improvementAliases.criticalIndustry.id]={overTwoHundred.criticalIndustryCitiesAndTiles[28]}},

--[[ Vienna ]]          [3] = {[15] = {{401,119}}, [6]  = {{400,116}}, [5]  = {{405,119}}, [4]  = {{401,121}, {402,122}}, [25] = {{394,116}},
                                [16] = {{402,120}}, [12]  = {{394,124}}, [10] = {{406,120}}, [11] = {{404,122}, {404,124}},
                                [29] = {{402,118}}, [26] = {{407,127}}, [22] = {{404,118}}, [14] = {{404,120}, {405,121}} },


--[[ Prague ]]          [2] = {[15] = {{373,103}}, [6]  = {{377,93}}, [5]  = {{372,100}}, [4]  = {{374,102}, {376,102}}, [25] = {{370,98}},
                                [16] = {{376,104}}, [12]  = {{369,101}}, [10] = {{374,98}}, [11] = {{377,101}, {378,102}},
                                [29] = {{373,101}}, [26] = {{379,109}}, [22] = {{376,98}}, [14] = {{375,99}, {377,99}} },


--[[ Dresden ]]         [1] = {[15] = {{371,91}}, [6]  = {{361,87}}, [5]  = {{368,92}}, [4]  = {{368,88}, {367,89}}, [25] = {{368,82}},
                                [16] = {{372,90}}, [12]  = {{367,95}}, [10] = {{366,90}}, [11] = {{368,90}, {367,91}},
                                [29] = {{372,88}}, [26] = {{374,88}}, [22] = {{366,88}}, [14] = {{369,91}, {371,89}} },


--[[ Leipzig ]]         [4] = {[15] = {{351,93}}, [6]  = {{351,83}}, [5]  = {{349,91}}, [4]  = {{350,90}, {351,91}}, [25] = {{358,90}},
                                [16] = {{353,93}}, [12]  = {{356,86}}, [10] = {{349,89}}, [11] = {{350,92}, {352,92}},
                                [29] = {{352,88}}, [26] = {{346,90}}, [22] = {{351,89}}, [14] = {{353,91}, {354,90}} },


--[[ Merseburg ]]       [5] = {[15] = {{345,85}}, [6]  = {{336,86}}, [5]  = {{346,82}}, [4]  = {{346,84}, {346,86}}, [25] = {{342,84}},
                                [16] = {{345,83}}, [12]  = {{345,79}}, [10] = {{347,83}}, [11] = {{349,85}, {348,84}},
                                [29] = {{345,87}}, [26] = {{341,87}}, [22] = {{348,82}}, [14] = {{348,86,}, {347,87}} },

--[[ Rostock ]]         [6] = {[15] = {{345,55}}, [6]  = {{344,60}}, [5]  = {{350,56}}, [4]  = {{346,54}, {345,55}}, [25] = {{346,60}},
                                [16] = {{344,54}}, [12]  = {{347,53}}, [10] = {{350,54}}, [11] = {{348,54}, {349,55}},
                                [29] = {{344,56}}, [26] = {{354,62}}, [22] = {{349,53}}, [14] = {{348,56}, {346,57}}, [34] = {{347,53}} },


--[[ Luneburg ]]        [7] = {[15] = {{323,71}}, [6]  = {{319,69}}, [5]  = {{320,74}}, [4]  = {{322,74}, {324,74}}, [25] = {{329,71}},
                                [16] = {{324,70}}, [12]  = {{328,70}}, [10] = {{324,76}}, [11] = {{325,75}, {326,74}},
                                [29] = {{326,72}}, [26] = {{317,79}}, [22] = {{321,73}}, [14] = {{323,75}, {325,75}} },


--[[ Hannover ]]        [8] = {[15] = {{303,83}}, [6]  = {{292,82}}, [5]  = {{307,85}}, [4]  = {{306,80}, {305,81}}, [25] = {{314,80}},
                                [16] = {{305,85}}, [12]  = {{308,88}}, [10] = {{309,81}}, [11] = {{308,82}, {307,83}},
                                [29] = {{307,81}}, [26] = {{303,73}}, [22] = {{304,80}}, [14] = {{306,84}, {308,84}} },


--[[ Bremen ]]          [9] = {[15] = {{301,65}}, [6]  = {{304,60}}, [5]  = {{300,60}}, [4]  = {{299,61}, {300,62}}, [25] = {{305,63}},
                                [16] = {{302,64}}, [12]  = {{301,69}}, [10] = {{301,61}}, [11] = {{299,65}, {300,64}},
                                [29] = {{301,63}}, [26] = {{304,66}}, [22] = {{302,62}}, [14] = {{297,63}, {297,65}}, [34] = {{298,62}} },

--[[ Wilhelmshaven ]]   [10] = {[15] = {{290,60}}, [6]  = {{285,57}}, [5]  = {{296,60}}, [4]  = {{291,59}}, [25] = {{294,66}},
                                [16] = {{291,57}}, [12]  = {{284,62}}, [10] = {{291,61}}, [11] = {{292,60}},
                                [29] = {{290,58}}, [26] = {{290,68}}, [22] = {{292,62}}, [14] = {{293,61}}, [34] = {{294,60}} },


--[[ Hamburg ]]         [15] = {[15] = {{318,56}}, [6]  = {{314,48}}, [5]  = {{314,60}}, [4]  = {{318,58}, {319,59}}, [25] = {{315,63}},
                                [16] = {{316,56}}, [12]  = {{322,60}}, [10] = {{315,61}}, [11] = {{317,61}, {318,62}},
                                [29] = {{320,58}}, [26] = {{314,62}}, [22] = {{319,57}}, [14] = {{315,57}, {316,58}}, [34] = {{316,60}},
                                [improvementAliases.criticalIndustry.id]={overTwoHundred.criticalIndustryCitiesAndTiles[15]}},


--[[ Kiel ]]            [16] = {[15] = {{323,47}}, [6]  = {{317,47}}, [5]  = {{325,53}}, [4]  = {{322,50}, {323,51}}, [25] = {{327,53}},
                                [16] = {{322,48}}, [12]  = {{328,50}}, [10] = {{326,52}}, [11] = {{325,51}, {324,52}},
                                [29] = {{323,53}}, [26] = {{323,47}}, [22] = {{326,50}}, [14] = {{323,49}, {325,49}}, [34] = {{324,48}} },


--[[ Lubeck ]]          [17] = {[15] = {{331,57}}, [6]  = {{336,60}}, [5]  = {{331,53}}, [4]  = {{332,54}, {333,55}}, [25] = {{336,62}},
                                [16] = {{332,58}}, [12]  = {{328,60}}, [10] = {{330,54}}, [11] = {{331,55}, {333,57}},
                                [29] = {{331,59}}, [26] = {{332,52}}, [22] = {{329,55}}, [14] = {{333,53}, {335,57}}, [34] = {{334,56}} },

--[[ Aarhus ]]          [23] = {[15] = {{327,33}}, [6]  = {{326,118}}, [5]  = {{323,31}}, [4]  = {{328,32}, {328,31}}, [25] = {{320,32}},
                                [16] = {{326,32}}, [12]  = {{328,38}}, [10] = {{327,29}}, [11] = {{328,30}, {327,31}},
                                [29] = {{325,35}}, [26] = {{315,37}}, [22] = {{325,29}}, [14] = {{324,30}, {324,32}}, [34] = {{326,34}} },
                                
                              
--[[ Linz ]]            [29] = {[15] = {{367,123}}, [6]  = {{360,122}}, [5]  = {{369,123}}, [4]  = {{372,120}, {372,122}}, [25] = {{378,122}},
                                [16] = {{368,124}}, [12]  = {{379,121}}, [10] = {{371,123}}, [11] = {{370,120}, {371,121}},
                                [29] = {{369,125}}, [26] = {{375,117}}, [22] = {{372,124}}, [14] = {{368,120}, {369,121}} },


--[[ Calais ]]          [46] = {[15] = {{199,79}}, [6]  = {{199,83}}, [5]  = {{197,79}}, [4]  = {{201,77}, {200,78}}, [25] = {{200,86}},
                                [16] = {{200,80}}, [12]  = {{202,82}}, [10] = {{196,78}}, [11] = {{198,78}, {199,77}},
                                [29] = {{198,80}}, [26] = {{202,86}}, [22] = {{197,77}}, [14] = {{202,78}, {201,79}}, [34] = {{200,76}} },


--[[ Brunswick ]]       [48] = {[15] = {{338,78}}, [6]  = {{339,81}}, [5]  = {{341,73}}, [4]  = {{337, 75}, {338,76}}, [25] = {{343,69}},
                                [16] = {{338,74}}, [12]  = {{335,81}}, [10] = {{340,72}}, [11] = {{339,75}, {341,75}},
                                [29] = {{339,75}}, [26] = {{343,81}}, [22] = {{338,72}}, [14] = {{340,76}, {341,77}} },


--[[ Peenemunde ]]      [49] = {[15] = {{377,61}}, [6]  = {{375,57}}, [5]  = {{372,62}}, [4]  = {{375,59}, {374,60}}, [25] = {{371,63}},
                                [16] = {{378,62}}, [12]  = {{382,58}}, [10] = {{373,63}}, [11] = {{373,59}, {374,58}},
                                [29] = {{376,64}}, [26] = {{370,56}}, [22] = {{374,64}}, [14] = {{373,61}, {374,62}},
                                [improvementAliases.criticalIndustry.id]={overTwoHundred.criticalIndustryCitiesAndTiles[49]}},

--[[ London ]]          [50] = {[15] = {{170,70}}, [6]  = {{173,71}}, [5]  = {{171,65}}, [4]  = {{170,68}, {171,67}}, [25] = {{170,56}},
                                [16] = {{171,71}}, [12]  = {{174,70}}, [10] = {{170,66}}, [11] = {{172,66}, {174,66}},
                                [29] = {{172,70}}, [26] = {{174,68}}, [22] = {{169,67}}, [14] = {{173,65}, {175,67}}, [34] = {{175,69}} },


--[[ Portsmouth ]]      [51] = {[15] = {{152,74}}, [6]  = {{151,67}}, [5]  = {{153,75}}, [4]  = {{152,72}, {153,71}}, [25] = {{151,69}},
                                [16] = {{154,74}}, [12]  = {{156,68}}, [10] = {{151,71}}, [11] = {{156,72}, {155,71}},
                                [29] = {{155,75}}, [26] = {{155,65}}, [22] = {{157,73}}, [14] = {{154,70}, {155,69}}, [34] = {{153,73}} },


--[[ Bristol ]]         [52] = {[15] = {{136,66}}, [6]  = {{137,59}}, [5]  = {{138,62}}, [4]  = {{137,65}, {138,66}}, [25] = {{138,70}},
                                [16] = {{137,67}}, [12]  = {{141,59}}, [10] = {{140,62}}, [11] = {{139,67}, {140,68}},
                                [29] = {{138,68}}, [26] = {{145,63}}, [22] = {{141,63}}, [14] = {{140,66}, {141,67}}, [34] = {{138,64}} },


--[[ Swansea ]]         [53] = {[15] = {{117,59}}, [6]  = {{109,57}}, [5]  = {{122,60}}, [4]  = {{118,60}, {120,62}}, [25] = {{123,61}},
                                [16] = {{118,58}}, [12]  = {{111,53}}, [10] = {{121,59}}, [11] = {{116,60}, {117,61}},
                                [29] = {{119,59}}, [26] = {{116,56}}, [22] = {{120,58}}, [14] = {{121,61}, {122,62}}, [34] = {{118,62}} },


--[[ Plymouth ]]        [54] = {[15] = {{108,70}}, [6]  = {{116,74}}, [5]  = {{113,71}}, [4]  = {{111,73}, {112,72}}, [25] = {{120,70}},
                                [16] = {{107,71}}, [12]  = {{113,69}}, [10] = {{112,70}}, [11] = {{110,70}, {111,71}},
                                [29] = {{109,69}}, [26] = {{101,71}}, [22] = {{111,69}}, [14] = {{108,72}, {109,71}}, [34] = {{109,73}} },


--[[ Cardiff ]]         [55] = {[15] = {{130,60}}, [6]  = {{126,48}}, [5]  = {{132,60}}, [4]  = {{129,63}, {130,64}}, [25] = {{136,62}},
                                [16] = {{129,61}}, [12]  = {{124,44}}, [10] = {{130,66}}, [11] = {{131,61}, {130,62}},
                                [29] = {{128,62}}, [26] = {{131,57}}, [22] = {{132,66}}, [14] = {{132,62}, {132,64}}, [34] = {{131,65}} },


--[[ Liverpool ]]       [56] = {[15] = {{137,45}}, [6]  = {{133,45}}, [5]  = {{137,43}}, [4]  = {{140,42}, {141,43}}, [25] = {{141,49}},
                                [16] = {{138,46}}, [12]  = {{136,50}}, [10] = {{140,46}}, [11] = {{142,42}, {141,41}},
                                [29] = {{139,47}}, [26] = {{145,51}}, [22] = {{141,47}}, [14] = {{141,45}, {142,44}}, [34] = {{149,43}} },


--[[ Birmingham ]]      [57] = {[15] = {{147,55}}, [6]  = {{146,52}}, [5]  = {{153,55}}, [4]  = {{147,53}, {148,52}}, [25] = {{162,56}},
                                [16] = {{148,56}}, [12]  = {{150,50}}, [10] = {{152,56}}, [11] = {{151,53}, {149,53}},
                                [29] = {{149,57}}, [26] = {{150,58}}, [22] = {{151,57}}, [14] = {{149,51}, {151,51}} },


--[[ Manchester ]]      [58] = {[15] = {{148,44}}, [6]  = {{157,43}}, [5]  = {{150,46}}, [4]  = {{149,45}, {150,44}}, [25] = {{158,46}},
                                [16] = {{149,43}}, [12]  = {{155,37}}, [10] = {{152,46}}, [11] = {{153,43}, {152,44}},
                                [29] = {{148,42}}, [26] = {{149,39}}, [22] = {{154,42}}, [14] = {{150,40}, {151,41}} },


--[[ Nottingham ]]      [59] = {[15] = {{163,51}}, [6]  = {{164,54}}, [5]  = {{164,50}}, [4]  = {{162,48}, {163,49}}, [25] = {{175,51}},
                                [16] = {{162,50}}, [12]  = {{162,44}}, [10] = {{165,51}}, [11] = {{164,46}, {165,47}},
                                [29] = {{161,49}}, [26] = {{170,50}}, [22] = {{166,50}}, [14] = {{166,48}, {165,49}} },


--[[ Sheffield ]]       [60] = {[15] = {{167,39}}, [6]  = {{167,43}}, [5]  = {{165,41}}, [4]  = {{166,40}, {166,42}}, [25] = {{174,40}},
                                [16] = {{168,38}}, [12]  = {{168,44}}, [10] = {{164,42}}, [11] = {{168,40}, {166,42}},
                                [29] = {{169,39}}, [26] = {{172,44}}, [22] = {{165,43}}, [14] = {{169,43}, {169,41}} },


--[[ Colchester ]]      [61] = {[15] = {{192,62}}, [6]  = {{199,63}}, [5]  = {{190,66}}, [4]  = {{191,65}, {192,64}}, [25] = {{187,65}},
                                [16] = {{191,63}}, [12]  = {{194,60}}, [10] = {{191,67}}, [11] = {{191,67}, {192,66}},
                                [29] = {{190,64}}, [26] = {{190,60}}, [22] = {{192,68}}, [14] = {{193,63}, {194,64}} },


--[[ Hull ]]            [62] = {[15] = {{178,42}}, [6]  = {{181,37}}, [5]  = {{180,46}}, [4]  = {{180,44}, {179,43}}, [25] = {{177,41}},
                                [16] = {{179,41}}, [12]  = {{178,48}}, [10] = {{183,45}}, [11] = {{181,41}, {180,42}},
                                [29] = {{180,40}}, [26] = {{187,51}}, [22] = {{184,44}}, [14] = {{183,43}, {182,42}}, [34] = {{181,45}} },


--[[ Newcastle ]]       [63] = {[15] = {{173,27}}, [6]  = {{163,25}}, [5]  = {{168,26}}, [4]  = {{171,25}, {170,26}}, [25] = {{167,21}},
                                [16] = {{173,29}}, [12]  = {{168,20}}, [10] = {{169,25}}, [11] = {{168,28}, {169,27}},
                                [29] = {{172,30}}, [26] = {{160,26}}, [22] = {{170,24}}, [14] = {{170,30}, {171,29}}, [34] = {{172,26}} },

--[[ Edinburgh ]]       [64] = {[15] = {{162,10}}, [6]  = {{162,6}}, [5]  = {{162,16}}, [4]  = {{165,13}, {164,14}}, [25] = {{158,14}},
                                [16] = {{164,10}}, [12]  = {{174,2}}, [10] = {{164,16}}, [11] = {{161,11}, {160,12}},
                                [29] = {{165,11}}, [26] = {{156,16}}, [22] = {{165,15}}, [14] = {{161,15}, {162,14}}, [34] = {{164,12}} },


--[[ Glasgow ]]         [65] = {[15] = {{134,10}}, [6]  = {{133,19}}, [5]  = {{137,9}}, [4]  = {{135,13}, {136,12}}, [25] = {{142,12}},
                                [16] = {{135,9}}, [12]  = {{145,17}}, [10] = {{138,8}}, [11] = {{138,10}, {139,11}},
                                [29] = {{136,8}}, [26] = {{142,8}}, [22] = {{139,9}}, [14] = {{138,14}, {139.13}}, [34] = {{135,11}} },


--[[ Belfast ]]         [66] = {[15] = {{113,21}}, [6]  = {{107,17}}, [5]  = {{111,25}}, [4]  = {{113,23}, {112,24}}, [25] = {{108,20}},
                                [16] = {{114,20}}, [12]  = {{115,19}}, [10] = {{113,25}}, [11] = {{110,22}, {111,23}},
                                [29] = {{115,21}}, [26] = {{114,26}}, [22] = {{114,24}}, [14] = {{110,24}, {109,23}}, [34] = {{114,22}} },
                                
                               
--[[ Leeds ]]           [68] = {[15] = {{165,33}}, [6]  = {{158,34}}, [5]  = {{163,31}}, [4]  = {{166,34}, {167,33}}, [25] = {{164,36}},
                                [16] = {{164,34}}, [12]  = {{164,28}}, [10] = {{164,30}}, [11] = {{168,32}, {167,31}},
                                [29] = {{163,33}}, [26] = {{170,36}}, [22] = {{165,29}}, [14] = {{164,32}, {165,31}} },
                                
--[[ Carlisle ]]        [67] = {[15] = {{149,23}}, [6]  = {{147,25}}, [5]  = {{155,23}}, [4]  = {{151,23}, {151,25}}, [25] = {{155,21}},
                                [16] = {{150,24}}, [12]  = {{156,24}}, [10] = {{154,24}}, [11] = {{152,22}, {153,23}},
                                [29] = {{149,25}}, [26] = {{153,29}}, [22] = {{155,25}}, [14] = {{152,26}, {153,25}} },
                                
--[[ Lille ]]           [45] = {[15] = {{212,84}}, [6]  = {{213,95}}, [5]  = {{209,87}}, [4]  = {{213,87}, {212,88}}, [25] = {{216,84}},
                                [16] = {{211,85}}, [12]  = {{208,94}}, [10] = {{210,88}}, [11] = {{213,85}, {212,86}},
                                [29] = {{210,86}}, [26] = {{219,91}}, [22] = {{211,89}}, [14] = {{211,89}, {210,88}} },
                      
--[[ Dover ]]           [99] = {[15] = {{183,73}}, [6]  = {{178,74}}, [5]  = {{184,74}}, [4]  = {{186,74}}, [25] = {{181,73}},
                                [16] = {{182,74}}, [12]  = {{184,68}}, [10] = {{185,73}}, [11] = {{187,75}},
                                [29] = {{183,75}}, [26] = {{180,72}}, [22] = {{187,73}}, [14] = {{188,74}}, [34] = {{186,76}} },






}

-- Defines relationships between improvements, units, and terrain types
-- ID numbers are used for table keys and values so we don't have to worry about renamed improvements, unit types, or terrain types
-- All of this information applies to all cities, and therefore shouldn't need to be edited when cities are added/updated in the "cityCoordinates" table
--[[ structure by Knighttime ]]
local improvementUnitTerrainLinks = {
								-- Key is an improvement ID
--[[ Industry I ]]				[15] = {unitTypeId=45, buildTerrainTypeMap0=8, buildTerrainTypeMap1=8, buildTerrainTypeMap2=4, destroyTerrainTypeMap0=14, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=12},
--[[ Industry II ]]				[16] = {unitTypeId=46, buildTerrainTypeMap0=8, buildTerrainTypeMap1=8,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=14, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=12},
--[[ Industry III ]]			[29] = {unitTypeId=47, buildTerrainTypeMap0=8, buildTerrainTypeMap1=8,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=14, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=12},

--[[ Aircraft Factory I ]]		[6]  = {unitTypeId=85, buildTerrainTypeMap0=8, buildTerrainTypeMap1=8,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=14, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=12},
--[[ Aircraft Factory II ]]		[12] = {unitTypeId=86, buildTerrainTypeMap0=8, buildTerrainTypeMap1=8,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=14, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=12},
--[[ Aircraft Factory III ]]	[26] = {unitTypeId=87, buildTerrainTypeMap0=8, buildTerrainTypeMap1=8,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=14, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=12},

--[[ Fuel Refinery I ]]			[5]  = {unitTypeId=88, buildTerrainTypeMap0=6, buildTerrainTypeMap1=6,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=12, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=12},
--[[ Fuel Refinery II ]]		[10] = {unitTypeId=89, buildTerrainTypeMap0=6, buildTerrainTypeMap1=6,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=12, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=12},
--[[ Fuel Refinery III ]]		[22] = {unitTypeId=90, buildTerrainTypeMap0=6, buildTerrainTypeMap1=6,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=12, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=12},

--[[ Civilian Population I ]]	[4]  = {unitTypeId=91, buildTerrainTypeMap0=4, buildTerrainTypeMap1=4,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=13, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=11},
--[[ Civilian Population II ]]	[11] = {unitTypeId=92, buildTerrainTypeMap0=4, buildTerrainTypeMap1=4,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=13, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=11},
--[[ Civilian Population III ]]	[14] = {unitTypeId=93, buildTerrainTypeMap0=4, buildTerrainTypeMap1=4,  buildTerrainTypeMap2=4, destroyTerrainTypeMap0=13, destroyTerrainTypeMap1=11, destroyTerrainTypeMap2=11},

--[[ Railyards ]]				[25] = {unitTypeId=7,  buildTerrainTypeMap0=1, buildTerrainTypeMap1=nil,  buildTerrainTypeMap2=1, destroyTerrainTypeMap0=11, destroyTerrainTypeMap1=nil, destroyTerrainTypeMap2=8},
--[[ Military Port ]]			[34] = {unitTypeId=19, buildTerrainTypeMap0=nil, buildTerrainTypeMap1=nil,  buildTerrainTypeMap2=nil, destroyTerrainTypeMap0=nil, destroyTerrainTypeMap1=nil, destroyTerrainTypeMap2=nil},
--[[Critical Industry]]         [improvementAliases.criticalIndustry.id] = {unitTypeId=unitAliases.SpecialTarget.id,buildTerrainTypeMap0=nil, buildTerrainTypeMap1=nil,  buildTerrainTypeMap2=nil, destroyTerrainTypeMap0=nil, destroyTerrainTypeMap1=nil, destroyTerrainTypeMap2=nil},
}



-- help.helpKey tables and definitions
-- This table changes the text displayed when the help key is pressed 
-- for units that have the corresponding attribute.
local OTRFlagTextTable ={
[1] = "Two space visibility",
[2] = "Ignore zones of control",
[3] = "Can make amphibious assaults",
[4] = "Hard to spot at night",--"Submarine advantages/disadvantages",
[5]= "Can attack air units (fighter)",
[6]= "Ship must stay near land (trireme)",
[7]= "Negates city walls (howitzer)",
[8]= "Can carry air units (carrier)",
[9]= "Can make paradrops",
[10]= "Alpine (treats all squares as road)",
[11]= "x2 on defense versus horse (pikemen)",
[12]= "Free support for fundamentalism (fanatics)",
[13]= "Destroyed after attacking (missiles)",
[14]= "x5 on defense versus munitions",--"x2 on defense versus air (AEGIS)",
[15]= "",--"Unit can spot submarines",
}
--help.helpKey(keyID,specialNumbers.helpKeyID,OTRFlagTextTable,OTRUnitTypeTextTable,OTRUnitTextFunction)


-- this table is for extra text to be displayed when the help key is pressed, indexed by unittype.id
-- of the corresponding unit.
local OTRUnitTypeTextTable ={

[unitAliases.V1Launch.id] = [[Can launch V1 buzz bombs by pressing 'k' if on 'installation' terrain.]],
[unitAliases.V2Launch.id] = [[Can launch V2 rockets by pressing 'k' if on 'installation' terrain.]],
[unitAliases.Photos.id] = [[Used to take photographs (investigate city) of enemy airfields and cities.]],
[unitAliases.Window.id] = [[Throws up a false radar signature, confusing German defenders.]],
[unitAliases.EarlyRadar.id] = [[Detects nearby aircraft with keystroke. Primary=Day, Secondary=Night.]],
[unitAliases.AdvancedRadar.id] = [[Detects nearby aircraft with keystroke. Primary=Day, Secondary=Night.]],
[unitAliases.Fw200.id] = [[Used to hunt for Allied convoys. Primary=1x 250lb bomb. Fuel cost = 20]],
[unitAliases.Sunderland.id] = [[Used to hunt for German wolfpacks. Primary=1x 250lb bomb. Fuel cost = 20]],
[unitAliases.Sdkfz.id] = [[Has powerful ammunition to attack low-flying aircraft.]],
[unitAliases.GermanFlak.id] = [[Fires flak: Primary=daylight, Secondary=night. Backspace=all flaks fire.]],
[unitAliases.FlakTrain.id] = [[Travels along railroads. Fires flak bursts: Primary=daylight, Secondary=night.]],
[unitAliases.Me109G6.id] = [[Escort. Can land on carriers. Primary=light ammo 2x per turn. Fuel cost = 5]],
[unitAliases.Me109G14.id] = [[Escort. Can land on carriers. Primary=light ammo 2x per turn. Fuel cost = 5]],
[unitAliases.Me109K4.id] = [[Escort. Can land on carriers. Primary=light ammo 2x per turn. Fuel cost = 5]],
[unitAliases.Fw190A5.id] = [[Primary=medium ammo 3x per turn. Fuel cost = 5]],
[unitAliases.Fw190A8.id] = [[Primary=heavy gunfire 3x per turn. Secondary=1x A2A Rockets. Fuel cost = 5]],
[unitAliases.Fw190D9.id] = [[Primary=medium ammo 3x per turn. Fuel cost = 5]],
[unitAliases.Ta152.id] = [[Primary=medium ammo 3x per turn. Fuel cost = 5]],
[unitAliases.Me110.id] = [[Primary=Rockets 1x per turn. Bombers won't shoot back. Fuel cost = 10]],
[unitAliases.Me410.id] = [[Primary=Rockets 1x per turn. Bombers won't shoot back. Fuel cost = 10]],
[unitAliases.Ju88C.id] = [[Primary=medium ammo 2x per turn. Secondary=A2A Rockets in Daylight. Fuel cost = 10]],
[unitAliases.Ju88G.id] = [[Primary=medium ammo 2x per turn. SecondaryDay=A2A Rockets Night=Radar 4x. Fuel cost = 10]],
[unitAliases.He219.id] = [[Primary=medium ammo 2x per turn. SecondaryDay=A2A Rockets Night=Radar 4x. Fuel cost = 10]],
[unitAliases.He162.id] = [[Jet fighter. Primary=heavy ammo 10x per turn. Fuel cost = 25]],
[unitAliases.Me163.id] = [[Very short-range rocket fighter. Primary=heavy ammo 10x per turn. Fuel cost = 40]],
[unitAliases.Me262.id] = [[Jet. Primary=heavy ammo 10x per turn. Secondary=1x A2A Rockets. Fuel cost = 50]],
[unitAliases.Ju87G.id] = [[Low-alt. Can land on carriers. Primary= 1x 1000lb bomb. Fuel cost = 5]],
[unitAliases.Fw190F.id] = [[Low-alt. Primary=medium ammo 2x per turn. Secondary=1x 1000lb bomb. Fuel cost = 5]],
[unitAliases.Do335.id] = [[Low-alt. Primary=medium ammo 2x per turn. Secondary=2x 1000lb bomb. Fuel cost = 5]],
[unitAliases.He111.id] = [[Primary=2x 250lb bomb. Fuel cost = 10]],
[unitAliases.Do217.id] = [[Primary=3x 250lb bomb. Fuel cost = 10]],
[unitAliases.He277.id] = [[Primary=3x 500lb bomb. Fuel cost = 20]],
[unitAliases.Arado234.id] = [[Primary=3x 500lb bomb. Fuel cost = 50]],
[unitAliases.Go229.id] = [[Primary=3x 1000lb bomb. Fuel cost = 50]],
[unitAliases.SpitfireIX.id] = [[Escort. Can land on carriers. Primary=heavy gunfire 2x per turn. Fuel cost = 5]],
[unitAliases.SpitfireXII.id] = [[Escort. Can land on carriers. Primary=heavy gunfire 2x per turn. Fuel cost = 5]],
[unitAliases.SpitfireXIV.id] = [[Escort. Can land on carriers. Primary=heavy gunfire 2x per turn. Fuel cost = 5]],
[unitAliases.HurricaneIV.id] = [[Low-alt. Lands on carriers. Primary=2x med. ammo. Second=1x 500lb. Fuel cost = 5]],
[unitAliases.Typhoon.id] = [[Low-alt. Primary=heavy gunfire 2x per turn. Secondary=1x 1000lb bomb. Fuel cost = 5]],
[unitAliases.Tempest.id] = [[Low-alt. Primary=heavy gunfire 2x per turn. Secondary=2x 10000lb bomb. Fuel cost = 5]],
[unitAliases.Meteor.id] = [[Jet fighter. Primary=heavy ammo 10x per turn. Fuel cost = 50]],
[unitAliases.Beaufighter.id] = [[Primary=medium ammo 2x per turn. Fuel cost = 10]],
[unitAliases.MosquitoII.id] = [[Primary=medium ammo 2x per turn. Secondary=250lb bomb 1x per sortie. Fuel cost = 10]],
[unitAliases.MosquitoXIII.id] = [[Primary=medium ammo 2x per turn. Secondary=500lb bomb 1x per sortie. Fuel cost = 10]],
[unitAliases.P47D11.id] = [[Escort. Primary=light ammo 2x per turn. Secondary-1x 250lb bomb. Fuel cost = 5]],
[unitAliases.P47D25.id] = [[Escort. Primary=light ammo 2x per turn. Secondary=1x 500lb bomb. Fuel cost = 5]],
[unitAliases.P47D40.id] = [[Escort. Primary=light ammo 2x per turn. Secondary=2x 500lb bomb. Fuel cost = 5]],
[unitAliases.P38L.id] = [[Interceptor - meant to attack fighters. Primary=medium ammo 3x per turn. Fuel cost = 10]],
[unitAliases.P38H.id] = [[Interceptor - meant to attack fighters. Primary=medium ammo 3x per turn. Fuel cost = 10]],
[unitAliases.P38J.id] = [[Interceptor - meant to attack fighters. Primary=medium ammo 3x per turn. Fuel cost = 10]],
[unitAliases.P51B.id] = [[Tremendous range.  Escort. Primary=light ammo 2x per turn. Fuel cost = 5]],
[unitAliases.P51D.id] = [[Tremendous range.  Escort. Primary=light ammo 2x per turn. Fuel cost = 5]],
[unitAliases.P80.id] = [[Jet fighter. Primary=heavy ammo 10x per turn. Fuel cost = 50]],
[unitAliases.Stirling.id] = [[Primary=2x 250lb bomb.  Fuel cost = 20]],
[unitAliases.Halifax.id] = [[Primary=3x 250lb bomb. Fuel cost = 20]],
[unitAliases.Lancaster.id] = [[Primary=3x 500lb bomb. Fuel cost = 20]],
[unitAliases.Pathfinder.id] = [[Primary=Deploys 'window' countermeasures 7x per turn to confuse enemy radar.]],
[unitAliases.A20.id] = [[Primary=2x 250lb bomb. Fuel cost = 10]],
[unitAliases.B26.id] = [[Primary=2x 250lb bomb. Fuel cost = 10]],
[unitAliases.A26.id] = [[Primary=3x 250lb bomb. Fuel cost = 10]],
[unitAliases.B17F.id] = [[High Alt. Primary=2x 250lb bomb. Fuel cost = 20. Survives first defeat.]],
[unitAliases.B24J.id] = [[High Alt. Primary=2x 500lb bomb. Fuel cost = 20.]],
[unitAliases.B17G.id] = [[High Alt. Primary=3x 250lb bomb. Fuel cost = 20. Survives first defeat.]],
[unitAliases.damagedB17F.id] = [[Return to base to transfer crew to new bomber.]],
[unitAliases.damagedB17G.id] = [[Return to base to transfer crew to new bomber.]],
[unitAliases.MedBombers.id] = [[High Alt. Primary=3x 250lb bomb. Fuel cost = 20]],
[unitAliases.RedTails.id] = [[Very strong escort. Primary=light ammo 2x per turn. Fuel cost = 5]],
[unitAliases.Yak3.id] = [[Low-alt. Primary=medium ammo 2x per turn. Fuel cost = 5]],
[unitAliases.Il2.id] = [[Low-alt. Primary=2x 1000lb bomb. Fuel cost = 5]],
[unitAliases.MossiePR.id] = [[Photo recon.  Primary=camera (spy) 2x per turn. Camera investigates cities.]],
[unitAliases.Ju188.id] = [[Photo recon.  Primary=camera (spy) 2x per turn. Camera investigates cities.]],
[unitAliases.AlliedFlak.id] = [[Fires flak: Primary=daylight, Secondary=night. Backspace=all flaks fire.]],
[unitAliases.GermanLightFlak.id] = [[Used to defend airfields from strafing. Fires low-alt, powerful flak.]],
[unitAliases.AlliedLightFlak.id] = [[Used to defend airfields from strafing. Fires low-alt, powerful flak.]],
[unitAliases.GunBattery.id] = [[Fires ammo at distant targets by pressing 'k.']],
[unitAliases.Convoy.id] = [[Bring to port and press 'k' to stockpile supplies to launch D-Day.]],
[unitAliases.FreightTrain.id] = [[Travels on railroads.  Disband in airfields to quickly build aircraft.]],
[unitAliases.GermanTaskForce.id] = [[Primary=Barrage for ground/sea attack.]],
[unitAliases.AlliedTaskForce.id] = [[Primary=Barrage for ground/sea attack.]],
[unitAliases.Carrier.id] = [[Carries certain aircraft (109s, Ju87, Spitfires, Hurricanes).]],
[unitAliases.UBoat.id] = [[Used to attack convoys. Fires torpedos 2x per turn.]],
[unitAliases.GermanArmyGroup.id] = [[Used to take cities. Can fire barrage 1x per turn.]],
[unitAliases.GermanBatteredArmyGroup.id] = [[Used to take cities. Can fire barrage 1x per turn.]],
[unitAliases.RedArmyGroup.id] = [[Used to take cities. Can fire barrage 1x per turn.]],
[unitAliases.AlliedArmyGroup.id] = [[Used to take cities. Can fire barrage 1x per turn.]],
[unitAliases.AlliedBatteredArmyGroup.id] = [[Used to take cities. Can fire barrage 1x per turn.]],
[unitAliases.EgonMayer.id] = [[The Luftwaffe's finest experten are a match for all. Primary=medium ammo 4x per turn. Secondary=2xA2A Roc.]],
[unitAliases.HermannGraf.id] = [[Best defensive Luftwaffe unit in game. Primary=medium ammo 4x per turn. Secondary=A2A Roc.]],
[unitAliases.JosefPriller.id] = [[The Luftwaffe's finest experten are a match for all. Primary=medium ammo 5x per turn. Secondary=A2A Roc.]],
[unitAliases.hwSchnaufer.id] = [[Only German Experten that can escape into night. Primary=medium ammo 4x per turn. Secondary=A2A Roc.]],
[unitAliases.AdolfGalland.id] = [[Half cost for jet attacks. Primary=heavy ammo 10x per turn.  Secondary=A2A Roc.]],
[unitAliases.Experten.id] = [[Experten pilot.  Use first for interceptions.  Few aircraft will react. Primary=heavy ammo 5x per turn.]],
[unitAliases.RAFAce.id] = [[Ace pilot.  Use first for interceptions.  Few aircraft will react. Primary=heavy ammo 3x per turn.]],
[unitAliases.USAAFAce.id] = [[Ace pilot.  Use first for interceptions.  Few aircraft will react. Primary=heavy ammo 3x per turn.]],
}


-- this function give information for the helpKey function to display that specifically
-- depends on the unit for which help was asked.  It currently gives the hp of the unit and the
-- distance to the nearest airfield for air units.
local function OTRUnitTextFunction(unit)
    local unitHPofMax = tostring(unit.hitpoints).." of "..tostring(unit.type.hitpoints).." Hit Points remaining."
    local nearestAirfield = nil
    local distanceToAirfield = 1000
    local function distance(tile1,tile2)
           return math.ceil((math.abs(tile1.x-tile2.x)+math.abs(tile1.y-tile2.y))/2)
        end
    for airfield in civ.iterateCities() do
        if airfield.owner == unit.owner and civ.hasImprovement(airfield,civ.getImprovement(17)) and 
            distance(airfield.location,unit.location) < distanceToAirfield then
                nearestAirfield = airfield
                distanceToAirfield = distance(airfield.location,unit.location)
        end
    end -- for city in civ.iterateCities()
    local nearestAirfieldText = " "
    if unit.type.domain == 1 then
        nearestAirfieldText = "No friendly airfield found."
        if nearestAirfield then
            nearestAirfieldText = "Nearest airfield is "..nearestAirfield.name.." at a distance of "..tostring(distanceToAirfield).."."
        end
    end
    return unitHPofMax.."  "..nearestAirfieldText
end--OTRUnitTextFunction
            
-- Radar Tables

-- Radar functionality will be governed by 2 tables, radarUserDetailsTable and radarIntruderDetailsTable
-- radarUserDetailsTable will deal mostly the radar using unit itself,
-- radarIntruderDetailsTable will deal with how units are detected (or not detected) by radar

-- Radar User Details
-- Indexed by unit type id number
-- absent unit type means it is not a radar user of any kind
-- .keyCode = int ==> keyId for radar activation (specialNumbers.primaryAttackKey and specialNumbers.secondaryAttackKey )
-- .installationOnly = bool or nil
--      if true, radar can only be used on tile type 7
-- .baseRangeSchedule = integer or table of 'rangeThreshold's
--      where rangeThreshold = {threshold, rangeIncrease},  0<=threshold<=1, rangeIncrease = number > 0
--          A radar user's maximum range is determined by a 'random roll' between 0 and 1, lower being better for the radar user
--          If the roll is below the threshold of a rangeThreshold, add the rangeIncrease to the unit's radar range
--          If fractional range (after .baseRangeSchedule and techRangeBonus), then round down
--      If integer, use fixed base range regardless of 'Roll'
-- .techRangeBonus = {tech = technologyObject, rangeSchedule = table of rangeThreshold} or table of same
--      If the radar user has the technology corresponding to the technologyObject, merge the 
--      rangeSchedule into the baseRangeSchedule for determining the radar range
--      absent means no bonus for technologies    
-- Radar is assumed to work on the sameTime basis (i.e. either detects on the night map or on both day maps, depending on where the user is)
--  Override this with one of the following keys
-- .allMaps = true or false (nil means false)
--      If true, radar from this unit detects on all maps
-- .sameMap = true or false (nil means false)
--      if true, radar from this unit only detects on the same map (might be useful at sea or something)
-- .errorThresholdPerfect = number or table of {tech = technologyObject, bonus = number}
--      absent means specialNumbers.defaultErrorThresholdPerfect
-- .errorThresholdClose = number or table of {tech = technologyObject, bonus = number}
--      absent means errorThresholdPerfect * specialNumbers.defaultErrorThresholdCloseFactor
-- .errorThresholdDetected = number or table of {tech = technologyObject, bonus = number}
--      absent means errorThresholdClose * specialNumbers.defaultErrorThresholdDetectedFactor
--      The error thresholds are the basic tool for determining how 'good' the radar is.  
--      Although detection can be customized for each intruder type and radar user, setting defaults here
--      might be good enough for most cases.
--      see Radar Detectability Details for info on exactly how the thresholds are used

-- .radarReportTile = string
--      title for the radar report dialog, absent means use default
-- .radarDetectionMessage = string
--      message for the radar report dialog, when something is found, absent means use default
-- .radarNothingFoundMessage = string
--      message for the radar report dialog when nothing is found, absent means use default
-- .moveCost = integer cost for this unit to use radar
--local testingMoveCost = 0
-- if you use moveCost = testingMoveCost or 3
-- then the commenting out testingMoveCost sets the move cost to 3 instead of 0 (or whatever testingMoveCost is)  This way, probabilities can be tested without constant reloading or going through every table after the fact
textAliases.defaultRadarReportTitle = "Radar Station Report"
textAliases.defaultRadarDetected = "Radar detects enemies."
textAliases.defaultRadarNothingFound = "Radar detects no enemies."
local radarMarkerType = "railroad"
specialNumbers.defaultErrorThresholdPerfect = 1
specialNumbers.defaultErrorThresholdCloseFactor = 2
specialNumbers.defaultErrorThresholdDetectedFactor = 1.5
unitAliases.spotterUnit = unitAliases.Photos

log.setCombatMarkerParameters("pollution",civ.getTile(specialNumbers.radarSafeTile[1],specialNumbers.radarSafeTile[2],specialNumbers.radarSafeTile[3]),unitAliases.spotterUnit)

local techAliases = {}
techAliases.AdvancedRadarI = civ.getTech(17)
techAliases.AdvancedRadarII = civ.getTech(19)
techAliases.AdvancedRadarIII = civ.getTech(88)
techAliases.ProximityFuses = civ.getTech(83)
techAliases.FortiesI = civ.getTech(9) -- alias for 1940s Tech I
techAliases.NightFightersI = civ.getTech(13)
techAliases.NightFightersII = civ.getTech(14)
techAliases.NightFightersIII = civ.getTech(16)
techAliases.TacticsI = civ.getTech(90)
techAliases.TacticsII = civ.getTech(91)
techAliases.IndustryI = civ.getTech(61)
techAliases.IndustryII = civ.getTech(62)
techAliases.IndustryIII = civ.getTech(63)
techAliases.InterceptorsIII = civ.getTech(2)
techAliases.EscortFightersII = civ.getTech(4)
techAliases.EscortFightersIII = civ.getTech(6)
techAliases.Delays = civ.getTech(89)
techAliases.DeathOfAlbertSpeer = civ.getTech(95)
techAliases.CadillacOfTheSkies = civ.getTech(8)


local radarUserDetailsTable = {}
local RUDT = radarUserDetailsTable -- can use either form to make edits
RUDT[unitAliases.EarlyRadar.id] ={ keyCode = specialNumbers.primaryAttackKey,
installationOnly = true,
baseRangeSchedule = {{.5,2.5},{1,6}},
techRangeBonus = {{tech = techAliases.AdvancedRadarI, rangeSchedule = {{1, .5}}},
                  {tech = techAliases.AdvancedRadarII, rangeSchedule = {{1,1.5},{.25, 1.5}}}},
allMaps = true,
errorThresholdPerfect = 1,
errorThresholdClose = {{tech = techAliases.FortiesI, bonus = 2},{tech = techAliases.AdvancedRadarII, bonus = 1}},
errorThresholdDetected = {{tech = techAliases.FortiesI, bonus = 3},
                          {tech = techAliases.AdvancedRadarI, bonus = 1},
                          {tech = techAliases.AdvancedRadarII, bonus = 1},},
moveCost = testingMoveCost or 4,

}
RUDT[unitAliases.AdvancedRadar.id] ={ keyCode = specialNumbers.primaryAttackKey,
installationOnly = true,
baseRangeSchedule = {{.5,3},{1,10}},
techRangeBonus = {{tech = techAliases.AdvancedRadarI, rangeSchedule = {{1, 1}}},
                  {tech = techAliases.AdvancedRadarII, rangeSchedule = {{1,2},{.25, 1}}}},
allMaps = true,
errorThresholdPerfect = 1,
errorThresholdClose = {{tech = techAliases.FortiesI, bonus = 2},{tech = techAliases.AdvancedRadarII, bonus = 1}},
errorThresholdDetected = {{tech = techAliases.FortiesI, bonus = 3},
                          {tech = techAliases.AdvancedRadarI, bonus = 1},
                          {tech = techAliases.AdvancedRadarII, bonus = 1},},
moveCost = testingMoveCost or 4,

}
RUDT[unitAliases.Ju88G.id] ={ keyCode = specialNumbers.secondaryAttackKey,
baseRangeSchedule = {{.5,1},{1,2}},
techRangeBonus = {{tech = techAliases.AdvancedRadarI, rangeSchedule = {{1, 1}}},
                  {tech = techAliases.AdvancedRadarII, rangeSchedule = {{1,1}}}},
sameMap = true,
errorThresholdPerfect = 1,
errorThresholdClose = {{tech = techAliases.FortiesI, bonus = 2},{tech = techAliases.AdvancedRadarII, bonus = 1}},
errorThresholdDetected = {{tech = techAliases.FortiesI, bonus = 3},
                          {tech = techAliases.AdvancedRadarI, bonus = 1},
                          {tech = techAliases.AdvancedRadarII, bonus = 1},},
moveCost = testingMoveCost or 8,

}
RUDT[unitAliases.He219.id] ={ keyCode = specialNumbers.secondaryAttackKey,
baseRangeSchedule = {{.5,1},{1,3}},
techRangeBonus = {{tech = techAliases.AdvancedRadarI, rangeSchedule = {{1, 1}}},
                  {tech = techAliases.AdvancedRadarII, rangeSchedule = {{1,1}}}},
sameMap = true,
errorThresholdPerfect = 1,
errorThresholdClose = {{tech = techAliases.FortiesI, bonus = 2},{tech = techAliases.AdvancedRadarII, bonus = 1}},
errorThresholdDetected = {{tech = techAliases.FortiesI, bonus = 3},
                          {tech = techAliases.AdvancedRadarI, bonus = 1},
                          {tech = techAliases.AdvancedRadarII, bonus = 1},},
moveCost = testingMoveCost or 10,

}
RUDT[unitAliases.hwSchnaufer.id] ={ keyCode = specialNumbers.secondaryAttackKey,
baseRangeSchedule = {{.5,1},{1,3}},
techRangeBonus = {{tech = techAliases.AdvancedRadarI, rangeSchedule = {{1, 1}}},
                  {tech = techAliases.AdvancedRadarII, rangeSchedule = {{1,1}}}},
sameMap = true,
errorThresholdPerfect = 1,
errorThresholdClose = {{tech = techAliases.FortiesI, bonus = 2},{tech = techAliases.AdvancedRadarII, bonus = 1}},
errorThresholdDetected = {{tech = techAliases.FortiesI, bonus = 3},
                          {tech = techAliases.AdvancedRadarI, bonus = 1},
                          {tech = techAliases.AdvancedRadarII, bonus = 1},},
moveCost = testingMoveCost or 10,

}
--[[RUDT[unitAliases.MosquitoII.id] ={ keyCode = specialNumbers.secondaryAttackKey,
baseRangeSchedule = {{.5,1},{1,2}},
techRangeBonus = {{tech = techAliases.AdvancedRadarI, rangeSchedule = {{1, 1}}},
                  {tech = techAliases.AdvancedRadarII, rangeSchedule = {{1,1}}}},
sameMap = true,
errorThresholdPerfect = 1,
errorThresholdClose = {{tech = techAliases.FortiesI, bonus = 2},{tech = techAliases.AdvancedRadarII, bonus = 1}},
errorThresholdDetected = {{tech = techAliases.FortiesI, bonus = 3},
                          {tech = techAliases.AdvancedRadarI, bonus = 1},
                          {tech = techAliases.AdvancedRadarII, bonus = 1},},
moveCost = testingMoveCost or 8,

}]]
--[[RUDT[unitAliases.MosquitoXIII.id] ={ keyCode = specialNumbers.secondaryAttackKey,
baseRangeSchedule = {{.5,1},{1,3}},
techRangeBonus = {{tech = techAliases.AdvancedRadarI, rangeSchedule = {{1, 1}}},
                  {tech = techAliases.AdvancedRadarII, rangeSchedule = {{1,1}}}},
sameMap = true,
errorThresholdPerfect = 1,
errorThresholdClose = {{tech = techAliases.FortiesI, bonus = 2},{tech = techAliases.AdvancedRadarII, bonus = 1}},
errorThresholdDetected = {{tech = techAliases.FortiesI, bonus = 3},
                          {tech = techAliases.AdvancedRadarI, bonus = 1},
                          {tech = techAliases.AdvancedRadarII, bonus = 1},},
moveCost = testingMoveCost or 10,

}]]
-- In this example, the Early Radar unit has a base range of 6, with at 50% chance of detecting at a range of 8
-- (since ranges are rounded down)
-- If the civ has AdvancedRadarI, the base range is 6, with 50% chance of detecting at 9
-- if the civ has AdvandedRadarII, base range is 7, 50% chance of range 10, 25% chance of range 11
-- If both AdvancedRadar I and II, base range is 8, 50% chance of 10, 25% chance of 12

-- Early Radar detects on all maps

-- Additional technologies do not increase the (default) chance that Early Radar makes a perfect prediction of intruder
-- location
-- AdvancedRadarI reduces the chance of a false negative, but only at the 25 squares detection level
-- AdvancedRadarII increases the likelihood of detection and also the likelihood of predicting the intruder(s) to be
-- in the 9 square box around their true location.
-- Note: if technologies determine the thresholds, use a tech that both civs will always have in order to establish
-- a 'base' threshold




-- Radar Detectability Details
-- Indexed by the (possibly) detected unit's type id number
-- absent units are not detected by any radar

-- When a radar user 'sweeps' a tile containing units, a detection 'error number' will be calculated, 
-- compared with the error thresholds of the radar user, with the following consequences
-- If error number <= errorThresholdPerfect, then a radar marker is placed on that tile
-- If errorThresholdPerfect <error number <= errorThresholdClose, 
--          a radar marker is placed somewhere on the 3x3 diamond that surrounds the tile in question,
--              1 in 9 chance for each tile
-- If errorThresholdClose <error number <= errorThresholdDetected,
--          a radar marker is placed somewhere on the 5x5 diamond that surrounds the tile in question,
--              1 in 25 chance for each tile
-- if errorThresholdDetected < error number
--          then the radar reports a false negative
-- A false negative is also reported if the randomly chosen tile is outside the maximum range of the radar user

-- When the tile is swept, a random 'detection roll' is made (lower is better for the radar user).
-- Based on the 'detection roll', the radar user, and discovered technologies, a base 'detection error'
-- is computed for each unit (using the same random roll).  The unit with the base lowest detection error
-- (low detection error is good for radar user) defines the base detection error number of the tile
-- in addition, each unit may have some 'volume detectability', which is subtracted off the base detection error
-- (this way, one plane might slip by, but 20 will probably be noticed, unless they have very low volume detectability)

-- errorThreshold = {threshold, errorIncrease}
--      if detection roll > threshold, add errorIncrease to the aircraft's detection error
--      (this way, lower roll means better for radar user)
-- errorSchedule is a table of errorThresholds

-- A unit's detectability details have the following entries
-- .baseError = errorSchedule
--      This is the error schedule used in the absence of a custom error schedule for the radar user

-- .customError = {detectors = tableOfUnitTypes, errorSchedule = errorSchedule} or table of same
--      If the radar user's unit type is in the tableOfUnitTypes, use the corresponding damage schedule
--      instead of the .baseError
--      nil means always use base error

-- .volumePenalty = num
--      reduce detection error for the tile by volumePenalty, regardless of whether this unit is the
--      'most detectable' or not
--      nil means volume penalty is 0

-- .radarTech = {tech = technologyObject, detectors = tableOfUnitTypes, errorSchedule = errorSchedule, volumeMod = num, counterTo = TechnologyObject} or table of same
--      if the radar user's tribe has the technology, and the radar user's type is in tableOfUnitTypes
--      then combine the corresponding error schedule with the baseError (or customError) schedule
--      since the radar user's technologies should increase radar effectiveness, the errorIncrease
--      should probably be negative
--      increase the volumePenalty by volumeMod (volumeMod absent means no change)
--      counterTo means apply this bonus only if the intruder has this technology, nil means always apply
--      nil means no change to base/custom error
--
-- .intruderTech = {tech = technologyObject, detectors = tableOfUnitTypes, errorSchedule = errorSchedule, volumeMod = num, counterTo = TechnologyObject} or table of same
--      if the intruder unit's (the unit being detected) tribe has the technology, and the radar user is in
--      the tableOfUnitTypes, merge the errorSchedule with the base/custom error schedule
--      increase the volumePenalty by volumeMod (probably negative, since the intruder's technologies should probably make detection harder) (absent means no penalty/bonus)
--      counterTo means apply this bonus only if the radarUser has this technology, nil means apply always
--      nil means no change to base/custom error

local intruder = {}
intruder.radarInvisible = { baseError = {{0,50}},}
intruder.alwaysSpotted = {baseError = {{0,0}},}

local radarIntruderDetailsTable = {}
local RIDT = radarIntruderDetailsTable
RIDT[unitAliases.Stirling.id] = {baseError = {{.25, 1.2},{.5, 2},{.75, 2}}, --****** NEED TO FILL OUT EVERYTHING HERE - ONLY HAVE UNIT NAMES
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersI, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar, unitAliases.Ju88G,unitAliases.He219}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersI, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersI},
}
            RIDT[unitAliases.Halifax.id] = {baseError = {{.25, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersII},

				
}
RIDT[unitAliases.Lancaster.id] = {baseError = {{.25, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersIII},

				
}
RIDT[unitAliases.Beaufighter.id] = {baseError = {{.15, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersI, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersI, detectors = {unitAliases.EarlyRadar, unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersI},

				
}
RIDT[unitAliases.MosquitoII.id] = {baseError = {{.10, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar, unitAliases.Ju88G,unitAliases.He219},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersII},

				
}
RIDT[unitAliases.MosquitoXIII.id] = {baseError = {{.05, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.Ju88G,unitAliases.He219},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersIII},

				
}
RIDT[unitAliases.He111.id] = {baseError = {{.25, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersI, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersI, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersI},

				
}
RIDT[unitAliases.Do217.id] = {baseError = {{.25, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersII, detectors = {unitAliases.EarlyRadar, unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersII},

				
}
RIDT[unitAliases.He277.id] = {baseError = {{.25, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersIII},

				
}
RIDT[unitAliases.Ju88C.id] = {baseError = {{.15, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersI, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersI, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersI},

				
}
RIDT[unitAliases.Ju88G.id] = {baseError = {{.10, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar, unitAliases.MosquitoII,unitAliases.MosquitoXIII},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersII},

				
}
RIDT[unitAliases.He219.id] = {baseError = {{.05, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersIII},

				
}
RIDT[unitAliases.hwSchnaufer.id] = {baseError = {{.05, 1.2},{.5, 2},{.75, 2}},
volumePenalty = 0.07,
radarTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII}, 
                errorSchedule = {{0,-2},{.75,2}}, volumePenalty = 0.03},
intruderTech = {tech = techAliases.NightFightersIII, detectors = {unitAliases.EarlyRadar,unitAliases.AdvancedRadar,unitAliases.MosquitoII,unitAliases.MosquitoXIII},
                errorSchedule = {{0,2},{.75,-2}}, volumePenalty = -0.03, counterTo = techAliases.NightFightersIII},

				
}

RIDT[unitAliases.MossiePR.id] = intruder.radarInvisible
RIDT[unitAliases.Ju188.id] = intruder.radarInvisible
RIDT[unitAliases.Arado234.id] = intruder.radarInvisible
RIDT[unitAliases.Go229.id] = intruder.radarInvisible
RIDT[unitAliases.Me262.id] = intruder.radarInvisible
RIDT[unitAliases.He162.id] = intruder.radarInvisible
RIDT[unitAliases.Me163.id] = intruder.radarInvisible
RIDT[unitAliases.P80.id] = intruder.radarInvisible
RIDT[unitAliases.Meteor.id] = intruder.radarInvisible
RIDT[unitAliases.neutralTerritory.id]=intruder.radarInvisible


-- All air units not otherwise included in RIDT are included as 'always spotted' (including munitions, though this probably doesn't matter)
for i=0,130 do
    if civ.getUnitType(i) and civ.getUnitType(i).domain == 1 and RIDT[i] == nil then
        RIDT[i] = intruder.alwaysSpotted
    end
end


-- If the detection roll is 0-.25 the Stirling's base error is 0, so it will be detected perfectly by Early Radar
-- roll .25-.5, base detection is 1.2, so the Stirling is detected, but only within 1 square, unless 3+ Stirlings are in the square
-- roll .5-.75, base detection is 3.2, so Stirling not detected unless 3 or more in square or AdvancedRadar I or II is discovered
-- roll .75-1, base detection is 5.2, so Stirlings not detected by example early radar unless 3+ in square and all advances (or a lot of planes in square)
-- if EarlyRadar user has NightFightersI, then base error is reduced by 2 for all rolls between 0 and .75 (basically, if Stirling is detected, it is detected pretty accurately, especially if 2 or more on square)
-- Also, Nightfighters increase volume detection by 0.03, so 2 Stirlings increase detection (by falling below integer) instead of 3 
-- if the Stirling owner has NightFightersI, the effect of the Radar User's NightFighersI is eliminated (i.e. the Stirlings have a good idea of the tactics/technology that increases detection and have employed countermeasures), but the bonus is not applied if the enemy doesn't have NightFightersI (i.e. they're using countermeasures for specific tactics/technology, not generally improving stealth) 







-- functions to specify radar

local function getRadarRangeFromSchedule(rangeSchedule,rangeRoll)
    if type(rangeSchedule) == 'number' then
        -- case where range is fixed
        return rangeSchedule
    end
    local range = 0
    for __,rangeThreshold in pairs(rangeSchedule) do
        if rangeRoll <= rangeThreshold[1] then
            range = range + rangeThreshold[2]
        end
    end
    return range
end

local function radarRangeFunction(radarUser)
    local radarUserDetails = radarUserDetailsTable[radarUser.type.id]
    local maps = {}
    -- find the maps for the range
    if radarUserDetails.allMaps then
        maps = {0,1,2}
    elseif radarUserDetails.sameMap then
        maps = {radarUser.location.z}
    elseif radarUser.location.z == 2 then
        maps = {2}
    else
        maps = {0,1}
    end
    local rangeRoll = math.random()
    local range = getRadarRangeFromSchedule(radarUserDetails.baseRangeSchedule,rangeRoll)
    if radarUserDetails.techRangeBonus then
        if radarUserDetails.techRangeBonus.tech then
            if civ.hasTech(radarUser.owner,radarUserDetails.techRangeBonus.tech) then
                range = range + getRadarRangeFromSchedule(radarUserDetails.techRangeBonus.rangeSchedule,rangeRoll)
            end
        else
            for __,techBonus in pairs(radarUserDetails.techRangeBonus) do
                if civ.hasTech(radarUser.owner,techBonus.tech) then
                    range = range + getRadarRangeFromSchedule(techBonus.rangeSchedule,rangeRoll)
                end
            end
        end
    end--if radarUserDetails.techRangeBonus then
    return math.floor(range), maps
end
    

local function radarDetectionFunction(radarUser,tile,range)
    -- don't try to detect on tiles that are occupied by the Radar User's unit
    -- or which are unoccupied, or which are on cities
    if radarUser.owner == tile.defender or tile.defender == nil then
        return false
    elseif tile.city ~= nil then
        return false
    end
    local radarUserDetails = radarUserDetailsTable[radarUser.type.id]
    local function getErrorThreshold(errorThreshold)
        if errorThreshold == nil then
            return nil
        end
        if type(errorThreshold) == "number" then
            return errorThreshold
        end
        local val = 0
        for __,techBonus in pairs(errorThreshold) do
            if civ.hasTech(radarUser.owner,techBonus.tech) then
                val = val + techBonus.bonus
            end
        end
        return val
    end
    local function horizontalDistance(tileA,tileB)
        return math.floor((math.abs(tileA.x-tileB.x)+math.abs(tileA.y-tileB.y))/2)
        -- The floor aspect just makes sure that an integer is returned, e.g. 2 instead of 2.0
    end
    local errorThresholdPerfect = (getErrorThreshold(radarUserDetails.errorThresholdPerfect) or specialNumbers.defaultErrorThresholdPerfect)
    local errorThresholdClose = (getErrorThreshold(radarUserDetails.errorThresholdClose) 
            or errorThresholdPerfect*specialNumbers.defaultErrorThresholdCloseFactor)
    local errorThresholdDetected = (getErrorThreshold(radarUserDetails.errorThresholdDetected) 
            or errorThresholdClose*specialNumbers.defaultErrorThresholdDetectedFactor)
    local tileErrorNumber = 0
    local lowestBaseDetectionErrorSoFar = errorThresholdDetected*100
    local detectionRoll = math.random()
    -- if a value is in a table, return the index.  Otherwise, return false
    local function inTable(value,tableOfValues)
        for index,val in pairs(tableOfValues) do
            if val == value then
                return index
            end
        end
        return false
    end
    for unit in tile.units do
        if radarIntruderDetailsTable[unit.type.id] then
            local intruderDetails = radarIntruderDetailsTable[unit.type.id]
            -- apply the base volume penalty
            tileErrorNumber = tileErrorNumber - (intruderDetails.volumePenalty or 0)
            local unitBaseError = 0
            local noCustomErrorFound = true
            if intruderDetails.customError then
                if intruderDetails.customError.detectors then
                    if inTable(radarUser.type,intruderDetails.customError.detectors) then
                        noCustomErrorFound = false
                        for __,errorThreshold in pairs(intruderDetails.customError.errorSchedule) do
                            if detectionRoll >= errorThreshold[1] then
                                unitBaseError = unitBaseError + errorThreshold[2]
                            end
                        end
                    end
                else
                    -- 'table of' case
                    for __,CE in pairs(intruderDetails.customError) do
                        if inTable(radarUser.type,CE.detectors) then
                            noCustomErrorFound = false
                            for __,errorThreshold in pairs(CE.errorSchedule) do
                                if detectionRoll >= errorThreshold[1] then
                                    unitBaseError = unitBaseError + errorThreshold[2]
                                end
                            end
                        end
                    end--for __,CE in pairs(intruderDetails.customError) do
                end -- intruderDetails.customError.detectors then
            end -- if intruderDetails.customError then
            if noCustomErrorFound then
                for __,errorThreshold in pairs(intruderDetails.baseError) do
                    if detectionRoll >= errorThreshold[1] then
                        unitBaseError = unitBaseError + errorThreshold[2]
                    end
                end
            end--if noCustomErrorFound then
            local rTech = nil
            if intruderDetails.radarTech and intruderDetails.radarTech.tech then
                -- this way, I can don't have to use two cases
                rTech = {intruderDetails.radarTech}
            elseif intruderDetails.radarTech then
                rTech = intruderDetails.radarTech
            end
            if rTech then
                for __, techMod in pairs(rTech) do
                    if civ.hasTech(radarUser.owner,techMod.tech) and inTable(radarUser.type,techMod.detectors)
                        and(techMod.counterTo == nil or civ.hasTech(unit.owner, techMod.counterTo)) then
                        -- apply volumeMod penalty change
                        tileErrorNumber = tileErrorNumber - (techMod.volumeMod or 0)
                        for __,errorThreshold in pairs(techMod.errorSchedule) do
                            if detectionRoll >= errorThreshold[1] then
                                unitBaseError = unitBaseError+errorThreshold[2]
                            end
                        end
                    end
                end 
            end
            local iTech = nil
            if intruderDetails.intruderTech and intruderDetails.intruderTech.tech then
                iTech = {intruderDetails.intruderTech}
            elseif intruderDetails.intruderTech then
                iTech = intruderDetails.intruderTech
            end
            if iTech then
                for __,techMod in pairs(iTech) do
                    if civ.hasTech(unit.owner,techMod.tech) and inTable(radarUser.type, techMod.detectors) 
                        and(techMod.counterTo == nil or civ.hasTech(radarUser.owner, techMod.counterTo)) then
                        tileErrorNumber = tileErrorNumber - (techMod.volumeMod or 0)
                        for __, errorThreshold in pairs(techMod.errorSchedule) do
                            if detectionRoll >= errorThreshold[1] then
                                unitBaseError = unitBaseError + errorThreshold[2]
                            end
                        end
                    end
                end            
            end --if iTech then
            debugPrint(unit.type.name.." base Error is"..tostring(unitBaseError))
            lowestBaseDetectionErrorSoFar = math.min(lowestBaseDetectionErrorSoFar,unitBaseError)
        end -- if radarIntruderDetailsTable[unit.type.id] then
    end --  for unit in tile.units do          
    tileErrorNumber = tileErrorNumber + lowestBaseDetectionErrorSoFar
    if tileErrorNumber <= errorThresholdPerfect then
        return tile
    elseif errorThresholdPerfect < tileErrorNumber and tileErrorNumber <= errorThresholdClose then
        local nineSquares = {}
        radar.diamond(tile,1,nineSquares,false)
        local tileToReturn = nineSquares[math.random(1,#nineSquares)]
        if horizontalDistance(tileToReturn,radarUser.location) <= range then
            return tileToReturn
        else
            return false
        end
    elseif errorThresholdClose<tileErrorNumber and tileErrorNumber<=errorThresholdDetected then
        local twentyFiveSquares = {}
        radar.diamond(tile,2,twentyFiveSquares,false)
        local tileToReturn = twentyFiveSquares[math.random(1,25)]
        if horizontalDistance(tileToReturn, radarUser.location) <= range then
            return tileToReturn
        else
            return false
        end
    else
    -- case where error number greater than detection threshold
        return false
    end
end -- function radarDetectionFunction(radarUser,tile,range)
-- End of radar specification
--
--
-- Activate All Radar Stations (not Aircraft)
-- All movement points will be expended for these units
local groupRadarUnits ={}
groupRadarUnits[unitAliases.EarlyRadar.id] = true
groupRadarUnits[unitAliases.AdvancedRadar.id] = true

local function doAllRadar()
    local enemyDetected = false
    local detectedMessageBox = civ.ui.createDialog()
    local detectedArchiveText = ""
    detectedMessageBox:addText("Enemy aircraft detected by these stations:")
    detectedArchiveText = detectedArchiveText.."Enemy aircraft detected by these stations:"
    local function nearestCityAirbase(unit)
        local bestCitySoFar = nil
        local bestDistanceSoFar = math.huge
        local function dist(unit,city)
            local unitLoc = unit.location
            local cityLoc = city.location
            return math.abs(unitLoc.x-cityLoc.x)+math.abs(unitLoc.y-cityLoc.y)
        end
        for city in civ.iterateCities() do
            if dist(unit,city) < bestDistanceSoFar then
                bestDistanceSoFar = dist(unit,city)
                bestCitySoFar = city
            end
        end
        return bestCitySoFar
    end
    for unit in civ.iterateUnits() do
        if groupRadarUnits[unit.type.id] and unit.owner==civ.getCurrentTribe() 
            and unit.moveSpent == 0 and unit.location.terrainType % 16 == 7 then
            local stationResult = radar.radarSweep(unit,radarRangeFunction,radarDetectionFunction,
                            radarMarkerType,state.radarRemovalInfo,unitAliases.spotterUnit,
                            civ.getTile(specialNumbers.radarSafeTile[1],
                                        specialNumbers.radarSafeTile[2],
                                        specialNumbers.radarSafeTile[3]))
            if stationResult then
                local tileString = "("..tostring(unit.location.x)..","..tostring(unit.location.y)..")"
                detectedMessageBox:addText(func.splitlines("\n^"..tileString.." near "..nearestCityAirbase(unit).name))
                detectedArchiveText = detectedArchiveText.."\n^"..tileString.." near "..nearestCityAirbase(unit).name
            end
            enemyDetected = enemyDetected or stationResult
            unit.moveSpent = unit.type.move
        end
    end
    if enemyDetected then
        detectedMessageBox.title = "Air Defense Report"
        detectedMessageBox:show()
        text.addToArchive(civ.getCurrentTribe(),detectedArchiveText,"Air Defense Report","Air Defense Report")
    else
        local messageBox = civ.ui.createDialog()
        messageBox.title = "Air Defense Report"
        messageBox:addText("None of our radar stations have detected enemy aircraft.")
        messageBox:show()
        text.addToArchive(civ.getCurrentTribe(),"None of our radar stations have detected enemy aircraft.","Air Defense Report","Air Defense Report")
    end
end

local function activateAllRadar()
    local messageBox = civ.ui.createDialog()
    messageBox.title = "Air Defense Minister"
    messageBox:addText("Do you wish to activate all our radar stations?")
    messageBox:addOption("No, I want to move some radar stations from their current position first.",1)
    messageBox:addOption("Yes, activate them all and report back.",2)
    local choice = messageBox:show()
    if choice == 1 then
        return
    elseif choice == 2 then
        doAllRadar()
    end
end

-- Fortify flak not in range of enemies or with a goto command
-- groupFlakUnits[unitAliases.FlakUnit.id]=true 
local groupFlakUnits = {}
groupFlakUnits[unitAliases.GermanFlak.id] = true
groupFlakUnits[unitAliases.AlliedFlak.id] = true

local function fortifyPassiveFlak()
    local function handleUnit(unit)
        if not groupFlakUnits[unit.type.id] then
            return
        end
        -- nothing is done to units under the goto Order
        if unit.gotoTile then
            return
        end
        local inRange = {[0]=false,[1]=false,[2]=false}
        local diamondTiles = {}
        radar.diamond(unit.location,unitAliases.Flak.move,diamondTiles,true)
        for __,checkTile in pairs(diamondTiles) do
            if not (checkTile.defender == unit.owner or checkTile.defender == nil) then
               for checkUnit in checkTile.units do
                   if checkUnit.type.domain == 1 and not(checkUnit.type.flags & 1<<12 == 1<<12) then
                        inRange[checkTile.z] = true
                    end
                end
            end
        end
        -- raid in progress
        if inRange[0] or inRange[1] or inRange[2] then
            -- clear the unit's orders, so it will activate
            unit.order = 0xFF
        else
            -- fortify the unit, since it doesn't have to be active
            unit.order = 0x02
        end
    end
    for unit in civ.iterateUnits() do
        if unit.owner == civ.getCurrentTribe() then
            handleUnit(unit)
        end
    end
end
console.fortifyPassiveFlak = fortifyPassiveFlak





------------------------------------------------------------------------------------------------------------------------------
--[==[ This convoy system is probably no longer needed.  Won't erase just yet p.g. 20 May 2019
-- convoy system data and functions

-- Convoy system for Over the Reich 3
-- calculates the battle scores for Allies and Germans in the
-- convoy system, for a region given by regionFunction, 
-- and scoring given by scoreFunction

-- regionFunction(tile) --> boolean
-- returns true if tile is in the specified region, false otherwise

-- scoreFunction(unit) --> boolean
-- returns a "score" for a given unit in the convoy system



function getConvoyScore(regionFunction,scoreFunction)
    local AlliesScore = 0
    local GermansScore = 0
    for unit in civ.iterateUnits() do
        if regionFunction(unit.location) then
            
            if unit.owner == tribeAliases.Allies then
                AlliesScore = AlliesScore + scoreFunction(unit)
                
            elseif unit.owner == tribeAliases.Germans then
                GermansScore = GermansScore+ scoreFunction(unit)
                
            end
        end
    end -- for unit in civ.iterateUnits()
    
    return AlliesScore, GermansScore
end --getConvoyScore

function inConvoyRegion1(tile)
    local xMin,xMax,yMin,yMax,zMin,zMax = 0, 82, 54, 80,0,0
    if tile.x >= xMin and tile.x <=xMax and
        tile.y >= yMin and tile.y <= yMax and
        tile.z >= zMin and tile.z <= zMax then
            return true
    else
        return false
    end
end

-- value of a unit in convoy zone 1 for determining the
-- number of freighters generated for the allies.  
-- Absent means no value in producing or sinking freighters
-- index by unit id number
-- .base is value of the unit
-- .moveBonus is the sore bonus if the unit has full movement points
--      (such units will have their movement reduced to 0, 1 for planes)
--      (If moveBonus = 0, movement points will not be deducted)
-- move bonus can only apply to the active player (allies for this table)
-- .german add this to score if the unit is owned by Germany

local convoy1UnitScore = {
[unitAliases.Destroyer.id]		= {base = 1, moveBonus = 1, germany = 2,},
[unitAliases.LightCruiser.id]	= {base = 1, moveBonus = 1, germany = 3,},
[unitAliases.UBoat.id]			= {base = 2, moveBonus = 0, germany = 0,},
[unitAliases.Carrier.id]		= {base = 2, moveBonus = 0, germany = -1,},
[unitAliases.Sunderland.id]		= {base = 0, moveBonus = 4, germany = 0,},
[unitAliases.Fw200.id]		    = {base = 0, moveBonus = 0, germany = 4,},

}

function convoyRegion1Score(unit)
    local score = 0
    if convoy1UnitScore[unit.type.id] then
        if convoy1UnitScore[unit.type.id].base then
            score = score+ convoy1UnitScore[unit.type.id].base
        end
        if convoy1UnitScore[unit.type.id].moveBonus and convoy1UnitScore[unit.type.id].moveBonus > 0 then
            if unit.moveSpent == 0 then
                score = score+convoy1UnitScore[unit.type.id].moveBonus
                if unit.type.domain == 1 and unit.owner == tribeAliases.Allies then
                    unit.moveSpent = unit.type.move - 1
                elseif unit.owner==tribeAliases.Allies then
                    unit.moveSpent = unit.type.move
                end
            end
        end
        if unit.owner == tribeAliases.Germans and convoy1UnitScore[unit.type.id].germany then
            score = score + convoy1UnitScore[unit.type.id].germany
        end
    end -- if convoy1UnitScore
    return score    
end -- convoyRegion1Score(unit)

-- compute number of freighters to generate for allies and how many sunk by germans
function freighterGeneration(alliedScore, germanScore)
    local numberOfAlliedMilitaryPorts = 0 -- p.g. initialize counter of allied port units
	local numberOfGermanMilitaryPorts = 0 -- p.g. initialize counter of german port units
	local dock = civ.getImprovement(34)
	for city in civ.iterateCities() do
	    if civ.hasImprovement(city, dock) and city.owner == tribeAliases.Allies then
	        numberOfAlliedMilitaryPorts = numberOfAlliedMilitaryPorts + 1--p.g. increment allied port count
	    end
	    if civ.hasImprovement(city,dock) and city.owner == tribeAliases.Germans then
	        numberOfGermanMilitaryPorts = numberOfGermanMilitaryPorts + 1 -- p.g. increment German port count
	    end
	end -- end loop over all cities in game
    local newFreighters = 0
    local sunkFreighters = 0
    local maxFreighters = 5
    if numberOfGermanMilitaryPorts >= 15 then
        maxFreighters = 5
    elseif numberOfGermanMilitaryPorts >= 10 then
        maxFreighters = 7
    elseif numberOfGermanMilitaryPorts >= 5 then
        maxFreighters = 9
    else
        maxFreighters = 11
    end
    local maxSunk = 5
    if germanScore == 0 then
        return maxFreighters, 0
    elseif alliedScore == 0 then
        return 0, maxSunk
    elseif alliedScore >= germanScore then
        return math.min(math.floor(alliedScore/germanScore),maxFreighters), 0
    elseif alliedScore < germanScore then
        return 0, math.min(math.floor(germanScore/alliedScore), maxSunk)
    end
end
    

-- computes the battle of the Atlantic for the turn
local function generateFreightersRegion1(unit)
    if flag("ConvoyZone1Calculated") == false and inConvoyRegion1(unit.location) then
        local convoyOptions = civ.ui.createDialog()
        convoyOptions.title = "Battle of the Atlantic"
        local coText = [[You are about to escort freighters to the end of the Atlantic Ocean convoy zone.  Many units get a bonus in the convoy calculation if they have full movement points, but any qualifying unit will have those movement points set to 0 (1 for aircraft) once this calculation is complete.  Make sure you have moved any units you wish to move before proceeding (if a unit has moved at least one square, it won't qualify for the full movement bonus and it won't have its movement expended). ]]
        convoyOptions:addText(func.splitlines(coText))
        convoyOptions:addOption(func.splitlines("I want to move more units or choose a different place for the convoy rendezvous."),1)
        convoyOptions:addOption(func.splitlines("Arrange for the convoy to rendezvous with this destroyer."),2)
        local selection = convoyOptions:show()
        if selection == 2 then
            setFlagTrue("ConvoyZone1Calculated")
            local alliedScore, germanScore = getConvoyScore(inConvoyRegion1,convoyRegion1Score)
            
            local newFreighters, sunkFreighters = freighterGeneration(alliedScore, germanScore)
            incrementCounter("SunkAlliedFreighters",-sunkFreighters)
            for i=1,newFreighters do
                nfrei = civ.createUnit(unitAliases.Freighter,tribeAliases.Allies,unit.location)
                nfrei.homeCity = nil
                nfrei.veteran = false
            end
            convoyResult = civ.ui.createDialog()
            convoyResult.title = "Battle of the Atlantic"
            convoyResult:addText(func.splitlines(tostring(newFreighters).." freighters successfully escorted and "..tostring(sunkFreighters).." freighters sunk by the Germans."))
            convoyResult:show()
        end
    end
end
--]==]
--
-- alliedPorts,germanPorts = countPorts()
local function countPorts()
    local alliedPorts = 0
    local germanPorts = 0
    for city in civ.iterateCities() do
        if civ.hasImprovement(city,improvementAliases.militaryPort) then
            if city.owner == tribeAliases.Allies then
                alliedPorts = alliedPorts+1
            elseif city.owner == tribeAliases.Germans then
                germanPorts = germanPorts+1
            end
        end
    end
    return alliedPorts,germanPorts
end
        
local function alliedConvoyBetweenTurns(turn)
    local alliedPorts,germanPorts = countPorts()
    germanPorts = germanPorts+state.alliedReinforcementsSent*specialNumbers.alliedReinforcementGermanPortPenalty
    local function randomTileInBox(xMin,xMax,yMin,yMax,z)
        local xVal = math.random(xMin,xMax)
        if yMin % 2 ~= xVal % 2 then
            yMin = yMin+1
        end
        if yMax % 2 ~= xVal % 2 then
            yMax = yMax-1
        end
        local yVal = yMin+2*(math.random(0,(yMax-yMin)//2))
        return civ.getTile(xVal,yVal,z)
    end
    --local function getTile(table)
      --  return civ.getTile(table[1],table[2],table[3])
    --end
    if 3*(turn % 3) + 1 > germanPorts/3 then
        local CAB1 = specialNumbers.convoyArrivalBox1
        local destination = randomTileInBox(CAB1.xMin,CAB1.xMax,CAB1.yMin,CAB1.yMax,0)
        if destination.defender == tribeAliases.Germans then
            for unit in destination.units do
                moveToAdjacent(unit)
            end
        end
        civ.createUnit(unitAliases.Convoy,tribeAliases.Allies,destination).homeCity = nil
    end
    if 3*(turn % 3) + 2 > germanPorts/3 then
        local CAB2 = specialNumbers.convoyArrivalBox2
        local destination = randomTileInBox(CAB2.xMin,CAB2.xMax,CAB2.yMin,CAB2.yMax,0)
        if destination.defender == tribeAliases.Germans then
            for unit in destination.units do
                moveToAdjacent(unit)
            end
        end
        civ.createUnit(unitAliases.Convoy,tribeAliases.Allies,destination).homeCity=nil
    end
    if 3*(turn % 3) + 3 > germanPorts/3 then
        local CAB3 = specialNumbers.convoyArrivalBox3
        local destination = randomTileInBox(CAB3.xMin,CAB3.xMax,CAB3.yMin,CAB3.yMax,0)
        if destination.defender == tribeAliases.Germans then
            for unit in destination.units do
                moveToAdjacent(unit)
            end
        end
        civ.createUnit(unitAliases.Convoy,tribeAliases.Allies,destination).homeCity=nil
    end
end
console.alliedConvoyBetweenTurns = alliedConvoyBetweenTurns

local function convoyKPress(unit)
    if not unit.type == unitAliases.Convoy then
        return
    end
    if not unit.location.city then
        civ.ui.text("Convoys can only unload their cargo in cities with military ports.")
        return
    end
    local city = unit.location.city
    if not civ.hasImprovement(city, improvementAliases.militaryPort) then
        civ.ui.text(city.name.." doesn't have a functioning military port, so it can't unload this convoy's cargo.")
        return 
    end
    state.cityDockings[city.id] = state.cityDockings[city.id] or 0
    local capacity = 2*civilImprovement(city)+1
    local fuelBonus = specialNumbers.baseFuelPerConvoy
    if civ.hasImprovement(city,improvementAliases.refineryI) then
        fuelBonus = fuelBonus+specialNumbers.convoyRefineryFuelBonus
    end
    if civ.hasImprovement(city,improvementAliases.refineryII) then
        fuelBonus = fuelBonus+specialNumbers.convoyRefineryFuelBonus
    end
    if civ.hasImprovement(city,improvementAliases.refineryIII) then
        fuelBonus = fuelBonus+specialNumbers.convoyRefineryFuelBonus
    end
    fuelBonus =math.max(0,fuelBonus - specialNumbers.penaltyForMissingAlliedPort*math.min(0,13-countPorts()))
    if capacity <= state.cityDockings[city.id] then
        local optionBox = civ.ui.createDialog()
        optionBox.title = "Port Capacity"
        optionBox:addText("The port in "..city.name.." is already operating at full capacity.  This convoy can be unloaded later or in a different port.")
        optionBox:show()
        return
    elseif capacity > state.cityDockings[city.id] and capacity < state.cityDockings[city.id] + specialNumbers.trainsPerConvoy then
        local optionBox = civ.ui.createDialog()
        optionBox.title = "Port Capacity"
        local surplusTrains = state.cityDockings[city.id]+specialNumbers.trainsPerConvoy-capacity
        optionBox:addText("This military port is operating near its maximum capacity.  If we unload the convoy here we'll unload all "..fuelBonus.." units of fuel, but "..surplusTrains.." of the "..specialNumbers.trainsPerConvoy.." trains in the convoy will not be able to move until next turn.")
        optionBox:addOption("Unload the convoy here.",1)
        optionBox:addOption("Set sail for a larger port.",2)
        local decision = optionBox:show()
        if decision == 2 then
            return
        else
            civ.deleteUnit(unit)
            state.cityDockings[city.id] = state.cityDockings[city.id]+specialNumbers.trainsPerConvoy
            city.owner.money = city.owner.money+fuelBonus
            for i=1,specialNumbers.trainsPerConvoy do
                local newTrain = civ.createUnit(unitAliases.FreightTrain,city.owner,city.location)
                newTrain.homeCity=nil
                if i <= surplusTrains then
                    newTrain.moveSpent = unitAliases.FreightTrain.move
                end
                if i==specialNumbers.trainsPerConvoy then
                    newTrain:activate()
                    runDoOnActivateUnit()
                end
            end
            return
        end
    else -- enough capacity for full unload
        civ.deleteUnit(unit)
        state.cityDockings[city.id] = state.cityDockings[city.id]+specialNumbers.trainsPerConvoy
        city.owner.money = city.owner.money+fuelBonus
        for i=1,specialNumbers.trainsPerConvoy do
            local newTrain = civ.createUnit(unitAliases.FreightTrain,city.owner,city.location)
            newTrain.homeCity=nil
            if i==specialNumbers.trainsPerConvoy then
                newTrain:activate()
                runDoOnActivateUnit()
            end
        end
        return
    end
end

local killWithMilitaryPort = {
[unitAliases.Convoy.id] = true,
[unitAliases.FreightTrain.id] = true,
[unitAliases.GermanTaskForce.id]=true,
[unitAliases.AlliedTaskForce.id]=true,
[unitAliases.UBoat.id]=true,
[unitAliases.Carrier.id]=true,
}
local function killPortExtras(winner,loser)
    if loser.type ~= unitAliases.MilitaryPort then
        return
    end
    local city = loser.homeCity
    if city == nil then
        civ.ui.text("Port killed had no home city.")
        return
    end
    for unit in city.location.units do
        if killWithMilitaryPort[unit.type.id] then
            log.onUnitKilled(winner,unit)
            local killDialog=civ.ui.createDialog()
            killDialog.title = "Defense Minister"
            killDialog:addText("A "..unit.type.name.." was destroyed in port.")
            killDialog:show()
            civ.deleteUnit(unit)
	        if unit.type == unitAliases.Convoy and unit.owner == tribeAliases.Allies then
	        incrementCounter("GermanScore",specialNumbers.germanScoreIncrementSinkFreighter)
            end
        end
    end
    return
end

local function chooseRandomCityWithPort(cityList,tribe)
    local citiesWithPort = {}
    for __,city in pairs(cityList) do
        if city:hasImprovement(improvementAliases.militaryPort) and city.owner==tribe then
            citiesWithPort[#citiesWithPort+1] = city
        end
    end
    local numberCities = #citiesWithPort
    if numberCities > 0 then
        return citiesWithPort[math.random(1,numberCities)]
    else
        return nil
    end
end

local tierOneRespawnCities={
    cityAliases.Brest,
    cityAliases.LeHavre,
    cityAliases.Bordeaux,
    cityAliases.LaRochelle,
}

local tierTwoRespawnCities={
    cityAliases.Hamburg,
    cityAliases.Bremen,
    cityAliases.Wilhelmshaven,
    cityAliases.Lubeck,
    cityAliases.Kiel,
    cityAliases.Rostock,
}

local function uBoatSurvival(winner,loser)
    if loser.type ~= unitAliases.UBoat or loser.location.terrainType % 16 ~= 10 then
        return
    end
    local portCityList = {}
    local index = 1
    for city in civ.iterateCities() do
        if civ.hasImprovement(city, improvementAliases.militaryPort) then
            portCityList[index] = city
            index = index+1
        end
    end
    local outcomeCity = portCityList[math.random(1,index-1+specialNumbers.extraUBoatLoss)]
    if civ.isCity(outcomeCity) and outcomeCity.owner == loser.owner then
        local spawnCity = chooseRandomCityWithPort(tierOneRespawnCities,loser.owner)
            or chooseRandomCityWithPort(tierTwoRespawnCities,loser.owner)
        if spawnCity then
            local newUBoat = civ.createUnit(unitAliases.UBoat,loser.owner,spawnCity.location)    
            newUBoat.homeCity = loser.homeCity
            newUBoat.veteran = loser.veteran
            newUBoat.moveSpent = 254
        end
    end
end

-- French Occupation Trains
local function inFranceSquare(tile)
    local xMin,xMax,yMin,yMax,zMin,zMax = 83, 227, 75, 145,0,0
    if tile.x >= xMin and tile.x <=xMax and
        tile.y >= yMin and tile.y <= yMax and
        tile.z >= zMin and tile.z <= zMax then
            return true
    else
        return false
    end
end
-- comment out this table to choose a random train track square from all of France for each train to be generated
--local occupationTrainGenLocations = {{212,138},{215,131},{199,143},{205,125},{165,143},{164,134},{149,135}, }

local function randomRailInFrance()
    local attempts =0
    local xMin,xMax,yMin,yMax,zMin,zMax = 83, 227, 75, 145,0,0
    while attempts <10000 do
        xVal = math.random(xMin,xMax)
        yVal = math.random(yMin,yMax)
        if xVal % 2 ~= yVal % 2 then
            xVal = xVal-1
        end
        if civ.getTile(xVal,yVal,0) and civ.getTile(xVal,yVal,0).terrainType % 16 == 1 then
            return civ.getTile(xVal,yVal,0)
        end
        attempts=attempts+1
    end
end

local function germanOccupationBonus()
    local occupationScore = 0
    for unit in civ.iterateUnits() do
        if unit.location.terrainType % 16 == 10 or not inFranceSquare(unit.location) then

        elseif unit.type == unitAliases.GermanArmyGroup or unit.type == unitAliases.AlliedArmyGroup then
            if unit.owner == tribeAliases.Germans then
                occupationScore = occupationScore+specialNumbers.armyGroupOccupationValue

            else
                occupationScore = occupationScore-specialNumbers.armyGroupOccupationPenalty
            end
        elseif unit.type == unitAliases.GermanBatteredArmyGroup or unit.type == unitAliases.AlliedBatteredArmyGroup then
            if unit.owner == tribeAliases.Germans then
                occupationScore = occupationScore+specialNumbers.batteredArmyGroupOccupationValue
            else
                occupationScore = occupationScore-specialNumbers.batteredArmyGroupOccupationPenalty
            end
        end
    end
    local trainsToMake = 0
    --print(occupationScore)
    for i=1,7 do
        if occupationScore >= specialNumbers["occupationScoreTrain"..tostring(i).."Threshold"] then
            trainsToMake = trainsToMake+1
        end
    end
    local extractionChangeMenu = {}
    if counterValue("GermanExtractionLevel") > 1 then
        extractionChangeMenu[1] = "Reduce the Occupation Levy to "..tostring(counterValue("GermanExtractionLevel")-1).."."
    end
    extractionChangeMenu[2] = "Maintain the Occupation Levy at "..tostring(counterValue("GermanExtractionLevel")).."."
    if counterValue("GermanExtractionLevel") < specialNumbers.maxExtractionLevel then
        extractionChangeMenu[3] = "Increase the Occupation Levy to "..tostring(counterValue("GermanExtractionLevel")+1).."."
    end
    local extractionMenuText = text.substitute("The current Occupation Levy in France is %STRING1 trains per turn, and our forces in France are capable of actually taking %STRING2 trains per turn.  As we increase the official Occupation Levy, we will spur more Frenchmen to join the Resistance and spy for the Allies.",{counterValue("GermanExtractionLevel"),trainsToMake})
    local choice = text.menu(extractionChangeMenu,extractionMenuText,"Occupation Minister")

    if choice == 1 then
        incrementCounter("GermanExtractionLevel",-1)
    end
    if choice == 3 then
        incrementCounter("GermanExtractionLevel",1)
    end
    trainsToMake = math.min(trainsToMake,counterValue("GermanExtractionLevel"))
    --print(trainsToMake)
    if occupationTrainGenLocations then
        local locNumber = #occupationTrainGenLocations
        for i=1,trainsToMake do
            local coords = occupationTrainGenLocations[math.random(1,locNumber)]
            local newTrain = civ.createUnit(unitAliases.FreightTrain,tribeAliases.Germans,civ.getTile(coords[1],coords[2],0))
            newTrain.homeCity = nil
        end
    else
        for i=1,trainsToMake do
            local newTrain = civ.createUnit(unitAliases.FreightTrain,tribeAliases.Germans,randomRailInFrance())
            newTrain.homeCity = nil
        end
    end
    local firefighterDestructionChance = specialNumbers["occupationFirefighterDestructionChance"..tostring(counterValue("GermanExtractionLevel")).."Train"]
    for city in civ.iterateCities() do
        if city:hasImprovement(improvementAliases.firefighters) and city.owner == tribeAliases.Germans and city.location.x < 227 and math.random() < firefighterDestructionChance then
            text.displayNextOpportunity(tribeAliases.Germans,text.substitute("The firefighters in %STRING1 can no longer be trusted to protect our vital infrastructure.  We need to reform the service with men who support our occupation.",{city.name}),"Gestapo Report","Unreliable Firefighters in "..city.name)
            city:removeImprovement(improvementAliases.firefighters)
        end
    end
end
console.germanOccupationBonus = germanOccupationBonus


function overTwoHundred.resistanceSpying()
    local cityRevelationChance = specialNumbers["occupationCityRevelationChance"..tostring(counterValue("GermanExtractionLevel")).."Train"]
    local airfieldRevelationChance = specialNumbers["occupationAirfieldRevelationChance"..tostring(counterValue("GermanExtractionLevel")).."Train"]
    local revealedCityList = {}
    local rCLIndex = 1
    for city in civ.iterateCities() do
        if city.location.x <227 and city.owner == tribeAliases.Germans then
            if (city:hasImprovement(improvementAliases.cityI) and math.random() < cityRevelationChance) or (city:hasImprovement(improvementAliases.airbase) and math.random() < airfieldRevelationChance) then
                city.attributes = gen.setBit1(city.attributes,23)
                -- reveal the city by placing and removing a radar marker
                radar.placeRadarMarker(civ.getTile(city.location.x-2,city.location.y,city.location.z),tribeAliases.Allies, "railroad",civ.getTile(specialNumbers.radarSafeTile[1],specialNumbers.radarSafeTile[2],specialNumbers.radarSafeTile[3]),state.radarRemovalInfo,unitAliases.spotterUnit)
                radar.removeRadarMarker(civ.getTile(city.location.x-2,city.location.y,city.location.z), "railroad",civ.getTile(specialNumbers.radarSafeTile[1],specialNumbers.radarSafeTile[2],specialNumbers.radarSafeTile[3]),state.radarRemovalInfo,unitAliases.spotterUnit)

                revealedCityList[rCLIndex] = city.name
                rCLIndex = rCLIndex+1
            end
        end
    end
    local message = nil
    if rCLIndex == 1 then
        return
    elseif rCLIndex == 2 then
        message = "Reports from the French Resistance have revealed to us the contents of "..revealedCityList[1].."."
    elseif rCLIndex == 3 then
        message = "Reports from the French Resistance have revealed to us the contents of "..revealedCityList[2].." and "..revealedCityList[1].."."
    else
        message = "Reports from the French Resistance have revealed to us the contents of "
        for i=(rCLIndex-1),2,-1 do
            message = message..revealedCityList[i]..", "
        end
        message = message.."and "..revealedCityList[1].."."
    end
    text.displayNextOpportunity(tribeAliases.Allies,message,"Resistance Report","Resistance Report")
end
console.resistanceSpying = overTwoHundred.resistanceSpying

-- Old Occupation Stuff

--[=[local occupationZoneScore = {
[unitAliases.Schutzen.id]       =   {base = 2, healthBonus =1 } ,
[unitAliases.Panzers.id]        =   {base = 1, healthBonus =1 },
[unitAliases.Artillery1.id]     =   {base = 0, healthBonus =1 },
[unitAliases.HurricaneIV.id]    =   {base = 6, healthBonus =15},
[unitAliases.Typhoon.id]        =   {base = 6, healthBonus =15},
[unitAliases.Tempest.id]        =   {base = 6, healthBonus =15},
}

local function frenchOccupationScore(unit)
    local germanScore = 0
    local alliedScore = 0
    if unit.owner == tribeAliases.Germans then
        if unit.moveSpent == 0 and occupationZoneScore[unit.type.id] then
            
    
    elseif unit.owner == tribeAliases.Allies then
    
    
    end
    
    

end--]=]
--[=[
local function temporaryFrenchTrainGeneration()
    local score = 0
    for unit in civ.iterateUnits() do
        if unit.owner == tribeAliases.Germans and unit.moveSpent == 0 and inFranceSquare(unit) then
            if unit.type == unitAliases.Schutzen then
                score = score + 3
                unit.moveSpent = unitAliases.Schutzen.move*totpp.movementMultipliers.aggregate
            elseif unit.type == unitAliases.Panzers then
                score = score + 2
                unit.moveSpent = unitAliases.Panzers.move*totpp.movementMultipliers.aggregate
            elseif unit.type == unitAliases.Artillery1 then
                score = score + 1
                unit.moveSpent = unitAliases.Artillery1.move*totpp.movementMultipliers.aggregate
            end
        end
    end
    score = math.max(score-150,0)
    score = math.min(math.floor(score/15),6)
    local destList = {civ.getTile(166,144,0),civ.getTile(198,142,0),civ.getTile(214,134,0)}
    for i=1,score do
        destination = destList[i%3+1]
        if destination.defender == tribeAliases.Allies then
            for unit in destination.units do
                moveToAdjacent(unit)
            end
        end
        newTrain = civ.createUnit(unitAliases.FreightTrain,tribeAliases.Germans,destination)
        newTrain.homeCity = nil
    end
end

local function generateTrainsFrance(unit)
    if flag("FrenchOccupationCalculated") == false and inFranceSquare(unit.location) then
        local occupationOptions = civ.ui.createDialog()
        occupationOptions.title = "Occupied France Administration"
        local ooText = [[You are about to request that supply trains move in from southern France.  All Schutzen, Panzer, and Artillery units in France (west of x=227) that have full movement points remaining will be ordered to suppress resistance spying and partisan attacks, but this will expend their movement points for the turn.  If you want to give any orders to such units, you must do so before requesting the trains.]]
        occupationOptions:addText(ooText)
        occupationOptions:addOption("I want to give more orders before requesting supply trains.",1)
        occupationOptions:addOption("Order the trains to start north.",2)
        local selection = occupationOptions:show()
        if selection == 2 then
            setFlagTrue("FrenchOccupationCalculated")
            temporaryFrenchTrainGeneration()
            
        end
    end
end
--]=]

-- Change the 'name' of units in report
local reportNameTable = {}

--Data for Allied availability of better escort aircraft
-- Aircraft qualifying as 'escorts' for allies
-- key is unitType ID number
-- .range integer ==> escort range of this fighter
-- .available function(unitType) --> boolean
--      return true if this aircraft is available to the allies


-- If the Allies have the tech to build the unit and it isn't expired
local function alliesHaveTechFor(unitType)
    local expired = false
    if unitType.expires ~= nil then
        expired = civ.hasTech(tribeAliases.Allies, unitType.expires)
    end
    local discovered = true
    if unitType.prereq ~= nil then
        discovered = civ.hasTech(tribeAliases.Allies, unitType.prereq)
    end
--    print(unitType)
--    print(discovered)
--    print(not(expired))    
    return discovered and not(expired)
end

-- Divides aircraft range by 2, rounds down (in case aircraft has odd range), multiplies by movement rate
local function physicalRange(unitType)
    return unitType.move*(math.floor(unitType.range/2))
end

local escortTableDay = {
[unitAliases.SpitfireIX.id]			= {available = alliesHaveTechFor, range = physicalRange(unitAliases.SpitfireIX)},
[unitAliases.SpitfireXII.id]		= {available = alliesHaveTechFor, range = physicalRange(unitAliases.SpitfireXII)},
[unitAliases.SpitfireXIV.id]		= {available = alliesHaveTechFor, range = physicalRange(unitAliases.SpitfireXIV)},
[unitAliases.HurricaneIV.id]		= {available = alliesHaveTechFor, range = physicalRange(unitAliases.HurricaneIV)},
[unitAliases.Typhoon.id]			= {available = alliesHaveTechFor, range = physicalRange(unitAliases.Typhoon)},
[unitAliases.Tempest.id]			= {available = alliesHaveTechFor, range = physicalRange(unitAliases.Tempest)},
[unitAliases.P47D11.id]				= {available = alliesHaveTechFor, range = physicalRange(unitAliases.P47D11)},
[unitAliases.P47D25.id]				= {available = alliesHaveTechFor, range = physicalRange(unitAliases.P47D25)},
[unitAliases.P47D40.id]				= {available = alliesHaveTechFor, range = physicalRange(unitAliases.P47D40)},

[unitAliases.P38H.id]				= {available = alliesHaveTechFor, range = physicalRange(unitAliases.P38H)},
[unitAliases.P38J.id]				= {available = alliesHaveTechFor, range = physicalRange(unitAliases.P38J)},
[unitAliases.P51B.id]				= {available = alliesHaveTechFor, range = physicalRange(unitAliases.P51B)},
[unitAliases.P51D.id]				= {available = alliesHaveTechFor, range = physicalRange(unitAliases.P51D)},

}
--
-- local escortTableNight = {}

-- Munitions that can increment the need for long range escorts for the allies (i.e. not Flak)
local munitionsForEscort = {
[unitAliases.FiftyCal.id]		= true,
[unitAliases.TwentyMM.id]		= true,
[unitAliases.ThirtyMM.id]		= true,
[unitAliases.A2ARockets.id]		= true,
}

-- table of bombers that can increment the counter leading to the need for long range escorts "KillsOutsideEscortRange"
-- table entry is a table to refer to to see if unit was killed outside escort range
local escortableBombers = {

[unitAliases.A20.id] = {validEscorts = escortTableDay, validKillers =munitionsForEscort},
[unitAliases.B26.id] = {validEscorts = escortTableDay, validKillers =munitionsForEscort},
[unitAliases.A26.id] = {validEscorts = escortTableDay, validKillers =munitionsForEscort},
[unitAliases.B17F.id] = {validEscorts = escortTableDay, validKillers =munitionsForEscort},
[unitAliases.B24J.id] = {validEscorts = escortTableDay, validKillers =munitionsForEscort},
[unitAliases.B17G.id] = {validEscorts = escortTableDay, validKillers =munitionsForEscort},
--[unitAliases.damagedB17F.id] = escortTableDay,
--[unitAliases.damagedB17G.id] = escortTableDay,
}




local function bestEscortRange(escortTable)
    local bestRange = 0
    for index, escortInfo in pairs (escortTable) do
        if escortInfo.available(civ.getUnitType(index)) then
            --print(civ.getUnitType(index))
            --print(escortInfo.range)
            bestRange = math.max(bestRange, escortInfo.range)
        end
    end
    return bestRange
end

local function outOfRangeCheck(killedUnit, bomberTable)
    local outOfRange = false
    local escortRange = 1001 -- very large, to make sure in range unless confirmed out of range
    local nearestAirfield = nil
    local distanceToAirfield = 1000
    local function distance(tile1,tile2)
       return math.ceil((math.abs(tile1.x-tile2.x)+math.abs(tile1.y-tile2.y))/2)
    end
    if killedUnit.owner == tribeAliases.Allies then
        if bomberTable[killedUnit.type.id]~=nil then
            escortRange = bestEscortRange(bomberTable[killedUnit.type.id].validEscorts)
        end
        for airfield in civ.iterateCities() do
            if airfield.owner == killedUnit.owner and civ.hasImprovement(airfield,civ.getImprovement(17)) and 
                distance(airfield.location,killedUnit.location) < distanceToAirfield then
                    nearestAirfield = airfield
                    distanceToAirfield = distance(airfield.location,killedUnit.location)
            end
        end -- for airfield in civ.iterateCities()
        if escortRange < distanceToAirfield then
            outOfRange = true
        end
    end
    return outOfRange
end

local function checkIfInOperatingRadius(unit)
    -- if unit not air, then definitely in radius
    if unit.type.domain ~= 1 then
        return true
    end
    if unit.type == unitAliases.Me163 then
        return true
    end
    local maxRadius = physicalRange(unit.type)
    if unit.type == unitAliases.damagedB17G then
        maxRadius = physicalRange(unitAliases.B17G)
    elseif unit.type == unitAliases.damagedB17F then
        maxRadius = physicalRange(unitAliases.B17F)
    end
    if unit.type == unitAliases.FifteenthAF or unit.type == unitAliases.RedTails then
        return maxRadius >= math.floor((math.abs(unit.location.x-345)+math.abs(unit.location.y-145))/2)
    end
    if unit.type == unitAliases.Il2 or unit.type == unitAliases.Yak3 then
        return maxRadius >= math.floor((math.abs(unit.location.x-406)+math.abs(unit.location.y-74))/2)
    end
    for city in civ.iterateCities() do
        if city.owner == unit.owner and city:hasImprovement(improvementAliases.airbase)
            and maxRadius >= math.floor((math.abs(unit.location.x-city.location.x)+math.abs(unit.location.y-city.location.y))/2) then
            return true
        end
    end
    if useCarrier[unit.type.id] then
        for potentialCarrier in civ.iterateUnits() do
            if potentialCarrier.type == unitAliases.Carrier and potentialCarrier.owner == unit.owner and
            maxRadius >= math.floor((math.abs(unit.location.x-potentialCarrier.location.x)+math.abs(unit.location.y-potentialCarrier.location.y))/2) then
                return true
            end
        end
    end
    return false
end





------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
--reaction Specifications
--reactionUnitClasses
-- it will be useful to group units into tables based on how other units can/will react to them

local reactionGroups = {}
reactionGroups.strategicBombers = {unitAliases.B17F,unitAliases.B17G,unitAliases.B24J,unitAliases.Stirling,unitAliases.Halifax,unitAliases.Lancaster,unitAliases.MedBombers,unitAliases.Do217,unitAliases.He277,unitAliases.He111}

reactionGroups.alliedFighters = {unitAliases.SpitfireIX,unitAliases.SpitfireXII,unitAliases.SpitfireXIV,unitAliases.HurricaneIV,unitAliases.Typhoon,unitAliases.Tempest,unitAliases.P47D11,unitAliases.P47D25,
unitAliases.P47D40,unitAliases.P38H,unitAliases.P38J,unitAliases.P38L,unitAliases.P51B,unitAliases.P51D,unitAliases.Beaufighter,unitAliases.MosquitoII,unitAliases.MosquitoXIII,unitAliases.RedTails,unitAliases.Yak3}

reactionGroups.germanInterceptors = {unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219}

reactionGroups.canInterceptGerman = {unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219,unitAliases.Me110,unitAliases.Me410,unitAliases.Ju87G,unitAliases.Do217,unitAliases.He277,unitAliases.He111,unitAliases.Fw200,
unitAliases.Fw190F,unitAliases.Do335}

--Actually is all but jets and German Experten which can't be intercepted except by P51D, Tempest, RedTails
reactionGroups.allButJets = {unitAliases.A26,unitAliases.B26,unitAliases.A20, unitAliases.B17F,unitAliases.B17G,unitAliases.B24J,unitAliases.Stirling,unitAliases.Halifax,unitAliases.Lancaster,unitAliases.MedBombers,
unitAliases.SpitfireIX,unitAliases.SpitfireXII,unitAliases.SpitfireXIV,unitAliases.HurricaneIV,unitAliases.Typhoon,unitAliases.Tempest,unitAliases.P47D11,unitAliases.P47D25,
unitAliases.P47D40,unitAliases.P38H,unitAliases.P38J,unitAliases.P38L,unitAliases.P51B,unitAliases.P51D,unitAliases.Beaufighter,unitAliases.MosquitoII,unitAliases.MosquitoXIII,unitAliases.RedTails,unitAliases.Yak3,
unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,unitAliases.Fw190F,unitAliases.Do335,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219,unitAliases.Me110,unitAliases.Me410,unitAliases.Ju87G,unitAliases.Do217,unitAliases.He277,unitAliases.He111,unitAliases.Fw200,unitAliases.Sunderland}

--Considers all units except jabo (strategic bombers and regular fighters need to be very wary of light flak)
reactionGroups.allButJabo = {unitAliases.A26,unitAliases.B26,unitAliases.A20,unitAliases.B17F,unitAliases.B17G,unitAliases.B24J,unitAliases.Stirling,unitAliases.Halifax,unitAliases.Lancaster,unitAliases.MedBombers,
unitAliases.SpitfireIX,unitAliases.SpitfireXII,unitAliases.SpitfireXIV,
unitAliases.P38H,unitAliases.P38J,unitAliases.P38L,unitAliases.P51B,unitAliases.P51D,unitAliases.Beaufighter,unitAliases.MosquitoII,unitAliases.MosquitoXIII,unitAliases.RedTails,unitAliases.Yak3,
unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219,unitAliases.Me110,unitAliases.Me410,unitAliases.Do217,unitAliases.He277,unitAliases.He111,unitAliases.Fw200,unitAliases.Sunderland}

--considers all jabo but not tactical bombers - jabo still takes 'some' damage from light flak whereas tactical bombers takes no reaction damage (they fly at medium alts)
reactionGroups.jabo = {unitAliases.Ju87G,unitAliases.Fw190F,unitAliases.Do335,unitAliases.HurricaneIV,unitAliases.Typhoon,unitAliases.Tempest,unitAliases.P47D11,unitAliases.P47D25,
unitAliases.P47D40}

--For purposes of Allied attacks, they will intercept and maul bombers, do significant damage to heavy fighters, and do less damage to regular fighters

reactionGroups.luftwaffeFighter = {unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219}

reactionGroups.luftwaffeHeavyFighter = {unitAliases.Me110,unitAliases.Me410,unitAliases.Fw190F, unitAliases.Do335}

reactionGroups.luftwaffeBomber = {unitAliases.Ju87G,unitAliases.Do217,unitAliases.He277,unitAliases.He111,unitAliases.Fw200}

reactionGroups.luftwaffeJets = {unitAliases.He162,unitAliases.Me262,unitAliases.EgonMayer,unitAliases.JosefPriller,unitAliases.HermannGraf,unitAliases.hwSchnaufer,unitAliases.AdolfGalland, unitAliases.Experten}

reactionGroups.alliedJets = {unitAliases.P80,unitAliases.Meteor}

reactionGroups.navalUnits = {unitAliases.Convoy,unitAliases.UBoat,unitAliases.AlliedTaskForce,unitAliases.GermanTaskForce, unitAliases.Carrier}

reactionGroups.gunBatteryVulnerable = {unitAliases.AlliedTaskForce, unitAliases.GermanTaskForce, unitAliases.AlliedArmyGroup, unitAliases.AlliedBatteredArmyGroup, unitAliases.GermanArmyGroup, unitAliases.GermanBatteredArmyGroup, unitAliases.AlliedLightFlak, unitAliases.GermanLightFlak, unitAliases.GermanFlak, unitAliases.AlliedFlak, unitAliases.Sdkfz, unitAliases.FlakTrain,}

-- make a reactionGroup of all air units
-- this includes munitions, so newly generated munitions will also be damaged if this
-- is used for area damage (that may be desirable or undesirable)
reactionGroups.allAir = {}
for i=0,128 do
    if civ.getUnitType(i) and civ.getUnitType(i).domain == 1 then
        table.insert(reactionGroups.allAir,civ.getUnitType(i))
    end
end

-- canReact is a table indexed by unitTypeID
-- if the unit type has no entry, that unit type will not react to anything

--
-- .range = integer
--      MANDITORY
--      range is the distance between a trigger unit and a reacting unit 
--      if range is not specified elsewhere, this range is used

-- .maxAttacks = integer
--      The maximum number of times in a turn this unit will "react" and attempt to damage a trigger unit
--      absent means no limit
--      If the trigger unit is killed before a unit reacts, the number of attacks that unit made will not increment

--  The following entries specify possible locations of the triggering and reacting unit
--  A match in any category means the unit will "react" to the triggering unit,
--  possibly attack it, and will be at greater risk (or at least different risk) from area
--  attack units compared to "bystander" units
--
--      Valid Data For Any of the Following Entries
--      table of unitTypes
--      {range = integer, unitTypes = table of unitTypes, probability = num between 0 and 1,
--      allowedTerrainTypes = {[integer]=boolorNil}}
--      table of {range = integer, unitTypes = table of unitTypes, probability = num between 0 and 1}
--
--      range is the horizontal distance between the trigger unit and the reacting unit
--          absent means use the default range
--      Probability means the likelihood of reacting to a unit for which the criteria otherwise match.
--          absent means probability of 1

-- .anyMap  
--  The unit can react to any unit in the table of unitTypes if that unit is
--      within the corresponding (horizontal) range regardless of which map
--      each unit is on

-- .sameMap
--  The unit can react to any unit in the table of unit types if both units are
--      on the same map and are within range

-- .sameTime
-- If the unit is on the night map it can react to units in the table if they
-- are on the night map within range.  If the unit is on a day map, it can
-- react to units in the table on either day map (within horizontal range)

-- .lowerAltitude
--      If the unit is on the low altitude (day) map, it reacts to units in the table
--      if they are also on the low altitude map.  If the unit is on the high altitude map
--      it reacts to units on both maps

--  .lowMap
--      Both units must be on the low altitude day map

--  .highMap
--      Both units must be on the high altitude day map

--  .nightMap
--      Both units must be on the night map

--  .allowedTerrainTypes
--      If allowedTerrainTypesTable[n]==true, then the unit can react while on that terrain type,
--      if false or nil, it can't.
--      No table means it will react on all terrain types

-- canReact canReactTable,canReactFunction
local canReact ={}
canReact[unitAliases.GermanArmyGroup.id] = {range = 1, lowMap = reactionGroups.strategicBombers}
canReact[unitAliases.GermanBatteredArmyGroup.id] = {range = 1, lowMap = reactionGroups.strategicBombers}
canReact[unitAliases.AlliedArmyGroup.id] = {range = 1, lowMap = reactionGroups.strategicBombers}
canReact[unitAliases.AlliedBatteredArmyGroup.id] = {range = 1, lowMap = reactionGroups.strategicBombers}
canReact[unitAliases.RedArmyGroup.id] = {range = 1, lowMap = reactionGroups.strategicBombers}
canReact[unitAliases.GunBattery.id] = {maxAttacks = 4, range=3, lowMap = reactionGroups.gunBatteryVulnerable,allowedTerrainTypes = {[0]=true,[4]=true,[7]=true}}

canReact[unitAliases.FlakTrain.id] = {maxAttacks = 2, range = 2, anyMap = reactionGroups.allButJets}
canReact[unitAliases.GermanFlak.id] = {maxAttacks = 4, range = 2, anyMap = reactionGroups.allButJets}
canReact[unitAliases.AlliedFlak.id] = {maxAttacks = 4, range = 2, anyMap = reactionGroups.allButJets}
canReact[unitAliases.GermanLightFlak.id] = {maxAttacks = 6, range = 2, sameMap = reactionGroups.allButJets}
canReact[unitAliases.AlliedLightFlak.id] = {maxAttacks = 6, range = 2, sameMap = reactionGroups.germanInterceptors}
canReact[unitAliases.Sdkfz.id] = {maxAttacks = 3, range = 2, lowMap = reactionGroups.allButJets}

canReact[unitAliases.AlliedTaskForce.id] = {maxAttacks = 2, range = 2, lowMap = reactionGroups.allButJets}
canReact[unitAliases.GermanTaskForce.id] = {maxAttacks = 2, range = 2, lowMap = reactionGroups.allButJets}


--The Allies can't defend against German jets with heavy flak.
--Light flak and flying around low in general is very dangerous

canReact[unitAliases.Fw190A5.id] = {maxAttacks = 2, range = 2, lowerAltitude = reactionGroups.allButJets}
canReact[unitAliases.Fw190A8.id] = {maxAttacks = 3, range = 2, lowerAltitude = reactionGroups.allButJets}
canReact[unitAliases.Fw190D9.id] = {maxAttacks = 4, range = 2, lowerAltitude = reactionGroups.allButJets}
canReact[unitAliases.Ta152.id] = {maxAttacks = 4, range = 3, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.Ju88C.id] = {maxAttacks = 1, range = 1, sameMap = reactionGroups.allButJets}
canReact[unitAliases.Ju88G.id] = {maxAttacks = 2, range = 1, sameMap = reactionGroups.allButJets}
canReact[unitAliases.He219.id] = {maxAttacks = 2, range = 2, sameMap = reactionGroups.allButJets}

canReact[unitAliases.Me109G6.id] = {maxAttacks = 2, range = 2, lowerAltitude = reactionGroups.allButJets}
canReact[unitAliases.Me109G14.id] = {maxAttacks = 3, range = 2, lowerAltitude = reactionGroups.allButJets}
canReact[unitAliases.Me109K4.id] = {maxAttacks = 4, range = 2, lowerAltitude = reactionGroups.allButJets}

canReact[unitAliases.He162.id] = {maxAttacks = 1, range = 4, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.Me262.id] = {maxAttacks = 2, range = 4, lowerAltitude = reactionGroups.allAir}

canReact[unitAliases.EgonMayer.id] = {maxAttacks = 4, range = 3, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.HermannGraf.id] = {maxAttacks = 4, range = 3, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.JosefPriller.id] = {maxAttacks = 4, range = 3, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.hwSchnaufer.id] = {maxAttacks = 4, range = 3, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.AdolfGalland.id] = {maxAttacks = 4, range = 4, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.Experten.id] = {maxAttacks = 4, range = 3, lowerAltitude = reactionGroups.allAir}
  
--American tactical bombers (A20, B26, A26) are not intercepted.  Their speed keeps them safe.
--The Ta152 and P-51D are important aircraft worth building.  They can intercept jets. 

--Allied fighters will attempt to intercept any German aircraft in range.
canReact[unitAliases.SpitfireIX.id] = {maxAttacks = 2, range = 2, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.SpitfireXII.id] = {maxAttacks = 3, range = 2, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.SpitfireXIV.id] = {maxAttacks = 4, range = 2, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.HurricaneIV.id] = {maxAttacks = 1, range = 1, lowMap = reactionGroups.canInterceptGerman}
canReact[unitAliases.Typhoon.id] = {maxAttacks = 1, range = 1, lowMap = reactionGroups.canInterceptGerman}
canReact[unitAliases.Tempest.id] = {maxAttacks = 1, range = 2, lowMap = reactionGroups.allAir}
canReact[unitAliases.Beaufighter.id] = {maxAttacks = 1, range = 1, nightMap = reactionGroups.canInterceptGerman}
canReact[unitAliases.MosquitoII.id] = {maxAttacks = 2, range = 1, nightMap = reactionGroups.canInterceptGerman}
canReact[unitAliases.MosquitoXIII.id] = {maxAttacks = 2, range = 2, nightMap = reactionGroups.canInterceptGerman}
canReact[unitAliases.P47D11.id] = {maxAttacks = 2, range = 3, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.P47D25.id] = {maxAttacks = 3, range = 3, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.P47D40.id] = {maxAttacks = 4, range = 3, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.P38H.id] = {maxAttacks = 1, range = 2, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.P38J.id] = {maxAttacks = 2, range = 2, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.P38L.id] = {maxAttacks = 3, range = 2, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.P51B.id] = {maxAttacks = 4, range = 4, lowerAltitude = reactionGroups.canInterceptGerman}
canReact[unitAliases.P51D.id] = {maxAttacks = 5, range = 4, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.RedTails.id] = {maxAttacks = 5, range = 5, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.Yak3.id] = {maxAttacks = 1, range = 1, lowMap = reactionGroups.canInterceptGerman}

canReact[unitAliases.RAFAce.id] = {maxAttacks = 4, range = 4, lowerAltitude = reactionGroups.allAir}
canReact[unitAliases.USAAFAce.id] = {maxAttacks = 4, range = 4, lowerAltitude = reactionGroups.allAir}

--Allied Jets 
canReact[unitAliases.P80.id] = {maxAttacks = 2, range = 5, sameTime = reactionGroups.allAir}
canReact[unitAliases.Meteor.id] = {maxAttacks = 2, range = 5, sameTime = reactionGroups.allAir}

--American heavy bombers will only fire defensive fire at high altitude as another incentive to keep them there
canReact[unitAliases.B17F.id] = {maxAttacks = 2, range = 2, highMap = reactionGroups.germanInterceptors}
canReact[unitAliases.B17G.id] = {maxAttacks = 2, range = 3, highMap = reactionGroups.germanInterceptors}
canReact[unitAliases.B24J.id] = {maxAttacks = 1, range = 1, highMap = reactionGroups.germanInterceptors}
canReact[unitAliases.MedBombers.id] = {maxAttacks = 1, range = 1, highMap = reactionGroups.germanInterceptors}

--British bombers have lower range for defensive fire and this isn't generally as effective
canReact[unitAliases.Stirling.id] = {maxAttacks = 1, range = 1, nightMap = reactionGroups.germanInterceptors}
canReact[unitAliases.Halifax.id] = {maxAttacks = 1, range = 2, nightMap = reactionGroups.germanInterceptors}
canReact[unitAliases.Lancaster.id] = {maxAttacks = 2, range = 2, nightMap = reactionGroups.germanInterceptors}

--German bombers can defend as well, but on any map because the Germans would be more likely to use these in tactical role (also they're unlikely to have many so this shouldn't imbalance things)
canReact[unitAliases.He111.id] = {maxAttacks = 1, range = 1, sameMap = reactionGroups.alliedFighters}
canReact[unitAliases.Do217.id] = {maxAttacks = 1, range = 2, sameMap = reactionGroups.alliedFighters}
canReact[unitAliases.He277.id] = {maxAttacks = 2, range = 2, sameMap = reactionGroups.alliedFighters}

--Naval bombers will react to nearby naval units
canReact[unitAliases.Sunderland.id] = {maxAttacks = 1, range = 2, sameMap = reactionGroups.navalUnits}
canReact[unitAliases.Fw200.id] = {maxAttacks = 1, range = 2, sameMap = reactionGroups.navalUnits}







-- reaction Damage, reactionDamage, targetReactionDamage
-- a damageSchedule is a table of tables, like this
--{{.05,7},{.1,1},{.4,1},{.6,1}}
-- The first entry in the smaller table is the probability threshold. If the
-- random number generated is less than that threshold, damage will be done equal
-- to the second entry to the unit
-- This example damage schedule has the following damage probabilities
-- 40% 0 damage (chance random number greater than .6
-- 20% 1 damage (chance random number between .4 and .6)
-- 30% 2 damage (chance r n between .1 and .4
-- 5%  3 damage
-- 5% 10 damage

-- reactionDamage is indexed by the unitType ID number of the reacting unit
-- the value is a table with the following keys
-- .all
-- .low
-- .high
-- .night
-- .dive

-- each of these keys has the following valid value
-- {triggerTypes = tableOfUnitTypes, damageSchedule = damageSchedule}
-- table of {triggerTypes = tableOfUnitTypes, damageSchedule = damageSchedule}

-- If the trigger Unit has a type in the table of unittypes, then the corresponding
-- damage schedule is applied to the unit.

-- all is checked for all units
-- low is checked if the trigger unit is on the low map
-- high is checked if the trigger unit is on the high map
-- night is checked if the trigger unit is on the night map
-- dive is checked if if the trigger unit is on the low map, and the reacting unit is on the high map

-- These are applied cumulatively (so low is extra damage above default, and dive is further damage on top of that)
-- If the following 3 damage schedules are applied to a unit, the probabilities are

-- {{.05,7},{.1,1},{.4,1},{.6,1}}
-- {{.8,1}}
-- [{.05,-7},{.1,7},{.4,1}}
-- 20% No damage (.8-1)
-- 20% 1 damage (.6-.8)
-- 20% 2 damage (.4-.6)
-- 30% 4 damage (.1-.4)
-- 5 % 12 damage(.05-.1)
-- 5 % 12 damage(0-.5)

-- notice that the negative damage in the threshold allows us to increase the probability of the +7 damage hit for the dive, without requiring the lowest 5% to be +14 damage
-- any individual damage schedule can be a health 'bonus' instead of attack, but the overall damage is negative, the unit will simply take 0 damage

-- pre-made damage schedules
local ds = {}
ds.groundForcesAAvStrategicBombers = {{1, 1},{.4,1},{.2,1}}

--88mm and 3.7inch heavy flak.  Should be more likely to hit in daylight than night.  Very likely to damage at low alt.
ds.highFlak = {{.7, 1},{.5,1},{.2,1},{.05,5}}
ds.nightFlak = {{.5, 1},{.3,1},{.1,1},{.01,5}}
ds.lowFlak = {{.9, 5},{.5,3},{.2,7},{.1,5}}


ds.lightFlak = {{1, 7},{.4,3},{.2,7},{.05,3}}
ds.lightFlakJabo = {{1, 2},{.4,2},{.2,3},{.05,4}}

ds.depthCharge = {{1, 10},{.2,10},}

--Aircraft have multiple ds.  interceptors should be stronger against bombers, escorts stronger against fighters, day aircraft stronger at day than at night.  
--To simplify there will be a suffix: 1,2,3 or 4 which corresponds as follows:
-- 1 = high
-- 2 = low
-- 3 = night
-- 4 = dive

--Allied Aircraft don't need all four because they can't actually change maps.  So they will always have 1,2 and 4 or only 3

ds.Fw190A5interceptionBomb1 = {{.8, 3},{.3,5},{.05,7},{.01,5}} 
ds.Fw190A5interceptionBomb2 = {{.9, 3},{.4,5},{.05,7},{.01,5}} 
ds.Fw190A5interceptionBomb3 = {{.4, 3},{.2,5},{.01,12}} 
ds.Fw190A5interceptionBomb4 = {{.7, 10}} 
ds.Fw190A5interceptionFighter1 = {{.4, 1},{.3,4},{.05,5}}
ds.Fw190A5interceptionFighter2 = {{.5, 1},{.4,4},{.05,5}}
ds.Fw190A5interceptionFighter3 = {{.3, 1},{.1,4},{.01,5}}
ds.Fw190A5interceptionFighter4 = {{.7, 10}}

ds.Fw190A8interceptionBomb1 = {{.8, 4},{.5,5},{.05,11}} 
ds.Fw190A8interceptionBomb2 = {{.9, 4},{.6,5},{.05,11}} 
ds.Fw190A8interceptionBomb3 = {{.4, 4},{.2,6},{.01,10}} 
ds.Fw190A8interceptionBomb4 = {{.8, 10}} 
ds.Fw190A8interceptionFighter1 = {{.3, 1},{.3,3},{.01,5}}
ds.Fw190A8interceptionFighter2 = {{.4, 1},{.4,3},{.05,5}}
ds.Fw190A8interceptionFighter3 = {{.3, 1},{.1,3},{.01,5}}
ds.Fw190A8interceptionFighter4 = {{.6, 11}}

ds.Fw190D9interceptionBomb1 = {{.9, 3},{.6,5},{.05,12}} 
ds.Fw190D9interceptionBomb2 = {{.9, 3},{.6,5},{.05,12}} 
ds.Fw190D9interceptionBomb3 = {{.4, 3},{.2,5},{.01,12}} 
ds.Fw190D9interceptionBomb4 = {{.8, 10}} 
ds.Fw190D9interceptionFighter1 = {{.5, 1},{.4,4},{.1,5}}
ds.Fw190D9interceptionFighter2 = {{.5, 1},{.4,4},{.1,5}}
ds.Fw190D9interceptionFighter3 = {{.3, 1},{.1,4},{.01,5}}
ds.Fw190D9interceptionFighter4 = {{.8, 10}}

ds.Ta152interceptionBomb1 = {{1, 3},{.7,5},{.1,12}} 
ds.Ta152interceptionBomb2 = {{1, 3},{.7,5},{.1,12}} 
ds.Ta152interceptionBomb3 = {{.4, 3},{.2,5},{.01,12}} 
ds.Ta152interceptionBomb4 = {{.9, 10}} 
ds.Ta152interceptionFighter1 = {{.7, 1},{.5,4},{.2,5}}
ds.Ta152interceptionFighter2 = {{.7, 1},{.5,4},{.2,5}}
ds.Ta152interceptionFighter3 = {{.4, 1},{.2,4},{.1,5}}
ds.Ta152interceptionFighter4 = {{.9, 10}}
ds.Ta152interceptionJet = {{.2, 10}}

ds.Ju88CinterceptionBomb1 = {{.3, 3},{.1,5},{.05,12}} 
ds.Ju88CinterceptionBomb2 = {{.3, 3},{.1,5},{.05,12}} 
ds.Ju88CinterceptionBomb3 = {{.6, 3},{.2,5},{.1,12}} 
ds.Ju88CinterceptionBomb4 = {{.5, 10}} 
ds.Ju88CinterceptionFighter1 = {{.1, 5},{.01,15}}
ds.Ju88CinterceptionFighter2 = {{.1, 5},{.01,15}}
ds.Ju88CinterceptionFighter3 = {{.4, 3},{.1,5},{.05,12}}
ds.Ju88CinterceptionFighter4 = {{.4, 10}}

ds.Ju88GinterceptionBomb1 = {{.3, 3},{.1,5},{.05,12}} 
ds.Ju88GinterceptionBomb2 = {{.3, 3},{.1,5},{.05,12}} 
ds.Ju88GinterceptionBomb3 = {{.7, 3},{.3,5},{.1,12}} 
ds.Ju88GinterceptionBomb4 = {{.5, 10}} 
ds.Ju88GinterceptionFighter1 = {{.1, 5},{.01,15}}
ds.Ju88GinterceptionFighter2 = {{.1, 5},{.01,15}}
ds.Ju88GinterceptionFighter3 = {{.5, 3},{.2,5},{.1,12}}
ds.Ju88GinterceptionFighter4 = {{.4, 10}}

ds.He219interceptionBomb1 = {{.3, 3},{.1,5},{.05,12}} 
ds.He219interceptionBomb2 = {{.3, 3},{.1,5},{.05,12}} 
ds.He219interceptionBomb3 = {{.8, 3},{.4,5},{.2,12}} 
ds.He219interceptionBomb4 = {{.6, 10}} 
ds.He219interceptionFighter1 = {{.1, 5},{.01,15}}
ds.He219interceptionFighter2 = {{.1, 5},{.01,15}}
ds.He219interceptionFighter3 = {{.6, 3},{.3,5},{.2,12}}
ds.He219interceptionFighter4 = {{.5, 10}}

ds.Me109G6interceptionBomb1 = {{.6, 1},{.4,3},{.05,6}} 
ds.Me109G6interceptionBomb2 = {{.6, 1},{.4,3},{.05,6}} 
ds.Me109G6interceptionBomb3 = {{.3, 1},{.2,3},{.01,6}} 
ds.Me109G6interceptionBomb4 = {{.6, 5}} 
ds.Me109G6interceptionFighter1 = {{.8, 3},{.4,7},{.05,5}}
ds.Me109G6interceptionFighter2 = {{.8, 3},{.4,7},{.05,5}}
ds.Me109G6interceptionFighter3 = {{.3, 3},{.1,7},{.01,5}}
ds.Me109G6interceptionFighter4 = {{.6, 10}}

ds.Me109G14interceptionBomb1 = {{.6, 2},{.4,4},{.05,6}} 
ds.Me109G14interceptionBomb2 = {{.6, 2},{.4,4},{.05,6}} 
ds.Me109G14interceptionBomb3 = {{.3, 2},{.2,4},{.01,6}} 
ds.Me109G14interceptionBomb4 = {{.6, 8}} 
ds.Me109G14interceptionFighter1 = {{.9, 3},{.5,7},{.1,5}}
ds.Me109G14interceptionFighter2 = {{.9, 3},{.5,7},{.1,5}}
ds.Me109G14interceptionFighter3 = {{.3, 3},{.1,7},{.01,5}}
ds.Me109G14interceptionFighter4 = {{.6, 10}}

ds.Me109K4interceptionBomb1 = {{.6, 3},{.4,4},{.05,3}} 
ds.Me109K4interceptionBomb2 = {{.6, 3},{.4,4},{.05,3}} 
ds.Me109K4interceptionBomb3 = {{.3, 3},{.2,4},{.01,3}} 
ds.Me109K4interceptionBomb4 = {{.6, 10}} 
ds.Me109K4interceptionFighter1 = {{1, 3},{.6,7},{.2,5}}
ds.Me109K4interceptionFighter2 = {{1, 3},{.6,7},{.2,5}}
ds.Me109K4interceptionFighter3 = {{.3, 3},{.1,7},{.01,5}}
ds.Me109K4interceptionFighter4 = {{.6, 10}}

--Shares stats with 262 but will only intercept once at range 4
ds.He162interceptionBomb1 = {{1, 10},{.5,10}}
ds.He162interceptionBomb2 = {{1, 10},{.5,10}}
ds.He162interceptionBomb3 = {{.5, 10},{.1,10}}
ds.He162interceptionBomb4 = {{1, 10}}
ds.He162interceptionFighter1 = {{1, 10},{.2,10}}
ds.He162interceptionFighter2 = {{1, 10},{.2,10}}
ds.He162interceptionFighter3 = {{.3, 10},{.1,10}}
ds.He162interceptionFighter4 = {{1, 10}}
ds.He162interceptionJet = {{.7, 10}}

--shares stats with 162 but will intercept twice at range 5
ds.Me262interceptionBomb1 = {{1, 10},{.5,10}}
ds.Me262interceptionBomb2 = {{1, 10},{.5,10}}
ds.Me262interceptionBomb3 = {{.5, 10},{.1,10}}
ds.Me262interceptionBomb4 = {{1, 10}}
ds.Me262interceptionFighter1 = {{1, 10},{.2,10}}
ds.Me262interceptionFighter2 = {{1, 10},{.2,10}}
ds.Me262interceptionFighter3 = {{.3, 10},{.1,10}}
ds.Me262interceptionFighter4 = {{1, 10}}
ds.Me262interceptionJet = {{.7, 10}}

--Jet Experten
ds.JetExperteninterceptionBomb1 = {{1, 10},{.7,10}}
ds.JetExperteninterceptionBomb2 = {{1, 10},{.7,10}}
ds.JetExperteninterceptionBomb3 = {{.5, 10},{.2,10}}
ds.JetExperteninterceptionBomb4 = {{1, 10}}
ds.JetExperteninterceptionFighter1 = {{1, 10},{.3,10}}
ds.JetExperteninterceptionFighter2 = {{1, 10},{.3,10}}
ds.JetExperteninterceptionFighter3 = {{.3, 10},{.2,10}}
ds.JetExperteninterceptionFighter4 = {{1, 15}}
ds.JetExperteninterceptionJet = {{.9, 10}}

--shares stats with 262.  Very dangerous opponent.
ds.ExperteninterceptionBomb1 = {{1, 10},{.5,10}}
ds.ExperteninterceptionBomb2 = {{1, 10},{.5,10}}
ds.ExperteninterceptionBomb3 = {{.5, 10},{.1,10}}
ds.ExperteninterceptionBomb4 = {{1, 10}}
ds.ExperteninterceptionFighter1 = {{1, 10},{.2,10}}
ds.ExperteninterceptionFighter2 = {{1, 10},{.2,10}}
ds.ExperteninterceptionFighter3 = {{.3, 10},{.1,10}}
ds.ExperteninterceptionFighter4 = {{1, 10}}
ds.ExperteninterceptionJet = {{.7, 10}}

--Allied fighters have different reactions for German light fighters, heavy fighters, and bombers.
--1 = high
--2 = low
--3 = night
--4 = dive

--P47s are great at high altitude, subpar at low altitude, great in a dive
ds.P47D11interceptionFighter1 = {{.7, 3},{.5,5},{.1,7}}
ds.P47D11interceptionFighter2 = {{.4, 3},{.1,5},{.01,7}}
ds.P47D11interceptionFighter4 = {{1, 10}}
ds.P47D11interceptionHeavyFighter1 = {{.8, 3},{.6,5},{.2,7}}
ds.P47D11interceptionHeavyFighter2 = {{.5, 3},{.2,5},{.05,7}}
ds.P47D11interceptionHeavyFighter4 = {{1, 10}}
ds.P47D11interceptionBomb1 = {{.9, 3},{.7,5},{.3,7}}
ds.P47D11interceptionBomb2 = {{.8, 3},{.6,5},{.1,7}}
ds.P47D11interceptionBomb4 = {{1, 10}}

ds.P47D25interceptionFighter1 = {{.8, 3},{.6,5},{.2,7}}
ds.P47D25interceptionFighter2 = {{.5, 3},{.2,5},{.03,7}}
ds.P47D25interceptionFighter4 = {{1, 10}}
ds.P47D25interceptionHeavyFighter1 = {{.8, 3},{.6,5},{.2,7}}
ds.P47D25interceptionHeavyFighter2 = {{.6, 3},{.3,5},{.08,7}}
ds.P47D25interceptionHeavyFighter4 = {{1, 10}}
ds.P47D25interceptionBomb1 = {{.95, 3},{.8,5},{.4,7}}
ds.P47D25interceptionBomb2 = {{.9, 3},{.7,5},{.15,7}}
ds.P47D25interceptionBomb4 = {{1, 10}}

ds.P47D40interceptionFighter1 = {{.9, 3},{.7,5},{.3,7}}
ds.P47D40interceptionFighter2 = {{.6, 3},{.3,5},{.05,7}}
ds.P47D40interceptionFighter4 = {{1, 10}}
ds.P47D40interceptionHeavyFighter1 = {{1, 3},{.8,5},{.4,7}}
ds.P47D40interceptionHeavyFighter2 = {{.7, 3},{.4,5},{.1,7}}
ds.P47D40interceptionHeavyFighter4 = {{1, 10}}
ds.P47D40interceptionBomb1 = {{1, 3},{.9,5},{.5,7}}
ds.P47D40interceptionBomb2 = {{1, 3},{.8,5},{.2,7}}
ds.P47D40interceptionBomb4 = {{1, 10}}

--P38s are average at high altitude, poor at low altitude, poor in a dive (L gets better because of dive flaps).  They carry cannon so they can do more damage when they intercept, though.

ds.P38HinterceptionFighter1 = {{.5, 5},{.3,5},{.1,3}}
ds.P38HinterceptionFighter2 = {{.3, 5},{.1,5},{.01,3}}
ds.P38HinterceptionFighter4 = {{.4, 10}}
ds.P38HinterceptionHeavyFighter1 = {{.6, 5},{.4,5},{.15,3}}
ds.P38HinterceptionHeavyFighter2 = {{.4, 5},{.15,5},{.05,3}}
ds.P38HinterceptionHeavyFighter4 = {{.5, 10}}
ds.P38HinterceptionBomb1 = {{.7, 5},{.5,5},{.2,3}}
ds.P38HinterceptionBomb2 = {{.5, 5},{.2,5},{.1,3}}
ds.P38HinterceptionBomb4 = {{.6, 10}}

ds.P38JinterceptionFighter1 = {{.6, 5},{.4,5},{.15,3}}
ds.P38JinterceptionFighter2 = {{.4, 5},{.2,5},{.05,3}}
ds.P38JinterceptionFighter4 = {{.4, 10}}
ds.P38JinterceptionHeavyFighter1 = {{.7, 5},{.5,5},{.2,3}}
ds.P38JinterceptionHeavyFighter2 = {{.5, 5},{.2,5},{.1,3}}
ds.P38JinterceptionHeavyFighter4 = {{.5, 10}}
ds.P38JinterceptionBomb1 = {{.8, 5},{.6,5},{.25,3}}
ds.P38JinterceptionBomb2 = {{.6, 5},{.3,5},{.15,3}}
ds.P38JinterceptionBomb4 = {{.6, 10}}

--P38L has same stats as P38J but significantly improved dive due to dive flaps
ds.P38LinterceptionFighter1 = {{.6, 5},{.4,5},{.15,3}}
ds.P38LinterceptionFighter2 = {{.4, 5},{.2,5},{.05,3}}
ds.P38LinterceptionFighter4 = {{.7, 10}}
ds.P38LinterceptionHeavyFighter1 = {{.7, 5},{.5,5},{.2,3}}
ds.P38LinterceptionHeavyFighter2 = {{.5, 5},{.2,5},{.1,3}}
ds.P38LinterceptionHeavyFighter4 = {{.8, 10}}
ds.P38LinterceptionBomb1 = {{.8, 5},{.6,5},{.25,3}}
ds.P38LinterceptionBomb2 = {{.6, 5},{.3,5},{.15,3}}
ds.P38LinterceptionBomb4 = {{.9, 10}}

--Spitfires are best at low altitude - the XIV is also good at high altitude
ds.SpitfireIXinterceptionFighter1 = {{.4, 4},{.2,5},{.1,7}}
ds.SpitfireIXinterceptionFighter2 = {{.7, 4},{.5,5},{.2,7}}
ds.SpitfireIXinterceptionFighter4 = {{.6, 10}}
ds.SpitfireIXinterceptionHeavyFighter1 = {{.5, 4},{.3,5},{.2,7}}
ds.SpitfireIXinterceptionHeavyFighter2 = {{.8, 4},{.6,5},{.3,7}}
ds.SpitfireIXinterceptionHeavyFighter4 = {{.7, 10}}
ds.SpitfireIXinterceptionBomb1 = {{.6, 4},{.4,5},{.3,7}}
ds.SpitfireIXinterceptionBomb2 = {{.8, 4},{.7,5},{.4,7}}
ds.SpitfireIXinterceptionBomb4 = {{.8, 10}}

ds.SpitfireXIIinterceptionFighter1 = {{.5, 4},{.3,5},{.2,7}}
ds.SpitfireXIIinterceptionFighter2 = {{.8, 4},{.6,5},{.3,7}}
ds.SpitfireXIIinterceptionFighter4 = {{.7, 10}}
ds.SpitfireXIIinterceptionHeavyFighter1 = {{.6, 4},{.4,5},{.3,7}}
ds.SpitfireXIIinterceptionHeavyFighter2 = {{.9, 4},{.7,5},{.4,7}}
ds.SpitfireXIIinterceptionHeavyFighter4 = {{.8, 10}}
ds.SpitfireXIIinterceptionBomb1 = {{.7, 4},{.5,5},{.3,7}}
ds.SpitfireXIIinterceptionBomb2 = {{.9, 4},{.8,5},{.5,7}}
ds.SpitfireXIIinterceptionBomb4 = {{.9, 10}}

ds.SpitfireXIVinterceptionFighter1 = {{.8, 4},{.6,5},{.3,7}}
ds.SpitfireXIVinterceptionFighter2 = {{.8, 4},{.6,5},{.3,7}}
ds.SpitfireXIVinterceptionFighter4 = {{.7, 10}}
ds.SpitfireXIVinterceptionHeavyFighter1 = {{.9, 4},{.7,5},{.4,7}}
ds.SpitfireXIVinterceptionHeavyFighter2 = {{.9, 4},{.7,5},{.4,7}}
ds.SpitfireXIVinterceptionHeavyFighter4 = {{.8, 10}}
ds.SpitfireXIVinterceptionBomb1 = {{.9, 4},{.8,5},{.5,7}}
ds.SpitfireXIVinterceptionBomb2 = {{.9, 4},{.8,5},{.5,7}}
ds.SpitfireXIVinterceptionBomb4 = {{.9, 10}}

--P-51's are excellent fighters at high and low altitude. P-51D can potentially intercept jets

ds.P51BinterceptionFighter1 = {{.8, 3},{.6,5},{.3,7}}
ds.P51BinterceptionFighter2 = {{.8, 3},{.6,5},{.3,7}}
ds.P51BinterceptionFighter4 = {{1, 10}}
ds.P51BinterceptionHeavyFighter1 = {{.9, 3},{.7,5},{.4,7}}
ds.P51BinterceptionHeavyFighter2 = {{.9, 3},{.7,5},{.4,7}}
ds.P51BinterceptionHeavyFighter4 = {{1, 10}}
ds.P51BinterceptionBomb1 = {{.9, 3},{.8,5},{.5,7}}
ds.P51BinterceptionBomb2 = {{.9, 3},{.8,5},{.5,7}}
ds.P51BinterceptionBomb4 = {{1, 10}}

ds.P51DinterceptionFighter1 = {{.8, 3},{.6,5},{.3,7}}
ds.P51DinterceptionFighter2 = {{.8, 3},{.6,5},{.3,7}}
ds.P51DinterceptionFighter4 = {{1, 10}}
ds.P51DinterceptionHeavyFighter1 = {{.9, 3},{.7,5},{.4,7}}
ds.P51DinterceptionHeavyFighter2 = {{.9, 3},{.7,5},{.4,7}}
ds.P51DinterceptionHeavyFighter4 = {{1, 10}}
ds.P51DinterceptionBomb1 = {{.9, 3},{.8,5},{.5,7}}
ds.P51DinterceptionBomb2 = {{.9, 3},{.8,5},{.5,7}}
ds.P51DinterceptionBomb4 = {{1, 10}}
ds.P51DinterceptionJet = {{.2, 5}}

--Tuskeegee Airmen have good chance to intercept bomber destroyers
ds.RedTailsinterceptionFighter1 = {{.8, 3},{.6,5},{.3,7}}
ds.RedTailsinterceptionFighter2 = {{.8, 3},{.6,5},{.3,7}}
ds.RedTailsinterceptionFighter4 = {{1, 10}}
ds.RedTailsinterceptionHeavyFighter1 = {{1, 3},{.8,5},{.6,7}}
ds.RedTailsinterceptionHeavyFighter2 = {{1, 3},{.8,5},{.6,7}}
ds.RedTailsinterceptionHeavyFighter4 = {{1, 10}}
ds.RedTailsinterceptionBomb1 = {{.9, 3},{.8,5},{.5,7}}
ds.RedTailsinterceptionBomb2 = {{.9, 3},{.8,5},{.5,7}}
ds.RedTailsinterceptionBomb4 = {{1, 10}}
ds.RedTailsinterceptionJet = {{.2, 10}}

--Yaks, Hurricane IV, Typhoons, and Tempests can intercept aircraft at low alt
ds.Yak3interceptionFighter2 = {{.8, 4},{.6,5},{.4,7}}
ds.Yak3interceptionHeavyFighter2 = {{.9, 4},{.7,5},{.5,7}}
ds.Yak3interceptionBomb2 = {{1, 4},{.8,5},{.6,7}}

ds.HurricaneinterceptionFighter2 = {{.5, 4},{.3,5},{.1,7}}
ds.HurricaneinterceptionHeavyFighter2 = {{.6, 4},{.4,5},{.2,7}}
ds.HurricaneinterceptionBomb2 = {{.7, 4},{.5,5},{.3,7}}

ds.TyphooninterceptionFighter2 = {{.6, 4},{.4,5},{.2,7}}
ds.TyphooninterceptionHeavyFighter2 = {{.7, 4},{.5,5},{.3,7}}
ds.TyphooninterceptionBomb2 = {{.8, 4},{.6,5},{.4,7}}

ds.TempestinterceptionFighter2 = {{.7, 4},{.5,5},{.3,7}}
ds.TempestinterceptionHeavyFighter2 = {{.8, 4},{.6,5},{.4,7}}
ds.TempestinterceptionBomb2 = {{.9, 4},{.7,5},{.5,7}}
ds.TempestinterceptionJet = {{.2, 10}}

--Allied night fighters can only intercept at night
ds.BeaufighterinterceptionFighter3 = {{.4, 3},{.1,5},{.05,12}}
ds.BeaufighterinterceptionHeavyFighter3 = {{.45, 3},{.15,5},{.1,12}}
ds.BeaufighterinterceptionBomb3 = {{.6, 3},{.2,5},{.1,12}}

ds.MosquitoIIFighter3 = {{.45, 3},{.15,5},{.1,12}}
ds.MosquitoIIHeavyFighter3 = {{.5, 3},{.2,5},{.15,12}}
ds.MosquitoIIBomb3 = {{.65, 3},{.25,5},{.15,12}}

ds.MosquitoXIIIFighter3 = {{.5, 3},{.2,5},{.15,12}}
ds.MosquitoXIIIHeavyFighter3 = {{.55, 3},{.25,5},{.2,12}}
ds.MosquitoXIIIBomb3 = {{.7, 3},{.3,5},{.2,12}}

--Allied Jets
ds.P80interceptionFighter1 = {{1, 10},{.2,10}}
ds.P80interceptionFighter2 = {{1, 10},{.2,10}}
ds.P80interceptionFighter4 = {{1, 10}}
ds.P80interceptionHeavyFighter1 = {{1, 10},{.4,10}}
ds.P80interceptionHeavyFighter2 = {{1, 10},{.4,10}}
ds.P80interceptionHeavyFighter4 = {{1, 10}}
ds.P80interceptionBomb1 = {{1, 10},{.5,10}}
ds.P80interceptionBomb2 = {{1, 10},{.5,10}}
ds.P80interceptionBomb4 = {{1, 10}}
ds.P80interceptionJet = {{.7, 10}}

ds.MeteorinterceptionFighter1 = {{1, 10},{.2,10}}
ds.MeteorinterceptionFighter2 = {{1, 10},{.2,10}}
ds.MeteorinterceptionFighter4 = {{1, 10}}
ds.MeteorinterceptionHeavyFighter1 = {{1, 10},{.4,10}}
ds.MeteorinterceptionHeavyFighter2 = {{1, 10},{.4,10}}
ds.MeteorinterceptionHeavyFighter4 = {{1, 10}}
ds.MeteorinterceptionBomb1 = {{1, 10},{.5,10}}
ds.MeteorinterceptionBomb2 = {{1, 10},{.5,10}}
ds.MeteorinterceptionBomb4 = {{1, 10}}
ds.MeteorinterceptionJet = {{.7, 10}}

--Allied bombers will fire but shouldn't do much damage alone, but intercepting large formations is not for the faint of heart.  
ds.B24JdefensiveFireReaction = {{.6, 1},{.4,1},{.1,1},{.05,1}}
ds.MedBombersdefensiveFireReaction = {{.6, 1},{.4,1},{.1,1},{.05,1}}
ds.B17FdefensiveFireReaction = {{.8, 2},{.6,2},{.4,2},{.05,2}}
ds.B17GdefensiveFireReaction = {{.8, 2},{.6,2},{.5,2},{.1,2}}
--ds.SturmbockReaction = {{.4, 1},{.3,1},{.05,1},{.03,1}}

ds.StirlingdefensiveFireReaction = {{.6, 1},{.4,1},{.05,1}}
ds.HalifaxdefensiveFireReaction = {{.6, 1},{.4,1},{.05,1}}
ds.LancasterdefensiveFireReaction = {{.6, 1},{.4,1},{.05,1}}

ds.He111defensiveFireReaction = {{.5, 1},{.3,1},{.05,1}}
ds.Do217defensiveFireReaction = {{.5, 1},{.3,1},{.05,1}}
ds.He277defensiveFireReaction = {{.5, 1},{.3,1},{.05,1}}

ds.gunBatteryFireReaction = {{1, 3},{.6,7},{.2,5}}

ds.testing1 = {{1,20}}
ds.testing2 = {{1,10}}
ds.testing3 = {{1,5}}
ds.testing4 = {{1,10}}

local reactionDamage = {}
-- Gun Battery TEST
reactionDamage[unitAliases.GunBattery.id] = {low={triggerTypes = reactionGroups.gunBatteryVulnerable, damageSchedule = ds.gunBatteryFireReaction}}
--Ground forces.  For now, no differentation between infantry and tanks and also artillery are vulnerable and won't fire back.

reactionDamage[unitAliases.GermanArmyGroup.id] ={low = {triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.groundForcesAAvStrategicBombers}}
reactionDamage[unitAliases.GermanBatteredArmyGroup.id] ={low = {triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.groundForcesAAvStrategicBombers}}
reactionDamage[unitAliases.AlliedArmyGroup.id] ={low = {triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.groundForcesAAvStrategicBombers}}
reactionDamage[unitAliases.AlliedBatteredArmyGroup.id] ={low = {triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.groundForcesAAvStrategicBombers}}
reactionDamage[unitAliases.AlliedBatteredArmyGroup.id] ={low = {triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.groundForcesAAvStrategicBombers}}
reactionDamage[unitAliases.RedArmyGroup.id] ={low = {triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.groundForcesAAvStrategicBombers}}

--Heavy flak reaction damages (88mm, FlakTrain and 3.7inch)
reactionDamage[unitAliases.FlakTrain.id] = {high = {triggerTypes = reactionGroups.allButJets, damageSchedule = ds.highFlak}, 
low = {triggerTypes = reactionGroups.allButJabo, damageSchedule = ds.lowFlak}, 
night = {triggerTypes = reactionGroups.allButJets, damageSchedule = ds.nightFlak}}

reactionDamage[unitAliases.GermanFlak.id] = {high = {triggerTypes = reactionGroups.allButJets, damageSchedule = ds.highFlak}, 
low = {triggerTypes = reactionGroups.allButJabo, damageSchedule = ds.lowFlak}, 
night = {triggerTypes = reactionGroups.allButJets, damageSchedule = ds.nightFlak}}

reactionDamage[unitAliases.AlliedFlak.id] = {high = {triggerTypes = reactionGroups.allButJets, damageSchedule = ds.highFlak}, 
low = {triggerTypes = reactionGroups.allButJabo, damageSchedule = ds.lowFlak}, 
night = {triggerTypes = reactionGroups.allButJets, damageSchedule = ds.nightFlak}}

--Low altitude flak reaction.  Most aircraft take heavy damage.  Jabo likely to take light damage.  Medium bombers take no damage from light flak on attack.

reactionDamage[unitAliases.GermanLightFlak.id] ={low = {{triggerTypes = reactionGroups.allButJabo, damageSchedule = ds.lightFlak},{triggerTypes=reactionGroups.jabo, damageSchedule = ds.lightFlakJabo}} }
reactionDamage[unitAliases.AlliedLightFlak.id] ={low = {{triggerTypes = reactionGroups.allButJabo, damageSchedule = ds.lightFlak},{triggerTypes=reactionGroups.jabo, damageSchedule = ds.lightFlakJabo}} }
reactionDamage[unitAliases.Sdkfz.id] ={low = {{triggerTypes = reactionGroups.allButJabo, damageSchedule = ds.lightFlak},{triggerTypes=reactionGroups.jabo, damageSchedule = ds.lightFlakJabo}} }
reactionDamage[unitAliases.AlliedTaskForce.id] ={low = {{triggerTypes = reactionGroups.allButJabo, damageSchedule = ds.lightFlak},{triggerTypes=reactionGroups.jabo, damageSchedule = ds.lightFlakJabo}} }
reactionDamage[unitAliases.GermanTaskForce.id] ={low = {{triggerTypes = reactionGroups.allButJabo, damageSchedule = ds.lightFlak},{triggerTypes=reactionGroups.jabo, damageSchedule = ds.lightFlakJabo}} }

--Naval Bombers attacking other forces
reactionDamage[unitAliases.Sunderland.id] ={low = {triggerTypes = reactionGroups.navalUnits, damageSchedule = ds.depthCharge}}
reactionDamage[unitAliases.Fw200.id] ={low = {triggerTypes = reactionGroups.navalUnits, damageSchedule = ds.depthCharge}}

--German interceptors and night fighters
reactionDamage[unitAliases.Fw190A5.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190A5interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190A5interceptionFighter1}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190A5interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190A5interceptionFighter2}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190A5interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190A5interceptionFighter3}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190A5interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190A5interceptionFighter4}} }

reactionDamage[unitAliases.Fw190A8.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190A8interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190A8interceptionFighter1}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190A8interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190A8interceptionFighter2}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190A8interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190A8interceptionFighter3}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190A8interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190A8interceptionFighter4}} }

reactionDamage[unitAliases.Fw190D9.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190D9interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190D9interceptionFighter1}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190D9interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190D9interceptionFighter2}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190D9interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190D9interceptionFighter3}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Fw190D9interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Fw190D9interceptionFighter4}} }

reactionDamage[unitAliases.Ta152.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ta152interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ta152interceptionFighter1},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.Ta152interceptionJet}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ta152interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ta152interceptionFighter2},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.Ta152interceptionJet}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ta152interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ta152interceptionFighter3},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.Ta152interceptionJet}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ta152interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ta152interceptionFighter4},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.Ta152interceptionJet}} }

reactionDamage[unitAliases.Ju88C.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ju88CinterceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ju88CinterceptionFighter1}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ju88CinterceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ju88CinterceptionFighter2}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ju88CinterceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ju88CinterceptionFighter3}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ju88CinterceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ju88CinterceptionFighter4}} }

reactionDamage[unitAliases.Ju88G.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ju88GinterceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ju88GinterceptionFighter1}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ju88GinterceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ju88GinterceptionFighter2}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ju88GinterceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ju88GinterceptionFighter3}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Ju88GinterceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Ju88GinterceptionFighter4}} }

reactionDamage[unitAliases.He219.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.He219interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.He219interceptionFighter1}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.He219interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.He219interceptionFighter2}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.He219interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.He219interceptionFighter3}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.He219interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.He219interceptionFighter4}} }

--German jet aircraft

reactionDamage[unitAliases.He162.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.He162interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.He162interceptionFighter1},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.He162interceptionJet}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.He162interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.He162interceptionFighter2},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.He162interceptionJet}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.He162interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.He162interceptionFighter3},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.He162interceptionJet}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.He162interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.He162interceptionFighter4},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.He162interceptionJet}} }

reactionDamage[unitAliases.Me262.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me262interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me262interceptionFighter1},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.Me262interceptionJet}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me262interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me262interceptionFighter2},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.Me262interceptionJet}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me262interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me262interceptionFighter3},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.Me262interceptionJet}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me262interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me262interceptionFighter4},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.Me262interceptionJet}} }


--German Experten
reactionDamage[unitAliases.EgonMayer.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter1},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter2},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter3},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter4},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}} }

reactionDamage[unitAliases.HermannGraf.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter1},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter2},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter3},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter4},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}} }

reactionDamage[unitAliases.JosefPriller.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter1},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter2},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter3},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter4},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}} }

reactionDamage[unitAliases.hwSchnaufer.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter1},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter2},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter3},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter4},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}} }

reactionDamage[unitAliases.Experten.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter1},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter2},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter3},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.ExperteninterceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.ExperteninterceptionFighter4},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.ExperteninterceptionJet}} }



reactionDamage[unitAliases.AdolfGalland.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.JetExperteninterceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.JetExperteninterceptionFighter1},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.JetExperteninterceptionJet}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.JetExperteninterceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.JetExperteninterceptionFighter2},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.JetExperteninterceptionJet}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.JetExperteninterceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.JetExperteninterceptionFighter3},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.JetExperteninterceptionJet}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.JetExperteninterceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.JetExperteninterceptionFighter4},
{triggerTypes=reactionGroups.alliedJets, damageSchedule = ds.JetExperteninterceptionJet}} }

--German escort fighters
reactionDamage[unitAliases.Me109G6.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109G6interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109G6interceptionFighter1}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109G6interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109G6interceptionFighter2}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109G6interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109G6interceptionFighter3}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109G6interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109G6interceptionFighter4}} }


reactionDamage[unitAliases.Me109G14.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109G14interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109G14interceptionFighter1}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109G14interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109G14interceptionFighter2}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109G14interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109G14interceptionFighter3}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109G14interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109G14interceptionFighter4}} }


reactionDamage[unitAliases.Me109K4.id] ={high = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109K4interceptionBomb1},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109K4interceptionFighter1}},
low = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109K4interceptionBomb2},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109K4interceptionFighter2}},
night = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109K4interceptionBomb3},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109K4interceptionFighter3}},
dive = {{triggerTypes = reactionGroups.strategicBombers, damageSchedule = ds.Me109K4interceptionBomb4},
{triggerTypes=reactionGroups.alliedFighters, damageSchedule = ds.Me109K4interceptionFighter4}} }



--Allied fighters will attack most German aircraft with exception of jets
reactionDamage[unitAliases.P47D11.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P47D11interceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P47D11interceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P47D11interceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P47D11interceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P47D11interceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P47D11interceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P47D11interceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P47D11interceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P47D11interceptionBomb4}}, }

reactionDamage[unitAliases.P47D25.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P47D25interceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P47D25interceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P47D25interceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P47D25interceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P47D25interceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P47D25interceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P47D25interceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P47D25interceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P47D25interceptionBomb4}}, }

reactionDamage[unitAliases.P47D40.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P47D40interceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P47D40interceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P47D40interceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P47D40interceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P47D40interceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P47D40interceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P47D40interceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P47D40interceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P47D40interceptionBomb4}}, }

reactionDamage[unitAliases.P38H.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P38HinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P38HinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P38HinterceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P38HinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P38HinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P38HinterceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P38HinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P38HinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P38HinterceptionBomb4}}, }

reactionDamage[unitAliases.P38J.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P38JinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P38JinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P38JinterceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P38JinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P38JinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P38JinterceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P38JinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P38JinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P38JinterceptionBomb4}}, }

reactionDamage[unitAliases.P38L.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P38LinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P38LinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P38LinterceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P38LinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P38LinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P38LinterceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P38LinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P38LinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P38LinterceptionBomb4}}, }

reactionDamage[unitAliases.SpitfireIX.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.SpitfireIXinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.SpitfireIXinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.SpitfireIXinterceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.SpitfireIXinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.SpitfireIXinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.SpitfireIXinterceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.SpitfireIXinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.SpitfireIXinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.SpitfireIXinterceptionBomb4}}, }

reactionDamage[unitAliases.SpitfireXII.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.SpitfireXIIinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.SpitfireXIIinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.SpitfireXIIinterceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.SpitfireXIIinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.SpitfireXIIinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.SpitfireXIIinterceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.SpitfireXIIinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.SpitfireXIIinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.SpitfireXIIinterceptionBomb4}}, }

reactionDamage[unitAliases.SpitfireXIV.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.SpitfireXIVinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.SpitfireXIVinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.SpitfireXIVinterceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.SpitfireXIVinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.SpitfireXIVinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.SpitfireXIVinterceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.SpitfireXIVinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.SpitfireXIVinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.SpitfireXIVinterceptionBomb4}}, }

reactionDamage[unitAliases.P51B.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P51BinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P51BinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P51BinterceptionBomb1}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P51BinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P51BinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P51BinterceptionBomb2}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P51BinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P51BinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P51BinterceptionBomb4}}, }

reactionDamage[unitAliases.P51D.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P51DinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P51DinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P51DinterceptionBomb1},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.P51DinterceptionJet}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P51DinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P51DinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P51DinterceptionBomb2},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.P51DinterceptionJet}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P51DinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P51DinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P51DinterceptionBomb4},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.P51DinterceptionJet}}, }

reactionDamage[unitAliases.RedTails.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.RedTailsinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.RedTailsinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.RedTailsinterceptionBomb1},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.RedTailsinterceptionJet}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.RedTailsinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.RedTailsinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.RedTailsinterceptionBomb2},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.RedTailsinterceptionJet}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.RedTailsinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.RedTailsinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.RedTailsinterceptionBomb4},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.RedTailsinterceptionJet}}, }

reactionDamage[unitAliases.RAFAce.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.RedTailsinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.RedTailsinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.RedTailsinterceptionBomb1},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.RedTailsinterceptionJet}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.RedTailsinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.RedTailsinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.RedTailsinterceptionBomb2},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.RedTailsinterceptionJet}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.RedTailsinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.RedTailsinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.RedTailsinterceptionBomb4},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.RedTailsinterceptionJet}}, }

reactionDamage[unitAliases.USAAFAce.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.RedTailsinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.RedTailsinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.RedTailsinterceptionBomb1},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.RedTailsinterceptionJet}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.RedTailsinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.RedTailsinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.RedTailsinterceptionBomb2},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.RedTailsinterceptionJet}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.RedTailsinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.RedTailsinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.RedTailsinterceptionBomb4},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.RedTailsinterceptionJet}}, }

reactionDamage[unitAliases.HurricaneIV.id] ={low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.HurricaneinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.HurricaneinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.HurricaneinterceptionBomb2}},}


reactionDamage[unitAliases.Typhoon.id] ={low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.TyphooninterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.TyphooninterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.TyphooninterceptionBomb2}},}

reactionDamage[unitAliases.Tempest.id] ={low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.TempestinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.TempestinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.TempestinterceptionBomb2},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.TempestinterceptionJet}},}

reactionDamage[unitAliases.Yak3.id] ={low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.Yak3interceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.Yak3interceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.Yak3interceptionBomb2}},}

reactionDamage[unitAliases.Beaufighter.id] ={night = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.BeaufighterinterceptionFighter3},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.BeaufighterinterceptionHeavyFighter3},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.BeaufighterinterceptionBomb3}},}

reactionDamage[unitAliases.MosquitoII.id] ={night = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.MosquitoIIFighter3},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.MosquitoIIHeavyFighter3},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.MosquitoIIBomb3}},}

reactionDamage[unitAliases.MosquitoXIII.id] ={night = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.MosquitoXIIIFighter3},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.MosquitoXIIIHeavyFighter3},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.MosquitoXIIIBomb3}},}

reactionDamage[unitAliases.P80.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P80DinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P80interceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P80interceptionBomb1},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.P80interceptionJet}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P80interceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P80interceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P80interceptionBomb2},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.P80interceptionJet}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.P80interceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.P80interceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.P80interceptionBomb4},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.P80interceptionJet}}, }

reactionDamage[unitAliases.Meteor.id] ={high = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.MeteorDinterceptionFighter1},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.MeteorinterceptionHeavyFighter1},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.MeteorinterceptionBomb1},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.MeteorinterceptionJet}},
low = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.MeteorinterceptionFighter2},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.MeteorinterceptionHeavyFighter2},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.MeteorinterceptionBomb2},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.MeteorinterceptionJet}},
dive = {{triggerTypes = reactionGroups.luftwaffeFighter, damageSchedule = ds.MeteorinterceptionFighter4},
{triggerTypes=reactionGroups.luftwaffeHeavyFighter, damageSchedule = ds.MeteorinterceptionHeavyFighter4},
{triggerTypes=reactionGroups.luftwaffeBomber, damageSchedule = ds.MeteorinterceptionBomb4},
{triggerTypes=reactionGroups.luftwaffeJets, damageSchedule = ds.MeteorinterceptionJet}}, }


--The various strategic bombers fire defensive fire.  The tactical bombers rely on speed (they can't be intercepted and have to be directly attacked but they don't fire defensively either).
reactionDamage[unitAliases.B24J.id] ={high = {triggerTypes = reactionGroups.germanInterceptors, damageSchedule = ds.B24JdefensiveFireReaction},}
reactionDamage[unitAliases.B17F.id] ={high = {triggerTypes = reactionGroups.germanInterceptors, damageSchedule = ds.B17FdefensiveFireReaction},}
reactionDamage[unitAliases.B17G.id] ={high = {triggerTypes = reactionGroups.germanInterceptors, damageSchedule = ds.B17GdefensiveFireReaction},}
reactionDamage[unitAliases.MedBombers.id] ={high = {triggerTypes = reactionGroups.germanInterceptors, damageSchedule = ds.MedBombersdefensiveFireReaction},}

reactionDamage[unitAliases.Stirling.id] ={night = {triggerTypes = reactionGroups.germanInterceptors, damageSchedule = ds.StirlingdefensiveFireReaction},}
reactionDamage[unitAliases.Halifax.id] ={night = {triggerTypes = reactionGroups.germanInterceptors, damageSchedule = ds.HalifaxdefensiveFireReaction},}
reactionDamage[unitAliases.Lancaster.id] ={night = {triggerTypes = reactionGroups.germanInterceptors, damageSchedule = ds.LancasterdefensiveFireReaction},}

reactionDamage[unitAliases.He111.id] ={all = {triggerTypes = reactionGroups.alliedFighters, damageSchedule = ds.He111defensiveFireReaction},}
reactionDamage[unitAliases.Do217.id] ={all = {triggerTypes = reactionGroups.alliedFighters, damageSchedule = ds.Do217defensiveFireReaction},}
reactionDamage[unitAliases.He277.id] ={all = {triggerTypes = reactionGroups.alliedFighters, damageSchedule = ds.He277defensiveFireReaction},}

--The naval bombers attacking naval units
reactionDamage[unitAliases.Sunderland.id] ={all = {triggerTypes = reactionGroups.navalUnits, damageSchedule = ds.depthCharge},}
reactionDamage[unitAliases.Fw200.id] ={all = {triggerTypes = reactionGroups.navalUnits, damageSchedule = ds.depthCharge},}

--, high = {triggerTypes = reactionGroups.allAir, damageSchedule = ds.heavyFlak},

-- areaReactionDamage area reaction
-- Information for damage done to other reacting units
-- indexed by unitTypeID
-- value is table with up to 5 entries
-- reactFriend = {range= int, vulnerableTypes = tableOfUnitTypes, all = damageSchedule, low =damageSchedule , high = damageSchedule, night = damageSchedule,dive =damageSchedule, diffTime = bool} or table of same
-- reactFoe = {range= int, vulnerableTypes = tableOfUnitTypes, all = damageSchedule, low = damageSchedule, high = damageSchedule, night = damageSchedule,dive =damageSchedule, diffTime = bool} or table of same
-- bystanderFriend = {range= int, vulnerableTypes = tableOfUnitTypes, all = damageSchedule, low = damageSchedule, high = damageSchedule, night = damageSchedule,dive =damageSchedule, diffTime = bool} or table of same
-- bystanderFoe = {range= int, vulnerableTypes = tableOfUnitTypes, all = damageSchedule, low =damageSchedule , high = damageSchedule, night = damageSchedule,dive =damageSchedule, diffTime = bool} or table of same
-- areaDamageOnlyIfReactingTo = table of unitTypes

-- reactFriend is damage done to friendly units that are reacting to the trigger unit
-- reactFoe is damage done to enemy units that are reacting to the trigger unit (at the moment, this category doesn't exist)
-- bystanderFriend is done to friendly units not reacting to the trigger unit
-- bystanderFoe is done to enemy units not reacting to the trigger unit

-- areaDamgeOnlyIfReactingTo give unitTypes for which this unit will do area damage when reacting.  If nil (absent), area damage is done for all trigger unit types.

-- range is the max distance between the areaDamage unit and the other reacting or bystanding unit
-- e.g. a fighter could farther than the 'range' of the flak unit could react safely
-- (i.e. be stationed on an approach and 'react' then), or the range could be extended on the basis
-- that the fighter has to follow the bomber into the flak to attack it
-- all, low, high, night, dive are all damage schedules with the same meaning as the targetReactionDamage damage schedules (except that here . They are all optional.  diffTime is optional.  If true, the damage is done even if the bystander/reactor is on a different time (day vs night) from the trigger unit. (e.g. flak fired in day time would also hit nearby night units)


local areaReactionDamage={}
ds.reactFriendTest = {{1, 1},{.4,1},{.2,3},{.05,5}}
ds.bystanderFriendTest = {{1, 1},{.4,1},{.2,3},{.05,5}}
ds.bystanderFoeTest = {{1, 1},{.4,2},{.2,3},{.05,4}}
reactionGroups.bombs = {unitAliases.TwoHundredFiftylb, unitAliases.FiveHundredlb,unitAliases.Thousandlb,}
ds.bystanderBombs = {{1,2},{.8,2},{.6,3},{.1,3}}

--areaReactionDamage[unitAliases.FlakTrain.id] = {bystanderFoe = {range = 2,vulnerableTypes = reactionGroups.bombs, all=ds.bystanderBombs}}
--areaReactionDamage[unitAliases.GermanFlak.id] = {bystanderFoe = {range = 2,vulnerableTypes = reactionGroups.bombs, all=ds.bystanderBombs}}
--areaReactionDamage[unitAliases.AlliedFlak.id] = {bystanderFoe = {range = 2,vulnerableTypes = reactionGroups.bombs, all=ds.bystanderBombs}}
--[[
areaReactionDamage[unitAliases.FlakTrain.id] = {
reactFriend = {range = 2, vulnerableTypes = reactionGroups.allButJets, all = ds.reactFriendTest},
bystanderFriend = {range = 2, vulnerableTypes = reactionGroups.allButJets, all = ds.bystanderFriendTest},
bystanderFoe = {range = 2, vulnerableTypes = reactionGroups.allButJets, all = ds.bystanderFoeTest},
}
areaReactionDamage[unitAliases.GermanFlak.id] = {
reactFriend = {range = 3, vulnerableTypes = reactionGroups.allButJets, all = ds.reactFriendTest},
bystanderFriend = {range = 3, vulnerableTypes = reactionGroups.allButJets, all = ds.bystanderFriendTest},
bystanderFoe = {range = 3, vulnerableTypes = reactionGroups.allButJets, all = ds.bystanderFoeTest},
}
areaReactionDamage[unitAliases.AlliedFlak.id] = {
reactFriend = {range = 3, vulnerableTypes = reactionGroups.allButJets, all = ds.reactFriendTest},
bystanderFriend = {range = 3, vulnerableTypes = reactionGroups.allButJets, all = ds.bystanderFriendTest},
bystanderFoe = {range = 3, vulnerableTypes = reactionGroups.allButJets, all = ds.bystanderFoeTest},
}
--]]

-- reaction warning reactionWarning

-- This table sets the category for each reaction type, to be used for determining the warning a player gets when they face reacting units.  Any absent entry uses the name of the unit as the category.  'dive' is automatically added if the trigger unit and reacting unit are on maps 0 and 1 respectively, and the reacting unit gets a dive bonus (even if there is no bonus against the trigger unit).

local reactionWarningType = {

--[unitAliases.B17F.id] = "bomber",
--[unitAliases.B17G.id] = "bomber",
}

local suppressReactionWarningText = false

-- state.reactionWarning gives information about the different threats facing the trigger unit

local function resetReactionWarning()
state.reactionWarning = {}
end


local function updateReactionWarning(triggerUnit, reactingUnit)
    local wkey = nil
    if reactionWarningType[reactingUnit.type.id] then
        wkey = reactionWarningType[reactingUnit.type.id]
    else
        wkey = reactingUnit.type.name
    end
    --print(wkey)
    --state.reactionWarning = state.reactionWarning or {}
    state.reactionWarning[wkey] = state.reactionWarning[wkey] or 0
    state.reactionWarning[wkey] = state.reactionWarning[wkey] + 1
    if triggerUnit.location.z == 0 and reactingUnit.location.z == 1 and reactionDamage[reactingUnit.type.id].dive then
        state.reactionWarning["dive"] = (state.reactionWarning["dive"] or 0) + 1
    end
end

local function displayReactionWarning()
    local title = "We are under attack by the following units:"
    local textToDisplay = ""
    for key, value in pairs(state.reactionWarning) do
        
        textToDisplay = textToDisplay.."\n^"..key..": "..tostring(value)
    end
    
    --local disp = civ.ui.createDialog()
    --disp.title = title
    --print(textToDisplay)
    if textToDisplay ~= "" then
        civ.ui.text(func.splitlines(title..textToDisplay))
        --disp:addText(textToDisplay)
        --disp:show()
    end
end


-- postReactionInfo
-- indexed by reactingUnitTypeID
-- {fuel = int, custom = function(triggerUnit,reactingUnit) --> void
-- absent keys mean do nothing
-- fuel means fuel expended for the reaction, however, can keep reacting on empty treasury
-- custom means run this function
-- can add more functionality if we need it
-- absent index means do nothing special for this unit type after it react

local postReactionInfo = {}



-- damage roll modifier damagerollmodifier targetDamageRollModifier(triggerUnit,reactingUnit)

-- The damage roll modifiers are as follows (more can be added if necessary).  All modifiers are multiplied together to get a result.
-- the damage roll for the target reaction (always between 0 and 1)
-- is multiplied by the result of this function
-- Results greater than 1 reduce the chance of damage, while results
-- less than 1 increase the chance of damage (since a lower roll is better)
-- A .5 modifier means a 5% event becomes a 10% event, and any event with probability 50% or more, becomes certain.
-- A 2 modifier means that a 5% event becomes a 2.5% event, and a formerly 100% event is now a 50% event
--[[

.clouds = number
    Modifier if the victim is on a cloud square
.cloudsTech1=tech, .cloudsTech1Mod=number
.cloudsTech2=tech, .cloudsTech2Mod=number
    Technologies owned by the attacker that change accuracy when the
    victim is in the clouds
    cloudsTechX is the technology to activate the modifier
    cloudsTechXMod is the modifier itself
.tech1=tech, .tech1Mod=number
.tech2=tech, .tech2Mod=number
    Technologies owned by the attacker that change accuracy
    techX is the technology to activate the modifier
    techXMod is the modifier itself
.enemyTech1=tech, .enemyTech1Mod=number
.enemyTech2=tech, .enemyTech2Mod=number
    Technologies owned by the victim that change accuracy
    same pattern as above
.counterToEnemyTech1=tech, counterToEnemyTech1Mod = number
.counterToEnemyTech2=tech, counterToEnemyTech2Mod = number
    If victim has enemyTechX and attacker has counterToEnemyTechX then
    apply counterToEnemyTechXMod (in addition to enemyTechXMod)
--]]
-- default target modifiers
dTM = {clouds = 1.5, cloudsTech1=nil, cloudsTech1Mod = 1, cloudsTech2=nil, cloudsTech2Mod=1, tech1=nil, tech1Mod=nil, tech2=nil, tech2Mod=1, enemyTech1=techAliases.TacticsI, enemyTech1Mod=1.2, enemyTech2=techAliases.TacticsII,enemyTech2Mod=1.5,counterToEnemyTech1=techAliases.TacticsI, counterToEnemyTech1Mod=1/1.2,counterToEnemyTech2 = techAliases.TacticsII, counterToEnemyTech2Mod=1/1.5,}






--dTM = {clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM = {}

-- Heavy Flak should get a bonus from tech 83 (proximity fuses) and tech 88 (advanced radar III)
targetDRM[unitAliases.GermanFlak.id]={clouds =dTM.clouds, cloudsTech1=techAliases.ProximityFuses, cloudsTech1Mod =1.25/dTM.clouds, cloudsTech2=techAliases.AdvancedRadarIII, cloudsTech2Mod=1.18/1.25, tech1=techAliases.ProximityFuses, tech1Mod=.85, tech2=techAliases.AdvancedRadarIII, tech2Mod=.85, enemyTech1=nil, enemyTech1Mod=nil, enemyTech2=nil,enemyTech2Mod=nil,counterToEnemyTech1=nil, counterToEnemyTech1Mod=nil, counterToEnemyTech2Mod=nil,}
targetDRM[unitAliases.AlliedFlak.id]={clouds =dTM.clouds, cloudsTech1=techAliases.ProximityFuses, cloudsTech1Mod =1.25/dTM.clouds, cloudsTech2=techAliases.AdvancedRadarIII, cloudsTech2Mod=1.18/1.25, tech1=techAliases.ProximityFuses, tech1Mod=.85, tech2=techAliases.AdvancedRadarIII, tech2Mod=.85, enemyTech1=nil, enemyTech1Mod=nil, enemyTech2=nil,enemyTech2Mod=nil,counterToEnemyTech1=nil, counterToEnemyTech1Mod=nil, counterToEnemyTech2Mod=nil,}

-- 2nd Generation night fighters should have less of an issue reacting to units in clouds 
targetDRM[unitAliases.Ju88G.id]={clouds =1.3, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.MosquitoII.id]={clouds =1.3, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}

--3rd Generation night fighters should have less of an issue reacting to units in clouds, and should get a bonus from tech 88 (advanced radar III)
targetDRM[unitAliases.He219.id]={clouds =1.1, cloudsTech1=techAliases.AdvancedRadarIII, cloudsTech1Mod =1/1.1, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.MosquitoXIII.id]={clouds =1.1, cloudsTech1=techAliases.AdvancedRadarIII, cloudsTech1Mod =1/1.1, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}

-- Regular aircraft should have no bonus to reacting against units in clouds regardless of techs.  Flak train also gets no bonus as it is firing while moving.
targetDRM[unitAliases.FlakTrain.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.EarlyRadar.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.AdvancedRadar.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Fw200.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Sdkfz.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Me109G6.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Me109G14.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Me109K4.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Fw190A5.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Fw190A8.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Fw190D9.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Ta152.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Me110.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Me410.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Ju88C.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.He162.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Me163.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Me262.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.AdolfGalland.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.HermannGraf.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.EgonMayer.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.JosefPriller.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.hwSchnaufer.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Experten.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Ju87G.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Fw190F.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Do335.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Do217.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.He277.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Arado234.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Go229.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.SpitfireIX.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.SpitfireXII.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.SpitfireXIV.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.HurricaneIV.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Typhoon.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Tempest.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Meteor.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Beaufighter.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.P47D11.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.P47D25.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.P47D40.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.P38H.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.P38J.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.P38L.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.P51B.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.P51D.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.P80.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Stirling.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Halifax.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Lancaster.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Pathfinder.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.A20.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.B26.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.A26.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.B17F.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.B24J.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.B17G.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
--targetDRM[unitAliases.Artillery1.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.He111.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Sunderland.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
--targetDRM[unitAliases.LightCruiser.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.GermanTaskForce.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.AlliedTaskForce.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.RedTails.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.RAFAce.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.USAAFAce.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.MedBombers.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.FifteenthAF.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.GunBattery.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Yak3.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Il2.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Ju188.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.MossiePR.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Convoy.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.GermanLightFlak.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.AlliedLightFlak.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.Carrier.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.damagedB17F.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.damagedB17G.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.UBoat.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.FreightTrain.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.GermanArmyGroup.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.GermanBatteredArmyGroup.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.RedArmyGroup.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.AlliedArmyGroup.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.AlliedBatteredArmyGroup.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}
targetDRM[unitAliases.constructionTeam.id]={clouds =dTM.clouds, cloudsTech1=dTM.cloudsTech1, cloudsTech1Mod =dTM.cloudsTech1Mod, cloudsTech2=dTM.cloudsTech2, cloudsTech2Mod=dTM.cloudsTech2Mod, tech1=dTM.tech1, tech1Mod=dTM.tech1Mod, tech2=dTM.tech2, tech2Mod=dTM.tech2Mod, enemyTech1=dTM.enemyTech1, enemyTech1Mod=dTM.enemyTech1Mod, enemyTech2=dTM.enemyTech2,enemyTech2Mod=dTM.enemyTech2Mod,counterToEnemyTech1=dTM.counterToEnemyTech1, counterToEnemyTech1Mod=dTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dTM.counterToEnemyTech2Mod,}


-- damage roll modifier damagerollmodifier areaDamageRollReactingFriendModifier(otherReactingUnit,areaDamageUnit,triggerUnit)


-- The damage roll modifiers are as follows (more can be added if necessary).  All modifiers are multiplied together to get a result.
-- the damage roll for the target reaction (always between 0 and 1)
-- is multiplied by the result of this function
-- Results greater than 1 reduce the chance of damage, while results
-- less than 1 increase the chance of damage (since a lower roll is better)
-- A .5 modifier means a 5% event becomes a 10% event, and any event with probability 50% or more, becomes certain.
-- A 2 modifier means that a 5% event becomes a 2.5% event, and a formerly 100% event is now a 50% event
--[[

.clouds = number
    Modifier if the victim (otherReactingUnit) is on a cloud square
.cloudsTech1=tech, .cloudsTech1Mod=number
.cloudsTech2=tech, .cloudsTech2Mod=number
    Technologies owned by the attacker that change accuracy when the
    victim is in the clouds
    cloudsTechX is the technology to activate the modifier
    cloudsTechXMod is the modifier itself
.tech1=tech, .tech1Mod=number
.tech2=tech, .tech2Mod=number
    Technologies owned by the attacker that change accuracy
    techX is the technology to activate the modifier
    techXMod is the modifier itself
.enemyTech1=tech, .enemyTech1Mod=number
.enemyTech2=tech, .enemyTech2Mod=number
    Technologies owned by the victim that change accuracy
    same pattern as above
.counterToEnemyTech1=tech, counterToEnemyTech1Mod = number
.counterToEnemyTech2=tech, counterToEnemyTech2Mod = number
    If victim has enemyTechX and attacker has counterToEnemyTechX then
    apply counterToEnemyTechXMod (in addition to enemyTechXMod)
--]]

-- default target modifiers for area reaction against reacting units
dARTM = {clouds = .9, cloudsTech1=nil, cloudsTech1Mod = 1, cloudsTech2=nil, cloudsTech2Mod=1, tech1=techAliases.TacticsI, tech1Mod=1.2, tech2=nil, tech2Mod=1, enemyTech1=nil, enemyTech1Mod=1, enemyTech2=nil,enemyTech2Mod=1,counterToEnemyTech1=nil, counterToEnemyTech1Mod=1,counterToEnemyTech2 = nil, counterToEnemyTech2Mod=1,}

--dTM = {clouds =dARTM.clouds, cloudsTech1=dARTM.cloudsTech1, cloudsTech1Mod =dARTM.cloudsTech1Mod, cloudsTech2=dARTM.cloudsTech2, cloudsTech2Mod=dARTM.cloudsTech2Mod, tech1=dARTM.tech1, tech1Mod=dARTM.tech1Mod, tech2=dARTM.tech2, tech2Mod=dARTM.tech2Mod, enemyTech1=dARTM.enemyTech1, enemyTech1Mod=dARTM.enemyTech1Mod, enemyTech2=dARTM.enemyTech2,enemyTech2Mod=dARTM.enemyTech2Mod,counterToEnemyTech1=dARTM.counterToEnemyTech1, counterToEnemyTech1Mod=dARTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dARTM.counterToEnemyTech2Mod,}

areaReactDRM = {}
areaReactDRM[unitAliases.GermanFlak.id]=dARTM
--{clouds =dARTM.clouds, cloudsTech1=techAliases.ProximityFuses, cloudsTech1Mod =dARTM.cloudsTech1Mod, cloudsTech2=techAliases.AdvancedRadarIII, cloudsTech2Mod=.75, tech1=techAliases.ProximityFuses, tech1Mod=.75, tech2=techAliases.AdvancedRadarIII, tech2Mod=.5, enemyTech1=nil, enemyTech1Mod=nil, enemyTech2=nil,enemyTech2Mod=nil,counterToEnemyTech1=nil, counterToEnemyTech1Mod=nil, counterToEnemyTech2Mod=nil,}

areaReactDRM[unitAliases.AlliedFlak.id]=dARTM
--{clouds =dARTM.clouds, cloudsTech1=techAliases.ProximityFuses, cloudsTech1Mod =dARTM.cloudsTech1Mod, cloudsTech2=techAliases.AdvancedRadarIII, cloudsTech2Mod=.75, tech1=techAliases.ProximityFuses, tech1Mod=.75, tech2=techAliases.AdvancedRadarIII, tech2Mod=.5, enemyTech1=nil, enemyTech1Mod=nil, enemyTech2=nil,enemyTech2Mod=nil,counterToEnemyTech1=nil, counterToEnemyTech1Mod=nil, counterToEnemyTech2Mod=nil,}

areaReactDRM[unitAliases.FlakTrain.id]=dARTM
--{clouds =dARTM.clouds, cloudsTech1=dARTM.cloudsTech1, cloudsTech1Mod =dARTM.cloudsTech1Mod, cloudsTech2=dARTM.cloudsTech2, cloudsTech2Mod=dARTM.cloudsTech2Mod, tech1=dARTM.tech1, tech1Mod=dARTM.tech1Mod, tech2=dARTM.tech2, tech2Mod=dARTM.tech2Mod, enemyTech1=dARTM.enemyTech1, enemyTech1Mod=dARTM.enemyTech1Mod, enemyTech2=dARTM.enemyTech2,enemyTech2Mod=dARTM.enemyTech2Mod,counterToEnemyTech1=dARTM.counterToEnemyTech1, counterToEnemyTech1Mod=dARTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dARTM.counterToEnemyTech2Mod,}

-- damage roll modifier damagerollmodifier areaDamageRollNotReactingModifier(otherNearbyUnit,areaDamageUnit,triggerUnit)

-- The damage roll modifiers are as follows (more can be added if necessary).  All modifiers are multiplied together to get a result.
-- the damage roll for the target reaction (always between 0 and 1)
-- is multiplied by the result of this function
-- Results greater than 1 reduce the chance of damage, while results
-- less than 1 increase the chance of damage (since a lower roll is better)
-- A .5 modifier means a 5% event becomes a 10% event, and any event with probability 50% or more, becomes certain.
-- A 2 modifier means that a 5% event becomes a 2.5% event, and a formerly 100% event is now a 50% event
--[[

.clouds = number
    Modifier if the victim (otherNearbyUnit, i.e. bystander)is on a cloud square
.cloudsTech1=tech, .cloudsTech1Mod=number
.cloudsTech2=tech, .cloudsTech2Mod=number
    Technologies owned by the attacker that change accuracy when the
    victim is in the clouds
    cloudsTechX is the technology to activate the modifier
    cloudsTechXMod is the modifier itself
.tech1=tech, .tech1Mod=number
.tech2=tech, .tech2Mod=number
    Technologies owned by the attacker that change accuracy
    techX is the technology to activate the modifier
    techXMod is the modifier itself
.enemyTech1=tech, .enemyTech1Mod=number
.enemyTech2=tech, .enemyTech2Mod=number
    Technologies owned by the victim that change accuracy
    same pattern as above
.counterToEnemyTech1=tech, counterToEnemyTech1Mod = number
.counterToEnemyTech2=tech, counterToEnemyTech2Mod = number
    If victim has enemyTechX and attacker has counterToEnemyTechX then
    apply counterToEnemyTechXMod (in addition to enemyTechXMod)
--]]
-- default target modifiers for area reaction against bystander units
dABTM = {clouds = 1, cloudsTech1=nil, cloudsTech1Mod = 1, cloudsTech2=nil, cloudsTech2Mod=1, tech1=nil, tech1Mod=nil, tech2=nil, tech2Mod=1, enemyTech1=nil, enemyTech1Mod=1, enemyTech2=nil,enemyTech2Mod=1,counterToEnemyTech1=nil, counterToEnemyTech1Mod=1,counterToEnemyTech2 = nil, counterToEnemyTech2Mod=1,}

--dTM = {clouds =dABTM.clouds, cloudsTech1=dABTM.cloudsTech1, cloudsTech1Mod =dABTM.cloudsTech1Mod, cloudsTech2=dABTM.cloudsTech2, cloudsTech2Mod=dABTM.cloudsTech2Mod, tech1=dABTM.tech1, tech1Mod=dABTM.tech1Mod, tech2=dABTM.tech2, tech2Mod=dABTM.tech2Mod, enemyTech1=dABTM.enemyTech1, enemyTech1Mod=dABTM.enemyTech1Mod, enemyTech2=dABTM.enemyTech2,enemyTech2Mod=dABTM.enemyTech2Mod,counterToEnemyTech1=dABTM.counterToEnemyTech1, counterToEnemyTech1Mod=dABTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dABTM.counterToEnemyTech2Mod,}

areaBystanderDRM = {}

-- Heavy Flak should get a bonus from tech 83 (proximity fuses) and tech 88 (advanced radar III)
areaBystanderDRM[unitAliases.GermanFlak.id]=dABTM
--{clouds =dABTM.clouds, cloudsTech1=techAliases.ProximityFuses, cloudsTech1Mod =dABTM.cloudsTech1Mod, cloudsTech2=techAliases.AdvancedRadarIII, cloudsTech2Mod=.75, tech1=techAliases.ProximityFuses, tech1Mod=.75, tech2=techAliases.AdvancedRadarIII, tech2Mod=.5, enemyTech1=nil, enemyTech1Mod=nil, enemyTech2=nil,enemyTech2Mod=nil,counterToEnemyTech1=nil, counterToEnemyTech1Mod=nil, counterToEnemyTech2Mod=nil,}
areaBystanderDRM[unitAliases.AlliedFlak.id]=dABTM
--{clouds =dABTM.clouds, cloudsTech1=techAliases.ProximityFuses, cloudsTech1Mod =dABTM.cloudsTech1Mod, cloudsTech2=techAliases.AdvancedRadarIII, cloudsTech2Mod=.75, tech1=techAliases.ProximityFuses, tech1Mod=.75, tech2=techAliases.AdvancedRadarIII, tech2Mod=.5, enemyTech1=nil, enemyTech1Mod=nil, enemyTech2=nil,enemyTech2Mod=nil,counterToEnemyTech1=nil, counterToEnemyTech1Mod=nil, counterToEnemyTech2Mod=nil,}

areaBystanderDRM[unitAliases.FlakTrain.id]=dABTM
--{clouds =dABTM.clouds, cloudsTech1=dABTM.cloudsTech1, cloudsTech1Mod =dABTM.cloudsTech1Mod, cloudsTech2=dABTM.cloudsTech2, cloudsTech2Mod=dABTM.cloudsTech2Mod, tech1=dABTM.tech1, tech1Mod=dABTM.tech1Mod, tech2=dABTM.tech2, tech2Mod=dABTM.tech2Mod, enemyTech1=dABTM.enemyTech1, enemyTech1Mod=dABTM.enemyTech1Mod, enemyTech2=dABTM.enemyTech2,enemyTech2Mod=dABTM.enemyTech2Mod,counterToEnemyTech1=dABTM.counterToEnemyTech1, counterToEnemyTech1Mod=dABTM.counterToEnemyTech1Mod, counterToEnemyTech2Mod=dABTM.counterToEnemyTech2Mod,}



-- Here is the code (except that which goes where the munition is created) that transforms the above tables into functions


local function getRangeAndProbability(unitType,dataTable,defaultRange)
    -- try the case where the entry is just a table of units
    local isTableOfUnitTypes = true
    for __,value in pairs(dataTable) do
        if not(civ.isUnitType(value)) then
            -- entry is not a table of units, try next type
            isTableOfUnitTypes = false
            break
        elseif unitType == value then
            return {range = defaultRange, prob = 1}
        end
    end
    if isTableOfUnitTypes then
        -- the unit was not found in the table
        return false
    end
    if dataTable.unitTypes then
        -- we have {range = integer, unitTypes = table of unitTypes, probability = num between 0 and 1}
        for __, uType in pairs(dataTable.uniTypes) do
            if uType == unitType then
                return {range = (dataTable.range or defaultRange), prob = (dataTable.probability or 1)}
            end
        end
        -- if we get here, the unit isn't in this dataTable
        return false
    else
        -- dataTable is table of {range = integer, unitTypes = table of unitTypes, probability = num between 0 and 1}
        for __, tripleTable in pairs(dataTable) do
            for __,uType in pairs(tripleTable.unitTypes) do
                if uType == unitType then
                    return {range = (tripleTable.range or defaultRange),prob = (tripleTable.probability or 1)}
                end
            end
        end
        return false
    end
end

local function canReactFunction(triggerUnit,reactingUnit)
    if debugFeatures then
        print("canReactFunction for reacting unit")
        print(reactingUnit)
    end
    -- Check if units are owned by the same tribe
    if triggerUnit.owner == reactingUnit.owner then
       debugPrint("sameOwner")
        return false
    end
    -- Check if the unit even has an entry in the table
    if not(canReact[reactingUnit.type.id]) then
        debugPrint("NoEntryInTable")
        return false
    end
    if reactingUnit.location.city and reactingUnit.type.domain == 1 then
        debugPrint("Air unit in city/airfield")
        return false
    end
    local reactionEntry = canReact[reactingUnit.type.id]
    debugPrint("CanReact[reactingUnit.type.id]")
    debugPrint(canReact[reactingUnit.type.id])
    debugPrint("reactionEntry")
    debugPrint(reactionEntry)
    -- check if the unit is within the operating radius
    if not checkIfInOperatingRadius(reactingUnit) then
        return false
    end
    -- check if on allowed terrain
    if reactionEntry.allowedTerrainTypes and not(reactionEntry.allowedTerrainTypes[reactingUnit.location.terrainType%16]) then
        debugPrint("Reacting Unit on incorrect terrain")
        return false
    end
    -- check if the unit has used all its reactions
    if reactionEntry.maxAttacks and state.reactions[reactingUnit.id] 
        and reactionEntry.maxAttacks <=state.reactions[reactingUnit.id] then
            debugPrint("All Reactions Used")
            return false
    end
    local function horizontalDistance(unitA,unitB)
        local lA = unitA.location
        local lB = unitB.location
        if debugFeatures and math.floor((math.abs(lA.x-lB.x)+math.abs(lA.y-lB.y))/2) < 0 then
        debugPrint("distance calculated to be less than 0 between")
        debugPrint(unitA)
        debugPrint(unitB)
        debugPrint(math.floor((math.abs(lA.x-lB.x)+math.abs(lA.y-lB.y))/2))
        end
        return math.floor((math.abs(lA.x-lB.x)+math.abs(lA.y-lB.y))/2)
        -- The floor aspect just makes sure that an integer is returned, e.g. 2 instead of 2.0
    end
    local probOutcome = math.random()
    if reactionEntry.anyMap then
        local rAndP = getRangeAndProbability(triggerUnit.type, reactionEntry.anyMap, reactionEntry.range)
        if rAndP then
            debugPrint(rAndP.range)
            debugPrint(probOutcome)
            debugPrint(rAndP.prob)
            if rAndP.range >= horizontalDistance(triggerUnit,reactingUnit) and probOutcome <= rAndP.prob then
                debugPrint("Can React")
                return true
            end
        end
    end
    if reactionEntry.sameMap and triggerUnit.location.z == reactingUnit.location.z then
        local rAndP = getRangeAndProbability(triggerUnit.type,reactionEntry.sameMap,reactionEntry.range)
        if rAndP then
            if rAndP.range >= horizontalDistance(triggerUnit,reactingUnit) and probOutcome <=rAndP.prob then
                debugPrint("CanReact")
                return true
            end
        end
    end
    if reactionEntry.sameTime and 
        ((triggerUnit.location.z == 2 and reactingUnit.location.z ==2) or
         (triggerUnit.location.z <=1 and reactingUnit.location.z <= 1)) then
        local rAndP = getRangeAndProbability(triggerUnit.type,reactionEntry.sameTime,reactionEntry.range)
        if rAndP then
            if rAndP.range >= horizontalDistance(triggerUnit,reactingUnit) and probOutcome <=rAndP.prob then
                return true
            end
        end
    end
    if reactionEntry.lowerAltitude and reactingUnit.location.z <=1 and triggerUnit.location.z <= reactingUnit.location.z then
        local rAndP = getRangeAndProbability(triggerUnit.type,reactionEntry.lowerAltitude,reactionEntry.range)
        if rAndP then
            if rAndP.range >= horizontalDistance(triggerUnit,reactingUnit) and probOutcome <=rAndP.prob then
                return true
            end
        end
    end
    debugPrint("reactionEntry.lowMap")
    debugPrint(reactionEntry.lowMap)
    if reactionEntry.lowMap and triggerUnit.location.z == 0 and reactingUnit.location.z == 0 then
        debugPrint("checking reactionEntry.lowMap")
        local rAndP = getRangeAndProbability(triggerUnit.type,reactionEntry.lowMap,reactionEntry.range)
        if rAndP then
            if rAndP.range >= horizontalDistance(triggerUnit,reactingUnit) and probOutcome <=rAndP.prob then
                return true
            end
        end    
    end
    if reactionEntry.highMap and triggerUnit.location.z == 1 and reactingUnit.location.z == 1 then
        local rAndP = getRangeAndProbability(triggerUnit.type,reactionEntry.highMap,reactionEntry.range)
        if rAndP then
            if rAndP.range >= horizontalDistance(triggerUnit,reactingUnit) and probOutcome <=rAndP.prob then
                return true
            end
        end    
    end
    if reactionEntry.nightMap and triggerUnit.location.z == 2 and reactingUnit.location.z == 2 then
        local rAndP = getRangeAndProbability(triggerUnit.type,reactionEntry.nightMap,reactionEntry.range)
        if rAndP then
            if rAndP.range >= horizontalDistance(triggerUnit,reactingUnit) and probOutcome <=rAndP.prob then
                return true
            end
        end    
    end
end

local function getDamage(damageTable,triggerUnitType,damageRoll)
    local damage = 0
    if damageTable.triggerTypes then
        -- case {triggerTypes = tableOfUnitTypes, damageSchedule = damageSchedule}
        for __,uType in pairs(damageTable.triggerTypes) do
            if uType == triggerUnitType then
                for l,threshold in pairs(damageTable.damageSchedule) do
                    if damageRoll <= threshold[1] then
                        damage = damage + threshold[2]
                    end
                end
                -- Once we've found the unit and applied the damage schedule, we can return           
                return damage
            end
        end--for __,uType in pairs(damageTable.triggerTypes)
    else
        -- case table of {triggerTypes = tableOfUnitTypes, damageSchedule = damageSchedule}
        for __, subDamageTable in pairs(damageTable) do
            for l,uType in pairs(subDamageTable.triggerTypes) do
                if uType == triggerUnitType then
                    for m,threshold in pairs(subDamageTable.damageSchedule) do
                        if damageRoll <= threshold[1] then
                            damage = damage+threshold[2]
                        end
                    end
                    -- Once we've found the unit and applied the damage schedule, we can return
                    return damage
                end
            end --for l,uType in pairs(subDamageTable.triggerTypes) do
        end --for __, subDamageTable in pairs(damageTable) do
    end
    return damage -- if we get here, damage should be 0 anyway
end

-- the damage roll for the target reaction (always between 0 and 1)
-- is multiplied by the result of this function
-- Results greater than 1 reduce the chance of damage, while results
-- less than 1 increase the chance of damage (since a lower roll is better)
-- A .5 modifier means a 5% event becomes a 10% event, and any event with probability 50% or more, becomes certain.
-- A 2 modifier means that a 5% event becomes a 2.5% event, and a formerly 100% event is now a 50% event
local function targetDamageRollModifier(triggerUnit,reactingUnit)
    local modifier = 1
    local modInfo = targetDRM[reactingUnit.type.id]
    local rUOwner = reactingUnit.owner
    local victimUnit = triggerUnit
    if modInfo == nil then
        return 1
    end
    if clouds.inClouds(victimUnit) then
        modifier = modifier*(modInfo.clouds or 1)
        if modInfo.cloudsTech1 and civ.hasTech(rUOwner,modInfo.cloudsTech1) then
            modifier = modifier*(modInfo.cloudsTech1Mod or 1)
        end
        if modInfo.cloudsTech2 and civ.hasTech(rUOwner,modInfo.cloudsTech2) then
            modifier = modifier*(modInfo.cloudsTech2Mod or 1)
        end
    end
    if modInfo.tech1 and civ.hasTech(rUOwner, modInfo.tech1) then
        modifier = modifier*(modInfo.tech1Mod or 1)
    end
    if modInfo.tech2 and civ.hasTech(rUOwner, modInfo.tech2) then
        modifier = modifier*(modInfo.tech2Mod or 1)
    end
    if modInfo.enemyTech1 and civ.hasTech(victimUnit.owner,modInfo.enemyTech1) then
        modifier = modifier*(modInfo.enemyTech1Mod or 1)
        if modInfo.counterToEnemyTech1 and civ.hasTech(rUOwner,modInfo.counterToEnemyTech1) then
            modifier = modifier*(modInfo.counterToEnemyTech1Mod or 1)
        end
    end
    if modInfo.enemyTech2 and civ.hasTech(victimUnit.owner,modInfo.enemyTech2) then
        modifier = modifier*(modInfo.enemyTech2Mod or 1)
        if modInfo.counterToEnemyTech2 and civ.hasTech(rUOwner,modInfo.counterToEnemyTech2) then
            modifier = modifier*(modInfo.counterToEnemyTech2Mod or 1)
        end
    end
    return modifier
end

-- the damage roll for the damage to a reacting friend (always between 0 and 1)
-- is multiplied by the result of this function
-- Results greater than 1 reduce the chance of damage, while results
-- less than 1 increase the chance of damage (since a lower roll is better)
-- A .5 modifier means a 5% event becomes a 10% event, and any event with probability 50% or more, becomes certain.
-- A 2 modifier means that a 5% event becomes a 2.5% event, and a formerly 100% event is now a 50% event
local function areaDamageRollReactingFriendModifier(otherReactingUnit,areaDamageUnit,triggerUnit)
    local modifier = 1
    local modInfo = areaReactDRM[reactingUnit.type.id]
    local rUOwner = areaDamageUnit.owner
    local victimUnit = otherReactingUnit
    if modInfo == nil then
        return 1
    end
    if clouds.inClouds(victimUnit) then
        modifier = modifier*(modInfo.clouds or 1)
        if modInfo.cloudsTech1 and civ.hasTech(rUOwner,modInfo.cloudsTech1) then
            modifier = modifier*(modInfo.cloudsTech1Mod or 1)
        end
        if modInfo.cloudsTech2 and civ.hasTech(rUOwner,modInfo.cloudsTech2) then
            modifier = modifier*(modInfo.cloudsTech2Mod or 1)
        end
    end
    if modInfo.tech1 and civ.hasTech(rUOwner, modInfo.tech1) then
        modifier = modifier*(modInfo.tech1 or 1)
    end
    if modInfo.tech2 and civ.hasTech(rUOwner, modInfo.tech2) then
        modifier = modifier*(modInfo.tech2 or 1)
    end
    if modInfo.enemyTech1 and civ.hasTech(victimUnit.owner,modInfo.enemyTech1) then
        modifier = modifier*(modInfo.enemyTech1Mod or 1)
        if modInfo.counterToEnemyTech1 and civ.hasTech(rUOwner,modInfo.counterToEnemyTech1) then
            modifier = modifier*(modInfo.counterToEnemyTech1Mod or 1)
        end
    end
    if modInfo.enemyTech2 and civ.hasTech(victimUnit.owner,modInfo.enemyTech2) then
        modifier = modifier*(modInfo.enemyTech2Mod or 1)
        if modInfo.counterToEnemyTech2 and civ.hasTech(rUOwner,modInfo.counterToEnemyTech2) then
            modifier = modifier*(modInfo.counterToEnemyTech2Mod or 1)
        end
    end
    return modifier
end

-- the damage roll for the damage to a bystander unit (always between 0 and 1)
-- is multiplied by the result of this function
-- Results greater than 1 reduce the chance of damage, while results
-- less than 1 increase the chance of damage (since a lower roll is better)
-- A .5 modifier means a 5% event becomes a 10% event, and any event with probability 50% or more, becomes certain.
-- A 2 modifier means that a 5% event becomes a 2.5% event, and a formerly 100% event is now a 50% event
local function areaDamageRollNotReactingModifier(otherNearbyUnit,areaDamageUnit,triggerUnit)
    local modifier = 1
    local modInfo = areaBystanderDRM[reactingUnit.type.id]
    local rUOwner = areaDamageUnit.owner
    local victimUnit = otherNearbyUnit
    if modInfo == nil then
        return 1
    end
    if clouds.inClouds(victimUnit) then
        modifier = modifier*(modInfo.clouds or 1)
        if modInfo.cloudsTech1 and civ.hasTech(rUOwner,modInfo.cloudsTech1) then
            modifier = modifier*(modInfo.cloudsTech1Mod or 1)
        end
        if modInfo.cloudsTech2 and civ.hasTech(rUOwner,modInfo.cloudsTech2) then
            modifier = modifier*(modInfo.cloudsTech2Mod or 1)
        end
    end
    if modInfo.tech1 and civ.hasTech(rUOwner, modInfo.tech1) then
        modifier = modifier*(modInfo.tech1 or 1)
    end
    if modInfo.tech2 and civ.hasTech(rUOwner, modInfo.tech2) then
        modifier = modifier*(modInfo.tech2 or 1)
    end
    if modInfo.enemyTech1 and civ.hasTech(victimUnit.owner,modInfo.enemyTech1) then
        modifier = modifier*(modInfo.enemyTech1Mod or 1)
        if modInfo.counterToEnemyTech1 and civ.hasTech(rUOwner,modInfo.counterToEnemyTech1) then
            modifier = modifier*(modInfo.counterToEnemyTech1Mod or 1)
        end
    end
    if modInfo.enemyTech2 and civ.hasTech(victimUnit.owner,modInfo.enemyTech2) then
        modifier = modifier*(modInfo.enemyTech2Mod or 1)
        if modInfo.counterToEnemyTech2 and civ.hasTech(rUOwner,modInfo.counterToEnemyTech2) then
            modifier = modifier*(modInfo.counterToEnemyTech2Mod or 1)
        end
    end
    return modifier
end


                
local function targetReactionDamage(triggerUnit,reactingUnit)
    debugPrint("The reacting unit is a ",reactingUnit.type)
    local damage = 0
    local damageRoll = math.random()*targetDamageRollModifier(triggerUnit,reactingUnit)

    local reactionDamageEntry = reactionDamage[reactingUnit.type.id]
    if reactionDamageEntry == nil then
        civ.ui.text("No entry in ractionDamage table for "..reactingUnit.type.name)
       return damage
    end
    if reactionDamageEntry.all then
    damage = damage + getDamage(reactionDamageEntry.all,triggerUnit.type,damageRoll)
    end
    if triggerUnit.location.z == 0 and reactionDamageEntry.low then
        damage = damage + getDamage(reactionDamageEntry.low,triggerUnit.type,damageRoll)   
    elseif triggerUnit.location.z == 1 and reactionDamageEntry.high then
        damage = damage + getDamage(reactionDamageEntry.high,triggerUnit.type,damageRoll)
    elseif triggerUnit.location.z == 2 and reactionDamageEntry.night then
        damage = damage + getDamage(reactionDamageEntry.night,triggerUnit.type,damageRoll)
    end
    if triggerUnit.location.z == 0 and reactingUnit.location.z == 1 and reactionDamageEntry.dive then
            damage = damage + getDamage(reactionDamageEntry.dive,triggerUnit.type,damageRoll)
    end
    return math.max(0,math.floor(damage))
end

local function isAreaDamageUnit(triggerUnit,reactingUnit)
    if areaReactionDamage[reactingUnit.type.id] then
        if areaReactionDamage[reactingUnit.type.id].areaDamageOnlyIfReactingTo then
            for __, uType in pairs(areaReactionDamage[reactingUnit.type.id].areaDamageOnlyIfReactingTo) do
                if triggerUnit.type == uType then
                    return true
                end
            end
            return false
        else
            return true
        end
    else
        return false
    end
end

local function getDamageFromSchedule(damageSchedule,damageRoll)
    local damage = 0
    for __,threshold in pairs(damageSchedule) do
        if damageRoll <= threshold[1] then
            damage = damage + threshold[2]
        end
    end
    return damage
end

local function areaDamageToReactingUnit(otherReactingUnit,areaDamageUnit,triggerUnit)
    local damageInfo = nil
    if otherReactingUnit.owner == areaDamageUnit.owner then
        damageInfo = areaReactionDamage[areaDamageUnit.type.id].reactFriend
    else
        damageInfo = areaReactionDamage[areaDamageUnit.type.id].reactFoe
    end
    local damage = 0
    if damageInfo == nil then
        -- areaDamageUnit doesn't do damage to this class of reacting unit
        return 0
    end
    local function horizontalDistance(unitA,unitB)
        local lA = unitA.location
        local lB = unitB.location
        return math.floor((math.abs(lA.x-lB.x)+math.abs(lA.y-lB.y))/2)
        -- The floor aspect just makes sure that an integer is returned, e.g. 2 instead of 2.0
    end
    if horizontalDistance(otherReactingUnit,areaDamageUnit) > damageInfo.range then
        -- unit out of range case
        return 0
    end
    if not((triggerUnit.location.z == 2 and otherReactingUnit.location.z ==2)
        or (triggerUnit.location.z <=1 and otherReactingUnit.location.z <=1)
        or damageInfo.diffTime) then
        -- no damage happens because the trigger Unit and other units ar positioned at different times
        return 0
    end
    local damageRoll = math.random()*areaDamageRollReactingFriendModifier(otherReactingUnit,areaDamageUnit,triggerUnit)

    if damageInfo.vulnerableTypes then
        if horizontalDistance(otherReactingUnit,areaDamageUnit) > damageInfo.range then
            return damage
        end
        for __,uType in pairs(damageInfo.vulnerableTypes) do
            if uType == otherReactingUnit.type then
                if damageInfo.all then
                    damage = damage + getDamageFromSchedule(damageInfo.all,damageRoll)
                end
                if otherReactingUnit.location.z == 0 and damageInfo.low then
                    damage = damage+ getDamageFromSchedule(damageInfo.low,damageRoll)
                elseif otherReactingUnit.location.z == 1 and damageInfo.high then
                    damage = damage+ getDamageFromSchedule(damageInfo.high,damageRoll)
                elseif otherReactingUnit.location.z == 2 and damageInfo.night then
                    damage = damage+ getDamageFromSchedule(damageInfo.night,damageRoll)
                end
                if otherReactingUnit.location.z == 0 and areaDamageUnit.location.z == 1 and damageInfo.dive then
                    damage = damage+ getDamageFromSchedule(damageInfo.dive,damageRoll)
                end
                return damage
            end --uType == otherReactingUnit.type then
       end --__,uType in pairs(damageInfo.vulnerableTypes) do
    else
        for ___,subDamageInfo in pairs(damageInfo) do
            if horizontalDistance(otherReactingUnit,areaDamageUnit) > subDamageInfo.range then
                return damage
            end
            for ____,uType in pairs(subDamageInfo.vulnerableTypes) do
                if uType == otherReactingUnit.type then
                    if subDamageInfo.all then
                        damage = damage + getDamageFromSchedule(subDamageInfo.all,damageRoll)
                    end
                    if otherReactingUnit.location.z == 0 and subDamageInfo.low then
                        damage = damage+ getDamageFromSchedule(subDamageInfo.low,damageRoll)
                    elseif otherReactingUnit.location.z == 1 and subDamageInfo.high then
                        damage = damage+ getDamageFromSchedule(subDamageInfo.high,damageRoll)
                    elseif otherReactingUnit.location.z == 2 and subDamageInfo.night then
                        damage = damage+ getDamageFromSchedule(subDamageInfo.night,damageRoll)
                    end
                    if otherReactingUnit.location.z == 0 and areaDamageUnit.location.z == 1 and subDamageInfo.dive then
                        damage = damage+ getDamageFromSchedule(subDamageInfo.dive,damageRoll)
                    end
                    return damage
                end -- uType == otherReactingUnit.type then
            end -- ____,uType in pairs(subDamageInfo.vulnerableTypes) do
        end --___,subDamageInfo in pairs(damageInfo) do
    end--if damageInfo.vulnerableTypes 
    return damage
end
    
local function areaDamageToNotReactingUnit(otherNearbyUnit,areaDamageUnit,triggerUnit)
    -- for some reason, I used otherReactingUnit for this function instead of otherNearbyUnit
    -- I don't want to risk breaking anything at this time, so I only changed the function definition
    local otherReactingUnit = otherNearbyUnit
    local damageInfo = nil
    if otherReactingUnit.owner == areaDamageUnit.owner then
        damageInfo = areaReactionDamage[areaDamageUnit.type.id].bystanderFriend
    else
        damageInfo = areaReactionDamage[areaDamageUnit.type.id].bystanderFoe
    end
    local damage = 0
    if damageInfo == nil then
        -- areaDamageUnit doesn't do damage to this class of reacting unit
        return 0
    end
    if otherReactingUnit.location.city and otherReactingUnit.type.domain == 1 then
        -- air unit is landed in city/airfield, so isn't subject to any bystander reaction damage
        return 0
    end
    local function horizontalDistance(unitA,unitB)
        local lA = unitA.location
        local lB = unitB.location
        return math.floor((math.abs(lA.x-lB.x)+math.abs(lA.y-lB.y))/2)
        -- The floor aspect just makes sure that an integer is returned, e.g. 2 instead of 2.0
    end
    if horizontalDistance(otherReactingUnit,areaDamageUnit) > damageInfo.range then
        -- unit out of range case
        return 0
    end
    if not((triggerUnit.location.z == 2 and otherReactingUnit.location.z ==2)
        or (triggerUnit.location.z <=1 and otherReactingUnit.location.z <=1)
        or damageInfo.diffTime) then
        -- no damage happens because the triggger Unit and other unit are positioned at different times
        return 0
    end
    local damageRoll = math.random()*areaDamageRollNotReactingModifier(otherNearbyUnit,areaDamageUnit,triggerUnit)

    if damageInfo.vulnerableTypes then
        if horizontalDistance(otherReactingUnit,areaDamageUnit) > damageInfo.range then
            return damage
        end
        for __,uType in pairs(damageInfo.vulnerableTypes) do
            if uType == otherReactingUnit.type then
                if damageInfo.all then
                    damage = damage + getDamageFromSchedule(damageInfo.all,damageRoll)
                end
                if otherReactingUnit.location.z == 0 and damageInfo.low then
                    damage = damage+ getDamageFromSchedule(damageInfo.low,damageRoll)
                elseif otherReactingUnit.location.z == 1 and damageInfo.high then
                    damage = damage+ getDamageFromSchedule(damageInfo.high,damageRoll)
                elseif otherReactingUnit.location.z == 2 and damageInfo.night then
                    damage = damage+ getDamageFromSchedule(damageInfo.night,damageRoll)
                end
                if otherReactingUnit.location.z == 0 and areaDamageUnit.location.z == 1 and damageInfo.dive then
                    damage = damage+ getDamageFromSchedule(damageInfo.dive,damageRoll)
                end
                return damage
            end --uType == otherReactingUnit.type then
       end --__,uType in pairs(damageInfo.vulnerableTypes) do
    else
        for ___,subDamageInfo in pairs(damageInfo) do
            if horizontalDistance(otherReactingUnit,areaDamageUnit) > subDamageInfo.range then
                return damage
            end
            for ____,uType in pairs(subDamageInfo.vulnerableTypes) do
                if uType == otherReactingUnit.type then
                    if subDamageInfo.all then
                        damage = damage + getDamageFromSchedule(subDamageInfo.all,damageRoll)
                    end
                    if otherReactingUnit.location.z == 0 and subDamageInfo.low then
                        damage = damage+ getDamageFromSchedule(subDamageInfo.low,damageRoll)
                    elseif otherReactingUnit.location.z == 1 and subDamageInfo.high then
                        damage = damage+ getDamageFromSchedule(subDamageInfo.high,damageRoll)
                    elseif otherReactingUnit.location.z == 2 and subDamageInfo.night then
                        damage = damage+ getDamageFromSchedule(subDamageInfo.night,damageRoll)
                    end
                    if otherReactingUnit.location.z == 0 and areaDamageUnit.location.z == 1 and subDamageInfo.dive then
                        damage = damage+ getDamageFromSchedule(subDamageInfo.dive,damageRoll)
                    end
                    return damage
                end -- uType == otherReactingUnit.type then
            end -- ____,uType in pairs(subDamageInfo.vulnerableTypes) do
        end --___,subDamageInfo in pairs(damageInfo) do
    end--if damageInfo.vulnerableTypes 
    return damage
end

local function willReact(triggerUnit,reactingUnit,reactingUnitsTable,otherNearbyUnitsTable)
    if not isAreaDamageUnit(triggerUnit,reactingUnit) then
        updateReactionWarning(triggerUnit, reactingUnit)
        return true
    end
    local simulatedFriendlyDamage = 0
    local simulatedFoeDamage = 0
    simulatedFoeDamage = simulatedFoeDamage+targetReactionDamage(triggerUnit,reactingUnit)
    for __,otherReactingUnit in pairs(reactingUnitsTable) do
        if otherReactingUnit.owner == reactingUnit.owner then
            simulatedFriendlyDamage = simulatedFriendlyDamage+areaDamageToReactingUnit(otherReactingUnit,reactingUnit,triggerUnit)
        else
            simulatedFoeDamage = simulatedFoeDamage+areaDamageToReactingUnit(otherReactingUnit,reactingUnit,triggerUnit)
        end
    end
    for __,otherNearbyUnit in pairs(otherNearbyUnitsTable) do
        if otherNearbyUnit.owner == reactingUnit.owner then
            simulatedFriendlyDamage = simulatedFriendlyDamage + areaDamageToNotReactingUnit(otherNearbyUnit,reactingUnit,triggerUnit)
        else
            simulatedFoeDamage = simulatedFoeDamage + areaDamageToNotReactingUnit(otherNearbyUnit,reactingUnit,triggerUnit)
        end
    end
    if specialNumbers.maxFriendlyFire*simulatedFoeDamage >= math.max(1,simulatedFriendlyDamage) then
        updateReactionWarning(triggerUnit, reactingUnit)
        return true
    else
        return false
    end
    --updateReactionWarning(triggerUnit, reactingUnit)
    --return true
    -- this could be changed to not fire if more damage would be done to allied units than
    -- enemy units or in response to some other reason not checked in the canReactFunction
end

local function reactionPriority(triggerUnit,reactingUnit)
    -- can customize later, for now will make priority random
    -- this is not really random, but it has to be deterministic, 
    -- and I don't want to do something complicated right now
    --return (reactingUnit.type.id*triggerUnit.id + reactingUnit.id) % triggerUnit.type.id
    return reactingUnit.id
end

local function postReactionFunction(triggerUnit,reactingUnit)
    state.reactions[reactingUnit.id] = state.reactions[reactingUnit.id] or 0
    state.reactions[reactingUnit.id] = state.reactions[reactingUnit.id] + 1
    if postReactionInfo[reactingUnit.type.id] then
        if postReactionInfo[reactingUnit.type.id].fuel then
           reactingUnit.owner.money = math.max(reactingUnit.owner.money - postReactionInfo[reactingUnit.type.id].fuel,0)
        end
        if postReactionInfo[reactingUnit.type.id].custom then
            postReactionInfo[reactingUnit.type.id].custom(triggerUnit,reactingUnit)
        end
    end--if postReactionInfo[reactingUnit.type.id] then
end

local function killFunction(deadUnit,reactingUnit)
    for possibleMunition in deadUnit.location.units do
        if possibleMunition.type.flags & 1<<12 == 1<<12 then
            -- this is actually a munition
            civ.deleteUnit(possibleMunition)
        end
    end
    if deadUnit.type == unitAliases.B17F or deadUnit.type == unitAliases.B17G then
        state.reactionWarning["B17sDamaged"] = (state.reactionWarning["B17sDamaged"] or 0) + 1
    else
        state.reactionWarning["Losses"] = (state.reactionWarning["Losses"] or 0) + 1
    end
    local replacementUnit = false
    local loser = deadUnit
    local winner = reactingUnit    
	-- Code for units to "survive" destruction by being re-created as a different unit
	if civ.getTile(loser.location.x,loser.location.y,loser.location.z) ~= nil then
	    local tile = loser.location
	    for __, unitSurvivalInfo in pairs(survivingUnitTypes) do
	        if loser.type == unitSurvivalInfo.unitType then
	            local quantityToProduce = unitSurvivalInfo.replacingQuantity or 1
	            if math.random() <= (quantityToProduce - math.floor(quantityToProduce)) then
	                quantityToProduce = math.ceil(quantityToProduce)
	            else 
	                quantityToProduce = math.floor(quantityToProduce)
	            end
	            local replacingHome = nil
	            if unitSurvivalInfo.preserveHome then
	                replacingHome = loser.homeCity
	            end
	            local replacingVetStatus = unitSurvivalInfo.replacementVetStatus or false 
	            if unitSurvivalInfo.preserveVetStatus then
	                replacingVetStatus = loser.veteran
	            end
	            for i=1,quantityToProduce do
	                local newUnit = civ.createUnit(unitSurvivalInfo.replacingUnit,loser.owner,loser.location)
	                newUnit.homeCity = replacingHome
	                newUnit.veteran = replacingVetStatus
	                replacementUnit = newUnit
                    local deadUnitRemainingMove = deadUnit.type.move - deadUnit.moveSpent
                    replacementUnit.moveSpent = math.max(0,replacementUnit.type.move-deadUnitRemainingMove)
	            end --1st instance for i=1,quantityToProduce
	            if unitSurvivalInfo.bonusUnit then
	                quantityToProduce = unitSurvivalInfo.bonusUnitQuantity or 1
	                if math.random() <= (quantityToProduce - math.floor(quantityToProduce)) then
	                    quantityToProduce = math.ceil(quantityToProduce)
	                else 
	                    quantityToProduce = math.floor(quantityToProduce)
	                end	   
	                for i=1,quantityToProduce do
	                    local newUnit = civ.createUnit(unitSurvivalInfo.bonusUnit,loser.owner,loser.location)
	                    newUnit.homeCity = nil
	                    newUnit.veteran = false
	                end --2nd instance for i=1,quantityToProduce   
	            end -- end if unitSurvivalInfo.bonusUnit       
	        end -- loser.type == unitSurvivalInfo.unitType
	    end -- for unitSurvivalInfo in pairs(survivingUnitTypes)
	end--civ.getTile(...
	if loser.owner == tribeAliases.Allies and outOfRangeCheck(loser, escortableBombers) then
	    --civ.ui.text("Bomber increment.")
	    incrementCounter("KillsOutsideEscortRange",1)
	end
	if loser.owner == tribeAliases.Allies then
	    
	    if loser.type == unitAliases.Freighter then
	    incrementCounter("GermanScore",specialNumbers.germanScoreIncrementSinkFreighter)
	    elseif loser.type == unitAliases.B17F or loser.type == unitAliases.B17G then
		incrementCounter("GermanScore",.75*specialNumbers.germanScoreIncrementKillHeavyBomber)
	    elseif loser.type == unitAliases.damagedB17F or loser.type == unitAliases.damagedB17G then
	        incrementCounter("GermanScore",.25*specialNumbers.germanScoreIncrementKillHeavyBomber)
	    elseif loser.type == unitAliases.FifteenthAF or loser.type == unitAliases.B24J or loser.type == unitAliases.Stirling or loser.type == unitAliases.Halifax or loser.type == unitAliases.Lancaster then
	        incrementCounter("GermanScore",specialNumbers.germanScoreIncrementKillHeavyBomber)
	    end
	end
	if loser.owner == tribeAliases.Germans then
	    if loser.type.domain == 1 and not (loser.type.flags & 2^12 == 2^12) then
	    incrementCounter("AlliedScore", specialNumbers.alliedScoreIncrementDestroyPlane)
	    --incrementCounter("GermanScore", -specialNumbers.alliedScoreIncrementDestroyPlane)
	    end
	end
    -- report losses
    log.onUnitKilled(winner,loser)
    --if loser.owner ~=civ.getCurrentTribe() then
    --    -- reports losses to the not active tribe
    --    --cr.addCombatEntry(state.cHistTable,loser,winner)
    --end
    civ.deleteUnit(deadUnit)
    return replacementUnit
end --function killFunction(deadUnit,reactingUnit)



local function primaryAttackReactionWrapper(ammoUnit,munitionTable,unitKilledFn)
    --print(type(unitKilledFn))
    --unitKilledFn = function (loser,winner) print("This is a function") return nil end
    munitionTable = munitionTable or {}
    reactOTR.makeReaction(ammoUnit,munitionTable,unitKilledFn,specialNumbers.maximumReactingUnits)
    --[[
    resetReactionWarning()
    react.reaction(ammoUnit,specialNumbers.reactionRangeToCheck,
                canReactFunction,targetReactionDamage,willReact,
                isAreaDamageUnit,areaDamageToReactingUnit,
                areaDamageToNotReactingUnit, reactionPriority,
                postReactionFunction,killFunction)
    displayReactionWarning()
    --]]
end

local function secondaryAttackReactionWrapper(ammoUnit,munitionTable,unitKilledFn)
    munitionTable = munitionTable or {}
    reactOTR.makeReaction(ammoUnit,munitionTable,unitKilledFn,specialNumbers.maximumReactingUnits)
    --[[
    resetReactionWarning()
    react.reaction(ammoUnit,specialNumbers.reactionRangeToCheck,
                canReactFunction,targetReactionDamage,willReact,
                isAreaDamageUnit,areaDamageToReactingUnit,
                areaDamageToNotReactingUnit, reactionPriority,
                postReactionFunction,killFunction)
   displayReactionWarning()
   --]]
end


-- ���������� Functions: ���������������������������������������������������������������������������������������������������������������������������������������
--[[
local function canDockFreighter(city)
    if not civ.hasImprovement(city, improvementAliases.militaryPort) then
        civ.ui.text(city.name.." can't unload freighters because it does not have a functioning military port.")
        return false
    end
    state.cityDockings[city.id] = state.cityDockings[city.id] or 0
    civilImprovements = 0
    if civ.hasImprovement(city, civ.getImprovement(4)) then
        civilImprovements = civilImprovements + 1
    end
    if civ.hasImprovement(city, civ.getImprovement(11)) then
        civilImprovements = civilImprovements +1
    end
    if civ.hasImprovement(city, civ.getImprovement(14)) then
        civilImprovements = civilImprovements + 1
    end
    if state.cityDockings[city.id] < math.max(1,2*civilImprovements) then
        state.cityDockings[city.id] = state.cityDockings[city.id]+1
        return true
    else
        civ.ui.text("The port in "..city.name.." is already operating at full capacity.  This freighter can be unloaded later or in a different port.")
        return false
    end
end
--]]

-- these units should only have the sub flag during the allied turn
local subFlagDuringAlliedTurn={
unitAliases.Me109G6				,
unitAliases.Me109G14			,
unitAliases.Me109K4				,
unitAliases.Fw190A5				,
unitAliases.Fw190A8				,
unitAliases.Fw190D9				,
unitAliases.Ta152				,
unitAliases.Me110				,
unitAliases.Me410				,
unitAliases.Ju88C				,
unitAliases.Ju88G				,
unitAliases.He219				,
unitAliases.He162				,
unitAliases.Me163				,
unitAliases.Me262				,
unitAliases.Ju87G				,
unitAliases.Fw190F				,
unitAliases.Do335				,
unitAliases.Do217				,
unitAliases.He277				,
unitAliases.Arado234			,
unitAliases.Go229				,
unitAliases.EgonMayer			,
unitAliases.He111				,
unitAliases.HermannGraf			,
unitAliases.JosefPriller		,
unitAliases.AdolfGalland		,
--unitAliases.Ju188				,
unitAliases.hwSchnaufer			,
unitAliases.Experten            ,
}

-- these units should only have the sub flag during the German turn
local subFlagDuringGermanTurn={
unitAliases.Beaufighter			,
unitAliases.MosquitoII			,
unitAliases.MosquitoXIII		,
unitAliases.Stirling			,
unitAliases.Halifax				,
unitAliases.Lancaster			,
unitAliases.Pathfinder			,
}

-- need afterProduction and onScenarioLoaded
local function setSubFlag()
    if civ.getCurrentTribe() == tribeAliases.Germans then
        for __,unitType in pairs(subFlagDuringGermanTurn) do
            gen.giveSubmarine(unitType)
        end
        for __,unitType in pairs(subFlagDuringAlliedTurn) do
            gen.removeSubmarine(unitType)
        end
    elseif civ.getCurrentTribe() == tribeAliases.Allies then
        for __,unitType in pairs(subFlagDuringAlliedTurn) do
            gen.giveSubmarine(unitType)
        end
        for __,unitType in pairs(subFlagDuringGermanTurn) do
            gen.removeSubmarine(unitType)
        end
    end
end



-- point values for aircraft for experten
local aircraftPointValues = {
[unitAliases.SpitfireIX.id]			= 1,
[unitAliases.SpitfireXII.id]		= 1,
[unitAliases.SpitfireXIV.id]		= 1,
[unitAliases.HurricaneIV.id]		= 1,
[unitAliases.Typhoon.id]			= 1,
[unitAliases.Tempest.id]			= 1,
[unitAliases.Meteor.id]				= 1,
[unitAliases.Beaufighter.id]		= 1,
[unitAliases.MosquitoII.id]			= 1,
[unitAliases.MosquitoXIII.id]		= 1,
[unitAliases.P47D11.id]				= 1,
[unitAliases.P47D25.id]				= 1,
[unitAliases.P47D40.id]				= 1,
[unitAliases.P38H.id]				= 1,
[unitAliases.P38J.id]				= 1,
[unitAliases.P38L.id]				= 1,
[unitAliases.P51B.id]				= 1,
[unitAliases.P51D.id]				= 1,
[unitAliases.P80.id]				= 1,
[unitAliases.Stirling.id]			= 3,
[unitAliases.Halifax.id]			= 3,
[unitAliases.Lancaster.id]			= 3,
[unitAliases.Pathfinder.id]			= 3,
[unitAliases.A20.id]				= 2,
[unitAliases.B26.id]			    = 3,
[unitAliases.A26.id]				= 2,
[unitAliases.B17F.id]				= 2,
[unitAliases.B24J.id]				= 3,
[unitAliases.B17G.id]				= 2,
[unitAliases.RedTails.id]			= 1,
[unitAliases.MedBombers.id]			= 3,
[unitAliases.FifteenthAF.id]        = 3,
[unitAliases.damagedB17F.id]		= 1,
[unitAliases.damagedB17G.id]		= 1,
}

local function displayScore()
    scoreTable = civ.ui.createDialog()
    scoreTable.title = "Scores for Allies and Germans"
    scoreTable:addText(func.splitlines("The Allied Score is "..tostring(counterValue("AlliedScore")..".")))
    scoreTable:addText(func.splitlines("\n^The German Score is "..tostring(counterValue("GermanScore")..".")))
    --scoreTable:addCheckbox(func.splitlines("The Germans have sunk "..tostring(-counterValue("SunkAlliedFreighters").." freighters.")),3)
    --if civ.getCurrentTribe() == tribeAliases.Allies or debugFeatures then
        scoreTable:addText(func.splitlines("\n^The Allies have lost "..tostring(counterValue("KillsOutsideEscortRange")).." bombers beyond their maximum escort range."))
    --end
    scoreTable:addText(func.splitlines("\n^German pilots have accumulated "..tostring(counterValue("GermanAircraftKills")).." points of aircraft kills."))
    local fifteenthAFCount = 0
    for unit in civ.iterateUnits() do
        if unit.type == unitAliases.FifteenthAF or unit.type == unitAliases.RedTails then
            fifteenthAFCount = fifteenthAFCount+1
        end
    end
    scoreTable:addText(func.splitlines("\n^The Fifteenth Air Force operates "..tostring(fifteenthAFCount).." aircraft units."))
    local function countGermanTrainsPerTurn()
        local occupationScore = 0
        for unit in civ.iterateUnits() do
            if unit.location.terrainType % 16 == 10 or not inFranceSquare(unit.location) then

            elseif unit.type == unitAliases.GermanArmyGroup or unit.type == unitAliases.AlliedArmyGroup then
                if unit.owner == tribeAliases.Germans then
                    occupationScore = occupationScore+specialNumbers.armyGroupOccupationValue

                else
                    occupationScore = occupationScore-specialNumbers.armyGroupOccupationPenalty
                end
            elseif unit.type == unitAliases.GermanBatteredArmyGroup or unit.type == unitAliases.AlliedBatteredArmyGroup then
                if unit.owner == tribeAliases.Germans then
                    occupationScore = occupationScore+specialNumbers.batteredArmyGroupOccupationValue
                else
                    occupationScore = occupationScore-specialNumbers.batteredArmyGroupOccupationPenalty
                end
            end
        end
        local trainsToMake = 0
        --print(occupationScore)
        for i=1,7 do
            if occupationScore >= specialNumbers["occupationScoreTrain"..tostring(i).."Threshold"] then
                trainsToMake = trainsToMake+1
            end
        end
        return trainsToMake
    end
    scoreTable:addText(func.splitlines("\n^The Germans can extract a maximum of "..tostring(countGermanTrainsPerTurn()).." trainloads of supplies from France every turn, and actually extracted "..tostring(counterValue("GermanExtractionLevel")).." last turn."))
    
    local function countAlliedConvoys(turn) 
        local alliedPorts,germanPorts = countPorts()
        germanPorts = germanPorts+state.alliedReinforcementsSent*specialNumbers.alliedReinforcementGermanPortPenalty
        local convoysProduced = 0
        if 3*(turn % 3) + 1 > germanPorts/3 then
            convoysProduced=convoysProduced+1
        end
        if 3*(turn % 3) + 2 > germanPorts/3 then
            convoysProduced=convoysProduced+1
        end
        if 3*(turn % 3) + 3 > germanPorts/3 then
            convoysProduced=convoysProduced+1
        end
        return convoysProduced
    end
    local ct = civ.getTurn()
    scoreTable:addText(func.splitlines(text.substitute("\n^%STRING1 Allied convoys are expected to enter the Atlantic on turn %STRING2, %STRING3 on turn %STRING4, and %STRING5 on turn %STRING6.",{countAlliedConvoys(ct+1),ct+1,countAlliedConvoys(ct+2),ct+2,countAlliedConvoys(ct+3),ct+3})))
    scoreTable:show() 
end

local negate = function (f)
	return function (x)
		return not f(x)
	end
end

-- Returns city object at coordinates (x,y,z)
function getCityAt (x,y,z)
	local cityTile = civ.getTile(x,y,z)
	return cityTile.city
end

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


local function changeAllTerrain (improvementId, operation, coordinateSet)
	local terrainTypeBaseKey = operation .. "TerrainTypeMap"
	for zcoord = 0, 2 do										-- Iterate through maps 0, 1, and 2
		local terrainTypeKey = terrainTypeBaseKey .. zcoord		-- The value of this variable should now exactly match a nested key in improvementUnitTerrainLinks
		local newTerrainType = improvementUnitTerrainLinks[improvementId][terrainTypeKey]
		if newTerrainType ~= nil then							-- Check that the terrain should be changed on this map
			for _, xycoord in ipairs(coordinateSet) do
				local xcoord, ycoord = table.unpack(xycoord)
				local tileToChange = civ.getTile(xcoord, ycoord, zcoord)
				if tileToChange ~= nil then
					tileToChange.terrainType = newTerrainType
					print("Changed terrain at " .. xcoord .. "," .. ycoord .. "," .. zcoord .. " to type " .. tileToChange.terrainType)
				else
					print("ERROR: Invalid terrain change coordinates " .. xcoord .. "," .. ycoord .. "," .. zcoord)
				end
			end
		end
	end
end

-- Creates a table programmatically that reverses information from the "cityCoordinates" table defined above
-- This allows events to look up a tile and identify which improvement and city are linked to units/terrain at that location
-- This code needs to be placed *after* the definition of table "cityCoordinates" and also *after* the definition of function "getTileId"
-- Right now it's located as the last entry in the "Functions" section, though it runs on initial script parsing only and isn't a function per se
--[[ by Knighttime ]]
local tileLookup = { }
for cityKey, data in pairs(cityCoordinates) do
	for improvementKey, locationList in pairs(data) do
		if locationList ~= nil and #locationList > 0 then
			local firstLocation = locationList[1]
			if firstLocation ~= nil and #firstLocation > 0 then
				local xcoord, ycoord = table.unpack(firstLocation)
				local zcoord = 1	-- Hardcoded reference to the map on which a unit will normally be created
				if improvementKey == 4 or improvementKey == 11 or improvementKey == 14 then
					zcoord = 2		-- Hardcoded references (on previous line) to specific improvements that will cause a unit to be created on map 2 *instead*
				end
				local potentialUnitTile = civ.getTile(xcoord, ycoord, zcoord)
				if potentialUnitTile ~= nil then
					local tileId = getTileId(potentialUnitTile)
					tileLookup[tileId] = { improvementId = improvementKey, cityId = cityKey, allLocations = locationList}
				else
					print("ERROR: failed to find valid map tile when populating \"tileLookup\" for " .. xcoord .. "," .. ycoord .. "," .. zcoord)
				end
			end
		end
	end
end

-- Takes a tile and checks the 8 tiles surrounding it for a place to move units of the tribe.
-- If such a tile exists, the first tile found is returned
-- returns false if all are occupied by foreign units.
function getSafeTile(tribe,tile)
    local h = {{2,0},{1,-1},{0,-2},{-1,-1},{-2,0},{-1,1},{0,2},{1,1}}
    for i=1,8 do
        local newTile = civ.getTile(tile.x+h[i][1],tile.y+h[i][2],tile.z)
        if newTile.defender == tribe or newTile.defender == nil then
            return newTile
        end
    end
    return false
end



--[[ removed 20 may 2019
-- Changes the production costs that are dependent on in game
-- status, (destroyers and U-Boats are dependent on military ports for their cost
local function resetProductionValues()
    local numberOfAlliedMilitaryPorts = 0 -- p.g. initialize counter of allied port units
	local numberOfGermanMilitaryPorts = 0 -- p.g. initialize counter of german port units
	local dock = civ.getImprovement(34)
	for city in civ.iterateCities() do
	    if civ.hasImprovement(city, dock) and city.owner == tribeAliases.Allies then
	        numberOfAlliedMilitaryPorts = numberOfAlliedMilitaryPorts + 1--p.g. increment allied port count
	    end
	    if civ.hasImprovement(city,dock) and city.owner == tribeAliases.Germans then
	        numberOfGermanMilitaryPorts = numberOfGermanMilitaryPorts + 1 -- p.g. increment German port count
	    end
	end -- end loop over all cities in game
    --unitAliases.Destroyer.cost = specialNumbers.minDestroyerCost + math.max(0,specialNumbers.maxAlliedPorts - numberOfAlliedMilitaryPorts)
    unitAliases.UBoat.cost = specialNumbers.minSubmarineCost +math.max(0,specialNumbers.maxGermanPorts -numberOfGermanMilitaryPorts)

end -- resetProductionValues
--]]

-- vet swap vetswap veteran swap veteranswap veterancyswap veterancy swap
local vetSwapCategories = {
{unitAliases.B17F, unitAliases.damagedB17F, unitAliases.B17G, unitAliases.damagedB17G, unitAliases.B24J},
{unitAliases.Stirling, unitAliases.Halifax, unitAliases.Lancaster},
{unitAliases.A20, unitAliases.B26, unitAliases.A26},
{unitAliases.Beaufighter, unitAliases.MosquitoII, unitAliases.MosquitoXIII},
{unitAliases.SpitfireIX, unitAliases.SpitfireXII, unitAliases.SpitfireXIV, unitAliases.HurricaneIV, unitAliases.Typhoon, unitAliases.Tempest, unitAliases.Meteor},
{unitAliases.P47D11, unitAliases.P47D25, unitAliases.P47D40, unitAliases.P38H, unitAliases.P38J, unitAliases.P38L, unitAliases.P51B, unitAliases.P51D, unitAliases.P80},
{unitAliases.Me109G6, unitAliases.Me109G14, unitAliases.Me109K4, unitAliases.Fw190A5, unitAliases.Fw190A8, unitAliases.Fw190D9, unitAliases.Ta152, unitAliases.He162, unitAliases.Me163, unitAliases.Me262},
{unitAliases.Me110, unitAliases.Me410, unitAliases.Ju88C, unitAliases.Ju88G, unitAliases.He219},
{unitAliases.Ju87G, unitAliases.Fw190F, unitAliases.Do335},
{unitAliases.He111, unitAliases.Do217, unitAliases.He277, unitAliases.Arado234, unitAliases.Go229},
}

textAliases.ciBoxTitle = "Aircrew Assignment"

textAliases.windowTitle = "Aircrew Assignment"

textAliases.unitVetText = "What equipment shall we give to our experienced aircrew?"

textAliases.unitRookieText = "To what experienced aircrew shall we assign this equipment?"
-- information regarding the use of vetswap.buildBasicVetSwap can be found at the top of the vetswap.lua file.

local doVetSwap = vetswap.buildBasicVetSwap(vetSwapCategories,true,true,true,true,0,true,textAliases.ciBoxTitle,textAliases.windowTitle,textAliases.unitVetText,textAliases.unitRookieText)

-- Wilde Sau wilde sau wildesau WildeSau

local function wildeSau(unit)
	if unit.owner == tribeAliases.Allies then
		local dialogBox = civ.ui.createDialog()
		dialogBox.title = "Wilde Sau"
		dialogBox:addText("The Allied High Command has not approved using day aircraft at night or night aircraft during the day.")
		dialogBox:show()
		return
	elseif unit.type.domain ~= 1 then
		local dialogBox = civ.ui.createDialog()
		dialogBox.title = "Wilde Sau"
		dialogBox:addText("Ground and sea units must remain on this map.")
		dialogBox:show()
		return
	elseif unit.type.flags & 2^12 == 2^12 then
		local dialogBox = civ.ui.createDialog()
		dialogBox.title = "Wilde Sau"
		dialogBox:addText("Muntions must be expended on the map where they were generated.")
		dialogBox:show()
		return
	elseif not civ.hasTech(tribeAliases.Germans, civ.getTech(59)) then
		local dialogBox = civ.ui.createDialog()
		dialogBox.title = "Wilde Sau"
		dialogBox:addText("We cannot assign day aircraft to night operations or night aircraft to day operations until we research Wilde Sau.")
		dialogBox:show()
		return
	elseif (not unit.location.city) and unit.location.z < 2 then
		local dialogBox = civ.ui.createDialog()
		dialogBox.title = "Wilde Sau"
		dialogBox:addText("This aircraft must be in an airfield in order to assign it to night operations.")
		dialogBox:show()
		return
	elseif (not unit.location.city) and unit.location.z == 2 then
		local dialogBox = civ.ui.createDialog()
		dialogBox.title = "Wilde Sau"
		dialogBox:addText("This aircraft must be in an airfield in order to assign it to day operations.")
		dialogBox:show()
		return
	elseif unit.location.z < 2 then			
		local dialogBox = civ.ui.createDialog()
		dialogBox.title = "Wilde Sau"
		dialogBox:addText("This "..unit.type.name.." has been assigned to night operations.")
		dialogBox:show()
		civ.teleportUnit(unit,civ.getTile(unit.location.x,unit.location.y,2))
        -- ME110 and ME410 don't have a movement penalty for switching operations
        if unit.type ~= unitAliases.Me110 and unit.type ~= unitAliases.Me410 then
		    unit.moveSpent = unit.type.move*totpp.movementMultipliers.aggregate
        end
		return
	else
		local dialogBox = civ.ui.createDialog()
		dialogBox.title = "Wilde Sau"
		dialogBox:addText("This "..unit.type.name.." has been assigned to day operations.")
		dialogBox:show()
		civ.teleportUnit(unit,civ.getTile(unit.location.x,unit.location.y,0))
        if unit.type ~= unitAliases.Me110 and unit.type ~= unitAliases.Me410 then
		    unit.moveSpent = unit.type.move*totpp.movementMultipliers.aggregate
        end
		return
	end
end



-- uncover targets air protected stacks airprotectedstacks
-- This function will attempt to uncover strategic targets from air protection
-- when a munition is generated in an adjacent square
local stratTargetTable = {
unitAliases.Railyard	,
unitAliases.MilitaryPort,
unitAliases.Industry1	,
unitAliases.Industry2	,
unitAliases.Industry3	,
unitAliases.ACFactory1	,
unitAliases.ACFactory2	,
unitAliases.ACFactory3	,
unitAliases.Refinery1	,
unitAliases.Refinery2	,
unitAliases.Refinery3	,
unitAliases.Urban1	,
unitAliases.Urban2	,
unitAliases.Urban3	,
unitAliases.V1Launch	,
unitAliases.V2Launch	,
unitAliases.SpecialTarget,
unitAliases.GermanArmyGroup     ,
unitAliases.GermanBatteredArmyGroup ,
unitAliases.RedArmyGroup            ,
unitAliases.AlliedArmyGroup         ,
unitAliases.AlliedBatteredArmyGroup ,
unitAliases.Convoy,  		    	
unitAliases.AlliedTaskForce			,
unitAliases.GermanTaskForce,
unitAliases.UBoat,
}

local canNotDefendAirfield ={}
canNotDefendAirfield[unitAliases.AlliedArmyGroup.id] = true
canNotDefendAirfield[unitAliases.AlliedBatteredArmyGroup.id] = true
canNotDefendAirfield[unitAliases.GermanArmyGroup.id] = true
canNotDefendAirfield[unitAliases.GermanBatteredArmyGroup.id] = true
canNotDefendAirfield[unitAliases.RedArmyGroup.id] = true
canNotDefendAirfield[unitAliases.Convoy.id] = true
canNotDefendAirfield[unitAliases.AlliedTaskForce.id]=true
canNotDefendAirfield[unitAliases.GermanTaskForce.id]=true

local canNotDefendCity ={}

local canNotDefendCityWithoutPort = {}
canNotDefendCityWithoutPort[unitAliases.Convoy.id] = true
canNotDefendCityWithoutPort[unitAliases.AlliedTaskForce.id]=true
canNotDefendCityWithoutPort[unitAliases.GermanTaskForce.id]=true


-- this function moves a unit to an adjacent square without worrying about placement
-- of strategic targets, etc.  Only that the unit can occupy the square.
local function moveUnitAdjacent(unit)
    local center = unit.location
    local offsets = {{0,2},{1,1},{2,0},{1,-1},{0,-2},{-1,-1},{-2,0},{-1,1}}
	for __,offset in pairs(offsets) do
	    local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
        if civlua.isValidUnitLocation(unit.type,unit.owner,t) then
            unit:teleport(t)
            return
        end
    end
end

local function moveForbiddenDefenders(tile)
    if tile.city and tile.city:hasImprovement(improvementAliases.cityI) then
        for unit in tile.units do
            if canNotDefendCity[unit.type.id] then
                moveUnitAdjacent(unit)
            end
        end
    end
    if tile.city and tile.city:hasImprovement(improvementAliases.cityI)
        and not tile.city:hasImprovement(improvementAliases.militaryPort) then
        for unit in tile.units do
            if canNotDefendCityWithoutPort[unit.type.id] then
                moveUnitAdjacent(unit)
            end
        end
    end
    if tile.city and tile.city:hasImprovement(improvementAliases.airbase) then
        for unit in tile.units do
            if canNotDefendAirfield[unit.type.id] then
                moveUnitAdjacent(unit)
            end
        end
    end
end

 
local function uncoverTarget(munitionGenerator)
	local function inTable(element,table)
		for __,value in pairs(table) do
			if element == value then
				return true
			end
		end
		return false
	end
	local function hasTarget(tile)
		for unit in tile.units do
			if inTable(unit.type,stratTargetTable) then
				return true
			end
		end
		return false
	end
	local function notAdjacent(tile1,tile2)
	-- returns true if two tiles are not adjacent (or the same) horizontally (i.e.
	-- does not take into account differences in altitude)
		return (math.abs(tile1.x-tile2.x)+math.abs(tile1.y-tile2.y))>=4
	end
	local function hasAirAndTarget(tile)
        -- If the tile is a city/airfield, then the aircraft should not be moved.
        if tile.city then
            return false
        end
		local hasAir = false
		local hasTarget = false
		for unit in tile.units do
			if hasAir and hasTarget then
				break
			elseif not hasAir and unit.type.domain == 1 then
				hasAir = true
			elseif not hasTarget and inTable(unit.type,stratTargetTable) then
				hasTarget = true
			end
		end
		return hasAir and hasTarget
	end
	local center = munitionGenerator.location
    local offsets = {{0,2},{1,1},{2,0},{1,-1},{0,-2},{-1,-1},{-2,0},{-1,1}}
    -- move units that can't defend a tile (such as battle group on airbase)
    -- to an adjacent tile first if a valid tile is available
    for __,offset in pairs(offsets) do
		local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
        if t then
            moveForbiddenDefenders(t)
        end
    end
	for __,offset in pairs(offsets) do
		local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
		if t and hasAirAndTarget(t) then
			-- we have to find a place to put the aircraft.
			-- first choice is an empty tile (because stack kills)
			local emptyTile = nil
			-- next choice is a tile without targets, but that might have other units
			local noTargetTile = nil
			-- final choice is a tile that may have a target, but that is not adjacent to 
			-- the munition generator
			local notAdjacentTarget = nil
			for ____, candidateOffset in pairs(offsets) do
				local candidateTile = civ.getTile(t.x+candidateOffset[1], t.y+candidateOffset[2],t.z)
				if candidateTile.defender == nil then
					emptyTile = candidateTile
					break
				elseif (not noTargetTile) and (not hasTarget(candidateTile)) and (t.defender == candidateTile.defender) then
					noTargetTile = candidateTile
				elseif (not notAdjacentTarget) and notAdjacent(center,candidateTile) and (t.defender == candidateTile.defender) then
					notAdjacentTarget = candidateTile
				end
			end
			local destination = emptyTile or noTargetTile or notAdjacentTarget
			if destination then
				for tUnit in t.units do
					if tUnit.type.domain == 1 then
					civ.teleportUnit(tUnit,destination)
					end
				end
			end
			-- if no destination, unit remains.  Decided against message, since
			-- it would become very annoying to appear every time a munition is generated
		end --if hasAirAndTarget(t) then
	end -- for __,offset in pairs(offsets) do
end

--Finds the city that an army group will retreat to
--[==[
local function potentialRetreatCities(unit)
    local defeatTile = unit.location
    local continent = defeatTile.landmass
    local closeCityList = {}
    local function dist1(tileA,tileB)
        return math.abs(tileA.x-tileB.x)+math.abs(tileA.y-tileB.y)
    end
    local function distInf(tileA,tileB)
        return math.max(math.abs(tileA.x-tileB.x),math.abs(tileA.y-tileB.y))
    end
    local function TIEQ1(source,dest,detour)
        return dist1(source,dest) == dist1(source,detour)+dist1(detour,dest)
    end
    local function TIEQInf(source,dest,detour)
        return distInf(source,dest)==distInf(source,detour)+distInf(detour,dest)
    end
    for city in civ.iterateCities() do
        if city:hasImprovement(improvementAliases.cityI) and city.location ~=defeatTile
            and city.location.landmass == continent then
            local insertCity=true
            for index, closeCity in pairs(closeCityList) do
                if TIEQ1(defeatTile,closeCity.location,city.location) then
                    --City is "closer" than closeCity, so closeCity should
                    --be removed from the list
                    closeCityList[index] = nil
                elseif TIEQ1(defeatTile,city.location,closeCity.location) then
                    -- closeCity is "closer" than City to the unit, so we don't need
                    -- to check anything else
                    insertCity=false
                    break
                end
            end
            if insertCity then
                closeCityList[city.id] = city
                print(closeCityList[city.id],id)
            end
        end
    end
    --
    local infNormCity1 = nil
    for index, cityInQuestion in pairs(closeCityList) do
        infNormCity1 = nil
        for __, otherCloseCity in pairs(closeCityList) do
            if otherCloseCity == cityInQuestion then
            elseif TIEQInf(defeatTile,cityInQuestion,otherCloseCity) then
                if infNormCity == nil then
                    infNormCity = otherCloseCity
                --elseif not TIEQInf(defeatTile,infNormCity,otherCloseCity)
                   -- and not TIEQInf(defeatTile,otherCloseCity,infNormCity) then
                else
                    closeCityList[index] = nil
                    break
                end
            end
        end
    end
    --]]
    for index,city in pairs(closeCityList) do
        if  unit.owner ~= city.owner then
            closeCityList[index]=nil
        end
    end
    for index,city in pairs(closeCityList) do
        print(index,city)
    end
    return closeCityList
end--]==]

local function potentialRetreatCities(unit,defeatTile)
    local continent = defeatTile.landmass
    local closeCityList = {}
    local numberOfCloseCities = 5
    local function dist1(tileA,tileB)
        return math.abs(tileA.x-tileB.x)+math.abs(tileA.y-tileB.y)
    end
    local function updateCloseCityList(nextCity,closeCityList)
        if not(nextCity:hasImprovement(improvementAliases.cityI)) or nextCity.location ==defeatTile or nextCity.location.landmass ~= continent then
            return
        end
        local citiesInList = 0
        local furthestCity = nextCity
        local furthestCityDistance = dist1(defeatTile,nextCity.location)
        for index, listCity in pairs(closeCityList) do
            if dist1(listCity.location,defeatTile) > furthestCityDistance then
                furthestCityDistance = dist1(listCity.location,defeatTile) 
                local temp = furthestCity
                furthestCity = closeCityList[index]
                closeCityList[index] = temp
            end
            citiesInList = citiesInList+1
        end
        if citiesInList < numberOfCloseCities then
            closeCityList[#closeCityList+1] = furthestCity
        end
    end
    for city in civ.iterateCities() do
        updateCloseCityList(city,closeCityList)
    end
    local function furtherThanOtherCity(city,list)
        for i,c in pairs(list) do
            if c~=city and dist1(city.location,defeatTile) == dist1(city.location,c.location)+dist1(c.location,defeatTile) then
                -- this means that a unit can travel from city to c to defeatTile in the same number of moves as from city to defeatTile directly.  Hence, city is further from defeatTile than c in the "same direction"
                return true
            elseif c~=city and dist1(city.location,defeatTile)>=
                14+dist1(c.location,defeatTile) and
                dist1(city.location,defeatTile)+20 >=
                dist1(city.location,c.location)+dist1(c.location,defeatTile) then
                -- this means that the other city is at least 1.5 times as far
                -- away, and the path to the farther city is within 5 squares
                -- of the nearer city
                return true
            end
        end
        return false
    end
    for index,city in pairs(closeCityList) do
        if furtherThanOtherCity(city,closeCityList) then
            closeCityList[index] = nil
        end
    end
    for index,city in pairs(closeCityList) do
        if unit.owner ~= city.owner then
            closeCityList[index] = nil
        end
    end
    return closeCityList
end

function overTwoHundred.startAlliedReinforcementDepletedDefeated()
    state.alliedReinforcementTrack[#state.alliedReinforcementTrack+1] = specialNumbers.alliedReinforcementDelay
    state.alliedReinforcementsSent = state.alliedReinforcementsSent +1
    local message = "To compensate for the recent defeat of our "..unitAliases.AlliedBatteredArmyGroup.name..
        ", Allied planners will send a replacement "..unitAliases.AlliedBatteredArmyGroup.name.." unit to England."
        .."  It is due to arrive on turn "..tostring(specialNumbers.alliedReinforcementDelay+civ.getTurn()).."."
        .."  Due to the manpower taken out of the economy, fewer convoys will be sent across the Atlantic.  "
        .."(This penalty is equivalent to increasing the German Military Port count by "..tostring(specialNumbers.alliedReinforcementGermanPortPenalty).." per "..unitAliases.AlliedBatteredArmyGroup.name.." sent.)"
    text.displayNextOpportunity(tribeAliases.Allies,message,"Defense Minister","Reinforcements Sent")
end

function overTwoHundred.startAlliedReinforcementFullStrengthDefeated()
    state.alliedReinforcementTrack[#state.alliedReinforcementTrack+1] = specialNumbers.alliedReinforcementDelay
    state.alliedReinforcementTrack[#state.alliedReinforcementTrack+1] = specialNumbers.alliedReinforcementDelay
    state.alliedReinforcementsSent = state.alliedReinforcementsSent +2
    local message = "To compensate for the recent annihilation of our "..unitAliases.AlliedArmyGroup.name..
        ", Allied planners will send two replacement "..unitAliases.AlliedBatteredArmyGroup.name.." units to England."
        .."  They are due to arrive on turn "..tostring(specialNumbers.alliedReinforcementDelay+civ.getTurn()).."."
        .."  Due to the manpower taken out of the economy, fewer convoys will be sent across the Atlantic.  "
        .."(This penalty is equivalent to increasing the German Military Port count by "..tostring(specialNumbers.alliedReinforcementGermanPortPenalty).." per "..unitAliases.AlliedBatteredArmyGroup.name.." sent.)"
    text.displayNextOpportunity(tribeAliases.Allies,message,"Defense Minister","Reinforcements Sent")
end

function overTwoHundred.startAlliedReinforcementFullStrengthDepleted()
    state.alliedReinforcementTrack[#state.alliedReinforcementTrack+1] = specialNumbers.alliedReinforcementDelay
    state.alliedReinforcementsSent = state.alliedReinforcementsSent +1
    local message = "To compensate for the recent defeat of our "..unitAliases.AlliedArmyGroup.name..
        ", Allied planners will send a replacement "..unitAliases.AlliedBatteredArmyGroup.name.." unit to England."
        .."  It is due to arrive on turn "..tostring(specialNumbers.alliedReinforcementDelay+civ.getTurn()).."."
        .."  Due to the manpower taken out of the economy, fewer convoys will be sent across the Atlantic.  "
        .."(This penalty is equivalent to increasing the German Military Port count by "..tostring(specialNumbers.alliedReinforcementGermanPortPenalty).." per "..unitAliases.AlliedBatteredArmyGroup.name.." sent.)"
    text.displayNextOpportunity(tribeAliases.Allies,message,"Defense Minister","Reinforcements Sent")
end
local reinforcementCityOwned = nil
function overTwoHundred.alliedReinforcementsAfterProduction()
    for index,value in pairs(state.alliedReinforcementTrack) do
        if value == 1 then
            if reinforcementCityOwned(unitAliases.AlliedBatteredArmyGroup,tribeAliases.Allies,reinforcementLocations.AlliedBattleGroups,"A "..unitAliases.AlliedBatteredArmyGroup.name.." unit has been sent from America to compensate for combat losses.") then
                civlua.createUnit(unitAliases.AlliedBatteredArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups, {count=1, randomize=false, veteran=false})
            end
            state.alliedReinforcementTrack[index] = nil
        else
            state.alliedReinforcementTrack[index] = value - 1
        end
    end
end

local function orderlyRetreat(unit)
    local cityOptionList = potentialRetreatCities(unit,unit.location)
    local retreatDialog = civ.ui.createDialog()
    retreatDialog.title = "Retreat"
    retreatDialog:addText("We can order our "..unit.type.name.." to make an orderly re-deployment to one of the following cities.  This will use up all movement points.")
    retreatDialog:addOption("Stay here.",-1)
    for index, city in pairs(cityOptionList) do
        retreatDialog:addOption(city.name,index)
    end
    local choice = retreatDialog:show()
    if choice == -1 then
        return
    else
        unit:teleport(cityOptionList[choice].location)
        unit.moveSpent = unit.type.move*totpp.movementMultipliers.aggregate
        return
    end
end

local function disorderlyEnemyBattleGroupRetreat(unit)
    local destinations = potentialRetreatCities(unit,unit.location)
    local closestCitySoFar = nil
    local bestDistanceSoFar = 10000
    local function dist1(tileA,tileB)
        return math.abs(tileA.x-tileB.x)+math.abs(tileA.y-tileB.y)
    end
    for __,city in pairs(destinations) do
        if dist1(city.location,unit.location) < bestDistanceSoFar then
            bestDistanceSoFar =dist1(city.location,unit.location) 
            closestCitySoFar = city
        end
    end
    if closestCitySoFar then
        local escapeDialog = civ.ui.createDialog()
        escapeDialog.title = "Ground Battle Report"
        escapeDialog:addText("We've won a major battle on the ground, but most enemy troops have escaped capture.")
        escapeDialog:show()
        if unit.owner == tribeAliases.Allies then
            overTwoHundred.startAlliedReinforcementFullStrengthDepleted()
        end
        if unit.type == unitAliases.GermanArmyGroup then
            local newDBG = civ.createUnit(unitAliases.GermanBatteredArmyGroup,unit.owner,closestCitySoFar.location)
            newDBG.veteran = unit.veteran
            newDBG.homeCity = unit.homeCity
        elseif unit.type == unitAliases.AlliedArmyGroup then
            local newDBG = civ.createUnit(unitAliases.AlliedBatteredArmyGroup,unit.owner,closestCitySoFar.location)
            newDBG.veteran = unit.veteran
            newDBG.homeCity = unit.homeCity
        end
    else
        local escapeDialog = civ.ui.createDialog()
        escapeDialog.title = "Ground Battle Report"
        escapeDialog:addText("We've encirled and defeated an enemy "..unit.type.name..".")
        escapeDialog:show()
        if unit.owner == tribeAliases.Allies then
            overTwoHundred.startAlliedReinforcementFullStrengthDefeated()
        end
    end
end
        

local function disorderlyFriendlyBattleGroupRetreat(unit,defeatTile)
    local destinations = potentialRetreatCities(unit,defeatTile)
    for index,city in pairs(destinations) do
        print(index,city)
    end
    local closestCitySoFar = nil
    local bestDistanceSoFar = 10000
    local function dist1(tileA,tileB)
        return math.abs(tileA.x-tileB.x)+math.abs(tileA.y-tileB.y)
    end
    for __,city in pairs(destinations) do
        print(dist1(city.location,defeatTile))
        if dist1(city.location,defeatTile) < bestDistanceSoFar then
            bestDistanceSoFar =dist1(city.location,defeatTile) 
            closestCitySoFar = city
        end
    end
    if closestCitySoFar then
        local escapeDialog = civ.ui.createDialog()
        escapeDialog.title = "Ground Battle Report"
        escapeDialog:addText("We've lost a major battle on the ground, but most of our troops have escaped capture.  They are re-grouping in "..closestCitySoFar.name..".")
        escapeDialog:show()
        if unit.owner == tribeAliases.Allies then
            overTwoHundred.startAlliedReinforcementFullStrengthDepleted()
        end
        if unit.type == unitAliases.GermanArmyGroup then
            local newDBG = civ.createUnit(unitAliases.GermanBatteredArmyGroup,unit.owner,closestCitySoFar.location)
            newDBG.veteran = unit.veteran
            newDBG.homeCity = unit.homeCity
            newDBG.moveSpent = newDBG.type.move*totpp.movementMultipliers.aggregate
        elseif unit.type == unitAliases.AlliedArmyGroup then
            local newDBG = civ.createUnit(unitAliases.AlliedBatteredArmyGroup,unit.owner,closestCitySoFar.location)
            newDBG.veteran = unit.veteran
            newDBG.homeCity = unit.homeCity
            newDBG.moveSpent = newDBG.type.move*totpp.movementMultipliers.aggregate
        end
    else
        local escapeDialog = civ.ui.createDialog()
        escapeDialog.title = "Ground Battle Report"
        escapeDialog:addText("We've suffered a major defeat.  Not only has the enemy repulsed our attack, but most of our men were killed or captured.")
        escapeDialog:show()
        if unit.owner == tribeAliases.Allies then
            overTwoHundred.startAlliedReinforcementFullStrengthDefeated()
        end
    end
end


local function reformBattleGroup(unit)
    local function isBatteredArmyGroup(funUnit)
        return funUnit.type == unitAliases.AlliedBatteredArmyGroup or funUnit.type == unitAliases.GermanBatteredArmyGroup
    end
    local function bGName(funUnit)
        if funUnit.type == unitAliases.AlliedBatteredArmyGroup then
            return unitAliases.AlliedArmyGroup.name
        else
            return unitAliases.GermanArmyGroup.name
        end
    end
    local function bGType(funUnit)
        if funUnit.type == unitAliases.AlliedBatteredArmyGroup then
            return unitAliases.AlliedArmyGroup
        else
            return unitAliases.GermanArmyGroup
        end
    end
    local trainsOnTile = 0
    local bAGOnTile = 0
    local vetBAGOnTile = 0
    for tileUnit in unit.location.units do
        if tileUnit.type == unitAliases.FreightTrain then
            trainsOnTile=trainsOnTile+1
        elseif isBatteredArmyGroup(tileUnit) then
            bAGOnTile = bAGOnTile+1
            if tileUnit.veteran then
                vetBAGOnTile=vetBAGOnTile+1
            end
        end
    end
    local aGToCreate = math.min(trainsOnTile,bAGOnTile-1)
    local vetAGToCreate = math.min(aGToCreate,vetBAGOnTile)
    local makeBGText = "We can combine two "..unit.type.name.."s and a "..unitAliases.FreightTrain.name.." to form a full strength "..bGName(unit)..".  For each additional "..unit.type.name.." and "..unitAliases.FreightTrain.name.." we gather on the square, another "..bGName(unit).." will be formed.  One veteran "..bGName(unit).." will be formed for each veteran "..unit.type.name.." used to form them (or one less if all are veteran)."
    if aGToCreate == 0 then
        local dialog = civ.ui.createDialog()
        dialog.title = "Consolidating Ground Forces"
        dialog:addText(makeBGText)
        dialog:show()
        return
    end
    local dialog = civ.ui.createDialog()
    dialog.title = "Consolidating Ground Forces"
    local makeBGOptionText = "We can equip "..tostring(aGToCreate+1).." "..unit.type.name.."s with the contents of "..tostring(aGToCreate).." "..unitAliases.FreightTrain.name.."s and create "..tostring(aGToCreate).." full strength "..bGName(unit).."s.  Of these, "..tostring(vetAGToCreate).." will be veteran units.  Shall we consolidate our forces now?"
    dialog:addText(makeBGOptionText)
    dialog:addOption("Let's wait for extra resources before we consolidate our forces.",1)
    dialog:addOption("Consolidate our men and equipment into effective "..bGName(unit).."s.",2)
    local decision = dialog:show()
    if decision == 1 then
        return
    end
    local trainsToDelete = aGToCreate
    local vetBAGToDelete = vetAGToCreate
    local rookieBAGToDelete = aGToCreate+1-vetBAGToDelete
    if bAGOnTile == vetBAGOnTile then
        rookieBAGToDelete = 0
        vetBAGToDelete = vetBAGToDelete+1
    end
    local extraBAGDeleted= false
    local createTile = unit.location
    local createType = bGType(unit)
    local createTribe = unit.owner
    for tileUnit in unit.location.units do
        if tileUnit.type == unitAliases.FreightTrain and trainsToDelete>0 then
           civ.deleteUnit(tileUnit) 
           trainsToDelete = trainsToDelete-1
        elseif isBatteredArmyGroup(tileUnit) and tileUnit.veteran and vetBAGToDelete > 0 then
            vetBAGToDelete = vetBAGToDelete -1
            if rookieBAGToDelete == 0 and not extraBAGDeleted then
                extraBAGDeleted=true
                civ.deleteUnit(tileUnit)
            else
                local newBG = civ.createUnit(createType,createTribe,createTile)
                newBG.homeCity = tileUnit.homeCity
                newBG.veteran = true
                civ.deleteUnit(tileUnit)
            end
        elseif isBatteredArmyGroup(tileUnit) and not tileUnit.veteran and rookieBAGToDelete > 0 then
            rookieBAGToDelete = rookieBAGToDelete-1
            if not extraBAGDeleted then
                extraBAGDeleted = true
                civ.deleteUnit(tileUnit)
            else
                local newBG = civ.createUnit(createType,createTribe,createTile)
                newBG.homeCity = tileUnit.homeCity
                newBG.veteran = false
                civ.deleteUnit(tileUnit)
            end
        end
    end
end

console.computeCosts = upkeep.computeCosts
local function doUpkeepWarning(tribe)
    if tribe == tribeAliases.Allies and flag("NeverWarnAlliesAboutUpkeep") then
        return
    elseif tribe == tribeAliases.Germans and flag("NeverWarnGermansAboutUpkeep") then
        return
    elseif flag("NoUpkeepWarningThisSession") or flag("NoUpkeepWarningThisTurn") then
        return
    elseif tribe.money > counterValue("UpkeepWarningTreasuryLevel") then
        return
    end
    local upkeepExpenses = upkeep.computeCosts(tribe)
    local warningDialog = civ.ui.createDialog()
    warningDialog.title = "Over the Recih Concepts: Fuel"
    warningDialog:addText("This mission has reduced our fuel reserves to "..tostring(tribe.money)..
        ".  It is estimated that we will need "..tostring(upkeepExpenses).." units of fuel to maintain "..
        "our infrastructure next turn.  Our refineries will produce more fuel in the upcomming turn, but if our fuel "..
        "reserves fall to 0 at any point during the city processing phase, some infrastructure will be sold off "..
        "even if enough fuel will have been produced once all the cities are processed.")
    warningDialog:addOption("Remind me again when fuel stores drop below "..tostring(tribe.money-100)..".",1)
    warningDialog:addOption("Don't remind me until I load the game again.",2)
    warningDialog:addOption("Don't remind me again this turn.",3)
    warningDialog:addOption("Don't bother me about this for the rest of the game.",4)
    local choice = warningDialog:show()
    if choice == 1 then
        setCounter("UpkeepWarningTreasuryLevel",tribe.money-100)
        return
    elseif choice == 2 then
        setFlagTrue("NoUpkeepWarningThisSession")
        return
    elseif choice == 3 then
        setFlagTrue("NoUpkeepWarningThisTurn")
        return
    elseif choice == 4 then
        if tribe==tribeAliases.Allies then
            setFlagTrue("NeverWarnAlliesAboutUpkeep")
        else
            setFlagTrue("NeverWarnGermansAboutUpkeep")
        end
        return
    end
    return
end

-- Battle Group Scouting
-- Terminology: "Scouting" refers to a unit's ability to reveal certain other units automatically at the
-- start of a turn.  Units are "scoutable" if they can be revealed by scouting units
-- If a unit is scouted in a location it can't defend (e.g. canNotDefendAirfield table), the unit will be moved to an adjacent tile if possible.
--
-- If a unit can scout, it is included in this table, and its scouting range in
-- tiles is listed as the value
local canScout = {}
canScout[unitAliases.RedArmyGroup.id] = 10
canScout[unitAliases.GermanArmyGroup.id] = 10
canScout[unitAliases.AlliedArmyGroup.id] = 10
canScout[unitAliases.AlliedBatteredArmyGroup.id]=6
canScout[unitAliases.GermanBatteredArmyGroup.id]=6

local canBeScouted = {}
canBeScouted[unitAliases.RedArmyGroup.id] = true
canBeScouted[unitAliases.GermanArmyGroup.id] = true
canBeScouted[unitAliases.AlliedArmyGroup.id] = true
canBeScouted[unitAliases.AlliedBatteredArmyGroup.id]=true
canBeScouted[unitAliases.GermanBatteredArmyGroup.id]=true

local function doScouting(activePlayer)
    activePlayer = activePlayer or civ.getCurrentTribe()
    --unitAliases.spotterUnit
    --specialNumbers.radarSafeTile
    local scoutableUnits = {}
    local scoutableIndex = 1
    local scoutingUnits = {}
    local scoutingIndex = 1
    for unit in civ.iterateUnits() do
        if unit.owner == activePlayer and canScout[unit.type.id] then
            scoutingUnits[scoutingIndex] = unit
            scoutingIndex = scoutingIndex+1
        elseif unit.owner ~= activePlayer and canBeScouted[unit.type.id] then
            scoutableUnits[scoutableIndex] = unit
            scoutableIndex = scoutableIndex+1
        end
    end
    local function distance(unit1,unit2)
        loc1 = unit1.location
        loc2 = unit2.location
        return (math.abs(loc1.x-loc2.x)+math.abs(loc1.y-loc2.y))//2 -- so distance is in tiles
    end
    local function isScouted(scoutableUnit) --> bool
        for __,scoutingUnit in pairs(scoutingUnits) do
            if scoutableUnit.location.landmass == scoutingUnit.location.landmass and
                distance(scoutableUnit,scoutingUnit) <= canScout[scoutingUnit.type.id] then
                return true
            end
        end
        return false
    end
    local function adjacentTileNoCity(center)
        local offsets = {{0,2},{1,1},{2,0},{1,-1},{0,-2},{-1,-1},{-2,0},{-1,1}}
        for __,offset in pairs(offsets) do
            local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
            if not t.city then
                return t
            end
        end
    end
    local function spotAdjacentScoutableUnits(center,tribe)
        local offsets = {{0,0},{0,2},{1,1},{2,0},{1,-1},{0,-2},{-1,-1},{-2,0},{-1,1}}
        local rST = civ.getTile(specialNumbers.radarSafeTile[1],specialNumbers.radarSafeTile[2],specialNumbers.radarSafeTile[3])
        for __,offset in pairs(offsets) do
            local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
            local dest = civ.getTile(rST.x+offset[1],rST.y+offset[2],rST.z)
            if t.defender ~= tribe then
                for unit in t.units do
                    if not canBeScouted[unit.type.id] then
                        unit:teleport(dest)
                    end
                end
            end
        end
        civ.deleteUnit(civ.createUnit(unitAliases.spotterUnit,tribe,center))
        for __,offset in pairs(offsets) do
            local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
            local dest = civ.getTile(rST.x+offset[1],rST.y+offset[2],rST.z)
            for unit in dest.units do
                unit:teleport(t)
            end
        end
    end
    for __,scoutedUnit in pairs(scoutableUnits) do
        if isScouted(scoutedUnit) then
            moveForbiddenDefenders(scoutedUnit.location)
            spotAdjacentScoutableUnits(adjacentTileNoCity(scoutedUnit.location),activePlayer)
        end
    end
end
console.doScouting = doScouting

--[[ superceeded
-- These are units which should have submarine qualities during the
-- opponent's turn, but not during the player's turn
-- (this way they are invisible until discovered, but don't carry munitions)
-- indexed by unit type id number, nil means false

local tempSubFlagAlliedUnits ={
    [unitAliases.Stirling.id]=true,
    [unitAliases.Halifax.id]=true,
    [unitAliases.Lancaster.id]=true,
	[unitAliases.Beaufighter.id]=true,

}

local tempSubFlagGermanUnits = {
    [unitAliases.FreightTrain.id]=true

}
local function setSubQualities()
    local activeTribe = civ.getCurrentTribe()
    if activeTribe == tribeAliases.Germans then
        for index, boolean in pairs(tempSubFlagAlliedUnits) do
            if boolean then
                -- set submarine flag to true
                civ.getUnitType(index).flags = civ.getUnitType(index).flags | 0x08
            end
        end
        for index, boolean in pairs(tempSubFlagGermanUnits) do
            if boolean then
                -- set submarine flag to false
                civ.getUnitType(index).flags = civ.getUnitType(index).flags & ~0x08
            end
        end
    else
        for index, boolean in pairs(tempSubFlagGermanUnits) do
            if boolean then
                -- set submarine flag to true
                civ.getUnitType(index).flags = civ.getUnitType(index).flags | 0x08
            end
        end
        for index, boolean in pairs(tempSubFlagAlliedUnits) do
            if boolean then
                -- set submarine flag to false
                civ.getUnitType(index).flags = civ.getUnitType(index).flags & ~0x08
            end
        end
    end
end
console.setSubQualities = setSubQualities
--]]


-- ships with the ability to carry units and the capacity they possess
-- absent index means the unit is not a transport ship
-- hold is the number of cargo slots for the ship
-- move is the movement allocation for the ship
local transportShips={
    [unitAliases.AlliedTaskForce.id]={hold=2,move=12},
    [unitAliases.GermanTaskForce.id]={hold=2,move=12},
}

-- land units restricted to the use of cities for loading and unloading
-- move is the movement allocation for the unit MANDATORY
-- onlyLoadInPort set to true if the unit must be picked up by transport in a city
-- onlyUnloadInPort set to true if the unit can only unload in a port
-- beachUnloadPenalty set to true if the unit can unload onto any square,
--      but is subject to the movement penalty and reaction from nearby enemies
-- Only one of onlyUnloadInPort and beachUnloadPenalty should be used
local harbourUsers={
    [unitAliases.constructionTeam.id]={move=4,onlyLoadInPort=true,onlyUnloadInPort=true},
    [unitAliases.FreightTrain.id]={move=12,onlyLoadInPort=true,onlyUnloadInPort=true},
    [unitAliases.AlliedArmyGroup.id]={move=8, beachUnloadPenalty=true},
    [unitAliases.GermanArmyGroup.id]={move=8, beachUnloadPenalty=true},
	[unitAliases.GermanBatteredArmyGroup.id]={move=6, onlyUnloadInPort=true},
	[unitAliases.AlliedBatteredArmyGroup.id]={move=6, onlyUnloadInPort=true},
	[unitAliases.GermanFlak.id]={move=4, onlyUnloadInPort=true},
	[unitAliases.AlliedFlak.id]={move=4, onlyUnloadInPort=true},
	[unitAliases.FlakTrain.id]={move=10, onlyLoadInPort=true, onlyUnloadInPort=true},
	[unitAliases.Sdkfz.id]={move=8, onlyUnloadInPort=true},
	[unitAliases.RedArmyGroup.id]={move=8, beachUnloadPenalty=true},
    [unitAliases.AlliedLightFlak.id]={move=2, onlyUnloadInPort=true},
    [unitAliases.GermanLightFlak.id]={move=2, onlyUnloadInPort=true},
}   


-- search for 
-- local function harbourUnitActivationFunction(activeUnit)
-- to find the implementing functions

local function harbourUnitActivationFunction(activeUnit)
    local activeUnitTypeID=activeUnit.type.id
    if (activeUnit.owner == tribeAliases.Germans and (not flag("GermansCanInvade")))
        or (activeUnit.owner == tribeAliases.Allies and (not flag("AlliesCanInvade"))) then
        for index,shipInfo in pairs(transportShips) do
            civ.getUnitType(index).hold = 0
            --civ.getUnitType(index).move = shipInfo.move*totpp.movementMultipliers.aggregate
        end
    elseif transportShips[activeUnitTypeID] then
        for index,shipInfo in pairs(transportShips) do
            civ.getUnitType(index).hold = shipInfo.hold
            --civ.getUnitType(index).move = shipInfo.move*totpp.movementMultipliers.aggregate
        end
        --[[
        --Since units can't be unloaded by sailing a transport into the land (since the menu was disabled)
        --this portion of code is no longer necessary
        for index,unitInfo in pairs(harbourUsers) do
            if unitInfo.beachUnloadPenalty or unitInfo.onlyUnloadInPort then
                civ.getUnitType(index).move=0
            end
        end--]]
    elseif harbourUsers[activeUnitTypeID] and harbourUsers[activeUnitTypeID].onlyLoadInPort then
        for index,shipInfo in pairs(transportShips) do
            civ.getUnitType(index).hold = 0
            --civ.getUnitType(index).move = 0
        end
        --for index,unitInfo in pairs(harbourUsers) do
            --civ.getUnitType(index).move = unitInfo.move*totpp.movementMultipliers.aggregate
        --end
    else
        for index,shipInfo in pairs(transportShips) do
            --civ.getUnitType(index).move=0
            civ.getUnitType(index).hold = shipInfo.hold
        end
        --for index,unitInfo in pairs(harbourUsers) do
        --    civ.getUnitType(index).move = unitInfo.move*totpp.movementMultipliers.aggregate
        --end
    end
end

-- to be run after spacebar,s,w,f are pressed, to ensure
-- that all units can be selected by the game to be the next active unit
-- I don't think it is necessary anymore
local function harbourKeyPressFunction()
    -- for index,shipInfo in pairs(transportShips) do
    --     civ.getUnitType(index).move=shipInfo.move
    -- end
    -- for index,unitInfo in pairs(harbourUsers) do
    --     civ.getUnitType(index).move=unitInfo.move
    -- end
end


-- returns movement allowance for a unit, multiplied by the road/rail multiplier
local function maxMoves(unit)
    local moveAllowance = (unit.hitpoints*unit.type.move)//unit.type.hitpoints
    local moveMult = totpp.movementMultipliers.aggregate
    if moveAllowance % moveMult > 0 then
        moveAllowance = moveAllowance - moveAllowance % moveMult + moveMult
    end
    if unit.type.domain == 0 then
        return math.min(math.max( moveAllowance,moveMult),unit.type.move)
    elseif unit.type.domain == 1 then
        return unit.type.move
    elseif unit.type.domain == 2 then
        return math.min(math.max( moveAllowance,2*moveMult),unit.type.move)
    else

    end
end

local function amphibiousPenalty(unit,carryingShip)
    secondaryAttackReactionWrapper(unit,{},overTwoHundred.doOnUnitKilled())
    if carryingShip then
        secondaryAttackReactionWrapper(carryingShip,{},overTwoHundred.doOnUnitKilled())
    end
    unit.moveSpent = math.max(unit.moveSpent,maxMoves(unit)-specialNumbers.beachLandingMoves*totpp.movementMultipliers.aggregate)
end
    
--==========================================================================
--==========================================================================
-- TRAINLIFT
-- 
-- noTrainlift is indexed by unittype id.  These units can't be transported using the
-- 'trainlift system.  If the value is a string, that message is displayed for why the
-- unit can't be transported by train
-- If true, a generic message is shown.
-- Air and Sea units can never be trainlifted, the function just closes with no action
local noTrainlift = {}
noTrainlift[unitAliases.FlakTrain.id] = "Flak Trains cannot be transported by other locomotives.  They must relocate under their own power."
noTrainlift[unitAliases.FreightTrain.id] = "This is already a train.  We can't transport it using the military transport system."
noTrainlift[unitAliases.EarlyRadar.id] = true

textAliases.OTRConceptsTrainlift = "OTR Concepts: Military Rail Transport"

-- set value to true if trainlift trains can cross the terrain type of the index
local trainCanCrossTerrain = {
    [0]=true,
    [1]=true,
    [4]=true,
    [6]=true,
    [8]=true,
    [9]=true,
    [12]=true,
    [13]=true,
    [14]=true,
}

local function excludeTilesCity(city,trainliftUnit,excludedTilesTable)
    local trainliftTribe = trainliftUnit.owner
    if city.owner == trainliftTribe or city.location.landmass ~= trainliftUnit.location.landmass then
        return
    end
    local tileTable = {}
    radar.diamond(city.location,specialNumbers.trainliftCityExclusionRadius,tileTable,false)
    for __,tile in pairs(tileTable) do
        excludedTilesTable[#excludedTilesTable+1]=tile
    end
end

local function excludeTilesUnit(unit,trainliftUnit,excludedTilesTable)
    local trainliftTribe = trainliftUnit.owner
    local unitType = unit.type
    if (unit.owner == trainliftTribe) or (unit.location.landmass ~= trainliftUnit.location.landmass) then
        return
    end
    if unitType == unitAliases.Railyard then
        local l=unit.location
        excludedTilesTable[#excludedTilesTable+1]=civ.getTile(l.x,l.y,0)
        return
    end
    -- if changing so that planes can block the track,
    -- keep in mind that below assumes the unit is a land
    -- unit, so double check code
    if unitType.domain ~= 0 then
        return
    end
    if unitType == unitAliases.AlliedArmyGroup or unitType == unitAliases.GermanArmyGroup
        or unitType == unitAliases.RedArmyGroup then
        local tileTable = {}
        radar.diamond(unit.location,specialNumbers.trainliftBattleGroupExclusionRadius,tileTable,false)
        for __,tile in pairs(tileTable) do
            excludedTilesTable[#excludedTilesTable+1]=tile
        end
        return
    elseif unitType == unitAliases.AlliedBatteredArmyGroup 
        or unitType == unitAliases.GermanBatteredArmyGroup then
        local tileTable = {}
        radar.diamond(unit.location,specialNumbers.trainliftDepletedBattleGroupExclusionRadius,tileTable,false)
        for __,tile in pairs(tileTable) do
            excludedTilesTable[1+#excludedTilesTable]=tile
        end
        return
    elseif trainCanCrossTerrain[(unit.location.terrainType % 16)] then
        local tileTable = {}
        radar.diamond(unit.location,1,tileTable,false)
        for __,tile in pairs(tileTable) do
            excludedTilesTable[1+#excludedTilesTable]=tile
        end
        return
    end
end

local function doTrainlift(unit)
    if unit.type.domain ~= 0 then
        return
    end
    local noTrainliftVal = noTrainlift[unit.type.id]
    if noTrainliftVal then
        if type(noTrainliftVal) == "string" then
            text.simple(noTrainliftVal,textAliases.OTRConceptsTrainlift)
        else
            text.simple(unit.type.name.." units cannot take advantage of military rail transportation.",
                textAliases.OTRConceptsTrainlift)
        end
        return
    end
    local unitCity = unit.location.city
    if (not unitCity) or (unitCity and 
        unitCity:hasImprovement(improvementAliases.airbase)) then
        text.simple("Military rail transportation must begin and end at cities with functioning railyards.",
            textAliases.OTRConceptsTrainlift)
        return
    end
    if unitCity:hasImprovement(improvementAliases.cityI) and
        not(unitCity:hasImprovement(improvementAliases.railyards)) then
        text.simple("The railyard in "..unitCity.name.." has suffered heavy damage.  It must be repaired before we can bring in enough trains to move this "..unit.type.name..".",textAliases.OTRConceptsTrainlift)
    end
    if state.cityHasDoneTrainlift[unitCity.id] then
        text.simple("The railyards near "..unitCity.name.." are already operating at capacity."..
        "  Only one unit per turn may be transported in or out of a city using the military rail transportation system.",
        "Railyard At Capacity")
        return
    end
    local excludedTiles = {}
    local potentialDestinations = {}
    for city in civ.iterateCities() do
        excludeTilesCity(city,unit,excludedTiles)
        if city.owner == unit.owner and not (state.cityHasDoneTrainlift[city.id])
            and city:hasImprovement(improvementAliases.railyards)
            and city ~= unitCity then
            potentialDestinations[city.id] = city.location
        end
    end
    for unitInList in civ.iterateUnits() do
        excludeTilesUnit(unitInList,unit,excludedTiles)
    end
    print(#excludedTiles)
    local pathTable = pathfind.breadthFirstSearchFixedCost(unit.location,
        potentialDestinations,trainCanCrossTerrain,excludedTiles)
    local menuTable = {}
    for index,value in pairs(pathTable) do
        if type(value) == "table" then
            local distance = #value -1
            local cost = math.ceil(specialNumbers.trainliftFixedCost+distance*specialNumbers.trainliftCostPerTile)
            pathTable[index] = cost
            -- have to add 1 to the menu index, since a city can have an index of 0, but that
            -- corresponds to cancel in the choice
            menuTable[index+1] = civ.getCity(index).name.." ("..tostring(cost).." Fuel)"
        else
            pathTable[index] = nil
        end
    end
    local menuText = "We can use our rail network to re-deploy this "..unit.type.name..
            " to any of the following cities."
    local choice = text.menu(menuTable,menuText,"Military Rail Transport",true)
    if choice == 0 then
        return
    else
        -- "re-align" menu option with city id
        choice = choice - 1
        if pathTable[choice] > unit.owner.money then
            text.simple("We don't have enough fuel to transport the "..unit.type.name..
                " all the way to "..civ.getCity(choice).name..".","Military Rail Transport")
            return
        else
            state.cityHasDoneTrainlift[unitCity.id] = true
            state.cityHasDoneTrainlift[choice] = true
            unit:teleport(civ.getCity(choice).location)
            unit.moveSpent = unit.type.move
            unit.owner.money = math.max(0,unit.owner.money-pathTable[choice])
            text.simple(unit.type.name.." successfully transported to "..civ.getCity(choice).name..".",
                "Military Rail Transport")
            return
        end
    end
end

-- automatically reHomes payload aircraft that are activated
-- in a city, if they currently have no home city
local function reHomePayloadUnit(unit,suppressMessage)
    if unit.homeCity or (not unit.location.city) then
        return
    end
    local payloadUnit = false
    local attackType = nil
    for __,specification in pairs(artilleryUnitTypes) do
        if specification.unitType == unit.type then
            if specification.payload then
                payloadUnit =true
                attackType = "primary"
            end
            break
        end
    end
    if not payloadUnit then
        for __,specification in pairs(secondaryAttackUnitTypes) do
            if specification.unitType == unit.type then
                if specification.payload then
                    payloadUnit =true
                    attackType = "secondary"
                end
                break
            end
        end
    end
    if not payloadUnit then
        return
    end
    if gen.cityCanSupportAnotherUnit(unit.location.city) then
        unit.homeCity = unit.location.city
        return
    elseif not suppressMessage then
        text.simple("This "..unit.type.name.." has not been automatically re-armed because "..
        unit.location.city.name.." can not support any more units.  This unit can't use its "..attackType..
        " attack until it has a home city.", "Over the Reich Concepts: Munition Payloads")
        return
    else
        return
    end
end

-- Escape into Night
-- This is the code for night fighters and bombers to escape after an attack

-- Compute the fraction of HP, the escape radius is given by the largest key value which is less
-- than that fraction of hp
-- e.g. 35% has a radius of 1, 80% has a radius of 2 in the defaultEscapeRadiusHPFraction
-- The value at 0 is the minimum number of squares a plane will travel if the 'within radius'
-- value is set to true in the escapeIntoNight function.  Have a slightly higher key if you want
-- nearly dead units to have a chance to go further out

local defaultEscapeRadiusHPFraction = gen.makeThresholdTable({[0]=2,[0.01]=3,[0.25]=5,[0.75]=6,})
local nightEscapeUnits = {}
nightEscapeUnits[unitAliases.Stirling.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.Halifax.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.Lancaster.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.Beaufighter.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.MosquitoII.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.MosquitoXIII.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.Ju88C.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.Ju88G.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.He219.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.He111.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.Do217.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.He277.id]=defaultEscapeRadiusHPFraction
nightEscapeUnits[unitAliases.hwSchnaufer.id]=defaultEscapeRadiusHPFraction
--nightEscapeUnits[unitAliases.]=defaultEscapeRadiusHPFraction
--nightEscapeUnits[unitAliases.]=defaultEscapeRadiusHPFraction


function overTwoHundred.escapeIntoNight(winner,loser)
    if winner.location.z == 2 and (not winner.location.city) and
        nightEscapeUnits[winner.type.id] and (not(loser.type == unitAliases.Flak or loser.type == unitAliases.LightFlak)) then
        local escapeRadius = nightEscapeUnits[winner.type.id][(winner.hitpoints/(winner.type.hitpoints))]
        local minRadius = nightEscapeUnits[winner.type.id][0]
        -- if withinRadius is true, then all the squares within the escape radius (including the current location of the winner)
        -- are equally likely to be chosen for escape
        -- if withinRadius is false, only the squares exactly the escapeDistance away are considered as places to move
        local withinRadius = true
        -- if avoidStacks is true, then an escaping plane will not stack with a friendly unit, unless no other squares are
        -- available
        -- if false, then the escaping plane is just as likely to choose a square with a friend as an empty square
        local avoidStacks = true
        local potentialEscapeTiles = {}
        local originalSquare = winner.location
        if withinRadius then
            for i=minRadius,escapeRadius do
                radar.tileRing(originalSquare,i,potentialEscapeTiles,false)
            end
        else
            radar.tileRing(originalSquare,escapeRadius,potentialEscapeTiles,false)
        end
        local firstChoiceTiles = {}
        local secondChoiceTiles = {}
        for __,tile in pairs(potentialEscapeTiles) do
            if tile.defender == nil then
                firstChoiceTiles[#firstChoiceTiles+1] = tile
            elseif avoidStacks and tile.defender == winner.owner then
                secondChoiceTiles[#secondChoiceTiles+1] = tile
            elseif tile.defender == winner.owner then
                firstChoiceTiles[#firstChoiceTiles+1] = tile
            end
        end
        local destinationTile = originalSquare
        if #firstChoiceTiles > 0 then
            destinationTile = firstChoiceTiles[math.random(1,#firstChoiceTiles)]
        elseif #secondChoiceTiles > 0 then
            destinationTile = secondChoiceTiles[math.random(1,#secondChoiceTiles)]
        end
        if destinationTile ~= originalSquare then
            -- unit escapes to another tile
            text.simple("We've attacked an enemy aircraft, but only damaged it! It escapes into the night!")
            winner:teleport(destinationTile)
        end
    end
end

-- GOTO hotkey gotohotkey gotohotkeys goto hotkeys
function overTwoHundred.setGoToHotKey()
    if civ.getActiveUnit() then
        return
    end
    state.hotkeys = state.hotkeys or {}
    for tribe = 0,7 do
        state.hotkeys[tribe] = state.hotkeys[tribe] or {}
    end
    local destinationTile = civ.getCurrentTile()

    local menuText = "Set the tile ("..tostring(destinationTile.x)..
    ","..tostring(destinationTile.y)..") as the goto destination for the active unit when the following key is pressed:"
    local menuTable = {}
    local function hotkeyValToString(hotkeyVal)
        if hotkeyVal then
            return ", currently set to ("..tostring(hotkeyVal[1])..","..tostring(hotkeyVal[2])..")"
        else
            return ""
        end
    end
    menuTable[7] = "Key 7"..hotkeyValToString(state.hotkeys[civ.getCurrentTribe().id][7])
    menuTable[8] = "Key 8"..hotkeyValToString(state.hotkeys[civ.getCurrentTribe().id][8])
    menuTable[9] = "Key 9"..hotkeyValToString(state.hotkeys[civ.getCurrentTribe().id][9])
    menuTable[20] = "Don't set a hotkey."
    menuTable[21] = "Clear all hotkeys."
    choice = text.menu(menuTable,menuText,"GOTO Hotkeys")
    if choice == 20 then
        return
    elseif choice == 21 then
        state.hotkeys[civ.getCurrentTribe().id][7]=nil
        state.hotkeys[civ.getCurrentTribe().id][8]=nil
        state.hotkeys[civ.getCurrentTribe().id][9]=nil
        return
    end
    state.hotkeys[civ.getCurrentTribe().id][choice]={destinationTile.x,destinationTile.y}
    return
end

function overTwoHundred.useGoToHotKey(numberKey)
    if not civ.getActiveUnit() then
        return
    end
    local currentUnit = civ.getActiveUnit()
    state.hotkeys = state.hotkeys or {}
    for tribe = 0,7 do
        state.hotkeys[tribe] = state.hotkeys[tribe] or {}
    end
    local hotkeyDest =  state.hotkeys[currentUnit.owner.id][numberKey]
    if hotkeyDest then
        local destTile = civ.getTile(hotkeyDest[1],hotkeyDest[2],currentUnit.location.z)
        if trainGoto.isTrain(currentUnit) then
            trainGoto.trainGotoGuts(currentUnit,destTile)
        else
            currentUnit.gotoTile = destTile
        end

        overTwoHundred.currentUnitGotoOrder = civ.getTile(hotkeyDest[1],hotkeyDest[2],currentUnit.location.z)
    else
        text.simple("The key "..tostring(numberKey).." is not set as a goto hotkey.","GOTO Hotkeys")
    end
end


-- ���������� Event Triggers: ��������������������������������������������������������������������������������������������������������������������������������������������

function overTwoHundred.defaultBuildFn(city,item)
    return city:canBuild(item)
end

overTwoHundred.germanAircraftBuildPolygon = {{278,58},{270,66},{265,71},{265,75},{267,77},{266,78},{267,79},{270,82},{268,84},{269,85},{268,86},{269,87},{272,90},{273,89},{275,91},{276,90},{277,91},{278,90},{280,92},{281,91},{283,93},{282,94},{286,98},{288,98},{288,100},{283,105},{284,106},{283,107},{277,113},{276,112},{273,115},{272,114},{270,116},{269,115},{267,117},{268,118},{264,122},{265,123},{263,125},{265,127},{271,127},{272,126},{280,126},{281,125},{285,125},{285,145},{407,145},{407,1},{406,0},{362,0},{320,0},{282,0},{282,32},}


overTwoHundred.alliedAircraftBuildPolygon = {{0,78},{88,78},{136,78},{168,78},{184,78},{190,78},{204,64},{204,22},{204,0},{132,0},{104,0},{20,0},{0,0},}

overTwoHundred.canCityBuild = function (defaultBuildFunction, city, item)
    --resetProductionValues()
	local separateCondition=nil
	if civ.isUnitType(item) then
        if item == unitAliases.RedArmyGroup then
            return false
        end
        if item == unitAliases.Sunderland and (city.location == civ.getTile(117,71,0) or 
            city.location == civ.getTile(108,18,0)) then
            -- Bolt Head and Mullaghmore can always produce Sunderlands
            return true
        end
        if city.owner == tribeAliases.Germans and item.domain == 1 and not gen.inPolygon(city.location,overTwoHundred.germanAircraftBuildPolygon) then
            return false
        end
        if city.owner == tribeAliases.Allies and item.domain == 1 and not gen.inPolygon(city.location,overTwoHundred.alliedAircraftBuildPolygon) then
            return false
        end
		for _,restrictedUnit in pairs(buildRestrictionsUnits) do
			if item.id == restrictedUnit.unit.id then
				separateCondition = restrictedUnit.conditionMet(city,state)
			end
		end
	end
	if civ.isImprovement(item) then
        if item == improvementAliases.firefighters then
            return city:hasImprovement(improvementAliases.cityI) and not(city:hasImprovement(improvementAliases.firefighters)) 
        end
        if item == improvementAliases.militaryPort and (city == cityAliases.Peenemunde or city == cityAliases.Friedrichshaven) then
            return false
        end
		for _,restrictedImprovement in pairs(buildRestrictionsImprovements) do
			if item.id == restrictedImprovement.improvement.id then
				separateCondition = restrictedImprovement.conditionMet(city,state)
			end
		end
	end
	if civ.isWonder(item) then
		for _,restrictedWonder in pairs(buildRestrictionsWonders) do
			if item.id == restrictedWonder.wonder.id then
				separateCondition = restrictedWonder.conditionMet(city,state)
			end
		end
	end
	if separateCondition == nil then
		return defaultBuildFunction(city,item)
	else
		return separateCondition
	end
end
civ.scen.onCanBuild(overTwoHundred.canCityBuild)

function overTwoHundred.canCityProduceItem(city,item)
    return overTwoHundred.canCityBuild(overTwoHundred.defaultBuildFn,city,item)
end

------------------------------------------------------------------------------------------------------------------------------------------------
civ.scen.onCityProduction(function(city, prod)
--This function will be called whenever something is produced
        if civ.isUnit(prod) and not overTwoHundred.canCityProduceItem(city,prod.type) and (prod.type ~= unitAliases.FreightTrain) then
            city.shields = city.shields + 10*prod.type.cost
            text.simple(city.name.." was set to produce a "..prod.type.name.." but it can't produce that unit type.  The unit has not been produced, and the shields have been returned to the production box.","Build Order Out of Date")
            civ.deleteUnit(prod)
        end
        if civ.isUnit(prod) then
            local prodType = prod.type
            if (prodType == unitAliases.Me109G6 or prodType == unitAliases.Me109K4 or prodType == unitAliases.Me109G14 )
                and overTwoHundred.germanCriticalIndustryActive(cityAliases.Regensburg) then
                local unitsToCreate = specialNumbers.bonusME109
                if math.random() < unitsToCreate - math.floor(unitsToCreate) then
                    unitsToCreate = math.ceil(unitsToCreate)
                else
                    unitsToCreate = math.floor(unitsToCreate)
                end
                for i=1,unitsToCreate do
                    local extraUnit = civ.createUnit(prodType,city.owner,city.location)
                    extraUnit.homeCity = city
                    extraUnit.veteran = false
                end
            end
        end
            
		if civ.isImprovement(prod) then
		
			--[[ by Knighttime ]]
			if improvementUnitTerrainLinks[prod.id] ~= nil then						-- Check that an entry for this improvement exists in the table
				-- A. Create one unit, on the *first* listed tile only:
				if improvementUnitTerrainLinks[prod.id]["unitTypeId"] ~= nil then	-- Check that a unit type should be created
					local xcoord, ycoord = table.unpack(cityCoordinates[city.id][prod.id][1])
					local zcoord = 1		-- Hardcoded reference to the map on which a unit will normally be created
					if prod.id == 4 or prod.id == 11 or prod.id == 14 or (prod.id == improvementAliases.criticalIndustry.id and city == cityAliases.Peenemunde) then
						zcoord = 2			-- Hardcoded references (on previous line) to specific improvements that will cause a unit to be created on map 2 *instead*
					end
					local unitDestination = civ.getTile(xcoord, ycoord, zcoord)
					if unitDestination ~= nil then
						local unitTypeToCreate = civ.getUnitType(improvementUnitTerrainLinks[prod.id]["unitTypeId"])
						if civlua.isValidUnitLocation(unitTypeToCreate, city.owner, unitDestination) == false then
							-- Presumably false because its occupied by an enemy unit, so delete all units on that tile:
							for enemyUnit in unitDestination.units do
								print("Deleted enemy unit blocking unit creation: " .. 
									  enemyUnit.owner.adjective .. " " .. enemyUnit.type.name .. " at " .. xcoord .. "," .. ycoord .. "," .. zcoord)
								civ.deleteUnit(enemyUnit)
							end
						end
						local newUnit = civ.createUnit(unitTypeToCreate, city.owner, unitDestination)
						if newUnit ~= nil then
							newUnit.homeCity = city
							newUnit.veteran = true
							print("Created " .. newUnit.type.name .. " unit at " .. xcoord .. "," .. ycoord .. "," .. zcoord)
						else
							print("ERROR: Failed to create unit at " .. xcoord .. "," .. ycoord .. "," .. zcoord)
						end
					else
						print("ERROR: Invalid unit destination " .. xcoord .. "," .. ycoord .. "," .. zcoord)
					end
				end
				
				-- B. Change the terrain type on one or more tiles, on one or more maps:
				changeAllTerrain(prod.id, "build", cityCoordinates[city.id][prod.id])
			end
	    --p.g. ensures day and night airfields have same improvements
		if city.location.z ==0 and civ.getTile(city.location.x,city.location.y,2).city then
		    civ.addImprovement(civ.getTile(city.location.x,city.location.y,2).city,prod)
		end
		if city.location.z==2 and civ.getTile(city.location.x,city.location.y,0).city then
		    civ.addImprovement(civ.getTile(city.location.x,city.location.y,0).city,prod)
		end

		end --End code for if an improvement is produced
        -- move 15th AF and Red Tails to Italy
        if civ.isUnit(prod) and (prod.type == unitAliases.RedTails or prod.type == unitAliases.MedBombers) then
            prod:teleport(civ.getTile(345,145,0))
            prod.homeCity = nil
            prod.moveSpent = prod.type.move
        end
        -- code to take away trains if chastise is successful
        if civ.isUnit(prod) and prod.type == unitAliases.FreightTrain
        and prod.owner == tribeAliases.Germans
        and counterValue("ChastiseTrainsToDivert") > 0 then
            incrementCounter("ChastiseTrainsToDivert",-1)
            civ.deleteUnit(prod)
            local message = civ.ui.createDialog()
            message.title = "Defense Minister"
            local messageText = [[Due to the recent destruction of the Ruhr Valley Dams, a trainload of war supplies has been diverted from air defense production.  ]]..tostring(counterValue("ChastiseTrainsToDivert"))..[[ more trains will be diverted before we can resume normal production.]]
            message:addText(messageText)
            message:show()

        end
		--resetProductionValues()


end) -- End onCityProduction

------------------------------------------------------------------------------------------------------------------------------------------------
-- p.g.
-- Checks if a tribe has all the cities in a table of cities
-- Returns true if so, false otherwise
function hasAllCities(tribe,tableOfCities)
    hasAllCitiesSoFar = true
    for __, city in pairs(tableOfCities) do
        hasAllCitiesSoFar = hasAllCitiesSoFar and (city.owner == tribe)
        -- if city.owner == tribe is false, hasAllCitiesSoFar becomes false, and will stay false
    end
    return hasAllCitiesSoFar
end

local DDayPortCities = {cityAliases.Bordeaux, cityAliases.LaRochelle, cityAliases.StNazaire,cityAliases.Brest,
            cityAliases.Cherbourg,cityAliases.LeHavre,cityAliases.Calais,cityAliases.Antwerp,cityAliases.TheHague,
            cityAliases.Rotterdam,cityAliases.Amsterdam,cityAliases.Wilhelmshaven,cityAliases.Bremen,cityAliases.Hamburg,cityAliases.Nantes,}

civ.scen.onCityDestroyed(function(city)
    log.onCityDestroyed(city)
end)

civ.scen.onCityTaken(function (city, defender)
    log.onCityTaken(city,defender)
     -- Will check all units in the game for those whose home city is the city taken.  If so, we run the 
    -- strategic target code from civ.scen.onUnitKilled in order to remove improvements and change the appropriate terrain
    for unit in civ.iterateUnits() do
        if unit.homeCity == city then
            local loser = unit

	--[[ by Knighttime ]]
	if civ.getTile(loser.x, loser.y, loser.z) ~= nil then
		local tileId = getTileId(loser.location)
		if tileLookup[tileId] ~= nil then		-- Check that an entry for this location exists in the table
			-- Verification:
			if loser.type.id ~= improvementUnitTerrainLinks[tileLookup[tileId].improvementId].unitTypeId then
				-- This will happen whenever a *non-event-created* unit is killed on a tile that *can* hold an event-created unit
				-- It doesn't necessarily indicate a problem with the Lua events
				print("    Unit type killed = " .. loser.type.id .. ", event unit type for " .. loser.x .. "," .. loser.y .. "," .. loser.z .. " = " .. improvementUnitTerrainLinks[tileLookup[tileId].improvementId].unitTypeId)
			elseif loser.homeCity.id ~= tileLookup[tileId].cityId then
				-- This shouldn't happen.  If the unit is the type we expect to be created here by events,
				-- its home city should match what we would have built here
				print("ERROR: city mismatch found, unit city = " .. loser.homeCity.id .. ", tile city = " .. tileLookup[tileId].cityId)
			else
				-- A. Destroy a city improvement:
				local improvementToRemove = civ.getImprovement(tileLookup[tileId].improvementId)
				local cityToRemoveImprovementFrom = civ.getCity(tileLookup[tileId].cityId)
				civ.removeImprovement(cityToRemoveImprovementFrom, improvementToRemove)
				print("Removed " .. improvementToRemove.name .. " improvement from " .. cityToRemoveImprovementFrom.name)
				
				-- B. Change the terrain type on one or more tiles, on one or more maps:
				changeAllTerrain(tileLookup[tileId].improvementId, "destroy", tileLookup[tileId].allLocations)
				
			end
		else
			--print("    Detected unit killed, but no \"tileLookup\" entry found for " .. loser.x .. "," .. loser.y .. "," .. loser.z)
		end
	end
        end -- end if unit.homeCity == city then
    end --for unit in civ.iterateUnits() do
	 if defender == tribeAliases.Germans and (city.location.terrainType % 16) ~= 9 and city.location.landmass == 10  then -- Code by Prof. Garfield
     state.DDayInvasion=true  -- this could probably be moved inside justOnce, but it shouldn't matter
     justOnce("OperationNeptune", function ()
     civ.ui.text(func.splitlines(textAliases.DDayText))
        --newspaper.addToNewspaper(state.newspaper.allies,"Operation Neptune Report",textAliases.DDayText)
        text.addToArchive(tribeAliases.Allies,textAliases.DDayText,"Operation Neptune Report","Operation Neptune Report")
     tribe = civ.getCurrentTribe()
     tribe:giveTech(civ.getTech(75))
     -- state.delay = 5 -- added this line to initialize the delay
        -- p.g. delay no longer needed
    end) -- end justOnce
  end --End if defender is german
        --p.g.  terrain check correction
     if defender ==tribeAliases.Allies and (city.location.terrainType % 16) ~= 9 and city.location.landmass == 10 then
     text.displayNextOpportunity({tribeAliases.Allies,tribeAliases.Germans},textAliases.germanCityCapture1..city.name..textAliases.germanCityCapture2,"Battle of "..city.name,"Battle of "..city.name)
     
     end -- Message does not happen on airbase capture. -- p.g. terrain check correction
     if defender==tribeAliases.Germans and hasAllCities(tribeAliases.Germans,DDayPortCities) and (city.location.terrainType % 16) ~=9 and city.location.landmass == 10 then
        civ.ui.text(func.splitlines(textAliases.DDayInBaltic1..city.name..textAliases.DDayInBaltic2))
        --newspaper.addToNewspaper(state.newspaper.allies,"Operation Neptune Report",textAliases.DDayInBaltic1..city.name..textAliases.DDayInBaltic2)
        text.addToArchive(tribeAliases.Allies,textAliases.DDayInBaltic1..city.name..textAliases.DDayInBaltic2,"Operation Neptune Report","Operation Neptune Report")

     end -- Message does not happen on airbase capture
    -- Loss check does not happen on airbase capture. 
  if  state.DDayInvasion and hasAllCities(tribeAliases.Germans,DDayPortCities) and defender==tribeAliases.Allies then
    text.displayNextOpportunity({tribeAliases.Allies,tribeAliases.Germans},textAliases.AlliedLoss,"Allied Defeat","Allied Defeat")
    
  end -- End loss check,
  -- Capture night airbase when day airbase is captured
  
  if civ.getTile(city.location.x,city.location.y,2).city and city.location.z == 0 then
    local nightAirfieldTile = civ.getTile(city.location.x,city.location.y,2)
    local planeKilledTextNotShown = true
    for nightAirplane in nightAirfieldTile.units do
        if planeKilledTextNotShown and nightAirplane then
            print(nightAirplane)
            civ.ui.text(func.splitlines("Troops destroy enemy night aircraft on the ground."))
            planeKilledTextNotShown = false
        end
        civ.deleteUnit(nightAirplane)
    end -- end for nightAirplane
    civ.ui.text("The Airfield "..city.name.." (and "..nightAirfieldTile.city.name..") has been destroyed in combat.  (This may not be visible until your next unit is activated.)")
    
    civ.deleteCity(nightAirfieldTile.city)
    overTwoHundred.cityToDelete = city
    --civ.deleteCity(city)
    --civ.captureCity(nightAirfieldTile.city,city.owner)
  end -- end capture night airfield if day airfield taken.
  -- Airfields must be captured on the daytime map.
  if city.location.z == 2 and civ.getTile(city.location.x,city.location.y,0).city then
    local dayAirbase = civ.getTile(city.location.x,city.location.y,0).city
    if city.owner ~=dayAirbase.owner then
        civ.ui.text(func.splitlines(textAliases.nightAirfieldCapture))
        for unit in city.location.units do
            civ.deleteUnit(unit)
        end
    city.owner = dayAirbase.owner
    end
  end -- end code preventing night airfield capture


    
end) --End function and onCityTaken







function overTwoHundred.isDirectionKey(keyID)
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

local lastKeyPAndActiveUnit = false

function overTwoHundred.goInDirection(unit,keyID)
    -- the unit will move until it has 2 movement points left
    -- if porting this code, you will need to account for totpp.movementMultipliers.aggregate
    local maxDistance = unit.type.move-unit.moveSpent-2
    local startTile = unit.location
    local destinationTile = startTile
    local bestValidDestination = startTile
    local distance = 0
    while (destinationTile and (destinationTile.city == nil)) and distance <= maxDistance +1 do
        bestValidDestination = destinationTile
        if keyID == 192 or keyID == 168 then
        -- up (smaller y)
            destinationTile = civ.getTile(startTile.x,startTile.y-2*distance,startTile.z)
        elseif keyID == 193 or keyID == 162 then
        -- down (bigger y)
            destinationTile = civ.getTile(startTile.x,startTile.y+2*distance,startTile.z)
        elseif keyID == 194 or keyID == 164 then
        -- left (smaller x)
            destinationTile = civ.getTile(startTile.x-2*distance,startTile.y,startTile.z)
        elseif keyID == 195 or keyID == 166  then
        -- right (bigger x)
            destinationTile = civ.getTile(startTile.x+2*distance,startTile.y,startTile.z)
        elseif keyID == 197 or keyID == 169  then
        -- up-right smaller y, bigger x
            destinationTile = civ.getTile(startTile.x+distance,startTile.y-distance,startTile.z)
        elseif keyID == 196 or keyID == 167  then
        -- up-left smaller y smaller x
            destinationTile = civ.getTile(startTile.x-distance,startTile.y-distance,startTile.z)
        elseif keyID == 198 or keyID == 163  then
        -- down right bigger y bigger x
            destinationTile = civ.getTile(startTile.x+distance,startTile.y+distance,startTile.z)
        elseif keyID == 199 or keyID == 161  then
        -- down left bigger y smaller x
            destinationTile = civ.getTile(startTile.x-distance,startTile.y+distance,startTile.z)
        end
        distance = distance +1
        -- want to choose a goto tile that isn't a city (so that plane doesn't land in urban center)
        -- and also want to choose a tile on the map
    end
    unit.gotoTile = bestValidDestination
    overTwoHundred.currentUnitGotoOrder = bestValidDestination
end

------------------------------------------------------------------------------------------------------------------------------------------------
civ.scen.onKeyPress(function(keyID)
    if civ.getActiveUnit() and keyID == 80 --[[p]] then
        lastKeyPAndActiveUnit = true
        
        return
        -- return so that lastKeyPAndActiveUnit is not set to false
    end
    if lastKeyPAndActiveUnit and civ.getActiveUnit() then
        overTwoHundred.goInDirection(civ.getActiveUnit(),keyID)
    end
    lastKeyPAndActiveUnit = false
    if keyID == 48 --[[zero above keys]] then
        overTwoHundred.setGoToHotKey()
    end
    if keyID == 55 --[[seven]] then
        overTwoHundred.useGoToHotKey(7)
    elseif keyID == 56 --[[8]] then
        overTwoHundred.useGoToHotKey(8)
    elseif keyID == 57 --[[9]] then
        overTwoHundred.useGoToHotKey(9)
    end
    if keyID == 217 --[[delete]] then
        local tile = civ.getCurrentTile() or (civ.getActiveUnit() and civ.getActiveUnit().location) or nil
        if tile then
            overTwoHundred.calculateCombatReady(tile)
            return
        end
    end
    if keyID == 173 --[[numpad minus]] and civ.getActiveUnit() then
        local activeTribe = civ.getCurrentTribe()
        local activeUnit = civ.getActiveUnit()
        local bestAirbaseSoFar = nil
        local bestDistanceSoFar = math.huge
        local function cityToUnit(city,unit)
            return math.abs(unit.location.x-city.location.x)+math.abs(unit.location.y-city.location.y)
        end
        for possibleAirbase in civ.iterateCities() do
            if possibleAirbase.owner == activeTribe and possibleAirbase:hasImprovement(improvementAliases.airbase)
                and cityToUnit(possibleAirbase,activeUnit) < bestDistanceSoFar then
                bestDistanceSoFar = cityToUnit(possibleAirbase,activeUnit)
                bestAirbaseSoFar = possibleAirbase
            end
        end
        local function findCloserAdjacentTile(fixedTile,centerTile)
            local offsets = {{0,2},{2,0},{0,-2},{-2,0},{1,1},{1,-1},{-1,-1},{-1,1}}
            local currentDist = math.abs(fixedTile.x-centerTile.x)+math.abs(fixedTile.y-centerTile.y)
            for __,offset in pairs(offsets) do
                local adjTile = civ.getTile(centerTile.x+offset[1],centerTile.y+offset[2],centerTile.z)
                if math.abs(adjTile.x-fixedTile.x)+math.abs(adjTile.y-fixedTile.y) < currentDist then
                    return adjTile
                end
            end
        end
        local destination = findCloserAdjacentTile(activeUnit.location,bestAirbaseSoFar.location)
        destination = civ.getTile(destination.x,destination.y,activeUnit.z)
        activeUnit.gotoTile = destination
        overTwoHundred.currentUnitGotoOrder = destination
        return
    end
    if keyID == 256 and civ.getActiveUnit() then
        if overTwoHundred.currentUnitGotoOrder then
            civ.getActiveUnit().gotoTile = overTwoHundred.currentUnitGotoOrder
        end
    end
    if keyID == specialNumbers.reportKeyID then
        -- activate the log report
        return log.combatReportFunction()
    end 
    -- code for improving unit selection
    if civ.getActiveUnit() and keyID == 87 then
        gen.betterUnitManualWait()
    end
    -- code for unload units in harbour only
    -- These keys change the active unit, so want to make sure all unit types have the appropriate
    -- movement allowance, so they are eligible to be selected next
    if civ.getActiveUnit() and (keyID == 209 or keyID == 87 or keyID == 83 or (keyID == 70 and civ.getActiveUnit().location.terrainType % 16 ~=10 )) then
        -- key pressed is spacebar,w,s,or f 
        harbourKeyPressFunction()
    end
    
    if civ.getActiveUnit() and keyID == specialNumbers.secondaryAttackKey
        and groupRadarUnits[civ.getActiveUnit().type.id] then
        activateAllRadar()
        -- return, since if the secondary key is pressed for a radar station, there is no other possible
        -- thing to do
        return
    end
    if civ.getActiveUnit() and keyID == specialNumbers.secondaryAttackKey 
        and civ.getActiveUnit().type == unitAliases.UBoat then
        local activeUBoat = civ.getActiveUnit()
        if activeUBoat.location.city and activeUBoat.location.city:hasImprovement(improvementAliases.militaryPort)
            and activeUBoat.damage == 0 and activeUBoat.moveSpent ==0 and overTwoHundred.germanCriticalIndustryActive(cityAliases.Hamburg) then
            local menuText = "Do you wish to deploy this "..activeUBoat.type.name.." unit to a random square in the Atlantic Ocean?  All movement will be used for this turn, and this "..activeUBoat.type.name.." unit will take "..tostring(specialNumbers.uBoatDeployDamage).." damage."
            local menuTable = {"Move this "..activeUBoat.type.name.." normally.","Deploy to Atlantic immediately."}
            local choice = text.menu(menuTable,menuText)
            if choice == 1 then
                return
            else
                activeUBoat:teleport(overTwoHundred.selectAtlanticTile())
                gen.setMoved(activeUBoat)
                activeUBoat.moveSpent = activeUBoat.type.move
                activeUBoat.damage = activeUBoat.damage+5
                return
            end
        else
            civ.ui.text("A "..activeUBoat.type.name.." must be at full health and movement, and be located in a city with a military port in order to deploy directly to the Atlantic.  The Blohm und Voss U-Boot Werke in Hamburg must also be operational.")
            return
        end
    end
    if keyID == specialNumbers.updateCloudKey then
        --clouds.updateAllWeather(state.mapStorageTable,state.stormInfoTable,clouds.catInfoTable,state.map1FrontStatisticsTable,state.map2FrontStatisticsTable)
        --[[
        for i=1,10 do
            civ.createUnit(unitAliases.Thousandlb,civ.getCurrentTribe(),civ.getCurrentTile()) 
        end
            civ.createUnit(unitAliases.AlliedArmyGroup,civ.getCurrentTribe(),civ.getCurrentTile()) --]]
    end
    -- formation flying
    if state.formationFlag == true and overTwoHundred.isDirectionKey(keyID) and civ.getActiveUnit()  then
        state.formationFlag = formation.moveFormation(state.formationTable,keyID,state.formationFlag)
    end
    if keyID == specialNumbers.formationKeyID and civ.getActiveUnit() then
        state.formationFlag = formation.getFormation(civ.getActiveUnit(),state.formationTable,state.formationFlag)
    end
    -- veteran swap
    if keyID == specialNumbers.vetSwapKeyID and civ.getActiveUnit() then
        doVetSwap(civ.getActiveUnit())
    end
    -- wilde sau and trainlift
    if keyID == specialNumbers.wildeSauKeyID and civ.getActiveUnit() then
        if civ.getActiveUnit().type.domain == 0 then
            doTrainlift(civ.getActiveUnit())
        else
            wildeSau(civ.getActiveUnit())
        end
    end	
	if keyID ==specialNumbers.newspaperKey then
        text.openArchive()
	    --if civ.getCurrentTribe() == tribeAliases.Allies then
	    --    newspaper.newspaperMenu(state.newspaper.allies)
	    --elseif civ.getCurrentTribe() == tribeAliases.Germans then
	    --    newspaper.newspaperMenu(state.newspaper.germans)
	    --end
	end
	
	if keyID ==specialNumbers.scoreDialogKeyCode then
	    displayScore()
	end
        
    --if keyID == specialNumbers.nextKeyID or keyID == specialNumbers.backKeyID or keyID == specialNumbers.reportKeyID then
    --cr.combatReportInterface(keyID, specialNumbers.nextKeyID, specialNumbers.backKeyID, specialNumbers.reportKeyID, state.cHistTable, reportNameTable)
    --end
    -- THESE SEQUENCES ARE NECESSARY TO MAKE 'K' UNITS WORK
	--civ.ui.text(func.splitlines(tostring(keyID)))
	--civ.ui.text(func.splitlines(tostring(currentUnit.location.terrainType)))
	-- display score
	--[[if keyID ==specialNumbers.primaryAttackKey and civ.getActiveUnit() and civ.getActiveUnit().owner == tribeAliases.Germans and civ.getActiveUnit().type == unitAliases.Schutzen then
	    generateTrainsFrance(civ.getActiveUnit())
	end--]] -- old German occupation command
	if keyID == specialNumbers.helpKeyID then
	help.helpKey(keyID,specialNumbers.helpKeyID,OTRFlagTextTable,OTRUnitTypeTextTable,OTRUnitTextFunction)
	end
    if keyID == specialNumbers.secondaryAttackKey and civ.getActiveUnit() then
        local cu = civ.getActiveUnit()
       -- if cu.type == unitAliases.AlliedArmyGroup or cu.type == unitAliases.GermanArmyGroup then
       --     orderlyRetreat(cu)
       -- end
        if cu.type ==unitAliases.AlliedBatteredArmyGroup or cu.type == unitAliases.GermanBatteredArmyGroup then
            reformBattleGroup(cu)
        end
       -- if cu.type ==unitAliases.AlliedBatteredArmyGroup or cu.type == unitAliases.GermanBatteredArmyGroup then
       --     local question=civ.ui.createDialog()
       --     question.title = "Secondary Options"
       --     question:addOption("Consider consolidating forces.",1)
       --     question:addOption("Consider making an orderly retreat.",2)
       --     if question:show() == 1 then
       --         reformBattleGroup(cu)
       --     else
       --         orderlyRetreat(cu)
       --     end
       -- end
       -- Note: Orderly Retreat superceeded by trainlift
    end
	--g If key "V" - this is the secondary attack
	if keyID == specialNumbers.secondaryAttackKey then
		
		--civ.ui.text(func.splitlines(tostring(keyID)))
		local currentUnit = civ.getActiveUnit()
		if currentUnit ~= nil then
			local currentTileCoordinates = { {currentUnit.location.x, currentUnit.location.y, currentUnit.location.z } }
		
			--g loop over all artilleryUnit Types
			for ___, secondAttackUnit in pairs(secondaryAttackUnitTypes) do
				
				if secondAttackUnit.unitType.id == currentUnit.type.id then
					correctTerrain = 0
					for _, allowedTerrain in pairs(secondAttackUnit.allowedTerrain) do
					    -- p.g. terrain check correction
						if (currentUnit.location.terrainType % 16) == allowedTerrain then
							correctTerrain = 1
						end
					end
					
					local enoughMoney = 1
					if currentUnit.owner.money<overTwoHundred.modifyMunitionCostForDistance(currentUnit,secondAttackUnit.moneyCostOfMunition) then
						enoughMoney = 0
					end
					if airWorkaround then
					    if currentUnit.type.domain==1 and currentUnit.moveSpent >= (currentUnit.type.move -1) then
					    enoughMoney = 0
					    civ.ui.text(func.splitlines(textAliases.airMunitions))
					    end
					end -- end airWorkarround Check
                    -- Payload Check
                    if currentUnit.homeCity == nil and secondAttackUnit.payload then
                        enoughMoney = 0
                        local dialogBox = civ.ui.createDialog()
                        dialogBox.title = "Over the Reich Concepts: Munition Payloads"
                        dialogBox:addText(textAliases.secondaryPayloadUsed)
                        dialogBox:show()
                    -- make sure it can attack at low altitude if there
                    elseif currentUnit.location.z == 1 and secondAttackUnit.highAltNoAttack then
                        enoughMoney = 0
                        civ.ui.text("This unit can't make its secondary attack at high altitude.")
						elseif currentUnit.location.z == 2 and secondAttackUnit.nightAltNoAttack then
                        enoughMoney = 0
                        elseif not checkIfInOperatingRadius(currentUnit) then
                        enoughMoney = 0
                        local operatingRadiusMessage = "This "..currentUnit.type.name.." unit is outside its maximum operating radius.  It will not fire munitions, perform reactive attacks, or even defend itself in combat until it is brought nearer an airbase"
                        if useCarrier[currentUnit.type.id] then
                            operatingRadiusMessage = operatingRadiusMessage.." (or carrier)"
                        end
                        operatingRadiusMessage = operatingRadiusMessage..".  Units can't be ordered into combat missions without the ability to return to base.  A unit's operating radius is its per turn movement multiplied by half its range (rounded down if the range is odd).  This unit has an operating radius of "..tostring(physicalRange(currentUnit.type)).."."
                        text.simple(operatingRadiusMessage,"Over the Reich Concepts: Operating Radius")
                    end
                    local munitionTable = nil
					if correctTerrain == 1 and enoughMoney == 1 then
					    -- p.g. code for extra functionality
                        local munitionVetStatus = false
					    local munitionToCreate = secondAttackUnit.munitionCreated
                        if currentUnit.veteran and not secondAttackUnit.vetOverride then
                            munitionVetStatus = true
                        elseif currentUnit.veteran and civ.isUnitType(secondAttackUnit.vetOverride) then
                            munitionToCreate = secondAttackUnit.vetOverride
                        end
					    local createOnTileObject= currentUnit.location
					    if secondAttackUnit.altMap then
					        createOnTileObject = civ.getTile(createOnTileObject.x,createOnTileObject.y,secondAttackUnit.altMap)
					    end
					    if not (createOnTileObject.defender == currentUnit.owner or createOnTileObject.defender == nil) then
					        if getSafeTile(currentUnit.owner, createOnTileObject) then
					            createOnTileObject = getSafeTile(currentUnit.owner, createOnTileObject)
					        else
					            createOnTileObject = currentUnit.location
					            civ.ui.text(func.splitlines("No place to create munition on other map."))
					        end
					    end
					    local quantityToCreate = 1
					    if secondAttackUnit.quantity and type(secondAttackUnit.quantity) == "function" then
					        quantityToCreate = secondAttackUnit.quantity(currentUnit,munitionToCreate, createOnTileObject)
					    elseif secondAttackUnit.quantity and type(secondAttackUnit.quantity) == "number" then
					        quantityToCreate = secondAttackUnit.quantity
					    end
					    if secondAttackUnit.quantityNight and createOnTileObject.z == 2 then
					        quantityToCreate = secondAttackUnit.quantityNight
					    end
					    if math.random()<= (quantityToCreate-math.floor(quantityToCreate)) then
	                        quantityToCreate = math.ceil(quantityToCreate)
	                    else
	                        quantityToCreate = math.floor(quantityToCreate)
	                    end
					    
					    local createOnTile = {{createOnTileObject.x,createOnTileObject.y,createOnTileObject.z}}
					    if quantityToCreate >=1 then
                                                -- remove air protection from strategic targets on an adjacent square
                                                uncoverTarget(civ.getActiveUnit())
					        munitionTable = civlua.createUnit(munitionToCreate, currentUnit.owner, createOnTile, {randomize=false, veteran=munitionVetStatus, count=quantityToCreate})
                            munitionTable[1]:activate()
                            runDoOnActivateUnit()
					        civ.ui.centerView(createOnTileObject)
					    elseif secondAttackUnit.munitionFailText then
					        civ.ui.text(func.splitlines(secondAttackUnit.munitionFailText))
					    else
					        civ.ui.text(func.splitlines(textAliases.defaultMunitionsFailure))
					    end
						--p.g. end changes
						--g after creation: reduce movement points of artillery unit, but do not go beyond the max movement points of the unit type
						local newSpent = currentUnit.moveSpent + secondAttackUnit.movementCostOfMunition		--*civ.cosmic.roadMultipier
						if newSpent >= currentUnit.type.move then
							--newSpent = currentUnit.type.move
							if airWorkaround and currentUnit.type.domain==1 then
							    newSpent = currentUnit.type.move -1
							end -- end airWorkaround modification
						end
						currentUnit.moveSpent = newSpent
						currentUnit.owner.money = currentUnit.owner.money - overTwoHundred.modifyMunitionCostForDistance(currentUnit,secondAttackUnit.moneyCostOfMunition)
                        doUpkeepWarning(currentUnit.owner)
                        state.mostRecentMunitionUserID = currentUnit.id
                        if secondAttackUnit.payload then
                            currentUnit.homeCity = nil
                        end
						if secondAttackUnit.displayText ~= nil then
							civ.ui.text(func.splitlines(tostring(secondAttackUnit.displayText)))
						end
						-- reaction after creation of munition
						secondaryAttackReactionWrapper(currentUnit,munitionTable,overTwoHundred.doOnUnitKilled())
					end -- end if correct terrain and enough money
				end -- end if secondAttackUnit.unitType.id == currentUnit.type.id
			end -- end for __, secondAttackUnit
		end -- end if currentUnit ~=nil
	end -- end if keyID == 86
	-- p.g. code to remove freighter and create allied tank if 'k' pressed on terrain 0
	-- didn't put this in the below keyID==75 condition, since this will delete the active unit
	if keyID == specialNumbers.primaryAttackKey and civ.getActiveUnit()~=nil and civ.getActiveUnit().type == unitAliases.Convoy then
       convoyKPress(civ.getActiveUnit()) 
        --[[ Old Freighter Code
	    local currentUnit = civ.getActiveUnit()
	        --p.g. terrain check correction
		if currentUnit.type == unitAliases.Freighter and (currentUnit.location.terrainType % 16) and 
		    currentUnit.location.city and canDockFreighter(currentUnit.location.city)  then
		    --tribeAliases.Allies.money = tribeAliases.Allies.money + specialNumbers.freighterBonus  -- No Freighter Bonus anymore, train instead
		    local newTrain = civ.createUnit(unitAliases.FreightTrain,tribeAliases.Allies,currentUnit.location)
		    newTrain.homeCity = nil -- No home city for new train
		    local newTank = civ.createUnit(civ.getUnitType(74),tribeAliases.Allies,currentUnit.location)
		    newTank.homeCity = nil --No home city for new tank.
		    incrementCounter("AlliedScore",specialNumbers.alliedScoreIncrementFreighter)
		    incrementCounter("GermanScore",-specialNumbers.alliedScoreIncrementFreighter)
		    civ.deleteUnit(currentUnit)
		    civ.ui.text(func.splitlines("American freighters reach England, offloading troops and supplies for the coming invasion!"))
		end
        --]]
	end -- end if keyID == 75 and civ.getActiveUnit

	--g If key "K" - check for unit type to create munitions - this is the primary attack
	if keyID == specialNumbers.primaryAttackKey and civ.getActiveUnit() ~= nil then

		--civ.ui.text(func.splitlines(tostring(keyID)))
		local currentUnit = civ.getActiveUnit()
		local currentTileCoordinates = { {currentUnit.location.x, currentUnit.location.y, currentUnit.location.z } }
			
		--g loop over all artilleryUnit Types
		for ___, artilleryUnit in pairs(artilleryUnitTypes) do
			
			if artilleryUnit.unitType.id == currentUnit.type.id then
				correctTerrain = 0
				for _, allowedTerrain in pairs(artilleryUnit.allowedTerrain) do
				    -- p.g. terrain check correction
					if (currentUnit.location.terrainType % 16) == allowedTerrain then
						correctTerrain = 1
					end
				end
				
			    local enoughMoney = 1
			    if currentUnit.owner.money < overTwoHundred.modifyMunitionCostForDistance(currentUnit,artilleryUnit.moneyCostOfMunition) then
				    enoughMoney = 0
			    end
			    if airWorkaround then
					if currentUnit.type.domain==1 and currentUnit.moveSpent >= (currentUnit.type.move -1) then
					    enoughMoney = 0
					    civ.ui.text(func.splitlines(textAliases.airMunitions))
					end
		        end -- end airWorkarround Check
				--Payload Check
                if currentUnit.homeCity == nil and artilleryUnit.payload then
                    enoughMoney = 0
                    local dialogBox = civ.ui.createDialog()
                    dialogBox.title = "Over the Reich Concepts: Munition Payloads"
                    dialogBox:addText(textAliases.primaryPayloadUsed)
                    dialogBox:show()
                -- check if unit can attack at low altitude if it is there
                elseif currentUnit.location.z == 0 and artilleryUnit.lowAltNoAttack then
                    enoughMoney = 0
                    civ.ui.text("This unit can't use its primary attack at low altitude.")
                elseif not checkIfInOperatingRadius(currentUnit) then
                    enoughMoney = 0
                    local operatingRadiusMessage = "This "..currentUnit.type.name.." unit is outside its maximum operating radius.  It will not fire munitions, perform reactive attacks, or even defend itself in combat until it is brought nearer an airbase"
                    if useCarrier[currentUnit.type.id] then
                        operatingRadiusMessage = operatingRadiusMessage.." (or carrier)"
                    end
                    operatingRadiusMessage = operatingRadiusMessage..".  Units can't be ordered into combat missions without the ability to return to base.  A unit's operating radius is its per turn movement multiplied by half its range (rounded down if the range is odd).  This unit has an operating radius of "..tostring(physicalRange(currentUnit.type)).."."
                    text.simple(operatingRadiusMessage,"Over the Reich Concepts: Operating Radius")
                end
			    if correctTerrain == 1 and enoughMoney == 1 then
			        -- p.g. some changes made for extra functionality
                    local munitionVetStatus = false
			        local munitionToCreate = artilleryUnit.munitionCreated
                    if currentUnit.veteran and not artilleryUnit.vetOverride then
                        munitionVetStatus = true
                    elseif currentUnit.veteran and civ.isUnitType(artilleryUnit.vetOverride) then
                        munitionToCreate = artilleryUnit.vetOverride
                    end
					local createOnTileObject= currentUnit.location
					if artilleryUnit.nightMunition and currentUnit.location.z == 2 then
					    munitionToCreate=artilleryUnit.nightMunition
					end
					if artilleryUnit.altMap then
					        createOnTileObject = civ.getTile(createOnTileObject.x,createOnTileObject.y,artilleryUnit.altMap)
					end
					if not (createOnTileObject.defender == currentUnit.owner or createOnTileObject.defender == nil) then
					    if getSafeTile(currentUnit.owner, createOnTileObject) then
					            createOnTileObject = getSafeTile(currentUnit.owner, createOnTileObject)
					    else
					            createOnTileObject = currentUnit.location
					            civ.ui.text(func.splitlines("No place to create munition on other map."))
					    end
					end
					if not (createOnTileObject.defender == currentUnit.owner or createOnTileObject.defender == nil) then
					    if getSafeTile(currentUnit.owner, createOnTileObject) then
					        createOnTileObject = getSafeTile(currentUnit.owner, createOnTileObject)
					    else
					        createOnTileObject = currentUnit.location
					        civ.ui.text(func.splitlines("No place to create munition on other map."))
					    end
					end
					local quantityToCreate = 1
					if artilleryUnit.quantity and type(artilleryUnit.quantity) == "function" then
					    quantityToCreate = artilleryUnit.quantity(currentUnit,munitionToCreate, createOnTileObject)
					elseif artilleryUnit.quantity and type(artilleryUnit.quantity) == "number" then
					    quantityToCreate = artilleryUnit.quantity
					end
					if artilleryUnit.quantityNight and createOnTileObject.z == 2 then
					    quantityToCreate = artilleryUnit.quantityNight
					end
	                if math.random()<= (quantityToCreate-math.floor(quantityToCreate)) then
	                    quantityToCreate = math.ceil(quantityToCreate)
	                else
	                    quantityToCreate = math.floor(quantityToCreate)
	                end					    
					   
					local createOnTile = {{createOnTileObject.x,createOnTileObject.y,createOnTileObject.z}}
                    --print(createOnTileObject.x,createOnTileObject.y,createOnTileObject.z)
                    local munitionTable = nil
					if quantityToCreate >= 1 then
                        if munitionToCreate == unitAliases.Photos then
                            -- have to create photos separately, since they have to be a ground unit, and
                            -- civlua.createUnit won't let ground units be created on water.
                            local newUnit = civ.createUnit(munitionToCreate,currentUnit.owner,createOnTileObject)
                            newUnit.homeCity = nil
                            newUnit:activate()
                            runDoOnActivateUnit()
                        else
                                -- uncover any strategic targets on an adjacent square
                                uncoverTarget(civ.getActiveUnit())
    			            munitionTable = civlua.createUnit(munitionToCreate,
                            currentUnit.owner, 
                            createOnTile,
                            {randomize=false, veteran=munitionVetStatus, count=quantityToCreate})
                            munitionTable[1]:activate()
                            runDoOnActivateUnit()
                        end
    			        civ.ui.centerView(createOnTileObject)
    			    elseif artilleryUnit.munitionFailText then
    			        civ.ui.text(func.splitlines(artilleryUnit.munitionsFailText))
    			    else
    			        civ.ui.text(func.splitlines(textAliases.defaultMunitionsFailure))
    			    end
    			     -- end changes
					--g after creation: reduce movement points of artillery unit, but do not go beyond the max movement points of the unit type
			        local newSpent = currentUnit.moveSpent + artilleryUnit.movementCostOfMunition		--*civ.cosmic.roadMultipier
			        if newSpent >= currentUnit.type.move then
				        --newSpent = currentUnit.type.move
				        if airWorkaround and currentUnit.type.domain==1 then
							    newSpent = currentUnit.type.move -1
					    end -- end airWorkaround modification
			        end
			        currentUnit.moveSpent = newSpent
			        currentUnit.owner.money = currentUnit.owner.money -overTwoHundred.modifyMunitionCostForDistance(currentUnit,artilleryUnit.moneyCostOfMunition) 
                    doUpkeepWarning(currentUnit.owner)
                    state.mostRecentMunitionUserID = currentUnit.id
			        if artilleryUnit.displayText ~= nil then
				        civ.ui.text(func.splitlines(tostring(artilleryUnit.displayText)))
			        end
                    if artilleryUnit.payload then
                        currentUnit.homeCity = nil
                    end
			        -- This is the reaction code
			        primaryAttackReactionWrapper(currentUnit,munitionTable,overTwoHundred.doOnUnitKilled())
		        end -- end if correct terrain and enough money
		    end -- end if artilleryUnit.unitType.id ==currentUnit.type.id
		end -- end for __,artilleryUnit
	end -- end if keyID == 75
	-- radar activation
	if keyID == specialNumbers.primaryAttackKey and civ.getActiveUnit() then
        local activeUnit = civ.getActiveUnit()
        if radarUserDetailsTable[activeUnit.type.id] 
            and radarUserDetailsTable[activeUnit.type.id].keyCode ==specialNumbers.primaryAttackKey 
            and ((not radarUserDetailsTable[activeUnit.type.id].installationOnly) or activeUnit.location.terrainType % 16 == 7)
            then
            if airWorkaround then
			    if activeUnit.type.domain==1 and activeUnit.moveSpent >= (activeUnit.type.move -1) then
			        civ.ui.text(func.splitlines(textAliases.airMunitions))
			        -- don't need to check anything else
			        return
			    end
			end -- end airWorkarround Check
            local enemyDetected = radar.radarSweep(activeUnit,radarRangeFunction,radarDetectionFunction,
                                    radarMarkerType, state.radarRemovalInfo,unitAliases.spotterUnit,
                                    civ.getTile(specialNumbers.radarSafeTile[1],
                                        specialNumbers.radarSafeTile[2],
                                        specialNumbers.radarSafeTile[3]))
            if enemyDetected then
                local radarDialog = civ.ui.createDialog()
                radarDialog.title = radarUserDetailsTable[activeUnit.type.id].radarReportTitle 
                                        or textAliases.defaultRadarReportTitle
                local detectionMessage = radarUserDetailsTable[activeUnit.type.id].radarDetectionMessage
                                        or textAliases.defaultRadarDetected
                radarDialog:addText(func.splitlines(detectionMessage))
                radarDialog:show()
            else
                local radarDialog = civ.ui.createDialog()
                radarDialog.title = radarUserDetailsTable[activeUnit.type.id].radarReportTitle 
                                        or textAliases.defaultRadarReportTitle
                local failureMessage = radarUserDetailsTable[activeUnit.type.id].radarNothingFoundMessage
                                        or textAliases.defaultRadarNothingFound
                radarDialog:addText(func.splitlines(failureMessage))
                radarDialog:show()
            end
            -- apply move cost
            if activeUnit.type.domain == 1 and airWorkaround then
                activeUnit.moveSpent = math.min(activeUnit.moveSpent + radarUserDetailsTable[activeUnit.type.id].moveCost, activeUnit.type.move -1)
            else
                activeUnit.moveSpent = math.min(activeUnit.moveSpent + radarUserDetailsTable[activeUnit.type.id].moveCost, activeUnit.type.move)
            end
            return -- if radar used, no need to check other things in onKeyPress
        end    
    end
    -- temporary code
	--if keyID == specialNumbers.primaryAttackKey and civ.getActiveUnit() then

    --    local activeUnit = civ.getActiveUnit()
    --    if radarUserDetailsTable[activeUnit.type.id] and 
    --        radarUserDetailsTable[activeUnit.type.id].installationOnly and
    --        activeUnit.location.terrainType % 16 == 2 then
    --        local choice = text.menu({"Change to installation.","Leave as Grassland."},"Due to a change, radar can now only detect from installation terrain.  To compensate for making the change mid game, grassland can be changed to installation by radar stations via key press.  If you're not part of a game that was ongoing when this change was made, we've forgotten to remove this option, and you shouldn't use it.")
    --        if choice == 1 then
    --            activeUnit.location.terrainType = 7
    --        end
    --    end
    --end
    -- end temporary code
	if keyID == specialNumbers.secondaryAttackKey and civ.getActiveUnit() then
        local activeUnit = civ.getActiveUnit()
        if radarUserDetailsTable[activeUnit.type.id] 
            and radarUserDetailsTable[activeUnit.type.id].keyCode == specialNumbers.secondaryAttackKey 
            and ((not radarUserDetailsTable[activeUnit.type.id].installationOnly) or activeUnit.location.terrainType % 16 == 7)
            then
            if airWorkaround then
			    if activeUnit.type.domain==1 and activeUnit.moveSpent >= (activeUnit.type.move -1) then
			        civ.ui.text(func.splitlines(textAliases.airMunitions))
			        -- don't need to check anything else
			        return
			    end
			end -- end airWorkarround Check
            local enemyDetected = radar.radarSweep(activeUnit,radarRangeFunction,radarDetectionFunction,
                                    radarMarkerType, state.radarRemovalInfo,unitAliases.spotterUnit,
                                    civ.getTile(specialNumbers.radarSafeTile[1],
                                        specialNumbers.radarSafeTile[2],
                                        specialNumbers.radarSafeTile[3]))
            if enemyDetected then
                local radarDialog = civ.ui.createDialog()
                radarDialog.title = radarUserDetailsTable[activeUnit.type.id].radarReportTitle 
                                        or textAliases.defaultRadarReportTitle
                local detectionMessage = radarUserDetailsTable[activeUnit.type.id].radarDetectionMessage
                                        or textAliases.defaultRadarDetected
                radarDialog:addText(func.splitlines(detectionMessage))
                radarDialog:show()
            else
                local radarDialog = civ.ui.createDialog()
                radarDialog.title = radarUserDetailsTable[activeUnit.type.id].radarReportTitle 
                                        or textAliases.defaultRadarReportTitle
                local failureMessage = radarUserDetailsTable[activeUnit.type.id].radarNothingFoundMessage
                                        or textAliases.defaultRadarNothingFound
                radarDialog:addText(func.splitlines(failureMessage))
                radarDialog:show()
            end
            if activeUnit.type.domain == 1 and airWorkaround then
                activeUnit.moveSpent = math.min(activeUnit.moveSpent + radarUserDetailsTable[activeUnit.type.id].moveCost, activeUnit.type.move -1)
            else
                activeUnit.moveSpent = math.min(activeUnit.moveSpent + radarUserDetailsTable[activeUnit.type.id].moveCost, activeUnit.type.move)
            end
            return -- if radar used, no need to check other things in onKeyPress
        end
    end 
	if keyID == specialNumbers.primaryAttackKey and civ.getActiveUnit() and civ.getActiveUnit().type == unitAliases.Destroyer then -- k destroyer convoy trigger
	    generateFreightersRegion1(civ.getActiveUnit())
	end
	if keyID == specialNumbers.helpKeyID and civ.getActiveUnit() == nil and radar.radarMarkerOnMap(radarMarkerType) then -- if help key (tab) is pressed
	    radar.askToRemoveRadarMarker(radarMarkerType,state.radarRemovalInfo,unitAliases.spotterUnit,
	                                civ.getTile(specialNumbers.radarSafeTile[1],
                                                specialNumbers.radarSafeTile[2],
                                                specialNumbers.radarSafeTile[3]))
	end
end) -- end function(keyID)


------------------------------------------------------------------------------------------------------------------------------------------------
-- `onLoad` is responsible for restoring scenario state from a string. `onSave` is responsible for returning the state as a string.
-- The implementations given here should suffice as a basis for most scenarios.
civ.scen.onLoad(function (buffer)
	state = civlua.unserialize(lualzw.decompress(buffer) or buffer)
	unitAliases.Torpedo.nativeTransport = 0
	unitAliases.damagedB17F.nativeTransport = 1
	unitAliases.damagedB17G.nativeTransport = 1
	unitAliases.P47D40.nativeTransport = 1
	unitAliases.A20.nativeTransport = 1
	unitAliases.B26.nativeTransport = 1
	unitAliases.A26.nativeTransport = 1
	unitAliases.V1.nativeTransport = 0
	unitAliases.V2.nativeTransport = 0
	unitAliases.EgonMayer.nativeTransport = 1
	unitAliases.HermannGraf.nativeTransport = 1
	unitAliases.JosefPriller.nativeTransport = 1
	unitAliases.AdolfGalland.nativeTransport = 1
	unitAliases.hwSchnaufer.nativeTransport = 1
	unitAliases.Experten.nativeTransport = 1
	unitAliases.Ju88C.nativeTransport = 1
	unitAliases.Ju88G.nativeTransport = 1
	unitAliases.He219.nativeTransport = 1
	unitAliases.Flak.nativeTransport = 1 
	unitAliases.RAFAce.nativeTransport = 1 
	unitAliases.USAAFAce.nativeTransport = 1 
	state.radarRemovalInfo = state.radarRemovalInfo or {}
	if radar.radarMarkerOnMap(radarMarkerType) then
	radar.askToRemoveRadarMarker(radarMarkerType,state.radarRemovalInfo, unitAliases.spotterUnit,
	                                    civ.getTile(specialNumbers.radarSafeTile[1],
	                                                 specialNumbers.radarSafeTile[2],
	                                                 specialNumbers.radarSafeTile[3]))
	end
	--resetProductionValues()
    state.logState = state.logState or {}
    log.linkState(state.logState)
    state.textTable = state.textTable or {}
    text.linkState(state.textTable)
    state.newReactionsTable = state.newReactionsTable or {}
    reactionBase.linkState(state.newReactionsTable)
	state.flags = state.flags or {}
	state.counters = state.counters or {}
	state.specialTargetsTable = state.specialTargetsTable or {}
	initializeFlagsAndCounters()
    setFlagFalse("NoUpkeepWarningThisSession")
	state.cHistTable = state.cHistTable or {}
	state.newspaper = state.newspaper or {}
    state.newspaper.allies = state.newspaper.allies or {articleName = "Report", newspaperName = "Allied Reports"}
    state.newspaper.germans = state.newspaper.germans or {articleName="Report", newspaperName = "German Reports"}
    state.reactions = state.reactions or {}
    state.cityDockings = state.cityDockings or {}
    state.cityHasDoneTrainlift = state.cityHasDoneTrainlift or {}
    state.formationTable = {}
    state.formationFlag = false
    state.mapStorageTable = state.mapStorageTable or {}
    state.stormInfoTable = state.stormInfoTable or {}
    state.map1FrontStatisticsTable = state.map1FrontStatisticsTable or {}
    state.map2FrontStatisticsTable = state.map2FrontStatisticsTable or {}
    state.mostRecentMunitionUserID = state.mostRecentMunitionUserID or 0
    state.alliedReinforcementTrack = state.alliedReinforcementTrack or {}
    state.alliedReinforcementsSent = state.alliedReinforcementsSent or 0
end)

civ.scen.onScenarioLoaded(function ()
    --setSubQualities()
    civ.ui.centerView(civ.getTile(407,1,0))
    setSubFlag()
    if civ.getActiveUnit() then
        harbourUnitActivationFunction(civ.getActiveUnit())
    end
    --require("makeCSV")


    justOnce("MakeTargetsVet",function ()
        for unit in civ.iterateUnits() do
            if unit.type.move == 0 then
                unit.veteran = true
            end
        end
    end)
    log.removeAllCombatMarkers()
end)

civ.scen.onSave(function ()
--    return civlua.serialize(state)
	return lualzw.compress(civlua.serialize(state))
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- `onNegotiation` runs not only when diplomatic negotiations occur between tribes, but also when opening the Foreign Minister dialog. Return `true` to allow the two tribes to negotiate, `false` to disallow.
-- no negotiations between the fleets!
civ.scen.onNegotiation(function (talker, listener)
	return false
end)


-----------------------------------------------------------------------------------------------------------
--Attempt at moving the deletion per turn outside of the other function

local currentUnit = civ.getActiveUnit()

local cannotLandCityItalyRussia = {
[unitAliases.Me109G6.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Fw200.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Me109G14.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Me109K4.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Fw190A5.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Fw190A8.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Fw190D9.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Ta152.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Me110.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Me410.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Ju88C.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Ju88G.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.He219.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.He162.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Me163.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Me262.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.EgonMayer.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.HermannGraf.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.hwSchnaufer.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Experten.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.AdolfGalland.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.JosefPriller.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Ju87G.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Fw190F.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Do335.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Do217.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.He277.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Arado234.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Go229.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.SpitfireIX	.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.SpitfireXII.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.SpitfireXIV.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.HurricaneIV.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Typhoon.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Tempest.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Meteor.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Beaufighter.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.MosquitoII.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.MosquitoXIII.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.P47D11.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.P47D25.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.P47D40.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.P38L.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.P38H.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.P38J.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.P51B.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.P51D.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.P80.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Stirling.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Halifax.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Pathfinder.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.A20.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.B26.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.A26.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.B17F.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.B24J.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.B17G.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.RAFAce.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.USAAFAce.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.He111.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Sunderland.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.Ju188.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.MossiePR.id] = { forbiddenTerrain={0, 15, -128, -114} },
[unitAliases.RedTails.id] = { forbiddenTerrain={0, -128, -114} },
[unitAliases.Yak3.id] = { forbiddenTerrain={0, -128, -114} },
[unitAliases.Il2.id] = { forbiddenTerrain={0, -128, -114} },
[unitAliases.MedBombers.id] = { forbiddenTerrain={0, -128, -114} }, 
--[unitAliases.Destroyer.id] = { forbiddenTerrain={9} },
--[unitAliases.LightCruiser.id] = { forbiddenTerrain={9} },
--[unitAliases.HeavyCruiser.id] = { forbiddenTerrain={9} },
--[unitAliases.Battleship.id] = { forbiddenTerrain={9} },
--[unitAliases.UBoat.id] = { forbiddenTerrain={9} },

--Index unit types by their id number
}


function doThisBetweenTurns(turn)
   for unit in civ.iterateUnits() do
       for unitTypeId, data in pairs(cannotLandCityItalyRussia) do
           if unit.type.id == unitTypeId then
               --print("Got here #1")
               for _, cannotLand in pairs(data.forbiddenTerrain) do
                   --print("Got here #2")
                   -- p.g. terrain check correction
                   if (unit.location.terrainType % 16) == cannotLand then
                       --print("Got here #3")
                       civ.deleteUnit(unit)
                   end
               end
           end
       end
    end -- end the for loop over all units in the game
end -- end function
--[==[
-- Special targets have been removed from the scenario
-- Special Targets (special Events, specialEvents, specialTargets) historic targets historictargets historical targets historicaltargets
-- sTNum, i.e. special target number
--
sTNum={}
-- First Turn is the first possible turn for the event to start
-- Last Turn is the last possible turn for the event to start
sTNum["OperationGomorrahFirstTurn"]=10000--25
sTNum["OperationGomorrahLastTurn"]=10000--55
sTNum["OperationGomorrahWindow"]=8
sTNum["OperationChastiseFirstTurn"]=10000--20--20
sTNum["OperationChastiseLastTurn"]=10000--50--50
sTNum["OperationChastiseWindow"]=8
sTNum["SchweinfurtRegensburgFirstTurn"]=10000--30--2
sTNum["SchweinfurtRegensburgLastTurn"]=10000--60--2
sTNum["SchweinfurtRegensburgWindow"]=12--2
sTNum["OperationHydraFirstTurn"]=10000--30--2
sTNum["OperationHydraLastTurn"]=10000--60--2
sTNum["OperationHydraWindow"]=8--2
sTNum["BattleOfBerlinFirstTurn"]=10000--150--2-- 50 before event removed
sTNum["BattleOfBerlinLastTurn"]=10000--200--2 -- 100 before event removed
sTNum["BattleOfBerlinWindow"]=specialNumbers.battleOfBerlinLength --2
sTNum["OperationJerichoMinAlliedScore"]=10000--800--9
sTNum["OperationJerichoChanceEachTurn"]=0.1--.5
sTNum["OperationJerichoWindow"]=1--1
sTNum["OperationCarthageFirstTurn"]=10000--100--2
sTNum["OperationCarthageLastTurn"]=10000--125--2
sTNum["OperationCarthageWindow"]=7--2
sTNum["BattleOfBerlinDelaysChance"]=1/3--1/3
sTNum["BattleOfBerlinStrikeChance"]=1/10--1/10 -- chance of a 'worker's strike'event when the target in Berlin is destroyed
sTNum["BattleOfBerlinStrikeDisorderChance"]=.4--0.4 -- If there is a worker's strike, this is the chance that a particular city will be put to disorder
sTNum["BattleOfBerlinSpeerDeathChance"]=1/25--1/25
sTNum["OperationCarthageDisasterChance"]=0.5--0.5 -- chance that operation carthage is a disaster if target killed
-- sTLoc i.e. special target location
sTLoc={}
sTLoc["OperationGomorrahLocation"]=civ.getTile(317,57,2)
sTLoc["OperationChastiseLocation1"]=civ.getTile(285,79,2)
sTLoc["OperationChastiseLocation2"]=civ.getTile(287,77,2)
sTLoc["OperationChastiseLocation3"]=civ.getTile(294,82,2)
sTLoc["OperationChastiseMoveCrewsTo"]=civ.getTile(290,80,0)
sTLoc["SchweinfurtLocation"]=civ.getTile(315,101,1)
sTLoc["RegensburgLocation"]=civ.getTile(344,108,1)
sTLoc["OperationHydraLocation"]=civ.getTile(375,61,2)
sTLoc["BattleOfBerlinLocation"]=civ.getTile(363,71,2)
sTLoc["OperationJerichoLocation"]=civ.getTile(200,90,0)
sTLoc["OperationCarthageLocation"]=civ.getTile(352,36,2)

local function getEventNameFromLocation(tile)
    for locationName,location in pairs(sTLoc) do
        if tile == location then
            local name = locationName
            name = string.gsub(name,"Location","")
            name = string.gsub(name,"%d","")
            return name
        end
    end
    print("Special Target killed at",tile," with no corresponding target event in sTLoc")
    return nil
end

local function alliedHistoricTargetsStartOfTurn(turn)
    -- If not a "standard game", don't do the historical targets 
    if not flag("StandardGame") then
        return
    end
    -- decrement all the counters for active special target operations
    local function decrementCounter(eventName)
        if flag(eventName.."Active") then
           incrementCounter(eventName.."TimeRemaining",-1)
        end
    end
    decrementCounter("OperationGomorrah")
    decrementCounter("OperationChastise")
    decrementCounter("SchweinfurtRegensburg")
    decrementCounter("OperationHydra")
    decrementCounter("BattleOfBerlin")
    decrementCounter("OperationJericho")
    decrementCounter("OperationCarthage")
    local function startEvent(eventName)
        if flag(eventName.."Active") or flag(eventName.."Complete") then
            return false
        elseif eventName== "OperationJericho" then
            if counterValue("AlliedScore")>=sTNum["OperationJerichoMinAlliedScore"] and math.random() <= sTNum["OperationJerichoChanceEachTurn"] and cityAliases.Paris.owner == tribeAliases.Germans and cityAliases.Calais.owner==tribeAliases.Germans and cityAliases.Lille.owner==tribeAliases.Germans then
                setFlagTrue(eventName.."Active")
                setCounter(eventName.."TimeRemaining",sTNum[eventName.."Window"])
                return true
            else
                return false
            end
        elseif eventName == "OperationChastise" and (cityAliases.Dortmund.owner == tribeAliases.Allies or cityAliases.Frankfurt.owner == tribeAliases.Allies or cityAliases.Hannover.owner == tribeAliases.Allies) then
            return false
        elseif turn < sTNum[eventName.."FirstTurn"] or turn > sTNum[eventName.."LastTurn"] then
            return false
        elseif math.random(turn,sTNum[eventName.."LastTurn"])~=sTNum[eventName.."LastTurn"] then
            return false
        else
            setFlagTrue(eventName.."Active")
            setCounter(eventName.."TimeRemaining",sTNum[eventName.."Window"])
            return true
        end
    end
    startEvent("OperationGomorrah")
    startEvent("OperationChastise")
    startEvent("SchweinfurtRegensburg")
    startEvent("OperationHydra")
    startEvent("BattleOfBerlin")
    startEvent("OperationJericho")
    startEvent("OperationCarthage")
    local function failEvent(eventName)
        if flag(eventName.."Active") and counterValue(eventName.."TimeRemaining") == 0 then
        setFlagTrue(eventName.."DoFailureAllies")
        setFlagTrue(eventName.."DoFailureGermans")
        setFlagTrue(eventName.."Complete")
        setFlagFalse(eventName.."Active")
        end
    end
    failEvent("OperationGomorrah")
    -- operation Chastise doesn't use failEvent system
    if flag("OperationChastiseActive") and counterValue("OperationChastiseTimeRemaining") == 0 then
        setFlagTrue("OperationChastiseDoAftermathAllies")
        setFlagTrue("OperationChastiseDoAftermathGermans") 
        setFlagTrue("OperationChastiseComplete")
        setFlagFalse("OperationChastiseActive")
    end
    -- schweinfurt regensburg doesn't use fail event system, due to dual targets
    if flag("SchweinfurtRegensburgActive") 
        and counterValue("SchweinfurtRegensburgTimeRemaining")==0 then
        setFlagFalse("SchweinfurtRegensburgActive")
        setFlagTrue("SchweinfurtRegensburgComplete")
        if not flag("SchweinfurtVictory") then
            setFlagTrue("SchweinfurtDoFailureAllies")
            setFlagTrue("SchweinfurtDoFailureGermans")
        end
        if not flag("RegensburgVictory") then
            setFlagTrue("RegensburgDoFailureAllies")
            setFlagTrue("RegensburgDoFailureGermans")
        end
    end
    failEvent("OperationHydra")
    -- Battle of Berllin doesn't use fail event system, since it isn't an event that 'fails'
    if flag("BattleOfBerlinActive") and counterValue("BattleOfBerlinTimeRemaining")==0 then
        setFlagFalse("BattleOfBerlinActive")
        setFlagTrue("BattleOfBerlinComplete")
    end
    failEvent("OperationJericho")
    failEvent("OperationCarthage")

end
--]==]
local function simpleDialog(title,text)
    local newDialog = civ.ui.createDialog()
    newDialog.title = title
    newDialog:addText(text)
    newDialog:show()
end
--[==[
local function placeGermanTargetIfNecessary(eventName,tile)
    if not flag(eventName.."Discovered") then
        if tile.defender == tribeAliases.Allies then
            for unit in tile.units do
                moveToAdjacent(unit)
            end
        end
        local newTarget = civ.createUnit(unitAliases.SpecialTarget,tribeAliases.Germans,tile)
        newTarget.homeCity = nil
        newTarget.veteran = true
    end
end

local function removeTargetIfNecessary(eventName,tile)
    if not flag(eventName.."Discovered") then
        for unit in tile.units do
            if unit.type == unitAliases.SpecialTarget then
                civ.deleteUnit(unit)
            end
        end

    end
end

local function removeTarget(tile)
    for unit in tile.units do
        if unit.type == unitAliases.SpecialTarget then
            civ.deleteUnit(unit)
        end
    end
end
local function displayGermanDiscoveryMessage(eventName,message,newspaperTitle)
    -- displays the discovery message for the Germans if appropriate
    if flag(eventName.."Discovered") then
        justOnce(eventName.."DiscoveredJO", 
            function() simpleDialog(textAliases.germanSpecialTargetRevealedBoxTitle, message)
            --newspaper.addToNewspaper(state.newspaper.germans, newspaperTitle,message)
            text.addToArchive(tribeAliases.Germans,message,newspaperTitle,newspaperTitle)
            end)

    end
end

local function alliedHistoricTargetsAfterAlliedProduction()
    -- If not a "standard game", don't do the historical targets 
    if not flag("StandardGame") then
        return
    end
    local function reminderText(eventName,eventTitle)
        local reminderText = nil
        if counterValue(eventName.."TimeRemaining") == 1 then
            reminderText = eventTitle..[[ is still ongoing and must be completed this turn!  Press 2 at any time to see the original order.]]
        else
            reminderText = eventTitle..[[ is still ongoing and must be completed on or before turn ]]..tostring(civ.getTurn()+counterValue(eventName.."TimeRemaining")-1)..[[.  Press 2 at any time to see the original order.]]
        end
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,reminderText)    
    end
    
    if flag("OperationGomorrahActive") and counterValue("OperationGomorrahTimeRemaining")==sTNum["OperationGomorrahWindow"] then
    -- first time Gomorrah is active
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.gomorrahText1)    
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.gomorrahText2)    
        local finishText = [[  This mission must be completed on or before turn ]]..tostring(civ.getTurn()+sTNum["OperationGomorrahWindow"]-1)..[[.]]
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.gomorrahText3..finishText)    
        --newspaper.addToNewspaper(state.newspaper.allies,textAliases.gomorrahText1,textAliases.gomorrahText2..textAliases.gomorrahText3..finishText)
        text.addToArchive(tribeAliases.Allies,textAliases.gomorrahText2..textAliases.gomorrahText3..finishText,textAliases.gomorrahText1,textAliases.gomorrahText1)
        placeGermanTargetIfNecessary("OperationGomorrah",sTLoc["OperationGomorrahLocation"])
        -- create Halifaxes
        for i=1,specialNumbers.gomorrahHalifaxes do
            local newHalifax=civ.createUnit(unitAliases.Halifax,tribeAliases.Allies,civ.getTile(181,57,2))
            newHalifax.homeCity=cityAliases.London
            newHalifax.veteran = true
        end
    elseif flag("OperationGomorrahActive") then
    -- subsequent turns of Gomorrah
        reminderText("OperationGomorrah","Operation Gomorrah")
        placeGermanTargetIfNecessary("OperationGomorrah",sTLoc["OperationGomorrahLocation"])
    elseif flag("OperationGomorrahDoFailureAllies") then
        removeTarget(sTLoc["OperationGomorrahLocation"])
        simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.gomorrahFailsAlliesText1)
        --newspaper.addToNewspaper(state.newspaper.allies,textAliases.gomorrahText1.." Results",textAliases.gomorrahFailsAlliesText1)
        text.addToArchive(tribeAliases.Allies,textAliases.gomorrahFailsAlliesText1,textAliases.gomorrahText1.." Results",textAliases.gomorrahText1.." Results")
        setFlagFalse("OperationGomorrahDoFailureAllies")
    end
    if flag("OperationChastiseActive") and counterValue("OperationChastiseTimeRemaining")==sTNum["OperationChastiseWindow"] then
        -- first time Chastise is active
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.chastiseText1)    
        local finishText = [[  This mission must be completed on or before turn ]]..tostring(civ.getTurn()+sTNum["OperationChastiseWindow"]-1)..[[.]]
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.chastiseText2..finishText)    
        --newspaper.addToNewspaper(state.newspaper.allies,textAliases.chastiseText1,textAliases.chastiseText2..finishText)
        text.addToArchive(tribeAliases.Allies,textAliases.chastiseText2..finishText,textAliases.chastiseText1,textAliases.chastiseText1)
        placeGermanTargetIfNecessary("OperationChastise",sTLoc["OperationChastiseLocation1"])
        placeGermanTargetIfNecessary("OperationChastise",sTLoc["OperationChastiseLocation2"])
        placeGermanTargetIfNecessary("OperationChastise",sTLoc["OperationChastiseLocation3"])
        for i=1,specialNumbers.chastiseLancasters do
           local newLancaster = civ.createUnit(unitAliases.Lancaster,tribeAliases.Allies,civ.getTile(197,63,2))
            newLancaster.homeCity=cityAliases.London
            newLancaster.veteran=true
        end
    elseif flag("OperationChastiseActive") then
        reminderText("OperationChastise","Operation Chastise")
        placeGermanTargetIfNecessary("OperationChastise",sTLoc["OperationChastiseLocation1"])
        placeGermanTargetIfNecessary("OperationChastise",sTLoc["OperationChastiseLocation2"])
        placeGermanTargetIfNecessary("OperationChastise",sTLoc["OperationChastiseLocation3"])
    elseif flag("OperationChastiseDoAftermathAllies") then
        setFlagFalse("OperationChastiseDoAftermathAllies")
        removeTarget(sTLoc["OperationChastiseLocation1"])
        removeTarget(sTLoc["OperationChastiseLocation2"])
        removeTarget(sTLoc["OperationChastiseLocation3"])
        if counterValue("OperationChastiseDamsDestroyed") == 0 then
            local resultText = textAliases.chastiseZeroDamsAlliesText
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,resultText)
            --newspaper.addToNewspaper(state.newspaper.allies,textAliases.chastiseText1.." Results",resultText)
            text.addToArchive(tribeAliases.Allies,resultText,textAliases.chastiseText1.." Results",textAliases.chastiseText1.." Results")
        elseif counterValue("OperationChastiseDamsDestroyed") == 1 then
            local resultText = textAliases.chastiseOneDamAlliesText
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,resultText)
            --newspaper.addToNewspaper(state.newspaper.allies,textAliases.chastiseText1.." Results",resultText)
            text.addToArchive(tribeAliases.Allies,resultText,textAliases.chastiseText1.." Results",textAliases.chastiseText1.." Results")
        elseif counterValue("OperationChastiseDamsDestroyed") == 2 then
            local resultText = textAliases.chastiseTwoDamsAlliesText
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,resultText)
            --newspaper.addToNewspaper(state.newspaper.allies,textAliases.chastiseText1.." Results",resultText)
            text.addToArchive(tribeAliases.Allies,resultText,textAliases.chastiseText1.." Results",textAliases.chastiseText1.." Results")
        elseif counterValue("OperationChastiseDamsDestroyed") == 3 then
            local resultText = textAliases.chastiseThreeDamsAlliesText
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,resultText)
            --newspaper.addToNewspaper(state.newspaper.allies,textAliases.chastiseText1.." Results",resultText)
            text.addToArchive(tribeAliases.Allies,resultText,textAliases.chastiseText1.." Results",textAliases.chastiseText1.." Results")
        end
    end
    if flag("SchweinfurtRegensburgActive") and counterValue("SchweinfurtRegensburgTimeRemaining") == sTNum["SchweinfurtRegensburgWindow"] then
       -- first time schweinfurt regensburg is active 
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.schweinfurtText1)    
        local finishText = [[  This mission must be completed on or before turn ]]..tostring(civ.getTurn()+sTNum["SchweinfurtRegensburgWindow"]-1)..[[.]]
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.schweinfurtText2..finishText)    
        --newspaper.addToNewspaper(state.newspaper.allies,textAliases.schweinfurtText1,textAliases.schweinfurtText2..finishText)
        text.addToArchive(tribeAliases.Allies,textAliases.schweinfurtText2..finishText,textAliases.schweinfurtText1,textAliases.schweinfurtText1)
        placeGermanTargetIfNecessary("Schweinfurt",sTLoc["SchweinfurtLocation"])
        placeGermanTargetIfNecessary("Regensburg",sTLoc["RegensburgLocation"])
        for i=1,specialNumbers.schweinfurtB17F do
            local newB17F = civ.createUnit(unitAliases.B17F,tribeAliases.Allies,civ.getTile(197,63,0))
            newB17F.homeCity=cityAliases.London
            newB17F.veteran=false
        end
    elseif flag("SchweinfurtRegensburgActive") then
        reminderText("SchweinfurtRegensburg", "Action against Schweinfurt and Regensburg")
        placeGermanTargetIfNecessary("Schweinfurt",sTLoc["SchweinfurtLocation"])
        placeGermanTargetIfNecessary("Regensburg",sTLoc["RegensburgLocation"])

    end
    if flag("RegensburgDoFailureAllies") then
        simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.regensburgFailureTextAllies)
        --newspaper.addToNewspaper(state.newspaper.allies,"Regensburg Attack Results",textAliases.regensburgFailureTextAllies)
        text.addToArchive(tribeAliases.Allies,textAliases.regensburgFailureTextAllies,"Regensburg Attack Results","Regensburg Attack Results")
        setFlagFalse("RegensburgDoFailureAllies")
        removeTarget(sTLoc["RegensburgLocation"])
    end
    if flag("SchweinfurtDoFailureAllies") then
        simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.schweinfurtFailureTextAllies)
        --newspaper.addToNewspaper(state.newspaper.allies,"Schweinfurt Attack Results",textAliases.schweinfurtFailureTextAllies)
        text.addToArchive(tribeAliases.Allies,textAliases.schweinfurtFailureTextAllies,"Schweinfurt Attack Results","Schweinfurt Attack Results")
        setFlagFalse("SchweinfurtDoFailureAllies")
        removeTarget(sTLoc["SchweinfurtLocation"])
    end
    if flag("OperationHydraActive") and counterValue("OperationHydraTimeRemaining") == sTNum["OperationHydraWindow"] then
        -- First turn of operation Hydra
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.hydraText1)
        local finishText = [[  This mission must be completed on or before turn ]]..tostring(civ.getTurn()+sTNum["OperationHydraWindow"]-1)..[[.]]
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.hydraText2..finishText)
        --newspaper.addToNewspaper(state.newspaper.allies,textAliases.hydraText1,textAliases.hydraText2..finishText)
        text.addToArchive(tribeAliases.Allies,textAliases.hydraText2..finishText,textAliases.hydraText1,textAliases.hydraText1)
        for i=1,specialNumbers.hydraLancasters do
            local newLancaster = civ.createUnit(unitAliases.Lancaster,tribeAliases.Allies,civ.getTile(197,63,2))
            newLancaster.homeCity=cityAliases.London
            newLancaster.veteran=false
        end
        for i=1,specialNumbers.hydraHalifaxes do
            local newHalifax=civ.createUnit(unitAliases.Halifax,tribeAliases.Allies,civ.getTile(197,63,2))
            newHalifax.homeCity = cityAliases.London
            newHalifax.veteran = false
        end
        placeGermanTargetIfNecessary("OperationHydra",sTLoc["OperationHydraLocation"])
    elseif flag("OperationHydraActive") then
        placeGermanTargetIfNecessary("OperationHydra",sTLoc["OperationHydraLocation"])
        reminderText("OperationHydra", "Operation Hydra")
    elseif flag("OperationHydraDoFailureAllies") then
        setFlagFalse("OperationHydraDoFailureAllies")
        simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.hydraFailureTextAllies)
        --newspaper.addToNewspaper(state.newspaper.allies,"Operation Hydra Report",textAliases.hydraFailureTextAllies)  
        text.addToArchive(tribeAliases.Allies,textAliases.hydraFailureTextAllies,"Operation Hydra Report","Operation Hydra Report")  
    end
    if flag("BattleOfBerlinActive") and counterValue("BattleOfBerlinTimeRemaining") == sTNum["BattleOfBerlinWindow"] then
        -- first turn of Battle of Berlin
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.berlinText1)
        local finishText = [[  This mission will continue until turn ]]..tostring(civ.getTurn()+sTNum["BattleOfBerlinWindow"]-1)..[[.]]
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.berlinText2..finishText)
        --newspaper.addToNewspaper(state.newspaper.allies,textAliases.berlinText1,textAliases.berlinText2..finishText)
        text.addToArchive(tribeAliases.Allies,textAliases.berlinText2..finishText,textAliases.berlinText1,textAliases.berlinText1)
        placeGermanTargetIfNecessary("BattleOfBerlin",sTLoc["BattleOfBerlinLocation"])
    elseif flag("BattleOfBerlinActive") then
        local reminderText = [[The Battle of Berlin is still ongoing and will continue until turn ]]..tostring(civ.getTurn()+counterValue("BattleOfBerlinTimeRemaining")-1)..[[.  Press 2 at any time to see the original order.]]
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,reminderText)    
        placeGermanTargetIfNecessary("BattleOfBerlin",sTLoc["BattleOfBerlinLocation"])
    end
    if flag("OperationJerichoActive") and counterValue("OperationJerichoTimeRemaining") == sTNum["OperationJerichoWindow"] then
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.jerichoText1)
        local finishText = [[  This mission must be completed this turn.]]
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.jerichoText2..finishText)
        --newspaper.addToNewspaper(state.newspaper.allies,textAliases.jerichoText1,textAliases.jerichoText2..finishText)
        text.addToArchive(tribeAliases.Allies,textAliases.jerichoText2..finishText,textAliases.jerichoText1,textAliases.jerichoText1)
        placeGermanTargetIfNecessary("OperationJericho",sTLoc["OperationJerichoLocation"])
        for i=1,specialNumbers.jerichoTyphoons do
            local newTyphoon = civ.createUnit(unitAliases.Typhoon,tribeAliases.Allies,civ.getTile(197,63,0)) 
            newTyphoon.homeCity = cityAliases.London
            newTyphoon.veteran = false
        end
    elseif flag("OperationJerichoActive") then
        civ.ui.text("Operation Jericho was meant to be a one turn only event, so something has gone wrong.")
    elseif flag("OperationJerichoDoFailureAllies") then
        setFlagFalse("OperationJerichoDoFailureAllies")
        simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.jerichoFailureTextAllies)
        --newspaper.addToNewspaper(state.newspaper.allies,"Operation Jericho Report",textAliases.jerichoFailureTextAllies)
        text.addToArchive(tribeAliases.Allies,textAliases.jerichoFailureTextAllies,"Operation Jericho Report","Operation Jericho Report")
    end
    if flag("OperationCarthageActive") and counterValue("OperationCarthageTimeRemaining") == sTNum["OperationCarthageWindow"] then
    -- first turn of operation carthage
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.carthageText1)
        local finishText = [[  This mission must be completed on or before turn ]]..tostring(civ.getTurn()+sTNum["OperationCarthageWindow"]-1)..[[.]]
        simpleDialog(textAliases.alliedSpecialTargetBoxTitle,textAliases.carthageText2..finishText)
        --newspaper.addToNewspaper(state.newspaper.allies,textAliases.carthageText1,textAliases.carthageText2..finishText)
        text.addToArchive(tribeAliases.Allies,textAliases.carthageText2..finishText,textAliases.carthageText1,textAliases.carthageText1)
        placeGermanTargetIfNecessary("OperationCarthage",sTLoc["OperationCarthageLocation"])
        for i=1,specialNumbers.carthageLancasters do
            local newLancaster = civ.createUnit(unitAliases.Lancaster,tribeAliases.Allies,civ.getTile(197,63,2))
            newLancaster.homeCity=cityAliases.London
            newLancaster.veteran=false
        end
    elseif flag("OperationCarthageActive") then
        placeGermanTargetIfNecessary("OperationCarthage",sTLoc["OperationCarthageLocation"])
        reminderText("OperationCarthage", "Operation Carthage")
    elseif flag("OperationCarthageDoFailureAllies") then
        setFlagFalse("OperationCarthageDoFailureAllies")
        simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.carthageFailureTextAllies)
        --newspaper.addToNewspaper(state.newspaper.allies,"Operation Carthage Report",textAliases.carthageFailureTextAllies)
        text.addToArchive(tribeAliases.Allies,textAliases.carthageFailureTextAllies,"Operation Carthage Report","Operation Carthage Report")
    end
end

local function alliedHistoricTargetsAfterGermanProduction()
    -- If not a "standard game", don't do the historical targets 
    if not flag("StandardGame") then
        return
    end 
    removeTargetIfNecessary("OperationGomorrah",sTLoc["OperationGomorrahLocation"])
    removeTargetIfNecessary("OperationChastise",sTLoc["OperationChastiseLocation1"])
    removeTargetIfNecessary("OperationChastise",sTLoc["OperationChastiseLocation2"])
    removeTargetIfNecessary("OperationChastise",sTLoc["OperationChastiseLocation3"])
    removeTargetIfNecessary("Schweinfurt",sTLoc["SchweinfurtLocation"])
    removeTargetIfNecessary("Regensburg",sTLoc["RegensburgLocation"])
    removeTargetIfNecessary("OperationHydra",sTLoc["OperationHydraLocation"])
    removeTargetIfNecessary("OperationJericho",sTLoc["OperationJerichoLocation"])
    removeTargetIfNecessary("OperationCarthage",sTLoc["OperationCarthageLocation"])
    displayGermanDiscoveryMessage("OperationGomorrah",textAliases.gomorrahDiscoveredText,"Operation Gomorrah")
    displayGermanDiscoveryMessage("OperationChastise",textAliases.chastiseDiscoveredText,"Operation Chastise")
    displayGermanDiscoveryMessage("Schweinfurt",textAliases.schweinfurtDiscovered,"Schweinfurt Attack")
    displayGermanDiscoveryMessage("Regensburg",textAliases.regensburgDiscovered,"Regensburg Attack")
    displayGermanDiscoveryMessage("OperationHydra",textAliases.hydraDiscoveredText,"Operation Hydra")
    displayGermanDiscoveryMessage("BattleOfBerlin",textAliases.berlinDiscovered,"Battle Of Berlin")
    displayGermanDiscoveryMessage("OperationCarthage",textAliases.carthageDiscovered,"Operation Carthage")
    
    
    if flag("OperationGomorrahDoVictoryGermans") then
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.gomorrahSucceedsGermansText1)
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.gomorrahSucceedsGermansText2)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Gomorrah Results",textAliases.gomorrahSucceedsGermansText1.."  "..textAliases.gomorrahSucceedsGermansText2)
        text.addToArchive(tribeAliases.Germans,textAliases.gomorrahSucceedsGermansText1.."  "..textAliases.gomorrahSucceedsGermansText2,"Operation Gomorrah Results","Operation Gomorrah Results")
        setFlagFalse("OperationGomorrahDoVictoryGermans")
    end     
    if flag("OperationGomorrahDoFailureGermans") then
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.gomorrahFailsGermansText1)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Gomorrah Results",textAliases.gomorrahFailsGermansText1)
        text.addToArchive(tribeAliases.Germans,textAliases.gomorrahFailsGermansText1,"Operation Gomorrah Results","Operation Gomorrah Results")
        tribeAliases.Germans.money = tribeAliases.Germans.money+specialNumbers.gomorrahFailsMoney
        setFlagFalse("OperationGomorrahDoFailureGermans")
    end
    if flag("OperationChastiseFirstDamDestroyedShowGermanMessage") then
        setFlagFalse("OperationChastiseFirstDamDestroyedShowGermanMessage")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.firstDamDestroyedGermanMessage)
        -- Will teleport all german construction crews to the dams
        -- first make sure no allied unit is on the destination
        if sTLoc["OperationChastiseMoveCrewsTo"].defender == tribeAliases.Allies then
            for unit in sTLoc["OperationChastiseMoveCrewsTo"].units do
                moveToAdjacent(unit)
            end
        end
        -- now find all the german construction crews and teleport them
        for unit in civ.iterateUnits() do
            if unit.type == unitAliases.constructionTeam and unit.owner==tribeAliases.Germans then
                civ.teleportUnit(unit,sTLoc["OperationChastiseMoveCrewsTo"])
            end
        end
    end
    if flag("OperationChastiseSecondDamDestroyedShowGermanMessage") then
        setFlagFalse("OperationChastiseSecondDamDestroyedShowGermanMessage")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.secondDamDestroyedGermanMessage)
        incrementCounter("ChastiseTrainsToDivert",specialNumbers.secondDamTrainsDiverted)
    end
    if flag("OperationChastiseThirdDamDestroyedShowGermanMessage") then
        setFlagFalse("OperationChastiseThirdDamDestroyedShowGermanMessage")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.thirdDamDestroyedGermanMessage)
        incrementCounter("ChastiseTrainsToDivert",specialNumbers.thirdDamTrainsDiverted)
        setFlagTrue("OperationChastiseDoAftermathAllies")
        setFlagTrue("OperationChastiseDoAftermathGermans") 
    end
    if flag("OperationChastiseDoAftermathGermans") then
        setFlagFalse("OperationChastiseDoAftermathGermans")
        if counterValue("OperationChastiseDamsDestroyed") == 0 then
            tribeAliases.Germans.money = tribeAliases.Germans.money+specialNumbers.chastiseZeroDamsMoney 
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.chastiseZeroDamsGermansText)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Chastise Results",textAliases.chastiseZeroDamsGermansText)
        text.addToArchive(tribeAliases.Germans,textAliases.chastiseZeroDamsGermansText,"Operation Chastise Results","Operation Chastise Results")
        elseif counterValue("OperationChastiseDamsDestroyed") == 1 then

        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.chastiseOneDamGermansText)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Chastise Results",textAliases.chastiseOneDamGermansText)
        text.addToArchive(tribeAliases.Germans,textAliases.chastiseOneDamGermansText,"Operation Chastise Results","Operation Chastise Results")
        elseif counterValue("OperationChastiseDamsDestroyed") == 2 then
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.chastiseTwoDamsGermansText)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Chastise Results",textAliases.chastiseTwoDamsGermansText)
        text.addToArchive(tribeAliases.Germans,textAliases.chastiseTwoDamsGermansText,"Operation Chastise Results","Operation Chastise Results")
        elseif counterValue("OperationChastiseDamsDestroyed") == 3 then
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.chastiseThreeDamsGermansText)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Chastise Results",textAliases.chastiseThreeDamsGermansText)
        text.addToArchive(tribeAliases.Germans,textAliases.chastiseThreeDamsGermansText,"Operation Chastise Results","Operation Chastise Results")
        end
    end
    if flag("SchweinfurtDoVictoryGermans") then
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.schweinfurtVictoryTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Schweinfurt Attack Results",textAliases.schweinfurtVictoryTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.schweinfurtVictoryTextGermans,"Schweinfurt Attack Results","Schweinfurt Attack Results")
        setFlagFalse("SchweinfurtDoVictoryGermans")
    end
    if flag("SchweinfurtDoFailureGermans") then
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.schweinfurtFailureTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Schweinfurt Attack Results",textAliases.schweinfurtFailureTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.schweinfurtFailureTextGermans,"Schweinfurt Attack Results","Schweinfurt Attack Results")
        setFlagFalse("SchweinfurtDoFailureGermans")
        for i=1,1 do
            local newFW = civ.createUnit(unitAliases.HermannGraf,tribeAliases.Germans,civ.getTile(338,118,0))
            newFW.homeCity=nil
            newFW.veteran=true
        end
        tribeAliases.Germans.money = tribeAliases.Germans.money+specialNumbers.schweinfurtFailureMoney
    end
    if flag("RegensburgDoVictoryGermans") then
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.regensburgVictoryTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Regensburg Attack Results",textAliases.regensburgVictoryTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.regensburgVictoryTextGermans,"Regensburg Attack Results","Regensburg Attack Results")
        setFlagFalse("RegensburgDoVictoryGermans")
    end
    if flag("RegensburgDoFailureGermans") then
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.regensburgFailureTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Regensburg Attack Results",textAliases.regensburgFailureTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.regensburgFailureTextGermans,"Regensburg Attack Results","Regensburg Attack Results")
        setFlagFalse("RegensburgDoFailureGermans")
        for i=1,3 do
            local newME = civ.createUnit(unitAliases.Me109K4, tribeAliases.Germans,civ.getTile(338,118,0))
            newME.homeCity = nil
            newME.veteran = true
        end
        tribeAliases.Germans.money = tribeAliases.Germans.money+specialNumbers.regensburgFailureMoney
    end
    if flag("OperationHydraDoVictoryGermans") then
        setFlagFalse("OperationHydraDoVictoryGermans")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.hydraVictoryTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Hydra Results",textAliases.hydraVictoryTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.hydraVictoryTextGermans,"Operation Hydra Results","Operation Hydra Results")
    end
    if flag("OperationHydraDoFailureGermans") then
        setFlagFalse("OperationHydraDoFailureGermans")
        tribeAliases.Germans:giveTech(tribeAliases.Germans.researching)
        local possibleV2Places = {}
        possibleV2Places[1]=civ.getTile(194,82,0)
        possibleV2Places[2]=civ.getTile(194,78,0)
        possibleV2Places[3]=civ.getTile(203,77,0)
        possibleV2Places[4]=civ.getTile(214,76,0)
        possibleV2Places[5]=civ.getTile(225,77,0)
        possibleV2Places[6]=civ.getTile(238,64,0)
        possibleV2Places[7]=civ.getTile(244,58,0)
        local V2LauncherTile = possibleV2Places[math.random(1,#possibleV2Places)]
        local V2TileString = "("..tostring(V2LauncherTile.x)..","..tostring(V2LauncherTile.y)..",0)"
        for i=1,1 do
            local newV2Launch = civ.createUnit(unitAliases.V2Launch,tribeAliases.Germans,V2LauncherTile)
            newV2Launch.homeCity=nil
            newV2Launch.veteran=false
        end
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,text.substitute(textAliases.hydraFailureTextGermans,{V2TileString}))
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Hydra Results",text.substitute(textAliases.hydraFailureTextGermans,{V2TileString}))
        text.addToArchive(tribeAliases.Germans,text.substitute(textAliases.hydraFailureTextGermans,{V2TileString},"Operation Hydra Results","Operation Hydra Results"))
        removeTarget(sTLoc["OperationHydraLocation"])
    end
    if flag("BattleOfBerlinDoDelaysGermany") then
        setFlagFalse("BattleOfBerlinDoDelaysGermany")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.berlinDelaysTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Battle Of Berlin Results",textAliases.berlinDelaysTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.berlinDelaysTextGermans,"Battle Of Berlin Results","Battle Of Berlin Results")
    end
    if flag("BattleOfBerlinDoWorkersStrikeGermany") then
        setFlagFalse("BattleOfBerlinDoWorkersStrikeGermany")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.workersStrikeTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Battle Of Berlin Results",textAliases.workersStrikeTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.workersStrikeTextGermans,"Battle Of Berlin Results","Battle Of Berlin Results")
    end
    if flag("BattleOfBerlinDoAlbertSpeerDeathGermany") then
        setFlagFalse("BattleOfBerlinDoAlbertSpeerDeathGermany")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.albertSpeerDeathTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Battle Of Berlin Results",textAliases.albertSpeerDeathTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.albertSpeerDeathTextGermans,"Battle Of Berlin Results","Battle Of Berlin Results")
        tribeAliases.Germans:giveTech(techAliases.DeathOfAlbertSpeer)
    end
    if flag("OperationJerichoDoVictoryGermans") then
        setFlagFalse("OperationJerichoDoVictoryGermans")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.jerichoVictoryTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Jericho Results",textAliases.jerichoVictoryTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.jerichoVictoryTextGermans,"Operation Jericho Results","Operation Jericho Results")
    
    end
    if flag("OperationJerichoDoFailureGermans") then
        setFlagFalse("OperationJerichoDoFailureGermans")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.jerichoFailureTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Jericho Results",textAliases.jerichoFailureTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.jerichoFailureTextGermans,"Operation Jericho Results","Operation Jericho Results")
        local jerichoRewardAirfields = {}
        jerichoRewardAirfields[1]=civ.getTile(217,81,0)
        jerichoRewardAirfields[2]=civ.getTile(195,87,0)
        jerichoRewardAirfields[3]=civ.getTile(178,106,0)
        jerichoRewardAirfields[4]=civ.getTile(165,101,0)
        jerichoRewardAirfields[5]=civ.getTile(142,92,0)
        jerichoRewardAirfields[6]=civ.getTile(97,97,0)
        jerichoRewardAirfields[7]=civ.getTile(238,76,0)
        jerichoRewardAirfields[8]=civ.getTile(247,71,0)
        jerichoValidAirfields = {}
        for __,tile in pairs(jerichoRewardAirfields) do
            if tile.city and tile.city.owner == tribeAliases.Germans then
                table.insert(jerichoValidAirfields,tile)
            end
        end
        -- give freight trains to germany as a reward for surviving operation jericho
        for i=1,6 do
            local trainTile = jerichoValidAirfields[math.random(1,#jerichoValidAirfields)]
            local newTrain = civ.createUnit(unitAliases.FreightTrain,tribeAliases.Germans,trainTile)
            newTrain.homeCity=nil
            newTrain.veteran=false
        end
    end
    if flag("OperationCarthageDoVictoryGermans") then
        setFlagFalse("OperationCarthageDoVictoryGermans")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.carthageVictoryTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Carthage Results",textAliases.carthageVictoryTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.carthageVictoryTextGermans,"Operation Carthage Results","Operation Carthage Results")
        
    end
    if flag("OperationCarthageDoFailureGermans") then
        setFlagFalse("OperationCarthageDoFailureGermans")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.carthageFailureTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Carthage Results",textAliases.carthageFailureTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.carthageFailureTextGermans,"Operation Carthage Results","Operation Carthage Results")
        local carthageRewardAirfields = {}
        carthageRewardAirfields[1]=civ.getTile(328,22,0)
        carthageRewardAirfields[2]=civ.getTile(326,32,0)
        carthageRewardAirfields[3]=civ.getTile(324,50,0)
        carthageRewardAirfields[4]=civ.getTile(317,59,0)
        carthageRewardAirfields[5]=civ.getTile(332,56,0)
        carthageValidAirfields = {}
        for __,tile in pairs(carthageRewardAirfields) do
            if tile.city and tile.city.owner == tribeAliases.Germans then
                table.insert(carthageValidAirfields,tile)
            end
        end
        -- give freight trains to germany as a reward for surviving operation carthage
        for i=1,6 do
            local trainTile = carthageValidAirfields[math.random(1,#carthageValidAirfields)]
            local newTrain = civ.createUnit(unitAliases.FreightTrain,tribeAliases.Germans,trainTile)
            newTrain.homeCity=nil
            newTrain.veteran=false
        end

    end
    if flag("OperationCarthageDoDisasterGermans") then
        setFlagFalse("OperationCarthageDoDisasterGermans")
        simpleDialog(textAliases.specialTargetResultsBoxTitleGermans,textAliases.carthageDisasterTextGermans)
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Carthage Results",textAliases.carthageDisasterTextGermans)
        text.addToArchive(tribeAliases.Germans,textAliases.carthageDisasterTextGermans,"Operation Carthage Results","Operation Carthage Results")
    end

             

end

local function alliedHistoricTargetsUnitKilled(winner,loser)
    -- If not a "standard game", don't do the historical targets 
    if not flag("StandardGame") then
        return
    end
    if winner.type == unitAliases.SpecialTarget and winner.owner == tribeAliases.Germans then
        local eventName = getEventNameFromLocation(winner.location)
        setFlagTrue(eventName.."Discovered")
    end
    if loser.type == unitAliases.SpecialTarget and loser.owner == tribeAliases.Germans then
        local eventName = getEventNameFromLocation(loser.location)
        if eventName == "OperationGomorrah" then
            --setFlagFalse(eventName.."Discovered")
            setFlagTrue(eventName.."DoVictoryGermans")
            setFlagTrue(eventName.."Complete")
            setFlagFalse(eventName.."Active")
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.gomorrahSucceedsAlliesText1)
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.gomorrahSucceedsAlliesText2)
            --newspaper.addToNewspaper(state.newspaper.allies,"Operation Gomorrah Report",textAliases.gomorrahSucceedsAlliesText1.."  "..textAliases.gomorrahSucceedsAlliesText2)
            text.addToArchive(tribeAliases.Allies,textAliases.gomorrahSucceedsAlliesText1.."  "..textAliases.gomorrahSucceedsAlliesText2,"Operation Gomorrah Report","Operation Gomorrah Report")
            incrementCounter("AlliedScore",specialNumbers.alliedScoreIncrementOperationGomorrah)
            local urbanSquares = {{315,57}, {316,58}, {317,57}, {318,58}, {319,57}, {320,58}, {319,59}, {316,62}, {317,61}, {318,62}}
            for __,coords in pairs(urbanSquares) do
                civ.getTile(coords[1],coords[2],0).terrainType = 13
                civ.getTile(coords[1],coords[2],1).terrainType = 11
                civ.getTile(coords[1],coords[2],2).terrainType = 11
            end
            local indSquares = {{318,56}, {316,56}, {320,58}}
            for __,coords in pairs(indSquares) do
                civ.getTile(coords[1],coords[2],0).terrainType = 14
                civ.getTile(coords[1],coords[2],1).terrainType = 14
                civ.getTile(coords[1],coords[2],2).terrainType = 14
            end
            local refSquares = {{314,60}, {315,61}, {319,57}}
            for __,coords in pairs(refSquares) do
                civ.getTile(coords[1],coords[2],0).terrainType = 12
                civ.getTile(coords[1],coords[2],1).terrainType = 12
                civ.getTile(coords[1],coords[2],2).terrainType = 14
            end
            for unit in civ.iterateUnits() do
                local uType = unit.type
                if unit.homeCity==cityAliases.Hamburg and
                    (uType==unitAliases.Industry1 or uType==unitAliases.Industry2
                    or uType==unitAliases.Industry3 or uType==unitAliases.Refinery1 
                    or uType==unitAliases.Refinery2 or uType==unitAliases.Refinery3 
                    or uType==unitAliases.Urban1 or uType==unitAliases.Urban2 
                    or uType==unitAliases.Urban3) then
                    civ.deleteUnit(unit)
                end
            end
            cityAliases.Hamburg:removeImprovement(civ.getImprovement(4))--Civ I
            cityAliases.Hamburg:removeImprovement(civ.getImprovement(5))--Ref I
            cityAliases.Hamburg:removeImprovement(civ.getImprovement(10))--Ref II
            cityAliases.Hamburg:removeImprovement(civ.getImprovement(11))--Civ II
            cityAliases.Hamburg:removeImprovement(civ.getImprovement(14))--Civ III
            cityAliases.Hamburg:removeImprovement(civ.getImprovement(15))--Ind I
            cityAliases.Hamburg:removeImprovement(civ.getImprovement(16))--Ind II
            cityAliases.Hamburg:removeImprovement(civ.getImprovement(22))--Ref III
            cityAliases.Hamburg:removeImprovement(civ.getImprovement(29))--Ind III
        elseif eventName == "OperationChastise" then
            if counterValue("OperationChastiseDamsDestroyed") == 0 then
                setFlagTrue("OperationChastiseFirstDamDestroyedShowGermanMessage")
                simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.firstDamDestroyedAlliedMessage)
                incrementCounter("OperationChastiseDamsDestroyed",1) 
            elseif counterValue("OperationChastiseDamsDestroyed") == 1 then
                setFlagTrue("OperationChastiseSecondDamDestroyedShowGermanMessage")
                simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.secondDamDestroyedAlliedMessage)
                incrementCounter("OperationChastiseDamsDestroyed",1) 
            elseif counterValue("OperationChastiseDamsDestroyed") == 2 then
                setFlagTrue("OperationChastiseThirdDamDestroyedShowGermanMessage")
                simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.thirdDamDestroyedAlliedMessage)
                setFlagFalse("OperationChastiseActive")
                setFlagTrue("OperationChastiseComplete")
                incrementCounter("OperationChastiseDamsDestroyed",1) 
            end
        elseif eventName == "Schweinfurt" then
            setFlagTrue(eventName.."DoVictoryGermans")
            setFlagTrue(eventName.."Victory")
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.schweinfurtVictoryTextAllies)
            --newspaper.addToNewspaper(state.newspaper.allies,"Schweinfurt Attack Report",textAliases.schweinfurtVictoryTextAllies)
            text.addToArchive(tribeAliases.Allies,textAliases.schweinfurtVictoryTextAllies,"Schweinfurt Attack Report","Schweinfurt Attack Report")
            if flag("RegensburgVictory") then
                setFlagTrue("SchweinfurtRegensburgComplete")
                setFlagFalse("SchweinfurtRegensburgActive")
            end 
            if civ.hasTech(tribeAliases.Germans,techAliases.IndustryI) then
                -- true third entry means tech for which this is a prereq
                -- are also taken
                civ.takeTech(tribeAliases.Germans,techAliases.IndustryI,true)
            end
        elseif eventName == "Regensburg" then
            setFlagTrue(eventName.."DoVictoryGermans")
            setFlagTrue(eventName.."Victory")
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.regensburgVictoryTextAllies)
            --newspaper.addToNewspaper(state.newspaper.allies,"Regensburg Attack Report",textAliases.regensburgVictoryTextAllies)
            text.addToArchive(tribeAliases.Allies,textAliases.regensburgVictoryTextAllies,"Regensburg Attack Report","Regensburg Attack Report")
            if flag("SchweinfurtVictory") then
                setFlagTrue("SchweinfurtRegensburgComplete")
                setFlagFalse("SchweinfurtRegensburgActive")
            end
            if civ.hasTech(tribeAliases.Germans, techAliases.EscortFightersIII) then
                civ.takeTech(tribeAliases.Germans, techAliases.EscortFightersIII)
            elseif civ.hasTech(tribeAliases.Germans, techAliases.EscortFightersII) then
                civ.takeTech(tribeAliases.Germans, techAliases.EscortFightersII)
            elseif civ.hasTech(tribeAliases.Germans, techAliases.InterceptorsIII) then
                civ.takeTech(tribeAliases.Germans, techAliases.InterceptorsIII)
            end
        elseif eventName == "OperationHydra" then
            setFlagTrue("OperationHydraComplete")
            setFlagFalse("OperationHydraActive")
            setFlagTrue("OperationHydraDoVictoryGermans")
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.hydraVictoryTextAllies)
            --newspaper.addToNewspaper(state.newspaper.allies,"Operation Hydra Report",textAliases.hydraVictoryTextAllies)
            text.addToArchive(tribeAliases.Allies,textAliases.hydraVictoryTextAllies,"Operation Hydra Report","Operation Hydra Report")
            tribeAliases.Germans.researching = techAliases.Delays
            tribeAliases.Germans.researchProgress = 0
        elseif eventName == "BattleOfBerlin" then
            local newTarget = civ.createUnit(unitAliases.SpecialTarget,tribeAliases.Germans,sTLoc["BattleOfBerlinLocation"])
            newTarget.homeCity = nil
            newTarget.veteran = true
            local resultRoll = math.random()
            if resultRoll <= sTNum["BattleOfBerlinDelaysChance"] then
                setFlagTrue("BattleOfBerlinDoDelaysGermany")
                tribeAliases.Germans.researching = techAliases.Delays
                tribeAliases.Germans.researchProgress = 0
                simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.berlinDelaysTextAllies)
                --newspaper.addToNewspaper(state.newspaper.allies,"Battle of Berlin Report",textAliases.berlinDelaysTextAllies)
                text.addToArchive(tribeAliases.Allies,textAliases.berlinDelaysTextAllies,"Battle of Berlin Report","Battle of Berlin Report")

            elseif resultRoll <=sTNum["BattleOfBerlinStrikeChance"]+ sTNum["BattleOfBerlinDelaysChance"] then
                setFlagTrue("BattleOfBerlinDoWorkersStrikeGermany")
                for city in civ.iterateCities() do
                    if city.owner == tribeAliases.Germans and isGermanCity(city) then
                        if math.random()<= sTNum["BattleOfBerlinStrikeChance"] then
                            -- set city to disorder
                            city.attributes = city.attributes | 1
                        end
                    end
                end
                simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.workersStrikeTextAllies)
                --newspaper.addToNewspaper(state.newspaper.allies,"Battle of Berlin Report",textAliases.workersStrikeTextAllies)
                text.addToArchive(tribeAliases.Allies,textAliases.workersStrikeTextAllies,"Battle of Berlin Report","Battle of Berlin Report")

            elseif resultRoll <=sTNum["BattleOfBerlinSpeerDeathChance"]+ sTNum["BattleOfBerlinStrikeChance"]+ sTNum["BattleOfBerlinDelaysChance"] then
                -- Speer dies
                justOnce("SpeerDeadJO", function()
                    setFlagTrue("BattleOfBerlinDoAlbertSpeerDeathGermany")
                    simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.albertSpeerDeathTextAllies) 
                    --newspaper.addToNewspaper(state.newspaper.allies,"Battle of Berlin Report",textAliases.albertSpeerDeathTextAllies)
                    text.addToArchive(tribeAliases.Allies,textAliases.albertSpeerDeathTextAllies,"Battle of Berlin Report","Battle of Berlin Report")
                    -- The tech is given on the German turn
                    end) 
            end
        elseif eventName == "OperationJericho" then 
            setFlagTrue("OperationJerichoDoVictoryGermans")
            setFlagTrue(eventName.."Complete")
            setFlagFalse(eventName.."Active")
            simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.jerichoVictoryTextAllies)
            --newspaper.addToNewspaper(state.newspaper.allies,"Operation Jericho Report",textAliases.jerichoVictoryTextAllies)
            text.addToArchive(tribeAliases.Allies,textAliases.jerichoVictoryTextAllies,"Operation Jericho Report","Operation Jericho Report")
            -- now find the nearby railyards and perform the strategic bombing code on them
            for unit in civ.iterateUnits() do
                if unit.type == unitAliases.Railyard and unit.owner == tribeAliases.Germans and (unit.homeCity == cityAliases.Paris or unit.homeCity == cityAliases.Lille or unit.homeCity == cityAliases.Calais or unit.homeCity == cityAliases.Rouen) then
                    --insert strategic bombing code here
                    local loser = unit
                    --[[ by Knighttime, first written in the unit killed section ]]
                    if civ.getTile(loser.x, loser.y, loser.z) ~= nil then
                    	local tileId = getTileId(loser.location)
                    	if tileLookup[tileId] ~= nil then		-- Check that an entry for this location exists in the table
                    		-- Verification:
                    		if loser.type.id ~= improvementUnitTerrainLinks[tileLookup[tileId].improvementId].unitTypeId then
                    			-- This will happen whenever a *non-event-created* unit is killed on a tile that *can* hold an event-created unit
                    			-- It doesn't necessarily indicate a problem with the Lua events
                    			print("    Unit type killed = " .. loser.type.id .. ", event unit type for " .. loser.x .. "," .. loser.y .. "," .. loser.z .. " = " .. improvementUnitTerrainLinks[tileLookup[tileId].improvementId].unitTypeId)
                    		elseif loser.homeCity.id ~= tileLookup[tileId].cityId then
                    			-- This shouldn't happen.  If the unit is the type we expect to be created here by events,
                    			-- its home city should match what we would have built here
                    			print("ERROR: city mismatch found, unit city = " .. loser.homeCity.id .. ", tile city = " .. tileLookup[tileId].cityId)
                    		else
                    			-- A. Destroy a city improvement:
                    			local improvementToRemove = civ.getImprovement(tileLookup[tileId].improvementId)
                    			local cityToRemoveImprovementFrom = civ.getCity(tileLookup[tileId].cityId)
                    			civ.removeImprovement(cityToRemoveImprovementFrom, improvementToRemove)
                    			print("Removed " .. improvementToRemove.name .. " improvement from " .. cityToRemoveImprovementFrom.name)
                    			
                    			-- B. Change the terrain type on one or more tiles, on one or more maps:
                    			changeAllTerrain(tileLookup[tileId].improvementId, "destroy", tileLookup[tileId].allLocations)
                    			
                    		end
                    	else
                    		--print("    Detected unit killed, but no \"tileLookup\" entry found for " .. loser.x .. "," .. loser.y .. "," .. loser.z)
                    	end
                    end
                    civ.deleteUnit(loser)
                end
            end
        elseif eventName == "OperationCarthage" then
            -- check if carthage is a victory or a disaster
            setFlagTrue(eventName.."Complete")
            setFlagFalse(eventName.."Active")
            if math.random() <= sTNum["OperationCarthageDisasterChance"] then
                -- Operation Carthage disaster stuff
                setFlagTrue("OperationCarthageDoDisasterGermans")
                simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.carthageDisasterTextAllies)
                --newspaper.addToNewspaper(state.newspaper.allies,"Operation Carthage Report",textAliases.carthageDisasterTextAllies)
                text.addToArchive(tribeAliases.Allies,textAliases.carthageDisasterTextAllies,"Operation Carthage Report","Operation Carthage Report")
                tribeAliases.Allies.researching = techAliases.Delays
                tribeAliases.Allies.researchProgress = 0
            else
                -- Operation Carthage not a disaster
                setFlagTrue("OperationCarthageDoVictoryGermans")
                simpleDialog(textAliases.specialTargetResultsBoxTitleAllies,textAliases.carthageVictoryTextAllies)
                --newspaper.addToNewspaper(state.newspaper.allies,"Operation Carthage Report",textAliases.carthageVictoryTextAllies)
                text.addToArchive(tribeAliases.Allies,textAliases.carthageVictoryTextAllies,"Operation Carthage Report","Operation Carthage Report")


            end
                -- Results for both cases of operation carthage
            for unit in civ.iterateUnits() do
                if unit.type == unitAliases.Railyard and unit.owner == tribeAliases.Germans and (unit.homeCity == cityAliases.Aaarhus or unit.homeCity == cityAliases.Kiel or unit.homeCity == cityAliases.Hamburg or unit.homeCity == cityAliases.Lubeck) then
                    --insert strategic bombing code here
                    local loser = unit
                    --[[ by Knighttime, first written in the unit killed section ]]
                    if civ.getTile(loser.x, loser.y, loser.z) ~= nil then
                    	local tileId = getTileId(loser.location)
                    	if tileLookup[tileId] ~= nil then		-- Check that an entry for this location exists in the table
                    		-- Verification:
                    		if loser.type.id ~= improvementUnitTerrainLinks[tileLookup[tileId].improvementId].unitTypeId then
                    			-- This will happen whenever a *non-event-created* unit is killed on a tile that *can* hold an event-created unit
                    			-- It doesn't necessarily indicate a problem with the Lua events
                    			print("    Unit type killed = " .. loser.type.id .. ", event unit type for " .. loser.x .. "," .. loser.y .. "," .. loser.z .. " = " .. improvementUnitTerrainLinks[tileLookup[tileId].improvementId].unitTypeId)
                    		elseif loser.homeCity.id ~= tileLookup[tileId].cityId then
                    			-- This shouldn't happen.  If the unit is the type we expect to be created here by events,
                    			-- its home city should match what we would have built here
                    			print("ERROR: city mismatch found, unit city = " .. loser.homeCity.id .. ", tile city = " .. tileLookup[tileId].cityId)
                    		else
                    			-- A. Destroy a city improvement:
                    			local improvementToRemove = civ.getImprovement(tileLookup[tileId].improvementId)
                    			local cityToRemoveImprovementFrom = civ.getCity(tileLookup[tileId].cityId)
                    			civ.removeImprovement(cityToRemoveImprovementFrom, improvementToRemove)
                    			print("Removed " .. improvementToRemove.name .. " improvement from " .. cityToRemoveImprovementFrom.name)
                    			
                    			-- B. Change the terrain type on one or more tiles, on one or more maps:
                    			changeAllTerrain(tileLookup[tileId].improvementId, "destroy", tileLookup[tileId].allLocations)
                    			
                    		end
                    	else
                    		--print("    Detected unit killed, but no \"tileLookup\" entry found for " .. loser.x .. "," .. loser.y .. "," .. loser.z)
                    	end
                    end
                    civ.deleteUnit(loser)
                end
            end
        end
    end


end
--]==]
	
-- Checks to see if City III (23) or Airbase (17) is missing from the
-- city and replaces it if necessary.  If the city has City II (9) then
-- it is a 'city' and not an airfield, so City III is replaced.
local function replaceSoldCityBuildings()
    local cityIII = civ.getImprovement(23)
    local airbase = civ.getImprovement(17)
    local cityII = civ.getImprovement(9)
    for city in civ.iterateCities() do
        if city.location == civ.getTile(406,74,0) then
            -- Russian Front City
            city:addImprovement(civ.getImprovement(3))
        elseif city.location == civ.getTile(345,145,0) then
            -- Italian Front City
            city:addImprovement(civ.getImprovement(18))
        elseif not(city:hasImprovement(cityIII) or city:hasImprovement(airbase)) then
            if city:hasImprovement(cityII) then
                city:addImprovement(cityIII)
            else
                city:addImprovement(airbase)
            end
        end
    end
end
console.replaceSoldCityBuildings = replaceSoldCityBuildings



------------------------------------------------------------------------------------------------------------------------------------------------
-- The `onTurn` function runs its argument every turn, with the turn number passed as `turn`.
-- THIS IS NOT USED FOR TEXT DUE TO THE MULTIPLAYER NATURE OF THE SCENARIO!!!
civ.scen.onTurn(function (turn)
    
    state.reactions = {}
    state.cityHasDoneTrainlift={}
    setFlagFalse("ConvoyZone1Calculated")
    setFlagTrue("AfterProdTribe0NotDone")
    setFlagTrue("AfterProdTribe1NotDone")
    setFlagTrue("AfterProdTribe2NotDone")
    setFlagTrue("AfterProdTribe3NotDone")
    setFlagTrue("AfterProdTribe4NotDone")
    setFlagTrue("AfterProdTribe5NotDone")
    setFlagTrue("AfterProdTribe6NotDone")
    setFlagTrue("AfterProdTribe7NotDone")
    setFlagFalse("FrenchOccupationCalculated")
    incrementCounter("RocketPointDelay",-1)
    if counterValue("RocketPointDelay") == 0 then
        text.displayNextOpportunity(tribeAliases.Allies,textAliases.rocketPenaltyExpired,"Operational Latitude Restored", "Operational Latitude Restored")
    end

    --resetProductionValues()
    doThisBetweenTurns(turn) 
    alliedConvoyBetweenTurns(turn)
    -- airfields can't have more than 10 food in box, so they can't grow
    for city in civ.iterateCities() do
        if city:hasImprovement(civ.getImprovement(specialNumbers.newAirfieldImprovementId)) then
            city.food = math.min(city.food,10)
        end
    end
    for unit in civ.iterateUnits() do
		for _, typeToBeDeleted in pairs(unitTypesToBeDeletedEachTurn) do
			if unit.type.id==typeToBeDeleted then
				civ.deleteUnit(unit)
			end
		end
        -- clear the flag to tell if a convoy has moved.  This way, convoys will recover even while under way,
        -- meaning that they have a better chance to escape
        if unit.type == unitAliases.Convoy then
            gen.clearMoved(unit)
        end
	end
    if tribeAliases.Allies:hasTech(civ.getTech(76)) then
        tile = civ.getTile(405, 75, 0)
    	tile.terrainType = 2
    end
	
	

	for city in civ.iterateCities() do
	    if city.location.z == 2 and civ.getTile(city.location.x,city.location.y,0).city == nil and civ.hasImprovement(city,civ.getImprovement(specialNumbers.newAirfieldImprovementId)) then
            
            civ.ui.text(city.name.." deleted from night map")
            civ.ui.text(tostring(civ.getTile(city.location.x,city.location.y,0).city))
	        civ.deleteCity(city)
	    end
	    -- Code to remove day airfield if no corresponding night airbase
	    if city.location.z == 0 and civ.getTile(city.location.x,city.location.y,2).city == nil and civ.hasImprovement(city,civ.getImprovement(specialNumbers.newAirfieldImprovementId)) then
            civ.ui.text(city.name.." deleted from day map")
            civ.ui.text(tostring(civ.getTile(city.location.x,city.location.y,2).city))
	        civ.deleteCity(city)
	    end
	end--]]
    --alliedHistoricTargetsStartOfTurn(turn)
    -- schweinfurt critical industry
    for unit in civ.iterateUnits() do
        if unit.owner == tribeAliases.Germans and unit.type.domain == 1 and
            unit.location.city and (not gen.isMoved(unit)) and
            overTwoHundred.germanCriticalIndustryActive(cityAliases.Schweinfurt) then
            unit.damage = math.max(0,unit.damage-specialNumbers.aircraftRecoveryBonus)
        end
    end
	
	
	
end)  --g end of onTurn function

-- urban defense value

local function setUrbanDefenseValue()
    local activeTribe = civ.getCurrentTribe()
    local urbanDefense = specialNumbers.defaultUrbanDefenseValue
    -- advanced Radar I
    if civ.hasTech(activeTribe,civ.getTech(17)) then
        urbanDefense = urbanDefense - specialNumbers.AdvancedRadarIUrbanDefenseDrop
    end
    if civ.hasTech(activeTribe,civ.getTech(19)) then
        urbanDefense = urbanDefense -specialNumbers.AdvancedRadarIIUrbanDefenseDrop
    end
    unitAliases.Urban1.defense = urbanDefense 
    unitAliases.Urban2.defense = urbanDefense
    unitAliases.Urban3.defense = urbanDefense
end


reinforcementCityOwned = function(unitType,tribe,destinations,initialMessageText)
    local destinationCity = nil
    for index, tileTable in ipairs(destinations) do
        local tile = civ.getTile(tileTable[1],tileTable[2],tileTable[3])
        if tile.city and tile.city.owner == tribe then
            destinationCity = tile.city
            break
        elseif not tile.city then
            civ.ui.text("Error in the events file.  "..unitType.name.." reinforcements are supposed to be in cities only.")
        end
    end
    if destinationCity then
        local message = civ.ui.createDialog()
        message.title = "Reinforcements"
        local messageText = initialMessageText.."  It has assembled in "..destinationCity.name..".  We must control at least one of "
        local citiesInList = #destinations
        for index, tileTable in ipairs(destinations) do
            local tile = civ.getTile(tileTable[1],tileTable[2],tileTable[3])
            if tile.city and index==citiesInList then
                messageText = messageText.."or "..tile.city.name.." in order to receive additional "..unitType.name.." reinforcements."
            elseif tile.city then
                messageText = messageText..tile.city.name..", "
            elseif not tile.city then
                civ.ui.text("Error in the events file.  "..unitType.name.." reinforcements are supposed to be in cities only.")
            end
        end
        message:addText(messageText)
        message:show()
        text.addToArchive(tribe,messageText,"Reinforcements","Reinforcements")
        return true
    else
        local message = civ.ui.createDialog()
        message.title = "Reinforcements Not Assembled!"
        local messageText = "We have not assembled a new "..unitType.name.." because we don't control any assembly cities.  We must control at least one of "
        local citiesInList = #destinations
        for index, tileTable in ipairs(destinations) do
            local tile = civ.getTile(tileTable[1],tileTable[2],tileTable[3])
            if tile.city and index==citiesInList then
                messageText = messageText.."or "..tile.city.name.." in order to receive additional "..unitType.name.." reinforcements."
            elseif tile.city then
                messageText = messageText..tile.city.name..", "
            elseif not tile.city then
                civ.ui.text("Error in the events file.  "..unitType.name.." reinforcements are supposed to be in cities only.")
            end
        end
        message:addText(messageText)
        message:show()
        text.addToArchive(tribe,messageText,"Reinforcements Not Assembled","Reinforcements Not Assembled")
        return false
    end
end

-- chooses an unoccupied tile in the Atlantic at random, in a box south of Ireland, west of Brest, north of Spain, on which to place a uBoat
function overTwoHundred.selectAtlanticTile()-->tile
    local xCoord = math.random(0,82)
    local yCoord = math.random(53,132)
    if xCoord%2 ~= yCoord%2 then
        yCoord = yCoord-1
    end
    local returnTile = civ.getTile(xCoord,yCoord,0)
    if returnTile.defender then
        -- tile is occupied
        return overTwoHundred.selectAtlanticTile()
    else
        return returnTile
    end
end

function overTwoHundred.countGermanSubs() --> integer
    local count = 0
    for unit in civ.iterateUnits() do
        if unit.type == unitAliases.UBoat and unit.owner == tribeAliases.Germans then
            count = count+1
        end
    end
    return count
end

-- these units are counted for the purposes of determining the number of
-- free fighters Germany will get
overTwoHundred.regensburgFighters = {}

overTwoHundred.regensburgFighters[unitAliases.Me109G6.id]				=true
overTwoHundred.regensburgFighters[unitAliases.Me109G14.id]		=true	
overTwoHundred.regensburgFighters[unitAliases.Me109K4.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Fw190A5.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Fw190A8.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Fw190D9.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Ta152.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Me110.id]				=true
overTwoHundred.regensburgFighters[unitAliases.Me410.id]				=true
overTwoHundred.regensburgFighters[unitAliases.Ju88C.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Ju88G.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.He219.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.He162.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Me163.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Me262.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Ju87G.id]				=false
overTwoHundred.regensburgFighters[unitAliases.Fw190F.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Do335.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Do217.id]				=false
overTwoHundred.regensburgFighters[unitAliases.He277.id]				=false
overTwoHundred.regensburgFighters[unitAliases.Arado234.id]			=false
overTwoHundred.regensburgFighters[unitAliases.Go229.id]				=false
overTwoHundred.regensburgFighters[unitAliases.SpitfireIX.id]			=false
overTwoHundred.regensburgFighters[unitAliases.SpitfireXII.id]			=false
overTwoHundred.regensburgFighters[unitAliases.SpitfireXIV.id]			=false
overTwoHundred.regensburgFighters[unitAliases.HurricaneIV.id]		=true	
overTwoHundred.regensburgFighters[unitAliases.Typhoon.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Tempest.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Meteor.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Beaufighter.id]		=true	
overTwoHundred.regensburgFighters[unitAliases.MosquitoII.id]		=true	
overTwoHundred.regensburgFighters[unitAliases.MosquitoXIII.id]	=true	
overTwoHundred.regensburgFighters[unitAliases.P47D11.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.P47D25.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.P47D40.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.P38H.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.P38J.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.P38L.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.P51B.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.P51D.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.P80.id]				=true	
overTwoHundred.regensburgFighters[unitAliases.Stirling.id]			=false
overTwoHundred.regensburgFighters[unitAliases.Halifax.id]				=false
overTwoHundred.regensburgFighters[unitAliases.Lancaster.id]			=false
overTwoHundred.regensburgFighters[unitAliases.Pathfinder.id]			=false
overTwoHundred.regensburgFighters[unitAliases.A20.id]					=false
overTwoHundred.regensburgFighters[unitAliases.B26.id]					=false
overTwoHundred.regensburgFighters[unitAliases.A26.id]					=false
overTwoHundred.regensburgFighters[unitAliases.B17F.id]				=false
overTwoHundred.regensburgFighters[unitAliases.B24J.id]				=false
overTwoHundred.regensburgFighters[unitAliases.B17G.id]				=false
overTwoHundred.regensburgFighters[unitAliases.EgonMayer.id]			=false
overTwoHundred.regensburgFighters[unitAliases.AlliedFlak.id]			=false
overTwoHundred.regensburgFighters[unitAliases.He111.id]				=false
overTwoHundred.regensburgFighters[unitAliases.Sunderland.id]			=false
overTwoHundred.regensburgFighters[unitAliases.HermannGraf.id]			=false
overTwoHundred.regensburgFighters[unitAliases.JosefPriller.id]		=false
overTwoHundred.regensburgFighters[unitAliases.AdolfGalland.id]		=false
overTwoHundred.regensburgFighters[unitAliases.RAFAce.id]		=false
overTwoHundred.regensburgFighters[unitAliases.USAAFAce.id]		=false
overTwoHundred.regensburgFighters[unitAliases.GermanTaskForce.id]		=false
overTwoHundred.regensburgFighters[unitAliases.AlliedTaskForce.id]		=false
overTwoHundred.regensburgFighters[unitAliases.RedTails.id]		=true	
overTwoHundred.regensburgFighters[unitAliases.MedBombers.id]			=false
overTwoHundred.regensburgFighters[unitAliases.FifteenthAF.id]         =false
overTwoHundred.regensburgFighters[unitAliases.GunBattery.id]			=false
overTwoHundred.regensburgFighters[unitAliases.Yak3.id]			=true	
overTwoHundred.regensburgFighters[unitAliases.Il2.id]					=false
overTwoHundred.regensburgFighters[unitAliases.Ju188.id]				=false
overTwoHundred.regensburgFighters[unitAliases.MossiePR.id]			=false
overTwoHundred.regensburgFighters[unitAliases.Freighter.id]			=false
overTwoHundred.regensburgFighters[unitAliases.Convoy.id]  			=false
overTwoHundred.regensburgFighters[unitAliases.GermanLightFlak.id]		=false
overTwoHundred.regensburgFighters[unitAliases.AlliedLightFlak.id]		=false
overTwoHundred.regensburgFighters[unitAliases.Carrier.id]				=false
overTwoHundred.regensburgFighters[unitAliases.damagedB17F.id]			=false
overTwoHundred.regensburgFighters[unitAliases.damagedB17G.id]			=false
overTwoHundred.regensburgFighters[unitAliases.UBoat.id]				=false
overTwoHundred.regensburgFighters[unitAliases.hwSchnaufer.id]			=false
overTwoHundred.regensburgFighters[unitAliases.Experten.id]			=false

function overTwoHundred.findGermanFighterDefeciency()
    local alliedCount = 0
    local germanCount = 0
    for unit in civ.iterateUnits() do
        if overTwoHundred.regensburgFighters[unit.type.id] then
            if unit.owner == tribeAliases.Allies then
                alliedCount = alliedCount+1
            elseif unit.owner == tribeAliases.Germans then
                germanCount = germanCount+1
            end
        end
    end
    return math.max(0,math.ceil(specialNumbers.fighterParity*alliedCount-germanCount))
end

function overTwoHundred.engineFailure(activeTribe)
    if flag("PlayingVersusSelf") then
        for unit in civ.iterateUnits() do
            if unit.type.domain == 1 and unit.owner == activeTribe and unit.location.city then
                if math.random() < specialNumbers.engineFailureProbabilitySP then
                    unit.moveSpent = unit.type.move
                end
            end
        end
    end
end

-- need unit killed function for after production, but it is defined below
local doOnUnitKilled = nil

-- These are the instructions to be performed when the first unit is activated
-- Will not happen if a tribe doesn't activate any units during its turn.
local function afterProduction(turn,tribe)
    log.purgeCasualtyInfo(tribe)
    replaceSoldCityBuildings()
    setUrbanDefenseValue()
    setFlagFalse("NoUpkeepWarningThisTurn")
    setCounter("UpkeepWarningTreasuryLevel",upkeep.computeCosts(tribe))
    --setSubQualities()
    setSubFlag()
    clouds.updateAllWeather(state.mapStorageTable,state.stormInfoTable,clouds.catInfoTable,state.map1FrontStatisticsTable,state.map2FrontStatisticsTable)
    justOnce("ZeroMovementUnitVetStatusFix",function() for unit in civ.iterateUnits() do if unit.type.move == 0 then unit.veteran = true end end end)
    --local aptext = "It is turn "..tostring(turn).." and the tribe is "..tribe.name..".  This should appear only once per turn per tribe."
    --civ.ui.text(func.splitlines(aptext))
    fortifyPassiveFlak()
    doScouting()
    overTwoHundred.alliedReinforcementsAfterProduction()
    overTwoHundred.engineFailure(tribe)
    if tribe == tribeAliases.Allies then
        if turn == 1 then
        	civ.ui.text(func.splitlines(textAliases.firstTurn1))
        	civ.ui.text(func.splitlines(textAliases.firstTurn2))
        	--civ.playSound('Turn1RAF.wav')
        	playMusic('Turn1RAF.wav')
        	civ.ui.text(func.splitlines(textAliases.firstTurn3))
        	civ.ui.text(func.splitlines(textAliases.firstTurn4))
        	civ.ui.text(func.splitlines(textAliases.firstTurn5))
            local archiveMessage =  textAliases.firstTurn1.."%PAGEBREAK".. 
                                    textAliases.firstTurn2
            text.addToArchive(tribeAliases.Allies,archiveMessage,"Dedication","Dedication")
            local archiveMessage =  textAliases.firstTurn3.."%PAGEBREAK"..
                                    textAliases.firstTurn4.."%PAGEBREAK"..
                                    textAliases.firstTurn5
            text.addToArchive(tribeAliases.Allies,archiveMessage,"Operation Millennium","Operation Millennium")
        end
        
        if turn == 2 then
        	civ.ui.text(func.splitlines(textAliases.secondTurn1))
        	civ.ui.text(func.splitlines(textAliases.secondTurn2))
        	civ.ui.text(func.splitlines(textAliases.secondTurn3))
        	civ.ui.text(func.splitlines(textAliases.secondTurn4))
        	civ.ui.text(func.splitlines(textAliases.secondTurn5))
        	civ.ui.text(func.splitlines(textAliases.secondTurn6))
            local archiveMessage =  textAliases.secondTurn1.."%PAGEBREAK"..
                                    textAliases.secondTurn2.."%PAGEBREAK"..
                                    textAliases.secondTurn3.."%PAGEBREAK"..
                                    textAliases.secondTurn4.."%PAGEBREAK"..
                                    textAliases.secondTurn5.."%PAGEBREAK"..
                                    textAliases.secondTurn6
            text.addToArchive(tribeAliases.Allies,archiveMessage,"Game Advice","Game Advice")
        end
        
        if turn == 3 then
        	--civ.playSound('FlyingFortress.wav') 
        	playMusic('FlyingFortress.wav') 
        	civ.ui.text(func.splitlines(textAliases.thirdTurn1))
        	civ.ui.text(func.splitlines(textAliases.thirdTurn2))
        	civ.ui.text(func.splitlines(textAliases.thirdTurn3))
            local archiveMessage = textAliases.thirdTurn1.."%PAGEBREAK"..
                                   textAliases.thirdTurn2.."%PAGEBREAK"..
                                   textAliases.thirdTurn3
            text.addToArchive(tribeAliases.Allies,archiveMessage,"Americans Arrive in England","Americans Arrive in England")
        	civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{154,48,0}}, {count=3, randomize=false, veteran=false})
        	civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{175,55,0}}, {count=3, randomize=false, veteran=false})
        	civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{148,72,0}}, {count=3, randomize=false, veteran=false})
        	civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{117,71,0}}, {count=3, randomize=false, veteran=false})
        	civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{179,53,0}}, {count=3, randomize=false, veteran=false})
        	civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{176,60,0}}, {count=3, randomize=false, veteran=false})
        	civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{181,57,0}}, {count=3, randomize=false, veteran=false})
        end 
        if turn >= 4 then
            local nightBombers = 0
            local dayBombers = 0
            for unit in civ.iterateUnits() do
                if (unit.type == unitAliases.Stirling or unit.type == unitAliases.Halifax
                    or unit.type == unitAliases.Lancaster) and unit.owner == tribeAliases.Allies then
                    nightBombers = nightBombers+1
                elseif (unit.type == unitAliases.B17F or unit.type == unitAliases.B24J
                    or unit.type == unitAliases.B17G or unit.type == unitAliases.MedBombers) and unit.owner == tribeAliases.Allies then
                    dayBombers = dayBombers+1
                end
            end
            local minDayBombers = specialNumbers.minDayBombersAllies+math.floor(turn*specialNumbers.minDayBomberTurnIncrement)
            local minNightBombers = specialNumbers.minNightBombersAllies+math.floor(turn*specialNumbers.minNightBomberTurnIncrement)
        	civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{149,17,0}}, {count=math.max(0,minDayBombers-dayBombers), randomize=false, veteran=false, homeCity=cityAliases.London})
        	civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{149,17,2}}, {count=math.max(0,minNightBombers-nightBombers), randomize=false, veteran=false, homeCity=cityAliases.London})
        end
        
        
        if turn == 13 then
        	civ.ui.text(func.splitlines(textAliases.FiftySixthFighterGroup))
            text.addToArchive(tribeAliases.Allies,archiveMessage,"Fifty Sixth Fighter Group","Fifty Sixth Fighter Group")
        	civlua.createUnit(unitAliases.P47D11, tribeAliases.Allies, {{179,53,0}}, {count=4, randomize=false, veteran=false})
        end
        
    end

	if tribe == tribeAliases.Germans and turn == 1 then
        civ.ui.text(func.splitlines(textAliases.firstTurn1))
        civ.ui.text(func.splitlines(textAliases.firstTurn2))
        local archiveMessage =  textAliases.firstTurn1.."%PAGEBREAK".. 
                                textAliases.firstTurn2
        text.addToArchive(tribeAliases.Germans,archiveMessage,"Dedication","Dedication")
        --civ.playSound('LuftwaffeMarch.wav')
        playMusic('LuftwaffeMarch.wav')
        civ.ui.text(func.splitlines(textAliases.firstGermanTurn1))
        civ.ui.text(func.splitlines(textAliases.firstGermanTurn2))
        civ.ui.text(func.splitlines(textAliases.firstGermanTurn3))
        civ.ui.text(func.splitlines(textAliases.firstGermanTurn4))
        civ.ui.text(func.splitlines(textAliases.firstGermanTurn5))
        civ.ui.text(func.splitlines(textAliases.firstGermanTurn6))
        local archiveMessage =textAliases.firstGermanTurn1.."%PAGEBREAK".. 
                              textAliases.firstGermanTurn2.."%PAGEBREAK"..
                              textAliases.firstGermanTurn3.."%PAGEBREAK"..
                              textAliases.firstGermanTurn4.."%PAGEBREAK"..
                              textAliases.firstGermanTurn5.."%PAGEBREAK"..
                              textAliases.firstGermanTurn6
        text.addToArchive(tribeAliases.Germans,archiveMessage,"War Summary","War Summary")



	end 
	
	if tribe == tribeAliases.Germans and turn == 2 then
        civ.ui.text(func.splitlines(textAliases.secondTurn1))
        civ.ui.text(func.splitlines(textAliases.secondTurn2))
        civ.ui.text(func.splitlines(textAliases.secondTurn3))
        civ.ui.text(func.splitlines(textAliases.secondTurn4))
        civ.ui.text(func.splitlines(textAliases.secondTurn5))
        civ.ui.text(func.splitlines(textAliases.secondTurn6))
        local archiveMessage =  textAliases.secondTurn1.."%PAGEBREAK"..
                                textAliases.secondTurn2.."%PAGEBREAK"..
                                textAliases.secondTurn3.."%PAGEBREAK"..
                                textAliases.secondTurn4.."%PAGEBREAK"..
                                textAliases.secondTurn5.."%PAGEBREAK"..
                                textAliases.secondTurn6
        text.addToArchive(tribeAliases.Germans,archiveMessage,"Game Advice","Game Advice")
	end 
	
	if tribe == tribeAliases.Germans and turn == 3 then
        civ.ui.text(func.splitlines(textAliases.thirdGermanTurn1))
        civ.ui.text(func.splitlines(textAliases.thirdGermanTurn2))
        local archiveMessage = textAliases.thirdGermanTurn1.."%PAGEBREAK"..
                               textAliases.thirdGermanTurn2
        text.addToArchive(tribeAliases.Germans,archiveMessage,"American Arrival","American Arrival")

    end 
	
    text.displayAccumulatedMessages()
    -- set airlift flag so that units can't be airlifted between flight schools
    for city in civ.iterateCities() do
        if city:hasImprovement(improvementAliases.jagdfliegerschule) then
            city.attributes = gen.setBit1(city.attributes,17)
        end
    end
    if tribe == tribeAliases.Germans then
        germanOccupationBonus()
        if overTwoHundred.countGermanSubs() < specialNumbers.uBoatBonusThreshold and 
                cityAliases.Hamburg:hasImprovement(improvementAliases.criticalIndustry)
                and cityAliases.Hamburg.owner == tribeAliases.Germans then
                for i=1,specialNumbers.uBoatBonusPerTurn do
                    civ.createUnit(unitAliases.UBoat,tribeAliases.Germans,cityAliases.Hamburg.location)
                end
        end
        local germanFighterDeficiency = overTwoHundred.findGermanFighterDefeciency()
        if overTwoHundred.germanCriticalIndustryActive(cityAliases.Regensburg) and germanFighterDeficiency>0 then
            local loc = specialNumbers.messerschmidtAirbaseLocation
            local deliveryAirbase = civ.getTile(loc[1],loc[2],loc[3]).city
            if deliveryAirbase then
                text.simple("The Messerschmidt Flugzeugwerke has been working around the clock to compensate for our shortage of fighters.  New fighters have been delivered to "..deliveryAirbase.name..".")
                local ME109Type = nil
                if overTwoHundred.canCityProduceItem(deliveryAirbase,unitAliases.Me109K4) then
                    ME109Type = unitAliases.Me109K4
                elseif overTwoHundred.canCityProduceItem(deliveryAirbase,unitAliases.Me109G14) then
                    ME109Type = unitAliases.Me109G14
                else
                    ME109Type = unitAliases.Me109G6
                end
                for i=1,germanFighterDeficiency do
                    local newFighter = civ.createUnit(ME109Type,tribeAliases.Germans,deliveryAirbase.location)
                    newFighter.homeCity = deliveryAirbase
                end
            end
        end
        if overTwoHundred.germanCriticalIndustryActive(cityAliases.Peenemunde) then
            tribeAliases.Germans.researchProgress = tribeAliases.Germans.researchProgress + tribeAliases.Germans.researchCost//specialNumbers.turnsForFreePeenemundeTech
            --incrementCounter("PeenemundeResearchTurns",-1)
            --if counterValue("PeenemundeResearchTurns") <= 0  then
            --    setCounter("PeenemundeResearchTurns",specialNumbers.turnsForFreePeenemundeTech)
            --    local techToGive = tribeAliases.Germans.researching
            --    civ.giveTech(tribeAliases.Germans,techToGive)
            --    text.simple("Researchers at the Erprobungsstelle der Luftwaffe have completed research on "..techToGive.name..".","Science Adviser")
            --end
        end
    end
    if tribe == tribeAliases.Allies and civ.hasTech(tribeAliases.Allies, civ.getTech(96)) then
        justOnce("AlliesTech96", function()
            tribeAliases.Allies.money = tribeAliases.Allies.money + specialNumbers.PoliticalSupportMoneyBonus
            civ.ui.text(func.splitlines(textAliases.AlliedPoliticalSupport))
            text.addToArchive(tribeAliases.Allies,textAliases.AlliedPoliticalSupport,"Political Support","Political Support")
        end)
    end
    if tribe == tribeAliases.Allies and civ.hasTech(tribeAliases.Allies, civ.getTech(97)) then
        justOnce("AlliesTech97", function()
            tribeAliases.Allies.money = tribeAliases.Allies.money + specialNumbers.PoliticalSupportMoneyBonus
            civ.ui.text(func.splitlines(textAliases.AlliedPoliticalSupport))
            text.addToArchive(tribeAliases.Allies,textAliases.AlliedPoliticalSupport,"Political Support","Political Support")
        end)
    end
    if tribe == tribeAliases.Allies and civ.hasTech(tribeAliases.Allies, civ.getTech(98)) then
        justOnce("AlliesTech98", function()
            tribeAliases.Allies.money = tribeAliases.Allies.money + specialNumbers.PoliticalSupportMoneyBonus
            civ.ui.text(func.splitlines(textAliases.AlliedPoliticalSupport))
            text.addToArchive(tribeAliases.Allies,textAliases.AlliedPoliticalSupport,"Political Support","Political Support")
        end)
    end
    if tribe == tribeAliases.Allies and civ.hasTech(tribeAliases.Allies, civ.getTech(99)) then
        justOnce("AlliesTech99", function()
            tribeAliases.Allies.money = tribeAliases.Allies.money + specialNumbers.PoliticalSupportMoneyBonus
            civ.ui.text(func.splitlines(textAliases.AlliedPoliticalSupport))
            text.addToArchive(tribeAliases.Allies,textAliases.AlliedPoliticalSupport,"Political Support","Political Support")
        end)
    end
    if tribe == tribeAliases.Germans and civ.hasTech(tribeAliases.Germans, civ.getTech(96)) then
        justOnce("GermansTech96", function()
            tribeAliases.Germans.money = tribeAliases.Germans.money + specialNumbers.PoliticalSupportMoneyBonus
            civ.ui.text(func.splitlines(textAliases.GermanPoliticalSupport))
            text.addToArchive(tribeAliases.Germans,textAliases.GermanPoliticalSupport,"Political Support","Political Support")
        end)
    end
    if tribe == tribeAliases.Germans and civ.hasTech(tribeAliases.Germans, civ.getTech(97)) then
        justOnce("GermansTech97", function()
            tribeAliases.Germans.money = tribeAliases.Germans.money + specialNumbers.PoliticalSupportMoneyBonus
            civ.ui.text(func.splitlines(textAliases.GermanPoliticalSupport))
            text.addToArchive(tribeAliases.Germans,textAliases.GermanPoliticalSupport,"Political Support","Political Support")
        end)
    end
    if tribe == tribeAliases.Germans and civ.hasTech(tribeAliases.Germans, civ.getTech(98)) then
        justOnce("GermansTech98", function()
            tribeAliases.Germans.money = tribeAliases.Germans.money + specialNumbers.PoliticalSupportMoneyBonus
            civ.ui.text(func.splitlines(textAliases.GermanPoliticalSupport))
            text.addToArchive(tribeAliases.Germans,textAliases.GermanPoliticalSupport,"Political Support","Political Support")
        end)
    end
    if tribe == tribeAliases.Germans and civ.hasTech(tribeAliases.Germans, civ.getTech(99)) then
        justOnce("GermansTech99", function()
            tribeAliases.Germans.money = tribeAliases.Germans.money + specialNumbers.PoliticalSupportMoneyBonus
            civ.ui.text(func.splitlines(textAliases.GermanPoliticalSupport))
            text.addToArchive(tribeAliases.Germans,textAliases.GermanPoliticalSupport,"Political Support","Political Support")
        end)
    end
    if tribe == tribeAliases.Allies and counterValue("KillsOutsideEscortRange") > specialNumbers.newEscortLosses then
        justOnce("GiveLongRangeEscortsNeeded", function ()
        
        civ.ui.text(func.splitlines(textAliases.heavyBomberLosses))
        text.addToArchive(tribeAliases.Allies,textAliases.heavyBomberLosses,"Long Range Escort Needed","Long Range Escort Needed")
        civ.giveTech(tribeAliases.Allies, civ.getTech(94))
        end)
    end
    if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.invadeItalyThreshold and not civ.hasTech(tribeAliases.Allies, civ.getTech(73)) then
		civ.ui.text(func.splitlines(textAliases.foggiaText1))
		civ.ui.text(func.splitlines(textAliases.foggiaText2))
		civ.ui.text(func.splitlines(textAliases.foggiaText3))
        --newspaper.addToNewspaper(state.newspaper.allies,"Italian Airbases",textAliases.foggiaText1.."  ".. textAliases.foggiaText2.."  ".. textAliases.foggiaText3)
        text.addToArchive(tribeAliases.Allies,textAliases.foggiaText1.."  ".. textAliases.foggiaText2.."  ".. textAliases.foggiaText3,"Italian Airbases","Italian Airbases")
		civlua.createUnit(unitAliases.MedBombers, tribeAliases.Allies, {{345,145,0}}, {count=10, randomize=false, veteran=false})
        civ.giveTech(tribeAliases.Allies, civ.getTech(73))
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.medBomberReinforcements1 and turn <= specialNumbers.medBomberReinforcements1Deadline then
	justOnce("medBomberReinforcements1", function()
		civ.ui.text(func.splitlines(textAliases.medBomberReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.medBomberReinforcements,"Reinforcements in Italy","Reinforcements in Italy")
		civlua.createUnit(unitAliases.MedBombers, tribeAliases.Allies, {{345,145,0}}, {count=10, randomize=false, veteran=false})
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.medBomberReinforcements2 and turn <= specialNumbers.medBomberReinforcements2Deadline then
		justOnce("medBomberReinforcements2", function()
		civ.ui.text(func.splitlines(textAliases.medBomberReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.medBomberReinforcements,"Reinforcements in Italy","Reinforcements in Italy")
		civlua.createUnit(unitAliases.MedBombers, tribeAliases.Allies, {{345,145,0}}, {count=10, randomize=false, veteran=false})
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.medBomberReinforcements3 and turn <= specialNumbers.medBomberReinforcements3Deadline then
		justOnce("medBomberReinforcements3", function()
		civ.ui.text(func.splitlines(textAliases.medBomberReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.medBomberReinforcements,"Reinforcements in Italy","Reinforcements in Italy")
		civlua.createUnit(unitAliases.MedBombers, tribeAliases.Allies, {{345,145,0}}, {count=10, randomize=false, veteran=false})
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.medBomberReinforcements4 and turn <= specialNumbers.medBomberReinforcements4Deadline then
		justOnce("medBomberReinforcements4", function()
		civ.ui.text(func.splitlines(textAliases.medBomberReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.medBomberReinforcements,"Reinforcements in Italy","Reinforcements in Italy")
		civlua.createUnit(unitAliases.MedBombers, tribeAliases.Allies, {{345,145,0}}, {count=10, randomize=false, veteran=false})
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.medBomberReinforcements5 and turn <= specialNumbers.medBomberReinforcements5Deadline then
		justOnce("medBomberReinforcements5", function()
		civ.ui.text(func.splitlines(textAliases.medBomberReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.medBomberReinforcements,"Reinforcements in Italy","Reinforcements in Italy")
		civlua.createUnit(unitAliases.MedBombers, tribeAliases.Allies, {{345,145,0}}, {count=10, randomize=false, veteran=false})
		end)
    end
    if tribe == tribeAliases.Allies then	
	justOnce("newAlliedArmyGroupReinforcements0", function()
        if reinforcementCityOwned(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups,textAliases.newAlliedArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.newAlliedArmyGroup1 and turn <= specialNumbers.newAlliedArmyGroup1Deadline then
	justOnce("newAlliedArmyGroupReinforcements1", function()
        if reinforcementCityOwned(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups,textAliases.newAlliedArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.newAlliedArmyGroup2 and turn <= specialNumbers.newAlliedArmyGroup2Deadline then
	justOnce("newAlliedArmyGroupReinforcements2", function()
        if reinforcementCityOwned(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups,textAliases.newAlliedArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.newAlliedArmyGroup3 and turn <= specialNumbers.newAlliedArmyGroup3Deadline then
	justOnce("newAlliedArmyGroupReinforcements3", function()
        if reinforcementCityOwned(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups,textAliases.newAlliedArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.newAlliedArmyGroup4 and turn <= specialNumbers.newAlliedArmyGroup4Deadline then
	justOnce("newAlliedArmyGroupReinforcements4", function()
        if reinforcementCityOwned(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups,textAliases.newAlliedArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.newAlliedArmyGroup5 and turn <= specialNumbers.newAlliedArmyGroup5Deadline then
	justOnce("newAlliedArmyGroupReinforcements5", function()
        if reinforcementCityOwned(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups,textAliases.newAlliedArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.AlliedArmyGroup, tribeAliases.Allies, reinforcementLocations.AlliedBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Allies then
	justOnce("newAlliedTaskForceReinforcements0", function()
        if reinforcementCityOwned(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces,textAliases.newAlliedTaskForceReinforcements) then
    		civlua.createUnit(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.newAlliedTaskForce1 and turn <= specialNumbers.newAlliedTaskForce1Deadline then
	justOnce("newAlliedTaskForceReinforcements1", function()
        if reinforcementCityOwned(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces,textAliases.newAlliedTaskForceReinforcements) then
    		civlua.createUnit(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.newAlliedTaskForce2 and turn <= specialNumbers.newAlliedTaskForce2Deadline then
	justOnce("newAlliedTaskForceReinforcements2", function()
        if reinforcementCityOwned(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces,textAliases.newAlliedTaskForceReinforcements) then
    		civlua.createUnit(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.newAlliedTaskForce3 and turn <= specialNumbers.newAlliedTaskForce3Deadline then
	justOnce("newAlliedTaskForceReinforcements3", function()
        if reinforcementCityOwned(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces,textAliases.newAlliedTaskForceReinforcements) then
    		civlua.createUnit(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.newAlliedTaskForce4 and turn <= specialNumbers.newAlliedTaskForce4Deadline then
	justOnce("newAlliedTaskForceReinforcements4", function()
        if reinforcementCityOwned(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces,textAliases.newAlliedTaskForceReinforcements) then
    		civlua.createUnit(unitAliases.AlliedTaskForce, tribeAliases.Allies, reinforcementLocations.AlliedTaskForces, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") > specialNumbers.ExpertenTrigger1 then
        justOnce("GermansGetExpertenEgonMayer", function ()
        
        civ.ui.text(func.splitlines(textAliases.EgonMayer))
        text.addToArchive(tribeAliases.Germans,textAliases.EgonMayer,"Egon Mayer","Egon Mayer")
        civlua.createUnit(unitAliases.EgonMayer, tribeAliases.Germans, {{165,101,0}}, {count=1, randomize=false, veteran=true})
        end)
    end
	
	if tribe == tribeAliases.Germans then
	justOnce("newGermanArmyGroupReinforcements0", function()
        if reinforcementCityOwned(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups,textAliases.newGermanArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanArmyGroup1 and turn <= specialNumbers.newGermanArmyGroup1Deadline then
	justOnce("newGermanArmyGroupReinforcements1", function()
        if reinforcementCityOwned(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups,textAliases.newGermanArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanArmyGroup2 and turn <= specialNumbers.newGermanArmyGroup2Deadline then
	justOnce("newGermanArmyGroupReinforcements2", function()
        if reinforcementCityOwned(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups,textAliases.newGermanArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanArmyGroup3 and turn <= specialNumbers.newGermanArmyGroup3Deadline then
	justOnce("newGermanArmyGroupReinforcements3", function()
        if reinforcementCityOwned(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups,textAliases.newGermanArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanArmyGroup4 and turn <= specialNumbers.newGermanArmyGroup4Deadline then
	justOnce("newGermanArmyGroupReinforcements4", function()
        if reinforcementCityOwned(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups,textAliases.newGermanArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanArmyGroup5 and turn <= specialNumbers.newGermanArmyGroup5Deadline then
	justOnce("newGermanArmyGroupReinforcements5", function()
        if reinforcementCityOwned(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups,textAliases.newGermanArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanArmyGroup6 and turn <= specialNumbers.newGermanArmyGroup6Deadline then
	justOnce("newGermanArmyGroupReinforcements6", function()
        if reinforcementCityOwned(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups,textAliases.newGermanArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanArmyGroup7 and turn <= specialNumbers.newGermanArmyGroup7Deadline then
	justOnce("newGermanArmyGroupReinforcements7", function()
        if reinforcementCityOwned(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups,textAliases.newGermanArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanArmyGroup8 and turn <= specialNumbers.newGermanArmyGroup8Deadline then
	justOnce("newGermanArmyGroupReinforcements8", function()
        if reinforcementCityOwned(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups,textAliases.newGermanArmyGroupReinforcements) then
    		civlua.createUnit(unitAliases.GermanArmyGroup, tribeAliases.Germans, reinforcementLocations.GermanBattleGroups, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans then
	justOnce("newGermanTaskForceReinforcements0", function()
        if reinforcementCityOwned(unitAliases.GermanTaskForce, tribeAliases.Germans, reinforcementLocations.GermanTaskForces,textAliases.newGermanTaskForceReinforcements) then
    		civlua.createUnit(unitAliases.GermanTaskForce, tribeAliases.Germans, reinforcementLocations.GermanTaskForces, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanTaskForce1 and turn <= specialNumbers.newGermanTaskForce1Deadline then
	justOnce("newGermanTaskForceReinforcements1", function()
        if reinforcementCityOwned(unitAliases.GermanTaskForce, tribeAliases.Germans, reinforcementLocations.GermanTaskForces,textAliases.newGermanTaskForceReinforcements) then
    		civlua.createUnit(unitAliases.GermanTaskForce, tribeAliases.Germans, reinforcementLocations.GermanTaskForces, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanTaskForce2 and turn <= specialNumbers.newGermanTaskForce2Deadline then
	justOnce("newGermanTaskForceReinforcements2", function()
        if reinforcementCityOwned(unitAliases.GermanTaskForce, tribeAliases.Germans, reinforcementLocations.GermanTaskForces,textAliases.newGermanTaskForceReinforcements) then
    		civlua.createUnit(unitAliases.GermanTaskForce, tribeAliases.Germans, reinforcementLocations.GermanTaskForces, {count=1, randomize=false, veteran=false})
        end
		end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.newGermanTaskForce3 and turn <= specialNumbers.newGermanTaskForce3Deadline then
	justOnce("newGermanTaskForceReinforcements3", function()
        if reinforcementCityOwned(unitAliases.GermanTaskForce, tribeAliases.Germans, reinforcementLocations.GermanTaskForces,textAliases.newGermanTaskForceReinforcements) then
    		civlua.createUnit(unitAliases.GermanTaskForce, tribeAliases.Germans, reinforcementLocations.GermanTaskForces, {count=1, randomize=false, veteran=false})
        end
		end)
    end
    if tribe == tribeAliases.Germans and counterValue("GermanScore") >= specialNumbers.germansCanInvade then
        setFlagTrue("GermansCanInvade")
    end
    --[[if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.overlordThreshold and not civ.hasTech(tribeAliases.Allies, civ.getTech(74)) then
		civ.ui.text(func.splitlines(textAliases.overlordText1))
		civ.ui.text(func.splitlines(textAliases.overlordText2))
		civ.ui.text(func.splitlines(textAliases.overlordText3))
		civ.ui.text(func.splitlines(textAliases.overlordText4))
        newspaper.addToNewspaper(state.newspaper.allies,"Operation Overlord Instructions",textAliases.overlordText1.."  ".. textAliases.overlordText2.."  ".. textAliases.overlordText3.."  ".. textAliases.overlordText4)
		civ.giveTech(tribeAliases.Allies, civ.getTech(74))
    end]]
	
    if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.vistulaOderThreshold and overTwoHundred.enoughCitiesCapturedForRussianFront() and not civ.hasTech(tribeAliases.Allies, civ.getTech(76)) and state.DDayInvasion == true then
		--civ.playSound('RedArmy.wav')
        playMusic('RedArmy.wav')
		civ.ui.text(func.splitlines(textAliases.vistulaText1))
		civ.ui.text(func.splitlines(textAliases.vistulaText2))
        --newspaper.addToNewspaper(state.newspaper.allies,"Vistula-Oder Offensive",textAliases.vistulaText1.."  ".. textAliases.vistulaText2)
        text.addToArchive(tribeAliases.Allies,textAliases.vistulaText1.."  ".. textAliases.vistulaText2,"Vistula-Oder Offensive","Vistula-Oder Offensive")
		civlua.createUnit(unitAliases.Yak3, tribeAliases.Allies, {{406,74,0}}, {count=8, randomize=false, veteran=true})
		civlua.createUnit(unitAliases.Il2, tribeAliases.Allies, {{406,74,0}}, {count=4, randomize=false, veteran=true})
		civlua.createUnit(unitAliases.RedArmyGroup, tribeAliases.Allies, {{406,74,0}}, {count=12, randomize=false, veteran=true})
        civ.giveTech(tribeAliases.Allies, civ.getTech(76))
        civ.getTile(404,74,0).terrainType = 2
        civ.getTile(404,74,0).landmass = 10 -- change the landmass so it can be scoutable
        for unit in civ.iterateUnits() do
            if unit.owner.id == 0 and unit.location.x>=403 and unit.location.x<=407 and unit.location.y>=71 and unit.location.y<=77 then
                civ.deleteUnit(unit)
            end
        end
    end
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.stalingradThreshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.stalingradThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.stalingradAlliedText))
        --newspaper.addToNewspaper(state.newspaper.allies,"Stalingrad",textAliases.stalingradAlliedText)
        text.addToArchive(tribeAliases.Allies,textAliases.stalingradAlliedText,"Stalingrad","Stalingrad")

        end)
    end
	if tribe == tribeAliases.Germans and counterValue("AlliedScore") >= specialNumbers.stalingradThreshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.stalingradThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.stalingradGermanText))
        --newspaper.addToNewspaper(state.newspaper.germans,"Stalingrad",textAliases.stalingradGermanText)
        text.addToArchive(tribeAliases.Germans,textAliases.stalingradGermanText,"Stalingrad","Stalingrad")
        end)
    end
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.huskyInvasionThreshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.huskyInvasionThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.huskyAlliedText))
        --newspaper.addToNewspaper(state.newspaper.allies,"Operation Husky",textAliases.huskyAlliedText)
        text.addToArchive(tribeAliases.Allies,textAliases.huskyAlliedText,"Operation Husky","Operation Husky")
        end)
    end
	if tribe == tribeAliases.Germans and counterValue("AlliedScore") >= specialNumbers.huskyInvasionThreshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.huskyInvasionThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.huskyGermanText))
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Husky",textAliases.huskyGermanText)
        text.addToArchive(tribeAliases.Germans,textAliases.huskyGermanText,"Operation Husky","Operation Husky")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.avalancheThreshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.avalancheThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.avalancheAlliedText))
        --newspaper.addToNewspaper(state.newspaper.allies,"Operation Avalanche",textAliases.avalancheAlliedText)
        text.addToArchive(tribeAliases.Allies,textAliases.avalancheAlliedText,"Operation Avalanche","Operation Avalanche")
        end)
    end
	if tribe == tribeAliases.Germans and counterValue("AlliedScore") >= specialNumbers.avalancheThreshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.avalancheThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.avalancheGermanText))
        --newspaper.addToNewspaper(state.newspaper.germans,"Operation Avalanche",textAliases.avalancheGermanText)
        text.addToArchive(tribeAliases.Germans,textAliases.avalancheGermanText,"Operation Avalanche","Operation Avalanche")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.kievThreshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.kievThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.kievAlliedText))
        --newspaper.addToNewspaper(state.newspaper.allies,"Kiev Liberated",textAliases.kievAlliedText)
        text.addToArchive(tribeAliases.Allies,textAliases.kievAlliedText,"Kiev Liberated","Kiev Liberated")
        end)
    end
	if tribe == tribeAliases.Germans and counterValue("AlliedScore") >= specialNumbers.kievThreshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.kievThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.kievGermanText))
        --newspaper.addToNewspaper(state.newspaper.germans,"Kiev Lost",textAliases.kievGermanText)
        text.addToArchive(tribeAliases.Germans,textAliases.kievGermanText,"Kiev Lost","Kiev Lost")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.korsunThreshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.korsunThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.korsunAlliedText))
        --newspaper.addToNewspaper(state.newspaper.allies,"Korsun Offensive",textAliases.korsunAlliedText)
        text.addToArchive(tribeAliases.Allies,textAliases.korsunAlliedText,"Korsun Offensive","Korsun Offensive")
        end)
    end
	if tribe == tribeAliases.Germans and counterValue("AlliedScore") >= specialNumbers.korsunThreshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.korsunThreshold).."ThresholdJO",function()
		civ.ui.text(func.splitlines(textAliases.korsunGermanText))
        --newspaper.addToNewspaper(state.newspaper.germans,"Korsun Offensive",textAliases.korsunGermanText)
        text.addToArchive(tribeAliases.Germans,textAliases.korsunGermanText,"Korsun Offensive","Korsun Offensive")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce1Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce1Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.RAFAce, tribeAliases.Allies, {{197,63,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedRAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedRAFAce,"RAF Pilot Earns Ace Status","RAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce2Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce2Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.RAFAce, tribeAliases.Allies, {{197,63,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedRAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedRAFAce,"RAF Pilot Earns Ace Status","RAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce3Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce3Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.RAFAce, tribeAliases.Allies, {{197,63,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedRAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedRAFAce,"RAF Pilot Earns Ace Status","RAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce4Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce4Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.RAFAce, tribeAliases.Allies, {{197,63,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedRAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedRAFAce,"RAF Pilot Earns Ace Status","RAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce5Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce5Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.RAFAce, tribeAliases.Allies, {{197,63,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedRAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedRAFAce,"RAF Pilot Earns Ace Status","RAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce6Threshold and civ.hasTech(tribeAliases.Allies, civ.getTech(8))  then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce6Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.USAAFAce, tribeAliases.Allies, {{176,60,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedUSAAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedUSAAFAce,"USAAF Pilot Earns Ace Status","USAAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce7Threshold and civ.hasTech(tribeAliases.Allies, civ.getTech(8))  then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce7Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.USAAFAce, tribeAliases.Allies, {{176,60,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedUSAAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedUSAAFAce,"USAAF Pilot Earns Ace Status","USAAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce8Threshold and civ.hasTech(tribeAliases.Allies, civ.getTech(8))  then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce8Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.USAAFAce, tribeAliases.Allies, {{176,60,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedUSAAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedUSAAFAce,"USAAF Pilot Earns Ace Status","USAAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce9Threshold and civ.hasTech(tribeAliases.Allies, civ.getTech(8))  then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce9Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.USAAFAce, tribeAliases.Allies, {{176,60,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedUSAAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedUSAAFAce,"USAAF Pilot Earns Ace Status","USAAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.AlliedAce10Threshold and civ.hasTech(tribeAliases.Allies, civ.getTech(8))  then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.AlliedAce10Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.USAAFAce, tribeAliases.Allies, {{176,60,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AlliedUSAAFAce))
        text.addToArchive(tribeAliases.Allies,textAliases.AlliedUSAAFAce,"USAAF Pilot Earns Ace Status","USAAF Pilot Earns Ace Status")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.bomberReinforcement1Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.bomberReinforcement1Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{154,48,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{175,55,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{148,72,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{117,71,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{179,53,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{176,60,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{181,57,2}}, {count=2, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.BomberCommandReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.BomberCommandReinforcements,"Bomber Command Reinforcements","Bomber Command Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.bomberReinforcement2Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.bomberReinforcement2Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{154,48,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{175,55,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{148,72,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{117,71,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{179,53,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{176,60,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Stirling, tribeAliases.Allies, {{181,57,2}}, {count=2, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.BomberCommandReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.BomberCommandReinforcements,"Bomber Command Reinforcements","Bomber Command Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.bomberReinforcement3Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.bomberReinforcement3Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.Halifax, tribeAliases.Allies, {{154,48,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Halifax, tribeAliases.Allies, {{175,55,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Halifax, tribeAliases.Allies, {{148,72,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Halifax, tribeAliases.Allies, {{117,71,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Halifax, tribeAliases.Allies, {{179,53,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Halifax, tribeAliases.Allies, {{176,60,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Halifax, tribeAliases.Allies, {{181,57,2}}, {count=2, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.BomberCommandReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.BomberCommandReinforcements,"Bomber Command Reinforcements","Bomber Command Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.bomberReinforcement4Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.bomberReinforcement4Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{154,48,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{175,55,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{148,72,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{117,71,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{179,53,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{176,60,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{181,57,2}}, {count=2, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.BomberCommandReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.BomberCommandReinforcements,"Bomber Command Reinforcements","Bomber Command Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.bomberReinforcement5Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.bomberReinforcement5Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{154,48,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{175,55,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{148,72,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{117,71,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{179,53,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{176,60,2}}, {count=2, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.Lancaster, tribeAliases.Allies, {{181,57,2}}, {count=2, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.BomberCommandReinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.BomberCommandReinforcements,"Bomber Command Reinforcements","Bomber Command Reinforcements")
        end)
    end
	
		
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.USAAFReinforcement1Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.USAAFReinforcement1Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{175,55,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{179,53,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{176,60,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{181,57,0}}, {count=3, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.B17Reinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.B17Reinforcements,"B17 Reinforcements","B17 Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.USAAFReinforcement2Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.USAAFReinforcement2Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{175,55,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{179,53,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{176,60,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{181,57,0}}, {count=3, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.B17Reinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.B17Reinforcements,"B17 Reinforcements","B17 Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.USAAFReinforcement3Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.USAAFReinforcement3Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{175,55,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{179,53,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{176,60,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17F, tribeAliases.Allies, {{181,57,0}}, {count=3, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.B17Reinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.B17Reinforcements,"B17 Reinforcements","B17 Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.USAAFReinforcement4Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.USAAFReinforcement4Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{175,55,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{179,53,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{176,60,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{181,57,0}}, {count=3, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.B17Reinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.B17Reinforcements,"B17 Reinforcements","B17 Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.USAAFReinforcement5Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.USAAFReinforcement5Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{175,55,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{179,53,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{176,60,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{181,57,0}}, {count=3, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.B17Reinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.B17Reinforcements,"B17 Reinforcements","B17 Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.USAAFReinforcement6Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.USAAFReinforcement6Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{175,55,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{179,53,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{176,60,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{181,57,0}}, {count=3, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.B17Reinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.B17Reinforcements,"B17 Reinforcements","B17 Reinforcements")
        end)
    end
	
	if tribe == tribeAliases.Allies and counterValue("AlliedScore") >= specialNumbers.USAAFReinforcement7Threshold then
        justOnce(tribeAliases.Allies.name..tostring(specialNumbers.USAAFReinforcement7Threshold).."ThresholdJO",function()
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{175,55,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{179,53,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{176,60,0}}, {count=3, randomize=false, veteran=false})
		civlua.createUnit(unitAliases.B17G, tribeAliases.Allies, {{181,57,0}}, {count=3, randomize=false, veteran=false})
		civ.ui.text(func.splitlines(textAliases.B17Reinforcements))
        text.addToArchive(tribeAliases.Allies,textAliases.B17Reinforcements,"B17 Reinforcements","B17 Reinforcements")
        end)
    end
    --[[
    if tribe == tribeAliases.Allies and tribeAliases.Allies.futureTechs >= 1 and (not state.DDayInvasion) then
        justOnce("AlliesFutreTech1BonusPenalty",function()

            setCounter("EarliestAlliedInvasionDate",math.max(specialNumbers.earliestAlliedInvasionDateIfDelays,
                turn+specialNumbers.minInvasionDelay))
            setFlagFalse("AlliesCanInvade")
            local message = "This change in focus has delayed our ability to invade Europe.  We will be unable to invade before turn "..tostring(counterValue("EarliestAlliedInvasionDate")).."."
            text.displayNextOpportunity(tribeAliases.Allies,message,"Defense Minister","Invasion Delay")
        end)
    end
    if tribe == tribeAliases.Allies and tribeAliases.Allies.futureTechs >= 2  and (not state.DDayInvasion) then
        justOnce("AlliesFutreTech2BonusPenalty",function()

            incrementCounter("EarliestAlliedInvasionDate",specialNumbers.invasionDelayExtension)
            if counterValue("EarliestAlliedInvasionDate") < (turn+specialNumbers.minInvasionDelay) then
                setCounter("EarliestAlliedInvasionDate",turn+specialNumbers.minInvasionDelay)
            end
            setFlagFalse("AlliesCanInvade")
            local message = "This change in focus has delayed our ability to invade Europe.  We will be unable to invade before turn "..tostring(counterValue("EarliestAlliedInvasionDate")).."."
            text.displayNextOpportunity(tribeAliases.Allies,message,"Defense Minister","Invasion Delay")
        end)
    end
    if tribe == tribeAliases.Allies and tribeAliases.Allies.futureTechs >= 3  and (not state.DDayInvasion)  then
        justOnce("AlliesFutreTech3BonusPenalty",function()

            incrementCounter("EarliestAlliedInvasionDate",specialNumbers.invasionDelayExtension)
            if counterValue("EarliestAlliedInvasionDate") < (turn+specialNumbers.minInvasionDelay) then
                setCounter("EarliestAlliedInvasionDate",turn+specialNumbers.minInvasionDelay)
            end
            setFlagFalse("AlliesCanInvade")
            local message = "This change in focus has delayed our ability to invade Europe.  We will be unable to invade before turn "..tostring(counterValue("EarliestAlliedInvasionDate")).."."
            text.displayNextOpportunity(tribeAliases.Allies,message,"Defense Minister","Invasion Delay")
        end)
    end
    if tribe == tribeAliases.Allies and tribeAliases.Allies.futureTechs >= 4  and (not state.DDayInvasion)  then
        justOnce("AlliesFutreTech4BonusPenalty",function()

            incrementCounter("EarliestAlliedInvasionDate",specialNumbers.invasionDelayExtension)
            if counterValue("EarliestAlliedInvasionDate") < (turn+specialNumbers.minInvasionDelay) then
                setCounter("EarliestAlliedInvasionDate",turn+specialNumbers.minInvasionDelay)
            end
            setFlagFalse("AlliesCanInvade")
            local message = "This change in focus has delayed our ability to invade Europe.  We will be unable to invade before turn "..tostring(counterValue("EarliestAlliedInvasionDate")).."."
            text.displayNextOpportunity(tribeAliases.Allies,message,"Defense Minister","Invasion Delay")
        end)
    end

	
    if tribe == tribeAliases.Allies and counterValue("EarliestAlliedInvasionDate") > turn then 
        setFlagFalse("AlliesCanInvade")
    end
    if tribe == tribeAliases.Allies and counterValue("EarliestAlliedInvasionDate") <= turn then
        if not flag("AlliesCanInvade") then
            text.displayNextOpportunity(tribeAliases.Allies,"We are once again logistically positioned to invade the continent.","Defense Minister","Invasion Delay Over")
        end
        setFlagTrue("AlliesCanInvade")
    end
    --]]
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanExperten1Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanExperten1Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.hwSchnaufer, tribeAliases.Germans, {{248,84,2}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.hwSchnaufer))
        text.addToArchive(tribeAliases.Germans,textAliases.hwSchnaufer,"Heinz-Wolfgang Schnaufer","Heinz-Wolfgang Schnaufer")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanExperten2Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanExperten2Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.JosefPriller, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.JosefPriller))
        text.addToArchive(tribeAliases.Germans,textAliases.JosefPriller,"Josef Priller","Josef Priller")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanExperten3Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanExperten3Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.HermannGraf, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.HermannGraf))
        text.addToArchive(tribeAliases.Germans,textAliases.HermannGraf,"Hermann Graf","Hermann Graf")
        end)
    end
	
	
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanExperten4Threshold and civ.hasTech(tribeAliases.Germans, civ.getTech(36)) then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanExperten4Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.AdolfGalland, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.AdolfGalland))
        text.addToArchive(tribeAliases.Germans,textAliases.AdolfGalland,"Adolf Galland","Adolf Galland")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce1Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce1Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce2Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce2Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce3Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce3Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce4Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce4Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce5Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce5Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce6Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce6Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce7Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce7Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce8Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce8Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce9Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce9Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
	if tribe == tribeAliases.Germans and counterValue("GermanAircraftKills") >= specialNumbers.GermanAce10Threshold then
        justOnce(tribeAliases.Germans.name..tostring(specialNumbers.GermanAce10Threshold).."ThresholdJOExperten",function()
		civlua.createUnit(unitAliases.Experten, tribeAliases.Germans, {{352,70,0}}, {count=1, randomize=false, veteran=true})
		civ.ui.text(func.splitlines(textAliases.ExpertenArrival))
        text.addToArchive(tribeAliases.Germans,textAliases.ExpertenArrival,"New Experten","New Experten")
        end)
    end
	
		
	if tribe == tribeAliases.Allies and civ.hasTech(tribeAliases.Allies, civ.getTech(93)) then -- ***111
        justOnce("AlliesTech93", function()
            civ.ui.text(func.splitlines(textAliases.roamAtWillA))
			civ.ui.text(func.splitlines(textAliases.roamAtWillB))
            text.addToArchive(tribeAliases.Allies,textAliases.roamAtWillA.."%PAGEBREAK"..textAliases.roamAtWillB,"Roam at Will","Roam at Will")
        end)
    end
	
	if tribe == tribeAliases.Germans and civ.hasTech(tribeAliases.Germans, civ.getTech(2)) then -- ***111
        justOnce("GermansTech2", function()
            civ.ui.text(func.splitlines(textAliases.Fw190D9Text))
            text.addToArchive(tribeAliases.Germans,textAliases.Fw190D9Text,"FW 190D9","FW 190D9")
        end)
    end
	
	if tribe == tribeAliases.Germans and civ.hasTech(tribeAliases.Germans, civ.getTech(41)) then -- ***111
        justOnce("GermansTech41", function()
            civ.ui.text(func.splitlines(textAliases.wunderWaffenText))
            text.addToArchive(tribeAliases.Germans,textAliases.wunderWaffenText,"Wunder Waffen","Wunder Waffen")
        end)
    end
	
	if tribe == tribeAliases.Germans and civ.hasTech(tribeAliases.Germans, civ.getTech(59)) then -- ***111
        justOnce("GermansTech59", function()
            civ.ui.text(func.splitlines(textAliases.wildeSauText))
            text.addToArchive(tribeAliases.Germans,textAliases.wildeSauText,"Wilde Sau","Wilde Sau")
        end)
    end
	
	
	
	--This warns Germany that D-Day has occurred
	if tribe == tribeAliases.Germans and civ.hasTech(tribeAliases.Allies, civ.getTech(75)) then
	justOnce("warnOfSecondFront", function()
		civ.ui.text(func.splitlines(textAliases.secondFrontText1))
        --newspaper.addToNewspaper(state.newspaper.germans,"Second Front",textAliases.secondFrontText1)
        text.addToArchive(tribeAliases.Germans,textAliases.secondFrontText1,"Second Front","Second Front")
		end)
	end
	
    -- Allied turn special target event
    if tribe == tribeAliases.Allies then
        --alliedHistoricTargetsAfterAlliedProduction()
    end
    -- German turn special target event
    if tribe == tribeAliases.Germans then
        --alliedHistoricTargetsAfterGermanProduction()
    end
    if tribe == tribeAliases.Allies then
        state.cityDockings = {}
    end
    if tribe == tribeAliases.Germans then
        incrementCounter("GermanScore", specialNumbers.germanScoreIncrementOnTurn)
        if counterValue("GermanScore") < specialNumbers.minimumGermanPoints then
            setCounter("GermanScore", specialNumbers.minimumGermanPoints)
        --elseif counterValue("GermanScore") >= specialNumbers.germanVictoryThreshold then
        --    civ.ui.text(textAliases.germanPointsVictory)
        end
    end
    if tribe == tribeAliases.Allies then
        overTwoHundred.resistanceSpying()
    end
    if turn == 1 then
        text.simple("Make sure you set the 'Always wait at end of turn.' game option.")
    end
    for unit in civ.iterateUnits() do
        if unit.owner == tribe then
            reHomePayloadUnit(unit,true)
        end
    end

    if tribe == tribeAliases.Allies then
        tribeAliases.Allies.money = math.max(0,tribeAliases.Allies.money-counterValue("FloatMoney"))
        setCounter("FloatMoney",math.max(0,specialNumbers.moneySafeFromRefineryKill-tribeAliases.Germans.money))
        tribeAliases.Germans.money = tribeAliases.Germans.money+counterValue("FloatMoney")
    elseif tribe==tribeAliases.Germans then
        tribeAliases.Germans.money = math.max(0,tribeAliases.Germans.money - counterValue("FloatMoney"))
        setCounter("FloatMoney",math.max(0,specialNumbers.moneySafeFromRefineryKill-tribeAliases.Allies.money))
        tribeAliases.Allies.money = tribeAliases.Allies.money+counterValue("FloatMoney")
    end
    local barbBomb = civ.createUnit(unitAliases.Thousandlb, civ.getTribe(0),civ.getTile(
                                        specialNumbers.radarSafeTile[1],
                                        specialNumbers.radarSafeTile[2],
                                        specialNumbers.radarSafeTile[3]))
    for factoryUnit in civ.iterateUnits() do
        local uType = factoryUnit.type
        if factoryUnit.owner == tribe and factoryUnit.homeCity and (not factoryUnit.homeCity:hasImprovement(improvementAliases.firefighters))
            -- arson targets
        and (uType==unitAliases.Industry1 or uType==unitAliases.Industry2
        or uType==unitAliases.Industry3 or uType==unitAliases.Refinery1 
        or uType==unitAliases.Refinery2 or uType==unitAliases.Refinery3 
        or uType==unitAliases.ACFactory1 or uType==unitAliases.ACFactory2 
        or uType==unitAliases.ACFactory3 or uType==unitAliases.Railyard) then
            if tribe == tribeAliases.Allies then
                if math.random() < specialNumbers.alliedSabotageChance then
                    doOnUnitKilled(factoryUnit,barbBomb)
                    civ.deleteUnit(factoryUnit)
                    text.displayNextOpportunity(tribeAliases.Allies,
                        text.substitute(textAliases.alliedMessageForAlliedFactoryFire,{uType.name,factoryUnit.homeCity.name}),
                        "Arson in "..factoryUnit.homeCity.name,
                        "Arson in "..factoryUnit.homeCity.name)
                    text.displayNextOpportunity(tribeAliases.Germans,
                        text.substitute(textAliases.germanMessageForAlliedFactoryFire,{uType.name,factoryUnit.homeCity.name}),
                        "Arson in "..factoryUnit.homeCity.name,
                        "Arson in "..factoryUnit.homeCity.name)


                end

            elseif isGermanCity(factoryUnit.homeCity) then
                if math.random() < specialNumbers.germanSabotageChance then
                    doOnUnitKilled(factoryUnit,barbBomb)
                    civ.deleteUnit(factoryUnit)
                    text.displayNextOpportunity(tribeAliases.Allies,
                        text.substitute(textAliases.alliedMessageForGermanFactoryFire,{uType.name,factoryUnit.homeCity.name}),
                        "Arson in "..factoryUnit.homeCity.name,
                        "Arson in "..factoryUnit.homeCity.name)
                    text.displayNextOpportunity(tribeAliases.Germans,
                        text.substitute(textAliases.germanMessageForGermanFactoryFire,{uType.name,factoryUnit.homeCity.name}),
                        "Arson in "..factoryUnit.homeCity.name,
                        "Arson in "..factoryUnit.homeCity.name)

                end

            else
                if math.random() < specialNumbers.occupiedSabotageChance then
                    doOnUnitKilled(factoryUnit,barbBomb)
                    civ.deleteUnit(factoryUnit)
                    text.displayNextOpportunity(tribeAliases.Allies,
                        text.substitute(textAliases.alliedMessageForOccupiedFactoryFire,{uType.name,factoryUnit.homeCity.name}),
                        "Arson in "..factoryUnit.homeCity.name,
                        "Arson in "..factoryUnit.homeCity.name)
                    text.displayNextOpportunity(tribeAliases.Germans,
                        text.substitute(textAliases.germanMessageForOccupiedFactoryFire,{uType.name,factoryUnit.homeCity.name}),
                        "Arson in "..factoryUnit.homeCity.name,
                        "Arson in "..factoryUnit.homeCity.name)

                end
            end
        end
    end
    civ.deleteUnit(barbBomb)
        
end
console.afterProduction = function() afterProduction(civ.getTurn(),civ.getCurrentTribe()) end


------------------------------------------------------------------------------------------------------------------------------------------------
local AAMunitionsTable = {}
local firstCombatRound = true
-- inFirestorm prevents infinite loop in recursion,
-- will be nil when called by the game when a unit is killed
-- doOnUnitKilled was defined as nil above, so it could be used in afterProduction
 doOnUnitKilled=function(loser, winner,inFirestorm)
    firstCombatRound = true
    --resetProductionValues()
    log.onUnitKilled(winner,loser)
    --cr.addCombatEntry(state.cHistTable,loser,winner)
    -- Function that controls special targets
    --alliedHistoricTargetsUnitKilled(winner,loser)
    -- uBoat re-creater
    uBoatSurvival(winner,loser)
    -- vet status for munition user code
    --
    if (winner.type == unitAliases.Urban1 or winner.type == unitAliases.Urban2 or winner.type == unitAliases.Urban3) and winner.homeCity and (not isGermanCity(winner.homeCity)) and loser.owner == tribeAliases.Allies then
        justOnce("DoNotBomb"..winner.homeCity.name.."Message",function ()
            text.simple(text.substitute("The residents of %STRING1 are under German occupation!  It would be bad politics for us to make direct attacks against the civilian population of our allies.  It would be preferable to have the Americans try a daylight attack on the target we actually wish to destroy.  We lose %STRING2 points for every Urban Center we destroy in an occupied city.",{winner.homeCity.name,-specialNumbers.alliedScoreIncrementKillOccupiedUrban}),"Foreign Minister")
        end)
    end
    if winner.type.move == 0 and winner.homeCity and isGermanCity(winner.homeCity) and (loser.type.flags & 0x1000 == 0x1000) then
        local lastMunitionUser = civ.getUnit(state.mostRecentMunitionUserID)
        -- guard in case the unit id table got shuffled
        if lastMunitionUser then
            local distance = (math.abs(winner.location.x - lastMunitionUser.location.x)+
                    math.abs(winner.location.y - lastMunitionUser.location.y))//2
                    -- remove the -1 from the winner location, since the winner is adjacent to where the munition was generated
            if --[[distance <= loser.type.move and]] (not AAMunitionsTable[loser.type.id]) then
                local validMunition = false
                for __, secondAttackUnit in pairs(secondaryAttackUnitTypes) do
                    if secondAttackUnit.unitType == lastMunitionUser.type and secondAttackUnit.munitionCreated == loser.type then
                        validMunition = true
                        break
                    end
                end
                if not validMunition then
                    for __, artilleryUnit in pairs(artilleryUnitTypes) do
                        if artilleryUnit.unitType == lastMunitionUser.type and artilleryUnit.munitionCreated == loser.type then
                            validMunition = true
                            break
                        end
                    end
                end
                if validMunition and not lastMunitionUser.veteran then
                    text.simple(text.substitute("Having flown to Germany and attacked a target, the crew of our %STRING1 can now be considered Ace.",{lastMunitionUser.type.name}),"Defense Minister")
                    lastMunitionUser.veteran = true
                end
            end
        end
    end
    if winner.type.flags & 0x1000 == 0x1000 then
        -- winner is a munition
        local lastMunitionUser = civ.getUnit(state.mostRecentMunitionUserID)
        -- guard in case the unit id table got shuffled
        if lastMunitionUser then
            local distance = (math.abs(winner.location.x - lastMunitionUser.location.x)+
                    math.abs(winner.location.y - lastMunitionUser.location.y))//2
            if distance <= winner.type.move -1  then
                local validMunition = false
                for __, secondAttackUnit in pairs(secondaryAttackUnitTypes) do
                    if secondAttackUnit.unitType == lastMunitionUser.type and secondAttackUnit.munitionCreated == winner.type then
                        validMunition = true
                        break
                    end
                end
                if not validMunition then
                    for __, artilleryUnit in pairs(artilleryUnitTypes) do
                        if artilleryUnit.unitType == lastMunitionUser.type and artilleryUnit.munitionCreated == winner.type then
                            validMunition = true
                            break
                        end
                    end
                end
                if validMunition and lastMunitionUser.type.domain == 1 and lastMunitionUser.owner == tribeAliases.Germans then
                    local points = aircraftPointValues[loser.type.id] or 0
                    if points > 0 then
                        justOnce("aircraftKillsIntro", function ()
                        local text1 = [[The Jagdflieger faced a wide variety of opponents across three fronts during the war. While the enormous victory tallies reported from the Russian Front were numerically impressive, it was generally agreed that Western pilots and aircraft were more challenging adversaries. The Luftwaffe High Command made an effort to officially recognize this and take it into account when awarding medals. On the Western Front, the destruction of different Allied aircraft earned pilots different "points." One point was awarded for the destruction of a single-engine fighter, and two points were awarded for destroying a twin-engine bomber. It was recognized that knocking the four-engine "heavies" out of the sky was a monumental task for any one pilot. Thus, the pilot who managed to knock the bomber out of formation was credited with a "separation" and earned 2 points. The pilot who finished off the cripple earned one point for its final destruction.]]
                        local text2 = [[The same points system is featured in Over the Reich, and it will be used to determine when many of the German "Experten" come online. Keep shooting down and destroying Allied aircraft, and various Experten will arrive to bolster your defenses.]] 
                        local theText = text1.."%PAGEBREAK"..text2
                        text.simple(theText,"Experten")
                        text.addToArchive(tribeAliases.Germans,theText,"Aircraft Kills Points","Aircraft Kills Points")
                    end)
                        incrementCounter("GermanAircraftKills",points)
                    end
                end
                    
                if validMunition and not winner.veteran and not lastMunitionUser.veteran and (math.random() < specialNumbers.munitionVeteranChance
                    or (loser.type.move == 0 and loser.homeCity and isGermanCity(loser.homeCity)) )then
                    local message = civ.ui.createDialog()
                    message.title = "Defense Minister"
                    message:addText("For valor in combat, our "..lastMunitionUser.type.name.." unit has been promoted to Ace status.")
                    message:show()
                    lastMunitionUser.veteran = true
                end
            end
        end
    end

    -- remove radar marker after defeat on a tile
    if loser.location and radar.hasRadarMarker(loser.location,radarMarkerType) then
        radar.removeRadarMarker(loser.location,radarMarkerType,
                            civ.getTile(specialNumbers.radarSafeTile[1],
	                                    specialNumbers.radarSafeTile[2],
	                                    specialNumbers.radarSafeTile[3]),
	                        state.radarRemovalInfo,unitAliases.spotterUnit)
    end
	--[[ by Knighttime ]]
	if civ.getTile(loser.x, loser.y, loser.z) ~= nil then
		local tileId = getTileId(loser.location)
		if tileLookup[tileId] ~= nil then		-- Check that an entry for this location exists in the table
			-- Verification:
			if loser.type.id ~= improvementUnitTerrainLinks[tileLookup[tileId].improvementId].unitTypeId then
				-- This will happen whenever a *non-event-created* unit is killed on a tile that *can* hold an event-created unit
				-- It doesn't necessarily indicate a problem with the Lua events
				print("    Unit type killed = " .. loser.type.id .. ", event unit type for " .. loser.x .. "," .. loser.y .. "," .. loser.z .. " = " .. improvementUnitTerrainLinks[tileLookup[tileId].improvementId].unitTypeId)
			elseif loser.homeCity.id ~= tileLookup[tileId].cityId then
				-- This shouldn't happen.  If the unit is the type we expect to be created here by events,
				-- its home city should match what we would have built here
				print("ERROR: city mismatch found, unit city = " .. loser.homeCity.id .. ", tile city = " .. tileLookup[tileId].cityId)
			else
				-- A. Destroy a city improvement:
				local improvementToRemove = civ.getImprovement(tileLookup[tileId].improvementId)
				local cityToRemoveImprovementFrom = civ.getCity(tileLookup[tileId].cityId)
				civ.removeImprovement(cityToRemoveImprovementFrom, improvementToRemove)
				print("Removed " .. improvementToRemove.name .. " improvement from " .. cityToRemoveImprovementFrom.name)
				
				-- B. Change the terrain type on one or more tiles, on one or more maps:
				changeAllTerrain(tileLookup[tileId].improvementId, "destroy", tileLookup[tileId].allLocations)
				
			end
		else
			--print("    Detected unit killed, but no \"tileLookup\" entry found for " .. loser.x .. "," .. loser.y .. "," .. loser.z)
		end
	end
	local replacementUnit = nil
	-- Code for units to "survive" destruction by being re-created as a different unit
	if civ.getTile(loser.location.x,loser.location.y,loser.location.z) ~= nil then
	    local tile = loser.location
	    for __, unitSurvivalInfo in pairs(survivingUnitTypes) do
	        if loser.type == unitSurvivalInfo.unitType then
	            local quantityToProduce = unitSurvivalInfo.replacingQuantity or 1
	            if math.random() <= (quantityToProduce - math.floor(quantityToProduce)) then
	                quantityToProduce = math.ceil(quantityToProduce)
	            else 
	                quantityToProduce = math.floor(quantityToProduce)
	            end
	            local replacingHome = nil
	            if unitSurvivalInfo.preserveHome then
	                replacingHome = loser.homeCity
	            end
	            local replacingVetStatus = unitSurvivalInfo.replacementVetStatus or false 
	            if unitSurvivalInfo.preserveVetStatus then
	                replacingVetStatus = loser.veteran
	            end
	            for i=1,quantityToProduce do
	                local newUnit = civ.createUnit(unitSurvivalInfo.replacingUnit,loser.owner,loser.location)
	                newUnit.homeCity = replacingHome
	                newUnit.veteran = replacingVetStatus
                    replacementUnit = newUnit
	            end --1st instance for i=1,quantityToProduce
	            if unitSurvivalInfo.bonusUnit then
	                quantityToProduce = unitSurvivalInfo.bonusUnitQuantity or 1
	                if math.random() <= (quantityToProduce - math.floor(quantityToProduce)) then
	                    quantityToProduce = math.ceil(quantityToProduce)
	                else 
	                    quantityToProduce = math.floor(quantityToProduce)
	                end	   
	                for i=1,quantityToProduce do
	                    local newUnit = civ.createUnit(unitSurvivalInfo.bonusUnit,loser.owner,loser.location)
	                    newUnit.homeCity = nil
	                    newUnit.veteran = false
	                end --2nd instance for i=1,quantityToProduce   
	            end -- end if unitSurvivalInfo.bonusUnit       
	        end -- loser.type == unitSurvivalInfo.unitType
	    end -- for unitSurvivalInfo in pairs(survivingUnitTypes)
	end--civ.getTile(...
	if loser.owner == tribeAliases.Allies and outOfRangeCheck(loser, escortableBombers) then
	    --civ.ui.text("Bomber increment.")
	    incrementCounter("KillsOutsideEscortRange",1)
	end

	if loser.owner == tribeAliases.Allies then
	    
	    if loser.type == unitAliases.Convoy then
	    incrementCounter("GermanScore",specialNumbers.germanScoreIncrementSinkFreighter)
	    elseif loser.type == unitAliases.Refinery1 or loser.type == unitAliases.Refinery2 or loser.type == unitAliases.Refinery3 then
				tribeAliases.Allies.money = math.min(tribeAliases.Allies.money,math.max(tribeAliases.Allies.money+specialNumbers.refineryKilledMoney,specialNumbers.moneySafeFromRefineryKill))
	    elseif loser.type == unitAliases.B17F or loser.type == unitAliases.B17G then
			justOnce("firstB17attacked",function () 
                civ.ui.text(func.splitlines(textAliases.flyingFortress1)) 
                text.addToArchive(tribeAliases.Germans,textAliases.flyingFortress1,"Flying Fortress","Flying Fortress")
            end) 
		incrementCounter("GermanScore",.75*specialNumbers.germanScoreIncrementKillHeavyBomber)
	    elseif loser.type == unitAliases.damagedB17F or loser.type == unitAliases.damagedB17G then
			justOnce("firstB17destroyed",function () 
            civ.ui.text(func.splitlines(textAliases.bomberText1))
			civ.ui.text(func.splitlines(textAliases.bomberText2))
			civ.ui.text(func.splitlines(textAliases.bomberText3))
			civ.ui.text(func.splitlines(textAliases.bomberText4))
			civ.ui.text(func.splitlines(textAliases.bomberText5))
			civ.ui.text(func.splitlines(textAliases.bomberText6))			
            local message = textAliases.bomberText1.."%PAGEBREAK"..
                            textAliases.bomberText2.."%PAGEBREAK"..
                            textAliases.bomberText3.."%PAGEBREAK"..
                            textAliases.bomberText4.."%PAGEBREAK"..
                            textAliases.bomberText5.."%PAGEBREAK"..
                            textAliases.bomberText6
            text.addToArchive(tribeAliases.Germans,message,"Adolf Galland Memo","Adolf Galland Memo")
        end)
	        incrementCounter("GermanScore",.25*specialNumbers.germanScoreIncrementKillHeavyBomber)
	    elseif loser.type == unitAliases.FifteenthAF or loser.type == unitAliases.B24J or loser.type == unitAliases.Stirling or loser.type == unitAliases.Halifax or loser.type == unitAliases.Lancaster then
	        incrementCounter("GermanScore",specialNumbers.germanScoreIncrementKillHeavyBomber)
	    elseif loser.type == unitAliases.Urban1 or loser.type == unitAliases.Urban2 or loser.type == unitAliases.Urban3 then
	        incrementCounter("GermanScore",specialNumbers.germanScoreIncrementKillAlliedUrban)
            -- this prevents the Allies from gaining points if they've recently had an urban
            -- target killed in England.  Liberated cities don't count
            if loser.homeCity.location.landmass == 3 and (winner.type == unitAliases.V1 or winner.type == unitAliases.V2) then
                -- add 1 to the rocket points turns, since the counter will be decremented
                -- before the Allies get a chance to move
                setCounter("RocketPointDelay",specialNumbers.rocketPointsTurns+1)
                text.displayNextOpportunity(tribeAliases.Allies,text.substitute(textAliases.rocketPolitics,
                {"turn "..tostring(counterValue("RocketPointDelay")+civ.getTurn())}),"Target Priority Directive","Target Priority Directive")

            end

	    end
	end
    local function rocketPointAmount(rawPoints)
        if counterValue("RocketPointDelay")>0 then
            return specialNumbers.rocketPointMultiplier*rawPoints
        else
            return rawPoints
        end
    end
	if loser.owner == tribeAliases.Germans then
	    if loser.type.domain == 1 and not (loser.type.flags & 2^12 == 2^12) then
	    incrementCounter("AlliedScore", specialNumbers.alliedScoreIncrementDestroyPlane)
	    --incrementCounter("GermanScore", -specialNumbers.alliedScoreIncrementDestroyPlane)
		elseif loser.type == unitAliases.Industry1 or loser.type == unitAliases.Industry2 or loser.type == unitAliases.Industry3 then
	    incrementCounter("AlliedScore",rocketPointAmount(specialNumbers.alliedScoreIncrementKillIndustry))
	    --incrementCounter("GermanScore",-specialNumbers.alliedScoreIncrementKillIndustry)
		elseif loser.type == unitAliases.Railyard then
		incrementCounter("AlliedScore",rocketPointAmount(specialNumbers.alliedScoreIncrementKillRailyard))
		elseif loser.type == unitAliases.MilitaryPort then
		incrementCounter("AlliedScore",rocketPointAmount(specialNumbers.alliedScoreIncrementKillGermanPort))
	    elseif loser.type == unitAliases.Refinery1 or loser.type == unitAliases.Refinery2 or loser.type == unitAliases.Refinery3 then
	    	    incrementCounter("AlliedScore",rocketPointAmount(specialNumbers.alliedScoreIncrementKillRefinery))
				tribeAliases.Germans.money = math.min(tribeAliases.Germans.money,math.max(tribeAliases.Germans.money+specialNumbers.refineryKilledMoney,specialNumbers.moneySafeFromRefineryKill))
	    --incrementCounter("GermanScore",-specialNumbers.alliedScoreIncrementKillRefinery)
	    elseif loser.type == unitAliases.ACFactory1 or loser.type == unitAliases.ACFactory2 or loser.type == unitAliases.ACFactory3 then	    
	    incrementCounter("AlliedScore",rocketPointAmount(specialNumbers.alliedScoreIncrementKillFactory))
	    --incrementCounter("GermanScore",-specialNumbers.alliedScoreIncrementKillFactory)
	    elseif loser.type == unitAliases.Urban1 or loser.type == unitAliases.Urban2 or loser.type == unitAliases.Urban3 then
	        if isGermanCity(loser.homeCity) then
	            incrementCounter("AlliedScore",rocketPointAmount(specialNumbers.alliedScoreIncrementKillGermanUrban))
	            --incrementCounter("GermanScore",-specialNumbers.alliedScoreIncrementKillGermanUrban)
	        else
	            incrementCounter("AlliedScore",specialNumbers.alliedScoreIncrementKillOccupiedUrban)
	            --incrementCounter("GermanScore",-specialNumbers.alliedScoreIncrementKillOccupiedUrban)
	        end
        elseif loser.type == unitAliases.V1Launch or loser.type == unitAliases.V2Launch then
            setCounter("RocketPointDelay",-1) -- set to -1, since 0 triggers a message
            text.displayNextOpportunity(tribeAliases.Allies, text.substitute(textAliases.launchSiteDestroyed,{loser.type.name}),loser.type.name.." Destroyed",loser.type.name.." Destroyed")

	    end
	end
    killPortExtras(winner,loser)
    if loser.type == unitAliases.AlliedArmyGroup or loser.type == unitAliases.GermanArmyGroup then
        if winner.type.flags & 0x1000 == 0x1000 and loser.owner ~= civ.getCurrentTribe() and
            loser.location.terrainType % 16 ~= 10 then
            local newUnit = civ.createUnit(loser.type,loser.owner,loser.location)
            newUnit.veteran = loser.veteran
            newUnit.order = loser.order
            newUnit.attributes = loser.attributes
            newUnit.damage = loser.damage

        elseif loser.owner == civ.getCurrentTribe() then
            disorderlyFriendlyBattleGroupRetreat(loser,winner.location)
        else
            disorderlyEnemyBattleGroupRetreat(loser)
        end
    end
    if loser.type == unitAliases.AlliedBatteredArmyGroup or loser.type == unitAliases.GermanBatteredArmyGroup then
        if winner.type.flags & 0x1000 == 0x1000 and loser.owner ~= civ.getCurrentTribe() and
            loser.location.terrainType % 16 ~= 10 then
            local newUnit = civ.createUnit(loser.type,loser.owner,loser.location)
            newUnit.veteran = loser.veteran
            newUnit.order = loser.order
            newUnit.attributes = loser.attributes
            newUnit.damage = loser.damage
        elseif loser.owner == tribeAliases.Allies then
            overTwoHundred.startAlliedReinforcementDepletedDefeated()
        end
    end
	
	if loser.type == unitAliases.EgonMayer then 
		justOnce("EgonMayerKilled",function () 
            text.displayNextOpportunity({tribeAliases.Allies,tribeAliases.Germans},textAliases.EgonMayerKilled,"Egon Mayer Killed","Egon Mayer Killed") 
        end)
		tribeAliases.Germans.money = math.min(tribeAliases.Germans.money,math.max(specialNumbers.moneySafeFromRefineryKill,tribeAliases.Germans.money+specialNumbers.ExpertenKilledMoney))
	end
	
	if loser.type == unitAliases.HermannGraf then 
		justOnce("HermannGrafKilled",function () text.displayNextOpportunity({tribeAliases.Allies,tribeAliases.Germans},textAliases.HermannGrafKilled,"Hermann Graf Killed","Hermann Graf Killed") end)
		tribeAliases.Germans.money = math.min(tribeAliases.Germans.money,math.max(specialNumbers.moneySafeFromRefineryKill,tribeAliases.Germans.money+specialNumbers.ExpertenKilledMoney))
	end
	
	if loser.type == unitAliases.JosefPriller then 
		justOnce("JosefPrillerKilled",function () text.displayNextOpportunity({tribeAliases.Allies,tribeAliases.Germans},textAliases.JosefPrillerKilled,"Josef Priller Killed","Josef Priller Killed") end)
		tribeAliases.Germans.money = math.min(tribeAliases.Germans.money,math.max(specialNumbers.moneySafeFromRefineryKill,tribeAliases.Germans.money+specialNumbers.ExpertenKilledMoney))
	end
	
	if loser.type == unitAliases.hwSchnaufer then 
		justOnce("hwSchnauferKilled",function () text.displayNextOpportunity({tribeAliases.Allies,tribeAliases.Germans},textAliases.hwSchnauferKilled,"Heinz-Wolfgang Schaufer Killed","Heinz-Wolfgang Schaufer Killed") end)
		tribeAliases.Germans.money = math.min(tribeAliases.Germans.money,math.max(specialNumbers.moneySafeFromRefineryKill,tribeAliases.Germans.money+specialNumbers.ExpertenKilledMoney))
	end
	
	if loser.type == unitAliases.AdolfGalland then 
		justOnce("AdolfGallandKilled",function () text.displayNextOpportunity({tribeAliases.Allies,tribeAliases.Germans},textAliases.AdolfGallandKilled,"Adolf Galland Killed","Adolf Galland Killed") end)
		tribeAliases.Germans.money = math.min(tribeAliases.Germans.money,math.max(specialNumbers.moneySafeFromRefineryKill,tribeAliases.Germans.money+specialNumbers.ExpertenKilledMoney))
	end
    overTwoHundred.escapeIntoNight(winner,loser)
    -- firestorm code
    -- checks if there are few enough clouds for firestorms
    local function firestormWeatherCheck(city)
        local cloudCount = 0
        local tileTable = {}
        radar.diamond(city.location,specialNumbers.cloudExclusionRadius,tileTable,true)
        for __,tile in pairs(tileTable) do
            if tile.z >=1 and tile.terrainType % 16 == 5 then
                cloudCount = cloudCount+1
            end
        end
        return cloudCount <= specialNumbers.maximumClouds
    end
    if (loser.type == unitAliases.Urban1 or loser.type == unitAliases.Urban2 or loser.type == unitAliases.Urban3) and (not inFirestorm) then
        local victimCity = loser.homeCity
        if victimCity:hasImprovement(improvementAliases.firefighters) then
            victimCity:removeImprovement(improvementAliases.firefighters)
        elseif math.random() < specialNumbers.firestormChance and firestormWeatherCheck(victimCity) then
            for burningUnit in civ.iterateUnits() do
                local uType = burningUnit.type
                if burningUnit.homeCity==victimCity and burningUnit ~=loser and
                    (uType==unitAliases.Industry1 or uType==unitAliases.Industry2
                    or uType==unitAliases.Industry3 or uType==unitAliases.Refinery1 
                    or uType==unitAliases.Refinery2 or uType==unitAliases.Refinery3 
                    or uType==unitAliases.Urban1 or uType==unitAliases.Urban2 
                    or uType==unitAliases.Urban3 or uType==unitAliases.Railyard
                    or uType==unitAliases.MilitaryPort or uType==unitAliases.SpecialTarget) then
                    doOnUnitKilled(burningUnit,winner,true)
                    civ.deleteUnit(burningUnit)
                end
            end
            if winner.owner == tribeAliases.Germans or (winner.owner == tribeAliases.Allies and isGermanCity(victimCity)) then
                text.displayNextOpportunity(winner.owner,text.substitute(textAliases.attackerFirestormText,{victimCity.name}),"Firestorm in "..victimCity.name,"Firestorm in "..victimCity.name)
                text.displayNextOpportunity(victimCity.owner,text.substitute(textAliases.defenderFirestormText,{victimCity.name,winner.owner.adjective}),"Firestorm in "..victimCity.name,"Firestorm in "..victimCity.name)
            else
                text.displayNextOpportunity(tribeAliases.Allies,text.substitute(textAliases.firestormInOccupiedCityAllies,{victimCity.name}),"Firestorm in "..victimCity.name,"Firestorm in "..victimCity.name)
                text.displayNextOpportunity(tribeAliases.Germans,text.substitute(textAliases.firestormInOccupiedCityGermans,{victimCity.name}),"Firestorm in "..victimCity.name,"Firestorm in "..victimCity.name)
                incrementCounter("GermanScore",specialNumbers.occupiedFirestormGermanPointBounus)
            end
        end
    end
    local uType = loser.type
    if (uType==unitAliases.Industry1 or uType==unitAliases.Industry2
       or uType==unitAliases.Industry3 or uType==unitAliases.Refinery1 
       or uType==unitAliases.Refinery2 or uType==unitAliases.Refinery3 
       or uType==unitAliases.Urban1 or uType==unitAliases.Urban2 
       or uType==unitAliases.Urban3 or uType==unitAliases.Railyard)
       then
        if math.random() < specialNumbers.dayAttackFirefightersKillChance then
            loser.homeCity:removeImprovement(improvementAliases.firefighters)
        end
           
    end
    -- replacementUnit will be nil if no unit is replaced
    -- some stuff will use the returned unit of the unit killed function
    return replacementUnit
	
end
civ.scen.onUnitKilled(doOnUnitKilled)
overTwoHundred.doOnUnitKilled = function () return doOnUnitKilled end

function overTwoHundred.calculateCombatReady(tile)
    -- want to count units with full movement points, and other characteristics
    -- need: all units, full move & full health, full move & 17+ health, vet for each
    local unitDataTable = {}
    local function enterData(unit,typeData)
        typeData.count = typeData.count+1
        if unit.veteran then
            typeData.countVet = typeData.countVet+1
        end
        if unit.moveSpent > 0 then
            return
        end
        typeData.fullMove=typeData.fullMove+1
        if unit.veteran then
            typeData.fullMoveVet = typeData.fullMoveVet+1
        end
        if unit.damage > 3 then
            return
        end
        typeData.fullMove17 = typeData.fullMove17+1
        if unit.veteran then
            typeData.fullMove17Vet=typeData.fullMove17Vet+1
        end
        if unit.damage > 0 then
            return
        end
        typeData.fullMoveHP = typeData.fullMoveHP +1
        if unit.veteran then
            typeData.fullMoveHPVet = typeData.fullMoveHPVet+1
        end
    end
    for unit in tile.units do
        unitDataTable[unit.type.id] = unitDataTable[unit.type.id] or {count=0,countVet=0,fullMove=0,fullMoveVet=0,
        fullMove17=0,fullMove17Vet=0,fullMoveHP=0,fullMoveHPVet=0}
        enterData(unit,unitDataTable[unit.type.id])
    end
    local dataTable = {}
    dataTable[0] = {"Unit Type","All (Vet)","Full Move (Vet)","17+ HP (Vet)","Full HP (Vet)"}
    local dataTableRow = 1
    for unitTypeID =0,127 do
        if unitDataTable[unitTypeID] then
            local ud = unitDataTable[unitTypeID]
            dataTable[dataTableRow]={
            [1]=civ.getUnitType(unitTypeID).name
            ,[2]=tostring(ud.count).." ("..tostring(ud.countVet)..")"
            ,[3]=tostring(ud.fullMove).." ("..tostring(ud.fullMoveVet)..")"
            ,[4]=tostring(ud.fullMove17).." ("..tostring(ud.fullMove17Vet)..")"
            ,[5]=tostring(ud.fullMoveHP).." ("..tostring(ud.fullMoveHPVet)..")"
        }
            dataTableRow = dataTableRow+1
        end
    end
    if dataTable[1] then
        text.simpleTabulation(dataTable,"Combat Readiness Report")
    end
end



------------------------------------------------------------------------------------------------------------------------------------------------
overTwoHundred.cityToDelete = nil
overTwoHundred.checkForAirbase = nil
overTwoHundred.checkForAirbaseOriginalTerrain = nil

civ.scen.onCityFounded(function (city)
--[[
if city.owner == tribeAliases.Germans and city.location.x >= 113 and city.location.x <= 247 and city.location.y >= 111 and city.location.y <= 145 then
    overTwoHundred.cityToDelete = city
    civ.ui.text(textAliases.noAirfieldsInSouthFrance)
    return
end--]]


tile = civ.getCurrentTile()
-- this code will run twice when attempting to build an airbase, once for the original airbase, and once
-- for the alternate airbase that will be created on the other map.  We only want to get one square to check
-- for stuff (and after checking, it is set back to nil), so we only put new information in if it is already nil
overTwoHundred.checkForAirbase = overTwoHundred.checkForAirbase or tile
overTwoHundred.checkForAirbaseOriginalTerrain = overTwoHundred.checkForAirbaseOriginalTerrain or {[0]=civ.getTile(tile.x,tile.y,0).terrainType%16,civ.getTile(tile.x,tile.y,1).terrainType%16,civ.getTile(tile.x,tile.y,2).terrainType%16}
tile.terrainType = 9
civ.addImprovement(city,civ.getImprovement(specialNumbers.newAirfieldImprovementId))
-- This event should be updated once a version of TOTPP comes out where the on city founded routine runs after the city is built, not before
if city.location.z == 0 then --Day airfield constructed, so make night airfield also
    local nightTile = civ.getTile(city.location.x,city.location.y,2)
    if nightTile.city == nil then -- Prevents infinite loop, when city can be founded on either map
        if not (nightTile.defender == city.owner or nightTile.defender == nil) then
            local moveEnemyUnitsTo = getSafeTile(nightTile.defender, nightTile)
            if moveEnemyUnitsTo==false then
                local eastTile = civ.getTile(nightTile.x+2,nightTile.y,nightTile.z)
                local moveFriendlyUnitsTo = getSafeTile(eastTile.defender,eastTile) -- this will always have a valid result in this case, since southeast tile must have friendly units, or enemy could be moved there
                for unit in eastTile.units do
                    unit:teleport(moveFriendlyUnitsTo)
                end
                moveEnemyUnitsTo = eastTile
            end
            for unit in nightTile.units do
                unit:teleport(moveEnemyUnitsTo)
            end
        end -- End case where enemy is on night map where city is to be built
        local nightAirfield = civ.createCity(city.owner,nightTile)
        nightAirfield.name = "New Airfield"
        civ.addImprovement(nightAirfield,civ.getImprovement(specialNumbers.newAirfieldImprovementId))
        nightTile.terrainType = 9
        civ.getTile(nightTile.x,nightTile.y,1).terrainType = 9
        local spotter = civ.createUnit(unitAliases.Photos,city.owner,nightAirfield.location)
        civ.deleteUnit(spotter) -- Spotter makes new city visible on night map.
    end
end

if city.location.z == 2 then --Night airfield constructed, so make day airfield also
    local dayTile = civ.getTile(city.location.x,city.location.y,0)
    if dayTile.city == nil then -- Prevents infinite loop
        if not (dayTile.defender == city.owner or dayTile.defender == nil) then
            local moveEnemyUnitsTo = getSafeTile(dayTile.defender, dayTile)
            if moveEnemyUnitsTo == false then
                local eastTile=civ.getTile(dayTile.x+2,dayTile.y,dayTile.z)
                local moveFriendlyUnitsTo = getSafeTile(eastTile.defender,eastTile)
                for unit in eastTile.units do
                    unit:teleport(moveFriendlyUnitsTo)
                end
                moveEnemyUnitsTo=eastTile
            end
            for unit in dayTile.units do
                unit:teleport(moveEnemyUnitsTo)
            end
        end-- End case where enemy is on day low altitude map where city is to be built
        local dayAirfield = civ.createCity(city.owner,dayTile)
        dayAirfield.name = "New Airfield"
        civ.addImprovement(dayAirfield,civ.getImprovement(specialNumbers.newAirfieldImprovementId))
        dayTile.terrainType = 9
        civ.getTile(dayTile.x,dayTile.y,1).terrainType = 9
        local spotter = civ.createUnit(unitAliases.Photos, city.owner,dayAirfield.location)
        civ.deleteUnit(spotter) -- spotter makes new city visible on day map
    end
end

end)

-- lower weight means "better" unit for next selection
local function customWeightFunction(unit,activeUnit)
    local bestMap = activeUnit.location.z
    local weight = 0
    if activeUnit.type == unitAliases.Flak then
        bestMap = 0
        weight = weight-5
    end
    if unit.type ~= activeUnit.type then
        weight = weight+1
    end
    if bestMap == 2 then 
        if unit.location.z ~= 2 then
            weight = weight+10000
        end
    elseif unit.location.z == 2 then
        weight = weight+10000
    elseif unit.location.z ~= bestMap then
        weight = weight+20
    end
    weight = weight+math.abs(unit.location.x-activeUnit.location.x)+math.abs(unit.location.y-activeUnit.location.y)
    if (activeUnit.type == unitAliases.EarlyRadar or activeUnit.type == unitAliases.AdvancedRadar) and
        (unit.type == unitAliases.EarlyRadar or unit.type == unitAliases.AdvancedRadar) then
        weight = weight-100000
    end
    return weight
end

-- doOnActivateUnit is a local variable, but I want to reference it earlier in the code,
-- so I defined it as nil above
doOnActivateUnit = function(unit,source)
    -- gets better unit selection
    gen.selectNextActiveUnit(unit,source,customWeightFunction)
    --unit = gen.activateBetterUnit(unit,source)
    reHomePayloadUnit(unit)
    overTwoHundred.currentUnitGotoOrder = unit.gotoTile
    trainGoto.trainGotoOnActivate(unit)
    state.formationTable = {}
    state.formationFlag = false
    if civ.isCity(overTwoHundred.cityToDelete) then
        local loc = overTwoHundred.cityToDelete.location
        civ.deleteCity(overTwoHundred.cityToDelete)
        -- airbase being deleted, turn tile to rubble
        if loc.terrainType%16 == 9 then
            civ.getTile(loc.x,loc.y,0).terrainType = 13
            civ.getTile(loc.x,loc.y,1).terrainType = 11
            civ.getTile(loc.x,loc.y,2).terrainType = 11
        end
        overTwoHundred.cityToDelete = nil        
    end
    -- this makes sure that a 'canceled' airbase doesn't 'leave behind' airbase terrain.
    if overTwoHundred.checkForAirbase then
        local tile = overTwoHundred.checkForAirbase
        if not tile.city then
            for index,value in pairs(overTwoHundred.checkForAirbaseOriginalTerrain) do
                if civ.getTile(tile.x,tile.y,index).city then
                    civ.deleteCity(civ.getTile(tile.x,tile.y,index).city)
                end
                civ.getTile(tile.x,tile.y,index).terrainType = value
                print(civ.getTile(tile.x,tile.y,index), value)

            end
        end
        overTwoHundred.checkForAirbase = nil
        overTwoHundred.checkForAirbaseOriginalTerrain = nil
    end

    local activeTribe = civ.getCurrentTribe()
    local activeUnitType = unit.type
    -- change gun attack based on technologies
    if activeUnitType == unitAliases.FiftyCal or activeUnitType == unitAliases.TwentyMM or activeUnitType == unitAliases.ThirtyMM or activeUnitType == unitAliases.Hispanos or activeUnitType == unitAliases.A2ARockets then
        local gunBonus = 0
        if civ.hasTech(activeTribe, civ.getTech(90)) then
            gunBonus = gunBonus+1
        end
        if civ.hasTech(activeTribe, civ.getTech(91)) then
            gunBonus=gunBonus+1
        end
        if civ.hasTech(activeTribe, civ.getTech(92)) then
            gunBonus=gunBonus+1
        end
        unitAliases.FiftyCal.attack = 4 + gunBonus
        unitAliases.TwentyMM.attack = 5 + gunBonus
        unitAliases.ThirtyMM.attack = 6 + gunBonus
		unitAliases.Hispanos.attack = 7 + gunBonus
        unitAliases.A2ARockets.attack = 5+gunBonus
        if unit.veteran then
            activeUnitType.attack = activeUnitType.attack-1
        end
    end
    -- p.g. code for making carriers only carry specific units see useCarrier table above
    -- munitions also use carrier, since otherwise the carrier is air protected
    if useCarrier[unit.type.id] or unit.type.flags & 1<<12 == 1<<12  then
        unitAliases.Carrier.flags = specialNumbers.defaultCarrierFlags
    else
        unitAliases.Carrier.flags = specialNumbers.doNotCarryCarrierFlags
    end
    rearmCarrierUnit(unit)
    -- p.g. code for disallowing certain units to unload outisde of cities
    harbourUnitActivationFunction(unit)
    if unit.location.terrainType % 16 == 10 and harbourUsers[activeUnitType.id] then
        local doNotActivate=false
        local carryingShip = nil
        if unit.carriedBy and unit.carriedBy.location == unit.location then
            carryingShip = unit.carriedBy
        else
            for unitInSquare in unit.location.units do
                if transportShips[unitInSquare.type.id] then
                    carryingShip = unitInSquare
                    break
                end
            end
        end
        if harbourUsers[activeUnitType.id].beachUnloadPenalty then
            local shippingMessage = civ.ui.createDialog()
            shippingMessage.title = "Naval Liaison Officer"
            if carryingShip then
                shippingMessage:addText(func.splitlines("It is more efficient to unload our "..activeUnitType.name..
                    " in a city.  If we unload this unit onto a beach, most of its movement points"..
                    "will be expended, and it and our "..carryingShip.type.name.." may come under enemy fire."))
            else
                shippingMessage:addText(func.splitlines("It is more efficient to unload our "..activeUnitType.name..
                " in a city.  If we unload this unit onto a beach, most of its movement points "..
                "will be expended, and it  may come under enemy fire."))
            end
            shippingMessage:addText(func.splitlines("\n^If you choose to activate this unit, move it off the ship immediately."..
            "  Activating it again will subject it to more enemy fire."))
            shippingMessage:addOption("Do not activate this "..activeUnitType.name..".",1)
            shippingMessage:addOption("We must unload onto this beach.",2)
            local choice = shippingMessage:show()
            if choice == 1 then
                doNotActivate=true
            else
                amphibiousPenalty(unit,carryingShip)
            end
        elseif harbourUsers[activeUnitType.id].onlyUnloadInPort then
            local shippingMessage = civ.ui.createDialog()
            shippingMessage.title = "Naval Liaison Officer"
            if unit.carriedBy and unit.carriedBy.location == unit.location then
            shippingMessage:addText("Our "..activeUnitType.name.." can not be activated at sea "..
                "because it can only be unloaded from our "..unit.carriedBy.type.name.." in a city.")
            else
                -- just in case there is some error and the unit is alone at sea or something
                shippingMessage:addText("Our "..activeUnitType.name.." can not be activated at sea.")
            end
            shippingMessage:show()
            doNotActivate=true
        end
        if doNotActivate then
            if carryingShip then
                local newActiveUnit = carryingShip
                harbourUnitActivationFunction(newActiveUnit)
                newActiveUnit:activate()
                runDoOnActivateUnit()
            else
                -- if the unit isn't being carried by anything, find a unit with 0 movement and
                -- activate that.  Since it can't be activated
                -- the game will then find another suitable unit to activate
                local failsafeUnit = nil
                for potentialUnit in civ.iterateUnits() do
                    if not failsafeUnit and potentialUnit.order == -1 then
                        -- -1 means the unit has no order
                        failsafeUnit = potentialUnit
                    end
                    if potentialUnit.type.move == 0 and potentialUnit.order == -1 then
                        failsafeUnit = nil
                        potentialUnit:activate()
                        -- don't need harbourUnitActivationFunction, since another unit will 
                        -- activate afterward
                        break
                    end
                end
                if failsafeUnit then
                    harbourUnitActivationFunction(failsafeUnit)
                    failsafeUnit:activate()
                end
                runDoOnActivateUnit()
            end
        end
    end


    -- autofire munition auto fire munition
    --if activeUnitType.flags & 0x1000 == 0x1000 and activeUnitType.move == 1 and true then
    --    local offsets = {{0,2},{1,1},{2,0},{1,-1},{0,-2},{-1,-1},{-2,0},{-1,1}}
    --    local center = unit.location
    --    local enemyTile = nil
    --    local noAdjacentEnemiesFound = true
    --    for __,offset in pairs(offsets) do
    --        local t = civ.getTile(center.x+offset[1],center.y+offset[2],center.z)
    --        if t and t.defender ~= nil and t.defender~=unit.owner then
    --            if noAdjacentEnemiesFound then
    --                enemyTile = t
    --                noAdjacentEnemiesFound = false
    --            else
    --                enemyTile = nil
    --                break
    --            end
    --        end
    --    end
    --    if enemyTile then
    --        civ.ui.text("goto placed")
    --        unit.gotoTile = enemyTile
    --    end


    --end
    
    -- functionality to have events after a tribe's production.  This will not happen if the tribe
    -- has no units to activate

    
    if flag("AfterProdTribe"..tostring(activeTribe.id).."NotDone") then
        afterProduction(civ.getTurn(),activeTribe)
        setFlagFalse("AfterProdTribe"..tostring(activeTribe.id).."NotDone")
    end
    if unit.type == unitAliases.GermanFlak or unit.type == unitAliases.FlakTrain or unit.type == unitAliases.AlliedFlak --[[or unit.type == unitAliases.AlliedTaskForce or unit.type == unitAliases.GermanTaskForce]] then
        local inRange = {[0]=false,[1]=false,[2]=false}
        local diamondTiles = {}
        radar.diamond(unit.location,unitAliases.Flak.move,diamondTiles,true)
        for __,checkTile in pairs(diamondTiles) do
            if not (checkTile.defender == unit.owner or checkTile.defender == nil) then
               for checkUnit in checkTile.units do
                   if checkUnit.type.domain == 1 and not(checkUnit.type.flags & 2^12 == 2^12) then
                        inRange[checkTile.z] = true
                    end
                end
            end
        end
        if inRange[0] or inRange[1] or inRange[2] then
            local lowText = (inRange[0] and "\n^Low altitude air raid in progress.") or ""
            local highText = (inRange[1] and"\n^High altitude air raid in progress.") or ""
            local nightText = (inRange[2] and"\n^Night air raid in progress.") or ""
            civ.ui.text(func.splitlines(lowText..highText..nightText))
        end
    end
end--End onActivateUnit instructions
civ.scen.onActivateUnit(doOnActivateUnit)


-- AAMunitions are munitions primarily used against air units
-- These munitions do no damage against unit types in the
-- AAInvulnerableTable
-- needed to reference AAMunitionsTable above, so defined before the
-- function doOnUnitKilled
--local AAMunitionsTable = {}
AAMunitionsTable[unitAliases.Hispanos.id]=true
AAMunitionsTable[unitAliases.A2ARockets.id] = true
AAMunitionsTable[unitAliases.FiftyCal.id]=true
AAMunitionsTable[unitAliases.ThirtyMM.id]=true
AAMunitionsTable[unitAliases.TwentyMM.id]=true
AAMunitionsTable[unitAliases.Flak.id] = true
local AAInvulnerableTable = {}
-- by default, AAInvulnerableTable is the same as stratTargetTable,
-- but this can be modified if necessary
for __,unitType in pairs(stratTargetTable) do
    AAInvulnerableTable[unitType.id]=true
end

local function ineffectiveAAMunitionMessage(attacker,defender)
    local message = "In Over The Reich, some munitions are primarily anti-aircraft and are therefore ineffective against \"large,\" and \"strategic\" targets such as industry and battle groups.  "..
                    "The munition type %STRING1 cannot damage %STRING2 units in this scenario."
    text.simple(text.substitute(message,{attacker.type.name,defender.type.name}),
                "Over the Reich Concepts: Ineffective Munitions")
end

-- the maximum number of hitpoints a munition can do a defending unit in combat
overTwoHundred.maxMunitionDamage = {}
overTwoHundred.maxMunitionDamage[unitAliases.AlliedTaskForce.id] = 3
overTwoHundred.maxMunitionDamage[unitAliases.GermanTaskForce.id] = 3
overTwoHundred.maxMunitionDamage[unitAliases.Carrier.id] = 3

-- overTwoHundred.unitSurvivalChance[unitType.id] = number between 0 and 1
-- this is the probability that a unit killed by a munition will survive
-- so a 20% kill chance is represented by .8 survival chance
-- nil or false means 0 survival chance (i.e. ordinary combat rules apply)
overTwoHundred.unitSurvivalChance = {}

overTwoHundred.unitSurvivalChance[unitAliases.Fw190A8.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.Fw190F.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.He111.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.Do217.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.He277.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.Go229.id] = specialNumbers.defaultSurvivalChance

overTwoHundred.unitSurvivalChance[unitAliases.HermannGraf.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.JosefPriller.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.AdolfGalland.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.hwSchnaufer	.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.Experten.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.EgonMayer.id] = specialNumbers.defaultSurvivalChance

overTwoHundred.unitSurvivalChance[unitAliases.RAFAce.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.USAAFAce.id] = specialNumbers.defaultSurvivalChance

overTwoHundred.unitSurvivalChance[unitAliases.Stirling.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.Halifax.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.Lancaster.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.Pathfinder.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.B24J.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.B17F.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.B17G.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.MedBombers.id] = specialNumbers.defaultSurvivalChance

overTwoHundred.unitSurvivalChance[unitAliases.P47D11.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.P47D25.id] = specialNumbers.defaultSurvivalChance
overTwoHundred.unitSurvivalChance[unitAliases.P47D40.id] = specialNumbers.defaultSurvivalChance

--by default, air units except munitions have this survival chance
--for i=0,127 do
 --   if civ.getUnitType(i) and civ.getUnitType(i).domain == 1 and not (civ.getUnitType(i).flags & 0x1000 == 0x1000) then
 --       overTwoHundred.unitSurvivalChance[i] = specialNumbers.defaultSurvivalChance
 --   end
--end

-- if we want to modify the survival chance based on other factors, we
-- do it in this function
function overTwoHundred.getSurvivalChance(defender,attacker)
    --if attacker.type == unitAliases.A2ARockets then
        -- under this system, rockets can damage but not kill
    --    return 1
    --end
    return overTwoHundred.unitSurvivalChance[defender.type.id] or 0
end

local defenderMaxDamage = 999

local function combatResolutionFunction(defaultResolutionFunction,defender,attacker)
    if firstCombatRound then
        firstCombatRound = false
        if overTwoHundred.maxMunitionDamage[defender.type.id] then
            defenderMaxDamage = defender.damage + overTwoHundred.maxMunitionDamage[defender.type.id]
            if defenderMaxDamage >= defender.type.hitpoints or attacker.type == unitAliases.Barrage then
                -- without this, defender will sometimes survive combat when it should be killed,
                -- since it will take more than the maximum damage, but the attacker will be killed instead
                -- barrages are exempt from maximum damage limitations
                defenderMaxDamage = 999
            end
        else
            defenderMaxDamage = 999
        end
        if AAMunitionsTable[attacker.type.id] and AAInvulnerableTable[defender.type.id] then
            attacker.damage = attacker.type.hitpoints
            ineffectiveAAMunitionMessage(attacker,defender)
            return false
        elseif not checkIfInOperatingRadius(defender) then
            -- units outside the operating radius don't defend themselves
            local messageBody = "Last turn, a "..defender.type.name.." was stationed beyond its maximum operating radius and was attacked.  The unit did not defend itself in combat and was defeated.  Units can't be ordered into combat missions (including firing munitions or making reactive attacks) without the ability to return to base.  A unit's operating radius is its per turn movement multiplied by half its range (rounded down if the range is odd).  A "..defender.type.name.." has an operating radius of "..tostring(physicalRange(defender.type)).."."
            text.displayNextOpportunity(defender.owner,messageBody,"Over the Reich Concepts: Operating Radius","Over the Reich Concepts: Operating Radius")
            defender.damage = defender.type.hitpoints
            return false
        elseif attacker.location.z == 2 then
            local aType = attacker.type
            local dType = defender.type
            if (aType == unitAliases.TwoHundredFiftylb or aType == unitAliases.FiveHundredlb
                or aType == unitAliases.Thousandlb ) 
                and not(dType == unitAliases.SpecialTarget
                or dType == unitAliases.Urban1 or dType == unitAliases.Urban2
                or dType == unitAliases.Urban3 or dType == unitAliases.GermanLightFlak
        		or dType == unitAliases.AlliedLightFlak) then
                attacker.damage = attacker.type.hitpoints
                local message = "At night, bombs are not accurate enough to damage most targets.  They can be "..
                "used against Urban and Critical Industries, as well as "..unitAliases.GermanLightFlak.name.." and "..
                unitAliases.AlliedLightFlak.name..".  No damage was done to the "..defender.type.name.."."
                text.simple(message,"Over the Reich Concepts: Ineffective Munitions")
                return false
            elseif (aType == unitAliases.V2 or aType == unitAliases.V1)  
                and not(dType == unitAliases.SpecialTarget
                or dType == unitAliases.Urban1 or dType == unitAliases.Urban2
                or dType == unitAliases.Urban3) then
                attacker.damage = attacker.type.hitpoints
                local message = "%STRING1 units and %STRING2 units are not accurate"..
                " enough to target anything smaller than a city.  Use them against Urban or Special Targets."..
                "  No damage was done to the %STRING3."
                text.simple(text.substitute(message,{unitAliases.V1.name,unitAliases.V2.name,defender.type.name}),
                    "Over the Reich Concepts: Ineffective Munitions")
                return false
            end
        end
        if flag("PlayingVersusSelf") and (attacker.type.flags & 1<<12 == 1<<12) and math.random() <specialNumbers.munitionFailureProbabilitySP then
            attacker.damage = attacker.type.hitpoints
            return false
        end
    end
    local dType = defender.type
    if defender.damage >= specialNumbers.maxMunitionDamageToArmyGroup 
        and (attacker.type.flags & 0x1000 == 0x1000) and 
        (dType == unitAliases.GermanArmyGroup or dType ==unitAliases.AlliedArmyGroup or
         dType == unitAliases.RedArmyGroup or
         dType == unitAliases.GermanBatteredArmyGroup or dType==unitAliases.AlliedBatteredArmyGroup) then
         attacker.damage = attacker.type.hitpoints
         defender.damage = math.min(defender.damage,specialNumbers.maxMunitionDamageToArmyGroup)
         local message = "Once a "..defender.type.name.." unit has had its hit points reduced below "..
         tostring(defender.type.hitpoints - specialNumbers.maxMunitionDamageToArmyGroup)..", it can no longer be damaged by munitions."..
         "  It must be finished off by a direct attack from another Battle Group."
         text.simple(message,"Over the Reich Concepts: Ineffective Munitions")
         return false
    end
    if defender.damage >= defenderMaxDamage and (attacker.type.flags & 0x1000 == 0x1000) then
        defender.damage = defenderMaxDamage
        attacker.damage = attacker.type.hitpoints
        return false
    end
    if defender.hitpoints <= 0 and math.random() < overTwoHundred.getSurvivalChance(defender,attacker) then
        attacker.damage = attacker.type.hitpoints
        defender.damage = defender.type.hitpoints - specialNumbers.survivalHP
        return false
    end

    return defaultResolutionFunction(attacker,defender)
end

civ.scen.onResolveCombat(combatResolutionFunction)
------------------------------------------------------------------------------------------------------------------------------------------------

print("Events.lua parsed successfully at " .. os.date("%c"))
print("")










--[[
for index,text in pairs(textAliases) do
    local disp = civ.ui.createDialog()
    disp.title = tostring(index)
    disp:addText(text)
    disp:show()
end--]]

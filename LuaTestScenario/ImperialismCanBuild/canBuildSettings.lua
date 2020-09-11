
local object = require("object")
local canBuildFunctions = require("canBuild")

-- canBuildParameters
--      Three tables, one for unitTypes, one for Improvements, one for Wonders
--      absent entry means use the defaultCanBuild function
-- canBuildObjectType[item.id]= {
--      .forbiddenTribes = {[tribeID]=bool}
--          if canBuildObjectType[item.id].forbiddenTribes[tribeID] is true, then the tribe with
--          tribeID can't build item, false or nil/absent means it can
--
--      .forbiddenMaps = {[0] = bool,[1]=bool,[2]=bool,[3]=bool}
--          if canBuildObjectType[item.id].forbiddenMaps[mapCityIsOn] = true, then city can't build the item
--              false or nil means it can
--          absent means all maps are allowed
--      .location = {xCoord,yCoord} or {xCoord,yCoord,zCoord} or tileObject or cityObject or integer or function(tileObject)-->boolean or table of these kinds of objects
--          {xCoord,yCoord} if the city is located at (xCoord,yCoord) on any map, it can build the object
--          {xCoord,yCoord,zCoord} means the city must be located at those coordinates to build the object
--          tileObject means the city must be located at that tile
--          cityObject means the city must be that city
--          function means object can be built if function(city.location) returns true 
--          (and all other conditions are met), and can't be built otherwise
--          table of these things means that each entry in the table is checked, and if any one of them means the object can be built, then it can be built
--          absent means the object can be built at any location
--          (Note: Can't use integers to match city id, since code can't distinguish between several cities and a coordinate triple)
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .forbiddenLocation= {xCoord,yCoord} or {xCoord,yCoord,zCoord} or tileObject or cityObject or function(tileObject)-->boolean or table of these kinds of objects
--              see location details, except that a match in forbidden location prevents the item from being buitl
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .allImprovements = improvementObject or wonderObject or table of improvementObjects and wonderObjects
--          The city must have all improvements/wonders in the table to build the object
--          absent means no improvements needed (in this section)
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .someImprovements = improvementObject or wonderObject or table of improvementObjects and wonderObjects
--          The city must have some number of objects in the table to build the item in question.  The exact
--          number is governed by the next key
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .numberOfImprovements = integer
--          tells how many of the 'someImprovements' are needed to build the item
--          absent means ignore .someImprovements
--      .forbiddenImprovements = improvementObject or wonderObject or table of improvementObjects and wonderObjects
--          The city must have none of the improvements/wonders in the table to build the object
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .allTechs = technologyObject or table of technologyObjects
--          the civ must have all the technologies in the table to build the object
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .someTechs = technologies or table of technologyObjects
--          the civ must have some of the technologies in the table to build the object
--          the number is governed by the next key
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .numberOfTechs = integer
--          tells how many of the 'someTechs' are needed for the object to be built
--      .forbiddenTechs = technologyObject or table of technologyObjects
--          the civ must not have any of the technologies in the table to build the object
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .allFlagsMatch = {[flagKey]=boolean}
--          the city can only build the item if all the flags for the flagKeys in the table have the  
--          corresponding value
--          absent flag key (including [flagKey]=nil) doesn't affect production
--          absent means no restriction
--      .someFlagsMatch = {[flagKey]=boolean}
--          the city can only build the item if all the flags for the flagKeys in the table have the  
--          corresponding value
--          absent flag key (including [flagKey]=nil) doesn't affect production
--          absent means no restriction
--      .numberOfFlags = integer
--          tells how many of the 'someFlags' are needed for the object to be built
--      .minimumPopulation = integer
--          the city must have at least this many citizens to build the item
--          absent means 0
--      .maximumPopulation = integer 
--          the city can have at most this many citizens to build the item
--          absent means no maximum population
--      .earliestTurn = integer
--          item can't be built before this turn
--          absent means no restriction
--      .latestTurn = integer
--          item can't be built after this turn
--          absent means no restriction
--      .allWonders = wonderObject or table of wonderObject
--          the city's tribe must have all these wonders in order to build the item
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .someWonders = wonderObject or table of wonderObject
--          the city's tribe must have some of the wonders in order to build the item
--          the number is governed by the next key
--          absent means no restriction
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .numberOfWonders = integer
--          tells how many of 'someWonders' the tribe must have to build the item
--          absent means no restriction
--
--
--      .overrideDefaultBuildFunction = boolean or nil
--          if true, the in game function for determining if the item can be built is ignored
--          for improvements and wonders, a check will be made if the item has already been built
--          false, nil, absent means the game's regular conditions must also be met
--      .forbiddenAlternateProduction = unitTypeObject or imprvementObject or wonderObject or table of these objects
--          the city can only build the item if city:canBuild(item) returns false for all items in the list
--          Be careful that the 'can build chain' does not form a loop
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .requireSomeAsAlternateProduction = unitTypeObject or improvementObject or wonderObject or table of these objects
--          the city can only build the item if the city can build some of the items in the list
--          Be careful that the 'can build chain' does not form a loop
--          A single entry not in a table will be 'wrapped' with a table in post processing
--      .numberOfAlternateProduction = integer
--          tells how many of 'someAlternateProduction' is required
--          absent means no restriction
--      .conditionFunction = function(defaultBuildFunction,city,item) --> bool
--          if function returns true, item can be built if other conditions are met, if false, item can't be built
--          absent means no extra condition
--      .returnFalse = bool or nil
--          if true, item can't be built
--          if false or nil, refer to other conditions
--          (happens before overrideFunction and alternateParameters)
--      .overrideFunction = function(defaultBuildFunction,city,item) --> boolean
--          if function returns true, the city is automatically allowed to build the item, regardless of any
--          conditions that isn't met
--          if function returns false, the other conditions are checked
--      .alternateParameters = table of itemParameters
--          itemParameters is this table of restrictions on whether a given item can be produced
--          if the item in question satisfies any of the itemParameters in the table, it can be produced,
--          regardless of whether the 'top' itemParameters are satisfied
--          use this (or overrideFunction) if you want to have more than one valid way to produce the item
--          the 'table' format is important.  Unlike other parameters, you must enclose the value of 
--          alternateParameters in a table, even if there is only one itemParameters as the value
--      .computerOnly = bool or nil
--          if true, item can only be built by computer controlled players
--          if false or nil, either human or AI players can build
--          (in conjunction with alternateParameters, this can be used to have different conditions for the
--          ai and human players)
--      .humanOnly = bool or nil
--          if true, item can only be built by human controlled players
--          if false or nil, either human or AI players can build
--          (in conjunction with alternateParameters, this can be used to have different conditions for the
--          ai and human players)
--
--      .onlyBuildCoastal = bool or nil
--          if true, the item can only be built if the city has the 'coastal' flag,
--          that is, in the default game it could build harbors and offshore platforms
--      .onlyBuildShips = bool or nil
--          if true, the item can only be built if the city has the 'ship building' flag
--          that is, in the default game it could build sea units
--      .onlyBuildHydroPlant = bool or nil
--          if true, the item can only be built if the city has the 'can build hydro plant' flag
--          that is, the city could build hydro plants in the default game
--
--

local britishHomeCities = {--[[britain]]{287,35},{286,38},{283,39},{284,34},{285,29},{283,25},
--[[Canada, except Quebec City]]{243,47},{236,48},{228,46},{223,49},{217,39},{212,34},{206,34},{200,32},{192,40},
}
local frenchHomeCities = {civ.getTile(3,51,0),civ.getTile(3,47,0),civ.getTile(2,42,0),civ.getTile(6,44,0),
civ.getTile(284,44,0),civ.getTile(286,46,0),civ.getTile(0,50,0),}

local scotlandCities = {civ.getTile(283,25,0).city,civ.getTile(285,29,0).city}

local nationalTroops = {object.uRiflemen1,object.uRiflemen2,object.uRiflemen3,object.uVoltigeurs,object.uInfantrie1, object.uInfantrie2,object.uImperialTroops,object.uImperialArmy1,object.uImperialArmy2,}

local function isJapan(tile) return tile.landmass == 28 end

local americanSouthCities = {{226,66},{224,70},{223,81},{222,64},{220,70},{220,74},{216,68},{216,72},{216,76},{211,77},{209,75},{208,78},}

local unitTypeBuild = {}
unitTypeBuild[object.uRiflemen1.id] = {location=britishHomeCities}
print(type(unitTypeBuild[object.uRiflemen1.id].location),type(unitTypeBuild[object.uRiflemen1.id].location[1]))
unitTypeBuild[object.uRiflemen2.id] = {location=britishHomeCities}
unitTypeBuild[object.uRiflemen3.id] = {location=britishHomeCities}
unitTypeBuild[object.uHighlanders1.id] ={location=scotlandCities}
unitTypeBuild[object.uHighlanders2.id] ={location=scotlandCities}
-- militia can't be built in cities that can recruit national troops
unitTypeBuild[object.uMilitia.id] = {forbiddenAlternateProduction = nationalTroops}
-- freighters can only be built in towns with a steel mill and world port
unitTypeBuild[object.uFreighter.id] = {allImprovements={object.iWorldPort,object.iSteelMill}}
-- marines can only be recruited in cities where national troops can also be recruited
unitTypeBuild[object.uMarines.id] = {requireSomeAsAlternateProduction=nationalTroops,numberOfAlternateProduction=1}
unitTypeBuild[object.uVoltigeurs.id]= {location=frenchHomeCities}
unitTypeBuild[object.uInfantrie1.id]= {location=frenchHomeCities}
unitTypeBuild[object.uInfantrie2.id]= {location=frenchHomeCities}
unitTypeBuild[object.uImperialTroops.id] = {location=isJapan}
unitTypeBuild[object.uImperialArmy1.id] = {location=isJapan}
unitTypeBuild[object.uImperialArmy2.id] = {location=isJapan}
-- engineer can either be built where national troops can be built, or in cities with universities
-- the capital can build engineers, even without a university or the required tech
local engineerAltCondition1 = {requireSomeAsAlternateProduction=nationalTroops,numberOfAlternateProduction=1}
local engineerAltCondition2 = {allImprovements=object.iCapital, overrideDefaultBuildFunction=true}
unitTypeBuild[object.uEngineers.id] = {allImprovements=object.iUniversity,alternateParameters= {engineerAltCondition1,engineerAltCondition2,}}

-- everyone can build heavy artillery with the tech, but AI civs can build it anytime, so they can be more dangerous 
-- note that even with only one alternate parameter, there are two sets of table constructors, so the alternate parameter is in a table of alternate parameters, even though there is only one
unitTypeBuild[object.uHeavyArtillery.id] = {alternateParameters={{overrideDefaultBuildFunction=true,computerOnly=true}}}
-- agent can only be built by an owner of Diplomatic Corps or Imperial Powers
unitTypeBuild[object.uAgent.id]= {someWonders={object.wDiplomaticCorps,object.wImperialPowers},numberOfWonders=1}

-- before turn 24, cities in the 'American South' can't build USTroops
-- explanation: the alternate parameter allows troops to be built before turn 24, but excludes the 'South'.  The main parameter allows troops to be built after turn 24
unitTypeBuild[object.uUSTroops.id] = {earliestTurn=24, alternateParameters = {{forbiddenLocation=americanSouthCities}}}

local improvementBuild = {}
improvementBuild[object.iSteelMill.id] = {allImprovements={object.iBank},minimumPopulation=8}
improvementBuild[object.iGrandRailwayStation.id] = {someImprovements={object.iLocalIndustry,object.iFactory,object.iWorldPort},numberOfImprovements=2}

local wonderBuild = {}
-- Diplomatic Corps can only be constructed in a capital
wonderBuild[object.wDiplomaticCorps.id] = {allImprovements=object.iCapital}
-- Imperial Powers can only be constructed in a capital, or where the Kremlin is (
wonderBuild[object.wImperialPowers.id] = {someImprovements={object.iCapital,object.wKremlin},numberOfImprovements=1}
-- no particular reason for this restriction, other than testing
--wonderBuild[object.wArmsRace.id] = {overrideDefaultBuildFunction=true,onlyBuildHydroPlant=true}
--wonderBuild[object.wArmsRace.id] = {overrideDefaultBuildFunction=true,onlyBuildCoastal=true}
wonderBuild[object.wArmsRace.id] = {overrideDefaultBuildFunction=true,onlyBuildShips=true}

canBuildFunctions.supplyUnitTypeParameters(unitTypeBuild)
canBuildFunctions.supplyImprovementParameters(improvementBuild)
canBuildFunctions.supplyWonderParameters(wonderBuild)

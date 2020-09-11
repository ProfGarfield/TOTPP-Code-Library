
local object = require("object")
local canBuildFunctions = require("canBuild")
-- Settings for The Cold War 1947 - 1991
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
--          integer means city id must match the integer
--          function means object can be built if function(city.location) returns true 
--          (and all other conditions are met), and can't be built otherwise
--          table of these things means that each entry in the table is checked, and if any one of them means the object can be built, then it can be built
--          absent means the object can be built at any location
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
--



--Only locations that will build Eastern Troops (Europe)
local proEastHomeCities = {{283,35,0},{281,29,0},{285,29,0},{284,34,0},{287,35,0},{286,38,0},{283,39,0},{284,44,0},{286,46,0},{0,50,0},{3,51,0},{3,47,0},
							{2,42,0},{6,44,0},{285,53,0},{287,59,0},{284,58,0},{280,60,0},{282,64,0},{280,60,0},{282,64,0},{11,63,0},{14,60,0},{11,55,0},
							{9,49,0},{10,44,0},{13,45,0},{7,39,0},{7,35,0},{9,33,0},{10,30,0},{7,27,0},{11,37,0},{13,41,0},{16,32,0},{16,36,0},
							{17,41,0},{17,45,0},{18,50,0},{15,49,0},{17,57,0},{20,12,0},{21,57,0},{14,6,0},{19,11,0},{19,21,0},{14,22,0},{14,14,0},
							{9,13,0},{9,19,0},{5,21,0},{5,15,0},}

--Canada, Australia, New Zealand, South Africa
local proWestHomeCities = {{106,152,0},{93,187,0},{111,197,0},{116,198,0},{118,206,0},{120,194,0},{123,183,0},{135,213,0},{137,209,0},{140,204,0},{140,196,0},{232,42,0},
							{229,45,0},{226,44,0},{223,49,0},{217,39,0},{201,39,0},{200,32,0},{192,40,0},{15,191,0},{21,185,0},{22,178,0},{25,185,0},{22,190,0},}



--European Specific Locations

local europeanHomeCities = {{283,35,0},{281,29,0},{285,29,0},{284,34,0},{287,35,0},{286,38,0},{283,39,0},{284,44,0},{286,46,0},{0,50,0},{3,51,0},{3,47,0},
							{2,42,0},{6,44,0},{285,53,0},{287,59,0},{284,58,0},{280,60,0},{282,64,0},{280,60,0},{282,64,0},{11,63,0},{14,60,0},{11,55,0},
							{9,49,0},{10,44,0},{13,45,0},{7,39,0},{7,35,0},{9,33,0},{10,30,0},{7,27,0},{11,37,0},{13,41,0},{16,32,0},{16,36,0},
							{17,41,0},{17,45,0},{18,50,0},{15,49,0},{17,57,0},{20,12,0},{21,57,0},{14,6,0},{19,11,0},{19,21,0},{14,22,0},{14,14,0},
							{9,13,0},{9,19,0},{5,21,0},{5,15,0},{3,37,0}}
							
local britishParatroops = {{285,29,0}}
local frenchForeignLegion = {{0,50,0},{3,51,0},{4,66,0}, {0,68,0}}

--US Specific Locations
local usHomeCities = {{192,44,0},{189,47,0},{190,62,0},{194,70,0},{196,74,0},{198,66,0},{200,72,0},
						{200,58,0},{205,69,0},{205,61,0},{210,68,0},{209,75,0},{208,78,0},{211,77,0},{216,76,0},{216,68,0},
						{215,61,0},{211,55,0},{216,54,0},{213,45,0},{220,52,0},{222,56,0},{220,70,0},{223,81,0},{223,71,0},
						{225,67,0},{226,62,0},{225,51,0},{228,58,0},{229,55,0},{238,94,0},{230,52,0},{175,21,0},{160,92,0},}

local usMarinesBasicTraining = {{223,71,0},{196,74,0}}
local usAirborneBasicTraining = {{220,70,0}}

--Soviet Specific Locations

local ussrHomeCities = {{20,28,0},{22,34,0},{21,41,0},{25,47,0},{25,41,0},{26,32,0},{21,23,0},{25,21,0},{26,6,0},{33,13,0},
						{30,22,0},{30,30,0},{28,50,0},{29,41,0},{33,49,0},{34,42,0},{32,36,0},{36,56,0},{39,57,0},{44,58,0},
						{39,43,0},{37,37,0},{40,34,0},{43,37,0},{36,28,0},{33,25,0},{30,22,0},{33,13,0},{40,28,0},{46,24,0},
						{48,32,0},{51,43,0},{52,24,0},{54,62,0},{56,58,0},{62,50,0},{62,44,0},{61,27,0},{69,29,0},{82,30,0},
						{82,38,0},{95,37,0},{107,51,0},{103,17,0},{117,23,0},{128,34,0},}

local ussrGuards = {{30,30,0},{25,21,0}}

local ussrAirborne = {{61,27,0}}

--Chinese Specific Locations
local chinaHomeCities = {{98,44,0},{102,46,0},{101,51,0},{100,56,0},{93,59,0},{89,59,0},{86,62,0},{96,64,0},{91,67,0},{84,66,0},{78,64,0},{74,58,0},
							{70,56,0},{82,72,0},{86,74,0},{90,76,0},{92,72,0},{95,69,0},{98,72,0},{98,78,0},{96,82,0},{100,84,0},{92,88,0},{94,90,0},
							{88,88,0},{88,84,0},{83,85,0},}
							
local chinaAirborne = {{92,72,0}}
local chinaCommando = {{96,82,0},{93,59,0}}

--India Specific Locations


local gurkhaRecruitment = {{61,79,0},{63,83,0}}

--Different Regions
local Israel = {{29,71}}

local northernAsia = {{107,75,0},{113,69,0},{116,66,0},{115,53,0},{105,67,0},{103,63,0},{102,60,0},{93,43,0},{84,44,0},{73,43,0},
						{98,44,0},{102,46,0},{101,51,0},{100,56,0},{93,59,0},{89,59,0},{86,62,0},{96,64,0},{91,67,0},{84,66,0},{78,64,0},{74,58,0},
							{70,56,0},{82,72,0},{86,74,0},{90,76,0},{92,72,0},{95,69,0},{98,72,0},{98,78,0},{96,82,0},{100,84,0},{92,88,0},{94,90,0},
							{88,88,0},{88,84,0},{83,85,0},}
							
local southEastAsia = {{77,91,0},{78,100,0},{82,98,0},{87,101,0},{87,107,0},{82,106,0},{84,110,0},{81,121,0},{84,126,0},{84,136,0},
						{87,141,0},{91,143,0},{97,139,0},{90,134,0},{90,124,0},{100,128,0},{106,132,0},{119,147,0},{101,115,0},{98,100,0},}

local middleEast = { }

local afghanistan = {{54,70,0},{52,74,0}}

local latinAmerica = { }

local africa = { }

local pirateBases = { {36,124,0},{32,134,0},{34,110,0},{33,93,0},{37,105,0},{234,112,0},{81,121,0},{84,136,0},{100,128,0},{106,132,0},{97,139,0},{90,134,0},{90,124,0},{84,110,0},{87,101,0},{101,115,0},}



local unitTypeBuild = {}

--Most unit types can only be built in home cities.  Those that are shared need "a" home city.
--This means that the U.S. could build artillery, gun trucks, etc. in China if captured.
--This will prevent crashes (when there is nothing to build) and also makes sense.
--A nation's better equipment, and their infantry, can only be built at their "true" home city.
--Many units will require military factories to build.  A few require regular factories.
--Thus, the U.S. and Soviet Union will have an advantage, as they start with the most of these
--factories. 
--Naval units will require "a" home city that has a military port and military industry. 

--NAVAL UNITS
unitTypeBuild[object.uFrigate.id] = {allImprovements={object.iMilitaryPort}}
unitTypeBuild[object.uAegisCruiser.id] = {allImprovements={object.iMilitaryIndustry,object.iMilitaryPort}}
unitTypeBuild[object.uSSK.id] = {allImprovements={object.iMilitaryPort}}
unitTypeBuild[object.uSSNEarly.id] = {allImprovements={object.iMilitaryPort}}
unitTypeBuild[object.uSSNImproved.id] = {allImprovements={object.iMilitaryIndustry,object.iMilitaryPort}}
unitTypeBuild[object.uSSNAdvanced.id] = {allImprovements={object.iMilitaryIndustry,object.iMilitaryPort}}
unitTypeBuild[object.uSSBNEarly.id] = {allImprovements={object.iMilitaryPort}}
unitTypeBuild[object.uSSBNLate.id] = {allImprovements={object.iMilitaryIndustry,object.iMilitaryPort}}
unitTypeBuild[object.uDestroyer.id] = {allImprovements={object.iMilitaryPort}}
unitTypeBuild[object.uCruiser.id] = {allImprovements={object.iMilitaryIndustry,object.iMilitaryPort}}
unitTypeBuild[object.uBattleship.id] = {allImprovements={object.iMilitaryIndustry,object.iMilitaryPort}}
unitTypeBuild[object.uCarrier.id] = {allImprovements={object.iMilitaryIndustry,object.iMilitaryPort}}
unitTypeBuild[object.uNPCarrier.id] = {allImprovements={object.iMilitaryIndustry,object.iMilitaryPort}}

--SHARED EQUIPMENT (NON-NAVAL)
unitTypeBuild[object.uSpitfire.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uF4UCorsair.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uEarlyJet.id] = {allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uStrategicBomber.id] = {allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uAPC.id] = {allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uSPArtillery.id] = {allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uSpyPlane.id] = {allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uFreight.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uAuxiliaryPlane.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uKatyusha.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uFieldArtillery.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uGunTruck.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uMobileAA.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uMRBM.id] = {allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uICBM.id] = {allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uSpy.id] = {allImprovements=object.iIntelligenceAgency}
unitTypeBuild[object.uFreight.id] = {allImprovements=object.iRegionalTrade}
unitTypeBuild[object.uFreighter.id] = {allImprovements=object.iDocks}
unitTypeBuild[object.uSpecialForces.id] = {someImprovements={object.iCapitol,object.iIsrael},numberOfImprovements=1}
unitTypeBuild[object.uCenturion.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uYak9.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uMiG15.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uIl2.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uT3485.id] = {allImprovements=object.iFactory}
unitTypeBuild[object.uSCUDBattery.id] = {allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uPirates.id] = {allImprovements=object.iDocks}

--USA UNITS
--Main American infantry can be built anywhere that is U.S. home soil
unitTypeBuild[object.uUSInf.id] = {location=usHomeCities}
-- US Marines can only be built in San Diego and Charleston, SC
unitTypeBuild[object.uUSMarines.id] ={location=usMarinesBasicTraining}
-- US Airborne are only built in Atlanta (Fort Benning)
unitTypeBuild[object.uUSAirborne.id] ={location=usAirborneBasicTraining}
-- US Heavy Equipment (tanks, aircraft, artillery) can only be built in home cities with a military industry.
unitTypeBuild[object.uA7Corsair.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uA10ThunderboltII.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uF86Sabre.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uF100SuperSabre.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uF4PhantomII.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uF15Eagle.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uF16Falcon.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uF14Tomcat.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uB52Stratofortress.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uB1Lancer.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uBradleyIFV.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uM26Pershing.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uM48Patton.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uM60A1.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uM60A3.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uM1Abrams.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uAH1Cobra.id] = {location=usHomeCities,allImprovements=object.iMilitaryIndustry}


--EUROPEAN Units
--European infantry can only be built in European Home soil (note: this ends at Poland's eastern border).
unitTypeBuild[object.uEuroInf.id] = {location=europeanHomeCities}
--French Foreign Legion can only be built in select cities in France or Algeria
unitTypeBuild[object.uForeignLegion.id] = {location=frenchForeignLegion}
--British paratroops can only be built in Newcastle
unitTypeBuild[object.uUKParas.id] = {location=britishParatroops}
--Euro Heavy Equipment (tanks, aircraft, artillery) can only be built in home cities with a military industry.
unitTypeBuild[object.uHunter.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uSuperMystere.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uMirageIII.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uHarrier.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uMirage2000.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uFiatG91.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uTornado.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uVulcan.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uM47.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uLeopardI.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uChieftan.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uLeopardII.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uCanberra.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uLynx.id] = {location=europeanHomeCities,allImprovements=object.iMilitaryIndustry}

--USSR UNITS
--Soviet infantry can only be built on Soviet home soil (does not include Eastern Europe)
unitTypeBuild[object.uSovietInf.id] = {location=ussrHomeCities}
--Soviet Guards can only be built in Moscow and Leningrad
unitTypeBuild[object.uGuards.id] = {location=ussrGuards}
--Soviet paratroops can only be built in Omsk
unitTypeBuild[object.uSovietAirborne.id] = {location=ussrAirborne}
--Soviet Heavy Equipment (tanks, aircraft, artillery) can only be built in home cities with a military industry.
unitTypeBuild[object.uBMP1IFV.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uT55.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uT64.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uT72.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uT80.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uMiG19.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uMiG21.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uMiG23.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uMiG25.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uMiG29.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uSu27.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uSu7.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uSu25.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uTu160.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}
unitTypeBuild[object.uMilMi24.id] = {location=ussrHomeCities,allImprovements=object.iMilitaryIndustry}


--CHINESE UNITS
--A Major advantage for China is that they can build units in all Asian cities.
--Chinese infantry can only be built on Chinese home soil 
unitTypeBuild[object.uChineseInf.id] = {allImprovements=object.iAsia}
unitTypeBuild[object.uCommandos.id] = {allImprovements=object.iAsia}
unitTypeBuild[object.uChineseAirborne.id] = {allImprovements=object.iAsia}
unitTypeBuild[object.uType85.id] = {allImprovements={object.iMilitaryIndustry,object.iAsia}}
unitTypeBuild[object.uJ8Shenyang.id] = {allImprovements={object.iMilitaryIndustry,object.iAsia}}

--INDIAN UNITS
--A major advatage for the Non-Aligned is that they can build units in all Asian, Middle Eastern, or African cities
--EXCEPTION: Gurkhas only built where they should be
unitTypeBuild[object.uIndianInf.id] = {someImprovements={object.iAsia,object.iMiddleEast,object.iAfrica},numberOfImprovements=1}
unitTypeBuild[object.uGurkha.id] = {location=gurkhaRecruitment}
unitTypeBuild[object.uIndianParas.id] = {someImprovements={object.iAsia,object.iMiddleEast,object.iAfrica},numberOfImprovements=1}
unitTypeBuild[object.uType85.id] = {someImprovements={object.iMilitaryIndustry,object.iAsia,object.iMiddleEast,object.iAfrica},numberOfImprovements=2}
unitTypeBuild[object.uJ8Shenyang.id] = {someImprovements={object.iMilitaryIndustry,object.iAsia,object.iMiddleEast,object.iAfrica},numberOfImprovements=2}

--REGIONAL UNITS
--Afghanistan
unitTypeBuild[object.uMujahedeen.id] = {location=afghanistan}
--Israel
unitTypeBuild[object.uIsraeliInf.id] = {location=Israel}
--Northern Asia (Korea, China, Japan, Mongolia)
unitTypeBuild[object.uNAsianNat.id] = {location=northernAsia}
unitTypeBuild[object.uNAsianRev.id] = {location=northernAsia}
--Southeast Asia (Vietnam, Indonesia, India)
unitTypeBuild[object.uSEAsianNat.id] = {location=southEastAsia}
unitTypeBuild[object.uSEAsianRev.id] = {location=southEastAsia}
--Middle East (Pakistan, Middle East, North Africa
unitTypeBuild[object.uMidEastNat.id] = {allImprovements=object.iMiddleEast}
unitTypeBuild[object.uMidEastRev.id] = {allImprovements=object.iMiddleEast}
--Africa (below N. Africa)
unitTypeBuild[object.uAfricanNat.id] = {allImprovements=object.iAfrica}
unitTypeBuild[object.uAfricanRev.id] = {allImprovements=object.iAfrica}
--Latin American
unitTypeBuild[object.uLatinNat.id] = {allImprovements=object.iLatinAmerica}
unitTypeBuild[object.uLatinRev.id] = {allImprovements=object.iLatinAmerica}
--Eastern Europe
unitTypeBuild[object.uEasternInf.id] = {location=proEastHomeCities}
--Western Infantry (Canada, South Africa, Australia, Europe)
unitTypeBuild[object.uWesternInf.id] = {location=proWestHomeCities}


--Pirates
unitTypeBuild[object.uPirates.id] = {location=pirateBases}

--Military industry and military ports will only be buildable in core regions, Asia, or Middle East.  Africa and Latin America can never build these (except Egypt/north Africa).
--These also require a size 8 city to build.
local improvementBuild = {}
improvementBuild[object.iMilitaryPort.id] = {someImprovements={object.iAsia,object.iMiddleEast,object.iCoreRegion,object.iDocks},numberOfImprovements=2,minimumPopulation=8,forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iMilitaryIndustry.id] = {someImprovements={object.iAsia,object.iMiddleEast,object.iCoreRegion},numberOfImprovements=1,minimumPopulation=8,forbiddenImprovements=object.iMilitaryBase}
forbiddenImprovements=object.iMilitaryBase


improvementBuild[object.iCapitol.id] = {forbiddenImprovements=object.iMilitaryBase,minimumPopulation=8}
improvementBuild[object.iPoliceStation.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iLocalTrade.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iPrimarySchools.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iIntelligenceAgency.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iCityCenter.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iUrbanExpansion.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iRegionalTrade.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iEqualProtections.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iUniversity.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iGovernmentOffices.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iFactory.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iCheapLabor.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iInternationalCoT.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iMetropolis.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iCommercialFarms.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iColonialSystem.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iResearchLab.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iDocks .id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iCityCenter.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iCityCenter.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iCityCenter.id] = {forbiddenImprovements=object.iMilitaryBase}
improvementBuild[object.iCityCenter.id] = {forbiddenImprovements=object.iMilitaryBase}



local wonderBuild = {}
-- Moon Landing WoW can only be built in a city with a research lab 
wonderBuild[object.wMoonLanding.id] = {allImprovements=object.iResearchLab}
-- SUBSAFE can only be built in a city with a military port
wonderBuild[object.wSUBSAFE.id] = {allImprovements=object.iMilitaryPort}
-- The Marshall Plan and ECSC can only be built in a European City
wonderBuild[object.wTheMarshallPlan.id] = {location=europeanHomeCities}
wonderBuild[object.wECSC.id] = {location=europeanHomeCities}
-- The Civil Rights Act can only be built in a capitol (likely Washington, but who knows)
wonderBuild[object.wCivilRightsAct.id] = {allImprovements=object.iMilitaryPort}


canBuildFunctions.supplyUnitTypeParameters(unitTypeBuild)
canBuildFunctions.supplyImprovementParameters(improvementBuild)
canBuildFunctions.supplyWonderParameters(wonderBuild)

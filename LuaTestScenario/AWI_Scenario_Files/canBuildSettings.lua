
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

local unitTypeBuild = {}

--Americans
local americanNewHampshireCities = {--[[american]]{63,23},{60,28},{56,30}
}
local americanMassachusettsCities = {--[[american]]{60,34}
}
local americanRhodeIslandCities = {--[[american]]{59,39}
}
local americanConnecticutCities = {--[[american]]{55,37}
}
local americanNewYorkCities = {--[[american]]{52,32},{55,43}
}
local americanPennsylvaniaCities = {--[[american]]{49,41},{52,50}
}
local americanNewJerseyCities = {--[[american]]{52,46}
}
local americanMarylandCities = {--[[american]]{48,52}
}
local americanDelawareCities = {--[[american]]{52,56}
}
local americanVirginiaCities = {--[[american]]{47,57},{48,62},{52,64},{44,62}
}
local americanNorthCarolinaCities = {--[[american]]{52,70},{48,70},{45,67},{43,71},{48,76}
}
local americanSouthCarolinaCities = {--[[american]]{42,76},{45,81}
}
local americanGeorgiaCities = {--[[american]]{39,81},{41,87},{35,85},{33,79}
}
local americanTransylvaniaColonyCities = {--[[american]]{15,75},{22,74},{29,65},{35,57},{39,53},{40,46},{45,35}
}
local americanThirteenColoniesCities = {--[[american]]{63,23},{60,28},{56,30},{60,34},{59,39},{55,37},{52,32},{55,43},{49,41},{52,50},{52,46},{48,52},{52,56},{47,57},{48,62},{52,64},{44,62},{52,70},{48,70},{45,67},{43,71},{48,76},{42,76},{45,81},{39,81},{41,87},{35,85},{33,79}
}


--Spanish Empire
local spanishMississippiCities = {--[[spanish]]{12,62},{15,75}
}
local spanishLouisianaCities = {--[[spanish]]{5,95},{10,96},{11,103},{16,106}
}
local spanishFloridaCities = {--[[spanish]]{20,100},{24,88},{16,106},{25,99},{34,100},{40,94},{41,99}
}
local spanishHomeCities = {--[[spanish]]{152,114}
}

--British Empire
local britishCanadaCities = {--[[british]]{54,16},{50,22},{45,29},{39,33},{40,38},{35,45},{29,45},{30,40},{23,39},{26,24},{68,16},{76,16}
}
local britishUSACities = {--[[british]]{63,23},{60,28},{56,30},{60,34},{59,39},{55,37},{52,32},{55,43},{49,41},{52,50},{52,46},{48,52},{52,56},{47,57},{48,62},{52,64},{44,62},{52,70},{48,70},{45,67},{43,71},{48,76},{42,76},{45,81},{39,81},{41,87},{35,85},{33,79}
}
local britishFloridaCities = {--[[british]]{20,100},{24,88},{16,106},{25,99},{34,100},{40,94},{41,99}
}
local britishNorthAmericaCities = {--[[british]]{54,16},{50,22},{45,29},{39,33},{40,38},{35,45},{29,45},{30,40},{23,39},{26,24},{63,23},{60,28},{56,30},{60,34},{59,39},{55,37},{52,32},{55,43},{49,41},{52,50},{52,46},{48,52},{52,56},{47,57},{48,62},{52,64},{44,62},{52,70},{48,70},{45,67},{43,71},{48,76},{42,76},{45,81},{39,81},{41,87},{35,85},{33,79}
}
local britishHomeCities = {--[[british]]{152,20,0}
}





local unitTypeBuild = {}
--Americans
unitTypeBuild[object.uNewHampshireLine.id] = {location=americanNewHampshireCities}
unitTypeBuild[object.uMassachusettsLine.id] = {location=americanMassachusettsCities}
unitTypeBuild[object.uRhodeIslandLine.id] = {location=americanRhodeIslandCities}
unitTypeBuild[object.uRhodeIslandArtillery.id] = {location=americanRhodeIslandCities}
unitTypeBuild[object.uConnecticutLine.id] = {location=americanConnecticutCities}
unitTypeBuild[object.uConnecticutDragoons.id] = {location=americanConnecticutCities}
unitTypeBuild[object.uConnecticutArtillery.id] = {location=americanConnecticutCities}
unitTypeBuild[object.uNewYorkLine.id] = {location=americanNewYorkCities}
unitTypeBuild[object.uNewYorkDragoons.id] = {location=americanNewYorkCities}
unitTypeBuild[object.uNewYorkArtillery.id] = {location=americanNewYorkCities}
unitTypeBuild[object.uPennsylvaniaLine.id] = {location=americanPennsylvaniaCities}
unitTypeBuild[object.uPennsylvaniaDragoons.id] = {location=americanPennsylvaniaCities}
unitTypeBuild[object.uPennsylvaniaArtillery.id] = {location=americanPennsylvaniaCities}
unitTypeBuild[object.uNewJerseyLine.id] = {location=americanNewJerseyCities}
unitTypeBuild[object.uNewJerseyDragoons.id] = {location=americanNewJerseyCities}
unitTypeBuild[object.uMarylandLine.id] = {location=americanMarylandCities}
unitTypeBuild[object.uDelawareLine.id] = {location=americanDelawareCities}
unitTypeBuild[object.uVirginiaLine.id] = {location=americanVirginiaCities}
unitTypeBuild[object.uNorthCarolinaLine.id] = {location=americanNorthCarolinaCities}
unitTypeBuild[object.uSouthCarolinaLine.id] = {location=americanSouthCarolinaCities}
unitTypeBuild[object.uSouthCarolinaDragoons.id] = {location=americanSouthCarolinaCities}
unitTypeBuild[object.uGeorgiaLine.id] = {location=americanGeorgiaCities}
unitTypeBuild[object.uGeorgiaDragoons.id] = {location=americanGeorgiaCities}
unitTypeBuild[object.uTrapper.id] = {location=americanTransylvaniaColonyCities}
unitTypeBuild[object.uMinutemen.id] = {location=americanThirteenColoniesCities}
unitTypeBuild[object.uContinentalLightCorps.id] = {location=americanThirteenColoniesCities}
unitTypeBuild[object.uContinentalRifles.id] = {location=americanThirteenColoniesCities}
--Spanish Empire
unitTypeBuild[object.uMississippiRegt.id] = {location=spanishMississippiCities}
unitTypeBuild[object.uLouisianaRegt.id] = {location=spanishLouisianaCities}
unitTypeBuild[object.uFloridaRegt.id] = {location=spanishFloridaCities}
unitTypeBuild[object.uSpanishMusketeers.id] = {location=spanishHomeCities}
unitTypeBuild[object.uSpanishGrenadiers.id] = {location=spanishHomeCities}
unitTypeBuild[object.uSpanishDragoons.id] = {location=spanishHomeCities}
unitTypeBuild[object.uSpanishDragoons.id] = {location=spanishFloridaCities}
unitTypeBuild[object.uSpanishArtillery.id] = {location=spanishHomeCities}
unitTypeBuild[object.uSpanishArtillery.id] = {location=spanishFloridaCities}
--British Empire
unitTypeBuild[object.uCanadianLoyalists.id] = {location=britishCanadaCities}
unitTypeBuild[object.uBritishLegion.id] = {location=britishNorthAmericaCities}
unitTypeBuild[object.uLoyalists.id] = {location=britishUSACities}
unitTypeBuild[object.uQueensRangers.id] = {location=britishNorthAmericaCities}
unitTypeBuild[object.uMountedLoyalists.id] = {location=britishNorthAmericaCities}
unitTypeBuild[object.uShipoftheLine.id] = {location=britishNorthAmericaCities}
unitTypeBuild[object.uLightCorps.id] = {location=britishHomeCities}
unitTypeBuild[object.uLineInfantry.id] = {location=britishHomeCities}
unitTypeBuild[object.uRoyalMarines.id] = {location=britishHomeCities}
unitTypeBuild[object.uLineGrenadiers.id] = {location=britishHomeCities}
unitTypeBuild[object.uHighlanderRegt.id] = {location=britishHomeCities}
unitTypeBuild[object.uLightDragoons.id] = {location=britishHomeCities}
unitTypeBuild[object.uNobleCitizen.id] = {location=britishHomeCities}
unitTypeBuild[object.uFieldArtillery.id] = {location=britishHomeCities}
unitTypeBuild[object.uFieldHowitzer.id] = {location=britishHomeCities}
unitTypeBuild[object.uManofWar.id] = {location=britishHomeCities}
unitTypeBuild[object.uEastIndiaCoRegt.id] = {location=britishFloridaCities}

-- merchant
unitTypeBuild[object.uMerchant.id] = {allImprovements=object.iTradingCompany}


local improvementBuild = {}

local wonderBuild = {}

canBuildFunctions.supplyUnitTypeParameters(unitTypeBuild)
canBuildFunctions.supplyImprovementParameters(improvementBuild)
canBuildFunctions.supplyWonderParameters(wonderBuild)

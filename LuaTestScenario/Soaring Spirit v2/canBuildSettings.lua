
local object = require("object")
local canBuildFunctions = require("canBuild")
local param = require("parameters")

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
--          the city can only build the item if city:canBuild(item) is true for at least one item in the list
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

local unitTypeBuild = {}
unitTypeBuild[object.uColonist.id]={minimumPopulation=6}


local wonderListMB = {
object.wBlackSeaGrainTrade,
object.wGreatTempleofApollo,
object.wColossus,
object.wLighthouse,
object.wGreatTempleofPoseidon,
object.wLongWall,
object.wGreatAcademy,
object.wGrandMines,
object.wGrandEmbassy,
object.wGreatTempleofZeus,
object.wGreatObservatory,
object.wGreatVoyage,
object.wGreatTempleofAthena,
object.wGreatTempleofDionysis,
object.wGreatCollege,
object.wGreatAgora,
--object.wEurekaMoment, -- doesn't depend on master builder conditions
object.wStatueofZeus,
object.wStatueofApollo,
object.wGreatTempleofArtemis,
object.wGreatForge,
object.wGrandLeague,
object.wGreatTempleofAphrodite,
}

local function masterBuilderCondition(defaultBuildFunction,selectingCity,item)
    local wondersOwned = 0
    local wondersBuilt = 0
    for __,wonder in pairs(wonderListMB) do
        if wonder.city then
            wondersBuilt = wondersBuilt+1
            if wonder.city.owner == selectingCity.owner then
                wondersOwned = wondersOwned+1
            end
        end
    end
    if wondersOwned == 0 then
        return true
    elseif wondersOwned < param.wonderOwnershipThreshold*wondersBuilt then
        return true
    else
        return false
    end
end

local improvementBuild = {}
improvementBuild[object.iMasterBuilder.id] = {conditionFunction = masterBuilderCondition}

local wonderCondition = {allImprovements=object.iMasterBuilder, alternateParameters={{computerOnly=true}}}
local wonderBuild = {}
wonderBuild[object.wBlackSeaGrainTrade.id]=wonderCondition    
wonderBuild[object.wGreatTempleofApollo.id]=wonderCondition   
wonderBuild[object.wColossus.id]=wonderCondition              
wonderBuild[object.wLighthouse.id]=wonderCondition            
wonderBuild[object.wGreatTempleofPoseidon.id]=wonderCondition 
wonderBuild[object.wLongWall.id]=wonderCondition              
wonderBuild[object.wGreatAcademy.id]=wonderCondition          
wonderBuild[object.wGrandMines.id]=wonderCondition            
wonderBuild[object.wGrandEmbassy.id]=wonderCondition          
wonderBuild[object.wGreatTempleofZeus.id]=wonderCondition     
wonderBuild[object.wGreatObservatory.id]=wonderCondition      
wonderBuild[object.wGreatVoyage.id]=wonderCondition           
wonderBuild[object.wGreatTempleofAthena.id]=wonderCondition   
wonderBuild[object.wGreatTempleofDionysis.id]=wonderCondition 
wonderBuild[object.wGreatCollege.id]=wonderCondition          
wonderBuild[object.wGreatAgora.id]=wonderCondition            
--wonderBuild[object.wEurekaMoment.id]=wonderCondition  -- Eureka Moment doesn't depend on the master builder conditions
wonderBuild[object.wStatueofZeus.id]=wonderCondition          
wonderBuild[object.wStatueofApollo.id]=wonderCondition        
wonderBuild[object.wGreatTempleofArtemis.id]=wonderCondition  
wonderBuild[object.wGreatForge.id]=wonderCondition            
wonderBuild[object.wGrandLeague.id]=wonderCondition           
wonderBuild[object.wGreatTempleofAphrodite.id]=wonderCondition




canBuildFunctions.supplyUnitTypeParameters(unitTypeBuild)
canBuildFunctions.supplyImprovementParameters(improvementBuild)
canBuildFunctions.supplyWonderParameters(wonderBuild)

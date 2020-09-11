local diplomacy = require("diplomacy")
local object = require("object")

local diplomacySettings = {}

local maxDeploymentsPerTurn = 1
local diplomacySettingsState = "notLinked"
local function linkState(tableInState)
    if type(tableInState)~="table" then
        error("diplomacySettings.linkState takes a table as an argument.")
    else
        diplomacySettingsState = tableInState
    end
    diplomacySettingsState.cityDeployments = diplomacySettingsState.cityDeployments or {}
end
diplomacySettings.linkState = linkState
-- if nonGiftTechs[N] is set to true, then
-- civ.getTech(N) can't be given away in the diplomacy module

local nonGiftTechs = {}
nonGiftTechs[object.aFiveYearPlans.id] = true                 
nonGiftTechs[object.aPublicEducation.id] = false              
nonGiftTechs[object.aJetFightersI.id] = true                  
nonGiftTechs[object.aJetFightersII.id] = true                 
nonGiftTechs[object.aJetFightersIII.id] = true                
nonGiftTechs[object.aTheUnitedStates.id] = true               
nonGiftTechs[object.aJetFightersIV.id] = true                 
nonGiftTechs[object.aInfrastructure.id] = false                
nonGiftTechs[object.aJetFightersV.id] = true                  
nonGiftTechs[object.aBasicServices.id] = true                 
nonGiftTechs[object.aJetFightersVI.id] = true                 
nonGiftTechs[object.aAirTransport.id] = true                  
nonGiftTechs[object.aMainBattleTankI.id] = true               
nonGiftTechs[object.aMainBattleTankII.id] = true              
nonGiftTechs[object.aMainBattleTankIII.id] = true             
--nonGiftTechs[--object.a.id] = true--NOTUSED                   
nonGiftTechs[object.aMainBattleTankIV.id] = true              
nonGiftTechs[object.aCombinedArms.id] = true                  
nonGiftTechs[object.aMilitaryConstruct.id] = true             
nonGiftTechs[object.aAPCs.id] = true                          
nonGiftTechs[object.aIFVs.id] = true                          
--nonGiftTechs[--object.a.id] = true--NOTUSED                   
nonGiftTechs[object.aAttackHelicopters.id] = true             
nonGiftTechs[object.aStrategicBombersI.id] = true             
nonGiftTechs[object.aTheConstitution.id] = true               
nonGiftTechs[object.aAirborneForces.id] = true                
nonGiftTechs[object.aAegisCruiser.id] = true                  
nonGiftTechs[object.aStrategicBombersII.id] = true            
nonGiftTechs[object.aBlueWaterFleet.id] = true                
nonGiftTechs[object.aAlignEgypt.id] = true           
--nonGiftTechs[--object.aSAVE.id] = true                        
--nonGiftTechs[--object.a.id] = true--NOTUSED                   
--nonGiftTechs[--object.a.id] = true--NOTUSED                   
nonGiftTechs[object.aSpyGames.id] = true                      
--nonGiftTechs[--object.a.id] = true--NOTUSED                   
nonGiftTechs[object.aInternationalPower.id] = true            
nonGiftTechs[object.aSpyPlanes.id] = true                     
nonGiftTechs[object.aIndianIndependence.id] = true            
--nonGiftTechs[--object.a.id] = true--NOTUSED                   
nonGiftTechs[object.aAttackAircraftI.id] = true               
nonGiftTechs[object.aAttackAircraftII.id] = true              
nonGiftTechs[object.aCovertOps.id] = true                     
nonGiftTechs[object.aNuclearTesting.id] = true                
nonGiftTechs[object.aScientificInvestment.id] = false         
nonGiftTechs[object.aHydrogenBomb.id] = true                  
nonGiftTechs[object.aDeterrenceTheory.id] = true              
nonGiftTechs[object.aMRBM.id] = true                          
nonGiftTechs[object.aICBM.id] = true                          
nonGiftTechs[object.aIndustrialization.id] = false             
nonGiftTechs[object.aInexpensiveLabor.id] = true              
nonGiftTechs[object.aNativeArmsIndustry.id] = true            
nonGiftTechs[object.aDecolonization.id] = true                
nonGiftTechs[object.aAlignGhana.id] = true                  
nonGiftTechs[object.aNationalFighter.id] = true               
nonGiftTechs[object.aColonialSystem.id] = true                
nonGiftTechs[object.aLegalSystem.id] = false                   
nonGiftTechs[object.aFunctioningGovt.id] = true               
nonGiftTechs[object.aSubSafetyProgram.id] = true              
nonGiftTechs[object.aEuroHegemony.id] = true                  
nonGiftTechs[object.aNuclearPoweredNavy.id] = true            
nonGiftTechs[object.aSatellites.id] = true                    
nonGiftTechs[object.aMannedOrbit.id] = true                   
nonGiftTechs[object.aMilIndComplex.id] = true                 
nonGiftTechs[object.aManontheMoon.id] = true                  
nonGiftTechs[object.aSuperCarriers.id] = true                 
nonGiftTechs[object.aMobileArtillery.id] = false               
nonGiftTechs[object.aAirports.id] = true                      
nonGiftTechs[object.aInterstateHighways.id] = false            
nonGiftTechs[object.aAlignIndonesia.id] = true                     
nonGiftTechs[object.aCivilRightsMovement.id] = true           
nonGiftTechs[object.aCommercialFarms.id] = true               
--nonGiftTechs[--object.a.id] = true--NOTUSED                   
nonGiftTechs[object.aEuropeanEconomicRevival.id] = true       
nonGiftTechs[object.aEuropeanCommunity.id] = true             
nonGiftTechs[object.aRocketResearchII.id] = true              
nonGiftTechs[object.aNationalTank.id] = true                  
nonGiftTechs[object.aRegionalCommerce.id] = false              
nonGiftTechs[object.aInternationalCommerce.id] = false         
nonGiftTechs[object.aRocketResearchI.id] = true               
--nonGiftTechs[object.aSAVE.id] = true               
--nonGiftTechs[object.aMontgomeryBusBoycott.id] = true          
--nonGiftTechs[object.aFreedomRides.id] = true                  
nonGiftTechs[object.aCivilRightsAct.id] = true                
--nonGiftTechs[object.aMarchonWashington.id] = true             
nonGiftTechs[object.aBasicCommerce.id] = false                 
nonGiftTechs[object.aResearchLabs.id] = false                 
nonGiftTechs[object.aFundTechInstitutes.id] = true            
nonGiftTechs[object.aMobileAA.id] = false                     
nonGiftTechs[object.aTheSpaceRace.id] = true                  
nonGiftTechs[object.aDelays.id] = true                        
nonGiftTechs[object.aSLBM.id] = true                          
nonGiftTechs[object.aEarlySSBN.id] = true                     
nonGiftTechs[object.aAdvancedSSN.id] = true                   
nonGiftTechs[object.aEarlySSN.id] = true                      
nonGiftTechs[object.aImprovedSSN.id] = true                   
nonGiftTechs[object.aAdvancedSSBN.id] = true                  
nonGiftTechs[object.aAlgerianLiberation.id] = true               
nonGiftTechs[object.aAlignCuba.id] = true                    
nonGiftTechs[object.aAlignTurkey.id] = true              
nonGiftTechs[object.aGlasnostPerestroika.id] = true           




diplomacySettings.giftTechNotTrade = {}
local j=1
for i=0,99 do
    if nonGiftTechs[i] then
        diplomacySettings.giftTechNotTrade[j] = civ.getTech(i).name
        j=j+1
    end
end

local options = {giftTechNotTrade = diplomacySettings.giftTechNotTrade}


--      canGiveUnitFn(unit)-->bool
--          determines if a unit can be given away as a single unit
local function canGiveUnitFn(unit)
	
local unitCity = unit.location.city
-- rule out units not in cities, and ships
-- also rule out anything else that can't be given away
if not unitCity or (unit.type.domain == 2) or (unit.type == object.uICBM or unit.type == object.uMRBM or unit.type == object.uSpy or unit.type == object.uFreight
					or unit.type == object.uEasternInf or unit.type == object.uSovietInf or unit.type == object.uGuards or unit.type == object.uSovietAirborne or unit.type == object.uEuroInf or
					unit.type == object.uForeignLegion or unit.type == object.uUKParas or unit.type == object.uUSInf or unit.type == object.uUSMarines or unit.type == object.uUSAirborne or
					unit.type == object.uIndianInf or unit.type == object.uGurkha or unit.type == object.uIndianParas or unit.type == object.uChineseInf or unit.type == object.uCommandos or
					unit.type == object.uChineseAirborne or unit.type == object.uLatinNat or unit.type == object.uAfricanNat or unit.type == object.uNAsianNat or unit.type == object.uSEAsianNat or
					unit.type == object.uMidEastNat or unit.type == object.uIsraeliInf or unit.type == object.uMujahedeen or unit.type == object.uLatinRev or unit.type == object.uAfricanRev or
					unit.type == object.uNAsianRev or unit.type == object.uSEAsianRev or unit.type == object.uMidEastRev or unit.type == object.uWesternInf or unit.type == object.uNuclearBomb) then
    return false
end

if diplomacySettingsState.cityDeployments[unitCity.id] and diplomacySettingsState.cityDeployments[unitCity.id] >= maxDeploymentsPerTurn then
    return false
end
if unitCity:hasImprovement(object.iInternationalPort) then
    return true
end
if unit.owner == object.tEurope and unitCity:hasImprovement(object.iColonialSystem) then
    return true
end
if unitCity:hasImprovement(object.iMilitaryBase) then
    return true
end
-- if we get here, the unit can't be given away
return false
			
end



   

	

 
--      tribeCanReceiveUnitFn(unitBeforeGift,tribe)-->bool
--          determines if a tribe can receive a unit as a gift (so that a tribe
--          can be selected to receive a gift)


local function tribeCanReceiveUnitFn(unitBeforeGift,tribe)
	
	local sourceCity = unitBeforeGift.location.city
	
    if unitBeforeGift.owner == object.tUSSR and (tribe == object.tUSA or tribe == object.tEurope or tribe == object.tUSSR or tribe == object.tProWest)then
        return false
    end
	
	if unitBeforeGift.owner == object.tUSA and (tribe == object.tChina or tribe == object.tUSSR or tribe == object.tProEast)then
        return false
    end
	
	if unitBeforeGift.owner == object.tEurope and (tribe == object.tChina or tribe == object.tUSSR or tribe == object.tProEast)then
        return false
    end
	
	if unitBeforeGift.owner == object.tChina and (tribe == object.tChina or tribe == object.tUSA or tribe == object.tProWest)then
        return false
    end
	
	if unitBeforeGift.owner == object.tIndia and (tribe == object.tChina or tribe == object.tIndia or tribe == object.tProWest)then
        return false
    end
	
	--NOTE: The Pro-East and Pro-West Civs cannot donate units to anyone.  It is a one way street.
	if unitBeforeGift.owner == object.tProEast and (tribe == object.tProEast or tribe == object.tProWest or tribe == object.tIndia or tribe == object.tUSA or tribe == object.tEurope or tribe == object.tUSSR or tribe == object.tChina)then
        return false
    end
	
	if unitBeforeGift.owner == object.tProWest and (tribe == object.tProEast or tribe == object.tProWest or tribe == object.tIndia or tribe == object.tUSA or tribe == object.tEurope or tribe == object.tUSSR or tribe == object.tChina)then
        return false
    end
	
	

    return true
end

--      cityCanReceiveUnitFn(unitBeforeGift,destinationCity)--> bool or number
--          if false, city can't receive unit
--          if number, city can receive unit, but giver must pay that cost
--          if true, city can receive unit for free
local function cityCanReceiveUnitFn(unitBeforeGift,destinationCity)
    if diplomacySettingsState.cityDeployments[destinationCity.id] and diplomacySettingsState.cityDeployments[destinationCity.id] >= maxDeploymentsPerTurn then
        return false
    end

	local sourceCity = unitBeforeGift.location.city

-- if both cities have international ports, then the unit can always be received
if sourceCity:hasImprovement(object.iInternationalPort) and destinationCity:hasImprovement(object.iInternationalPort) then
    return math.abs(unitBeforeGift.location.x-destinationCity.location.x)+math.abs(unitBeforeGift.location.y-destinationCity.location.y)//4
end
-- if the destination has a military base, it can receive from a regular city, as long as they are from the same tribe
if destinationCity:hasImprovement(object.iMilitaryBase) and sourceCity:hasImprovement(object.iCityCenter) and destinationCity.owner == sourceCity.owner then
    return math.abs(unitBeforeGift.location.x-destinationCity.location.x)+math.abs(unitBeforeGift.location.y-destinationCity.location.y)//4
end
-- if the source has a military base, a destination city can receive the shipment if they are the same tribe
if destinationCity:hasImprovement(object.iCityCenter) and sourceCity:hasImprovement(object.iMilitaryBase) and destinationCity.owner == sourceCity.owner then
    return math.abs(unitBeforeGift.location.x-destinationCity.location.x)+math.abs(unitBeforeGift.location.y-destinationCity.location.y)//4
end
if sourceCity.owner == object.tEurope and destinationCity.owner == object.tEurope and destinationCity:hasImprovement(object.iColonialSystem) and sourceCity:hasImprovement(object.iColonialSystem) then
return math.abs(unitBeforeGift.location.x-destinationCity.location.x)+math.abs(unitBeforeGift.location.y-destinationCity.location.y)//4
end
	

    return false
end

--      canGiveTileFn(tile,giver)
--          if true, the tile and all its contents can be transferred to a new owner
--          if false, it can't

local function canGiveTileFn(tile,giver)

    return tile.owner == giver

end
--      canReceiveTileFn(tile,giver,receiver)
--          if true, the tribe can receive the tile
--          if false, it can't

-- NOTE: As of now, I'm allowing most civs to give each other cities, with the exception being that no one can give the USA and USSR cities directly. This is because they are the only civs that 
-- get a penalty for having extra cities under their control. If I allowed the USA and USSR to swap cities with each other, it could lead to a civ "giving" cities to the other as a form of sabotage.
-- Cities can still be exchanged as part of a peace treaty in a MP game, but they will need to be given to the Pro-East/Pro-West side instead.
-- The only civs that can give cities to the USA or USSR are their respective proxies, as it may sometimes make sense for the main civ to take a bigger stake in an area.

local function canReceiveTileFn(tile,giver,receiver)

if giver == object.tUSA and (receiver == object.tUSSR) then 
	return false
	end

if giver == object.tEurope and (receiver == object.tUSSR or receiver == object.tUSA) then 
	return false
	end

if giver == object.tUSSR and (receiver == object.tUSA) then 
	return false
	end

if giver == object.tProEast and (receiver == object.tUSA) then 
	return false
	end
	
if giver == object.tProWest and (receiver == object.tUSSR) then 
	return false
	end

if giver == object.tIndia and (receiver == object.tUSSR or receiver == object.tUSA) then 
	return false
	end

if giver == object.tChina and (receiver == object.tUSSR or receiver == object.tUSA) then 
	return false
	end

    return true
end


local function afterUnitTransferFn(sourceCity,destinationCity,unitGiven)
    diplomacySettingsState.cityDeployments[sourceCity.id] = (diplomacySettingsState.cityDeployments[sourceCity.id] or 0) +1
    diplomacySettingsState.cityDeployments[destinationCity.id] = (diplomacySettingsState.cityDeployments[destinationCity.id] or 0) +1
    unitGiven.moveSpent = 255
    -- if the unit is transferred between civs, remove vet status.
    if sourceCity.owner ~= destinationCity.owner then
        unitGiven.veteran = false
    end

end



function diplomacySettings.diplomacyDialog()
    diplomacy.coldWarDiplomacyMenu(options,canGiveUnitFn,tribeCanReceiveUnitFn,cityCanReceiveUnitFn,afterUnitTransferFn,canGiveTileFn,canReceiveTileFn)

end

function diplomacySettings.clearCityDeployments(tribe)
    for index,value in pairs(diplomacySettingsState.cityDeployments) do
        if civ.getCity(index).owner == tribe then
            diplomacySettingsState.cityDeployments[index] = nil
        end
    end
end

return diplomacySettings

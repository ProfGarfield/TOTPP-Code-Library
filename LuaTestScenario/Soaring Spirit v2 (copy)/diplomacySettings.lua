
local object = require("object")

local diplomacySettings = {}
-- the units with these id numbers can't be given away
-- if the value is set to true
local forbiddenGiveAway = {}

forbiddenGiveAway[object.uColonist.id]=true
forbiddenGiveAway[object.uEngineer.id]=true
forbiddenGiveAway[object.uArchaicHopliteSpartan.id]=true
forbiddenGiveAway[object.uClassicalHopliteSpartan.id]=true
forbiddenGiveAway[object.uMercenaryHoplite.id]=false
forbiddenGiveAway[object.uEtruscanHoplite.id]=true
forbiddenGiveAway[object.uLydianHoplite.id]=true
forbiddenGiveAway[object.uPsiloi.id]=true
forbiddenGiveAway[object.uPersianImmortal.id]=true
forbiddenGiveAway[object.uThracianWarrior.id]=false
forbiddenGiveAway[object.uPersianSparhabara.id]=true
forbiddenGiveAway[object.uPhoenicianHoplite.id]=true
forbiddenGiveAway[object.uCretanArcher.id]=false
forbiddenGiveAway[object.uToxotoi.id]=true
forbiddenGiveAway[object.uSkythianArcher.id]=false
forbiddenGiveAway[object.uSkythianHorseman.id]=false
forbiddenGiveAway[object.uHellenicHoplite.id]=true
forbiddenGiveAway[object.uLatinSpearman.id]=false
forbiddenGiveAway[object.uThessalianCavalry.id]=false
forbiddenGiveAway[object.uPeltast.id]=true
forbiddenGiveAway[object.uIllyrianWarrior.id]=false
forbiddenGiveAway[object.uLatinSkirmisher.id]=false
forbiddenGiveAway[object.uBallista.id]=false
forbiddenGiveAway[object.uPersianKardakes.id]=true
forbiddenGiveAway[object.uBatteringRam.id]=false
forbiddenGiveAway[object.uSiegeTower.id]=false
forbiddenGiveAway[object.uCatapult.id]=false
forbiddenGiveAway[object.uArchaicHopliteAthenian.id]=true
forbiddenGiveAway[object.uClassicalHopliteAthenian.id]=true
forbiddenGiveAway[object.uPersianTakhabara.id]=true
forbiddenGiveAway[object.uNumidianWarrior.id]=false
forbiddenGiveAway[object.uRhodianSlinger.id]=false
forbiddenGiveAway[object.uLiburnae.id]=false
forbiddenGiveAway[object.uSamniteWarrior.id]=false
forbiddenGiveAway[object.uMacedonianWarrior.id]=false
forbiddenGiveAway[object.uTransportShip.id]=false
forbiddenGiveAway[object.uTransportGalley.id]=false
forbiddenGiveAway[object.uPentreconter.id]=false
forbiddenGiveAway[object.uBireme.id]=false
forbiddenGiveAway[object.uTrireme.id]=false
forbiddenGiveAway[object.uPunicGalley.id]=true
forbiddenGiveAway[object.uSlave.id]=false
forbiddenGiveAway[object.uCitizen.id]=true
forbiddenGiveAway[object.uRecruiter.id]=true
forbiddenGiveAway[object.uEasternFortress.id]=true
forbiddenGiveAway[object.uStrategos.id]=true
forbiddenGiveAway[object.uRichVillage.id]=true
forbiddenGiveAway[object.uArchaicHopliteCorinthian.id]=true
forbiddenGiveAway[object.uTrader.id]=true
forbiddenGiveAway[object.uMerchant.id]=true
forbiddenGiveAway[object.uHelot.id]=true
forbiddenGiveAway[object.uArchaicHopliteIonian.id]=true
forbiddenGiveAway[object.uClassicalHopliteIonian.id]=true
forbiddenGiveAway[object.uTarentineCavalry.id]=false
forbiddenGiveAway[object.uCampanianCavalry.id]=false
forbiddenGiveAway[object.uPersianHorsemen.id]=true
forbiddenGiveAway[object.uPersianCavalry.id]=true
forbiddenGiveAway[object.uNumidianHorsemen.id]=false
forbiddenGiveAway[object.uClassicalHopliteCorinthian.id]=true
forbiddenGiveAway[object.uFortress.id]=false
forbiddenGiveAway[object.uCelticWarrior.id]=false
forbiddenGiveAway[object.uIberianWarrior.id]=false

function diplomacySettings.forbidTileGiveaway(tile)
    if tile.owner ~= civ.getCurrentTribe() then
        return true
    end
    for unit in tile.units do
        if forbiddenGiveAway[unit.type.id] then
            civ.ui.text("Note that the "..unit.type.name.." on this tile can not be given away.  If you wish to give away the contents of this tile to another player, the "..unit.type.name.." must be moved or disbanded.")
            return true
        end
    end
    return false
end

-- if true, the tech with the ID number can't be transferred
local forbiddenTechTransfer = {}
forbiddenTechTransfer[object.aSocialJustice.id] = false 
forbiddenTechTransfer[object.aNONIONIAN.id] = true 
forbiddenTechTransfer[object.aStandardCurrency.id] = false 
forbiddenTechTransfer[object.aNavigation.id] = false 
forbiddenTechTransfer[object.aOlympicGames.id] = false 
forbiddenTechTransfer[object.aCITYSTYLE1.id] = true 
forbiddenTechTransfer[object.aBanking.id] = false 
forbiddenTechTransfer[object.aBridgeBuilding.id] = false 
forbiddenTechTransfer[object.aBronzeCasting.id] = false 
forbiddenTechTransfer[object.aDrama.id] = false 
forbiddenTechTransfer[object.aAmphora.id] = false 
forbiddenTechTransfer[11] = true
forbiddenTechTransfer[object.aPolis.id] = false 
forbiddenTechTransfer[object.aColonization.id] = false 
forbiddenTechTransfer[object.aAgora.id] = false 
forbiddenTechTransfer[object.aTwinMonarchy.id] = false 
forbiddenTechTransfer[object.aMerchantilism.id] = false 
forbiddenTechTransfer[17] = true 
forbiddenTechTransfer[18] = true 
forbiddenTechTransfer[object.aLiteracy.id] = false 
forbiddenTechTransfer[object.aPapyrus.id] = false 
forbiddenTechTransfer[object.aDemocracy.id] = false 
forbiddenTechTransfer[object.aPhoenicianAlphabet.id] = false 
forbiddenTechTransfer[object.aPoetry.id] = false 
forbiddenTechTransfer[object.aThePriesthood.id] = false 
forbiddenTechTransfer[object.aGrainTrade.id] = false 
forbiddenTechTransfer[object.aSculpture.id] = false 
forbiddenTechTransfer[object.aCultofApollo.id] = false 
forbiddenTechTransfer[object.aMathematics.id] = false 
forbiddenTechTransfer[object.aFishingFleet.id] = false 
forbiddenTechTransfer[30] = true 
forbiddenTechTransfer[object.aWarCouncil.id] = false 
forbiddenTechTransfer[object.aTragedy.id] = false 
forbiddenTechTransfer[object.aIronForging.id] = false 
forbiddenTechTransfer[object.aSTART1.id] = true 
forbiddenTechTransfer[35] = true 
forbiddenTechTransfer[object.aMetropolis.id] = false 
forbiddenTechTransfer[37] = true 
forbiddenTechTransfer[object.aSTART2.id] = true 
forbiddenTechTransfer[39] = true 
forbiddenTechTransfer[object.aHarbourDefences.id] = false 
forbiddenTechTransfer[object.aAdvancedMining.id] = false 
forbiddenTechTransfer[42] = true 
forbiddenTechTransfer[object.aIambicPerameter.id] = false 
forbiddenTechTransfer[object.aTradeCentres.id] = false 
forbiddenTechTransfer[45] = true  
forbiddenTechTransfer[object.aMapping.id] = false 
forbiddenTechTransfer[object.aMedicine.id] = false 
forbiddenTechTransfer[object.aScience.id] = false 
forbiddenTechTransfer[object.aRiverPorts.id] = false 
forbiddenTechTransfer[object.aMusic.id] = false 
forbiddenTechTransfer[51] = true 
forbiddenTechTransfer[object.aMartialPride.id] = false 
forbiddenTechTransfer[53] = true 
forbiddenTechTransfer[object.aTyranny.id] = false 
forbiddenTechTransfer[object.aSTART3.id] = true 
forbiddenTechTransfer[object.aEpicPoetry.id] = false 
forbiddenTechTransfer[57] = true 
forbiddenTechTransfer[object.aCivilTaxation.id] = false 
forbiddenTechTransfer[object.aMasterShipbuilders.id] = false 
forbiddenTechTransfer[object.aCITYSTYLE2.id] = true 
forbiddenTechTransfer[object.aNONATHENIAN.id] = true 
forbiddenTechTransfer[object.aCitizenship.id] = false 
forbiddenTechTransfer[object.aGrainMarkets.id] = false 
forbiddenTechTransfer[64] = true 
forbiddenTechTransfer[object.aShipbuildingYards.id] = false 
forbiddenTechTransfer[object.aLYDIANSETTLERS.id] = true 
forbiddenTechTransfer[67] = true 
forbiddenTechTransfer[object.aPhilosophy.id] = false 
forbiddenTechTransfer[object.aSlaveTrading.id] = false 
forbiddenTechTransfer[object.aLandReform.id] = false 
forbiddenTechTransfer[object.aOligarchy.id] = false 
forbiddenTechTransfer[object.aLinenCuirass.id] = false 
forbiddenTechTransfer[object.aBiremes.id] = false 
forbiddenTechTransfer[object.aCivicPride.id] = false 
forbiddenTechTransfer[object.aAstronomy.id] = false 
forbiddenTechTransfer[object.aNONCORINTHIAN.id] = true 
forbiddenTechTransfer[object.aEngineering.id] = false 
forbiddenTechTransfer[object.aRecurvedBow.id] = false 
forbiddenTechTransfer[object.aPolitics.id] = false 
forbiddenTechTransfer[object.aGymnetes.id] = false 
forbiddenTechTransfer[object.aStonecutting.id] = false 
forbiddenTechTransfer[object.aLyricalPoetry.id] = false 
forbiddenTechTransfer[object.aArt.id] = false 
forbiddenTechTransfer[object.aCurrency.id] = false 
forbiddenTechTransfer[object.aGymnastics.id] = false 
forbiddenTechTransfer[object.aArchitecture.id] = false 
forbiddenTechTransfer[object.aHistory.id] = false 
forbiddenTechTransfer[object.aLandRights.id] = false 
forbiddenTechTransfer[object.aHellenicCulture.id] = false 
forbiddenTechTransfer[object.aElitism.id] = false 
forbiddenTechTransfer[object.aMasterCraftsmen.id] = false 
forbiddenTechTransfer[object.aConstruction.id] = false 
forbiddenTechTransfer[object.aRiseoftheMedes.id] = true 
forbiddenTechTransfer[object.aPersianInvasion.id] = true 
forbiddenTechTransfer[object.aNONSPARTAN.id] = true 
forbiddenTechTransfer[object.aNONLYDIAN.id] = true 
forbiddenTechTransfer[object.aNONETRUSCAN.id] = true 
forbiddenTechTransfer[object.aNONPHOENICIAN.id] = true 
forbiddenTechTransfer[object.aNONHELLENIC.id] = true 
diplomacySettings.forbiddenTechTransfer=forbiddenTechTransfer

diplomacySettings.giftTechNotTrade = {}
local j=1
for i=0,99 do
    if forbiddenTechTransfer[i] then
        diplomacySettings.giftTechNotTrade[j] = civ.getTech(i).name
        j=j+1
    end
end

return diplomacySettings

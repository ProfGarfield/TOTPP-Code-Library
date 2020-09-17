local object = require("object")

local attackBonusSettings = {} -- this will be returned
-- ============================================================================
-- 
-- simpleAttackBonus(activeUnit,simpleAttackBonusTable,defaultAttackTable)-->nil
-- 
-- only one bonus applies
--
-- =============================================================================
--
--
--
-- defaultAttackTable[unitType.id]=integer
-- gives the attack value of the unit type without a bonus. Only necessary for
-- units that might receive a bonus, but no problem if all use it


local defaultAttackTable = {}

defaultAttackTable[object.uFarmer.id]                    =  0
defaultAttackTable[object.uEngineers.id]                 =  0
defaultAttackTable[object.uLightCorps.id]                =  4
defaultAttackTable[object.uLineInfantry.id]              =  6
defaultAttackTable[object.uRoyalMarines.id]              =  6
defaultAttackTable[object.uLineGrenadiers.id]            =  7
defaultAttackTable[object.uHighlanderRegt.id]            =  6
--defaultAttackTableus[]                                 =  1
defaultAttackTable[object.uPirates.id]                   =  6
defaultAttackTable[object.uMinutemen.id]                 =  5
defaultAttackTable[object.uBritishLegion.id]             =  4
defaultAttackTable[object.uLoyalists.id]                 =  5
defaultAttackTable[object.uCanadianLoyalists.id]         =  5
defaultAttackTable[object.uQueensRangers.id]             =  8
defaultAttackTable[object.uDutchLineInfantry.id]         =  6
defaultAttackTable[object.uFrenchFusiliers.id]           =  6
defaultAttackTable[object.uFrenchGrenadiers.id]          =  7
defaultAttackTable[object.uSpanishMusketeers.id]         =  6
defaultAttackTable[object.uSpanishGrenadiers.id]         =  7
defaultAttackTable[object.uFortress.id]                  =  0
defaultAttackTable[object.uContinentalLightCorps.id]     =  4
defaultAttackTable[object.uConnecticutLine.id]           =  6
defaultAttackTable[object.uCitadel.id]                   =  0
defaultAttackTable[object.uDelawareLine.id]              =  6
defaultAttackTable[object.uGeorgiaLine.id]               =  6
defaultAttackTable[object.uMassachusettsLine.id]         =  6
defaultAttackTable[object.uMarylandLine.id]              =  6
defaultAttackTable[object.uNewHampshireLine.id]          =  6
defaultAttackTable[object.uNewYorkLine.id]               =  6
defaultAttackTable[object.uNewJerseyLine.id]             =  6
defaultAttackTable[object.uNorthCarolinaLine.id]         =  6
defaultAttackTable[object.uPennsylvaniaLine.id]          =  6
defaultAttackTable[object.uRhodeIslandLine.id]           =  6
defaultAttackTable[object.uSouthCarolinaLine.id]         =  6
defaultAttackTable[object.uVirginiaLine.id]              =  6
defaultAttackTable[object.uContinentalRifles.id]         =  8
defaultAttackTable[object.uMississippiRegt.id]           =  5
defaultAttackTable[object.uLouisianaRegt.id]             =  5
defaultAttackTable[object.uFloridaRegt.id]               =  5
defaultAttackTable[object.uWarriorSociety.id]            =  4
defaultAttackTable[object.uArchers.id]                   =  4
defaultAttackTable[object.uTomahawkThrower.id]           =  6
defaultAttackTable[object.uWarriors.id]                  =  6
defaultAttackTable[object.uMusketmen.id]                 =  8
defaultAttackTable[object.uEastIndiaCoRegt.id]           =  6
--defaultAttackTableus[]                                 =  1
defaultAttackTable[object.uNobleCitizen.id]              =  0
defaultAttackTable[object.uTrapper.id]                   =  5
defaultAttackTable[object.uSupplyWagon.id]               =  0
defaultAttackTable[object.uMerchant.id]                  =  0
defaultAttackTable[object.uLightDragoons.id]             =  8
defaultAttackTable[object.uQueensLightDragoons.id]       =  8
defaultAttackTable[object.uMountedLoyalists.id]          =  5
defaultAttackTable[object.uQueensHussars.id]             =  5
defaultAttackTable[object.uTarletonsDragoons.id]         =  8
defaultAttackTable[object.uFieldArtillery.id]            = 10
defaultAttackTable[object.uFieldHowitzer.id]             = 14
defaultAttackTable[object.uConnecticutDragoons.id]       =  8
defaultAttackTable[object.uNewJerseyDragoons.id]         =  8
defaultAttackTable[object.uPennsylvaniaDragoons.id]      =  8
defaultAttackTable[object.uSouthCarolinaDragoons.id]     =  8
defaultAttackTable[object.uGeorgiaDragoons.id]           =  8
defaultAttackTable[object.uConnecticutArtillery.id]      = 10
defaultAttackTable[object.uNewYorkArtillery.id]          = 10
defaultAttackTable[object.uPennsylvaniaArtillery.id]     = 10
defaultAttackTable[object.uRhodeIslandArtillery.id]      = 10
defaultAttackTable[object.uFrenchHussars.id]             =  8
defaultAttackTable[object.uFrenchArtillery.id]           = 10
defaultAttackTable[object.uSpanishDragoons.id]           =  8
defaultAttackTable[object.uSpanishArtillery.id]          = 10
defaultAttackTable[object.uHessianSappers.id]            =  0
defaultAttackTable[object.uHessianLightCorps.id]         =  4
defaultAttackTable[object.uHessianMusketeers.id]         =  6
defaultAttackTable[object.uHessianGrenadiers.id]         =  7
defaultAttackTable[object.uHessianJaegerRegt.id]         =  8
defaultAttackTable[object.uHessianDragoons.id]           =  8
defaultAttackTable[object.uHessianArtillery.id]          = 10
defaultAttackTable[object.uTribesmen.id]                 =  4
defaultAttackTable[object.uHorsemen.id]                  =  8
defaultAttackTable[object.uMountedSpearmen.id]           =  8
defaultAttackTable[object.uChiefsBodyguards.id]          =  8
defaultAttackTable[object.uNewYorkLoyalists.id]          =  5
defaultAttackTable[object.uNorthCarolinaLoyalists.id]    =  5
defaultAttackTable[object.uPennsylvaniaLoyalists.id]     =  5
defaultAttackTable[object.uIrishVolunteers.id]           =  5
defaultAttackTable[object.uColouredTroops.id]            =  4
defaultAttackTable[object.uEthiopianRegt.id]             =  5
defaultAttackTable[object.uRogersRangers.id]             =  8
defaultAttackTable[object.uNewfoundlandLoyalists.id]     =  5
defaultAttackTable[object.uKingsAmericanRegt.id]         =  5
defaultAttackTable[object.uCharlesCornwallis.id]         =  8
defaultAttackTable[object.uWilliamHowe.id]               =  8
defaultAttackTable[object.uHenryClinton.id]              =  8
defaultAttackTable[object.uJohnBurgoyne.id]              =  8
defaultAttackTable[object.uBanastreTarleton.id]          =  8
defaultAttackTable[object.uLordDunmore.id]               =  8
defaultAttackTable[object.uStockbridgeMohicans.id]       =  5
defaultAttackTable[object.uGreenMountainBoys.id]         =  7
defaultAttackTable[object.uMorgansRifles.id]             =  8
defaultAttackTable[object.uLeesLegion.id]                =  8
defaultAttackTable[object.uArmandsLegion.id]             =  8
defaultAttackTable[object.uGeorgeWashington.id]          =  8
defaultAttackTable[object.uHoratioGates.id]              =  8
defaultAttackTable[object.uMarquisdeLaFayette.id]        =  8
defaultAttackTable[object.uWilhelmvonSteuben.id]         =  8
defaultAttackTable[object.uFootGuards.id]                =  7
defaultAttackTable[object.uIrishRegt.id]                 =  7
defaultAttackTable[object.uRoyalWelshFusiliers.id]       =  7
defaultAttackTable[object.uNewYorkLightCorps.id]         =  5
defaultAttackTable[object.u1stPennsylvaniaRegt.id]       =  7
defaultAttackTable[object.uLauzansLegion.id]             =  7
defaultAttackTable[object.uGatinoisRegt.id]              =  7
defaultAttackTable[object.uSaintongeRegt.id]             =  7
defaultAttackTable[object.uRoyalDeuxPontsRegt.id]        =  7
defaultAttackTable[object.uComtedeRochambeau.id]         =  8
defaultAttackTable[object.uWaldeckRegt.id]               =  7
defaultAttackTable[object.uvonKnyphausenRegt.id]         =  7
defaultAttackTable[object.uvonRallsGrenadierRegt.id]     =  7
defaultAttackTable[object.uJohannRall.id]                =  8
defaultAttackTable[object.uEastIndiaman.id]              =  0
defaultAttackTable[object.uPrivateers.id]                =  5
defaultAttackTable[object.uFrigate.id]                   =  6
defaultAttackTable[object.uShipoftheLine.id]             = 10
defaultAttackTable[object.uManofWar.id]                  = 12
defaultAttackTable[object.uPirateShip.id]                =  6
defaultAttackTable[object.uCannonballs.id]               =  1


--simpleAttackBonusTable[activeUnit.type.id] ={[bonusUnitType.id]=bonusNumber}
--simpleAttackBonusTable.type = string
--if simpleAttackBonusTable.type == "addbonus" then
-- add the bonusNumber to the base attack
--if simpleAttackBonusTable.type == "addpercent"
-- add bonusNumber percent to the unit's attack
-- i.e. attack 6, bonusNumber 50, new attack 9
--if simpleAttackBonusTable.type == "addfraction"
-- add the fraction of the attack value to the attack,
-- i.e. attack 6, bonusNumber 0.5, new attack 9
-- if simpleAttackBonusTable.type == "multiplypercent" then
-- multiply the unit's attack by the bonusNumber precent
-- i.e. attack 6, bonusNumber 150, new attack 9
-- if simpleAttackBonusTable.type == "multiply" then
-- multiply the unit's attack by bonusNumber
-- i.e. attack 6, bonusNumber 1.5, new attack 9
--simpleAttackBonusTable.round = "up" or "down" or "standard" or nil
-- nil means "standard"
-- "up" means a fractional attack value after a bonus is rounded up
-- "down" means a fractional attack value after a bonus is rounded down
-- "standard" means a fractional attack value is rounded down
-- if fraction part is less than 0.5, and rounded up otherwise


local simpleAttackBonus = {}
simpleAttackBonus.type = "addpercent"
simpleAttackBonus.round = "standard"

local commonBonuses = {}

-- any unit in the simple attack table with value commonBonuses.loyalistInfantry gets a 50% attack bonus
-- when activated in the same square as charles cornwallis, and 30% if activated in the square with a
-- william howe unit
commonBonuses.loyalistInfantry = {[object.uCharlesCornwallis.id]=50, [object.uWilliamHowe.id] = 30,}

-- any unit in the simple attack table with value commonBonuses.rebelInfantry gets a 50% attack bonus when
-- activated in the same square as George Washington, and a 30% bonus if activated in a square with
-- horatio gates
commonBonuses.rebelInfantry = {[object.uGeorgeWashington.id] = 50, [object.uHoratioGates.id] = 30,}
-- note, in this example, Virginia Line units get a 100% bonus from Washington, so they don't use the 
-- commonBonuses.rebelInfantry, but,rather, a custom table

simpleAttackBonus[object.uFarmer.id]                    =  nil
simpleAttackBonus[object.uEngineers.id]                 =  nil
simpleAttackBonus[object.uLightCorps.id]                =  nil
simpleAttackBonus[object.uLineInfantry.id]              =  nil
simpleAttackBonus[object.uRoyalMarines.id]              =  nil
simpleAttackBonus[object.uLineGrenadiers.id]            =  nil
simpleAttackBonus[object.uHighlanderRegt.id]            =  nil
--simpleAttackBonus[]                                   =  1
simpleAttackBonus[object.uPirates.id]                   =  nil
simpleAttackBonus[object.uMinutemen.id]                 =  nil
simpleAttackBonus[object.uBritishLegion.id]             =  nil
simpleAttackBonus[object.uLoyalists.id]                 =  commonBonuses.loyalistInfantry

simpleAttackBonus[object.uCanadianLoyalists.id]         =  nil
simpleAttackBonus[object.uQueensRangers.id]             =  nil
simpleAttackBonus[object.uDutchLineInfantry.id]         =  nil
simpleAttackBonus[object.uFrenchFusiliers.id]           =  nil
simpleAttackBonus[object.uFrenchGrenadiers.id]          =  nil
simpleAttackBonus[object.uSpanishMusketeers.id]         =  nil
simpleAttackBonus[object.uSpanishGrenadiers.id]         =  nil
simpleAttackBonus[object.uFortress.id]                  =  nil
simpleAttackBonus[object.uContinentalLightCorps.id]     =  nil
simpleAttackBonus[object.uConnecticutLine.id]           =  nil
simpleAttackBonus[object.uCitadel.id]                   =  nil
simpleAttackBonus[object.uDelawareLine.id]              =  nil
simpleAttackBonus[object.uGeorgiaLine.id]               =  nil
simpleAttackBonus[object.uMassachusettsLine.id]         =  nil
simpleAttackBonus[object.uMarylandLine.id]              =  nil
simpleAttackBonus[object.uNewHampshireLine.id]          =  nil
simpleAttackBonus[object.uNewYorkLine.id]               =  nil
simpleAttackBonus[object.uNewJerseyLine.id]             =  nil
simpleAttackBonus[object.uNorthCarolinaLine.id]         =  nil
simpleAttackBonus[object.uPennsylvaniaLine.id]          =  nil
simpleAttackBonus[object.uRhodeIslandLine.id]           =  nil
simpleAttackBonus[object.uSouthCarolinaLine.id]         =  nil
simpleAttackBonus[object.uVirginiaLine.id]              =  nil
simpleAttackBonus[object.uContinentalRifles.id]         =  nil
simpleAttackBonus[object.uMississippiRegt.id]           =  nil
simpleAttackBonus[object.uLouisianaRegt.id]             =  nil
simpleAttackBonus[object.uFloridaRegt.id]               =  nil
simpleAttackBonus[object.uWarriorSociety.id]            =  nil
simpleAttackBonus[object.uArchers.id]                   =  nil
simpleAttackBonus[object.uTomahawkThrower.id]           =  nil
simpleAttackBonus[object.uWarriors.id]                  =  nil
simpleAttackBonus[object.uMusketmen.id]                 =  nil
simpleAttackBonus[object.uEastIndiaCoRegt.id]           =  nil
--simpleAttackBonus[]                                   =  1
simpleAttackBonus[object.uNobleCitizen.id]              =  nil
simpleAttackBonus[object.uTrapper.id]                   =  nil
simpleAttackBonus[object.uSupplyWagon.id]               =  nil
simpleAttackBonus[object.uMerchant.id]                  =  nil
simpleAttackBonus[object.uLightDragoons.id]             =  nil
simpleAttackBonus[object.uQueensLightDragoons.id]       =  nil
simpleAttackBonus[object.uMountedLoyalists.id]          =  nil
simpleAttackBonus[object.uQueensHussars.id]             =  nil
simpleAttackBonus[object.uTarletonsDragoons.id]         =  nil
simpleAttackBonus[object.uFieldArtillery.id]            =  nil
simpleAttackBonus[object.uFieldHowitzer.id]             =  nil
simpleAttackBonus[object.uConnecticutDragoons.id]       =  nil
simpleAttackBonus[object.uNewJerseyDragoons.id]         =  nil
simpleAttackBonus[object.uPennsylvaniaDragoons.id]      =  nil
simpleAttackBonus[object.uSouthCarolinaDragoons.id]     =  nil
simpleAttackBonus[object.uGeorgiaDragoons.id]           =  nil
simpleAttackBonus[object.uConnecticutArtillery.id]      =  nil
simpleAttackBonus[object.uNewYorkArtillery.id]          =  nil
simpleAttackBonus[object.uPennsylvaniaArtillery.id]     =  nil
simpleAttackBonus[object.uRhodeIslandArtillery.id]      =  nil
simpleAttackBonus[object.uFrenchHussars.id]             =  nil
simpleAttackBonus[object.uFrenchArtillery.id]           =  nil
simpleAttackBonus[object.uSpanishDragoons.id]           =  nil
simpleAttackBonus[object.uSpanishArtillery.id]          =  nil
simpleAttackBonus[object.uHessianSappers.id]            =  nil
simpleAttackBonus[object.uHessianLightCorps.id]         =  nil
simpleAttackBonus[object.uHessianMusketeers.id]         =  nil
simpleAttackBonus[object.uHessianGrenadiers.id]         =  nil
simpleAttackBonus[object.uHessianJaegerRegt.id]         =  nil
simpleAttackBonus[object.uHessianDragoons.id]           =  nil
simpleAttackBonus[object.uHessianArtillery.id]          =  nil
simpleAttackBonus[object.uTribesmen.id]                 =  nil
simpleAttackBonus[object.uHorsemen.id]                  =  nil
simpleAttackBonus[object.uMountedSpearmen.id]           =  nil
simpleAttackBonus[object.uChiefsBodyguards.id]          =  nil
simpleAttackBonus[object.uNewYorkLoyalists.id]          =  nil
simpleAttackBonus[object.uNorthCarolinaLoyalists.id]    =  nil
simpleAttackBonus[object.uPennsylvaniaLoyalists.id]     =  nil
simpleAttackBonus[object.uIrishVolunteers.id]           =  nil
simpleAttackBonus[object.uColouredTroops.id]            =  nil
simpleAttackBonus[object.uEthiopianRegt.id]             =  nil
simpleAttackBonus[object.uRogersRangers.id]             =  nil
simpleAttackBonus[object.uNewfoundlandLoyalists.id]     =  nil
simpleAttackBonus[object.uKingsAmericanRegt.id]         =  nil
simpleAttackBonus[object.uCharlesCornwallis.id]         =  nil
simpleAttackBonus[object.uWilliamHowe.id]               =  nil
simpleAttackBonus[object.uHenryClinton.id]              =  nil
simpleAttackBonus[object.uJohnBurgoyne.id]              =  nil
simpleAttackBonus[object.uBanastreTarleton.id]          =  nil
simpleAttackBonus[object.uLordDunmore.id]               =  nil
simpleAttackBonus[object.uStockbridgeMohicans.id]       =  nil
simpleAttackBonus[object.uGreenMountainBoys.id]         =  nil
simpleAttackBonus[object.uMorgansRifles.id]             =  nil
simpleAttackBonus[object.uLeesLegion.id]                =  nil
simpleAttackBonus[object.uArmandsLegion.id]             =  nil
simpleAttackBonus[object.uGeorgeWashington.id]          =  nil
simpleAttackBonus[object.uHoratioGates.id]              =  nil
simpleAttackBonus[object.uMarquisdeLaFayette.id]        =  nil
simpleAttackBonus[object.uWilhelmvonSteuben.id]        =  nil
simpleAttackBonus[object.uFootGuards.id]                =  nil
simpleAttackBonus[object.uIrishRegt.id]                 =  nil
simpleAttackBonus[object.uRoyalWelshFusiliers.id]       =  nil
simpleAttackBonus[object.uNewYorkLightCorps.id]         =  nil
simpleAttackBonus[object.u1stPennsylvaniaRegt.id]       =  nil
simpleAttackBonus[object.uLauzansLegion.id]             =  nil
simpleAttackBonus[object.uGatinoisRegt.id]              =  nil
simpleAttackBonus[object.uSaintongeRegt.id]             =  nil
simpleAttackBonus[object.uRoyalDeuxPontsRegt.id]        =  nil
simpleAttackBonus[object.uComtedeRochambeau.id]         =  nil
simpleAttackBonus[object.uWaldeckRegt.id]               =  nil
simpleAttackBonus[object.uvonKnyphausenRegt.id]         =  nil
simpleAttackBonus[object.uvonRallsGrenadierRegt.id]     =  nil
simpleAttackBonus[object.uJohannRall.id]                =  nil
simpleAttackBonus[object.uEastIndiaman.id]              =  nil
simpleAttackBonus[object.uPrivateers.id]                =  nil
simpleAttackBonus[object.uFrigate.id]                   =  nil
simpleAttackBonus[object.uShipoftheLine.id]             =  nil
simpleAttackBonus[object.uManofWar.id]                  =  nil
simpleAttackBonus[object.uPirateShip.id]                =  nil
simpleAttackBonus[object.uCannonballs.id]               =  nil




attackBonusSettings.defaultAttackTable = defaultAttackTable
attackBonusSettings.simpleAttackBonusTable = simpleAttackBonus

return attackBonusSettings

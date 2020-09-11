local object = {}

-- Civilization Advances
-- recommended key prefix 'a'
--
object.aSocialJustice=civ.getTech(0)
object.aNONIONIAN=civ.getTech(1)
object.aStandardCurrency=civ.getTech(2)
object.aNavigation=civ.getTech(3)
object.aOlympicGames=civ.getTech(4)
object.aCITYSTYLE1=civ.getTech(5)
object.aBanking=civ.getTech(6)
object.aBridgeBuilding=civ.getTech(7)
object.aBronzeCasting=civ.getTech(8)
object.aDrama=civ.getTech(9)
object.aAmphora=civ.getTech(10)
--object.aCUT=civ.getTech(11)
object.aPolis=civ.getTech(12)
object.aColonization=civ.getTech(13)
object.aAgora=civ.getTech(14)
object.aTwinMonarchy=civ.getTech(15)
object.aMerchantilism=civ.getTech(16)
--object.aCUT=civ.getTech(17)
--object.aCUT=civ.getTech(18)
object.aLiteracy=civ.getTech(19)
object.aPapyrus=civ.getTech(20)
object.aDemocracy=civ.getTech(21)
object.aPhoenicianAlphabet=civ.getTech(22)
object.aPoetry=civ.getTech(23)
object.aThePriesthood=civ.getTech(24)
object.aGrainTrade=civ.getTech(25)
object.aSculpture=civ.getTech(26)
object.aCultofApollo=civ.getTech(27)
object.aMathematics=civ.getTech(28)
object.aFishingFleet=civ.getTech(29)
--object.aCUT=civ.getTech(30)
object.aWarCouncil=civ.getTech(31)
object.aTragedy=civ.getTech(32)
object.aIronForging=civ.getTech(33)
object.aSTART1=civ.getTech(34)
--object.aCUT=civ.getTech(35)
object.aMetropolis=civ.getTech(36)
--object.aCUT=civ.getTech(37)
object.aSTART2=civ.getTech(38)
--object.aCUT=civ.getTech(39)
object.aHarbourDefences=civ.getTech(40)
object.aAdvancedMining=civ.getTech(41)
--object.aCUT=civ.getTech(42)
object.aIambicPerameter=civ.getTech(43)
object.aTradeCentres=civ.getTech(44)
--object.aCUT=civ.getTech(45)
object.aMapping=civ.getTech(46)
object.aMedicine=civ.getTech(47)
object.aScience=civ.getTech(48)
object.aRiverPorts=civ.getTech(49)
object.aMusic=civ.getTech(50)
--object.aCUT=civ.getTech(51)
object.aMartialPride=civ.getTech(52)
--object.aCUT=civ.getTech(53)
object.aTyranny=civ.getTech(54)
object.aSTART3=civ.getTech(55)
object.aEpicPoetry=civ.getTech(56)
--object.aCUT=civ.getTech(57)
object.aCivilTaxation=civ.getTech(58)
object.aMasterShipbuilders=civ.getTech(59)
object.aCITYSTYLE2=civ.getTech(60)
object.aNONATHENIAN=civ.getTech(61)
object.aCitizenship=civ.getTech(62)
object.aGrainMarkets=civ.getTech(63)
--object.aCUT=civ.getTech(64)
object.aShipbuildingYards=civ.getTech(65)
object.aLYDIANSETTLERS=civ.getTech(66)
--object.aCUT=civ.getTech(67)
object.aPhilosophy=civ.getTech(68)
object.aSlaveTrading=civ.getTech(69)
object.aLandReform=civ.getTech(70)
object.aOligarchy=civ.getTech(71)
object.aLinenCuirass=civ.getTech(72)
object.aBiremes=civ.getTech(73)
object.aCivicPride=civ.getTech(74)
object.aAstronomy=civ.getTech(75)
object.aNONCORINTHIAN=civ.getTech(76)
object.aEngineering=civ.getTech(77)
object.aRecurvedBow=civ.getTech(78)
object.aPolitics=civ.getTech(79)
object.aGymnetes=civ.getTech(80)
object.aStonecutting=civ.getTech(81)
object.aLyricalPoetry=civ.getTech(82)
object.aArt=civ.getTech(83)
object.aCurrency=civ.getTech(84)
object.aGymnastics=civ.getTech(85)
object.aArchitecture=civ.getTech(86)
object.aHistory=civ.getTech(87)
object.aLandRights=civ.getTech(88)
object.aHellenicCulture=civ.getTech(89)
object.aElitism=civ.getTech(90)
object.aMasterCraftsmen=civ.getTech(91)
object.aConstruction=civ.getTech(92)
object.aRiseoftheMedes=civ.getTech(93)
object.aPersianInvasion=civ.getTech(94)
object.aNONSPARTAN=civ.getTech(95)
object.aNONLYDIAN=civ.getTech(96)
object.aNONETRUSCAN=civ.getTech(97)
object.aNONPHOENICIAN=civ.getTech(98)
object.aNONHELLENIC=civ.getTech(99)

-- Map Locations (tiles/squares)
-- recommended key prefix 'l'



-- Cities
-- recommended key prefix 'c'
-- It is not recommended to put cities into this list if the city
-- can be destroyed. This list returns an error if 'nil' is the value
-- associated with the key (see bottom of file), so that could cause
-- a problem if a city in this list is destroyed.  Also, if another
-- city is founded, the ID number of the city might get reused, causing
-- more confusion.  An alternate way to reference a city is by using
-- object.lRome.city when you actually need the city (and suitably guarding
-- against nil values)

-- Unit Types
-- recommended key prefix 'u'
object.uColonist            =civ.getUnitType(0)
object.uEngineer            =civ.getUnitType(1)
object.uArchaicHopliteSpartan          =civ.getUnitType(2)
object.uClassicalHopliteSpartan            =civ.getUnitType(3)
object.uMercenaryHoplite            =civ.getUnitType(4)
object.uEtruscanHoplite         =civ.getUnitType(5)
object.uLydianHoplite           =civ.getUnitType(6)
object.uPsiloi          =civ.getUnitType(7)
object.uPersianImmortal         =civ.getUnitType(8)
object.uThracianWarrior         =civ.getUnitType(9)
object.uPersianSparhabara           =civ.getUnitType(10)
object.uPhoenicianHoplite           =civ.getUnitType(11)
object.uCretanArcher            =civ.getUnitType(12)
object.uToxotoi         =civ.getUnitType(13)
object.uSkythianArcher          =civ.getUnitType(14)
object.uSkythianHorseman            =civ.getUnitType(15)
object.uHellenicHoplite         =civ.getUnitType(16)
object.uLatinSpearman           =civ.getUnitType(17)
object.uThessalianCavalry           =civ.getUnitType(18)
object.uPeltast         =civ.getUnitType(19)
object.uIllyrianWarrior         =civ.getUnitType(20)
object.uLatinSkirmisher         =civ.getUnitType(21)
object.uBallista            =civ.getUnitType(22)
object.uPersianKardakes         =civ.getUnitType(23)
object.uBatteringRam            =civ.getUnitType(24)
object.uSiegeTower          =civ.getUnitType(25)
object.uCatapult            =civ.getUnitType(26)
object.uArchaicHopliteAthenian          =civ.getUnitType(27)
object.uClassicalHopliteAthenian            =civ.getUnitType(28)
object.uPersianTakhabara            =civ.getUnitType(29)
object.uNumidianWarrior         =civ.getUnitType(30)
object.uRhodianSlinger          =civ.getUnitType(31)
object.uLiburnae            =civ.getUnitType(32)
object.uSamniteWarrior          =civ.getUnitType(33)
object.uMacedonianWarrior           =civ.getUnitType(34)
object.uTransportShip           =civ.getUnitType(35)
object.uTransportGalley         =civ.getUnitType(36)
object.uPentreconter            =civ.getUnitType(37)
object.uBireme          =civ.getUnitType(38)
object.uTrireme         =civ.getUnitType(39)
object.uPunicGalley         =civ.getUnitType(40)
object.uSlave           =civ.getUnitType(41)
object.uCitizen         =civ.getUnitType(42)
object.uRecruiter           =civ.getUnitType(43)
object.uEasternFortress         =civ.getUnitType(44)
object.uStrategos           =civ.getUnitType(45)
object.uRichVillage         =civ.getUnitType(46)
object.uArchaicHopliteCorinthian          =civ.getUnitType(47)
object.uTrader          =civ.getUnitType(48)
object.uMerchant            =civ.getUnitType(49)
object.uHelot           =civ.getUnitType(50)
object.uArchaicHopliteIonian          =civ.getUnitType(51)
object.uClassicalHopliteIonian            =civ.getUnitType(52)
object.uTarentineCavalry            =civ.getUnitType(53)
object.uCampanianCavalry            =civ.getUnitType(54)
object.uPersianHorsemen         =civ.getUnitType(55)
object.uPersianCavalry          =civ.getUnitType(56)
object.uNumidianHorsemen            =civ.getUnitType(57)
object.uClassicalHopliteCorinthian            =civ.getUnitType(58)
object.uFortress            =civ.getUnitType(59)
object.uCelticWarrior           =civ.getUnitType(60)
object.uIberianWarrior          =civ.getUnitType(61)
--object.u= civ.getUnitType(62)
--object.u= civ.getUnitType(63)
--object.u= civ.getUnitType(64)
--object.u= civ.getUnitType(65)
--object.u= civ.getUnitType(66)
--object.u= civ.getUnitType(67)
--object.u= civ.getUnitType(68)
--object.u= civ.getUnitType(69)
--object.u= civ.getUnitType(70)
--object.u= civ.getUnitType(71)
--object.u= civ.getUnitType(72)
--object.u= civ.getUnitType(73)
--object.u= civ.getUnitType(74)
--object.u= civ.getUnitType(75)
--object.u= civ.getUnitType(76)
--object.u= civ.getUnitType(77)
--object.u= civ.getUnitType(78)
--object.u= civ.getUnitType(79)

-- City Improvements
-- recommended key prefix 'i'
--          
object.iNothing                 = civ.getImprovement(0)
object.iPalace                  = civ.getImprovement(1)
object.iBarracks                = civ.getImprovement(2)
object.iGranary                 = civ.getImprovement(3)
object.iTemple                  = civ.getImprovement(4)
object.iMarketPlace             = civ.getImprovement(5)
object.iLibrary                 = civ.getImprovement(6)
object.iCourthouse              = civ.getImprovement(7)
object.iCityWalls               = civ.getImprovement(8)
object.iAqueduct                = civ.getImprovement(9)
object.iBank                    = civ.getImprovement(10)
object.iCathedral               = civ.getImprovement(11)
object.iUniversity              = civ.getImprovement(12)
object.iMassTransit             = civ.getImprovement(13)
object.iColosseum               = civ.getImprovement(14)
object.iFactory                 = civ.getImprovement(15)
object.iManufacturingPlant      = civ.getImprovement(16)
object.iMasterBuilder           = civ.getImprovement(17)
object.iRecyclingCenter         = civ.getImprovement(18)
object.iPowerPlant              = civ.getImprovement(19)
object.iHydroPlant              = civ.getImprovement(20)
object.iNuclearPlant            = civ.getImprovement(21)
object.iStockExchange           = civ.getImprovement(22)
object.iSewerSystem             = civ.getImprovement(23)
object.iSupermarket             = civ.getImprovement(24)
object.iSuperhighways           = civ.getImprovement(25)
object.iResearchLab             = civ.getImprovement(26)
object.iGoldReserves            = civ.getImprovement(27)
object.iCoastalFortress         = civ.getImprovement(28)
object.iSolarPlant              = civ.getImprovement(29)
object.iHarbor                  = civ.getImprovement(30)
object.iOffshorePlatform        = civ.getImprovement(31)
object.iAirport                 = civ.getImprovement(32)
object.iPoliceStation           = civ.getImprovement(33)
object.iPortFacility            = civ.getImprovement(34)
object.iTransporter             = civ.getImprovement(35)

-- Tribes
-- recommended key prefix 't'
--
object.tMinorCities              = civ.getTribe(0)
object.tAthenians              = civ.getTribe(1)
object.tCorinthians              = civ.getTribe(2)
object.tIonians              = civ.getTribe(3)
object.tSpartans             = civ.getTribe(4)
object.tLydians               = civ.getTribe(5)
object.tPhoenicians            = civ.getTribe(6)
object.tEtruscans             = civ.getTribe(7)

-- Wonders
-- recommended key prefix 'w'
object.wBlackSeaGrainTrade                              =civ.getWonder(0)
object.wGreatTempleofApollo                     =civ.getWonder(1)
object.wColossus                        =civ.getWonder(2)
object.wLighthouse                      =civ.getWonder(3)
--object.wCUT                       =civ.getWonder(4)
object.wGreatTempleofPoseidon                       =civ.getWonder(5)
object.wLongWall                        =civ.getWonder(6)
object.wGreatAcademy                        =civ.getWonder(7)
object.wGrandMines                      =civ.getWonder(8)
object.wGrandEmbassy                        =civ.getWonder(9)
object.wGreatTempleofZeus                       =civ.getWonder(10)
object.wGreatObservatory                        =civ.getWonder(11)
object.wGreatVoyage                     =civ.getWonder(12)
object.wGreatTempleofAthena                     =civ.getWonder(13)
--object.wCUT                       =civ.getWonder(14)
object.wGreatTempleofDionysis                       =civ.getWonder(15)
object.wGreatCollege                        =civ.getWonder(16)
object.wGreatAgora                      =civ.getWonder(17)
object.wEurekaMoment                        =civ.getWonder(18)
object.wStatueofZeus                        =civ.getWonder(19)
object.wStatueofApollo                      =civ.getWonder(20)
object.wGreatTempleofArtemis                        =civ.getWonder(21)
object.wGreatForge                      =civ.getWonder(22)
--object.wCUT                       =civ.getWonder(23)
object.wGrandLeague                     =civ.getWonder(24)
--object.wCUT                               =civ.getWonder(25)
--object.wCUT                               =civ.getWonder(26)
object.wGreatTempleofAphrodite                      =civ.getWonder(27)

-- this will give you an if you try to access a key not entered into
-- the object table, which could be helpful for debugging, but it
-- means that no nil value can ever be returned for table object
-- If you need that ability, comment out this section
setmetatable(object,{__index = function(myTable,key)
    error("The object table doesn't have a value associated with "..tostring(key)..".") end})

return object

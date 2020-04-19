-- Provides Functionality related to diplomacy
--  diplomacy.warExists(tribe1,tribe2)-->bool
--  diplomacy.setWar(tribe1,tribe2)
--  diplomacy.clearWar(tribe1,tribe2)
--  diplomacy.contactExists(tribe1,tribe2)-->bool
--  diplomacy.setContact(tribe1,tribe2)
--  diplomacy.clearContact(tribe1,tribe2)
--  diplomacy.ceaseFireExists(tribe1,tribe2)-->bool
--  diplomacy.setCeaseFire(tribe1,tribe2)
--  diplomacy.clearCeaseFire(tribe1,tribe2)
--  diplomacy.peaceTreatyExists(tribe1,tribe2)-->bool
--  diplomacy.setPeaceTreaty(tribe1,tribe2)
--  diplomacy.clearPeaceTreaty(tribe1,tribe2)
--  diplomacy.allianceExists(tribe1,tribe2)-->bool
--  diplomacy.setAlliance(tribe1,tribe2)
--  diplomacy.clearAlliance(tribe1,tribe2)
--  diplomacy.hasEmbassyWith(ownerTribe,hostTribe) -->bool
--  diplomacy.setEmbassyWith(ownerTribe,hostTribe)
--  diplomacy.clearEmbassyWith(ownerTribe,hostTribe)
--  diplomacy.hasVendettaWith(angryTribe,offendingTribe)-->bool
--  diplomacy.setVendettaWith(angryTribe,offendingTribe)
--  diplomacy.clearVendettaWith(angryTribe,offendingTribe)

local gen = require("generalLibrary")
local text = require("text")
local civlua = require("civlua")

local diplomacy = {}

local diplomacyState = "notLinked"

local function linkState(tableInState)
    if type(tableInState)~="table" then
        error("diplomacy.linkState takes a table as an argument.")
    else
        diplomacyState = tableInState
    end
    diplomacyState.diplomaticOffers = diplomaticOffers.diplomaticOffers or {}
end
diplomacy.linkState = linkState

-- checkSymmetricBit1(int1,int2,bitNumber,errorMessage)-->bool
-- if the bitNumber'th bit in int1 and int2 are both 1,
-- then return true
-- if they are both 0, then return false,
-- if they are different, then return an error
local function checkSymmetricBit1(int1,int2,bitNumber,errorMessage)
    local int1Bit = gen.isBit1(int1,bitNumber)
    local int2Bit = gen.isBit1(int2,bitNumber)
    if int1Bit == int2Bit then
        return int1Bit
    else
        -- bits are not symmetric
        error(errorMessage)
    end
end


-- 
-- setTreatiesBit1(tribe1,tribe2,bitNumber,tribe1Only=nil)-->void
-- changes the treaties for tribe1 and tribe2, setting the corresponding
-- bit to 1, unless tribe1Only is true, in which case, only tribe1's treaties
-- are changed
local function setTreatiesBit1(tribe1,tribe2,bitNumber,tribe1Only)
    tribe1.treaties[tribe2] = gen.setBit1(tribe1.treaties[tribe2],bitNumber)
    if tribe1Only then
        return
    else
        tribe2.treaties[tribe1]=gen.setBit1(tribe2.treaties[tribe1],bitNumber)
    end
end

-- setTreatiesBit0(tribe1,tribe2,bitNumber,tribe1Only=nil)-->void
-- changes the treaties for tribe1 and tribe2, setting the corresponding
-- bit to 0, unless tribe1Only is true, in which case, only tribe1's treaties
-- are changed
local function setTreatiesBit0(tribe1,tribe2,bitNumber,tribe1Only)
    tribe1.treaties[tribe2] = gen.setBit0(tribe1.treaties[tribe2],bitNumber)
    if tribe1Only then
        return
    else
        tribe2.treaties[tribe1]=gen.setBit0(tribe2.treaties[tribe1],bitNumber)
    end

end


local function warExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],14,
    "warExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric war status.")
end
diplomacy.warExists = warExists

local function setWar(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,14)
end
diplomacy.setWar = setWar

local function clearWar(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,14)
end
diplomacy.clearWar = clearWar

local function contactExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],1,
    "contactExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric contact status.")
end
diplomacy.contactExists = contactExists

local function setContact(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,1)
end
diplomacy.setContact = setContact

local function clearContact(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,1)
end
diplomacy.clearContact = clearContact

local function ceaseFireExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],2,
    "ceaseFireExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric Cease Fire status.")
end
diplomacy.ceaseFireExists = ceaseFireExists

local function setCeaseFire(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,2)
end
diplomacy.setCeaseFire = setCeaseFire

local function clearCeaseFire(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,2)
end
diplomacy.clearCeaseFire = clearCeaseFire

local function peaceTreatyExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],3,
    "peaceTreatyExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric Peace Treaty status.")
end
diplomacy.peaceTreatyExists = peaceTreatyExists

local function setPeaceTreaty(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,3)
end
diplomacy.setPeaceTreaty = setPeaceTreaty

local function clearPeaceTreaty(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,3)
end
diplomacy.clearPeaceTreaty = clearPeaceTreaty

local function allianceExists(tribe1,tribe2)
    return checkSymmetricBit1(tribe1.treaties[tribe2],tribe2.treaties[tribe1],4,
    "allianceExists: the "..tribe1.name.." and "..tribe2.name.." do not have a symmetric Alliance status.")
end
diplomacy.allianceExists = allianceExists

local function setAlliance(tribe1,tribe2)
    setTreatiesBit1(tribe1,tribe2,4)
end
diplomacy.setAlliance = setAlliance

local function clearAlliance(tribe1,tribe2)
    setTreatiesBit0(tribe1,tribe2,4)
end
diplomacy.clearAlliance = clearAlliance

local function hasEmbassyWith(ownerTribe,hostTribe)
    return gen.isBit1(ownerTribe.treaties[hostTribe],8)
end
diplomacy.hasEmbassyWith = hasEmbassyWith

local function setEmbassyWith(ownerTribe,hostTribe)
    setTreatiesBit1(tribe1,tribe2,8,true)
end
diplomacy.setEmbassyWith = setEmbassyWith

local function clearEmbassyWith(ownerTribe,hostTribe)
    setTreatiesBit0(tribe1,tribe2,8,true)
end
diplomacy.clearEmbassyWith = clearEmbassyWith

local function hasVendettaWith(angryTribe,offendingTribe)
    return gen.isBit1(ownerTribe.treaties[hostTribe],5)
end
diplomacy.hasVendettaWith = hasVendettaWith

local function setVendettaWith(angryTribe,offendingTribe)
    setTreatiesBit1(tribe1,tribe2,5,true)
end
diplomacy.setVendettaWith = setVendettaWith

local function clearVendettaWith(angryTribe,offendingTribe)
    setTreatiesBit0(tribe1,tribe2,5,true)
end
diplomacy.clearVendettaWith = clearVendettaWith


-- a diplomaticOffer is a table with the following keys
--  .offerMaker = tribeID
--      the ID number of the tribe making the offer of a change in the
--      diplomatic state
--  .offerReceiver = tribeID
--      the ID number of the tribe receiving the offer of a change in
--      the diplomatic state
--  .offerType = string
--      "peace" offer is to establish a peace treaty
--      "ceaseFire" offer is to establish a cease fire state
--      "alliance" offer is to establish an alliance
--  .offerMoney = integer
--      The tribe making the offer will give this amount of money
--      to the receiver if the offer is accepted (or all money, 
--      if treasury is smaller)
--  .demandMoney = integer
--      The tribe making the offer will take this amount of money
--      from the receiver if the offer is accepted.  Offer can't be
--      accepted if receiver doesn't have the money
--

-- manageDiplomaticOffers(tribeID,functionState,offer)
--      
local function manageDiplomaticOffers(tribeID,functionState,offer)
   local functionState = functionState or "choose"
end

local function textTransform(s, translationTable)
   for i,v in pairs(translationTable) do
      s = s:gsub(v.code, v.value)
   end
   return s
end
      


-- Default amounts of money for gift-money screen
local defaultGiftMoneyAmounts = {}
defaultGiftMoneyAmounts[1] = "Add 1"
defaultGiftMoneyAmounts[5] = "Add 5"
defaultGiftMoneyAmounts[10] = "Add 10"
defaultGiftMoneyAmounts[50] = "Add 50"
defaultGiftMoneyAmounts[100] = "Add 100"
defaultGiftMoneyAmounts[500] = "Add 500"
defaultGiftMoneyAmounts[1000] = "Add 1000"
defaultGiftMoneyAmounts[5000] = "Add 5000"
defaultGiftMoneyAmounts[10000] = "Add 5000"

-- Offers a menu to gift a given amount of money 
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * giftMoneyText -> Text to display in main dialog text
--                 * giftMoneyConfirmation -> Text to display when money is gifted
--                 * giftMoneyAmounts -> A table with the available amounts and the text associated with them
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * %MONEY -> The amount of money given out
--
--    Tribe: The tribe to pass money to
local function giftMoneyMenu(tribe, options)
   translationTable = { { code = "%%RECEIVER", value = tribe.name } };
   options = options or {}
   giftMoneyText = options.giftMoneyText or "Which amount should we gift to our %RECEIVER friends?"
   giftMoneyText = textTransform(giftMoneyText, translationTable)
   giftMoneyAmounts = options.giftMoneyAmounts or defaultGiftMoneyAmounts
   player = civ.getCurrentTribe()
   totalMoney  = 0
   ended = False
   repeat
      menuTable = {}
      lastOne = 1
      for i,v in pairs(giftMoneyAmounts) do
	 if(i<=(player.money-totalMoney)) then
	    menuTable[i] = v
	 end
	 if(i+1) > lastOne then
	    lastOne = i+1
	 end
      end
      if(totalMoney>0) then
	 menuTable[lastOne] = "Yes, give "..tostring(totalMoney).."!"
      end
      tmp = giftMoneyText .. "(".. tostring(totalMoney).. " cumulated)"
      money = text.menu(menuTable, tmp, tmp, true)
      if giftMoneyAmounts[money]~=nil then
	 totalMoney = totalMoney + money
      end
   until giftMoneyAmounts[money]==nil
   if money~=0 then
      tribe.money = tribe.money + totalMoney
      player.money = player.money - totalMoney
      translationTable[#translationTable + 1 ] = { code = "%%MONEY", value = totalMoney }
      message = options.giftMoneyConfirmation or "%MONEY sent to our %RECEIVER friends!"
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   end
end

--- Destroy (and retun all units in tile)
---
---   param is tile
---
---   returns array of units that have been destroyed
local function destroyUnitsIn(tile)
   units = {}
   for unit in tile.units do
      units[#units+1] = { unittype = unit.type, veteran = unit.veteran, damage = unit.damage }
   end
   for unit in tile.units do
      civ.deleteUnit(unit)
   end
   return units
end

-- Recreate array of units in tile (or set of tiles) for tribe
--
--   params are
--             units = array of units to be recreated
--             tile = Position, or a table of positions (see civlua.createUnit)
--             tribe = Owner of the unit
--
--   returns true if all are created, false otherwise
local function recreateUnitsIn(units, tile, tribe)
   allGood = true
   for i,unit in pairs(units) do
      x = civlua.createUnit(unit.unittype, tribe, position)
      if x~=nil then
	 x.veteran = unit.veteran
	 x.damage = unit.damage
      else
	 allGood = false
      end
   end
   return allGood
end



-- Gift units to another tribe and display text
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * giftUnitsMaxCharUnitList -> Limit of characters for the list of units description (default: 300)
--                 * giftUnitsText -> Text to be shown to ask for confirmation
--                 * giftUnitsConfirmation -> Dialog to show after confirmation
--                 * giftUnitsLocations -> A list of locations per tribe name to put the gift. It will start with the first one,
--                                           and use all of them until one is valid
--                 * giftUnitsError -> A error message to be displayed in case no suitable location is found
--                   (only happens when giftUnitsLocations is provided)
--
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * %TILE     -> Tile where it happens
--                 * %UNITS     -> Friendly text about the units given
--
local function giftUnits(tribe, options)
   local function buildUnitsText(tile, maxcChar)
      local text = ""
      byType = {}
      for unit in tile.units do
	 if byType[unit.type.id] == nil then
	    byType[unit.type.id] = 1
	 else
	    byType[unit.type.id] = byType[unit.type.id] + 1
	 end
      end
      for i,v in pairs(byType) do
	 if text:len() < maxChar then
	    thisPart = tostring(v).." "..civ.getUnitType(i).name
	    if text == "" then
	       text = thisPart
	    else
	       text = text..", "..thisPart
	    end
	 end
      end
      return text
   end
	 
   tile = civ.getCurrentTile()
   maxChar = options.giftUnitsMaxCharUnitList or 300
   translationTable = { { code = "%%RECEIVER", value = tribe.name },
      { code = "%%TILE", value = tostring(tile.x)..","..tostring(tile.y).." in map "..tostring(tile.z) },
      { code = "%%UNITS", value = buildUnitsText(tile,maxchar) }}
   giftUnitsQuestion = options.giftUnitsText or "Do you confirm gifting %UNITS to %RECEIVER in %TILE?"
   giftUnitsQuestion = textTransform(giftUnitsQuestion, translationTable)
   menuTable = {}
   menuTable[1] = "Ok!"
   goAhead = text.menu(menuTable, giftUnitsQuestion, giftUnitsQuestion, true)
   if goAhead == 1 then
      units = destroyUnitsIn(tile)
      if options.giftUnitsLocations ~= nil and options.giftUnitsLocations[tribe.name] ~= nil then
	 position = options.giftUnitsLocations[tribe.name]
      else
	 position = {{ tile.x, tile.y, tile.z }}
      end
      if recreateUnitsIn(units, position, tribe) then
	 message = options.giftUnitsConfirmation or "Units in %TILE transferred to %RECEIVER"
      else
	 message = options.giftUnitsError or "Some units were lost as no suitable destination square was found!"
      end
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   end
end

-- Gift a city (non-captial) to another tribe and display text
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * giftCityText -> Text to be shown to ask for confirmation
--                 * giftCityConfirmation -> Dialog to show after confirmation
--                 * giftCityDestroyUnits -> Whether all units needs to be destroyed after the city is given out
--
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * %CITY     -> Name of the city
--
local function giftCity(tribe, options)
   tile = civ.getCurrentTile()
   city = tile.city
   translationTable = { { code = "%%RECEIVER", value = tribe.name },
      { code = "%%CITY", value = city.name } }
   giftCityQuestion = options.giftCityText or "Do you confirm gifting %CITY to %RECEIVER?"
   giftCityQuestion = textTransform(giftCityQuestion, translationTable)
   menuTable = {}
   menuTable[1] = "Ok!"
   goAhead = text.menu(menuTable, giftCityQuestion, giftCityQuestion, true)
   if goAhead == 1 then
      units = destroyUnitsIn(tile)
      destroyUnits = options.giftCityDestroyUnits or false
      city.owner = tribe
      position = {{ tile.x, tile.y, tile.z }}
      if destroyUnits or recreateUnitsIn(units, position, tribe) then
	 message = options.giftCityConfirmation or "%CITY transferred to %RECEIVER"
      else
	 message = "Unexpected error - Some units were lost!"
      end
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   end
end


-- Gift a technology to another tribe and display text
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * giftTechText -> Tech to be shown in the Tech window
--                 * giftTechConfirmation -> Text to show when map is passed
--                 * giftTechNoTechs -> Text to show when no tech to offer
--                 * giftTechNotTrade -> Table with names of techs that can't be traded
--
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * $tech     -> Name of the tech
--
local function giftTechnology(tribe, options) -- 
   local function techInTable(tech, techTable)
      for i, v in pairs(techTable) do
	 if v == tech.name then
	    return true
	 end
      end
      return false
   end

   translationTable = { { code = "%%RECEIVER", value = tribe.name } };
   player = civ.getCurrentTribe()
   listTechs = {}
   techTechs = {}
   techTable = options.giftTechNotTrade or {}
   for techId = 0,99 do
      tech = civ.getTech(techId)
      if not tribe:hasTech(tech) and player:hasTech(tech) and not techInTable(tech, techTable)
      then
	 listTechs[#listTechs+1] = tech.name
	 techTechs[#techTechs+1] = tech
      end
   end
   if #listTechs == 0 then
      message = options.giftTechNoTechs or  "There are no tech we can give to %RECEIVER"
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   else
      giftTechText = options.giftTechText or "Which tech to give our friends %RECEIVER?"
      giftTechText = textTransform(giftTechText, translationTable)
      techId = text.menu(listTechs, giftTechText, giftTechText, true)
      if techId ~= 0 then
	 tech = techTechs[techId]
	 translationTable[#translationTable + 1] = { code = "$tech", value = tech.name } ;
	 tribe:giveTech(tech)
	 message = options.giftTechConfirmation or "$tech given to %RECEIVER"
	 message = textTransform(message, translationTable)
	 civ.ui.text(message)
      end
   end
end
   



-- Offers a menu to present what can be given as a present to other civ
--
--    options is an optional table, and may contain different configuration
--    parameters for what and how to offer
--                 * mainDialogText -> Text to display in main dialog text
--                 * civSelectionText -> Text to display when selecting destination civ
--                 * giftMoneyText -> Text to display in main dialog text
--                 * giftMoneyConfirmation -> Text to display when money is gifted
--                 * giftMoneyAmounts -> A table with the available amounts and the text associated to them
--                 * sameCivPlayer -> Text when a player attemps to gift something to his/herself.
--                 * giftUnitsMaxCharUnitList -> Limit of characters for the list of units description (default: 300)
--                 * giftUnitsText -> Text to be shown to ask for confirmation
--                 * giftUnitsConfirmation -> Dialog to show after confirmation
--                 * giftUnitsLocations -> A list of locations per tribe name to put the gift. It will start with the first one,
--                                           and use all of them until one is valid
--                 * giftUnitsError -> A error message to be displayed in case no suitable location is found
--                   (only happens when giftUnitsLocations is provided)
--                 * giftCityText -> Text to be shown to ask for confirmation
--                 * giftCityConfirmation -> Dialog to show after confirmation
--                 * giftCityDestroyUnits -> Whether all units needs to be destroyed after the city is given out
--
--    
--    You can use the following replacement parameters
--                 * %RECEIVER -> Tribe name of who is receiving the gift
--                 * %MONEY -> The amount of money given out
--                 * %TILE     -> Tile where it happens
--                 * %CITY0     -> Name of the city
--                 * %UNITS     -> Friendly text about the units given
--
--    Offers present regardless of the cursor position
--                    * Money
--                    * Technology
--                    * Map
--
--    Offers that depend on city/units present on the cursor
--                    * Unit
--                    * City
local function diplomacyMenu(options)
   -- Returns if the city is capital
      local function isCapital(city)
	 return city and city:hasImprovement(civ.getImprovement(1))
      end
      local function buildOptions()
	 tile = civ.getCurrentTile()
	 menuTable = {}
	 menuTable[1] = "Gift money"
	 menuTable[2] = "Gift technology"
	 if tile.owner == civ.getCurrentTribe() then
	    if tile.city == nil then
	       count = 0
	       for i in tile.units do
		  count = count + 1
	       end
	       if count > 0 then
		  menuTable[3] = "Gift units"
	       end
	    else
	       if not isCapital(tile.city) then
		  menuTable[4] = "Gift city"
	       end
	    end
	 end
	 return menuTable
      end

      options = options or {}
      mainDialogText = options.mainDialogText or "Choose your option"
      menuTable = buildOptions()
      gift = text.menu(menuTable, mainDialogText, mainDialogText, true)
      if gift ~= 0 then
	 civSelectionText = options.civSelectionText or "Choose the civ to gift to"
	 for i = 0, 7 do
	    menuTable[i+1] = civ.getTribe(i).name
	 end
	 tribeId = text.menu(menuTable, civSelectionText, civSelectionText, true)
      end
      if tribeId~=0 and gift ~=0 then
	 -- How I miss switch/case
	 tribeId = tribeId -1
	 tribe  = civ.getTribe(tribeId)
	 player = civ.getCurrentTribe()
	 if tribe.name ~= player.name
	 then
	    if gift == 1 then
	       giftMoneyMenu(tribe, options)
	    elseif gift == 2 then
	       giftTechnology(tribe, options)
	    elseif gift == 3 then
	       giftUnits(tribe, options)
	    elseif gift == 4 then
	       giftCity(tribe, options)
	    end
	 else
	    errorMessage = options.sameCivPlayer or "You can't gift yourself!"
	    civ.ui.text(errorMessage)
	 end
      end
end
diplomacy.diplomacyMenu = diplomacyMenu

return diplomacy

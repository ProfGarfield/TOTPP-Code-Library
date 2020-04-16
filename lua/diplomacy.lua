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
local default_gift_money_amounts = {}
default_gift_money_amounts[1] = "1"
default_gift_money_amounts[5] = "5"
default_gift_money_amounts[10] = "10"
default_gift_money_amounts[50] = "50"
default_gift_money_amounts[100] = "100"
default_gift_money_amounts[500] = "500"
default_gift_money_amounts[1000] = "1000"
default_gift_money_amounts[5000] = "5000"
default_gift_money_amounts[10000] = "5000"

-- Offers a menu to gift a given amount of money 
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * gift_money_text -> Text to display in main dialog text
--                 * gift_money_confiramtion -> Text to display when money is gifted
--                 * gift_money_amounts -> A table with the available amounts and the text associated with them
--    You can use the following replacement parameters
--                 * $receiver -> Tribe name of who is receiving the gift
--                 * $money -> The amount of money given out
--
--    Tribe: The tribe to pass money to
local function giftMoneyMenu(tribe, options)
   translationTable = { { code = "$receiver", value = tribe.name } };
   options = options or {}
   gift_money_text = options.gift_money_text or "Which amount should we gift to our $receiver friends?"
   gift_money_text = textTransform(gift_money_text, translationTable)
   gift_money_amounts = options.gift_money_amounts or default_gift_money_amounts
   menu_table = {}
   player = civ.getCurrentTribe()
   total_money = player.money
   for i,v in pairs(gift_money_amounts) do
      if(i<=total_money) then
	 menu_table[i] = v
      end
   end
   money = text.menu(menu_table, gift_money_text, gift_money_text, true)
   if money~=0 then
      tribe.money = tribe.money + money
      player.money = player.money - money
      translationTable[#translationTable + 1 ] = { code = "$money", value = money }
      message = options.gift_money_confirmation or "$money sent to our $receiver friends!"
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
--                 * gift_units_text -> Text to be shown to ask for confirmation
--                 * gift_units_confirmation -> Dialog to show after confirmation
--                 * gift_units_locations -> A list of locations to put the gift. It will start with the first one,
--                                           and use all of them until one is valid
--                 * gitft_units_error -> A error message to be displayed in case no suitable location is found
--                   (only happens when gift_units_location is provided)
--
--    You can use the following replacement parameters
--                 * $receiver -> Tribe name of who is receiving the gift
--                 * $tile     -> Tile where it happens
--
local function giftUnits(tribe, options)
   tile = civ.getCurrentTile()
   translationTable = { { code = "$receiver", value = tribe.name },
      { code = "$tile", value = tostring(tile.x)..","..tostring(tile.y).." in map "..tostring(tile.z) } };
   gift_units_question = options.gift_unit_text or "Do you confirm gifting all units to $receiver in $tile?"
   gift_units_question = textTransform(gift_units_question, translationTable)
   menu_table = {}
   menu_table[1] = "Ok!"
   go_ahead = text.menu(menu_table, gift_units_question, gift_units_question, true)
   if go_ahead == 1 then
      units = destroyUnitsIn(tile)
      position = options.gift_units_locations or {{ tile.x, tile.y, tile.z }}
      if recreateUnitsIn(units, position, tribe) then
	 message = options.gift_units_confirmation or "Units in $tile transferred to $receiver"
      else
	 message = options.gift_units_error or "Some units were lost as no suitable destination square was found!"
      end
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   end
end

-- Gift a city (non-captial) to another tribe and display text
--
--    options is to be pased on, and may contain different configuration
--    parameters for what and how to offer
--                 * gift_city_text -> Text to be shown to ask for confirmation
--                 * gift_city_confirmation -> Dialog to show after confirmation
--                 * gift_city_destroy units -> Whether all units needs to be destroyed after the city is given out
--
--    You can use the following replacement parameters
--                 * $receiver -> Tribe name of who is receiving the gift
--                 * $city     -> Name of the city
--
local function giftCity(tribe, options)
   tile = civ.getCurrentTile()
   city = tile.city
   translationTable = { { code = "$receiver", value = tribe.name },
      { code = "$city", value = city.name } }
   gift_city_question = options.gift_city_text or "Do you confirm gifting $city to $receiver?"
   gift_city_question = textTransform(gift_city_question, translationTable)
   menu_table = {}
   menu_table[1] = "Ok!"
   go_ahead = text.menu(menu_table, gift_city_question, gift_city_question, true)
   if go_ahead == 1 then
      units = destroyUnitsIn(tile)
      destroy_units = options.gift_city_destroy_units or false
      city.owner = tribe
      position = {{ tile.x, tile.y, tile.z }}
      if destroy_units or recreateUnitsIn(units, position, tribe) then
	 message = options.gift_city_confirmation or "$city transferred to $receiver"
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
--                 * gift_tech_text -> Tech to be shown in the Tech window
--                 * gift_tech_confirmation -> Text to show when map is passed
--                 * gift_tech_no_techs -> Text to show when no tech to offer
--                 * gift_tech_not_trade -> Table with names of techs that can't be traded
--
--    You can use the following replacement parameters
--                 * $receiver -> Tribe name of who is receiving the gift
--                 * $tech     -> Name of the tech
--
local function giftTechnology(tribe, options) -- 
   local function techInTable(tech, tech_table)
      for i, v in pairs(tech_table) do
	 if v == tech.name then
	    return true
	 end
      end
      return false
   end

   translationTable = { { code = "$receiver", value = tribe.name } };
   player = civ.getCurrentTribe()
   list_techs = {}
   tech_techs = {}
   tech_table = options.gift_tech_not_trade or {}
   for techId = 0,99 do
      tech = civ.getTech(techId)
      if not tribe:hasTech(tech) and player:hasTech(tech) and not techInTable(tech, tech_table)
      then
	 list_techs[#list_techs+1] = tech.name
	 tech_techs[#tech_techs+1] = tech
      end
   end
   if #list_techs == 0 then
      message = options.gift_tech_no_techs or  "There are no tech we can give to $receiver"
      message = textTransform(message, translationTable)
      civ.ui.text(message)
   else
      gift_tech_text = options.gift_tech_text or "Which tech to give our friends $receiver?"
      gift_tech_text = textTransform(gift_tech_text, translationTable)
      techId = text.menu(list_techs, gift_tech_text, gift_tech_text, true)
      if techId ~= 0 then
	 tech = tech_techs[techId]
	 translationTable[#translationTable + 1] = { code = "$tech", value = tech.name } ;
	 tribe:giveTech(tech)
	 message = options.gift_tech_confirmation or "$tech given to $receiver"
	 message = textTransform(message, translationTable)
	 civ.ui.text(message)
      end
   end
end
   



-- Offers a menu to present what can be given as a present to other civ
--
--    options is an optional table, and may contain different configuration
--    parameters for what and how to offer
--                 * main_dialog_text -> Text to display in main dialog text
--                 * civ_selection_text -> Text to display when selecting destination civ
--                 * gift_money_text -> Text to display in main dialog text
--                 * gift_money_confiramtion -> Text to display when money is gifted
--                 * gift_money_amounts -> A table with the available amounts and the text associated to them
--                 * same_civ_player -> Text when a player attemps to gift something to his/herself.
--                 * gift_units_text -> Text to be shown to ask for confirmation
--                 * gift_units_confirmation -> Dialog to show after confirmation
--                 * gift_units_locations -> A list of locations to put the gift. It will start with the first one,
--                                           and use all of them until one is valid
--                 * gitft_units_error -> A error message to be displayed in case no suitable location is found
--                   (only happens when gift_units_location is provided)
--                 * gift_city_text -> Text to be shown to ask for confirmation
--                 * gift_city_confirmation -> Dialog to show after confirmation
--                 * gift_city_destroy units -> Whether all units needs to be destroyed after the city is given out
--
--    
--    You can use the following replacement parameters
--                 * $receiver -> Tribe name of who is receiving the gift
--                 * $money -> The amount of money given out
--                 * $tile     -> Tile where it happens
--                 * $city     -> Name of the city
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
      main_dialog_text = options.main_dialog_text or "Choose your option"
      menuTable = buildOptions()
      gift = text.menu(menuTable, main_dialog_text, main_dialog_text, true)
      if gift ~= 0 then
	 civ_selection_text = options.civ_selection_text or "Choose the civ to gift to"
	 for i = 0, 7 do
	    menuTable[i+1] = civ.getTribe(i).name
	 end
	 tribeId = text.menu(menuTable, civ_selection_text, civ_selection_text, true)
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
	    error_message = options.same_civ_player or "You can't gift yourself!"
	    civ.ui.text(error_message)
	 end
      end
end
diplomacy.diplomacyMenu = diplomacyMenu

return diplomacy

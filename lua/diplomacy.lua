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

return diplomacy




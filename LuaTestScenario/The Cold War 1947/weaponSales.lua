local gen = require("generalLibrary")
local text = require("text")
local object = require("object")

-- the table with functions to return
local weaponSales = {}


-- canSellTo[seller.id][buyer.id] = bool
-- if true, seller has the option to set prices for 
-- sales to buyer in a menu, if false, seller won't
-- get that option
local canSellTo = {}
canSellTo[object.tNeutrals.id] = {[object.tNeutrals.id] = false, [object.tUSSR.id] = false, [object.tProEast.id] = false,
                [object.tChina.id] = false, [object.tUSA.id] = false, [object.tProWest.id] = false,
                [object.tEurope.id] = false, [object.tIndia.id] = false,}
canSellTo[object.tUSSR.id] = {[object.tNeutrals.id] = false, [object.tUSSR.id] = false, [object.tProEast.id] = true,
                [object.tChina.id] = true, [object.tUSA.id] = false, [object.tProWest.id] = false,
                [object.tEurope.id] = false, [object.tIndia.id] = true,}
canSellTo[object.tProEast.id] = {[object.tNeutrals.id] = false, [object.tUSSR.id] = false, [object.tProEast.id] = false,
                [object.tChina.id] = false, [object.tUSA.id] = false, [object.tProWest.id] = false,
                [object.tEurope.id] = false, [object.tIndia.id] = false,}
canSellTo[object.tChina.id] = {[object.tNeutrals.id] = false, [object.tUSSR.id] = false, [object.tProEast.id] = false,
                [object.tChina.id] = false, [object.tUSA.id] = false, [object.tProWest.id] = false,
                [object.tEurope.id] = false, [object.tIndia.id] = false,}
canSellTo[object.tUSA.id] = {[object.tNeutrals.id] = false, [object.tUSSR.id] = false, [object.tProEast.id] = false,
                [object.tChina.id] = false, [object.tUSA.id] = false, [object.tProWest.id] = true,
                [object.tEurope.id] = true, [object.tIndia.id] = true,}
canSellTo[object.tProWest.id] = {[object.tNeutrals.id] = false, [object.tUSSR.id] = false, [object.tProEast.id] = false,
                [object.tChina.id] = false, [object.tUSA.id] = false, [object.tProWest.id] = false,
                [object.tEurope.id] = false, [object.tIndia.id] = false,}
canSellTo[object.tEurope.id] = {[object.tNeutrals.id] = false, [object.tUSSR.id] = false, [object.tProEast.id] = false,
                [object.tChina.id] = false, [object.tUSA.id] = true, [object.tProWest.id] = true,
                [object.tEurope.id] = false, [object.tIndia.id] = true,}
canSellTo[object.tIndia.id] = {[object.tNeutrals.id] = false, [object.tUSSR.id] = false, [object.tProEast.id] = false,
                [object.tChina.id] = false, [object.tUSA.id] = false, [object.tProWest.id] = false,
                [object.tEurope.id] = false, [object.tIndia.id] = false,}

-- unitSalesCategory[unitType.id] = string or false or nil
--          The category of the unit for the menu (e.g. "Fighters", "Tanks", "Bombers", etc.)
--          false or nil means the unit can never be offered for sale
--  if no entry, unit can't be sold
-- the list of categories to be displayed
local categoryList = {"Fighters","Bombers","Tanks","Artillery"}
local unitSalesCategory = {}
unitSalesCategory[object.uSpitfire.id] = "Fighters"
unitSalesCategory[object.uSPArtillery.id] = "Artillery"





-- canSell[unitType.id][tribe.id] = bool or nil
--      if true, the unitType can be sold by the tribe
--      if false or nil, it can't
--      This is only used in the priceOptions function,
--      so you don't need to fill it in if you have an alternate
--      method of determining who can sell what
--      canSell[unitType.id] == nil means no one can sell
local canSell = {}
canSell[object.uSpitfire.id] = {[object.tEurope.id] = true,}
canSell[object.uSPArtillery.id] = {[object.tEurope.id] = true, [object.tUSA.id] = true, [object.tUSSR.id] = true}

-- priceOptions(seller,buyer,unitType)--> table or false or nil
-- returns a table (indexed by integers, with integer values)
-- of prices a seller may charge a buyer for the unitType
-- in question
-- returning false or nil means the sale can't be made
-- returning an empty table means that if the unit is already
-- being offered, it can continue to be offered at the current price
-- but the price can't be changed, and if the offer is withdrawn, it can't
-- be reinstated
local function priceOptions(seller,buyer,unitType)

    if not (canSell[unitType.id] and canSell[unitType.id][seller.id]) then
        return false
    end
    -- unitType can't be sold if would be seller has no prereq
    if unitType.prereq and not seller:hasTech(unitType.prereq) then
        return false
    end
    

    -- example costs
    return {unitType.cost*50,unitType.cost*70,unitType.cost*100,}

end

-- productionCost(seller,buyer,unitType,price)--> integer
-- returns the production cost of unitType when sold
-- by seller to buyer at the price stated
local function productionCost(seller,buyer,unitType,price)

    -- example cost is 40 gold per shield row and 3% of sale price
    return math.floor(unitType.cost*40+0.03*price)

end

-- determines if a city an receive a purchased unit type from a
-- given seller
-- return a number to add a transportation cost
local function cityCanReceivePurchasedUnit(city,unitType,seller)
    if city:hasImprovement(object.iInternationalPort) then
        return true
    end
    if gen.isBuildCoastal(city) then
        return 500
    end
    return false
end


-- state.unitSalesStatus[buyerTribe.id][sellerTribe.id][unitType.id] = integer or false or nil
-- if integer, the sellerTribe is offering the buyerTribe the unit at the price listed
-- if false or nil, the item is not for sale
--
-- if the state table doesn't have a key unitSalesStatus, create it, and its necessary
-- sub tables with this function
local function initializeUnitSalesStatus()
    local unitSalesStatus = {}
    for buyerID=0,7 do
        local buyerTable = {}
        for sellerID=0,7 do
            buyerTable[sellerID] = {}
        end
        unitSalesStatus[buyerID]=buyerTable
    end
    return unitSalesStatus
end
-- change a selling status with this function
-- set to false or nil to prevent the sale outright
-- offered as global, so changes can be made in the console
function changeSellingStatus(sellerTribe,buyerTribe,unitType,priceOrFalseOrNil)
    local state = gen.getState()
    state.unitSalesStatus = state.unitSalesStatus or initializeUnitSalesStatus()
    state.unitSalesStatus[buyerTribe.id][sellerTribe.id][unitType.id] = priceOrFalseOrNil
end

weaponSales.changeSellingStatus = changeSellingStatus

-- this function can be used to initialize the selling status of different tribes
-- and units
-- clears existing choices, then makes the listed changes
-- provided as global, so it can be accessed from the console

function resetSellingStatus()
    gen.getState().unitSalesStatus =  initializeUnitSalesStatus()
    --changeSellingStatus(object.tEurope,object.tProWest,object.uSpitfire,priceOptions(object.tEurope,object.tProWest,object.uSpitfire)[2])
    changeSellingStatus(object.tEurope,object.tProWest,object.uSpitfire,500)
    changeSellingStatus(object.tEurope,object.tIndia,object.uSpitfire,priceOptions(object.tEurope,object.tIndia,object.uSpitfire)[3])
    changeSellingStatus(object.tEurope,object.tProWest,object.uSPArtillery,priceOptions(object.tEurope,object.tProWest,object.uSpitfire)[2])
    changeSellingStatus(object.tEurope,object.tIndia,object.uSPArtillery,priceOptions(object.tEurope,object.tIndia,object.uSpitfire)[3])
    -- changeSellingStatus( )
    
end
weaponSales.resetSellingStatus = resetSellingStatus




local function buyEquipment(unitType,buyer,seller,price,deliveryCity)
    local deliveryCost = cityCanReceivePurchasedUnit(deliveryCity,unitType,seller)
    if type(deliveryCost) == "number" then
        buyer.money = buyer.money - price - deliveryCost
    else
        buyer.money = buyer.money - price
    end
    seller.money = seller.money + price - productionCost(seller,buyer,unitType,price)
    local newEquipment = civ.createUnit(unitType,buyer,deliveryCity.location)
    newEquipment.moveSpent = 255
    newEquipment.homeCity = deliveryCity
end
weaponSales.buyEquipment = weaponSales.buyEquipment

local menuOffset = 5

local function listAvailablePurchases(buyer,category)
    gen.getState().unitSalesStatus = gen.getState().unitSalesStatus or initializeUnitSalesStatus()
    local statusTable = gen.getState().unitSalesStatus
    local offers = statusTable[buyer.id]
    local menuTable = {}
    -- options are 10*UnitTypeID+tribeID+menuOffset, so the choice
    -- can be easily reversed
    menuTable[1] = "Change Hardware Category"
    for unitTypeID=0,civ.cosmic.numberOfUnitTypes do
        for tribeID = 0,7 do
            local price = offers[tribeID][unitTypeID]
            if price and unitSalesCategory[unitTypeID] and unitSalesCategory[unitTypeID] == category then
                menuTable[(10*unitTypeID+tribeID)+menuOffset] = civ.getUnitType(unitTypeID).name..", Price: $"..tostring(price)..",000, Seller: "..civ.getTribe(tribeID).name
            end
        end
    end
    return menuTable
end


local function buildCityMenu(buyer,seller,unitType)
    local menuTable = {}
    menuTable[1] = "Choose different unit."
    for city in civ.iterateCities() do
        if city.owner == buyer and cityCanReceivePurchasedUnit(city,unitType,seller) then
            local purchaseResult = cityCanReceivePurchasedUnit(city,unitType,seller)
            if type(purchaseResult) == "number" then
                menuTable[city.id+menuOffset] = city.name.." (+ $"..tostring(purchaseResult)..",000 transport cost)"
            else
                menuTable[city.id+menuOffset] = city.name
            end
        end
    end
    return menuTable
end


local function equipmentPurchaseMenu(buyer,nextMenu,extraInfo)
    local menuTitle = "International Arms Market"
    nextMenu = nextMenu or "SelectCategory"
    extraInfo = extraInfo or nil

    if nextMenu == "SelectCategory" then
        local menuText = "Select the type of military equipment you wish to purchase."
        local choice = text.menu(categoryList,menuText,menuTitle,true)
        if choice == 0 then 
            return
        else
            return equipmentPurchaseMenu(buyer,"SelectUnit",categoryList[choice])
        end
    elseif nextMenu == "SelectUnit" then
        local menuTable = listAvailablePurchases(buyer,extraInfo)
        local menuText = "These are the "..extraInfo.." on the market."
        local choice = text.menu(menuTable,menuText,menuTitle,true)
        if choice == 0 then
            return
        elseif choice == 1 then
            return equipmentPurchaseMenu(buyer,"SelectCategory",nil)
        else
            choice = choice - menuOffset
            -- choice = 10*unitTypeID+tribeID
            local seller = civ.getTribe(choice % 10)
            -- note // is divide and round down
            local unitType = civ.getUnitType(choice//10)
            return equipmentPurchaseMenu(buyer,"SelectCity",{unitType,seller})
        end
    elseif nextMenu == "SelectCity" then
        local seller = extraInfo[2]
        local unitType = extraInfo[1]
        -- menuOffset was removed from choice before calling this function, so
        local price = gen.getState().unitSalesStatus[buyer.id][seller.id][unitType.id]
        local menuTable = buildCityMenu(buyer,seller,unitType)
        local menuText = "Select a city to receive delivery of the "..seller.adjective.." "..unitType.name.." unit."
        local choice = text.menu(menuTable,menuText,menuTitle,true)
        if choice == 0 then
            return
        elseif choice == 1 then
            return equipmentPurchaseMenu(buyer,"SelectCategory")
        else
            local deliveryCity = civ.getCity(choice-menuOffset)
            return equipmentPurchaseMenu(buyer,"ConfirmPurchase",{unitType,seller,deliveryCity})
        end
    elseif nextMenu == "ConfirmPurchase" then
        local unitType = extraInfo[1]
        local seller = extraInfo[2]
        local deliveryCity = extraInfo[3]
        local price = gen.getState().unitSalesStatus[buyer.id][seller.id][unitType.id]
        local priceString = "$"..tostring(price)..",000"
        local receiveCityVal = cityCanReceivePurchasedUnit(deliveryCity,unitType,seller)
        local tCost = 0
        if type(receiveCityVal) == "number" then
            priceString = priceString.." and $"..tostring(receiveCityVal)..",000 in transportation costs ($"..tostring(price+receiveCityVal)..",000)"
            tCost = receiveCityVal
        end
        local menuText = nil
        local menuTable = {}
        menuTable[3] = "Perhaps we should purchase different equipment."
        if buyer.money >= price then
            menuTable[1] = "Perhaps a different city should take delivery."
        end
        if buyer.money >= (price + tCost) then
            menuTable[2] = "Yes."
            menuText = "Shall we purchase a "..unitType.name.." unit from the "..seller.name.." for "..priceString..", and receive it in "..deliveryCity.name.."?"
        else
            menuText = "We do not have the funds to purchase a "..unitType.name.." unit from the "..seller.name.." for "..priceString..", and receive it in "..deliveryCity.name.."."
        end
        local choice = text.menu(menuTable,menuText,menuTitle,true)
        if choice == 0 then
            return
        elseif choice == 1 then
            return equipmentPurchaseMenu(buyer,"SelectCity",{unitType,seller})
        elseif choice == 2 then
            buyEquipment(unitType,buyer,seller,price,deliveryCity)
            return
        elseif choice == 3 then
            return equipmentPurchaseMenu(buyer,"SelectCategory")
        end
    end
end
weaponSales.equipmentPurchaseMenu = equipmentPurchaseMenu


local function equipmentOfferMenu(seller,category,otherInfo)
    local menuTitle = "International Arms Sales"
    category = category or "chooseTribe"

    if category == "chooseTribe" then
        local menuTable = {}
        for i=0,7 do
            if canSellTo[seller.id][i] then
                menuTable[i+menuOffset] = civ.getTribe(i).name
            end
        end
        local menuText = "For what block shall we review sales terms?"
        local choice = text.menu(menuTable,menuText,menuTitle,true)
        if choice == 0 then
            return
        end
        return equipmentOfferMenu(seller,"chooseUnitType",{tribe=civ.getTribe(choice-menuOffset)})
    end
    if category == "chooseUnitType" then
        local buyer = otherInfo.tribe
        local menuTable = {}
        gen.getState().unitSalesStatus = gen.getState().unitSalesStatus or initializeUnitSalesStatus()
        local statusTable = gen.getState().unitSalesStatus
        for unitTypeID=0,127 do
            if civ.getUnitType(unitTypeID) and priceOptions(seller,buyer,civ.getUnitType(unitTypeID)) then
                local currentPrice = statusTable[buyer.id][seller.id][unitTypeID]
                local menuEntry = civ.getUnitType(unitTypeID).name
                if currentPrice then
                    local currentCost = productionCost(seller,buyer,civ.getUnitType(unitTypeID),currentPrice)
                    menuEntry = menuEntry..", $"..tostring(currentPrice)..",000 (Net: $"..tostring(currentPrice-currentCost)..",000)"
                else
                    menuEntry = menuEntry..", Not Offered."
                end
                menuTable[unitTypeID+menuOffset] = menuEntry
            end
        end
        local menuText = "For which unit shall we change our export policy towards the "..buyer.name.."?"
        menuTable[1] = "Choose a different block"
        local choice = text.menu(menuTable,menuText,menuTitle,true)
        if choice == 0 then
            return
        elseif choice == 1 then
            return equipmentOfferMenu(seller,"chooseTribe")
        else
            return equipmentOfferMenu(seller,"choosePrice",{tribe = buyer,unitType = civ.getUnitType(choice-menuOffset)})
        end
    end
    if category == "choosePrice" then
        local buyer = otherInfo.tribe
        local unitType = otherInfo.unitType
        local prices = priceOptions(seller,buyer,unitType)
        gen.getState().unitSalesStatus = gen.getState().unitSalesStatus or initializeUnitSalesStatus()
        local statusTable = gen.getState().unitSalesStatus
        local currentPrice = statusTable[buyer.id][seller.id][unitType.id]
        local menuTable = {}
        menuTable[1] = "Let us review the export policy for a different weapons system."
        if currentPrice then
            menuTable[2] = "The current price ($"..tostring(currentPrice)..",000, Net: $"..tostring(currentPrice-productionCost(seller,buyer,unitType,currentPrice))..",000) is good."
        else
            menuTable[2] = "Maintain the policy of not selling "..unitType.name.." units to the "..buyer.name.."."
        end
        local largestIndex = 0
        for index,value in pairs(prices) do
            if index > largestIndex then
                largestIndex = index
            end
            menuTable[index+menuOffset] = "$"..tostring(prices[index])..",000, (Net: $"..tostring(prices[index]-productionCost(seller,buyer,unitType,prices[index]))..",000) is a good price."
        end
        menuTable[largestIndex+1+menuOffset] = "Do not sell "..unitType.name.." units to the "..buyer.name.."."
        menuText = "What price should we charge the "..buyer.name.." for our "..unitType.name.." units?"
        local choice = text.menu(menuTable,menuText,menuTitle,false)
        if choice == 1 then
            return equipmentOfferMenu(seller,"chooseUnitType",{tribe = buyer})
        elseif choice == 2 then
            return
        else
            -- note: if do not sell was chosen, prices[choice-menuOffset] == nil,
            -- which changeSellingStatus can handle
            changeSellingStatus(seller,buyer,unitType,prices[choice-menuOffset])
            return equipmentOfferMenu(seller,"chooseUnitType",{tribe = buyer})
        end
    end
end
weaponSales.equipmentOfferMenu = equipmentOfferMenu




-- makes sure that any offers of sale are being made by
-- tribes that actually can make the sale
-- that is, priceOptions(seller,buyer,unitType) is not
-- nil or false.  Does not ensure that the offer price is
-- one of the prices in the list (so, you can still have
-- 'obsolete' prices unless the seller updates)

local function verifyOffers(seller)
    gen.getState().unitSalesStatus = gen.getState().unitSalesStatus or initializeUnitSalesStatus()
    local statusTable = gen.getState().unitSalesStatus
    local sellerID = seller.id
    for buyerID=0,7 do
        if canSellTo[seller.id][buyerID] then
            local buyer = civ.getTribe(buyerID)
            for unitTypeID=0,127 do
                if statusTable[buyerID][sellerID][unitTypeID] and not priceOptions(seller,buyer,civ.getUnitType(unitTypeID)) then
                    statusTable[buyerID][sellerID][unitTypeID] = nil
                end
            end
        end
    end
end
weaponSales.verifyOffers = verifyOffers


return weaponSales 

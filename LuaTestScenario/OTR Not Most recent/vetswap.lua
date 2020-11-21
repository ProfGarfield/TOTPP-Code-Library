-- There is a good chance that all you will need from this file is the buildBasicVetSwap function that I've described here.  A bit more explanation (and the code) will start at "DETAILS HERE"

-- buildBasicVetSwap(categoryTable,inCity,fullHealth,fullMove,spendMove,swapCost,swapHomeCity,ciBoxTitle,windowTitle,unitVetText,unitRookieText)--> (function(unit) -->void)
-- builds a function that takes a unit and offers to swap veteran status with another eligible unit on the tile.  The effect of each argument follows

-- Usage:
-- 1) Define the categoryTable
-- 2) myVetSwapFn = buildBasicVetSwap(...)
-- 3) In the onKeyPress function add the following lines
--	if keyID == vetSwapKeyID and civ.getActiveUnit() then
--		myVetSwapFn(civ.getActiveUnit())
--	end

-- categoryTable is table of (table of unitTypes)
--    Each table of unitTypes in categoryTable can trade Veteran Status between them

-- inCity
-- boolean
--    True if both units must be in a city to swap vet status, false otherwise

-- fullHealth
-- boolean
--    True if both units must be at full health to swap vet status, false otherwise

-- fullMove
-- boolean
--    True if both units must be at full movement points to swap vet status, false otherwise

-- spendMove
-- boolean
--    True if swapping veteran status expends all movement for the turn, false otherwise

-- swapCost
-- integer
--   The money cost to the player for exchanging veteran status

-- swapHomeCity
-- boolean
--    True if swapping veteran status should also swap the home city of the units, false otherwise.

-- ciBoxTitle (optional)
-- string
--	Custom box title for the dialog window that tells why the unit can't swap veteran status

-- windowTitle (optional)
-- string
--    Custom box title for the dialog window when you choose what unit to swap vet status with

-- unitVetText (optional)
-- string
--    Custom instruction message when a veteran unit is choosing the unit to receive its vet status

-- unitRookieText (optional)
-- string
--    Custom instruction message when a non-vet unit is choosing the unit to receive veteran status from.

--*******DETAILS HERE*******

-- This file implements veterancy exchange between units.  Both units must be on the same tile.  Any other conditions must be provided by the scenario creator.  This is done by providing the following functions:

-- canInitiateFn(unit)
--	This returns true if the unit can give or receive veteran status at the current time
--	if it can't, it should produce a message for the player.
--	This file has a default function for this purpose.

-- canExchangeVeteranStatus(giver,receiver)
--	return true if at this time the giver can give veteran status to the receiver, and false otherwise
--	This file has a function that will return a function suitable for this purpose.  See below

-- postExchangeFn(giver,receiver)
--	This function is run if the exchange is successful, and does things like change home cities or remove movement points

-- This function handles a multiple page option selection, taking a table where the keys are the option values, and the values are the text for each option.

-- bigOptionList(table of strings, titleString, InstructionString,elementsPerPage, startAtPage) --> integer
-- Takes a table of strings indexed by the integers starting at 1, and including every integer until the end of the options list, and returns the integer corresponding to the user's selection.  If an option is indexed by 0, it will appear on every page.

-- elements per page does not include the option indexed by 0 or the page navigation options.  So elementsPerPage=10 would have up to 13 options on page, two possible navigation options and the 0 option 

local function bigOptionList(tableOfOptions, titleString, instructionString,elementsPerPage, startAtPage)
	local pageToDisplay = startAtPage or 1
	local selections = 0
	local totalOptions = #tableOfOptions -- excludes the 0 option
	local totalPages = math.max(math.ceil(totalOptions/elementsPerPage),1)
	pageToDisplay = math.min(pageToDisplay,totalPages)
	while selections < 1000 do
		local optionDisplay = civ.ui.createDialog()
		optionDisplay.title = titleString.." (Page "..pageToDisplay.." of "..totalPages..")"
		optionDisplay:addText(instructionString)
		if pageToDisplay < totalPages then
			optionDisplay:addOption("Next Page",-2)
		end
		if pageToDisplay > 1 then
			optionDisplay:addOption("Previous Page",-1)
		end
		
		if tableOfOptions[0] then
			optionDisplay:addOption(tableOfOptions[0],0)
		end
		for i=(pageToDisplay-1)*elementsPerPage+1,math.min(pageToDisplay*elementsPerPage,totalOptions) do
			optionDisplay:addOption(tableOfOptions[i], i)
		end
		local selection = optionDisplay:show()
		if selection >= 0 then
			return selection
		elseif selection == -1 then
			selections = selections+1
			pageToDisplay = pageToDisplay -1
		elseif selection == -2 then
			selections = selections+1
			pageToDisplay = pageToDisplay+1
		end
		
	end
	civ.ui.text("Either the multiPageOptions.lua file has an infinite loop problem, or you made 1000 selections.")

end
local function swapVetStatus(unit,windowTitle,unitVetText,unitRookieText,canInitiateFn,canExchangeVeteranStatus,postExchangeFn)
	if not canInitiateFn(unit) then
		return
	end
	if unit.veteran then
		-- this unit will be giving the veteran status
		-- must make table of units that are eligible for the exchange
		local validUnitsTable = {}
		local optionListTable = {[0] = "Cancel."}
		local indexer = 1
		for unitOnTile in unit.location.units do
			if unitOnTile ~= unit and canExchangeVeteranStatus(unit,unitOnTile) then
				validUnitsTable[indexer] = unitOnTile
				local hpStatus = ""
				if unitOnTile.damage > 0 then
					hpStatus = " HP:"..tostring(unitOnTile.hitpoints).."/"..tostring(unitOnTile.type.hitpoints)
				end
				local moveStatus = ""
				if unitOnTile.moveSpent > 0 then
					-- Compute the move remaining.  The multiplication by 10 is to
					-- enable at least part of the fractional value to be represented
					-- but only do so for one digit after the decimal
					moveRemaining = 10*(unitOnTile.type.move*totpp.movementMultipliers.aggregate - unitOnTile.moveSpent)/(unitOnTile.type.move*totpp.movementMultipliers.aggregate)
					moveRemaining = math.floor(moveRemaining)/10
					moveStatus = " MP:"..tostring(moveRemaining).."/"..tostring(unitOnTile.type.move)
				end
                local unitHomeCityName = nil
                if unitOnTile.homeCity then
                    unitHomeCityName = unitOnTile.homeCity.name
                else
                    unitHomeCityName = "NONE"
                end
				optionListTable[indexer] = unitOnTile.type.name.." of "..unitHomeCityName..hpStatus..moveStatus
				indexer = indexer+1
			end
		end
		local selection = bigOptionList(optionListTable,windowTitle,unitVetText,10,1)
		if selection == 0 then
			return
		else
			local receiverUnit = validUnitsTable[selection]
			receiverUnit.veteran = true
			unit.veteran = false
			postExchangeFn(unit,receiverUnit)
			return
		end
	else -- if unit veteran is false
		-- this unit will be receiving the veteran status
		-- must make table of units that are eligible for the exchange
		local validUnitsTable={}
		local optionListTable = {[0] = "Cancel."}
		local indexer = 1
		for unitOnTile in unit.location.units do
			if unitOnTile ~= unit and canExchangeVeteranStatus(unitOnTile,unit)then
			validUnitsTable[indexer]=unitOnTile
			local hpStatus = ""
				if unitOnTile.damage > 0 then
					hpStatus = " HP:"..tostring(unitOnTile.hitpoints).."/"..tostring(unitOnTile.type.hitpoints)
				end
				local moveStatus = ""
				if unitOnTile.moveSpent > 0 then
					-- Compute the move remaining.  The multiplication by 10 is to
					-- enable at least part of the fractional value to be represented
					-- but only do so for one digit after the decimal
					moveRemaining = 10*(unitOnTile.type.move*totpp.movementMultipliers.aggregate - unitOnTile.moveSpent)/(unitOnTile.type.move*totpp.movementMultipliers.aggregate)
					moveRemaining = math.floor(moveRemaining)/10
					moveStatus = " MP:"..tostring(moveRemaining).."/"..tostring(unitOnTile.type.move)
				end
                if unitOnTile.homeCity then
                    unitHomeCityName = unitOnTile.homeCity.name
                else
                    unitHomeCityName = "NONE"
                end
				optionListTable[indexer] = unitOnTile.type.name.." of "..unitHomeCityName..hpStatus..moveStatus
				indexer = indexer+1
			end -- if unitOnTile ~= unit
		end -- for unitOnTile in unit.location.units do
		local selection = bigOptionList(optionListTable,windowTitle,unitRookieText,10,1)
		if selection == 0 then
			return
		else
			local giverUnit = validUnitsTable[selection]
			giverUnit.veteran = false
			unit.veteran = true
			postExchangeFn(giverUnit,unit)
			return
		end -- selection
	end -- if unit veteran
end

local function buildDefaultCanInitiateFn(inCity,fullHealth,fullMove,minTreasury,boxTitle)
	local function canInitiateFn(unit)
		if inCity and not unit.location.city then
			local message = civ.ui.createDialog()
			message.title = boxTitle
			message:addText("Units must be in a city to transfer veteran status.")
			message:show()
			return false
		elseif fullHealth and unit.damage > 0 then
			local message = civ.ui.createDialog()
			message.title = boxTitle
			message:addText("Units must be at full health to transfer veteran status.")
			message:show()
			return false
		elseif fullMove and unit.moveSpent > 0 then
			local message = civ.ui.createDialog()
			message.title = boxTitle
			message:addText("Units must still have their full movement allotment to transfer veteran status.")
			message:show()
			return false
		elseif unit.owner.money < minTreasury then
			message.title = boxTitle
			message:addText("Your need at least "..tostring(minTreasury).." in your treasury to transfer veteran status.")
			messsage:show()
		else
			return true
		end
	end
	return canInitiateFn
end

-- categoryTable is a table of unitCategory
--	unitCategory is a table of unit types (index doesn't matter)
local function buildDefaultCanExchangeVeteranStatus(categoryTable,inCity,fullHealth,fullMove)
	local function canExchangeVetStatus(giver,receiver)
		if not giver.veteran then
			return false
		elseif receiver.veteran then
			return false
		elseif giver.location ~= receiver.location then
			return false
		elseif inCity and not giver.location.city then
			return false
		elseif fullHealth and (giver.damage > 0 or receiver.damage > 0) then
			return false
		elseif fullMove and (giver.moveSpent > 0 or receiver.moveSpent > 0) then
			return false
		end
		-- if we get here, we must check the category table
		local giverCatIndex = {}
		local receiverCatIndex = {} 
		for catIndex, unitCategory in pairs(categoryTable) do
			for typeIndex, unitType in pairs(unitCategory) do
				if unitType == giver.type then
					giverCatIndex[#giverCatIndex+1]= catIndex
				end
				if unitType == receiver.type then
					receiverCatIndex[#receiverCatIndex+1] = catIndex
				end
			end
		end
		for __,catIndex in pairs(giverCatIndex) do
			for ___,rCatIndex in pairs(receiverCatIndex) do
				if catIndex == rCatIndex then
					return true
				end
			end
		end
		return false
	end -- local functino canExchangeVetStatus
	return canExchangeVetStatus
end

local function buildDefaultPostExchangeFn(moneyCost,swapHomeCity,expendMovement)
	local function postExchangeFn(giver,receiver)
		giver.owner.money = giver.owner.money - moneyCost
		if swapHomeCity then
			local receiverHome = receiver.homeCity
			receiver.homeCity = giver.homeCity
			giver.homeCity = receiverHome
		end
		if expendMovement then
			giver.moveSpent = giver.type.move*totpp.movementMultipliers.aggregate
			receiver.moveSpent = receiver.type.move*totpp.movementMultipliers.aggregate
		end
	end
	return postExchangeFn
end

-- buildBasicVetSwap(categoryTable,inCity,fullHealth,fullMove,spendMove,swapCost,swapHomeCity,ciBoxTitle,windowTitle,unitVetText,unitRookieText)--> (function(unit) -->void)
-- builds a function that takes a unit and offers to swap veteran status with another eligible unit on the tile.  The effect of each argument follows

-- categoryTable is table of (table of unitTypes)
--    Each table of unitTypes in categoryTable can trade Veteran Status between them

-- inCity
-- boolean
--    True if both units must be in a city to swap vet status, false otherwise

-- fullHealth
-- boolean
--    True if both units must be at full health to swap vet status, false otherwise

-- fullMove
-- boolean
--    True if both units must be at full movement points to swap vet status, false otherwise

-- spendMove
-- boolean
--    True if swapping veteran status expends all movement for the turn, false otherwise

-- swapCost
-- integer
--   The money cost to the player for exchanging veteran status

-- swapHomeCity
-- boolean
--    True if swapping veteran status should also swap the home city of the units, false otherwise.

-- ciBoxTitle (optional)
-- string
--	Custom box title for the dialog window that tells why the unit can't swap veteran status

-- windowTitle (optional)
-- string
--    Custom box title for the dialog window when you choose what unit to swap vet status with

-- unitVetText (optional)
-- string
--    Custom instruction message when a veteran unit is choosing the unit to receive its vet status

-- unitRookieText (optional)
-- string
--    Custom instruction message when a non-vet unit is choosing the unit to receive veteran status from. 


local function buildBasicVetSwap(categoryTable,inCity,fullHealth,fullMove,spendMove,swapCost,swapHomeCity,ciBoxTitle,windowTitle,unitVetText,unitRookieText)
	local ciBoxTitle = ciBoxTitle or"Veteran Status Exchange"
	local canInitiateFn = buildDefaultCanInitiateFn(inCity,fullHealth,fullMove,swapCost
,ciBoxTitle)
	local canExchangeVeteranStatus = buildDefaultCanExchangeVeteranStatus(categoryTable,inCity,fullHealth,fullMove)
	local postExchangeFn = buildDefaultPostExchangeFn(swapCost,swapHomeCity,spendMove)
	local windowTitle = windowTitle or "Veteran Status Exchange"
	local unitVetText = unitVetText or "What unit do you wish to assign the veteran status to?"
	local unitRookieText = unitRookieText or "What unit do you wish to take veteran status from?"
	local function basicVetSwap(unit)
		return swapVetStatus(unit,windowTitle,unitVetText,unitRookieText,canInitiateFn,canExchangeVeteranStatus,postExchangeFn)
	end
	return basicVetSwap
end

return{swapVetStatus = swapVetStatus,
buildDefaultCanInitiateFn = buildDefaultCanInitiateFn,
buildDefaultCanExchangeVeteranStatus = buildDefaultCanExchangeVeteranStatus,
buildDefaultPostExchangeFn = buildDefaultPostExchangeFn,
buildBasicVetSwap = buildBasicVetSwap,
}

		






























--[[
events.lua
by Knighttime
Example implementation of the columnText.lua module

This example displays a table containing basic information on your first 15 cities
	(a portion of what you see on the City Status popup available by pressing F1)
	when you press the plus sign key [+] on the numeric keyboard (not the [Shift][=] combination!)
	
As a result, the code here is placed within the civ.scen.onKeyPress() trigger,
	but you could use this in any trigger and to display any information of your choosing.

Step-by-step instructions are inline below.
]]

local func = require "functions"

local eventsPath = string.gsub(debug.getinfo(1).source, "@", "")
local scenarioFolderPath = string.gsub(eventsPath, "events.lua", "?.lua")
if string.find(package.path, scenarioFolderPath, 1, true) == nil then
   package.path = package.path .. ";" .. scenarioFolderPath
end

package.loaded["columnText"] = nil
local columnText = require("columnText")

civ.scen.onKeyPress(function (keyCode)

	-- keyCode 171 is the plus sign on the numeric keypad (right side of a standard full-size keyboard)
	if keyCode == 171 then
	
		-- STEP 1: Create and populate a table that defines the layout of the information you want to present
		--		This table itself is not displayed, rather, it's where you explain the structure of your content
		--		Each display column is added as a separate table element
		--		The field named "column" is required and must be populated with a string that will be used as a table key for a data element (column)
		--			that you wish to populate and display (see Steps 2 and 3)
		--		The field named "align" is optional.  Valid values are "center" and "right".  Any other value, including nil, means "left".
		local columnTable = {
			{column = "size", align = "right"},
			{column = "city"},
			{column = "food", align = "right"},
			{column = "shields", align = "right"},
			{column = "trade", align = "right"}
		}
		
		-- STEP 2: Create a table that will contain the content you wish to display
		--		You can initialize it to { } if you do not wish to display a header row
		--		If you wish to display a header row of labels, define those statically here as the first table element
		--		Notice that the *fields* in this table (size, city, etc.) must exactly match the values of the *column* field
		--			in the rows of the columnTable defined in Step 1
		local dataTable = { {size = "SIZE", city = "CITY", food = "FOOD", shields = "SHIELDS", trade = "TRADE"} }
		
		for city in civ.iterateCities() do				
			if city.owner == civ.getPlayerTribe() and #dataTable <= 16 then
			
				-- STEP 3: Append an element to your data table for each row of content that it should contain
				--		As was pointed out in Step 2, notice that the *fields* in this table (size, city, etc.) must exactly match
				--			the values of the *column* field in the rows of the columnTable defined in Step 1
				--		Any other fields that you include (which do not match those defined in step 1) are ignored
				table.insert(dataTable, {
					size = city.size,
					city = city.name, 
					food = city.totalFood,
					shields = city.totalShield,
					trade = city.totalTrade
				})
			end
		end
		
		-- STEP 4: Call "columnText.convertTableToColumnText" to convert the content of your dataTable to a single string
		--		The first parameter is the name of the table you created in Step 1, with the data structure
		--		The second parameter is the name of the table you created in Step 2 and populated in Step 3, with the actual content to display
		--		The third parameter is the number of blank spaces you want to appear *between* each column in your output
		-- 			i.e., how widely spaced apart the columns should be
		local textString = columnText.convertTableToColumnText(columnTable, dataTable, 4)
		
		-- STEP 5: Display the string
		--		Note that you could combine this with the previous step and avoid introducing a separate textString variable;
		--			the separate variable is used here just for clarity
		--		Also, as an alternative to using civ.ui.text() to display the content, you could instead use civ.ui.createDialog() to
		--			create a dialog object, and then pass your string to the addText() function of that object
		civ.ui.text(func.splitlines(textString))
	end

end)

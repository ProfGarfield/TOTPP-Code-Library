local gen = require("generalLibrary")
local delayedAction = require("delayedAction")

local delayableFunctionsTable = {}


-- These are the settings for delayed functions
-- If you want to be able to write an event that automatically
-- performs some action or actions at a later time, you should
-- write the function with those actions here, and save it
-- as a value in the delayableFunctionsTable, with an integer
-- key.  The function should have the form
-- function(table)-->void
-- and the table should only have string and integer keys
-- and values must also be strings, integers, or tables of 
-- strings and integers
--

-- exampleOne(table) --> void
--  table has following keys
--      .setYear = integer
--          year the function was set up
--      .setTribeID = integer
--          the active tribe when the event was set
local function exampleOne(table)
    civ.ui.text("The setYear key has a value of "..tostring(table.setYear)..
    " and the setting tribe was "..civ.getTribe(table.setTribeID).name..
    ".  It is now "..tostring(civ.getGameYear()).." and the active tribe is "..
    civ.getCurrentTribe().name..".")
end
delayableFunctionsTable["exampleOne"] = exampleOne



delayedAction.getDelayableFunctions(delaybleFunctionsTable)

return

-- THE ACTION MODULE
--
-- This module provides some prepackaged event actions,
-- that are specified using keys and values provided
-- in a Lua table.  The skill level for using these events
-- should be more in line with the skill level necessary
-- to use the old macro events.
--
--  This module provides a function
--  action.doAction(actionTable,eventArgumentTable)
--  The actionTable provides all the key words and values
--  that determine the actions that will take place
--  eventArgumentTable consists of values not known at
--  the time of event writing (think keywords like 
--  TRIGGERATTACKER in the old macro events)
--
--


-- actionTable Keys
-- A single action table can define multiple actions of the
-- same type, by appending a number to the end of the key
-- If a key is specified as 
-- myActionKey# = value
-- then the action associated with myActionKey will be done first, if it exists,
-- then the action associated with myActionKey1 will be done, if it exists
-- then myActionKey2 will be executed, if it exists, and myActionKey3 will be checked,
-- and so on.  
-- For myActionKeyX, for X>=3, myActionKey(X-1) must also exist, so
-- if myActionKey2=value2, and myActionKey4=value4, but there is no myActionKey3, then
-- myActionKey4 will not be executed
--
-- If a key is specified as
-- myActionKey = value,
-- then it can only be executed once in a single action


-- Actions in the Action Table will be executed in the order in which they
-- are defined here.  Order does not matter in lua tables, so the keys may be
-- placed in any order
--

-- 

-- DISPLAY TEXT
--      
--
--
--
--
--
--
-- 

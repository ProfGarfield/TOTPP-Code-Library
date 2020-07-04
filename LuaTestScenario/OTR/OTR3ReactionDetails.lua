local canReactTo ={}

-- canReactTo is a table indexed by unitTypeID
-- if the unit type has no entry, that unit type will not react to anything


-- .range = integer
--      range is the distance between a trigger unit and a reacting unit 
--      if range is not specified elsewhere, this range is used

-- .maxAttacks = integer
--      The maximum number of times in a turn this unit will "react" and attempt to damage a trigger unit
--      absent means no limit
--      If the trigger unit is killed before a unit reacts, the number of attacks that unit made will not increment

--  The following entries specify possible locations of the triggering and reacting unit
--  A match in any category means the unit will "react" to the triggering unit,
--  possibly attack it, and will be at greater risk (or at least different risk) from area
--  attack units compared to "bystander" units
--
--      Valid Data For Any of the Following Entries
--      table of unitTypes
--      {range = integer, unitTypes = table of unitTypes}
--      table of {range = integer, unitTypes = table of unitTypes}

-- .anyMap  
--  The unit can react to any unit in the table of unitTypes if that unit is
--      within the corresponding (horizontal) range regardless of which map
--      each unit is on

-- .sameMap
--  The unit can react to any unit in the table of unit types if both units are
--      on the same map and are within range

-- .sameTime
-- If the unit is on the night map it can react to units in the table if they
-- are on the night map within range.  If the unit is on a day map, it can
-- react to units in the table on either day map (within horizontal range)

-- .lowerAltitude
--      If the unit is on the low altitude (day) map, it reacts to units in the table
--      if they are also on the low altitude map.  If the unit is on the high altitude map
--      it reacts to units on both maps

--  .lowMap
--      Both units must be on the low altitude day map

--  .highMap
--      Both units must be on the high altitude day map

--  .nightMap
--      Both units must be on the night map


local reactionDamage = {}

-- Reaction damage will be specified as table of thresholds and damage, similar to the bombs generated
-- depending on HP tables
-- table of {threshold = num,damage = int}
-- A number will be generated between 0 and 1.  If that number is less than the threshold, the
-- specified damage will be taken.  If the number is less than two thresholds, the damage from both will
-- be applied




















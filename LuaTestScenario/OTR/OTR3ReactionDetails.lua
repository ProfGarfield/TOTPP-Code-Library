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

--STANDARD FIGHTER VS. FIGHTER
--damageSchedule = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}),    --Strong attack - unit in their element catching unit outside of element (includes dive and nightfighter caught at day)
--damageSchedule = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}),    --Medium attack - unit in (or out of) their element vs. foe in (or out of) its element: Even match
--damageSchedule = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}),    --Weak attack   - unit out of element vs. foe in its element (includes day fighter vs. nightfighter at night)

--JET FIGHTERS VS. FIGHTERS 
--damageSchedule = gen.makeThresholdTable({[0]=6,[.25]=7,[.5]=8,[.75]=9}),    --Strong attack - jet vs. propeller fighter
--damageSchedule = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}),    --Medium attack - jet vs. jet: Even match
--damageSchedule = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}),    --Weak attack   - jet is climbing to attack a fighter 

--JET FIGHTERS VS. BOMBERS
--damageSchedule = gen.makeThresholdTable({[0]=7,[.25]=8,[.5]=9,[.75]=10}),   --Strong attack - jet vs. light or medium bomber
--damageSchedule = gen.makeThresholdTable({[0]=6,[.25]=7,[.5]=8,[.75]=9}),    --Medium attack - jet vs. heavy bomber
--damageSchedule = gen.makeThresholdTable({[0]=2,[.25]=4,[.5]=6,[.75]=8}),    --Weak attack   - jet vs. jet bomber, or any bomber at night/climbing

--BOMBER DEFENSIVE GUNS
--damageSchedule = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}),    --Strong attack - bomber reacts to escort fighter
--damageSchedule = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}),    --Medium attack - bomber reacts to interceptor
--damageSchedule = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}),    --Weak attack   - bomber reacts to armored interceptor, or anything at night

--FIGHTER VS. BOMBER
--damageSchedule = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}),    --Strong attack - bomber attacked by Bomber Destroyer (day only)
--damageSchedule = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}),    --Medium attack - bomber attacked by Interceptor or dedicated night fighter, also CAS attacked by escort
--damageSchedule = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}),    --Weak attack   - bomber attacked by Escort, or day fighter flying at night, 

--FLAK VS. AIRCRAFT
--damageSchedule = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}),    --Strong attack - reaction against most aircraft at low altitude - exception: armored aircraft
--damageSchedule = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}),    --Medium attack - reaction against most bombers at high altitude
--damageSchedule = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}),    --Weak attack   - reaction against fighters at high altitude, armored fighters and jets at low altitude, jet bombers at high alt

--TASK FORCE VS. Attackers (Sunderland shares Strong Attack).
--damageSchedule = gen.makeThresholdTable({[0]=0,[.25]=5,[.5]=15,[.75]=20}),  --Strong attack - reaction against U-Boats (25% chance of miss, 25% chance of kill, 25% chance of various damage)
--damageSchedule = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}),    --Medium attack - reaction against most aircraft
--damageSchedule = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}),    --Weak attack   - reaction against Sunderland and FW200



















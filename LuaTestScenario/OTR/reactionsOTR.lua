local gen = require("generalLibrary")
local reactionBase = require("reactionBase")
local unitAliases = require("unitAliases")



-- reactionDetail
--
-- A reactionDetail is a table that specifies how a unit will react
-- under a given circumstance (e.g. vs a specific trigger unit type,
-- and the map they are both on)
--
--      Keys
--          targetTypes = table of unit types
--              The reactionDetail applies to the unit types in this table
--          maxDistance = integer
--              maximum number of tiles that a potential shooter can be from the target
--              to still participate in a reaction
--          forbiddenShooterTerrain = {[integer]=bool}
--              if the shooter's location has a terrain type with a 'true' listing,
--              the shooter won't make a reaction
--          hitChance = number or {[integer]=number}
--              chance that the shooter will hit the target
--              if a table, the key is the distance in tiles between the shooter
--              and the target (e.g. hitChance[2] is the chance that a unit two tiles
--              away will hit the target).  If hitChance[dist] = nil, count as 0
--              (could be modified below, and subject to minChance, maxChance,
--              use maxDistance to stop reaction entirely)
--          hitChanceCloud = number or {[integer]=number}
--              chance the shooter will hit a target in cloud terrain
--              nil means use hitChance
--          shooterTechMod = table of {techObject,number}
--              for each technology the shooter has, add the number to the hit chance
--              nil means no modification
--          targetTechMod = table of {techObject,number}
--              for each technology the target has, add the number to the hit chance
--              nil means no modification
--          shooterTechModCloud = table of {techObject,number}
--              apply this instead of shooterTechMod, if the target is in clouds
--              nil means use shooterTechMod
--          targetTechModCloud = table of {techObject,number}
--              apply this instead of targetTechMod, if the target is in clouds
--              nil means use targetTechMod
--          minChance = number
--              this is the lowest likelihood that the shooter hits a target (even
--              if modifications would make it lower)
--              nil means 0
--          maxChance = number
--              this is the greatest likelihood that the shooter hits a target
--              (even if modifications would make it higher)
--              nil means 1
--          damageSchedule = thresholdTable
--              Governs the damage done IF a hit is scored
--              thresholdTable must return a number for damageSchedule[0]
--              consider myDamageSchedule = makeThresholdTable({[0]=6,[0.3]=3,[0.8]=0,[.85]=1})
--              30% chance of 6 damage ('roll' between 0 and .3)
--              50% chance of 3 damage ('roll' between .3 and .8)
--              5% chance of 0 damage ('roll' between .8 and .85)
--              15% chance of 1 damage ('roll' between .85 and 1)
--      


-- reactionInformation
--
-- puts together some reactionDetails in order to specify how a particular unit type
-- will react under different circumstances

--
--      Keys
--          low = table of reactionDetail
--              governs how the shooter will react at low altitude to other units at low altitude
--              the unit types in targetTypes should only appear in one reactionDetail each in this table
--              absent means the shooter won't react for these unit locations
--          high = table of reactionDetail
--              governs how the shooter will react at high altitude to other units at high altitude
--              the unit types in targetTypes should only appear in one reactionDetail each in this table
--              absent means the shooter won't react for these unit locations
--          night = table of reactionDetail
--              governs how the shooter will react at night to other units at night
--              the unit types in targetTypes should only appear in one reactionDetail each in this table
--              absent means the shooter won't react for these unit locations
--          dive = table of reactionDetail
--              governs how a shooter at high altitude will react to a target at low altitude
--              the unit types in targetTypes should only appear in one reactionDetail each in this table
--              absent means the shooter won't react for these unit locations
--          climb = table of reactionDetail
--              governs how a shooter at low altitude will react to a target at high altitude
--              the unit types in targetTypes should only appear in one reactionDetail each in this table
--              absent means the shooter won't react for these unit locations
--          groundToNight = table of reactionDetail
--              governs how a shooter at low altitude will react to a target at night
--              the unit types in targetTypes should only appear in one reactionDetail each in this table
--              absent means the shooter won't react for these unit locations
--      
--          reactionsPerTurn = integer
--              the number of reactions a unit can make per turn
--              nil means unlimited
--          reactInsideCity = bool
--              if true, the shooter can react from inside a city/airbase and when stacked with a carrier
--              nil or false means it can't
--          killMunition = bool or number
--              if true, and the shooter's attack kills the target, destroy the target's munitions
--              if number between 0 and .9999, destroy each munition with that probability
--              if the number is 1 or larger, do that much damage to each munition
--

local function modifyTable(table,key1,newValue1,key2,newValue2,key3,newValue3)
    local newTable = gen.copyTable(table)
    if key1 and newValue1 then
        newTable[key1] = newValue1
    end
    if key2 and newValue2 then
        newTable[key2] = newValue2
    end
    if key3 and newValue3 then
        newTable[key3] = newValue3
    end
    return newTable
end


local reactionGroups = {}

--These cover how fighters will react to other units
reactionGroups.heavyBombers = {unitAliases.B17F,unitAliases.B17G,unitAliases.B24J,unitAliases.MedBombers,unitAliases.Do217,unitAliases.He277,unitAliases.FifteenthAF}
reactionGroups.nightBombers = {unitAliases.Stirling,unitAliases.Halifax,unitAliases.Lancaster}
reactionGroups.mediumBombers = {unitAliases.He111,unitAliases.Sunderland,unitAliases.Fw200,unitAliases.A20,unitAliases.B26,unitAliases.A26}
reactionGroups.lightCloseAirSupport = {unitAliases.Ju87G}
reactionGroups.heavyCloseAirSupport = {unitAliases.Il2,unitAliases.Fw190F}
reactionGroups.jetBombers = {unitAliases.Arado234,unitAliases.Go229}

reactionGroups.highAltFighters = {unitAliases.P47D11,unitAliases.P47D25,unitAliases.P47D40,unitAliases.SpitfireIX,unitAliases.SpitfireXII,unitAliases.SpitfireXIV,unitAliases.Me109G6,unitAliases.Me109G14}
reactionGroups.lowAltFighters = {unitAliases.Yak3,unitAliases.P38H,unitAliases.P38J,unitAliases.HurricaneIV,unitAliases.Typhoon,unitAliases.Tempest,unitAliases.Fw190A5,unitAliases.Fw190A8}
reactionGroups.bothAltFighters = {unitAliases.P51B,unitAliases.P51D,unitAliases.P38L,unitAliases.RedTails,unitAliases.Me109K4,unitAliases.Fw190D9,unitAliases.Ta152}
reactionGroups.nightFighters = {unitAliases.Beaufighter,unitAliases.MosquitoII,unitAliases.MosquitoXIII,unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219}
reactionGroups.bomberDestroyer = {unitAliases.Me110,unitAliases.Me410}
reactionGroups.specialFighters = {unitAliases.EgonMayer,unitAliases.HermannGraf,unitAliases.JosefPriller,unitAliases.hwSchnaufer,unitAliases.Experten,unitAliases.USAAFAce,unitAliases.RAFAce}
reactionGroups.jetFighters = {unitAliases.P80,unitAliases.Meteor,unitAliases.He162,unitAliases.Me163,unitAliases.Me262}

--This is used for bombers to deal with how they approach various units - interceptor, escort, armored interceptor, or jet interceptor.  
--Bomber destroyers, Experten, and Aces don't trigger bomber defensive fire.  
--Jets do trigger bomber fire now (so bomber destroyers remain useful), but it will be minimal damage.

reactionGroups.escortFighters = {unitAliases.Yak3,unitAliases.RedTails,unitAliases.P51B,unitAliases.P51D,unitAliases.P47D11,unitAliases.P47D25,unitAliases.P47D40,unitAliases.SpitfireIX,unitAliases.SpitfireXII,unitAliases.SpitfireXIV,unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4  }
reactionGroups.interceptorFighters = {unitAliases.P38H,unitAliases.P38J,unitAliases.P38L,unitAliases.Typhoon,unitAliases.Tempest,unitAliases.Fw190A5,unitAliases.Fw190D9,unitAliases.Ta152}
reactionGroups.armoredInterceptorFighters =  {unitAliases.Fw190F,unitAliases.Fw190A8}
reactionGroups.jetInterceptors = {unitAliases.P80,unitAliases.Meteor,unitAliases.He162,unitAliases.Me163,unitAliases.Me262}
reactionGroups.nightInterceptors = {unitAliases.Beaufighter,unitAliases.MosquitoII,unitAliases.MosquitoXIII,unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219,unitAliases.Me110,unitAliases.Me410}

--These cover how flak does against other units.  Measures the armor rating of the unit it comes across.
reactionGroups.FlakvsLightFighter = {unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.SpitfireIX,unitAliases.SpitfireXII,unitAliases.SpitfireXIV,unitAliases.HurricaneIV,unitAliases.P51B,unitAliases.P51D}
reactionGroups.FlakvsMediumFighter = {unitAliases.Fw190A5,unitAliases.Fw190D9,unitAliases.Ta152,unitAliases.Me110,unitAliases.Me410,unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219,unitAliases.Do335,unitAliases.P38H,unitAliases.P38J,unitAliases.P38L,unitAliases.Beaufighter,unitAliases.MosquitoII,unitAliases.MosquitoXIII,unitAliases.Typhoon,unitAliases.Tempest}
reactionGroups.FlakvsHeavyFighter = {unitAliases.Fw190A8,unitAliases.Fw190F,unitAliases.P47D11,unitAliases.P47D25,unitAliases.P47D40}
reactionGroups.FlakvsJetFighter = {unitAliases.P80,unitAliases.Meteor,unitAliases.He162,unitAliases.Me163,unitAliases.Me262}
reactionGroups.FlakvsMediumBomber = {unitAliases.Ju87G,unitAliases.He111,unitAliases.A20,unitAliases.B26,unitAliases.A26}
reactionGroups.FlakvsHeavyBomber = {unitAliases.Do217,unitAliases.He277,unitAliases.Fw200,unitAliases.B17F,unitAliases.B24J,unitAliases.B17G,unitAliases.Stirling,unitAliases.Halifax,unitAliases.Lancaster,unitAliases.Sunderland}
reactionGroups.FlakvsJetBomber = {unitAliases.Arado234,unitAliases.Go229}

--This covers how Sunderlands and FW200 will react to naval units.
reactionGroups.navalUnits = {unitAliases.Convoy,unitAliases.UBoat,unitAliases.AlliedTaskForce,unitAliases.GermanTaskForce, unitAliases.Carrier}

--This covers how task forces will react to U-Boats and light bombers/fighter bombers.  Anything that can drop a bomb at low alt.
reactionGroups.canAttackNaval = {unitAliases.UBoat,unitAliases.Fw200,unitAliases.Sunderland,unitAliases.P47D11,unitAliases.P47D25,unitAliases.P47D40,unitAliases.Ju87G,unitAliases.Fw190F,unitAliases.Do335,unitAliases.A20,unitAliases.B26,unitAliases.A26,unitAliases.HurricaneIV,unitAliases.Typhoon,unitAliases.Tempest}

--This covers how gun batteries will react to naval invasions and ground forces
reactionGroups.gunBatteryVulnerable = {unitAliases.AlliedTaskForce,unitAliases.GermanTaskForce,unitAliases.AlliedArmyGroup,unitAliases.AlliedBatteredArmyGroup,unitAliases.GermanArmyGroup, unitAliases.GermanBatteredArmyGroup, unitAliases.AlliedLightFlak, unitAliases.GermanLightFlak, unitAliases.GermanFlak, unitAliases.AlliedFlak, unitAliases.Sdkfz, unitAliases.FlakTrain,}

-- make a reactionGroup of all air units
-- this includes munitions, so newly generated munitions will also be damaged if this
-- is used for area damage (that may be desirable or undesirable)
reactionGroups.allAir = {}
for i=0,128 do
    if civ.getUnitType(i) and civ.getUnitType(i).domain == 1 then
        table.insert(reactionGroups.allAir,civ.getUnitType(i))
    end
end

local techAliases = {}
techAliases.AdvancedRadarI = civ.getTech(17)
techAliases.AdvancedRadarII = civ.getTech(19)
techAliases.AdvancedRadarIII = civ.getTech(88)
techAliases.ProximityFuses = civ.getTech(83)
techAliases.FortiesI = civ.getTech(9) -- alias for 1940s Tech I
techAliases.NightFightersI = civ.getTech(13)
techAliases.NightFightersII = civ.getTech(14)
techAliases.NightFightersIII = civ.getTech(16)
techAliases.TacticsI = civ.getTech(90)
techAliases.TacticsII = civ.getTech(91)
techAliases.IndustryI = civ.getTech(61)
techAliases.IndustryII = civ.getTech(62)
techAliases.IndustryIII = civ.getTech(63)
techAliases.InterceptorsIII = civ.getTech(2)
techAliases.EscortFightersII = civ.getTech(4)
techAliases.EscortFightersIII = civ.getTech(6)


 
local damageType = {}

--STANDARD FIGHTER VS. FIGHTER
damageType.StrongFightervsFighterAttack = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}) -- unit in their element catching unit outside of element (includes nightfighter caught at day)
damageType.MediumFightervsFighterAttack = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}) -- unit in (or out of) their element vs. foe in (or out of) its element: Even match
damageType.WeakFightervsFighterAttack = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}) -- unit out of element vs. foe in its element (includes day fighter vs. nightfighter at night)

--FIGHTER VS. BOMBER
damageType.StrongFightervsBomberAttack = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}) -- bomber attacked by Bomber Destroyer (day only)
damageType.MediumFightervsBomberAttack = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}) -- bomber attacked by Interceptor or dedicated night fighter, also CAS attacked by escort
damageType.WeakFightervsBomberAttack = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}) -- bomber attacked by Escort, or day fighter flying at night, 


damageType.StrongJetFightervsFighterAttack = gen.makeThresholdTable({[0]=6,[.25]=7,[.5]=8,[.75]=9}) --Strong attack - jet vs. propeller fighter
damageType.MediumJetFightervsFighterAttack = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}) --Medium attack - jet vs. jet: Even match
damageType.WeakJetFightervsFighterAttack = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}) --Weak attack   - jet is climbing to attack a fighter 
 
damageType.StrongJetFightervsBomberAttack = gen.makeThresholdTable({[0]=7,[.25]=8,[.5]=9,[.75]=10}) --Strong attack - jet vs. light or medium bomber
damageType.MediumJetFightervsBomberAttack = gen.makeThresholdTable({[0]=6,[.25]=7,[.5]=8,[.75]=9}) --Medium attack - jet vs. heavy bomber
damageType.WeakJetFightervsBomberAttack = gen.makeThresholdTable({[0]=2,[.25]=4,[.5]=6,[.75]=8}) --Weak attack   - jet vs. jet bomber, or any bomber at night/climbing

damageType.StrongBomberDefense = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}) --Strong attack - bomber reacts to escort fighter
damageType.MediumBomberDefense = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}) --Medium attack - bomber reacts to interceptor
damageType.WeakBomberDefense = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}) --Weak attack   - bomber reacts to armored interceptor, or anything at night


damageType.StrongFlakAttack = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6})
damageType.MediumFlakAttack = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5})
damageType.WeakFlakAttack = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4})

damageType.StrongSeaDefense = gen.makeThresholdTable({[0]=0,[.25]=5,[.5]=15,[.75]=20})
damageType.MediumSeaDefense = gen.makeThresholdTable({[0]=0,[.25]=3,[.5]=4,[.75]=5})
damageType.WeakSeaDefense = gen.makeThresholdTable({[0]=0,[.25]=2,[.5]=3,[.75]=4})

damageType.StrongDiveAttack = gen.makeThresholdTable({[0]=8,[.25]=9,[.5]=10,[.75]=11})
damageType.MediumDiveAttack = gen.makeThresholdTable({[0]=4,[.25]=5,[.5]=6,[.75]=7})
damageType.WeakDiveAttack =  gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4})

damageType.GunBatteryDefensiveFire = gen.makeThresholdTable({[0]=4,[.25]=5,[.5]=6,[.75]=7})










--FLAK VS. AIRCRAFT
--damageSchedule = gen.makeThresholdTable({[0]=3,[.25]=4,[.5]=5,[.75]=6}),    --Strong attack - reaction against most aircraft at low altitude - exception: armored aircraft
--damageSchedule = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}),    --Medium attack - reaction against most bombers at high altitude
--damageSchedule = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}),    --Weak attack   - reaction against fighters at high altitude, armored fighters and jets at low altitude, jet bombers at high alt

--TASK FORCE VS. Attackers (Sunderland shares Strong Attack).
--damageSchedule = gen.makeThresholdTable({[0]=0,[.25]=5,[.5]=15,[.75]=20}),  --Strong attack - reaction against U-Boats (25% chance of miss, 25% chance of kill, 25% chance of various damage)
--damageSchedule = gen.makeThresholdTable({[0]=2,[.25]=3,[.5]=4,[.75]=5}),    --Medium attack - reaction against most aircraft
--damageSchedule = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}),    --Weak attack   - reaction against Sunderland and FW200

--DIVE BONUS
--damageSchedule = gen.makeThresholdTable({[0]=8,[.25]=9,[.5]=10,[.75]=11}),  --Strong diving attack
--damageSchedule = gen.makeThresholdTable({[0]=4,[.25]=5,[.5]=6,[.75]=7}),    --Medium diving attack
--damageSchedule = gen.makeThresholdTable({[0]=1,[.25]=2,[.5]=3,[.75]=4}),    --Weak diving attack


-- ri[unitType.id]=reactionInformation
local ri = {}
ri[unitAliases.Me109G6.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.6,-- 60% chance to kill munition set to true to kill munition 100% of time
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb.
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.WeakDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },--reactionDetail 1
        

    },

}

ri[unitAliases.Me109G14.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.7,-- 70% chance to kill munition set to true to kill munition 100% of time
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .28,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.WeakDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },--reactionDetail 1
        

    },

}

ri[unitAliases.Me109K4.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.7,-- 70% chance to kill munition set to true to kill munition 100% of time
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb.
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.WeakDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },--reactionDetail 1
        

    },

}

ri[unitAliases.Fw190A5.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.6,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumDiveAttack 
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.Fw190A8.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.7,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.Fw190D9.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.8,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.Ta152.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 3,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 3,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 3,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 3,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 3,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 3,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 3,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 3,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 3,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 3,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 3,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.Me110.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.6,-- 60% chance to kill munition set to true to kill munition 100% of time
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 1,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .1,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9]]
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 10
		--{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12]]

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 1,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .1,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9]]
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 10
		--{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12]]

    },
    
    climb = {
        --This unit will not climb to attack
		
    },
    --]]
    dive = {
        --This unit will not dive to attack
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .3,
            hitChanceCloud = .15,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.Me410.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.7,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 1,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .1,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9]]
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 10
		--{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12]]

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 1,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .1,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9]]
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 10
		--{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12]]

    },
    
    climb = {
        --This unit will not climb to attack
		
    },
    --]]
    dive = {
        --This unit will not dive to attack
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .4,
            hitChanceCloud = .2,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        

    },

}

--Dedicated night fighters will not do well by day, though they can intercept bombers.
ri[unitAliases.Ju88C.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.7,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		

    },
    
    climb = {
        --This unit will not climb to attack
		
    },
    --]]
    dive = {
        --This unit will not dive to attack
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
				{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 9
        

    },

}

ri[unitAliases.Ju88G.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.8,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		

    },
    
    climb = {
        --This unit will not climb to attack
		
    },
    --]]
    dive = {
        --This unit will not dive to attack
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
				{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 9
        

    },

}

ri[unitAliases.He219.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		

    },
    
    climb = {
        --This unit will not climb to attack
		
    },
    --]]
    dive = {
        --This unit will not dive to attack
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
				{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 9
        

    },

}

--GERMAN JETS WORKING ON FIRST ONE STILL

ri[unitAliases.He162.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.8,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .85,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongJetFightervsFighterAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .85,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumJetFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1

				
        

    },

}

ri[unitAliases.Me262.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .95,
            hitChanceCloud = .53,
            damageSchedule = damageType.StrongJetFightervsFighterAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .95,
            hitChanceCloud = .53,
            damageSchedule = damageType.StrongJetFightervsFighterAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1

				
        

    },

}

ri[unitAliases.Me163.id] ={
    reactionsPerTurn = 2,
	killMunition = .99,
	reactInsideCity = true,
    low = {
        --This unit only scrambles to attack high altitude units.

    },
    high = {
        
		--This unit spends one turn in the air so it can't react.		

    },
    
    climb = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 10,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 10,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 10,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		
    },
    --]]
    dive = {
        --This unit won't dive.
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
         {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 10,
            hitChance = .45,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 10,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 10,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5

				
        

    },

}

--GERMAN SPECIAL UNITS

ri[unitAliases.AdolfGalland.id] ={
    reactionsPerTurn = 4,
    killMunition = .99,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .95,
            hitChanceCloud = .53,
            damageSchedule = damageType.StrongJetFightervsFighterAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .95,
            hitChanceCloud = .53,
            damageSchedule = damageType.StrongJetFightervsFighterAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1

				
        

    },

}


ri[unitAliases.JosefPriller.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.EgonMayer.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.hwSchnaufer.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = 8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Schnaufer is deadly at night
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
				{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
        

    },

}

ri[unitAliases.HermannGraf.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.Experten.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .20,
            hitChanceCloud = .10,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .20,
            hitChanceCloud = .10,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },--reactionDetail 1
        

    },

}


ri[unitAliases.Go229.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = {
        --Strategic bombers don't react at low alt	
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsBomberAttack
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.StrongFightervsBomberAttack
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 1,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },
        

    },

}

ri[unitAliases.He277.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
        --Strategic bombers don't react at low alt	
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .2,
            damageSchedule = damageType.WeakBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .2,
            damageSchedule = damageType.WeakBomberDefense
        },
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .2,
            damageSchedule = damageType.WeakBomberDefense
        },
        

    },

}

ri[unitAliases.Do217.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
        --Strategic bombers don't react at low alt	
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.WeakBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.WeakBomberDefense
        },
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 1,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.WeakBomberDefense
        },
        

    },

}

ri[unitAliases.He111.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
        --Strategic bombers don't react at low alt	
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .70,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .70,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .40,
            hitChanceCloud = .20,
            damageSchedule = damageType.WeakBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .40,
            hitChanceCloud = .20,
            damageSchedule = damageType.WeakBomberDefense
        },
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 1,
            hitChance = .40,
            hitChanceCloud = .20,
            damageSchedule = damageType.WeakBomberDefense
        },
        

    },

}

ri[unitAliases.Ju87G.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = {
        
		{
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakBomberDefense
        },		
		
    },
    high = {
        --Jabo don't climb to height

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .1,
            hitChanceCloud = .05,
            damageSchedule = damageType.WeakBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .1,
            hitChanceCloud = .05,
            damageSchedule = damageType.WeakBomberDefense
        },
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 1,
            hitChance = .1,
            hitChanceCloud = .05,
            damageSchedule = damageType.WeakBomberDefense
        },
        

    },

}

ri[unitAliases.Fw190F.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = {
        
		{
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsFighterAttack
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },		
		
    },
    high = {
        --Jabo don't climb to height

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 1,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },
        

    },

}

ri[unitAliases.He219.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = {
        
		{
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsFighterAttack
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },		
		
    },
    high = {
        --Jabo don't climb to height

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 1,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },
        

    },

}

ri[unitAliases.Fw200.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
        
		{
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.WeakBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.WeakBomberDefense
        },		
		{
            targetTypes = reactionGroups.navalUnits,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.StrongBomberDefense
        },
		
    },
    high = {
        --Jabo don't climb to height

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .1,
            damageSchedule = damageType.WeakBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .1,
            damageSchedule = damageType.WeakBomberDefense
        },
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 1,
            hitChance = .2,
            hitChanceCloud = .1,
            damageSchedule = damageType.WeakBomberDefense
        },
        

    },

}

ri[unitAliases.Arado234.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
        
		{
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumBomberDefense
        },		
		
    },
    high = {
        --Jabo don't climb to height

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.WeakBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.WeakBomberDefense
        },
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 1,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.WeakBomberDefense
        },
        

    },

}

ri[unitAliases.B17F.id] ={
    reactionsPerTurn = 3,
    killMunition = .99,
    low = {
        --Strategic bombers don't react at low alt	
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.WeakBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        --This unit does not fly at night
       

    },

}

ri[unitAliases.B17G.id] ={
    reactionsPerTurn = 4,
    killMunition = .99,
    low = {
        --Strategic bombers don't react at low alt	
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.WeakBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        --This unit does not fly at night
       

    },

}

ri[unitAliases.B24J.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
        --Strategic bombers don't react at low alt	
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.WeakBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        --This unit does not fly at night
       

    },

}

ri[unitAliases.FifteenthAF.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
        --Strategic bombers don't react at low alt	
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.WeakBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        --This unit does not fly at night
       

    },

}

ri[unitAliases.MedBombers.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
        --Strategic bombers don't react at low alt	
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.WeakBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        --This unit does not fly at night
       

    },

}

ri[unitAliases.A20.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumBomberDefense
        },	
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakBomberDefense
        },
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        --This unit does not fly at night
       

    },

}

ri[unitAliases.B26.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumBomberDefense
        },	
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 1,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.WeakBomberDefense
        },
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 1,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.WeakBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        --This unit does not fly at night
       

    },

}

ri[unitAliases.A26.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumBomberDefense
        },	
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakBomberDefense
        },
		
    },
    high = {
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakBomberDefense
        },

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		
        --This unit does not fly at night
       

    },

}

ri[unitAliases.Stirling.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
       --Bomber Command does not fly during the day.
		
    },
    high = {
       --Bomber Command does not fly during the day.

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		--Bomber Command does better against Wilde Sau than dedicated night fighters
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumBomberDefense
        },
       {
            targetTypes = reactionGroups.nightInterceptors,
            maxDistance = 1,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakBomberDefense
        },

    },

}

ri[unitAliases.Halifax.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
       --Bomber Command does not fly during the day.
		
    },
    high = {
       --Bomber Command does not fly during the day.

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		--Bomber Command does better against Wilde Sau than dedicated night fighters
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.MediumBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 1,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.MediumBomberDefense
        },
       {
            targetTypes = reactionGroups.nightInterceptors,
            maxDistance = 1,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.WeakBomberDefense
        },

    },

}

ri[unitAliases.Lancaster.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
       --Bomber Command does not fly during the day.
		
    },
    high = {
       --Bomber Command does not fly during the day.

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		--Bomber Command does better against Wilde Sau than dedicated night fighters
        {
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumBomberDefense
        },
		{
            targetTypes = reactionGroups.armoredInterceptorFighters,
            maxDistance = 1,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumBomberDefense
        },
       {
            targetTypes = reactionGroups.nightInterceptors,
            maxDistance = 1,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakBomberDefense
        },

    },

}

ri[unitAliases.HurricaneIV.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = {
        
		{
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsFighterAttack
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 1,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },		
		
    },
    high = {
        --Jabo don't climb to height

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		--This unit does not fly at night.     

    },

}

ri[unitAliases.Typhoon.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = { 
		
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		
    },
    high = {
        --Jabo don't climb to height

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		--This unit does not fly at night.     

    },

}

ri[unitAliases.Tempest.id] ={
    reactionsPerTurn = 1,
    killMunition = .99,
    low = { 
		
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		
    },
    high = {
        --Jabo don't climb to height

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
		--This unit does not fly at night.     

    },

}

ri[unitAliases.USAAFAce.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .20,
            hitChanceCloud = .10,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .20,
            hitChanceCloud = .10,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.RAFAce.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .20,
            hitChanceCloud = .10,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = .20,
            hitChanceCloud = .10,
            damageSchedule = damageType.WeakFightervsFighterAttack,
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Wilde Sau units will only react to bombers and will do so poorly.
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 1,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },--reactionDetail 1
        

    },

}

ri[unitAliases.P47D11.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.6,-- 60% chance to kill munition set to true to kill munition 100% of time
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 3,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 3,
            hitChance = .25,
            hitChanceCloud = .12,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 3,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 3,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb.
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 3,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Allied daylight fighters don't fly at night.      
        

    },

}

ri[unitAliases.P47D25.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.7,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 3,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 3,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 3,
            hitChance = .3,
            hitChanceCloud = .15,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 3,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 3,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 3,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 3,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 3,
            hitChance = .55,
            hitChanceCloud = .28,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 3,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 3,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb.
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 3,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Allied daylight fighters don't fly at night.      
        

    },

}

ri[unitAliases.P47D40.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.7,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 3,
            hitChance = .6,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 3,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 3,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 3,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 3,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 3,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 3,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 3,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 3,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 3,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb.
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 3,
            hitChance = 1,
            hitChanceCloud = .5,
            damageSchedule = damageType.StrongDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--Allied daylight fighters don't fly at night.      
        

    },

}

ri[unitAliases.P38H.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.6,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .35,
            hitChanceCloud = .18,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakDiveAttack 
        },--reactionDetail 1
        
    },
    night = {
		--USAAF fighters don't fly at night
        
        

    },

}

ri[unitAliases.P38J.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.7,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
            damageSchedule = damageType.WeakDiveAttack 
        },--reactionDetail 1
        
    },
    night = {
		--USAAF fighters don't fly at night
        
        

    },

}

ri[unitAliases.P38L.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.8,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.WeakFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumDiveAttack 
        },--reactionDetail 1
        
    },
    night = {
		--USAAF fighters don't fly at night
        
        

    },

}

ri[unitAliases.P51B.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .9,
            hitChanceCloud = .45,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .70,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--USAAF units don't fly at night        
        

    },

}

ri[unitAliases.P51D.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .45,
            hitChanceCloud = .23,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--USAAF units don't fly at night        
        

    },

}

ri[unitAliases.RedTails.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 4,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.MediumFightervsBomberAttack 
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongFightervsBomberAttack
        },-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsBomberAttack
        },-- reactionDetail 4
		--[[{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 1,
            hitChance = .05
            hitChanceCloud = .025
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 5]]
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 4,
            hitChance = .85,
            hitChanceCloud = .43,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 9
		--[[{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 10
		--[[{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },]]-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 4,
            hitChance = .75,
            hitChanceCloud = .38,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 4,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--USAAF units don't fly at night        
        

    },

}

ri[unitAliases.Sunderland.id] ={
    reactionsPerTurn = 2,
    killMunition = .99,
    low = {
        
		{
            targetTypes = reactionGroups.interceptorFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.WeakBomberDefense
		},
        
		{
            targetTypes = reactionGroups.escortFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.WeakBomberDefense
        },		
		{
            targetTypes = reactionGroups.navalUnits,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
            damageSchedule = damageType.StrongSeaDefense
        },
		
    },
    high = {
        --Jabo don't climb to height

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        --This unit will not dive
        
    },
    night = {
	    --This unit does not fly at night.
        

    },

}

ri[unitAliases.Meteor.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.8,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .85,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongJetFightervsFighterAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .85,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumJetFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--This unit does not fly at night
        
		
	},
}

ri[unitAliases.P80.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.8,
    low = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .85,
            hitChanceCloud = .48,
            damageSchedule = damageType.StrongJetFightervsFighterAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.StrongJetFightervsFighterAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    high = {
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 6,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.mediumBombers,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },-- reactionDetail 2
		{
            targetTypes = reactionGroups.lightCloseAirSupport,
            maxDistance = 6,
            hitChance = .85,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumJetFightervsBomberAttack 
			},-- reactionDetail 3
		{
            targetTypes = reactionGroups.heavyCloseAirSupport,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsBomberAttack
        },-- reactionDetail 4
		{
            targetTypes = reactionGroups.jetBombers,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.WeakJetFightervsBomberAttack
        },-- reactionDetail 5
		{
            targetTypes = reactionGroups.highAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 6
		{
            targetTypes = reactionGroups.lowAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 7
		{
            targetTypes = reactionGroups.bothAltFighters,
            maxDistance = 6,
            hitChance = .7,
            hitChanceCloud = .35,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 8
		{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 9
		{
            targetTypes = reactionGroups.specialFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 10
		{
            targetTypes = reactionGroups.jetFighters,
            maxDistance = 3,
            hitChance = .5,
            hitChanceCloud = .25,
            damageSchedule = damageType.MediumJetFightervsFighterAttack
        },-- reactionDetail 11
		{
            targetTypes = reactionGroups.bomberDestroyer,
            maxDistance = 6,
            hitChance = .80,
            hitChanceCloud = .4,
            damageSchedule = damageType.StrongFightervsFighterAttack
        },-- reactionDetail 12

    },
    
    climb = {
        --This unit will not climb
		
    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.allAir,
            maxDistance = 2,
            hitChance = .95,
            hitChanceCloud = .48,
            damageSchedule = damageType.MediumDiveAttack
        },--reactionDetail 1
        
    },
    night = {
		--This unit does not fly at night
        
		
	},
}

ri[unitAliases.Beaufighter.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.7,
    low = {
       --This unit doesn't fly during the day 
		

    },
    high = {
        
		

    },
    
    climb = {
        --This unit will not climb to attack
		
    },
    --]]
    dive = {
        --This unit will not dive to attack
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .6,
            hitChanceCloud = .3,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
				{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .4,
            hitChanceCloud = .2,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 9
        

    },

}

ri[unitAliases.MosquitoII.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.8,
    low = {
         --This unit doesn't fly during the day
		

    },
    high = {
         --This unit doesn't fly during the day
		

    },
    
    climb = {
        --This unit will not climb to attack
		
    },
    --]]
    dive = {
        --This unit will not dive to attack
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .65,
            hitChanceCloud = .33,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
				{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .45,
            hitChanceCloud = .23,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 9
        

    },

}

ri[unitAliases.MosquitoXIII.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.9,
    low = {
         --This unit doesn't fly during the day
		

    },
    high = {
         --This unit doesn't fly during the day
		

    },
    
    climb = {
        --This unit will not climb to attack
		
    },
    --]]
    dive = {
        --This unit will not dive to attack
        
    },
    night = {
		
        {
            targetTypes = reactionGroups.heavyBombers,
            maxDistance = 2,
            hitChance = .7,
            hitChanceCloud = .35,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsBomberAttack
        },--reactionDetail 1
				{
            targetTypes = reactionGroups.nightFighters,
            maxDistance = 2,
            hitChance = .5,
            hitChanceCloud = .25,
			shooterTechMod = {{techAliases.AdvancedRadarI,.1},{techAliases.AdvancedRadarII,.1},{techAliases.AdvancedRadarIII,.1},},
            shooterTechCloud = {{techAliases.AdvancedRadarI,.05},{techAliases.AdvancedRadarII,.05},{techAliases.AdvancedRadarIII,.05},},
            damageSchedule = damageType.MediumFightervsFighterAttack
        },-- reactionDetail 9
        

    },

}

--**GETEND**



ri[unitAliases.GermanFlak.id] ={
    reactionsPerTurn = 4,
    killMunition = 4,-- if plane killed, do 4 damage to each munition
    reactInsideCity=true,
    low = {
        {
            targetTypes = reactionGroups.FlakvsLightFighter,
            maxDistance = 2,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
            damageSchedule = damageType.StrongFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
        {
            targetTypes = reactionGroups.FlakvsMediumFighter,
            maxDistance = 2,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyFighter,
            maxDistance = 2,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetFighter,
            maxDistance = 2,
            hitChance = {[1]=.4,[2]=.2},
            hitChanceCloud = {[1]=.2,[2]=.1},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 2,
            hitChance = {[1]=.7,[2]=.35},
            hitChanceCloud = {[1]=.35,[2]=.175},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 2,
            hitChance = {[1]=.8,[2]=.4},
            hitChanceCloud = {[1]=.4,[2]=.2},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.6,[2]=.3},
            hitChanceCloud = {[1]=.3,[2]=.15},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
    climb = {
        
		
		{
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 2,
            hitChance = {[1]=.4,[2]=.2},
            hitChanceCloud = {[1]=.2,[2]=.1},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 2,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.3,[2]=.15},
            hitChanceCloud = {[1]=.15,[2]=.075},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
    --
    groundToNight = {
        {
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 2,
            hitChance = {[1]=.35,[2]=.15},
            hitChanceCloud = {[1]=.175,[2]=.075},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 2,
            hitChance = {[1]=.45,[2]=.2},
            hitChanceCloud = {[1]=.275,[2]=.1},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.25,[2]=.1},
            hitChanceCloud = {[1]=.125,[2]=.05},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
}

ri[unitAliases.AlliedFlak.id] ={
    reactionsPerTurn = 4,
    killMunition = 4,-- if plane killed, do 4 damage to each munition
    reactInsideCity=true,
    low = {
        {
            targetTypes = reactionGroups.FlakvsLightFighter,
            maxDistance = 2,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
            damageSchedule = damageType.StrongFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
        {
            targetTypes = reactionGroups.FlakvsMediumFighter,
            maxDistance = 2,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyFighter,
            maxDistance = 2,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetFighter,
            maxDistance = 2,
            hitChance = {[1]=.4,[2]=.2},
            hitChanceCloud = {[1]=.2,[2]=.1},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 2,
            hitChance = {[1]=.7,[2]=.35},
            hitChanceCloud = {[1]=.35,[2]=.175},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 2,
            hitChance = {[1]=.8,[2]=.4},
            hitChanceCloud = {[1]=.4,[2]=.2},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.6,[2]=.3},
            hitChanceCloud = {[1]=.3,[2]=.15},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
    climb = {
        
		
		{
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 2,
            hitChance = {[1]=.4,[2]=.2},
            hitChanceCloud = {[1]=.2,[2]=.1},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 2,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.3,[2]=.15},
            hitChanceCloud = {[1]=.15,[2]=.075},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
    --
    groundToNight = {
        {
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 2,
            hitChance = {[1]=.35,[2]=.15},
            hitChanceCloud = {[1]=.175,[2]=.075},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 2,
            hitChance = {[1]=.45,[2]=.2},
            hitChanceCloud = {[1]=.275,[2]=.1},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.25,[2]=.1},
            hitChanceCloud = {[1]=.125,[2]=.05},
			shooterTechMod = {{techAliases.ProximityFuses,.2},},
            shooterTechCloud = {{techAliases.ProximityFuses,.2},},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
}

ri[unitAliases.GermanLightFlak.id] ={
    reactionsPerTurn = 2,
    killMunition = 10,-- if plane killed, do 4 damage to each munition
    reactInsideCity=true,
    low = {
        {
            targetTypes = reactionGroups.FlakvsLightFighter,
            maxDistance = 2,
            hitChance = {[1]=.8,[2]=.4},
            hitChanceCloud = {[1]=.4,[2]=.2},
            damageSchedule = damageType.StrongFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
        {
            targetTypes = reactionGroups.FlakvsMediumFighter,
            maxDistance = 2,
            hitChance = {[1]=.6,[2]=.3},
            hitChanceCloud = {[1]=.3,[2]=.15},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyFighter,
            maxDistance = 2,
            hitChance = {[1]=.3,[2]=.15},
            hitChanceCloud = {[1]=.15,[2]=.075},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetFighter,
            maxDistance = 2,
            hitChance = {[1]=.4,[2]=.2},
            hitChanceCloud = {[1]=.2,[2]=.1},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 2,
            hitChance = {[1]=.8,[2]=.4},
            hitChanceCloud = {[1]=.4,[2]=.2},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 2,
            hitChance = {[1]=.9,[2]=.45},
            hitChanceCloud = {[1]=.45,[2]=.275},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.7,[2]=.35},
            hitChanceCloud = {[1]=.35,[2]=.175},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
    climb = {
        
		--Light flak only fires at low altitude
		

    },
    --
    night = {
        {
            targetTypes = reactionGroups.FlakvsLightFighter,
            maxDistance = 1,
            hitChance = {[1]=.7,[2]=.35},
            hitChanceCloud = {[1]=.35,[2]=.175},
            damageSchedule = damageType.StrongFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
        {
            targetTypes = reactionGroups.FlakvsMediumFighter,
            maxDistance = 1,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyFighter,
            maxDistance = 1,
            hitChance = {[1]=.2,[2]=.1},
            hitChanceCloud = {[1]=.1,[2]=.5},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetFighter,
            maxDistance = 1,
            hitChance = {[1]=.3,[2]=.15},
            hitChanceCloud = {[1]=.15,[2]=.075},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 1,
            hitChance = {[1]=.7,[2]=.35},
            hitChanceCloud = {[1]=.35,[2]=.175},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 1,
            hitChance = {[1]=.8,[2]=.4},
            hitChanceCloud = {[1]=.4,[2]=.2},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.6,[2]=.3},
            hitChanceCloud = {[1]=.3,[2]=.15},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
}

ri[unitAliases.AlliedLightFlak.id] ={
    reactionsPerTurn = 2,
    killMunition = 10,-- if plane killed, do 4 damage to each munition
    reactInsideCity=true,
    low = {
        {
            targetTypes = reactionGroups.FlakvsLightFighter,
            maxDistance = 2,
            hitChance = {[1]=.8,[2]=.4},
            hitChanceCloud = {[1]=.4,[2]=.2},
            damageSchedule = damageType.StrongFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
        {
            targetTypes = reactionGroups.FlakvsMediumFighter,
            maxDistance = 2,
            hitChance = {[1]=.6,[2]=.3},
            hitChanceCloud = {[1]=.3,[2]=.15},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyFighter,
            maxDistance = 2,
            hitChance = {[1]=.3,[2]=.15},
            hitChanceCloud = {[1]=.15,[2]=.075},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetFighter,
            maxDistance = 2,
            hitChance = {[1]=.4,[2]=.2},
            hitChanceCloud = {[1]=.2,[2]=.1},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 2,
            hitChance = {[1]=.8,[2]=.4},
            hitChanceCloud = {[1]=.4,[2]=.2},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 2,
            hitChance = {[1]=.9,[2]=.45},
            hitChanceCloud = {[1]=.45,[2]=.275},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.7,[2]=.35},
            hitChanceCloud = {[1]=.35,[2]=.175},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
    climb = {
        
		--Light flak only fires at low altitude
		

    },
    --
    night = {
        {
            targetTypes = reactionGroups.FlakvsLightFighter,
            maxDistance = 1,
            hitChance = {[1]=.7,[2]=.35},
            hitChanceCloud = {[1]=.35,[2]=.175},
            damageSchedule = damageType.StrongFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
        {
            targetTypes = reactionGroups.FlakvsMediumFighter,
            maxDistance = 1,
            hitChance = {[1]=.5,[2]=.25},
            hitChanceCloud = {[1]=.25,[2]=.125},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyFighter,
            maxDistance = 1,
            hitChance = {[1]=.2,[2]=.1},
            hitChanceCloud = {[1]=.1,[2]=.5},
            damageSchedule = damageType.WeakFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetFighter,
            maxDistance = 1,
            hitChance = {[1]=.3,[2]=.15},
            hitChanceCloud = {[1]=.15,[2]=.075},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsMediumBomber,
            maxDistance = 1,
            hitChance = {[1]=.7,[2]=.35},
            hitChanceCloud = {[1]=.35,[2]=.175},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsHeavyBomber,
            maxDistance = 1,
            hitChance = {[1]=.8,[2]=.4},
            hitChanceCloud = {[1]=.4,[2]=.2},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },
		{
            targetTypes = reactionGroups.FlakvsJetBomber,
            maxDistance = 2,
            hitChance = {[1]=.6,[2]=.3},
            hitChanceCloud = {[1]=.3,[2]=.15},
            damageSchedule = damageType.MediumFlakAttack,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },

    },
}


ri[unitAliases.GunBattery.id] ={
    reactionsPerTurn = 2,
    killMunition = 10,-- if plane killed, do 4 damage to each munition
    reactInsideCity=true,
    low = {
        {
            targetTypes = reactionGroups.gunBatteryVulnerable,
            maxDistance = 2,
            hitChance = {[1]=.8,[2]=.4},
            hitChanceCloud = {[1]=.4,[2]=.2},
            damageSchedule = damageType.GunBatteryDefensiveFire,
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[8]=true,[9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[14]=true,[15]=true}
        },
       
    },
   
}
























--  You should not have to modify stuff below this line
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--  You should not have to modify stuff below this line
--
--
--
--
--
--
--
--
--
--
--
--  You should not have to modify stuff below this line






local function canReact(target,shooter)
    if not ri[shooter.type.id] then
        return false
    end
    if target.owner == shooter.owner then
        return false
    end
    local shooterMap = shooter.location.z
    local targetMap = target.location.z
    local reactionSuffix = ""
    
    local elevationKey = nil
    if shooterMap == 0 and targetMap == 0 then
        elevationKey = "low"
    elseif shooterMap == 0 and targetMap == 1 then
        elevationKey = "climb"
        reactionSuffix = " (Climb)"
    elseif shooterMap == 0 and targetMap == 2 then
        elevationKey = "groundToNight"
    elseif shooterMap == 1 and targetMap == 0 then
        elevationKey = "dive"
        reactionSuffix = " (Dive)"
    elseif shooterMap == 1 and targetMap == 1 then
        elevationKey = "high"
    elseif shooterMap == 2 and targetMap == 2 then
        elevationKey = "night"
    else
        return false
    end
    -- now, we find the specific reaction detail
    local detailsTable = ri[shooter.type.id][elevationKey]
    if not detailsTable then
        return false
    end
    local selectedDetail = nil
    local targetType = target.type
    for __,reactionDetail in pairs(detailsTable) do
        if gen.inTable(targetType,reactionDetail.targetTypes) then
            selectedDetail = reactionDetail
            break
        end
    end
    if not selectedDetail then
        return false
    end
    if gen.distance(shooter,target) > selectedDetail.maxDistance or 
        (selectedDetail.forbiddenShooterTerrain and
        selectedDetail.forbiddenShooterTerrain[shooter.location.terrainType % 16]) then
        return false
    end
    if reactionBase.getReactionsMade(shooter) >= ri[shooter.type.id]["reactionsPerTurn"] then
        return false
    end
    if (shooter.location.city or gen.unitTypeOnTile(shooter.location,unitAliases.Carrier)) and not (ri[shooter.type.id]["reactInsideCity"]) then
        return false
    end
    return shooter.type.name..reactionSuffix
end


local function hitProbability(target,shooter)
    local shooterMap = shooter.location.z
    local targetMap = target.location.z
    if shooterMap == 0 and targetMap == 0 then
        elevationKey = "low"
    elseif shooterMap == 0 and targetMap == 1 then
        elevationKey = "climb"
    elseif shooterMap == 0 and targetMap == 2 then
        elevationKey = "groundToNight"
    elseif shooterMap == 1 and targetMap == 0 then
        elevationKey = "dive"
    elseif shooterMap == 1 and targetMap == 1 then
        elevationKey = "high"
    elseif shooterMap == 2 and targetMap == 2 then
        elevationKey = "night"
    else
        return false
    end
    -- now, we find the specific reaction detail
    local detailsTable = ri[shooter.type.id][elevationKey]
    local selectedDetail = nil
    local targetType = target.type
    for __,reactionDetail in pairs(detailsTable) do
        if gen.inTable(targetType,reactionDetail.targetTypes) then
            selectedDetail = reactionDetail
            break
        end
    end
    local distance = gen.distance(shooter,target)
    local cloudSuffix = ""
    if target.location.z == 2 and target.location.terrainType % 16 == 5 then
        cloudSuffix = "Cloud"
    elseif target.location.z == 1 and target.location.terrainType % 16 == 5 then
        cloudSuffix = "Cloud"
    end
    local hitChanceVal = selectedDetail["hitChance"..cloudSuffix] or slectedDetail["hitChance"]
    local hitProb = 0
    if type(hitChanceVal) == "table" then
        hitProb = hitChanceVal[distance] or 0
    else
        hitProb = hitChanceVal
    end
    local shooterTechModVal = selectedDetail["shooterTechMod"..cloudSuffix] or selectedDetail["shooterTechMod"]
    local targetTechModVal = selectedDetail["targetTechMod"..cloudSuffix] or selectedDetail["targetTechMod"]
    if shooterTechModVal then
        for __,techModifier in pairs(shooterTechModVal) do
            if civ.hasTech(shooter.owner,techModifier[1]) then
                hitProb = hitProb+techModifier[2]
            end
        end
    end
    if targetTechModVal then
        for __,techModifier in pairs(targetTechModVal) do
            if civ.hasTech(target.owner,techModifier[1]) then
                hitProb = hitProb+techModifier[2]
            end
        end
    end
    hitProb = math.max(math.min(hitProb,(selectedDetail.maxChance or 1)),(selectedDetail.minChance or 0))
    return hitProb
end

local function damageSchedule(target,shooter)
    local shooterMap = shooter.location.z
    local targetMap = target.location.z
    if shooterMap == 0 and targetMap == 0 then
        elevationKey = "low"
    elseif shooterMap == 0 and targetMap == 1 then
        elevationKey = "climb"
    elseif shooterMap == 0 and targetMap == 2 then
        elevationKey = "groundToNight"
    elseif shooterMap == 1 and targetMap == 0 then
        elevationKey = "dive"
    elseif shooterMap == 1 and targetMap == 1 then
        elevationKey = "high"
    elseif shooterMap == 2 and targetMap == 2 then
        elevationKey = "night"
    else
        return false
    end
    -- now, we find the specific reaction detail
    local detailsTable = ri[shooter.type.id][elevationKey]
    local selectedDetail = nil
    local targetType = target.type
    for __,reactionDetail in pairs(detailsTable) do
        if gen.inTable(targetType,reactionDetail.targetTypes) then
            selectedDetail = reactionDetail
            break
        end
    end
    return selectedDetail.damageSchedule
end

local function reactionPriority(target,shooter,hitProbability,damageSchedule)
    return reactionBase.expectedRemainingHitpoints(target,hitProbability,damageSchedule)
end

local function munitionEffect(targetBeforeDamage,shooter,munitionsTable,targetHit,damageToBeDoneToTarget)
    if damageToBeDoneToTarget < targetBeforeDamage.hitpoints then
        -- target will survive this attack
        return
    end
    local killMunition = ri[shooter.type.id].killMunition
    if type(killMunition) == "number" then
        for __,munition in pairs(munitionsTable) do
            if killMunition < 1 then
                if math.random() < killMunition then
                    civ.deleteUnit(munition)
                end
            elseif killMunition < munition.type.hitpoints then
                munition.damage = math.floor(killMunition)
            else
                civ.deleteUnit(munition)
            end
        end
    elseif killMunition then
        civ.deleteUnit(munition)
    end
end

local function afterReaction(targetAfterDamageBeforeDeletion,shooter,damageDone,targetHit,targetKilled,targetDemoted)
    reactionBase.incrementReactions(shooter)
end

local reactOTR = {}

function reactOTR.makeReaction(target,munitionsTable,doWhenUnitKilled,maximumReactionsAgainstTriggerUnit)
    reactionBase.reactionEngine(target,munitionsTable,canReact,hitProbability,damageSchedule,reactionPriority,munitionEffect,afterReaction,doWhenUnitKilled,maximumReactionsAgainstTriggerUnit)

end

return reactOTR




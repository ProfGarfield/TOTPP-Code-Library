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
reactionGroups.strategicBombers = {unitAliases.B17F,unitAliases.B17G,unitAliases.B24J,unitAliases.Stirling,unitAliases.Halifax,unitAliases.Lancaster,unitAliases.MedBombers,unitAliases.Do217,unitAliases.He277,unitAliases.He111,unitAliases.damagedB17F,unitAliases.damagedB17G}

reactionGroups.alliedFighters = {unitAliases.SpitfireIX,unitAliases.SpitfireXII,unitAliases.SpitfireXIV,unitAliases.HurricaneIV,unitAliases.Typhoon,unitAliases.Tempest,unitAliases.P47D11,unitAliases.P47D25,
unitAliases.P47D40,unitAliases.P38H,unitAliases.P38J,unitAliases.P38L,unitAliases.P51B,unitAliases.P51D,unitAliases.Beaufighter,unitAliases.MosquitoII,unitAliases.MosquitoXIII,unitAliases.RedTails,unitAliases.Yak3}

reactionGroups.germanInterceptors = {unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219}

reactionGroups.canInterceptGerman = {unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219,unitAliases.Me110,unitAliases.Me410,unitAliases.Ju87G,unitAliases.Do217,unitAliases.He277,unitAliases.He111,unitAliases.Fw200,
unitAliases.Fw190F,unitAliases.Do335}

--Actually is all but jets and German Experten which can't be intercepted except by P51D, Tempest, RedTails
reactionGroups.allButJets = {unitAliases.A26,unitAliases.B26,unitAliases.A20, unitAliases.B17F,unitAliases.B17G,unitAliases.B24J,unitAliases.Stirling,unitAliases.Halifax,unitAliases.Lancaster,unitAliases.MedBombers,
unitAliases.SpitfireIX,unitAliases.SpitfireXII,unitAliases.SpitfireXIV,unitAliases.HurricaneIV,unitAliases.Typhoon,unitAliases.Tempest,unitAliases.P47D11,unitAliases.P47D25,
unitAliases.P47D40,unitAliases.P38H,unitAliases.P38J,unitAliases.P38L,unitAliases.P51B,unitAliases.P51D,unitAliases.Beaufighter,unitAliases.MosquitoII,unitAliases.MosquitoXIII,unitAliases.RedTails,unitAliases.Yak3,
unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,unitAliases.Fw190F,unitAliases.Do335,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219,unitAliases.Me110,unitAliases.Me410,unitAliases.Ju87G,unitAliases.Do217,unitAliases.He277,unitAliases.He111,unitAliases.Fw200,unitAliases.Sunderland}

--Considers all units except jabo (strategic bombers and regular fighters need to be very wary of light flak)
reactionGroups.allButJabo = {unitAliases.A26,unitAliases.B26,unitAliases.A20,unitAliases.B17F,unitAliases.B17G,unitAliases.B24J,unitAliases.Stirling,unitAliases.Halifax,unitAliases.Lancaster,unitAliases.MedBombers,
unitAliases.SpitfireIX,unitAliases.SpitfireXII,unitAliases.SpitfireXIV,
unitAliases.P38H,unitAliases.P38J,unitAliases.P38L,unitAliases.P51B,unitAliases.P51D,unitAliases.Beaufighter,unitAliases.MosquitoII,unitAliases.MosquitoXIII,unitAliases.RedTails,unitAliases.Yak3,
unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219,unitAliases.Me110,unitAliases.Me410,unitAliases.Do217,unitAliases.He277,unitAliases.He111,unitAliases.Fw200,unitAliases.Sunderland}

--considers all jabo but not tactical bombers - jabo still takes 'some' damage from light flak whereas tactical bombers takes no reaction damage (they fly at medium alts)
reactionGroups.jabo = {unitAliases.Ju87G,unitAliases.Fw190F,unitAliases.Do335,unitAliases.HurricaneIV,unitAliases.Typhoon,unitAliases.Tempest,unitAliases.P47D11,unitAliases.P47D25,
unitAliases.P47D40}

--For purposes of Allied attacks, they will intercept and maul bombers, do significant damage to heavy fighters, and do less damage to regular fighters

reactionGroups.luftwaffeFighter = {unitAliases.Me109G6,unitAliases.Me109G14,unitAliases.Me109K4,unitAliases.Fw190A5,unitAliases.Fw190A8,unitAliases.Fw190D9,unitAliases.Ta152,
unitAliases.Ju88C,unitAliases.Ju88G,unitAliases.He219}

reactionGroups.luftwaffeHeavyFighter = {unitAliases.Me110,unitAliases.Me410,unitAliases.Fw190F, unitAliases.Do335}

reactionGroups.luftwaffeBomber = {unitAliases.Ju87G,unitAliases.Do217,unitAliases.He277,unitAliases.He111,unitAliases.Fw200}

reactionGroups.luftwaffeJets = {unitAliases.He162,unitAliases.Me262,unitAliases.EgonMayer,unitAliases.JosefPriller,unitAliases.HermannGraf,unitAliases.hwSchnaufer,unitAliases.AdolfGalland, unitAliases.Experten}

reactionGroups.alliedJets = {unitAliases.P80,unitAliases.Meteor}

reactionGroups.navalUnits = {unitAliases.Convoy,unitAliases.UBoat,unitAliases.AlliedTaskForce,unitAliases.GermanTaskForce, unitAliases.Carrier}

reactionGroups.gunBatteryVulnerable = {unitAliases.AlliedTaskForce, unitAliases.GermanTaskForce, unitAliases.AlliedArmyGroup, unitAliases.AlliedBatteredArmyGroup, unitAliases.GermanArmyGroup, unitAliases.GermanBatteredArmyGroup, unitAliases.AlliedLightFlak, unitAliases.GermanLightFlak, unitAliases.GermanFlak, unitAliases.AlliedFlak, unitAliases.Sdkfz, unitAliases.FlakTrain,}

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



-- ri[unitType.id]=reactionInformation
local ri = {}
ri[unitAliases.Me109G6.id] ={
    reactionsPerTurn = 4,
    killMunition = 0.6,-- 60% chance to kill munition set to true to kill munition 100% of time
    low = {
        {
            targetTypes = reactionGroups.strategicBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = gen.makeThresholdTable({[0]=9,[.05]=4,[.1]=3,[.5]=2}),
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.alliedFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 2

    },
    high = {
        {
            targetTypes = reactionGroups.strategicBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = gen.makeThresholdTable({[0]=9,[.05]=4,[.1]=2,[.5]=1}),
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.alliedFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 2

    },
    
    climb = {
        {
            targetTypes = reactionGroups.strategicBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = gen.makeThresholdTable({[0]=9,[.05]=7,[.1]=6,[.5]=5}),
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.alliedFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 2

    },
    --]]
    dive = {
        {
            targetTypes = reactionGroups.strategicBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = gen.makeThresholdTable({[0]=9,[.05]=4,[.1]=2,[.5]=1}),
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.alliedFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 2

    },
    night = {
        {
            targetTypes = reactionGroups.strategicBombers,
            maxDistance = 2,
            hitChance = .2,
            hitChanceCloud = .1,
            damageSchedule = gen.makeThresholdTable({[0]=9,[.05]=4,[.1]=2,[.5]=1}),
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.alliedFighters,
            maxDistance = 2,
            hitChance = .2,
            hitChanceCloud = .1,
            shooterTechMod = {},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
        },-- reactionDetail 2

    },

}


ri[unitAliases.GermanFlak.id] ={
    reactionsPerTurn = 4,
    killMunition = 4,-- if plane killed, do 4 damage to each munition
    reactInsideCity=true,
    low = {
        {
            targetTypes = reactionGroups.strategicBombers,
            maxDistance = 2,
            hitChance = .8,
            hitChanceCloud = .4,
            damageSchedule = gen.makeThresholdTable({[0]=9,[.05]=4,[.1]=3,[.5]=2}),
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.alliedFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },-- reactionDetail 2

    },
    climb = {
        {
            targetTypes = reactionGroups.strategicBombers,
            maxDistance = 2,
            hitChance = 0,
            hitChanceCloud = .4,
            shooterTechMod = {{techAliases.ProximityFuses,1},},
            shooterTechCloud = {{techAliases.ProximityFuses,.6},},
            damageSchedule = gen.makeThresholdTable({[0]=9,[.05]=7,[.1]=6,[.5]=5}),
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.alliedFighters,
            maxDistance = 2,
            hitChance = {[1]=1,[2]=.4},
            hitChanceCloud = {[1]=.5,[2]=.2},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },-- reactionDetail 2

    },
    --]]
    groundToNight = {
        {
            targetTypes = reactionGroups.strategicBombers,
            maxDistance = 2,
            hitChance = .2,
            hitChanceCloud = .1,
            damageSchedule = gen.makeThresholdTable({[0]=9,[.05]=4,[.1]=2,[.5]=1}),
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },--reactionDetail 1
        {
            targetTypes = reactionGroups.alliedFighters,
            maxDistance = 2,
            hitChance = .2,
            hitChanceCloud = .1,
            shooterTechMod = {},
            damageSchedule = gen.makeThresholdTable({[0]=6,[0.1]=3,[0.5]=1,}),
            forbiddenShooterTerrain = {[1]=true,[2]=true,[3]=true,[5]=true,[10]=true}
        },-- reactionDetail 2

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




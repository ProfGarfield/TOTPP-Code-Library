local unitKilledEvents = {}

-- This will only run when a unit is killed in combat (i.e. not when an event
-- 'kills' a unit)
-- note that if the aggressor loses, aggressor.location will not work
--
function unitKilledEvents.unitKilledInCombat(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetSatus)

end


-- This will run any time a unit is killed, either in combat or by events
--
function unitKilledEvents.unitDefeated(loser,winner,aggressor,victim,loserLocation,winnerVetStatus,loserVetStatus)

    civ.ui.text("Unit Killed context 1 test")
end

-- this happens whenever a unit 'dies', regardless of combat, as long as it is not replaced
function unitKilledEvents.unitDeath(dyingUnit)

end

-- this happens if a unit is deleted (either through combat death, or by some other event,
-- but not if the unit is disbanded)
-- If the unit isn't being replaced, replacingUnit is nil
function unitKilledEvents.unitDeleted(deletedUnit,replacingUnit)

end

return unitKilledEvents


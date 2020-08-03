local param = {}

param.richVillagePlunder = 150
param.currencyPlural = "Drachmae"
param.shipInterceptionDistance = 3 -- distance (in squares) at which a warship can prevent a ship from recharging movement
param.colonySiteUpgradeChance = 1/90 -- chance each colonySite will be upgraded during each afterproduction phase.
param.upgradeColonySitesOnAITurns = false -- determines if colony sites will have a chance to upgrade on AI turns
param.strategosAttack = 0.2 -- immediately remove this fraction of the defender's hp if a strategos is in the same square as the attacker
param.strategosDefense = 2 -- if the defending unit is at risk of being killed in the next round of combat, and there is a strategos in the square, multiply the unit's firepower by this amount, and do that damage to the attacker
param.wonderOwnershipThreshold = 0.25 -- If a human player has at least this fraction of the total wonders constructed in the game (except Eureka Moment), he can't build the master builder improvement (and, so can't construct any more wonders)
param.techProliferationChance = 1/14 -- chance a tribe with all the prerequisite techs will receive a tech that is known by other tribes, times the number of tribes that know the tech, so if 3 tribes have the tech, chance to receive is 3/14
param.pirateChanceBase = -0.02 -- base chance a pirate will appear when a ship recharges movement while having a pirate enticing cargo on the same square
-- negative means that the chance must be incremented before pirates start appearing
param.pirateChanceIncrement = 0.01 -- with each ship recharge, the chance of a pirate appearing increases by this much (until a pirate does appear, then the chance is reset
param.yearIncrement = 5 -- number of years per turn
param.fortressMercenaries = 2 -- number of mercenary hoplites generated when a full health fortress is attacked
param.strategosLife = 8 -- this is the number of turns a strategos will live
return param

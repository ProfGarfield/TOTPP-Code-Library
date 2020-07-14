local param = {}

param.richVillagePlunder = 150
param.currencyPlural = "Drachmae"
param.shipInterceptionDistance = 3 -- distance (in squares) at which a warship can prevent a ship from recharging movement
param.colonySiteUpgradeChance = 1/90 -- chance each colonySite will be upgraded during each afterproduction phase.
param.strategosAttack = 0.2 -- immediately remove this fraction of the defender's hp if a strategos is in the same square as the attacker
param.strategosDefense = 2 -- if the defending unit is at risk of being killed in the next round of combat, and there is a strategos in the square, multiply the unit's firepower by this amount, and do that damage to the attacker
param.wonderOwnershipThreshold = 0.25 -- If a human player has at least this fraction of the total wonders constructed in the game (except Eureka Moment), he can't build the master builder improvement (and, so can't construct any more wonders)
param.techProliferationChance = 1/7 -- chance a tribe with all the prerequisite techs will receive a tech that is known by other tribes, times the number of tribes that know the tech, so if 3 tribes have the tech, chance to receive is 3/7
return param

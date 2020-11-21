local munitions = require("munitions")

local munitionSettings = {}

local primaryAttackTable = {}


local secondaryAttackTable = {}





local function primaryAttack(generatingUnit)
    return munitions.spawnUnit(generatingUnit,primaryAttackTable,gen.getActivationFunction())
end
munitionSettings.primaryAttack = primaryAttack

local function secondaryAttack(generatingUnit)
    return munitions.spawnUnit(generatingUnit,primaryAttackTable,gen.getActivationFunction())
end
munitionSettings.secondaryAttack = secondaryAttack

local function activationReArm(unit)
    return munitions.activationReArm(unit,primaryAttackTable,secondaryAttackTable)
end
munitionSettings.activationReArm = activationReArm

local function afterProductionReArm()
    munitions.afterProductionReArm(primaryAttackTable,secondaryAttackTable)
end
munitionSettings.afterProductionReArm = afterProductionReArm

local function payloadRestrictionCheck(carryingUnit)
    munitions.payloadRestrictionCheck(carryingUnit,primaryAttackTable)
    munitions.payloadRestrictionCheck(carryingUnit,secondaryAttackTable)
end
munitionSettings.payloadRestrictionCheck = payloadRestrictionCheck

local function onProdPayloadRestrictionCheck(carryingUnit)
    munitions.onProdPayloadRestrictionCheck(carryingUnit,primaryAttackTable)
    munitions.onProdPayloadRestrictionCheck(carryingUnit,secondaryAttackTable)
end
munitionSettings.onProdPayloadRestrictionCheck = onProdPayloadRestrictionCheck

return munitionSettings

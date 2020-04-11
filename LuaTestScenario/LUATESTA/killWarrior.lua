flag = require "flags"

flag.define("warriorKilled",false,"killWarrior.lua")

local function legionMessage(loser)
    if loser.type.id ~= 5 then
        return
    end
    if not flag.value("warriorKilled","killWarrior.lua") then
        civ.ui.text("First Legion Killed!")
        flag.setTrue("warriorKilled","killWarrior.lua")
    end
end

return {
    legionMessage = legionMessage,
}

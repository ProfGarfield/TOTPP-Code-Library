local legacy = require("legacyEventEngine")
local negotiationSettings = {}
function negotiationSettings.negotiation(talker,listener)
    legacy.doNegotiationEvents(talker,listener)
    return legacy.canNegotiate(talker,listener)
    --return true
end

return negotiationSettings

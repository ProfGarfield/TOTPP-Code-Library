local gen = require("generalLibrary")
local geographyTable = {}
local polygon = {}

local function makeDayRegion(polygonTable)
    local function newRegion(tile)
        return (tile.z ~= 2) and gen.inPolygon(tile,polygonTable)
    end
    return newRegion
end

local function makeNightRegion(polygonTable)
    local function newRegion(tile)
        return (tile.z==2) and gen.inPolygon(tile,polygonTable)
    end
    return newRegion
end

polygon = {{0,0},{98,0},{98,14},{76,20},{61,31},{36,48},{0,48},} --North Atlantic Approach
geographyTable["North Atlantic Approach (Day)"] = makeDayRegion(polygon)
geographyTable["North Atlantic Approach (Night)"] = makeNightRegion(polygon)
polygon = {{0,50},{46,50},{46,94},{0,94},} -- Mid Atlantic Approach
geographyTable["Mid Atlantic Approach (Day)"] = makeDayRegion(polygon)
geographyTable["Mid Atlantic Approach (Night)"] = makeNightRegion(polygon)
polygon = {{0,96},{46,96},{46,144},{0,144},} -- South Atlantic Approach
geographyTable["South Atlantic Approach (Day)"] = makeDayRegion(polygon)
geographyTable["South Atlantic Approach (Night)"] = makeNightRegion(polygon)
polygon = {{47,95},{47,145},{113,145},{123,135},{126,126},{123,109},{108,106},{97,101},{82,96},} --Bay of Biscay
geographyTable["Bay of Biscay (Day)"] = makeDayRegion(polygon)
geographyTable["Bay of Biscay (Night)"] = makeNightRegion(polygon)
polygon = {{47,91},{83,91},{83,47},{47,49},} --Celtic Sea
geographyTable["Celtic Sea (Day)"] = makeDayRegion(polygon)
geographyTable["Celtic Sea (Night)"] = makeNightRegion(polygon)
polygon = {{84,72},{84,90},{118,92},{121,95},{131,93},{137,93},{138,82},{147,83},{147,89},{162,90},{165,85},{193,81},{192,74},{186,76},{166,76},{157,75},{142,74},{118,74},} -- English Channel
geographyTable["English Channel (Day)"] = makeDayRegion(polygon)
geographyTable["English Channel (Night)"] = makeNightRegion(polygon)
polygon = {{84,68},{88,70},{94,70},{102,66},{110,66},{117,65},{127,65},{122,64},{117,63},{111,59},{103,57},{93,59},} --Bristol Channel
geographyTable["Bristol Channel (Day)"] = makeDayRegion(polygon)
geographyTable["Bristol Channel (Night)"] = makeNightRegion(polygon)
polygon = {{93,55},{103,55},{103,53},{105,51},{113,51},{123,47},{123,41},{126,40},{139,41},{145,35},{144,26},{129,23},{116,18},{116,26},{107,29},{102,36},{93,47},} --Irish Sea
geographyTable["Irish Sea (Day)"] = makeDayRegion(polygon)
geographyTable["Irish Sea (Night)"] = makeNightRegion(polygon)
polygon = {{194,70},{201,75},{211,69},{210,50},{204,30},{192,12},{172,22},{181,35},{186,44},{190,46},{191,51},{192,54},{195,55},{198,56},{202,58},{202,64},{198,66},} -- Dogger Bank
geographyTable["Dogger Bank (Day)"] = makeDayRegion(polygon)
geographyTable["Dogger Bank (Night)"] = makeNightRegion(polygon)
polygon = {{173,19},{170,16},{166,12},{168,6},{174,0},{185,1},{191,1},{192,14},{185,19},} -- Coast of Scotland
geographyTable["Coast of Scotland (Day)"] = makeDayRegion(polygon)
geographyTable["Coast of Scotland (Night)"] = makeNightRegion(polygon)
polygon = {{193,1},{196,14},{201,31},{211,39},{227,43},{243,23},{259,19},{263,1},{222,0},} -- North Sea
geographyTable["North Sea (Day)"] = makeDayRegion(polygon)
geographyTable["North Sea (Night)"] = makeNightRegion(polygon)
polygon = {{218,76},{218,58},{236,40},{253,29},{269,39},{272,56},{253,59},{241,59},{231,69},} -- Coast of Holland
geographyTable["Coast of Holland (Day)"] = makeDayRegion(polygon)
geographyTable["Coast of Holland (Night)"] = makeNightRegion(polygon)
polygon = {{274,56},{271,37},{269,19},{281,3},{298,26},{301,39},{301,53},{288,54},} -- Heligoland Bight
geographyTable["Heligoland Bight (Day)"] = makeDayRegion(polygon)
geographyTable["Heligoland Bight (Night)"] = makeNightRegion(polygon)
polygon = {{300,24},{299,7},{316,2},{332,0},{347,5},{350,16},{337,17},{333,11},{327,11},{322,14},{315,15},{308,16},} -- Skagerrak
geographyTable["Skagerrak (Day)"] = makeDayRegion(polygon)
geographyTable["Skagerrak (Night)"] = makeNightRegion(polygon)
polygon = {{332,20},{350,16},{362,28},{359,33},{360,50},{336,52},} -- Kattegat
geographyTable["Kattegat (Day)"] = makeDayRegion(polygon)
geographyTable["Kattegat (Night)"] = makeNightRegion(polygon)
polygon = {{362,42},{372,40},{376,40},{379,41},{382,40},{385,37},{390,34},{405,35},{406,52},{384,56},{368,54},{360,52},} -- Baltic Sea
geographyTable["Baltic Sea (Day)"] = makeDayRegion(polygon)
geographyTable["Baltic Sea (Night)"] = makeNightRegion(polygon)
polygon = {{43,39},{46,48},{66,48},{89,47},{103,33},{115,25},{113,17},{104,14},{98,12},{84,12},{74,20},{65,17},{56,16},{51,23},{48,34},} --Ireland
geographyTable["Ireland (Day)"] = makeDayRegion(polygon)
geographyTable["Ireland (Night)"] = makeNightRegion(polygon)
polygon = {{123,1},{125,23},{137,25},{150,26},{161,23},{171,19},{166,14},{169,7},{177,3},{175,1},{158,0},{135,1},{128,6},} --Scotland
geographyTable["Scotland (Day)"] = makeDayRegion(polygon)
geographyTable["Scotland (Night)"] = makeNightRegion(polygon)
polygon = {{143,27},{154,28},{168,22},{171,23},{179,35},{182,44},{169,47},{161,51},{151,51},{141,49},{138,44},{141,41},{144,38},} --Northern England
geographyTable["Northern England (Day)"] = makeDayRegion(polygon)
geographyTable["Northern England (Night)"] = makeNightRegion(polygon)
polygon = {{137,51},{138,62},{134,66},{125,67},{112,66},{105,67},{96,70},{90,72},{96,74},{107,73},{116,74},{122,72},{135,73},{147,73},{153,75},{158,74},{167,75},{176,76},{190,74},{201,63},{199,57},{191,55},{187,49},{179,47},{172,46},{168,52},{158,54},{147,53},} -- Southern England
geographyTable["Southern England (Day)"] = makeDayRegion(polygon)
geographyTable["Southern England (Night)"] = makeNightRegion(polygon)
polygon = {{136,44},{136,62},{132,64},{123,63},{116,60},{109,57},{104,54},{110,52},{116,52},{118,44},{122,40},} --Wales
geographyTable["Wales (Day)"] = makeDayRegion(polygon)
geographyTable["Wales (Night)"] = makeNightRegion(polygon)
polygon = {{0,134},{12,136},{24,138},{33,139},{38,140},{44,144},{49,145},{33,145},{11,145},{0,144},} -- Spain
geographyTable["Spain (Day)"] = makeDayRegion(polygon)
geographyTable["Spain (Night)"] = makeNightRegion(polygon)
polygon = {{86,92},{94,90},{103,91},{119,93},{131,95},{136,96},{137,109},{124,106},{115,107},{105,105},{95,101},{86,98},} -- Brittany
geographyTable["Brittany (Day)"] = makeDayRegion(polygon)
geographyTable["Brittany (Night)"] = makeNightRegion(polygon)
polygon = {{120,112},{130,110},{139,111},{147,113},{154,116},{155,145},{139,145},{114,144},{117,117},} --Western France
geographyTable["Western France (Day)"] = makeDayRegion(polygon)
geographyTable["Western France (Night)"] = makeNightRegion(polygon)
polygon = {{138,84},{140,108},{152,112},{169,111},{185,109},{184,88},{164,88},{145,85},} -- Normandy
geographyTable["Normandy (Day)"] = makeDayRegion(polygon)
geographyTable["Normandy (Night)"] = makeNightRegion(polygon)
polygon = {{160,116},{163,145},{225,145},{223,107},{197,109},{177,113},} -- Southern France
geographyTable["Southern France (Day)"] = makeDayRegion(polygon)
geographyTable["Southern France (Night)"] = makeNightRegion(polygon)

polygon = {{185,87},{191,89},{196,90},{201,97},{202,108},{194,110},{186,102},} -- Paris
geographyTable["Paris (Day)"] = makeDayRegion(polygon)
geographyTable["Paris (Night)"] = makeNightRegion(polygon)
polygon = {{191,87},{198,90},{202,96},{212,92},{215,81},{211,77},{198,76},{193,77},} -- Pas de Calais
geographyTable["Pas de Calais (Day)"] = makeDayRegion(polygon)
geographyTable["Pas de Calais (Night)"] = makeNightRegion(polygon)
polygon = {{217,77},{228,76},{240,74},{240,74},{259,85},{265,101},{257,119},{241,119},{229,123},{229,101},} --Belgium
geographyTable["Belgium (Day)"] = makeDayRegion(polygon)
geographyTable["Belgium (Night)"] = makeNightRegion(polygon)
polygon = {{230,72},{242,60},{254,56},{265,55},{261,71},{247,73},{237,73},} -- Holland
geographyTable["Holland (Day)"] = makeDayRegion(polygon)
geographyTable["Holland (Night)"] = makeNightRegion(polygon)
polygon = {{262,72},{274,66},{285,71},{286,92},{276,94},} -- The Ruhr
geographyTable["The Ruhr (Day)"] = makeDayRegion(polygon)
geographyTable["The Ruhr (Night)"] = makeNightRegion(polygon)
polygon = {{276,96},{269,117},{268,124},{280,124},{295,123},{310,118},{309,99},{296,90},} --Southwest Germany
geographyTable["Southwest Germany (Day)"] = makeDayRegion(polygon)
geographyTable["Southwest Germany (Night)"] = makeNightRegion(polygon)
polygon = {{311,97},{311,145},{339,145},{341,127},{350,118},{346,104},{328,104},} -- Bavaria
geographyTable["Bavaria (Day)"] = makeDayRegion(polygon)
geographyTable["Bavaria (Night)"] = makeNightRegion(polygon)
polygon = {{352,116},{370,118},{392,120},{407,117},{407,145},{373,145},{353,145},} -- Austria
geographyTable["Austria (Day)"] = makeDayRegion(polygon)
geographyTable["Austria (Night)"] = makeNightRegion(polygon)
polygon = {{369,95},{369,117},{388,118},{399,115},{406,108},{391,101},{377,97},} -- Czechoslovakia
geographyTable["Czechoslovakia (Day)"] = makeDayRegion(polygon)
geographyTable["Czechoslovakia (Night)"] = makeNightRegion(polygon)
polygon = {{377,61},{379,97},{396,102},{407,101},{406,78},{407,55},} -- Poland
geographyTable["Poland (Day)"] = makeDayRegion(polygon)
geographyTable["Poland (Night)"] = makeNightRegion(polygon)
polygon = {{375,57},{365,49},{356,52},{354,72},{365,83},{375,77},} -- Berlin
geographyTable["Berlin (Day)"] = makeDayRegion(polygon)
geographyTable["Berlin (Night)"] = makeNightRegion(polygon)
polygon = {{371,85},{371,91},{366,94},{352,96},{337,97},{338,84},{353,81},} -- Saxony
geographyTable["Saxony (Day)"] = makeDayRegion(polygon)
geographyTable["Saxony (Night)"] = makeNightRegion(polygon)
polygon = {{269,59},{270,68},{278,68},{289,73},{298,82},{305,85},{318,78},{335,79},{346,74},{348,56},{332,52},{318,50},{299,55},{281,57},} -- Northern Germany
geographyTable["Northern Germany (Day)"] = makeDayRegion(polygon)
geographyTable["Northern Germany (Night)"] = makeNightRegion(polygon)
polygon = {{304,48},{298,42},{301,23},{320,16},{332,12},{339,27},{335,41},{323,47},} -- Denmark 
geographyTable["Denmark  (Day)"] = makeDayRegion(polygon)
geographyTable["Denmark  (Night)"] = makeNightRegion(polygon)

geographyTable["Straits of Dover"] = {192,76}
geographyTable["Scotland"] = {154,8}
geographyTable["Northern Ireland"] = {92,12}
geographyTable["Switzerland"] = {268,138}
geographyTable["The Rhein"] = {264,74}
geographyTable["Spain"] = {18,144}
geographyTable["The Thames"] = {162,68}
geographyTable["The Beaches of Normandy"] = {156,92}
geographyTable["The Elbe"] = {332,64}
geographyTable["The Danube"] = {354,116}
geographyTable["The Oder"] = {389,75}
geographyTable["Oresund"] = {358,36}
geographyTable["Denmark"] = {312,32}
geographyTable["The Low Countries"] = {239,71}
geographyTable["The Border with Vichy France"] = {192,40}
geographyTable["St. George's Channel"] = {97,49}
geographyTable["Muir Eireann"] = {103,37}
geographyTable["Southwest Ireland"] = {39,43}
geographyTable["The Isle of Man"] = {128,30}
geographyTable["Guernsey"] = {125,85}
geographyTable["Mouth of the Garonne River"] = {129,137}
geographyTable["Norway"] = {297,3}
geographyTable["The Alps"] = {331,41}
geographyTable["The Cotentin Peninsula"] = {142,88}
geographyTable["Copenhagen"] = {352,36}

--geographyTable["The skies above London"] = ({172,68,1}, {172,68,2}}


return geographyTable

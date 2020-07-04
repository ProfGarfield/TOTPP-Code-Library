local improvementUpkeep = {

[0]= 0,-- 0 Nothing Nothing
[1]= 0,-- 1 Palace Headquarters
[2]= 1,-- 2 Barracks NOT USED
[3]= 0,-- 3 Granary Red Army
[4]= 1,-- 4 Temple Civilian Population I
[5]= 1,-- 5 MarketPlace Fuel Refinery I
[6]= 1,-- 6 Library Aircraft Factory I
[7]= 2,-- 7 Courthouse Quartermaster
[8]= 0,-- 8 City Walls  City I
[9]= 0,-- 9 Aqueduct  City II
[10]= 1,-- 10 Bank Fuel Refinery II
[11]= 1,-- 11 Cathedral Civilian Population II
[12]= 1,-- 12 University Aircraft Factory II
[13]=  20,-- 13 Mass Transit 00000101 Shipping Losses
[14]= 1,-- 14 Colosseum Civilian Population III
[15]= 1,-- 15 Factory Industry I
[16]= 2,-- 16 Manufacturing Plant Industry II
[17]= 3,-- 17 SDI Defense Airbase
[18]= 0,-- 18 Recycling Center 15th Air Force
[19]= 3,-- 19 Power Plant OLD Industry III
[20]= 1,-- 20 Hydro Plant NOT USED
[21]= 1,-- 21 Nuclear Plant NOT USED
[22]= 1,-- 22 Stock Exchange Fuel Refinery III
[23]= 6,-- 23 Sewer System  City III
[24]= 1,-- 24 Supermarket Rationing
[25]= 1,-- 25 Superhighways Railyards
[26]= 1,-- 26 Research Lab Aircraft Factory III
[27]= 6,-- 27 SAM Missile Battery Flak Battery
[28]= 1,-- 28 Coastal Fortress NOT USED
[29]= 3,-- 29 Solar Plant Industry III
[30]= 1,-- 30 Harbor Docks
[31]= 1,-- 31 Offshore Platform NOT USED
[32]= 63,-- 32 Airport Jagdfliegerschule
[33]= 3,-- 33 Police Station SAVE
[34]= 1,-- 34 Port Facility Military Port
[35]= 1,-- 35 Transporter NOT USED
}

local function computeCosts(tribe)
    local costSoFar = 0
    for city in civ.iterateCities() do
        if city.owner == tribe then
            for i=0,35 do
                if city:hasImprovement(civ.getImprovement(i)) then
                    costSoFar = costSoFar+improvementUpkeep[i]
                end
            end
        end
    end
    return costSoFar
end

return {
    computeCosts = computeCosts,
}


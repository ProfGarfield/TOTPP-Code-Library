local fileName = civ.getToTDir().."\\OTRData.csv"
local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

-- set value for id for tribe to true if you want to include that tribe in the output
local includeTribe = {[0]=false,true,true,false,false,false,false,false}

-- appends a line to the csv file 
local function appendCSVLine(file,table)
    local lineToWrite = "\n"
    for i=1,(#table) do
        table[i] = table[i] or ""
        lineToWrite = lineToWrite..tostring(table[i])..","
    end
    io.output(file)
    io.write(lineToWrite)
end 

-- if the file doesn't exist yet, then we want to do something different than usual (i.e. initialize the csv file)
if not file_exists(fileName) then
    -- write first lines of file
    local csvFile = io.open(fileName,"a+")
    local writeTableLine1 = {}
    local writeTableLine2 = {}
    writeTableLine1[1] = "Turn"
    writeTableLine1[2] = "Active Tribe"
    writeTableLine2[1] = ""
    writeTableLine2[2] = ""
    local writeTableIndex = 3
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        for i=0,127 do
            if civ.getUnitType(i) then
                writeTableLine1[writeTableIndex] = civ.getUnitType(i).name
                writeTableLine2[writeTableIndex] = civ.getTribe(ownerTribe).name
                writeTableIndex=writeTableIndex+1
            end
        end
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = "Cities"
        writeTableLine2[writeTableIndex] = civ.getTribe(ownerTribe).name
        writeTableIndex=writeTableIndex+1
        for i=0,40 do
            if civ.getImprovement(i) then
                writeTableLine1[writeTableIndex] = civ.getImprovement(i).name
                writeTableLine2[writeTableIndex] = civ.getTribe(ownerTribe).name
                writeTableIndex=writeTableIndex+1
            end
        end
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = "Treasury"
        writeTableLine2[writeTableIndex] = civ.getTribe(ownerTribe).name
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = "Tax Rate"
        writeTableLine2[writeTableIndex] = civ.getTribe(ownerTribe).name
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = "Technologies"
        writeTableLine2[writeTableIndex] = civ.getTribe(ownerTribe).name
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = "Research Cost"
        writeTableLine2[writeTableIndex] = civ.getTribe(ownerTribe).name
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = "Research Progress"
        writeTableLine2[writeTableIndex] = civ.getTribe(ownerTribe).name
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = "Science Rate"
        writeTableLine2[writeTableIndex] = civ.getTribe(ownerTribe).name
        writeTableIndex=writeTableIndex+1
      end
    end
    appendCSVLine(csvFile,writeTableLine1)
    appendCSVLine(csvFile,writeTableLine2)
    io.close(csvFile)
    civ.ui.text(fileName.." initialized.")
end


local function countUnits(unitTypeID,tribeID)
    local count =0
    for unit in civ.iterateUnits() do
        if civ.getTile(unit.location.x,unit.location.y,unit.location.z) and unit.type.id == unitTypeID
            and unit.owner.id == tribeID then
            count = count+1
        end
    end
    return count
end

local function countCities(tribeID)
    local count = 0
    for city in civ.iterateCities() do
        if city.owner.id == tribeID then
            count = count+1
        end
    end
    return count
end

local function countCityImprovements(improvementID,tribeID)
    local count = 0
    if not civ.getImprovement(improvementID) then
        return count
    end
    for city in civ.iterateCities() do
        if city.owner.id == tribeID and city:hasImprovement(civ.getImprovement(improvementID)) then
            count = count+1
        end
    end
    return count
end

-- after initializing (if necessary), we want to do our ordinary tasks
local file = io.open(fileName,"a+")
    local csvFile = io.open(fileName,"a+")
    local writeTableLine1 = {}
    writeTableLine1[1] = tostring(civ.getTurn())
    writeTableLine1[2] = tostring(civ.getCurrentTribe().name)
    local writeTableIndex = 3
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        for i=0,127 do
            if civ.getUnitType(i) then
                writeTableLine1[writeTableIndex] = countUnits(i,ownerTribe)
                writeTableIndex=writeTableIndex+1
            end
        end
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = countCities(ownerTribe)
        writeTableIndex=writeTableIndex+1
        for i=0,39 do
            if civ.getImprovement(i) then
                writeTableLine1[writeTableIndex] = countCityImprovements(i,ownerTribe)
                writeTableIndex=writeTableIndex+1
            end
        end
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = civ.getTribe(ownerTribe).money
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = civ.getTribe(ownerTribe).taxRate
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = civ.getTribe(ownerTribe).numTechs
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = civ.getTribe(ownerTribe).researchCost
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = civ.getTribe(ownerTribe).researchProgress
        writeTableIndex=writeTableIndex+1
      end
    end
    for ownerTribe=0,7 do
      if includeTribe[ownerTribe] then
        writeTableLine1[writeTableIndex] = civ.getTribe(ownerTribe).scienceRate
        writeTableIndex=writeTableIndex+1
      end
    end
    appendCSVLine(csvFile,writeTableLine1)
    io.close(csvFile)
    civ.ui.text("Data added to "..fileName.." for turn "..tostring(civ.getTurn()).." and active tribe "..tostring(civ.getCurrentTribe().name)..".")

io.close(file)

return {}

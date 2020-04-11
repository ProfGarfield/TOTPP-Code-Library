local CHAR_PIXEL_WIDTH = require("characterTable")
local civlua = require("civlua")
local func = require("functions")

civ.ui.text("This script gathers information about the size of the characters displayed in"..
" Civilization II text boxes on your system.  With this information, the \"text\" module "..
"can improve how text is displayed, most notably by allowing the formation of columns of text.")

civ.ui.text("This module will help you collect information about the font your system provides to "..
"Civilization II for text boxes.  It will also write for you a new file \"characterTable.lua\" which "..
"you can use to replace the existing file with that name, and improve the formatting of text in "..
"scenarios that use lua.")

civ.ui.text("Doing this is optional.  You can also save a partly modified file \"characterTable.lua\""..
"and come back to it later.")
local function gcd(a,b)
    if b ~= 0 then
        return gcd(b, a % b)
    else
        return math.abs(a)
    end
end

local function tableGCD(table)
    local gcdSoFar = nil
    for index,value in pairs(table) do
        if type(value) == "number" then
            gcdSoFar = gcdSoFar or value
            gcdSoFar = gcd(gcdSoFar,value)
        end
    end
    return gcdSoFar
end

-- CHAR_PIXEL_WIDTH["StartAtThisChar"] is the character to start at
local function closeMenu(charNum,candidateSize,changeIncrement)
    CHAR_PIXEL_WIDTH["StartAtThisChar"]=nil
    local charGCD = tableGCD(CHAR_PIXEL_WIDTH)
    for i,val in pairs(CHAR_PIXEL_WIDTH) do
        CHAR_PIXEL_WIDTH[i] = val//charGCD
    end
    if charNum <= 255 then
        CHAR_PIXEL_WIDTH["StartAtThisChar"]=charNum-1
    end
    print(civlua.serialize(CHAR_PIXEL_WIDTH))
end

local function checkSize(charNum,candidateSize,changeIncrement)
    if charNum > 255 then
        return closeMenu(charNum,candidateSize,changeIncrement)
    end
    if not(CHAR_PIXEL_WIDTH[charNum]) then
        return checkSize(charNum+1,CHAR_PIXEL_WIDTH[charNum+1])
    end
    local spaceSize = CHAR_PIXEL_WIDTH[32]
    local greatestCommonDivisor = gcd(spaceSize,candidateSize)
    local numChar = spaceSize//greatestCommonDivisor
    local numSpace = candidateSize//greatestCommonDivisor
    while math.min(numChar,numSpace) < 6 do
        numSpace = numSpace+1
        numChar = numChar+1
    end
    local char = string.char(charNum)
    local window = civ.ui.createDialog()
    local spaceString = "\n^|"
    for i=1,numSpace do
        spaceString = spaceString.." "
    end
    spaceString = spaceString.."|"
    local charString = "\n^|"
    for i=1,numChar do
        charString = charString..char
        if charNum == 38 then
            -- &, must have 2nd & to display
            charString = charString..char
        end
    end
    charString=charString.."|"
    window.title=tostring(charNum)
    window:addText(func.splitlines(spaceString))
    window:addText(func.splitlines(charString))
    window:addOption("First line is too short.",1)
    window:addOption("First line is too long.",2)
    window:addOption("Lines are same length.",3)
    window:addOption("Previous character.",4)
    window:addOption("Shorten the change increment.",5)
    window:addOption("Lengthen the change increment.",6)
    window:addOption("Reset the change increment.",7)
    window:addOption("Quit.",8)
    local choice = window:show()
    local changeIncrement = changeIncrement or greatestCommonDivisor
    if choice == 1 then
        return checkSize(charNum,candidateSize+changeIncrement,changeIncrement)
    elseif choice == 2 then
        return checkSize(charNum,candidateSize-changeIncrement,changeIncrement)
    elseif choice == 3 then
        return checkSize(charNum+1,CHAR_PIXEL_WIDTH[charNum+1],changeIncrement)
    elseif choice == 4 then
        return checkSize(charNum-1,CHAR_PIXEL_WIDTH[charNum-1],changeIncrement)
    elseif choice == 5 then
            print(changeIncrement-1)
        if changeIncrement == 1 then
            -- set width of space to 60, so there are a lot of factors
            -- adjust all other entries accordingly
            CHAR_PIXEL_WIDTH["StartAtThisChar"] = nil
            local multiplier = 60//(CHAR_PIXEL_WIDTH[32])
            for index,val in pairs(CHAR_PIXEL_WIDTH) do
                CHAR_PIXEL_WIDTH[index] = val*multiplier
            end
            return checkSize(charNum,CHAR_PIXEL_WIDTH[charNum],multiplier-1)
        else 
            return checkSize(charNum,CHAR_PIXEL_WIDTH[charNum],changeIncrement-1)
        end
    elseif choice == 6 then
        print(changeIncrement+1)
        return checkSize(charNum,CHAR_PIXEL_WIDTH[charNum], changeIncrement +1)
    elseif choice == 7 then
        return checkSize(charNum,CHAR_PIXEL_WIDTH[charNum],tableGCD(CHAR_PIXEL_WIDTH))
    elseif choice == 8 then
       return closeMenu(charNum,candidateSize,changeIncrement)
    end
end

local startChar = CHAR_PIXEL_WIDTH["StartAtThisChar"] or 32
checkSize(startChar,CHAR_PIXEL_WIDTH[startChar],tableGCD(CHAR_PIXEL_WIDTH))

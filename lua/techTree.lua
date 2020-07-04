text = require("text")

local techNameMaxLength = 19
local aiValueLength = 7
local lengthBeforeSemicolon = 45

local techKey = {}
techKey[0]  = "AFl"
techKey[1]  = "Alp"
techKey[2]  = "Amp"
techKey[3]  = "Ast"
techKey[4]  = "Ato"
techKey[5]  = "Aut"
techKey[6]  = "Ban"
techKey[7]  = "Bri"
techKey[8]  = "Bro"
techKey[9]  = "Cer"
techKey[10] = "Che"
techKey[11] = "Chi"
techKey[12] = "CoL"
techKey[13] = "CA"
techKey[14] = "Cmb"
techKey[15] = "Cmn"
techKey[16] = "Cmp"
techKey[17] = "Csc"
techKey[18] = "Cst"
techKey[19] = "Cor"
techKey[20] = "Cur"
techKey[21] = "Dem"
techKey[22] = "Eco"
techKey[23] = "E1"
techKey[24] = "E2"
techKey[25] = "Eng"
techKey[26] = "Env"
techKey[27] = "Esp"
techKey[28] = "Exp"
techKey[29] = "Feu"
techKey[30] = "Fli"
techKey[31] = "Fun"
techKey[32] = "FP"
techKey[33] = "Gen"
techKey[34] = "Gue"
techKey[35] = "Gun"
techKey[36] = "Hor"
techKey[37] = "Ind"
techKey[38] = "Inv"
techKey[39] = "Iro"
techKey[40] = "Lab"
techKey[41] = "Las"
techKey[42] = "Ldr"
techKey[43] = "Lit"
techKey[44] = "Too"
techKey[45] = "Mag"
techKey[46] = "Map"
techKey[47] = "Mas"
techKey[48] = "MP"
techKey[49] = "Mat"
techKey[50] = "Med"
techKey[51] = "Met"
techKey[52] = "Min"
techKey[53] = "Mob"
techKey[54] = "Mon"
techKey[55] = "MT"
techKey[56] = "Mys"
techKey[57] = "Nav"
techKey[58] = "NF"
techKey[59] = "NP"
techKey[60] = "Phi"
techKey[61] = "Phy"
techKey[62] = "Pla"
techKey[63] = "Plu"
techKey[64] = "PT"
techKey[65] = "Pot"
techKey[66] = "Rad"
techKey[67] = "RR"
techKey[68] = "Rec"
techKey[69] = "Ref"
techKey[70] = "Rfg"
techKey[71] = "Rep"
techKey[72] = "Rob"
techKey[73] = "Roc"
techKey[74] = "San"
techKey[75] = "Sea"
techKey[76] = "SFl"
techKey[77] = "Sth"
techKey[78] = "SE"
techKey[79] = "Stl"
techKey[80] = "Sup"
techKey[81] = "Tac"
techKey[82] = "The"
techKey[83] = "ToG"
techKey[84] = "Tra"
techKey[85] = "Uni"
techKey[86] = "War"
techKey[87] = "Whe"
techKey[88] = "Wri"
techKey[89] = "..."
techKey[90] = "U1"
techKey[91] = "U2"
techKey[92] = "U3"
techKey[93] = "X1"
techKey[94] = "X2"
techKey[95] = "X3"
techKey[96] = "X4"
techKey[97] = "X5"
techKey[98] = "X6"
techKey[99] = "X7"

local function spaces(int)
    local spaces = ""
    for i=1,int do
        spaces = spaces.." "
    end
    return spaces
end

function printTechRules()
    local function getPrereqKey(tech,prereqNum)
        local techPrereq = tech["prereq"..tostring(prereqNum)]
        if techPrereq then
            return techKey[techPrereq.id]
        else
            return "nil"
        end
    end
    local function getModifier(rawModifier)
        if rawModifier <= 127 then
            return tostring(rawModifier)
        else
            return tostring(rawModifier-256)
        end
    end
    local outputText = "@CIVILIZE\n"
    for i=0,99 do
        local currentTech = civ.getTech(i)
        local newLine = currentTech.name..","
        newLine = newLine..spaces(techNameMaxLength+1-newLine:len())
        local techMod = getModifier(currentTech.modifier)
        local nextPart = tostring(currentTech.aiValue)..","..spaces(2-techMod:len())..techMod..","
        newLine = newLine..nextPart
        newLine = newLine..spaces(techNameMaxLength+1+aiValueLength-newLine:len())
        nextPart = getPrereqKey(currentTech,1)..","
        nextPart = nextPart..spaces(5-nextPart:len())
        nextPart = nextPart..getPrereqKey(currentTech,2)..","
        nextPart = nextPart..spaces(10-nextPart:len())
        newLine = newLine..nextPart
        nextPart = tostring(currentTech.epoch)..", "..tostring(currentTech.category)
        newLine = newLine..nextPart
        newLine = newLine..spaces(lengthBeforeSemicolon-newLine:len()).."; "..techKey[i].."\n"
        outputText = outputText..newLine
    end
    print(outputText)
end

function selectTech(menuText,defaultTech,nilOption)
    local menuText = menuText or ""
    local menuList = {}
    local offset = 3
    if defaultTech then
        menuList[1] = defaultTech.name
    end
    for i=0,99 do
        menuList[i+offset] = civ.getTech(i).name
    end
    if nilOption then
        menuList[2] = "\"nil\""
    end
    local choice = text.menu(menuList,menuText,"",true)
    if choice == 0 then
        return false
    elseif choice == 1 then
        return defaultTech
    elseif choice == 2 then
        return nil
    else
        return civ.getTech(choice-offset)
    end
end

function setPrerequisites()
    local techToChange = selectTech("Choose the technology for which you wish to change prerequisites.")
    if not techToChange then
        civ.ui.text("Nothing changed.")
        return
    end
    local prereq1Tech = selectTech("Choose prerequisite 1 for "..techToChange.name..".",techToChange.prereq1,true)
    if prereq1Tech == false then
        civ.ui.text("Nothing changed.")
        return
    end

    local prereq2Tech = selectTech("Choose prerequisite 2 for "..techToChange.name..".",techToChange.prereq2,true)
    if prereq2Tech == false then
        civ.ui.text("Nothing changed.")
        return
    end
    techToChange.prereq1 = prereq1Tech
    techToChange.prereq2 = prereq2Tech
end

print("Tech Tree Utilities Loaded.")

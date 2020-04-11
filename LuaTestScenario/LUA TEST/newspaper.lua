local func = require "functions"

-- A newspaper "article" is a table with the following entries
-- .title = string ==> the "title" of the newspaper article, which will be shown when selecting an article
-- .body = string ==> the "body" of the newspaper article
-- .archived = bool ==> if true, article will only be accessible in archive mode

-- A newspaper is a table of tables of "articles", indexed by integers from 1 without skipping any entries
-- also has entries 
-- .newspaperName so that it doesn't have to be called a "Newspaper" e.g. "Reports"
-- .articleName so that it doesn't have to be called an "article" e.g. "Report"


-- When accessed, the newspaper will show the most recent "article" first,
-- with the option to go to the previous article, or the next article, archive an article,
-- see a list of articles, see a list of articles including archived articles

local function findLastIndex(newspaperTable)
    local lastUsedIndex = 0
    local articleAtNextIndex = true
    while articleAtNextIndex do
        if newspaperTable[lastUsedIndex+1] ~= nil then
            lastUsedIndex = lastUsedIndex+1
        else
            articleAtNextIndex = false
        end
    end 
    return lastUsedIndex
end

local function addToNewspaper(newspaperTable, titleString, bodyString)
    local index = findLastIndex(newspaperTable) + 1
    newspaperTable[index] = { title = titleString, body = bodyString, archieved = false}
end

local function addToTheseNewspapers(tableOfNewspapers, titleString, bodyString)
    for __,newspaperTable in pairs(tableOfNewspapers) do
        addToNewspaper(newspaperTable, titleString, bodyString)
    end
end

-- returns false if no previous unarchived index
local function previousUnarchivedIndex(newspaperTable,articleIndex)
    print("previousUnarchivedIndex called on index "..tostring(articleIndex))
    local index = articleIndex -1
    while index > 0 do
        if newspaperTable[index].archived then
            index = index - 1
        else
            print("returned "..tostring(index))
            return index
        end
    end
    print("retunred false")
    return false
end

-- return false if all subsequent articles are archived
local function nextUnarchivedIndex(newspaperTable, articleIndex)
    
    local index = articleIndex + 1
    while newspaperTable[index] ~= nil do
        if newspaperTable[index].archived then
            index = index + 1
        else
            
            return index
        end
    end
    return false
end

local function displayArticle(newspaperTable, articleIndex,onlyShowNotArchived,articleName,newspaperName) 
    local article = newspaperTable[articleIndex]
    local box = civ.ui.createDialog()
    box.title = article.title
    box:addText(func.splitlines(article.body))
    if onlyShowNotArchived and previousUnarchivedIndex(newspaperTable,articleIndex) then
        box:addOption("Earlier "..articleName,1)
    end
    if not(onlyShowNotArchived) and articleIndex > 1 then
        box:addOption("Earlier "..articleName,1)
    end
    if onlyShowNotArchived and nextUnarchivedIndex(newspaperTable, articleIndex)  then
        box:addOption("Later "..articleName,2)
    end
    if not(onlyShowNotArchived) and newspaperTable[articleIndex+1] ~= nil then
        box:addOption("Later "..articleName,2)
    end
    box:addOption("Menu",0)
    if article.archived then
        --box:addOption("Restore this "..newspaperTable.articleName.." to my "..newspaperTable.newspaperName..".",4)
    else
        --box:addOption("Put this "..newspaperTable.articleName.." into the archives.",4)
    end
    return box:show()
end

local maxOptionsPerPage = 15


local function articlesForNotArchivedMenu(newspaperTable, assocTable)
    assocTable = {}
    local assocIndex = 1
    for i=1,findLastIndex(newspaperTable) do
        if newspaperTable[i].archived == false then
            assocTable[assocIndex] = i
            assocIndex = assocIndex + 1
        end
    end
end
        
local function articleMenuPage(newspaperTable, articleName, newspaperName, notArchivedList, page, maxIndex)
    local pageMaxIndex = maxIndex -(page-1)*maxOptionsPerPage
    local pageMinIndex = math.max(maxIndex -page*maxOptionsPerPage + 1,1)
    local selectionDialog = civ.ui.createDialog()
    selectionDialog.title = "Select "..articleName.." (Page "..tostring(page).." of "..
        tostring(math.ceil(maxIndex/maxOptionsPerPage))..")"
    if pageMinIndex > 1 then
        selectionDialog:addOption("Find older "..articleName, -2)
    end
    if page > 1 then
        selectionDialog:addOption("Find more recent "..articleName,-1)
    end
    for i = pageMaxIndex,pageMinIndex,-1 do
        local choice = notArchivedList[i]
        selectionDialog:addOption(newspaperTable[choice].title,choice)
    end
    selectionDialog:addOption(newspaperName.." Menu",0)
    return selectionDialog:show()
end

-- returns index of the article selected
-- returns 0 to go back to the menu
local function articleMenu(newspaperTable, articleName, newspaperName)
    local notArchivedList = {}
    articlesForNotArchivedMenu(newspaperTable,notArchivedList)
    local lastIndex = findLastIndex(notArchivedList)
    local pages = math.ceil(lastIndex/maxOptionsPerPage)
    local page = 1
    while true do
        selection = articleMenuPage(newspaperTable,articleName,newspaperName,notArchivedList,page,lastIndex)
        if selection == -2 then
            page = page+1
        elseif selection == -1 then
            page = page - 1
        else
            return selection
        end
    end
end   


local function archivedArticleMenuPage(newspaperTable, articleName, newspaperName, page, maxIndex)
    local pageMaxIndex = maxIndex -(page-1)*maxOptionsPerPage
    local pageMinIndex = math.max(maxIndex-page*maxOptionsPerPage+1,1)
    local selectionDialog = civ.ui.createDialog()
    selectionDialog.title = "Select "..articleName.." (Page "..tostring(page).." of "..
        tostring(math.ceil(maxIndex/maxOptionsPerPage))..")"
        if pageMinIndex > 1 then
        selectionDialog:addOption("Find older "..articleName, -2)
    end
    if page > 1 then
        selectionDialog:addOption("Find more recent "..articleName,-1)
    end
    for i=pageMaxIndex,pageMinIndex,-1 do
        selectionDialog:addOption(newspaperTable[i].title,i)
    end
    selectionDialog:addOption(newspaperName.." Menu",0)
    return selectionDialog:show()
end

local function archivedArticleMenu(newspaperTable, articleName, newspaperName)
    local lastIndex = findLastIndex(newspaperTable)
    local pages = math.ceil(lastIndex/maxOptionsPerPage)
    local page = 1
    while true do
        selection = archivedArticleMenuPage(newspaperTable,articleName,newspaperName,page,lastIndex)
        if selection == -2 then
            page = page+1
        elseif selection == -1 then
            page = page - 1
        else
            return selection
        end
    end
end

local function readArticles(newspaperTable, startIndex, onlyShowNotArchived,articleName,newspaperName)
    local toDoCode = 1
    local articleIndex = startIndex
    local loopGuard = 0
    while toDoCode ~=0 and loopGuard <10000 do
        loopGuard = loopGuard+1
        toDoCode = displayArticle(newspaperTable, articleIndex,onlyShowNotArchived,articleName,newspaperName)
        if toDoCode == 1 and onlyShowNotArchived then
            articleIndex = previousUnarchivedIndex(newspaperTable,articleIndex)
        elseif toDoCode == 1 and not(onlyShowNotArchived) then
            articleIndex = articleIndex - 1
        elseif toDoCode == 2 and onlyShowNotArchived then
            articleIndex = nextUnarchivedIndex(newspaperTable,articleIndex)
        elseif toDoCode == 2 and not(onlyShowNotArchived) then
            articleIndex = articleIndex + 1
        end
        if toDoCode == 4 then
            newspaperTable[articleIndex].archived = not(newspaperTable[articleIndex].archived)
        end
    end
    return articleIndex
end
        
local function newspaperMenu(newspaperTable)
    local npName = newspaperTable.newspaperName or "Newspaper"
    local articleName = newspaperTable.articleName or "Article"
    local loopGuard = 0
    while loopGuard < 1000 do
        local npMenuDialog = civ.ui.createDialog()
        npMenuDialog.title = npName.." Menu"
        npMenuDialog:addOption("See most recent "..articleName,1)
        --npMenuDialog:addOption("Select "..articleName.." From List",2)
        --npMenuDialog:addOption("Select Archived "..articleName.." From List",3)
        npMenuDialog:addOption("Close "..npName,4)
        choice = npMenuDialog:show()
        if choice == 1 then
            local mostRecentUnarchivedArticle = previousUnarchivedIndex(newspaperTable,findLastIndex(newspaperTable)+1)
            if mostRecentUnarchivedArticle then
                readArticles(newspaperTable,mostRecentUnarchivedArticle,true,articleName, npName)
            else
                local noArtDialog = civ.ui.createDialog()
                noArtDialog:addText(func.splitlines("Nothing Here.  Check the Archives."))
                noArtDialog:show()
            end
        elseif choice == 2 then
            local aChoice = articleMenu(newspaperTable, articleName, npName)
            if aChoice ~=0 then
                readArticles(newspaperTable,aChoice,true,articleName, npName)
            end
        elseif choice==3 then
            local aChoice = archivedArticleMenu(newspaperTable, articleName,npName)
            if aChoice ~=0 then
                readArticles(newspaperTable,aChoice,false,articleName,npName)
            end
        else
            return
        end
    end
    civ.ui.text(func.splitlines("Either You've made 1000 selections in this menu, or there has been an infinite loop error."))

end


return {newspaperMenu = newspaperMenu,
        addToNewspaper = addToNewspaper,
        addToTheseNewspapers = addToTheseNewspapers,
        }






































    



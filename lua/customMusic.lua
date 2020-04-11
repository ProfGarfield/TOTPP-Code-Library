-- WARNING!!
--
-- This module will overwrite data.  Specifically, it overwrites the data in the Music
-- directory of your Test of Time install directory, in order to change the music that
-- is played.
--
-- Reads the music selection from @PICKMUSICTOT in Game.txt and tries to play that music 
-- instead of the TOT soundtrack.
-- If a double quote (") is the first and/or last character of the line in 
-- @PICKMUSICTOT, the quote will be ignored when trying to find the file name
-- if a line of @PICKMUSICTOT is 
-- "My Custom Theme"
-- This module copies the file _My Custom Theme.mp3 to one of the hard coded names
-- for music in the Test of Time Patch Project
--
-- If _My Custom Theme.mp3 is not in the TOT Music directory, the directory given
-- by customMusicFolderPath (default scenarioDirectory\Music) is checked for _My Custom Theme.mp3 and My Custom Theme.mp3
-- and if either one exists, it is used
-- 

file = require("file")
local originalMusicNames = {
"Funeral March",
"Ode to Joy",
"Crusade",
"Alien",
"Mongol Horde",
"The Apocalypse",
"Jurassic Jungle",
"New World",
"Tolkien",
"Mars Expedition",
"Jules Verne",
"They're Here",
"The Dome",
}

math.randomseed(os.time())


-- customMusicDirectory is scenarioDirectory\Music unless otherwise specified
-- See an example for how to get the scenario directory
-- returns true, so that a scenario maker can tell if custom music is used
-- (the customMusic.lua "replacement" module will have importMusic return false
local function importMusic(scenarioDirectory,customMusicDirectory)
    customMusicDirectory = customMusicDirectory or scenarioDirectory.."\\Music"
    local readingMusicNames = false
    local musicLineNumber = 1
    local musicOptions = 13
    local musicTitles = {}
    for line in io.lines(scenarioDirectory.."\\Game.txt") do
        if musicLineNumber > musicOptions then
            break
        end
        if readingMusicNames and line:sub(1,1) ~= "@" then
            if line:sub(1,1) == "\"" then
                line = line:sub(2)
            end
            if line:sub(-1) == "\"" then
                line = line:sub(1,-2)
            end
            -- Think twice before changing this.  A music title with other characters
            -- (I can think of \ in particular) might change the read and write location of
            -- this function.
            if string.find(line,"[^0-9a-zA-Z .\'\"_%-%.]") then
                civ.ui.text("Music titles in Game.txt can only use the characters 0-9, A-Z, a-z, \', \",-, ., space and underscore when using the importMusic event module.")
                error("importMusic: Music titles in Game.txt can only use the characters 0-9, A-Z, a-z, \', \",-, , ., and _.")
            end
            musicTitles[musicLineNumber]=line
            musicLineNumber = musicLineNumber+1
        end
        if line == "@PICKMUSICTOT" then
            readingMusicNames = true
        end
    end
    local musicDir = civ.getToTDir().."\\Music"
    -- playing this 'silence' makes sure we don't try to overwrite a
    -- file being played
    civ.playMusic(musicDir.."\\silence.mp3")
    -- This will copy the Alien.mp3 to _Alien.mp3, if _Alien.mp3 is not already in the
    -- Music directory.  This should only happen the first time this is run (since afterward,
    -- the tracks with _ will exist), and will preserve the original music
    -- commented out, since I now distribute an entire music folder
    --for trackNumber,trackName in pairs(originalMusicNames) do
    --    if not file.exists(musicDir.."\\_"..trackName..".mp3") then
    --        file.copy(musicDir.."\\"..trackName..".mp3",musicDir.."\\_"..trackName..".mp3")
    --    end
    --end
    for trackNumber,trackTitle in pairs(musicTitles) do
        if file.exists(musicDir.."\\_"..trackTitle..".mp3") then
            file.copy(musicDir.."\\_"..trackTitle..".mp3",musicDir.."\\"..originalMusicNames[trackNumber]..".mp3")
        else
            if file.exists(customMusicDirectory.."\\"..trackTitle..".mp3") then
                file.copy(customMusicDirectory.."\\"..trackTitle..".mp3",musicDir.."\\"..originalMusicNames[trackNumber]..".mp3")
            elseif file.exists(customMusicDirectory.."\\_"..trackTitle..".mp3") then
                file.copy(customMusicDirectory.."\\_"..trackTitle..".mp3",musicDir.."\\"..originalMusicNames[trackNumber]..".mp3")
            else
                error("importMusic: can't find the track "..trackTitle.." .")
            end
        end
        -- old version of code, where music was automatically copied 

        --if not file.exists(musicDir.."\\_"..trackTitle..".mp3") then
        --    if file.exists(customMusicDirectory.."\\"..trackTitle..".mp3") then
        --        file.copy(customMusicDirectory.."\\"..trackTitle..".mp3",musicDir.."\\_"..trackTitle..".mp3")
        --    elseif file.exists(customMusicDirectory.."\\_"..trackTitle..".mp3") then
        --        file.copy(customMusicDirectory.."\\_"..trackTitle..".mp3",musicDir.."\\_"..trackTitle..".mp3")
        --    else
        --        error("importMusic: can't find the track "..trackTitle.." .")
        --    end
        --end
        --file.copy(musicDir.."\\_"..trackTitle..".mp3",musicDir.."\\"..originalMusicNames[trackNumber]..".mp3")
    end
    return true
end

local function resetMusic()
    local musicDir = civ.getToTDir().."\\Music"
    civ.playMusic(musicDir.."\\silence.mp3")
    for trackNumber,trackName in pairs(originalMusicNames) do
        file.copy(musicDir.."\\_"..trackName..".mp3",musicDir.."\\"..trackName..".mp3")
    end
end

local function choosePlaylist()
    local maxPlaylistOptions = 14
    local musicDir = civ.getToTDir().."\\Music"
    if not file.exists(musicDir.."\\playlist.txt") then
        resetMusic()
        return
    end 
    local playlistTable = {}
    local playlistTableIndex = 1
    local trackIndex = 1
    local readingPlaylist = false
    local ampersandValue = nil
    for line in io.lines(musicDir.."\\playlist.txt") do
        while line:sub(-1) ==" " do
            line = line:sub(1,-2)
        end
        if line:sub(1,1) == ";" then
            -- comment line
        elseif line:sub(1,1) == "@" then
            if readingPlaylist then
                civ.ui.text("It looks like you forgot to end playlist @"..
                playlistTable[playlistTableIndex]["name"].." with a #.")
                error("It looks like you forgot to end playlist @"..
                playlistTable[playlistTableIndex]["name"].." with a #.")
            end
            playlistTable[playlistTableIndex] = {}
            playlistTable[playlistTableIndex]["name"]=line:sub(2)
            readingPlaylist=true
        elseif line:sub(1,1) == "#" then
            playlistTableIndex=playlistTableIndex+1
            readingPlaylist = false
            trackIndex=1
        elseif line:sub(1,1) == "&" then
            ampersandValue = line:sub(2)
        elseif readingPlaylist then
            -- Think twice before changing this.  A music title with other characters
            -- (I can think of \ in particular) might change the read and write location of
            -- this function.
            if string.find(line,"[^0-9a-zA-Z \'\"_%-%.]") then
                civ.ui.text("Music titles in playlist.txt can only use the characters 0-9, A-Z, a-z, \', \",-, ., space and underscore when using the importMusic event module.")
                error("choosePlaylist: Music titles in playlist.txt can only use the characters 0-9, A-Z, a-z, \', \",-, , ., and _.")
            end
            playlistTable[playlistTableIndex][trackIndex] = line
            trackIndex = trackIndex+1
        end
    end
    ampersandValue = ampersandValue or playlistTable[1]["name"]
    if ampersandValue == "RANDOMIZE" then
        playlistTable = {playlistTable[math.random(1,#playlistTable)]}
    elseif ampersandValue == "SELECT" then
        local playlistTableLength = #playlistTable
        if playlistTableLength > maxPlaylistOptions then
            local newPlaylistTable = {}
            local newPlaylistTableIndex = 1
            for playlistTableIndex=1,playlistTableLength do
                if math.random(1,playlistTableLength+1-playlistTableIndex) <= 
                    maxPlaylistOptions - newPlaylistTableIndex+1 then
                    newPlaylistTable[newPlaylistTableIndex] = playlistTable[playlistTableIndex]
                    newPlaylistTableIndex = newPlaylistTableIndex+1
                end
            end
            playlistTable = newPlaylistTable
        end
    else
        for __,playlist in pairs(playlistTable) do
            if playlist["name"] == ampersandValue then
                playlistTable = {playlist}
                break
            end
        end
        if playlistTable[2] then
            civ.ui.text("The value \"&"..ampersandValue.."\" in playlist.txt does not "..
            "correspond to a defined playlist.")
            playlistTable = {playlistTable[1]}
        end
    end
    for playlistNumber,playlist in pairs(playlistTable) do
        local playlistLength = #playlist
        if playlistLength > 13 then
            local newPlaylist = {}
            newPlaylist["name"] = playlist["name"]
            newPlaylist[1] = playlist[1]
            newPlaylist[2] = playlist[2]
            local newPlaylistIndex = 3
            for originalPlaylistIndex=3,playlistLength do
                if math.random(1,playlistLength+1-originalPlaylistIndex)<= 13 - newPlaylistIndex + 1 then
                    newPlaylist[newPlaylistIndex]=playlist[originalPlaylistIndex]
                    newPlaylistIndex=newPlaylistIndex+1
                end
            end
            playlistTable[playlistNumber] = newPlaylist
        end
    end
    local playlistTableLength = #playlistTable
    if playlistTableLength == 0 then
        resetMusic()
        return
    elseif playlistTableLength >= 2 then
        local playlistChoiceDialog = civ.ui.createDialog()
        playlistChoiceDialog.title = "Select Music Playlist"
        for i=1,playlistTableLength do
            playlistChoiceDialog:addOption(playlistTable[i]["name"],i)
        end
        local choice = playlistChoiceDialog:show()
        local chosenPlaylist = playlistTable[choice]
        playlistTable = {chosenPlaylist}
    end
    resetMusic()
    civ.playMusic(musicDir.."\\silence.mp3")
    local chosenPlaylist = playlistTable[1]
    for i=1,13 do
        --civ.ui.text(tostring(chosenPlaylist[i]))
        if chosenPlaylist[i] and file.exists(musicDir.."\\"..chosenPlaylist[i]) then
            file.copy(musicDir.."\\"..chosenPlaylist[i],musicDir.."\\"..originalMusicNames[i]..".mp3")
        end
    end
end


return {
    importMusic = importMusic,
    resetMusic = resetMusic,
    choosePlaylist = choosePlaylist,
}









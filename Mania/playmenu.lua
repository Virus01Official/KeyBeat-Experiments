local playmenu = {}
local Game = require("game")

-- Table to hold available songs
local songFiles = {}

-- Function to add a song to the songFiles table
local function addSong(name, midiPath, musicPath)
    table.insert(songFiles, {name = name, midi = midiPath, music = musicPath})
end

-- Function to load all songs from a directory
local function loadSongsFromDirectory(midiDir, musicDir)
    local midiFiles = love.filesystem.getDirectoryItems(midiDir)
    local musicFiles = love.filesystem.getDirectoryItems(musicDir)

    for _, midiFile in ipairs(midiFiles) do
        local midiName = midiFile:gsub("%.json$", "")
        local musicFile = midiName .. ".ogg"
        
        if love.filesystem.getInfo(musicDir .. "/" .. musicFile) then
            addSong(midiName, midiDir .. "/" .. midiFile, musicDir .. "/" .. musicFile)
        end
    end
end

-- Load all songs
loadSongsFromDirectory("assets/midi", "assets/music")

local currentSongIndex = 1

-- Function to load resources for the play menu (if needed)
function playmenu.load()
    -- Any initialization for the play menu
end

function playmenu.update(dt)
    -- Any updates for the play menu
end

-- Function to draw the menu
function playmenu.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Select a song:", love.graphics.getWidth() / 2 - 60, 50)

    for i, song in ipairs(songFiles) do
        local y = 100 + (i - 1) * 30
        if i == currentSongIndex then
            love.graphics.setColor(0, 1, 0) -- Highlight selected song in green
            love.graphics.print("> " .. song.name, love.graphics.getWidth() / 2 - 60, y)
        else
            love.graphics.setColor(1, 1, 1) -- Default color for other songs
            love.graphics.print("  " .. song.name, love.graphics.getWidth() / 2 - 60, y)
        end
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Use UP and DOWN arrows to navigate, ENTER to select", love.graphics.getWidth() / 2 - 150, love.graphics.getHeight() - 30)
end

-- Function to handle key presses in the menu
function playmenu.keypressed(key)
    if key == "down" then
        currentSongIndex = (currentSongIndex % #songFiles) + 1
    elseif key == "up" then
        currentSongIndex = (currentSongIndex - 2) % #songFiles + 1
    elseif key == "return" then
        local selectedSong = songFiles[currentSongIndex]
        goToGame(selectedSong)
    end
end

return playmenu

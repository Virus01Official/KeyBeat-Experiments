local playmenu = {}
local Game = require("game")

local PollLink = "https://forms.gle/JQ8g22Js2eUqfx7b6"

local LinkText = "Feedback"
local LinkX, LinkY = 0, love.graphics.getHeight() - 30
local LinkWidth, LinkHeight = 0, 0

-- Table to hold available songs
local songFiles = {}

-- Function to add a song to the songFiles table
local function addSong(name, osuPath, musicPath)
    table.insert(songFiles, {name = name, osu = osuPath, music = musicPath})
end

-- Function to load all songs from a directory
local function loadSongsFromDirectory(osuDir, musicDir)
    local osuFiles = love.filesystem.getDirectoryItems(osuDir)
    local musicFiles = love.filesystem.getDirectoryItems(musicDir)

    for _, osuFile in ipairs(osuFiles) do
        local osuName = osuFile:gsub("%.osu$", "")
        
        -- Check for both .ogg and .mp3 files
        local musicFileOgg = osuName .. ".ogg"
        local musicFileMp3 = osuName .. ".mp3"

        if love.filesystem.getInfo(musicDir .. "/" .. musicFileOgg) then
            addSong(osuName, osuDir .. "/" .. osuFile, musicDir .. "/" .. musicFileOgg)
        elseif love.filesystem.getInfo(musicDir .. "/" .. musicFileMp3) then
            addSong(osuName, osuDir .. "/" .. osuFile, musicDir .. "/" .. musicFileMp3)
        end
    end
end

-- Load all songs
loadSongsFromDirectory("assets/osu", "assets/music")

local currentSongIndex = 1

-- Function to load resources for the play menu (if needed)
function playmenu.load()
    -- Measure the text width and height for the Link
    LinkWidth = love.graphics.getFont():getWidth(LinkText)
    LinkHeight = love.graphics.getFont():getHeight()
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

    love.graphics.setColor(0, 0, 1)
    love.graphics.print(LinkText, LinkX, LinkY)
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

function playmenu.mousepressed(x, y, button)
    if button == 1 then
        -- Check if the click was within the Link's bounding box
        if x >= LinkX and x <= LinkX + LinkWidth and y >= LinkY and y <= LinkY + LinkHeight then
            love.system.openURL(PollLink)
        end
    end
end

return playmenu

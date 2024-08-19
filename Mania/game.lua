local Game = {}

local json = require("dkjson")

local lanes = 4
local baseSpeed = 200
local hitWindow = 0.15
local hitLineY = love.graphics.getHeight() - 60

local notes = {}
local timeOffset = 0
local music
local score = 0
local hitEffects = {}
local selectedSong

-- Key bindings for the lanes
local laneKeys = {"d", "f", "j", "k"}

-- Function to start the Game with a selected song
function Game.start(song)
    selectedSong = song

    local fileContent = love.filesystem.read(song.midi)
    local midiData, pos, err = json.decode(fileContent)

    if err then
        error("Error parsing JSON: " .. err)
    end

    notes = {}
    for _, event in ipairs(midiData) do
        local lane = (event.note % lanes) + 1
        local time = event.time
        local speed = baseSpeed * (event.bpm / 120)  -- Adjust speed based on BPM
        table.insert(notes, {time = time, lane = lane, hit = false, speed = speed})
    end

    table.sort(notes, function(a, b) return a.time < b.time end)

    music = love.audio.newSource(song.music, "stream")
    timeOffset = love.timer.getTime()
    music:play()
end

function Game.load()
    -- Initial setup or configuration, if needed
end

function Game.update(dt)
    local currentTime = love.timer.getTime() - timeOffset

    -- Update hit effects
    for i = #hitEffects, 1, -1 do
        hitEffects[i].duration = hitEffects[i].duration - dt
        if hitEffects[i].duration <= 0 then
            table.remove(hitEffects, i)
        end
    end
end

function Game.draw()
    local currentTime = love.timer.getTime() - timeOffset

    local laneWidth = love.graphics.getWidth() / lanes
    for i = 1, lanes do
        love.graphics.line(laneWidth * (i - 1), 0, laneWidth * (i - 1), love.graphics.getHeight())
    end

    love.graphics.setColor(1, 0, 0)
    love.graphics.line(0, hitLineY, love.graphics.getWidth(), hitLineY)

    for _, note in ipairs(notes) do
        if not note.hit then
            local y = hitLineY - (note.time - currentTime) * note.speed
            if y > 0 and y < love.graphics.getHeight() then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", (note.lane - 1) * laneWidth, y, laneWidth, 20)
            end
        end
    end

    for _, effect in ipairs(hitEffects) do
        love.graphics.setColor(1, 1, 0, effect.duration / 0.2)
        love.graphics.rectangle("fill", (effect.lane - 1) * laneWidth, hitLineY - 20, laneWidth, 20)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
end

function Game.keypressed(key)
    local currentTime = love.timer.getTime() - timeOffset

    for _, note in ipairs(notes) do
        if not note.hit and laneKeys[note.lane] == key then
            if math.abs(note.time - currentTime) <= hitWindow then
                note.hit = true
                score = score + 100
                table.insert(hitEffects, {lane = note.lane, duration = 0.2})
                print("Hit! Score: " .. score)
            end
        end
    end

    if key == 'r' then
        music:stop()
        timeOffset = love.timer.getTime()
        music:play()

        for _, note in ipairs(notes) do
            note.hit = false
        end

        score = 0
        hitEffects = {}
    end
end

return Game

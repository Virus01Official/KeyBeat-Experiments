local Game = {}

local lanes = 4
local baseSpeed = 200
local hitWindow = 0.15
local missWindow = 0.2 -- Time after which a note is considered missed
local hitLineY = love.graphics.getHeight() - 60

local notes = {}
local timeOffset = 0
local music
local score = 0
local misses = 0
local hitEffects = {}
local missEffects = {}
local selectedSong
local hitsound = love.audio.newSource("assets/hitsound.ogg", "static")
local missSFX = love.audio.newSource("assets/miss.ogg", "static")

-- Key bindings for the lanes
local laneKeys = {"d", "f", "j", "k"}

-- Function to start the Game with a selected song
function Game.start(song)
    selectedSong = song

    local fileContent = love.filesystem.read(song.osu)
    local hitObjects, bpm = Game.parseOsu(fileContent)

    notes = {}
    for _, obj in ipairs(hitObjects) do
        local lane = obj.lane
        local time = obj.time
        -- Calculate speed based on BPM
        local speed = baseSpeed * (bpm / 120)  -- Assume 120 BPM as the base for baseSpeed
        table.insert(notes, {time = time, lane = lane, hit = false, speed = speed})
    end

    table.sort(notes, function(a, b) return a.time < b.time end)

    music = love.audio.newSource(song.music, "stream")
    timeOffset = love.timer.getTime()
    music:play()
end

-- Function to parse the .osu file and extract the HitObjects and BPM
function Game.parseOsu(content)
    local hitObjects = {}
    local inHitObjects = false
    local bpm = 120  -- Default BPM

    for line in content:gmatch("[^\r\n]+") do
        if line:find("%[TimingPoints%]") then
            -- Extract BPM from the first uninherited timing point
            local params = {}
            for value in line:gmatch("[^,]+") do
                table.insert(params, value)
            end
            local beatLength = tonumber(params[2])
            if tonumber(params[7]) == 1 then  -- Check if it's an uninherited timing point
                bpm = 60000 / beatLength
            end
        elseif line:find("%[HitObjects%]") then
            inHitObjects = true
        elseif inHitObjects then
            if line == "" then
                break
            end

            local params = {}
            for value in line:gmatch("[^,]+") do
                table.insert(params, value)
            end

            local x = tonumber(params[1])
            local time = tonumber(params[3])
            local lane = math.floor(x / (512 / lanes)) + 1
            local holdEndTime = tonumber(params[4])

            table.insert(hitObjects, {
                time = time / 1000,
                lane = lane,
                holdEndTime = holdEndTime and holdEndTime / 1000 or nil
            })
        end
    end

    return hitObjects, bpm
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

    -- Update miss effects
    for i = #missEffects, 1, -1 do
        missEffects[i].duration = missEffects[i].duration - dt
        if missEffects[i].duration <= 0 then
            table.remove(missEffects, i)
        end
    end

    -- Check for missed notes
    for i = #notes, 1, -1 do
        local note = notes[i]
        if not note.hit then
            local y = hitLineY - (note.time - currentTime) * note.speed

            if note.holdEndTime then
                -- Handle hold notes
                local holdEndY = hitLineY - (note.holdEndTime - currentTime) * note.speed
                if holdEndY > hitLineY + missWindow * note.speed then
                    -- Hold note is missed
                    note.hit = true
                    score = score - 50 -- Deduct points for misses
                    misses = misses + 1
                    missSFX:play()
                    table.insert(missEffects, {lane = note.lane, duration = 0.2})
                    print("Missed! Score: " .. score)
                    table.remove(notes, i) -- Remove missed note from list
                end
            else
                -- Handle regular notes
                if y > hitLineY + missWindow * note.speed then
                    note.hit = true
                    score = score - 50 -- Deduct points for misses
                    misses = misses + 1
                    missSFX:play()
                    table.insert(missEffects, {lane = note.lane, duration = 0.2})
                    print("Missed! Score: " .. score)
                    table.remove(notes, i) -- Remove missed note from list
                end
            end
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

            if note.holdEndTime then
                -- Draw hold note
                local holdEndY = hitLineY - (note.holdEndTime - currentTime) * note.speed
                if holdEndY > 0 and y < love.graphics.getHeight() then
                    love.graphics.setColor(0, 0, 1)
                    love.graphics.rectangle("fill", (note.lane - 1) * laneWidth, math.min(y, holdEndY), laneWidth, math.abs(holdEndY - y))
                end
            else
                -- Draw regular note
                if y > 0 and y < love.graphics.getHeight() then
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.rectangle("fill", (note.lane - 1) * laneWidth, y, laneWidth, 20)
                end
            end
        end
    end

    for _, effect in ipairs(hitEffects) do
        love.graphics.setColor(1, 1, 0, effect.duration / 0.2)
        love.graphics.rectangle("fill", (effect.lane - 1) * laneWidth, hitLineY - 20, laneWidth, 20)
    end

    for _, effect in ipairs(missEffects) do
        love.graphics.setColor(1, 0, 0, effect.duration / 0.2)
        love.graphics.rectangle("fill", (effect.lane - 1) * laneWidth, hitLineY - 20, laneWidth, 20)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("Misses: " .. misses, 10, 30)
end

function Game.keypressed(key)
    local currentTime = love.timer.getTime() - timeOffset

    for _, note in ipairs(notes) do
        if not note.hit and laneKeys[note.lane] == key then
            if math.abs(note.time - currentTime) <= hitWindow then
                if note.holdEndTime then
                    -- Handle hold note
                    local holdDuration = note.holdEndTime - note.time
                    if currentTime <= note.holdEndTime then
                        note.hit = true
                        score = score + 100
                        table.insert(hitEffects, {lane = note.lane, duration = 0.2})
                        print("Hit! Score: " .. score)
                        hitsound:play()
                    end
                else
                    -- Handle regular note
                    note.hit = true
                    score = score + 100
                    table.insert(hitEffects, {lane = note.lane, duration = 0.2})
                    print("Hit! Score: " .. score)
                    hitsound:play()
                end
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
        misses = 0
        hitEffects = {}
        missEffects = {}
    end
end

return Game

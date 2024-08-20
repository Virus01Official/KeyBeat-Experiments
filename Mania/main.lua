local Game = require("game")
local intro = require("intro")
local joining = require("joining")
local playmenu = require("playmenu")

local game_state = "intro"
local cursor = love.mouse.newCursor("assets/cursor.png", 0, 0)

function love.load()
    if game_state == "intro" then
        intro.load()
    elseif game_state == "playmenu" then
        playmenu.load()
    end
end

function love.update(dt)
    if game_state == "game" then
        Game.update(dt)
    elseif game_state == "intro" then
        intro.update(dt)
    elseif game_state == "joining" then
        joining.update(dt)
    elseif game_state == "playmenu" then
        playmenu.update(dt)
    end
end

function love.draw()
    if game_state == "game" then
        Game.draw()
    elseif game_state == "intro" then
        intro.draw()
    elseif game_state == "joining" then
        joining.draw()
    elseif game_state == "playmenu" then
        playmenu.draw()
    end
end

function love.keypressed(key)
    if game_state == "game" then
        Game.keypressed(key)
    elseif game_state == "intro" then
        intro.keypressed(key)
    elseif game_state == "playmenu" then
        playmenu.keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    if game_state == "joining" then
        joining.mousepressed(x, y, button)
    elseif game_state == "playmenu" then
        playmenu.mousepressed(x, y, button)
    end
end

function goToGame(song)
    Game.start(song)
    game_state = "game"
end

function gotoJoining()
    joining.load()
    game_state = "joining"
end

function goToPlayMenu()
    playmenu.load()
    game_state = "playmenu"
    love.mouse.setCursor(cursor)
end

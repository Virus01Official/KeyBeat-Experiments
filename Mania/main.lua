local Game = require("game")
local intro = require("intro")
local joining = require("joining")

local game_state = "intro"

function love.load()
    if game_state == "intro" then
        intro.load()
    end
end

function love.update(dt)
    if game_state == "game" then
        Game.update(dt)
    elseif game_state == "intro" then
        intro.update(dt)
    elseif game_state == "joining" then
        joining.update(dt)
    end
end

function love.draw()
    if game_state == "game" then
        Game.draw()
    elseif game_state == "intro" then
        intro.draw()
    elseif game_state == "joining" then
        joining.draw()
    end
end

function love.keypressed(key)
    if game_state == "game" then
        Game.keypressed(key)
    elseif game_state == "intro" then
        intro.keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    if game_state == "joining" then
        joining.mousepressed(x, y, button)
    end
end

function goToGame()
    Game.load()
    game_state = "game"
end

function gotoJoining()
    joining.load()
    game_state = "joining"
end
-- conf.lua
function love.conf(t)
    t.window.title = "KeyBeat Experiment"
    t.window.icon = "assets/GameIcon.png"
    t.window.width = 1000
    t.window.height = 700
    t.window.fullscreen = false
    t.window.vsync = 1 -- Enable vertical sync
    t.window.resizable = true -- Enable window resizing
    t.window.fullscreentype = "desktop" -- Use the current desktop resolution
end
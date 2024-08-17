local intro = {}
local introDuration = 3 -- Total duration of the intro in seconds
local fadeDuration = 1.5 -- Duration for the fade in
local introElapsed = 0
local introFinished = false
local alpha = 0
local introFont -- Declare a variable to hold the font
local originalFont
local introSFX = love.audio.newSource("assets/Intro.mp3", "static")
local logo = love.graphics.newImage("assets/logo.png")

function intro.load()
    logoSizeX = 250
    logoSizeY = 250

    -- Original dimensions of the image
    originalWidth = logo:getWidth()
    originalHeight = logo:getHeight()

    -- Calculate the scaling factors
    LogoscaleX = logoSizeX / originalWidth
    LogoscaleY = logoSizeY / originalHeight

    love.audio.play(introSFX)
    introElapsed = 0
    introFinished = false

    introFont = love.graphics.newFont("Fonts/Moderniz.otf", 24)  -- Adjust size as needed
    -- Load font based on the selected language from settings
    originalFont = love.graphics.newFont("Fonts/NotoSans-Regular.ttf", 24)
end

function intro.update(dt)
    introElapsed = introElapsed + dt

    -- Calculate alpha value for fading
    if introElapsed <= fadeDuration then
        alpha = introElapsed / fadeDuration -- Fade in
    elseif introElapsed <= introDuration then
        alpha = 1 -- Fully visible
    else
        introFinished = true
        if love.filesystem.getInfo("terms_accepted") then
            goToGame()
        else
            gotoJoining()
        end
    end
end

function intro.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local logoWidth = logo:getWidth()
    local logoHeight = logo:getHeight()

    -- Calculate centered position for the logo
    local logoX = (screenWidth - logoWidth * LogoscaleX) / 2
    local logoY = (screenHeight - logoHeight * LogoscaleY) / 2

    love.graphics.setColor(1, 1, 1, alpha) -- Set the alpha value
    love.graphics.draw(logo, logoX, logoY, 0, LogoscaleX, LogoscaleY)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white with full opacity

    -- Center the text horizontally
    local text = "Made by Moonwave Studios"

    love.graphics.setFont(introFont) -- Set the specific font
    local textWidth = introFont:getWidth(text)
    local textX = (screenWidth - textWidth) / 2

    love.graphics.setColor(1, 1, 1, alpha) -- Set the alpha value
    love.graphics.print(text, textX, screenHeight - 100)
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white with full opacity

    -- Reset the font back to original
    love.graphics.setFont(originalFont)
end

function intro.isFinished()
    return introFinished
end

function intro.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

return intro

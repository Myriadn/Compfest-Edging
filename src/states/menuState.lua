-- menuState.lua

local menu = {}
menu.__index = menu

function menu.new()
    local self = setmetatable({}, menu)
    return self
end

-- menu items
local options = {"start", "credits"}
local currentSelection = 1

local bgFrames = {}
local bgTimer = 0
local bgIndex = 1

local floatTimer = 0
local font 

local fontPath = "/assets/fonts/PixAntiqua.ttf"
local fontSize = 30

function menu:load(f)
    font = love.graphics.newFont(fontPath, fontSize)
    for i = 1, 4 do
        bgFrames[i] = love.graphics.newImage("/assets/images/background/menu-bg-"..i..".png")
    end
end

function menu:update(dt)
    bgTimer = bgTimer + dt
    if bgTimer > 0.5 then
        bgTimer = 0
        bgIndex = bgIndex % #bgFrames + 1
    end
    floatTimer = floatTimer + dt
end

function menu:draw()
    if font == nil then
        error("Font is nil in menu:draw")
    end
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 0.8) -- Atur opacity ke 50%
    love.graphics.draw(bgFrames[bgIndex], 0, 0, 0,
        love.graphics.getWidth()/bgFrames[bgIndex]:getWidth(),
        love.graphics.getHeight()/bgFrames[bgIndex]:getHeight())
    love.graphics.setColor(1, 1, 1, 1) 

    local titleY = 200 + math.sin(floatTimer*2)*5
    love.graphics.printf("Funabulist", love.graphics.getWidth() - 400, titleY, 400, "left") 

    for i, v in ipairs(options) do
        local y = 250 + (i * 40) + math.sin(floatTimer*3 + i)*3
        if i == currentSelection then
            love.graphics.print(">", love.graphics.getWidth() - 430, y) -- Geser tanda ">" ke kanan
        end
        love.graphics.print(v, love.graphics.getWidth() - 400, y)       -- Geser teks tombol ke kanan
    end
end

function menu:keypressed(key)
    if key == "up" or key == "w" then
        currentSelection = currentSelection - 1
        if currentSelection < 1 then currentSelection = #options end
    elseif key == "down" or key == "s" then
        currentSelection = currentSelection + 1
        if currentSelection > #options then currentSelection = 1 end
    elseif key == "return" or key == "space" then
        if options[currentSelection] == "start" then
            SwitchState(require("src.states.prologueState").new())
        elseif options[currentSelection] == "credits" then
            print("Show credits")
        end
    end
end

return menu

-- main.lua
-- Entry point untuk game

-- Include dependencies
_G.love             =   require("love")
_G.SoundManager     =   require("src.systems.soundManager").new()
local fontPath      =   "/assets/fonts/PixAntiqua.ttf"
local fontSize      =   30

-- VIRTUAL RESOLUTION
VIRTUAL_WIDTH       =   1280    -- Virtual width of the game
VIRTUAL_HEIGHT      =   720     -- Virtual height of the game

-- Global variables
local activeState

-- Fungsi global untuk mengganti state
function SwitchState(newState)
    if activeState and activeState.unload then
        activeState:unload()
    end
    activeState = newState
    if activeState and activeState.load then
        activeState:load()
    end
end
_G.SwitchState = SwitchState

function love.load(font)

    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")
    font = love.graphics.newFont(fontPath, fontSize)
    SwitchState(require("src.states.menuState").new())
end

function love.update(dt)
    if activeState and activeState.update then
        activeState:update(dt)
    end
end

function love.draw()
    local w, h      =   love.graphics.getDimensions()
    local scale     =   math.min(w / VIRTUAL_WIDTH, h / VIRTUAL_HEIGHT)
    local offsetX   =   (w - (VIRTUAL_WIDTH * scale)) / 2
    local offsetY   =   (h - (VIRTUAL_HEIGHT * scale)) / 2

    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale)

    if activeState and activeState.draw then
        activeState:draw()
    end

    love.graphics.pop()
end

function love.resize(w, h)
	-- Sengaja kosong
end

function love.keypressed(key, scancode, isrepeat)
    -- Baru keluar aja
    if key == "escape" then
        love.event.quit()
    end
    if activeState and activeState.keypressed then
        activeState:keypressed(key, scancode, isrepeat)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if activeState and activeState.mousepressed then
        local w, h      =   love.graphics.getDimensions()
        local scale     =   math.min(w / VIRTUAL_WIDTH, h / VIRTUAL_HEIGHT)
        local offsetX   =   (w - VIRTUAL_WIDTH * scale) / 2
        local offsetY   =   (h - VIRTUAL_HEIGHT * scale) / 2

        local mouseX    =   (x - offsetX) / scale
        local mouseY    =   (y - offsetY) / scale

        activeState:mousepressed(mouseX, mouseY, button, istouch, presses)
    end
end

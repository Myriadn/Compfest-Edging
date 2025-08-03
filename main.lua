-- main.lua
-- Entry point for the Love2D game

-- Include dependencies
local playState = require("src.states.playState")

-- VIRTUAL RESOLUTION
VIRTUAL_WIDTH = 1280    -- Virtual width of the game
VIRTUAL_HEIGHT = 720    -- Virtual height of the game

-- Global variables
local activeState
local canvas
local scaleX, scaleY
local offsetX, offsetY

-- Function to switch between game states
function SwitchState(newState)
    print("Memasuki switchState. Tipe dari currentState adalah: " .. type(currentState))

    -- Clean up current state if needed
    if activeState and activeState.unload then
        activeState:unload()
    end

    -- Switch to new state
    activeState = newState

    -- Initialize new state if needed
    if activeState and activeState.load then
        activeState:load()
    end
end
_G.SwitchState = SwitchState

-- Love2D callback functions
function love.load()
    -- Initialize random seed
    math.randomseed(os.time())

    -- Set default filter mode for scaling images
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Muat state awal menggunakan SwitchState
    SwitchState(require("src.states.playState").new())

    -- Panggil resize sekali di awal untuk setup skala
    love.resize(love.graphics.getDimensions())
end

function love.update(dt)
    -- Update current game state
    if activeState and activeState.update then
        activeState:update(dt)
    end
end

function love.draw()
    -- Translate/Scale
    love.graphics.push()

    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scaleX, scaleY)

    -- Draw the current game state
    if activeState and activeState.draw then
        activeState:draw()
    end

    -- Back to normal coordinates
    love.graphics.pop()
end

function love.resize(w, h)
	-- Calculate scale factors
	scaleX = w / VIRTUAL_WIDTH
	scaleY = h / VIRTUAL_HEIGHT

	-- Calculate offsets to center the game
	local scale = math.min(scaleX, scaleY)

	-- Reset scales for uniform scaling
	scaleX = scale
	scaleY = scale

	-- Calculate offsets to center the game
	offsetX = (w - VIRTUAL_WIDTH * scaleX) / 2
	offsetY = (h - VIRTUAL_HEIGHT * scaleY) / 2
end

function love.keypressed(key, scancode, isrepeat)
    -- Handle keyboard input
    if key == "escape" then
        love.event.quit()
    end

    -- Pass input to current state
    if activeState.keypressed then
        activeState:keypressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    -- Pass input to current state
    if activeState.keyreleased then
        activeState:keyreleased(key, scancode)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    -- Pass input to current state
    if activeState.mousepressed then
        activeState:mousepressed(x, y, button, istouch, presses)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    -- Pass input to current state
    if activeState.mousereleased then
        activeState:mousereleased(x, y, button, istouch, presses)
    end
end

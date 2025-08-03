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

    -- Initialize the game state
    currentState = playState.new()

    -- Load assets and initialize game components
    if currentState.load then
        currentState:load()
    end

    love.resize(love.graphics.getDimensions())
end

function love.update(dt)
    -- Update current game state
    if currentState.update then
        currentState:update(dt)
    end
end

function love.draw()
    -- Translate/Scale
    love.graphics.push()

    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scaleX, scaleY)

    -- Draw the current game state
    if currentState.draw then
        currentState:draw()
    end

    -- Back to normal coordinates
    love.graphics.pop()

    -- Debug information (can be toggled)
    -- love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
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
    if currentState.keypressed then
        currentState:keypressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key, scancode)
    -- Pass input to current state
    if currentState.keyreleased then
        currentState:keyreleased(key, scancode)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    -- Pass input to current state
    if currentState.mousepressed then
        currentState:mousepressed(x, y, button, istouch, presses)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    -- Pass input to current state
    if currentState.mousereleased then
        currentState:mousereleased(x, y, button, istouch, presses)
    end
end

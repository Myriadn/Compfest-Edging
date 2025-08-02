-- main.lua
-- Entry point for the Love2D game

-- Include dependencies
local gameState = require("src.states.gameState")

-- Global variables
local currentState

-- Love2D callback functions
function love.load()
    -- Initialize random seed
    math.randomseed(os.time())

    -- Set default filter mode for scaling images
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- Initialize the game state
    currentState = gameState.new()

    -- Load assets and initialize game components
    if currentState.load then
        currentState:load()
    end
end

function love.update(dt)
    -- Update current game state
    if currentState.update then
        currentState:update(dt)
    end
end

function love.draw()
    -- Draw the current game state
    if currentState.draw then
        currentState:draw()
    end

    -- Debug information (can be toggled)
    -- love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
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

-- Function to switch between game states
function switchState(newState)
    -- Clean up current state if needed
    if currentState and currentState.unload then
        currentState:unload()
    end

    -- Switch to new state
    currentState = newState

    -- Initialize new state if needed
    if currentState and currentState.load then
        currentState:load()
    end
end

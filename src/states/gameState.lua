-- gameState.lua

local gameState     = {}
gameState.__index   = gameState

function gameState.new()
    local self = setmetatable({}, gameState)

    self.paused = false
    self.entities = {}

    return self
end

-- Load resources and initialize state
function gameState:load()
    -- Override in state implementations
end

-- Update game logic
function gameState:update(dt)
    -- Skip updates if paused
    if self.paused then return end

    -- Update all entities
    for _, entity in ipairs(self.entities) do
        if entity.update then
            entity:update(dt)
        end
    end
end

-- Draw the state
function gameState:draw()
    -- Draw all entities
    for _, entity in ipairs(self.entities) do
        if entity.draw then
            entity:draw()
        end
    end
end

-- Clean up resources when leaving state
function gameState:unload()
    -- Override in state implementations
end

-- Input handling methods
function gameState:keypressed(key, scancode, isrepeat)
    -- Override in state implementations
end

function gameState:keyreleased(key, scancode)
    -- Override in state implementations
end

function gameState:mousepressed(x, y, button, istouch, presses)
    -- Override in state implementations
end

function gameState:mousereleased(x, y, button, istouch, presses)
    -- Override in state implementations
end

-- Add entity to the state
function gameState:addEntity(entity)
    table.insert(self.entities, entity)
    return entity
end

-- Remove entity from the state
function gameState:removeEntity(entity)
    for i, e in ipairs(self.entities) do
        if e == entity then
            table.remove(self.entities, i)
            return true
        end
    end
    return false
end

-- Toggle pause state
function gameState:togglePause()
    self.paused = not self.paused
    return self.paused
end

return gameState

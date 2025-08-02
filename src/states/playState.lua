-- playState.lua

-- Import the base game state module
local gameState = require("src.states.gameState")

-- Table for the play state, inheriting from gameState
local playState = {}
playState.__index = playState

-- Constructor for the play state
function playState.new()
    local self = setmetatable(gameState.new(), playState)

    -- for development
    self.player = {
        x = 50,         -- initial x position
        y = 600,        -- (y rope - tinggi pemain), contoh: 664 - 64 = 600
        width = 32,     -- width of the player
        height = 64,    -- height of the player
        speed = 100     -- movement speed in pixels per second
    }

    self.rope = {
        y = 664,                 -- Posisi Y tali (dibawah kaki pemain)
        startX = 0,
        endX = VIRTUAL_WIDTH     -- lebar jendela
    }

    return self
end

function playState:load()
    print("playState loaded") -- for debugging purposes
end

function playState:update(dt)
    gameState.update(self, dt)

    -- Player consistency speed
    self.player.x = self.player.x + self.player.speed * dt

    print("playState updated") -- for debugging purposes
end

function playState:draw()
    gameState.draw(self)

    -- Development drawing
    -- Draw rope
    love.graphics.setColor(1, 1, 1) -- Reset color to white
    love.graphics.line(self.rope.startX, self.rope.y, self.rope.endX, self.rope.y)

    -- Draw player
    love.graphics.rectangle("fill", self.player.x, self.player.y, self.player.width, self.player.height)
end

function playState:unload()
    print("playState unloaded") -- for debugging purposes
end

function playState:keypressed(key, scancode, isrepeat)
    -- later maybe
end

return playState

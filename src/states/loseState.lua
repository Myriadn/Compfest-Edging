-- loseState.lua

-- local gameState = require("src.states.gameState")

local loseState = {}
loseState.__index = loseState

function loseState.new()
    return setmetatable({}, loseState)
end

function loseState:draw()
    love.graphics.printf("Keseimbangan hilang", 0, VIRTUAL_HEIGHT / 2 - 50, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Space kembali ke menu", 0, VIRTUAL_HEIGHT / 2 + 20, VIRTUAL_WIDTH, "center")
end

function loseState:keypressed(key)
    if key == "space" then
        -- Transition to the main menu state
        _G.SwitchState(require("src.states.playState").new())
    end
end

return loseState

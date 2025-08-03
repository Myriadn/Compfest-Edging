-- winState.lua

local winState = {}
winState.__index = winState

function winState.new()
    return setmetatable({}, winState)
end

function winState:draw()
    love.graphics.printf("Tujuan ditemukan", 0, VIRTUAL_HEIGHT / 2 - 50, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Space back to mneu", 0, VIRTUAL_HEIGHT / 2 + 20, VIRTUAL_WIDTH, "center")
end

function winState:keypressed(key)
    if key == "space" then
        -- Transition to the main menu state
        _G.SwitchState(require("src.states.menuState").new())
    end
end

return winState

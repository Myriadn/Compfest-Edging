-- prologueState.lua

local PrologueState     =   {}
PrologueState.__index   =   PrologueState

function PrologueState.new()
    local self = setmetatable({}, PrologueState)

    self.scenes = {}
    -- Muat semua gambar scene secara berurutan
    for i = 1, 9 do
        -- Coba muat scene-i.png dan scene-i-j.png
        local scenePath = "assets/images/tony-1/scene-" .. i .. ".png"
        if love.filesystem.exists(scenePath) then
            table.insert(self.scenes, love.graphics.newImage(scenePath))
        end
        for j = 1, 4 do
             local subScenePath = "assets/images/tony-1/scene-" .. i .. "-" .. j .. ".png"
             if love.filesystem.exists(subScenePath) then
                table.insert(self.scenes, love.graphics.newImage(subScenePath))
             end
        end
    end

    self.currentSceneIndex = 1
    self.sceneDuration = 3 -- detik per adegan
    self.timer = self.sceneDuration

    return self
end

function PrologueState:update(dt)
    self.timer = self.timer - dt
    if self.timer <= 0 then
        self.currentSceneIndex = self.currentSceneIndex + 1
        self.timer = self.sceneDuration

        -- Jika scene sudah habis, pindah ke playState
        if self.currentSceneIndex > #self.scenes then
            _G.SwitchState(require("src.states.playState").new())
        end
    end
end

function PrologueState:draw()
    local currentScene = self.scenes[self.currentSceneIndex]
    if currentScene then
        -- Gambar scene di tengah layar
        local x = (VIRTUAL_WIDTH - currentScene:getWidth()) / 2
        local y = (VIRTUAL_HEIGHT - currentScene:getHeight()) / 2
        love.graphics.draw(currentScene, x, y)
    end
end

function PrologueState:keypressed(key)
    -- Izinkan pemain untuk skip prologue
    if key == "space" or key == "return" then
         _G.SwitchState(require("src.states.playState").new())
    end
end

return PrologueState

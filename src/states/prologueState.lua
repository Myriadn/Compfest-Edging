-- prologueState.lua

local PrologueState = {}
PrologueState.__index = PrologueState

local cutsceneScale = 0.5

function PrologueState.new()
    local self = setmetatable({}, PrologueState)

    self.scenes = {}

    self.fadeAlpha = 1     -- Mulai dari hitam (1 = penuh), 0 = transparan
    self.fadingIn = true   -- Awalnya fade in
    self.fadeSpeed = 3     -- Kecepatan fade
    self.fadeOut = false   -- Flag untuk fade out
    self.waiting = false   -- Flag untuk jeda setelah fade out

    -- Muat semua gambar scene secara berurutan
    for i = 1, 9 do
        local scenePath = "assets/images/tony-1/scene-" .. i .. ".png"
        if love.filesystem.getInfo(scenePath) then
            table.insert(self.scenes, love.graphics.newImage(scenePath))
        end
        for j = 1, 4 do
            local subScenePath = "assets/images/tony-1/scene-" .. i .. "-" .. j .. ".png"
            if love.filesystem.getInfo(subScenePath) then
                table.insert(self.scenes, love.graphics.newImage(subScenePath))
            end
        end
    end

    self.currentSceneIndex = 1
    self.sceneDuration = 2 -- Detik per adegan
    self.timer = self.sceneDuration
    self.waitTimer = 0     -- Timer untuk jeda setelah fade out
    self.waitDuration = 0.5  -- Durasi jeda setelah fade out (dalam detik)

    return self
end

function PrologueState:update(dt)
    local currentScene = self.scenes[self.currentSceneIndex]
    if not currentScene then return end

    -- Tentukan apakah scene ini memerlukan fade berdasarkan indeks
    local requiresFade = self:requiresFade(self.currentSceneIndex)

    if requiresFade and self.fadingIn then
        self.fadeAlpha = self.fadeAlpha - dt * self.fadeSpeed
        if self.fadeAlpha <= 0 then
            self.fadeAlpha = 0
            self.fadingIn = false
        end
    elseif not requiresFade and self.fadingIn then
        self.fadeAlpha = 0 -- Langsung transparan jika tidak perlu fade
        self.fadingIn = false
    end

    if not self.fadeOut and not self.waiting then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            if requiresFade then
                self.fadeOut = true
            else
                self.currentSceneIndex = self.currentSceneIndex + 1
                self.timer = self.sceneDuration
                if self.currentSceneIndex > #self.scenes then
                    _G.SwitchState(require("src.states.playState").new())
                end
            end
        end
    end

    if requiresFade and self.fadeOut then
        self.fadeAlpha = self.fadeAlpha + dt * self.fadeSpeed
        if self.fadeAlpha >= 1 then
            self.fadeAlpha = 1
            self.fadeOut = false
            self.waiting = true
            self.waitTimer = self.waitDuration
        end
    elseif self.fadeOut then
        self.fadeAlpha = 1 -- Langsung hitam jika tidak perlu fade
        self.fadeOut = false
        self.waiting = true
        self.waitTimer = self.waitDuration
    end

    if self.waiting then
        self.waitTimer = self.waitTimer - dt
        if self.waitTimer <= 0 then
            self.waiting = false
            if requiresFade then
                self.currentSceneIndex = self.currentSceneIndex + 1
                self.timer = self.sceneDuration
                self.fadingIn = true
                if self.currentSceneIndex > #self.scenes then
                    _G.SwitchState(require("src.states.playState").new())
                end
            end
        end
    end
end

function PrologueState:requiresFade(index)
    -- Definisikan scene yang memerlukan fade berdasarkan indeks
    -- Indeks dimulai dari 1 sesuai urutan pemuatan
    -- scene-1.png sampai scene-5.png (indeks 1-5)
    -- scene-6-1.png sampai scene-6-4.png (indeks 6-9)
    -- scene-7.png sampai scene-8.png (indeks 10-11)
    -- scene-9-1.png sampai scene-9-2.png (indeks 12-13)
    local fadeScenes = {1, 2, 3, 4, 5, 10, 11, 13} -- Indeks yang memerlukan fade
    return table.contains(fadeScenes, index)
end

-- Fungsi bantu untuk memeriksa apakah tabel mengandung nilai
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then return true end
    end
    return false
end


function PrologueState:draw()
    local currentScene = self.scenes[self.currentSceneIndex]
    if currentScene then
        local scale = cutsceneScale

        local imgW = currentScene:getWidth()
        local imgH = currentScene:getHeight()

        -- Posisi agar tetap center setelah diskalakan
        local x = (VIRTUAL_WIDTH - imgW * scale) / 2
        local y = (VIRTUAL_HEIGHT - imgH * scale) / 2

        love.graphics.draw(currentScene, x, y, 0, scale, scale)
    end

    -- Black bars cinematic
    love.graphics.setColor(0, 0, 0, 1)
    local barHeight = 80
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, barHeight)
    love.graphics.rectangle("fill", 0, VIRTUAL_HEIGHT - barHeight, VIRTUAL_WIDTH, barHeight)
    love.graphics.setColor(1, 1, 1, 1)

    -- Overlay hitam untuk fade in/out
    love.graphics.setColor(0, 0, 0, self.fadeAlpha)
    love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
end

function PrologueState:keypressed(key)
    -- Izinkan pemain untuk skip prologue
    if key == "space" or key == "return" then
        _G.SwitchState(require("src.states.playState").new())
    end
end

return PrologueState

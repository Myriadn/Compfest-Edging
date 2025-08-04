-- winState.lua

local winState = {}
winState.__index = winState

local cutsceneScale = 0.5

function winState.new()
    local self = setmetatable({}, winState)

    self.scenes = {}

    self.fadeAlpha = 1     -- Mulai dari hitam (1 = penuh), 0 = transparan
    self.fadingIn = true   -- Awalnya fade in
    self.fadeSpeed = 1     -- Kecepatan fade
    self.fadeOut = false   -- Flag untuk fade out
    self.waiting = false   -- Flag untuk jeda setelah fade out

    self.audio = love.audio.newSource("/assets/sounds/Music/Musik Kemenangan (Win Phase).ogg", "stream")
    self.audio:setLooping(false)
    self.audio:setVolume(0.5)
    self.audio:play()

    -- Muat semua gambar ending secara berurutan
    for i = 1, 5 do
        local scenePath = "/assets/images/tony-1/ending-" .. i .. ".png"
        if love.filesystem.getInfo(scenePath) then
            table.insert(self.scenes, love.graphics.newImage(scenePath))
        end
    end

    self.currentSceneIndex = 1
    self.sceneDuration = 3 -- Detik per adegan
    self.timer = self.sceneDuration
    self.waitTimer = 0     -- Timer untuk jeda setelah fade out
    self.waitDuration = 1  -- Durasi jeda setelah fade out (dalam detik)

    return self
end

function winState:update(dt)
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
                    _G.SwitchState(require("src.states.menuState").new())
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
            if requiresFade or self.currentSceneIndex > #self.scenes then
                self.currentSceneIndex = self.currentSceneIndex + 1
                self.timer = self.sceneDuration
                self.fadingIn = true
                if self.currentSceneIndex > #self.scenes then
                    self.audio:stop()
                    local menuState = require("src.states.menuState").new()
                    menuState.showCredits = true
                    _G.SwitchState(menuState)
                end
            end
        end
    end
end

function winState:requiresFade(index)
    -- Definisikan scene yang memerlukan fade berdasarkan indeks
    -- ending-1.png = indeks 1
    -- ending-2.png = indeks 2
    -- ending-3.png = indeks 3 (tanpa fade)
    -- ending-4.png = indeks 4 (tanpa fade)
    -- ending-5.png = indeks 5
    local fadeScenes = {1, 2, 5} -- Indeks yang memerlukan fade
    return table.contains(fadeScenes, index)
end

-- Fungsi bantu untuk memeriksa apakah tabel mengandung nilai
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then return true end
    end
    return false
end

function winState:draw()
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

function winState:keypressed(key)
    -- Izinkan pemain untuk skip ke menu utama
    if key == "space" then
        self.audio:stop()
        local menuState = require("src.states.menuState").new()
        menuState.showCredits = true
        _G.SwitchState(menuState)
    end
end

return winState

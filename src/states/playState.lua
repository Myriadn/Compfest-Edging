-- playState.lua

-- Impor semua modul dan sistem
local gameState         =   require("src.states.gameState")
local Player            =   require("src.entities.player")
local BalanceSystem     =   require("src.systems.balanceSystem")
local ObstacleSystem    =   require("src.systems.obstacleSystem")
local BackgroundSystem  =   require("src.systems.backgroundSystem")

local playState     =   {}
playState.__index   =   playState

function playState.new()
    local self  = setmetatable(gameState.new(), playState)

    -- Definisikan properti level
    self.ropeY = 655

    -- Instances
    self.player             =   Player.new(50, self.ropeY)      -- Entities player
    self.balanceSystem      =   BalanceSystem.new()             -- Balance system
    self.obstacleSystem     =   ObstacleSystem.new()            -- Obstacle system
    self.backgroundSystem   =   BackgroundSystem.new()          -- Background system

    self.obstacleSystem.player = self.player

    return self
end

function playState:update(dt)
    self.player:update(dt)
    self.balanceSystem:update(dt)
    self.obstacleSystem:update(dt, self.player, self.balanceSystem)
    self.backgroundSystem:update(dt)

    -- Cek kondisi menang/kalah dari sistem yang relevan
    if self.balanceSystem:isDepleted() then
        _G.SwitchState(require("src.states.loseState").new())
        return
    end

    if self.player.x > VIRTUAL_WIDTH then
        _G.SwitchState(require("src.states.winState").new())
        return
    end
end

function playState:draw()
    -- Gambar dalam urutan layer yang benar (belakang ke depan)
    self.backgroundSystem:draw()

    love.graphics.setColor(1, 1, 1)
    love.graphics.line(0, self.ropeY, VIRTUAL_WIDTH, self.ropeY)

    self.player:draw()
    self.obstacleSystem:draw(self.player)

    -- Gambar UI selalu paling depan
    self.balanceSystem:draw(self.player)
end

function playState:keypressed(key, scancode, isrepeat)
    -- self.balanceSystem:keypressed(key)      -- QTE Input key

    if key == "space" then
        -- Panggil fungsi handleInput dari BalanceSystem, dan simpan hasilnya (true/false)
        local success = self.balanceSystem:handleInput(self.player)

        -- Jika hasilnya true (berhasil), perintahkan pemain untuk bergerak maju
        if success then
            self.player:moveForward()
        end
    end
end

function playState:mousepressed(x, y, button, istouch, pressed)
	self.obstacleSystem:mousepressed(x, y, self.balanceSystem)
end

function playState:load()
    _G.SoundManager:setVolume(0.35)
    print("playState loaded")
    _G.SoundManager:playMusic("gameplay", true)
end

function playState:unload()
    print("playState unloaded")
    _G.SoundManager:stopMusic()
end

return playState

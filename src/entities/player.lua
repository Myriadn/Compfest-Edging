-- player.lua
local Entity    =   require("src.entities.entity")
local Animation =   require("src.utils.animation")

local Player    =   {}
Player.__index  =   Player

function Player.new(x, y)
    -- Warisi properti dasar dari Entity
    local self  = setmetatable(Entity.new(x, y), Player)
    self.speed  =  100

    -- Muat aset sprite dan buat animasi
    local spriteImage = love.graphics.newImage("assets/images/sprites/protag-spritesheets.png")
    self.animation = Animation.new(spriteImage, spriteImage:getWidth() / 3, spriteImage:getHeight(), 0.15, false)

    local _, _, w, h = self.animation.quads[1]:getViewport()
    self.width  = w
    self.height = h
    self.y      = y - self.height

    -- Properti untuk pergerakan smooth
    self.targetX    = self.x
    self.moveSpeed  = 2      -- Kecepatan interpolasi (semakin tinggi, semakin cepat)
    self.stunTimer  = 0      -- Properti untuk stun

    self.animation:setCurrentFrame(2)

    return self
end

-- Semua logika update pemain ada di sini
function Player:update(dt)
    -- Gerakan auto-run
    -- self.x = self.x + self.speed * dt
    self.x = self.x + (self.targetX - self.x) * self.moveSpeed * dt

    if self:isStunned() then
        self.stunTimer = self.stunTimer - dt
        self.animation:setCurrentFrame(2) -- Paksa ke frame tengah (stun)
    else
        self.animation:update(dt)

        -- Jika animasi berjalan sudah selesai, kembali ke posisi idle
        if self.animation.isFinished then
            self.animation:setCurrentFrame(2)
        end
    end
end

function Player:moveForward()
    -- Jarak pergerakan bisa disesuaikan agar terasa pas
    local moveDistance = 25
    self.targetX = self.targetX + moveDistance
    _G.SoundManager:play("playerWalk")
    self.animation:play()
end

-- Semua logika gambar pemain ada di sini
function Player:draw()
    love.graphics.setColor(1, 1, 1)

    -- Gambar bagian atas (badan)
    self.animation:draw(self.x, self.y)
end

function Player:stun(duration)
    self.stunTimer = duration
    _G.SoundManager:play("playerStun")
end

function Player:isStunned()
    return self.stunTimer > 0
end

return Player

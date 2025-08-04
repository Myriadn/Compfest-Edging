-- player.lua
local Entity    =   require("src.entities.entity")
local Animation =   require("src.utils.animation")

local Player    =   {}
Player.__index  =   Player

function Player.new(x, y)
    -- Warisi properti dasar dari Entity
    local self  =  setmetatable(Entity.new(x, y, 32, 64), Player)

    self.speed  =  100

    -- Muat aset sprite dan buat animasi
    local upperBodyImg = love.graphics.newImage("assets/images/sprites/protag-spritesheets.png")
    local lowerBodyImg = love.graphics.newImage("assets/images/sprites/protag-spritesheets-walk.png")

    self.animUpper = Animation.new(upperBodyImg, upperBodyImg:getWidth() / 3, upperBodyImg:getHeight(), 0.5)
    self.animLower = Animation.new(lowerBodyImg, lowerBodyImg:getWidth() / 3, lowerBodyImg:getHeight(), 0.5)

    -- Asumsi lebar setiap frame adalah 1/3 dari total lebar gambar
    local _, _, upperW, upperH = self.animUpper.quads[1]:getViewport()
    local _, _, lowerW, lowerH = self.animLower.quads[1]:getViewport()

    -- Sesuaikan tinggi pemain berdasarkan gabungan sprite
    self.height = upperH + lowerH
    self.width  = upperW

    self.y = y - self.height

    return self
end

-- Semua logika update pemain ada di sini
function Player:update(dt)
    -- Gerakan auto-run
    -- self.x = self.x + self.speed * dt

    self.animUpper:update(dt)
    self.animLower:update(dt)
end

function Player:moveForward()
    -- Jarak pergerakan bisa disesuaikan agar terasa pas
    local moveDistance = 30
    self.x = self.x + moveDistance
end

-- Semua logika gambar pemain ada di sini
function Player:draw()
    love.graphics.setColor(1, 1, 1)

    local _, _, _, upperBodyHeight = self.animUpper.quads[1]:getViewport()

    -- Gambar bagian bawah (kaki) terlebih dahulu
    self.animLower:draw(self.x, self.y + upperBodyHeight)
    -- Gambar bagian atas (badan)
    self.animUpper:draw(self.x, self.y)
end

return Player

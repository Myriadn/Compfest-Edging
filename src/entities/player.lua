-- player.lua
local Entity    = require("src.entities.entity")
local Animation = require("src.utils.animation")

local Player    = {}
Player.__index  = Player

function Player.new(x, y)
    -- Warisi properti dasar dari Entity
    local self = setmetatable(Entity.new(x, y, 32, 64), Player)

    self.speed = 100

    -- Muat aset sprite dan buat animasi
    local upperBodyImg = love.graphics.newImage("assets/images/sprites/protag-spritesheets.png")
    local lowerBodyImg = love.graphics.newImage("assets/images/sprites/protag-spritesheets-walk.png")

    -- Asumsi lebar setiap frame adalah 1/3 dari total lebar gambar
    self.animUpper = Animation.new(upperBodyImg, upperBodyImg:getWidth() / 3, upperBodyImg:getHeight(), 0.5)
    self.animLower = Animation.new(lowerBodyImg, lowerBodyImg:getWidth() / 3, lowerBodyImg:getHeight(), 0.5)

    -- Sesuaikan tinggi pemain berdasarkan gabungan sprite
    self.height = self.animUpper.quads[1]:getViewport()[4] + self.animLower.quads[1]:getViewport()[4]
    self.width = self.animUpper.quads[1]:getViewport()[3]

    return self
end

-- Semua logika update pemain ada di sini
function Player:update(dt)
    -- Gerakan auto-run
    self.x = self.x + self.speed * dt

    self.animUpper:update(dt)
    self.animLower:update(dt)
end

-- Semua logika gambar pemain ada di sini
function Player:draw()
    local upperBodyHeight = self.animUpper.quads[1]:getViewport()[4]

    -- Gambar bagian bawah (kaki) terlebih dahulu
    self.animLower:draw(self.x, self.y + upperBodyHeight)
    -- Gambar bagian atas (badan)
    self.animUpper:draw(self.x, self.y)
end

return Player

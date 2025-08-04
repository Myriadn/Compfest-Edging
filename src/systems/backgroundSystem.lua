-- backgroundSystem.lua

local BackgroundSystem      =   {}
BackgroundSystem.__index    =   BackgroundSystem

function BackgroundSystem.new()
    local self = setmetatable({}, BackgroundSystem)

    local bg1_stars         = love.graphics.newImage("assets/images/background/1.png")     -- Bintang (paling belakang, diam)
    local bg2_moon          = love.graphics.newImage("assets/images/background/2.png")     -- Bulan (di belakang awan, diam)
    local bg_uppercloud     = love.graphics.newImage("assets/images/background/4-1.png")   -- Awan Atas (di belakang, bergerak lambat)
    local bg3_far_clouds    = love.graphics.newImage("assets/images/background/v3-1.png")  -- Awan Jauh (di belakang, bergerak lambat)
    local bg4_near_clouds   = love.graphics.newImage("assets/images/background/v4.png")    -- Awan Dekat (di bawah, bergerak lebih cepat)
    local bg5_front_clouds  = love.graphics.newImage("assets/images/background/v5-1.png")  -- Awan Paling Depan (di bawah, bergerak paling cepat)

    local stars_sx = VIRTUAL_WIDTH / bg1_stars:getWidth()
    local stars_sy = VIRTUAL_HEIGHT / bg1_stars:getHeight()
    local moon_sx = VIRTUAL_WIDTH / bg2_moon:getWidth()
    local moon_sy = VIRTUAL_HEIGHT / bg2_moon:getHeight()

    local uppercloud_scale = VIRTUAL_WIDTH / bg_uppercloud:getWidth()
    local far_clouds_scale = VIRTUAL_WIDTH / bg3_far_clouds:getWidth()
    local near_clouds_scale = VIRTUAL_WIDTH / bg4_near_clouds:getWidth()
    local front_clouds_scale = VIRTUAL_WIDTH / bg5_front_clouds:getWidth()

    -- Muat semua lapisan gambar dari aset Anda
    self.layers = {
        {
            img     = bg1_stars,
            speed   = 0,
            offset  = 0,
            y       = 0,
            sx      = stars_sx,
            sy      = stars_sy
        },
        {
            img     = bg2_moon,
            speed   = 0,
            offset  = 0,
            y       = 50,
            sx      = moon_sx,
            sy      = moon_sy
        },
        {
            img    = bg_uppercloud,
            speed  = 0,
            offset = 0,
            y      = 0,
            scale  = uppercloud_scale
        },
        {
            img     = bg3_far_clouds,
            speed   = 25,
            offset  = 0,
            y       = 250,
            scale   = far_clouds_scale
        },
        {
            img     = bg4_near_clouds,
            speed   = 60,
            offset  = 0,
            scale   = near_clouds_scale,
            y       = VIRTUAL_HEIGHT - (bg4_near_clouds:getHeight() * near_clouds_scale) + 300,
            sx      = VIRTUAL_WIDTH / bg4_near_clouds:getWidth()
        },
        {
            img     = bg5_front_clouds,
            speed   = 80,
            offset  = 0,
            scale   = front_clouds_scale,
            y       = VIRTUAL_HEIGHT - (bg5_front_clouds:getHeight() * front_clouds_scale) + 340
        },
    }

    return self
end

function BackgroundSystem:update(dt)
    -- Gerakkan setiap lapisan dengan kecepatan berbeda
    for _, layer in ipairs(self.layers) do
        layer.offset = (layer.offset + layer.speed * dt) % layer.img:getWidth()
    end
end

function BackgroundSystem:draw()
    for _, layer in ipairs(self.layers) do
        local sx = layer.sx or layer.scale or 1
        local sy = layer.sy or layer.scale or 1

        local scaledWidth = layer.img:getWidth() * sx

        -- Gambar layer dua kali untuk efek loop yang mulus
        love.graphics.draw(layer.img, -layer.offset, layer.y, 0, sx, sy)
        love.graphics.draw(layer.img, -layer.offset + scaledWidth, layer.y, 0, sx, sy)
    end
end

return BackgroundSystem

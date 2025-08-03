local BackgroundSystem      =   {}
BackgroundSystem.__index    =   BackgroundSystem

function BackgroundSystem.new()
    local self = setmetatable({}, BackgroundSystem)

    self.layers = {
        -- Lapisan paling belakang, bergerak paling lambat
        {img = love.graphics.newImage("assets/images/background/orig_big.png"), speed = 15, offset = 0},
        -- Lapisan tengah
        {img = love.graphics.newImage("assets/images/background/v3.png"), speed = 30, offset = 0},
        -- Lapisan depan, bergerak paling cepat
        {img = love.graphics.newImage("assets/images/background/v4.png"), speed = 50, offset = 0}
    }

    return self
end

function BackgroundSystem:update(dt)
    for _, layer in ipairs(self.layers) do
        layer.offset = (layer.offset + layer.speed * dt) % layer.img:getWidth()
    end
end

function BackgroundSystem:draw()
    for _, layer in ipairs(self.layers) do
        -- Gambar layer pertama
        love.graphics.draw(layer.img, -layer.offset, 0)
        -- Gambar layer kedua di sebelahnya untuk menciptakan efek loop
        love.graphics.draw(layer.img, -layer.offset + layer.img:getWidth(), 0)
    end
end

return BackgroundSystem

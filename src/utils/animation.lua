local Animation         =   {}
Animation.__index       =   Animation

function Animation.new(image, frameWidth, frameHeight, duration)
    local self = setmetatable({}, Animation)

    self.image          =   image
    self.quads          =   {}
    self.duration       =   duration or 1
    self.timer          =   0
    self.currentFrame   =   1

    -- Potong-potong gambar menjadi beberapa frame (quad)
    for y = 0, image:getHeight() - frameHeight, frameHeight do
        for x = 0, image:getWidth() - frameWidth, frameWidth do
            table.insert(self.quads, love.graphics.newQuad(x, y, frameWidth, frameHeight, image:getDimensions()))
        end
    end

    return self
end

function Animation:update(dt)
    self.timer = self.timer + dt
    if self.timer >= self.duration then
        self.timer = self.timer - self.duration
        self.currentFrame = (self.currentFrame % #self.quads) + 1
    end
end

function Animation:draw(x, y, angle, sx, sy, ox, oy)
    love.graphics.draw(self.image, self.quads[self.currentFrame], x, y, angle, sx, sy, ox, oy)
end

return Animation

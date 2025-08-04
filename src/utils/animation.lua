-- animation.lua

local Animation         =   {}
Animation.__index       =   Animation

function Animation.new(image, frameWidth, frameHeight, duration, looping)
    local self = setmetatable({}, Animation)

    self.image          =   image
    self.quads          =   {}
    self.duration       =   duration or 1
    self.timer          =   0
    self.currentFrame   =   1

    self.looping = looping      -- Jika true, animasi akan berulang
    self.isPlaying = looping    -- Animasi looping langsung berjalan
    self.isFinished = false

    -- Potong-potong gambar menjadi beberapa frame (quad)
    for y = 0, image:getHeight() - frameHeight, frameHeight do
        for x = 0, image:getWidth() - frameWidth, frameWidth do
            table.insert(self.quads, love.graphics.newQuad(x, y, frameWidth, frameHeight, image:getDimensions()))
        end
    end

    return self
end

function Animation:update(dt)
    if not self.isPlaying then return end

    self.timer = self.timer + dt
    if self.timer >= self.duration then
        if self.looping then
            self.timer = self.timer - self.duration
            self.currentFrame = (self.currentFrame % #self.quads) + 1
        else
            -- Jika tidak looping, berhenti di frame terakhir
            self.currentFrame = #self.quads
            self.isPlaying = false
            self.isFinished = true
        end
    end
end

function Animation:play()
    self.timer = 0
    self.currentFrame = 1
    self.isPlaying = true
    self.isFinished = false
end

function Animation:draw(x, y, angle, sx, sy, ox, oy)
    love.graphics.draw(self.image, self.quads[self.currentFrame], x, y, angle, sx, sy, ox, oy)
end

function Animation:setCurrentFrame(frameNumber)
    self.currentFrame = math.max(1, math.min(frameNumber, #self.quads))
    self.isPlaying = false
end

return Animation

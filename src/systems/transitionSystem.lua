-- transitionSystem.lua
-- Unused

local TransitionSystem      = {}
TransitionSystem.__index    = TransitionSystem

function TransitionSystem.new(duration)
    local self      = setmetatable({}, TransitionSystem)

    self.duration   = duration or 1 -- Durasi default 1 detik
    self.alpha      = 1 -- Mulai dari hitam pekat (untuk fade-in)
    self.timer      = 0
    self.isActive   = false
    self.onComplete = nil -- Callback function setelah transisi selesai

    return self
end

function TransitionSystem:fadeIn(onComplete)
    self.alpha      = 1
    self.timer      = self.duration
    self.mode       = "in"
    self.isActive   = true
    self.onComplete = onComplete
end

function TransitionSystem:fadeOut(onComplete)
    self.alpha      = 0
    self.timer      = 0
    self.mode       = "out"
    self.isActive   = true
    self.onComplete = onComplete
end

function TransitionSystem:update(dt)
    if not self.isActive then return end

    if self.mode == "in" then
        self.timer = self.timer - dt
        self.alpha = self.timer / self.duration
    elseif self.mode == "out" then
        self.timer = self.timer + dt
        self.alpha = self.timer / self.duration
    end

    -- Cek jika transisi selesai
    if self.timer <= 0 or self.timer >= self.duration then
        self.isActive = false
        if self.onComplete then
            self.onComplete()
        end
    end
end

function TransitionSystem:draw()
    if self.alpha > 0 then
        love.graphics.setColor(0, 0, 0, self.alpha)
        love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        love.graphics.setColor(1, 1, 1, 1) -- Selalu reset warna
    end
end

return TransitionSystem

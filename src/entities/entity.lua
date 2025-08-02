-- entity.lua
-- Base entity class for all game objects

local Entity = {}
Entity.__index = Entity

-- Create a new entity instance
function Entity.new(x, y, width, height)
    local self = setmetatable({}, Entity)

    -- Position
    self.x = x or 0
    self.y = y or 0

    -- Dimensions
    self.width = width or 32
    self.height = height or 32

    -- Physics properties
    self.velocity = {x = 0, y = 0}
    self.acceleration = {x = 0, y = 0}

    -- Entity state
    self.active = true
    self.visible = true
    self.collidable = true

    -- Identification
    self.type = "entity"
    self.id = tostring({}):sub(8) -- Generate a unique id

    return self
end

-- Update entity logic (to be overridden by child classes)
function Entity:update(dt)
    -- Apply physics
    self.velocity.x = self.velocity.x + self.acceleration.x * dt
    self.velocity.y = self.velocity.y + self.acceleration.y * dt

    self.x = self.x + self.velocity.x * dt
    self.y = self.y + self.velocity.y * dt
end

-- Draw entity (to be overridden by child classes)
function Entity:draw()
    -- Debug draw
    if self.visible then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end
end

-- Check if this entity collides with another
function Entity:collidesWith(other)
    if not (self.collidable and other.collidable) then
        return false
    end

    return self.x < other.x + other.width and
           self.x + self.width > other.x and
           self.y < other.y + other.height and
           self.y + self.height > other.y
end

-- Handle collision with another entity (to be overridden by child classes)
function Entity:onCollision(other)
    -- Override in child classes
end

-- Set position
function Entity:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Get center position
function Entity:getCenter()
    return {
        x = self.x + self.width / 2,
        y = self.y + self.height / 2
    }
end

-- Calculate distance to another entity
function Entity:distanceTo(other)
    local centerA = self:getCenter()
    local centerB = other:getCenter()

    local dx = centerB.x - centerA.x
    local dy = centerB.y - centerA.y

    return math.sqrt(dx * dx + dy * dy)
end

return Entity

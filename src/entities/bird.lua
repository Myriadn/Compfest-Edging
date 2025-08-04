-- bird.lua

local Entity    =   require("src.entities.entity")
local helpers   =   require("src.utils.helpers")
local Animation =   require("src.utils.animation")

local decreaseBalance   =   20

local Bird      =   {}
Bird.__index    =   Bird

function Bird.new()
    -- Inisialisasi properti dasar
    local self      =   setmetatable(Entity.new(), Bird)
    self.x          =   VIRTUAL_WIDTH + 50
    self.y          =   math.random(500, 600)
    self.speed      =   200

    local image = love.graphics.newImage("assets/images/sprites/bird-evil.png")
    self.animation = Animation.new(image, image:getWidth() / 3, image:getHeight(), 0.3, true)

    self.width = image:getWidth() / 3
    self.height = image:getHeight()

    -- Data spesifik untuk QTE
    self.qte = {
        active                  =   false,
        triggerDistance         =   300,
        hitCircleRadius         =   40,
        approachCircleRadius    =   150,
        approachRate            =   100,
        isMissed                =   false
    }

    return self
end

function Bird:update(dt, player, balanceSystem)
    -- Gerakkan burung ke kiri
    self.x = self.x - self.speed * dt
    self.animation:update(dt)

    local dist = math.abs(self.x - player.x)
        if not self.qte.active and dist < self.qte.triggerDistance then
        self.qte.active = true
    end

    if self.qte.active and not self.qte.isMissed then
        self.qte.approachCircleRadius = self.qte.approachCircleRadius - self.qte.approachRate * dt
        if self.qte.approachCircleRadius < self.qte.hitCircleRadius then
            self.qte.isMissed = true
            player:stun(1.5)
            balanceSystem:decreaseBalance(decreaseBalance)
        end
    end
end

function Bird:draw()
    love.graphics.setColor(1, 1, 1)
    self.animation:draw(self.x, self.y)

    -- Gambar QTE jika aktif
    if self.qte.active and not self.qte.isMissed then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.circle("line", self.x + self.width/2, self.y + self.height/2, self.qte.approachCircleRadius)
        love.graphics.circle("fill", self.x + self.width/2, self.y + self.height/2, self.qte.hitCircleRadius)
    end
end

function Bird:isClicked(mouseX, mouseY)
    if self.qte.active and not self.qte.isMissed then
        local dist = helpers.getDistance(mouseX, mouseY, self.x + self.width/2, self.y + self.height/2)
        return dist <= self.qte.hitCircleRadius
    end
    return false
end

return Bird

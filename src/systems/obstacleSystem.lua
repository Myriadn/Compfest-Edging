-- obstacleSystem.lua

local Bird              =   require("src.entities.Bird")

local increaseBalance   =   5
local decreaseBalance   =   25

local ObstacleSystem    =   {}
ObstacleSystem.__index  =   ObstacleSystem

function ObstacleSystem.new()
    local self          =   setmetatable({}, ObstacleSystem)

    self.obstacles      =   {}
    self.spawnTimer     =   3
    self.spawnInterval  =   5

    return self
end

function ObstacleSystem:update(dt, player, balanceSystem)
    -- Logika Spawner
    self.spawnTimer = self.spawnTimer - dt
    if self.spawnTimer <= 0 then
        table.insert(self.obstacles, Bird.new())
        self.spawnTimer = self.spawnInterval + math.random(-1, 1)
    end

    -- Update setiap rintangan
    for i = #self.obstacles, 1, -1 do
        local obs = self.obstacles[i]
        obs:update(dt, player)

        -- Periksa apakah QTE terlewat dan berikan penalti
        if obs.qte.isMissed then
            print("QTE Missed! Balance decreased.")
            balanceSystem:decreaseBalance(decreaseBalance)
            table.remove(self.obstacles, i)

        elseif obs.x + obs.width < 0 then
            table.remove(self.obstacles, i)
        end
    end
end

function ObstacleSystem:draw()
    for _, obs in ipairs(self.obstacles) do
        obs:draw()
    end
end

function ObstacleSystem:mousepressed(x, y, balanceSystem)
    for i = #self.obstacles, 1, -1 do
        local obs = self.obstacles[i]
        if obs:isClicked(x, y) then
            print("HIT! obstacles removed.")
            balanceSystem:increaseBalance(increaseBalance)
            table.remove(self.obstacles, i)
            return
        end
    end
end

return ObstacleSystem

-- obstacleSystem.lua

local Bird              =   require("src.entities.Bird")

local ObstacleSystem    =   {}
ObstacleSystem.__index  =   ObstacleSystem

function ObstacleSystem.new()
    local self          =   setmetatable({}, ObstacleSystem)

    self.obstacles      =   {}
    self.spawnTimer     =   3
    self.spawnInterval  =   5

    return self
end

function ObstacleSystem:update(dt, player)
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
            player.balance = player.balance - 25 -- Penalti
            table.remove(self.obstacles, i) -- Hapus burung
        -- Hapus rintangan jika sudah keluar layar
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

function ObstacleSystem:mousepressed(x, y, player)
    for i = #self.obstacles, 1, -1 do
        local obs = self.obstacles[i]
        if obs:isClicked(x, y) then
            player.balance = player.balance + 5 -- Bonus
            table.remove(self.obstacles, i)
            return -- Hentikan loop setelah satu klik berhasil
        end
    end
end

return ObstacleSystem

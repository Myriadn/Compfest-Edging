-- balanceSystem.lua

local BalanceSystem     =   {}
BalanceSystem.__index   =   BalanceSystem

function BalanceSystem.new()
    local self = setmetatable({}, BalanceSystem)

    self.balance = 100
    self.maxBalance = 100
    self.balanceDecayRate = 5

    self.qte = {
        bar = {
            x = VIRTUAL_WIDTH / 2 - 200, y = VIRTUAL_HEIGHT - 50,
            width = 400, height = 20
        },
        safeZone = { width = 60, height = 20 },
        cursor = {
            x = 0, width = 10, height = 30,
            speed = 350, direction = 1
        }
    }
    self.qte.safeZone.x = self.qte.bar.x + (self.qte.bar.width - self.qte.safeZone.width) / 2
    self.qte.cursor.x = self.qte.bar.x

    return self
end

function BalanceSystem:update(dt)
    -- Turunkan keseimbangan
    self.balance = self.balance - self.balanceDecayRate * dt

    -- Gerakkan kursor
    local qte = self.qte

    qte.cursor.x = qte.cursor.x + (qte.cursor.speed * qte.cursor.direction * dt)
    if qte.cursor.x < qte.bar.x then
        qte.cursor.x = qte.bar.x
        qte.cursor.direction = 1
    elseif qte.cursor.x + qte.cursor.width > qte.bar.x + qte.bar.width then
        qte.cursor.x = qte.bar.x + qte.bar.width - qte.cursor.width
        qte.cursor.direction = -1
    end
end

function BalanceSystem:draw()
    local qte = self.qte
    -- Gambar bar utama
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", qte.bar.x, qte.bar.y, qte.bar.width, qte.bar.height)

    -- Gambar zona aman
    love.graphics.setColor(0.1, 0.7, 0.2)
    love.graphics.rectangle("fill", qte.safeZone.x, qte.bar.y, qte.safeZone.width, qte.safeZone.height)

    -- Gambar kursor
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", qte.cursor.x, qte.bar.y - 5, qte.cursor.width, qte.cursor.height)

    -- Gambar teks
    love.graphics.print("Balance: " .. math.floor(self.balance), 10, 10)
end

function BalanceSystem:keypressed(key)
    if key == "space" then
        local cursorCenter = self.qte.cursor.x + self.qte.cursor.width / 2
        local safeZone = self.qte.safeZone
        if cursorCenter >= safeZone.x and cursorCenter <= safeZone.x + safeZone.width then
            self.balance = self.balance + 20
            if self.balance > self.maxBalance then self.balance = self.maxBalance end
        else
            self.balance = self.balance - 15
        end
    end
end

function BalanceSystem:isDepleted()
    return self.balance <= 0
end

function BalanceSystem:increaseBalance(amount)
    self.balance = self.balance + amount
    if self.balance > self.maxBalance then
        self.balance = self.maxBalance
    end
end

function BalanceSystem:decreaseBalance(amount)
    self.balance = self.balance - amount
end

return BalanceSystem

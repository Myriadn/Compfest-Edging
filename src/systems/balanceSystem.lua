-- balanceSystem.lua

local BalanceSystem     =   {}
BalanceSystem.__index   =   BalanceSystem

function BalanceSystem.new()
    local self = setmetatable({}, BalanceSystem)

    self.balance            = 100
    self.maxBalance         = 100
    self.balanceDecayRate   = 5

    self.streak             = 0
    self.maxStreak          = 8
    self.baseSafeZoneWidth  = 120
    self.minSafeZoneWidth   = 30

    self.qte = {
        bar = {
            x       = VIRTUAL_WIDTH / 2 - 200,
            y       = VIRTUAL_HEIGHT - 50,
            width   = 400,
            height  = 20
        },
        safeZone = {
            width   = self.baseSafeZoneWidth,
            height  = 20
        },
        cursor = {
            x           = 0,
            width       = 10,
            height      = 30,
            speed       = 450,
            direction   = 1
        }
    }

    self:randomizeSafeZone()
    self.qte.cursor.x = self.qte.bar.x

    return self
end

function BalanceSystem:randomizeSafeZone()
    local qte = self.qte
    local maxPos = qte.bar.x + qte.bar.width - qte.safeZone.width
    qte.safeZone.x = math.random(qte.bar.x, maxPos)
end

function BalanceSystem:adjustSafeZoneSize()
    -- Gunakan interpolasi linear untuk mengecilkan safe zone secara mulus
    local progress = self.streak / self.maxStreak
    self.qte.safeZone.width = self.baseSafeZoneWidth - (self.baseSafeZoneWidth - self.minSafeZoneWidth) * progress
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
    -- love.graphics.print("Streak: " .. self.streak, 10, 30)

    local barWidth = qte.bar.width
    local barHeight = 5
    local barX = qte.bar.x
    local barY = qte.bar.y - barHeight - 5

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

    local balancePercent = self.balance / self.maxBalance
    local currentBarWidth = barWidth * balancePercent

    if self.balance > 50 then
        love.graphics.setColor(0.1, 0.8, 0.2) -- Hijau
    elseif self.balance > 25 then
        love.graphics.setColor(1, 0.6, 0) -- Oranye
    else
        love.graphics.setColor(0.9, 0.1, 0.1) -- Merah
    end

    love.graphics.rectangle("fill", barX, barY, currentBarWidth, barHeight)
    love.graphics.setColor(1, 1, 1)
end

function BalanceSystem:handleInput()
    local qte = self.qte
    local cursorCenter = qte.cursor.x + qte.cursor.width / 2
    local safeZone = qte.safeZone

    if cursorCenter >= safeZone.x and cursorCenter <= safeZone.x + safeZone.width then
        -- SUKSES
        self:increaseBalance(20)
        self.streak = math.min(self.streak + 1, self.maxStreak)
        self:adjustSafeZoneSize()
        self:randomizeSafeZone()
        return true -- Kembalikan 'true' untuk menandakan keberhasilan
    else
        -- GAGAL
        self:decreaseBalance(15)
        self.streak = 0 -- Reset streak
        self:adjustSafeZoneSize()
        self:randomizeSafeZone()
        return false -- Kembalikan 'false'
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

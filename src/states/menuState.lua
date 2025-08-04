-- menuState.lua

local menu = {}
menu.__index = menu

function menu.new()
    local self = setmetatable({}, menu)
    self.showCredits    = false -- Flag untuk menampilkan credits
    self.showControls   = false -- Flag untuk menampilkan controls
    return self
end

-- menu items
local options = {"start", "credits", "controls"}
local currentSelection = 1

local bgFrames  = {}
local bgTimer   = 0
local bgIndex   = 1

local floatTimer = 0
local font       -- Font utama (ukuran 30)
local smallFont  -- Font kecil (ukuran 20)

local fontPath      = "/assets/fonts/PixAntiqua.ttf"
local fontSize      = 30
local smallFontSize = 20 -- Ukuran font kecil

function menu:load(f)
    self.audio = love.audio.newSource("/assets/sounds/Music/Musik Menu Utama.ogg", "stream")
    self.audio:setVolume(0.6)
    self.audio:setLooping(true) 
    self.audio:play() 

    font = love.graphics.newFont(fontPath, fontSize)
    smallFont = love.graphics.newFont(fontPath, smallFontSize) -- Tambahkan font kecil
    for i = 1, 4 do
        bgFrames[i] = love.graphics.newImage("/assets/images/background/menu-bg-"..i..".png")
    end
end

function menu:update(dt)
    bgTimer = bgTimer + dt
    if bgTimer > 0.5 then
        bgTimer = 0
        bgIndex = bgIndex % #bgFrames + 1
    end
    floatTimer = floatTimer + dt
end

function menu:draw()
    if font == nil or smallFont == nil then
        error("Font is nil in menu:draw")
    end
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 0.8) -- Atur opacity ke 80%
    love.graphics.draw(bgFrames[bgIndex], 0, 0, 0,
        love.graphics.getWidth()/bgFrames[bgIndex]:getWidth(),
        love.graphics.getHeight()/bgFrames[bgIndex]:getHeight())
    love.graphics.setColor(1, 1, 1, 1) 

    if not self.showCredits and not self.showControls then
        -- Tampilkan menu utama
        local titleY = 200 + math.sin(floatTimer*2)*5
        love.graphics.printf("Funabulist", love.graphics.getWidth() - 400, titleY, 400, "left") 

        for i, v in ipairs(options) do
            local y = 250 + (i * 40) + math.sin(floatTimer*3 + i)*3
            if i == currentSelection then
                love.graphics.print(">", love.graphics.getWidth() - 430, y) -- Geser tanda ">" ke kanan
            end
            love.graphics.print(v, love.graphics.getWidth() - 400, y) -- Geser teks tombol ke kanan
        end
    elseif self.showCredits then
        -- Tampilkan credits dengan animasi floating
        local credits = {
            "Created by:",
            "Myriadn as Programmer",
            "seymourissey as 2D Artist",
            "azwinrx as Sound/Music Design",
            "",
            "Special Thanks to",
            "COMPFEST 17 IGI GAMEJAM",
            "2025"
        }
        local startY = 200 
        for i, credit in ipairs(credits) do
            local floatOffset = math.sin(floatTimer * 2 + i) * 5 
            local y = startY + (i - 1) * 40 + floatOffset
            -- Gunakan smallFont untuk teks tertentu
            if i == 2 or i == 3 or i == 4 or i == 7 then -- Indeks 2, 3, 4, 7 (Myriadn, seymourissey, azwinrx, COMPFEST)
                love.graphics.setFont(smallFont)
                love.graphics.print(credit, love.graphics.getWidth() - 500, y)
                love.graphics.setFont(font) -- Kembali ke font utama
            else
                love.graphics.print(credit, love.graphics.getWidth() - 500, y)
            end
        end
    elseif self.showControls then
        -- Tampilkan controls dengan animasi floating
        local controls = {
            "Controls:",
            "Space for QTE movement / Interact",
            "LMB for QTE Obstacles",
            "Arrow Up Arrow Down"
        }
        local startY = 200 -- Posisi vertikal awal
        for i, control in ipairs(controls) do
            local floatOffset = math.sin(floatTimer * 2 + i) * 5 -- Animasi naik-turun
            local y = startY + (i - 1) * 40 + floatOffset
            -- Gunakan smallFont untuk detail controls
            if i > 1 then -- Indeks 2, 3, 4 (detail controls)
                love.graphics.setFont(smallFont)
                love.graphics.print(control, love.graphics.getWidth() - 500, y)
                love.graphics.setFont(font) -- Kembali ke font utama
            else
                love.graphics.print(control, love.graphics.getWidth() - 500, y)
            end
        end
    end
end

function menu:keypressed(key)
    if not self.showCredits and not self.showControls then
        if key == "up" or key == "w" then
            currentSelection = currentSelection - 1
            if currentSelection < 1 then currentSelection = #options end
        elseif key == "down" or key == "s" then
            currentSelection = currentSelection + 1
            if currentSelection > #options then currentSelection = 1 end
        elseif key == "return" or key == "space" then
            if options[currentSelection] == "start" then
                self.audio:stop()
                SwitchState(require("src.states.prologueState").new())
            elseif options[currentSelection] == "credits" then
                self.showCredits = true
            elseif options[currentSelection] == "controls" then
                self.showControls = true
            end
        end
    elseif self.showCredits then
        -- Kembali ke menu utama saat menekan spasi di credits
        if key == "space" then
            self.showCredits = false
            currentSelection = 1 -- Kembali ke opsi "start"
        end
    elseif self.showControls then
        -- Kembali ke menu utama saat menekan spasi di controls
        if key == "space" then
            self.showControls = false
            currentSelection = 1 -- Kembali ke opsi "start"
        end
    end
end

return menu
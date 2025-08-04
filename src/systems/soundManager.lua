-- soundManager.lua

local SoundManager      = {}
SoundManager.__index    = SoundManager

function SoundManager.new()
    local self          = setmetatable({}, SoundManager)

    self.sounds         = {}
    self.music          = {}
    self.currentMusic   = nil

    -- SFX
    self:loadSound("qteSuccess",    "assets/sounds/SFX/SFX QTE Sukses.ogg")
    self:loadSound("qteFail",       "assets/sounds/SFX/SFX QTE Gagal.ogg")
    self:loadSound("playerStun",    "assets/sounds/SFX/SFX Tidak Stabil.ogg")
    self:loadSound("playerWalk",    "assets/sounds/SFX/SFX Langkah Kaki di Tali.ogg")
    self:loadSound("birdSpawn",     "assets/sounds/SFX/SFX Burung Terbang Rintangan.ogg")
    self:loadSound("birdHit",       "assets/sounds/SFX/SFX QTE Sukses.ogg")
    self:loadSound("click",         "assets/sounds/SFX/SFX Klik Tombol UI.ogg")

    -- Music
    self:loadMusic("gameplay",      "assets/sounds/Music/Musik Gameplay Utama.ogg")
    self:loadMusic("lose",          "assets/sounds/Music/Musik Kekalahan (Lose Phase).ogg")

    return self
end

function SoundManager:loadSound(name, path)
    local success, sound = pcall(love.audio.newSource, path, "static")
    if success then self.sounds[name] = sound end
end

function SoundManager:play(name)
    if self.sounds[name] then
        self.sounds[name]:play()
    end
end

-- Fungsi untuk memuat BGM
function SoundManager:loadMusic(name, path)
    local success, music = pcall(love.audio.newSource, path, "stream")
    if success then self.music[name] = music end
end

function SoundManager:playMusic(name, shouldLoop)
    if self.currentMusic and self.currentMusic:isPlaying() then
        self.currentMusic:stop()
    end

    if self.music[name] then
        self.currentMusic = self.music[name]
        self.currentMusic:setLooping(shouldLoop or false)
        self.currentMusic:play()
    end
end

function SoundManager:stopMusic()
    if self.currentMusic then
        self.currentMusic:stop()
    end
end

function SoundManager:setVolume(volume)
    love.audio.setVolume(volume)
end

return SoundManager

-- playState.lua

-- Import the base game state module
local gameState         =   require("src.states.gameState")
local Player            =   require("src.entities.player")
local BalanceSystem     =   require("src.systems.balanceSystem")
local ObstacleSystem    =   require("src.systems.obstacleSystem")
local BackgroundSystem  =   require("src.systems.backgroundSystem")

-- Table for the play state, inheriting from gameState
local playState     =   {}
playState.__index   =   playState

-- Constructor for the play state
function playState.new()
    local self  = setmetatable(gameState.new(), playState)

    -- Properti level
    self.rope = {
        y = 664,
        startX = 0,
        endX = VIRTUAL_WIDTH
    }

    -- Instances
    self.player             =   Player.new(50, self.rope.y)     -- Entities player
    self.balanceSystem      =   BalanceSystem.new()             -- Balance system
    self.obstacleSystem     =   ObstacleSystem.new()            -- Obstacle system
    self.backgroundSystem   =   BackgroundSystem.new()          -- Background system

    self.obstacleSystem.player = self.player

    return self
end

function playState:spawnObstacle()
	local newObstacle = {
	    type = "bird",
	    x = VIRTUAL_WIDTH + 50,                 -- Start at the right edge of the screen
        y = math.random(100, 400),              -- Random Y position within the screen height
        width = 40,
        height = 30,
        speed = 200,
        isActive = true,

        qte = {
            active = false,
            triggerDistance = 300,              -- Distance from player to trigger QTE
            hitCircleRadius = 30,
            approachCircleRadius = 150,         -- Init radius
            approachRate = 100,                 -- Speed when approaching
            isMissed = false,
        }
	}
	table.insert(self.obstacles, newObstacle)
	print("Spawn bird")
end

function playState:load()
    print("playState loaded")
end

function playState:update(dt)
    self.player:update(dt)
    self.balanceSystem:update(dt)
    self.obstacleSystem:update(dt, self.player, self.balanceSystem)
    self.backgroundSystem:update(dt)

    -- Cek kondisi menang/kalah dari sistem yang relevan
    if self.balanceSystem:isDepleted() then
        _G.SwitchState(require("src.states.loseState").new())
        return
    end

    if self.player.x > VIRTUAL_WIDTH then
        _G.SwitchState(require("src.states.winState").new())
        return
    end
end

function playState:draw()
    -- Gambar dalam urutan layer yang benar (belakang ke depan)
    self.backgroundSystem:draw()

    love.graphics.setColor(1, 1, 1)
    love.graphics.line(0, self.rope.y, VIRTUAL_WIDTH, self.rope.y)

    self.player:draw()
    self.obstacleSystem:draw()

    -- Gambar UI selalu paling depan
    self.balanceSystem:draw()
end

function playState:mousepressed(x, y, button, istouch, pressed)
	self.obstacleSystem:mousepressed(x, y, self.balanceSystem)
end

function playState:unload()
    print("playState unloaded")             -- for debugging purposes
end

function playState:keypressed(key, scancode, isrepeat)
    self.balanceSystem:keypressed(key)      -- QTE Input key
end

return playState

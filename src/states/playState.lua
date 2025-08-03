-- playState.lua

-- Import the base game state module
local gameState         =   require("src.states.gameState")
local helpers           =   require("src.utils.helpers")
local player            =   require("src.entities.player")
local BalanceSystem     =   require("src.systems.balanceSystem")
local BackgroundSystem  =   require("src.systems.BackgroundSystem")

-- Table for the play state, inheriting from gameState
local playState     =   {}
playState.__index   =   playState

-- Constructor for the play state
function playState.new()
    local self = setmetatable(gameState.new(), playState)

    self.player = player.new(50, self.ropeY)    -- Entities player

    self.rope = {
        y = 664,                                -- Posisi Y tali (dibawah kaki pemain)
        startX = 0,
        endX = VIRTUAL_WIDTH                    -- lebar jendela
    }

    -- Obstacles
    self.obstacles = {}                         -- Placeholder for obstacles, can be filled later
    self.obstacleSpawnTimer = 3                 -- Time in seconds to spawn a new obstacle
    self.obstacleSpawnInterval = 5              -- Interval for spawning obstacles

    self.balanceSystem = BalanceSystem.new()    -- Balance system
    self.backgroundSystem = BackgroundSystem.new()

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
    print("playState loaded")                   -- for debugging purposes
end

function playState:update(dt)
    gameState.update(self, dt)

    self.backgroundSystem:update(dt)            -- Update background system

    self.player:update(dt)                      -- just development update for player

    self.balanceSystem:update(dt)               -- Update balance system

    -- Lose condition
    if self.balance <= 0 then
        print("Game Over! Balance reached zero.")
        _G.SwitchState(require("src.states.loseState").new())
        return
    end

    -- Win condition
    if self.player.x > VIRTUAL_WIDTH then
        print("You win! Reached the goal.")
        -- call the win state
        _G.SwitchState(require("src.states.winState").new())
        return  -- Stop further updates
    end

    -- Obstacle Spawner
    self.obstacleSpawnTimer = self.obstacleSpawnTimer - dt
    if self.obstacleSpawnTimer <= 0 then
        self:spawnObstacle()
        self.obstacleSpawnTimer = self.obstacleSpawnInterval + math.random(-1, 1)
    end

    -- Looping for obstacles and memory management
    for i = #self.obstacles, 1, -1 do
        local obs = self.obstacles[i]
        obs.x = obs.x - obs.speed * dt

        local dist = math.abs(obs.x - self.player.x)
        if not obs.qte.active and dist < obs.qte.triggerDistance then
            obs.qte.active = true   -- Activate QTE
        end

        if obs.qte.active and not obs.qte.isMissed then
            -- Susutkan approach circle
            obs.qte.approachCircleRadius = obs.qte.approachCircleRadius - obs.qte.approachRate * dt

            -- Check condition "missed"
            if obs.qte.approachCircleRadius < obs.qte.hitCircleRadius then
                obs.qte.isMissed = true
                print("QTE Missed! Balance decreased.")
                self.balance = self.balance - 25
            end
        end

        -- Remove obstacle if it goes left off-screen
        if obs.x + obs.width < 0 then
            table.remove(self.obstacles, i)
            print("Remove bird")
        end
    end
end

function playState:draw()
    gameState.draw(self)

    -- Set background
    self.backgroundSystem:draw()

    -- Draw rope
    love.graphics.setColor(1, 1, 1)
    love.graphics.line(self.rope.startX, self.rope.y, self.rope.endX, self.rope.y)

    -- Draw player
    self.player:draw()

    -- Draw balance system
    self.balanceSystem:draw()

    -- Return color to white
    love.graphics.setColor(1, 1, 1)
end

function playState:mousepressed(x, y, button, istouch, pressed)
	-- Loop dari belakang untuk keamanan saat menghapus
	for i = #self.obstacles, 1, -1 do
        local obs = self.obstacles[i]
        -- Check only active QTA
        if obs.qte.active and not obs.qte.isMissed then
            local dist = helpers.getDistance(x, y, obs.x + obs.width/2, obs.y + obs.height/2)

            -- Check if clicked on hit circle
            if dist <= obs.qte.hitCircleRadius then
                print("HIT! obstacles removed.")
                table.remove(self.obstacles, i)
                -- add simply balance
                self.balance = self.balance + 5
                goto next_obstacle          -- next iteration
            end
        end
        ::next_obstacle::
    end
end

function playState:unload()
    print("playState unloaded")             -- for debugging purposes
end

function playState:keypressed(key, scancode, isrepeat)
    self.balanceSystem:keypressed(key)      -- QTE Input key
end

return playState

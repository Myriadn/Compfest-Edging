-- playState.lua

-- Import the base game state module
local gameState = require("src.states.gameState")
local helpers = require("src.utils.helpers")

-- Table for the play state, inheriting from gameState
local playState = {}
playState.__index = playState

-- Constructor for the play state
function playState.new()
    local self = setmetatable(gameState.new(), playState)

    -- for development
    self.player = {
        x = 50,         -- initial x position
        y = 600,        -- (y rope - tinggi pemain), contoh: 664 - 64 = 600
        width = 32,     -- width of the player
        height = 64,    -- height of the player
        speed = 100     -- movement speed in pixels per second
    }

    self.rope = {
        y = 664,                 -- Posisi Y tali (dibawah kaki pemain)
        startX = 0,
        endX = VIRTUAL_WIDTH     -- lebar jendela
    }

    -- Balancing system
    self.balance = 100          -- Initial balance value
    self.maxBalance = 100
    self.balanceDecayRate = 5   -- Rate at which balance decays per second

    -- Quick time event system
    self.balanceQTE = {
        -- Bar property
        bar = {
            x = VIRTUAL_WIDTH / 2 - 200, y = VIRTUAL_HEIGHT - 50,
            width = 400, height = 20
        },

        -- Safezone property (target)
        safeZone = {
            width = 60, height = 20
        },

        -- Moved cursor property
        cursor = {
            x = 0,               -- the X will be updated
            width = 10,
            height = 30,
            speed = 350,
            direction = 1        -- 1 for right, -1 for left
        }
    }

    -- Safezone in the middle of the bar
    self.balanceQTE.safeZone.x = self.balanceQTE.bar.x + (self.balanceQTE.bar.width - self.balanceQTE.safeZone.width) / 2
    -- Initial cursor position
    self.balanceQTE.cursor.x = self.balanceQTE.bar.x

    -- Obstacles
    self.obstacles = {}                 -- Placeholder for obstacles, can be filled later
    self.obstacleSpawnTimer = 3         -- Time in seconds to spawn a new obstacle
    self.obstacleSpawnInterval = 5      -- Interval for spawning obstacles

    return self
end

function playState:spawnObstacle()
	local newObstacle = {
	    type = "bird",
	    x = VIRTUAL_WIDTH + 50,         -- Start at the right edge of the screen
        y = math.random(100, 400),      -- Random Y position within the screen height
        width = 40,
        height = 30,
        speed = 200,
        isActive = true,

        qte = {
            active = false,
            triggerDistance = 300,          -- Distance from player to trigger QTE
            hitCircleRadius = 30,
            approachCircleRadius = 150,     -- Init radius
            approachRate = 100,             -- Speed when approaching
            isMissed = false,
        }
	}
	table.insert(self.obstacles, newObstacle)
	print("Spawn bird")
end

function playState:load()
    print("playState loaded") -- for debugging purposes
end

function playState:update(dt)
    gameState.update(self, dt)

    -- Player consistency speed (for development)
    self.player.x = self.player.x + self.player.speed * dt

    -- Turunkan keseimbangan secara perlahan
    self.balance = self.balance - self.balanceDecayRate * dt

    -- Logika gerakan cursor QTE
    local qte = self.balanceQTE
    -- Update cursor position
    qte.cursor.x = qte.cursor.x + (qte.cursor.speed * qte.cursor.direction * dt)

    -- Make cursor bounce back when it reaches the edges of the bar
    if qte.cursor.x < qte.bar.x then
        qte.cursor.x = qte.bar.x
        qte.cursor.direction = 1 -- Change direction to right
    elseif qte.cursor.x + qte.cursor.width > qte.bar.x + qte.bar.width then
        qte.cursor.x = qte.bar.x + qte.bar.width - qte.cursor.width
        qte.cursor.direction = -1 -- Change direction to left
    end

    -- Lose condition
    if self.balance <= 0 then
        print("Game Over! Balance reached zero.")
        -- call the lose state
        _G.SwitchState(require("src.states.loseState").new)
        return  -- Stop further updates
    end

    -- Win condition
    if self.player.x > VIRTUAL_WIDTH then
        print("You win! Reached the goal.")
        -- call the win state
        _G.SwitchState(require("src.states.winState").new)
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

    -- Development drawing
    -- Draw rope
    love.graphics.setColor(1, 1, 1)                 -- Reset color to white
    love.graphics.line(self.rope.startX, self.rope.y, self.rope.endX, self.rope.y)

    -- Draw player
    love.graphics.rectangle("fill", self.player.x, self.player.y, self.player.width, self.player.height)

    -- QTE testing
    local qte = self.balanceQTE

    -- Gambar bar utama
    love.graphics.setColor(0.3, 0.3, 0.3)           -- Dark gray for the bar
    love.graphics.rectangle("fill", qte.safeZone.x, qte.bar.y, qte.safeZone.width, qte.safeZone.height)

    -- Gambar safezone
    love.graphics.setColor(0.1, 0.7, 0.2)           -- Green for the safezone
    love.graphics.rectangle("fill", qte.safeZone.x, qte.bar.y, qte.safeZone.width, qte.safeZone.height)

    -- Gambar cursor
    love.graphics.setColor(1, 1, 1)                 -- White for the cursor
    love.graphics.rectangle("fill", qte.cursor.x, qte.bar.y - 5, qte.cursor.width, qte.cursor.height)

    -- Debug information Balancing
    love.graphics.print("Balance: " .. math.floor(self.balance), 10, 10)

    -- Draw obstacles
    love.graphics.setColor(1, 0.2, 0.2)             -- Red for obstacles
    for _, obs in ipairs(self.obstacles) do
        love.graphics.rectangle("fill", obs.x, obs.y, obs.width, obs.height)
    end

    -- Draw QTE obstacle
    for _, obs in ipairs(self.obstacles) do
        if obs.qte.active and not obs.qte.isMissed then
            love.graphics.setColor(1, 1, 1, 0.8)    -- Semi-transparent white
            -- Draw approach circle
            love.graphics.circle("line", obs.x + obs.width/2, obs.y + obs.height/2, obs.qte.approachCircleRadius)
            -- Draw hit circle
            love.graphics.circle("fill", obs.x + obs.width/2, obs.y + obs.height/2, obs.qte.hitCircleRadius)
        end
    end

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
                goto next_obstacle      -- next iteration
            end
        end
        ::next_obstacle::
    end
end

function playState:unload()
    print("playState unloaded") -- for debugging purposes
end

function playState:keypressed(key, scancode, isrepeat)
    -- Input system QTE
    if key == "space" then
        local qte = self.balanceQTE
        local cursorCenter = qte.cursor.x + qte.cursor.width / 2
        local safeZone = qte.safeZone

        -- Check if the cursor is within the safe zone
        if cursorCenter >= safeZone.x and cursorCenter <= safeZone.x + safeZone.width then
            print("QTE Success! Balance increased.")
            self.balance = self.balance + 20
            -- make it not exceed max balance
            if self.balance > self.maxBalance then
                self.balance = self.maxBalance
            end
        else
            print("QTE Failed! Balance decreased.")
            self.balance = self.balance - 15
        end
    end
end

return playState

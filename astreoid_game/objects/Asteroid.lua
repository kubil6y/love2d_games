require("globals")
local love = require("love")
local utils = require("utils")

function Asteroid(x, y, size, level)
	local ASTEROID_VERT = 10 -- average verticies... how many edges it will gave
	local ASTEROID_JAG = 0.4 -- asteroid jaggedness (less round)
	local ASTEROID_SPEED = math.random(50) + (level * 2)
	local MIN_ASTEROID_SIZE = math.ceil(ASTEROID_SIZE / 4)

	local vert = math.floor(math.random(ASTEROID_VERT + 1) + ASTEROID_VERT / 2)
	local offset = {}
	for _ = 1, vert + 1 do
		-- NOTE: the math.random() * ASTEROID_JAG should be like that and NOT math.random(ASTEROID_JAG)
		-- because math.random returns an INTEGER and not a FLOAT (and we want a float)
		table.insert(offset, math.random() * ASTEROID_JAG * 2 + 1 - ASTEROID_JAG)
	end

	local vel = -1
	if math.random() < 0.5 then
		vel = 1
	end

	return {
		x = x,
		y = y,
		velX = math.random() * ASTEROID_SPEED * vel,
		velY = math.random() * ASTEROID_SPEED * vel,
		radius = math.ceil(size / 2),
		angle = math.rad(math.random(math.pi)), -- angle in radians
		vert = vert, -- verticies
		offset = offset,

		draw = function(self, faded)
			local opacity = 1

			-- asteroid will be faded if game is paused
			if faded then
				opacity = 0.2
			end

			utils.setColor(186, 189, 182, opacity)

			local points = {
				self.x + self.radius * self.offset[1] * math.cos(self.angle),
				self.y + self.radius * self.offset[1] * math.sin(self.angle),
			}

			for i = 1, self.vert - 1 do
				table.insert(
					points,
					self.x + self.radius * self.offset[i + 1] * math.cos(self.angle + i * math.pi * 2 / self.vert)
				)
				table.insert(
					points,
					self.y + self.radius * self.offset[i + 1] * math.sin(self.angle + i * math.pi * 2 / self.vert)
				)
			end

			love.graphics.polygon("line", points)

			if showDebugging then
				utils.setColor(255, 0, 0)
				-- the hitbox of the asteroid
				love.graphics.circle("line", self.x, self.y, self.radius)
			end
		end,

		update = function(self, dt)
			self.x = self.x + self.velX * dt
			self.y = self.y + self.velY * dt

			-- Make sure the asteroid doesn't leave the screen
			if self.x + self.radius < 0 then
				self.x = love.graphics.getWidth() + self.radius
			elseif self.x - self.radius > love.graphics.getWidth() then
				self.x = -self.radius
			end

			if self.y + self.radius < 0 then
				self.y = love.graphics.getHeight() + self.radius
			elseif self.y - self.radius > love.graphics.getHeight() then
				self.y = -self.radius
			end
		end,

		destroy = function(self, asteroidsTable, index, game)
			if self.radius > MIN_ASTEROID_SIZE then
				-- split asteroid in half
				table.insert(asteroidsTable, Asteroid(self.x, self.y, self.radius, game.level))
				table.insert(asteroidsTable, Asteroid(self.x, self.y, self.radius, game.level))
			end
			table.remove(asteroidsTable, index)
		end,
	}
end

return Asteroid

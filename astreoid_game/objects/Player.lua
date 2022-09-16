require("globals")
local love = require("love")
local utils = require("utils")
local keys = require("keybindings")
local Lazer = require("objects.Lazer")

function Player()
	local SHIP_SIZE = 30
	local VIEW_ANGLE = math.rad(90)
	local MAX_LAZER_DISTANCE = 0.6 * love.graphics.getWidth()
	local MAX_LAZER_COUNT = 10

	return {
		x = love.graphics.getWidth() / 2,
		y = love.graphics.getHeight() / 2,
		radius = SHIP_SIZE / 2,
		angle = VIEW_ANGLE,
		rotation = 0,
		lazers = {},
		thrusting = false,
		thrust = {
			x = 0,
			y = 0,
			speed = 5,
			bigFlame = false,
			flame = 2.0,
		},

		shootLazer = function(self)
			if #self.lazers >= MAX_LAZER_COUNT then
				return
			end
			-- TODO needs tweaking
			local lazer = Lazer(self.x, self.y, self.angle)
			table.insert(self.lazers, lazer)
		end,

		destroyLazer = function(self, index)
			table.remove(self.lazers, index)
		end,

		drawFlameThrust = function(self, fillType, r, g, b)
			utils.setColor(r, g, b)
			love.graphics.polygon(
				fillType,
				self.x - self.radius * (2 / 3 * math.cos(self.angle) + 0.5 * math.sin(self.angle)),
				self.y + self.radius * (2 / 3 * math.sin(self.angle) - 0.5 * math.cos(self.angle)),
				self.x - self.radius * self.thrust.flame * math.cos(self.angle),
				self.y + self.radius * self.thrust.flame * math.sin(self.angle),
				self.x - self.radius * (2 / 3 * math.cos(self.angle) - 0.5 * math.sin(self.angle)),
				self.y + self.radius * (2 / 3 * math.sin(self.angle) + 0.5 * math.cos(self.angle))
			)
		end,

		---@param faded boolean
		draw = function(self, faded)
			local opacity = 1
			local fps -- protection for zero division (nan issue)

			if love.timer.getFPS() == 0 then
				fps = 10
			else
				fps = love.timer.getFPS()
			end

			if faded then
				opacity = 0.2
			end

			if self.thrusting then
				if not self.thrust.bigFlame then
					self.thrust.flame = self.thrust.flame - 1 / fps
					if self.thrust.flame < 1.5 then
						self.thrust.bigFlame = true
					end
				else
					self.thrust.flame = self.thrust.flame + 1 / fps
					if self.thrust.flame > 2.5 then
						self.thrust.bigFlame = false
					end
				end

				self:drawFlameThrust("fill", 255, 102, 25)
				self:drawFlameThrust("line", 255, 41, 0)
			end

			if showDebugging then
				utils.setColor(255, 0, 0)
				local len = 4
				love.graphics.rectangle("fill", self.x - len / 2, self.y - len / 2, len, len)
				-- draw collision
				love.graphics.circle("line", self.x, self.y, self.radius)
			end

			utils.setColor(255, 255, 255, opacity)
			love.graphics.polygon(
				"line",
				self.x + (4 / 3 * self.radius) * math.cos(self.angle),
				self.y - (4 / 3 * self.radius) * math.sin(self.angle),
				self.x - self.radius * (2 / 3 * math.cos(self.angle) + math.sin(self.angle)),
				self.y + self.radius * (2 / 3 * math.sin(self.angle) - math.cos(self.angle)),
				self.x - self.radius * (2 / 3 * math.cos(self.angle) - math.sin(self.angle)),
				self.y + self.radius * (2 / 3 * math.sin(self.angle) + math.cos(self.angle))
			)

			-- lazers
			for _, lazer in pairs(self.lazers) do
				lazer:draw(faded)
			end
		end,

		update = function(self, dt)
			local friction = 0.7
			-- We want to move the ship 360degrees in one second
			-- How much player should move every second
			--self.rotation = utils.degreeToRadius(360) / FPS
			self.rotation = utils.degreeToRadius(360) * dt

			if love.keyboard.isDown(keys.mv.LEFT) then
				self.angle = self.angle + self.rotation
			end
			if love.keyboard.isDown(keys.mv.RIGHT) then
				self.angle = self.angle - self.rotation
			end

			if self.thrusting then
				self.thrust.x = self.thrust.x + self.thrust.speed * math.cos(self.angle) * dt
				self.thrust.y = self.thrust.y - self.thrust.speed * math.sin(self.angle) * dt
			else
				if self.thrust.x ~= 0 or self.thrust.y ~= 0 then
					self.thrust.x = self.thrust.x - friction * self.thrust.x * dt
					self.thrust.y = self.thrust.y - friction * self.thrust.y * dt
				end
			end

			self.x = self.x + self.thrust.x
			self.y = self.y + self.thrust.y

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

			-- update lazers
			for index, lazer in pairs(self.lazers) do
				if lazer.distance > MAX_LAZER_DISTANCE and lazer.exploding == explodingEnum.notExploding then
					lazer:explode(dt)
				end

				if lazer.exploding == explodingEnum.notExploding then
					lazer:update(dt)
				elseif lazer.exploding == explodingEnum.doneExploding then
					self:destroyLazer(index)
				end
			end
		end,
	}
end

return Player

local love = require("love")
local utils = require("utils")

_G.explodingEnum = {
	notExploding = 0,
	exploding = 1,
	doneExploding = 2,
}

---@param x number
---@param y number
---@param angle number
function Lazer(x, y, angle)
	local LAZER_SPEED = 500
	local LAZER_SIZE = 3
	local EXPLODE_DURATION = 0.2

	return {
		x = x,
		y = y,
		angle = angle,
		velX = math.cos(angle) / love.timer.getFPS(),
		velY = math.sin(angle) / love.timer.getFPS(),
		distance = 0,
		exploding = explodingEnum.notExploding,
		explodingTime = 0,

		draw = function(self, faded)
			local opacity = 1

			if faded then
				opacity = 0.2
			end

			if self.exploding == explodingEnum.notExploding then
				utils.setColor(255, 255, 255, opacity)
				love.graphics.setPointSize(LAZER_SIZE)
				love.graphics.points(self.x, self.y)
			else
				utils.setColor(255, 104, 0, opacity)
				love.graphics.circle("fill", self.x, self.y, 7 * 1.5)
				utils.setColor(255, 234, 0, opacity)
				love.graphics.circle("fill", self.x, self.y, 7)
			end
		end,

		update = function(self, dt)
			local velX = math.cos(angle) * LAZER_SPEED * dt
			local velY = math.sin(angle) * -LAZER_SPEED * dt

			-- currently exploding
			if self.explodingTime > 0 then
				self.exploding = explodingEnum.exploding
			end

			self.x = self.x + velX
			self.y = self.y + velY

			if self.x < 0 then
				self.x = love.graphics.getWidth()
			elseif self.x > love.graphics.getWidth() then
				self.x = 0
			end

			if self.y < 0 then
				self.y = love.graphics.getHeight()
			elseif self.y > love.graphics.getHeight() then
				self.y = 0
			end

			self.distance = self.distance + math.sqrt(velX ^ 2 + velY ^ 2)
		end,

		explode = function(self, dt)
			self.explodeTime = math.ceil(EXPLODE_DURATION / (dt * 100))

			if self.explodeTime > EXPLODE_DURATION then
				self.exploding = explodingEnum.doneExploding
			end
		end,
	}
end

return Lazer

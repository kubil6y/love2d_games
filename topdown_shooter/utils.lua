local love = require("love")

local M = {}

function M.distanceBetween(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function M.angleBetweenAPointAndCursor(x, y)
	-- update where player faces
	local mouseX, mouseY = love.mouse.getPosition()
	return math.atan2(mouseY - y, mouseX - x)
end

function M.angleBetweenTwoPoints(x1, y1, x2, y2)
	return math.atan2((y2 - y1), (x2 - x1))
end

function M.getRandomOffScreenCoordinates(imageW, imageH, padding)
	local dice = math.random(1, 4) -- get a random direction
	local _w = love.graphics.getWidth()
	local _h = love.graphics.getHeight()
	local x, y
	if dice == 1 then -- up
		y = -padding - imageH / 2
		x = math.random(-imageW / 2 - padding, _w + padding + imageW / 2)
	elseif dice == 2 then -- down
		y = _h + padding + imageH / 2
		x = math.random(-imageW / 2 - padding, _w + padding + imageW / 2)
	elseif dice == 3 then -- left
		x = -padding - imageW / 2
		y = math.random(-padding - imageH / 2, _h + padding + imageH / 2)
	else -- right
		x = padding + imageW / 2 + _w
		y = math.random(-padding - imageH / 2, _h + padding + imageH / 2)
	end
	return x, y
end

function M.spawnZombie()
	local zombieW = sprites.zombie:getWidth()
	local zombieH = sprites.zombie:getHeight()
	local padding = math.random(0, 50)
	local _x, _y = M.getRandomOffScreenCoordinates(zombieW, zombieH, padding)
	local zombie = {
		x = _x,
		y = _y,
		speed = 100,
		dead = false,
		draw = function(self, x1, y1)
			love.graphics.draw(
				sprites.zombie,
				self.x,
				self.y,
				M.angleBetweenTwoPoints(self.x, self.y, x1, y1),
				nil,
				nil,
				sprites.zombie:getWidth() / 2,
				sprites.zombie:getHeight() / 2
			)
		end,
	}
	table.insert(zombies, zombie)
end

function M.spawnBullet()
	--local bulletW = sprites.bullet:getWidth()
	--local bulletH = sprites.bullet:getHeight()
	local bullet = {
		x = player.x,
		y = player.y,
		dead = false,
		speed = 500,
		scale = 0.5,
		width = sprites.bullet:getWidth(),
		height = sprites.bullet:getHeight(),
		direction = M.angleBetweenAPointAndCursor(player.x, player.y),
		draw = function(self)
			love.graphics.draw(
				sprites.bullet,
				self.x,
				self.y,
				nil,
				self.scale, -- sx scaleX
				self.scale, -- sy scaleY
				sprites.bullet:getWidth() / 2,
				sprites.bullet:getHeight() / 2
			)
		end,
	}
	table.insert(bullets, bullet)
end

function M.isOffScreen(x, y, imageWidth, imageHeight)
	local _w = love.graphics.getWidth()
	local _h = love.graphics.getHeight()
	if x + imageWidth < 0 or x > _w or y + imageHeight < 0 or y > _h then
		return true
	end
	return false
end

return M

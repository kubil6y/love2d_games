local M = {}

---@param radius number
function M.radiusToDegree(radius)
	return radius * 180 / math.pi
end

---@param degree number
function M.degreeToRadius(degree)
	return degree * math.pi / 180
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
function M.distanceBetweenPoints(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

---@param r number Red
---@param g number Green
---@param b number Blue
---@param alpha? number # The amount of alpha.  The alpha value will be applied to all subsequent draw operations, even the drawing of an image.
function M.setColor(r, g, b, alpha)
	alpha = alpha or 1
	love.graphics.setColor(r / 255, g / 255, b / 255, alpha)
end

function M.printFPS()
	local fps = love.timer.getFPS()
	if fps < 10 then
		M.setColor(255, 0, 0)
	else
		M.setColor(0, 255, 0)
	end
	love.graphics.print(tostring(love.timer.getFPS()), love.graphics.getWidth() - 30, 10)
	M.setColor(255, 255, 255)
end

return M

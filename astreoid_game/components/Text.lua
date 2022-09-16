local love = require("love")
local utils = require("utils")

---@alias FontSize
--- Default font size value
---
---| "p"
---| "h1"
---| "h2"
---| "h3"
---| "h4"
---| "h5"
---| "h6"
---@param text string # Text to be displayed
---@param x number # Position of text
---@param y number # Position of text
---@param fontSize? FontSize # Font size
---@param fadeIn? boolean # Should text fade in (default false)
---@param fadeOut? boolean # Should text fade in (default false)
---@param wrapWidth? number # When should text break - default: love.graphics.getWidth() [window width]
---@param align? love.AlignMode # Align text to location
---@param opacity? number
function Text(text, x, y, fontSize, fadeIn, fadeOut, wrapWidth, align, opacity)
	fontSize = fontSize or "p"
	fadeIn = fadeIn or false
	fadeOut = fadeOut or false
	wrapWidth = wrapWidth or love.graphics.getWidth()
	align = align or "left"
	opacity = opacity or 1

	local TEXT_FADE_DUR = 5

	local fonts = {
		h1 = love.graphics.newFont(60),
		h2 = love.graphics.newFont(50),
		h3 = love.graphics.newFont(40),
		h4 = love.graphics.newFont(30),
		h5 = love.graphics.newFont(20),
		h6 = love.graphics.newFont(10),
		p = love.graphics.newFont(16),
	}

	if fadeIn then
		opacity = 0.1 -- if should fade in, then start at low opacity
	end

	return {
		text = text,
		x = x,
		y = y,
		opacity = opacity,

		colors = {
			r = 255,
			g = 255,
			b = 255,
		},

		setColor = function(self, red, green, blue)
			self.colors.r = red
			self.colors.g = green
			self.colors.b = blue
		end,

		draw = function(self, tableText, index)
			if self.opacity > 0 then
				-- when pausing, the below will still fade out, it will not be paused
				if fadeIn then
					-- only render text if visible, otherwise skip it
					if self.opacity < 1 then
						self.opacity = self.opacity + (1 / TEXT_FADE_DUR / love.timer.getFPS())
					else
						fadeIn = false
					end
				elseif fadeOut then
					self.opacity = self.opacity - (1 / TEXT_FADE_DUR / love.timer.getFPS())
				end

				utils.setColor(self.colors.r, self.colors.g, self.colors.b, self.opacity)
				love.graphics.setFont(fonts[fontSize])
				love.graphics.printf(self.text, self.x, self.y, wrapWidth, align)
				love.graphics.setFont(fonts["p"])
			else
				-- remove yourself once you dissapear
				table.remove(tableText, index)
				return false
			end

			return true
		end,
	}
end

return Text

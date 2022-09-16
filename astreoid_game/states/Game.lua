local love = require("love")
local Text = require("components.Text")
local Asteroid = require("objects.Asteroid")

function Game()
	return {
		level = 1,
		state = {
			menu = false,
			paused = false,
			running = true,
			ended = false,
		},
		changeGameState = function(self, state)
			self.state.menu = state == "menu"
			self.state.paused = state == "paused"
			self.state.running = state == "running"
			self.state.ended = state == "ended"
		end,
		draw = function(self, faded)
			if faded then
				Text(
					"PAUSED",
					0,
					love.graphics.getHeight() * 0.4,
					"h1",
					false,
					false,
					love.graphics.getWidth(),
					"center"
				):draw()
			end
		end,
		startNewGame = function(self, player)
			self:changeGameState("running")
			-- TODO change asteroids
			for _ = 1, 5, 1 do
				local x = math.floor(math.random(love.graphics.getWidth()))
				local y = math.floor(math.random(love.graphics.getHeight()))
				local asteroid = Asteroid(x, y, 100, self.level)
				table.insert(asteroids, asteroid)
			end
		end,
	}
end

return Game

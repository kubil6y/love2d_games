require("globals")
local love = require("love")
local utils = require("utils")
local keys = require("keybindings")
local Player = require("objects.Player")
local Game = require("states.Game")

function love.load()
	-- make everything random
	math.randomseed(os.time())

	love.mouse.setVisible(false)
	_G.mouseX, _G.mouseY = 0, 0

	_G.player = Player()
	_G.asteroids = {}
	_G.game = Game()

	game:startNewGame(player)
end

function love.update(dt)
	mouseX, mouseY = love.mouse.getPosition()

	if game.state.running then
		player:update(dt)

		for asteroidIndex, asteroid in pairs(asteroids) do
			for lazerIndex, lazer in pairs(player.lazers) do
				-- calculate distance
				local distance = utils.distanceBetweenPoints(lazer.x, lazer.y, asteroid.x, asteroid.y)
				if distance < asteroid.radius then
					lazer:explode(dt)
					asteroid:destroy(asteroids, asteroidIndex, game)
				end
			end

			asteroid:update(dt)
		end
	end
end

function love.draw()
	utils.printFPS()

	if game.state.running or game.state.paused then
		player:draw(game.state.paused)

		for _, asteroid in pairs(asteroids) do
			asteroid:draw(game.state.paused)
		end

		game:draw(game.state.paused) -- if paused it will draw
	end
end

function love.keypressed(key)
	if game.state.running then
		if key == keys.mv.UP then
			player.thrusting = true
		end

		if key == keys.escape then
			game:changeGameState("paused")
			game:draw(true)
		end

		if key == keys.shoot then
			player:shootLazer()
		end
	elseif game.state.paused then
		if keys.escape == key then
			game:changeGameState("running")
		end
	end
end

function love.keyreleased(key)
	if key == keys.mv.UP then
		player.thrusting = false
	end
end

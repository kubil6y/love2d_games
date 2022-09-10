local love = require("love")
local utils = require("utils")

function love.load()
	math.randomseed(os.time())

	_G.keys = {
		movement = {
			UP = "e",
			DOWN = "d",
			LEFT = "s",
			RIGHT = "f",
		},
	}

	_G.gameState = 1 --{menu:1,running:2}
	_G.score = 0
	_G.maxTime = 2
	_G.timer = maxTime

	_G.myFont = love.graphics.newFont(30)

	_G.sprites = {
		background = love.graphics.newImage("sprites/background.png"),
		bullet = love.graphics.newImage("sprites/bullet.png"),
		zombie = love.graphics.newImage("sprites/zombie.png"),
		player = love.graphics.newImage("sprites/player.png"),
	}

	_G.player = {
		x = love.graphics.getWidth() / 2 - 17.5,
		y = love.graphics.getHeight() / 2 - 21.5,
		--speed = 180,
		speed = 300,
		radians = 0,
	}

	_G.zombies = {}
	_G.bullets = {}
end

function love.draw()
	love.graphics.draw(sprites.background, 0, 0)

	if gameState == 1 then
		love.graphics.setFont(myFont)
		love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
	end

	love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")

	love.graphics.draw(
		sprites.player,
		player.x,
		player.y,
		utils.angleBetweenAPointAndCursor(player.x, player.y),
		nil,
		nil,
		sprites.player:getWidth() / 2,
		sprites.player:getHeight() / 2
	)

	-- draw zombies
	for _, z in ipairs(zombies) do
		z:draw(player.x, player.y)
	end

	-- draw bullets
	for _, b in ipairs(bullets) do
		b:draw()
	end
end

function love.update(dt)
	if gameState == 2 then
		if love.keyboard.isDown(keys.movement.UP) and player.y - sprites.player:getHeight() / 2 > 0 then
			player.y = player.y - (player.speed * dt)
		end
		if
			love.keyboard.isDown(keys.movement.DOWN)
			and player.y + sprites.player:getHeight() / 2 < love.graphics.getHeight()
		then
			player.y = player.y + (player.speed * dt)
		end
		if
			love.keyboard.isDown(keys.movement.RIGHT)
			and player.x + sprites.player:getWidth() / 2 < love.graphics.getWidth()
		then
			player.x = player.x + (player.speed * dt)
		end
		if love.keyboard.isDown(keys.movement.LEFT) and player.x > sprites.player:getWidth() / 2 then
			player.x = player.x - (player.speed * dt)
		end
	end

	for _, z in ipairs(zombies) do
		local angle = utils.angleBetweenTwoPoints(z.x, z.y, player.x, player.y)
		local dx = math.cos(angle) * (z.speed * dt)
		local dy = math.sin(angle) * (z.speed * dt)
		z.x = z.x + dx
		z.y = z.y + dy

		-- check for collision
		if utils.distanceBetween(z.x, z.y, player.x, player.y) < 30 then
			--remove all zombies (game ends)
			for k in ipairs(zombies) do
				zombies[k] = nil
				gameState = 1
				player.x = love.graphics.getWidth() / 2
				player.y = love.graphics.getHeight() / 2
			end
		end
	end

	for i, b in ipairs(bullets) do
		b.x = b.x + (b.speed * dt) * math.cos(b.direction)
		b.y = b.y + (b.speed * dt) * math.sin(b.direction)
	end

	-- remove offscreen bullets
	for i = #bullets, 1, -1 do
		local b = bullets[i]
		if utils.isOffScreen(b.x, b.y, b.width * b.scale, b.height * b.scale) then
			table.remove(bullets, i)
		end
	end

	for _, z in ipairs(zombies) do
		for _, b in ipairs(bullets) do
			if utils.distanceBetween(z.x, z.y, b.x, b.y) < 20 then
				b.dead = true
				z.dead = true
				score = score + 1
			end
		end
	end

	for i = #bullets, 1, -1 do
		local b = bullets[i]
		if b.dead then
			table.remove(bullets, i)
		end
	end

	for i = #zombies, 1, -1 do
		local z = zombies[i]
		if z.dead then
			table.remove(zombies, i)
		end
	end

	if gameState == 2 then
		timer = timer - dt
		if timer <= 0 then
			utils.spawnZombie()
			maxTime = 0.97 * maxTime -- shorten timer
			timer = maxTime
		end
	end
end

function love.mousepressed(x, y, button)
	if button == 1 and gameState == 2 then -- left click
		utils.spawnBullet()
	elseif gameState == 1 and button == 1 then
		gameState = 2
		restartGame()
	end
end

function restartGame()
	maxTime = 2
	timer = maxTime
	score = 0
end

--function love.keypressed(key)
--if key == "space" then
--utils.spawnZombie()
--end
--end

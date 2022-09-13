local love = require("love")

function love.load()
	local anim8_ok, anim8 = pcall(require, "libs.anim8.anim8")
	if not anim8_ok then
		error("error loading anim8")
	end
	local wf_ok, wf = pcall(require, "libs.windfield.windfield")
	if not wf_ok then
		error("error loading windfield")
	end
	sti_ok, sti = pcall(require, "libs.Simple-Tiled-Implementation.sti")
	if not sti_ok then
		error("error loading tile loader")
	end
	cameraFile_ok, cameraFile = pcall(require, "libs.hump.camera")
	if not cameraFile then
		error("error loading camera file")
	end

	cam = cameraFile()

	_G.keys = {
		reload = "r",
		mv = {
			up = "e",
			down = "d",
			left = "s",
			right = "f",
		},
	}

	_G.sprites = {
		playerSheet = love.graphics.newImage("sprites/playerSheet.png"),
		enemySheet = love.graphics.newImage("sprites/enemySheet.png"),
		background = love.graphics.newImage("sprites/background.png"),
	}

	_G.sounds = {
		jump = love.audio.newSource("audio/jump.wav", "static"),
		music = love.audio.newSource("audio/music.mp3", "stream"),
	}
	sounds.music:setLooping(true)
	sounds.music:setVolume(0.1)
	sounds.jump:setVolume(0.1)

	sounds.music:play()

	_G.C = {
		Player = "Player",
		Platform = "Platform",
		Danger = "Danger",
	}

	_G.levels = {
		level1 = "level1",
		level2 = "level2",
	}
	_G.saveData = {
		currentLevel = levels.level1,
	}

	if love.filesystem.getInfo("data.lua") then
		local data = love.filesystem.load("data.lua")
		data() -- it will fill our saveData table
	end

	local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
	local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

	_G.animations = {
		idle = anim8.newAnimation(grid("1-15", 1), 0.05),
		jump = anim8.newAnimation(grid("1-7", 2), 0.05),
		run = anim8.newAnimation(grid("1-15", 3), 0.05),
		enemy = anim8.newAnimation(enemyGrid("1-2", 1), 0.03),
	}

	_G.platforms = {}
	_G.flag = {
		x = 0,
		y = 0,
	}

	-- Physics Object = Collider {body,fixture,shape}
	-- Collider types {dynamic,static,kinematic}
	-- Colliders have x,y positions from center unlike images
	world = wf.newWorld(0, 800, false)
	world:setQueryDebugDrawing(true)

	-- Add Collision classes for setting up custom interactions
	world:addCollisionClass(C.Platform)
	world:addCollisionClass(C.Player, {
		--ignores = { "Platform" },
	})
	world:addCollisionClass(C.Danger)

	require("player")
	require("enemy")
	require("libs.show")

	-- below gameplay window
	dangerZone = world:newRectangleCollider(-500, 800, 5000, 50, {
		collision_class = C.Danger,
	})
	dangerZone:setType("static")

	loadMap(saveData.currentLevel)
end

function love.update(dt)
	world:update(dt)
	gameMap:update(dt)
	updatePlayer(dt)
	updateEnemies(dt)

	local px, py = player:getPosition()
	cam:lookAt(px, love.graphics.getHeight() / 2)

	-- query for ending level
	local colliders = world:queryCircleArea(flag.x, flag.y, 10, { C.Player })
	if #colliders > 0 then
		if saveData.currentLevel == levels.level1 then
			loadMap(levels.level2)
		else
			loadMap(levels.level1)
		end
	end
end

function love.draw()
	-- after camera is attached, everything will be
	-- drawn reference to the camera.
	-- referenced items should be between attach/detach

	love.graphics.draw(sprites.background, 0, 0)
	cam:attach()
	gameMap:drawLayer(gameMap.layers["Tile Layer 1"])
	--world:draw() -- enable hitboxes
	drawPlayer()
	drawEnemies()

	cam:detach()
end

function love.keypressed(key)
	if key == keys.mv.up then
		if player.isGrounded then
			player:applyLinearImpulse(0, -4000)
			sounds.jump:play()
		end
	end
end

function love.mousepressed(x, y, button)
	if button == 1 then
		local colliders = world:queryCircleArea(x, y, 200, { C.Platform, C.Danger })
		for _, c in ipairs(colliders) do
			c:destroy()
		end
	end
end

function spawnPlatform(x, y, width, height)
	if width > 0 and height > 0 then
		local platform = world:newRectangleCollider(x, y, width, height, {
			collision_class = C.Platform,
		})
		platform:setType("static")
		table.insert(platforms, platform)
	end
end

function destroyAll()
	for i = #platforms, 1, -1 do
		if platforms[i] ~= nil then
			platforms[i]:destroy()
		end
		table.remove(platforms, i)
	end

	for i = #enemies, 1, -1 do
		if enemies[i] ~= nil then
			enemies[i]:destroy()
		end
		table.remove(enemies, i)
	end
end

function loadMap(level)
	saveData.currentLevel = level
	-- save data using file system + show.lua
	love.filesystem.write("data.lua", table.show(saveData, "saveData"))
	destroyAll()
	_G.gameMap = sti("maps/" .. level .. ".lua")
	for _, obj in pairs(gameMap.layers["Start"].objects) do
		playerStartX = obj.x
		playerStartY = obj.y
	end
	player:setPosition(playerStartX, playerStartY)
	-- Load Platforms
	for _, obj in pairs(gameMap.layers["Platforms"].objects) do
		spawnPlatform(obj.x, obj.y, obj.width, obj.height)
	end

	-- Load Enemies
	for _, obj in pairs(gameMap.layers["Enemies"].objects) do
		spawnEnemy(obj.x, obj.y)
	end

	for _, obj in pairs(gameMap.layers["Flag"].objects) do
		flag.x = obj.x
		flag.y = obj.y
	end
end

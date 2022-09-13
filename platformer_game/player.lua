playerStartX = 100
playerStartY = 100

player = world:newRectangleCollider(playerStartX, playerStartY, 40, 100, {
	collision_class = C.Player,
})

player.speed = 240 -- custom property (player is just a table)
player:setFixedRotation(true) -- disable rotation
player.animation = animations.idle
player.isMoving = false
player.isGrounded = true
player.direction = 1 -- {-1:left, 1:right}

function updatePlayer(dt)
	if player.body then
		local px, py = player:getPosition()
		player.isMoving = false

		-- check if player is gounded
		local colliders = world:queryRectangleArea(player:getX() - 20, player:getY() + 50, 40, 2, { C.Platform })
		if #colliders > 0 then
			player.isGrounded = true
		else
			player.isGrounded = false
		end

		if love.keyboard.isDown(keys.mv.left) then
			player:setX(px - player.speed * dt)
			player.isMoving = true
			player.direction = -1
		end
		if love.keyboard.isDown(keys.mv.right) then
			player:setX(px + player.speed * dt)
			player.isMoving = true
			player.direction = 1
		end

		if player:enter(C.Danger) then
			player:setPosition(playerStartX, playerStartY)
		end
	end

	if player.isGrounded then
		if player.isMoving then
			player.animation = animations.run
		else
			player.animation = animations.idle
		end
	else
		player.animation = animations.jump
	end

	player.animation:update(dt)
end

function drawPlayer()
	if player.body then
		local px, py = player:getPosition()
		player.animation:draw(sprites.playerSheet, px, py, nil, 0.25 * player.direction, 0.25, 130, 300) -- second .25 is because we do not want to flip the image with directions
	end
end

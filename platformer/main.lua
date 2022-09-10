function love.load()
	local wf_ok, wf = pcall(require, "libraries.windfield.windfield")
	if not wf_ok then
		print("windfield is not required")
		return
	end

	world = wf.newWorld(0, 800) -- parameters gravity

	player = world:newRectangleCollider(360, 100, 80, 80)
	platform = world:newRectangleCollider(250, 400, 300, 100)
end

function love.update(dt)
	world:update(dt)
end

function love.draw()
	world:draw()
end

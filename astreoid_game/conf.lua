local love = require("love")

function love.conf(app)
	app.window.x = 50
	app.window.y = 80
	app.window.width = 1280 -- 16x9
	app.window.height = 720
	app.window.title = "Astreoids"
end

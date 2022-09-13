local love = require("love")

function love.conf(t)
	-- FIXME remove these later
	t.window.x = 100
	t.window.y = 50
	t.window.height = 768
end

-- NOTE:
-- Default window size for love games is 800px wide, 600px high.
-- Tile maps file type should be CSV.

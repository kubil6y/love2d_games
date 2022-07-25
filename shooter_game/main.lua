require("helpers")

function love.load()
  Score = 0
  Timer = 10
  GameState = 0

  GameFont = love.graphics.newFont(30)
  W = love.graphics.getWidth()
  H = love.graphics.getHeight()
  love.mouse.setVisible(false) -- hide mouse

  -- Target (Enemy)
  Target = {}
  Target.x = 300
  Target.y = 300
  Target.radius = 50

  Sprites = {}
  Sprites.sky = love.graphics.newImage("sprites/sky.png")
  Sprites.target = love.graphics.newImage("sprites/target.png")
  Sprites.crosshairs = love.graphics.newImage("sprites/crosshairs.png")
end

function love.update(dt)
  if GameState == 1 then
    if Timer > 0 then
      Timer = Timer - dt
    end

    if Timer < 0 then
      Timer = 0
      GameState = 0
    end
  end
end

function love.draw()
  love.graphics.setColor(1, 0, 0)
  love.graphics.circle("fill", Target.x, Target.y, Target.radius)


  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(GameFont)
  love.graphics.draw(Sprites.sky, 0, 0)
  love.graphics.print("Timer: " .. math.ceil(Timer), W / 2 - 100, 0)
  love.graphics.print("Score: " .. Score, 0, 0)

  if GameState == 1 then
    love.graphics.draw(Sprites.target, Target.x - Target.radius, Target.y - Target.radius)
  end

  if GameState == 0 then
    love.graphics.print("Click mouse1 to start!", W / 2 - 160, H / 2)
  end

  love.graphics.draw(Sprites.crosshairs, love.mouse.getX() - 20, love.mouse.getY() - 20)
end

function love.mousepressed(x, y, button, istouch, presses)
  if button == 1 and GameState == 1 then
    if IsInCircle(Target, x, y) and Timer > 0 then
      IncreaseScore(1)
      ChangeCirclePositionRandomly(Target)
    end
  elseif button == 1 and GameState == 0 then
    GameState = 1
    ResetGameState()
  end
end

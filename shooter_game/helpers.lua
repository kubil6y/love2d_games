-- IsInCircle returns if a point is in circle
function IsInCircle(C, x, y)
  return DistanceBetween(C.x, C.y, x, y) < C.radius
end

-- DistanceBetween returns distance between two points
function DistanceBetween(x1, y1, x2, y2)
  return math.sqrt(math.pow((x1 - x2), 2) + math.pow((y1 - y2), 2))
end

function IncreaseScore(n)
  Score = Score + n
end

function ChangeCirclePositionRandomly(C)
  C.x = math.random(C.radius, math.floor(W - C.radius))
  C.y = math.random(C.radius, math.floor(H - C.radius))
end

function ResetGameState()
  Timer = 10
  Score = 0
end

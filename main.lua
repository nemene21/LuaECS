require "ecs"

function love.load()
  RegisterComp("Position", function(ent, x, y)
    ent.x = x
    ent.y = y
  end)

  RegisterComp("Move", function(ent, vx, vy)
    ent.vx = vx or 0
    ent.vy = vy or 0
  end)

  for _ = 1, 200000 do
    -- Entity creation and component adding
    local entity = {}
    AddComp(
      entity, "Position",
      love.math.random() * 1280, love.math.random() * 720)

    AddComp(
      entity, "Move",
      love.math.random(-100, 100), love.math.random(-100, 100))
  end

  DrawSys = function()
    for _, ent in Query("Position") do
      love.graphics.points(ent.x, ent.y)
    end
  end

  MoveSys = function()
    local delta = love.timer.getDelta()
    for _, ent in Query("Move") do
      -- Move
      ent.x = ent.x + ent.vx * delta
      ent.y = ent.y + ent.vy * delta

      -- Bounce
      if ent.x < 0 or ent.x > 1280 then
        ent.vx = -ent.vx
        ent.x = ent.x + ent.vx * delta * 1.001
      end
      if ent.y < 0 or ent.y > 1280 then
        ent.vy = -ent.vy
        ent.y = ent.y + ent.vy * delta * 1.001
      end
    end
  end

  love.window.setMode(1280, 720)
end

function love.update()
  RunSystem(MoveSys)
  love.window.setTitle(love.timer.getFPS())
end

function love.draw()
  RunSystem(DrawSys)
end


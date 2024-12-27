local Animations = {
  clearingLines = {},
  particleSystems = {},
  timer = 0
}

function Animations:createParticleSystem(x, y)
  local ps = love.graphics.newParticleSystem(
    love.graphics.newCanvas(2, 2), 50
  )

  -- Draw white pixel on canvas
  love.graphics.setCanvas(ps:getTexture())
  love.graphics.clear()
  love.graphics.setColor(1, 0.5, 0.5, 1)
  love.graphics.rectangle('fill', 0, 0, 2, 2)
  love.graphics.setCanvas()

  local maxLifetime = 0.6

  -- Configure for explosion effect
  ps:setParticleLifetime(0.3, maxLifetime) -- Shorter lifetime
  ps:setEmissionRate(0)                    -- Don't emit continuously
  ps:setSizeVariation(0.5)
  ps:setSizes(2, 0.5)                      -- Start bigger, end smaller
  ps:setSpeed(50, 100)                     -- Particles shoot out faster
  ps:setSpread(2 * math.pi)                -- Spread in all directions
  ps:setLinearDamping(1)                   -- Slow down over time
  ps:setLinearAcceleration(0, 0, 0, 0)     -- No constant acceleration
  ps:setColors(
    1, 0.8, 0.8, 1,                        -- "Red-ish"
    1, 0.8, 0.8, 0.7,                      -- "Red-ish" transparent
    1, 0.8, 0.8, 0                         -- White transparent
  )

  -- Emit all particles at once
  ps:emit(50)

  table.insert(self.particleSystems, {
    system = ps,
    x = x,
    y = y,
    lifetime = maxLifetime
  })
end

function Animations:addClearingLine(y)
  table.insert(self.clearingLines, {
    y = y,
    alpha = 1,
    timer = 0
  })

  -- Create particle effects for the entire line
  for x = 1, Constants.GRID_X_CELLS do
    self:createParticleSystem(
      Constants.GAME_PADDING_X + x * Constants.CELL_SIZE - Constants.CELL_SIZE / 2,
      Constants.GAME_PADDING_Y + y * Constants.CELL_SIZE - Constants.CELL_SIZE / 2
    )
  end
end

function Animations:update(dt)
  -- Update clearing lines
  for i = #self.clearingLines, 1, -1 do
    local line = self.clearingLines[i]
    line.timer = line.timer + dt
    line.alpha = 1 - (line.timer / Constants.CLEAR_ANIMATION_DURATION)

    if line.timer >= Constants.CLEAR_ANIMATION_DURATION then
      table.remove(self.clearingLines, i)
    end
  end

  -- Update particle systems
  for i = #self.particleSystems, 1, -1 do
    local ps = self.particleSystems[i]
    ps.system:update(dt)
    ps.lifetime = ps.lifetime - dt

    if ps.lifetime <= 0 then
      table.remove(self.particleSystems, i)
    end
  end
end

function Animations:draw()
  -- Draw clearing lines
  for _, line in ipairs(self.clearingLines) do
    love.graphics.setColor(1, 1, 1, line.alpha)
    love.graphics.rectangle(
      'fill',
      Constants.GAME_PADDING_X,
      Constants.GAME_PADDING_Y + (line.y - 1) * Constants.CELL_SIZE,
      Constants.GRID_X_CELLS * Constants.CELL_SIZE,
      Constants.CELL_SIZE
    )
  end

  -- Draw particle systems
  love.graphics.setColor(1, 1, 1, 1)
  for _, ps in ipairs(self.particleSystems) do
    love.graphics.draw(ps.system, ps.x, ps.y)
  end
end

function Animations:isAnimating()
  return #self.clearingLines > 0
end

return Animations

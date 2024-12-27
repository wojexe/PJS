package.path = package.path ..
    ";/opt/homebrew/share/lua/5.4/?.lua;/opt/homebrew/share/lua/5.4/?/init.lua;/Users/wojexe/.luarocks/share/lua/5.4/?.lua;/Users/wojexe/.luarocks/share/lua/5.4/?/init.lua"
package.cpath = package.cpath .. ";/opt/homebrew/lib/lua/5.4/?.so;/Users/wojexe/.luarocks/lib/lua/5.4/?.so"

Constants = require('src.constants')
Animations = require('src.animations')

local game = require('src.game')

local fallTimer = 0

debug = {}

function love.load()
  if love.system.getOS() == 'iOS' or love.system.getOS() == 'Android' then
    Constants:initializeMobileSettings()
  end

  love.window.setMode(
    Constants.WINDOW_WIDTH, Constants.WINDOW_HEIGHT,
    { highdpi = true }
  )

  game:initialize()
end

function love.update(dt)
  game.timer:update(dt)

  if game.menu.active then
    game.menu:update(dt)
    return
  end

  Animations:update(dt)

  if not game.gameOver and
      not Animations:isAnimating() then
    fallTimer = fallTimer + dt
    if fallTimer >= game:fallSpeed() then
      fallTimer = 0
      game:tick()
    end
  end
end

function love.keypressed(key)
  game:handleInput(key)
end

-- Touch controls variables
local touchStartX = 0
local touchStartY = 0
local touchStartTime = 0

local swipeThreshold = 30
local holdThreshhold = 0.3

function love.touchpressed(id, x, y)
  touchStartX = x
  touchStartY = y
  touchStartTime = love.timer.getTime()
end

function love.touchreleased(id, x, y)
  local dx = x - touchStartX
  local dy = y - touchStartY
  local touchDuration = love.timer.getTime() - touchStartTime

  table.insert(debug, 1, "dx: " .. dx)
  table.insert(debug, 2, "dy: " .. dy)
  table.insert(debug, 3, "duration: " .. touchDuration)

  if touchDuration > holdThreshhold then
    game:handleTouch('hold')
    return
  end

  -- Swipe detection
  if math.abs(dx) > swipeThreshold then
    if dx > 0 then
      game:handleTouch('right')
    else
      game:handleTouch('left')
    end

    return
  end

  if math.abs(dy) > swipeThreshold then
    if dy > 0 then
      game:handleTouch('down')
    else
      game:handleTouch('up')
    end

    return
  end

  -- No swipe detected (must be tap or hold)
  if touchDuration < holdThreshhold then
    table.insert(debug, 4, "tap")
    game:handleTouch('tap')
  else
    table.insert(debug, 4, "hold")
    game:handleTouch('hold')
  end
end

function love.draw()
  love.graphics.setBackgroundColor(Constants.COLORS.BACKGROUND)

  drawGrid()
  drawPiece()

  Animations:draw()

  drawUI()

  -- debugStuff()
end

function drawGrid()
  for y = 1, Constants.GRID_Y_CELLS do
    for x = 1, Constants.GRID_X_CELLS do
      love.graphics.rectangle('line',
        (x - 1) * Constants.CELL_SIZE + Constants.GAME_PADDING_X,
        (y - 1) * Constants.CELL_SIZE + Constants.GAME_PADDING_Y,
        Constants.CELL_SIZE,
        Constants.CELL_SIZE)

      if game.grid[y][x] then
        love.graphics.setColor(Constants.COLORS[game.grid[y][x]])

        love.graphics.rectangle('fill',
          (x - 1) * Constants.CELL_SIZE + Constants.GAME_PADDING_X,
          (y - 1) * Constants.CELL_SIZE + Constants.GAME_PADDING_Y,
          Constants.CELL_SIZE,
          Constants.CELL_SIZE)

        love.graphics.setColor(Constants.COLORS.UI_TEXT)
      end
    end
  end
end

function drawPiece()
  love.graphics.setColor(Constants.COLORS[game.currentPiece.type])

  for y = 1, #game.currentPiece.shape do
    for x = 1, #game.currentPiece.shape[y] do
      if game.currentPiece.shape[y][x] == 1 then
        love.graphics.rectangle('fill',
          (game.currentPiece.x + x - 2) * Constants.CELL_SIZE + Constants.GAME_PADDING_X,
          (game.currentPiece.y + y - 2) * Constants.CELL_SIZE + Constants.GAME_PADDING_Y,
          Constants.CELL_SIZE,
          Constants.CELL_SIZE)
      end
    end
  end
end

function drawUI()
  love.graphics.setColor(Constants.COLORS.UI_TEXT)

  local font = love.graphics.getFont()

  local scoreText = "Score: " .. game.score
  local levelText = "Level: " .. game.level

  love.graphics.print(
    scoreText,
    Constants.GAME_PADDING_X,
    Constants.GAME_PADDING_Y - 5 - font:getHeight()
  )

  love.graphics.print(
    levelText,
    Constants.GAME_WIDTH - font:getWidth(levelText) + Constants.GAME_PADDING_X,
    Constants.GAME_PADDING_Y - 5 - font:getHeight()
  )

  if game.gameOver then
    local gameOverText = Constants.TEXT.GAME_OVER

    local gameOverX = Constants.WINDOW_WIDTH / 2 - font:getWidth(gameOverText) / 2
    local gameOverY = Constants.WINDOW_HEIGHT / 2 - font:getHeight()

    love.graphics.setColor({ 1, 0, 0, 0.8 })

    love.graphics.rectangle(
      "fill",
      gameOverX - 10, gameOverY - 10,
      font:getWidth(gameOverText) + 20, font:getHeight() * 2 + 20
    )

    love.graphics.setColor(Constants.COLORS.UI_TEXT)
    love.graphics.print(gameOverText, gameOverX, gameOverY)
  end

  game.menu:draw()
end

function debugStuff()
  local r, g, b, a = love.graphics.getColor()

  love.graphics.setColor(1, 0, 0, 0.8)
  love.graphics.rectangle(
    'fill',
    0, Constants.WINDOW_HEIGHT / 2,
    Constants.WINDOW_WIDTH / 2, Constants.WINDOW_HEIGHT / 2
  )

  love.graphics.setColor(Constants.COLORS.UI_TEXT)
  for i, message in ipairs(debug) do
    love.graphics.print(message, 0, Constants.WINDOW_HEIGHT / 2 + (i - 1) * 20)
  end

  love.graphics.setColor(r, g, b, a)
end

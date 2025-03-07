local Constants = require 'src.constants'
local Utils = require 'src.utils'

local Animations = require 'src.animations'

local Game = {
  menu = require 'src.menu',
  sounds = require 'src.sounds',
  timer = require('lib.hump.timer').new()
}

function Game:initialize()
  self.grid = {}
  self.currentPiece = {}
  self.score = 0
  self.level = 1
  self.gameOver = false

  self.sounds:initialize()
  self.menu:initialize(self)

  if not self.sounds.library.background:isPlaying() then
    self.sounds.library.background:play()
  end

  self:clearGrid()
  self:spawnNewPiece()
end

function Game:clearGrid()
  self.grid = {}
  for row = 1, Constants.GRID_Y_CELLS do
    self.grid[row] = {}
    for col = 1, Constants.GRID_X_CELLS do
      self.grid[row][col] = nil
    end
  end
end

function Game:spawnNewPiece()
  local shapes = Utils:getKeys(Constants.SHAPES)
  local randomShape = shapes[love.math.random(#shapes)]

  self.currentPiece = {
    shape = Constants.SHAPES[randomShape][1],
    type = randomShape,
    x = math.floor(Constants.GRID_X_CELLS / 2) -
        math.floor(#Constants.SHAPES[randomShape][1][1] / 2),
    y = 1
  }
end

function Game:tick()
  if self:canMove(self.currentPiece.x, self.currentPiece.y + 1) then
    self.currentPiece.y = self.currentPiece.y + 1
  else
    self:lockPiece()
    self:clearLines()
    self:spawnNewPiece()
    if not self:canMove(self.currentPiece.x, self.currentPiece.y) then
      self.gameOver = true
    end
  end
end

function Game:handleInput(key)
  if self.menu.active then
    self.menu:handleInput(key)
    return
  end

  if key == Constants.KEYS.TOGGLE_MENU then
    self.menu:show('pause')
    return
  end

  if self.gameOver then
    if key == Constants.KEYS.RESTART then
      self:initialize()
    end
    return
  end

  if key == Constants.KEYS.MOVE_LEFT and
      self:canMove(self.currentPiece.x - 1, self.currentPiece.y) then
    self.currentPiece.x = self.currentPiece.x - 1
    self.sounds:play('move')
  elseif key == Constants.KEYS.MOVE_RIGHT and
      self:canMove(self.currentPiece.x + 1, self.currentPiece.y) then
    self.currentPiece.x = self.currentPiece.x + 1
    self.sounds:play('move')
  elseif key == Constants.KEYS.SOFT_DROP then
    self:tick()
    self.sounds:play('move')
  elseif key == Constants.KEYS.ROTATE then
    local didRotate = self:rotatePiece()
    if didRotate and self.currentPiece.type ~= 'O' then self.sounds:play('rotate') end
  elseif key == Constants.KEYS.HARD_DROP then
    while self:canMove(self.currentPiece.x, self.currentPiece.y + 1) do
      self.currentPiece.y = self.currentPiece.y + 1
    end
    self:tick()
    self.sounds:play('drop')
  end
end

function Game:handleTouch(action)
  if self.menu.active then
    self.menu:handleTouch(action)
    return
  end

  if action == 'hold' then
    self.menu:show('pause')
    return
  end

  if self.gameOver then
    if action == 'tap' then
      self:initialize()
    end
    return
  end

  if action == 'left' and
      self:canMove(self.currentPiece.x - 1, self.currentPiece.y) then
    self.currentPiece.x = self.currentPiece.x - 1
    self.sounds:play('move')
  elseif action == 'right' and
      self:canMove(self.currentPiece.x + 1, self.currentPiece.y) then
    self.currentPiece.x = self.currentPiece.x + 1
    self.sounds:play('move')
  elseif action == 'down' then
    self:tick()
    self.sounds:play('move')
  elseif action == 'up' then
    while self:canMove(self.currentPiece.x, self.currentPiece.y + 1) do
      self.currentPiece.y = self.currentPiece.y + 1
    end
    self:tick()
    self.sounds:play('drop')
  elseif action == 'tap' then
    local didRotate = self:rotatePiece()
    if didRotate and self.currentPiece.type ~= 'O' then self.sounds:play('rotate') end
  end
end

function Game:canMove(newX, newY)
  for y = 1, #self.currentPiece.shape do
    for x = 1, #self.currentPiece.shape[y] do
      if self.currentPiece.shape[y][x] == 1 then
        local testX = newX + x - 1
        local testY = newY + y - 1

        if testX < 1 or
            testX > Constants.GRID_X_CELLS or
            testY < 1 or
            testY > Constants.GRID_Y_CELLS or
            self.grid[testY][testX] then
          return false
        end
      end
    end
  end
  return true
end

function Game:lockPiece()
  for y = 1, #self.currentPiece.shape do
    for x = 1, #self.currentPiece.shape[y] do
      if self.currentPiece.shape[y][x] == 1 then
        local gridY = self.currentPiece.y + y - 1
        if gridY > 0 then
          self.grid[gridY][self.currentPiece.x + x - 1] = self.currentPiece.type
        end
      end
    end
  end
end

function Game:clearLines()
  local linesToClear = {}

  -- Check for complete lines
  for y = 1, Constants.GRID_Y_CELLS do
    local complete = true
    for x = 1, Constants.GRID_X_CELLS do
      if not self.grid[y][x] then
        complete = false
        break
      end
    end

    if complete then
      table.insert(linesToClear, y)
      Animations:addClearingLine(y)
    end
  end

  if #linesToClear > 0 then
    self.sounds:play('clear')

    -- Wait for animation to complete before removing lines
    self.timer:after(Constants.CLEAR_ANIMATION_DURATION, function()
      for _, y in pairs(linesToClear) do
        table.remove(self.grid, y)

        -- Add new empty line at top
        table.insert(self.grid, 1, {})
        for x = 1, Constants.GRID_X_CELLS do
          self.grid[1][x] = nil
        end
      end

      -- Update score and level
      local points = #linesToClear * 100

      self.score = self.score + points
      self.level = math.floor(self.score / 1000) + 1
    end)
  end
end

function Game:rotatePiece()
  local rotated = {}
  local size = #self.currentPiece.shape

  for y = 1, size do
    rotated[y] = {}
    for x = 1, size do
      rotated[y][x] = self.currentPiece.shape[size - x + 1][y]
    end
  end

  local oldShape = self.currentPiece.shape
  self.currentPiece.shape = rotated

  if not self:canMove(self.currentPiece.x, self.currentPiece.y) then
    self.currentPiece.shape = oldShape

    return false
  end

  return true
end

function Game:fallSpeed()
  return Constants.INITIAL_FALL_SPEED -
      (self.level - 1) * Constants.LEVEL_SPEED_INCREASE
end

return Game

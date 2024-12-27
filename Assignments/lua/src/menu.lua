local Constants = require 'src.constants'

local JSON = require 'lib.json'

local Menu = {
  game = nil,

  active = false,
  currentMenu = nil,
  messageText = nil,
  messageTimer = 0,
  menus = {}
}

function Menu:initialize(game)
  self.game = game
end

-- Main pause menu definition
Menu.menus.pause = {
  title = "PAUSE",
  options = {}, -- Will be populated dynamically
  selected = 1,
  onShow = function(self)
    self.options = {
      { text = "Resume Game", action = function() Menu:close() end },
      { text = "Save Game",   action = function() Menu:show('save') end },
      { text = "Load Game",   action = function() Menu:show('load') end }
    }

    if not Constants.MOBILE then
      table.insert(self.options, { text = "Exit Game", action = function() love.event.quit() end })
    end
  end
}

-- Save menu definition
Menu.menus.save = {
  title = "SAVE GAME",
  options = {}, -- Will be populated dynamically
  selected = 1,
  onShow = function(self)
    self.options = {}
    local saves = Menu:getSaveSlots()

    for i = 1, Constants.MAX_SAVE_SLOTS do
      local slotText = "Slot " .. i
      if saves[i] then
        slotText = slotText .. " (" .. os.date("%Y-%m-%d %H:%M:%S", saves[i].modtime) .. ")"
      else
        slotText = slotText .. " (Empty)"
      end

      table.insert(self.options, {
        text = slotText,
        action = function()
          Menu:saveGame(i)
          Menu:show('pause')
        end
      })
    end

    table.insert(self.options, {
      text = "Back",
      action = function() Menu:show('pause') end
    })
  end
}

-- Load menu definition
Menu.menus.load = {
  title = "LOAD GAME",
  options = {}, -- Will be populated dynamically
  selected = 1,
  onShow = function(self)
    self.options = {}
    local saves = Menu:getSaveSlots()

    for i = 1, Constants.MAX_SAVE_SLOTS do
      local slotText = "Slot " .. i
      if saves[i] then
        slotText = slotText .. " (" .. os.date("%Y-%m-%d %H:%M:%S", saves[i].modtime) .. ")"
        table.insert(self.options, {
          text = slotText,
          action = function()
            Menu:loadGame(i)
            Menu:close()
          end
        })
      end
    end

    table.insert(self.options, {
      text = "Back",
      action = function() Menu:show('pause') end
    })
  end
}

function Menu:show(menuName)
  self.active = true
  self.currentMenu = self.menus[menuName]
  self.currentMenu.selected = 1
  if self.currentMenu.onShow then
    self.currentMenu:onShow()
  end
end

function Menu:close()
  self.active = false
  self.currentMenu = nil
end

function Menu:update(dt)
  if self.messageText then
    self.messageTimer = self.messageTimer - dt
    if self.messageTimer <= 0 then
      self.messageText = nil
    end
  end
end

function Menu:showMessage(text, duration)
  self.messageText = text
  self.messageTimer = duration or Constants.MESSAGE_DISPLAY_TIME
end

function Menu:handleInput(key)
  if key == 'up' then
    self.currentMenu.selected = self.currentMenu.selected - 1
    if self.currentMenu.selected < 1 then
      self.currentMenu.selected = #self.currentMenu.options
    end
  elseif key == 'down' then
    self.currentMenu.selected = self.currentMenu.selected + 1
    if self.currentMenu.selected > #self.currentMenu.options then
      self.currentMenu.selected = 1
    end
  elseif key == 'return' or key == 'space' then
    local selectedOption = self.currentMenu.options[self.currentMenu.selected]
    if selectedOption and selectedOption.action then
      selectedOption.action()
    end
  elseif key == 'escape' then
    if self.currentMenu == self.menus.pause then
      self:close()
    else
      self:show('pause')
    end
  end
end

function Menu:handleTouch(action)
  if action == 'up' then
    self:handleInput('up')
  elseif action == 'down' then
    self:handleInput('down')
  elseif action == 'tap' then
    self:handleInput('return')
  elseif action == 'hold' then
    self:handleInput('escape')
  end
end

function Menu:draw()
  if not self.active or not self.currentMenu then return end

  -- Draw semi-transparent background
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", 0, 0, Constants.WINDOW_WIDTH, Constants.WINDOW_HEIGHT)

  -- Draw menu title
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(self.currentMenu.title,
    0,
    Constants.WINDOW_HEIGHT / 4,
    Constants.WINDOW_WIDTH,
    "center")

  -- Draw menu options
  for i, option in ipairs(self.currentMenu.options) do
    if i == self.currentMenu.selected then
      love.graphics.setColor(1, 1, 0)
      love.graphics.printf("> " .. option.text .. " <",
        0,
        Constants.WINDOW_HEIGHT / 2 + (i - 1) * 30,
        Constants.WINDOW_WIDTH,
        "center")
    else
      love.graphics.setColor(1, 1, 1)
      love.graphics.printf(option.text,
        0,
        Constants.WINDOW_HEIGHT / 2 + (i - 1) * 30,
        Constants.WINDOW_WIDTH,
        "center")
    end
  end

  -- Draw message if exists
  if self.messageText then
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.messageText,
      0,
      Constants.WINDOW_HEIGHT - 60,
      Constants.WINDOW_WIDTH,
      "center")
  end
end

function Menu:getSaveSlots()
  local saves = {}
  local files = love.filesystem.getDirectoryItems("")

  for _, file in ipairs(files) do
    if file:match("^tetris_save_%d+%.json$") then
      local slot = tonumber(file:match("%d+"))
      local info = love.filesystem.getInfo(file)
      saves[slot] = {
        filename = file,
        modtime = info.modtime
      }
    end
  end

  return saves
end

function Menu:saveGame(slot)
  local saveData = {
    grid = self.game.grid,
    score = self.game.score,
    level = self.game.level,
    gameOver = self.game.gameOver,
    currentPiece = {
      shape = self.game.currentPiece.shape,
      type = self.game.currentPiece.type,
      x = self.game.currentPiece.x,
      y = self.game.currentPiece.y
    },
    timestamp = os.time()
  }

  -- '/Users/wojexe/Library/Application Support/LOVE/lua' is the default save directory
  local filename = string.format("tetris_save_%d.json", slot)
  local success, message = love.filesystem.write(filename, JSON:encode(saveData))

  if success then
    self:showMessage("Game saved to slot " .. slot)
  else
    self:showMessage("Failed to save: " .. message)
  end
end

function Menu:loadGame(slot)
  local filename = string.format("tetris_save_%d.json", slot)

  if not love.filesystem.getInfo(filename) then
    self:showMessage("No save file found in slot " .. slot)
    return
  end

  local contents = love.filesystem.read(filename)
  if not contents then
    self:showMessage("Could not read save file")
    return
  end

  local saveData = JSON:decode(contents)

  if not saveData then
    self:showMessage("Failed to decode save data")
    return
  end

  -- Check if save data has required fields
  if not saveData.grid or not saveData.score or not saveData.level or
      not saveData.currentPiece or not saveData.currentPiece.shape or
      not saveData.currentPiece.type or not saveData.currentPiece.x or
      not saveData.currentPiece.y then
    self:showMessage("Save data is corrupted")
    return
  end

  -- Restore game state
  self.game.grid = saveData.grid
  self.game.score = saveData.score
  self.game.level = saveData.level
  self.game.gameOver = false

  -- Restore current piece
  self.game.currentPiece = {
    shape = saveData.currentPiece.shape,
    type = saveData.currentPiece.type,
    x = saveData.currentPiece.x,
    y = saveData.currentPiece.y
  }

  self:showMessage("Game loaded from slot " .. slot)
end

return Menu

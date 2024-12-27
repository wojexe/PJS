local Constants = {
  MOBILE = false,

  -- Grid
  CELL_SIZE = 30,

  GRID_X_CELLS = 10,
  GRID_Y_CELLS = 20,

  -- Colors
  COLORS = {
    I = { 0, 1, 1 },   -- cyan
    O = { 1, 1, 0 },   -- yellow
    T = { 1, 0, 1 },   -- magenta
    L = { 1, 0.5, 0 }, -- orange
    BACKGROUND = { 0.1, 0.1, 0.1 },
    UI_TEXT = { 1, 1, 1 },
    UI_BACKGROUND = { 0, 0, 0, 0.8 }
  },

  SHAPES = {
    I = {
      {
        { 0, 0, 0, 0 },
        { 1, 1, 1, 1 },
        { 0, 0, 0, 0 },
        { 0, 0, 0, 0 }
      }
    },
    O = {
      {
        { 1, 1 },
        { 1, 1 }
      }
    },
    T = {
      {
        { 0, 1, 0 },
        { 1, 1, 1 },
        { 0, 0, 0 }
      }
    },
    L = {
      {
        { 1, 0, 0 },
        { 1, 1, 1 },
        { 0, 0, 0 }
      }
    }
  },

  -- Game Settings
  INITIAL_FALL_SPEED = 0.5,
  LEVEL_SPEED_INCREASE = 0.05,
  POINTS_PER_LINE = 100,
  LINES_PER_LEVEL = 10,
  MAX_SAVE_SLOTS = 3,

  -- Animations
  CLEAR_ANIMATION_DURATION = 0.7,

  -- File Names
  SAVE_FILE_PREFIX = "tetris_save_",
  SAVE_FILE_EXTENSION = ".json",

  -- UI Settings
  MESSAGE_DISPLAY_TIME = 2,
  MENU_PADDING = 40,
  MENU_LINE_HEIGHT = 30,

  -- Key Bindings
  KEYS = {
    MOVE_LEFT = 'left',
    MOVE_RIGHT = 'right',
    ROTATE = 'up',
    SOFT_DROP = 'down',
    HARD_DROP = 'space',
    PAUSE = 'escape',
    SAVE = 's',
    LOAD = 'l',
    RESTART = 'r',
    TOGGLE_MENU = 'escape'
  }
}

-- Calculate dependent constants

-- Window size
Constants.GAME_WIDTH = Constants.CELL_SIZE * Constants.GRID_X_CELLS
Constants.GAME_HEIGHT = Constants.CELL_SIZE * Constants.GRID_Y_CELLS

Constants.GAME_PADDING_X = 25
Constants.GAME_PADDING_Y = 25

Constants.WINDOW_WIDTH = Constants.GAME_WIDTH + 50
Constants.WINDOW_HEIGHT = Constants.GAME_HEIGHT + 50

-- Strings
Constants.TEXT = {
  GAME_OVER = "Game Over!\nPress 'R' to restart",
}

-- Mobile constants

Constants.TOUCH_CONTROLS = {
  SWIPE_THRESHOLD = 30,
  TAP_TIMEOUT = 0.2
}

-- Adjust grid size based on screen resolution
function Constants:initializeMobileSettings(w, h)
  self.MOBILE = true

  if w == nil or h == nil then
    w, h = love.graphics.getDimensions()
  end

  self.CELL_SIZE = math.floor(w / (self.GRID_X_CELLS + 2))

  self.GAME_WIDTH = self.CELL_SIZE * self.GRID_X_CELLS
  self.GAME_HEIGHT = self.CELL_SIZE * self.GRID_Y_CELLS

  self.WINDOW_WIDTH = w
  self.WINDOW_HEIGHT = h

  self.GAME_PADDING_X = (w - self.CELL_SIZE * self.GRID_X_CELLS) / 2
  self.GAME_PADDING_Y = (h - self.CELL_SIZE * self.GRID_Y_CELLS) / 2
end

return Constants

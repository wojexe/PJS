local Sounds = {
  initialized = false,
  library = {},
  volume = 1.0,
  enabled = true
}

function Sounds:initialize()
  if self.initialized then return end

  self:load()
  self.initialized = true
end

function Sounds:load()
  -- Load all sound effects
  self.library = {
    move = love.audio.newSource("sounds/swoosh.mp3", "static"),
    rotate = love.audio.newSource("sounds/swoosh.mp3", "static"),
    drop = love.audio.newSource("sounds/boom.mp3", "static"),
    clear = love.audio.newSource("sounds/clear.mp3", "static"),
    levelup = love.audio.newSource("sounds/swoosh.mp3", "static"),
    gameover = love.audio.newSource("sounds/gameover.mp3", "static"),
    menu_select = love.audio.newSource("sounds/swoosh.mp3", "static"),
    menu_move = love.audio.newSource("sounds/swoosh.mp3", "static"),
    background = love.audio.newSource('sounds/music.mp3', 'stream')
  }

  self.library.background:setLooping(true)

  -- Set initial volume for all sounds
  for _, sound in pairs(self.library) do
    sound:setVolume(self.volume)
  end
end

function Sounds:play(soundName)
  if not self.enabled then return end

  local sound = self.library[soundName]
  if sound then
    -- Stop the sound if it's already playing
    sound:stop()
    -- Create a clone and play it
    local clone = sound:clone()
    clone:play()
  end
end

function Sounds:toggleLooping(soundName)
  local isLooping = self.library[soundName]:isLooping()
  self.library[soundName]:setLooping(not isLooping)
end

function Sounds:setVolume(volume)
  self.volume = volume
  for _, sound in pairs(self.library) do
    sound:setVolume(volume)
  end
end

function Sounds:toggle()
  self.enabled = not self.enabled
end

return Sounds

function init(args)
  entity.setInteractive(true)

  if storage.state == nil then
    storage.state = false
  else
    entity.setAllOutboundNodes(storage.state)
  end

  if self.instate == nil then
    self.instate = false
  end

  if storage.timer == nil then
    storage.timer = 0
  end
  
  if storage.duration == nil then
    storage.duration = 0
  end

  if storage.mode == nil then
    storage.mode = 1
  end
  
  self.delays = entity.configParameter("delays")
  self.delayNames = entity.configParameter("delayNames")
  self.delay = self.delays[storage.mode]
  
  output(storage.state)
  draw()
end

function onInteraction(args)
  local mode = storage.mode + 1
  for key,value in pairs(self.delays) do
    if (key == mode) then
      self.delay = self.delays[mode]
      storage.mode = mode
      storage.duration = 0
      storage.timer = 0
      storage.instate = false
      storage.state = true
      output(false)
      return
    end
  end
  
  self.delay = self.delays[mode]
  storage.mode = 1
  storage.duration = 0
  storage.timer = 0
  storage.instate = false
  storage.state = true
  output(false)
end

function draw()
  local statestr = ".off"
  if storage.state then
    statestr = ""
  end
  
  if entity.direction() == 1 then
    entity.setAnimationState("delaydiodeDelayState", self.delayNames[storage.mode]..statestr)
  else
    entity.setAnimationState("delaydiodeDelayState", self.delayNames[storage.mode]..".flipped"..statestr)
  end

  if storage.state then
    entity.setAnimationState("delaydiodeFrameState", "on")
  else
    entity.setAnimationState("delaydiodeFrameState", "off")
  end
end

function output(state)
  if storage.state ~= state then
    storage.state = state
    entity.setAllOutboundNodes(state)
    
    draw()
  end
end

function main()
  local state = entity.getInboundNodeLevel(0)
  if state ~= self.instate then
    self.instate = state
    
    if state then
      storage.duration = 1
      storage.timer = self.delay;
    end
  end

  -- Check if anything to do.
  if storage.timer == 0 and storage.duration == -1 then
    return
  end
  
  -- Increase duration.
  if self.instate == true then
    storage.duration = storage.duration + 1
  end
  
  -- Check timer.
  if storage.timer == 0 then
    -- Decrease duration and output.
    if storage.duration > 0 then
      storage.duration = storage.duration - 1
      output(true)
    else
      output(false)
    end
  else
    -- Decrease timer.
    storage.timer = storage.timer - 1 
  end
end

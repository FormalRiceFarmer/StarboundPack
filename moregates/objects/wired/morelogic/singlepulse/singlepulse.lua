function init(args)
  entity.setInteractive(false)
  if storage.state == nil then
    storage.state = false
    storage.wait = false
    storage.ended = false
  end

  output(storage.state)
end

function output(state)
  if (storage.wait == true) then
    storage.ended = true
    output_do(false)
    return
  end
  
  if (state == true) then
    storage.wait = true
  end

  output_do(state)
end

function output_do(state)
  entity.setAllOutboundNodes(state)
  if state then
    entity.setAnimationState("switchState", "on")
  else
    entity.setAnimationState("switchState", "off")
  end
end

function main()
  local state = entity.getInboundNodeLevel(0)
  if state ~= storage.state then
    storage.state = state
    
    if state == false then
      storage.wait = false
      storage.ended = false
    end

    output(state)
  else
    if storage.wait == true and storage.ended ~= true then
      output(false)
    end
  end
end

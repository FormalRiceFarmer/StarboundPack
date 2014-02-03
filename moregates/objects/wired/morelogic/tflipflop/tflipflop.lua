function init(args)
  entity.setInteractive(false)
  if storage.state == nil then
    storage.state = false
    storage.wait = false
  end

  output(storage.state)
end

function output(state)
  if (storage.state ~= state and storage.wait ~= true) then
    storage.wait = true
    storage.state = state
    entity.setAllOutboundNodes(state)
    if state then
      entity.setAnimationState("switchState", "on")
    else
      entity.setAnimationState("switchState", "off")
    end
  end
end

function main()
  if entity.getInboundNodeLevel(0) then
    output(not storage.state)
  else
    storage.wait = false
  end
end

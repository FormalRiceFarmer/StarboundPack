function init(args)
  entity.setInteractive(false)
  if storage.state == nil then
    storage.state = false
  end

  output(storage.state)
end

function output(state)
  if (storage.state ~= state) then
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
  output(entity.getInboundNodeLevel(0))
end

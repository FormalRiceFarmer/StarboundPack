function init()
  toUse = true
  data.HeldItem = ""
end

function init(args)
  entity.setInteractive(true)
end

function onInteraction(args)
  if not toUse then
    local heldItem = world.entityHandItem(args.sourceId, "primary")
    world.spawnItem(heldItem, entity.toAbsolutePosition({ 0.0, 5.0 }), 1)
  else
	return { "ShowPopup", { message = "Nope." } }
  end
end

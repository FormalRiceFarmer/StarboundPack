function init(args)
    if not self.initialized and not args then
      self.initialized = true
      entity.setInteractive(true)
      entity.setAllOutboundNodes(false)
      if storage.mode == nil then
          storage.mode = "all"
      end
      entity.setAnimationState("ele_detectorState", storage.mode.."Off")
      self.countdown = 0
    end
end

function trigger()
  entity.setAllOutboundNodes(true)
  entity.setAnimationState("ele_detectorState", storage.mode.."On")
  self.countdown = entity.configParameter("detectTickDuration")
end

function onInteraction(args)
    storage.owner = world.entityName(args["sourceId"])
    if storage.mode == "all" then
        storage.mode = "owner"
    elseif storage.mode == "owner" then
        storage.mode = "player"
    elseif storage.mode == "player" then
        storage.mode = "monster"
    elseif storage.mode == "monster" then
        storage.mode = "item"
    elseif storage.mode == "item" then
        storage.mode = "npc"
    elseif storage.mode == "npc" then
        storage.mode = "solar"
    elseif storage.mode == "solar" then
        storage.mode = "all"
    end
    entity.setAnimationState("ele_detectorState", storage.mode.."Off")
end

function main()
  if self.countdown > 0 then
    self.countdown = self.countdown - 1
  else
    if self.countdown == 0 then
      local radius = entity.configParameter("detectRadius")
      local entityIds = {}
      if storage.mode == "all" then
          entityIds = world.entityQuery(entity.position(), radius, { notAnObject = true })
      elseif storage.mode == "owner" then
          entityIds = world.playerQuery(entity.position(), radius, { notAnObject = true })
          local value = {}
          for _, entityId in pairs(entityIds) do
            if world.entityName(entityId) == storage.owner then
                value[1] = "test"
                break
            end
          end
          entityIds = value
      elseif storage.mode == "player" then
          entityIds = world.playerQuery(entity.position(), radius, { notAnObject = true })
      elseif storage.mode == "monster" then
          entityIds = world.monsterQuery(entity.position(), radius, { notAnObject = true })
      elseif storage.mode == "item" then
          entityIds = world.itemDropQuery(entity.position(), radius, { notAnObject = true })
      elseif storage.mode == "npc" then
          entityIds = world.npcQuery(entity.position(), radius, { notAnObject = true })
      elseif storage.mode == "solar" then
          local lightLevel = entity.configParameter("lightLevel")
          if world.lightLevel(entity.position()) >= lightLevel then
            entityIds[1] = "test"
          end
      end

      if #entityIds > 0 then
        trigger()
        entity.setAnimationState("ele_detectorState", storage.mode.."On")
      else
        entity.setAllOutboundNodes(false)
        entity.setAnimationState("ele_detectorState", storage.mode.."Off")
      end
    end
  end
end
function init(args)
    if not self.initialized and not args then
        energyApi.init()
        self.cooldown, self.targetId, self.initialized = 0, false, true
        entity.setInteractive(true)
        entity.setAllOutboundNodes(false)
        if storage.state == nil then
            storage.state = true
        end
        entity.setAnimationState("ele_springtrapState", "off")
    end
end

function main()
    if storage.state then
        if self.cooldown == 0 then
            if entity.animationState("ele_springtrapState") == "on" then
                self.cooldown = entity.configParameter("coolDown") - 1
                entity.setAnimationState("ele_springtrapState", "recycle")
                return
            end
            local entityIds = world.entityQuery(entity.toAbsolutePosition({-1,0}), entity.toAbsolutePosition({1,2}), { callScript = "canBePushed", callScriptResult = true })
            for _, entityId in pairs(entityIds) do
                self.targetId = entityId
                break
            end
            if self.targetId and energyApi.check() then
                entity.setAnimationState("ele_springtrapState", "on")
                push()
            else
                self.targetId = false
            end
        else
            self.cooldown = self.cooldown - 1
        end
    end
end

function onInteraction(args)
    updateActive(storage.state == false)
end

function onInboundNodeChange(args)
    updateActive(args.level)
end

function onNodeConnectionChange(args)
    if energyApi.onNodeConnectionChange(args) and storage.energy == 0 then
        energyApi.get(15)
    end
end

function push()
    local pushForce = entity.configParameter("pushForce")
    world.callScriptedEntity(self.targetId, "pushEntity", {entity.direction()*pushForce[1], pushForce[2]})
    self.cooldown, self.targetId = 1, false
    return true
end

function updateActive(active)
    if active then
        storage.state = true
    else
        storage.state = false
        entity.setAnimationState("ele_springtrapState", "off")
    end
end
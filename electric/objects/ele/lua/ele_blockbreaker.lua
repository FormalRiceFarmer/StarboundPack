function init(args)
    if not self.initialized and not args then
        self.initialized = true
        self.build = false

        entity.setInteractive(true)
        entity.setColliding(false)
        if storage.positions == nil then
            storage.positions = {}
            storage.materials = {}
        end
        if storage.state == nil then
            storage.state = "off"
        end
        entity.setAnimationState("ele_blockbreakerState", storage.state);
    end
end

function onInteraction(args)
    local entityIds = world.objectQuery(entity.position(), 50, { name = "ele_placeholder" })
    local i = #storage.positions
    self.build = {}
    for _, entityId in pairs(entityIds) do
        i = i + 1
        storage.positions[i] = world.entityPosition(entityId)
        storage.materials[i] = "dirt"
        world.callScriptedEntity(entityId, "entity.smash")
        self.build[i] = storage.positions[i]
    end
    if #self.build == 0 then self.build = false end
end

function main()
    if self.build then
        for k, pos in pairs(self.build) do
            world.placeMaterial(pos, "foreground", "dirt")
            self.build[k] = nil
        end
        if #self.build == 0 then self.build = false end
    end
end

function updateActive(active)
    if active then
        storage.state = "on"
    else
        storage.state = "off"
    end
    entity.setAnimationState("ele_blockbreakerState", storage.state);
    for k, entityPos in pairs(storage.positions) do
        if active then
            local mat = world.material(entityPos, "foreground")
            if mat then
                storage.materials[k] = mat
                world.damageTiles({entityPos}, "foreground", entityPos, "crushing", 1000)
            end
        else
            world.placeMaterial(entityPos, "foreground", storage.materials[k])
        end
    end
end

function onInboundNodeChange(args)
    updateActive(args.level)
end

function onNodeConnectionChange()
    updateActive(entity.getInboundNodeLevel(0))
end
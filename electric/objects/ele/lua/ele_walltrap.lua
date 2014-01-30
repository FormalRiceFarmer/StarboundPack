function init(args)
    if not self.initialized and not args then
        energyApi.init()
        energyApi.usage = 10
        self.initialized = true
        self.countdown = 0
        entity.setInteractive(true)
        entity.setAllOutboundNodes(false)
        if storage.owner == nil then
            storage.owner = entity.id()
        end
        if storage.mode == nil then
            storage.mode = 1
        end
        if storage.active == nil then
            storage.active = false
        end
        if storage.firePosition == nil then
            storage.anchor = entity.configParameter("anchors")[1]
            if storage.anchor == "bottom" then
                storage.anchor = "Bottom"
                storage.firePosition = { entity.toAbsolutePosition({0.5,1}), {0,1} }
            elseif storage.anchor == "top" then
                storage.anchor = "Top"
                storage.firePosition = { entity.toAbsolutePosition({0.5,-1}), {0,-1} }
            elseif storage.anchor == "right" then
                if entity.direction() * 1 == 1 then
                    storage.anchor = "Right"
                else
                    storage.anchor = "Left"
                end
                storage.firePosition = { entity.toAbsolutePosition({-1.5,0.5}), {-1,0} }
            elseif storage.anchor == "left" then
                if entity.direction() * -1 == 1 then
                    storage.anchor = "Right"
                else
                    storage.anchor = "Left"
                end
                storage.firePosition = { entity.toAbsolutePosition({1.5,0.5}), {1,0} }
            end
        end
        local projectileOrder = entity.configParameter("projectileOrder")
        entity.setAnimationState("ele_dispenserState", projectileOrder[storage.mode]..storage.anchor)
    end
end

function isActive()
    return storage.active
end

function deactivateTrap()
    updateActive(false)
end

function updateActive(active)
    if active then
        storage.active = true
    else
        storage.active = false
    end
end

function onInboundNodeChange(args)
    updateActive(args.level)
end

function onNodeConnectionChange()
    if energyApi.onNodeConnectionChange() and storage.energy == 0 then
        if energyApi.get(20) then
            main()
        end
    end
end

function onInteraction(args)
    storage.owner = args["sourceId"]
    local projectiles = entity.configParameter("projectiles")
    local projectileOrder = entity.configParameter("projectileOrder")

    if projectiles[storage.mode+1] then
        storage.mode = storage.mode + 1
    else
        storage.mode = 1
    end
    energyApi.usage = projectiles[storage.mode]["energyUsage"]

    entity.setAnimationState("ele_dispenserState", projectileOrder[storage.mode]..storage.anchor)
end

function main()
    if storage.active then
        if self.countdown < 1 then
            local projectile = entity.configParameter("projectiles")[storage.mode]
            if energyApi.check() then
                world.spawnProjectile(projectile["projectileType"], storage.firePosition[1], storage.owner, storage.firePosition[2], false, projectile["projectileConfig"])
                self.countdown  = projectile["coolDown"]
            end
        end
        self.countdown  = self.countdown - entity.dt()*2
    end
end
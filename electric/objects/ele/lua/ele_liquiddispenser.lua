function init(args)
    if not self.initialized and not args then
        energyApi.init()
        self.initialized = true
        entity.setInteractive(true)
        entity.setColliding(true)
        if storage.mode == nil then
            storage.mode = "off"
        end
        if storage.pump == nil then
            storage.pump = false
        end
        if storage.anchor == nil then
            storage.anchor = entity.configParameter("anchors")[1]
            if storage.anchor == "right" then
                if entity.direction() * 1 == 1 then
                    storage.anchor = "right"
                else
                    storage.anchor = "left"
                end
                storage.firePosition = entity.toAbsolutePosition({-1, -1})

            elseif storage.anchor == "left" then
                if entity.direction() * -1 == 1 then
                    storage.anchor = "right"
                else
                    storage.anchor = "left"
                end
                storage.firePosition = entity.toAbsolutePosition({0, -1})
            end
        end

        entity.setAnimationState("ele_liquiddispenserState", storage.mode..storage.anchor);
    end
end

function onInteraction(args)
    if storage.mode == "off" then
        storage.mode = "water"
    elseif storage.mode == "water" then
        storage.mode = "lava"
    elseif storage.mode == "lava" then
        storage.mode = "acid"
    else
        storage.mode = "off"
    end
    entity.setAnimationState("ele_liquiddispenserState", storage.mode..storage.anchor);
end

function main(args)
    if storage.pump and not world.pointCollision(storage.firePosition)then
        local liquidQuantity = entity.configParameter("liquidQuantity")
        local action = { action = "liquid", quantity = liquidQuantity, liquidId = 0 }
        if storage.mode == "water" then
            action = { action = "liquid", quantity = liquidQuantity, liquidId = 1 }
        elseif storage.mode == "lava" then
            action = { action = "liquid" , quantity = liquidQuantity, liquidId = 3 }
        elseif storage.mode == "acid" then
            action = { action = "liquid", quantity = liquidQuantity, liquidId = 4 }
        end

        if energyApi.check() or 1 == 1 then
            world.spawnProjectile("ele_liquid", storage.firePosition, entity.id(), {0, 1}, false, { actionOnReap = { action }})
        end
    end
end

function isActive()
    return storage.pump
end

function updateActive(active)
    storage.pump = active
end

function onInboundNodeChange(args)
    updateActive(args.level)
end

function onNodeConnectionChange()
    if energyApi.onNodeConnectionChange() and storage.energy == 0 then
        energyApi.get(15)
    end
end
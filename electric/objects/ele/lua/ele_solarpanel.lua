function init(args)
    if not self.initialized and not args then
        energyApi.init({supplier = true})
        entity.setInteractive(false)
        entity.setAnimationState("solarState", "off")
        self.initialized = true;
        entity.setAllOutboundNodes(false)
        if storage.energy == nil then
            storage.energy = 0
        end
    end
end

function main()
    -- TODO: Add check if lightLevel > ~0.5 when more energy sources are available
    --local lightLevel = world.lightLevel(entity.position())
    energyApi.generate(energyApi.income())
end

function energyApi.income()
    return math.floor((world.lightLevel(entity.position()))*entity.configParameter("efficiency"))
end

function onInteraction()
    return { "ShowPopup", { message = storage.energy } }
end
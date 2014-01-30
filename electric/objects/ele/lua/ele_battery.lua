function init(args)
    if not self.initialized and not args then
        energyApi.init({supplier = true})
        self.initialized = true
        entity.setInteractive(true)
        updateEnergyState()
        if entity.direction() < 0 then
            entity.setAnimationState("ele_batteryState", "onr");
        else
            entity.setAnimationState("ele_batteryState", "on");
        end
    end
end

function onInteraction(args)
    main()
    local mult, name, message = 10^2, entity.configParameter("shortdescription"), ""
    local currentEnergy = math.floor(storage.energy * mult + 0.5) / mult

    message = message.."\rCurrent energy: "..currentEnergy.."/"..energyApi.max
    message = message.." ("..math.floor(100/energyApi.max*storage.energy).."%)"

    local inboundNodeIds = entity.getInboundNodeIds(0)
    local incomingEnergyCount, incomingEnergy = 0, 0
    for _,inboundNode in ipairs(inboundNodeIds) do
        local energyPerTick = world.callScriptedEntity(inboundNode[1], "energyApi.usagePerTick")
        if energyPerTick then
            incomingEnergyCount = incomingEnergyCount + 1
            incomingEnergy = incomingEnergy + energyPerTick
        end
    end
    local outboundNodeIds = entity.getOutboundNodeIds(0)
    local outgoingEnergyCount, outgoingEnergy = {0,0}, {0,0}
    for _,outboundNode in pairs(outboundNodeIds) do
        local energyPerTick = world.callScriptedEntity(outboundNode[1], "energyApi.usagePerTick")
        if energyPerTick then
            outgoingEnergyCount[1] = outgoingEnergyCount[1] + 1
            outgoingEnergy[1] = outgoingEnergy[1] + energyPerTick
            local isActive = world.callScriptedEntity(outboundNode[1], "isActive")
            if isActive then
                outgoingEnergyCount[2] = outgoingEnergyCount[2] + 1
                outgoingEnergy[2] = outgoingEnergy[2] + energyPerTick
            end
        end
    end

    incomingEnergy = math.floor(incomingEnergy * mult + 0.5) / mult
    outgoingEnergy[1] = math.floor(outgoingEnergy[1] * mult + 0.5) / mult
    outgoingEnergy[2] = math.floor(outgoingEnergy[2] * mult + 0.5) / mult

    message = message .. "\rEnergy generated per tick: "..incomingEnergy.." ("..incomingEnergyCount..")"
    message = message .. "\rCurrent energy usage per tick: "..outgoingEnergy[2].." ("..outgoingEnergyCount[2]..")"
    message = message .. "\rMaximal energy usage per tick: "..outgoingEnergy[1].." ("..outgoingEnergyCount[1]..")"

    return { "ShowPopup", { message = message } }
end

function onNodeConnectionChange()
    if energyApi.onNodeConnectionChange() and storage.energy == 0 then
        main()
    end
end

function main()
    if energyApi.hasSpace() then
        energyApi.get(200)
        updateEnergyState()
    end
end

function updateEnergyState()
    local energyDisplayLength = entity.configParameter("energyDisplayLength") or 19
    local perc = 100/energyApi.max*storage.energy+2
    entity.scaleGroup("energy", { 1, energyDisplayLength/100*perc })
end

function die()
    if entity.configParameter("portable") then
        if storage.energy > 0 then
            world.spawnItem(entity.configParameter("objectName"), entity.toAbsolutePosition({0,0}), 1, { currentEnergy = storage.energy })
        else
            world.spawnItem(entity.configParameter("objectName"), entity.toAbsolutePosition({0,0}), 1)
        end
    end
end
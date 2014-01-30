function init(args)
    if not self.initialized and not args then
        liquidApi.init({ liquids = 0 })
        transferApi.init({
            size = {3, 5}, borders = { 1, 2, 3 }, mode = 0, type = "liquids"
        })
        entity.setInteractive(true)
        self.initialized = true
        updateAnimationState()
    end
end

function main()
    transferApi.update(entity.dt())
    if entity.getInboundNodeLevel(0) then
        liquidApi.send(1000)
    end
end

function onInteraction(src)
    transferApi.onInteraction(src)
    local mes = "Tank contains"
    for liquidId, amount in pairs(storage.liquids) do
        if liquidApi.liquidNames[tonumber(liquidId)] then
            mes = mes.."\r"..liquidApi.liquidNames[tonumber(liquidId)]..":"
        else
            mes = mes.."\rUnknown Liquid #"..liquidId..":"
        end
        mes = mes.."\r"..amount.."/"..liquidApi.max.." (".. math.floor(perc(amount))..")%"
    end
    return { "ShowPopup", { message = mes } }
end

function perc(amount)
    return 100/liquidApi.max*amount
end

function updateAnimationState()
    local liq = "empty"
    if next(storage.liquids) ~= nil then
        local liqLength = entity.configParameter("liqDisplayLength") or 27
        for liquidId, amount in pairs(storage.liquids) do
            liq = liquidApi.liquidNames[tonumber(liquidId)] or "unknown"
            entity.scaleGroup("liq", { 1, liqLength/100*perc(amount) })
            break
        end
    end
    if entity.direction() < 0 then
        entity.setAnimationState("ele_liqState", liq.."r")
    else
        entity.setAnimationState("ele_liqState", liq)
    end
end

function liquidApi.afterGive(liquid)
    updateAnimationState()
end

function liquidApi.afterUse(liquid)
    updateAnimationState()
end

function die()
    if entity.configParameter("portable") then
        if next(storage.liquids) ~= nil then
            world.spawnItem(entity.configParameter("objectName"), entity.toAbsolutePosition({0,0}), 1, { storedLiquids = storage.liquids })
        else
            world.spawnItem(entity.configParameter("objectName"), entity.toAbsolutePosition({0,0}), 1)
        end
    end
end


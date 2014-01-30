liquidApi = {}

function liquidApi.init(args)
    args = args or {}
    liquidApi.max = args.max or entity.configParameter("maxLiquidAmount") or 50000
    liquidApi.liquids = args.liquids or { 1 }
    liquidApi.maxLiquids = args.maxLiquids or 1
    liquidApi.pos = args.pos or entity.position()
    if storage.liquids == nil then
        local storedLiquids  = args.storedLiquids or entity.configParameter("storedLiquids")
        storage.liquids = storedLiquids or {}
    end
end

function liquidApi.spawn(liquidId, amt, pos)
    pos = pos or liquidApi.pos
    if storage.liquids[liquidId] then
        local amount = math.min(storage.liquids[liquidId], amt)
        local spawn = world.spawnProjectile("ele_liquid", pos, entity.id(), {0,-1}, false, { actionOnReap = {{
            action = "liquid",
            liquidId = liquidId,
            quantity = amount
        }}})
        if spawn then
            liquidApi.use(liquidId, amount)
            return true
        end
    end
    return false
end

function liquidApi.take(pos)
    pos = pos or liquidApi.pos
    local liquidAt = world.liquidAt(pos)
    if liquidAt and liquidAt[2] > 0.1 and liquidApi.can(liquidAt[1]) then
        local take = math.ceil(math.min(liquidAt[2], liquidApi.max - (storage.liquids[liquidAt[1]] or 0)) * 1050)
        local left = liquidApi.give(liquidAt[1], take)
        if left then
            world.spawnProjectile("ele_liquidr", pos, entity.id(), {0,-1}, false, { actionOnReap = {{
                action = "liquid",
                liquidId = 0,
                quantity = (take - left)
            }}})
            return take - left
        end
    end
    return false
end

function liquidApi.give(liquidId, amt)
    local gave = false
    if liquidApi.can(liquidId) then
        if liquidApi.beforeGive ~= nil then liquidApi.beforeGive(liquidId, amt) end
        local newAmount = amt + (storage.liquids[liquidId] or 0)
        if newAmount > liquidApi.max then
            storage.liquids[liquidId] = liquidApi.max
            gave = newAmount - liquidApi.max
        else
            storage.liquids[liquidId] = newAmount
            gave = 0
        end
        if liquidApi.afterGive ~= nil then liquidApi.afterGive(liquidId, amt) end
    end
    return gave
end

function liquidApi.use(liquidId, amt)
    if liquidApi.has(liquidId, amt) then
        if liquidApi.beforeUse ~= nil then liquidApi.beforeUse(liquidId, amt) end
        storage.liquids[liquidId] = storage.liquids[liquidId] - amt
        if storage.liquids[liquidId] <= 0 then
            storage.liquids[liquidId] = nil
        end
        if liquidApi.afterUse ~= nil then liquidApi.afterUse(liquidId, amt) end
        return true
    end
    return false
end

function liquidApi.hasSpace(liquidId, amt)
    amount = amount or 0
    return (storage.liquids[liquidId] or 0) + amount < liquidApi.max
end

function liquidApi.has(liquidId, amt)
    amt = amt or 0
    if storage.liquids[liquidId] and storage.liquids[liquidId] >= amt then
        return storage.liquids[liquidId]
    end
    return false
end

function liquidApi.can(liquidId, amt)
    if storage.liquids[liquidId] then
        return storage.liquids[liquidId] < liquidApi.max
    elseif countTable(storage.liquids) < liquidApi.maxLiquids then
        if liquidApi.liquids == 0 then
           return true
        end
        for _, liq in ipairs(liquidApi.liquids) do
            if liq == liquidId then
                return true
            end
        end
    end
    return false
end

liquidApi.liquidNames = {
    "Water", "Water", "Lava", "Acid", "Lava", "TentacleJuice", "Tar"
}

----

function countTable(table)
    local c = 0
    for _, _ in pairs(table) do
        c = c + 1
    end
    return c
end
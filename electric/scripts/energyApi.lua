--- Energy API
--      Example usage:
--          function init()
--              energyApi.init({ max = 1000, usage = 2 })
--          end
--
--          function main()
--              if energyApi.check() then
--                  -- Do cool stuff
--              end
--          end
--
--          function onNodeConnectionChange()
--              energyApi.onNodeConnectionChange()
--          end

energyApi = {}

--- Initialize energy api
-- @param args Additional filtering options table, accepts the following:
--      energyNode - (int) number of node that should be used for energy transfer
--      max - Maximum amount of energy storage
--      usage - Current usage of energy per check
--      supplier - True if the entity produces or transfers energy (=battery)
function energyApi.init(args)
    args = args or {}
    if storage.energy == nil then
        storage.energy = 0
        local currentEnergy  = args.currentEnergy or entity.configParameter("currentEnergy")
        if currentEnergy then
            storage.energy = currentEnergy
        end
    end
    energyApi.energyNode = args.energyNode or entity.configParameter("energyNode") or 0
    energyApi.max = args.max or entity.configParameter("maxEnergy") or 500
    energyApi.supplier = args.supplier or false
    energyApi.usage = args.usage or entity.configParameter("energyUsage") or 0
    energyApi.connections = false
    energyApi.requestTimeout = {0,1}
    --updateSignal(storage.energy > 0)
end

--- Optional to check sometimes for energy while idling
function energyApi.update(amount, min)
    min = min or energyApi.max
    if storage.energy < min then
        energyApi.checkSometimes(amount or 10)
    end
end

--- Check if there's space for more energy
-- @param amount (optional) Add to current energy to check before adding
-- @returns True if there's enough space
function energyApi.hasSpace(amount)
    amount = amount or 0
    return storage.energy + amount < energyApi.max
end

--- Get current energy to be called from another entity
-- @returns (int) current energy
function energyApi.get()
    return storage.energy
end

--- Check if is energy supplier to be called from another entity
-- @returns True if supplier
function energyApi.isSupplier()
    return energyApi.supplier
end

--- Checks for and substracts energy
-- If not enough energy is present it trys to request it
-- @param amount (optionally) Amount of energy to check
-- @returns True if had enough energy, (int) Amount of received energy or false
function energyApi.check(amount)
    local energyUsage = amount or energyApi.usage

    if storage.energy >= energyUsage then
        storage.energy = storage.energy - energyUsage
        energyApi.checkSometimes(energyUsage*5)
        --updateSignal(true)
        return true
    else
        local req = energyApi.request(energyUsage*7, energyUsage)
        --updateSignal(req)
        return req
    end
end

--- Trys to request energy directly
-- If not enough energy is present it trys to request it
-- @param amount (int) Amount of energy to request
-- @returns (int) Amount of received energy or false
function energyApi.get(amount)
    local req = energyApi.request(amount)
    --updateSignal(req)
    return req
end

--- Requests energy from provicer
-- If not enough energy is present it trys to request it
-- @param amount (int) Amount of energy to request
-- @param usage (optional) If given it returns true and stops requesting as soon as it has >= energy
-- @returns (int) Amount of received energy or false
function energyApi.request(amount, usage)
    if not energyApi.connections then
        energyApi.onNodeConnectionChange()
    end
    if #energyApi.connections > 0 and energyApi.requestTimeout[1] < 1 then
        local energyBefore = storage.energy
        if not energyApi.hasSpace(amount) then
            amount = energyApi.max - storage.energy
        end
        for _, inboundNodeId in ipairs(energyApi.connections) do
            if amount > 0 then
                local gotEnergy = world.callScriptedEntity(inboundNodeId, "energyApi.provide", amount, energyApi.max-storage.energy, energyApi.supplier)
                if gotEnergy then
                    storage.energy = storage.energy + gotEnergy
                    if usage and storage.energy >= usage then
                        energyApi.requestTimeout = { 0, 3 }
                        return storage.energy - energyBefore
                    end
                    amount = amount - gotEnergy
                end
            end
        end
        if not usage and energyBefore < storage.energy then
            energyApi.requestTimeout = { 0, 3 }
            return storage.energy - energyBefore
        end
        -- timeOutOffset increases the request timeout to prevent unnecessary requests
        local timeOutOffset = math.min(energyApi.requestTimeout[2], 50)
        energyApi.requestTimeout = { timeOutOffset, timeOutOffset+1 }
    end
    energyApi.requestTimeout[1] = energyApi.requestTimeout[1] - 1
    return false
end

--- Callback to energyApi.request executed in supplier that provides energy
-- @param amount (int) Amount of requested energy
-- @param max (int) Max amount request entity can take (for batterys)
-- @param supplier (boolen) If another supplier requests
-- @returns (int) Amount of provided energy or false
function energyApi.provide(amount, max, supplier)
    if energyApi.isSupplier and storage.energy > 0 then
        if supplier then
           amount = math.min(max, math.max(amount, storage.energy/3))
        end
        if storage.energy >= amount then
            storage.energy = storage.energy - amount
            return amount
        else
            local amount = storage.energy
            storage.energy = 0
            return amount
        end
    end
    return false
end

function energyApi.generate(amount)
    storage.energy = math.min(storage.energy+amount,energyApi.max)
end

--- Checks sometimes for energy to get energy while not activley using it
-- @param amount (int) Amount of energy to request
-- @returns (int) Amount of provided energy or false
function energyApi.checkSometimes(amount)
    if amount and math.random(100) > math.min(83 + storage.energy/3,99) then
        return energyApi.request(amount,0)
    end
    return false
end

--- Checks for energy node to stop or start requests
-- Add this to your onNodeConnectionChange function!
-- @returns True if request are closed
function energyApi.onNodeConnectionChange()
    energyApi.map()
    if #energyApi.connections > 0 then
        energyApi.requestTimeout = { 0 , 3 }
        return true
    else
        return false
    end
end

--- To calculate the networks usage in batter
-- @returns (int) Amount of used or generated energy
function energyApi.usagePerTick()
    local scriptDelta = entity.dt()
    if energyApi.usage > 0 then
        return energyApi.usage/scriptDelta
    elseif energyApi.income ~= nil then
        return energyApi.income()/scriptDelta
    end
    return 0
end

--- Stores the wire connections to only request them after init and on connection change
function energyApi.map()
    energyApi.connections = {}
    local inboundNodeIds = entity.getInboundNodeIds(energyApi.energyNode)
    if inboundNodeIds then
        for _,inboundNode in ipairs(inboundNodeIds) do
            if world.callScriptedEntity(inboundNode[1], "isEnergySupplier") then
                energyApi.connections[#energyApi.connections+1] = inboundNode[1]
            end
        end
    end
end

--- Maybe coming, maybe optional
function energyApi.updateSignal(hasenergy)
    local signal = entity.animationState("energysignal")
    if signal then
        if hasenergy and signal == "empty" then
            entity.setAnimationState("energysignal",  "filled")
        elseif not hasenergy and signal == "full" then
            entity.setAnimationState("energysignal",  "empty")
        end
    else
        --energyApi.updateSignal = function() return true end
    end
end

function isEnergySupplier()
    return energyApi.isSupplier()
end
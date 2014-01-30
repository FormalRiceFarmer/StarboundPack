--- Transfer API to define connected entity's and exchange things
--      For now only barely used for items, liquids later on
--      Example usage:
--          function init()
--              transferApi.init({
--                  size = {3,0},
--                  mode = 0
--              })
--          end
--
--          function main()
--              -- Update transfer api
--              transferApi.update(entity.dt())
--              -- Try to send items
--              local transfer = transferApi.send(storage.items, { action = "yourDefinedAction" })
--              if transfer then
--                  -- if success empty storage and store what couldn't be send
--                  itemApi.emptyStorage()
--                  itemApi.storeAll(transfer)
--              end
--          end
--
--          -- Another entity trys to give your entity items
--          function transferApi.receive(args)
--              -- Look for connected entities to directly give them further
--              -- store all possible and return what can't be stored
--              return itemApi.storeAll(args.objects)
--          end

transferApi = {}

--- Initialize transfer api
-- @param args Additional filtering options table, accepts the following:
--      pos - if entity's position isn't in it's left bottom corner set it {x,y}
--      size - size {x, y} of entity
--      borders - defines which borders are connectable { 1 (left), 2 (top), 3 (right), 4 (bottom) )
--      type - type of connection network
--      mode - define if entity
--             -1: Does nothing
--              0: Does both
--              1: Puts things inside the network
--              2: Takes things out of the network
function transferApi.init(args)
    args = args or {}
    transferApi.checkForMaterial = true
    transferApi.pos = args.pos or entity.position()
    transferApi.size = args.size or entity.configParameter("transferSize") or {1,1}
    transferApi.type = args.type or entity.configParameter("transferType") or "items"
    transferApi.mode = args.mode or entity.configParameter("transferMode") or -1
    transferApi.countdown = 0
    transferApi.transfering = {}
    if transferApi.transferBorders == nil then
        local borders =  args.borders or { 1, 2, 3, 4 }
        if entity.direction() < 0 then
            for k, border in ipairs(borders) do
                if border == 1 then
                    borders[k] = 3
                elseif border == 3 then
                    borders[k] = 1
                end
            end
        end
        transferApi.calculateBorders(borders)
    end
end

--- Update for connection map
-- @returns True if map got updated
function transferApi.update(dt)
    transferApi.countdown = transferApi.countdown - dt

    if transferApi.countdown < 1 then
        transferApi.map()
        -- randomize countdown to spread the load
        transferApi.countdown = math.random(45,55)
        return true
    end
    return false
end

--- Gets mode to be called from another entity
function transferApi.getMode()
    return transferApi.mode
end

--- Checks if mode is input
-- @param mode to check another entity's mode
function transferApi.isInput(mode)
    mode = mode or transferApi.mode
    return (mode == 0 or mode == 1)
end

--- Check if mode is output
-- @param mode to check another entity's mode
function transferApi.isOutput(mode)
    mode = mode or transferApi.mode
    return (mode == 0 or mode == 2)
end

--- Get table of connections
function transferApi.getConnections()
    return transferApi.connections
end

function transferApi.isConnectable(id, type, mode, pos)
    -- Check if mode is active,
    if transferApi.mode >= 0 and (transferApi.type[type] or transferApi.type == type) and
        (transferApi.mode == 0 or mode ~= transferApi.mode) and transferApi.inEntity(pos) then
        return transferApi.mode
    end
    return false
end

--- Checks for connected entities to take objects
-- @param objects (optional) Table of objects to pass
-- @param args (optional) Arguments to pass to the transferApi.receive function
-- @returns Objects that couldn't get transferred or false
function transferApi.send(objects, args)
    return transferApi.transfer(objects, args, transferApi.outputIds, "transferApi.receive")
end

function transferApi.request(objects, args)
    return transferApi.transfer(objects, args, transferApi.inputIds, "transferApi.answer")
end

function transferApi.check(args, nodes)
    args = args or {}
    nodes = nodes or transferApi.outputIds
    for _, entityId in ipairs(nodes) do
        if world.callScriptedEntity(entityId, "transferApi.can", args) then
            return true
        end
    end
    return false
end

--- Checks for connected entities to tansfer objects
-- @param objects (optional) Table of objects to pass
-- @param args (optional) Arguments to pass to the transferApi.receive function
-- @returns Objects that couldn't get transferred or false
function transferApi.transfer(objects, args, nodes, func)
    if #objects > 0 and next(nodes) ~= nil then
        args = args or {}
        args.id, args.type = entity.id(), transferApi.type
        local injected = false
        for _, entityId in pairs(nodes) do
            -- Prevent loops
            if transferApi.transfering[entityId] == nil then
                transferApi.transfering[entityId] = 1
                local inject, config = false, transferApi.connections[entityId]
                args.objects = objects
                if next(config) == nil or transferApi.config == nil then
                    inject = world.callScriptedEntity(entityId, func, args)
                else
                    --TODO
                    inject = transferApi.config(entityId, args, config)
                end
                transferApi.transfering[entityId] = nil
                if inject then
                    if #inject > 0 then
                        injected = true
                        objects = inject
                    else
                        return {}
                    end
                end
            end
        end
        if injected then
            return objects
        end
    end
    return false
end

transferApi.directions = {
    { -1,  0 }, --left
    {  0,  1 }, --up
    {  1,  0 }, --right
    {  0, -1 }  --down
}

--- Maps connected entities
function transferApi.map()
    transferApi.connections, transferApi.outputIds, transferApi.inputIds = {}, {}, {}
    transferApi.nodesToCheck, transferApi.nodesToAvoid = {}, {}

    for _, positions in pairs(transferApi.transferBorders) do
        for _, pos in ipairs(positions) do
            table.insert(transferApi.nodesToCheck, pos)
        end
    end

    while #transferApi.nodesToCheck > 0 do
        if transferApi.nodesToCheck[1].start then
            transferApi.vistedNodes = transferApi.nodesToAvoid
            transferApi.notNested = true
        end
        local pos = transferApi.nodesToCheck[1].pos
        local config = transferApi.nodesToCheck[1].config or {}
        transferApi.checkMaterial(pos, transferApi.nodesToCheck[1].dir, config)
        table.remove(transferApi.nodesToCheck, 1)
    end
    return true
end

--- Checks for connection material or entity
function transferApi.checkMaterial(pos, dir, config)
    if transferApi.checkForMaterial then
        for _, layer in ipairs({"background", "foreground"}) do
            local material = world.material(pos, layer)
            if transferApi.minerals[material] and transferApi.minerals[material].dir[dir] then
                if transferApi.minerals[material].config then
                    config[#config + 1] = transferApi.minerals[material].config
                end
                transferApi.vistedNodes[pos[1]..pos[2]] = 1
                local newDirections = transferApi.minerals[material].dir[dir]
                if transferApi.notNested then
                    transferApi.nodesToAvoid[pos[1]..pos[2]] = 1
                    if #newDirections > 1 then
                        transferApi.notNested = true
                    end
                end
                for _, newDir in ipairs(newDirections) do
                    local newPos = transferApi.toAbsolutePosition(pos, transferApi.directions[newDir])
                    if not transferApi.vistedNodes[newPos[1]..newPos[2]] then
                        table.insert(transferApi.nodesToCheck, 2, {pos = newPos, dir = newDir, config = config})
                    end
                end
                return true
            end
        end
    end
    local entityIds = world.entityLineQuery(pos, pos, {withoutEntityId = entity.id(), callScript = "isTransferEntity"})
    transferApi.addToMap(entityIds, config, pos)
    return false
end

--- Add entities to map
function transferApi.addToMap(entityIds, config, pos)
    config = config or {}
    if #entityIds > 0 then
        local id = entity.id()
        for _, entityId in ipairs(entityIds) do
            if not transferApi.connections[entityId] and entityId ~= id then
                local entityMode = world.callScriptedEntity(entityId, "transferApi.isConnectable", id, transferApi.type, transferApi.mode, pos)
                if entityMode then
                    transferApi.connections[entityId] = {pos = pos, config = config}
                    if transferApi.isInput(entityMode) then
                        transferApi.inputIds[#transferApi.inputIds+1] = entityId
                    end
                    if transferApi.isOutput(entityMode) then
                        transferApi.outputIds[#transferApi.outputIds+1] = entityId
                    end
                end
            end
        end
    end
end

function transferApi.calculateBorders(borders)
    -- { mainAxis, partAxis, mainAxisDirection, {startPosX, startPosY } }
    local help = {
        {2, 1,  1, {-1, 0}},  -- left side
        {1, 2,  1, { 0, transferApi.size[2]}},  -- top
        {2, 1, -1, { transferApi.size[1], transferApi.size[2]-1}},  -- right side
        {1, 2, -1, { transferApi.size[1]-1, -1}}   -- bottom
    }
    local borderPositions = {}
    for _, border in ipairs(borders) do
        local pos = transferApi.toAbsolutePosition(transferApi.pos, help[border][4])
        local mainAxis, partAxis = help[border][1], help[border][2]
        local mainAxisDirection = help[border][3]
        borderPositions[border] = {}
        for i = 0, transferApi.size[mainAxis]-1 do
            local newpos = {}
            newpos[mainAxis] = (mainAxisDirection*i) + pos[mainAxis]
            newpos[partAxis] = pos[partAxis]
            borderPositions[border][i+1] = { pos = newpos, dir = border, start = 1 }
        end
    end
    transferApi.endPos = transferApi.toAbsolutePosition(transferApi.pos, {transferApi.size[1]-1, transferApi.size[2]-1})
    transferApi.transferBorders = borderPositions
end

--- Check if position {x,y} is inside entity
function transferApi.inEntity(pos)
    if transferApi.pos[1] <= pos[1] and transferApi.pos[2] <= pos[2] and transferApi.endPos[1] >= pos[1] and transferApi.endPos[2] >= pos[2] then
        return true
    end
    return false
end

function transferApi.onInteraction(args)
    local handItem = world.entityHandItem(args["sourceId"], "primary")
    if handItem and handItem == "ele_wrench" then
        transferApi.countdown = 0
    end
end

function transferApi.toAbsolutePosition(pos, vec)
    return {vec[1] + pos[1], vec[2] + pos[2]}
end

function isTransferEntity()
    return true
end

transferApi.minerals = {
    ele_pipehoriz = {
        dir = {
            { 1 },
            false,
            { 3 },
            false
        }
    },
    ele_pipevert = {
        dir = {
            false,
            { 2 },
            false,
            { 4 }
        }
    },
    ele_pipelt = {
        dir = {
            false,
            false,
            { 2 },
            { 1 }
        }
    },
    ele_pipert = {
        dir = {
            { 2 },
            false,
            false,
            { 3 }
        }
    },
    ele_piperb = {
        dir = {
            { 4 },
            { 3 },
            false,
            false
        }
    },
    ele_pipelb = {
        dir = {
            false,
            { 1 },
            { 4 },
            false
        }
    },
    ele_pipeleft = {
        dir = {
            { 1 },
            false,
            false,
            false
        }
    },
    ele_pipetop = {
        dir = {
            false,
            { 2 },
            false,
            false
        }
    },
    ele_piperight = {
        dir = {
            false,
            false,
            { 3 },
            false
        }
    },
    ele_pipebottom = {
        dir = {
            false,
            false,
            false,
            { 4 }
        }
    }
}
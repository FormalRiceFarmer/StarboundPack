function init(args)
    if not self.initialized and not args then
        itemApi.init()
        transferApi.init({
            size = {3,1}, mode = 0, transferType = "items", borders = { 2 }
        })
        self.cooldown, self.currentTarget, self.initialized = 0, false, true
        entity.setInteractive(true)
        if storage.mode == nil then
            storage.state, storage.mode = true, "input"
        end
        if self.spawnPosition == nil then
            self.anchor = entity.configParameter("anchors")[1]
            if self.anchor == "bottom" then
                itemApi.dropPosition = entity.toAbsolutePosition({1.5,1})
                self.spawnPosition = {
                    entity.toAbsolutePosition({0,1}),
                    entity.toAbsolutePosition({2,1})
                }
            elseif self.anchor == "top" then
                itemApi.dropPosition = entity.toAbsolutePosition({1.5,1})
                self.spawnPosition = {
                    entity.toAbsolutePosition({0,-1}),
                    entity.toAbsolutePosition({2,-1})
                }
            end
        end
        updateAnimationState()
    end
end

function main()
    transferApi.update(entity.dt())
    if storage.state and self.cooldown <= 0 then
        updateAnimationState()
        if storage.mode == "input" then
            if not self.currentTarget then
                self.currentTarget = findTarget()
            end
            if self.currentTarget then
                world.logInfo("currentTarget %s", self.currentTarget)
                local itemIds = world.itemDropQuery(self.spawnPosition[1], self.spawnPosition[2])
                world.logInfo("itemIds %s", itemIds)

                for _, itemId in pairs(itemIds) do
                    local item = world.takeItemDrop(itemId)
                    if item then
                        itemApi.store(item)
                    end
                end
                if #storage.items > 0 then
                    updateAnimationState("tele")
                    local gotAnswer = world.callScriptedEntity(self.currentTarget, "setOutput", storage.items)
                    if gotAnswer then
                        storage.items, self.cooldown = {}, 4
                        return
                    else
                        self.currentTarget, self.cooldown = false, 4
                        return
                    end
                end
            else
                self.cooldown = 8
                return
            end
        end
    end
    self.cooldown = self.cooldown - 1
end

function transferApi.receive(args)
    if storage.state and self.currentTarget and storage.mode == "input" and args.action ~= "gotItems" then
        return itemApi.storeAll(args.objects)
    end
    return args.objects
end

function findTarget()
    local outboundNodeIds = entity.getOutboundNodeIds(0)
    world.logInfo("outboundNodeIds %s", outboundNodeIds)

    if #outboundNodeIds > 0 then
        for _,outboundNode in pairs(outboundNodeIds) do
            local isOutput = world.callScriptedEntity(outboundNode[1], "isTeleporterOutput")
            if isOutput then
                return outboundNode[1]
            end
        end
    else
        self.cooldown = 20
    end
    return false
end

function setOutput(items)
    if storage.state then
        updateAnimationState("tele")
        self.cooldown = 2
        local transfer = transferApi.send(items, { action = "dropItems"} )
        if not transfer then
            itemApi.dropAll(false, items)
        elseif #transfer > 0 then
            itemApi.dropAll(false, transfer)
        end
        return true
    end
end

function isTeleporterOutput()
    return storage.state
end

function onInteraction(args)
    transferApi.onInteraction(args)
    if storage.state then
        if storage.mode == "input" then
            storage.mode = "output"
            self.currentTarget = false
        else
            storage.mode = "input"
        end
        updateAnimationState()
    end
end

function updateAnimationState(state)
    if state == nil then
        state = "off"
        if storage.state then
            state = "on"
        end
    end
    entity.setAnimationState("ele_itemteleporterState", storage.mode.."_"..state.."_"..self.anchor)
end

function updateActive(active)
    storage.state = active
    updateAnimationState()
end

function onNodeConnectionChange()
    self.currentTarget = findTarget()
end

function die()
    itemApi.dropAll(itemApi.dropPosition, storage.items, true)
end
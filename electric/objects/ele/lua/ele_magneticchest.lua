function init(args)
    if not self.initialized and not args then
        itemApi.init()
        transferApi.init({
            mode = 0, transferType = "items", borders = { 1, 2, 3 }
        })
        self.initialized, self.countdown = true, 5
        itemApi.dropPosition = entity.toAbsolutePosition({1,1})
        entity.setInteractive(true)
        updateAnitmationState()
    end
end

function onInteraction(args)
    transferApi.onInteraction(args)
    if #storage.items > 0 then
        itemApi.dropAll(false, storage.items, true)
        updateAnitmationState()
    end
end

function main()
    local dt = entity.dt()
    transferApi.update(dt)
    self.countdown = self.countdown - dt
    if itemApi.hasSpace() then
        if itemApi.take(false, 5, entity.id()) then
            updateAnitmationState()
        end
    end
    if self.countdown < 1 and #storage.items > 0 and entity.getInboundNodeLevel(0) then
        self.countdown = 3
        if not sendItems() then
            self.countdown = 5
        end
    end
end

function transferApi.receive(args)
    local stored = itemApi.storeAll(args.objects)
    self.countdown = 3
    updateAnitmationState()
    return stored
end

function onNodeConnectionChange(args)
    if entity.isInboundNodeConnected(0) then
        checkInboundNode()
    end
end

function onInboundNodeChange(args)
    checkInboundNode()
end

function checkInboundNode()
    if #storage.items > 0 and entity.getInboundNodeLevel(0) then
        sendItems()
    end
end

function updateAnitmationState()
    if #storage.items == 0 then
        entity.setAnimationState("ele_magneticchestState", "empty")
    elseif itemApi.hasSpace() then
        entity.setAnimationState("ele_magneticchestState", "filled")
    else
        entity.setAnimationState("ele_magneticchestState", "full")
    end
end


function sendItems()
    local direct = transferApi.send(storage.items, { action = "dropItems"})
    if direct then
        storage.items = {}
        if #direct > 0 then
            itemApi.storeAll(direct, true)
        end
        updateAnitmationState()
        return true
    end
    return false
end

function die()
    itemApi.dropAll(itemApi.dropPosition, storage.items, true)
end
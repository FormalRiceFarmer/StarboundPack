function init(args)
    if not self.initialized and not args then
        itemApi.init()
        transferApi.init({
            mode = 0,
            transferType = "items",
            borders = { 2 }
        })
        self.initialized = true
        self.countdown = 25
        entity.setInteractive(true)
        storage.itemName = false
        itemApi.dropPosition = entity.toAbsolutePosition({1,1})
        updateAnitmationState()
    end
end

function onInteraction(args)
    if #storage.items > 0 and storage.items[1].count > 1 then
        local amt = math.min(storage.items[1].count-1, 10)
        itemApi.drop(storage.items[1], amt)
        updateAnitmationState()
    else
        local primaryItem = world.entityHandItem(args.sourceId,"primary")
        if primaryItem then
            world.logInfo("primaryItem")
            world.logInfo(primaryItem)
            world.logInfo(world.itemType(primaryItem))
            --setItem(name)
        end
    end
end

typePath = {
    generic = "/items/generic/crafting/",
    thrownitem = "/items/throwables/",
    matitem = "/items/materials/",
    instrument = "/items/instruments/",
    coinitem = "/items/coins/"
}

placeHolder = {

}

function setItem(name)
    local newItem, type = {name, 1, {} }, world.itemType(name)
    itemApi.store(newItem)
    storage.itemName = name
    if typePath[type] then
        entity.setGlobalTag("rotationFrame", typePath[type].. name ..".png")
    elseif placeHolder[type] then

    end
end

function transferApi.receive(args)
    local stored = itemApi.storeAll(args.objects)
    self.countdown = 5
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
    end
end

function die()
    itemApi.dropAll(itemApi.dropPosition, storage.items, true)
end
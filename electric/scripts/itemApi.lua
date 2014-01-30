--- Energy API
--      Example usage (would be a basic magnetic chest):
--          function itemApi()
--              itemApi.init({
--                  max = 50,
--                  dropPosition = entity.toAbsolutePosition({1,2})
--              })
--          end
--
--          function onInteraction()
--              itemApi.dropAll(false, false, true)
--          end
--
--          function main()
--              local itemIds = world.itemDropQuery(entity.position(), 4)
--              for _, itemId in pairs(itemIds) do
--                  if not itemApi.justDropped(itemId, 10) then
--                      local item = world.takeItemDrop(itemId)
--                      if item then
--                          itemApi.store(item)
--                      end
--                  end
--              end
--          end
--
--          function onNodeConnectionChange()
--              energyApi.onNodeConnectionChange()
--          end

itemApi = {}

--- Initialize item api
-- @param args (optional) Change starting parameters
--      -max: (int) maxmimum space for different items
--      -storedItems: (array) of item descriptors of existing content
--      -dropIds: (array) items recently dropped by this entity
--      -dropPosition: (array) position for automatically drops (optional)
function itemApi.init(args)
    args = args or {}
    itemApi.storage = args.storage or "items"
    if storage[itemApi.storage] == nil then
        storage[itemApi.storage] = {}
        local storedItems  = args.storedItems or entity.configParameter("storedItems")
        if storedItems then
            storage[itemApi.storage] = storedItems
        end
    end
    itemApi.dropIds = args.dropIds or {}
    itemApi.dropPosition = args.dropPosition or false
    itemApi.max = args.max or entity.configParameter("maxItems") or 50
    itemApi.maxStackSize = args.maxStackSize or 1000
end

--- Checks if there's space for more items
-- @param amount (optional) Add to current amount of items to check before adding
-- @returns True if there's enough space
function itemApi.hasSpace(amount)
    amount = amount or 0
    if itemApi.max == 0 or #storage[itemApi.storage]+amount < itemApi.max then
        return true
    end
    return false
end

--- Gets currently stored items; to be called from another enitity
-- @returns Table (array) of storred items
function itemApi.getAll()
    return storage[itemApi.storage]
end

--- Stores one item
-- @param newItem (array) item descriptor { itemname, count, data }
-- @returns True if there was enough space for the item
function itemApi.store(newItem)
    if itemApi.hasSpace() then
        for i, oldItem in ipairs(storage[itemApi.storage]) do
            if oldItem.name == newItem.name and oldItem.count < itemApi.maxStackSize and compareTables(oldItem.data, newItem.data) then
                local newCount = storage[itemApi.storage][i].count +  newItem.count
                if newCount > itemApi.maxStackSize then
                    storage[itemApi.storage][i].count = itemApi.maxStackSize
                    newItem.count = newCount - itemApi.maxStackSize
                    return itemApi.store(newItem)
                else
                    storage[itemApi.storage][i].count = newCount
                    return true
                end
            end
        end
        storage[itemApi.storage][#storage[itemApi.storage]+1] = newItem
        return true
    end
    return false, newItem
end

--- Stores multiple items
-- @param items (array) of item descriptors { { itemname, count, data }, ... }
-- @param drop (optional) drop
-- @returns (array) Ids of items that couldn't be storred or dropped
function itemApi.storeAll(items, drop)
    local unresolved = {}
    if items and #items > 0 then
        if itemApi.hasSpace() then
            -- First try to store all at once if empty
            if #storage[itemApi.storage] == 0 and itemApi.hasSpace(#items) then
                storage[itemApi.storage] = items
            else
                local time = not drop or os.time()
                for _, item in ipairs(items) do
                    if not itemApi.store(item) then
                        if drop and itemApi.dropPosition and not itemApi.drop(item, false, false, time)then
                            unresolved[#unresolved+1] = item
                        else
                            unresolved[#unresolved+1] = item
                        end
                    end
                end
            end
        end
    end
    return unresolved
end

function itemApi.take2(pos, radius, takenBy)
    return false
end

--- Try to get item drop
-- @param pos (array) position to search for items
-- @param radius (int) radius
-- @param takenBy (int) entitiy id to animate item to
-- @returns (array) Item descriptor or false if not existent
function itemApi.take(pos, radius, takenBy)
    pos = pos or itemApi.dropPosition
    radius = radius or 1
    local c, time = false, os.time()
    if itemApi.hasSpace() then
        local itemIds = world.itemDropQuery(pos, radius)
        for _, itemId in ipairs(itemIds) do
            if not itemApi.justDropped(itemId, time) then
                local item = world.takeItemDrop(itemId, takenBy)
                if item then
                    c = (c or 0) + 1
                    itemApi.store(item)
                end
            end
        end
    end
    return c
end

--- Drops one item
-- @param item (array) Item descriptor
-- @param amt (optional) If provided will only drop certain amount of item
-- @param pos (optional) { x, y } to drop item
-- @param time (optional) current os.time time
-- @returns Id of dropped item or false
function itemApi.drop(item, amt, pos, time)
    pos = pos or itemApi.dropPosition
    time = time or os.time()
    local drop = false
    if amt and amt > item.count then
       local newItem = item
       newItem.count = newItem.count - amt
       item.count = amt
       itemApi.store(newItem)
    end
    if not item.data or next(item.data) == nil then
        drop = world.spawnItem(item.name, pos, item.count)
    else
        drop = world.spawnItem(item.name, pos, item.count, item.data)
    end
    if drop then
        itemApi.dropIds[drop] = time
        return drop
    end
    return false
end

--- Drops all items
-- @param pos (optional) { x, y } to drop items
-- @param items (optional) Table of item descriptors { { itemname, count, data }, ... }
-- @param delete (optional) Delete form storage[itemApi.storage]
-- @returns True if it could drop all items
function itemApi.dropAll(pos, items, delete)
    pos = pos or itemApi.dropPosition
    items = items or storage[itemApi.storage]
    local time, count, i, c = os.time(), #items, 1, 0
    while i <= #items do
        if itemApi.drop(items[i], false, pos, time) then
            c = c + 1
            if delete then
                table.remove(storage[itemApi.storage], i)
            else i=i+1 end
        else i=i+1 end
    end
    if count == c  then
        return true
    end
    return false
end

--- Checks if item was recently dropped by
-- @param itemId (int) id of dropped item entity
-- @param cooldown (optional) how long to let the item stay
-- @param time (optional) current os.time time
-- @returns True if it could drop all
function itemApi.justDropped(itemId, cooldown, time)
    cooldown = cooldown or 20
    time = time or os.time()
    if itemApi.dropIds[itemId] == nil or itemApi.dropIds[itemId]+cooldown < time then
        itemApi.dropIds[itemId] = nil
        return false
    end
    return true
end

--- Empty the storage
function itemApi.emptyStorage()
    storage[itemApi.storage] = {}
end

--- Remember to drop items on die
function itemApi.die()
    itemApi.dropAll(itemApi.dropPosition, storage[itemApi.storage], true)
end

-----------------

function compareTables(first, second)
    if next(first) == nil and next(second) == nil then
        return true
    end
    for i, v in pairs(first) do
        if not second[i] or v ~= second[i] then
            return false
        end
    end
    for i, v in pairs(second) do
        if not second[i] or v ~= second[i] then
            return false
        end
    end
    return true
end
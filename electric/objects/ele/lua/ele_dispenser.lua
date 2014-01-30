function init(args)
    if not self.initialized and not args then
        self.initialized = true
        entity.setInteractive(true)
        transferApi.init({
            size = {1,1}, mode = 2,
            type = {items = 1, liquids = 1}
        })
        itemApi.dropIds = {}
        storage.liquids = {}
        if storage.active == nil then
            storage.active = false
        end
        if self.dropPosition == nil then
            self.anchor = entity.configParameter("anchors")[1]
            if self.anchor == "bottom" then
                self.dropPosition = entity.toAbsolutePosition({0,0})
            elseif self.anchor == "top" then
                self.dropPosition = entity.toAbsolutePosition({0,-0})
            elseif self.anchor == "right" then
                if entity.direction() * 1 == -1 then
                    self.anchor = "left"
                end
                self.dropPosition = entity.toAbsolutePosition({-0,0})
            elseif self.anchor == "left" then
                if entity.direction() * -1 == 1 then
                    self.anchor = "right"
                end
                self.dropPosition = entity.toAbsolutePosition({0,0})
            end
            --world.placeObject("ele_placeholder", self.dropPosition, entity.direction())
        end
		updateActive(storage.active)
    end
end

function transferApi.can()
    return storage.active
end

function transferApi.receive(args)
    if transferApi.can() then
        if args.type == "items" then
            if itemApi.dropAll(self.dropPosition, args.objects) then
                return {}
            end
        elseif args.type == "liquids" then
            storage.liquids[args.objects[1][1]] = args.objects[1][2]
            world.logInfo(args.objects[1])
            if liquidApi.spawn(args.objects[1][1], args.objects[1][2], self.dropPosition) then
                return {}
            end
        end
    end
    return false
end

function updateActive(active)
    storage.active = active
    if active then
		entity.setAnimationState("ele_dispenseState", "on"..self.anchor)
    else
		entity.setAnimationState("ele_dispenseState", self.anchor)
    end
end

function onInboundNodeChange(args)
    updateActive(args.level)
end

function onInteraction(args)
    updateActive(not storage.active)
end

function main()
    transferApi.update(entity.dt())
end
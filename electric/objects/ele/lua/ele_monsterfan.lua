function init(args)
    if not self.initialized and not args then
        energyApi.init()
        self.initialized =  true
        entity.setInteractive(true)
        entity.setColliding(true)
        if storage.state == nil then
            storage.state = true
        end
        if self.rangePosition == nil then
            local range = entity.configParameter("range")
            self.anchor = entity.configParameter("anchors")[1]
            if self.anchor == "bottom" then
                self.changeVelocity = {0, 1, 2, 1}
                self.rangePosition = { entity.toAbsolutePosition({-1,2}), entity.toAbsolutePosition({1,2+range}), entity.toAbsolutePosition({0,2}) }
            elseif self.anchor == "top" then
                self.changeVelocity = {0, -1.2, 2, 1}
                self.rangePosition = { entity.toAbsolutePosition({-1,-2}), entity.toAbsolutePosition({1,-2-range}), entity.toAbsolutePosition({0,-2}) }
            elseif self.anchor == "right" then
                if entity.direction() * 1 == -1 then
                    self.anchor = "left"
                end
                self.changeVelocity = {-1, 0, 1, 2}
                self.rangePosition = { entity.toAbsolutePosition({-2-range,1}), entity.toAbsolutePosition({-2,-1}), entity.toAbsolutePosition({-2,0}) }
            elseif self.anchor == "left" then
                if entity.direction() * -1 == 1 then
                    self.anchor = "right"
                end
                self.changeVelocity = {1, 0, 1, 2}
                self.rangePosition = { entity.toAbsolutePosition({2,-1}), entity.toAbsolutePosition({2+range,1}), entity.toAbsolutePosition({2,0}) }
            end
        end
        updateAnimationState(storage.state)
        --world.placeObject("ele_placeholder", self.rangePosition[3], entity.direction())
    end
end

function main()
    if storage.state then
        if storage.energy < 50 then
            self.requestTimeout = 0
        end
        if energyApi.check() then
            updateAnimationState(true)
            local range, speed = entity.configParameter("range"), entity.configParameter("speed")
            local config = {
                callScript = "updatePush",
                callScriptArgs = {
                    entity.id(),
                    {
                        pos = self.rangePosition[3],
                        changeVelocity = self.changeVelocity,
                        range = range,
                        speed = speed,
                        timeout = 5
                    }
                }
            }
            local query = world.entityQuery(self.rangePosition[1], self.rangePosition[2], config)
            -- dirty fix for a weird bug with rectangular queries
            if self.anchor == "top" and #query == 0 then
                world.entityQuery(self.rangePosition[2], self.rangePosition[1], config)
            end
        else
            updateAnimationState(false)
        end
    end
end

function onInteraction(args)
    updateActive(storage.state == false)
end

function onInboundNodeChange(args)
    updateActive(args.level)
end

function onNodeConnectionChange()
    if energyApi.onNodeConnectionChange() and storage.energy == 0 then
        if energyApi.get(20) then
            main()
        end
    end
end

function isActive()
    return storage.state
end

function updateActive(active)
    if storage.state ~= active then
        updateAnimationState(active)
    end
    storage.state = active
end

function updateAnimationState(active)
    if not active then
        entity.setAnimationState("ele_monsterfanState",  "off"..self.anchor)
        return
    end
    entity.setAnimationState("ele_monsterfanState",  self.anchor)
end
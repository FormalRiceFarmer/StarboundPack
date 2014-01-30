function init(args)
    if not self.initialized and not args then
        liquidApi.init({
            max = 10000, maxLiquids = 3, liquids = 0, pos = entity.toAbsolutePosition({1, 0})
        })
        transferApi.init({
            size = {3, 3}, borders = { 1, 2, 3 }, mode = 1, type = "liquids"
        })
        self.countdown, self.maxPipeLengt, self.initialized, self.pipeLength = 0, 50, true, 0
        entity.setInteractive(true)
        if storage.active == nil then
           storage.active, storage.doneSearch = false, false
        end
    end
end

function main()
    transferApi.update(entity.dt())
    if storage.active then
        if liquidApi.send() then
            entity.setAnimationState("ele_pumpState", "pump")
            self.countdown = 3
        end
        if next(storage.liquids) == nil then
            if liquidApi.take() then
                storage.doneSearch = false
                entity.setAnimationState("ele_pumpState", "pump")
                self.countdown = 3
            elseif not storage.doneSearch and self.countdown == 0 then
                self.pipeLength = self.pipeLength + 1
                if self.pipeLength%5 == 0 or self.pipeLength == 1 then
                    liquidApi.pos = toAbsolutePosition(liquidApi.pos, {0, -0.5 })
                end
                if world.pointCollision(liquidApi.pos) or self.pipeLength > self.maxPipeLengt then
                    storage.doneSearch, self.pipeLength = true, 0
                    liquidApi.pos = entity.toAbsolutePosition({1, 0})
                end
                entity.scaleGroup("pipe", { 1, -self.pipeLength })
            end
        end
        if self.countdown == 0 then
            entity.setAnimationState("ele_pumpState", "idle")
        else
            self.countdown = self.countdown - 1
        end
    end
end

function onInteraction(args)
    updateActive(not storage.active)
    transferApi.onInteraction(args)
    storage.doneSearch = false
    if storage.active then
        entity.setAnimationState("ele_pumpState", "idle")
    else
        entity.setAnimationState("ele_pumpState", "off")
    end
end

function updateActive(active)
    storage.active = active
end

function onInboundNodeChange(args)
    updateActive(args.level)
end

function toAbsolutePosition(pos, vec)
    return {vec[1] + pos[1], vec[2] + pos[2]}
end
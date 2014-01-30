function init(args)
    if not self.initialized and not args then
        self.initialized, self.liquid = true, entity.configParameter("turbineLiquid")
        energyApi.init({ max = 1000, supplier = true })
        liquidApi.init({ max = 20000, liquids = { self.liquid } })
        transferApi.init({
            size = {3, 2}, borders = {}, mode = 2, type = "liquids"
        })
        entity.setInteractive(true)
        if storage.active == nil then
            storage.active = true
        end
        updateActive(storage.active)
    end
end

function energyApi.income()
    if storage.active and next(storage.liquids) ~= nil then
        return entity.configParameter("generatedEnergy")
    end
    return 0
end

function main()
    if storage.active then
        local income = energyApi.income()
        if income > 0 and energyApi.hasSpace() and liquidApi.use(self.liquid, entity.configParameter("useLiquid")) then
            entity.setAnimationState("ele_turbineState", "generate")
            energyApi.generate(income)
        else
            entity.setAnimationState("ele_turbineState", "idle")
        end
    end
end

function transferApi.can(args)
    return storage.active and args.liquidId == self.liquid and liquidApi.hasSpace()
end

function onInteraction()
    updateActive(not storage.active)
end

function updateActive(active)
    storage.active = active
    if active then
        entity.setAnimationState("ele_turbineState", "idle")
    else
        entity.setAnimationState("ele_turbineState", "off")
    end
end
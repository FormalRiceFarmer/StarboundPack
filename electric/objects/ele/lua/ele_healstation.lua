function init(args)
    if not self.initialized and not args then
        energyApi.init()
        self.initialized = true
        self.cooldown = 0
        self.spawnPosition = entity.toAbsolutePosition({-1,4})
        entity.setInteractive(true)
        if storage.state == nil then
            storage.state = "off"
        end
        if storage.helperId == nil then
            storage.helperId = false
        end
        if storage.dir == nil then
            if entity.direction() < 0 then
                storage.dir = "flipped"
            else
                storage.dir = ""
            end
        end
        entity.setAnimationState("ele_healstationState", storage.state..storage.dir);

    end
end

function onInteraction(args)
    local playerId = args["sourceId"]
    local health = world.entityHealth(playerId)
    if health[1] < health[2] and not storage.helperId and energyApi.check() then
        local healAmount = entity.configParameter("healAmount")
        local objectConfig = entity.configParameter("objectConfig")
        objectConfig.statusEffects[1].amount = health[2]*healAmount
        if world.placeObject("ele_healhelper", self.spawnPosition, entity.direction(), objectConfig) then
            storage.helperId = world.objectQuery(self.spawnPosition, 1, { name = "ele_healhelper" })[1]
            self.cooldown = 0
        end
    end
    updateState()
end

function main()
    if self.cooldown then
        if self.cooldown == 0 then
            if storage.helperId then
                world.callScriptedEntity(storage.helperId, "entity.smash")
                storage.helperId = false
            end

            local maxEnergy = entity.configParameter("maxEnergy")
            if storage.energy < maxEnergy then
                energyApi.get(150)
                updateState()
                self.cooldown = 1
            else
                self.cooldown = false
            end
        else
            self.cooldown = self.cooldown - 1
        end
    end
end

function onNodeConnectionChange(args)
    if energyApi.onNodeConnectionChange(args) and storage.energy == 0 then
        if energyApi.get(15) then
            updateState()
        end
    end
end

function updateState()
    local maxEnergy = entity.configParameter("maxEnergy")
    local perc = 100/maxEnergy*storage.energy
    if perc >= 100 then
        storage.state = "fill3"
    elseif perc > 66 then
        storage.state = "fill2"
    elseif perc > 33 then
        storage.state = "fill1"
    elseif perc > 0 then
        storage.state = "fill0"
    else
        storage.state = "off"
    end
    entity.setAnimationState("ele_healstationState", storage.state..storage.dir);
end
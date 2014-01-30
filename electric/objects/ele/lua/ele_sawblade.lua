function init(args)
    if not self.initialized and not args then
        energyApi.init()
        entity.setInteractive(true)
        self.initialized = true
        self.timer = 0
        self.wait = 0
        if storage.state == nil then
            storage.state = "Off"
        end
        if self.anchor == nil then
            self.anchor = entity.configParameter("anchors")[1]
        end
        entity.setAnimationState("ele_sawbladeState", self.anchor..storage.state)
    end
end

function updateActive(active)
    if active then
        storage.state = "On"
        --entity.playSound("onSounds")
        main()
    else
        storage.state = "Off"
        entity.setAnimationState("ele_sawbladeState", self.anchor..storage.state);
    end
end

function main()
    self.timer = self.timer + 1

    if storage.state == "On" and  self.timer > self.wait then
        if energyApi.check() then
            local fireCooldown = entity.configParameter("fireCooldown")
            local projectileConfig = entity.configParameter("projectileConfig")

            entity.setAnimationState("ele_sawbladeState", self.anchor..storage.state);
            self.wait = 0
            world.spawnProjectile("ele_invdamage", entity.toAbsolutePosition({ 0.0, 0.5 }), entity.id(), { 0, 1 }, false, projectileConfig)
            if fireCooldown > 0 then
                self.wait = self.timer + fireCooldown
            end
        else
            entity.setAnimationState("ele_sawbladeState", self.anchor.."Off");
            self.wait = self.timer + 5
        end
    else
        entity.setAnimationState("ele_sawbladeState", self.anchor.."Off");
    end
end

function isActive()
    if storage.state == "On" then
        return true
    end
    return false
end

function onInteraction()
    updateActive(storage.state == "Off")
end

function onInboundNodeChange(args)
    updateActive(args.level)
end

function onNodeConnectionChange()
    if energyApi.onNodeConnectionChange() and storage.energy == 0 then
        if energyApi.get(15) then
            main()
        end
    end
end

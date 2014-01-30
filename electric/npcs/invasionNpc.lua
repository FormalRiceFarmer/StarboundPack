function setInvasionTarget(targetId, objectId)
    if targetId then
        storage.targetId = targetId
        storage.objectId = objectId
        if storage.attackOnSightIds then
            storage.attackOnSightIds[targetId] = world.time()+1000
        else
            storage.attackOnSightIds = {targetId = world.time()+1000}
        end
        self.state = stateMachine.create({
            "invasionState",
            "meleeAttackState",
            "rangedAttackState"
        })
        self.state.pickState({targetId = targetId, objectId = objectId})
    end
end

function deactivateEnergyObjects()
    world.objectQuery(entity.position(), 3, {callScript = "deactivateTrap" })
end

function main()
    local dt = entity.dt()

    deactivateEnergyObjects()
    self.state.update(dt)
    self.timers.tick(dt)
    if not self.state.hasState() then
        self.state.pickState({targetId = storage.targetId, objectId = storage.objectId})
    end
end
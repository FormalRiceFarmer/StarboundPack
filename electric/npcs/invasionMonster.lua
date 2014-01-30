function setInvasionTarget(targetId)
    if targetId then
        self.targetPosition = world.entityPosition(targetId)
        self.targetId = targetId
        self.state.update(entity.dt())
    end
end
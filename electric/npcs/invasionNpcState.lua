invasionState = {}

function invasionState.enterWith(params)
    if params.targetId == nil then return nil, 10 end
    return {
        timer = 1000,
        targetId = params.targetId,
        objectId = params.objectId,
        lastPosition = entity.position(),
        stuckTimer = 0
    }
end

function invasionState.update(dt, stateData)
    stateData.timer = stateData.timer - dt
    if world.entityExists(stateData.targetId) then
        attack(stateData.targetId,stateData.targetId,true)

        if not moveTo(world.entityPosition(stateData.targetId),entity.dt(),{ run = true }) then
            return true, 10
        end

        local position = entity.position()
        if position[1] == stateData.lastPosition[1] then
            stateData.stuckTimer = stateData.stuckTimer + dt
            if stateData.stuckTimer >= 4 then
                return true, 10
            end
        else
            stateData.stuckTimer = 0
        end

        stateData.lastPosition = position
    else
        return true, 10
    end

    return stateData.timer <= 0
end

function invasionState.leavingState(stateData)
    if stateData and stateData.timer < 995 then
        world.callScriptedEntity(stateData.objectId, "destroy")
    end
end
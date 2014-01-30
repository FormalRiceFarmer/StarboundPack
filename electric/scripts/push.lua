function pushEntity(force)
    if entity.setVelocity(force) then
        return true
    end
    return false
end

function canBePushed()
    return true
end


function updatePush(id, args)
    -- To fix problem that entity's position is the head
    -- TODO: Find way to get the exact middle of every entity
    local entityPos = entity.toAbsolutePosition({0,-1.5})

    if self.fans == nil then
        self.fans = {}
    end
    if self.fans[id] then
        self.fans[id].timeout = 5
    else
        -- Check for collision at first enter; maybe to less
        if not world.lineCollision(args.pos, entityPos) then
            self.fans[id] = args
        end
    end
    local velocity = entity.velocity()

    for id, fan in pairs(self.fans) do
        local distance = world.distance(fan.pos, entityPos)
        local mainAxis = fan.changeVelocity[3]
        local partAxis = fan.changeVelocity[4]
        if math.abs(distance[mainAxis]) > fan.range or math.abs(distance[partAxis]) > 2 or fan.timeout == 0 then
            self.fans[id] = nil
        else
            -- (Range - Distance + Little Boost (to not hit 0 velocity)) * speed of fan * direction
            local force = ( fan.range - math.abs(distance[mainAxis]) + 1 ) * fan.speed * fan.changeVelocity[mainAxis]
            velocity[mainAxis] = velocity[mainAxis] + force
            -- Check if velocity is greater as force as force is always the maximum on the mainAxis
            if force > 0 then
                if velocity[mainAxis] > force then
                    velocity[mainAxis] = force
                end
            else
                if velocity[mainAxis] < force then
                    velocity[mainAxis] = force
                end
            end
            -- Slow down movement on the partAxis
            velocity[partAxis] = velocity[partAxis]/1.3
            self.fans[id].timeout = self.fans[id].timeout - 1
        end
    end
    entity.setVelocity(velocity)
    return true
end
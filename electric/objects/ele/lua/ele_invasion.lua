function init(args)
    if not self.initialized and not args then
        self.initialized = true

        entity.setInteractive(true)
        self.state = "idle"
        self.cooldown = 10
        entity.setAnimationState("ele_invasionState", self.state);
    end
end

function destroy()
    self.state = "idle"
    entity.smash()
    world.spawnProjectile("regularexplosion2", entity.toAbsolutePosition({ 0.0, 1.0 }))
end

function main()
    if self.state == "active" and self.cooldown <= 0 then
        local randPlayer = self.playerId[math.random(#self.playerId)]
        if not world.entityExists(randPlayer) then
            destroy()
        end
        local spawnMonsters = entity.configParameter("spawnMonsters")
        local spawnBoss = entity.configParameter("spawnBoss")
        local randcheck = math.random(100) - (self.counter/10)
        if self.counter < entity.configParameter("maxMonster") then
            for _, spawnMonster in pairs(spawnMonsters) do
                if randcheck < spawnMonster[1] then
                    local monsterId = spawn(spawnMonster)
                    if monsterId then
                        self.monsterIds[#self.monsterIds+1] = monsterId
                        world.callScriptedEntity(monsterId, "setInvasionTarget", randPlayer, entity.id())
                        self.counter = self.counter + 1
                        if self.counter == 1 then
                            self.cooldown = 4
                        elseif self.counter < 8 then
                            self.cooldown = 2
                        elseif self.counter < 16 then
                            self.cooldown = 1
                        else
                            self.cooldown = 0
                        end
                    end
                end
            end
        elseif self.bossCounter < #spawnBoss then
            if #self.monsterIds == 0 then
                -- Enemies are dead; Spawn bosses
                self.bossCounter = self.bossCounter + 1
                if spawnBoss[self.bossCounter] then
                    for _, playerId in pairs(self.playerId) do
                        local monsterId = spawn(spawnBoss[self.bossCounter], 1)
                        if monsterId then
                            self.bossIds[#self.bossIds+1] = monsterId
                            world.callScriptedEntity(monsterId, "setInvasionTarget", playerId, entity.id())
                        end
                    end
                end
            else
                -- Check if enemies are still alive
                for k, monsterId in pairs(self.monsterIds) do
                    if not world.entityExists(monsterId) then
                        self.monsterIds[k] = nil
                    end
                end
            end
        else
            if #self.bossIds == 0 then
                -- Bosses are dead; Spawn treasures at player
                local treasures = entity.configParameter("treasure")
                for _, treasure in pairs(treasures) do
                    for _, playerId in pairs(self.playerId) do
                        world.spawnItem(treasure[1], world.entityPosition(playerId), treasure[2])
                    end
                end
                destroy()
            else
                -- Check if bosses are still alive
                for k, bossId in pairs(self.bossIds) do
                    if not world.entityExists(bossId) then
                        self.bossIds[k] = nil
                    end
                end
            end
        end
    else
        self.cooldown = self.cooldown - 1
    end
end

function spawn(params, plus)
    local level, monsterId = entity.configParameter("level") + (plus or 0), false
    local movementControllerSettings = entity.configParameter("movementControllerSettings")
    movementControllerSettings.walkSpeed = entity.randomizeParameterRange("movementControllerSettings.walkSpeed")
    movementControllerSettings.runSpeed = entity.randomizeParameterRange("movementControllerSettings.runSpeed")

    if params[4] then
        local npcParameter = params[4]
        npcParameter.scripts = entity.configParameter("npcScripts")
        npcParameter.levelVariance = {level,level}
        npcParameter.movementControllerSettings = movementControllerSettings
        monsterId = world.spawnNpc(self.spawnPosition, params[3], params[2], level, false, npcParameter)
    else
        local monsterParameter = params[3]
        monsterParameter.level = level
        monsterParameter.scripts = entity.configParameter("monsterScripts")
        monsterId = world.spawnMonster(params[2], self.spawnPosition, monsterParameter)
    end
    return monsterId
end

function onInteraction(args)
    if not goodReception() then
        return { "ShowPopup", { message = "I should take it to the planet surface before activating it." } }
    elseif not isInside(entity.position())then
        return { "ShowPopup", { message = "I should take it inside activating it." } }
    else
        self.spawnPosition = findSpawnPoint()
        if not self.spawnPosition then
            return { "ShowPopup", { message = "It could't find a proper spawn point. I should try another position." } }
        end
        entity.setInteractive(false)
        self.state = "active"
        self.playerId = world.playerQuery(entity.position(), 30, { order = "nearest" })
        if #self.playerId == 0 then
            self.playerId = {args["sourceId"]}
        end
        self.maxMonsters = entity.configParameter("maxMonster")
        self.maxMonsters = self.maxMonsters * (#self.playerId+2)/3
        self.cooldown, self.counter = 3, 0
        self.monsterIds, self.bossIds = {}, {}
        self.bossCounter = 0

        entity.setAnimationState("ele_invasionState", self.state);
    end
end

function findSpawnPoint()
    local direction = 1
    local objPos = entity.position()
    local check = false
    for i = 1, 100, 1 do
        check = checkPosition({ objPos[1]+i, objPos[2] }, 0)
        if check then
            break
        else
           check = checkPosition({ objPos[1]-i, objPos[2] }, 0)
            if check then
               direction = -1
               break
            end
        end
    end
    if check then
        -- Plus 80 blocks from entrance
        check[1] = check[1] + (direction * 80)
        if checkPosition(check) then
            local max = 50
            while checkPosition(check) do
                max = max - 1
                check[2] = check[2] - 1
                if max < 0 then
                   return check
                end
            end
            check[2] = check[2] + 2
        else
            local max = 100
            while not checkPosition(check) do
                max = max - 1
                check[2] = check[2] + 1
                if max < 0 then
                    return false
                end
            end
            if not world.pointCollision({check[1], check[2]+2}) then
                check[2] = check[2] + 2
                return check
            end
        end
        return check
    end
    return false
end

function checkPosition(pos)
    local material = world.material(pos, "background")
    if material == nil and not world.pointCollision(pos) then
        return pos
    end
    return false
end

function goodReception()
  if world.underground(entity.position()) then
    return false
  end
  return true
end

function isInside(position)
    --local material = world.material(position, "background")
    --return material ~= nil and material ~= "dirt" and material ~= "drysand"
    return true
end
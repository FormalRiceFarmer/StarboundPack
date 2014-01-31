function init(virtual)
  if not virtual then
	energy.init()
    if storage.state == nil then
      storage.state = false
    end

    if storage.timer == nil then
      storage.timer = 0
    end

	storage.fuel = 0
	
	self.fueltype = entity.configParameter("fueltype") or 3
	self.fuelUseRate = entity.configParameter("fueluserate") or 200
	self.energenrate = entity.configParameter("energenrate") or 20
	
    updateAnimationState()
	
    self.connectionMap = {}
    self.connectionMap[1] = 2
    self.connectionMap[2] = 1
	
    pipes.init({liquidPipe})
  end
end

function die()
  energy.die()
end

function main()
	pipes.update(entity.dt())
	if storage.fuel>0 then
		storage.fuel = storage.fuel - 1
		if not storage.state then
			storage.state = true
			updateAnimationState()
		end
	else
		if storage.state then
			storage.state = false
			updateAnimationState()
		end
	end
	energy.update()
end

--only send energy while generating (even if it's in the pool... could try revamping this later)
function onEnergySendCheck()
   return energy.getEnergy()
end

--never accept energy from elsewhere
function onEnergyNeedsCheck(energyNeeds)
  energyNeeds[tostring(entity.id())] = 0
  return energyNeeds
end

function beforeLiquidGet(liquid, nodeId)
  --world.logInfo("passing liquid peek get from %s to %s", nodeId, self.connectionMap[nodeId])
  return peekPullLiquid(self.connectionMap[nodeId], liquid)
end

function onLiquidGet(liquid, nodeId)
  --world.logInfo("passing liquid get from %s to %s", nodeId, self.connectionMap[nodeId])
  return pullLiquid(self.connectionMap[nodeId], liquid)
end

function beforeLiquidPut(liquid, nodeId)
  --world.logInfo("passing liquid peek from %s to %s", nodeId, self.connectionMap[nodeId])
  return peekPushLiquid(self.connectionMap[nodeId], liquid)
end

function onLiquidPut(liquid, nodeId)
	local power = false
  	if liquid[1]==self.fueltype then
		if liquid[2] > self.fuelUseRate then
			power = true
			liquid[2] = liquid[2] - self.fuelUseRate
		end
	end
	local result = pushLiquid(self.connectionMap[nodeId], liquid)
	if result then
		if power then
			energy.addEnergy(self.energenrate)
			storage.fuel = storage.fuel+4
		end
	end
	return result
end

function updateAnimationState()
	if storage.fuel > 0 then
		entity.setAnimationState("turbineState", "generate")
    else
        entity.setAnimationState("turbineState", "off")
    end
end

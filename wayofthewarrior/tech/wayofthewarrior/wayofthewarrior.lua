function init()
  data.air = false
  data.direction = 0
  data.inputTimer = 0
  data.maxStepTime = 0.3 --maximum time for each command step
  data.currHadoRStep = 1
  data.doHadouken = false
  data.currSHadoRStep = 1
  data.currShorStep = 1
  data.doSHadouken = false
  data.doShoryuken = false
  data.shoryukenPeak = false --used to mark when hit peak of shoryuken uppercut
  data.projFired = false
  data.proj2Fired = false
  data.animTimer = 0 --timer used for animations
  data.reappeared = false
  data.hyperBarStep = 0 -- max of 11 (full bar)
  data.backgroundFlag = false --if hyperbackground is in use
  data.soundFlag = false
  data.projCounter = 1 --used to spawn certain amount of projectiles
  tech.setParentAppearance("normal")
  tech.setAnimationState("fighting", "off")
  tech.setAnimationState("shadoukenbeam", "off")
  tech.setAnimationState("beameffect1", "off")
  tech.setAnimationState("hypercharge", "off")
  tech.setAnimationState("warping", "off")
  data.entityTable = {}
  data.gotEnergy = false --used for modular energy cost
  data.maxEnergy = 0 --used for modular energy cost
  data.currEnergy = 0 --used for modular energy cost
  data.showBar = true
end

function getDirection(position, techpos)
  if position < techpos then
    return -1
  else
    return 1
  end
end

function showHyperBar()
  if data.showBar == false then
    tech.setAnimationState("hyperbar", "off")
  elseif data.direction == 1 then
    if data.hyperBarStep == 0 then tech.setAnimationState("hyperbar", "empty")
    elseif data.hyperBarStep == 1 then tech.setAnimationState("hyperbar", "10")
    elseif data.hyperBarStep == 2 then tech.setAnimationState("hyperbar", "20")
    elseif data.hyperBarStep == 3 then tech.setAnimationState("hyperbar", "30")
    elseif data.hyperBarStep == 4 then tech.setAnimationState("hyperbar", "40")
    elseif data.hyperBarStep == 5 then tech.setAnimationState("hyperbar", "50")
    elseif data.hyperBarStep == 6 then tech.setAnimationState("hyperbar", "60")
    elseif data.hyperBarStep == 7 then tech.setAnimationState("hyperbar", "70")
    elseif data.hyperBarStep == 8 then tech.setAnimationState("hyperbar", "80")
    elseif data.hyperBarStep == 9 then tech.setAnimationState("hyperbar", "90")
    elseif data.hyperBarStep == 10 then tech.setAnimationState("hyperbar", "100")
    elseif data.hyperBarStep == 11 then tech.setAnimationState("hyperbar", "full")
    end
  else
    if data.hyperBarStep == 0 then tech.setAnimationState("hyperbar", "emptyL")
    elseif data.hyperBarStep == 1 then tech.setAnimationState("hyperbar", "10L")
    elseif data.hyperBarStep == 2 then tech.setAnimationState("hyperbar", "20L")
    elseif data.hyperBarStep == 3 then tech.setAnimationState("hyperbar", "30L")
    elseif data.hyperBarStep == 4 then tech.setAnimationState("hyperbar", "40L")
    elseif data.hyperBarStep == 5 then tech.setAnimationState("hyperbar", "50L")
    elseif data.hyperBarStep == 6 then tech.setAnimationState("hyperbar", "60L")
    elseif data.hyperBarStep == 7 then tech.setAnimationState("hyperbar", "70L")
    elseif data.hyperBarStep == 8 then tech.setAnimationState("hyperbar", "80L")
    elseif data.hyperBarStep == 9 then tech.setAnimationState("hyperbar", "90L")
    elseif data.hyperBarStep == 10 then tech.setAnimationState("hyperbar", "100L")
    elseif data.hyperBarStep == 11 then tech.setAnimationState("hyperbar", "fullL")
    end
  end
end

function incrementHyper()
  if data.hyperBarStep < 11 then
    data.hyperBarStep = data.hyperBarStep + 1
  end
end

function seqCheck(currStep, move)
  
  --check if sequence complete
  if currStep > #move then
    return true
  else
    --reset timer and wait for next move
    data.inputTimer = data.maxStepTime
  end
  return false
end


function input(args)
  
  -- local hadoukenCommandsR = { "down", "downright", "right", "rightspecial1" }
  -- local hadoukenCommandsR2 = { "down", "downright", "right", "special1" }
  -- local shadoukenCommandsR = { "down", "downright", "right", "down", "downright", "right", "rightspecial1" }
  -- local shadoukenCommandsR2 = { "down", "downright", "right", "down", "downright", "right", "special1" }
  -- local shoryukenCommandsR = { "right", "down", "downright", "special1" }
  -- local shoryukenCommandsR2 = { "right", "down", "downright", "downrightspecial1" }
  -- local shoryukenCommandsR3 = { "right", "down", "downright", "right", "special1" }
  -- local shoryukenCommandsR4 = { "right", "down", "downright", "rightspecial1" }
  local hadoukenCommandsR = { "down", "downright", "right", "rightprimaryFire" }
  local hadoukenCommandsR2 = { "down", "downright", "right", "primaryFire" }
  local shadoukenCommandsR = { "down", "downright", "right", "down", "downright", "right", "rightprimaryFire" }
  local shadoukenCommandsR2 = { "down", "downright", "right", "down", "downright", "right", "primaryFire" }
  local shoryukenCommandsR = { "right", "down", "downright", "primaryFire" }
  local shoryukenCommandsR2 = { "right", "down", "downright", "downrightprimaryFire" }
  local shoryukenCommandsR3 = { "right", "down", "downright", "right", "primaryFire" }
  local shoryukenCommandsR4 = { "right", "down", "downright", "rightprimaryFire" }
  
  if args.moves["special"] == 2 then
    if data.showBar == true then
	  data.showBar = false
	else
	  data.showBar = true
	end
  end

  ---- debug stuff  
  -- if args.moves["special"] == 3 then
    -- data.hyperBarStep = 11
  -- end
  
  ------suppress fire----------- (prevents person from swinging when clicking)
  
  if data.currHadoRStep == #hadoukenCommandsR-1 or data.currShorStep == #shoryukenCommandsR-1 or data.currSHadoRStep == #shadoukenCommandsR-1 then
    tech.setToolUsageSuppressed(true) --get unsuppressed after attack animation in update
  -- else
    -- tech.setToolUsageSuppressed(false)
  end
  
  if data.inputTimer <= 0.05 and not data.doHadouken and not data.doShoryuken and not data.doSHadouken then --half of maxStepTime
    tech.setToolUsageSuppressed(false)
  end
  
  ------------------------------

  --just mash all the commands into one string
  local inputStr = ""
  for i, command in ipairs({"up", "down", "left", "right", "special", "primaryFire"}) do
    if command == "special" and args.moves["special"] > 0 then
	  inputStr = inputStr.."special1"
    elseif args.moves[command] and command ~= "special" then
	  inputStr = inputStr..command
    end
  end
     
  --decrement timer
  if data.inputTimer > 0 then
    data.inputTimer = data.inputTimer - args.dt
  end
  
  --world.logInfo("move: %s, stepnum %d", inputStr, data.currentStep)
     
  if data.inputTimer <= 0 then
    --reset if time expired
	data.inputTimer = data.maxStepTime
	data.currHadoRStep = 1
	data.currSHadoRStep = 1
	data.currShorStep = 1
  else
    --now you can tell whether your inputs match with just one comparison
	if shadoukenCommandsR[data.currSHadoRStep] == inputStr then
	  data.currSHadoRStep = data.currSHadoRStep + 1
	  if seqCheck(data.currSHadoRStep, shadoukenCommandsR) then
	    if data.hyperBarStep < 11 then
	      return "hadouken"
		else
		  return "shadouken"
		end
	  end
	elseif shadoukenCommandsR2[data.currSHadoRStep] == inputStr then
	  data.currSHadoRStep = data.currSHadoRStep + 1
	  if seqCheck(data.currSHadoRStep, shadoukenCommandsR2) then
	    if data.hyperBarStep < 11 then
	      return "hadouken"
		else
		  return "shadouken"
		end
	  end
	elseif shoryukenCommandsR[data.currShorStep] == inputStr then
	  data.currShorStep = data.currShorStep + 1
	  if seqCheck(data.currShorStep, shoryukenCommandsR) then
	    return "shoryuken"
	  end
	elseif shoryukenCommandsR2[data.currShorStep] == inputStr then
	  data.currShorStep = data.currShorStep + 1
	  if seqCheck(data.currShorStep, shoryukenCommandsR2) then
	    return "shoryuken"
	  end
	elseif shoryukenCommandsR3[data.currShorStep] == inputStr then
	  data.currShorStep = data.currShorStep + 1
	  if seqCheck(data.currShorStep, shoryukenCommandsR3) then
	    return "shoryuken"
	  end
	elseif shoryukenCommandsR4[data.currShorStep] == inputStr then
	  data.currShorStep = data.currShorStep + 1
	  if seqCheck(data.currShorStep, shoryukenCommandsR4) then
	    return "shoryuken"
	  end
    elseif hadoukenCommandsR[data.currHadoRStep] == inputStr then
	  --input correct; continue the sequence
	  data.currHadoRStep = data.currHadoRStep + 1
	  
	  --check if sequence complete
	  if seqCheck(data.currHadoRStep, hadoukenCommandsR) then
	    return "hadouken"
	  end
	elseif hadoukenCommandsR2[data.currHadoRStep] == inputStr then
	  data.currHadoRStep = data.currHadoRStep + 1
	  if seqCheck(data.currHadoRStep, hadoukenCommandsR2) then
	    return "hadouken"
	  end
	else
      --input not detected this frame (but keep waiting)
    end
  end

  return nil
end



function update(args)
  local controlForce = tech.parameter("controlForce")
  local energyUsage = tech.parameter("energyUsage")
  
  local hadoukenProj = tech.parameter("hadoukenProj")
  local dustRight = tech.parameter("dustRight")
  local shorProj = tech.parameter("shorProj")
  local shorDust = tech.parameter("shorDust")
  local shsplode = tech.parameter("shadoukenExplode")
  local shblue = tech.parameter("shadoukenBlue")
  local shdamage = tech.parameter("shadoukenDamage")
  
  local hadoukenSound = tech.parameter("hadoukenSound")
  local shoryukenSound = tech.parameter("shoryukenSound")
  local shinkuSound = tech.parameter("shinkuSound")
  local shadoukenSound = tech.parameter("shadoukenSound")
  local shadoukenBeamSound = tech.parameter("shadoukenBeamSound")
  local hyperSound = tech.parameter("hyperSound")
  
  local hyperBackground = tech.parameter("hyperBackground")
  local hyperBackgroundStart = tech.parameter("hyperBackgroundStart")
  
  ---- timing variables
  local maxAnimTimer = 0.55
  local whenToHide = maxAnimTimer-0.05
  local hadoukenTime = maxAnimTimer
  local warpOutTime = hadoukenTime-0.35
  local reappearTime = warpOutTime-0.05
  ---- end timing variables

  local diag = 1 / math.sqrt(2)
  local usedEnergy = 0
  
  
  if args.actions["shadouken"] and data.animTimer <= 0 and args.availableEnergy > energyUsage then
    data.animTimer = 3.1 --for now
	data.direction = getDirection(args.aimPosition[1], tech.position()[1])
	usedEnergy = energyUsage*3
	data.air = not tech.onGround()
	data.doSHadouken = true
	data.hyperBarStep = 0
	data.entityTable = world.entityQuery(tech.position(), 50)
  elseif args.actions["shoryuken"] and data.animTimer <= 0 and args.availableEnergy > energyUsage then
	if tech.onGround() then -- can't perform move in air
	  data.direction = getDirection(args.aimPosition[1], tech.position()[1])
	  usedEnergy = energyUsage
      data.animTimer = 1.05
      data.doShoryuken = true
	  incrementHyper()
	end
  elseif args.actions["hadouken"] and data.animTimer <= 0 and args.availableEnergy > energyUsage then
    if tech.velocity()[2] < -50 then
	  return 0
	end
    data.animTimer = maxAnimTimer
    data.direction = getDirection(args.aimPosition[1], tech.position()[1])
    usedEnergy = energyUsage
    data.air = not tech.onGround()
	data.doHadouken = true
	incrementHyper()
	---- modular energy cost part 1 ----
	-- if not data.gotEnergy then
	  -- data.currEnergy = args.availableEnergy
	  -- data.gotEnergy = true
	  -- return -5000
	-- end
	---- end modular energy cost ----
  end
  
  showHyperBar()
  
  ---- modular energy cost part 2 - 15% of max energy ----
  -- if data.gotEnergy then
    -- data.maxEnergy = args.availableEnergy
    -- data.gotEnergy = false
	-- usedEnergy = data.maxEnergy - data.currEnergy + (data.maxEnergy * 0.15)
	-- if args.availableEnergy < usedEnergy then
	  -- return 0
	-- end
  -- end
  ---- end modular energy cost ----
  
  
  ----super hadouken-----
  
  if data.doSHadouken then 
    if data.animTimer > 0 then
      tech.xControl(0, 1000, true)
	  for i, entity in ipairs(data.entityTable) do
	    if world.entityExists(entity) then
	      world.callScriptedEntity(entity, "entity.setVelocity", {0,0})
		--else
		  --table.remove(data.entityTable, i)
		end
	  end
	  tech.applyMovementParameters({runSpeed = 0.0, walkSpeed = 0.0})
	  tech.setParentAppearance("hidden")

      if data.air then
        tech.applyMovementParameters({gravityEnabled = false})
        tech.yControl(0, controlForce, true)
      end
	
	  if data.direction == -1 then
        tech.setFlipped(true)
      else
        tech.setFlipped(false)
      end
	  
	  local startpoint = {tech.position()[1]+(data.direction*3), tech.position()[2]-2.7}
	  local endpoint = {tech.position()[1]+(40*data.direction), tech.position()[2]-2.7}
	  
	  if data.animTimer < 0.2 then
	    tech.setAnimationState("warping", "warpout")
		tech.setParentAppearance("normal")
	  elseif data.animTimer < 0.6 then
	    tech.setAnimationState("fighting", "superhadouken")
		tech.setAnimationState("shadoukenbeam", "outro")
		tech.setAnimationState("beameffect1", "off")
	  elseif data.animTimer < 1.4 then
	    tech.setAnimationState("fighting", "superhadouken")
		tech.setAnimationState("shadoukenbeam", "full")
		if data.projCounter%2==0 then
		  if world.lineCollision(startpoint, endpoint) then
		    world.spawnProjectile(shsplode, {tech.position()[1]+(data.direction*2.5), tech.position()[2]-1.2}, tech.parentEntityId(), {1*data.direction,0})
		  else
		    world.spawnProjectile(shblue, {tech.position()[1]+(data.direction*2.5), tech.position()[2]-1.2}, tech.parentEntityId(), {1*data.direction,0})
		  end
		else
		  world.spawnProjectile(shdamage, {tech.position()[1]+(data.direction*2.5), tech.position()[2]}, tech.parentEntityId(), {1*data.direction,0})
		end
		data.projCounter = data.projCounter + 1
	  elseif data.animTimer < 1.8 then
	    tech.setAnimationState("fighting", "superhadouken")
		tech.setAnimationState("shadoukenbeam", "intro")
		tech.setAnimationState("beameffect1", "on")
		if data.projCounter%2==0 then
		  if world.lineCollision(startpoint, endpoint) then
		    world.spawnProjectile(shsplode, {tech.position()[1]+(data.direction*2.5), tech.position()[2]-1.2}, tech.parentEntityId(), {1*data.direction,0})
		  else
		    world.spawnProjectile(shblue, {tech.position()[1]+(data.direction*2.5), tech.position()[2]-1.2}, tech.parentEntityId(), {1*data.direction,0})
		  end
		else
		  world.spawnProjectile(shdamage, {tech.position()[1]+(data.direction*2.5), tech.position()[2]}, tech.parentEntityId(), {1*data.direction,0})
		end
		data.projCounter = data.projCounter + 1
		if not data.backgroundFlag then
		  world.spawnProjectile(hyperBackground, {tech.position()[1]-1, tech.position()[2]}, tech.parentEntityId(), {0,0}, true)
		  tech.playImmediateSound(shadoukenBeamSound)
		  tech.playImmediateSound(shadoukenSound)
		  data.backgroundFlag = true
		end
	  elseif data.animTimer < 2.1 then
	    tech.setAnimationState("fighting", "superhadouken")
		tech.setAnimationState("hypercharge", "off")
		tech.setAnimationState("beameffect1", "off")
	  elseif data.animTimer < 2.9 then
	    tech.setAnimationState("warping", "off")
	  elseif data.animTimer == 3.1 then
	    tech.setAnimationState("warping", "warpin")
	  else
	    if not data.soundFlag then
		  tech.playImmediateSound(shinkuSound)
		  tech.playImmediateSound(hyperSound)
		  world.spawnProjectile(hyperBackgroundStart, {tech.position()[1]-1, tech.position()[2]}, tech.parentEntityId(), {0,0}, true)
		  data.soundFlag = true
		end
	    tech.setAnimationState("fighting", "superhadoukenstart")
		tech.setAnimationState("hypercharge", "on")
		tech.setAnimationState("beameffect1", "ball")
	  end
	  
	  data.animTimer = data.animTimer - args.dt
	else
	  tech.setToolUsageSuppressed(false)
	  tech.setParentAppearance("normal")
	  tech.setAnimationState("fighting", "off")
	  tech.setAnimationState("shadoukenbeam", "off")
	  tech.setAnimationState("beameffect1", "off")
	  tech.setAnimationState("hypercharge", "off")
	  tech.setAnimationState("warping", "off")
	  data.projCounter = 1
	  data.backgroundFlag = false
	  data.soundFlag = false
	  data.doSHadouken = false
    end
  end
  
  
  ----shoryuken--------
  if data.doShoryuken then
    if data.animTimer > 0 then
	  tech.applyMovementParameters({runSpeed = 0.0, walkSpeed = 0.0})
	  tech.setParentAppearance("hidden")
	  
	  if data.direction == -1 then
        tech.setFlipped(true)
      else
        tech.setFlipped(false)
      end
	  
	  if data.animTimer < 0.2 then
	    tech.setAnimationState("warping", "warpout")
		tech.setParentAppearance("normal")
	  elseif data.animTimer < 0.3 then
	    tech.setAnimationState("fighting", "shoryukenland")
	  elseif data.animTimer < 0.4 then
	    tech.setAnimationState("fighting", "shoryukenfall")
	  elseif data.animTimer < 0.6 then
	    tech.setAnimationState("fighting", "shoryukenfallstart")
		if not data.shoryukenPeak then
		  tech.control({0,0}, 3000, true, true)
		  data.shoryukenPeak = true
		end
      elseif data.animTimer < 0.85 then
	    tech.setAnimationState("fighting", "shoryukenair")
		tech.control({data.direction* 60 * diag, 80 * diag}, 300, true, true)
		if not data.projFired then
		    if data.direction == 1 then
 		      world.spawnProjectile(shorDust, {tech.position()[1]-(data.direction*2), tech.position()[2]+1}, tech.parentEntityId(), {1*data.direction,0}, false)
		    else
		      world.spawnProjectile(shorDust, {tech.position()[1]-(data.direction*2), tech.position()[2]+1}, tech.parentEntityId(), {1*data.direction,0}, false, {speed = 0.001})
		    end
			data.projFired = true
		end
		world.spawnProjectile(shorProj, {tech.position()[1]+(data.direction*1.5), tech.position()[2]}, tech.parentEntityId(), {1*data.direction,0})
	    tech.setAnimationState("warping", "off")
	  elseif data.animTimer < 1.05 then
	    tech.setAnimationState("fighting", "shoryukenstart")
		world.spawnProjectile(shorProj, {tech.position()[1]+(data.direction*1.5), tech.position()[2]}, tech.parentEntityId(), {1*data.direction,0})
		if not data.soundFlag then
			tech.playImmediateSound(shoryukenSound)
			data.soundFlag = true
		end
		tech.xControl(data.direction * 20, 300, true)
	  elseif data.animTimer == 1.05 then
	    tech.setAnimationState("warping", "warpin")
	  else
	  
	  end
	  
	  data.animTimer = data.animTimer - args.dt
	else
	  tech.setToolUsageSuppressed(false)
	  tech.setParentAppearance("normal")
	  tech.setAnimationState("fighting", "off")
	  tech.setAnimationState("warping", "off")
	  data.soundFlag = false
      data.doShoryuken = false
	  data.shoryukenPeak = false
	  data.projFired = false
	end
  end
  
  
  ----hadouken---------
  
  if data.doHadouken then 
    if data.animTimer > 0 then
      tech.xControl(0, 1000, true)
	  tech.applyMovementParameters({runSpeed = 0.0, walkSpeed = 0.0})

      if data.air then
        tech.applyMovementParameters({gravityEnabled = false})
        tech.yControl(0, controlForce, true)
      end
	
	  if data.animTimer < whenToHide and not data.reappeared then
	      tech.setParentAppearance("hidden")
	  end

      if data.direction == -1 then
        tech.setFlipped(true)
      else
        tech.setFlipped(false)
      end
	
	  if data.animTimer < warpOutTime then
	    tech.setAnimationState("warping", "warpout")
	    if not data.projFired then
          world.spawnProjectile(hadoukenProj, {tech.position()[1]+(data.direction*3), tech.position()[2]}, tech.parentEntityId(), {1*data.direction,0})
	      data.projFired = true
	    end
	    if data.animTimer < reappearTime then
	      tech.setParentAppearance("normal")
		  data.reappeared = true
	    end
	  elseif data.animTimer < hadoukenTime then
        tech.setAnimationState("fighting", "hadouken")
	    if not data.proj2Fired then
	      tech.playImmediateSound(hadoukenSound)
		  if tech.onGround() then
		    if data.direction == 1 then
 		      world.spawnProjectile(dustRight, {tech.position()[1]-(data.direction*4), tech.position()[2]}, tech.parentEntityId(), {1*data.direction,0}, false)
		    else
		      world.spawnProjectile(dustRight, {tech.position()[1]-(data.direction*4), tech.position()[2]}, tech.parentEntityId(), {1*data.direction,0}, false, {speed = 0.001})
		    end
		  end
		  data.proj2Fired = true
	    end
	  else
	    tech.setAnimationState("warping", "warpin")
	  end

      data.animTimer = data.animTimer - args.dt
    else
	  tech.setToolUsageSuppressed(false)
      tech.setAnimationState("fighting", "off")
	  tech.setAnimationState("warping", "off")
	  tech.setParentAppearance("normal")
	  data.reappeared = false
	  data.projFired = false
	  data.proj2Fired = false
	  data.doHadouken = false
    end
  end

  return usedEnergy
end

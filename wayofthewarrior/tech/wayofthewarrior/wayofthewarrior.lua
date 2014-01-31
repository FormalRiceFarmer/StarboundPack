function init()
  data.air = false
  data.direction = 0
  data.inputTimer = 0
  data.maxStepTime = 0.3 --maximum time for each command step
  data.currHadoRStep = 1
  data.doHadouken = false
  data.currSHadoRStep = 1
  data.currShorStep = 1
  data.currHadoLStep = 1
  data.currShorLStep = 1
  data.currSHadoLStep = 1
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
  data.currMousePosition = {}
  
  data.debugMode = tech.parameter("debugMode")
  data.mouseMode = tech.parameter("mouseMode")
  
  if tech.parameter("easyInput") then
    ---easier inputs
    data.hadoukenCommandsR = { "down", "right", "primaryFire" }
    data.hadoukenCommandsR2 = { "down", "right", "rightprimaryFire" }
	data.shadoukenCommandsR = { "down", "right", "down", "right", "primaryFire" }
    data.shadoukenCommandsR2 = { "down", "right", "down", "right", "rightprimaryFire" }
	data.shoryukenCommandsR = { "right", "down", "rightprimaryFire" }
    data.shoryukenCommandsR2 = { "right", "down", "right", "primaryFire" }
    data.shoryukenCommandsR3 = { "right", "down", "downright", "right", "primaryFire" }
    data.shoryukenCommandsR4 = { "right", "down", "downright", "rightprimaryFire" }
	if data.mouseMode == false then
	  ---use directional inputs for left side instead of based on mouse
      data.hadoukenCommandsL = { "down", "left", "primaryFire" }
      data.hadoukenCommandsL2 = { "down", "left", "leftprimaryFire" }
	  data.shadoukenCommandsL = { "down", "left", "down", "left", "primaryFire" }
      data.shadoukenCommandsL2 = { "down", "left", "down", "left", "leftprimaryFire" }
	  data.shoryukenCommandsL = { "left", "down", "leftprimaryFire" }
      data.shoryukenCommandsL2 = { "left", "down", "left", "primaryFire" }
      data.shoryukenCommandsL3 = { "left", "down", "downleft", "left", "primaryFire" }
      data.shoryukenCommandsL4 = { "left", "down", "downleft", "leftprimaryFire" }
	end
  else
    ---original inputs
    data.hadoukenCommandsR = { "down", "downright", "right", "rightprimaryFire" }
    data.hadoukenCommandsR2 = { "down", "downright", "right", "primaryFire" }
    data.shadoukenCommandsR = { "down", "downright", "right", "down", "downright", "right", "rightprimaryFire" }
    data.shadoukenCommandsR2 = { "down", "downright", "right", "down", "downright", "right", "primaryFire" }
    data.shoryukenCommandsR = { "right", "down", "downright", "primaryFire" }
    data.shoryukenCommandsR2 = { "right", "down", "downright", "downrightprimaryFire" }
    data.shoryukenCommandsR3 = { "right", "down", "downright", "right", "primaryFire" }
    data.shoryukenCommandsR4 = { "right", "down", "downright", "rightprimaryFire" }
	if data.mouseMode == false then
	  ---use directional inputs for left side
      data.hadoukenCommandsL = { "down", "downleft", "left", "leftprimaryFire" }
      data.hadoukenCommandsL2 = { "down", "downleft", "left", "primaryFire" }
      data.shadoukenCommandsL = { "down", "downleft", "left", "down", "downleft", "left", "leftprimaryFire" }
      data.shadoukenCommandsL2 = { "down", "downleft", "left", "down", "downleft", "left", "primaryFire" }
      data.shoryukenCommandsL = { "left", "down", "downleft", "primaryFire" }
      data.shoryukenCommandsL2 = { "left", "down", "downleft", "downleftprimaryFire" }
      data.shoryukenCommandsL3 = { "left", "down", "downleft", "left", "primaryFire" }
      data.shoryukenCommandsL4 = { "left", "down", "downleft", "leftprimaryFire" }
	end
  end
end

function uninit()
  tech.setParentAppearance("normal")
  tech.setAnimationState("fighting", "off")
  tech.setAnimationState("shadoukenbeam", "off")
  tech.setAnimationState("beameffect1", "off")
  tech.setAnimationState("hypercharge", "off")
  tech.setAnimationState("warping", "off")
  data.entityTable = {}
end

function getDirection(position, techpos)
  if position < techpos then
    return -1
  else
    return 1
  end
end

function directionCheck()
  if data.mouseMode == true then
    return getDirection(data.currMousePosition[1], tech.position()[1])
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

  
  if args.moves["special"] == 2 then
    if data.showBar == true then
	  data.showBar = false
	else
	  data.showBar = true
	end
  end

  ---- debug stuff  
  if data.debugMode then
    if args.moves["special"] == 3 then
      data.hyperBarStep = 11
    end
  end
  
  ------suppress fire----------- (prevents person from swinging when clicking)
  
  if data.currHadoRStep == #data.hadoukenCommandsR or data.currShorStep == #data.shoryukenCommandsR2 or data.currSHadoRStep == #data.shadoukenCommandsR then
    tech.setToolUsageSuppressed(true) --get unsuppressed after attack animation in update
  -- else
    -- tech.setToolUsageSuppressed(false)
  elseif data.mouseMode == false then
    if data.currHadoLStep == #data.hadoukenCommandsL or data.currShorLStep == #data.shoryukenCommandsL2 or data.currSHadoLStep == #data.shadoukenCommandsL then
	  --world.logInfo("move: %s, hadoL %d, shorL %d, shadoL %d", inputStr, data.currHadoLStep, data.currShorLStep, data.currSHadoLStep)
	  tech.setToolUsageSuppressed(true)
	end
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
	data.currHadoLStep = 1
	data.currSHadoLStep = 1
	data.currShorLStep = 1
  else
    --now you can tell whether your inputs match with just one comparison
	if data.shadoukenCommandsR[data.currSHadoRStep] == inputStr then
	  data.currSHadoRStep = data.currSHadoRStep + 1
	  if seqCheck(data.currSHadoRStep, data.shadoukenCommandsR) then
	    data.direction = directionCheck()
	    if data.hyperBarStep < 11 then
	      return "hadouken"
		else
		  return "shadouken"
		end
	  end
	elseif data.shadoukenCommandsR2[data.currSHadoRStep] == inputStr then
	  data.currSHadoRStep = data.currSHadoRStep + 1
	  if seqCheck(data.currSHadoRStep, data.shadoukenCommandsR2) then
        data.direction = directionCheck()
	    if data.hyperBarStep < 11 then
	      return "hadouken"
		else
		  return "shadouken"
		end
	  end
	elseif data.shoryukenCommandsR[data.currShorStep] == inputStr then
	  data.currShorStep = data.currShorStep + 1
	  if seqCheck(data.currShorStep, data.shoryukenCommandsR) then
        data.direction = directionCheck()
	    return "shoryuken"
	  end
	elseif data.shoryukenCommandsR2[data.currShorStep] == inputStr then
	  data.currShorStep = data.currShorStep + 1
	  if seqCheck(data.currShorStep, data.shoryukenCommandsR2) then
        data.direction = directionCheck()
	    return "shoryuken"
	  end
	elseif data.shoryukenCommandsR3[data.currShorStep] == inputStr then
	  data.currShorStep = data.currShorStep + 1
	  if seqCheck(data.currShorStep, data.shoryukenCommandsR3) then
        data.direction = directionCheck()
	    return "shoryuken"
	  end
	elseif data.shoryukenCommandsR4[data.currShorStep] == inputStr then
	  data.currShorStep = data.currShorStep + 1
	  if seqCheck(data.currShorStep, data.shoryukenCommandsR4) then
        data.direction = directionCheck()
	    return "shoryuken"
	  end
    elseif data.hadoukenCommandsR[data.currHadoRStep] == inputStr then
	  --input correct; continue the sequence
	  data.currHadoRStep = data.currHadoRStep + 1
	  
	  --check if sequence complete
	  if seqCheck(data.currHadoRStep, data.hadoukenCommandsR) then
        data.direction = directionCheck()
	    return "hadouken"
	  end
	elseif data.hadoukenCommandsR2[data.currHadoRStep] == inputStr then
	  data.currHadoRStep = data.currHadoRStep + 1
	  if seqCheck(data.currHadoRStep, data.hadoukenCommandsR2) then
		data.direction = directionCheck()
	    return "hadouken"
	  end
	elseif data.mouseMode == false then
	--------------------------do all left sided checking here-----------------------
	  if data.shadoukenCommandsL[data.currSHadoLStep] == inputStr then
  	    data.currSHadoLStep = data.currSHadoLStep + 1
	    if seqCheck(data.currSHadoLStep, data.shadoukenCommandsL) then
	      if data.hyperBarStep < 11 then
		    data.direction = directionCheck()
	        return "hadouken"
		  else
		    data.direction = directionCheck()
		    return "shadouken"
		  end
	    end
	  elseif data.shadoukenCommandsL2[data.currSHadoLStep] == inputStr then
	    data.currSHadoLStep = data.currSHadoLStep + 1
	    if seqCheck(data.currSHadoLStep, data.shadoukenCommandsL2) then
	      if data.hyperBarStep < 11 then
		    data.direction = directionCheck()
	        return "hadouken"
		  else
		    data.direction = directionCheck()
		    return "shadouken"
		  end
	    end
	  elseif data.shoryukenCommandsL[data.currShorLStep] == inputStr then
	    data.currShorLStep = data.currShorLStep + 1
	    if seqCheck(data.currShorLStep, data.shoryukenCommandsL) then
		  data.direction = directionCheck()
	      return "shoryuken"
	    end
	  elseif data.shoryukenCommandsL2[data.currShorLStep] == inputStr then
	    data.currShorLStep = data.currShorLStep + 1
	    if seqCheck(data.currShorLStep, data.shoryukenCommandsL2) then
		  data.direction = directionCheck()
	      return "shoryuken"
	    end
	  elseif data.shoryukenCommandsL3[data.currShorLStep] == inputStr then
	    data.currShorLStep = data.currShorLStep + 1
	    if seqCheck(data.currShorLStep, data.shoryukenCommandsL3) then
		  data.direction = directionCheck()
	      return "shoryuken"
	    end
	  elseif data.shoryukenCommandsL4[data.currShorLStep] == inputStr then
	    data.currShorLStep = data.currShorLStep + 1
	    if seqCheck(data.currShorLStep, data.shoryukenCommandsL4) then
		  data.direction = directionCheck()
	      return "shoryuken"
	    end
      elseif data.hadoukenCommandsL[data.currHadoLStep] == inputStr then
	    --input correct; continue the sequence
	    data.currHadoLStep = data.currHadoLStep + 1
	  
	    --check if sequence complete
	    if seqCheck(data.currHadoLStep, data.hadoukenCommandsL) then
		  data.direction = directionCheck()
	      return "hadouken"
	    end
	  elseif data.hadoukenCommandsL2[data.currHadoLStep] == inputStr then
	    data.currHadoLStep = data.currHadoLStep + 1
	    if seqCheck(data.currHadoLStep, data.hadoukenCommandsL2) then
		  data.direction = directionCheck()
	      return "hadouken"
	    end
	  else
	    --input not detected this frame (but keep waiting)
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
  
  data.currMousePosition = args.aimPosition
  
  
  if args.actions["shadouken"] and data.animTimer <= 0 and args.availableEnergy > energyUsage then
    data.animTimer = 3.1 --for now
    data.direction = directionCheck()
	usedEnergy = energyUsage*3
	data.air = not tech.onGround()
	data.doSHadouken = true
	data.hyperBarStep = 0
	data.entityTable = world.entityQuery(tech.position(), 50)
  elseif args.actions["shoryuken"] and data.animTimer <= 0 and args.availableEnergy > energyUsage then
	if tech.onGround() then -- can't perform move in air
      data.direction = directionCheck()
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
    data.direction = directionCheck()
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
	  local startpoint2 = {tech.position()[1]+(data.direction*3), tech.position()[2]}
	  local endpoint2 = {tech.position()[1]+(40*data.direction), tech.position()[2]}
	  
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
		  if world.lineCollision(startpoint, endpoint) or world.lineCollision(startpoint2, endpoint2) then
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

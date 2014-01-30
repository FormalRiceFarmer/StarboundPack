function init()
  data.active = false
  data.timer = 0
  tech.setVisible(false)
  data.holdingUp = false
  data.holdingDown = false
  data.left = false
  data.right = false
  data.soundOff = false
end

function uninit()
  if data.active then
		deactivate()
        return 0
  end
end

function input(args)
  
  if args.moves["up"] then
    data.holdingUp = true
  else
    data.holdingUp = false
  end
  
  if args.moves["down"] then
    data.holdingDown = true
  else
    data.holdingDown = false
  end
  
  if args.moves["left"] then
    data.left = true
  else
    data.left = false
  end
  
  if args.moves["right"] then
    data.right = true
  else
    data.right = false
  end
  
  if args.moves["special"] == 1 then
    if data.active then
      return "flightDeactivate"
    else
      return "flightActivate"
  end
 end

  return nil
end

function update(args)
  -- get parameters from basicflight.tech
  local flightCustomMovementParameters = tech.parameter("flightCustomMovementParameters")
  local parentOffset = tech.parameter("parentOffset")
  local flightCollisionTest = tech.parameter("flightCollisionTest")
  local energyCostPerSecond = tech.parameter("energyCostPerSecond")
  local verticalSpeed = tech.parameter("verticalSpeed")
  local onSound = tech.parameter("auraStart")
  local offSound = tech.parameter("auraStop")
  local dustProjectileRight = tech.parameter("dustProjectileRight")
  local dustProjectileLeft = tech.parameter("dustProjectileLeft")
  
  -- activate mech
  if not data.active and args.actions["flightActivate"] then
    -- check for collision
    flightCollisionTest[1] = flightCollisionTest[1] + tech.position()[1]
    flightCollisionTest[2] = flightCollisionTest[2] + tech.position()[2]
    flightCollisionTest[3] = flightCollisionTest[3] + tech.position()[1]
    flightCollisionTest[4] = flightCollisionTest[4] + tech.position()[2]
    if not world.rectCollision(flightCollisionTest) and args.availableEnergy > energyCostPerSecond then
      world.spawnProjectile(dustProjectileRight, {tech.position()[1]-3, tech.position()[2]}, tech.parentEntityId())
	  world.spawnProjectile(dustProjectileLeft, {tech.position()[1]+3, tech.position()[2]}, tech.parentEntityId())
	  tech.playImmediateSound(onSound)
	  activate()
    else
      -- Make some kind of error noise
    end
  end	
  
  -- particle effects
  if data.active then
	tech.setParticleEmitterActive("auraParticles", true)
	if tech.onGround() then
	  tech.setParticleEmitterActive("groundParticles", true)
	else
	  tech.setParticleEmitterActive("groundParticles", false)
	end
  end	
  
  --deactivate mech
  if args.actions["flightDeactivate"] or args.availableEnergy < 1 then
	deactivate()
	return 0
  end	
	
  if data.active then
	tech.applyMovementParameters(flightCustomMovementParameters)
	
	-- move vehicle up and down (left and right work with standard walking) and set state to "moving"/"idle"
	if data.active and data.holdingUp and data.right then
	    tech.yControl(verticalSpeed, 1000, true)
		tech.setParentAppearance("fly")
		tech.setAnimationState("basicflight", "auraupright")
		return energyCostPerSecond * args.dt
	  elseif data.active and data.holdingUp and data.left then
	    tech.yControl(verticalSpeed, 1000, true)
		tech.setParentAppearance("fly")
		tech.setAnimationState("basicflight", "auraupleft")
		return energyCostPerSecond * args.dt
      elseif data.active and data.holdingDown and data.right then
	    tech.yControl(-verticalSpeed, 1000, true)
		tech.setParentAppearance("fly")
		tech.setAnimationState("basicflight", "auradownright")
		return energyCostPerSecond * args.dt
	  elseif data.active and data.holdingDown and data.left then
	    tech.yControl(-verticalSpeed, 1000, true)
		tech.setAnimationState("basicflight", "auradownleft")
		tech.setParentAppearance("fly")
		return energyCostPerSecond * args.dt
      elseif data.active and data.holdingUp then
		tech.yControl(verticalSpeed, 1000, true)
		tech.setParentAppearance("fly")
        tech.setAnimationState("basicflight", "auraup")
		return energyCostPerSecond * args.dt
	  elseif data.active and data.holdingDown then
		tech.yControl(-verticalSpeed, 1000, true)
		tech.setParentAppearance("fly")
        tech.setAnimationState("basicflight", "auradown")
		return energyCostPerSecond * args.dt
	  elseif data.active and data.right then
		tech.setParentAppearance("fly")
		tech.setAnimationState("basicflight", "auraright")
		return energyCostPerSecond * args.dt
	  elseif data.active and data.left then
		tech.setParentAppearance("fly")
		tech.setAnimationState("basicflight", "auraleft")
		return energyCostPerSecond * args.dt
	  else
	    tech.setAnimationState("basicflight", "auraidle")
		tech.setParentAppearance("fly")
      end
   end  
  return 0
end

function activate()
	tech.setVisible(true)
    tech.setToolUsageSuppressed(false)
    data.active = true
end

function deactivate()
    tech.setParentOffset({0, 0})
    data.active = false
    tech.setVisible(false)
    tech.setParentAppearance("normal")
    tech.setToolUsageSuppressed(false)
    tech.setParentFacingDirection(nil)
	tech.setAnimationState("basicflight", "off")
	tech.setParticleEmitterActive("auraParticles", false)
	tech.setParticleEmitterActive("groundParticles", false)
	return 0
end
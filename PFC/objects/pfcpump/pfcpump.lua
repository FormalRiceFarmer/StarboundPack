function init(virtual)
    --self.projectile = entity.configParameter("projectile")
end

function main(args)
  if entity.getInboundNodeLevel(0) then
    world.spawnProjectile("pfc_proj", {entity.position()[1] + 0.5, entity.position()[2]}, entity.id(), {0, 1}, false, {})
  end
end
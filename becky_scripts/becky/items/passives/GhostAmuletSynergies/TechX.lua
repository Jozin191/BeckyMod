local mod = BeckyMod
local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")

---@param fam EntityFamiliar
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local ghostData = fam:GetData()

    if not fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then return end
    if ghostData.TechXRing then return end

    ghostData.TechXRing = BeckyMod.Game:Spawn(EntityType.ENTITY_LASER, LaserVariant.THIN_RED, fam.Position, Vector.Zero, fam, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, 1):ToLaser()
    
    local laser = ghostData.TechXRing ---@cast laser EntityLaser
    
    laser.Parent = fam
    laser:GetData().GhostBallTear = true
    laser.Radius = laser.Radius * 0.7
    laser.CollisionDamage = laser.CollisionDamage / 2
end, GHOST_BALL)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, GHOST_BALL)) do
        ent:GetData().TechXRing = nil
    end
end)

--Thank you kotry. I just used most of your godhead code. You are the goat!!
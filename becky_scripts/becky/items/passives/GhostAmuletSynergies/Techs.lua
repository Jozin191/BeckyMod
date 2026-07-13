local mod = BeckyMod

---@param player EntityPlayer
local function BeckyHasTechItem(player)
    return (
        player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or
        player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) or
        player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_5)
    )
end

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams, position)
    local player = fam.Player

    if not player then return end
    if not BeckyHasTechItem(player) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MUCORMYCOSIS)

    local laser = player:FireTechLaser(position, LaserOffset.LASER_TECH1_OFFSET, rng:RandomVector())
    laser.CollisionDamage = laser.CollisionDamage/2
    
    -- local bomb = player:FireBomb(fam.Position, Vector.Zero, player)
end)
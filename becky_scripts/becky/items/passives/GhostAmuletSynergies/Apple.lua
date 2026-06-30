---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_APPLE) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_APPLE)
    local formula = 1 / math.max(15 - player.Luck, 1)

    if rng:RandomFloat() > formula then return end
    
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.RAZOR, 0, fam.Position,rng:RandomVector():Resized(player.ShotSpeed * 10), fam)
    tear.CollisionDamage = player.Damage * 4
end)
---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITOID) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PARASITOID)
    local formula = 1 / math.max(7 - player.Luck, 2)

    if rng:RandomFloat() > formula then return end
    
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.EGG, 0, fam.Position,rng:RandomVector():Resized(player.ShotSpeed * 10), fam)
    tear:ToTear().TearFlags = TearFlags.TEAR_EGG
    tear.CollisionDamage = player.Damage
end)
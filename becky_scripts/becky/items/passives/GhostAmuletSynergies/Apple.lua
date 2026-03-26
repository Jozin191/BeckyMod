---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_APPLE) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_APPLE)
    local luck = player.Luck
    if luck > 15 then luck = 15
    elseif luck < 0 then luck = 0 end
    local chance = 1/ (15- luck)
    
    print("spawn apple chance",chance)
    if rng:RandomFloat() > chance then return end
    
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.RAZOR, 0, fam.Position, Vector(1,0):Resized(player.ShotSpeed *10):Rotated(rng:RandomInt(360)), fam)
    tear.CollisionDamage = player.Damage * 3.2
end)
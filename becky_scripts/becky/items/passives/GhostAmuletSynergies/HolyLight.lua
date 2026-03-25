---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_HOLY_LIGHT) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_HOLY_LIGHT)
    local formula = 1 / math.max((10 - (player.Luck * 0.9)), 2)

    if rng:RandomFloat() > formula then return end

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 10, enemy.Position, Vector.Zero, player)
    enemy:TakeDamage(player.Damage * 3, DamageFlag.DAMAGE_LASER, EntityRef(player), 0)

    -- local bomb = player:FireBomb(fam.Position, Vector.Zero, player)
end)
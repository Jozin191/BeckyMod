---@param fam EntityFamiliar
---@param enemy EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams, position)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_FIRE_MIND) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_FIRE_MIND)
    local formula = 1 / math.max(10 - player.Luck * 0.7, 1)

    if rng:RandomFloat() > formula then return end
    BeckyMod.Game:BombExplosionEffects(position, tearParams.TearDamage, tearParams.TearFlags, tearParams.TearColor)
    local fire = Isaac.Spawn(1000, EffectVariant.RED_CANDLE_FLAME, 0, position, Vector.Zero, player):ToEffect()
    fire.CollisionDamage = 23
    fire:SetTimeout(360)
end)
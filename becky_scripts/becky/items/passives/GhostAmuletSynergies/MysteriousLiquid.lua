---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MYSTERIOUS_LIQUID) then return end

    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_GREEN, 0, fam.Position, Vector.Zero, player):ToEffect() ---@cast creep EntityEffect

    creep.Timeout = 25
end)
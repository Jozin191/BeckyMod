---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams, position)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_C_SECTION)

    if rng:RandomFloat() > 0.15 then return end

    local tear = player:FireTear(position, (enemy.Position - position):Normalized():Resized(10))
    tear:ChangeVariant(TearVariant.FETUS)
    tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_FETUS)
end)
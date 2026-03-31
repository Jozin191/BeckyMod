---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_COMMON_COLD) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_COMMON_COLD)
    local formula = 1 / math.max(4 - player.Luck*0.25, 1)

    if rng:RandomFloat() > formula then return end
    
    enemy:AddPoison(EntityRef(player), 23, player.Damage)
end)
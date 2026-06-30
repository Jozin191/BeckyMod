---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_IRON_BAR) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_IRON_BAR)
    local formula = 1/ math.max(27 - player.Luck , 1)

    if rng:RandomFloat() > formula then return end
    enemy:AddConfusion(EntityRef(player), 120, false)
end)
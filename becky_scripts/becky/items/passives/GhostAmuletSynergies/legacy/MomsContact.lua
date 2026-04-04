---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_CONTACTS) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_CONTACTS)
    local formula = 1/ math.max(5 - player.Luck *0.15, 2)

    if rng:RandomFloat() > formula then return end

    enemy:AddFreeze(EntityRef(player), 45)
end)
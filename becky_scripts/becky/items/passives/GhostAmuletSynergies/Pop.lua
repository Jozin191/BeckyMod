---@param fam EntityFamiliar
---@param enemy Entity
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, tearParams, position)
    local player = fam.Player 

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_POP) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_POP)

    if rng:RandomFloat() > 0.2 then return end

    local tear = player:FireTear(position, rng:RandomVector() * (player.ShotSpeed * 10))
    tear:ChangeVariant(TearVariant.EYE_BLOOD)
end)
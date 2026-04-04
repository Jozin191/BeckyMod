---@param fam EntityFamiliar
---@param enemy EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, fam, enemy, tearParams)
    local player = fam.Player

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then return end
    BeckyMod.Game:ChainLightning(fam.Position, player.Damage / 2, tearParams.TearFlags, fam)    
end)
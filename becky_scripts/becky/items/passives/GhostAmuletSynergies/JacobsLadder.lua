---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, fam, enemy)
    local player = fam.Player

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_JACOBS_LADDER) then return end
    BeckyMod.Game:ChainLightning(enemy.Position, player.Damage / 2, player.TearFlags, fam)    
end)
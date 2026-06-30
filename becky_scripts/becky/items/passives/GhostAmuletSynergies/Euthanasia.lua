---@param fam EntityFamiliar
---@param enemy Entity
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_KILL_ENEMY, function(_, fam, enemy)
    local player = fam.Player 

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_EUTHANASIA) then return end

    local chance = 1 / math.max((30 - (player.Luck * 2)), 1)
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EUTHANASIA)

    if rng:RandomFloat() > chance then return end

    local tear = player:FireTear(enemy.Position, rng:RandomVector() * (player.ShotSpeed * 10))
    tear:ChangeVariant(TearVariant.NEEDLE)
end)
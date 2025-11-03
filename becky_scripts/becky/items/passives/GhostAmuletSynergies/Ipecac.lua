-- local mod = BeckyMod
-- local enums = mod.Enums
-- local Callbacks = enums.Callbacks
-- local game = enums.Utils.Game

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then return end
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_IPECAC)

    if rng:RandomFloat() > 0.2 then return end

    BeckyMod.Game:BombExplosionEffects(fam.Position, player.Damage * 10, TearFlags.TEAR_POISON)
end)
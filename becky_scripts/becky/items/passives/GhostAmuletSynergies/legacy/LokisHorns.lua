---@param fam EntityFamiliar
---@param npc EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, fam, npc, position)
    local player = fam.Player

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LOKIS_HORNS)
    local formula = 1 / math.max((20 - player.Luck), 5)

    if rng:RandomFloat() > formula then return end

    for i = 1, 4 do
        player:FireTear(fam.Position, Vector(1, 0):Rotated((i/4)*360) * (player.ShotSpeed * 10))
    end
end)
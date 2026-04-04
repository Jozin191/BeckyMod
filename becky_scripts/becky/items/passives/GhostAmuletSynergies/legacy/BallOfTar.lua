--[[local SLOWDOWN_COLOR = Color(0.2,0.2,0.2, 1, 0,0,0)

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BALL_OF_TAR) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BALL_OF_TAR)
    local formula = 1/ math.max(10 - player.Luck *0.5, 1)

    if rng:RandomFloat() > formula then return end

    enemy:AddSlowing(EntityRef(player), 60, 0.5, SLOWDOWN_COLOR)
end)]]
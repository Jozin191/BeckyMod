local Callbacks = BeckyMod.Enums.Callbacks
local tempData = BeckyMod.getData

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then return end

    local ghostData = tempData(fam)

    ghostData.BrimHits = ghostData.BrimHits or 3
    ghostData.BrimHits = ghostData.BrimHits - 1

    if ghostData.BrimHits == 0 then
        player:FireBrimstoneBall(enemy.Position, Vector.Zero)
        ghostData.BrimHits = 3
    end
end)
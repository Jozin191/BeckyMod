--[[---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_STYE) then return end

    local ghostData = fam:GetData()
    if ghostData.Stye then
        enemy:TakeDamage(BeckyMod.Item.GHOST_AMULET:GetGhostDamage(player) * 0.28, 0, EntityRef(fam), 0)
        ghostData.Stye = false
    else
        ghostData.Stye = true
    end
end)]]
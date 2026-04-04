--[[
---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_CHEMICAL_PEEL) then return end

    local ghostData = fam:GetData()
    if ghostData.ChemicalPeel then
        enemy:TakeDamage(2, 0, EntityRef(fam), 0)
        ghostData.ChemicalPeel = false
    else
        ghostData.ChemicalPeel = true
    end
end)]]
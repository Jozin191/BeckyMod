---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_IBS) then return end

    local damageDone = math.min(BeckyMod.Item.GHOST_AMULET:GetGhostDamage(player), enemy.HitPoints)
    
    local charge = player.IBSCharge + damageDone / (40 +13.33 * (BeckyMod.Level():GetStage() -1) )

    player.IBSCharge = math.min(charge, 1.0)
end)
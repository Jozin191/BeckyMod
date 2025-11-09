local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")

---@param familiar EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, familiar, collider)
    

    local player = familiar.Player
    local posDif = (familiar.Position - player.Position)
    
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) then return end

    local laser = player:FireTechLaser(player.Position, LaserOffset.LASER_TECH1_OFFSET, posDif:Normalized(), false, true, player, 1) 
    laser:SetMaxDistance(posDif:Length())
    -- laser:SetMaxDistance(posDif:Length())
end)
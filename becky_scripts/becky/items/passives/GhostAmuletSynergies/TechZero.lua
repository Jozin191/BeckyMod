local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")

---@param familiar EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, familiar, collider)

    local player = familiar.Player
    local posDif = (familiar.Position - player.Position)
    -- local laser 

    -- if not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) then return end

    -- if laser then return end
    
    print("a[sodk[aksd[pk]]]")

    local laser = player:FireTechLaser(player.Position, LaserOffset.LASER_TECH1_OFFSET, posDif:Normalized(), false, true, player, 1) 
    laser:SetMaxDistance(posDif:Length())
    print(laser.Variant)


    -- laser:SetMaxDistance(posDif:Length())
end)

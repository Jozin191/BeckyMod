-- local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")

-- ---@param familiar EntityFamiliar
-- BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
--     local player = familiar.Player
--     local posDif = (familiar.Position - player.Position)
--     local laser 

--     if not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) then return end

--     if laser then return end
    
--     laser = player:FireTechLaser(player.Position, LaserOffset.LASER_SHOOP_OFFSET, posDif:Normalized())

--     -- lo
    


--     laser:SetMaxDistance(posDif:Length())
-- end, GHOST_BALL_VAR)

--[[
---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ABADDON)
        local formula = 15/ math.max(100 - player.Luck, 15)
        if rng:RandomFloat() <= formula then
            enemy:AddFear(EntityRef(player), 180)
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ABADDON)
        local formula = 1/ math.max(3 - player.Luck *0.1, 1)
        if rng:RandomFloat() <= formula then
            enemy:AddFear(EntityRef(player), 180)
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_ABADDON)
        local formula = 15/ math.max(100 - player.Luck, 15)
        if rng:RandomFloat() <= formula then
            enemy:AddFear(EntityRef(player), 180)
        end
    end
end)]]
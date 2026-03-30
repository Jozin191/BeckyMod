---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PARASITE)
        if rng:RandomFloat() <= 0.25 then
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, fam.Position, rng:RandomVector():Resized(player.ShotSpeed * 10), player):ToTear() ---@cast tear EntityTear
            tear:AddTearFlags(TearFlags.TEAR_SPLIT)
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CRICKETS_BODY)
        if rng:RandomFloat() <= 0.25 then
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, fam.Position, rng:RandomVector():Resized(player.ShotSpeed * 10), player):ToTear() ---@cast tear EntityTear
            tear:AddTearFlags(TearFlags.TEAR_QUADSPLIT)
        end
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE)
        if rng:RandomFloat() <= 0.25 then
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BONE, 0, fam.Position, rng:RandomVector():Resized(player.ShotSpeed * 10), player):ToTear() ---@cast tear EntityTear
            tear:AddTearFlags(TearFlags.TEAR_SPLIT)
        end
    end

    
end)
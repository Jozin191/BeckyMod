---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams)
    local player = fam.Player

    if not player then return end

    if tearParams.TearFlags & TearFlags.TEAR_SPLIT == TearFlags.TEAR_SPLIT then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_PARASITE)
        if rng:RandomFloat() <= 0.25 then
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, fam.Position, rng:RandomVector():Resized(player.ShotSpeed * 10), player):ToTear() ---@cast tear EntityTear
            tear:AddTearFlags(TearFlags.TEAR_SPLIT)
        end
    end
    if tearParams.TearFlags & TearFlags.TEAR_QUADSPLIT == TearFlags.TEAR_QUADSPLIT then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CRICKETS_BODY)
        if rng:RandomFloat() <= 0.25 then
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, fam.Position, rng:RandomVector():Resized(player.ShotSpeed * 10), player):ToTear() ---@cast tear EntityTear
            tear:AddTearFlags(TearFlags.TEAR_QUADSPLIT)
        end
    end
    if tearParams.TearFlags & TearFlags.TEAR_BONE == TearFlags.TEAR_BONE then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE)
        if rng:RandomFloat() <= 0.25 then
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BONE, 0, fam.Position, rng:RandomVector():Resized(player.ShotSpeed * 10), player):ToTear() ---@cast tear EntityTear
            tear:AddTearFlags(TearFlags.TEAR_SPLIT)
        end
    end

    
end)
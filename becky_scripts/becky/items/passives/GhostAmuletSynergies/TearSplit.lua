---@param player EntityPlayer
local function playerHasTearSplitItems(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) or player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY) or player:HasCollectible(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE)
end

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not playerHasTearSplitItems(player)then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EXPLOSIVO)
    local flags = 0

    if player:HasCollectible(CollectibleType.COLLECTIBLE_PARASITE) then
        flags = flags | TearFlags.TEAR_SPLIT
    end
    if player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_BODY) then
        flags = flags | TearFlags.TEAR_QUADSPLIT
    end

    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, enemy.Position, Vector.Zero, player):ToTear() ---@cast tear EntityTear
    tear:AddTearFlags(TearFlags.TEAR_SPLIT | TearFlags.TEAR_QUADSPLIT)

    -- local bomb = player:FireBomb(fam.Position, Vector.Zero, player)
end)
local Callbacks = BeckyMod.Enums.Callbacks

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not (player:HasCollectible(CollectibleType.COLLECTIBLE_SINUS_INFECTION) or player:HasTrinket(TrinketType.TRINKET_NOSE_GOBLIN)) then return end

    local rng = (player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_SINUS_INFECTION) or player:GetTrinketRNG(TrinketType.TRINKET_NOSE_GOBLIN))

    if rng:RandomFloat() > 0.25 then return end

    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BOOGER, 0, enemy.Position, Vector.Zero, player):ToTear() ---@cast tear EntityTear
    tear:AddTearFlags(TearFlags.TEAR_BOOGER)
end)
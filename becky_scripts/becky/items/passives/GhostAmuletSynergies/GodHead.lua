local mod = BeckyMod
local enums = mod.Enums
local variants = enums.Variants
local tempData = mod.getData

---@param fam EntityFamiliar
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local ghostData = tempData(fam)

    if not fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_GODHEAD) then return end
    if ghostData.GodHeadAura then return end

    ghostData.GodHeadAura = enums.Utils.Game:Spawn(EntityType.ENTITY_TEAR, 0, fam.Position, Vector.Zero, fam, 0, math.max(Random(), 1)):ToTear() 
    
    local tear = ghostData.GodHeadAura ---@cast tear EntityTear

    tear:AddTearFlags(TearFlags.TEAR_GLOW | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
    tempData(tear).GhostBallTear = true
    tear.Color = Color(1, 1, 1, 0)
end, variants.GHOST_BALL)

---@param tear EntityTear
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
    if not tempData(tear).GhostBallTear then return end

    tear.Position = tear.SpawnerEntity.Position 
    tear.Height = -5
end)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, variants.GHOST_BALL)) do
        tempData(ent).GodHeadAura = nil
    end
end)
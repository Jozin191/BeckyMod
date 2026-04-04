---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam, tearParams)
    local player = fam.Player

    if not player then return end
    if tearParams.TearFlags & TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP == TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP and fam.FrameCount % 6 == 0 then
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, fam.Position, Vector.Zero, player):ToEffect() ---@cast creep EntityEffect
        creep.Timeout = 26
        creep:Update()
    end
end)
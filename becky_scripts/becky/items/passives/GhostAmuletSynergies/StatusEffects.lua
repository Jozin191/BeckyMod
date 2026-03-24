---@param familiar EntityFamiliar
---@param entity EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, familiar, entity)
    local player = familiar.Player
    entity:ApplyTearflagEffects(entity.Position, player.TearFlags, player, player.Damage)
end)
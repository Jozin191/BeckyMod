---@param familiar EntityFamiliar
---@param entity EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, familiar, entity, tearParams, position)
    if not BeckyMod.IsEnemy(entity) then return end
    
    local player = familiar.Player
    local npc = entity:ToNPC() ---@cast npc EntityNPC
    npc:ApplyTearflagEffects((npc.Position+position)/2, tearParams.TearFlags, player, tearParams.TearDamage)
end)
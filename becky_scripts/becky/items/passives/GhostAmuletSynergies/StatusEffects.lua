---@param familiar EntityFamiliar
---@param entity EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, familiar, entity, tearParams)
    if not BeckyMod.IsEnemy(entity) then return end
    
    local player = familiar.Player
    local npc = entity:ToNPC() ---@cast npc EntityNPC
    npc:ApplyTearflagEffects((npc.Position+familiar.Position)/2, tearParams.TearFlags, player, tearParams.TearDamage)
end)
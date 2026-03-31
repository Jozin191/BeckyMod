---@param familiar EntityFamiliar
---@param entity EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, familiar, entity)
    if not BeckyMod.IsEnemy(entity) then return end
    
    local player = familiar.Player
    local npc = entity:ToNPC() ---@cast npc EntityNPC
    npc:ApplyTearflagEffects(npc.Position, player.TearFlags, player, player.Damage)
end)
---@param familiar EntityFamiliar
---@param entity EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, familiar, entity)
    if not BeckyMod.IsEnemy(entity) then return end
    
    local player = familiar.Player
    local npc = entity:ToNPC() ---@cast npc EntityNPC
    
    local tearParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS, 1, 1, familiar)
    npc:ApplyTearflagEffects((npc.Position+familiar.Position)/2, tearParams.TearFlags, player, tearParams.TearDamage)
end)
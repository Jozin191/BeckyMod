---@param fam EntityFamiliar
---@param enemy EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, fam, enemy, tearParams)
    local player = fam.Player
    if not (tearParams.TearFlags & TearFlags.TEAR_RIFT == TearFlags.TEAR_RIFT) then return end
    local rift = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIFT, 0, (fam.Position+enemy.Position)/2, Vector.Zero, player):ToEffect() 
    rift.SpriteScale = Vector.One*fam.SpriteScale*1.2
    rift.Size = rift.Size*fam.SpriteScale:Length()*1.2
    rift:SetTimeout(90)
    rift.CollisionDamage = tearParams.TearDamage/2
end)
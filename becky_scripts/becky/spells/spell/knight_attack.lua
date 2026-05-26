local SPELL_COST = 45
local knightAttackVar = Isaac.GetEntityVariantByName("Spell Knight Attack")
local knightVar = Isaac.GetEntityVariantByName("Spell (The) Knight")
BeckyMod.Spells.ENTITIES.KNIGHT_ATTACK = { Type = 1000, Variant = knightAttackVar }
BeckyMod.Spells.ENTITIES.THE_KNIGHT = { Type = 1000, Variant = knightVar }

local LASER_DMG = 50
local LASER_TIMEOUT = 4

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
    local sp = eff:GetSprite()
    sp:Play("Slash", true)
    sp.Rotation = eff:GetDropRNG():RandomFloat() * 360

end, knightAttackVar)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local sp = eff:GetSprite()
    if sp:IsFinished("Disappear") then
        eff:Remove()
        return
    end
    if not sp:IsFinished() or sp:IsPlaying("Disappear") then return end
    eff:Die()
    sp:Play("Disappear", true)

    local room = BeckyMod.Game:GetRoom()

    local laser = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, eff.Position, Vector.Zero, eff.SpawnerEntity):ToLaser()
    laser.Angle = sp.Rotation
    laser.AngleDegrees = sp.Rotation
    laser.CollisionDamage = LASER_DMG
    laser:SetTimeout(LASER_TIMEOUT)
    laser:SetOneHit(false)
    laser:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    laser:SetInitSound(SoundEffect.SOUND_NULL)
    laser:SetDisableFollowParent(true)
    laser:GetSprite().Color.A = 0

    local laser2 = Isaac.Spawn(EntityType.ENTITY_LASER, LaserVariant.THICK_RED, 0, eff.Position, Vector.Zero, eff.SpawnerEntity):ToLaser()
    laser2.Angle = sp.Rotation + 180
    laser2.AngleDegrees = sp.Rotation + 180
    laser2.CollisionDamage = LASER_DMG
    laser2:SetTimeout(LASER_TIMEOUT)
    laser2:SetOneHit(false)
    laser2:AddTearFlags(TearFlags.TEAR_SPECTRAL)
    laser2:SetInitSound(SoundEffect.SOUND_NULL)
    laser2:SetDisableFollowParent(true)
    laser2:GetSprite().Color.A = 0
    
end, knightAttackVar)


BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
    local sp = eff:GetSprite()
    sp:Play("Appear", true)

end, knightVar)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local sp = eff:GetSprite()
    if sp:IsFinished("Appear") then
        Isaac.Spawn(1000, knightAttackVar, 0, eff.Position, Vector.Zero, eff.SpawnerEntity)
        sp:Play("Idle", true)
    elseif sp:IsFinished("Idle") then
        sp:Play("Slice", true)
    elseif sp:IsFinished("Slice") then
        sp:Play("Away", true)
    elseif sp:IsFinished("Away") then
        eff:Remove()
    end
end, knightVar)


local function fun(player)
    Isaac.Spawn(1000, knightVar, 0, player.Position, Vector.Zero, player)
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.KNIGHT_ATTACK,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST
}
local SPELL_COST = 45
local knightAttackVar = Isaac.GetEntityVariantByName("Spell Knight Attack")
local knightVar = Isaac.GetEntityVariantByName("Spell (The) Knight")
BeckyMod.Spells.ENTITIES.KNIGHT_ATTACK = { Type = 1000, Variant = knightAttackVar }
BeckyMod.Spells.ENTITIES.THE_KNIGHT = { Type = 1000, Variant = knightVar }

local LASER_DMG = 50 /6
local LASER_TIMEOUT = 4
local NONO_FLAGS = (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
    local sp = eff:GetSprite()

    local angleOffset = 0
    if eff.SubType == 1 then
        sp:Play("Disappear", true)
        angleOffset = BeckyMod.RandomFloat(-24, 24, eff:GetDropRNG())
    else
        sp:Play("Slash", true)
    end

    local spawner = eff.SpawnerEntity

    if spawner == nil or spawner.TargetPosition == nil or spawner.TargetPosition:Length() <= 0.001 then
        sp.Rotation = eff:GetDropRNG():RandomFloat() * 360 - 180
    else
        sp.Rotation = (spawner.TargetPosition - spawner.Position):GetAngleDegrees() + angleOffset
    end

end, knightAttackVar)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local sp = eff:GetSprite()
    if sp:IsFinished("Disappear") then
        eff:Remove()
        return
    end
    if eff.SubType == 1 then
        if sp:GetFrame() > 0 then return end
    elseif sp:IsFinished("Slash") then 
        sp:Play("Disappear", true)
    elseif sp:IsPlaying("Slash") then
        local spawner = eff.SpawnerEntity
        if spawner and spawner.TargetPosition ~= nil and spawner.TargetPosition:Length() > 0.001 then
            sp.Rotation = (spawner.TargetPosition - spawner.Position):GetAngleDegrees()
        end

        return
    elseif sp:IsPlaying("Disappear") then
        return
    end

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
    BeckyMod.GetEntData(laser).NoGrantMana = true

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
    BeckyMod.GetEntData(laser2).NoGrantMana = true
    
end, knightAttackVar)


local function TableFilter(ent)
    if ent:ToNPC() ~= nil and ent:GetEntityFlags() & NONO_FLAGS == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() then return true end
    return false
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
    local sp = eff:GetSprite()
    sp:Play("Appear", true)

end, knightVar)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local sp = eff:GetSprite()
    if eff.State == 0 then
        local pos = eff.Position
        local dis
        local targetPos
        for _, ent in ipairs( BeckyMod:FilterList(Isaac.GetRoomEntities(), TableFilter) ) do
            local entDis = ent.Position:Distance(pos)
            if (targetPos == nil or entDis < dis) then
                targetPos = ent.Position
                dis = entDis
            end
        end

        if targetPos ~= nil then
            if eff.TargetPosition == nil or eff.TargetPosition:Length() <= 0.001 then
                eff.TargetPosition = targetPos
            else
                eff.TargetPosition = BeckyMod:Lerp(eff.TargetPosition, targetPos, 0.035)
            end
        end
    end
    
    if sp:IsFinished("Appear") then
        Isaac.Spawn(1000, knightAttackVar, 0, eff.Position, Vector.Zero, eff)
        sp:Play("Idle", true)
    elseif sp:IsFinished("Idle") then
        sp:Play("Slice", true)
        eff.State = 1
    elseif sp:IsPlaying("Slice") and sp:GetFrame() >= 4 then
        Isaac.Spawn(1000, knightAttackVar, 1, eff.Position, Vector.Zero, eff)
        sp:Play("Slice2", true)
    elseif sp:IsPlaying("Slice2") and sp:GetFrame() >= 4 then
        Isaac.Spawn(1000, knightAttackVar, 1, eff.Position, Vector.Zero, eff)
        sp:Play("Slice3", true)
    elseif sp:IsFinished("Slice3") then
        sp:Play("Away", true)
    elseif sp:IsFinished("Away") then
        eff:Remove()
    end

end, knightVar)


BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, -300, function(_, player, dmg, dmgFlags, src)
    local srcEnt = src.Entity
    local spawner = srcEnt and srcEnt.SpawnerEntity
    if (srcEnt and srcEnt.Type == 1000 and srcEnt.Variant == knightVar) or (spawner and spawner.Type == 1000 and spawner.Variant == knightVar) then
        return false
    end
end)

local function fun(player)
    local knight = Isaac.Spawn(1000, knightVar, 0, player.Position, Vector.Zero, player)
    BeckyMod.GetEntData(knight).NoGrantMana = true
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

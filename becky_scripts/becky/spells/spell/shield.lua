
local MANA_DISCHARGE = 1
local SHIELD_PUSH = Vector(14,0)
BeckyMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, function(_, player, dmgAmount, dmgFlags, src, dmgCooldown)
    if dmgFlags & DamageFlag.DAMAGE_FAKE >0 then return end

    local data = player:GetData()
    if data.SpellsData and data.SpellsData.ShieldActive then
        local playerPos = player.Position
        local list = Isaac.FindInRadius( playerPos, 60, EntityPartition.ENEMY )
        local entRef = EntityRef(player)
        local dmg = player.Damage
        for _, ent in ipairs(list) do
            ent:TakeDamage(dmg, 0, entRef, 0)
            ent:AddKnockback(
                entRef,
                SHIELD_PUSH:Rotated( (ent.Position - playerPos):GetAngleDegrees() ),
                2,
                false
            )
        end
        return false
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
    eff.Parent = eff.SpawnerEntity
    if eff.Parent then
        eff:FollowParent(eff.Parent)
    end
end, BeckyMod.Spells.ENTITIES.SHIELD.Variant)


BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local player = eff.Parent and eff.Parent:ToPlayer()
    if not player then
        eff:Remove()
        return
    end
    
    local save = BeckyMod:RunSave(player)
    if player:IsDead() or not save.ManaCharge or save.ManaCharge <= 0 then
        eff:Remove()
        local data = player:GetData()
        data.SpellsData = data.SpellsData or {}

        data.SpellsData.ShieldActive = false
        data.NoChargeMana = data.NoChargeMana -1
        data.ManaDischarge = data.ManaDischarge -MANA_DISCHARGE
    end
end, BeckyMod.Spells.ENTITIES.SHIELD.Variant)


local function fun(player)
    local data = player:GetData()
    data.SpellsData = data.SpellsData or {}

    data.SpellsData.ShieldActive = (not data.SpellsData.ShieldActive)
    if data.SpellsData.ShieldActive then
        data.NoChargeMana = (data.NoChargeMana or 0) +1

        local ent = Isaac.Spawn(
            BeckyMod.Spells.ENTITIES.SHIELD.Type,
            BeckyMod.Spells.ENTITIES.SHIELD.Variant,
            0,
            player.Position,
            Vector.Zero,
            player
        )
        ent.DepthOffset = 1
        data.ManaDischarge = (data.ManaDischarge or 0) + MANA_DISCHARGE
    else
        data.NoChargeMana = (data.NoChargeMana or 0) -1
        local ptr = GetPtrHash(player)
        for _, ent in ipairs(Isaac.FindByType(BeckyMod.Spells.ENTITIES.SHIELD.Type, BeckyMod.Spells.ENTITIES.SHIELD.Variant)) do
            if ent.Parent and GetPtrHash(ent.Parent) == ptr then ent:Remove() end
        end
        data.ManaDischarge = data.ManaDischarge -MANA_DISCHARGE
    end
end

local function canSelectFun(player, manaLeft)
    return manaLeft > 15
end

return {
    BeckyMod.Spells.SpellType.SHIELD,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0
}
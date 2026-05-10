local shieldEntVar = Isaac.GetEntityVariantByName("Mana Shield")
local nullItem = Isaac.GetNullItemIdByName("SPELL_Shield")
BeckyMod.Spells.NULL_ITEMS.SHIELD = nullItem
BeckyMod.Spells.ENTITIES.SHIELD = { Type = 1000, Variant = shieldEntVar }

local MANA_DISCHARGE = 1
local SHIELD_PUSH = Vector(14,0)
BeckyMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, function(_, player, dmgAmount, dmgFlags, src, dmgCooldown)
    if dmgFlags & DamageFlag.DAMAGE_FAKE >0 then return end

    if player:GetEffects():HasNullEffect(nullItem) then
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
end, shieldEntVar)


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

        data.NoChargeMana = data.NoChargeMana -1*count
        data.ManaDischarge = data.ManaDischarge -MANA_DISCHARGE
    end
end, shieldEntVar)


BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, function(_, player, itemConfig, addCostume, count)
    if itemConfig:IsNull() and itemConfig.ID == nullItem then
        local data = player:GetData()
        data.NoChargeMana = (data.NoChargeMana or 0) +1*count
    
        local ent = Isaac.Spawn(
            1000,
            shieldEntVar,
            0,
            player.Position,
            Vector.Zero,
            player
        )
        ent.DepthOffset = 1
        data.ManaDischarge = (data.ManaDischarge or 0) + MANA_DISCHARGE *count
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, function(_, player, itemConfig, count)
    if itemConfig:IsNull() and itemConfig.ID == nullItem then
        local data = player:GetData()
        data.NoChargeMana = (data.NoChargeMana or 0) -1*count
        local ptr = GetPtrHash(player)
        for _, ent in ipairs(Isaac.FindByType(1000, shieldEntVar)) do
            if ent.Parent and GetPtrHash(ent.Parent) == ptr then ent:Remove() end
        end
        data.ManaDischarge = data.ManaDischarge -MANA_DISCHARGE *count
    end
end)


local function fun(player)
    local effects = player:GetEffects()
    if effects:HasNullEffect(nullItem) then
        effects:RemoveNullEffect(nullItem, -1)
    else
        effects:AddNullEffect(nullItem)
    end
end

local function canSelectFun(player, manaLeft)
    return manaLeft > 15 or player:GetEffects():HasNullEffect(nullItem)
end

return {
    BeckyMod.Spells.SpellType.SHIELD,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0
}
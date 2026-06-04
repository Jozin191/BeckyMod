local SPELL_COST = 20
local MANA_DISCHARGE = 0.25
local nullItem = Isaac.GetNullItemIdByName("SPELL_FirePower")
BeckyMod.Spells.NULL_ITEMS.FIRE_POWER = nullItem
local FireCooldown = -1

local function CheckForMana(player)
    if not player:GetEffects():HasNullEffect(nullItem) then return end
    local save = BeckyMod:RunSave(player)
    if player:IsDead() or not save.ManaCharge or save.ManaCharge <= 0 then
        player:GetEffects():RemoveNullEffect(nullItem, -1)
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if BeckyMod.Game:IsPaused() then return end
    local room = BeckyMod.Game:GetRoom()
    local effectNum = room:GetEffects():GetNullEffectNum(nullItem)
    if effectNum == 0 then return end
    if FireCooldown == -1 then
        FireCooldown = 30 + 15 * (Random() % 4)
    elseif FireCooldown > 0 then
        FireCooldown = FireCooldown -1
        return
    end
    BeckyMod:ForEachPlayer(CheckForMana)

    local seed = Random()
    if seed == 0 then seed =1 end
    local spawnPos = room:GetGridPosition(room:GetRandomTileIndex(seed))
    
    local fire = Isaac.Spawn(1000, EffectVariant.RED_CANDLE_FLAME, 0, room:FindFreeTilePosition(spawnPos, 40), Vector.Zero, Isaac.GetPlayer()):ToEffect()
    fire.CollisionDamage = 15
    fire:SetTimeout(90)
    BeckyMod.GetEntData(fire).NoGrantMana = true

    FireCooldown = 60 + 15 * (Random() % 4) - 15 *effectNum
    if FireCooldown < 15 then FireCooldown = 15 end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function() FireCooldown =-1 end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, function(_, player, itemConfig, addCostume, count)
    if itemConfig:IsNull() and itemConfig.ID == nullItem then
        local data = BeckyMod.GetEntData(player)
        data.ManaDischarge = (data.ManaDischarge or 0) + MANA_DISCHARGE *count
        BeckyMod.Game:GetRoom():GetEffects():AddNullEffect(nullItem, count)
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, function(_, player, itemConfig, count)
    if itemConfig:IsNull() and itemConfig.ID == nullItem then
        local data = BeckyMod.GetEntData(player)
        data.ManaDischarge = data.ManaDischarge -MANA_DISCHARGE *count
        BeckyMod.Game:GetRoom():GetEffects():RemoveNullEffect(nullItem, count)
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
    return manaLeft >= SPELL_COST or player:GetEffects():HasNullEffect(nullItem)
end

return {
    BeckyMod.Spells.SpellType.FIRE_POWER,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0
}

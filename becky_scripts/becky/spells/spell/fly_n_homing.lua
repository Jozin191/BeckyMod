
local SPELL_COST = 70
local nullItem = Isaac.GetNullItemIdByName("SPELL_FlyHoming")
BeckyMod.Spells.NULL_ITEMS.FLY_N_HOMING = nullItem
local HOMING_COLOR = Color

BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlags)
    if not player:GetEffects():HasNullEffect(nullItem) then return end
    
    if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = math.max(player.MoveSpeed + 0.3, 1.25)

    elseif cacheFlags & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG then
        player.TearFlags = player.TearFlags | TearFlags.TEAR_HOMING

    elseif cacheFlags & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR then
        player.TearColor = player.TearColor * Color.TearHoming
        player.LaserColor = player.LaserColor * Color.LaserHoming

    elseif cacheFlags & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING then
        player.CanFly = true
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

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, function(_, player, itemConfig, addCostume, count)
    if itemConfig:IsNull() and itemConfig.ID == nullItem then
        local data = BeckyMod.GetEntData(player)
        data.NoChargeMana = (data.NoChargeMana or 0) +1*count
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, function(_, player, itemConfig, count)
    if itemConfig:IsNull() and itemConfig.ID == nullItem then
        local data = BeckyMod.GetEntData(player)
        data.NoChargeMana = (data.NoChargeMana or 0) -1*count
    end
end)

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST or player:GetEffects():HasNullEffect(nullItem)
end

return {
    BeckyMod.Spells.SpellType.FLY_N_HOMING,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST
}
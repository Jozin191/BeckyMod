
local SPELL_COST = 70
local nullItem = Isaac.GetNullItemIdByName("SPELL_Multishot")
BeckyMod.Spells.NULL_ITEMS.MULTISHOT = nullItem
local SPREAD_ANGLE = 4.34

BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_MULTI_SHOT_PARAMS, function(_, player, multishotParam, weaponType)
    if player:GetEffects():HasNullEffect(nullItem) then
        local numTears = multishotParam:GetNumTears() + 3
        multishotParam:SetNumTears( numTears * multishotParam:GetNumEyesActive() )
        multishotParam:SetNumLanesPerEye(numTears)
        local spread = multishotParam:GetSpreadAngle(weaponType)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
            if spread < SPREAD_ANGLE *0.666666 then
                multishotParam:SetSpreadAngle(weaponType, SPREAD_ANGLE *0.666666)
            end
        elseif spread < SPREAD_ANGLE then
            multishotParam:SetSpreadAngle(weaponType, SPREAD_ANGLE)
        end
        return multishotParam
    end
end)

BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, function(_, player, cacheFlags)
    if not player:GetEffects():HasNullEffect(nullItem) then return end
    
    local tps = BeckyMod:toTearsPerSecond(player.MaxFireDelay)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
        tps = tps * 0.42
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) then
        tps = tps * 0.56
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) then
        tps = tps * 0.68
    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) then
        tps = tps * 0.56
    else
        tps = tps * 0.42
    end
    player.MaxFireDelay = BeckyMod:toMaxFireDelay(tps)

end, CacheFlag.CACHE_FIREDELAY)


local function fun(player)
    local save = BeckyMod:RunSave(player)
    local effects = player:GetEffects()
    local hasEffect = effects:HasNullEffect(nullItem)

    if hasEffect then
        effects:RemoveNullEffect(nullItem, -1)
    else
        save.ManaCharge = save.ManaCharge - SPELL_COST
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
    BeckyMod.Spells.SpellType.MULTISHOT,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0
}
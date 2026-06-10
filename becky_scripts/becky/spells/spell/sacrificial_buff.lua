
local SPELL_COST = 0
local nullItem = Isaac.GetNullItemIdByName("SPELL_SacrificialBuff")
BeckyMod.Spells.NULL_ITEMS.SACRIFICIAL_BUFF = nullItem
local DAMAGE_FLAGS = DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_NO_MODIFIERS

local function fun(player)
    player:ResetDamageCooldown()
    player:TakeDamage(2, DAMAGE_FLAGS, EntityRef(player), 30)
    player:SetMinDamageCooldown(30)

    local effects = player:GetEffects()
    if effects:HasNullEffect(nullItem) then
        effects:RemoveNullEffect(nullItem, -1)
    else
        effects:AddNullEffect(nullItem)
    end
end

local function canSelectFun(player, manaLeft)
    return true
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, 200, function(_, player, cacheFlags)
    local buff = player:GetEffects():GetNullEffectNum(nullItem)

    if buff <= 0 then return end
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * (1.25 ^ buff)

    elseif cacheFlags & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY then
        
        local tps = BeckyMod:toTearsPerSecond(player.MaxFireDelay)
        tps = tps * (1.25 ^ buff)
        player.MaxFireDelay = BeckyMod:toMaxFireDelay(tps)

    elseif cacheFlags & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE then
        player.TearRange = player.TearRange * (1.25 ^ buff)
    end
end)

return {
    BeckyMod.Spells.SpellType.SACRIFICIAL_BUFF,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST,
    Frame = 4
}
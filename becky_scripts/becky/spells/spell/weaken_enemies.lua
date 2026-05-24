local SPELL_COST = 70
local nullItem = Isaac.GetNullItemIdByName("SPELL_WeakEnemies")
BeckyMod.Spells.NULL_ITEMS.WEAKEN_ENEMIES = nullItem
local SLOWNESS_COLOR = Color(1,1,1,1, 0.16,0.16,0.16)

local function fun(player)
    local src = EntityRef(player)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if ent:ToNPC() and ent:IsActiveEnemy() and ent:CanShutDoors() then
            ent:AddWeakness(src, 300)
            ent:AddSlowing(src, 300, 0.75, SLOWNESS_COLOR)
        end
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_EFFECT, function(_, player, itemConfig, addCostume, count)
    if itemConfig:IsNull() and itemConfig.ID == nullItem then
        local data = BeckyMod.GetEntData(player)
        data.NoChargeMana = data.NoChargeMana +1*count
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, function(_, player, itemConfig, count)
    if itemConfig:IsNull() and itemConfig.ID == nullItem then
        local data = BeckyMod.GetEntData(player)
        data.NoChargeMana = data.NoChargeMana -1*count
    end
end)


local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.WEAKEN_ENEMIES,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST
}
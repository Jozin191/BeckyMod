local function fun(player) end

local function canSelectFun(player, manaLeft)
    return false
end

return {
    BeckyMod.Spells.SpellType.MANA_REGEN,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0
}
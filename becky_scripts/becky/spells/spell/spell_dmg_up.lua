local function fun(player) end

local function canSelectFun(player, manaLeft)
    return false
end

return {
    BeckyMod.Spells.SpellType.SPELL_DMG_UP,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = 0
}
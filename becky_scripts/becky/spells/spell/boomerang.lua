local SPELL_COST = 15
local TEAR_VEL = Vector(2.5 *10, 0)

local function fun(player)
    local pos = player.Position

end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.BOOMERANG,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST
}
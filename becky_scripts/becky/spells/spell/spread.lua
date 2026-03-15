
local SPELL_COST = 30
local TEAR_VEL = Vector(1, 0)

local function fun(player)
    local vel = TEAR_VEL:Resized(2.5 *10)
    local pos = player.Position

    for i=0, 270, 90 do
        local tear = player:FireTear(pos, vel:Rotated(i), false, false, false, player, 1)
        tear:ChangeVariant(BeckyMod.Spells.ENTITIES.MANA_TEAR.Variant)
    end
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.SPREAD,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST
}
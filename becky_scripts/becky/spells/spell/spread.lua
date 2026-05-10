
local SPELL_COST = 15
local TEAR_VEL = Vector(1.8 *10, 0)

local function fun(player)
    local pos = player.Position

    for angle=-180, 135, 45 do
        for _, weap in ipairs(BeckyMod.Character.BECKY_B:FireWeapon(player, player, Vector(1,0):Rotated(angle), 1.15, false, false)) do
            if weap.Velocity:Length() >0 then
                weap.Velocity = TEAR_VEL:Rotated( weap.Velocity:GetAngleDegrees() )
            end
        end
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
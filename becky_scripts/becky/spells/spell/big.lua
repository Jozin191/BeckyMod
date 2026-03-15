
local SPELL_COST = 50
local TEAR_VEL = Vector(1, 0)

local function fun(player)
    local data = player:GetData()
    if data.MagicStaff_SelectSpellDir == nil then
        data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.BIG }
        return
    end
    local vel = TEAR_VEL:Resized(2.5 *10)
    local pos = player.Position
    local angle = -180 + data.MagicStaff_SelectSpellDir.Dir * 90

    local tear = player:FireTear(pos, vel:Rotated(angle), false, false, false, player, 2.25)
    tear:ChangeVariant(BeckyMod.Spells.ENTITIES.BIG_MANA_TEAR.Variant)
    tear.Scale = 2
    tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)

    data.MagicStaff_SelectSpellDir = nil
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.BIG,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST
}

local SPELL_COST = 30
local TEAR_VEL = Vector(2.5 *10, 0)

local function fun(player)
    local data = player:GetData()
    if data.MagicStaff_SelectSpellDir == nil then
        data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.BIG }
        return
    end
    local pos = player.Position
    local angle = -180 + data.MagicStaff_SelectSpellDir.Dir * 90

    --local tear = player:FireTear(pos, vel:Rotated(angle), false, false, false, player, 2.25)
    --tear:ChangeVariant(BeckyMod.Spells.ENTITIES.BIG_MANA_TEAR.Variant)
    --tear.Scale = 2
    --tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)

    for _, weap in ipairs(BeckyMod.Character.BECKY_B:FireWeapon(player, player, Vector(1,0):Rotated(angle), 2.25, false, false)) do
        weap:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_PIERCING)
        if weap.Velocity:Length() >0 then
            weap.Velocity = TEAR_VEL:Rotated( weap.Velocity:GetAngleDegrees() )
        end
        if weap.Type == 7 then
            weap.SpriteScale.X = weap.SpriteScale.X *1.5
        elseif type(weap.Scale) == "number" then
            weap.Scale = 2
        end
    end

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
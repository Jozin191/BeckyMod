local SPELL_COST = 35
local FIRESPEED = Vector(12, 0)

local function fun(player)
    local dmg = math.max(player.Damage * 0.25 + 3, 5)

    for i=1, 8 do
        local angle = 45 * i -180
        local mult = 1
        if i % 2 then mult = 0.66 end

        local fire = Isaac.Spawn(1000, EffectVariant.RED_CANDLE_FLAME, 0, player.Position, (FIRESPEED * mult):Rotated(angle), player):ToEffect()
        fire.CollisionDamage = dmg
        fire:SetTimeout(120)
        BeckyMod.GetEntData(fire).NoGrantMana = true
    end
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.AETHER_CIRCLE,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST,
    Frame = 99
}

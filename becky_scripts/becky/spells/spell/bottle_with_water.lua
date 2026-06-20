local SPELL_COST = 40
local TEAR_VEL = Vector(1.35 *10, 0)
local flaskVar = Isaac.GetEntityVariantByName("Spell Bottle With Water")

BeckyMod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear, offset)
    local sp = tear:GetSprite()

    local scale = tear.Scale
    local sizeMulti = tear.SizeMulti
    local flags = tear.TearFlags
    local anim
    if scale <= 0.3 then
        anim = "RegularTear1"
    elseif scale <= 0.55 then
        anim = "RegularTear2"
    elseif scale <= 0.675 then
        anim = "RegularTear3"
    elseif scale <= 0.8 then
        anim = "RegularTear4"
    elseif scale <= 0.925 then
        anim = "RegularTear5"
    elseif scale <= 1.05 then
        anim = "RegularTear6"
    elseif scale <= 1.175 then
        anim = "RegularTear7"
    elseif scale <= 1.425 then
        anim = "RegularTear8"
    elseif scale <= 1.675 then
        anim = "RegularTear9"
    elseif scale <= 1.925 then
        anim = "RegularTear10"
    elseif scale <= 2.175 then
        anim = "RegularTear11"
    elseif scale <= 2.55 then
        anim = "RegularTear12"
    else
        anim = "RegularTear13"
    end
    sp:SetFrame(anim, tear.FrameCount % 16)

    if scale > 2.55 then
        tear.SpriteScale = Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
    elseif flags & TearFlags.TEAR_GROW == TearFlags.TEAR_GROW or flags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO then
        if scale <= 0.3 then
            tear.SpriteScale = Vector((scale * sizeMulti.X) / 0.25, (scale * sizeMulti.Y) / 0.25)
        elseif scale <= 0.55 then
            local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
            tear.SpriteScale = Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
        elseif scale <= 1.175 then
            local adjustedBase = math.ceil((scale - 0.175) / 0.125) * 0.125 + 0.175
            tear.SpriteScale = Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
        elseif scale <= 2.175 then
            local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
            tear.SpriteScale = Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
        else
            tear.SpriteScale = Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
        end
    else
        tear.SpriteScale = sizeMulti
    end
end, flaskVar)
BeckyMod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, function(_, tear)

    local eff = Isaac.Spawn(1000, EffectVariant.TEAR_POOF_A, 1, tear.Position, Vector.Zero, tear):ToEffect()
    eff.Color = tear.Color
    eff.Scale = tear.Scale
    BeckyMod.SFX:Play(SoundEffect.SOUND_GLASS_BREAK)

    local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, tear.Position, Vector.Zero, tear):ToEffect()
    creep.CollisionDamage = 0.75
    creep.Scale = 2
    creep:SetTimeout(150)
    BeckyMod.GetEntData(creep).NoGrantMana = true

end, flaskVar)

local function fun(player)
    local data = BeckyMod.GetEntData(player)
    if data.MagicStaff_SelectSpellDir == nil then
        data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.BOTTLE_WITH_WATER }
        return
    end
    local pos = player.Position
    local angle = -180 + data.MagicStaff_SelectSpellDir.Dir * 90

    local tear = Isaac.Spawn(2, flaskVar, 0, pos, TEAR_VEL:Rotated(angle) + player:GetTearMovementInheritance( Vector(1,0):Rotated(angle) ) , player):ToTear()
    tear.CollisionDamage = 7.5
    tear.Scale = 1.05
    tear.FallingSpeed = -16
    tear.FallingAcceleration = 1.33
    BeckyMod.GetEntData(tear).NoGrantMana = true

    data.MagicStaff_SelectSpellDir = nil
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.BOTTLE_WITH_WATER,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST,
    Frame = 22
}
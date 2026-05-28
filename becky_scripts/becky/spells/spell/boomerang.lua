local SPELL_COST = 12
local boomerangVar = Isaac.GetEntityVariantByName("Spell Boomerang")
local boomerangAltVar = Isaac.GetEntityVariantByName("Spell Boomerang Alt")
BeckyMod.Spells.ENTITIES.BOOMERANG = { Type = 1000, Variant = boomerangVar }
BeckyMod.Spells.ENTITIES.BOOMERANG_ALT = { Type = 1000, Variant = boomerangAltVar }

local BOOMERANG_VEL = Vector(2.5 *7.5, 0)
local function Lerp(vec1, vec2, percent)
    return vec1 * (1 - percent) + vec2 * percent
end
local State = {
    DO_NOTHING = 0,
    RETURN = 1,
    GO_FREE = 2,
}
local RETURN_TIME = 24
local BOOMERANG_DMG = 14 /5

local RoomLimits = {
    X1 = 0,
    Y1 = 0,
    X2 = 0,
    Y2 = 0,
}

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local room = BeckyMod.Game:GetRoom()
    local width = (room:GetGridWidth() /2 +2) *40
    local height = (room:GetGridHeight() /2 +2) *40
    local center = room:GetCenterPos()
    RoomLimits.X1 = center.X - width
    RoomLimits.Y1 = center.Y - height
    RoomLimits.X2 = center.X + width
    RoomLimits.Y2 = center.Y + height

end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
    local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, eff.Position, Vector.Zero, eff):ToEffect() 
    trail:FollowParent(eff)
    trail.SpriteScale = trail.SpriteScale *2
    if eff.SpawnerEntity == nil then
        BeckyMod.GetEntData(eff).SpawnerPos = eff.Position
    end
end, boomerangVar)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local state = eff.State
    local pos = eff.Position
    if state == State.DO_NOTHING then
        if eff.FrameCount >= RETURN_TIME then
            eff.State = State.RETURN
            if eff.SpawnerEntity == nil then
                BeckyMod.GetEntData(eff).ReturnVel = eff.Velocity:Rotated(180)
            end
        end
    elseif state == State.RETURN then
        local targetPos
        if BeckyMod.GetEntData(eff).SpawnerPos then
            targetPos = BeckyMod.GetEntData(eff).SpawnerPos
        else
            targetPos = eff.SpawnerEntity.Position
        end

        local mult = math.min((eff.FrameCount - RETURN_TIME) / 15, 1)
        local angle = (targetPos - pos):Normalized():GetAngleDegrees()
        local targetVel = BOOMERANG_VEL:Rotated( angle )
        eff.Velocity = Lerp(eff.Velocity, targetVel, 0.08 * mult)
        
        if mult < 1 then return end

        if BeckyMod.GetEntData(eff).ReturnVel then
            if BeckyMod.GetEntData(eff).ReturnVel:Distance(eff.Velocity) < 0.1 then
                eff.State = State.GO_FREE
            end
        else
            local spawner = eff.SpawnerEntity
            local spawnerPos = spawner.Position
            if spawnerPos:Distance(pos) < 18 + spawner.Size then
                eff.State = State.GO_FREE
            end
        end

    elseif state == State.GO_FREE then
        eff.Velocity = eff.Velocity *1.045
        if pos.X < RoomLimits.X1 or pos.X > RoomLimits.X2 or pos.Y < RoomLimits.Y1 or pos.Y > RoomLimits.Y2 then
            eff:Remove()
        end
    end
    
    eff:GetSprite().Rotation = eff.Velocity:GetAngleDegrees()

    if Isaac.CountEnemies() <= 0 then return end
    local ref = EntityRef(eff)
    for _, ent in ipairs(Isaac.FindInRadius(pos, 14, EntityPartition.ENEMY)) do
        if BeckyMod.IsEnemy(ent) then
            ent:TakeDamage(BOOMERANG_DMG, 0, ref, 0)
        end
    end
end, boomerangVar)

local function fun(player)
    local pos = player.Position

    local eff = Isaac.Spawn(1000, boomerangVar, 0, pos, BOOMERANG_VEL:Rotated(Random() % 360), player)
    BeckyMod.GetEntData(eff).NoGrantMana = true
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
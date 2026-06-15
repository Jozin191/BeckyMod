local SPELL_COST = 0
local HELPER_VAR = Isaac.GetEntityVariantByName("Spell Haunt Helper")
local NONO_FLAGS = (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN)
local TEAR_SPEED = Vector(10, 0)
local HAUNT_COLOR = Color(0.75, 0.75, 0.75,1, 0.4, 0.0, 0.55)

local function ValidEnt(ent)
    if ent:ToNPC() ~= nil and ent:GetEntityFlags() & NONO_FLAGS == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() then return true end
    return false
end


BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, -200, function(_, npc)
    if not BeckyMod.GetEntData(npc).IsHaunted then return end
    local frameCount = npc.FrameCount/30
    --local colorAmount = (5 * math.sin((360/16) * frameCount) +5) / 10

    npc:SetColor(HAUNT_COLOR, 2, 999, false, false)
    
    -- a * sin((360/d)*x - f) + m
    local X = 2.5 * math.sin((360/12) * frameCount/4) * 5
    local Y = 1.5 * math.sin((360/5) * frameCount/4) * 5 - 8
    npc.PositionOffset = Vector(X, Y)
    ---npc.SpriteRotation = 2.5 * math.sin((360/12) * frameCount/4 + 3) *2.5
    return true
end)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, -200, function(_, npc, coll)
    if not BeckyMod.GetEntData(npc).IsHaunted then
        if BeckyMod.GetEntData(coll).IsHaunted then
            coll:TakeDamage(math.max(npc.CollisionDamage, 0.5), 0, EntityRef(npc), 0)
        end
        return
    end

    if coll:ToPlayer() then
        return false
    elseif coll:ToNPC() then
        coll:TakeDamage(math.max(npc.CollisionDamage, 0.5), 0, EntityRef(npc), 0)
    end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local parent = eff.Parent
    local player = eff.SpawnerEntity and eff.SpawnerEntity:ToPlayer()
    if eff.Timeout == 0 or parent == nil or parent:IsDead() or not parent:Exists() then
        if parent and parent:Exists() then
            parent.PositionOffset = Vector.Zero
            --parent.SpriteRotation = 0
        end
        eff:Remove()
        return
    end
    if player == nil or player:IsDead() or not player:Exists() then
        eff.Velocity = Vector.Zero
        parent.Velocity = Vector.Zero
        return
    end
    local aimDir = player:GetShootingJoystick()

    eff.Velocity = aimDir:Resized(player.ShotSpeed *10):Lerp(eff.Velocity, 0.2)
    parent.Velocity = eff.Velocity

end, HELPER_VAR)

BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, ent)
    if ent.Type == 1000 and ent.Variant == HELPER_VAR then
        local target = ent.Parent
        if target and not target:IsDead() and target:Exists() then
            BeckyMod.GetEntData(target).IsHaunted = nil
        end
    end
end)


local function MakeHauntedEnt(ent, spawner)
    if BeckyMod.GetEntData(ent).IsHaunted then return end
    if ent:IsBoss() then
        ent:AddConfusion(EntityRef(spawner), 75, false)
        return
    else
        local eff = Isaac.Spawn(1000, HELPER_VAR, 0, ent.Position, Vector.Zero, spawner):ToEffect()
        eff:FollowParent(ent)
        eff:SetTimeout(150)
        BeckyMod.GetEntData(ent).IsHaunted = true
    end
    if ent.Parent then
        MakeHauntedEnt(ent.Parent, spawner)
    end
    if ent.Child then
        MakeHauntedEnt(ent.Child, spawner)
    end
end
BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, 200, function(_, tear, coll)
    if not ValidEnt(coll) then return end
    
    local spawner = tear.SpawnerEntity
    if spawner == nil then return end
    for _, ent in ipairs(Isaac.FindByType(coll.Type, coll.Variant)) do
        if ValidEnt(ent) then
            MakeHauntedEnt(ent, spawner)
        end
    end
end, BeckyMod.Spells.ENTITIES.MANA_TEAR.Variant)


local function fun(player)
    local data = BeckyMod.GetEntData(player)
    if data.MagicStaff_SelectSpellDir == nil then
        data.MagicStaff_SelectSpellDir = { Type = BeckyMod.Spells.SpellType.HAUNT }
        return
    end
    local pos = player.Position
    local angle = -180 + data.MagicStaff_SelectSpellDir.Dir * 90

    local tear = Isaac.Spawn(2, BeckyMod.Spells.ENTITIES.MANA_TEAR.Variant, 0, pos, TEAR_SPEED:Rotated(angle), player):ToTear()
    BeckyMod.GetEntData(tear).NoGrantMana = true
    tear.CollisionDamage = 0
    data.MagicStaff_SelectSpellDir = nil
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.HAUNT,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST,
    Frame = 99
}

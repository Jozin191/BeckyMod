local SPELL_COST = 40
local SPEAR_SPEED = Vector(24, 0)
local SPEAR_VAR = Isaac.GetEntityVariantByName("Spell Gilded Spear Spear")
local NONO_FLAGS = (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN)

local function TableFilter(ent)
    if ent:ToNPC() ~= nil and ent:GetEntityFlags() & NONO_FLAGS == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() and ent:IsVulnerableEnemy() then return true end
    return false
end
local RoomBorder = {
    X1=0,
    Y1=0,
    X2=0,
    Y2=0,
}

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    local room = BeckyMod.Game:GetRoom()
    local width = (room:GetGridWidth() /2 ) *40
    local height = (room:GetGridHeight() /2 ) *40
    local center = room:GetCenterPos()
    RoomBorder.X1 = center.X - width
    RoomBorder.Y1 = center.Y - height
    RoomBorder.X2 = center.X + width
    RoomBorder.Y2 = center.Y + height

end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    if eff.State == 0 then
        local pos = eff.Position
        local dis
        local targetPos
        for _, ent in ipairs( BeckyMod:FilterList(Isaac.GetRoomEntities(), TableFilter) ) do
            local entDis = ent.Position:Distance(pos)
            if (targetPos == nil or entDis < dis) then
                targetPos = ent.Position
                dis = entDis
            end
        end

        if targetPos ~= nil then
            if eff.TargetPosition == nil or eff.TargetPosition:Length() <= 0.001 then
                eff.TargetPosition = targetPos
            else
                eff.TargetPosition = BeckyMod:Lerp(eff.TargetPosition, targetPos, 0.035)
            end
            eff.SpriteRotation = (eff.TargetPosition - eff.Position):GetAngleDegrees()
        end
    elseif eff.State == 1 then
        local entRef = EntityRef(eff)
        local dmg = eff.CollisionDamage
        for _, ent in ipairs( Isaac.FindInRadius(eff.Position, eff.Size, EntityPartition.ENEMY) ) do
            if ent:ToNPC() ~= nil and ent:GetEntityFlags() & NONO_FLAGS == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() and ent:IsVulnerableEnemy() then
                ent:TakeDamage(dmg, 0, entRef, 0)
            end
        end
        eff.Velocity = eff.Velocity:Lerp(SPEAR_SPEED:Rotated(eff.SpriteRotation), 0.08) 
    end

    if eff.Timeout == 0 then
        eff.Timeout = -1
        eff.State = 1
    end
end, SPEAR_VAR)

local DummyRNG = RNG()
local function fun(player)
    local seed = Random()
    if seed == 0 then seed = 67 end
    DummyRNG:SetSeed(seed, 20)


    for i=1, DummyRNG:RandomInt(5, 7) do
        local side = DummyRNG:RandomInt(4)
        local spawnPos
        local angle = 0
        if side == 1 then
            spawnPos = Vector( DummyRNG:RandomInt(RoomBorder.X1, RoomBorder.X2), RoomBorder.Y1 )
            angle = 90
        elseif side == 2 then
            spawnPos = Vector( DummyRNG:RandomInt(RoomBorder.X1, RoomBorder.X2), RoomBorder.Y2 )
            angle = -90
        elseif side == 3 then
            spawnPos = Vector( RoomBorder.X1, DummyRNG:RandomInt(RoomBorder.Y1, RoomBorder.Y2) )
        else
            angle = 180
            spawnPos = Vector( RoomBorder.X2, DummyRNG:RandomInt(RoomBorder.Y1, RoomBorder.Y2) )
        end
        
        local spear = Isaac.Spawn(1000, SPEAR_VAR, 0, spawnPos, Vector.Zero, player):ToEffect()
        spear:SetTimeout(105)
        spear.SpriteRotation = angle
        BeckyMod.GetEntData(spear).NoGrantMana = true
    end
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.GILDED_SPEAR,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST,
    Frame = 99
}

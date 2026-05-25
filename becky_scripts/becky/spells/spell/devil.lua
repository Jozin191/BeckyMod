
----------------------------------------------
-- As far i tested, this freezes the game for what ever reason
----------------------------------------------
local SPELL_COST = 50
local laserVar = Isaac.GetEntityVariantByName("Spell Devil Laser")
local nullItem = Isaac.GetNullItemIdByName("SPELL_Devil")
BeckyMod.Spells.NULL_ITEMS.DEVIL = nullItem
BeckyMod.Spells.ENTITIES.DEVIL_LASER = { Type = 1000, Variant = laserVar }
local FireCooldown = -1
local ShootingAmount = 0
local SPEED = 3.17715
local SPEED_VECT = Vector(SPEED, 0)
local ONE_TILE = Vector(40, 0)
local NONO_FLAGS = (EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_ICE_FROZEN)

local function TableFilter(ent)
    if ent:ToNPC() ~= nil and ent:GetEntityFlags() & NONO_FLAGS == 0 and ent:CanShutDoors() and ent:IsActiveEnemy() then return true end
    return false
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if BeckyMod.Game:IsPaused() then return end
    if ShootingAmount <= 0 then
        FireCooldown = -1
        return
    end
    if FireCooldown == -1 then
        FireCooldown = 30 + 15 * (Random() % 4)
    elseif FireCooldown > 0 then
        FireCooldown = FireCooldown -1
        return
    end
    
    local room = BeckyMod.Game:GetRoom()
    
    local seed = Random()
    if seed == 0 then seed =1 end
    local spawnPos
    local findAPlayer = false
    local players = PlayerManager.GetPlayers()

    repeat
        findAPlayer = false
        spawnPos = room:GetGridPosition(room:GetRandomTileIndex(seed))
        for _, player in ipairs(players) do
            if player.Position:Distance(spawnPos) <= 100 then
                findAPlayer = true
                break
            end
        end
        seed = Random()
        if seed == 0 then seed =1 end
    until not findAPlayer


    local laser = Isaac.Spawn(1000, laserVar, 0, spawnPos, Vector.Zero, players[ (seed % #players) +1 ]):ToEffect()
    laser.CollisionDamage = 23
    laser:SetTimeout(150)
    laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    laser.GridCollisionClass =EntityGridCollisionClass.GRIDCOLL_WALLS

    FireCooldown = 90 + 15 * (Random() % 4)
    ShootingAmount = ShootingAmount -1
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    FireCooldown =-1
    ShootingAmount = 0
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_ROOM_ADD_EFFECT, function(_, itemConfig)
    if itemConfig:IsNull() and itemConfig.ID == nullItem then ShootingAmount = ShootingAmount + 7 end
end)


BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, eff)
    eff:GetSprite():Play("Start", true)
    eff.Velocity = eff:GetDropRNG():RandomVector() * SPEED
end, laserVar)

BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
    local sp = eff:GetSprite()

    if sp:IsFinished("End") then
        eff:Remove()
        return
    elseif sp:IsPlaying("End") then
        return
    elseif eff.Timeout == 0 then
        sp:Play("End", true)
        return
    elseif sp:IsFinished("Start") then
        sp:Play("Loop", true)
    end

    local player = eff.SpawnerEntity and eff.SpawnerEntity:ToPlayer()
    local tearParam
    local ref
    local dmg = 5

    if player then
        local mult = 3.25
        if player:GetPlayerType() == BeckyMod.Character.BECKY_B.PLAYERTYPE then mult = mult *3 end

        tearParam = player:GetTearHitParams(WeaponType.WEAPON_BRIMSTONE, mult, 1, player)
        sp.Color = tearParam.TearColor
        dmg = math.max(tearParam.TearDamage, 5)
        ref = EntityRef(player)
    else
        ref = EntityRef(eff)
    end

    local pos = eff.Position

    -- making this mess because some times the game freezes for what ever reason (it may be just a me thing tho)
    local entityList = BeckyMod:FilterList(Isaac.GetRoomEntities(), TableFilter)
    entityList = BeckyMod:AppendTable(entityList, PlayerManager.GetPlayers() )

    if eff.Target and not eff.Target:IsDead() and eff.Target:Exists() then
        local angle = (eff.Target.Position - pos):GetAngleDegrees()
        eff.Velocity = SPEED_VECT:Rotated( angle )
    else eff.Target = nil end


    if eff.FrameCount % 5 == 0 then
        local dis
        local target
        if eff.Target ~= nil then
            target = eff.Target
            if not target:IsDead() and target:Exists() then
                dis = target.Position:Distance(pos)
            else
                target = nil
                eff.Target = nil
            end
        end
        
        for _, ent in ipairs(entityList) do
            local entDis = ent.Position:Distance(pos)
            if entDis <= 100 and (target == nil or entDis < dis) then
                target = ent
                dis = entDis
            end
        end
        if target ~= nil then
            eff.Target = target
        end
    end


    if eff.Velocity:Length() < SPEED then
        local moveAngle = eff.Velocity:GetAngleDegrees()
        local room = BeckyMod.Game:GetRoom()
        
        local smallestAngle = 180
        for angle = -90, 90, 15 do
            if room:CheckLine(pos, ONE_TILE:Rotated(angle) +pos, 3, 4000, false, true) then
                local targetAngle = ((ONE_TILE:Rotated(angle) +pos) - pos):GetAngleDegrees() - moveAngle
                if math.abs(targetAngle) < math.abs(smallestAngle) then
                    smallestAngle = targetAngle
                end
            end
        end
        eff.Velocity = (eff.Velocity:Normalized() *SPEED):Rotated(smallestAngle)
    end

    local effSize = eff.Size
    for _, ent in ipairs(entityList) do
        if ent.Position:Distance(pos) - ent.Size > effSize then goto continued end
        if ent.Type == 1 then
            ent:TakeDamage(1, DamageFlag.DAMAGE_LASER, ref, 30)
        else
            local npc = ent:ToNPC()
            if npc and tearParam then
                npc:ApplyTearflagEffects(npc.Position, tearParam.TearFlags, player, dmg)
            end
            ent:TakeDamage(dmg, DamageFlag.DAMAGE_LASER, ref, 2)
        end
        ::continued::
    end

end, laserVar)



local function fun(player)
    local roomEffects = BeckyMod.Game:GetRoom():GetEffects()
    local effects = player:GetEffects()
    if effects:HasNullEffect(nullItem) then
        roomEffects:RemoveNullEffect(nullItem, 1)
    else
        roomEffects:AddNullEffect(nullItem)
    end
end

local function canSelectFun(player, manaLeft)
    return manaLeft >= SPELL_COST
end

return {
    BeckyMod.Spells.SpellType.DEVIL,
    Func = fun,
    CanSelect = canSelectFun,
    Cost = SPELL_COST
}
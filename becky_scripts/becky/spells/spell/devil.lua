local SPELL_COST = 50
local nullItem = Isaac.GetNullItemIdByName("SPELL_Devil")
BeckyMod.Spells.NULL_ITEMS.DEVIL = nullItem
local FireCooldown = -1
local ShootingAmount = 0
local LaserSubType = 100


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
    local spawnPos = room:GetGridPosition(room:GetRandomTileIndex(seed))
    
    local laser = Isaac.Spawn(1000, EffectVariant.HUSH_LASER, LaserSubType, room:FindFreeTilePosition(spawnPos, 40), Vector.Zero, Isaac.GetPlayer()):ToEffect()
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


BeckyMod:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, function(_, eff)
    if eff.SubType ~= LaserSubType then return end
    local sp = eff:GetSprite()

    if sp:IsPlaying("End") then return
    elseif eff.Timeout == 0 then
        sp:Play("End", true)
        eff:Die()
        return
    elseif sp:IsFinished("Start") then
        sp:Play("Loop", true)
    end

    local player = eff.SpawnerEntity and eff.SpawnerEntity:ToPlayer()
    local tearParam
    local ref

    if player then
        tearParam = player:GetTearHitParams(WeaponType.WEAPON_BRIMSTONE, 3.25, 1, player)
        sp.Color = tearParam.TearColor
        ref = EntityRef(player)
    else
        ref = EntityRef(eff)
    end

    for _, ent in ipairs(Isaac.FindInRadius(eff.Position, eff.Size, EntityPartition.PLAYER | EntityPartition.ENEMY)) do
        if ent.Type == 1 then
            ent:TakeDamage(1, DamageFlag.DAMAGE_LASER, ref, 30)
        else
            local npc = ent:ToNPC()
            if npc and tearParam then
                npc:ApplyTearflagEffects(npc.Position, tearParam.TearFlags, player, math.max(tearParam.TearDamage, 5))
            else
                ent:TakeDamage(5, DamageFlag.DAMAGE_LASER, ref, 0)
            end
        end
    end

    return false
end, EffectVariant.HUSH_LASER)



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
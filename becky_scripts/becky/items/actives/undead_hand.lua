local UNDEAD_HAND = {}

BeckyMod.Item.UNDEAD_HAND = UNDEAD_HAND
UNDEAD_HAND.ID = Isaac.GetItemIdByName("Undead Hand")
UNDEAD_HAND.NULL_ITEM_ID = Isaac.GetNullItemIdByName("Undead Hand_Zombie Counter")
UNDEAD_HAND.FAMILIAR = Isaac.GetEntityVariantByName("Becky Zombie")
UNDEAD_HAND.SPEED_MULT = 0.85
UNDEAD_HAND.DEAD_COOLDOWN = 300
UNDEAD_HAND.SPAWN_UNDEAD_CHANCE = 6

local game = BeckyMod.Game
local spawnPos

local State = {
    SPAWNING = 0,
    ATTACKING = 1,
    DEAD = 2,
    REVIVING = 3,
}


local function GetBodyAnim(moveVec)
    local angle = moveVec:GetAngleDegrees()

    if (angle > 50 and angle < 130) or (angle < -50 and angle > -130) then
        return "WalkVert", false
    end
    return "WalkHori", (angle > 130 or angle < -130)
end


function UNDEAD_HAND:FamiliarInit(fam)
    fam:GetSprite():Play("Spawning", true)
    fam.State = State.SPAWNING
    fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
end

function UNDEAD_HAND:FamiliarUpdate(fam)

    local sprite = fam:GetSprite()
    sprite:SetOverlayRenderPriority(false)
    local state = fam.State

    if state == State.SPAWNING or state == State.REVIVING then
        if sprite:IsFinished() then
            sprite:SetFrame("WalkVert", 0)
            if state == State.SPAWNING then
                sprite:PlayOverlay("Head", true)
                local room = game:GetRoom()
                if room:GetGridEntityFromPos(fam.Position) ~= nil then
                    fam.Position = room:FindFreeTilePosition(fam.Position, 40)
                end
            else
                sprite:SetOverlayFrame("Head", 19)
            end

            fam.State = State.ATTACKING
            fam.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
        elseif state == State.SPAWNING then
            if sprite:IsEventTriggered("sound") then
                BeckyMod.SFX:Play(SoundEffect.SOUND_MAGGOT_BURST_OUT, 0.75, 1, false, 0.85)
            end
        end
    elseif state == State.ATTACKING then
        if fam.FrameCount % 180 == 0 and fam:GetDropRNG():RandomInt(2) == 0 then
            BeckyMod.SFX:Play(SoundEffect.SOUND_MONSTER_ROAR_1, 0.75, 5, false, 0.75)
        end

        local anim, xflip = GetBodyAnim(fam.Velocity)
        if anim ~= sprite:GetAnimation() then sprite:SetAnimation(anim, false) end
        if fam.FlipX ~= xflip then fam.FlipX = xflip end
        local target = fam.Target
        if Isaac.CountEnemies() == 0 then
            target = fam.Player
        end

        local pathfinder = fam:GetPathfinder()
        if target then
            if not sprite:IsPlaying(anim) then sprite:Play(anim, true) end
            local targetPos = target.Position
            if pathfinder:HasPathToPos(targetPos, false) then
                pathfinder:FindGridPath(targetPos, UNDEAD_HAND.SPEED_MULT, 0, true)
                if targetPos:Distance(fam.Position) < 4 then
                    sprite.PlaybackSpeed = 0
                else
                    sprite.PlaybackSpeed = UNDEAD_HAND.SPEED_MULT
                end
                return
            end
        end
        if Isaac.CountEnemies() == 0 then return end

        local famPos = fam.Position
        local prevDis
        local target
        for _, ent in ipairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 50000, EntityPartition.ENEMY)) do
            local entPos = ent.Position
            if ent:CanShutDoors() and pathfinder:HasPathToPos(entPos, false) and (target == nil or entPos:Distance(famPos) < prevDis) then
                prevDis = entPos:Distance(famPos)
                target = ent
            end
        end
        fam.Target = target
    elseif state == State.DEAD then
        fam.Velocity = Vector.Zero

        if sprite:IsFinished() then
            sprite:Play("Down", true)
        end
        if fam.FireCooldown > 0 then
            fam.FireCooldown = fam.FireCooldown -1
        else
            fam.HitPoints = fam.MaxHitPoints
            sprite:Play("Revive", true)
            fam.State = State.REVIVING
        end
    end
end


function UNDEAD_HAND:PostKillEntity(ent, killerRef)
    local killer = killerRef.Entity
    if killer and killer.Type == 3 and killer.Variant == UNDEAD_HAND.FAMILIAR then
        local player = killer:ToFamiliar().Player
        if player and killer:GetDropRNG():RandomInt(UNDEAD_HAND.SPAWN_UNDEAD_CHANCE) == 0 then
            spawnPos = ent.Position
            player:AddCollectibleEffect(UNDEAD_HAND.ID, false, nil, false)
            --player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
        end
    end
end


function UNDEAD_HAND:TakeDamage(ent, dmg)
    if ent.Type ~= 3 or ent.Variant ~= UNDEAD_HAND.FAMILIAR then return end
    if ent.SubType == 120 then return end
    
    if ent.HitPoints - dmg <= 0 then
        ent.HitPoints = ent.HitPoints + dmg + 999999
        local sprite = ent:GetSprite()
        sprite.PlaybackSpeed = 1
        sprite:RemoveOverlay()
        sprite:Play("Killed", true)

        ent.Target = nil
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        local fam = ent:ToFamiliar()
        fam.State = State.DEAD
        fam.FireCooldown = UNDEAD_HAND.DEAD_COOLDOWN
    end
end


function UNDEAD_HAND:CacheFams(player, cacheFlags)
    local num = player:GetEffects():GetNullEffectNum(UNDEAD_HAND.NULL_ITEM_ID)
    local rng = player:GetCollectibleRNG(UNDEAD_HAND.ID)

    player:CheckFamiliar(UNDEAD_HAND.FAMILIAR, num, rng, nil)
end

function UNDEAD_HAND:UseItem(itemID, rng, player, useFlags, slot)
    if Isaac.CountEnemies() == 0 then return { Discharge = false, ShowAnim = false } end
    --player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
    player:AddNullItemEffect(UNDEAD_HAND.NULL_ITEM_ID)
    
    return useFlags & UseFlag.USE_NOANIM == 0
end

BeckyMod:AddCallback(ModCallbacks.MC_USE_ITEM, UNDEAD_HAND.UseItem, UNDEAD_HAND.ID)
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, UNDEAD_HAND.CacheFams, CacheFlag.CACHE_FAMILIARS)
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, UNDEAD_HAND.FamiliarInit, UNDEAD_HAND.FAMILIAR)
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, UNDEAD_HAND.FamiliarUpdate, UNDEAD_HAND.FAMILIAR)
BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, UNDEAD_HAND.PostKillEntity)
BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, UNDEAD_HAND.TakeDamage)
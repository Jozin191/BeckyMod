local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")
local LittleGhost = Isaac.GetEntityVariantByName("Lachgraphagy Ghost (Ghost Ball Synergy)")
---@param ghost EntityEffect
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, ghost)
    local sprite = ghost:GetSprite()
    if ghost.FrameCount == 1 then
        ghost.State = 0
        sprite:Play("Appear")
    elseif ghost.FrameCount >= 70 then
        ghost.State = 2
        if sprite:IsFinished("Death") then
            ghost:Remove()
            return
        else
            sprite:Play("Death")
        end
    elseif sprite:IsFinished("Appear") then
        ghost.State = 1
    end
    if ghost.State == 1 then
        sprite:Play("Idle")
    end

    if ghost.FrameCount >= 15 and ghost.FrameCount <= 85 then 
        local function check() --- probably a better way to check if the ghost is touching the main one
            local foes = Isaac.FindInRadius(ghost.Position, 15, EntityPartition.FAMILIAR)
            for i, v in ipairs(foes) do
                if v.Variant == GHOST_BALL_VAR then
                    return v:ToFamiliar()
                end
            end
            return false
        end
        local familiar = check()
        if familiar then
            local player = familiar.Player
            local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LACHRYPHAGY)
            local amount, rotation = rng:RandomInt(2,5), rng:RandomFloat()*90
            familiar:GetSprite():Play("Hit",true)
            for i = 0, amount-1 do
                local tear = familiar.Player:FireTear(ghost.Position, Vector(1,0):Rotated((i*(360/(amount)))+rotation)*player.ShotSpeed*7, false, true, false, familiar, .75)
                tear.Scale=tear.Scale*.8
                tear:ClearTearFlags(TearFlags.TEAR_ABSORB)
                if tear.Variant == TearVariant.HUNGRY then
                    tear:ChangeVariant(TearVariant.BLUE)
                end
                BeckyMod.TryChangeTearToBloodVariant(tear)
            end
            ghost:Remove()
        end
    end
    ghost.Velocity = ghost.Velocity*.93
end, LittleGhost)

---@param fam EntityFamiliar
---@param enemy EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams, position)
    local player = fam.Player
    if not (tearParams.TearFlags & TearFlags.TEAR_ABSORB == TearFlags.TEAR_ABSORB) then return end
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LACHRYPHAGY)
    local baby = Isaac.Spawn(EntityType.ENTITY_EFFECT, LittleGhost, 0, position, rng:RandomVector()*(2+(player.ShotSpeed/2))*(rng:RandomInt(230, 450)/100), fam)
    if rng:RandomFloat() >= .5 then baby.FlipX = true end
end)
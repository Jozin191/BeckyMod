---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams, position)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then return end

    local ghostData = BeckyMod.GetEntData(fam)

    ghostData.BrimHits = ghostData.BrimHits or 3

    ghostData.BrimHits = ghostData.BrimHits - 1

    if ghostData.BrimHits == 0 then
        SFXManager():Play(SoundEffect.SOUND_BLOOD_LASER, .67)
        local bale = player:FireBrimstoneBall(position, RandomVector()*5)
        ghostData.BrimHits = 3
    end
end)

---@param ball EntityEffect
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, ball)
    local function yea(drop)
        drop.LifeSpan = 30
        drop.Color = ball.Color
        drop.m_Height = 5
        drop.State = 2
    end
    if ball.FrameCount % 3 == 0 then
        local hi =ball.Position+(RandomVector()*ball.SpriteScale:Length()*40)
        local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 2, hi, (hi-ball.Position):Normalized()*math.random(3,12), ball):ToEffect()
        yea(drop)
    end
    if ball.FrameCount % 2 == 0 then
        local hi =ball.Position+(RandomVector()*ball.SpriteScale:Length()*math.random(0,25))
        local drop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_DROP, 2, hi, (hi-ball.Position):Normalized()*math.random(3,12), ball):ToEffect()
        yea(drop)
    end
end, EffectVariant.BRIMSTONE_BALL)
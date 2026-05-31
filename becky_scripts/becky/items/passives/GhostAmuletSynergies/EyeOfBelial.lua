---@param fam EntityFamiliar
---@param enemy Entity
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams)
    local player = fam.Player 
    local ghostData = fam:GetData()
    if not (tearParams.TearFlags & TearFlags.TEAR_BELIAL == TearFlags.TEAR_BELIAL) then return end
    local redGhostRef = ghostData.RedGhost and ghostData.RedGhost.Ref 
    local exists = redGhostRef and redGhostRef:Exists()
    if not exists then 
        local ghost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HUNGRY_SOUL, 0, fam.Position, Vector.Zero, player):ToEffect()
        local sprite = ghost:GetSprite()
        sprite.PlaybackSpeed = 2
        sprite:SetFrame(10)
        ghost:SetTimeout(50)
        ghost.Velocity = ((enemy.Position-fam.Position):Normalized()*40)
        ghost.Target = enemy
        ghost.DepthOffset = 7
        ghostData.RedGhost = EntityPtr(ghost)
        SFXManager():Play(SoundEffect.SOUND_FLOATY_BABY_ROAR, .6, 0, false, 2)
        BeckyMod.SFX:Play(SoundEffect.SOUND_SUMMON_POOF, 1, 0, false, 1.3)
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, fam.Position, Vector.Zero, player)
        poof.Color = Color(.5,0,0, .8)
        poof.DepthOffset = 3
    end
end)

---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam, tearParams)
    local player = fam.Player 
    local ghostData = fam:GetData()

    local redGhostRef = ghostData.RedGhost and ghostData.RedGhost.Ref 
    local exists = redGhostRef and redGhostRef:Exists()
    if exists and redGhostRef.FrameCount >= 60 then
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 1, redGhostRef.Position, Vector.Zero, player)
        poof.Color = Color(.8,0,0,1.3)
        poof:GetSprite():SetFrame(2)
        redGhostRef:Remove()
    elseif exists and redGhostRef.Target then 
        redGhostRef.Velocity = redGhostRef.Velocity*.9 + (redGhostRef.Target.Position-redGhostRef.Position):Normalized()*1.5
    end

    if (not exists) and (tearParams.TearFlags & TearFlags.TEAR_BELIAL == TearFlags.TEAR_BELIAL) then
        fam:SetColor(Color(.7+math.sin(fam.FrameCount*.15)*.2,0,0), 2, 70, false, false)
    end
end)
---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function (_, fam)
    local player = fam.Player
    local data = BeckyMod.GetEntData(fam)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_KIDNEY_STONE) then return end
    local urethracharge = data.URETHRACHARGE or 0
    local urethradir = data.URETHRADIR or 0
    local nexttear = data.URETHRATEAR or 0
    local blasting = data.URETHRABLAST or false
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NEPTUNUS)

    if not blasting then
        urethracharge = math.min(urethracharge+(1/(30*25)), 1) -- 25 secs I think
        if urethracharge >= 1 then
            fam:SetColor(Color(1,.55+(.15*math.cos(fam.FrameCount)),.55+(.15*math.cos(fam.FrameCount)),1,0,0,0), 2, 50, false, false)
            fam.Velocity = fam.Velocity*.9
        end
    else
        urethracharge = math.max((urethracharge*.99)-.0013, 0)
        fam.Velocity = fam.Velocity-(Vector.FromAngle(urethradir)*(urethracharge*3))
        nexttear = nexttear+(urethracharge*1.5)
        urethradir=urethradir+(((rng:RandomFloat()*8)*((urethracharge*1.2)-.2))-2)
        if nexttear >= 1 then
            
            for i = 1, math.floor(nexttear) do
                local tear = player:FireTear(fam.Position, (Vector.FromAngle(urethradir)*(7+3*urethracharge))-(fam.Velocity*.4)*(rng:RandomFloat()*.5+.5), false, false, false, fam, 1.33)
                tear.Velocity = tear.Velocity:Rotated((rng:RandomFloat()*70)-35)
                tear.FallingAcceleration = rng:RandomFloat()*.3+.1
                tear.Height = -7+fam.PositionOffset.Y
                tear.FallingSpeed = -3
            end
            nexttear = 0
        end
        if urethracharge <= 0 then
            blasting = false
        end
        if urethracharge >= .3 then
            fam.State = 1
        end
    end
    data.URETHRADIR = urethradir
    data.URETHRATEAR = nexttear
    data.URETHRABLAST = blasting
    data.URETHRACHARGE = urethracharge
end)

---@param fam EntityFamiliar
---@param npc EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, fam, npc,tearParams)
    local player = fam.Player
    local data = BeckyMod.GetEntData(fam)
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_KIDNEY_STONE) then return end
    local blasting = data.URETHRABLAST or false
    local urethracharge = data.URETHRACHARGE or 0
    local urethradir = data.URETHRADIR or 0
    if urethracharge >= 1 and not blasting then
        local ukiddin = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.STONE, 0, fam.Position, (npc.Position-fam.Position):Normalized()*20, fam):ToTear()
        ukiddin:SetInitSound(SoundEffect.SOUND_STONE_IMPACT)
        SFXManager():Play(SoundEffect.SOUND_BLOODSHOOT)
        ukiddin:AddTearFlags(TearFlags.TEAR_EXTRA_GORE | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
        ukiddin.FallingAcceleration = 0
        ukiddin.Scale = 1.2
        ukiddin.CollisionDamage = tearParams.TearDamage*10
        urethradir = (npc.Position-fam.Position):GetAngleDegrees()
        blasting = true
        npc:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
        Game():ShakeScreen(2)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, fam.Position, Vector.Zero, fam)
    end
    data.URETHRADIR = urethradir
    data.URETHRACHARGE = urethracharge
    data.URETHRABLAST = blasting
end)
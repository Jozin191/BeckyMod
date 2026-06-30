local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")
--local Callbacks = BeckyMod.Enums.Callbacks

---@param fam EntityFamiliar
---@param enemy EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams)
    local player = fam.Player
    local ghostData = BeckyMod.GetEntData(fam)

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then return end
    if ghostData.Sword then return end

    -- 99% sure these two are make up the sword spin
    local pitch = 1
    if fam.SpriteScale:Length() > 2 then
        pitch = .6
    end
    SFXManager():Play(SoundEffect.SOUND_SWORD_SPIN, .7, 2, false, pitch)
    SFXManager():Play(SoundEffect.SOUND_SWORD_SPIN, .7, 2, false, pitch)

    ghostData.Sword = player:FireKnife(
        fam,
        90,
        true,
        0,
        KnifeVariant.SPIRIT_SWORD
    )

    local knife = ghostData.Sword
    local knifeData = BeckyMod.GetEntData(knife)
    local knifeSprite = knife:GetSprite()

    knifeSprite:Play("SpinDown", true)
    knife.Visible = false
    knife.TearFlags = tearParams.TearFlags
    knife.Color = tearParams.TearColor
    knife.SpriteScale = fam.SpriteScale
    
    local effect = Isaac.Spawn(
        EntityType.ENTITY_EFFECT,
        EffectVariant.POOF01,
        0,
        fam.Position,
        Vector.Zero,
        nil
    ):ToEffect() ---@cast effect EntityEffect

    effect:FollowParent(fam)
    local effectSprite = effect:GetSprite()
    effectSprite:Load("gfx/008.010_spirit sword.anm2", true)
    effectSprite:Play("SpinDown")
    effectSprite.Scale = fam.SpriteScale

    local baseDamage = ((tearParams.TearDamage * 8) + 10)
    local formula = baseDamage * 0.5

    knifeData.GhostSword = true
    knife.CollisionDamage = formula
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
    local knifeSprite = knife:GetSprite()
    local knifeData = BeckyMod.GetEntData(knife)
	
    if knife.Variant ~= KnifeVariant.SPIRIT_SWORD or not knifeData.GhostSword then return end
    if not (knifeSprite:GetAnimation() == "SpinDown" and knifeSprite:IsFinished()) then return end

    knife:Remove()
	
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, GHOST_BALL_VAR)) do
        local ghostData = BeckyMod.GetEntData(fam)
        ghostData.Sword = nil
    end
end)
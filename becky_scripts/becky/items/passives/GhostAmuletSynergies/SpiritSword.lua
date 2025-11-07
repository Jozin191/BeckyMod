local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")
--local Callbacks = BeckyMod.Enums.Callbacks

---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player
    local ghostData = fam:GetData()

    if not player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_SWORD) then return end
    if ghostData.Sword then return end

    ghostData.Sword = player:FireKnife(
        fam,
        90,
        true,
        0,
        KnifeVariant.SPIRIT_SWORD
    )

    local knife = ghostData.Sword
    local knifeData = knife:GetData()
    local knifeSprite = knife:GetSprite()

    knifeSprite:Play("SpinDown", true)
    knife.Visible = false

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
    
    local baseDamage = ((player.Damage * 8) + 10)
    local formula = baseDamage * 0.5

    knifeData.GhostSword = true
    knife.CollisionDamage = formula
end)

BeckyMod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife)
    local knifeSprite = knife:GetSprite()
    local knifeData = knife:GetData()
	
    if knife.Variant ~= KnifeVariant.SPIRIT_SWORD or not knifeData.GhostSword then return end
    if not (knifeSprite:GetAnimation() == "SpinDown" and knifeSprite:IsFinished()) then return end

    knife:Remove()
	
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, GHOST_BALL_VAR)) do
        local ghostData = fam:GetData()
        ghostData.Sword = nil
    end
end)
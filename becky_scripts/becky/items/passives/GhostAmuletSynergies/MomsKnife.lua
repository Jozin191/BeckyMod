local mod = BeckyMod
local enums = mod.Enums
local variants = enums.Variants

---@param fam EntityFamiliar
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    -- local ghostData = fam:GetData()

    -- local player = fam.Player
    
    -- -- if ghostData.Knife then return end

    -- ghostData.Knife = player:FireKnife(
    --     player,
    --     90,
    --     true,
    --     0,
    --     KnifeVariant.MOMS_KNIFE
    -- )

    -- local knife = ghostData.Knife
    -- local knifeData = knife:GetData()
    -- local knifeSprite = knife:GetSprite()

    -- knife:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    -- knife.Position = fam.Position

    -- local effect = Isaac.Spawn(
    --     EntityType.ENTITY_EFFECT,
    --     EffectVariant.POOF01,
    --     0,
    --     player.Position,
    --     Vector.Zero,
    --     nil
    -- ):ToEffect() ---@cast effect EntityEffect

    -- knifeSprite:Play("SpinDown", true)
    -- knife.Visible = false

    -- local effect = Isaac.Spawn(
    --     EntityType.ENTITY_EFFECT,
    --     EffectVariant.POOF01,
    --     0,
    --     player.Position,
    --     Vector.Zero,
    --     nil
    -- ):ToEffect() ---@cast effect EntityEffect

    -- effect:FollowParent(player)
    -- local effectSprite = effect:GetSprite()
    -- effectSprite:Load("gfx/008.010_spirit sword.anm2", true)
    -- effectSprite:Play("SpinDown")
    
    -- local damageMult = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 0.75 or 0.5
    -- local baseDamage = ((player.Damage * 8) + 10)
    -- local formula = baseDamage * damageMult

    -- knife.SpriteScale = knife.SpriteScale * 1.7
    -- knifeData.StompSword = true
    -- knife.CollisionDamage = formula

    -- if not fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_GODHEAD) then return end
    -- if ghostData.GodHeadAura then return end

    -- ghostData.GodHeadAura = enums.Utils.Game:Spawn(EntityType.ENTITY_TEAR, 0, fam.Position, Vector.Zero, fam, 0, math.max(Random(), 1)):ToTear() 
    
    -- local tear = ghostData.GodHeadAura ---@cast tear EntityTear

    -- tear:AddTearFlags(TearFlags.TEAR_GLOW | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
    -- tear:GetData().GhostBallTear = true
    -- tear.Color = Color(1, 1, 1, 0)
end, variants.GHOST_BALL)

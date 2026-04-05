---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_EPIC_FETUS) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EPIC_FETUS)
    if rng:RandomFloat()+player.Luck/20 < 0.85 then return end
    local rocket = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMALL_ROCKET, 0, player.Position, Vector.Zero, player):ToEffect()
   
    local lobangle = math.rad(45)
    rocket.State = 1
    local dist = (fam.Position-player.Position)
    rocket.Velocity = (dist)*math.cos(lobangle)*(1/8)
    rocket:Update()
    rocket.CollisionDamage = 0

    rocket.m_Height = 0
    SFXManager():Play(SoundEffect.SOUND_FETUS_FEET)
end)

---@param eff EntityEffect
BeckyMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, eff)
end, EffectVariant.SMALL_ROCKET)
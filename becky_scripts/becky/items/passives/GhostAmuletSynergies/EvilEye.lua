---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function (_, fam)
    local player = fam.Player
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_EVIL_EYE) then return end
    if fam.FrameCount % 10 == 0 then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EVIL_EYE)
        local formula = math.min(1/(30-math.min(player.Luck, 30)),.1) -- 3.33% maxes out 10% at 20 luck
        if rng:RandomFloat() < (1-formula) then return end
        if fam.State > 0 then
            BeckyMod.SFX:Play(SoundEffect.SOUND_TEARS_FIRE)
            local eye = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EVIL_EYE, 0, fam.Position, rng:RandomVector()*3, player)
            eye.Parent = player
        end
    end
end)
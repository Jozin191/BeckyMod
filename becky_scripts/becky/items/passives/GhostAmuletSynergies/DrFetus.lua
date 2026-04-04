---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_DR_FETUS)

    if rng:RandomFloat() > 0.15 then return end

    local bomb = player:FireBomb(fam.Position, Vector.Zero, player)
    SFXManager():Play(SoundEffect.SOUND_FETUS_FEET)
end)
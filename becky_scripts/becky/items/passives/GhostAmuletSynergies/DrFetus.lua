---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams, position)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then return end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_DR_FETUS)

    if rng:RandomFloat()+player.Luck/20 < 0.75 then return end

    local bomb = player:FireBomb(position, Vector.Zero, player)
    SFXManager():Play(SoundEffect.SOUND_FETUS_FEET)
end)
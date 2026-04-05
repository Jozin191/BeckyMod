---@param fam EntityFamiliar
---@param enemy EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy)
    local player = fam.Player

    if not player then return end
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then return end

    local ghostData = fam:GetData()

    ghostData.BrimHits = ghostData.BrimHits or 3

    ghostData.BrimHits = ghostData.BrimHits - 1

    if ghostData.BrimHits == 0 then
        SFXManager():Play(SoundEffect.SOUND_BLOOD_LASER, .67)
        local bale = player:FireBrimstoneBall(fam.Position, RandomVector()*5)
        ghostData.BrimHits = 3
    end
end)
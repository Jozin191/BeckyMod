---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function (_, fam)
    local player = fam.Player
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_SORE) then return end
    print(player.MaxFireDelay)
    if fam.FrameCount % math.max(math.floor(player.MaxFireDelay)+2, 0) == 0 then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EYE_SORE)
        if rng:RandomFloat() > .5 then return end
        if player:GetAimDirection():Length() > .1 then
            for i = 1, rng:RandomInt(1, 3) do
                player:FireTear(fam.Position, -rng:RandomVector() * (player.ShotSpeed * 10))
            end
        end
    end
end)
---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function(_, fam)
    local player = fam.Player
    local ghostdata = fam:GetData()
    if player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS) then
        if fam.State > 0 then
            local fakeVelo = (fam.Position - ghostdata.LASTPOS) -- do this to patch the wall bug
            if fakeVelo:Length() > 1 then
                ghostdata.NEPCD = (ghostdata.NEPCD or 0)+((fakeVelo:Length()/22))
                if ghostdata.NEPCD >= 1 then
                    for i = 1, math.min(math.floor(ghostdata.NEPCD), 6) do
                        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NEPTUNUS)
                        local tear = player:FireTear(fam.Position,
                            (-fam.Velocity:Normalized() * 5) - (fam.Velocity * .3) * (rng:RandomFloat() * .5 + .5), false,
                            false, false, fam)
                        tear.Velocity = tear.Velocity:Rotated((rng:RandomFloat() * 70) - 35)
                        tear.FallingAcceleration = rng:RandomFloat() + .5
                        tear.Height = -7 + fam.PositionOffset.Y
                        tear.FallingSpeed = -5
                    end
                    ghostdata.NEPCD = 0
                end
            end
        end
    end
    ghostdata.LASTPOS = fam.Position
end)

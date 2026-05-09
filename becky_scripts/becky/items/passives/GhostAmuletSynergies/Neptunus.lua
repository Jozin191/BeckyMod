---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function (_, fam)
    local player = fam.Player
    local ghostdata = fam:GetData()
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS) then return end
    if player:GetAimDirection():Length() < .1 then return end
    if fam.Velocity:Length() < 20 then return end
    ghostdata.NEPCD = (ghostdata.NEPCD or 0)+((fam.Velocity:Length()/25))
        if ghostdata.NEPCD >= 1 then
            for i = 1, math.min(math.floor(ghostdata.NEPCD),6) do
                print(i)
                local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NEPTUNUS)
                SFXManager():Play(SoundEffect.SOUND_TEARS_FIRE)
                local tear = player:FireTear(fam.Position, (-fam.Velocity:Normalized()*5)-(fam.Velocity*.3)*(rng:RandomFloat()*.5+.5), false, false, false, fam, .5)
                tear.Velocity = tear.Velocity:Rotated((rng:RandomFloat()*70)-35)
                tear.FallingAcceleration = rng:RandomFloat()+.5
                tear.Height = -7+fam.PositionOffset.Y
                tear.FallingSpeed = -5
            end
            ghostdata.NEPCD = 0
        end
end)
local synergyCallbacks = include("becky_scripts.becky.characters.ghost.becky_ghost_callbacks")

BeckyMod:AddCallback(synergyCallbacks.BECKY_GHOST_UPDATE, function(_, familiar, familiarData)
    local player = familiar.Player
    if player then
        -- Tractor Beam Synergy
        if player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
            local tractorBeamAngle = Vector.FromAngle(player:GetTractorBeam():ToLaser().Angle)
            local tractorBeamDistance = (player.Position - familiar.Position):Length()
            local tractorAlongPosition = player.Position + (tractorBeamDistance * tractorBeamAngle)
            familiar.Velocity = familiar.Velocity + (tractorAlongPosition - familiar.Position)
            familiarData.fireDirection = tractorBeamAngle
        end
    end
end)
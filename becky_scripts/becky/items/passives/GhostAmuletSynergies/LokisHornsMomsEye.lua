---@param fam EntityFamiliar
---@param npc EntityNPC
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, fam, npc)
    local player = fam.Player
    local horns, eye = player:HasCollectible(CollectibleType.COLLECTIBLE_LOKIS_HORNS), player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_EYE)
   
    if not (horns or eye) then return end
    local formula = .25+(player.Luck*.05) -- 25% maxes out 100% at 15 luck
    if eye then
        formula = .5+(player.Luck*.1) -- 50% maxes out 100% at 5 luck
    end

    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_MOMS_EYE)
    if rng:RandomFloat() < 1-formula then return end
    if not horns then
        player:FireTear(fam.Position, -player:GetAimDirection() * (player.ShotSpeed * 10))
    else
        for i = 1, 4 do
            player:FireTear(fam.Position, Vector(1, 0):Rotated((i/4)*360) * (player.ShotSpeed * 10))
        end
    end

end)
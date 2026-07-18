---@param fam EntityFamiliar
---@param enemy EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function(_, fam, enemy, tearParams, position, copy)
    local player = fam.Player
    if copy then return end
    if not player then return end

    if tearParams.TearFlags & TearFlags.TEAR_SPLIT == TearFlags.TEAR_SPLIT then
        local rot = (enemy.Position-position):GetAngleDegrees()+90
        for i = 1, 2 do
            local tear = player:FireTear(position, Vector(1, 0):Rotated((i/2)*360+rot)*player.ShotSpeed * 10, false, true, false, fam)
            tear.CollisionDamage = tear.CollisionDamage*.5
            tear.TearFlags = tearParams.TearFlags &~ TearFlags.TEAR_QUADSPLIT  &~TearFlags.TEAR_BURSTSPLIT &~TearFlags.TEAR_BONE
            tear.Scale = tearParams.TearScale*.6
            tear.FallingAcceleration = tear.FallingAcceleration+.3
            tear.Color = tearParams.TearColor
            if tear.Variant ~= tearParams.TearVariant then
                tear:ChangeVariant(tearParams.TearVariant)
            end
        end
    end
    if tearParams.TearFlags & TearFlags.TEAR_QUADSPLIT == TearFlags.TEAR_QUADSPLIT then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CRICKETS_BODY)
        local rot = (rng:RandomInt(0,900)/10)
        for i = 1, 4 do
            local tear = player:FireTear(position, Vector(1, 0):Rotated((i/4)*360+rot)*player.ShotSpeed * 10, false, true, false, fam)
            tear.CollisionDamage = tear.CollisionDamage*.3
            tear.Scale = tearParams.TearScale*.6
            tear.TearFlags = tearParams.TearFlags &~ TearFlags.TEAR_QUADSPLIT  &~TearFlags.TEAR_BURSTSPLIT &~TearFlags.TEAR_BONE
            tear.FallingAcceleration = tear.FallingAcceleration+.3
            tear.Color = tearParams.TearColor
            if tear.Variant ~= tearParams.TearVariant then
                tear:ChangeVariant(tearParams.TearVariant)
            end
        end
    end
    if tearParams.TearFlags & TearFlags.TEAR_BONE == TearFlags.TEAR_BONE then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE)
        for i = 1, rng:RandomInt(1,3) do
            local tear = player:FireTear(position, RandomVector()*player.ShotSpeed * 10, false, true, false, fam)
            tear.CollisionDamage = tear.CollisionDamage*.3
            tear.Scale = 1
            tear.TearFlags = tearParams.TearFlags &~ TearFlags.TEAR_BONE  &~TearFlags.TEAR_BURSTSPLIT
            tear.Color = tearParams.TearColor
            if tear.Variant ~= TearVariant.BONE then
                tear:ChangeVariant(TearVariant.BONE)
            end
            tear:GetSprite():ReplaceSpritesheet(0, "gfx/tears_brokenbone.png", true)
        end
    end
end)
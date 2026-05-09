---@param fam EntityFamiliar
---@param npc EntityNPC
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.ON_GHOST_HIT_ENEMY, function (_, fam, npc, tearParams)
    local player = fam.Player
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_LARGE_ZIT) then return end
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_LARGE_ZIT)
    if rng:RandomFloat() > .1 then return end

    local zit = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, fam.Position, rng:RandomVector()*10*player.ShotSpeed, fam):ToTear()
    if zit then
        zit.Scale = .5
        zit.Color = Color(.3,.3,.3, 1, .7, .7 ,.7)
        zit:AddTearFlags(TearFlags.TEAR_SLOW)
        zit.CollisionDamage = tearParams.TearDamage*2
        for i = 1, rng:RandomInt(1, 3) do
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_WHITE, 0, fam.Position+zit.Velocity*(i*2), Vector.Zero, player):ToEffect() ---@cast creep EntityEffect
            creep.Timeout = 120
            creep:Update()
        end
    end
end)
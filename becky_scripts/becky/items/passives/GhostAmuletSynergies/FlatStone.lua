local function toTearsPerSecond(maxFireDelay)
  return 30 / (maxFireDelay + 1)
end

local function getBounce(player)
    return math.min(toTearsPerSecond(player.MaxFireDelay)*.5, 10)
end
---@param fam EntityFamiliar
---@param tearParams TearParams
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, function (_, fam, tearParams)
    local player = fam.Player
    if not player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then return end
    local data = fam:GetData()
    data.GTVeloH = data.GTVeloH or 0
    data.GTH = data.GTH or 0
    local bounce = getBounce(player)
    if data.GTH < 0 then
        data.GTH = 0
        data.GTVeloH = bounce*3
        local splash = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIPPLE_POOF, 0,  fam.Position, Vector.Zero, fam):ToEffect()
        splash.SpriteScale = fam.SpriteScale
        splash.Color = tearParams.TearColor
        SFXManager():Play(SoundEffect.SOUND_TEARIMPACTS, .3, 0, false, 1.2)
        local enemies = Isaac.FindInRadius(fam.Position, fam.Size*2.5, EntityPartition.ENEMY)
        for i, v in pairs(enemies) do
            local npc = v:ToNPC()
            if npc then
                npc:ApplyTearflagEffects(fam.Position, tearParams.TearFlags, fam, tearParams.TearDamage*.25)
                npc:TakeDamage(tearParams.TearDamage*.25, 0, EntityRef(fam), 0)
                npc:AddVelocity((npc.Position-fam.Position):Normalized())
            end
        end
    end
end)


-- its smooth ok );
---@param fam EntityFamiliar
BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_RENDER_HELPER, function (_, fam)
    if Game():IsPaused() then return end
    local player = fam.Player
    local data = fam:GetData()
    data.GTVeloH = data.GTVeloH or 0
    data.GTH = data.GTH or 0
    if player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then
        local bounce = getBounce(player)
        local gravity = (bounce^2)*.1
        data.GTVeloH = math.min(data.GTVeloH - gravity, 1000)
        data.GTH = math.min(data.GTH + data.GTVeloH, 5000)
    else
        data.GTH = 0
        data.GTVeloH = 0
    end


    fam.PositionOffset = Vector(0, math.min(-data.GTH,0))
end)
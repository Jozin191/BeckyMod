
local function getBounce(player)
    return math.min(BeckyMod:toTearsPerSecond(player.MaxFireDelay)*.3+.2, 30)
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
        splash.SpriteScale = fam.SpriteScale*1.25
        splash.Color = fam:GetColor()
        splash:GetSprite():ReplaceSpritesheet(0, "gfx/effect_ripplepoof_ghost.png", true)
        SFXManager():Play(SoundEffect.SOUND_TEARIMPACTS, .3, 0, false, 1.2)
        local enemies = Isaac.FindInRadius(fam.Position, fam.SizeMulti:Length()*37.5, EntityPartition.ENEMY)
        for i, v in pairs(enemies) do
            local npc = v:ToNPC()
            if npc then
                npc:ApplyTearflagEffects(fam.Position, tearParams.TearFlags, fam, tearParams.TearDamage*.5)
                npc:TakeDamage(tearParams.TearDamage, 0, EntityRef(fam), 0)
                --npc:AddVelocity((npc.Position-fam.Position):Normalized()*5) i just found out that the puddle doesnt knock enemies back in vanilla 
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
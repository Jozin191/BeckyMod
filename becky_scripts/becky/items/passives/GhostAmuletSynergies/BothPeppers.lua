local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")

---@param familiar EntityFamiliar
local function peppersUpdate(_, familiar, tearParams)
    local player = familiar.Player
    local red, blue = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRDS_EYE), player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER)
    if (not red) and (not blue) then return end
    if familiar.State <= 0 or familiar.FrameCount % 7 ~= 0 then return end

    local formula = (1/(12-math.min(player.Luck, 10))) -- max at 10 luck
    local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GHOST_PEPPER)
    if blue and red then formula = formula*2 end --  the chances get doubled if you have both peppers
    if (rng:RandomFloat() > formula) then return end

    local shoot = familiar.Velocity/1.5+(player:GetAimDirection()*player.ShotSpeed*7)
    if red and blue then --- randomly choosing a flame if you have both peppers
        if rng:RandomFloat() >= .5 then
            red, blue = false, true
        else
            red, blue = true, false
        end
    end

    if blue then
        local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, familiar.Position, shoot, familiar):ToEffect()
        fire.Scale = tearParams.TearScale
        fire:SetTimeout(60)
        fire.CollisionDamage = player.Damage * 6
        return
    elseif red then
        local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, familiar.Position, shoot, familiar):ToEffect()
        fire.Scale = tearParams.TearScale
        fire:SetTimeout(300)
        fire.CollisionDamage = player.Damage*4
    end
end

BeckyMod:AddCallback(BeckyMod.Callbacks.GHOST_UPDATE_HELPER, peppersUpdate)
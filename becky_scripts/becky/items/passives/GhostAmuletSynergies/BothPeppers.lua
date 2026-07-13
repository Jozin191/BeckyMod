local GHOST_BALL = Isaac.GetEntityVariantByName("Ghost Ball")

---@param familiar EntityFamiliar
local function peppersUpdate(_, familiar, tearParams, position)
    if BeckyMod.Game:GetRoom():IsClear() then return end

    local player = familiar.Player

    if player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_PEPPER) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_GHOST_PEPPER)
        if rng:RandomInt(100) + 1 <= 1 then
            local fire = BeckyMod.Game:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, position, familiar.Velocity, familiar, 0, 1):ToEffect()
            fire.Timeout = 45
            fire.CollisionDamage = 14

            return
        end
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRDS_EYE) then
        local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BIRDS_EYE)
        if rng:RandomInt(100) + 1 <= 1 then
            local fire = BeckyMod.Game:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, position, familiar.Velocity, familiar, 0, 1):ToEffect()
            fire.Timeout = 45
            fire.CollisionDamage = 14

            return
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, peppersUpdate, GHOST_BALL)
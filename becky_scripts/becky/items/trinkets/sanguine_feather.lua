local SANGUINE_FEATHER = {}

SANGUINE_FEATHER.ID = Isaac.GetTrinketIdByName("Sanguine Feather")

BeckyMod.Trinket.SANGUINE_FEATHER = SANGUINE_FEATHER

---@param entity Entity
---@param flags DamageFlag
---@param source Entity
function SANGUINE_FEATHER:postDamage(entity, amount, flags, source, cd)
    local player = entity:ToPlayer()
    if not player or not player:HasTrinket(SANGUINE_FEATHER.ID) then return end
    local rng = player:GetTrinketRNG(SANGUINE_FEATHER.ID)

    if rng:RandomInt(2) == 0  then
        player:GetData().rngFlight = true
        player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
    end

    return nil
end
BeckyMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SANGUINE_FEATHER.postDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
function SANGUINE_FEATHER:giveFlight(player, cacheFlags)
    if player:HasTrinket(SANGUINE_FEATHER.ID) and player:GetData().rngFlight then
        player.CanFly = true
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SANGUINE_FEATHER.giveFlight, CacheFlag.CACHE_FLYING)

function SANGUINE_FEATHER:newRoom()
    for _, player in ipairs(PlayerManager:GetPlayers()) do
        player:GetData().rngFlight = false
        player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SANGUINE_FEATHER.newRoom, CacheFlag.CACHE_FLYING)

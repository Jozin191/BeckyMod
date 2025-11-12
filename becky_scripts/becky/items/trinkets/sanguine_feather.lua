local SANGUINE_FEATHER = {}

SANGUINE_FEATHER.ID = Isaac.GetTrinketIdByName("Sanguine Feather")

BeckyMod.Trinket.SANGUINE_FEATHER = SANGUINE_FEATHER

---@param player EntityPlayer
function SANGUINE_FEATHER:postDamage(player)
    if not player:HasTrinket(SANGUINE_FEATHER.ID) then return end
    local rng = player:GetTrinketRNG(SANGUINE_FEATHER.ID)

    if player:GetDamageCooldown() ~= 0 then return end
    if rng:RandomInt(2) ~= 0 then return end
    player:GetData().rngFlight = true
    player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
    player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)
end
BeckyMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, SANGUINE_FEATHER.postDamage)

---@param player EntityPlayer
function SANGUINE_FEATHER:giveFlight(player)
    if not (player:HasTrinket(SANGUINE_FEATHER.ID) and player:GetData().rngFlight) then return end
    player.CanFly = true
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SANGUINE_FEATHER.giveFlight, CacheFlag.CACHE_FLYING)

function SANGUINE_FEATHER:newRoom()
    for _, player in ipairs(PlayerManager:GetPlayers()) do
        player:GetData().rngFlight = false
        player:AddCacheFlags(CacheFlag.CACHE_FLYING, true)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SANGUINE_FEATHER.newRoom)

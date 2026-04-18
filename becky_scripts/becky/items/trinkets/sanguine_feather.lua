local SANGUINE_FEATHER = {}

SANGUINE_FEATHER.ID = Isaac.GetTrinketIdByName("Sanguine Feather")

BeckyMod.Trinket.SANGUINE_FEATHER = SANGUINE_FEATHER

---@param player EntityPlayer
function SANGUINE_FEATHER:postDamage(ent)
    local player = ent:ToPlayer()
    if player == nil or not player:HasTrinket(SANGUINE_FEATHER.ID) then return end
    local rng = player:GetTrinketRNG(SANGUINE_FEATHER.ID)

    if player:GetDamageCooldown() > 0 then return end
    if rng:RandomInt(3) > 0 then return end
    local effects = player:GetEffects()
    effects:AddCollectibleEffect(CollectibleType.COLLECTIBLE_FATE)
    effects:AddTrinketEffect(SANGUINE_FEATHER.ID)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, SANGUINE_FEATHER.postDamage)

---@param player EntityPlayer
function SANGUINE_FEATHER:giveFlight(player)
    if not (player:HasTrinket(SANGUINE_FEATHER.ID) and player:GetEffects():HasTrinketEffect(SANGUINE_FEATHER.ID)) then return end
    player.CanFly = true
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, SANGUINE_FEATHER.giveFlight, CacheFlag.CACHE_FLYING)


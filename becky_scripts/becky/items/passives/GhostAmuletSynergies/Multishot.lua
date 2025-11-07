local GHOST_BALL_VAR = Isaac.GetEntityVariantByName("Ghost Ball")

local ITEM_GHOST_AMULET = Isaac.GetItemIdByName("Ghost Amulet")

---@param player EntityPlayer
---@return boolean
local function HasGhostAmulet(player)
    return player:HasCollectible(ITEM_GHOST_AMULET)
end

---@param player EntityPlayer
---@param cacheflag CacheFlag
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, cacheflag)
    if not HasGhostAmulet(player) then return end
    local rng = RNG()
    local seed = math.max(Random(), 1)
    rng:SetSeed(seed, 35)

    player:CheckFamiliar(GHOST_BALL_VAR, 1, rng)
end, CacheFlag.CACHE_FAMILIARS)
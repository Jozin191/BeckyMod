--[[
    CREDTIS:
        ITEM IDEA: Tiburones202 and Jozin
        ART: Nerfexus
        CODE: Tiburones202
]]
local mod = BeckyMod
local enums = mod.Enums 
local items = enums.CollectibleType
local COXINHA = {}

-- COXINHA.ID = Isaac.GetItemIdByName("Coxinha")
COXINHA.SPEED_INCREASE = 0.3

---@param player EntityPlayer
function COXINHA:evaluateCache(player)
    if not player:HasCollectible(items.COXINHA) then return end
    player.MoveSpeed = player.MoveSpeed + COXINHA.SPEED_INCREASE * player:GetCollectibleNum(items.COXINHA, false)
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, COXINHA.evaluateCache, CacheFlag.CACHE_SPEED)
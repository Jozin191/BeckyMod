--[[
    CREDTIS:
        ITEM IDEA: Tiburones202 and Jozin
        ART: Nerfexus
        CODE: Tiburones202
]]

local COXINHA = {}

COXINHA.ID = Isaac.GetItemIdByName("Coxinha")
COXINHA.SPEED_INCREASE = 0.3

BeckyMod.Item.COXINHA = COXINHA

function COXINHA:evaluateCache(player)
    if player:HasCollectible(COXINHA.ID) then
        player.MoveSpeed = player.MoveSpeed + COXINHA.SPEED_INCREASE * player:GetCollectibleNum(COXINHA.ID, false)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, COXINHA.evaluateCache, CacheFlag.CACHE_SPEED)
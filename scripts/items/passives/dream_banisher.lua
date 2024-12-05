local dreamBanisher = Isaac.GetItemIdByName("Dream Banisher")
local curseDmg = 1.5
local curseTears = 0.5

-- i got the formula for this from the tboi modding discord resource page, from a guide by catinsurance
local function toTearsPerSecond(maxFireDelay)
    return 30 / (maxFireDelay + 1)
  end
  
local function toMaxFireDelay(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

  
function BeckyMod:evaluateCache(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        if Game():GetLevel():GetCurses() > 0 then
            if player:HasCollectible(dreamBanisher) then
                player.Damage = player.Damage + curseDmg
            end
        end
    end
    if cacheFlags & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY then
        if Game():GetLevel():GetCurses() > 0 then
            if player:HasCollectible(dreamBanisher) then
                local tearsPerSecond = toTearsPerSecond(player.MaxFireDelay)
                tearsPerSecond = tearsPerSecond + curseTears
                player.MaxFireDelay = toMaxFireDelay(tearsPerSecond)
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BeckyMod.evaluateCache)

function BeckyMod:postNewFloor()
    local player = Isaac.GetPlayer()
    if player:HasCollectible(dreamBanisher) then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
        player:AddBlackHearts(1)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BeckyMod.postNewFloor)


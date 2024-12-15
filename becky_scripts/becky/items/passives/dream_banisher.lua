local DREAM_BANISHER = {}

DREAM_BANISHER.ID = Isaac.GetItemIdByName("Dream Banisher")
DREAM_BANISHER.CURSE_DAMAGE = 1.5
DREAM_BANISHER.CURSE_TEARS = 0.5
DREAM_BANISHER.DEAL_INCREASE = 15 --15%

BeckyMod.Item.DREAM_BANISHER = DREAM_BANISHER

function DREAM_BANISHER:evaluateCache(player, cacheFlags)
    if BeckyMod:areThereCurses() and player:HasCollectible(DREAM_BANISHER.ID) then
        if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + DREAM_BANISHER.CURSE_DAMAGE
        end
        if cacheFlags & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY then
            local tearsPerSecond = BeckyMod:toTearsPerSecond(player.MaxFireDelay)
            tearsPerSecond = tearsPerSecond + DREAM_BANISHER.CURSE_TEARS
            player.MaxFireDelay = BeckyMod:toMaxFireDelay(tearsPerSecond)
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, DREAM_BANISHER.evaluateCache)

function DREAM_BANISHER:postNewFloor()
    BeckyMod:ForEachPlayer(function(player)
        if player:HasCollectible(DREAM_BANISHER.ID) then
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
            player:AddBlackHearts(1)
        end
    end)
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, DREAM_BANISHER.postNewFloor)

function DREAM_BANISHER:curseCheck()
    if BeckyMod:areThereCurses() then
        BeckyMod:ForEachPlayer(function(player)
            if player:HasCollectible(DREAM_BANISHER.ID) then
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            end
        end)
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, DREAM_BANISHER.curseCheck)

function DREAM_BANISHER:devilModifyChances(chance)
    local firstPlayer = PlayerManager.FirstCollectibleOwner(DREAM_BANISHER.ID)

    if firstPlayer then
        return BeckyMod:addPercentToDealChance(chance, DREAM_BANISHER.DEAL_INCREASE)
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_SPECIAL_ITEMS, DREAM_BANISHER.devilModifyChances)
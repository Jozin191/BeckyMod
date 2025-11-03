--[[
    CREDTIS:
        ITEM IDEA: Darigoat
        ART: Nerfexus
        CODE: Tiburones202 and Nerfexus
]]
local mod = BeckyMod
local enums = mod.Enums
local items = enums.CollectibleType

local DREAM_BANISHER = {}

DREAM_BANISHER.CURSE_DAMAGE = 1.5
DREAM_BANISHER.CURSE_TEARS = 0.5
DREAM_BANISHER.DEAL_INCREASE = 15 --15%

function DREAM_BANISHER:evaluateCache(player, cacheFlags)
    if not (BeckyMod:areThereCurses() and player:HasCollectible(items.DREAM_BANISHER)) then return end
    if cacheFlags == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + DREAM_BANISHER.CURSE_DAMAGE
    elseif cacheFlags == CacheFlag.CACHE_FIREDELAY then
        local tearsPerSecond = BeckyMod:toTearsPerSecond(player.MaxFireDelay)
        tearsPerSecond = tearsPerSecond + DREAM_BANISHER.CURSE_TEARS
        player.MaxFireDelay = BeckyMod:toMaxFireDelay(tearsPerSecond)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, DREAM_BANISHER.evaluateCache)

local function TriggerDreamBanisherFlags(player, addHeart)
    if not player:HasCollectible(items.DREAM_BANISHER) then return end
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)

    if addHeart then
        player:AddBlackHearts(1)
    end
end

function DREAM_BANISHER:postNewFloor()
    BeckyMod:ForEachPlayer(function(player)
        TriggerDreamBanisherFlags(player, true)
    end)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, DREAM_BANISHER.postNewFloor)

function DREAM_BANISHER:curseCheck()
    if not BeckyMod:areThereCurses() then return end
    BeckyMod:ForEachPlayer(function(player)
        TriggerDreamBanisherFlags(player, false)
    end)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, DREAM_BANISHER.curseCheck)

function DREAM_BANISHER:devilModifyChances(chance)
    local firstPlayer = PlayerManager.FirstCollectibleOwner(items.DREAM_BANISHER)

    if firstPlayer then
        return BeckyMod:addPercentToDealChance(chance, DREAM_BANISHER.DEAL_INCREASE)
    end
    return chance
end

BeckyMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_SPECIAL_ITEMS, DREAM_BANISHER.devilModifyChances)
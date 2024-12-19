local HOLY_BOOKMARK = {}

HOLY_BOOKMARK.ID = Isaac.GetTrinketIdByName("Holy Bookmark")

BeckyMod.Trinket.HOLY_BOOKMARK = HOLY_BOOKMARK

HOLY_BOOKMARK.HolyList = {
    Passives = {},
    Actives = {}
} --Look in mod_compatibility/patches/becky (to load after all mods)

function HOLY_BOOKMARK:applyLuck(player, cacheFlags)
    if player:HasTrinket(HOLY_BOOKMARK.ID) and cacheFlags & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK then
        local holyStuffCount = player:GetTrinketMultiplier(HOLY_BOOKMARK.ID) --Counts itself

        

        player.Luck = player.Luck + holyStuffCount*0.5
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, HOLY_BOOKMARK.applyLuck)
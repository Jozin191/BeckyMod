local HOLY_BOOKMARK = {}

HOLY_BOOKMARK.ID = Isaac.GetTrinketIdByName("Holy Bookmark")

BeckyMod.Trinket.HOLY_BOOKMARK = HOLY_BOOKMARK

HOLY_BOOKMARK.LUCK_PER_ITEM = 0.25

HOLY_BOOKMARK.HolyList = {
    --Add non-seraphim but angel-realted passives in here
    Passives = {
        CollectibleType.COLLECTIBLE_GUARDIAN_ANGEL,
        CollectibleType.COLLECTIBLE_HABIT,
        CollectibleType.COLLECTIBLE_HOLY_WATER,
        CollectibleType.COLLECTIBLE_TRINITY_SHIELD,
        CollectibleType.COLLECTIBLE_WAFER,
        CollectibleType.COLLECTIBLE_CENSER,
        CollectibleType.COLLECTIBLE_SERAPHIM,
        CollectibleType.COLLECTIBLE_SWORN_PROTECTOR,
        CollectibleType.COLLECTIBLE_EUCHARIST,
        CollectibleType.COLLECTIBLE_TRISAGION,
        CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION,
        CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR,
        CollectibleType.COLLECTIBLE_MONSTRANCE,
        CollectibleType.COLLECTIBLE_PASCHAL_CANDLE,
        CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES,
        CollectibleType.COLLECTIBLE_SACRED_ORB,
    },

    --Add non-seraphim but angel-realted actives in here
    Actives = {
        CollectibleType.COLLECTIBLE_BREATH_OF_LIFE,
        CollectibleType.COLLECTIBLE_PRAYER_CARD,
        CollectibleType.COLLECTIBLE_BOOK_OF_REVELATIONS,

        --Should I add Genesis?
    }
}

--Function to add custom items to this (non-seraphim ones, for other mods)

function HOLY_BOOKMARK:addItem(type, itemId)
    if type == ItemType.ITEM_ACTIVE then
        if table.indexOf(HOLY_BOOKMARK.HolyList.Actives, itemId) then
            HOLY_BOOKMARK.HolyList.Actives[#HOLY_BOOKMARK.HolyList.Actives + 1] = itemId
        end
    else
        if table.indexOf(HOLY_BOOKMARK.HolyList.Passives, itemId) then
            HOLY_BOOKMARK.HolyList.Passives[#HOLY_BOOKMARK.HolyList.Passives + 1] = itemId
        end
    end
end

--Holy bookmark items (added after all mods have loaded)

function HOLY_BOOKMARK:addAllItems()
    for itemId = 1, BeckyMod.itemconfig:GetCollectibles().Size - 1 do
        local cfg = BeckyMod.itemconfig:GetCollectible(itemId)
        -- auto mod compatibility??? real...
        if cfg and cfg:HasTags(ItemConfig.TAG_ANGEL) then
            HOLY_BOOKMARK:addItem(cfg.Type, itemId)
        end
    end
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.LATE, HOLY_BOOKMARK.addAllItems)

function HOLY_BOOKMARK:applyLuck(player, cacheFlags)
    if player:HasTrinket(HOLY_BOOKMARK.ID) and cacheFlags & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK then
        local holyStuffCount = player:GetTrinketMultiplier(HOLY_BOOKMARK.ID) --Counts itself

        for i = 1, #HOLY_BOOKMARK.HolyList.Passives do
            if player:HasCollectible(HOLY_BOOKMARK.HolyList.Passives[i]) then
                holyStuffCount = holyStuffCount + 1 --Count as 1 item (1 luck)
            end
        end
        for i = 1, #HOLY_BOOKMARK.HolyList.Actives do
            if player:HasCollectible(HOLY_BOOKMARK.HolyList.Actives[i]) then
                holyStuffCount = holyStuffCount + 2 --Count as 2 items (1 luck)
            end
        end

        player.Luck = player.Luck + holyStuffCount * HOLY_BOOKMARK.LUCK_PER_ITEM
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, HOLY_BOOKMARK.applyLuck)

--Cache luck when picking up an item

function HOLY_BOOKMARK:refresLuckOnPickup(_, _, _, _, _, player)
    if player:HasTrinket(HOLY_BOOKMARK.ID) then
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:EvaluateItems()
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, HOLY_BOOKMARK.refresLuckOnPickup)

--Cache luck when dropping up an item

function HOLY_BOOKMARK:refresLuckOnDrop(player)
    if player:HasTrinket(HOLY_BOOKMARK.ID) then
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
        player:EvaluateItems()
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, HOLY_BOOKMARK.refresLuckOnDrop)
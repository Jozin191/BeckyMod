local loader = BeckyMod.PatchesLoader

local function BeckyPatch()
    --If we have arrays/dictionaries that we want to add our items to, we do it here
    HOLY_BOOKMARK = BeckyMod.Trinket.HOLY_BOOKMARK
    --HOLY_BOOKMARK:addItem(ItemType.ITEM_ACTIVE, BeckyMod.Item.HAND_MADE_BIBLE.ID)
end

loader:RegisterPatch("BeckyMod", BeckyPatch)
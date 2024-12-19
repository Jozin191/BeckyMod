local loader = BeckyMod.PatchesLoader

local function BeckyPatch()
    --Holy bookmark items (added after all mods have loaded)
    HOLY_BOOKMARK = BeckyMod.Trinket.HOLY_BOOKMARK
    for itemId = 1, BeckyMod.itemconfig:GetCollectibles().Size - 1 do
        local cfg = BeckyMod.itemconfig:GetCollectible(itemId)
        -- auto mod compatibility??? real...
        if cfg and cfg:HasTags(ItemConfig.TAG_ANGEL) then
            if cfg.MaxCharges > 0 then
                HOLY_BOOKMARK.HolyList.Actives[#HOLY_BOOKMARK.HolyList.Actives] = itemId
                print("Active " .. cfg.Name .. " added")
            else
                HOLY_BOOKMARK.HolyList.Passives[#HOLY_BOOKMARK.HolyList.Passives] = itemId
                print("Passive " .. cfg.Name .. " added")
            end
        end
    end
end

loader:RegisterPatch("BeckyMod", BeckyPatch)
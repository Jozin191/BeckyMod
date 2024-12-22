local loader = BeckyMod.PatchesLoader

local function EpiphanyPatch()
    --mother's shadow curse of darkness thing

    local oldCallback = BeckyMod.areThereCurses

    function BeckyMod:areThereCurses()
        local someoneHasMothersShadow = false

        BeckyMod:ForEachPlayer(function(player)
            if player:HasCollectible(Epiphany.Item.MOTHERS_SHADOW.ID) then
                someoneHasMothersShadow = true
            end
        end)

        local someoneHasBlackCandle = false

        BeckyMod:ForEachPlayer(function(player)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE) then
                someoneHasBlackCandle = true
            end
        end)

        return oldCallback(self) or (someoneHasMothersShadow and not someoneHasBlackCandle)
    end

    --Holy bookmark items

    HOLY_BOOKMARK = BeckyMod.Trinket.HOLY_BOOKMARK
    HOLY_BOOKMARK:addItem(ItemType.ITEM_ACTIVE, Epiphany.Item.DIVINE_REMNANTS.ID)
    HOLY_BOOKMARK:addItem(ItemType.ITEM_PASSIVE, Epiphany.Item.RETRIBUTION.ID)

    --Rejection

    REJECTION = BeckyMod.Trinket.REJECTION

    REJECTION.ValidPriceTypes[Epiphany.PickupPrice.PRICE_TWO_BROKEN_HEARTS] = true

    if Epiphany.PickupPrice.PRICE_TWO_BLUE_BROKEN_HEARTS then
        REJECTION.ValidPriceTypes[Epiphany.PickupPrice.PRICE_TWO_BLUE_BROKEN_HEARTS] = true
    end
end

loader:RegisterPatch("Epiphany", EpiphanyPatch)
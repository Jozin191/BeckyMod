local loader = BeckyMod.PatchesLoader

local function EpiphanyPatch()
    --TrJudas' deal thingy

    --[[
    BeckyMod.Character.BECKY.AddDealModifiers({
        ["TARNISHED JUDAS"] = {
            priority = -200,
            condition = function(_)
                print("hello. this judas code")
                local fyoujudaslol = PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS1) or
                PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS2) or
                PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS) or
                PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS4) or
                PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS5)
                return fyoujudaslol
            end,
            modification = function(pickup)
                print("mod judas")
                local newPickup = pickup
                newPickup.Price = Epiphany.PickupPrice.PRICE_TWO_BLUE_BROKEN_HEARTS
                return newPickup
            end,
        }
    })]]

    BeckyMod.Character.BECKY.AddDealModifiers({
        {
            identificator = "TARNISHED JUDAS",
            priority = -200,
            condition = function(_)
                local fyoujudaslol = Epiphany and (PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS1) or
                PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS2) or
                PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS) or
                PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS4) or
                PlayerManager.AnyoneIsPlayerType(Epiphany.PlayerType.JUDAS5))
                return fyoujudaslol
            end,
            modification = function(pickup)
                local newPickup = pickup
                newPickup.Price = Epiphany.PickupPrice.PRICE_TWO_BLUE_BROKEN_HEARTS
                return newPickup
            end,
        },
    })

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

    --Devilzon Prime

    DEVILZON_PRIME = BeckyMod.Trinket.DEVILZON_PRIME

    DEVILZON_PRIME.ValidPriceTypes[Epiphany.PickupPrice.PRICE_TWO_BROKEN_HEARTS] = true

    if Epiphany.PickupPrice.PRICE_TWO_BLUE_BROKEN_HEARTS then
        DEVILZON_PRIME.ValidPriceTypes[Epiphany.PickupPrice.PRICE_TWO_BLUE_BROKEN_HEARTS] = true
    end

    --Eden blacklist

    --[[
    Epiphany.API:AddItemsToEdenBlackList(
        BeckyMod.Item.COXINHA.ID
    )
    ]]
end

loader:RegisterPatch("Epiphany", EpiphanyPatch)
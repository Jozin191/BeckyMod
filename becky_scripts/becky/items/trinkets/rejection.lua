--[[
    CREDTIS:
        ITEM IDEA: InterstellarNuggo and Tiburones202
        ART: Nerfexus
        CODE: Tiburones202
]]

local REJECTION = {}

REJECTION.ID = Isaac.GetTrinketIdByName("Rejection")

REJECTION.EXTRA_CHANCE_PER_DEAL = 10

REJECTION.ValidPriceTypes = {
    [PickupPrice.PRICE_ONE_HEART] = true,
    [PickupPrice.PRICE_TWO_HEARTS] = true,
    [PickupPrice.PRICE_THREE_SOULHEARTS] = true,
    [PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS] = true,
    [PickupPrice.PRICE_SOUL] = true,
    [PickupPrice.PRICE_ONE_SOUL_HEART] = true,
    [PickupPrice.PRICE_TWO_SOUL_HEARTS] = true,
    [PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART] = true,
}

BeckyMod.Trinket.REJECTION = REJECTION

function REJECTION:checkDealPickup(item, player)
    local player = player:ToPlayer()

    if player and BeckyMod.AnyoneHasTrinketPlusGolden(REJECTION.ID) then
        if REJECTION.ValidPriceTypes[item.Price] then
            local P1 = Isaac.GetPlayer() --The extra chance will always check for P1
            local runSave = BeckyMod:RunSave(P1)

            if not runSave.extraDealchanceByRejectionForNextFloor then
                runSave.extraDealchanceByRejectionForNextFloor = 0
            end

            runSave.extraDealchanceByRejectionForNextFloor = runSave.extraDealchanceByRejectionForNextFloor + REJECTION.EXTRA_CHANCE_PER_DEAL
            print(runSave.extraDealchanceByRejectionForNextFloor)
        end
    end
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, CallbackPriority.LATE, REJECTION.checkDealPickup, PickupVariant.PICKUP_COLLECTIBLE)

function REJECTION:onNewFloor()
    local P1 = Isaac.GetPlayer() --The extra chance will always check for P1
    local runSave = BeckyMod:RunSave(P1)

    if BeckyMod.AnyoneHasTrinketPlusGolden(REJECTION.ID) then
        --Deal chance stuff

        if not runSave.extraDealchanceByRejectionForNextFloor then
            runSave.extraDealchanceByRejectionForNextFloor = 0
        end

        runSave.extraDealchanceByRejection = runSave.extraDealchanceByRejectionForNextFloor
        runSave.extraDealchanceByRejectionForNextFloor = 0
    end

    if runSave.someoneHadRejection then --Anyone had the trinket at one point
        --Lock to devil deal

        BeckyMod.Game:AddDevilRoomDeal()
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, REJECTION.onNewFloor)

function REJECTION:devilModifyChances(chance)
    if BeckyMod.AnyoneHasTrinketPlusGolden(REJECTION.ID) then
        local runSave = BeckyMod:RunSave(Isaac.GetPlayer())

        if not runSave.extraDealchanceByRejection then
            runSave.extraDealchanceByRejection = 0
        end

        local totalCount = PlayerManager.GetTotalTrinketMultiplier(REJECTION.ID)
        local finalExtraChance = (runSave.extraDealchanceByRejection * 2 * (1 - 0.5^totalCount))/100

        return chance + finalExtraChance
    end

    return chance
end

BeckyMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_SPECIAL_ITEMS, REJECTION.devilModifyChances)

function REJECTION:LockToDevilDeals()
    BeckyMod:RunSave(Isaac.GetPlayer()).someoneHadRejection = true

    BeckyMod.Game:AddDevilRoomDeal() --Lock in for the current floor
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, REJECTION.LockToDevilDeals, REJECTION.ID)
BeckyMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, REJECTION.LockToDevilDeals, REJECTION.ID | TrinketType.TRINKET_GOLDEN_FLAG) --Separate version for the golden version (?
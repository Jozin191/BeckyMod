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

    if player and PlayerManager.AnyoneHasTrinket(REJECTION.ID) then
        if REJECTION.ValidPriceTypes[item.Price] then
            local P1 = Isaac.GetPlayer() --The extra chance will always check for P1
            local runSave = BeckyMod:RunSave(P1)

            if not runSave.extraDealchanceByRejectionForNextFloor then
                runSave.extraDealchanceByRejectionForNextFloor = 0
            end

            runSave.extraDealchanceByRejectionForNextFloor = runSave.extraDealchanceByRejectionForNextFloor + REJECTION.EXTRA_CHANCE_PER_DEAL
        end
    end
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, CallbackPriority.LATE, REJECTION.checkDealPickup, PickupVariant.PICKUP_COLLECTIBLE)

function REJECTION:onNewFloor()
    if PlayerManager.AnyoneHasTrinket(REJECTION.ID) then
        --Lock devil/angel

        

        --Deal chance stuff

        local P1 = Isaac.GetPlayer() --The extra chance will always check for P1
        local runSave = BeckyMod:RunSave(P1)

        if not runSave.extraDealchanceByRejectionForNextFloor then
            runSave.extraDealchanceByRejectionForNextFloor = 0
        end

        runSave.extraDealchanceByRejection = runSave.extraDealchanceByRejectionForNextFloor
        runSave.extraDealchanceByRejectionForNextFloor = 0
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, REJECTION.onNewFloor)

function REJECTION:devilModifyChances(chance)
    if PlayerManager.AnyoneHasTrinket(REJECTION.ID) then
        local runSave = BeckyMod:RunSave(Isaac.GetPlayer())

        if not runSave.extraDealchanceByRejection then
            runSave.extraDealchanceByRejection = 0
        end

        return chance * (1 + runSave.extraDealchanceByRejection/100)
    end
    return chance
end

BeckyMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_SPECIAL_ITEMS, REJECTION.devilModifyChances)
--[[
    CREDTIS:
        ITEM IDEA: InterstellarNuggo and Tiburones202
        ART: Nerfexus
        CODE: Tiburones202
]]

local DEVILZON_PRIME = {}

DEVILZON_PRIME.ID = Isaac.GetTrinketIdByName("Devilzon Prime")

DEVILZON_PRIME.EXTRA_CHANCE_PER_DEAL = 10

DEVILZON_PRIME.ValidPriceTypes = {
    [PickupPrice.PRICE_ONE_HEART] = true,
    [PickupPrice.PRICE_TWO_HEARTS] = true,
    [PickupPrice.PRICE_THREE_SOULHEARTS] = true,
    [PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS] = true,
    [PickupPrice.PRICE_SOUL] = true,
    [PickupPrice.PRICE_ONE_SOUL_HEART] = true,
    [PickupPrice.PRICE_TWO_SOUL_HEARTS] = true,
    [PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART] = true,
}

BeckyMod.Trinket.DEVILZON_PRIME = DEVILZON_PRIME

function DEVILZON_PRIME:checkDealPickup(item, player)
    local player = player:ToPlayer()

    if player and BeckyMod.AnyoneHasTrinketPlusGolden(DEVILZON_PRIME.ID) then
        if DEVILZON_PRIME.ValidPriceTypes[item.Price] then
            local P1 = Isaac.GetPlayer() --The extra chance will always check for P1
            local runSave = BeckyMod:RunSave(P1)

            if not runSave.extraDealchanceByDevilzonPrimeForNextFloor then
                runSave.extraDealchanceByDevilzonPrimeForNextFloor = 0
            end

            runSave.extraDealchanceByDevilzonPrimeForNextFloor = runSave.extraDealchanceByDevilzonPrimeForNextFloor + DEVILZON_PRIME.EXTRA_CHANCE_PER_DEAL
            print(runSave.extraDealchanceByDevilzonPrimeForNextFloor)
        end
    end
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, CallbackPriority.LATE, DEVILZON_PRIME.checkDealPickup, PickupVariant.PICKUP_COLLECTIBLE)

function DEVILZON_PRIME:onNewFloor()
    local P1 = Isaac.GetPlayer() --The extra chance will always check for P1
    local runSave = BeckyMod:RunSave(P1)

    if BeckyMod.AnyoneHasTrinketPlusGolden(DEVILZON_PRIME.ID) then
        --Deal chance stuff

        if not runSave.extraDealchanceByDevilzonPrimeForNextFloor then
            runSave.extraDealchanceByDevilzonPrimeForNextFloor = 0
        end

        runSave.extraDealchanceByDevilzonPrime = runSave.extraDealchanceByDevilzonPrimeForNextFloor
        runSave.extraDealchanceByDevilzonPrimeForNextFloor = 0
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, DEVILZON_PRIME.onNewFloor)

function DEVILZON_PRIME:devilModifyChances(chance)
    if BeckyMod.AnyoneHasTrinketPlusGolden(DEVILZON_PRIME.ID) then
        local runSave = BeckyMod:RunSave(Isaac.GetPlayer())

        if not runSave.extraDealchanceByDevilzonPrime then
            runSave.extraDealchanceByDevilzonPrime = 0
        end

        local totalCount = PlayerManager.GetTotalTrinketMultiplier(DEVILZON_PRIME.ID)
        local finalExtraChance = (runSave.extraDealchanceByDevilzonPrime * 2 * (1 - 0.5^totalCount))/100

        return chance + finalExtraChance
    end

    return chance
end

BeckyMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_SPECIAL_ITEMS, DEVILZON_PRIME.devilModifyChances)
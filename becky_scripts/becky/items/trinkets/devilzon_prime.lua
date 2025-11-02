--[[
    CREDTIS:
        ITEM IDEA: InterstellarNuggo and Tiburones202
        ART: Nerfexus
        CODE: Tiburones202
]]
local mod = BeckyMod
local enums = mod.Enums
local trinkets = enums.TrinketType
local DEVILZON_PRIME = {}

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

---@param item EntityPickup
function DEVILZON_PRIME:checkDealPickup(item)
    if not BeckyMod.AnyoneHasTrinketPlusGolden(trinkets.DEVILZON_PRIME) then return end
    if not DEVILZON_PRIME.ValidPriceTypes[item.Price] then return end

    local P1 = Isaac.GetPlayer() --The extra chance will always check for P1
    local runSave = BeckyMod:RunSave(P1)

    if not runSave.extraDealchanceByDevilzonPrimeForNextFloor then
        runSave.extraDealchanceByDevilzonPrimeForNextFloor = 0
    end

    runSave.extraDealchanceByDevilzonPrimeForNextFloor = runSave.extraDealchanceByDevilzonPrimeForNextFloor + DEVILZON_PRIME.EXTRA_CHANCE_PER_DEAL
end
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, CallbackPriority.LATE, DEVILZON_PRIME.checkDealPickup, PickupVariant.PICKUP_COLLECTIBLE)

function DEVILZON_PRIME:onNewFloor()
    local P1 = Isaac.GetPlayer() --The extra chance will always check for P1
    local runSave = BeckyMod:RunSave(P1)

    if not BeckyMod.AnyoneHasTrinketPlusGolden(trinkets.DEVILZON_PRIME) then return end
        --Deal chance stuff

    if not runSave.extraDealchanceByDevilzonPrimeForNextFloor then
        runSave.extraDealchanceByDevilzonPrimeForNextFloor = 0
    end

    runSave.extraDealchanceByDevilzonPrime = runSave.extraDealchanceByDevilzonPrimeForNextFloor
    runSave.extraDealchanceByDevilzonPrimeForNextFloor = 0
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, DEVILZON_PRIME.onNewFloor)

function DEVILZON_PRIME:devilModifyChances(chance)
    if BeckyMod.AnyoneHasTrinketPlusGolden(trinkets.DEVILZON_PRIME) then
        local runSave = BeckyMod:RunSave(Isaac.GetPlayer())

        if not runSave.extraDealchanceByDevilzonPrime then
            runSave.extraDealchanceByDevilzonPrime = 0
        end

        local totalCount = PlayerManager.GetTotalTrinketMultiplier(trinkets.DEVILZON_PRIME)
        local finalExtraChance = (runSave.extraDealchanceByDevilzonPrime * 2 * (1 - 0.5^totalCount))/100

        return chance + finalExtraChance
    end

    return chance
end
BeckyMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_SPECIAL_ITEMS, DEVILZON_PRIME.devilModifyChances)
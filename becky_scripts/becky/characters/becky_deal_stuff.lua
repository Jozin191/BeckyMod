local DEVIL_DEAL = {}

BeckyMod.Character.BECKY.DealStuff = DEVIL_DEAL

--[[
DEVIL_DEAL.ExcludeSpikePickupVariants = {
    [PickupVariant.PICKUP_CHEST] = true,
    [PickupVariant.PICKUP_BOMBCHEST] = true,
    [PickupVariant.PICKUP_ETERNALCHEST] = true,
    [PickupVariant.PICKUP_MIMICCHEST] = true,
    [PickupVariant.PICKUP_REDCHEST] = true,
    [PickupVariant.PICKUP_OLDCHEST] = true,
    [PickupVariant.PICKUP_WOODENCHEST] = true,
    [PickupVariant.PICKUP_MEGACHEST] = true,
    [PickupVariant.PICKUP_HAUNTEDCHEST] = true,
    [PickupVariant.PICKUP_LOCKEDCHEST] = true,
}]]

 -- most of this stuff was taken from https://github.com/Guantol-Lemat/Isaac.LuaDecomps/blob/main/_Legacy/Room/SubSystem/Shop.lua

local game = BeckyMod.Game

local function IsBeckyPresent()
    return PlayerManager.AnyoneIsPlayerType(BeckyMod.Character.BECKY.PLAYERTYPE) or PlayerManager.AnyoneIsPlayerType(BeckyMod.Character.BECKY_B.PLAYERTYPE)
end
local function IsKeeperPresent()
    return PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER) or PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER_B)
end

local function CollectiblesInRoom()
    return Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
end

local VALID_HEALTHTYPES = { [HealthType.DEFAULT] = true, [HealthType.BONE] = true }
local function SetRoomSaveData()
    local roomSave = BeckyMod:RoomSave()

    local keepersBargain = 0
    local healthCointainers = 0
    local judasTongue = 0
    for _, player in ipairs(PlayerManager:GetPlayers()) do
        if VALID_HEALTHTYPES[player:GetHealthType()] then
            healthCointainers = healthCointainers + math.ceil(player:GetMaxHearts() / 2) + player:GetBoneHearts()
        end
        if keepersBargain < 2 and player:HasTrinket(TrinketType.TRINKET_KEEPERS_BARGAIN) then
            if player:HasGoldenTrinket(TrinketType.TRINKET_KEEPERS_BARGAIN) or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                keepersBargain = 2
            elseif keepersBargain < 1 then
                keepersBargain = 1
            end
        end
        if judasTongue < 2 and player:HasTrinket(TrinketType.TRINKET_JUDAS_TONGUE) then
            if player:HasGoldenTrinket(TrinketType.TRINKET_JUDAS_TONGUE) or player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
                judasTongue = 2
            elseif judasTongue < 1 then
                judasTongue = 1
            end
        end
    end

    roomSave.BeckyPrices = {
        IsBeckyPresent = IsBeckyPresent(),
        IsKeeperPresent = IsKeeperPresent(),
        BlueBabyPrices = PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BLUEBABY),
        PoundOfFlesh = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_POUND_OF_FLESH),
        JudasTongue = judasTongue,
        HealthCointainers = healthCointainers,
        YourSoul = PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_YOUR_SOUL),
        KeepersBargain = keepersBargain,
        KeepersBargainSeedTable = {}
    }
end

local itemConfig = Isaac.GetItemConfig()
local function GetPriceOf(var, sub, devilPrice, roomSave)
    if var ~= 100 then
        if devilPrice then
            return PickupPrice.PRICE_SPIKES
        elseif var == PickupVariant.PICKUP_HEART then
            return (sub == HeartSubType.HEART_FULL or sub == HeartSubType.HEART_HALF) and 3 or 5
        elseif var == PickupVariant.PICKUP_KEY then
            return sub == KeySubType.KEY_GOLDEN and 10 or 5
        elseif var == PickupVariant.PICKUP_BOMB then
            return sub == BombSubType.BOMB_GOLDEN and 10 or 5
        elseif var == PickupVariant.PICKUP_GRAB_BAG then
            return 7
        end

        return 5
    end

    local config = itemConfig:GetCollectible(sub)
    if not config then
        if devilPrice then return PickupPrice.PRICE_ONE_HEART end
        return 15
    end

    if devilPrice then
        local price = config.DevilPrice >= 2 and PickupPrice.PRICE_TWO_HEARTS or PickupPrice.PRICE_ONE_HEART
        if roomSave.HealthCointainers and roomSave.HealthCointainers > 0 then
            if roomSave.JudasTongue > 0 then
                price = PickupPrice.PRICE_ONE_HEART
            elseif price == PickupPrice.PRICE_TWO_HEARTS and roomSave.HealthCointainers == 1 then
                price = PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS
            end
            return price
        end
        if roomSave.BlueBabyPrices then
            price = roomSave.JudasTongue == 0 and config.DevilPrice >= 2 and PickupPrice.PRICE_TWO_SOUL_HEARTS or PickupPrice.PRICE_ONE_SOUL_HEART
        else
            price = roomSave.JudasTongue > 1 and PickupPrice.PRICE_TWO_SOUL_HEARTS or PickupPrice.PRICE_THREE_SOULHEARTS
        end
        if roomSave.YourSoul then
            return PickupPrice.PRICE_SOUL
        end
        return price
    end
    
    local price = config.ShopPrice
    if price == 15 and config.DevilPrice >= 2 then
        price = 30
    end
    

    return price
end

local function IsKeepersBargain(var, sub, roomSave, roomDesc)
    if roomSave.KeepersBargain == 0 then return false end
    --if roomSave.KeepersBargain == 2 then return true end -- the golden effect was not on .12
    
    local seed = roomSave.KeepersBargainSeedTable[var + sub]
    if seed == nil then
        roomSave.KeepersBargainSeedTable[var + sub] = roomDesc.DecorationSeed & 0xfffff800 | var + sub
    end

    return seed % 2 == 0
end

local function ShouldBeDevilPrice(roomDesc)
    local roomData = roomDesc.Data
    if roomData == nil then return false end
    if roomData.Type == RoomType.ROOM_DEVIL or roomDesc.Flags & RoomDescriptor.FLAG_DEVIL_TREASURE > 0 then return false end
    if roomData.Type == RoomType.ROOM_ANGEL then return true end
    return false
end


function DEVIL_DEAL:PostNewRoom()
    if not IsBeckyPresent() then return end
    local room = game:GetRoom()
    
    if not room:IsFirstVisit() or IsKeeperPresent() then return end
    local roomType = room:GetType()

    if roomType == RoomType.ROOM_TREASURE then
        SetRoomSaveData()
    elseif roomType == RoomType.ROOM_DEVIL then
        SetRoomSaveData()
        if Epiphany and Epiphany.Item.BROKEN_HALO:isBrokenHaloRoom() then
            return
        end

        local pickupGroup
        for _, entity in ipairs(CollectiblesInRoom()) do
            local pickup = entity:ToPickup()

            if not pickup or pickup.SubType == 0 then goto continue end

            if pickup.Price == -10 then
                local grid = room:GetGridEntityFromPos(pickup.Position + Vector(0, -40))
                if grid and grid:GetType() == GridEntityType.GRID_SPIKES then
                    room:RemoveGridEntityImmediate(grid:GetGridIndex(), 0, true)
                end
            end

            pickup.Price = 0
            pickup.ShopItemId = 0
            if pickupGroup == nil then
                pickupGroup = pickup:SetNewOptionsPickupIndex()
            end
            pickup.OptionsPickupIndex = pickupGroup

            ::continue::
        end
    elseif roomType == RoomType.ROOM_ANGEL then
        SetRoomSaveData()
        local shopId = 0
        for _, entity in ipairs(CollectiblesInRoom()) do
            local pickup = entity:ToPickup()

            if not pickup or pickup.SubType == 0 or pickup.Price ~= 0 then goto continue end

            pickup.ShopItemId = -1
            pickup.Price = 1
            pickup.OptionsPickupIndex = 0

            shopId = shopId +1
            ::continue::
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DEVIL_DEAL.PostNewRoom)


function DEVIL_DEAL:ShopPrice(var, sub, shopId)
    local roomSave = BeckyMod:RoomSave()
    if roomSave.BeckyPrices == nil then return end
    local priceSave = roomSave.BeckyPrices
    
    if priceSave.IsKeeperPresent or not priceSave.IsBeckyPresent then return end

    local level = BeckyMod.Level()
    local roomDesc = level:GetCurrentRoomDesc()
    local devilPrice
    if shopId < 0 then
        devilPrice = shopId == -1
    else devilPrice = ShouldBeDevilPrice(roomDesc) end

    if priceSave.PoundOfFlesh then devilPrice = not devilPrice end
    if IsKeepersBargain(var, sub, priceSave, roomDesc) then devilPrice = false end
    return GetPriceOf(var, sub, devilPrice, priceSave)
end
BeckyMod:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, DEVIL_DEAL.ShopPrice)


local function UpdateRoomSaveData()
    if BeckyMod:RoomSave().BeckyPrices == nil then return end
    SetRoomSaveData()
end

local function SetUpSatanicBible()
    local room = game:GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS and game:GetLevel():GetStateFlag(LevelStateFlag.STATE_SATANIC_BIBLE_USED) then
        SetRoomSaveData()
    end
end

BeckyMod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, 200, SetUpSatanicBible, CollectibleType.COLLECTIBLE_SATANIC_BIBLE)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, 200, UpdateRoomSaveData, 100)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, 200, UpdateRoomSaveData)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, 200, UpdateRoomSaveData)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_ADDED, 200, UpdateRoomSaveData)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_TRIGGER_TRINKET_REMOVED, 200, UpdateRoomSaveData)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_REVIVE, 200, UpdateRoomSaveData)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_KILL, 200, UpdateRoomSaveData)
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_GAME_STARTED, 200, UpdateRoomSaveData)

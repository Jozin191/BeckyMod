local mod = BeckyMod
local enums = mod.Enums
local costumes = enums.NullItemID
local BeckyPlayer = enums.PlayerType.BECKY
local BECKY = {}

BECKY.ExcludeSpikePickupVariants = {
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
}

local game = enums.Utils.Game

--Deal modifiers (keeper's passive, blue baby's passive, or modded stuff)
--Modded example: Tarnished Judas

BECKY.DealModifiers = {}
BECKY.OldDealModifiers = {}

local function CollectiblesInRoom()
    return Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
end

---Add a custom deal modifiers. Can add multiple at the same time.
---Sorts them later after adding them, lower priority meaning that it goes before!
function BECKY.AddDealModifiers(toAddDealModifiers)
    BECKY.OldDealModifiers = BECKY.DealModifiers
    for _, data in ipairs(toAddDealModifiers) do
        --print("LINE 75: " .. data.identificator .. " POS:".. #BECKY.DealModifiers)
        table.insert(BECKY.OldDealModifiers, data)
    end

    BECKY.DealModifiers = BECKY.OldDealModifiers
    
    table.sort(BECKY.DealModifiers, function (a,b)
        return a.priority < b.priority
    end)

    --[[
    for _, data in pairs(BECKY.DealModifiers) do
        print("LINE 75: " .. data.identificator .. " PRIORITY:".. data.priority)
    end
    ]]
end

BECKY.AddDealModifiers({
    {
        identificator = "BECKY",
        priority = 500,
        condition = function(_)
            return PlayerManager.AnyoneIsPlayerType(enums.PlayerType.PlayerType_BECKY)
        end,
        ---@param pickup EntityPickup
        ---@param price number
        modification = function(pickup, price)
            local newPickup = pickup
            newPickup.Price = (price == 1) and PickupPrice.PRICE_ONE_HEART or PickupPrice.PRICE_TWO_HEARTS
            return newPickup
        end,
    },
})

-- BeckyMod.Character.BECKY = BECKY

--End of deal modifiers

---@param player EntityPlayer
function BECKY:OnInit(player)
    if player:GetPlayerType() ~= BeckyPlayer then return end
    PlayerAnimLib:SetDefaultAnm2(player, "gfx/player_becky.anm2")
    player:AddNullCostume(costumes.BECKY_HAIR)
    player:AddNullCostume(costumes.BECKY_BODY)
    player:AddCollectible(enums.CollectibleType.GHOST_AMULET)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BECKY.OnInit, 0)

function BECKY:postNewRoom()
    local player = PlayerManager.FirstPlayerByType(BeckyPlayer)

    if not player then return end
    local room = game:GetRoom()
    local roomType = room:GetType()

    if roomType == RoomType.ROOM_DEVIL and room:IsFirstVisit() then
        for _, entity in ipairs(CollectiblesInRoom()) do
            local pickup = entity:ToPickup()

            if not pickup then goto continue end
            if pickup.Price == PickupPrice.PRICE_FREE then goto continue end

            local pos = pickup.Position
            local subType = pickup.SubType
            local newPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, subType, pos, Vector(0, 0), nil):ToPickup()
            if newPickup then
                newPickup.OptionsPickupIndex = 1
            end
            pickup:Remove()
            ::continue::
        end
    end

    if roomType == RoomType.ROOM_ANGEL then
        local runSave = BeckyMod:RunSave(player)

        game:GetLevel():AddAngelRoomChance(50)
        runSave.ENTERED_ANGEL_ROOM = true
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BECKY.postNewRoom)

function BECKY:updateAngelDealPrice(pickup)
    if not BeckyMod:GetRerollPersistentData(pickup).beckyPassiveChecked then
        return
    end

    --Should I move this to deal modifiers as the number 1 priority thing?
    if PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_YOUR_SOUL) then
        pickup.Price = PickupPrice.PRICE_SOUL
        return
    end

    local subtype = pickup.SubType
    local itemData = Isaac.GetItemConfig():GetCollectible(subtype)
    local price = itemData and itemData.DevilPrice or 1

    --[[
    for _, data in ipairs(BECKY.DealModifiers) do
        print("LINE 146: " .. data.identificator)
    end
    ]]

    for _, modifierData in ipairs(BECKY.DealModifiers) do
        --print("LINE 150: " .. modifierData.identificator)
        if modifierData.condition(pickup) then
            pickup = modifierData.modification(pickup, price)
            return
        end
    end

    --No special stuff

    local normalHeartsCount = 0

    BeckyMod:ForEachPlayer(function(player)
        normalHeartsCount = normalHeartsCount + player:GetHearts()
    end)

    if normalHeartsCount == 2 and price == 2 then
        pickup.Price = PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS
    elseif normalHeartsCount > 0 then
        if price == 1 then
            pickup.Price = PickupPrice.PRICE_ONE_HEART
        else
            pickup.Price = PickupPrice.PRICE_TWO_HEARTS
        end
    else
        pickup.Price = PickupPrice.PRICE_THREE_SOULHEARTS
    end
end

---@param pickup EntityPickup
function BECKY:initAngelPickupPrices(pickup)
    local becky = PlayerManager.FirstPlayerByType(BeckyPlayer)
    local room = game:GetRoom()

    if not becky then return end
    if room:GetType() ~= RoomType.ROOM_ANGEL then return end
    if pickup.SubType == CollectibleType.COLLECTIBLE_NULL then return end
    if not (pickup.Price < 0 or room:GetFrameCount() <= 1) then return end
    if pickup.FrameCount > 1 then return end

    local pData = BeckyMod:GetRerollPersistentData(pickup)

    if pData.beckyPassiveChecked then return end

    pData.beckyPassiveChecked = true

    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
        BECKY:updateAngelDealPrice(pickup)
    elseif not BECKY.ExcludeSpikePickupVariants[pickup.Variant] then
        pickup.Price = PickupPrice.PRICE_SPIKES
    end

    pickup.AutoUpdatePrice = false

    Scheduler.Schedule(1, function()
        pickup.OptionsPickupIndex = 0
    end)
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, BECKY.initAngelPickupPrices)

--checks if the player ever made a deal with in a angel room
function BECKY:checkAngelItem(pickup, player)
    local player = player:ToPlayer()

    if not player then return end
    if player:GetPlayerType() ~= BeckyPlayer then return end
    if not game:GetRoom():GetType() == RoomType.ROOM_ANGEL then return end
    if not player:IsExtraAnimationFinished() then return end

    local firstBecky = PlayerManager.FirstPlayerByType(BeckyPlayer) --Mod only checks the first becky for everything else
    BeckyMod:RunSave(firstBecky).GOT_ANGEL_ITEM = true

    BECKY:updateAngelDealPrice(pickup)
end
BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, BECKY.checkAngelItem, PickupVariant.PICKUP_COLLECTIBLE)
--Needs to run late in case a mod says "nuh uh" and stops you from colliding with it

function BECKY:onBossDeath(entity)
    local player = PlayerManager.FirstPlayerByType(BeckyPlayer)
    if player and entity:IsBoss() then
        BeckyMod:FloorSave(player).bossIsDead = true
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, BECKY.onBossDeath)

function BECKY:checkAngelRoomGen()
    local player = PlayerManager.FirstPlayerByType(BeckyPlayer)
    if not player then return end

    local runSave = BeckyMod:RunSave(player)
    local floorSave = BeckyMod:FloorSave(player)

    if not floorSave.bossIsDead then return end
    local level = game:GetLevel()
    local currentRoomDesc = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)

    if currentRoomDesc.Data then return end
    runSave.FIRST_DEAL_RUN = false
    floorSave.bossIsDead = false
end
-- end
BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BECKY.checkAngelRoomGen)

function BECKY:DamageMult(player)
    if player:GetPlayerType() ~= enums.PlayerType.PlayerType_BECKY then return end
    player.Damage = player.Damage * 1.2
end
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BECKY.DamageMult, CacheFlag.CACHE_DAMAGE)
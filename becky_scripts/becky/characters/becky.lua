local BECKY = {}

BECKY.PLAYERTYPE = Isaac.GetPlayerTypeByName("Becky", false)
BECKY.POCKET_ITEM = Isaac.GetItemIdByName("Hand Made Bible")
local game = BeckyMod.Game
BECKY.RECEIVED_ITEMS = {}
BECKY.GENERATED_DEVIL_ITEMS = {}

BECKY.ENTERED_ANGEL_ROOM = false
BECKY.GOT_ANGEL_ITEM = false
BECKY.FIRST_DEAL_RUN = true

BeckyMod.Character.BECKY = BECKY

function BeckyMod:OnPreAddCollectible(type)
    BECKY.RECEIVED_ITEMS[type] = true
    return true
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, BeckyMod.OnPreAddCollectible)

function BeckyMod:OnInit()
    local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/becky_hair.anm2")
    local bodyCostume = Isaac.GetCostumeIdByPath("gfx/characters/becky_body.anm2")
    local player = Isaac.GetPlayer()
    if player:GetPlayerType() == BECKY.PLAYERTYPE then
        player:AddNullCostume(hairCostume)
        player:AddNullCostume(bodyCostume)

        player:SetPocketActiveItem(BECKY.POCKET_ITEM, ActiveSlot.SLOT_POCKET, true)
        game:GetItemPool():RemoveCollectible(BECKY.POCKET_ITEM)
    end
    BECKY.RECEIVED_ITEMS = {}
    BECKY.GENERATED_DEVIL_ITEMS = {}
    BECKY.FIRST_DEAL_RUN = true
    BECKY.GOT_ANGEL_ITEM = false
    BECKY.ENTERED_ANGEL_ROOM = false
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BeckyMod.OnInit)

--[[function BeckyMod:changePickupPrice(pickup)
    local player = Isaac.GetPlayer()
    local room = game:GetRoom()
    local itemConfig = Isaac.GetItemConfig()

    if player:GetPlayerType() == BECKY.PLAYERTYPE and room:GetType() == RoomType.ROOM_ANGEL then --for angel items
        local subtype = pickup.SubType
        local itemData = itemConfig:GetCollectible(subtype)
        local quality = itemData and itemData.Quality or 0
        local newPrice
        pickup.OptionsPickupIndex = 0
        if not BECKY.RECEIVED_ITEMS[subtype] then
            if player:GetHearts() > 0 then
                if quality <= 2 then
                    newPrice = PickupPrice.PRICE_ONE_HEART
                else
                    newPrice = PickupPrice.PRICE_TWO_HEARTS
                end
            else
                newPrice = PickupPrice.PRICE_THREE_SOULHEARTS
            end
            pickup.AutoUpdatePrice = false
            pickup.Price = newPrice
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, BeckyMod.changePickupPrice, PickupVariant.PICKUP_COLLECTIBLE)]]

local markedPickup = {}
local markedRealPickup = {}

function BeckyMod:postNewRoom()
    local player = Isaac.GetPlayer()
    local room = game:GetRoom()

    if player:GetPlayerType() == BECKY.PLAYERTYPE and room:GetType() == RoomType.ROOM_DEVIL and room:IsFirstVisit() then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local pickup = entity:ToPickup()
            if pickup and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.Price ~= PickupPrice.PRICE_FREE then
                local pos = pickup.Position
                local subType = pickup.SubType
                local newPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, subType, pos, Vector(0, 0), nil):ToPickup()
                if newPickup then
                    newPickup.OptionsPickupIndex = 1
                    table.insert(BECKY.GENERATED_DEVIL_ITEMS, newPickup.InitSeed)
                end
                pickup:Remove()
            end
        end
    end
    if player:GetPlayerType() == BECKY.PLAYERTYPE then
        if room:GetType() == RoomType.ROOM_ANGEL then
            game:GetLevel():AddAngelRoomChance(50)
            BECKY.ENTERED_ANGEL_ROOM = true
            markedPickup = {}
            markedRealPickup = {}
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                local pickup = entity:ToPickup()
                if pickup and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                    table.insert(markedPickup, pickup.Position)
                end
                if pickup and pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE then
                    table.insert(markedRealPickup, pickup.Position)
                end
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BeckyMod.postNewRoom)

function BeckyMod:updateAngelPickupPrices()
    local player = Isaac.GetPlayer()
    local room = game:GetRoom()
    local itemConfig = Isaac.GetItemConfig()

    if player:GetPlayerType() == BECKY.PLAYERTYPE and room:GetType() == RoomType.ROOM_ANGEL then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local pickup = entity:ToPickup()
            if pickup and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local subtype = pickup.SubType
                local itemData = itemConfig:GetCollectible(subtype)
                local quality = itemData and itemData.Quality or 0
                local newPrice
                local matched = false
                
                for _, savedPosition in ipairs(markedPickup) do
                    if pickup.Position:Distance(savedPosition) < 1 then
                        matched = true
                        break
                    end
                end
                if not BECKY.RECEIVED_ITEMS[subtype] and matched then
                    if player:GetHearts() > 0 then
                        if quality <= 2 then
                            newPrice = PickupPrice.PRICE_ONE_HEART
                        else
                            newPrice = PickupPrice.PRICE_TWO_HEARTS
                        end
                    else
                        newPrice = PickupPrice.PRICE_THREE_SOULHEARTS
                    end
                    pickup.OptionsPickupIndex = 0
                    pickup.AutoUpdatePrice = false
                    pickup.Price = newPrice
                end
            end
            if pickup and PickupVariant ~= PickupVariant.PICKUP_COLLECTIBLE then
                local newPrice
                local matched = false
                for _, savedPosition in ipairs(markedRealPickup) do
                    if pickup.Position:Distance(savedPosition) < 1 then
                        matched = true
                        break
                    end
                end
                if matched then
                    newPrice = PickupPrice.PRICE_SPIKES
                    pickup.AutoUpdatePrice = false
                    pickup.Price = newPrice
                end  
            end
        end
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BeckyMod.updateAngelPickupPrices)

--[[function BeckyMod:updateAngelItems()
    local player = Isaac.GetPlayer()
    local room = game:GetRoom()

    if player:GetPlayerType() == BECKY.PLAYERTYPE and room:GetType() == RoomType.ROOM_ANGEL then
        for i, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local pos = entity.Position
                local item = entity:ToPickup()
                local subType = entity.SubType
                item.OptionsPickupIndex = 0
                if not player:HasCollectible(subType) and not subType == nil then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, entity.SubType, pos, Vector(0,0), nil)
                end
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, BeckyMod.updateAngelItems, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)]]

--Add angel deal chance instead of devil deal


function BeckyMod:angelDealChance()
    local player = Isaac.GetPlayer()
    local becky = player:GetPlayerType() == BECKY.PLAYERTYPE
    if not BECKY.ENTERED_ANGEL_ROOM and not BECKY.GOT_ANGEL_ITEM and becky and BECKY.FIRST_DEAL_RUN then
        game:GetLevel():AddAngelRoomChance(100)
    end
    if BECKY.ENTERED_ANGEL_ROOM and BECKY.GOT_ANGEL_ITEM and becky then
        game:GetLevel():AddAngelRoomChance(100)
    elseif BECKY.ENTERED_ANGEL_ROOM and not BECKY.GOT_ANGEL_ITEM and becky then
        local rngDoor = math.random(100)
        if rngDoor >= 50 then
            game:GetLevel():InitializeDevilAngelRoom(false, true)
        else
            game:GetLevel():InitializeDevilAngelRoom(true, false)
        end
    elseif not BECKY.ENTERED_ANGEL_ROOM and not BECKY.FIRST_DEAL_RUN and becky then
        game:GetLevel():InitializeDevilAngelRoom(false, true)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_ITEMS, BeckyMod.angelDealChance)


--checks if the player ever made a deal with in a angel room
function BeckyMod:gotAngelItem()
    local player = Isaac.GetPlayer()
    local becky = player:GetPlayerType() == BECKY.PLAYERTYPE
    if game:GetRoom():GetType() == RoomType.ROOM_ANGEL and becky then
        for _, entity in ipairs(Isaac:GetRoomEntities()) do
            if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local subType = entity.SubType
                if player:HasCollectible(subType) then
                    BECKY.GOT_ANGEL_ITEM = true
                end
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BeckyMod.gotAngelItem)

local bossIsDead = false

function BeckyMod:onBossDeath(entity)
    local player = Isaac.GetPlayer()
    local becky = player:GetPlayerType() == BECKY.PLAYERTYPE
    if becky and entity:IsBoss() then
        bossIsDead = true
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, BeckyMod.onBossDeath)

function BeckyMod:checkAngelRoomGen()
    if bossIsDead then
        local level = game:GetLevel()
        local currentRoomDesc = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)
        if currentRoomDesc.Data ~= nil then
            BECKY.FIRST_DEAL_RUN = false
            if BECKY.FIRST_DEAL_RUN == false then
                bossIsDead = false
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BeckyMod.checkAngelRoomGen)

function BeckyMod:onNewFloor()
    bossIsDead = false
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BeckyMod.onNewFloor)

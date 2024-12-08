local PLAYER_BECKY = Isaac.GetPlayerTypeByName("Becky", false)
local game = Game()
local receivedItems = {}
local generatedDevilItems = {}

local enteredAngelRoom = false
local gotAngelItem = false
local firstDealRun = true

function BeckyMod:OnPreAddCollectible(type)
    receivedItems[type] = true
    return true
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, BeckyMod.OnPreAddCollectible)

function BeckyMod:OnInit()
    local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/becky_hair.anm2")
    local player = Isaac.GetPlayer()
    if player:GetPlayerType() == PLAYER_BECKY then
        player:AddNullCostume(hairCostume)
    end
    receivedItems = {}
    generatedDevilItems = {}
    firstDealRun = true
    gotAngelItem = false
    enteredAngelRoom = false
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BeckyMod.OnInit)

function BeckyMod:changePickupPrice(pickup)
    local player = Isaac.GetPlayer()
    local room = game:GetRoom()
    local itemConfig = Isaac.GetItemConfig()

    if player:GetPlayerType() == PLAYER_BECKY and room:GetType() == RoomType.ROOM_ANGEL then --for angel items
        local subtype = pickup.SubType
        local itemData = itemConfig:GetCollectible(subtype)
        local quality = itemData and itemData.Quality or 0
        local newPrice
        pickup.OptionsPickupIndex = 0
        if not receivedItems[subtype] then
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
BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, BeckyMod.changePickupPrice, PickupVariant.PICKUP_COLLECTIBLE)

function BeckyMod:generateDevilItems()
    local player = Isaac.GetPlayer()
    local room = game:GetRoom()

    if player:GetPlayerType() == PLAYER_BECKY and room:GetType() == RoomType.ROOM_DEVIL and room:IsFirstVisit() then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local pickup = entity:ToPickup()
            if pickup and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.Price ~= PickupPrice.PRICE_FREE then
                local pos = pickup.Position
                local subType = pickup.SubType
                local newPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, subType, pos, Vector(0, 0), nil):ToPickup()
                if newPickup then
                    newPickup.OptionsPickupIndex = 1
                    table.insert(generatedDevilItems, newPickup.InitSeed)
                end
                pickup:Remove()
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BeckyMod.generateDevilItems)

function BeckyMod:updateAngelPickupPrices()
    local player = Isaac.GetPlayer()
    local room = game:GetRoom()
    local itemConfig = Isaac.GetItemConfig()

    if player:GetPlayerType() == PLAYER_BECKY and room:GetType() == RoomType.ROOM_ANGEL then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local pickup = entity:ToPickup()
            if pickup and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local subtype = pickup.SubType
                local itemData = itemConfig:GetCollectible(subtype)
                local quality = itemData and itemData.Quality or 0
                local newPrice

                -- Evita atualizar pickups que já foram coletados
                if not receivedItems[subtype] then
                    if player:GetHearts() > 0 then
                        if quality <= 2 then
                            newPrice = PickupPrice.PRICE_ONE_HEART
                        else
                            newPrice = PickupPrice.PRICE_TWO_HEARTS
                        end
                    else
                        newPrice = PickupPrice.PRICE_THREE_SOULHEARTS
                    end

                    -- Atualiza o preço do pickup
                    pickup.OptionsPickupIndex = 0
                    pickup.AutoUpdatePrice = false
                    pickup.Price = newPrice
                end
            end
        end
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BeckyMod.updateAngelPickupPrices)

function BeckyMod:updateAngelItems()
    local player = Isaac.GetPlayer()
    local room = game:GetRoom()

    if player:GetPlayerType() == PLAYER_BECKY and room:GetType() == RoomType.ROOM_ANGEL then
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
BeckyMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, BeckyMod.updateAngelItems, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

--Add angel deal chance instead of devil deal


function BeckyMod:angelDealChance()
    local player = Isaac.GetPlayer()
    local becky = player:GetPlayerType() == PLAYER_BECKY
    if not enteredAngelRoom and not gotAngelItem and becky and firstDealRun then
        game:GetLevel():AddAngelRoomChance(100)
    end
    if enteredAngelRoom and gotAngelItem and becky then
        game:GetLevel():AddAngelRoomChance(100)
    elseif enteredAngelRoom and not gotAngelItem and becky then
        local rngDoor = math.random(100)
        if rngDoor >= 50 then
            game:GetLevel():InitializeDevilAngelRoom(false, true)
        else
            game:GetLevel():InitializeDevilAngelRoom(true, false)
        end
    elseif not enteredAngelRoom and not firstDealRun and becky then
        game:GetLevel():InitializeDevilAngelRoom(false, true)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_ITEMS, BeckyMod.angelDealChance)

function BeckyMod:enteringAngelRoom()
    local player = Isaac.GetPlayer()
    if player:GetPlayerType() == PLAYER_BECKY then
        if game:GetRoom():GetType() == RoomType.ROOM_ANGEL then
            game:GetLevel():AddAngelRoomChance(50)
            enteredAngelRoom = true
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BeckyMod.enteringAngelRoom)

--checks if the player ever made a deal with in a angel room
function BeckyMod:gotAngelItem()
    local player = Isaac.GetPlayer()
    local becky = player:GetPlayerType() == PLAYER_BECKY
    if game:GetRoom():GetType() == RoomType.ROOM_ANGEL and becky then
        for _, entity in ipairs(Isaac:GetRoomEntities()) do
            if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local subType = entity.SubType
                if player:HasCollectible(subType) then
                    gotAngelItem = true
                end
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BeckyMod.gotAngelItem)

local bossIsDead = false

function BeckyMod:onBossDeath(entity)
    local player = Isaac.GetPlayer()
    local becky = player:GetPlayerType() == PLAYER_BECKY
    if becky and entity:IsBoss() then
        print("Boss defeated")
        bossIsDead = true
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, BeckyMod.onBossDeath)

function BeckyMod:checkAngelRoomGen()
    if bossIsDead then
        local level = game:GetLevel()
        local currentRoomDesc = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)
        if currentRoomDesc.Data ~= nil then
            firstDealRun = false
            if firstDealRun == false then
                bossIsDead = false
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BeckyMod.checkAngelRoomGen)

local BECKY = {}

BECKY.PLAYERTYPE = Isaac.GetPlayerTypeByName("Becky", false)
BECKY.POCKET_ITEM = BeckyMod.Item.HAND_MADE_BIBLE.ID

BECKY.HAIR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_hair.anm2")
BECKY.BODY_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_body.anm2")

BeckyMod.Character.BECKY = BECKY

local game = BeckyMod.Game

function BECKY:OnPreAddCollectible(type, _, _, _, _, player)
    local runSave = BeckyMod:RunSave(player)
    if runSave.BECKY_RECEIVED_ITEMS then
        runSave.BECKY_RECEIVED_ITEMS[type] = true
    else
        runSave.BECKY_RECEIVED_ITEMS = { }
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, BECKY.OnPreAddCollectible)

function BECKY:OnInit(player)
    if player:GetPlayerType() == BECKY.PLAYERTYPE then
        player:AddNullCostume(BECKY.HAIR_COSTUME)
        player:AddNullCostume(BECKY.BODY_COSTUME)

        player:SetPocketActiveItem(BECKY.POCKET_ITEM, ActiveSlot.SLOT_POCKET, true)

        Scheduler.Schedule( --Needs to wait for a frame lol
	    	1,
	    	function()
	    		player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
                player:EvaluateItems()
	    	end,
	    	{ player }
	    )

        game:GetItemPool():RemoveCollectible(BECKY.POCKET_ITEM)
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BECKY.OnInit)

local markedPickup = {}
local markedRealPickup = {}

function BECKY:postNewRoom()
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)
    local room = game:GetRoom()

    if player then
        if room:GetType() == RoomType.ROOM_DEVIL and room:IsFirstVisit() then
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                local pickup = entity:ToPickup()
                if pickup and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.Price ~= PickupPrice.PRICE_FREE then
                    local pos = pickup.Position
                    local subType = pickup.SubType
                    local newPickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, subType, pos, Vector(0, 0), nil):ToPickup()
                    if newPickup then
                        newPickup.OptionsPickupIndex = 1
                    end
                    pickup:Remove()
                end
            end
        end

        if room:GetType() == RoomType.ROOM_ANGEL then
            local runSave = BeckyMod:RunSave(player)

            game:GetLevel():AddAngelRoomChance(50)
            runSave.ENTERED_ANGEL_ROOM = true
            markedPickup = {}
            markedRealPickup = {}
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                local pickup = entity:ToPickup()
                if pickup then
                    table.insert((pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE) and markedPickup or markedRealPickup, pickup.Position)
                end
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BECKY.postNewRoom)

function BECKY:updateAngelPickupPrices()
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)
    local room = game:GetRoom()

    if player and room:GetType() == RoomType.ROOM_ANGEL then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local pickup = entity:ToPickup()
            if pickup and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                local subtype = pickup.SubType
                local itemData = Isaac.GetItemConfig():GetCollectible(subtype)
                local price = itemData and itemData.DevilPrice or 1
                local newPrice
                local matched = false

                for _, savedPosition in ipairs(markedPickup) do
                    if pickup.Position:Distance(savedPosition) < 1 then
                        matched = true
                        break
                    end
                end
                if not BeckyMod:RunSave(player).BECKY_RECEIVED_ITEMS[subtype] and matched then
                    if player:GetHearts() > 0 then
                        if price == 1 then
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

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BECKY.updateAngelPickupPrices)

--Add angel deal chance instead of devil deal

function BECKY:angelDealChance()
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)

    if player then
        local runSave = BeckyMod:RunSave(player)
        if not runSave.FIRST_DEAL_RUN then
            runSave.FIRST_DEAL_RUN = true
        end

        if not runSave.ENTERED_ANGEL_ROOM and not runSave.GOT_ANGEL_ITEM and runSave.FIRST_DEAL_RUN then
            game:GetLevel():AddAngelRoomChance(100)
        end
        if runSave.ENTERED_ANGEL_ROOM and runSave.GOT_ANGEL_ITEM then
            game:GetLevel():AddAngelRoomChance(100)
        elseif runSave.ENTERED_ANGEL_ROOM and not runSave.GOT_ANGEL_ITEM then
            local rngDoor = math.random(100)
            if rngDoor >= 50 then
                game:GetLevel():InitializeDevilAngelRoom(false, true)
            else
                game:GetLevel():InitializeDevilAngelRoom(true, false)
            end
        elseif not runSave.ENTERED_ANGEL_ROOM and not runSave.FIRST_DEAL_RUN then
            game:GetLevel():InitializeDevilAngelRoom(false, true)
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_ITEMS, BECKY.angelDealChance)


--checks if the player ever made a deal with in a angel room
function BECKY:gotAngelItem()
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)

    if player and game:GetRoom():GetType() == RoomType.ROOM_ANGEL then
        for _, entity in ipairs(Isaac:GetRoomEntities()) do
            if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                if player:HasCollectible(entity.SubType) then
                    BeckyMod:RunSave(player).GOT_ANGEL_ITEM = true
                end
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BECKY.gotAngelItem)

function BECKY:onBossDeath(entity)
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)
    if player and entity:IsBoss() then
        BeckyMod:RunSave(player).bossIsDead = true
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, BECKY.onBossDeath)

function BECKY:checkAngelRoomGen()
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)

    if player then
        local runSave = BeckyMod:RunSave(player)

        if runSave.bossIsDead then
            local level = game:GetLevel()
            local currentRoomDesc = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)
            if currentRoomDesc.Data ~= nil then
                runSave.FIRST_DEAL_RUN = false
                runSave.bossIsDead = false
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BECKY.checkAngelRoomGen)

function BECKY:onNewFloor()
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)

    if player then
        local runSave = BeckyMod:RunSave(player)
        runSave.bossIsDead = false
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, BECKY.onNewFloor)

local BECKY = {}

BECKY.PLAYERTYPE = Isaac.GetPlayerTypeByName("Becky", false)
BECKY.POCKET_ITEM = BeckyMod.Item.HAND_MADE_BIBLE.ID

BECKY.HAIR_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_hair.anm2")
BECKY.BODY_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/becky_body.anm2")

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

BeckyMod.Character.BECKY = BECKY

local game = BeckyMod.Game

--Deal modifiers (keeper's passive, blue baby's passive, or modded stuff)
--Modded example: Tarnished Judas

BECKY.DealModifiers = BECKY.DealModifiers or {
    ["KEEPER"] = {
        priority = -100,
        condition = function()
            return BeckyMod:IsAnyoneKeeper()
        end,
        modification = function(pickup, price)
            pickup.Price = price*15
        end,
    },
    ["BLUE BABY"] = {
        priority = 500,
        condition = function()
            return PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BLUEBABY)
        end,
        modification = function(pickup, price)
            if price == 1 then
                pickup.Price = PickupPrice.PRICE_ONE_SOUL_HEART
            else
                pickup.Price = PickupPrice.PRICE_TWO_SOUL_HEARTS
            end
        end,
    },
}

---Add a custom deal modifiers. Can add multiple at the same time.
---Sorts them later after adding, lower priority means that it goes before!
function BECKY.AddDealModifiers(dealModifiers)
    for name, data in pairs(dealModifiers) do
        BECKY.DealModifiers[name] = data
    end

    table.sort(BECKY.DealModifiers, function (a, b)
        return a.priority < b.priority
    end)
end

--End of deal modifiers

function BECKY:OnInit(player)
    if player:GetPlayerType() == BECKY.PLAYERTYPE then
        player:AddNullCostume(BECKY.HAIR_COSTUME)
        player:AddNullCostume(BECKY.BODY_COSTUME)

        player:SetPocketActiveItem(BECKY.POCKET_ITEM, ActiveSlot.SLOT_POCKET, true)

        Scheduler.Schedule( --Needs to wait for a frame to spawn the ghost haha
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

function BECKY:postNewRoom()
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)

    if player then
        local room = game:GetRoom()
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
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BECKY.postNewRoom)

function BECKY:updateAngelDealPrice(pickup)
    if not BeckyMod:GetRerollPersistentData(pickup).beckyPassiveChecked then
        return
    end

    if PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_YOUR_SOUL) then
        pickup.Price = PickupPrice.PRICE_SOUL
        return
    end

    local subtype = pickup.SubType
    local itemData = Isaac.GetItemConfig():GetCollectible(subtype)
    local price = itemData and itemData.DevilPrice or 1

    local resultingType = ""

    if BeckyMod:IsAnyoneKeeper() then
        resultingType = "KEEPER"
    elseif PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BLUEBABY) then
        resultingType = "BLUE BABY"
    end

    if resultingType == "KEEPER" then
        --If any player is keeper
        pickup.Price = price*15
    elseif resultingType == "BLUE BABY" then
        --If someone is blue baby
        if price == 1 then
            pickup.Price = PickupPrice.PRICE_ONE_SOUL_HEART
        else
            pickup.Price = PickupPrice.PRICE_TWO_SOUL_HEARTS
        end
    else
        --TO DO: ADD MOD COMPATIBILITY

        

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
end

function BECKY:initAngelPickupPrices(pickup)
    local becky = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)
    local room = game:GetRoom()

    if becky
        and room:GetType() == RoomType.ROOM_ANGEL 
        and pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL
		and pickup:Exists()
		and (pickup.Price < 0 or room:GetFrameCount() <= 1)
        and pickup.FrameCount <= 1
    then
        local pData = BeckyMod:GetRerollPersistentData(pickup)

        if pickup.FrameCount <= 1 and not pData.beckyPassiveChecked then
            pData.beckyPassiveChecked = true

            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                BECKY:updateAngelDealPrice(pickup)
            else
                if not BECKY.ExcludeSpikePickupVariants[pickup.Variant] then
                    pickup.Price = PickupPrice.PRICE_SPIKES
                end
            end

            pickup.AutoUpdatePrice = false

            Scheduler.Schedule(1, function()
                pickup.OptionsPickupIndex = 0
            end)
        end
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, BECKY.initAngelPickupPrices)

function BECKY:updateAngelItemPrices()
    local becky = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)

    if becky
    and game:GetRoom():GetType() == RoomType.ROOM_ANGEL 
    then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            local pickup = entity:ToPickup()
            if pickup 
            and pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL
            and pickup:Exists()
            and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE
            then
                BECKY:updateAngelDealPrice(pickup)
            end
        end
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_PLAYER_ADD_HEARTS, BECKY.updateAngelItemPrices)

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

function BECKY:checkAngelItem(_, player)
    local player = player:ToPlayer()

    if player
        and player:GetPlayerType() == BECKY.PLAYERTYPE
        and game:GetRoom():GetType() == RoomType.ROOM_ANGEL
        and player:CanPickupItem()
        and player:IsExtraAnimationFinished()
    then
        local firstBecky = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE) --Mod only checks the first becky for everything else
        BeckyMod:RunSave(firstBecky).GOT_ANGEL_ITEM = true

        Scheduler.Schedule(
	    	1,
	    	function()
                for _, entity in ipairs(Isaac.GetRoomEntities()) do
                    local pickup = entity:ToPickup()
                    if pickup 
                    and pickup.SubType ~= CollectibleType.COLLECTIBLE_NULL
                    and pickup:Exists()
                    and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE
                    then
                        BECKY:updateAngelDealPrice(pickup)
                    end
                end
            end
	    )
    end
end

--Needs to run late in case a mod says "nuh uh" and stops you from colliding with it

BeckyMod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, BECKY.checkAngelItem, PickupVariant.PICKUP_COLLECTIBLE)

function BECKY:onBossDeath(entity)
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)
    if player and entity:IsBoss() then
        BeckyMod:FloorSave(player).bossIsDead = true
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, BECKY.onBossDeath)

function BECKY:checkAngelRoomGen()
    local player = PlayerManager.FirstPlayerByType(BECKY.PLAYERTYPE)

    if player then
        local runSave = BeckyMod:RunSave(player)
        local floorSave = BeckyMod:FloorSave(player)

        if floorSave.bossIsDead then
            local level = game:GetLevel()
            local currentRoomDesc = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)
            if currentRoomDesc.Data ~= nil then
                runSave.FIRST_DEAL_RUN = false
                floorSave.bossIsDead = false
            end
        end
    end
end
BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BECKY.checkAngelRoomGen)

local RIPPED_CARD = {}
RIPPED_CARD.ID = Isaac.GetCardIdByName("Ripped Card_BeckyMod")
RIPPED_CARD.ID2 = Isaac.GetCardIdByName("Ripped Card (Complete)_BeckyMod")
    
BeckyMod.Pickup.RIPPED_CARD = RIPPED_CARD

RIPPED_CARD.NULL_Items = {
    The_Magician = Isaac.GetNullItemIdByName("RIPPED_CARD_The_Magician"),
    The_Devil = Isaac.GetNullItemIdByName("RIPPED_CARD_The_Devil"),
    The_Empress = Isaac.GetNullItemIdByName("RIPPED_CARD_The_Empress"),
    Strength = Isaac.GetNullItemIdByName("RIPPED_CARD_Strength"),
    The_Hanged_Man = Isaac.GetNullItemIdByName("RIPPED_CARD_The_Hanged_Man"),
}
RIPPED_CARD.Achievement = Isaac.GetEntityVariantByName("Ripped Card")
local game = BeckyMod.Game



local CARDS_EFFECTS = {
    [Card.CARD_FOOL] = function(player, rng)
        local level = game:GetLevel()
        level.LeaveDoor = -1
        game:StartRoomTransition(
            level:GetRandomRoomIndex(false, rng:Next()),
            -1,
            RoomTransitionAnim.TELEPORT,
            player,
            level:GetDimension()
        )
    end,
    [Card.CARD_MAGICIAN] = function(player, rng)
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.The_Magician)

    end,
    [Card.CARD_HIGH_PRIESTESS] = function(player, rng)
        if Isaac.CountEnemies() == 0 then return end
        local enemyList = Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 50000, EntityPartition.ENEMY)
        
        enemyList = BeckyMod:ShuffleTable(enemyList, rng)
        local target
        for i=1, #enemyList do
            if enemyList[i]:CanShutDoors() then
                target = enemyList[i]
                break
            end
        end
        if target == nil then return end
        local hand = Isaac.Spawn(1000, EffectVariant.MOMS_HAND, 0, target.Position, Vector.Zero, player):ToEffect()
        hand.Target = target

    end,
    [Card.CARD_EMPRESS] = function(player, rng)
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.The_Empress)

    end,
    [Card.CARD_EMPEROR] = function(player, rng)
        RIPPED_CARD.TeleportOutsideOf(RoomType.ROOM_BOSS, rng)

    end,
    [Card.CARD_HIEROPHANT] = function(player, rng)
        local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true, false)
        Isaac.Spawn(5, 10, HeartSubType.HEART_SOUL, spawnPos, Vector.Zero, player)

    end,
    [Card.CARD_LOVERS] = function(player, rng)
        local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true, false)
        Isaac.Spawn(5, 10, HeartSubType.HEART_FULL, spawnPos, Vector.Zero, player)

    end,
    [Card.CARD_CHARIOT] = function(player, rng)
        player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, true, 165, false) -- activates my little unicorn for 3.5 seconds

    end,
    [Card.CARD_JUSTICE] = function(player, rng)
        local coins = player:GetNumCoins()
        local bombs = player:GetNumBombs()
        local keys = player:GetNumKeys()
        local hearts = (player:GetEffectiveMaxHearts() - player:GetHearts()) *2

        local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true, false)
        
        if coins < bombs and coins < keys and coins < hearts then
            Isaac.Spawn(5, 20, 0, spawnPos, Vector.Zero, player)

        elseif keys < bombs and keys < coins and keys < hearts then
            Isaac.Spawn(5, 30, 0, spawnPos, Vector.Zero, player)

        elseif bombs < coins and bombs < keys and bombs < hearts then
            Isaac.Spawn(5, 40, 0, spawnPos, Vector.Zero, player)

        elseif hearts < bombs and hearts < keys and hearts < coins then
            Isaac.Spawn(5, 10, 0, spawnPos, Vector.Zero, player)
        else
            Isaac.Spawn(5, rng:RandomInt(1,4) *10, 0, spawnPos, Vector.Zero, player)
        end

    end,
    [Card.CARD_HERMIT] = function(player, rng)
        RIPPED_CARD.TeleportOutsideOf(RoomType.ROOM_SHOP, rng)

    end,
    [Card.CARD_WHEEL_OF_FORTUNE] = function(player, rng)
        player:UseActiveItem(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, UseFlag.USE_MIMIC)

    end,
    [Card.CARD_STRENGTH] = function(player, rng)
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.Strength)

    end,
    [Card.CARD_HANGED_MAN] = function(player, rng)
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.The_Hanged_Man)

    end,
    [Card.CARD_DEATH] = function(player, rng)
        if Isaac.CountEnemies() == 0 then return end
        local prevDis
        local target
        local playerPos = player.Position
        for _, ent in ipairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 50000, EntityPartition.ENEMY)) do
            if ent:CanShutDoors() and (target == nil or ent.Position:Distance(playerPos) < prevDis) then
                prevDis = ent.Position:Distance(playerPos)
                target = ent
            end
        end
        if target then
            target:TakeDamage(40, 0, EntityRef(player), 0)
        end
    end,
    [Card.CARD_TEMPERANCE] = function(player, rng)
        player:UseActiveItem(CollectibleType.COLLECTIBLE_IV_BAG, UseFlag.USE_MIMIC)

    end,
    [Card.CARD_DEVIL] = function(player, rng)
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.The_Devil)

    end,
    [Card.CARD_TOWER] = function(player, rng)
        Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_TROLL, 0, player.Position, Vector.Zero, player)

    end,
    [Card.CARD_STARS] = function(player, rng)
        RIPPED_CARD.TeleportOutsideOf(RoomType.ROOM_TREASURE, rng)

    end,
    [Card.CARD_MOON] = function(player, rng)
        RIPPED_CARD.TeleportOutsideOf(RoomType.ROOM_SECRET, rng)

    end,
    [Card.CARD_SUN] = function(player, rng)
        player:AddHearts(6)

        local levelRooms = BeckyMod:ShuffleTable(RIPPED_CARD.GetRooms(), rng)
        local roomsReveal = rng:RandomInt(3, 5)
        
        local level = game:GetLevel()

        for idx = #levelRooms, 1, -1 do
            if roomsReveal <= 0 then return end

            local room = level:GetRoomByIdx(levelRooms[idx])
            local displayFlags = room.DisplayFlags

            if displayFlags & (1<<2) > 0 then
                table.remove(levelRooms, idx)
            else
                room.DisplayFlags = displayFlags | RoomDescriptor.DISPLAY_ICON
                level:UpdateVisibility()
                roomsReveal = roomsReveal -1
            end
        end

    end,
    [Card.CARD_JUDGEMENT] = function(player, rng)
        --- TO DO
    end,
    [Card.CARD_WORLD] = function(player, rng)
        game:GetLevel():ApplyCompassEffect()
    end
}


local CARD_GROUPS = {
    {
        Card.CARD_FOOL,
        Card.CARD_EMPEROR,
        Card.CARD_HERMIT,
        Card.CARD_STARS,
        Card.CARD_MOON,
        Card.CARD_MAGICIAN,
        Card.CARD_WHEEL_OF_FORTUNE,
        Card.CARD_HANGED_MAN,
        Card.CARD_TEMPERANCE,
        Card.CARD_DEATH,
        Card.CARD_DEVIL,
    },
    {
        Card.CARD_JUDGEMENT,
        Card.CARD_HIGH_PRIESTESS,
        Card.CARD_EMPRESS,
        Card.CARD_HIEROPHANT,
        Card.CARD_LOVERS,
        Card.CARD_CHARIOT,
        Card.CARD_JUSTICE,
        Card.CARD_STRENGTH,
        Card.CARD_TOWER,
        Card.CARD_SUN,
        Card.CARD_WORLD,
    },
    TeleportCards = {
        [Card.CARD_FOOL] = true,
        [Card.CARD_EMPEROR] = true,
        [Card.CARD_HERMIT] = true,
        [Card.CARD_STARS] = true,
        [Card.CARD_MOON] = true,
    }
}


function RIPPED_CARD.GetRooms()
	local returnList = {}
	local checkedSafeGrids = {}

	local levelRooms = game:GetLevel():GetRooms()
	for i = 0, levelRooms.Size -1 do
		local gridIdx = levelRooms:Get(i).SafeGridIndex
		local rType = levelRooms:Get(i).Data.Type

		if rType ~= RoomType.ROOM_ULTRASECRET and not checkedSafeGrids[gridIdx] then
			checkedSafeGrids[gridIdx] = true
			table.insert(returnList, gridIdx)
		end
	end

	return returnList
end


function RIPPED_CARD.TeleportOutsideOf(roomType, rng)
    local level = game:GetLevel()
    local returnList = {}
	local checkedSafeGrids = {}

	local levelRooms = level:GetRooms()
	for i = 0, levelRooms.Size -1 do
		local gridIdx = levelRooms:Get(i).SafeGridIndex
		local rType = levelRooms:Get(i).Data.Type

		if rType == roomType and not checkedSafeGrids[gridIdx] then
			checkedSafeGrids[gridIdx] = true
			table.insert(returnList, levelRooms:Get(i))
		end
	end

    if #returnList == 0 then
        level.LeaveDoor = -1
        game:StartRoomTransition(
            level:GetRandomRoomIndex(false, rng:Next()),
            -1,
            RoomTransitionAnim.TELEPORT,
            player,
            level:GetDimension()
        )
        return
    end

    local roomDesc = returnList[ rng:RandomInt(1, #returnList) ]
    local neighbors = {}

    for doorSlot, neighDesc in pairs(roomDesc:GetNeighboringRooms()) do
        if neighDesc.Data and neighDesc.Data.Type ~= RoomType.ROOM_SECRET then
            table.insert(neighbors, neighDesc)
        end
    end

    if #neighbors == 0 then
        level.LeaveDoor = -1
        game:StartRoomTransition(
            level:GetRandomRoomIndex(false, rng:Next()),
            -1,
            RoomTransitionAnim.TELEPORT,
            player,
            level:GetDimension()
        )
        return
    end

    local targetRoom = neighbors[ rng:RandomInt(1, #neighbors) ]
    level.LeaveDoor = -1

    game:StartRoomTransition(
        targetRoom.SafeGridIndex,
        -1,
        RoomTransitionAnim.TELEPORT,
        player,
        targetRoom:GetDimension()
    )
end


function RIPPED_CARD:UseCard(CardId, player, useFlags)
    if useFlags & UseFlag.USE_CARBATTERY > 0 then return end
    local rng = player:GetCardRNG(RIPPED_CARD.ID)
    local copyCard = rng:RandomInt(Card.CARD_FOOL, Card.CARD_WORLD)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
        player:UseCard(copyCard, UseFlag.USE_MIMIC | UseFlag.USE_NOANNOUNCER)
        return
    end
    --print(copyCard)
    --Isaac.DebugString("Ripped Card copy "..copyCard)

    CARDS_EFFECTS[copyCard](player, rng)
end


local DO_ON_NEW_ROOM = {}
function RIPPED_CARD:UseCard2(CardId, player, useFlags) --- patched stuff
    if useFlags & UseFlag.USE_CARBATTERY > 0 then return end
    local rng = player:GetCardRNG(RIPPED_CARD.ID)
    local card1 = CARD_GROUPS[1][rng:RandomInt(1, #CARD_GROUPS[1])]
    local card2 = CARD_GROUPS[2][rng:RandomInt(1, #CARD_GROUPS[2])]

    if player:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
        player:UseCard(card1, UseFlag.USE_MIMIC | UseFlag.USE_NOANNOUNCER)
        if CARD_GROUPS.TeleportCards[card1] then
            table.insert(DO_ON_NEW_ROOM, {Player = player, CardId = card2, TarotCloth = true})
        else
            player:UseCard(card2, UseFlag.USE_MIMIC | UseFlag.USE_NOANNOUNCER)
        end
        return
    end
    
    CARDS_EFFECTS[card1](player, rng)
    if CARD_GROUPS.TeleportCards[card1] then
        table.insert(DO_ON_NEW_ROOM, {Player = player, CardId = card2, TarotCloth = false})
    else
        CARDS_EFFECTS[card2](player, rng)
    end

    --local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true, false)
    --Isaac.Spawn(5, 300, rng:RandomInt(Card.CARD_FOOL, Card.CARD_WORLD), spawnPos, Vector.Zero, player)
end

function RIPPED_CARD:OnNewRoom()
    for _, data in ipairs(DO_ON_NEW_ROOM) do

        local player = data.Player
        if data.TarotCloth then
            player:UseCard(data.CardId, UseFlag.USE_MIMIC | UseFlag.USE_NOANNOUNCER)
        else
            CARDS_EFFECTS[data.CardId](player, player:GetCardRNG(RIPPED_CARD.ID))
        end
    end
    
    DO_ON_NEW_ROOM = {}
end


function RIPPED_CARD:TearHitParams(player, tearParams, weaponType, damageScale, tearDisplacement, src)
    local effects = player:GetEffects()
    if effects:HasNullEffect(RIPPED_CARD.NULL_Items.The_Magician) then
        local rng = player:GetCardRNG(Card.CARD_MAGICIAN)
        if rng:RandomInt(6) == 0 then
            tearParams.TearFlags = tearParams.TearFlags | TearFlags.TEAR_HOMING
            if weaponType == WeaponType.WEAPON_BRIMSTONE or weaponType == WeaponType.WEAPON_LASER or weaponType == WeaponType.WEAPON_TECH_X then
                tearParams.TearColor = tearParams.TearColor * Color.LaserHoming
            else
                tearParams.TearColor = tearParams.TearColor * Color.TearHoming
            end
        end
    end
    if effects:HasNullEffect(RIPPED_CARD.NULL_Items.The_Hanged_Man) then
        tearParams.TearColor = tearParams.TearColor * Color(1.5, 2, 2, 0.5, 0, 0, 0)
    end
end


function RIPPED_CARD:Cache(player, cacheFlags)
    local effects = player:GetEffects()
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        if effects:HasNullEffect(RIPPED_CARD.NULL_Items.The_Devil) then
            player.Damage = player.Damage + 1.25 * effects:GetNullEffectNum(RIPPED_CARD.NULL_Items.The_Devil)
        end
        if effects:HasNullEffect(RIPPED_CARD.NULL_Items.The_Empress) then
            player.Damage = player.Damage + 0.9 * effects:GetNullEffectNum(RIPPED_CARD.NULL_Items.The_Empress)
        end
        if effects:HasNullEffect(RIPPED_CARD.NULL_Items.Strength) then
            player.Damage = (player.Damage * 1.28) + 0.5 * effects:GetNullEffectNum(RIPPED_CARD.NULL_Items.Strength)
        end
    elseif cacheFlags & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE then
        if effects:HasNullEffect(RIPPED_CARD.NULL_Items.Strength) then
            player.TearRange = player.TearRange + 1.25 * effects:GetNullEffectNum(RIPPED_CARD.NULL_Items.Strength) *40
        end
    elseif cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        if effects:HasNullEffect(RIPPED_CARD.NULL_Items.The_Empress) then
            player.MoveSpeed = player.MoveSpeed + 0.12 * effects:GetNullEffectNum(RIPPED_CARD.NULL_Items.The_Empress)
        end
        if effects:HasNullEffect(RIPPED_CARD.NULL_Items.Strength) then
            player.MoveSpeed = player.MoveSpeed + 0.12 * effects:GetNullEffectNum(RIPPED_CARD.NULL_Items.Strength)
        end
        if effects:HasNullEffect(RIPPED_CARD.NULL_Items.The_Hanged_Man) then
            player.MoveSpeed = player.MoveSpeed + 0.06 * effects:GetNullEffectNum(RIPPED_CARD.NULL_Items.The_Hanged_Man)
        end
    elseif cacheFlags & CacheFlag.CACHE_TEARFLAG == CacheFlag.CACHE_TEARFLAG then
        if effects:HasNullEffect(RIPPED_CARD.NULL_Items.The_Hanged_Man) then
            player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
        end
    end
end


function RIPPED_CARD:PreCollectCard(player, pickup)

    for slot=0, PillCardSlot.QUATERNARY do
        local slotInfo = player:GetPocketItem(slot)
        if slotInfo:GetType() == PocketItemType.CARD and player:GetCard(slot) == RIPPED_CARD.ID then
            --local rng = player:GetCardRNG(RIPPED_CARD.ID)

            --local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true, false)
            --Isaac.Spawn(5, 300, rng:RandomInt(Card.CARD_FOOL, Card.CARD_WORLD), spawnPos, Vector.Zero, player)
            player:RemovePocketItem(slot)
            player:AddCard(RIPPED_CARD.ID2, "UseItem")
            player:AnimateCard(RIPPED_CARD.ID2)
            local cardConfig = Isaac.GetItemConfig():GetCard(RIPPED_CARD.ID2)
            game:GetHUD():ShowItemText(cardConfig.Name, cardConfig.Description)

            BeckyMod.SFX:Play(SoundEffect.SOUND_PAPER_OUT)
            pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            pickup:GetSprite():Play("Collect", true)
            pickup:Die()
            return false
        end
    end

end


function RIPPED_CARD:GetCard(rng, cardId, includePlay, includeRunes, runesOnly)
    --if not Isaac.GetPersistentGameData():Unlocked(RIPPED_CARD.Achievement) then return end
    if runesOnly then return end
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        for slot=0, PillCardSlot.QUATERNARY do
            local cardSlot = player:GetCard(slot)
            if cardSlot == RIPPED_CARD.ID or cardSlot == RIPPED_CARD.ID2 then
                if rng:RandomInt(10) == 0 then return RIPPED_CARD.ID end
                break
            end
        end
    end
end


BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_TEAR_HIT_PARAMS, RIPPED_CARD.TearHitParams)
BeckyMod:AddCallback(ModCallbacks.MC_USE_CARD, RIPPED_CARD.UseCard, RIPPED_CARD.ID)
BeckyMod:AddCallback(ModCallbacks.MC_USE_CARD, RIPPED_CARD.UseCard2, RIPPED_CARD.ID2)
BeckyMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, RIPPED_CARD.Cache)
BeckyMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLECT_CARD, RIPPED_CARD.PreCollectCard, RIPPED_CARD.ID)
BeckyMod:AddCallback(ModCallbacks.MC_GET_CARD, RIPPED_CARD.GetCard)
BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM , RIPPED_CARD.OnNewRoom)
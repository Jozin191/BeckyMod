local RIPPED_CARD = {}
    
BeckyMod.Pickup.RIPPED_CARD = RIPPED_CARD

RIPPED_CARD.ID = Isaac.GetCardIdByName("Ripped Card_BeckyMod")
RIPPED_CARD.ID2 = Isaac.GetCardIdByName("Ripped Card (Complete)_BeckyMod")
RIPPED_CARD.NULL_Items = {
    The_Magician = Isaac.GetNullItemIdByName("RIPPED_CARD_The_Magician"),
    The_Devil = Isaac.GetNullItemIdByName("RIPPED_CARD_The_Devil"),
    The_Empress = Isaac.GetNullItemIdByName("RIPPED_CARD_The_Empress"),
    Strength = Isaac.GetNullItemIdByName("RIPPED_CARD_Strength"),
    The_Hanged_Man = Isaac.GetNullItemIdByName("RIPPED_CARD_The_Hanged_Man"),
}
RIPPED_CARD.Achievement = Isaac.GetEntityVariantByName("Ripped Card")
local game = BeckyMod.Game


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
        if neighDesc.Data.Type ~= RoomType.ROOM_SECRET then
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
        neighbors.SafeGridIndex,
        -1,
        RoomTransitionAnim.TELEPORT,
        player,
        level:GetDimension()
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

    if copyCard == Card.CARD_FOOL then
        local level = game:GetLevel()
        level.LeaveDoor = -1
        game:StartRoomTransition(
            level:GetRandomRoomIndex(false, rng:Next()),
            -1,
            RoomTransitionAnim.TELEPORT,
            player,
            level:GetDimension()
        )
    elseif copyCard == Card.CARD_MAGICIAN then
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.The_Magician)

    elseif copyCard == Card.CARD_HIGH_PRIESTESS then
        if Isaac.CountEnemies() == 0 then return end
        local enemyList = Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 50000, EntityPartition.ENEMY)
        
        local target = BeckyMod:ShuffleTable(enemyList, rng)[1]
        local hand = Isaac.Spawn(1000, EffectVariant.MOMS_HAND, 0, target.Position, Vector.Zero, player):ToEffect()
        hand.Target = target

    elseif copyCard == Card.CARD_EMPRESS then
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.The_Empress)

    elseif copyCard == Card.CARD_EMPEROR then
        RIPPED_CARD.TeleportOutsideOf(RoomType.ROOM_BOSS, rng)

    elseif copyCard == Card.CARD_HIEROPHANT then
        local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true, false)
        Isaac.Spawn(5, 10, HeartSubType.HEART_SOUL, spawnPos, Vector.Zero, player)

    elseif copyCard == Card.CARD_LOVERS then
        local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true, false)
        Isaac.Spawn(5, 10, HeartSubType.HEART_FULL, spawnPos, Vector.Zero, player)

    elseif copyCard == Card.CARD_CHARIOT then
        player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_MY_LITTLE_UNICORN, true, 165, false) -- activates my little unicorn for 3.5 seconds

    elseif copyCard == Card.CARD_JUSTICE then
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

    elseif copyCard == Card.CARD_HERMIT then
        RIPPED_CARD.TeleportOutsideOf(RoomType.ROOM_SHOP, rng)

    elseif copyCard == Card.CARD_WHEEL_OF_FORTUNE then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_PORTABLE_SLOT, UseFlag.USE_MIMIC)

    elseif copyCard == Card.CARD_STRENGTH then
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.Strength)

    elseif copyCard == Card.CARD_HANGED_MAN then
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.The_Hanged_Man)

    elseif copyCard == Card.CARD_DEATH then
        if Isaac.CountEnemies() == 0 then return end
        local prevDis
        local target
        local playerPos = player.Position
        for _, ent in ipairs(Isaac.FindInRadius(game:GetRoom():GetCenterPos(), 50000, EntityPartition.ENEMY)) do
            if target == nil or ent.Position:Distance(playerPos) < prevDis then
                prevDis = ent.Position:Distance(playerPos)
                target = ent
            end
        end
        if target then
            target:TakeDamage(40, 0, EntityRef(player), 0)
        end
    elseif copyCard == Card.CARD_TEMPERANCE then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_IV_BAG, UseFlag.USE_MIMIC)

    elseif copyCard == Card.CARD_DEVIL then
        player:AddNullItemEffect(RIPPED_CARD.NULL_Items.The_Devil)

    elseif copyCard == Card.CARD_TOWER then
        Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_TROLL, 0, player.Position, Vector.Zero, player)

    elseif copyCard == Card.CARD_STARS then
        RIPPED_CARD.TeleportOutsideOf(RoomType.ROOM_TREASURE, rng)

    elseif copyCard == Card.CARD_MOON then
        RIPPED_CARD.TeleportOutsideOf(RoomType.ROOM_SECRET, rng)

    elseif copyCard == Card.CARD_SUN then
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

    elseif copyCard == Card.CARD_JUDGEMENT then

        --- TO DO

    elseif copyCard == Card.CARD_WORLD then
        game:GetLevel():ApplyCompassEffect()
    end
end

function RIPPED_CARD:UseCard2(CardId, player, useFlags) --- full stuff
    local rng = player:GetCardRNG(RIPPED_CARD.ID)

    local spawnPos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 40, true, false)
    Isaac.Spawn(5, 300, rng:RandomInt(Card.CARD_FOOL, Card.CARD_WORLD), spawnPos, Vector.Zero, player)
end


function RIPPED_CARD:TearHitParams(player, tearParams, weaponType, damageScale, tearDisplacement, src)
    if player:GetEffects():HasNullEffect(RIPPED_CARD.NULL_Items.The_Magician) then
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
    elseif cacheFlags & CacheFlag.CACHE_TEARCOLOR == CacheFlag.CACHE_TEARCOLOR then
        if effects:HasNullEffect(RIPPED_CARD.NULL_Items.The_Hanged_Man) then
            player.TearColor = player.TearColor * Color(1.5, 2, 2, 0.5, 0, 0, 0)
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


function RIPPED_CARD:GetCard(rng, cardId)
    --if not Isaac.GetPersistentGameData():Unlocked(RIPPED_CARD.Achievement) then return end
    for _, player in ipairs(PlayerManager.GetPlayers()) do
        for slot=0, PillCardSlot.QUATERNARY do
            if player:GetCard(slot) == RIPPED_CARD.ID then
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
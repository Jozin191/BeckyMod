local CHALLENGE_ID = Isaac.GetChallengeIdByName("Poltergeist")
local game = BeckyMod.Game

local validDoors = {
	[RoomShape.ROOMSHAPE_1x1] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.UP0]=true,
        [DoorSlot.RIGHT0]=true,
        [DoorSlot.DOWN0]=true,
    },
	[RoomShape.ROOMSHAPE_IH] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.RIGHT0]=true,
    },
	[RoomShape.ROOMSHAPE_IV] = {
        [DoorSlot.UP0]=true,
        [DoorSlot.DOWN0]=true,
    },
	[RoomShape.ROOMSHAPE_1x2] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.LEFT1]=true,
        [DoorSlot.UP0]=true,
        [DoorSlot.RIGHT0]=true,
        [DoorSlot.RIGHT1]=true,
        [DoorSlot.DOWN0]=true,
    },
	[RoomShape.ROOMSHAPE_IIV] = {
        [DoorSlot.UP0]=true,
        [DoorSlot.DOWN0]=true,
    },
	[RoomShape.ROOMSHAPE_2x1] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.UP0]=true,
        [DoorSlot.UP1]=true,
        [DoorSlot.RIGHT0]=true,
        [DoorSlot.DOWN0]=true,
        [DoorSlot.DOWN1]=true,
    },
	[RoomShape.ROOMSHAPE_IIH] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.RIGHT0]=true,
    },
	[RoomShape.ROOMSHAPE_2x2] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.LEFT1]=true,
        [DoorSlot.UP0]=true,
        [DoorSlot.UP1]=true,
        [DoorSlot.RIGHT0]=true,
        [DoorSlot.DOWN0]=true,
        [DoorSlot.RIGHT1]=true,
    },
	[RoomShape.ROOMSHAPE_LTL] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.LEFT1]=true,
        [DoorSlot.UP0]=true,
        [DoorSlot.UP1]=true,
        [DoorSlot.RIGHT0]=true,
        [DoorSlot.DOWN0]=true,
        [DoorSlot.RIGHT1]=true,
    },
	[RoomShape.ROOMSHAPE_LTR] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.LEFT1]=true,
        [DoorSlot.UP0]=true,
        [DoorSlot.UP1]=true,
        [DoorSlot.RIGHT0]=true,
        [DoorSlot.DOWN0]=true,
        [DoorSlot.RIGHT1]=true,
    },
	[RoomShape.ROOMSHAPE_LBL] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.LEFT1]=true,
        [DoorSlot.UP0]=true,
        [DoorSlot.UP1]=true,
        [DoorSlot.RIGHT0]=true,
        [DoorSlot.DOWN0]=true,
        [DoorSlot.RIGHT1]=true,
    },
	[RoomShape.ROOMSHAPE_LBR] = {
        [DoorSlot.LEFT0]=true,
        [DoorSlot.LEFT1]=true,
        [DoorSlot.UP0]=true,
        [DoorSlot.UP1]=true,
        [DoorSlot.RIGHT0]=true,
        [DoorSlot.DOWN0]=true,
        [DoorSlot.RIGHT1]=true,
    },
}

local BIG_ROOMS = {
    [RoomShape.ROOMSHAPE_2x2] = true,
    [RoomShape.ROOMSHAPE_LTL] = true,
    [RoomShape.ROOMSHAPE_LTR] = true,
    [RoomShape.ROOMSHAPE_LBL] = true,
    [RoomShape.ROOMSHAPE_LBR] = true,
}

local POS_OFFSET = {
    [DoorSlot.LEFT0] = Vector( 40,  0),
    [DoorSlot.UP0] =   Vector(  0, 40),
    [DoorSlot.RIGHT0] =Vector(-40,  0),
    [DoorSlot.DOWN0] = Vector(  0,-40),
}

local SPAWN_POLTIES_ON_ROOM = {
    [RoomShape.ROOMSHAPE_1x1] = 1,
    [RoomShape.ROOMSHAPE_IH] = 1,
    [RoomShape.ROOMSHAPE_IV] = 1,
    [RoomShape.ROOMSHAPE_1x2] = 2,
    [RoomShape.ROOMSHAPE_IIV] = 1,
    [RoomShape.ROOMSHAPE_2x1] = 2,
    [RoomShape.ROOMSHAPE_IIH] = 1,
    [RoomShape.ROOMSHAPE_2x2] = 3,
    [RoomShape.ROOMSHAPE_LTL] = 3,
    [RoomShape.ROOMSHAPE_LTR] = 3,
    [RoomShape.ROOMSHAPE_LBL] = 3,
    [RoomShape.ROOMSHAPE_LBR] = 3,
}

local function SpawnDusts(pos, roomShape, opositeDoor)
    for i=1, SPAWN_POLTIES_ON_ROOM[roomShape] do
        local ent = Isaac.Spawn(EntityType.ENTITY_DUST, 0, 0, pos + POS_OFFSET[opositeDoor % 4], Vector.Zero, nil)
    end
end

BeckyMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if Isaac.GetChallenge() ~= CHALLENGE_ID then return end
    local room = game:GetRoom()
    if room:IsClear() then return end
    local grids = {}
    local level = game:GetLevel()
    local opositeDoor = level.EnterDoor + 2 % DoorSlot.NUM_DOOR_SLOTS
    local pos = room:GetDoorSlotPosition(opositeDoor)

    for idx=0, room:GetGridSize()-1 do
        if room:CanPickupGridEntity(idx) then
            table.insert(grids, idx)
        end
    end
    local roomShape = room:GetRoomShape()
    if not validDoors[roomShape][opositeDoor] then
        opositeDoor = opositeDoor % 4

        if not validDoors[roomShape][opositeDoor] then
            SpawnDusts(pos, roomShape, opositeDoor)
            return
        end
    end

    if #grids == 0 then
        SpawnDusts(pos, roomShape, opositeDoor)
        return
    elseif BIG_ROOMS[roomShape] and #grids <= 8 then
        Isaac.Spawn(EntityType.ENTITY_DUST, 0, 0, pos + POS_OFFSET[opositeDoor % 4], Vector.Zero, nil)
        Isaac.Spawn(EntityType.ENTITY_DUST, 0, 0, pos + POS_OFFSET[opositeDoor % 4], Vector.Zero, nil)
    elseif #grids <= 5 then
        Isaac.Spawn(EntityType.ENTITY_DUST, 0, 0, pos + POS_OFFSET[opositeDoor % 4], Vector.Zero, nil)
    end
    
    for i=1, SPAWN_POLTIES_ON_ROOM[roomShape] do
        local ent = Isaac.Spawn(EntityType.ENTITY_POLTY, 0, 0, pos + POS_OFFSET[opositeDoor % 4], Vector.Zero, nil)
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        ent:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_SPIKE_DAMAGE | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_QUERY)
    end
end)

BeckyMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, ent)
    if Isaac.GetChallenge() == CHALLENGE_ID then
        local sprt = ent:GetSprite()
        if sprt:IsPlaying("Idle") and Isaac.CountEnemies() == Isaac.CountEntities(nil, EntityType.ENTITY_POLTY) and game:GetRoom():GetFrameCount() > 5 then
            ent:Remove()
            return
        end
        ent.HitPoints = 99999999
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        sprt.Color.A = 0.66
    end
end, EntityType.ENTITY_POLTY)

--BeckyMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
--    if Isaac.GetChallenge() ~= CHALLENGE_ID then return end
--end)
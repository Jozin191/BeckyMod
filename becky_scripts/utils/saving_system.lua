---@diagnostic disable: undefined-field, cast-local-type

local Mod = BeckyMod

-- ==========================================
-- --- Becky Mod Utility Saving functions ---
-- ==========================================

--#region save functions

---@param player EntityPlayer
---@return string
---@function
function BeckyMod:GetPlayerString(player)
	if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
		return "PLAYERID_" .. player:GetCollectibleRNG(2):GetSeed() .. "_" .. player:GetCollectibleRNG(1):GetSeed()
	else
		return "PLAYERID_" .. player:GetCollectibleRNG(1):GetSeed() .. "_" .. player:GetCollectibleRNG(2):GetSeed()
	end
end

---Returns complete save data
---@return table
---@function
function BeckyMod:GameSave()
	return Mod.SaveManager.GetPersistentSave() ---@type table
end

---@param ent? Entity @If an entity is provided, returns an entity specific save within the run save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@return table
---@function
function BeckyMod:RunSave(ent, noHourglass)
	return Mod.SaveManager.GetRunSave(ent, noHourglass)
end

---@param ent? Entity  @If an entity is provided, returns an entity specific save within the floor save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@return table
---@function
function BeckyMod:FloorSave(ent, noHourglass)
	return Mod.SaveManager.GetFloorSave(ent, noHourglass)
end

---@param ent? Entity | Vector @If an entity is provided, returns an entity specific save within the roomFloor save, which is a floor-lasting save that has unique data per-room. If a Vector is provided, returns a grid index specific save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@param listIndex? integer @Returns data for the provided `listIndex` instead of the index of the current room.
---@return table
---@function
function BeckyMod:RoomSave(ent, noHourglass, listIndex)
	return Mod.SaveManager.GetRoomFloorSave(ent, noHourglass, listIndex)
end

---@param ent? Entity | Vector  @If an entity is provided, returns an entity specific save within the room save. If a Vector is provided, returns a grid index specific save. Otherwise, returns arbitrary data in the save not attached to an entity.
---@param noHourglass false|boolean? @If true, it'll look in a separate game save that is not affected by the Glowing Hourglass.
---@return table
---@function
function BeckyMod:TempSave(ent, noHourglass)
	return Mod.SaveManager.GetRoomSave(ent, noHourglass)
end

--#endregion

-- ===========================================
-- BeckyMod Pickup Utility Saving functions --
-- ===========================================

--- Gets given pickup's persistent data table or creates an empty one if it doesn't exist.
--- Use this if you intend to add persistent data to a pickup.
---@param pickup EntityPickup
---@return table
---@function
function BeckyMod:GetPickupData(pickup)
	local data = Mod.SaveManager.GetRoomFloorSave(pickup)
	return data.NoRerollSave
end

--- Gets given pickup's persistent data table.
--- Unlike GetPickupData, this function may return nil,
--- and doesn't create a persistent table.
--- Use this if you intend to read, but not add any persistent data.
---@param pickup EntityPickup
---@return table|nil
---@function
function BeckyMod:TryGetPickupData(pickup)
	local roomFloorSave = Mod.SaveManager.GetEntireSave().game.roomFloor
	local listIndexSave = roomFloorSave[tostring(Mod.Level():GetCurrentRoomDesc().ListIndex)]
	if not listIndexSave then return end
	local pickupData = listIndexSave[Mod.SaveManager.Utility.GetSaveIndex(pickup)]
	if not pickupData then return end
	return pickupData.NoRerollSave
end

---Gets given pickup's reroll persistent data table or creates an empty one if it doesn't exist.
---@param pickup EntityPickup
---@return table
function BeckyMod:GetRerollPersistentData(pickup)
	local data = Mod.SaveManager.GetRoomSave(pickup)
	return data.RerollSave
end

--- Gets given pickup's reroll persistent data table.
--- Unlike GetRerollPersistentData, this function may return nil,
--- and doesn't create a persistent table.
--- Use this if you intend to read, but not add any persistent data.
---@param pickup EntityPickup
---@return table?
function BeckyMod:TryGetRerollPersistentData(pickup)
	local roomFloorSave = Mod.SaveManager.GetEntireSave().game.roomFloor
	local listIndexSave = roomFloorSave[tostring(Mod.Level():GetCurrentRoomDesc().ListIndex)]
	if not listIndexSave then return end
	local pickupData = listIndexSave[Mod.SaveManager.Utility.GetSaveIndex(pickup)]
	if not pickupData then return end
	return pickupData.RerollSave
end

-- ===========================================
-- Cache functions ---------------------------
-- ===========================================

---@function
function BeckyMod:SetCacheNextFloor(cacheFlags)
	local run_save = BeckyMod:RunSave()
	if not run_save.CacheFlagsFloor then
		run_save.CacheFlagsFloor = 0
	end

	run_save.CacheFlagsFloor = run_save.CacheFlagsFloor | cacheFlags
end

-- ===========================================
-- Callback functions ------------------------
-- ===========================================

-- Cache Flag trigger on New floor
Mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, function()
	local run_save = BeckyMod:RunSave()
	if not run_save.CacheFlagsFloor then
		return
	end
	local cacheFlags = run_save.CacheFlagsFloor
	local num_players = Mod.Game:GetNumPlayers()
	for i = 0, (num_players - 1) do
		local player = Isaac.GetPlayer(i)
		player:AddCacheFlags(cacheFlags)
		player:EvaluateItems()
	end
	run_save.CacheFlagsFloor = nil
end)

-- ===========================================
-- Legacy functions ------------------------
-- ===========================================
-- For backwards compatibility

BeckyMod.PersistentDataHelper = {}
local pData = BeckyMod.PersistentDataHelper

--- Gets given pickup's persistent data table or creates an empty one if it doesn't exist.
--- Use this if you intend to add persistent data to a pickup.
---@param pickup EntityPickup
---@return table
---@function
---@scope BeckyMod.PersistentDataHelper
function pData:GetPickupData(pickup)
	local msg = "BeckyMod.PersistentDataHelper was used. This is a legacy function. Use BeckyMod:GetPickupData(pickup) instead!\n"
	BeckyMod:Log(msg)
	return BeckyMod:GetPickupData(pickup)
end

--putting this here since.... i dunno where else to put it sorry jozin/other modders

local function copyTable(sourceTab)
	local targetTab = {}
	sourceTab = sourceTab or {}
	
	if type(sourceTab) ~= "table" then
		error("[ERROR] - cucco_helper.copyTable - invalid argument #1, table expected, got " .. type(sourceTab), 2)
	end

	for i, v in pairs(sourceTab) do
		if type(v) == "table" then
			targetTab[i] = copyTable(sourceTab[i])
		else
			targetTab[i] = sourceTab[i]
		end
	end
	
	return targetTab
end

BeckyAchievementSystem = include("becky_scripts.utils.achievements")

-- Code below here was taken from Cucco's save data system
local GLOWING_HOURGLASS_DATA = {}
local TEMPORARY_DATA = {}
local script = {}
local modRef

modRef = BeckyMod ---@cast modRef any

function script:resetTemporaryData(entity)
	local hash = tostring(GetPtrHash(entity))
	TEMPORARY_DATA[hash] = nil
end

function script:postGlowingHourglassSave(slot)
	slot = slot + 1
	GLOWING_HOURGLASS_DATA[slot] = GLOWING_HOURGLASS_DATA[slot] or {}
    GLOWING_HOURGLASS_DATA[slot].TEMPORARY_DATA = copyTable(TEMPORARY_DATA)
end

function script:preGlowingHourglassLoad(slot)
	slot = slot + 1
	GLOWING_HOURGLASS_DATA[slot] = GLOWING_HOURGLASS_DATA[slot] or {}
    TEMPORARY_DATA = copyTable(GLOWING_HOURGLASS_DATA[slot].TEMPORARY_DATA)
end

--- Alternative to Entity::GetData()
---
--- Acts as a localized version to avoid incompatibilities with
--- other mods.
function BeckyMod.getData(entity)
	local hash = GetPtrHash(entity)
	TEMPORARY_DATA[hash] = TEMPORARY_DATA[hash] or {}

	return TEMPORARY_DATA[hash]
end

modRef:AddPriorityCallback(ModCallbacks.MC_POST_GLOWING_HOURGLASS_SAVE, -200, script.postGlowingHourglassSave)
modRef:AddPriorityCallback(ModCallbacks.MC_PRE_GLOWING_HOURGLASS_LOAD, -200, script.preGlowingHourglassLoad)
modRef:AddPriorityCallback(ModCallbacks.MC_FAMILIAR_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_TEAR_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_BOMB_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_SLOT_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_LASER_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_KNIFE_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_EFFECT_INIT, -200, script.resetTemporaryData)
modRef:AddPriorityCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, -200, script.resetTemporaryData)
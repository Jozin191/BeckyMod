---@diagnostic disable

--BombLib Created by [No need to credit directly on the mod page. Though, a thanks would be appreciated]:
-- * Tiburones202

--Debug [DO NOT MODIFY]
local VERSION = 1
local FORCE_VERSION_UPDATE = true

local game = Game()
local Mod = BombLib or nil

local CACHED_CALLBACKS
local CACHED_BOMBS
local CACHED_MOD_CALLBACKS

local RGON_AVOID = true
local RGONON = (REPENTOGON ~= nil) and not RGON_AVOID

local function InitMod()
	local oldMod
	if EID then oldMod = EID._currentMod end

	local BombLib = RegisterMod("BombLibrary", 1)

	if EID then EID._currentMod = oldMod end

	BombLib.Version = VERSION

	BombLib.AddedCallbacks = {
		[ModCallbacks.MC_POST_BOMB_UPDATE] = {},
		[ModCallbacks.MC_PRE_USE_ITEM] = {},
		[ModCallbacks.MC_POST_EFFECT_INIT] = {},
		[ModCallbacks.MC_POST_PEFFECT_UPDATE] = {},
		[ModCallbacks.MC_POST_NEW_ROOM] = {},
		[ModCallbacks.MC_ENTITY_TAKE_DMG] = {},
	} -- for any vanilla callback functions added by this library

	if RGONON then
		BombLib.AddedCallbacks[ModCallbacks.MC_POST_GRID_ROCK_DESTROY] = {}
	else
		BombLib.AddedCallbacks[ModCallbacks.MC_POST_UPDATE] = {}
	end

	BombLib.Callbacks = BombLib.Callbacks or {}
	BombLib.Callbacks.RegisteredCallbacks = game:GetFrameCount() == 0 and CACHED_CALLBACKS or {}
	BombLib.RegisteredBombs = game:GetFrameCount() == 0 and CACHED_BOMBS or {}
	BombLib.AddedCallbacks = game:GetFrameCount() == 0 and CACHED_MOD_CALLBACKS or BombLib.AddedCallbacks
	
	return BombLib
end

--[[
	--BOMB EXAMPLE:

	RegisterBombModifier("My Custom Bomb", {
		HasModifier = function(player) return player:HasCollectible(Isaac.GetItemIdByName("My Bomb")) end,

		FetusChance = BombLib.DefaultFetusChance, --Shared with epic fetus. input a function. luck is offered as a parameter
		NancyChance = -1, --Not recommended until I find a "vanilla" way to include custom bombs

		IgnoreSmallBomb = false,
		IgnoreBomberBoy = true,

		IgnoreKamikaze = false, --Shared with Swallowed M80
		IgnoreEpicFetus = false,
		IgnoreWarLocust = false,
		IgnoreBobsBrain = false,
		IgnoreBobsRottenHead = false,
		IgnoreBBF = false,

		IgnoreHotPotato = false,

		Variant = Isaac.GetEntityVariantByName("My Bomb Variant"),
		Path = "gfx/items/pick ups/bombs/custom",
		AddPathSuffixOnGolden = true,

		CopperBombSprite = false,
	})
]]

---Initializes data and functions that get overwritten when a newer version of the mod is loaded.
local function InitFunctions()
	BombLib.DefaultFetusChance = function(luck) return 11 + (3 * luck) end --Brimstone bombs chance as a placeholder
	BombLib.DefaultNancyChance = -1 --Disabled normally. Will have a base chance once I figure out how it works.

	BombLib.BLACKLISTED_VARIANTS = {
		[BombVariant.BOMB_GIGA] = true,
		[BombVariant.BOMB_THROWABLE] = true,
	}

	BombLib.ENUMS = {}
	BombLib.ENUMS.BOMB_SIZES = {
		SMALL_BOMB = 0,
		SMALL_MR_MEGA_BOMB = 1,
		NORMAL_BOMB = 2,
		REGULAR_BOMB = 2,
		MR_MEGA_BOMB = 3,
		GIGA_BOMB = 4,
	}

	local BLEnum = BombLib.ENUMS

	BombLib.SET_BOMB_SIZES = {
		[BombVariant.BOMB_BIG] = BLEnum.BOMB_SIZES.MR_MEGA_BOMB,
		[BombVariant.BOMB_DECOY] = BLEnum.BOMB_SIZES.MR_MEGA_BOMB,
		[BombVariant.BOMB_SUPERTROLL] = BLEnum.BOMB_SIZES.MR_MEGA_BOMB,
		[BombVariant.BOMB_POISON_BIG] = BLEnum.BOMB_SIZES.MR_MEGA_BOMB,
		[BombVariant.BOMB_MR_MEGA] = BLEnum.BOMB_SIZES.MR_MEGA_BOMB,
		[BombVariant.BOMB_GIGA] = BLEnum.BOMB_SIZES.GIGA_BOMB,
		[BombVariant.BOMB_ROCKET_GIGA] = BLEnum.BOMB_SIZES.GIGA_BOMB
	}

	BombLib.SIZE_TO_EXPLOSION_SCALE = {
		[BLEnum.BOMB_SIZES.SMALL_BOMB] = Vector(0.65, 0.65),
		[BLEnum.BOMB_SIZES.SMALL_MR_MEGA_BOMB] = Vector(0.65, 0.65),
		[BLEnum.BOMB_SIZES.REGULAR_BOMB] = Vector.One,
		[BLEnum.BOMB_SIZES.MR_MEGA_BOMB] = Vector(1.4, 1.4),
		[BLEnum.BOMB_SIZES.GIGA_BOMB] = Vector(2, 2),
	}

	local rockEffectIndexes = {}

	--#region Utils

	---Will attempt to find the player using the attached Entity, EntityRef, or EntityPtr.
	---Will return if its a player, the player's familiar, or loop again if it has a SpawnerEntity
	---@param ent Entity | EntityRef | EntityPtr
	---@param directOnly? boolean
	---@return EntityPlayer?
	function Mod:TryGetPlayer(ent, directOnly)
		if not ent then return end
		if string.find(getmetatable(ent).__type, "EntityPtr") then
			if ent.Ref then
				return Mod:TryGetPlayer(ent.Ref)
			end
		elseif string.find(getmetatable(ent).__type, "EntityRef") then
			if ent.Entity then
				return Mod:TryGetPlayer(ent.Entity)
			end
		elseif ent:ToPlayer() then
			return ent:ToPlayer()
		elseif ent:ToFamiliar() and ent:ToFamiliar().Player and not directOnly then
			return ent:ToFamiliar().Player
		elseif ent.SpawnerEntity and not directOnly then
			return Mod:TryGetPlayer(ent.SpawnerEntity)
		end
	end

	---Executes given function for every player
	---Return anything to end the loop early
	---@param func fun(player: EntityPlayer, playerNum?: integer): any?
	function Mod:ForEachPlayer(func)
		if REPENTOGON then
			for i, player in ipairs(PlayerManager.GetPlayers()) do
				if func(player, i) then
					return true
				end
			end
		else
			for i = 0, game:GetNumPlayers() - 1 do
				if func(Isaac.GetPlayer(i), i) then
					return true
				end
			end
		end
	end

	--- Gives the player's luck accounting for teardrop charm [Taken from Epiphany, ty]
	---@param player EntityPlayer
	---@return integer
	function Mod:GetTearModifierLuck(player)
		local luck = player.Luck
		if player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) then
			luck = luck + (player:GetTrinketMultiplier(TrinketType.TRINKET_TEARDROP_CHARM) * 4)
		end
		return luck
	end

	---Explosion will (almsot) always be in the same position
	function Mod:IsNotBomberBoyExplosion(effect, spawner)
		return (effect.Position.X == spawner.Position.X) and (effect.Position.Y == spawner.Position.Y)
	end

	--Calculates de resulting explosion size (scale vector) getting the spawner bomb size
	function Mod:GetExplosionScale(bomb)
		if not bomb:ToBomb() then bomb = bomb.SpawnerEntity end --Explsion effect to bomb
		return BombLib.SIZE_TO_EXPLOSION_SCALE[Mod:GetBombSize(bomb)] or Vector.One
	end

	--Gets the bomb size
	--2 for Normal Bomb (Default Value), 0 for Scatter Bomb, 
	--3 for Mr. Mega and Best Friend, 1 for Mr. Mega Scatter Bombs 
	--and 4 for Giga Bombs
	function Mod:GetBombSize(bomb)
		if not bomb then return BLEnum.BOMB_SIZES.REGULAR_BOMB end
		if BombLib.SET_BOMB_SIZES[bomb.Variant] then return BombLib.SET_BOMB_SIZES[bomb.Variant] end --Set sizes

		local file = bomb:GetSprite():GetFilename()
		return tonumber(file:sub(file:len()-5, -6)) or BLEnum.BOMB_SIZES.REGULAR_BOMB
	end

	function Mod:WillEntityDie(Entity, Amount)
		if Entity:ToPlayer() then
			local player = Entity:ToPlayer()
			local healthLeft = ((player:GetHearts() - player:GetRottenHearts() * 2) + player:GetSoulHearts() + player:GetRottenHearts() +
				player:GetEternalHearts() + player:GetBoneHearts())
			return (healthLeft - Amount) <= 0
		else
			return (Entity.HitPoints - Amount) <= 0
		end
	end

	function Mod:CheckExplosionType(extraData, registeredBomb, checkFor)
		return extraData["Is" .. checkFor] and not registeredBomb["Ignore" .. checkFor]
	end

	function Mod:ShouldFireStandard(identificator, extraData, spawnerThing, player, spawner, isExplosionCallback)
		local registeredBomb = Mod.RegisteredBombs[identificator]

		if isExplosionCallback then
			if not ((extraData.IsBomberBoy and not registeredBomb.IgnoreBomberBoy) or not extraData.IsBomberBoy) then
				return false
			end
		end

		if Mod:CheckExplosionType(extraData, registeredBomb, "Kamikaze") then
			return registeredBomb.HasModifier(player)
		elseif Mod:CheckExplosionType(extraData, registeredBomb, "WarLocust") then
			return registeredBomb.HasModifier(player)
		elseif Mod:CheckExplosionType(extraData, registeredBomb, "BobsBrain") then
			return registeredBomb.HasModifier(player)
		elseif Mod:CheckExplosionType(extraData, registeredBomb, "BBF") then
			return registeredBomb.HasModifier(player)
		elseif Mod:CheckExplosionType(extraData, registeredBomb, "BobsRottenHead") then
			return registeredBomb.HasModifier(player)
		elseif Mod:CheckExplosionType(extraData, registeredBomb, "HotPotato") then
			return registeredBomb.HasModifier(player)
		elseif Mod:CheckExplosionType(extraData, registeredBomb, "EpicFetus") then
			local checkFrom = spawner == nil and spawnerThing.SpawnerEntity or spawner
			print('checking...', checkFrom)
			return checkFrom:GetData()[identificator]
		else
			local bomb
			if spawnerThing:ToBomb() then
				bomb = spawnerThing:ToBomb()
			else
				bomb = spawnerThing.SpawnerEntity:ToBomb()
			end

			if bomb and ((extraData.IsSmallBomb and not registeredBomb.IgnoreSmallBomb) or not extraData.IsSmallBomb) then
				return bomb:GetData()[identificator]
			end
		end
	end

	--endregion

	--#region Callbacks

	BombLib.Callbacks.ID = {
		--"New" callbacks
		POST_BOMB_EXPLODE = 0, --No pre because it just kinda doesn't exist lmfao

		PRE_PROPER_BOMB_INIT = 1, --Before adding modifiers and changing sprite
		POST_PROPER_BOMB_INIT = 2, --After doing that thingy

		ENTITY_TAKE_EXPLOSION_DMG = 3, 

		POST_EXPLOSION_DESTROY_GRID_ROCK = 4,
	}

	for _, v in pairs(BombLib.Callbacks.ID) do
		if not BombLib.Callbacks.RegisteredCallbacks[v] then
			BombLib.Callbacks.RegisteredCallbacks[v] = {}
		end
	end

	BombLib.CallbackPriority = {
		HIGHEST = 0,
		HIGH = 10,
		NORMAL = 20,
		LOW = 30,
		LOWEST = 40,
	}

	---@param id number
	---@param priority integer
	---@param func function
	---@param ... any
	function BombLib.Callbacks.AddPriorityCallback(id, priority, func, ...)
		local callbacks = BombLib.Callbacks.RegisteredCallbacks[id]
		local callback = {
			Priority = priority,
			Function = func,
			Args = { ... },
		}

		if #callbacks == 0 then
			callbacks[#callbacks + 1] = callback
		else
			for i = #callbacks, 1, -1 do
				if callbacks[i].Priority <= priority then
					table.insert(callbacks, i + 1, callback)
					return
				end
			end
			table.insert(callbacks, 1, callback)
		end
	end

	---@param id number
	---@param func function
	---@param ... any
	function BombLib.Callbacks.AddCallback(id, func, ...)
		BombLib.Callbacks.AddPriorityCallback(id, BombLib.CallbackPriority.NORMAL, func, ...)
	end

	---@param id string
	---@param func function
	function BombLib.Callbacks.RemoveCallback(id, func)
		local callbacks = BombLib.Callbacks.RegisteredCallbacks[id]
		for i = #callbacks, 1, -1 do
			if callbacks[i].Function == func then
				table.remove(callbacks, i)
			end
		end
	end

	function BombLib.Callbacks.FireCallback(callbackId, ...)
		local callbacks = Mod.Callbacks.RegisteredCallbacks[callbackId]
		if callbacks ~= nil then
			return Mod.CallbackHandlers[callbackId](callbacks, ...)
		end
	end

	BombLib.CallbackHandlers = {
		[Mod.Callbacks.ID.POST_BOMB_EXPLODE] = function(callbacks, effect, player, extraData)
			local effectData = effect:GetData()

			if effectData.BombLibChecked then goto continue2 end
			effectData.BombLibChecked = true

			for i = 1, #callbacks do
				local identificator = callbacks[i].Args[1]
				local shouldFire = (not identificator) or Mod:ShouldFireStandard(identificator, extraData, effect, player, _, true)

				if shouldFire then
					callbacks[i].Function(BombLib, effect, player, extraData)
				end

				::continue::
			end
			::continue2::
		end,

		[Mod.Callbacks.ID.PRE_PROPER_BOMB_INIT] = function (callbacks, bomb, player)
			for i = 1, #callbacks do --No extra parameters
				callbacks[i].Function(BombLib, bomb, player)
			end
		end,

		[Mod.Callbacks.ID.POST_PROPER_BOMB_INIT] = function (callbacks, bomb, player)
			for i = 1, #callbacks do
				local identificator = callbacks[i].Args[1]
				local shouldFire = not identificator

				if not shouldFire then
					shouldFire = bomb:GetData()[identificator]
				end

				if shouldFire then
					callbacks[i].Function(BombLib, bomb, player)
				end
			end
		end,

		[Mod.Callbacks.ID.ENTITY_TAKE_EXPLOSION_DMG] = function (callbacks, Entity, Amount, DamageFlags, source, CountdownFrames, player, extraData)
			for i = 1, #callbacks do
				local identificator = callbacks[i].Args[1]
				local shouldFire = (not identificator) or Mod:ShouldFireStandard(identificator, extraData, source, player)

				if shouldFire then
					local stop = callbacks[i].Function(BombLib, Entity, Amount, DamageFlags, source, CountdownFrames, extraData)

					if stop ~= nil then
						return stop
					end
				end
			end
		end,

		[Mod.Callbacks.ID.POST_EXPLOSION_DESTROY_GRID_ROCK] = function (callbacks, gridEnt, effect, spawner, player, extraData)
			for i = 1, #callbacks do
				local limits = callbacks[i].Args
				local shouldFire = (not limits[1]) or Mod:ShouldFireStandard(limits[1], extraData, effect, player, spawner)
				local shouldFire2 = (not limits[2] or limits[2] == gridEnt:GetType())
				local shouldFire3 = (not limits[3] or limits[3] == gridEnt:GetVariant())

				if shouldFire and shouldFire2 and shouldFire3 then
					callbacks[i].Function(BombLib, gridEnt, effect, spawner, player, extraData)
				end
			end
		end,
	}

	--#endregion

	for callback, funcs in pairs(BombLib.AddedCallbacks) do
		for i = 1, #funcs do
			BombLib:RemoveCallback(callback, funcs[i])
		end
	end

	local function AddPriorityCallback(callback, priority, func, arg)
		BombLib:AddPriorityCallback(callback, priority, func, arg)

		if not BombLib.AddedCallbacks[callback] then
			BombLib.AddedCallbacks[callback] = {}
		end
		table.insert(BombLib.AddedCallbacks[callback], func)
	end

	local function AddCallback(callback, func, arg)
		AddPriorityCallback(callback, CallbackPriority.DEFAULT, func, arg)
	end

	function BombLib:RegisterBombModifier(Identifier, BombData)
		BombLib.RegisteredBombs[Identifier] =
		{
			HasModifier = BombData.HasModifier,

			FetusChance = BombData.FetusChance or BombLib.DefaultFetusChance,
			NancyChance = BombData.NancyChance or BombLib.DefaultNancyChance,

			IgnoreSmallBomb = BombData.IgnoreSmallBomb or false,
			IgnoreBomberBoy = BombData.IgnoreBomberBoy == nil and true or BombData.IgnoreBomberBoy,

			IgnoreKamikaze = BombData.IgnoreKamikaze or false,
			IgnoreEpicFetus = BombData.IgnoreEpicFetus or false,
			IgnoreWarLocust = BombData.IgnoreWarLocust or false,
			IgnoreBobsBrain = BombData.IgnoreBobsBrain or false,
			IgnoreBobsRottenHead = BombData.IgnoreBobsRottenHead or false,
			IgnoreBBF = BombData.IgnoreBBF or false,

			IgnoreHotPotato = BombData.IgnoreHotPotato or false,

			Variant = BombData.Variant or nil,
			Path = BombData.Path or nil,

			AddPathSuffixOnGolden = BombData.AddPathSuffixOnGolden or false,

			CopperBombSprite = BombData.CopperBombSprite or false,
		}

		--#region Dynamic Bomb HUD Compatibility

		local DBHUDCompat = BombData.DynamicBombHUDCompat
		if DBHUDCompat then
			CustomBombHUDIcons:AddPriorityBombIcon(DBHUDCompat.Priority or CustomBombHUDIcons.BombPriority.DEFAULT,
    		{
    		    Name = DBHUDCompat.Name,

    		    Anm2 = DBHUDCompat.Anm2,
    		    GoldAnm2 = DBHUDCompat.GoldAnm2,
    		    CopperAnm2 = DBHUDCompat.CopperAnm2,
    		    FrameName = DBHUDCompat.FrameName,
    		    Frame = DBHUDCompat.Frame,

    		    Condition = DBHUDCompat.Condition
    		})
		end

		--#endregion
	end

	--#region Bomb States
	function BombLib:IsCopperBomb(bomb, bombData) 
		return bombData.CopperBombSprite and FiendFolio and (bomb.Variant == FiendFolio.BOMB.COPPER)
	end

	function BombLib:ChangeVariant(bomb, identifier, bombData)
		local variant = bombData.Variant
		local isCopper = BombLib:IsCopperBomb(bomb, bombData) 

		local sprite = bomb:GetSprite()
	    local file = sprite:GetFilename()
		local endingString = file:sub(file:len()-5)

	    if isCopper or bomb.Variant == 0 or bomb.Variant == variant then --Change skin if normal bomb
			if variant and not isCopper then 
				bomb.Variant = variant
			end

			local path = bombData.Path

			if path then
				local spritesheetSuffix = ''

				if isCopper then
					spritesheetSuffix = "_copper"
				elseif bombData.AddPathSuffixOnGolden and bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
					spritesheetSuffix = "_gold"
				end

				local anim = sprite:GetAnimation()

			    sprite:Load(path .. spritesheetSuffix .. endingString, true)
			    sprite:Play(anim, true)
			end
	    end

	    bomb:GetData()[identifier] = true
	end

	---@param bomb EntityBomb
	function BombLib:ProperBombInit(bomb, player)
	    if not player then return end
	    if BombLib.BLACKLISTED_VARIANTS[bomb.Variant] then return end

		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.PRE_PROPER_BOMB_INIT, bomb, player)

		local HasNancy = player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS)
		local NancyRNG = HasNancy and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS) or nil

	    --Detect nancy bombs anddddd the dr fetus from SMB yeah
		for identifier, bombData in pairs(BombLib.RegisteredBombs) do
			if bombData.HasModifier(player, bomb) then
			    if bomb.IsFetus then
			        local rng = bomb:GetDropRNG()

			        if rng:RandomInt(100) > bombData.FetusChance(Mod:GetTearModifierLuck(player), player) then
			            goto continue
			        end
			    end

			    BombLib:ChangeVariant(bomb, identifier, bombData)
			elseif HasNancy then
			    --TODO: Better way to add modifiers by nancy bombs

			    if NancyRNG:RandomInt(100) > bombData.NancyChance then
			        goto continue
			    end

			    BombLib:ChangeVariant(bomb, identifier, bombData)
			end

			::continue::
		end

		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_PROPER_BOMB_INIT, bomb, player)
	end

	---@param bomb EntityBomb
	function BombLib:BombUpdate(bomb)
		if bomb.FrameCount == 1 then
			local player = Mod:TryGetPlayer(bomb)

			BombLib:ProperBombInit(bomb, player)
		end
	end
	AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, BombLib.BombUpdate)

	--#endregion

	--#region Bomb Explosion

	function BombLib:DetectBombExplosion(spawner)
		local bomb = spawner:ToBomb()

		if not bomb then return end

		local extraData = {}

		if Mod:GetBombSize(bomb) < 2 then --Mini bomb
			extraData.IsSmallBomb = true
			extraData.SmallExplosion = true
		end

		return extraData
	end

	--#endregion

	--#region Kamikaze

	function BombLib:UseKamikaze(_, _, player)
		player:GetData().BombLibKamikazeUsed = true

		BombLib.Scheduler.Schedule(0, function(player) --delay a bit
			player:GetData().BombLibKamikazeUsed = nil
		end, {player})
	end

	AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.LATE, BombLib.UseKamikaze, CollectibleType.COLLECTIBLE_KAMIKAZE)

	function BombLib:DetectKamikazeExplosion(spawner)
	    local player = spawner:ToPlayer()

	    if not player then return end

	    if player:GetData().BombLibKamikazeUsed then
			local extraData = {
				IsKamikaze = true
			}

			return extraData
	    end
	end

	--#endregion

	--#region Epic Fetus

	BombLib.RocketEffects = {
		[EffectVariant.ROCKET] = true,
		[EffectVariant.SMALL_ROCKET] = true,
	}

	function BombLib:EpicFetusRocketInit(rocket)
		player = rocket.SpawnerEntity

		if not player then return end

		player = player:ToPlayer()

		if not player then return end

		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EPIC_FETUS)
		for identifier, bombData in pairs(BombLib.RegisteredBombs) do
			if bombData.HasModifier(player) then
				if rng:RandomInt(100) <= bombData.FetusChance(Mod:GetTearModifierLuck(player), player) then
					rocket:GetData()[identifier] = true
				end
			end
		end
	end
	for rocket, _ in pairs(BombLib.RocketEffects) do
		AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, BombLib.EpicFetusRocketInit, rocket)
	end

	function BombLib:DetectEpicFetusExplosion(spawner)
		if BombLib.RocketEffects[spawner.Variant] then
			local extraData = {
				IsEpicFetus = true,
			}

			return extraData
		end
	end

	--#endregion

	--#region Locust of War

	function BombLib:DetectWarLocustExplosion(spawner)
		if spawner.Variant ~= FamiliarVariant.BLUE_FLY or spawner.SubType ~= 1 then return end

		local extraData = {
			IsWarLocust = true,
			SmallExplosion = true,
		}

		return extraData
	end

	--#endregion

	--#region Bob's Brain

	function BombLib:DetectBobsBrainExplosion(spawner)
		if spawner.Variant ~= FamiliarVariant.BOBS_BRAIN then return end

		local extraData = {
			IsBobsBrain = true
		}

		return extraData
	end

	--#endregion

	--#region Bob's Rotten Head

	function BombLib:DetectBobsRottenHeadtByInit(effect)
		local player = effect.SpawnerEntity
		if not player then return end
		player = player:ToPlayer()
		if not player then return end

		local bobsRottenHead = Isaac.FindInRadius(effect.Position, 0)[1]:ToTear()

		if not bobsRottenHead then return end

		local extraData = {
			IsBobsRottenHead = true
		}

		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, bobsRottenHead, player, extraData)
	end

	AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, BombLib.DetectBobsRottenHeadtByInit, EffectVariant.SMOKE_CLOUD)

	--#endregion

	--#region BBF

	function BombLib:DetectBBFExplosion(spawner)
		if spawner.Variant ~= FamiliarVariant.BBF then return end

		local extraData = {
			IsBBF = true
		}

		return extraData
	end

	--#endregion

	--#region Hot Potato

	function BombLib:HotPotatoForgorPEffectUpdate(player)
		if game.Challenge ~= Challenge.CHALLENGE_HOT_POTATO then return end

		local FrameCountRoom = (player.FrameCount - (player:GetData().BombLibStartingFrames or 0))
		if (FrameCountRoom % 73 == 0) and FrameCountRoom > 0 then 
			local extraData = {
				IsHotPotato = true
			}

			Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, player, player, extraData)
		end
	end

	AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BombLib.HotPotatoForgorPEffectUpdate, PlayerType.PLAYER_THEFORGOTTEN_B)

	function BombLib:HotPotatoNewRoom() --Reset frames on new room
		if game.Challenge ~= Challenge.CHALLENGE_HOT_POTATO then return end

		Mod:ForEachPlayer(function(player)
			if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
				player:GetData().BombLibStartingFrames = player.FrameCount - 1
			end
		end)
	end

	AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BombLib.HotPotatoNewRoom)

	--#endregion

	function BombLib:CheckExplosionGridsDestroyed(effect, spawner, player, extraData)
		local room = game:GetRoom()
		for i = 0, room:GetGridSize() do
			local gridEnt = room:GetGridEntity(i)
			if gridEnt then
				gridEnt = gridEnt:ToRock()

				if gridEnt and gridEnt.State == 2 then
					local idx = gridEnt:GetSaveState().SpawnSeed

					if not rockEffectIndexes[idx] then
						rockEffectIndexes[idx] = {}
					end

					if not rockEffectIndexes[idx].Checked then
						rockEffectIndexes[idx].TimeDoneOn = game:GetFrameCount()
						rockEffectIndexes[idx].EffectHash = GetPtrHash(effect)
						rockEffectIndexes[idx].ExtraData = extraData
						rockEffectIndexes[idx].Checked = true
					end
				end
			end
		end
	end

	function BombLib:TypeChecker(spawner, func, extraData)
		local returnedData = func(BombLib, spawner)

		if returnedData then --Overwrite extraData
			for k,v in pairs(returnedData) do
				extraData[k] = v
			end

			extraData.successful = true
		end

		return extraData
	end

	function BombLib:CustomBombInteractionsInit(effect)
		local spawner = effect.SpawnerEntity

		if not spawner then return end

		local player = Mod:TryGetPlayer(spawner)

		if not player then return end

		local extraData = {
			IsBomberBoy = not Mod:IsNotBomberBoyExplosion(effect, spawner)
		}

		extraData = BombLib:TypeChecker(spawner, BombLib.DetectBombExplosion, extraData) --Normal Bomb
		extraData = BombLib:TypeChecker(spawner, BombLib.DetectKamikazeExplosion, extraData) --Kamikaze
		extraData = BombLib:TypeChecker(spawner, BombLib.DetectEpicFetusExplosion, extraData) --Epic Fetus
		if spawner.Type == EntityType.ENTITY_FAMILIAR then
			extraData = BombLib:TypeChecker(spawner, BombLib.DetectBobsBrainExplosion, extraData) --Bob's Brain
			extraData = BombLib:TypeChecker(spawner, BombLib.DetectWarLocustExplosion, extraData) --War Locust
			extraData = BombLib:TypeChecker(spawner, BombLib.DetectBBFExplosion, extraData) --BBF
		end

		if not extraData.successful then return end --No explosion that counts, do nothing.

		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, effect, player, extraData)

		BombLib:CheckExplosionGridsDestroyed(effect, spawner, player, extraData)
	end

	AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, BombLib.CustomBombInteractionsInit, EffectVariant.BOMB_EXPLOSION)

	function BombLib:PostEntityTakeExplosionDamage(Entity, Amount, DamageFlags, Source, CountdownFrames)
		local spawner = Source.Entity

		if not spawner then goto continue end

		local player = Mod:TryGetPlayer(spawner)

		if not player then goto continue end

		local extraData = {
			WillDie = BombLib:WillEntityDie(Entity, Amount),
			--IsBomberBoy = not Mod:IsNotBomberBoyExplosion(effect, spawner)
		}

		extraData = BombLib:TypeChecker(spawner, BombLib.DetectBombExplosion, extraData) --Normal Bomb
		extraData = BombLib:TypeChecker(spawner, BombLib.DetectKamikazeExplosion, extraData) --Kamikaze
		extraData = BombLib:TypeChecker(spawner, BombLib.DetectEpicFetusExplosion, extraData) --Epic Fetus
		if spawner.Type == EntityType.ENTITY_FAMILIAR then
			extraData = BombLib:TypeChecker(spawner, BombLib.DetectBobsBrainExplosion, extraData) --Bob's Brain
			extraData = BombLib:TypeChecker(spawner, BombLib.DetectWarLocustExplosion, extraData) --War Locust
			extraData = BombLib:TypeChecker(spawner, BombLib.DetectBBFExplosion, extraData) --BBF
		end

		if not extraData.successful then goto continue end --No explosion that counts, do nothing.

		local stop = Mod.Callbacks.FireCallback(Mod.Callbacks.ID.ENTITY_TAKE_EXPLOSION_DMG, Entity, Amount, DamageFlags, spawner, CountdownFrames, player, extraData)

		if stop ~= nil then
			return stop
		end

		::continue::
	end

	AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BombLib.PostEntityTakeExplosionDamage)

	function BombLib:DestroyGrid(gridEnt)
		local idx = gridEnt:GetSaveState().SpawnSeed

		if not rockEffectIndexes[idx] then
			rockEffectIndexes[idx] = {}
		end

		--print(game:GetFrameCount())
		if rockEffectIndexes[idx].TimeDoneOn == game:GetFrameCount() then
			local eHash = rockEffectIndexes[idx].EffectHash
			for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT)) do
				if eHash == GetPtrHash(effect) then
					effect = effect:ToEffect()

					Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_EXPLOSION_DESTROY_GRID_ROCK, gridEnt, effect,
						effect.SpawnerEntity, Mod:TryGetPlayer(effect), rockEffectIndexes[idx].ExtraData)

					break
				end
			end
		end

		rockEffectIndexes[idx].Destroyed = true
	end

	if not RGONON then
		local function runGridUpdate()
			local room = game:GetRoom()
			for i = 0, room:GetGridSize() do
				local gridEnt = room:GetGridEntity(i)
				if gridEnt then
					gridEnt = gridEnt:ToRock()
					if gridEnt and gridEnt.State == 2 then
						local idx = gridEnt:GetSaveState().SpawnSeed

						if not rockEffectIndexes[idx] then
							rockEffectIndexes[idx] = {}
						end

						if not rockEffectIndexes[idx].Destroyed then
							BombLib:DestroyGrid(gridEnt)
						end
					end
				end
			end
		end

		AddCallback(ModCallbacks.MC_POST_UPDATE, runGridUpdate)
	else
		local function destroyGridRockRGON(_, gridEnt)
			BombLib.Scheduler.Schedule(0, function(gridEnt) --delay a bit
				BombLib:DestroyGrid(gridEnt)
			end, {gridEnt})
		end

		AddCallback(ModCallbacks.MC_POST_GRID_ROCK_DESTROY, destroyGridRockRGON)
	end

	local function ResetEffectsBombLib()
		rockEffectIndexes = {} --Reset yay

		if not RGONON then
			local room = game:GetRoom()
			for i = 0, room:GetGridSize() do
				local gridEnt = room:GetGridEntity(i)
				if gridEnt then
					gridEnt = gridEnt:ToRock()
					if gridEnt and gridEnt.State == 2 then
						local idx = gridEnt:GetSaveState().SpawnSeed

						if not rockEffectIndexes[idx] then
							rockEffectIndexes[idx] = {}
							rockEffectIndexes[idx].Destroyed = true
						end
					end
				end
			end
		end
	end
	
	AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ResetEffectsBombLib)
end

--#region Base Game callbacks, passing a modifier [Add later?] --#endregion

--#region Update

if BombLib then
	if BombLib.Version > VERSION and not FORCE_VERSION_UPDATE then
		return
	end

	CACHED_CALLBACKS = BombLib.Callbacks.RegisteredCallbacks
	CACHED_BOMBS = BombLib.RegisteredBombs
	CACHED_MOD_CALLBACKS = BombLib.AddedCallbacks
end

BombLib = InitMod()
Mod = BombLib
InitFunctions()

--#region Scheduler

local function schedulerInit() --Taken from Epiphany
	local scheduler = {}
	scheduler.ScheduleData = {}
	---
	---@param delay integer
	---@param func function
	---@param args any
	---@function
	---@scope Scheduler
	function scheduler.Schedule(delay, func, args)
		table.insert(scheduler.ScheduleData, {
			Time = game:GetFrameCount(),
			Delay = delay,
			Call = func,
			Args = args or {},
		})
	end
	
	Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
		local time = game:GetFrameCount()
		for i = #scheduler.ScheduleData, 1, -1 do
			local data = scheduler.ScheduleData[i]
			if data.Time + data.Delay <= time then
				table.remove(scheduler.ScheduleData, i)
				data.Call(table.unpack(data.Args))
			end
		end
	end)
	
	Mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function()
		scheduler.ScheduleData = {}
	end)
	
	return scheduler
end

BombLib.Scheduler = schedulerInit()

--#endregion

--#endregion
---@diagnostic disable

--BombLib Created by [No need to credit directly on the mod page. Though, a thanks would be appreciated]:
-- * Tiburones202

BombLib = RegisterMod("BombLibrary", 1)
BombLib.Version = 1 --v1.0.0 release

local game = Game()

local Mod = BombLib

BombLib.DefaultFetusChance = function(luck) return 11 + (3 * luck) end --Brimstone bombs chance as a placeholder
BombLib.DefaultNancyChance = -1 --Disabled normally. Will have a base chance once I figure out how it works.

BombLib.BLACKLISTED_VARIANTS = {
    [BombVariant.BOMB_GIGA] = true,
    [BombVariant.BOMB_THROWABLE] = true,
}
--[[
--TODO:
* Base game callbacks with modifier as limiters [Later?]
]]

BombLib.RegisteredBombs = { }

--[[
	--BOMB EXAMPLE:

	RegisterBombModifier("My Custom Bomb", {
		HasModifier = function(player) return player:HasCollectible(Isaac.GetItemIdByName("My Bomb")) end,

		FetusChance = BombLib.DefaultFetusChance, --Shared with epic fetus. input a function. luck is offered as a parameter
		NancyChance = -1, --Not recommended until I find a "vanilla" way to include custom bombs

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

function BombLib:RegisterBombModifier(Identifier, BombData)
	BombLib.RegisteredBombs[Identifier] =
	{
		HasModifier = BombData.HasModifier,

		FetusChance = BombData.FetusChance or BombLib.DefaultFetusChance,
		NancyChance = BombData.NancyChance or BombLib.DefaultNancyChance,

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
end

--#region Callbacks

BombLib.Callbacks = {}
BombLib.Callbacks.RegisteredCallbacks = {}

BombLib.Callbacks.ID = {
	--"New" callbacks
	POST_BOMB_EXPLODE = 0, --No pre because it just kinda doesn't exist lmfao

	PRE_PROPER_BOMB_INIT = 1, --Before adding modifiers and changing sprite
	POST_PROPER_BOMB_INIT = 2, --After doing that thingy
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
	[Mod.Callbacks.ID.POST_BOMB_EXPLODE] = function(callbacks, bomb, player, extraData)
		for i = 1, #callbacks do
			local identificator = callbacks[i].Args[1]
			local shouldFire = not identificator

			if not shouldFire then
				local bombData = bomb:GetData()
				local registeredBomb = Mod.RegisteredBombs[identificator]

				if extraData.IsKamikaze and not registeredBomb.IgnoreKamikaze then
					shouldFire = registeredBomb.HasModifier(player)
				elseif extraData.IsWarLocust and not registeredBomb.IgnoreWarLocust then
					shouldFire = registeredBomb.HasModifier(player)
				elseif extraData.IsBobsBrain and not registeredBomb.IgnoreBobsBrain then
					shouldFire = registeredBomb.HasModifier(player)
				elseif extraData.IsBBF and not registeredBomb.IgnoreBBF then
					shouldFire = registeredBomb.HasModifier(player)
				elseif extraData.IsBobsRottenHead and not registeredBomb.IgnoreBobsRottenHead then
					shouldFire = registeredBomb.HasModifier(player)
				elseif extraData.IsHotPotato and not registeredBomb.IgnoreHotPotato then
					shouldFire = registeredBomb.HasModifier(player)
				elseif extraData.IsEpicFetus and not registeredBomb.IgnoreEpicFetus then
					local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_EPIC_FETUS)
					if rng:RandomInt(100) > registeredBomb.FetusChance(player.Luck) then goto continue end

					shouldFire = registeredBomb.HasModifier(player)
				else
					shouldFire = bombData[identificator]
				end
			end

			if shouldFire then
				callbacks[i].Function(BombLib, bomb, player, extraData)
			end

			::continue::
		end
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
	end
}

--#endregion

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
		for i = 0, Mod.game:GetNumPlayers() - 1 do
			if func(Isaac.GetPlayer(i), i) then
				return true
			end
		end
	end
end

---Explosion will (almsot) always be in the same position
function Mod:IsNotBomberBoyExplosion(effect, spawner)
	return (effect.Position.X == spawner.Position.X) and (effect.Position.Y == spawner.Position.Y)
end

---Decoy from Best Friend is LITERALLY a bomb (4.2.0, lmfao)
---
---But it doesn't have an explode animation, so I have to check for the last frame manually :P
function Mod:DecoyExplosion(decoy)
	if decoy.Variant ~= BombVariant.BOMB_DECOY then return false end

	return (decoy:GetData().BombLibReEnter and 45 or 151) - decoy.FrameCount == 0
end

function Mod:DecoyReInit(decoy)
	decoy:GetData().BombLibReEnter = decoy.SpawnerEntity == nil --SpawnerEntity is nil for one frame only on re enter (lol?)
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, Mod.DecoyReInit, BombVariant.BOMB_DECOY)

--endregion

--#region Bomb States

function BombLib:ChangeVariant(bomb, identifier, bombData)
	local variant = bombData.Variant
	local isCopper = CopperBombSprite and FiendFolio and (bomb.Variant == FiendFolio.BOMB.COPPER)

	local sprite = bomb:GetSprite()
    local file = sprite:GetFilename()
	local endingString = file:sub(file:len()-5)

    if (isCopper or bomb.Variant == 0) and variant then --Change skin if normal bomb
		if not isCopper then 
			bomb.Variant = variant
		end

		local path = bombData.Path

		if not path then goto continue end

        local spritesheetSuffix = ""

		if isCopper then
			spritesheetSuffix = "_copper"
		elseif bombData.AddPathSuffixOnGolden and bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
			spritesheetSuffix = "_gold"
		end

		local anim = sprite:GetAnimation()

        sprite:Load(path .. spritesheetSuffix .. endingString, true)
        sprite:Play(anim, true)
    end

	::continue::

	bomb:GetData().BombLibEndingString = endingString
    bomb:GetData()[identifier] = true
end

---@param bomb EntityBomb
function BombLib:ProperBombInit(bomb, player)
    if not player then return end
    if BombLib.BLACKLISTED_VARIANTS[bomb.Variant] then return end

	local HasNancy = player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS)
	local NancyRNG = HasNancy and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS) or nil

    --Detect nancy bombs anddddd the dr fetus from SMB yeah
	for identifier, bombData in pairs(BombLib.RegisteredBombs) do
		if bombData.HasModifier(player, bomb) then
		    if bomb.IsFetus then
		        local rng = bomb:GetDropRNG()

		        if rng:RandomInt(100) > bombData.FetusChance(player.Luck) then
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
end

---@param bomb EntityBomb
function BombLib:BombUpdate(bomb)
    local player = Mod:TryGetPlayer(bomb)

	if bomb.FrameCount == 1 then
		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.PRE_PROPER_BOMB_INIT, bomb, player)
		BombLib:ProperBombInit(bomb, player)
		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_PROPER_BOMB_INIT, bomb, player)
	end

    local sprite = bomb:GetSprite()
	if (sprite:IsPlaying("Explode") or Mod:DecoyExplosion(bomb)) then
		if bomb:HasTearFlags(TearFlags.TEAR_SCATTER_BOMB) then
            for _, scatterBomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
				if scatterBomb.FrameCount == 0 then --Just created bomb
					scatterBomb:GetData().BombLibIsSmallBomb = true
				end
			end
        end

		local extraData = {}

		if bomb:GetData().BombLibIsSmallBomb then
			extraData.SmallExplosion = true
		end

		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, bomb, player, extraData)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, BombLib.BombUpdate)

--#endregion

--#region Kamikaze

function BombLib:UseKamikaze(_, _, player)
	player:GetData().BombLibKamikazeUses = (player:GetData().BombLibKamikazeUses or 0) + 1
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.LATE, BombLib.UseKamikaze, CollectibleType.COLLECTIBLE_KAMIKAZE)

function BombLib:DetectKamikazeByInit(effect, spawner)
    local player = spawner:ToPlayer()

    if not player then return end

    if player:GetData().BombLibKamikazeUses then
        player:GetData().BombLibKamikazeUses = player:GetData().BombLibKamikazeUses - 1
        if player:GetData().BombLibKamikazeUses <= 0 then
            player:GetData().BombLibKamikazeUses = nil
        end

		local extraData = {
			IsKamikaze = true
		}

        Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, effect, player, extraData)
    end
end

--#endregion

--#region Epic Fetus

function BombLib:DetectEpicFetusByInit(effect, spawner)
	if spawner.Variant == EffectVariant.ROCKET or spawner.Variant == EffectVariant.SMALL_ROCKET then
		local IsNotBomberBoy = Mod:IsNotBomberBoyExplosion(effect, spawner)
		if IsNotBomberBoy then
			local extraData = {
				IsEpicFetus = true
			}

			Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, effect, Mod:TryGetPlayer(spawner), extraData)
		end
	end
end

--#endregion

--#region Locust of War

function BombLib:DetectWarLocustByInit(effect, spawner)
	if spawner.Variant ~= FamiliarVariant.BLUE_FLY or spawner.SubType ~= 1 then return end

	local IsNotBomberBoy = Mod:IsNotBomberBoyExplosion(effect, spawner)

	if IsNotBomberBoy then
		local extraData = {
			IsWarLocust = true,
			SmallExplosion = true,
		}
		
		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, effect, Mod:TryGetPlayer(spawner), extraData)
	end
end

--#endregion

--#region Bob's Brain

function BombLib:DetectBobsBrainByInit(effect, spawner)
	if spawner.Variant ~= FamiliarVariant.BOBS_BRAIN then return end

	local IsNotBomberBoy = Mod:IsNotBomberBoyExplosion(effect, spawner)

	if IsNotBomberBoy then
		local extraData = {
			IsBobsBrain = true
		}
		
		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, effect, Mod:TryGetPlayer(spawner), extraData)
	end
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

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, BombLib.DetectBobsRottenHeadtByInit, EffectVariant.SMOKE_CLOUD)

--#endregion

--#region BBF

function BombLib:DetectBBFByInit(effect, spawner)
	if spawner.Variant ~= FamiliarVariant.BBF then return end

	local IsNotBomberBoy = Mod:IsNotBomberBoyExplosion(effect, spawner)

	if IsNotBomberBoy then
		local extraData = {
			IsBBF = true
		}

		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, effect, Mod:TryGetPlayer(spawner), extraData)
	end
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

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BombLib.HotPotatoForgorPEffectUpdate, PlayerType.PLAYER_THEFORGOTTEN_B)

function BombLib:HotPotatoNewRoom() --Reset frames on new room
	if game.Challenge ~= Challenge.CHALLENGE_HOT_POTATO then return end

	Mod:ForEachPlayer(function(player)
		if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
			player:GetData().BombLibStartingFrames = player.FrameCount - 1
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BombLib.HotPotatoNewRoom)

--#endregion

function BombLib:CustomBombInteractionsInit(effect)
	local spawner = effect.SpawnerEntity

	if spawner then
		BombLib:DetectKamikazeByInit(effect, spawner) --Kamikaze
		--BombLib:DetectHotPotatoByInit(effect) --Hot Potato
		BombLib:DetectEpicFetusByInit(effect, spawner) --Epic Fetus
		if spawner.Type == EntityType.ENTITY_FAMILIAR then
			BombLib:DetectBobsBrainByInit(effect, spawner) --Bob's Brain
			BombLib:DetectWarLocustByInit(effect, spawner) --War Locust
			BombLib:DetectBBFByInit(effect, spawner) --BBF
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, BombLib.CustomBombInteractionsInit, EffectVariant.BOMB_EXPLOSION)

--#region Base Game callbacks, passing a modifier [Add later?]


--#endregion
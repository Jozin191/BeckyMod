---@diagnostic disable

--CBMAPI Created by [No need to credit directly on the mod page. Though, a thanks would be appreciated]:
-- * Tiburones202

CustomBombModifiersAPI = RegisterMod("CustomBombModifiersAPI", 1)
CustomBombModifiersAPI.Version = 1 --v1.0.0 release

local game = Game()

local Mod = CustomBombModifiersAPI

CustomBombModifiersAPI.DefaultFetusChance = function(luck) return 11 + (3 * luck) end --Brimstone bombs chance as a placeholder
CustomBombModifiersAPI.DefaultNancyChance = -1 --Disabled normally. Will have a base chance once I figure out how it works.

CustomBombModifiersAPI.BLACKLISTED_VARIANTS = {
    [BombVariant.BOMB_GIGA] = true,
    [BombVariant.BOMB_THROWABLE] = true,
}
--[[
--TODO: List
* Kamikaze + Swallowed M80 support [OK]
* Epic Fetus support [OK]
	** Forgotten support [OK]
* War Locust support [OK]
* BBF support [OK]
* Bob's Brain support [OK]
* Best Friend support [OK]
* Bob's Rotten Head support [OK]

* Hot Potato support [OK]

* Base game callbacks with modifier as limiters [Later?]
]]

CustomBombModifiersAPI.RegisteredBombs =
{
	["Null Bomb"] =
	{
		HasModifier = function(player) return player:HasCollectible(Isaac.GetItemIdByName("Null Bombs")) end,

		FetusChance = CustomBombModifiersAPI.DefaultFetusChance, --Shared with epic fetus. you can input a function to scale with luck
		NancyChance = 5, --Whacky.

		IgnoreKamikaze = false, --Shared with Swallowed M80
		IgnoreEpicFetus = false,
		IgnoreWarLocust = false,
		IgnoreBobsBrain = false,
		IgnoreBobsRottenHead = false,
		IgnoreBBF = false,

		IgnoreHotPotato = false,

		Variant = Isaac.GetEntityVariantByName("Null Bomb"),
		Path = "gfx/items/pick ups/bombs/null",
		AddPathSuffixOnGolden = true,

		CopperBombSprite = true,
	}
}

function CustomBombModifiersAPI:RegisterBombModifier(Identifier, BombData)
	CustomBombModifiersAPI.RegisteredBombs[Identifier] =
	{
		HasModifier = BombData.HasModifier,

		FetusChance = BombData.FetusChance or CustomBombModifiersAPI.DefaultFetusChance,
		NancyChance = BombData.NancyChance or CustomBombModifiersAPI.DefaultNancyChance,

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

CustomBombModifiersAPI.Callbacks = {}
CustomBombModifiersAPI.Callbacks.RegisteredCallbacks = {}

CustomBombModifiersAPI.Callbacks.ID = {
	--"New" callbacks
	POST_BOMB_EXPLODE = 0, --No pre because it just kinda doesn't exist lmfao

	PRE_PROPER_BOMB_INIT = 1, --Before adding modifiers and changing sprite
	POST_PROPER_BOMB_INIT = 2, --After doing that thingy
}

for _, v in pairs(CustomBombModifiersAPI.Callbacks.ID) do
	if not CustomBombModifiersAPI.Callbacks.RegisteredCallbacks[v] then
		CustomBombModifiersAPI.Callbacks.RegisteredCallbacks[v] = {}
	end
end

CustomBombModifiersAPI.CallbackPriority = {
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
function CustomBombModifiersAPI.Callbacks.AddPriorityCallback(id, priority, func, ...)
	local callbacks = CustomBombModifiersAPI.Callbacks.RegisteredCallbacks[id]
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
function CustomBombModifiersAPI.Callbacks.AddCallback(id, func, ...)
	CustomBombModifiersAPI.Callbacks.AddPriorityCallback(id, CustomBombModifiersAPI.CallbackPriority.NORMAL, func, ...)
end

---@param id string
---@param func function
function CustomBombModifiersAPI.Callbacks.RemoveCallback(id, func)
	local callbacks = CustomBombModifiersAPI.Callbacks.RegisteredCallbacks[id]
	for i = #callbacks, 1, -1 do
		if callbacks[i].Function == func then
			table.remove(callbacks, i)
		end
	end
end

function CustomBombModifiersAPI.Callbacks.FireCallback(callbackId, ...)
	local callbacks = Mod.Callbacks.RegisteredCallbacks[callbackId]
	if callbacks ~= nil then
		return Mod.CallbackHandlers[callbackId](callbacks, ...)
	end
end

CustomBombModifiersAPI.CallbackHandlers = {
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
				callbacks[i].Function(CustomBombModifiersAPI, bomb, player, extraData)
			end

			::continue::
		end
	end,

	[Mod.Callbacks.ID.PRE_PROPER_BOMB_INIT] = function (callbacks, bomb, player)
		for i = 1, #callbacks do --No extra parameters
			callbacks[i].Function(CustomBombModifiersAPI, bomb, player)
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
				callbacks[i].Function(CustomBombModifiersAPI, bomb, player)
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

---Explosion will always be in the same position
function Mod:IsNotBomberBoyExplosion(effect, spawner)
	return (effect.Position.X == spawner.Position.X) and (effect.Position.Y == spawner.Position.Y)
end

---Decoy from Best Friend is LITERALLY a bomb (4.2.0, lmfao)
---
---But it doesn't have an explode animation, so I have to check for the last frame manually :P
function Mod:DecoyExplosion(decoy)
	if decoy.Variant ~= BombVariant.BOMB_DECOY then return false end

	return (decoy:GetData().ReEnter and 45 or 151) - decoy.FrameCount == 0
end

function Mod:DecoyReInit(decoy)
	decoy:GetData().ReEnter = decoy.SpawnerEntity == nil --SpawnerEntity is nil for one frame only on re enter (lol?)
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, Mod.DecoyReInit, BombVariant.BOMB_DECOY)

--endregion

--#region Bomb States

function CustomBombModifiersAPI:ChangeVariant(bomb, identifier, bombData)
	local variant = bombData.Variant
	local isCopper = CopperBombSprite and FiendFolio and (bomb.Variant == FiendFolio.BOMB.COPPER)

    if (isCopper or bomb.Variant == 0) and variant then --Change skin if normal bomb
		if not isCopper then 
			bomb.Variant = variant
		end

		local path = bombData.Path

		if not path then goto continue end

		local sprite = bomb:GetSprite()
        local anim = sprite:GetAnimation()
        local file = sprite:GetFilename()

        local spritesheetSuffix = ""

		if isCopper then
			spritesheetSuffix = "_copper"
		elseif bombData.AddPathSuffixOnGolden and bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
			spritesheetSuffix = "_gold"
		end

        sprite:Load(path .. spritesheetSuffix .. file:sub(file:len()-5), true)
        sprite:Play(anim, true)
    end

	::continue::

    bomb:GetData()[identifier] = true
end

---@param bomb EntityBomb
function CustomBombModifiersAPI:ProperBombInit(bomb, player)
    if not player then return end
    if CustomBombModifiersAPI.BLACKLISTED_VARIANTS[bomb.Variant] then return end

	local HasNancy = player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS)
	local NancyRNG = HasNancy and player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS) or nil

    --Detect nancy bombs anddddd the dr fetus from SMB yeah
	for identifier, bombData in pairs(CustomBombModifiersAPI.RegisteredBombs) do
		if bombData.HasModifier(player, bomb) then
		    if bomb.IsFetus then
		        local rng = bomb:GetDropRNG()

		        if rng:RandomInt(100) > bombData.FetusChance(player.Luck) then
		            goto continue
		        end
		    end

		    CustomBombModifiersAPI:ChangeVariant(bomb, identifier, bombData)
		elseif HasNancy then
		    --TODO: Better way to add modifiers by nancy bombs

		    if NancyRNG:RandomInt(100) > bombData.NancyChance then
		        goto continue
		    end

		    CustomBombModifiersAPI:ChangeVariant(bomb, identifier, bombData)
		end

		::continue::
	end
end

---@param bomb EntityBomb
function CustomBombModifiersAPI:BombUpdate(bomb)
    local player = Mod:TryGetPlayer(bomb)

	if bomb.FrameCount == 1 then
		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.PRE_PROPER_BOMB_INIT, bomb, player)
		CustomBombModifiersAPI:ProperBombInit(bomb, player)
		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_PROPER_BOMB_INIT, bomb, player)
	end

    local sprite = bomb:GetSprite()
	if (sprite:IsPlaying("Explode") or Mod:DecoyExplosion(bomb)) then
		if bomb:HasTearFlags(TearFlags.TEAR_SCATTER_BOMB) then
            for _, scatterBomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
				if scatterBomb.FrameCount == 0 then --Just created bomb
					scatterBomb:GetData().IsSmallBomb = true
				end
			end
        end

		local extraData = {}

		if bomb:GetData().IsSmallBomb then
			extraData.SmallExplosion = true
		end

		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, bomb, player, extraData)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, CustomBombModifiersAPI.BombUpdate)

--#endregion

--#region Kamikaze

function CustomBombModifiersAPI:UseKamikaze(_, _, player)
	player:GetData().KamikazeUses = (player:GetData().KamikazeUses or 0) + 1
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.LATE, CustomBombModifiersAPI.UseKamikaze, CollectibleType.COLLECTIBLE_KAMIKAZE)

function CustomBombModifiersAPI:DetectKamikazeByInit(effect, spawner)
    local player = spawner:ToPlayer()

    if not player then return end

    if player:GetData().KamikazeUses then
        player:GetData().KamikazeUses = player:GetData().KamikazeUses - 1
        if player:GetData().KamikazeUses <= 0 then
            player:GetData().KamikazeUses = nil
        end

		local extraData = {
			IsKamikaze = true
		}

        Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, effect, player, extraData)
    end
end

--#endregion

--#region Epic Fetus

function CustomBombModifiersAPI:DetectEpicFetusByInit(effect, spawner)
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

function CustomBombModifiersAPI:DetectWarLocustByInit(effect, spawner)
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

function CustomBombModifiersAPI:DetectBobsBrainByInit(effect, spawner)
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

function CustomBombModifiersAPI:DetectBobsRottenHeadtByInit(effect)
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

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, CustomBombModifiersAPI.DetectBobsRottenHeadtByInit, EffectVariant.SMOKE_CLOUD)

--#endregion

--#region BBF

function CustomBombModifiersAPI:DetectBBFByInit(effect, spawner)
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

function CustomBombModifiersAPI:HotPotatoForgorPEffectUpdate(player)
	if game.Challenge ~= Challenge.CHALLENGE_HOT_POTATO then return end

	local FrameCountRoom = (player.FrameCount - (player:GetData().CBMAPIStartingFrames or 0))
	if (FrameCountRoom % 73 == 0) and FrameCountRoom > 0 then 
		local extraData = {
			IsHotPotato = true
		}

		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, player, player, extraData)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CustomBombModifiersAPI.HotPotatoForgorPEffectUpdate, PlayerType.PLAYER_THEFORGOTTEN_B)

function CustomBombModifiersAPI:HotPotatoNewRoom() --Reset frames on new room
	if game.Challenge ~= Challenge.CHALLENGE_HOT_POTATO then return end

	Mod:ForEachPlayer(function(player)
		if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then
			player:GetData().CBMAPIStartingFrames = player.FrameCount - 1
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, CustomBombModifiersAPI.HotPotatoNewRoom)

--#endregion

function CustomBombModifiersAPI:CustomBombInteractionsInit(effect)
	local spawner = effect.SpawnerEntity

	if spawner then
		CustomBombModifiersAPI:DetectKamikazeByInit(effect, spawner) --Kamikaze
		--CustomBombModifiersAPI:DetectHotPotatoByInit(effect) --Hot Potato
		CustomBombModifiersAPI:DetectEpicFetusByInit(effect, spawner) --Epic Fetus
		if spawner.Type == EntityType.ENTITY_FAMILIAR then
			CustomBombModifiersAPI:DetectBobsBrainByInit(effect, spawner) --Bob's Brain
			CustomBombModifiersAPI:DetectWarLocustByInit(effect, spawner) --War Locust
			CustomBombModifiersAPI:DetectBBFByInit(effect, spawner) --BBF
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, CustomBombModifiersAPI.CustomBombInteractionsInit, EffectVariant.BOMB_EXPLOSION)

--#region Base Game callbacks, passing a modifier



if REPENTOGON then
	
end

--#endregion
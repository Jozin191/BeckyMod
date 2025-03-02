---@diagnostic disable

--CBMAPI Created by [No need to credit directly on the page, though a thanks would be appreciated]:
-- * Tiburones202

CustomBombModifiersAPI = RegisterMod("CustomBombModifiersAPI", 1)
CustomBombModifiersAPI.Version = 1 --v1.0.0 release

local Mod = CustomBombModifiersAPI

CustomBombModifiersAPI.DefaultFetusChance = function(luck) return 11 + (3 * luck) end --Brimstone bombs chance as a placeholder
CustomBombModifiersAPI.DefaultNancyChance = 5

CustomBombModifiersAPI.BLACKLISTED_VARIANTS = {
    [BombVariant.BOMB_GIGA] = true,
    [BombVariant.BOMB_THROWABLE] = true,
}
--[[
--TODO: List
* Kamikaze support [OK]
* Epic Fetus support [OK]
	** Forgotten support [X]
* War Locust support [OK]
* BFF support [X]
* Bob's Brain support [X]
* Best Friend support [X]
* Bob's Rotten Head support [X]

* Hot Potato support [X]

* Base game callbacks with modifier limiters [X]

* Epiphany Zip Bombs support (broken on Epiphany's side?) [X]

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

	--Old modified ones, having to pass the identifier

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
		    if false then return end --TODO: Check if unlocked

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
		CustomBombModifiersAPI:ProperBombInit(bomb, player)
	end

    local sprite = bomb:GetSprite()
	if sprite:IsPlaying("Explode") then
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

--[[
function CustomBombModifiersAPI:Poop1(bomb)
	bomb:GetData()["Null Bomb"] = true
end
Mod:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, CustomBombModifiersAPI.Poop1)
]]

--#endregion

--#region Kamikaze

function CustomBombModifiersAPI:UseKamikaze(_, _, player)
	player:GetData().KamikazeUses = (player:GetData().KamikazeUses or 0) + 1
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_USE_ITEM, CallbackPriority.LATE, CustomBombModifiersAPI.UseKamikaze, CollectibleType.COLLECTIBLE_KAMIKAZE)

function CustomBombModifiersAPI:DetectKamikazeByInit(effect)
    local player = effect.SpawnerEntity

    if not player then return end

    player = player:ToPlayer()

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

function CustomBombModifiersAPI:DetectEpicFetuseByUpdate(effect)
	local player = Mod:TryGetPlayer(effect)

	if not player then return end

	if effect.FrameCount == 10 then
		local extraData = {
			IsEpicFetus = true
		}
		
		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, effect, player, extraData)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, CustomBombModifiersAPI.DetectEpicFetuseByUpdate, EffectVariant.ROCKET)

--#endregion

--#region Locust of War

function CustomBombModifiersAPI:DetectEpicFetuseByUpdate(effect)
	local player = effect.SpawnerEntity:ToPlayer()

	if not player then return end

	if effect.FrameCount == 10 then
		local extraData = {
			IsEpicFetus = true
		}
		
		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, effect, player, extraData)
	end
end

--#endregion

function CustomBombModifiersAPI:CustomBombInteractionsInit(effect)
	CustomBombModifiersAPI:DetectKamikazeByInit(effect) --Kamikaze
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, CustomBombModifiersAPI.CustomBombInteractionsInit, EffectVariant.BOMB_EXPLOSION)

function CustomBombModifiersAPI:CustomBombInteractionsFlyCollision(fly, Collider)
	if fly.SubType == 1 then --War fly
		local enemy = Collider:ToNPC()
		
		if not enemy then goto continue end
		if (not enemy:IsVulnerableEnemy()) or (not enemy:IsActiveEnemy(false)) or enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then goto continue end

		local extraData = {
			IsWarLocust = true,
			SmallExplosion = true,
		}
		
		Mod.Callbacks.FireCallback(Mod.Callbacks.ID.POST_BOMB_EXPLODE, fly, Mod:TryGetPlayer(fly), extraData)
	end
	::continue::
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, CustomBombModifiersAPI.CustomBombInteractionsFlyCollision, FamiliarVariant.BLUE_FLY)
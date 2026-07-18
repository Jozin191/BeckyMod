local mod = BeckyMod

--- No idea how to explain this lol.
--- I got the formula for this from the tboi modding discord resource page, from a guide by catinsurance.
function mod:toTearsPerSecond(maxFireDelay)
    return 30 / (maxFireDelay + 1)
end
  
function mod:toMaxFireDelay(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

function mod:ForEachPlayer(func)
	for i, player in ipairs(PlayerManager.GetPlayers()) do
		if func(player, i) then
			return true
		end
	end
end

--- Returns true if there is a curse present.
--- Mods can modify this (Look at the Epiphany compatibility to see how it's done).
function mod:areThereCurses()
    return BeckyMod.Game:GetLevel():GetCurses() > 0
end

-- Prints a group of given strings/numbers to both console and log.txt.
-- If luadebug is on, the output is prefixed by name of current file
-- and function that called Log, as well as line Log was called from.
---@function
function BeckyMod:Log(...)
	local str = ""
	if debug then               -- only passes if luadebug is on
		local info = debug.getinfo(2) -- get info on the function that called BeckyMod:Log
		if info.func == mod.DebugLog then
			info = debug.getinfo(3)
		end
		local file = info.short_src
		file = file:match("^.+/(.+)$") -- get full path to the file and trim it to just the filename.lua
		if file then             -- file may be nil after match if BeckyMod:Log was called from console
			local funcName = info.name
			funcName = (funcName or tostring(info.func):gsub("^function: ", "f:")) .. ":" .. info.currentline
			str = string.format("[%s:%s] ", file, info.currentline)
		end
	else
		str = str .. "[BeckyMod] "
	end
	local args = { ... }
	for i = 1, #args do
		args[i] = tostring(args[i])
	end
	str = str .. table.concat(args, " ")
	print(str)
	Isaac.DebugString(str)
end

function BeckyMod:Lerp(first, second, percent, smoothIn, smoothOut) --woah siiickkkk
    if smoothIn then
        percent = percent ^ smoothIn
    end

    if smoothOut then
        percent = 1 - percent
        percent = percent ^ smoothOut
        percent = 1 - percent
    end

	return (first + (second - first)*percent)
end

function BeckyMod:InverseLerp(first, second, percent)
	return (percent - first) / (second - first)
end

--Checks if something is in a table
---@param table Table
---@param element any
function BeckyMod:CheckTableContents(table, element)
	for _, value in pairs(table) do
	  	if value == element then
			return true
	  	end
	end
	return false
end

function BeckyMod:removeSubstring(str, substr)
	str = str or "Null Name"
	substr = substr or "Null"
   local startIndex, endIndex = string.find(str, substr)
 
    if startIndex and endIndex then
        local prefix = string.sub(str, 1, startIndex - 1)
        local suffix = string.sub(str, endIndex + 1)
        return prefix .. suffix
    end
    return str
end

function BeckyMod:gsubMany(string, ...)

  local words = {...}

  for i = 1, #words do
    if type(words[i]) == "string" then
      string = string:gsub(words[i], '')
    end
  end

  return string 
end


-- thanks bobbymod (i cvs added this so this is self promo)

function BeckyMod:NestVariable(tab, variable, ... )
	if not tab or type(tab) ~= "table" then
		error("Did not give Table!")
	end

	local keys = { ... }


	for i, key in ipairs(keys) do

		key = tostring(key)

		if i < #keys+1 and (type(tab) == "table") then
			if not tab[key] or (tab and type(tab[key]) ~= "table") then
				tab[key] = i < #keys and {} or variable
			else
				tab[key] = i < #keys and tab[key] or variable
			end

			tab = tab[key]
		end

	end	--return tab
end

function BeckyMod:GetNestedVariable(tab, ... )
    
	if not tab or type(tab) ~= "table" then
		error("Did not give Table!")
	end

	local keys = { ... }

	for i = 1, #keys do
		if not tab[tostring(keys[i])] then
			return false
		end
		tab = tab[tostring(keys[i])]
	end
	return tab
end

---Equivalent to BeckyMod:Log, but only prints if mod.FLAGS.Debug is set to true.
---@function
function BeckyMod:DebugLog(...)
	if mod.FLAGS.Debug then
		mod:Log(...)
	end
end

---@param beamType
---|0  #Default Instant Crack the Sky. 17 frames of hitbox
---|1  #2 frames of hitbox before turning into SubType 10
---|2  #Delayed with a visual cue. 17 frames of hitbox
---|10 #Visual only, no hitbox
---@param pos Vector
---@param spawner Entity
---@param parent Entity
---@param damage number
---@return EntityEffect
function BeckyMod:FireHolyBeam(beamType, pos, spawner, parent, damage)
	local beam = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, beamType, pos, Vector.Zero, spawner):ToEffect()
	---@cast beam EntityEffect

	beam.Parent = parent
	beam.CollisionDamage = damage
	beam:Update()
	return beam
end

---Deal chances are stupid.
---@param chance number
---@param percent number
---@return number	
function BeckyMod:addPercentToDealChance(chance, percent)
	return chance * (1 + percent/100)
end

function BeckyMod:forceAngelDevil(angel, devil, force)
	local level = game:GetLevel()

	if force then
		level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX).Data = nil
	end

	level:InitializeDevilAngelRoom(angel, devil)
end

function BeckyMod.AnyoneHasTrinketPlusGolden(ItemID)
	return PlayerManager.AnyoneHasTrinket(ItemID) or PlayerManager.AnyoneHasTrinket(ItemID | TrinketType.TRINKET_GOLDEN_FLAG)
end

function BeckyMod:IsAnyKeeper(player)
	local type = player:GetPlayerType()
	return type == PlayerType.PLAYER_KEEPER or type == PlayerType.PLAYER_KEEPER_B or (Epiphany and type == Epiphany.PlayerType.KEEPER)
end

function BeckyMod:IsAnyoneKeeper()
	for _, player in ipairs(PlayerManager.GetPlayers()) do
		if BeckyMod:IsAnyKeeper(player) then
			return true
		end
	end
end

---Will attempt to find the player using the attached Entity, EntityRef, or EntityPtr.
---Will return if its a player, the player's familiar, or loop again if it has a SpawnerEntity
---@param ent Entity | EntityRef | EntityPtr
---@param directOnly? boolean
---@return EntityPlayer?
function BeckyMod:TryGetPlayer(ent, directOnly)
	if not ent then return end
	if string.find(getmetatable(ent).__type, "EntityPtr") then
		if ent.Ref then
			return BeckyMod:TryGetPlayer(ent.Ref)
		end
	elseif string.find(getmetatable(ent).__type, "EntityRef") then
		if ent.Entity then
			return BeckyMod:TryGetPlayer(ent.Entity)
		end
	elseif ent:ToPlayer() then
		return ent:ToPlayer()
	elseif ent:ToFamiliar() and ent:ToFamiliar().Player and not directOnly then
		return ent:ToFamiliar().Player
	elseif ent.SpawnerEntity and not directOnly then
		return BeckyMod:TryGetPlayer(ent.SpawnerEntity)
	end
end

---@param ent Entity
---@return boolean
function BeckyMod.IsEnemy(ent)
	return ent:IsActiveEnemy() and ent:IsVulnerableEnemy()
end


function BeckyMod.RandomFloat(min, max, rng)
	min = min or 0
	max = max or 1

	if min > max then
		local v = max
		max = min
		min = v
	end

	return min + rng:RandomFloat() * (max - min)
end

--- This isn't mine and I cant remember where i got it from
local bloodTearTable = {
    [TearVariant.BLUE] = TearVariant.BLOOD,
    [TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
    [TearVariant.NAIL] = TearVariant.NAIL_BLOOD,
    [TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
    [TearVariant.GODS_FLESH] = TearVariant.GODS_FLESH_BLOOD,
    [TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA_BLOOD,
    [TearVariant.EYE] = TearVariant.EYE_BLOOD,
}

---@param tear EntityTear
function BeckyMod.TryChangeTearToBloodVariant(tear)
    if bloodTearTable[tear.Variant] then
        tear:ChangeVariant(bloodTearTable[tear.Variant])
    end
end

local cache_GetData = {} --- this is a lua version of GetData
---@param ent Entity
---@return table
function BeckyMod.GetEntData(ent)
	if not ent then return {} end
	local ptr = GetPtrHash(ent)
	if not cache_GetData[ptr] then cache_GetData[ptr] = {} end
	return cache_GetData[ptr]
end
BeckyMod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, 10000, function(_, ent) cache_GetData[ GetPtrHash(ent) ] = nil end) -- clears the table of an entity when is remove
-- the table get clear when the player exit or ends the run (this is just in case because the game should call "Entity Remove" when doing this)
-- it can't use "Post Game Starts" because some entities init before this function calls like the player or familiars (aparently)
BeckyMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function() cache_GetData = {} end)
BeckyMod:AddCallback(ModCallbacks.MC_POST_GAME_END, function() cache_GetData = {} end)


--[[
if not BeckyMod_refreshBallz then
	BeckyMod_refreshBallz = false
end
---@param mod ModReference
---@param refreshBallz boolean
BeckyMod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, function(_, mod, refreshBallz)
	if mod.Name == "Becky" then
		BeckyMod_refreshBallz = true
	end
end)
local GHOSTBALL = Isaac.GetEntityVariantByName("Ghost Ball")
BeckyMod:AddCallback(ModCallbacks.MC_PRE_UPDATE, function(_)
	if BeckyMod_refreshBallz then
		BeckyMod_refreshBallz = false
		local ghosts = Isaac.FindByType(EntityType.ENTITY_FAMILIAR, GHOSTBALL, nil, false)
		for _, v in pairs(ghosts) do
			local ghost = v and v:ToFamiliar()
			if ghost then
				Isaac.RunCallbackWithParam(ModCallbacks.MC_FAMILIAR_INIT, GHOSTBALL, ghost)
			end
		end
	end
end)
]]
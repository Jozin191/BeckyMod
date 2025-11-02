local mod = BeckyMod
local game = mod.Enums.Utils.Game

--- No idea how to explain this lol.
--- I got the formula for this from the tboi modding discord resource page, from a guide by catinsurance.
function BeckyMod:toTearsPerSecond(maxFireDelay)
    return 30 / (maxFireDelay + 1)
end
  
function BeckyMod:toMaxFireDelay(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

function BeckyMod:ForEachPlayer(func)
	for i, player in ipairs(PlayerManager.GetPlayers()) do
		if func(player, i) then
			return true
		end
	end
end

---@param ent Entity
function BeckyMod:IsEnemy(ent)
	return (ent:IsActiveEnemy() and ent:IsVulnerableEnemy())
end

function BeckyMod:GetRoomEnemies()
	local roomEnts = Isaac.GetRoomEntities()
	local enemyTable = {}

	for _, ent in ipairs(roomEnts) do
		if not mod:IsEnemy(ent) then goto continue end

		table.insert(enemyTable, ent)
		::continue::
	end

	return enemyTable
end

---@param rng RNG
---@param chance? number
---@return boolean
function BeckyMod:RandomBoolean(rng, chance)
	return (rng or RNG()):RandomFloat() <= (chance or 0.5)
end


---Helper function for a better management of random floats, allowing to use min and max values, like `math.random()` and `RNG:RandomInt()`
---@param rng? RNG if `nil`, the function will use Mod's `RNG` object instead
---@param min number
---@param max? number if `nil`, returned number will be one between 0 and `min`
function BeckyMod.RandomFloat(rng, min, max)
	if not max then
		max = min
		min = 0
	end

	min = min * 1000
	max = max * 1000

	return (rng or RNG()):RandomInt(min, max) / 1000
end


--- Returns true if there is a curse present.
--- Mods can modify this (Look at the Epiphany compatibility to see how it's done).
---@diagnostic disable-next-line: duplicate-set-field
function BeckyMod:areThereCurses()
    return game:GetLevel():GetCurses() > 0
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

--Checks if something is in a table
---@param table table
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
---@diagnostic disable-next-line: undefined-global
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
local mod = BeckyMod

-- i got the formula for this from the tboi modding discord resource page, from a guide by catinsurance
function mod:toTearsPerSecond(maxFireDelay)
    return 30 / (maxFireDelay + 1)
end
  
function mod:toMaxFireDelay(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

function mod:ForEachPlayer(func)
	if REPENTOGON then
		for i, player in ipairs(PlayerManager.GetPlayers()) do
			if func(player, i) then
				return true
			end
		end
	else
		for i = 0, mod.Game:GetNumPlayers() - 1 do
			if func(Isaac.GetPlayer(i), i) then
				return true
			end
		end
	end
end

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

---Equivalent to BeckyMod:Log, but only prints if mod.FLAGS.Debug is set to true.
---@function
function BeckyMod:DebugLog(...)
	if mod.FLAGS.Debug then
		mod:Log(...)
	end
end